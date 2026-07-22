//主界面公用的常量
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart' as transparent_image;

bool checkingUsers = true;

const leftBarWidth = 240.0; //左侧菜单宽度
const leftBarLittleWidth = 74.0; //左侧菜单宽度收缩后的宽度
const leftBarIconHeight = 78.0; //左侧菜单图标部分高度
const leftBarHeight = 52.0; //左侧菜单高度
const topBarHeight = 56.0; //顶部菜单高度
const iconAppSize = 36.0; //顶部菜单大小
const iconMenuSize = 22.0; //顶部菜单大小
const leftAppNameWidth = 170.0; //左侧菜单应用名称宽度
const pageTopTitleHeight = 56.0; //页面顶部标题高度
const topLinePadding = 2.0; //顶部操作栏间距高度
const regularPadding = 14.0; //常规边距
const dialogTitleheight = 54.0; //对话框标题高度
const smallPadding = 8.0; //小边距
const largePadding = 20.0; //大边距
const bottomBtnHeight = 68.0; //底部按钮高度
const inputHeight = 48.0; //输入框高度
const btnHeight = 48.0; //按钮高度
const inputWidth = 300.0; //输入框宽度
const textContentHeight = 42.0; //文本控件高度
const scaleItemHeight = 62.0; //秤列表项高度
const scaleInnerItemHeight = 38.0; //秤列表项里图标占用的控件宽度
const topIconSize = 20.0; //顶部菜单图标大小
const scaleListWidth = 290.0; //下拉秤的列表宽度
const wifiListWidth = 255.0; //下拉秤的列表宽度
const headWidthPadding = 500.0; //头部菜单间隔宽度
const wgtIconSize = 24.0; //顶部菜单图标大小
const dialogHeadHeight = 54.0; //对话框头部高度

const appScaleListWidth = 234.0; //app里面下拉秤的列表宽度

String appIconPath = 'assets/images/app.png';
String logoIconPath = 'assets/images/logo.png';

bool unstableZeroTare = false; // 动态置零

// Duration for home page elements to fade in.
const Duration entranceAnimationDuration = Duration(milliseconds: 200);

// The desktop top padding for a page's first header (e.g. Gallery, Settings)
const double firstHeaderDesktopTopPadding = 5.0;

// A transparent image used to avoid loading images when they are not needed.
final Uint8List kTransparentImage = transparent_image.kTransparentImage;

//全局变量

GlobalKey<NavigatorState> contentNavigatorKey = GlobalKey();

String defualtSelectPage = '/setConfig'; //当前选中的页面ID

bool showLeftNavigationBar = true; // 控制导航栏显示
bool formAppSetting = false; // 是否是app设置页面

// 存储用户选择要添加的付费菜单 ID
Set<int> selectedConfigPaidMenuIds = {0};

enum PageId { home, config, apps, appsSetting, systemSetting }

//免费的Config菜单Id
Set<int> freeConfigMenuIds = {
  MenuId.multiScaleManagement,
  MenuId.setSystemTimePage,
  MenuId.btSettingPage,
  MenuId.wifiSettingPage,
  MenuId.updateFirmwarePage,
  MenuId.calibrationPage,
  MenuId.pluEditPage,
  MenuId.downReciptPage,
  MenuId.downloadLabelPage,
  MenuId.wiredSettingPage,
  MenuId.printOnlinePage,
};

//付费的Config菜单Id
Set<int> paidConfigMenuIds = {
  MenuId.labelDesignPage,
  MenuId.receiptDesignPage,
  MenuId.serialOutputDesignPage,
  MenuId.basicDataCollectionPage,
  // MenuId.parameterSettingPage,
  MenuId.sealManagmentPage,
};

// 存储用户选择要添加的付费菜单 ID
Set<int> selectedAppsPaidMenuIds = {
  MenuId.weightModePage,
  MenuId.retailReportPage,
};

//免费的appId
Set<int> freeAppMenuIds = {
  MenuId.weightModePage,
  MenuId.retailReportPage,
};

//零售的appId
Set<int> retailAppMenuIds = {
  MenuId.appLabelDesignPage,
  MenuId.appRcpDesignPage,
};

//零售的appId 付费的
Set<int> industrialAppMenuIds = {
  MenuId.weightDataCollectionPage,
  MenuId.checkWeighersPage,
  MenuId.takeInPage,
  MenuId.takeOutPage,
  MenuId.formulationScalePage,
  MenuId.flowRatePage,
  MenuId.sealManagmentPage
};

//如何定义一个枚举类型 比如  home  = 1  config = 2  apps = 3  appsSetting = 4  systemSetting = 5

class MenuId {
  static const int multiScaleManagement = 0;
  static const int setSystemTimePage = 1;
  static const int btSettingPage = 2;
  static const int wifiSettingPage = 3;
  static const int updateFirmwarePage = 4;
  static const int labelDesignPage = 5;
  static const int receiptDesignPage = 6;
  static const int serialOutputDesignPage = 7;
  static const int basicDataCollectionPage = 8;
  static const int weightModePage = 9;
  static const int pluEditPage = 10;
  static const int downloadLabelPage = 11;
  static const int downReciptPage = 12;
  static const int retailReportPage = 13;
  static const int weightDataCollectionPage = 14;
  static const int checkWeighersPage = 15;
  static const int takeInPage = 16;
  static const int takeOutPage = 17;
  static const int formulationScalePage = 18;
  static const int flowRatePage = 19;
  static const int calibrationPage = 20;
  static const int appLabelDesignPage = 21;
  static const int appRcpDesignPage = 22;
  static const int appConfigPage = 23;
  static const int wiredSettingPage = 24;
  static const int sealManagmentPage = 25;
  static const int printOnlinePage = 26;
}
