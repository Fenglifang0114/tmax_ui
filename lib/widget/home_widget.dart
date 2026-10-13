// 修改 MenuItem 以支持选中状态和点击回调
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_tooltip/smart_tooltip_text.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/routes_data.dart';
import 'package:t_max/dialog/exit_app_dialog.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

const double barLeftWidth = 24;
const double barBetweenHeight = 13;

class ShowMenuItem extends StatelessWidget {
  const ShowMenuItem({
    super.key,
    this.showIcon = false, // 是否显示图标

    required this.demo,
    this.isExpanded = true,
    required this.isSelected, // 新增选中状态
    required this.onTap, // 新增点击回调
  });

  final bool showIcon; // 是否显示图标

  final RouteData demo;
  final bool isExpanded;
  final bool isSelected; // 新增选中状态
  final VoidCallback onTap; // 新增点击回调

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildMenuInfo() {
      return SizedBox(
          height: 52, // 固定高度
          child: Material(
            color: isSelected
                ? Colors.black.withValues(alpha: 0.2) //透明度百分比20% *255
                : Theme.of(context).colorScheme.primary,
            child: MergeSemantics(
              child: InkWell(
                onTap: onTap, // 绑定点击回调
                child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: showIcon
                          ? 14
                          : isExpanded
                              ? 42
                              : barLeftWidth,
                      end: 5,
                    ),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (showIcon)
                            SizedBox(
                              child: getSvgIcon(demo.iconPath, 22, 22,
                                  Theme.of(context).colorScheme.onPrimary),
                            ),
                          if (isExpanded) ...[
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: FittedBox(
                                fit: BoxFit.scaleDown, // 仅在需要时缩小内容
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  demo.title,
                                  maxLines: 1,
                                  style: textTheme.bodySmall!.apply(
                                      // 根据选中状态改变颜色
                                      color: colorScheme.onPrimary),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )),
              ),
            ),
          ));
    }

    if (isExpanded) {
      return buildMenuInfo();
    }
    return SmartTooltip(
        borderColor: colorScheme.onInverseSurface,
        message: isExpanded ? '' : demo.title,
        backgroundColor: colorScheme.onInverseSurface.withValues(alpha: 0.7),
        textStyle: TextStyle(
          color: colorScheme.onPrimary,
        ),
        position: TooltipPosition.right,
        child: buildMenuInfo());
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
            // macOS 使用系统自带的红绿灯按钮（位于左上角），预留位置避免遮挡
            if (Platform.isMacOS) SizedBox(width: 72),
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

            // 窗口控制按钮：仅 Windows/Linux 显示自绘按钮，macOS 使用系统原生按钮
            if (showButtons && !Platform.isMacOS) WindowButtons(),
          ],
        ),
      ),
    );
  }
}
