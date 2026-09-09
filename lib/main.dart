import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:t_max/check_service.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/writelog.dart';
import 'package:t_max/pages/home_page.dart';
import 'package:t_max/pages/login_page.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';
import 'common/web_socket_channel.dart';
import 'data/get_theme_color.dart';
import 'data/manager_scale_channel.dart';
import 'data/parse_log.dart';
import 'data/setting_version_info.dart';
import 'generated/l10n.dart';
import 'widget/theme_color.dart';
import 'package:win32/win32.dart';

const String serviceName = "TmaxService";
const bool isServiceVersion = true; //是否是服务版本

/// 应用程序全局入口点。
/// 负责检查 Windows 服务状态、初始化 [WidgetsFlutterBinding]、
/// 限制应用程序单例运行 (通过检测端口绑定) 并启动主界面的 Route 容器。
Future<void> main() async {
  if (isServiceVersion) {
    //如果是服务的话，先检测服务是否开启
    try {
      // 检查服务是否安装
      bool isInstalled = await checkServiceInstalled(serviceName);
      if (!isInstalled) {
        // 弹框提示服务未安装
        if (Platform.isWindows) {
          MessageBox(
            HWND_DESKTOP,
            TEXT("Service $serviceName uninstalled"),
            TEXT("Error"),
            MB_ICONERROR | MB_OK,
          );
        } else {
          debugPrint("Service $serviceName uninstalled");
        }
        // exit(0); // Temporarily disabled
      }

      // 检查服务是否正在运行
      bool isRunning = await checkServiceRunning(serviceName);
      if (!isRunning) {
        bool startSuccess = await startServiceWithAdmin(serviceName);

        if (startSuccess) {
          sleep(Duration(seconds: 2));
        } else {
          if (Platform.isWindows) {
            MessageBox(
              HWND_DESKTOP,
              TEXT("Service $serviceName start failed"),
              TEXT("Error"),
              MB_ICONERROR | MB_OK,
            );
          } else {
            debugPrint("Service $serviceName start failed");
          }
          // exit(0); // Temporarily disabled
        }
      }
    } catch (e) {
      if (Platform.isWindows) {
        MessageBox(
          HWND_DESKTOP,
          TEXT("Error: $e"),
          TEXT("Error"),
          MB_ICONERROR | MB_OK,
        );
      } else {
        debugPrint("Error: $e");
      }
      // exit(0); // Temporarily disabled
    }
  }
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await setWindowOptions();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String savedLanguage = prefs.getString('language') ?? 'en_US';
  String savedDarkMode = prefs.getString('darkMode') ?? 'false';

  ipAddress = await readIpAddr();
  if (ipAddress.isEmpty) {
    ipAddress = '127.0.0.1';
  }
  await initPageId();
  await ensureInitialized();
  bool isPortAvailable = await checkAndBindPort();
  if (isPortAvailable) {
    runApp(MyApp(savedLanguage, ipAddress, savedDarkMode == 'true'));
  } else {
    // exit(0); // Temporarily disabled for debugging
    runApp(MyApp(savedLanguage, ipAddress, savedDarkMode == 'true'));
  }
}

/// 读取系统页面 ID 配置并初始化。
/// 将配置好的菜单 ID 与应用白名单加载到全局的 [selectedConfigPaidMenuIds] 和 [selectedAppsPaidMenuIds] 集合中进行校验。
Future<void> initPageId() async {
  Map<String, dynamic> pageIds = await readPageIdsFromJsonReversed();
  if (pageIds.isNotEmpty) {
    Set<int> configPages = Set.from(pageIds['configPageList'] ?? []);
    Set<int> appPages = Set.from(pageIds['appPagedList'] ?? []);

    selectedConfigPaidMenuIds = configPages;
    selectedAppsPaidMenuIds = appPages;

    if (!selectedConfigPaidMenuIds.contains(0)) {
      selectedConfigPaidMenuIds.add(0);
    }

    defualtSelectPage = pageIds['defaultPageId'];
    if (defualtSelectPage == '/settingsConfig') {
      defualtSelectPage = '/setConfig';
    }
  }
}

/// 检测并抢占单一进程专属端口号 (例如 58581)。
/// 用于判断是否已有同名程序正在运行，以此实现应用程序在桌面端的单例启动 (Single Instance)。
Future<bool> checkAndBindPort() async {
  ServerSocket? serverSocket;
  try {
    // 尝试创建ServerSocket来绑定端口20015
    serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 58581);
    debugPrint(serverSocket.address.toString());
    return true; // 成功绑定端口，说明应用之前没开启，现在可以占用该端口继续
  } catch (e) {
    return false; // 端口已被占用，推测应用已在运行
  }
}

/// 异步初始化系统关键依赖。
/// 加载本地动态色板（JSON 格式）绑定给全局 [colorTheme]，并准备系统标题栏参数。
Future<void> ensureInitialized() async {
  colorTheme = await loadColorsFromJson();
  await mySystemVersionInfo.getTitle();
}

/// 设定桌面客户端 (Windows, macOS, Linux) 的窗口初始参数。
/// 包括设定初始宽高[Size]、隐藏原生的操作条 (TitleBarStyle) 等深度个性化设定。
Future<void> setWindowOptions() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1320, 720));
  }

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1320, 720),
    minimumSize: Size(1320, 720),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false, // 底部任务栏是否显示 true 不显示
    titleBarStyle:
        TitleBarStyle.hidden, //隐藏控制栏，TitleBarStyle.hidden, // 标题栏的图标是否显示
    windowButtonVisibility: true, // 没有作用呢
    title: '',
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    windowManager.setMinimizable(true);
    windowManager.setResizable(true);
  });
}

/// 读取配置文件中设置的 IP 地址。
/// 作为后期底层 [WebSocket] 与服务网关进行绑定的目标地。
Future<String> readIpAddr() async {
  String contentStr = '';
  String logFilePath = await getAppFilePath(myIpConfig);
  // 检查文件是否存在
  bool fileExists = await File(logFilePath).exists();
  if (!fileExists) {
    return contentStr;
  }
  // 追加写入日志
  String fileContent = await File(logFilePath).readAsString();
  return fileContent;
}

/// Flutter 框架的最核心根 Widget。
/// 它负责在 Build 阶段前拉起后端的 [WebSocketManager] 进行实时通讯连接。
/// 同时管理全局 [ThemeData] 的下发与多语言国际化 [localizationsDelegates] 的挂载支持。
class MyApp extends StatelessWidget {
  const MyApp(this.savedLanguage, this.ipAddr, this.savedDarkMode, {super.key});
  final String savedLanguage;
  final String ipAddr;
  final bool savedDarkMode;

  // 重写build 方法，build 方法返回值为Widget类型，返回内容为屏幕上显示内容。
  @override
  Widget build(BuildContext context) {
    writelog('go to start ui');
    final WebSocketManager socketManager = WebSocketManager();
    socketManager.connect();

    return MaterialApp(
      //自定义主题
      theme: themeColor(colorTheme, savedDarkMode),
      scrollBehavior: DesktopScrollBehavior(), //触屏支持滚动
      // 国际化
      localizationsDelegates: const [
        // 本地化的代理类
        S.delegate,
        GlobalMaterialLocalizations.delegate, //为使material组件支持多语言
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate, // 定义组件默认的文本方向，从左到右或从右到左
      ],
      // 应用支持的语言列表
      supportedLocales: S.delegate.supportedLocales,
      locale: Locale(savedLanguage.split('_')[0],
          savedLanguage.split('_')[1]), // locale: Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => MyHomePage(),
      },
    );
  }

  Future<bool> checkServerExists() async {
    try {
      var channel = await Socket.connect('127.0.0.1', webPort);
      channel.close();
      return true;
    } catch (e) {
      return false;
    }
  }
}
