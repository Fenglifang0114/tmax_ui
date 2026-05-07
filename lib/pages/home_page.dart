// //主页

//首页   测试首页
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:t_max/data/company_info.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/dialog_data.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/manager_scale_channel.dart';
import 'package:t_max/data/routes_data.dart';
import 'package:t_max/data/scale_info_from_scale.dart';
import 'package:t_max/data/screen_mgr.dart';
import 'package:t_max/dialog/company_info_dialog.dart';
import 'package:t_max/dialog/exit_app_dialog.dart';
import 'package:t_max/dialog/language_setting.dart';
import 'package:t_max/dialog/sys_user_pwd.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/widget/home_widget.dart';
import 'package:t_max/widget/page_info.dart';
import 'package:t_max/widget/version.dart';
import 'package:t_max/common/window_lifecycle_mixin.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with WindowLifecycleMixin {
  String _selectedNavRoute = '/';
  String lastRouteName = defualtSelectPage; //除了设置外的最后一个路由

  bool isLeftBarCollapsed = false;
  // isResize 已经在 WindowLifecycleMixin 中定义
  DateTime dataTimeNow = DateTime.now();

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;
  dynamic _eventbus9;
  dynamic _eventbus10;

  ScrollController scrollController = ScrollController();
  bool isHovering = false; // 用于控制鼠标悬停状态

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
    Future.delayed(const Duration(milliseconds: 10), () {
      setState(() {
        if (mySysUser.roleId == superAdminRoleId ||
            mySysUser.roleId == adminRoleId) {
          _navigateContent('/multiScaleManagement');
        } else {
          _navigateContent(defualtSelectPage);
        }
      });
    });
  }

  @override
  void initState() {
    initWindowLifecycle();
    super.initState();

    PublicFunctions.getScaleUnstableZeroTare();

    _eventbus1 = eventBus.on<EventDialogData>().listen((event) {
      if (mounted) {
        setState(() {
          myDialogData = event.obj;
        });
      }
    });
    setState(() {
      dataTimeNow = DateTime.now();
    });
    _eventbus2 = eventBus.on<EventMySysUser>().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });

    _eventbus4 = eventBus.on<EventGetFactoryInfo>().listen((event) {
      if (mounted) {
        setState(() {
          myFactoryInfoFromScale = event.obj;
        });
      }
    });

    _eventbus5 = eventBus.on<EventGetOneEepromDateResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.contains('ok')) {
            if (myRespDataFromScale.msgBody.contains('bt')) {
              myScreenMgr.wifiOrBt = 'bt';
            } else if (myRespDataFromScale.msgBody.contains('wifi')) {
              myScreenMgr.wifiOrBt = 'wifi';
            } else if (myRespDataFromScale.msgBody.contains('off')) {
              myScreenMgr.wifiOrBt = 'off';
            }
          }
        });
      }
    });
    _eventbus6 = eventBus.on<EventLicenseData>().listen((event) {
      if (mounted) {
        setState(() {
          var eventInfo = event.obj;
          if (eventInfo.isNotEmpty) {
            var jsonData = json.decode(eventInfo);
            try {
              List<dynamic> jsonList = json.decode(eventInfo);
              if (jsonList.isNotEmpty) {
                myLicenseInfo.pId = jsonList[0]['Id'];
              }
            } catch (e) {
              myLicenseInfo.pId = '';
            }

            try {
              myLicenseData = LicenseData.fromJson(jsonData);
            } catch (e) {
              myLicenseData = LicenseData([]);
            }
            if (myLicenseData.licList.isNotEmpty) {
              LicenseSetting().setLicInfo();
            }
          }
        });
      }
    });
    _eventbus7 = eventBus.on<EventCloseScalePassthResp>().listen((event) {
      if (mounted) {
        PublicFunctions.stopWeight(myDefScaleInfo.defScaleId!);
      }
    });
    _eventbus8 = eventBus.on<EventSerialPortResponse>().listen((event) {
      if (mounted) {
        if (myScreenMgr.isMainScreen) {
          setState(() {
            myRespDataFromScale = event.obj;
            if (myComScaleInfo.isOnline) {
              myComScaleInfo.isOnline = false;
              myComScaleSn.modelName = '';
              myComScaleSn.scaleSn = '';
              myComScaleInfo.isOnline = false;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('The serial port disconnected.',
                      style: const TextStyle(fontSize: 20)), ////此处需要秤回复
                  duration: const Duration(seconds: 5),
                  backgroundColor: Theme.of(context).colorScheme.error));
            }
          });
        }
      }
    });

    _eventbus9 = eventBus.on<EventServiceOff>().listen((event) {
      setState(() {
        showServiceErrorDialog(context, localizedStrings.gTipServiceOff,
            localizedStrings.gTitleConfirm);
      });
    });

    _eventbus10 = eventBus.on<EventGetUnstableZeroTare>().listen((event) {
      if (mounted) {
        setState(() {
          String s = event.obj;
          if (s.isNotEmpty && s.contains("true")) {
            unstableZeroTare = true;
          }
        });
      }
    });

    // 所有初始化完成后设置默认页面
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    _eventbus9.cancel();
    _eventbus10.cancel();

    disposeWindowLifecycle();

    scrollController.dispose();
    super.dispose();
  }

  void _navigateContent(String routeName) {
    setState(() {
      _selectedNavRoute = routeName;
      showLeftNavigationBar = !routeName.startsWith('/settings'); // 控制导航栏显示
    });

    if (routeName.contains('/settings')) {
      if (routeName.contains('/settingsApp')) {
        routeName = routeName.replaceAll('/settingsApp', '');
      }

      contentNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              buildPageContent(_navigateContent, routeName, null),
        ),
        (route) => false, // 这个条件永远返回 false，表示移除所有现有路由
      );
    } else {
      lastRouteName = routeName;
      // contentNavigatorKey.currentState?.pushReplacementNamed(routeName);
      contentNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              buildPageContent(_navigateContent, routeName, null),
        ),
        (route) => false, // 这个条件永远返回 false，表示移除所有现有路由
      );
    }
  }

  Widget showNavigationBar() {
    // 获取层级菜单数据
    final hierarchicalMenus = getHierarchicalConfigMenus();

    return ListView.builder(
      itemCount: hierarchicalMenus.length,
      itemBuilder: (context, index) {
        final group = hierarchicalMenus[index];
        return _buildMenuGroup(group, index);
      },
    );
  }

  final Map<int, bool> _expandedStates = {};

// 构建菜单组
  Widget _buildMenuGroup(RouteDataGroup group, int groupIndex) {
    if (group.children.isEmpty) {
      return Container();
    }

    // 特殊处理"多台秤管理"组 - 直接作为菜单项跳转
    if (group.title == localizedStrings.menuMultiScaleManagement) {
      // 获取第一个有效路由项
      final effectiveRoute = group.children.firstWhere(
        (item) => item is RouteData,
        orElse: () => RouteData(
          id: 0,
          title: '',
          subtitle: '',
          routeName: '',
          iconPath: '',
        ),
      ) as RouteData?;

      return effectiveRoute != null
          ? _buildMenuItem(effectiveRoute, showIcon: true)
          : Container();
    }

    if (group.title == localizedStrings.menuApplications) {
      final effectiveRoute = group.children.firstWhere(
        (item) => item is RouteData,
        orElse: () => RouteData(
          id: MenuId.appConfigPage,
          title: '',
          subtitle: '',
          routeName: '',
          iconPath: '',
        ),
      ) as RouteData?;

      return effectiveRoute != null
          ? _buildMenuItem(effectiveRoute, showIcon: true)
          : Container();
    }

    return ExpansionTile(
      title: Text(group.title,
          style: Theme.of(context).textTheme.bodySmall!.apply(
                color: Theme.of(context).colorScheme.onPrimary,
              )),
      shape: Border(),
      leading: getSvgIcon(
          group.iconPath, 22, 22, Theme.of(context).colorScheme.onPrimary),
      trailing: Icon(
        (_expandedStates[groupIndex] ?? false)
            ? Icons.expand_less
            : Icons.expand_more,
        color: Theme.of(context).colorScheme.onPrimary, // 设置图标颜色
        size: 20, // 可选：调整图标大小
      ),
      onExpansionChanged: (isExpanded) {
        setState(() {
          _expandedStates[groupIndex] = isExpanded;
        });
      },
      children: group.children.map((item) {
        // 判断子项类型并构建
        if (item is RouteDataGroup) {
          return _buildMenuGroup(item, groupIndex); // 支持嵌套组
        } else if (item is RouteData) {
          return _buildMenuItem(item, isSubMenu: true);
        }
        return Container();
      }).toList(),
    );
  }

// 构建菜单项（增加isSubMenu参数）
  Widget _buildMenuItem(RouteData item,
      {bool showIcon = false, bool isSubMenu = false}) {
    return ShowMenuItem(
      showIcon: showIcon,
      demo: item,
      isExpanded: true,
      isSelected: item.routeName == _selectedNavRoute, // 选中状态
      onTap: () {
        _navigateContent(item.routeName!);
      }, // 点击回调
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    localizedStrings = S.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40), // 自定义高度
        child: DraggableTitleBar(title: ''),
      ),
      body: Row(
        children: [
          // 动态显示的左侧导航栏
          if (showLeftNavigationBar)
            Container(
              width: leftBarWidth,
              color: Theme.of(context).colorScheme.primary, // 可替换为实际内容
              child: Column(children: [
                SizedBox(
                  height: leftBarIconHeight,
                  width: leftBarWidth,
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.only(left: largePadding),
                        iconSize: iconAppSize,
                        onPressed: () {},
                        icon: Image.asset(
                          logoIconPath,
                          width: iconAppSize,
                          height: iconAppSize,
                        ),
                      ),
                      Expanded(
                          child: Container(
                              padding: EdgeInsets.only(left: regularPadding),
                              child: Text(
                                myAppName.appName!,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .apply(
                                        // 根据选中状态改变颜色
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                              )))
                    ],
                  ),
                ),
                Expanded(
                  child: showNavigationBar(),
                ),
                SizedBox(
                  height: largePadding,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 120,
                        height: 40,
                        child: Image.asset(companyImage)),
                  ],
                ),
                SizedBox(
                  height: largePadding,
                )
              ]),
            ),

          // 右侧主区域
          Expanded(
            child: Column(
              children: [
                // 顶部设置栏（始终显示）
                Container(
                  height: topLinePadding,
                  color: colorScheme.surfaceDim,
                ),
                SizedBox(
                  height: topBarHeight,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        showLeftNavigationBar
                            ? Container(
                                padding: EdgeInsets.only(left: largePadding),
                                child: Text(
                                  generateTitle(getPageId(_selectedNavRoute)),
                                  style: textTheme.bodySmall!.apply(
                                      // 根据选中状态改变颜色
                                      color: colorScheme.onSurface),
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.only(left: largePadding),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      appIconPath,
                                      width: iconAppSize,
                                      height: iconAppSize,
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(
                                            left: regularPadding),
                                        child: Text(
                                          myAppName.appName!,
                                          style: textTheme.headlineSmall!.apply(
                                              // 根据选中状态改变颜色
                                              color: colorScheme.primary),
                                        ))
                                  ],
                                ),
                              ),
                        Row(
                          children: [
                            if (generateHelpTitle(
                                    getPageId(_selectedNavRoute)) !=
                                '')
                              Tooltip(
                                message: localizedStrings.gTipHelp,
                                child: PageInfoButton(
                                    helpInfo: generateHelpTitle(
                                        getPageId(_selectedNavRoute)),
                                    onRefresh: () {},
                                    color: colorScheme.surfaceContainerHighest),
                              ),
                            SizedBox(
                              width: regularPadding,
                            ),
                            Image.asset(
                              'assets/images/person.png',
                              width: 24.0,
                              height: 24.0,
                            ),
                            SizedBox(
                              width: regularPadding,
                            ),
                            SizedBox(
                              child: Text(
                                mySysUser.nickName ?? '',
                                style: textTheme.bodySmall!.apply(
                                  color: colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: regularPadding,
                            ),
                            showSysSetting(colorScheme, textTheme),
                            SizedBox(
                              width: regularPadding,
                            ),
                            Tooltip(
                              message: localizedStrings.menuSystemInformation,
                              child: IconButton(
                                icon: getSvgIcon(
                                    infoSvgIcon(),
                                    topIconSize,
                                    topIconSize,
                                    colorScheme.surfaceContainerHighest),
                                onPressed: () {
                                  // showLicenseDialog(context);
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false, // 允许点击空白处关闭对话框
                                    builder: (context) {
                                      return const CompanyInfoDialog();
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: regularPadding,
                            ),
                          ],
                        ),
                      ]),
                ),

                Container(
                  height: regularPadding,
                  color: colorScheme.surfaceDim,
                ),
                // 内容区域导航器
                Expanded(
                    child: Container(
                  padding: EdgeInsets.symmetric(horizontal: regularPadding),
                  color: colorScheme.surfaceDim,
                  child: Navigator(
                    key: contentNavigatorKey,
                    initialRoute: _selectedNavRoute,
                    onGenerateRoute: (settings) {
                      final pageContent = buildPageContent(
                          _navigateContent, settings.name, lastRouteName);

                      return MaterialPageRoute(
                        builder: (context) => pageContent,
                        settings: settings,
                      );
                    },
                  ),
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showSysSetting(ColorScheme colorScheme, TextTheme textTheme) {
    return PopupMenuButton<String>(
      tooltip: localizedStrings.gSystemSetting,
      splashRadius: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      icon: Icon(
        Icons.settings,
        color: colorScheme.surfaceContainerHighest,
      ),
      offset: Offset(-15, 40),
      color: colorScheme.onSurfaceVariant,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (mySysUser.roleId == 1 || mySysUser.roleId == 2)
          PopupMenuItem(
            value: '1',
            child: Text(
              localizedStrings.userManagement,
              style: textTheme.bodySmall!.apply(
                // 根据选中状态改变颜色
                color: colorScheme.surface,
              ),
            ),
            onTap: () {
              Future.delayed(
                Duration.zero,
                () {
                  _navigateContent('/settingsUser');
                },
              );
            },
          ),
        if (mySysUser.roleId == 1 || mySysUser.roleId == 2)
          PopupMenuDivider(height: 1.0),
        if (mySysUser.roleId == 1 || mySysUser.roleId == 2)
          PopupMenuItem(
            value: '5',
            child: Text(
              localizedStrings.logManagement,
              style: textTheme.bodySmall!.apply(
                // 根据选中状态改变颜色
                color: colorScheme.surface,
              ),
            ),
            onTap: () {
              Future.delayed(
                Duration.zero,
                () {
                  _navigateContent('/settingsLog');
                },
              );
            },
          ),
        if (mySysUser.roleId == 1 || mySysUser.roleId == 2)
          PopupMenuDivider(height: 1.0),
        if (mySysUser.roleId == 1 || mySysUser.roleId == 2)
          PopupMenuItem(
            value: '6',
            child: Text(
              localizedStrings.gBtnConfigSetting,
              style: textTheme.bodySmall!.apply(
                // 根据选中状态改变颜色
                color: colorScheme.surface,
              ),
            ),
            onTap: () {
              Future.delayed(
                Duration.zero,
                () {
                  _navigateContent('/settingsFunction');
                },
              );
            },
          ),
        if (mySysUser.roleId == 1 || mySysUser.roleId == 2)
          PopupMenuDivider(height: 1.0),
        if ((mySysUser.roleId == superAdminRoleId && mySysUser.isChanged!) ||
            (mySysUser.roleId != superAdminRoleId))
          PopupMenuItem(
            value: '2',
            child: Text(
              localizedStrings.titleChangePassword,
              style: textTheme.bodySmall!.apply(
                // 根据选中状态改变颜色
                color: colorScheme.surface,
              ),
            ),
            onTap: () {
              Future.delayed(
                Duration.zero,
                () {
                  showModifyPwdDialog();
                },
              );
            },
          ),
        PopupMenuDivider(height: 1.0),
        PopupMenuItem(
          value: '3',
          child: Text(
            localizedStrings.menuLanguageSetting,
            style: textTheme.bodySmall!.apply(
              // 根据选中状态改变颜色
              color: colorScheme.surface,
            ),
          ),
          onTap: () {
            Future.delayed(
              Duration.zero,
              () {
                showSetLanguageDialog();
              },
            );
          },
        ),
        if ((mySysUser.roleId == superAdminRoleId && mySysUser.isChanged!) ||
            (mySysUser.roleId != superAdminRoleId))
          PopupMenuDivider(height: 1.0),
        if ((mySysUser.roleId == superAdminRoleId && mySysUser.isChanged!) ||
            (mySysUser.roleId != superAdminRoleId))
          PopupMenuItem(
            value: '4',
            child: Text(
              localizedStrings.titleLogout,
              style: textTheme.bodySmall!.apply(
                // 根据选中状态改变颜色
                color: colorScheme.surface,
              ),
            ),
            onTap: () {
              firstLogin = true;
              PublicFunctions.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (Route<dynamic> route) => false,
              );
            },
          ),
        PopupMenuDivider(height: 1.0),
      ],
    );
  }

  int getPageId(String routeName) {
    int pageId = 9999;
    for (var item in getAllConfigMenus()) {
      if (item.routeName == routeName) {
        pageId = item.id;
        break;
      }
    }
    if (pageId == 9999) {
      for (var item in getAllAppsMenus()) {
        if (item.routeName == routeName) {
          pageId = item.id;
          break;
        }
      }
    }
    if (routeName == '/setConfig') {
      pageId = MenuId.appConfigPage;
    }
    return pageId;
  }

  void showSetLanguageDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const LanguageSettingPage();
      },
    ).then((value) {
      if (value == null) {
        return;
      }
      if (mounted && value == true) {
        setState(() {
          _navigateContent(_selectedNavRoute);
        });
      }
    });
  }

  void showModifyPwdDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const ModifyPwdPage();
      },
    );
  }
}
