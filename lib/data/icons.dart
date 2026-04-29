//所有Icons的图标都可以在这里找到
// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:t_max/data/home_page_common_data.dart';

SvgPicture getSvgIcon(
    String iconPath, double? width, double? height, Color? color) {
  return SvgPicture.asset(
    iconPath,
    width: width,
    height: height,
    colorFilter:
        color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    fit: BoxFit.contain,
  );
}

String getMenuIconPath(int pageId) {
  if (pageId == MenuId.multiScaleManagement) {
    return multiScaleSvgIcon();
  } else if (pageId == MenuId.setSystemTimePage) {
    return dateTimeSvgIcon();
  } else if (pageId == MenuId.btSettingPage) {
    return btSettingSvgIcon();
  } else if (pageId == MenuId.wifiSettingPage) {
    return wifiSettingSvgIcon();
  } else if (pageId == MenuId.updateFirmwarePage) {
    return firmwareSvgIcon();
  } else if (pageId == MenuId.pluEditPage) {
    return pluEditSvgIcon();
  } else if (pageId == MenuId.takeInPage) {
    return takeInSvgIcon();
  } else if (pageId == MenuId.takeOutPage) {
    return takeOutSvgIcon();
  } else if (pageId == MenuId.checkWeighersPage) {
    return checkScaleSvgIcon();
  } else if (pageId == MenuId.retailReportPage) {
    return detailReportSvgIcon();
  } else if (pageId == MenuId.formulationScalePage) {
    return formulaModeSvgIcon();
  } else if (pageId == MenuId.labelDesignPage) {
    return labelDesignSvgIcon();
  } else if (pageId == MenuId.downloadLabelPage) {
    return labelDownloadSvgIcon();
  } else if (pageId == MenuId.pluEditPage) {
    return pluEditSvgIcon();
  } else if (pageId == MenuId.flowRatePage) {
    return rateSpeedSvgIcon();
  } else if (pageId == MenuId.receiptDesignPage) {
    return reciptDesignSvgIcon();
  } else if (pageId == MenuId.downReciptPage) {
    return reciptDownloadSvgIcon();
  } else if (pageId == MenuId.weightModePage) {
    return weighingSvgIcon();
  } else if (pageId == MenuId.weightDataCollectionPage) {
    return wgtCollectionSvgIcon();
  } else if (pageId == MenuId.serialOutputDesignPage) {
    return serialSvgIcon();
  } else if (pageId == MenuId.basicDataCollectionPage) {
    return basicDataSvgIcon();
  } else if (pageId == MenuId.wiredSettingPage) {
    return wiredSettingSvgIcon();
  } else if (pageId == MenuId.sealManagmentPage) {
    return sealManagmentSvgIcon();
  }

  return '';
}

String appSvgIcon() {
  return 'assets/images/app.svg';
}

String multiScaleSvgIcon() {
  return 'assets/images/multiMgt.svg';
}

String dateTimeSvgIcon() {
  return 'assets/images/datetime.svg';
}

String btSettingSvgIcon() {
  return 'assets/images/bt.svg';
}

String wifiSettingSvgIcon() {
  return 'assets/images/wifi.svg';
}

String wifi1BlueSvgIcon() {
  return 'assets/images/wifi1_b.png';
}

String wifi1WhiteSvgIcon() {
  return 'assets/images/wifi1_w.png';
}

String wifi2BlueSvgIcon() {
  return 'assets/images/wifi2_b.png';
}

String wifi2WhiteSvgIcon() {
  return 'assets/images/wifi2_w.png';
}

String wifi3BlueSvgIcon() {
  return 'assets/images/wifi3_b.png';
}

String wifi3WhiteSvgIcon() {
  return 'assets/images/wifi3_w.png';
}

String wifi4BlueSvgIcon() {
  return 'assets/images/wifi4_b.png';
}

String wifi4WhiteSvgIcon() {
  return 'assets/images/wifi4_w.png';
}

String bt1BlueSvgIcon() {
  return 'assets/images/bt1_b.png';
}

String bt1WhiteSvgIcon() {
  return 'assets/images/bt1_w.png';
}

String bt2BlueSvgIcon() {
  return 'assets/images/bt2_b.png';
}

String bt2WhiteSvgIcon() {
  return 'assets/images/bt2_w.png';
}

String bt3BlueSvgIcon() {
  return 'assets/images/bt3_b.png';
}

String bt3WhiteSvgIcon() {
  return 'assets/images/bt3_w.png';
}

String bt4BlueSvgIcon() {
  return 'assets/images/bt4_b.png';
}

String bt4WhiteSvgIcon() {
  return 'assets/images/bt4_w.png';
}

String firmwareSvgIcon() {
  return 'assets/images/firmwareUpdate.svg';
}

String pluEditSvgIcon() {
  return 'assets/images/pluApp.svg';
}

String takeInSvgIcon() {
  return 'assets/images/addScale.svg';
}

String takeOutSvgIcon() {
  return 'assets/images/minusScale.svg';
}

String checkScaleSvgIcon() {
  return 'assets/images/checkScale.svg';
}

String detailReportSvgIcon() {
  return 'assets/images/detailReport.svg';
}

String formulaModeSvgIcon() {
  return 'assets/images/formulaMode.svg';
}

String labelDesignSvgIcon() {
  return 'assets/images/labelDesign.svg';
}

String labelDownloadSvgIcon() {
  return 'assets/images/labelDownload.svg';
}

String rateSpeedSvgIcon() {
  return 'assets/images/rateSpeed.svg';
}

String reciptDesignSvgIcon() {
  return 'assets/images/reciptDesign.svg';
}

String reciptDownloadSvgIcon() {
  return 'assets/images/reciptDownload.svg';
}

String varSettingSvgIcon() {
  return 'assets/images/varSetting.svg';
}

String weighingSvgIcon() {
  return 'assets/images/weighing.svg';
}

String wgtCollectionSvgIcon() {
  return 'assets/images/wgtCollection.svg';
}

String settingSvgIcon() {
  return 'assets/images/setting.svg';
}

String infoSvgIcon() {
  return 'assets/images/info.svg';
}

String aboutSvgIcon() {
  return 'assets/images/about.svg';
}

String appsSvgIcon() {
  return 'assets/images/apps.svg';
}

String serialSvgIcon() {
  return 'assets/images/serial.svg';
}

String basicDataSvgIcon() {
  return 'assets/images/basicData.svg';
}

String parameterSvgIcon() {
  return 'assets/images/parameter.svg';
}

String calibrationSvgIcon() {
  return 'assets/images/calibration_icon.svg';
}

String serialPortSvgIcon() {
  return 'assets/images/serialPort.svg';
}

String rptSettingSvgIcon() {
  return 'assets/images/rptSetting.svg';
}

String exportSvgIcon() {
  return 'assets/images/export.svg';
}

String exportSuccessSvgIcon() {
  return 'assets/images/exportSuccess.svg';
}

String importSvgIcon() {
  return 'assets/images/import.svg';
}

String stableLightSvgIcon() {
  return 'assets/images/light.svg';
}

String calSuccessSvgIcon() {
  return 'assets/images/calSuccess.svg';
}

String calFailSvgIcon() {
  return 'assets/images/calFail.svg';
}

String wgtStableSvgIcon() {
  return 'assets/images/wgtStable.svg';
}

String returnSvgIcon() {
  return 'assets/images/return.svg';
}

String zeroSvgIcon() {
  return 'assets/images/zeroIcon.svg';
}

String netSvgIcon() {
  return 'assets/images/netIcon.svg';
}

String stableSvgIcon() {
  return 'assets/images/stableIcon.svg';
}

String saveSvgIcon() {
  return 'assets/images/save.svg';
}

String performZeroSvgIcon() {
  return 'assets/images/performZero.svg';
}

String performTareSvgIcon() {
  return 'assets/images/performTare.svg';
}

String startWgtSvgIcon() {
  return 'assets/images/start.svg';
}

String endWgtSvgIcon() {
  return 'assets/images/endWgt.svg';
}

String deleteSvgIcon() {
  return 'assets/images/delete.svg';
}

String clearSvgIcon() {
  return 'assets/images/clear.svg';
}

String reportSettingSvgIcon() {
  return 'assets/images/reportSetting.svg';
}

String highLowSettingSvgIcon() {
  return 'assets/images/highLowSetting.svg';
}

String configSettingSvgIcon() {
  return 'assets/images/configSetting.svg';
}

String appSettingSvgIcon() {
  return 'assets/images/appSetting.svg';
}

String appOnOffSvgIcon() {
  return 'assets/images/appOnOff.svg';
}

String basicDataTitleSvgIcon() {
  return 'assets/images/basicDataTitle.svg';
}

String formatTitleSvgIcon() {
  return 'assets/images/formatTitle.svg';
}

String rawTemplateSvgIcon() {
  return 'assets/images/pluTemplate.svg';
}

String addSvgIcon() {
  return 'assets/images/add.svg';
}

String enabledSvgIcon() {
  return 'assets/images/enabled.svg';
}

String disabledSvgIcon() {
  return 'assets/images/disabled.svg';
}

String downloadToScaleSvgIcon() {
  return 'assets/images/downloadToScale.svg';
}

String barcodeSvgIcon() {
  return 'assets/images/barcode.svg';
}

String checkCodeSvgIcon() {
  return 'assets/images/checkCode.svg';
}

String networkSvgIcon() {
  return 'assets/images/network.svg';
}

String fmaBarcodeIcon() {
  return 'assets/images/fmaBarcode.svg';
}

String recordsIcon() {
  return 'assets/images/records.svg';
}

String wiredSettingSvgIcon() {
  return 'assets/images/wiredSetting.svg';
}

String sealManagmentSvgIcon() {
  return 'assets/images/sealMgr.svg';
}

String unlockOkSvgIcon() {
  return 'assets/images/unlockOk.svg';
}

String sealOkSvgIcon() {
  return 'assets/images/sealOk.svg';
}

String sealedSvgIcon() {
  return 'assets/images/sealed.svg';
}

String hardwareSealSvgIcon() {
  return 'assets/images/hardwareSeal.svg';
}

String softwareSealSvgIcon() {
  return 'assets/images/softwareSeal.svg';
}

String failedSvgIcon() {
  return 'assets/images/failed.svg';
}

String btSvgIcon() {
  return 'assets/images/bt.svg';
}

String btDeviceSvgIcon() {
  return 'assets/images/bt_device.svg';
}

String outputSvgIcon() {
  return 'assets/images/output.svg';
}
