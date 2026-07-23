//所有的路由
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/labeldesign/label_design_page.dart';
import 'package:t_max/pages/apps_setting_page.dart';
import 'package:t_max/pages/basic_data_page.dart';
import 'package:t_max/pages/blue_tooth_setting_page.dart';
import 'package:t_max/pages/calibration_page.dart';
import 'package:t_max/pages/calibration_seal_page.dart';
import 'package:t_max/pages/check_weighers_page.dart';
import 'package:t_max/pages/configuration_center_page.dart';
import 'package:t_max/pages/serial_protocol_page.dart';
import 'package:t_max/pages/down_recipt_fmt_page.dart';
import 'package:t_max/pages/flow_rate_page.dart';
import 'package:t_max/pages/formula_scale_page.dart';
import 'package:t_max/pages/lable_down_prn_fmt_page.dart';
import 'package:t_max/pages/multi_scale_management_page.dart';
import 'package:t_max/pages/plu_edit_page.dart';
import 'package:t_max/pages/receipt_design_page.dart';
import 'package:t_max/pages/retail_report_page.dart';
import 'package:t_max/pages/set_system_time.dart';
import 'package:t_max/pages/sys_log_page.dart';
import 'package:t_max/pages/sys_user_manager.dart';
import 'package:t_max/pages/take_in_page.dart';
import 'package:t_max/pages/take_out_page.dart';
import 'package:t_max/pages/update_firmware_page.dart';
import 'package:t_max/pages/weighing.dart';
import 'package:t_max/pages/weight_collection_page.dart';
import 'package:t_max/pages/wifi_setting_page.dart';
import 'package:t_max/pages/wired_setting_page.dart';

class RouteData {
  RouteData({
    required this.title,
    required this.subtitle,
    required this.id,
    this.routeName,
    this.selected,
    required this.iconPath,
  });

  String title;
  String subtitle;
  int id;
  String? routeName;
  String? selected;
  String iconPath;
}

List<int> allPaidConfigMenu = [
  MenuId.labelDesignPage,
  MenuId.receiptDesignPage,
  MenuId.serialOutputDesignPage,
  MenuId.basicDataCollectionPage,
  // MenuId.parameterSettingPage,
  MenuId.sealManagmentPage,
];

List<RouteData> getApplication() {
  List<RouteData> application = [
    RouteData(
      id: MenuId.appConfigPage,
      title: localizedStrings.menuApplications,
      routeName: "/setConfig",
      subtitle: localizedStrings.menuApplications,
      iconPath: appSvgIcon(),
    ),
  ];
  return application;
}

List<RouteData> getAllConfigMenus() {
  List<RouteData> allConfigMenus = [
    RouteData(
      id: MenuId.multiScaleManagement,
      title: localizedStrings.menuMultiScaleManagement,
      routeName: "/multiScaleManagement",
      subtitle: localizedStrings.subTitleMultiScaleManagement,
      iconPath: multiScaleSvgIcon(),
    ),
    RouteData(
      id: MenuId.setSystemTimePage,
      title: localizedStrings.menuDeviceTime,
      routeName: "/setSystemTime",
      subtitle: localizedStrings.subTitleDeviceTime,
      iconPath: dateTimeSvgIcon(),
    ),
    RouteData(
      id: MenuId.btSettingPage,
      title: localizedStrings.menuBluetoothSetting,
      routeName: "/btSetting",
      subtitle: localizedStrings.subTitleBluetoothSetting,
      iconPath: btSettingSvgIcon(),
    ),
    RouteData(
      id: MenuId.wifiSettingPage,
      title: localizedStrings.menuWifiSetting,
      routeName: "/wifiSetting",
      subtitle: localizedStrings.subTitleWifiSetting,
      iconPath: wifiSettingSvgIcon(),
    ),
    RouteData(
      id: MenuId.updateFirmwarePage,
      title: localizedStrings.menuFirmwareUpdate,
      routeName: "/updateFirmware",
      subtitle: localizedStrings.subTitleFirmwareUpdate,
      iconPath: firmwareSvgIcon(),
    ),
    RouteData(
      id: MenuId.labelDesignPage,
      title: localizedStrings.menuLabelDesign,
      routeName: "/labelDesign",
      subtitle: localizedStrings.subTitleLabelDesign,
      iconPath: labelDesignSvgIcon(),
    ),
    RouteData(
      id: MenuId.receiptDesignPage,
      title: localizedStrings.menuReceiptDesign,
      routeName: "/receiptDesign",
      subtitle: localizedStrings.subTitleReceiptDesign,
      iconPath: reciptDesignSvgIcon(),
    ),
    RouteData(
      id: MenuId.serialOutputDesignPage,
      title: localizedStrings.menuSerialOutputDesign,
      routeName: "/serialOutputDesign",
      subtitle: localizedStrings.subTitleSerialOutputDesign,
      iconPath: serialSvgIcon(),
    ),
    RouteData(
      id: MenuId.basicDataCollectionPage,
      title: localizedStrings.menuBasicDataCollection,
      routeName: "/basicDataCollection",
      subtitle: localizedStrings.subTitleBasicDataCollection,
      iconPath: basicDataSvgIcon(),
    ),
    RouteData(
      id: MenuId.wiredSettingPage,
      title: localizedStrings.menuWiredSetting,
      routeName: "/wiredSetting",
      subtitle: localizedStrings.subTitleWiredSetting,
      iconPath: wiredSettingSvgIcon(),
    ),
    RouteData(
      id: MenuId.sealManagmentPage,
      title: localizedStrings.menuSealManagment,
      routeName: "/sealManagment",
      subtitle: localizedStrings.subTitleSealManagment,
      iconPath: sealManagmentSvgIcon(),
    ),

    // RouteData(
    //     id: MenuId.parameterSettingPage.index,
    //     title: localizedStrings.menuParameterSetting,
    //     routeName: "/parameterSetting",
    //     subtitle: localizedStrings.subTitleParameterSetting,
    //     iconPath: parameterSvgIcon()),
    RouteData(
        id: MenuId.calibrationPage,
        title: localizedStrings.menuWeighingSetting,
        routeName: "/calibration",
        subtitle: localizedStrings.subTitleCalibration,
        iconPath: calibrationSvgIcon()),
    RouteData(
      id: MenuId.pluEditPage,
      title: localizedStrings.menuPluManagement,
      routeName: "/pluEdit",
      subtitle: localizedStrings.subTitlePluManagement,
      iconPath: pluEditSvgIcon(),
    ),
    RouteData(
        id: MenuId.downloadLabelPage,
        title: localizedStrings.menuLabelFormatDownload,
        routeName: "/downloadLabel",
        subtitle: localizedStrings.subTitleLabelFormatDownload,
        iconPath: labelDownloadSvgIcon()),
    RouteData(
        id: MenuId.downReciptPage,
        title: localizedStrings.menuReceiptFormatDownload,
        routeName: "/downRecipt",
        subtitle: localizedStrings.subTitleReceiptFormatDownload,
        iconPath: reciptDownloadSvgIcon()),
  ];
  return allConfigMenus;
}

List<RouteData> getCurrentConfigMenus() {
  List<RouteData> currentConfigMenus = [];
  List<RouteData> allConfigMenus = getAllConfigMenus();
  for (var menu in allConfigMenus) {
    if (freeConfigMenuIds.contains(menu.id) &&
        selectedConfigPaidMenuIds.contains(menu.id) &&
        getUserPermission(menu.id)) {
      currentConfigMenus.add(menu);
    } else if (myLicenseInfo.isValid &&
        selectedConfigPaidMenuIds.contains(menu.id) &&
        getUserPermission(menu.id)) {
      currentConfigMenus.add(menu);
    }
  }
// 多秤管理菜单要一直都在
  for (var menu in allConfigMenus) {
    if (menu.id == MenuId.multiScaleManagement &&
        !currentConfigMenus.contains(menu)) {
      currentConfigMenus.add(menu);
    }
  }

  return currentConfigMenus;
}

String generateTitle(int pageId) {
  if (pageId == MenuId.multiScaleManagement) {
    return localizedStrings.menuMultiScaleManagement;
  } else if (pageId == MenuId.setSystemTimePage) {
    return localizedStrings.menuDeviceTime;
  } else if (pageId == MenuId.btSettingPage) {
    return localizedStrings.menuBluetoothSetting;
  } else if (pageId == MenuId.wifiSettingPage) {
    return localizedStrings.menuWifiSetting;
  } else if (pageId == MenuId.updateFirmwarePage) {
    return localizedStrings.menuFirmwareUpdate;
  } else if (pageId == MenuId.labelDesignPage) {
    return localizedStrings.menuLabelDesign;
  } else if (pageId == MenuId.receiptDesignPage) {
    return localizedStrings.menuReceiptDesign;
  } else if (pageId == MenuId.serialOutputDesignPage) {
    return localizedStrings.menuSerialOutputDesign;
  } else if (pageId == MenuId.basicDataCollectionPage) {
    return localizedStrings.menuBasicDataCollection;
  } else if (pageId == MenuId.sealManagmentPage) {
    return localizedStrings.menuSealManagment;
  }

  // else if (pageId == MenuId.parameterSettingPage.index) {
  //   return localizedStrings.menuParameterSetting;
  // }
  else if (pageId == MenuId.weightModePage) {
    return localizedStrings.menuWeighing;
  } else if (pageId == MenuId.pluEditPage) {
    return localizedStrings.menuPluManagement;
  } else if (pageId == MenuId.downloadLabelPage) {
    return localizedStrings.menuLabelFormatDownload;
  } else if (pageId == MenuId.downReciptPage) {
    return localizedStrings.menuReceiptFormatDownload;
  } else if (pageId == MenuId.retailReportPage) {
    return localizedStrings.menuRetailReport;
  } else if (pageId == MenuId.weightDataCollectionPage) {
    return localizedStrings.menuWeighingDataCollection;
  } else if (pageId == MenuId.checkWeighersPage) {
    return localizedStrings.menuCheckWeighing;
  } else if (pageId == MenuId.takeInPage) {
    return localizedStrings.menuIncrementWeighing;
  } else if (pageId == MenuId.takeOutPage) {
    return localizedStrings.menuTakeOutScale;
  } else if (pageId == MenuId.formulationScalePage) {
    return localizedStrings.menuFormula;
  } else if (pageId == MenuId.flowRatePage) {
    return localizedStrings.menuFlowRate;
  } else if (pageId == MenuId.calibrationPage) {
    return localizedStrings.menuWeighingSetting;
  } else if (pageId == MenuId.appLabelDesignPage) {
    return localizedStrings.menuLabelDesign;
  } else if (pageId == MenuId.appRcpDesignPage) {
    return localizedStrings.menuReceiptDesign;
  } else if (pageId == MenuId.wiredSettingPage) {
    return localizedStrings.menuWiredSetting;
  }

  if (pageId == MenuId.appConfigPage) {
    return localizedStrings.menuApplications;
  }
  return '';
}

String generateHelpTitle(int pageId) {
  if (pageId == MenuId.multiScaleManagement) {
    return localizedStrings.gTipScaleMgrPageHelp;
  } else if (pageId == MenuId.setSystemTimePage) {
    return localizedStrings.gTipDeviceTimePageHelp;
  } else if (pageId == MenuId.wifiSettingPage) {
    return localizedStrings.gTipWifiSettingPageHelp;
  } else if (pageId == MenuId.updateFirmwarePage) {
    return localizedStrings.gTipUpdateFirmwarePageHelp;
  } else if (pageId == MenuId.labelDesignPage) {
    return localizedStrings.gTipLabelDesignPageHelp;
  } else if (pageId == MenuId.receiptDesignPage) {
    return localizedStrings.gTipReceiptDesignPageHelp;
  } else if (pageId == MenuId.serialOutputDesignPage) {
    return localizedStrings.gTipSerialDesignPageHelp;
  } else if (pageId == MenuId.basicDataCollectionPage) {
    return localizedStrings.gTipBasicDataPageHelp;
  } else if (pageId == MenuId.pluEditPage) {
    return localizedStrings.gTipPlueditPageHelp;
  } else if (pageId == MenuId.downloadLabelPage) {
    return localizedStrings.gTipLabelFmtDownPageHelp;
  } else if (pageId == MenuId.downReciptPage) {
    return localizedStrings.gTipReceiptFmtDownPageHelp;
  } else if (pageId == MenuId.appLabelDesignPage) {
    return localizedStrings.gTipLabelDesignPageHelp;
  } else if (pageId == MenuId.appRcpDesignPage) {
    return localizedStrings.gTipReceiptDesignPageHelp;
  } else if (pageId == MenuId.wiredSettingPage) {
    return localizedStrings.menuWiredSetting;
  } else if (pageId == MenuId.sealManagmentPage) {
    return localizedStrings.menuSealManagment;
  }

  return '';
}

List<int> allPaidAppMenu = [
  MenuId.weightDataCollectionPage,
  MenuId.checkWeighersPage,
  MenuId.takeInPage,
  MenuId.takeOutPage,
  MenuId.appLabelDesignPage,
  MenuId.appRcpDesignPage,
  MenuId.formulationScalePage,
  MenuId.flowRatePage,
];

List<RouteData> getAllAppsMenus() {
  return [
    RouteData(
      id: MenuId.weightModePage,
      title: localizedStrings.menuWeighing,
      routeName: "/weightMode",
      subtitle: localizedStrings.subTitleWeighing,
      iconPath: weighingSvgIcon(),
    ),
    RouteData(
        id: MenuId.retailReportPage,
        title: localizedStrings.menuRetailReport,
        routeName: "/retailReport",
        subtitle: localizedStrings.subTitleRetailReport,
        iconPath: detailReportSvgIcon()),
    RouteData(
        id: MenuId.weightDataCollectionPage,
        title: localizedStrings.menuWeighingDataCollection,
        routeName: "/weightDataCollection",
        subtitle: localizedStrings.subTitleWeighingDataCollection,
        iconPath: wgtCollectionSvgIcon()),
    RouteData(
        id: MenuId.checkWeighersPage,
        title: localizedStrings.menuCheckWeighing,
        routeName: "/checkWeighing",
        subtitle: localizedStrings.subTitleCheckWeighing,
        iconPath: checkScaleSvgIcon()),
    RouteData(
        id: MenuId.takeInPage,
        title: localizedStrings.menuIncrementWeighing,
        routeName: "/takeIn",
        subtitle: localizedStrings.subTitleIncrementWeighing,
        iconPath: takeInSvgIcon()),
    RouteData(
      id: MenuId.takeOutPage,
      title: localizedStrings.menuTakeOutScale,
      routeName: "/takeOut",
      subtitle: localizedStrings.subTitleTakeOutScale,
      iconPath: takeOutSvgIcon(),
    ),
    RouteData(
        id: MenuId.formulationScalePage,
        title: localizedStrings.menuFormula,
        routeName: "/formulationScale",
        subtitle: localizedStrings.subTitleFormula,
        iconPath: firmwareSvgIcon()),
    RouteData(
        id: MenuId.flowRatePage,
        title: localizedStrings.menuFlowRate,
        routeName: "/flowRate",
        subtitle: localizedStrings.subTitleFlowRate,
        iconPath: rateSpeedSvgIcon()),
    RouteData(
      id: MenuId.appLabelDesignPage,
      title: localizedStrings.menuLabelDesign,
      routeName: "/labelDesign",
      subtitle: localizedStrings.subTitleLabelDesign,
      iconPath: labelDesignSvgIcon(),
    ),
    RouteData(
      id: MenuId.appRcpDesignPage,
      title: localizedStrings.menuReceiptDesign,
      routeName: "/receiptDesign",
      subtitle: localizedStrings.subTitleReceiptDesign,
      iconPath: reciptDesignSvgIcon(),
    ),
  ];
}

bool getUserPermission(int id) {
  if (mySysUser.roleId == adminRoleId || mySysUser.roleId == superAdminRoleId) {
    return true;
  }
  if (mySysUser.pageIdList!.isEmpty) {
    return false;
  }
  if (mySysUser.pageIdList!.contains(id)) {
    return true;
  }
  return false;
}

bool getIsAppCertified(int id) {
  if (id == MenuId.weightDataCollectionPage) {
    return myWedaLicInfo.isValid;
  } else if (id == MenuId.checkWeighersPage) {
    return myChweLicInfo.isValid;
  } else if (id == MenuId.takeInPage) {
    return myInWeLicInfo.isValid;
  } else if (id == MenuId.takeOutPage) {
    return myTaouLicInfo.isValid;
  } else if (id == MenuId.formulationScalePage) {
    return myFoScLicInfo.isValid;
  } else if (id == MenuId.flowRatePage) {
    return myFaSpInfo.isValid;
  } else if (id == MenuId.labelDesignPage) {
    return myLadeLicInfo.isValid;
  } else if (id == MenuId.receiptDesignPage) {
    return myRedeLicInfo.isValid;
  } else if (id == MenuId.appLabelDesignPage) {
    return myLadeLicInfo.isValid;
  } else if (id == MenuId.appRcpDesignPage) {
    return myRedeLicInfo.isValid;
  }

  return false;
}

bool isFreeConfig(int pId) => freeConfigMenuIds.contains(pId);

bool isFreeApp(int pId) => freeAppMenuIds.contains(pId);

Widget buildPageContent(dynamic Function(String) navigateContent,
    String? pageName, String? lastRouteName) {
  lastRouteName ??= '/setConfig';
  if (pageName == '/setConfig') {
    return ConfigurationPage(
        onNavigate: navigateContent, lastRouteName: lastRouteName);
  }
  if (pageName == '/settingsUser') {
    return SysUserManagerPage(
        onNavigate: navigateContent, lastRouteName: lastRouteName);
  }

  if (pageName == '/settingsLog') {
    return SysLogPage(
        onNavigate: navigateContent, lastRouteName: lastRouteName);
  }

  if (pageName == '/settingsFunction') {
    return AppsSettingPage(
        onNavigate: navigateContent, lastRouteName: lastRouteName);
    // return ConfigurationPage(
    //     onNavigate: navigateContent, lastRouteName: lastRouteName!);
  }

  int pageId = 9999;

  for (var item in getAllConfigMenus()) {
    if (item.routeName == pageName) {
      pageId = item.id;
      break;
    }
  }
  if (pageId == 9999) {
    for (var item in getAllAppsMenus()) {
      if (item.routeName == pageName) {
        pageId = item.id;
        break;
      }
    }
  }
  if (pageId == 9999) {
    return Container();
  }

  if (pageId == MenuId.multiScaleManagement) {
    return MultiScaleManagement();
  } else if (pageId == MenuId.setSystemTimePage) {
    return SetSystemTimePage();
  } else if (pageId == MenuId.wifiSettingPage) {
    return WifiSettingPage();
  } else if (pageId == MenuId.wiredSettingPage) {
    return WiredSettingPage();
  } else if (pageId == MenuId.btSettingPage) {
    return BluetoothPage();
  } else if (pageId == MenuId.updateFirmwarePage) {
    return UpdateFirmwarePage();
  } else if (pageId == MenuId.labelDesignPage) {
    return LabelDesignPage(
      type: formAppSetting ? "app" : "config",
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.receiptDesignPage) {
    return ReceiptDesignPage(
      type: formAppSetting ? "app" : "config",
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.serialOutputDesignPage) {
    return CustomSerialProtocol();
  } else if (pageId == MenuId.basicDataCollectionPage) {
    return BasicDataPage();
  } else if (pageId == MenuId.sealManagmentPage) {
    return CalibrationSealPage();
  } else if (pageId == MenuId.sealManagmentPage) {
    return CalibrationSealPage();
  }

  //  else if (pageId == MenuId.parameterSettingPage.index) {
  //   return SetParameterPage();
  // }
  else if (pageId == MenuId.weightModePage) {
    return WeightModePage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.pluEditPage) {
    return PluEidtPage();
  } else if (pageId == MenuId.downloadLabelPage) {
    return DownloadLabelPage();
  } else if (pageId == MenuId.downReciptPage) {
    return DownReciptPage();
  } else if (pageId == MenuId.retailReportPage) {
    return RetailReportPage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.weightDataCollectionPage) {
    return WeightDataCollectionPage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.checkWeighersPage) {
    return CheckWeighersPage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.takeInPage) {
    return TakeInPage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.takeOutPage) {
    return TakeOutPage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.formulationScalePage) {
    return FormulationScalePage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.flowRatePage) {
    return FlowRatePage(
      onNavigate: navigateContent,
      lastRouteName: lastRouteName,
    );
  } else if (pageId == MenuId.multiScaleManagement) {
    return MultiScaleManagement();
  } else if (pageId == MenuId.calibrationPage) {
    return CalibrationPage();
  }
  return Container();
}

String getRoutePath(int pageId) {
  for (var item in getAllConfigMenus()) {
    if (item.id == pageId) {
      return item.routeName!;
    }
  }
  for (var item in getAllAppsMenus()) {
    if (item.id == pageId) {
      return item.routeName!;
    }
  }
  return "";
}

class RouteDataGroup {
  final String title;
  final List<dynamic> children; // 可以包含RouteData或RouteDataGroup
  bool isExpanded; // 控制展开/收起状态
  final String iconPath;

  RouteDataGroup({
    required this.title,
    required this.children,
    this.isExpanded = false,
    this.iconPath = '',
  });
}

// 添加新的获取层级菜单方法
List<RouteDataGroup> getHierarchicalConfigMenus() {
  // 获取原始权限过滤后的菜单列表
  final originalMenus = getCurrentConfigMenus();
  final appMemu = getApplication();

  bool hasS15 = myAllScalesList.any((scale) => scale.scaleModel == "S15");

  return [
    // 多秤管理组
    RouteDataGroup(
      title: localizedStrings.menuMultiScaleManagement,
      iconPath: multiScaleSvgIcon(),
      children: [
        // 使用firstWhereOrNull避免找不到时抛出异常
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.multiScaleManagement)
      ]
          // 过滤空值
          .whereType<RouteData>()
          .toList(),
    ),

    // 设置组
    RouteDataGroup(
      title: localizedStrings.gBtnSetting,
      iconPath: settingSvgIcon(),
      children: [
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.setSystemTimePage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.wifiSettingPage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.wiredSettingPage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.btSettingPage),
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.updateFirmwarePage),
        if (hasS15)
          originalMenus.firstWhereOrNull((m) => m.id == MenuId.calibrationPage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.sealManagmentPage),
      ].whereType<RouteData>().toList(),
    ),

    // 格式组
    RouteDataGroup(
      title: localizedStrings.menuFormat,
      iconPath: formatTitleSvgIcon(),
      children: [
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.labelDesignPage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.receiptDesignPage),
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.serialOutputDesignPage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.downloadLabelPage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.downReciptPage),
      ].whereType<RouteData>().toList(),
    ),

    // 基础数据组
    RouteDataGroup(
      title: localizedStrings.menuData,
      iconPath: basicDataTitleSvgIcon(),
      children: [
        originalMenus
            .firstWhereOrNull((m) => m.id == MenuId.basicDataCollectionPage),
        originalMenus.firstWhereOrNull((m) => m.id == MenuId.pluEditPage),
      ].whereType<RouteData>().toList(),
    ),
    // App管理组
    RouteDataGroup(
      title: localizedStrings.menuApplications,
      iconPath: appSvgIcon(),
      children: [
        // // 使用firstWhereOrNull避免找不到时抛出异常
        appMemu.firstWhereOrNull((m) => m.id == MenuId.appConfigPage)
      ]
          // 过滤空值
          .whereType<RouteData>()
          .toList(),
    ),
  ];
}
