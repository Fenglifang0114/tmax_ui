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
      ProcessResult result = await Process.run('pgrep', ['-f', 'tmaxsrv_mac']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
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

Future<bool> startServiceWithAdmin(String serviceName) async {
  if (Platform.isMacOS) {
    try {
      String backendPath = getBackendPathMacOS();
      if (!File(backendPath).existsSync()) {
        debugPrint("macOS Backend file not found: $backendPath");
        return false;
      }
      // 1. 递归清除整个 .app 应用包及内部二进制的隔离标记
      try {
        String exePath = Platform.resolvedExecutable;
        String contentsDir = p.dirname(p.dirname(exePath));
        String appBundlePath = p.dirname(contentsDir);
        if (appBundlePath.endsWith('.app')) {
          await Process.run('xattr', ['-cr', appBundlePath]);
        }
        await Process.run('xattr', ['-d', 'com.apple.quarantine', backendPath]);
      } catch (_) {}
      // 2. 赋予可执行权限
      try {
        await Process.run('chmod', ['+x', backendPath]);
      } catch (_) {}
      // 3. 后台分离模式启动 Go 后端进程（若未运行）
      bool isRunning = await checkServiceRunning(serviceName);
      if (!isRunning) {
        String workDir = p.dirname(backendPath);
        await Process.start(
          backendPath,
          [],
          mode: ProcessStartMode.detached,
          workingDirectory: workDir,
        );
      }
      // 4. 轮询检测后端 TCP 端口（webPort = 7878）是否就绪，解决启动时差问题
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

