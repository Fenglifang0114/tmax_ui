import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:t_max/data/manager_scale_channel.dart';

// 自定义滚动行为，支持触摸和鼠标设备
class DesktopScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch, // 支持触摸设备
        PointerDeviceKind.mouse, // 支持鼠标设备
      };
}

/// 获取 macOS 下 Go 后端可执行文件的路径
String getBackendPathMacOS() {
  String exePath = Platform.resolvedExecutable;
  // 如果运行在 .app 包内: .../TMaxPcServiceUI.app/Contents/MacOS/TMaxPcServiceUI
  // 查找 Contents/Resources/tmaxsrv_mac
  String contentsDir = p.dirname(p.dirname(exePath));
  String bundlePath = p.join(contentsDir, 'Resources', 'tmaxsrv_mac');
  if (File(bundlePath).existsSync()) {
    return bundlePath;
  }
  // 备用：同级目录
  String sameDirPath = p.join(p.dirname(exePath), 'tmaxsrv_mac');
  if (File(sameDirPath).existsSync()) {
    return sameDirPath;
  }
  // 备用：当前工作目录
  String cwdPath = p.join(Directory.current.path, 'tmaxsrv_mac');
  if (File(cwdPath).existsSync()) {
    return cwdPath;
  }
  return bundlePath;
}

// 检查服务是否安装 / macOS 下检查 backend 可执行文件是否存在
Future<bool> checkServiceInstalled(String serviceName) async {
  if (Platform.isMacOS) {
    String backendPath = getBackendPathMacOS();
    return File(backendPath).existsSync();
  }
  if (!Platform.isWindows) {
    return true;
  }
  try {
    ProcessResult result = await Process.run(
        'sc',
        [
          'query',
          serviceName,
        ],
        runInShell: true);

    // 检查命令输出，判断服务是否存在
    return result.exitCode == 0 &&
        result.stdout.toString().contains("SERVICE_NAME: $serviceName");
  } catch (e) {
    // debugPrint("check service installed error: $e");

    return false;
  }
}

// 检查服务是否正在运行 / macOS 下检查后台进程是否存在
Future<bool> checkServiceRunning(String serviceName) async {
  if (Platform.isMacOS) {
    try {
      ProcessResult result = await Process.run('/usr/bin/pgrep', ['-f', 'tmaxsrv_mac']);
      return result.exitCode == 0;
    } catch (e) {
      try {
        ProcessResult result = await Process.run('pgrep', ['-f', 'tmaxsrv_mac']);
        return result.exitCode == 0;
      } catch (_) {
        return false;
      }
    }
  }
  if (!Platform.isWindows) {
    return true;
  }
  try {
    ProcessResult result = await Process.run(
        'sc',
        [
          'query',
          serviceName,
        ],
        runInShell: true);

    // 服务状态为RUNNING表示正在运行
    return result.stdout.toString().contains("STATE              : 4  RUNNING");
  } catch (e) {
    // debugPrint("check service running error: $e");
    return false;
  }
}

/// 获取 macOS 下 Go 后端动态库 (.dylib) 的路径
String getBackendDylibPathMacOS() {
  String exePath = Platform.resolvedExecutable;
  // 如果运行在 .app 包内: .../TMaxPcServiceUI.app/Contents/MacOS/TMaxPcServiceUI
  // 查找 Contents/Frameworks/libtmaxsrv.dylib
  String contentsDir = p.dirname(p.dirname(exePath));
  String frameworkPath = p.join(contentsDir, 'Frameworks', 'libtmaxsrv.dylib');
  if (File(frameworkPath).existsSync()) {
    return frameworkPath;
  }
  // 备用：Contents/Resources/libtmaxsrv.dylib
  String resourcePath = p.join(contentsDir, 'Resources', 'libtmaxsrv.dylib');
  if (File(resourcePath).existsSync()) {
    return resourcePath;
  }
  // 备用：同级目录
  String sameDirPath = p.join(p.dirname(exePath), 'libtmaxsrv.dylib');
  if (File(sameDirPath).existsSync()) {
    return sameDirPath;
  }
  // 备用：当前工作目录
  String cwdPath = p.join(Directory.current.path, 'libtmaxsrv.dylib');
  if (File(cwdPath).existsSync()) {
    return cwdPath;
  }
  return frameworkPath;
}

typedef StartGoServerC = ffi.Void Function();
typedef StartGoServerDart = void Function();

Future<bool> startBackendDylibMacOS() async {
  try {
    String dylibPath = getBackendDylibPathMacOS();
    if (!File(dylibPath).existsSync()) {
      debugPrint("macOS Backend dylib not found at: $dylibPath");
      return false;
    }
    debugPrint("Opening macOS Backend dylib: $dylibPath");
    final dylib = ffi.DynamicLibrary.open(dylibPath);
    final StartGoServerDart startServer = dylib
        .lookup<ffi.NativeFunction<StartGoServerC>>('StartGoServer')
        .asFunction();
    startServer();
    debugPrint("macOS Go backend dylib started successfully via FFI!");
    return true;
  } catch (e) {
    debugPrint("macOS start backend dylib error: $e");
    return false;
  }
}

Future<bool> startServiceWithAdmin(String serviceName) async {
  if (Platform.isMacOS) {
    try {
      // 1. 优先尝试通过 FFI 动态库 (.dylib) 在主进程内拉起 Go 服务（终极解决 macOS 沙箱/进程拉起限制）
      bool dylibStarted = await startBackendDylibMacOS();
      if (dylibStarted) {
        for (int i = 0; i < 20; i++) {
          try {
            var socket = await Socket.connect('127.0.0.1', webPort, timeout: const Duration(milliseconds: 500));
            socket.destroy();
            debugPrint("macOS Backend dylib port $webPort is ready!");
            return true;
          } catch (_) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      }

      // 2. 备用降级方案：若未挂载 .dylib，退回为可执行文件拉起模式
      String backendPath = getBackendPathMacOS();
      if (!File(backendPath).existsSync()) {
        debugPrint("macOS Backend file not found: $backendPath");
        return false;
      }
      // 递归清除隔离标记
      try {
        String exePath = Platform.resolvedExecutable;
        String contentsDir = p.dirname(p.dirname(exePath));
        String appBundlePath = p.dirname(contentsDir);
        if (appBundlePath.endsWith('.app')) {
          await Process.run('/usr/bin/xattr', ['-cr', appBundlePath]);
        }
        await Process.run('/usr/bin/xattr', ['-d', 'com.apple.quarantine', backendPath]);
      } catch (_) {}
      try {
        await Process.run('/bin/chmod', ['+x', backendPath]);
      } catch (_) {}
      bool isRunning = await checkServiceRunning(serviceName);
      if (!isRunning) {
        String workDir = p.dirname(backendPath);
        Process process = await Process.start(
          backendPath,
          [],
          mode: ProcessStartMode.detachedWithStdio,
          workingDirectory: workDir,
        );
        process.stdout.listen((_) {});
        process.stderr.listen((_) {});
      }
      for (int i = 0; i < 20; i++) {
        try {
          var socket = await Socket.connect('127.0.0.1', webPort, timeout: const Duration(milliseconds: 500));
          socket.destroy();
          debugPrint("macOS Backend port $webPort is ready!");
          return true;
        } catch (_) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      debugPrint("macOS Backend port $webPort polling timeout");
      return false;
    } catch (e) {
      debugPrint("macOS start backend error: $e");
      return false;
    }
  }
  if (!Platform.isWindows) {
    return true;
  }
  try {
    // 检查当前是否具有管理员权限
    bool isAdmin = await _checkAdminPrivileges();

    if (!isAdmin) {
      // 请求管理员权限并重新启动程序
      return await _runAsAdministrator(serviceName);
    } else {
      // 已有管理员权限，直接启动服务
      return await _startService(serviceName);
    }
  } catch (e) {
    // debugPrint('start service with admin error: $e');
    return false;
  }
}

Future<bool> _checkAdminPrivileges() async {
  try {
    // 尝试访问需要管理员权限的系统目录
    final result = await Process.run('net', ['session'], runInShell: true);
    return result.exitCode == 0;
  } catch (e) {
    return false;
  }
}

Future<bool> _runAsAdministrator(String serviceName) async {
  try {
    // 直接使用PowerShell以管理员身份启动sc命令
    final script = '''
      \$proc = Start-Process -FilePath "sc" -ArgumentList "start", "$serviceName" -Verb RunAs -PassThru -WindowStyle Hidden
      \$proc.WaitForExit()
      exit \$proc.ExitCode
    ''';

    final result =
        await Process.run('powershell', ['-Command', script], runInShell: true);
    return result.exitCode == 0;
  } catch (e) {
    // debugPrint('管理员权限启动失败: $e');
    return false;
  }
}

Future<bool> _startService(String serviceName) async {
  try {
    final result = await Process.run('sc', ['start', serviceName]);
    return result.exitCode == 0 &&
        (result.stdout.toString().contains('START_PENDING') ||
            result.stdout.toString().contains('SUCCESS'));
  } catch (e) {
    return false;
  }
}

