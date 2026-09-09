import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

// 自定义滚动行为，支持触摸和鼠标设备
class DesktopScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch, // 支持触摸设备
        PointerDeviceKind.mouse, // 支持鼠标设备
        // 可以根据需要添加其他设备类型
        // PointerDeviceKind.stylus,
        // PointerDeviceKind.invertedStylus,
        // PointerDeviceKind.trackpad,
      };
}

// 检查服务是否安装
Future<bool> checkServiceInstalled(String serviceName) async {
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

// 检查服务是否正在运行
Future<bool> checkServiceRunning(String serviceName) async {
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
