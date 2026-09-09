import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_max/data/company_info.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/sys_user_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';

import 'package:t_max/dialog/exit_app_dialog.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/common/window_lifecycle_mixin.dart';

import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with WindowLifecycleMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rememberController =
      TextEditingController(text: "false");

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String backImgPath = 'assets/images/background.png';
  bool _showPassword = false;
  bool firstTime = true; // 第一次点击登录
  bool _checkingUsers = true;

  DateTime _lastKeyTime = DateTime.now();
  String _rfidBuffer = '';
  bool _isSwipingCard = false;

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final now = DateTime.now();
    final int diff = now.difference(_lastKeyTime).inMilliseconds;
    _lastKeyTime = now;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      if (_rfidBuffer.isNotEmpty && (_isSwipingCard || _rfidBuffer.length >= 3)) {
        final String scannedRfid = _rfidBuffer.trim();
        _rfidBuffer = '';
        _isSwipingCard = false;
        if (scannedRfid.isNotEmpty && !_isLoading) {
          _submitRfidLogin(scannedRfid);
          return true;
        }
      }
      _rfidBuffer = '';
      _isSwipingCard = false;
      return false;
    }

    final String? char = event.character;
    if (char != null && char.isNotEmpty && char.codeUnitAt(0) >= 32) {
      if (diff < 80) {
        _isSwipingCard = true;
        _rfidBuffer += char;
      } else {
        _isSwipingCard = false;
        _rfidBuffer = char;
      }
    }

    return false;
  }

  void _submitRfidLogin(String rfid) {
    setState(() {
      _isLoading = true;
    });
    PublicFunctions.userRfidLogin(rfid);
  }

  Future<void> _submitLogin() async {
    firstTime = false;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      PublicFunctions.userLogin(
          _usernameController.text, _passwordController.text, false);
    }
  }

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
    getPasswordSetting();
  }

  void getPasswordSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account = prefs.getString('account') ?? '';
    String password = prefs.getString('password') ?? '';
    bool isRemember = prefs.getBool('isRemember') ?? false;
    if (isRemember) {
      setState(() {
        _usernameController.text = account;
        _passwordController.text = password;
        _rememberController.text = "true";
      });
    }
  }

  @override
  void initState() {
    initWindowLifecycle();
    super.initState();
    _checkingUsers = checkingUsers;
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);

    _eventbus1 = eventBus.on<EventRespLogin>().listen((event) {
      if (mounted) {
        setState(() {
          String dataString = event.obj;
          if (dataString.contains('ok')) {
            PublicFunctions.getUserInfo(_usernameController.text);
            savePasswordSetting(_usernameController.text,
                _passwordController.text, _rememberController.text == "true");
          } else {
            _isLoading = false;
            showTipInfo(localizedStrings.tipLoginError, context);
          }
        });
      }
    });

    _eventbus2 = eventBus.on<EventRespGetUserDetail>().listen((event) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          String dataString = event.obj;
          try {
            mySysUser = sysUserDetailFromDbFromJson(dataString);
            if (mySysUser.roleId == superAdminRoleId ||
                mySysUser.roleId == adminRoleId) {
              mySysUser.pageIdList = allPageIdList;
            }
          } catch (e) {
            showTipInfo(localizedStrings.tipLoginError, context);
          }
          if (mySysUser.initialPageId != null) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            showTipInfo(localizedStrings.tipLoginError, context);
          }
        });
      }
    });

    _eventbus3 = eventBus.on<EventServiceOff>().listen((event) {
      setState(() {
        showServiceErrorDialog(context, localizedStrings.gTipServiceOff,
            localizedStrings.gTitleConfirm);
      });
    });
    _eventbus4 = eventBus.on<EventRespGetAllUsers>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        List<SysUserFromDb> allUserList = sysUserFromDbFromJson(dataStr);
        setState(() {
          if (allUserList.length == 1) {
            checkingUsers = false;
            SysUserFromDb tempUser = allUserList[0];
            mySysUser.userId = tempUser.userId;
            mySysUser.userName = tempUser.userName;
            mySysUser.password = tempUser.password;
            mySysUser.nickName = tempUser.nickName;
            mySysUser.roleId = tempUser.roleId;
            mySysUser.isEnabled = tempUser.isEnabled;
            mySysUser.email = tempUser.email;
            mySysUser.phone = tempUser.phone;
            mySysUser.initialPageId = tempUser.initialPageId;
            mySysUser.isChanged = tempUser.isChanged;
            mySysUser.pageIdList = allPageIdList;
            mySysUser.roleName = "super_admin";
            PublicFunctions.userLogin(mySysUser.userName!, '', true);
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            _checkingUsers = false;
            checkingUsers = false;
          }
        });
      }
    });

    _eventbus5 = eventBus.on<EventRespRfidLogin>().listen((event) {
      if (mounted) {
        setState(() {
          String dataString = event.obj;
          if (dataString.startsWith('ok')) {
            List<String> parts = dataString.split(',');
            if (parts.length > 1 && parts[1].isNotEmpty) {
              String userName = parts[1];
              PublicFunctions.getUserInfo(userName);
            } else {
              _isLoading = false;
              showTipInfo(localizedStrings.tipLoginError, context);
            }
          } else {
            _isLoading = false;
            if (dataString.contains('user disabled')) {
              showTipInfo(localizedStrings.tipAccountDisabled, context);
            } else {
              showTipInfo(localizedStrings.tipRfidNotFound, context);
            }
          }
        });
      }
    });

    // 所有初始化完成后设置默认页面
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();

    _usernameController.dispose();
    _passwordController.dispose();
    _rememberController.dispose();
    _formKey.currentState?.dispose();
    _isLoading = false;

    disposeWindowLifecycle();

    super.dispose();
  }

  void savePasswordSetting(String account, String password, bool isSave) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('account', account);
    await prefs.setString('password', password);
    await prefs.setBool('isRemember', isSave);
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    double tHeight = MediaQuery.of(context).size.height;
    if (_checkingUsers) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40), // 自定义高度
        child: DraggableTitleBar(title: ''),
      ),
      body: Stack(
        children: [
          // 背景图
          Positioned.fill(
            child: Image.asset(
              backImgPath,
              fit: BoxFit.cover, // 确保图片覆盖整个屏幕
            ),
          ),

          SizedBox(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // SizedBox(
                  //   height: 50,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     children: [
                  //       Image.asset(
                  //         'assets/images/company.png',
                  //         width: 138,
                  //         height: 50,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(
                    height: tHeight - 130,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.all(60),
                          width: 420,
                          child: Form(
                            // 添加Form组件包裹输入框
                            key: _formKey, // 关联formKey
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction, // 用户交互时自动验证
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: Text(
                                    myAppName.appName!,
                                    style: textTheme.titleLarge!.copyWith(
                                      color: colorScheme.surface,
                                      fontSize: 42,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 36),
                                SizedBox(
                                  height: 80,
                                  child: TextFormField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      prefixIcon: Icon(
                                        size: 18,
                                        Icons.person_outline,
                                        color: colorScheme.primary,
                                      ),
                                      fillColor: colorScheme.surface,
                                      filled: true,
                                      hintText: localizedStrings
                                          .tipLoginUsernameEmpty,
                                      hintStyle: textTheme.bodySmall!.apply(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                      ),
                                      counterText: "",
                                      // 验证错误时的边框样式
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: colorScheme.error,
                                            width: 1.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: colorScheme.error,
                                            width: 1.0),
                                      ),
                                    ),
                                    maxLength: 40,
                                    style: textTheme.bodySmall!.apply(
                                      color: colorScheme.onSurface,
                                    ),
                                    // 添加验证器
                                    validator: (value) {
                                      if (firstTime) return null;
                                      if (value == null || value.isEmpty) {
                                        return localizedStrings
                                            .tipLoginUsernameNotEmpty;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 80,
                                  child: TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      prefixIcon: Icon(
                                          size: 18,
                                          Icons.lock_outline,
                                          color: colorScheme.primary),
                                      fillColor: colorScheme.surface,
                                      filled: true,
                                      hintText: localizedStrings
                                          .tipLoginPasswordEmpty,
                                      hintStyle: textTheme.bodySmall!.apply(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          size: 18,
                                          _showPassword
                                              ? Icons.remove_red_eye_outlined
                                              : Icons.visibility_off_outlined,
                                          color: colorScheme.onSurface,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showPassword = !_showPassword;
                                          });
                                        },
                                      ),
                                      counterText: "",
                                      // 验证错误时的边框样式
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: colorScheme.error,
                                            width: 1.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: colorScheme.error,
                                            width: 1.0),
                                      ),
                                    ),
                                    obscureText: !_showPassword,
                                    obscuringCharacter: '*',
                                    style: textTheme.bodySmall!.apply(
                                      color: colorScheme.onSurface,
                                    ),
                                    maxLength: 15,
                                    // 添加验证器
                                    validator: (value) {
                                      if (firstTime) return null;

                                      if (value == null || value.isEmpty) {
                                        return localizedStrings
                                            .tipLoginPasswordNotEmpty;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Checkbox(
                                          activeColor: colorScheme.primary,
                                          value: _rememberController.text ==
                                              "true",
                                          side: BorderSide(
                                              width: 1.0,
                                              color: colorScheme.surface),
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == null) return;
                                              if (value) {
                                                _rememberController.text =
                                                    "true";
                                              } else {
                                                _rememberController.text =
                                                    "false";
                                              }
                                            });
                                          },
                                        ),
                                        Text(
                                          localizedStrings.tipLoginRemember,
                                          style: textTheme.bodySmall!.apply(
                                            color: colorScheme.surface,
                                          ),
                                        ),
                                      ],
                                    )),
                                SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  height: btnHeight,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submitLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                    ),
                                    child: _isLoading
                                        ? const CircularProgressIndicator()
                                        : Text(
                                            localizedStrings.btnLogin,
                                            style: textTheme.bodySmall!.apply(
                                              color: colorScheme.surface,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> with WindowListener {
  final StreamController<bool> _maximizedStreamController =
      StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    // 注册监听器
    windowManager.addListener(this);
    _initMaximizedState();
  }

  Future<void> _initMaximizedState() async {
    _maximizedStreamController.add(await windowManager.isMaximized());
  }

  // 实现 WindowListener 接口的 onWindowMaximize 方法
  @override
  void onWindowMaximize() {
    _maximizedStreamController.add(true);
  }

  // 实现 WindowListener 接口的 onWindowUnmaximize 方法
  @override
  void onWindowUnmaximize() {
    _maximizedStreamController.add(false);
  }

  @override
  void dispose() {
    // 移除监听器
    windowManager.removeListener(this);
    _maximizedStreamController.close();
    super.dispose();
  }

  // 定义常量
  static const buttonSize = Size(45, 32);
  static const iconSize = 16.0;

  // 公共按钮样式
  ButtonStyle get baseButtonStyle => ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        minimumSize: WidgetStateProperty.all(buttonSize),
        maximumSize: WidgetStateProperty.all(buttonSize),
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return Colors.black12;
          }
          if (states.contains(WidgetState.pressed)) {
            return Colors.black26;
          }
          return Colors.transparent;
        }),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        )),
      );

  // 创建最小化按钮
  Widget _buildMinimizeButton() {
    return IconButton(
      style: baseButtonStyle,
      icon: Icon(
        Icons.remove,
        size: iconSize,
        color: Colors.black,
      ),
      onPressed: () => windowManager.minimize(),
    );
  }

  // 创建最大化/还原按钮
  Widget _buildMaximizeButton() {
    return IconButton(
      style: baseButtonStyle,
      icon: StreamBuilder<bool>(
        stream: _maximizedStreamController.stream,
        initialData: false,
        builder: (context, snapshot) {
          final isMaximized = snapshot.data ?? false;
          return Icon(
            isMaximized ? Icons.fullscreen_exit_sharp : Icons.fullscreen_sharp,
            size: iconSize,
            color: Colors.black,
          );
        },
      ),
      onPressed: () async {
        if (await windowManager.isMaximized()) {
          windowManager.unmaximize();
        } else {
          windowManager.maximize();
        }
      },
    );
  }

  // 创建关闭按钮
  Widget _buildCloseButton() {
    return IconButton(
      style: baseButtonStyle.copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.pressed)) {
            return Colors.red;
          }
          return Colors.black;
        }),
      ),
      icon: Icon(
        Icons.close_sharp,
        size: iconSize,
        color: Colors.black,
      ),
      onPressed: () async {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false, // 允许点击空白处关闭对话框
            builder: (context) {
              return CustomAlertDialog(
                titleText: localizedStrings.gTipExitApp,
                onNoPressed: () {
                  Navigator.of(context).pop();
                },
                onYesPressed: () async {
                  Navigator.of(context).pop();
                  dispose();
                  await trayManager.destroy(); //退出系统托盘
                  await windowManager.destroy();
                  exit(0);
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildMinimizeButton(),
        _buildMaximizeButton(),
        _buildCloseButton(),
      ],
    );
  }
}

// 可拖拽的标题栏组件
class DraggableTitleBar extends StatelessWidget {
  final Widget? leading; // 左侧图标/内容
  final String title; // 标题文本
  final bool showButtons; // 是否显示窗口按钮

  const DraggableTitleBar({
    super.key,
    this.leading,
    required this.title,
    this.showButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 关键：添加拖拽事件处理
      onPanStart: (details) => windowManager.startDragging(),

      // 双击标题栏时切换窗口最大化/还原
      onDoubleTap: () async {
        if (await windowManager.isMaximized()) {
          windowManager.unmaximize();
        } else {
          windowManager.maximize();
        }
      },

      child: Container(
        height: 32, // 标题栏高度
        color: Color(0xFFF0F0F0), // 标题栏背景色
        child: Row(
          children: [
            if (leading != null) leading!,
            SizedBox(width: 8), // 左侧图标和标题之间的间距
            Image.asset(appIconPath, width: 20, height: 20), // 左侧图标

            // 标题文本
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // 窗口控制按钮
            if (showButtons) WindowButtons(),
          ],
        ),
      ),
    );
  }
}
