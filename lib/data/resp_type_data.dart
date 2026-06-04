import 'dart:convert';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/settingparam_data.dart';
import '../eventbus/eventbus.dart';
import 'downloadresponse.dart';
import 'ipinfodata.dart';
import 'record_data.dart';
import 'reqweightdata_data.dart';
import 'respdata_data.dart';
import 'scale_info_from_scale.dart';
import 'wifi_ap_info.dart';
import 'wifi_list_info.dart';

class RespMsgType {
  static const String weightData = 'weight_data';
  static const String respZeroCmd = 'resp_zero_cmd';
  static const String respTareCmd = 'resp_tare_cmd';
  static const String respWeightData = 'resp_weight_data';
  static const String respRegWeight = 'resp_reg_weight';
  static const String respUnregWeight = 'resp_unreg_weight';
  static const String respGetRecs = 'resp_get_recs';
  static const String respAddRec = 'resp_add_rec';
  static const String respDelRec = 'resp_del_rec';
  static const String respEnFacMode = 'resp_en_fac_mode';
  static const String respDisFacMode = 'resp_dis_fac_mode';
  static const String respEnPassthMode = 'resp_en_passth_mode';
  static const String respDisPassthMode = 'resp_dis_passth_mode';
  static const String respEraseFlash = 'resp_erase_flash';
  static const String respWriteDataFlash = 'resp_write_data_flash';
  static const String respDownPrnFmt = 'resp_down_prn_fmt';
  static const String respDownDefPrnFmt = 'resp_down_def_prn_fmt';
  static const String respErrSerial = 'resp_err_serial';
  static const String respGetApList = 'resp_get_ap_list';
  static const String respRescanApList = 'resp_rescan_ap_list';
  static const String respConnectAp = 'resp_connect_ap';
  static const String respConnectApOneKey = 'resp_connect_ap_one_key';
  static const String respSetWifiDynamicIp = 'resp_set_wifi_dynamic_ip';
  static const String respSetWifiStaticIp = 'resp_set_wifi_static_ip';
  static const String respGetWifiApInfo = 'resp_get_wifi_ap_info';
  static const String respGetIpInfo = 'resp_get_ip_info';
  static const String respGetIpMode = 'resp_get_ip_mode';
  static const String respModifyBTName = 'resp_modify_bt_name';
  static const String respNoResponse = 'resp_no_response';
  static const String respBTPassthData = 'resp_bt_passth_data';
  static const String respWiFiPassthData = 'resp_wifi_passth_data';
  static const String respPrtpassthData = 'resp_prt_passth_data';
  static const String respSendDataToWiFi = 'resp_send_data_to_wifi';
  static const String respUpdateFirmware = 'resp_update_firmware';
  static const String respUpdateFirmwareProgress =
      'resp_update_firmware_progress';
  static const String respCheckSerialPort = 'resp_check_serial_port';
  static const String respGetBuildInfo = 'resp_get_build_info';
  static const String respGetWeightErr = 'resp_get_weight_err';
  static const String respSetOutputFmt = 'resp_set_output_fmt';
  static const String respOpenScalePassthrough = 'resp_open_scale_passthrough';
  static const String respCloseScalePassthrough =
      'resp_close_scale_passthrough';
  static const String scalePassthData = 'scale_passth_data';
  static const String respChangeScalePassthMode =
      'resp_change_scale_passth_mode';
  static const String respGetScaleTime = 'resp_get_scale_time';
  static const String respSetScaleTime = 'resp_set_scale_time';
  static const String respDownPlu = 'resp_down_plu';
  static const String respInsertPlu = 'resp_insert_plu';
  static const String respDelPlu = 'resp_del_plu';
  static const String respGetUIConf = 'resp_get_ui_conf';
  static const String respUpdateUIConf = 'resp_update_ui_conf';
  static const String respChangeWifiMode = 'resp_change_wifi_mode';
  static const String respGetAllEepromData = 'resp_get_all_eeprom_info';
  static const String respGetOneEepromData = 'resp_get_one_eeprom_info';
  static const String respModifyEepromInfo = 'resp_modify_eeprom_info';
  static const String respModifyVarValue = 'resp_modify_var_value';
  static const String respSetServerIP = 'resp_set_server_ip';
  static const String respGetFactoryInfo = 'resp_get_factory_info';
  static const String respUpdateFirmwareNet = 'resp_update_firmware_wifi';
  static const String respGetBasicData = 'resp_get_basic_data';
  static const String respSetLimit = 'resp_set_limit_to_scale';
  static const String respSwitchLimit = 'resp_switch_limit_from_scale';
  static const String respRevDetailTail = 'resp_rev_detail_tail';
  static const String respExportRecs = 'resp_export_recs';
  static const String respImportRecs = 'resp_import_recs';
  static const String respSetCalWgt = 'resp_cal_weight';
  static const String respCalValue = 'resp_cal_value';
  static const String respSetGaduation1Value = 'resp_set_gaduation1_value';
  static const String respSetDecimalValue = 'resp_set_decimal_value';
  static const String respWifiPwdAdd = 'resp_wifi_pwd_add';
  static const String respGetGaduation1Value = 'resp_get_gaduation1_value';
  static const String respGetDecimalValue = 'resp_get_decimal_value';
  static const String respGetGravAcc = 'resp_get_grav_acc';
  static const String respGetWeightUnit = 'resp_get_weight_unit';
  static const String respGetMaxRange1 = 'resp_get_max_range1';
  static const String respGetManualZero = 'resp_get_manual_zero';
  static const String respGetZeroTracking = 'resp_get_zero_tracking';
  static const String respGetInitialZero = 'resp_get_initial_zero';

  static const String respSetMaxRange1 = 'resp_set_max_range1';
  static const String respSetManualZero = 'resp_set_manual_zero';
  static const String respSetWeightUnit = 'resp_set_weight_unit';
  static const String respSetInitialZero = 'resp_set_initial_zero';
  static const String respSetZeroTracking = 'resp_set_zero_tracking';
  static const String respSetGravAcc = 'resp_set_grav_acc';
  static const String respGetWiredIp = 'resp_get_wired_ip';
  static const String respSetWiredIp = 'resp_set_wired_ip';
  static const String respSetWiredDhcp = 'resp_set_wired_dhcp';
  static const String respGetWiredDhcp = 'resp_get_wired_dhcp';
  static const String respGetSealStatus = 'resp_get_seal_status';
  static const String respSoftSeal = 'resp_soft_seal';
  static const String respRemoveSoftSeal = 'resp_remove_soft_seal';
  static const String respRemoveSoftSealOnce = 'resp_remove_soft_seal_once';
  static const String respSetSerialPort = 'resp_set_serial_port';
  static const String respGetSerialPort = 'resp_get_serial_port';

  static final Map<String, Function> handlers = {
    RespMsgType.respGetUIConf: handleGetUIConf,
    RespMsgType.weightData: handleWeightData,
    RespMsgType.respDownPrnFmt: handleRespDownPrnFmt,
    RespMsgType.respDownDefPrnFmt: handleRespDefDownPrnFmt,
    RespMsgType.respErrSerial: handleRespErrSerial,
    RespMsgType.respBTPassthData: handleRespBTPassthData,
    RespMsgType.respSetWifiDynamicIp: handleRespSetWifiDynamicIp,
    RespMsgType.respSetWifiStaticIp: handleRespSetWifiStaticIp,
    RespMsgType.respUpdateFirmware: handleRespUpdateFirmware,
    RespMsgType.respUpdateFirmwareProgress: handleRespUpdateFirmwareProgress,
    RespMsgType.respCheckSerialPort: handleRespCheckSerialPort,
    RespMsgType.respGetBuildInfo: handleRespGetBuildInfo,
    RespMsgType.respGetScaleTime: handleRespGetScaleTime,
    RespMsgType.respSetScaleTime: handleRespSetScaleTime,
    RespMsgType.respGetWeightErr: handleRespGetWeightErr,
    RespMsgType.respSetOutputFmt: handleRespSetOutputFmt,
    RespMsgType.scalePassthData: handlescalePassthData,
    RespMsgType.respOpenScalePassthrough: handleRespOpenScalePassthrough,
    RespMsgType.respCloseScalePassthrough: handleRespCloseScalePassthrough,
    RespMsgType.respUnregWeight: handleRespUnregWeight,
    RespMsgType.respDelRec: handleRespDelRec,
    RespMsgType.respDownPlu: handleRespDownPlu,
    RespMsgType.respInsertPlu: handleRespInsertPlu,
    RespMsgType.respDelPlu: handleRespDelPlu,
    RespMsgType.respUpdateUIConf: handleRespUpdateUIConf,
    RespMsgType.respChangeWifiMode: handleRespChangeWifiMode,
    RespMsgType.respGetIpInfo: handleRespGetIpInfo,
    RespMsgType.respConnectAp: handleRespConnectAp,
    RespMsgType.respConnectApOneKey: handleRespConnectApOneKey,
    RespMsgType.respGetApList: handleRespGetApList,
    RespMsgType.respGetIpMode: handleRespGetIpMode,
    RespMsgType.respGetWifiApInfo: handleRespGetWifiApInfo,
    RespMsgType.respGetRecs: handleRespGetRecs,
    RespMsgType.respRegWeight: handleRespRegWeight,
    RespMsgType.respModifyBTName: handleRespModifyBTName,
    RespMsgType.respGetAllEepromData: handleRespGetAllEepromData,
    RespMsgType.respGetOneEepromData: handleRespGetOneEepromData,
    RespMsgType.respModifyEepromInfo: handleRespModifyEepromInfo,
    RespMsgType.respModifyVarValue: handleRespModifyVarValue,
    RespMsgType.respSetServerIP: handleRespSetServerIp,
    RespMsgType.respGetFactoryInfo: handleRespGetfactoryInfo,
    RespMsgType.respUpdateFirmwareNet: handleRespUpdateFirmwareNet,
    RespMsgType.respGetBasicData: handleRespGetBasicData,
    RespMsgType.respSetLimit: handleRespSetLimit,
    RespMsgType.respSwitchLimit: handleRespSwitchLimit,
    RespMsgType.respRevDetailTail: handleRespRevDetailTail,
    RespMsgType.respExportRecs: handleRespExportRecs,
    RespMsgType.respAddRec: handleRespAddRec,
    RespMsgType.respSetCalWgt: handleSetCalWgt,
    RespMsgType.respCalValue: handleCalValue,
    RespMsgType.respSetGaduation1Value: handleSetDecimalValue,
    RespMsgType.respSetDecimalValue: handleSetDecimalValue,
    RespMsgType.respGetGaduation1Value: handleRespGetGaduation1Value,
    RespMsgType.respGetDecimalValue: handleRespGetDecimalValue,
    RespMsgType.respGetGravAcc: handleRespGetGravAcc,
    RespMsgType.respGetWeightUnit: handleRespGetWeightUnit,
    RespMsgType.respGetMaxRange1: handleRespGetMaxRange1,
    RespMsgType.respGetManualZero: handleRespGetManualZero,
    RespMsgType.respGetZeroTracking: handleRespGetZeroTracking,
    RespMsgType.respGetInitialZero: handleRespGetInitialZero,
    RespMsgType.respSetMaxRange1: handleSetDecimalValue,
    RespMsgType.respSetManualZero: handleSetDecimalValue,
    RespMsgType.respSetWeightUnit: handleSetDecimalValue,
    RespMsgType.respSetInitialZero: handleSetDecimalValue,
    RespMsgType.respSetZeroTracking: handleSetDecimalValue,
    RespMsgType.respSetGravAcc: handleSetDecimalValue,
    RespMsgType.respGetWiredIp: handleRespGetWiredIp,
    RespMsgType.respSetWiredIp: handleRespSetWiredIp,
    RespMsgType.respSetWiredDhcp: handleRespSetWiredDhcp,
    RespMsgType.respGetWiredDhcp: handleRespGetWiredDhcp,
    RespMsgType.respGetSealStatus: handleRespGetSealStatus,
    RespMsgType.respSoftSeal: handleRespSoftSeal,
    RespMsgType.respRemoveSoftSeal: handleRespRemoveSoftSeal,
    RespMsgType.respRemoveSoftSealOnce: handleRespRemoveSoftSealOnce,
    RespMsgType.respSetSerialPort: handleRespSetSerialPort,
    RespMsgType.respGetSerialPort: handleRespGetSerialPort,
  };

  static void handleGetUIConf(dynamic data) {
    final jsonResponse = json.decode(data['MsgBody']);
    mySettingParam = SettingParam.fromJson(jsonResponse);

    eventBus.fire(EventSettingParam(mySettingParam));
  }

  static void handleWeightData(dynamic data) {
    dynamic mobj = ReqWeightCountine.fromJson(data);
    eventBus.fire(EventReqWeightCountine(mobj));
  }

  static void handleRespDownPrnFmt(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventDownPrnFmtResp(mobj));
  }

  static void handleRespDefDownPrnFmt(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventDownDefPrnFmtResp(mobj));
  }

  static void handleRespErrSerial(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventSerialPortResponse(mobj));
  }

  static void handleRespModifyBTName(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventConnectBTResponse(mobj));
  }

  static void handleRespGetAllEepromData(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventGetAllEepromDateResp(mobj));
  }

  static void handleRespGetOneEepromData(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventGetOneEepromDateResp(mobj));
  }

  static void handleRespModifyEepromInfo(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventModifyEepromInfoResp(mobj));
  }

  static void handleRespModifyVarValue(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventModifyVarValueResp(mobj));
  }

  static void handleRespSetServerIp(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventSetServerIPResp(mobj));
  }

  static void handleRespBTPassthData(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventBTResponse(mobj));
  }

  static void handleRespSetWifiDynamicIp(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventConnectDynamicIp(mobj));
  }

  static void handleRespSetWifiStaticIp(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventConnectStaticIp(mobj));
  }

  static void handleRespUpdateFirmware(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRespUpdateFirmware(mobj));
  }

  static void handleRespUpdateFirmwareProgress(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRespUpdateFirmwareProcess(mobj));
  }

  static void handleRespGetBuildInfo(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventGetBuildInfo(mobj));
  }

  static void handleRespGetScaleTime(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventGetScaleTime(mobj));
  }

  static void handleRespSetScaleTime(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventSetScaleTime(mobj));
  }

  static void handleRespGetWeightErr(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventGetWeightErr(mobj));
  }

  static void handleRespSetOutputFmt(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventSerialOutputResp(mobj));
  }

  static void handlescalePassthData(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventScalePassthData(mobj));
  }

  static void handleRespOpenScalePassthrough(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventOpenScalePassthResp(mobj));
  }

  static void handleRespCloseScalePassthrough(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventCloseScalePassthResp(mobj));
  }

  static void handleRespRegWeight(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRegWeightResp(mobj));
  }

  static void handleRespUnregWeight(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventUnregWeightResp(mobj));
  }

  static void handleRespDelRec(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventDeleteRec(mobj));
  }

  static void handleRespDownPlu(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRespDownPlu(mobj));
  }

  static void handleRespInsertPlu(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRespInsertPlu(mobj));
  }

  static void handleRespDelPlu(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRespDelPlu(mobj));
  }

  static void handleRespUpdateUIConf(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventUpdateSettingParam(mobj));
  }

  static void handleRespChangeWifiMode(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRespChangeWiFiMode(mobj));
  }

  static void handleRespGetIpInfo(dynamic data) {
    final jsonStrings = data['MsgBody'];
    pasterIpInfo(jsonStrings);
  }

  static void pasterIpInfo(String jsonStrings) {
    if (jsonStrings.contains('error') || jsonStrings.contains('fail')) {
      myGetIpError.messagedata = jsonStrings;
      eventBus.fire(EventGetIpError(myGetIpError));
      return;
    }
    final jsonResponse = json.decode(jsonStrings);
    myIpInfoData = IpInfoData.fromJson(jsonResponse);
    eventBus.fire(EventIpInfo(myIpInfoData));
  }

  static void handleRespConnectAp(dynamic data) {
    final jsonStrings = data['MsgBody'];
    pasterConnectApInfo(jsonStrings);
  }

  static void handleRespConnectApOneKey(dynamic data) {
    final jsonStrings = data['MsgBody'];
    pasterConnectApInfo(jsonStrings);
  }

  static void pasterConnectApInfo(String jsonDataString) {
    String jsonStrings = jsonDataString;
    myRespDataFromScale.msgBody = jsonStrings;
    eventBus.fire(EventConnectAp(myRespDataFromScale));
  }

  static void handleRespGetApList(dynamic data) {
    final jsonStrings = data['MsgBody'];
    pasterWifiList(jsonStrings);
  }

  static void pasterWifiList(String jsonStrings) {
    if (jsonStrings.contains('error') ||
        jsonStrings.contains('fail') ||
        jsonStrings.contains('done')) {
      myGetWifiListError.messagedata = jsonStrings;
      eventBus.fire(EventGetWifiListError(myGetWifiListError));
      return;
    }
    final jsonResponse = json.decode(jsonStrings);
    myWifiListInfo = WifiListInfo.fromJson(jsonResponse);
    eventBus.fire(EventWiFiListInfo(myWifiListInfo));
  }

  static void handleRespGetIpMode(dynamic data) {
    final jsonStrings = data['MsgBody'];
    pasterGetIpMode(jsonStrings);
  }

  static void pasterGetIpMode(String jsonDataString) {
    String jsonStrings = jsonDataString;
    myRespGetIpMode.messagedata = jsonStrings;
    eventBus.fire(EventRespGetIpMode(myRespGetIpMode));
  }

  static void handleRespGetWifiApInfo(dynamic data) {
    final jsonStrings = data['MsgBody'];
    pasterWifiApInfo(jsonStrings);
  }

  static void pasterWifiApInfo(String jsonStrings) {
    if (jsonStrings.contains('error') || jsonStrings.contains('fail')) {
      myMessageError.messagedata = jsonStrings;
      eventBus.fire(EventMessageError(myMessageError));
      return;
    }
    final jsonResponse = json.decode(jsonStrings);
    myWiFiAPInfo = WiFiAPInfo.fromJson(jsonResponse);
    eventBus.fire(EventGetWifiApInfo(myWiFiAPInfo));
  }

  static void handleRespGetRecs(dynamic data) {
    final jsonStrings = data['MsgBody'];
    pasterGetRecords(jsonStrings);
  }

  static void pasterGetRecords(String jsonDataString) {
    if (myGetScaleRecords.weightRecords != null) {
      myGetScaleRecords.weightRecords!.clear();
    }
    if (jsonDataString.isNotEmpty) {
      var newData = GetScaleRecords.fromJson(json.decode(jsonDataString));
      if (newData.weightRecords != null) {
        if (myGetScaleRecords.weightRecords == null) {
          myGetScaleRecords.weightRecords = newData.weightRecords;
        } else {
          myGetScaleRecords.weightRecords!.addAll(newData.weightRecords!);
        }
      }
    }
    eventBus.fire(EventGetScaleRecords(myGetScaleRecords));
  }

  // static void pasterGetRecords(String jsonDataString) {
  //   if (jsonDataString == '[]') {
  //     if (myGetScaleRecords.weightRecords != null) {
  //       myGetScaleRecords.weightRecords!.clear();
  //     }
  //   } else if (jsonDataString.isNotEmpty) {
  //     myGetScaleRecords = GetScaleRecords.fromJson(json.decode(jsonDataString));
  //   } else {
  //     if (myGetScaleRecords.weightRecords != null) {
  //       myGetScaleRecords.weightRecords!.clear();
  //     }
  //   }

  //   eventBus.fire(EventGetScaleRecords(myGetScaleRecords));
  // }

  static void handleRespGetfactoryInfo(dynamic data) {
    final jsonStrings = data['MsgBody'];
    dynamic mobj;
    if (!jsonStrings.contains('fail')) {
      mobj = FactoryInfoFromScale.fromJson(json.decode(jsonStrings));
    } else {
      mobj = FactoryInfoFromScale(
        "",
        "",
      );
    }
    eventBus.fire(EventGetFactoryInfo(mobj));
  }

  static void handleRespGetBasicData(dynamic data) {
    final jsonStrings = data['MsgBody'];
    dynamic mobj;
    mobj = jsonStrings;
    eventBus.fire(EventGetBasicData(mobj));
  }

  static void handleRespSetLimit(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventSetLimitToScale(mobj));
  }

  static void handleRespSwitchLimit(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventSwitchLimitFromScale(mobj));
  }

  static void handleRespRevDetailTail(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevDetailTail(mobj));
  }

  static void handleRespExportRecs(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevExportRecs(mobj));
  }

  static void handleRespAddRec(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevAddRec(mobj));
  }

  static void handleSetCalWgt(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevCalWeight(mobj));
  }

  static void handleCalValue(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevCalValue(mobj));
  }

  static void handleSetGaduation1Value(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevSetGaduationValue(mobj));
  }

  static void handleSetDecimalValue(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevSetDecimalValue(mobj));
  }

  static void handleRespGetWiredIp(dynamic data) {
    final jsonStrings = data['MsgBody'];
    eventBus.fire(EventRevGetWiredIp(jsonStrings));
  }

  static void handleRespSetWiredIp(dynamic data) {
    final jsonStrings = data['MsgBody'];
    eventBus.fire(EventRevSetWiredIp(jsonStrings));
  }

  static void handleRespSetWiredDhcp(dynamic data) {
    final jsonStrings = data['MsgBody'];
    eventBus.fire(EventRevSetWiredDhcp(jsonStrings));
  }

  static void handleRespGetWiredDhcp(dynamic data) {
    final jsonStrings = data['MsgBody'];
    eventBus.fire(EventRevGetWiredDhcp(jsonStrings));
  }

  static void handleRespGetGaduation1Value(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevGetGaduation1Value(mobj));
  }

  static void handleRespGetDecimalValue(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevGetDecimalValue(mobj));
  }

  static void handleRespGetGravAcc(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevGetGravAcc(mobj));
  }

  static void handleRespGetWeightUnit(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevGetWeightUnit(mobj));
  }

  static void handleRespGetMaxRange1(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevGetMaxRange1(mobj));
  }

  static void handleRespGetManualZero(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevGetManualZero(mobj));
  }

  static void handleRespGetZeroTracking(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevGetZeroTracking(mobj));
  }

  static void handleRespGetInitialZero(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevGetInitialZero(mobj));
  }

  static void handleRespUpdateFirmwareNet(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventUpdateFirmWareNetResp(mobj));
  }

  static void handleRespGetSealStatus(dynamic data) {
    final jsonStrings = data['MsgBody'];
    eventBus.fire(EventRevGetSealStatus(jsonStrings));
  }

  static void handleRespSoftSeal(dynamic data) {
    final jsonStrings = data['MsgBody'];
    eventBus.fire(EventRevSoftSeal(jsonStrings));
  }

  static void handleRespRemoveSoftSeal(dynamic data) {
    final jsonStrings = data['MsgBody'];
    eventBus.fire(EventRevRemoveSoftSeal(jsonStrings));
  }

  static void handleRespRemoveSoftSealOnce(dynamic data) {
    final jsonStrings = data['MsgBody'];
    eventBus.fire(EventRevRemoveSoftSealOnce(jsonStrings));
  }

  static void handleRespCheckSerialPort(dynamic data) {
    final jsonStrings = data['MsgBody'];
    int id = data['ScaleId'];
    if (!jsonStrings.contains('fail') && !jsonStrings.contains('timeout')) {
      myFactoryInfoFromScale =
          FactoryInfoFromScale.fromJson(json.decode(jsonStrings));
    } else {
      myFactoryInfoFromScale = FactoryInfoFromScale("", "");
      myOnlineInfo.factInfo = myFactoryInfoFromScale;
      myOnlineInfo.scaleId = id;
      for (var tempScale in myAllScalesList) {
        if (tempScale.scaleId == id) {
          tempScale.isOnline = false;
          break;
        }
      }

      return eventBus.fire(EventRespCheckNetScale(myOnlineInfo));
    }

    if (myFactoryInfoFromScale.modelName != '') {
      for (var tempScale in myAllScalesList) {
        if (tempScale.scaleId == id) {
          tempScale.scaleModel = myFactoryInfoFromScale.modelName!;
          tempScale.scaleSn = myFactoryInfoFromScale.scaleSn!;
          tempScale.isOnline = true;
          break;
        }
      }
    }
    myOnlineInfo.factInfo = myFactoryInfoFromScale;
    myOnlineInfo.scaleId = id;

    return eventBus.fire(EventRespCheckNetScale(myOnlineInfo));
  }

  static void handleRespTareCmd(dynamic data) {}

  static void handleRespSetSerialPort(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevSetSerialPort(mobj));
  }

  static void handleRespGetSerialPort(dynamic data) {
    dynamic mobj = ChannelResponse.fromJson(data);
    eventBus.fire(EventRevGetSerialPort(mobj));
  }
}
