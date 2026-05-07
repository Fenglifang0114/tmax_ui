// 系统数据0通道返回数据
import 'dart:async';
import 'dart:convert';
import 'package:t_max/data/cominfoslist_data.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/modifyresult_data.dart';
import 'package:t_max/data/pak_info_data.dart';
import 'package:t_max/data/plu_data_source.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/scalelist_data.dart';
import 'package:t_max/data/settingparam_data.dart';

import 'package:t_max/data/wifi_list_info.dart';
import '../data/ipinfodata.dart';
import '../data/manager_scale_channel.dart';
import '../data/wifi_pwd_info.dart';
import '../eventbus/eventbus.dart';

class RespSysMsgType {
  static const String respPortsList = 'resp_ports_list';
  static const String respBtList = 'resp_bt_list';
  static const String respScalesList = 'resp_scales_list';
  static const String respScaleModify = 'resp_scale_modify';
  static const String respProductList = 'resp_product_list';
  static const String respPluList = 'resp_plu_list';
  static const String respPluSetting = 'resp_plu_setting';

  static const String respProductDel = 'resp_product_del';
  static const String respDownAllPlu = 'resp_down_all_plu';

  static const String respGetLicense = 'resp_get_license';
  static const String respCheckLicenseKey = 'resp_check_license_key';
  static const String respGetApList = 'resp_get_ap_list';
  static const String respGetIpInfo = 'resp_get_ip_info';
  static const String respUpdateLicense = 'resp_update_license';
  static const String respScaleDel = 'resp_scale_del';
  static const String respScaleAdd = 'resp_scale_add';
  static const String respDetailList = 'resp_detail_list';
  static const String respNewDetail = 'resp_new_detail';
  static const String respDetailAdd = 'resp_detail_add';
  static const String respWifiPwdList = 'resp_wifi_pwd_list';
  static const String respScaleOnline = 'resp_scale_online';
  static const String respGetScaleSrvList = 'resp_get_scale_srv_list';
  static const String respDoServiceAction = 'resp_do_service_action';
  static const String respRawTypeList = 'resp_raw_type_list';
  static const String respFormulaTypeList = 'resp_formula_type_list';
  static const String respRawList = 'resp_raw_list';
  static const String respRawDataAdd = 'resp_raw_data_add';
  static const String respRawDataDelete = 'resp_raw_data_delete';
  static const String respRawDataEdit = 'resp_raw_data_edit';
  static const String respRawData = 'resp_raw_data';
  static const String respFmaData = 'resp_formula_data';

  static const String respFormulaTypeAdd = 'resp_formula_type_add';
  static const String respFmaTypeEdit = 'resp_fma_type_edit';
  static const String respFmaTypeDelete = 'resp_fma_type_delete';
  static const String respFmaTypeUnusedDel = 'resp_fma_type_unused_del';
  static const String respRawTypeUnusedDel = 'resp_raw_type_unused_del';
  static const String respFormulaList = 'resp_formula_list';
  static const String respFormulaAdd = 'resp_formula_add';
  static const String respFormulaUpdate = 'resp_formula_update';
  static const String respFormulaDelete = 'resp_formula_delete';
  static const String respFormulaRecList = 'resp_formula_rec_list';
  static const String respOneFmaRecList = 'resp_one_fma_rec_list';
  static const String respFormulaRecAdd = 'resp_formula_rec_add';
  static const String respRawTypeAdd = 'resp_raw_type_add';
  static const String respRawTypeEdit = 'resp_raw_type_edit';
  static const String respFlowRateList = 'resp_flow_rate_list';
  static const String respFlowRateAdd = 'resp_flow_rate_add';
  static const String respGetAllWgtRecList = 'resp_get_all_wgt_rec_list';
  static const String respGetUiConfig = 'resp_get_ui_config';
  static const String respUpdateUiConfig = 'resp_update_ui_config';
  static const String respDelWgtRec = 'resp_del_wgt_rec';
  static const String respAddWgtRec = 'resp_add_wgt_rec';
  static const String respExportAllRecs = 'resp_export_all_recs';
  static const String respWifiPwdAdd = 'resp_wifi_pwd_add';
  static const String respGetAutoNext = 'resp_get_auto_next';
  static const String respGetDraftFmaWgtRecList =
      'resp_get_draft_fma_wgt_rec_list';
  static const String respCreateDraftFmaWgtRecList =
      'resp_create_draft_fma_wgt_rec_list';
  static const String respUpdateDraftFmaWgtRecList =
      'resp_update_draft_fma_wgt_rec_list';
  static const String respDeleteDraftFmaWgtRecList =
      'resp_delete_draft_fma_wgt_rec_list';
  static const String respRawTypeDelete = 'resp_raw_type_delete';
  static const String respAddSysUser = 'resp_add_sys_user';
  static const String respDeleteSysUser = 'resp_delete_sys_user';
  static const String respUpdateSysUser = 'resp_update_sys_user';
  static const String respDisableSysUser = 'resp_disable_sys_user';
  static const String respChangePassword = 'resp_change_password';
  static const String respLogin = 'resp_login';
  static const String respGetAllUsers = 'resp_get_all_users';
  static const String respGetUserDetail = 'resp_get_user_detail';
  static const String respPluAdd = 'resp_product_add';
  static const String respProductAddOne = 'resp_product_add_one';
  static const String respGetLastProductRec = 'resp_get_last_product_rec';
  static const String respImportRawList = 'resp_raw_list_import';
  static const String respDelManyRaw = 'resp_many_raw_del';
  static const String respDelManyDraft = 'resp_many_draft_fma_del';
  static const String respDelManyFma = 'resp_many_fma_del';

  static const String respGetSysLogList = 'resp_get_sys_log_list';
  static const String respGetWgtLogList = 'resp_get_scale_log_list';
  static const String respDelSysLog = 'resp_del_sys_log';
  static const String respDelAllSysLog = 'resp_del_all_sys_log';
  static const String respExportSysLog = 'resp_export_sys_log';
  static const String respExportWgtLog = 'resp_export_scale_log';

  static const String respDelScaleLog = 'resp_del_scale_log';
  static const String respDelAllScaleLog = 'resp_del_all_scale_log';
  static const String respGetCalLogList = 'resp_get_cal_log_list';

  static const String respDelAllCalLog = 'resp_del_all_cal_log';
  static const String respDelCalLog = 'resp_del_cal_log';
  static const String respExportCalLog = 'resp_export_cal_log';
  static const String respCheckPluExist = 'resp_check_plu_exist';
  static const String respExportPluList = 'resp_export_plu_list';
  static const String respFormulasListByBarcode =
      'resp_formula_list_by_barcode';
  static const String respCheckFmaIdAndBarcode =
      'resp_check_fma_id_and_barcode';
  static const String respFormulaRecByOrder = 'resp_formula_rec_by_order';
  static const String respUploadServerGet = 'resp_upload_server_get';
  static const String respUploadServerEdit = 'resp_upload_server_edit';
  static const String respGetReportPrint = 'resp_get_set_report_print';
  static const String respGetAllSealLog = 'resp_get_all_seal_log';

  static const String respUnsealByMasterKey = 'resp_unseal_by_master_key';
  static const String respGetOutputPortStatus = 'resp_get_output_port';
  static const String respUpdateOutputPort = 'resp_update_output_port';
  static const String respRawOutputByFmaId = 'resp_raw_output_by_fma_id';

  static const String respOpenOutputPort = 'resp_open_output_port';
  static const String respGetInputPortStatus = 'resp_get_input_port';
  static const String respUpdateInputPort = 'resp_update_input_port';

  static const String respScaleInput = 'resp_scale_input'; // 按键输入

  static const String respGetUnstableZeroTare = 'resp_get_unstable_zero_tare';
  static const String respUpdateUnstableZeroTare =
      'resp_update_unstable_zero_tare';

  static final Map<String, Function> handlers = {
    RespSysMsgType.respPortsList: handlePortsList,
    RespSysMsgType.respBtList: handleBtList,
    RespSysMsgType.respScalesList: handleScalesList,
    RespSysMsgType.respScaleModify: handleScaleModify,
    RespSysMsgType.respProductList: handleProductList,
    RespSysMsgType.respPluList: handlePluList,
    RespSysMsgType.respPluSetting: handlePluSetting,
    RespSysMsgType.respGetLicense: handleGetLicense,
    RespSysMsgType.respCheckLicenseKey: handleCheckLicenseKey,
    RespSysMsgType.respGetApList: handleGetApList,
    RespSysMsgType.respGetIpInfo: handleGetIpInfo,
    RespSysMsgType.respUpdateLicense: handleUpdateLicense,
    RespSysMsgType.respScaleDel: handleScaleDel,
    RespSysMsgType.respScaleAdd: handleScaleAdd,
    RespSysMsgType.respDetailList: handleDetailList,
    RespSysMsgType.respNewDetail: handleNewDetail,
    RespSysMsgType.respDetailAdd: handleDetailAdd,
    RespSysMsgType.respWifiPwdList: handleWifiPwdList,
    RespSysMsgType.respScaleOnline: handleScaleOnline,
    RespSysMsgType.respGetScaleSrvList: handleGetScaleSrvList,
    RespSysMsgType.respDoServiceAction: handleDoServiceAction,
    RespSysMsgType.respRawTypeList: handleRawTypeList,
    RespSysMsgType.respFormulaTypeList: handleFormulaTypeList,
    RespSysMsgType.respRawList: handleRawList,
    RespSysMsgType.respRawData: handleRawData,
    RespSysMsgType.respRawDataAdd: handleRawDataAdd,
    RespSysMsgType.respRawDataDelete: handleRawDataDelete,
    RespSysMsgType.respRawDataEdit: handleRawDataEdit,
    RespSysMsgType.respFormulaTypeAdd: handleFormulaTypeAdd,
    RespSysMsgType.respFmaTypeEdit: handleFmaTypeEdit,
    RespSysMsgType.respFmaTypeDelete: handleFmaTypeDelete,
    RespSysMsgType.respFmaTypeUnusedDel: handleFmaTypeDelete,
    RespSysMsgType.respRawTypeUnusedDel: handleRawTypeDelete,
    RespSysMsgType.respFormulaList: handleFormulaList,
    RespSysMsgType.respFormulaAdd: handleFormulaAdd,
    RespSysMsgType.respFormulaUpdate: handleFormulaUpdate,
    RespSysMsgType.respFormulaDelete: handleFormulaDelete,
    RespSysMsgType.respFormulaRecList: handleFormulaRecList,
    RespSysMsgType.respOneFmaRecList: handleOneFmaRecList,
    RespSysMsgType.respFormulaRecAdd: handleFormulaRecAdd,
    RespSysMsgType.respRawTypeAdd: handleRawTypeAdd,
    RespSysMsgType.respRawTypeEdit: handleRawTypeEdit,
    RespSysMsgType.respFlowRateList: handleFlowRateList,
    RespSysMsgType.respFlowRateAdd: handleFlowRateAdd,
    RespSysMsgType.respGetAllWgtRecList: handleGetAllWgtRecList,
    RespSysMsgType.respGetUiConfig: handleGetUiConfig,
    RespSysMsgType.respUpdateUiConfig: handleUpdateUiConfig,
    RespSysMsgType.respDelWgtRec: handleDelWgtRec,
    RespSysMsgType.respAddWgtRec: handleAddWgtRec,
    RespSysMsgType.respExportAllRecs: handleExportAllRecs,
    RespSysMsgType.respWifiPwdAdd: handleWifiPwdAdd,
    RespSysMsgType.respGetAutoNext: handleGetAutoNext,
    RespSysMsgType.respGetDraftFmaWgtRecList: handleGetDraftFmaWgtRecList,
    RespSysMsgType.respCreateDraftFmaWgtRecList: handleCreateDraftFmaWgtRecList,
    RespSysMsgType.respUpdateDraftFmaWgtRecList: handleUpdateDraftFmaWgtRecList,
    RespSysMsgType.respDeleteDraftFmaWgtRecList: handleDeleteDraftFmaWgtRecList,
    RespSysMsgType.respRawTypeDelete: handleRawTypeDelete,
    RespSysMsgType.respAddSysUser: handleAddSysUser,
    RespSysMsgType.respDeleteSysUser: handleDeleteSysUser,
    RespSysMsgType.respUpdateSysUser: handleUpdateSysUser,
    RespSysMsgType.respDisableSysUser: handleDisableSysUser,
    RespSysMsgType.respChangePassword: handleChangePassword,
    RespSysMsgType.respLogin: handleLogin,
    RespSysMsgType.respGetAllUsers: handleGetAllUsers,
    RespSysMsgType.respGetUserDetail: handleGetUserDetail,
    RespSysMsgType.respPluAdd: handleRespPluAdd,
    RespSysMsgType.respProductAddOne: handleRespProductAddOne,
    RespSysMsgType.respGetLastProductRec: handleRespGetLastProductRec,
    RespSysMsgType.respImportRawList: handleRespImportRawList,
    RespSysMsgType.respDelManyRaw: handleRespDelManyRaw,
    RespSysMsgType.respDelManyFma: handleRespDelManyFma,
    RespSysMsgType.respDelManyDraft: handleRespDelManyDraft,
    RespSysMsgType.respFmaData: handleFmaData,
    RespSysMsgType.respGetSysLogList: handleRespGetSysLogList,
    RespSysMsgType.respGetWgtLogList: handleRespGetWgtLogList,
    RespSysMsgType.respDelSysLog: handleRespDelSysLog,
    RespSysMsgType.respDelAllSysLog: handleRespDelSysLog,
    RespSysMsgType.respExportSysLog: handleRespExportSysLog,
    RespSysMsgType.respDelScaleLog: handleRespDelWgtLog,
    RespSysMsgType.respDelAllScaleLog: handleRespDelWgtLog,
    RespSysMsgType.respExportWgtLog: handleRespExportWgtLog,
    RespSysMsgType.respGetCalLogList: handleRespGetCalLogList,
    RespSysMsgType.respDelCalLog: handleRespDelCalLog,
    RespSysMsgType.respDelAllCalLog: handleRespDelAllCalLog,
    RespSysMsgType.respExportCalLog: handleRespExportCalLog,
    RespSysMsgType.respProductDel: handleRespProductDel,
    RespSysMsgType.respCheckPluExist: handleRespCheckPluExist,
    RespSysMsgType.respExportPluList: handleRespExportPluList,
    RespSysMsgType.respDownAllPlu: handleRespDownAllPlu,
    RespSysMsgType.respFormulasListByBarcode: handleRespFormulasListByBarcode,
    RespSysMsgType.respCheckFmaIdAndBarcode: handleRespCheckFmaIdAndBarcode,
    RespSysMsgType.respFormulaRecByOrder: handleRespFormulaRecByOrder,
    RespSysMsgType.respUploadServerGet: handleRespUploadServerGet,
    RespSysMsgType.respUploadServerEdit: handleRespUploadServerEdit,
    RespSysMsgType.respGetReportPrint: handleRespGetReportPrint,
    RespSysMsgType.respGetAllSealLog: handleRespGetAllSealLog,
    RespSysMsgType.respUnsealByMasterKey: handleRespUnsealByMasterKey,
    RespSysMsgType.respGetOutputPortStatus: handleRespGetOutputPortStatus,
    RespSysMsgType.respUpdateOutputPort: handleRespUpdateOutputPort,
    RespSysMsgType.respRawOutputByFmaId: handleRespRawOutputByFmaId,
    RespSysMsgType.respOpenOutputPort: handleRespOpenOutputPort,
    RespSysMsgType.respGetInputPortStatus: handleRespGetInputPortStatus,
    RespSysMsgType.respUpdateInputPort: handleRespUpdateInputPort,
    RespSysMsgType.respScaleInput: handleRespScaleInput,
    RespSysMsgType.respGetUnstableZeroTare: handleRespGetUnstableZeroTare,
    RespSysMsgType.respUpdateUnstableZeroTare: handleRespUpdateUnstableZeroTare,
  };

  static void handleBtList(dynamic jsonData) {
    String dataString;
    dataString = jsonData['MsgBody'];
    String dataJson = json.decode(dataString); // 第一次解析：去掉外层的引号和转义
    eventBus.fire(EventBtInfoList(dataJson));
  }

  static void handlePortsList(dynamic jsonData) {
    String dataString;
    dataString = jsonData['MsgBody'];
    List<String> dataList = <String>[];
    for (var value in const JsonDecoder().convert(dataString)) {
      dataList.add(value);
    }
    myComInfoList.msgBody = dataList;
    Map<String, dynamic> map = json.decode(json.encode(myComInfoList));
    dynamic mobj = ComInfoList.fromJson(map);
    eventBus.fire(EventComInfoList(mobj));
  }

  static void handleScalesList(dynamic jsonData) {
    pasterScaleList(jsonData['MsgBody']);
  }

  static void handleScaleModify(dynamic jsonData) {
    pasterModifyAck(jsonData['MsgBody']);
  }

  static void handleProductList(dynamic jsonData) {
    pasterProductList(jsonData['MsgBody']);
  }

  static void handlePluList(dynamic jsonData) {
    eventBus.fire(EventPLuList(jsonData['MsgBody']));
  }

  static void handlePluSetting(dynamic jsonData) {
    eventBus.fire(EventRespPluSetting(jsonData['MsgBody']));
  }

  static void handleGetLicense(dynamic jsonData) {
    pasterLicense(jsonData['MsgBody']);
  }

  static void handleCheckLicenseKey(dynamic jsonData) {
    pasterLicenseKey(jsonData['MsgBody']);
  }

  static void handleGetApList(dynamic jsonData) {
    pasterWifiList(jsonData['MsgBody']);
  }

  static void handleGetIpInfo(dynamic jsonData) {
    pasterIpInfo(jsonData['MsgBody']);
  }

  static void handleUpdateLicense(dynamic jsonData) {
    var dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespUpdateLic(dataString));
  }

  static void handleScaleDel(dynamic jsonData) {
    var dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDelScale(dataString));
  }

  static void handleScaleAdd(dynamic jsonData) {
    var dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespAddScale(dataString));
  }

  static void handleDetailList(dynamic jsonData) {
    var dataString = jsonData['MsgBody'];

    try {
      PakInfo pakInfo = pakInfoFromJson(dataString);
      if (pakInfo.pagId == 1) {
        myDetailPakList = [];
      }
      if (pakInfo.msgBody == "null") {
        return;
      }
      myDetailPakList.add(pakInfo);
      if (pakInfo.pakCount == myDetailPakList.length) {
        //先把包排序
        myDetailPakList.sort((a, b) => a.pagId.compareTo(b.pagId));
        for (int i = 0; i < myDetailPakList.length; i++) {
          myDetailRevPak.msgBody.write(myDetailPakList[i].msgBody);
        }
        eventBus.fire(EventRespDetailInfo(''));
        myDetailPakList = [];
      }
    } catch (e) {
      return;
    }
  }

  static void handleNewDetail(dynamic jsonData) {
    var dataString = jsonData['MsgBody'];

    try {
      PakInfo pakInfo = pakInfoFromJson(dataString);
      if (pakInfo.pagId == 1) {
        myDetailPakList = [];
      }
      if (pakInfo.msgBody == "null") {
        return;
      }
      myDetailPakList.add(pakInfo);
      if (pakInfo.pakCount == myDetailPakList.length) {
        //先把包排序
        myDetailPakList.sort((a, b) => a.pagId.compareTo(b.pagId));
        for (int i = 0; i < myDetailPakList.length; i++) {
          myDetailRevPak.msgBody.write(myDetailPakList[i].msgBody);
        }
        eventBus.fire(EventRespNewDetailInfo(''));
        myDetailPakList = [];
      }
    } catch (e) {
      return;
    }
  }

  static void handleDetailAdd(dynamic jsonData) {
    var dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDetailAdd(dataString));
  }

  static void handleWifiPwdList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    if (dataString.isNotEmpty) {
      myWifiPwdInfoList = wifiPwdInfoListFromJson(dataString);
    }
  }

  static void handleScaleOnline(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    try {
      final jsonInfo = json.decode(dataString);
      ScaleIsOnline scaleOnline;
      scaleOnline = ScaleIsOnline.fromJson(jsonInfo);
      for (var scale in myAllScalesList) {
        if (scale.scaleId == scaleOnline.scaleId) {
          // 现在可以正常更新状态
          scale.isOnline = scaleOnline.isOnline!;
          if (scaleOnline.isOnline!) {
            scale.scaleModel = scaleOnline.modelName!;
            scale.scaleSn = scaleOnline.sn!;
          }
          eventBus.fire(EventRespScaleOnline(''));
          break;
        }
      }
    } catch (e) {
      return;
    }
  }

  static void handleGetScaleSrvList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespScaleSrvList(dataString));
  }

  static void handleDoServiceAction(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDoSrvAction(dataString));
  }

  static void handleRawTypeList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetRawTypeList(dataString));
  }

  static void handleFormulaTypeList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetFormulaTypeList(dataString));
  }

  static void handleRawList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetRawDataList(dataString));
  }

  static void handleRawData(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetRawData(dataString));
  }

  static void handleRawDataAdd(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespAddRawData(dataString));
  }

  static void handleRawDataDelete(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDelRawData(dataString));
  }

  static void handleRawDataEdit(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespEditRawData(dataString));
  }

  static void handleFormulaTypeAdd(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespAddFormulaType(dataString));
  }

  static void handleRespFormulasListByBarcode(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespFormulasListByBarcode(dataString));
  }

  static void handleRespCheckFmaIdAndBarcode(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespCheckFmaIdAndBarcode(dataString));
  }

  static void handleRespFormulaRecByOrder(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespFormulaRecByOrder(dataString));
  }

  static void handleRespUploadServerGet(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespUploadServerGet(dataString));
  }

  static void handleRespUploadServerEdit(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespUploadServerEdit(dataString));
  }

  static void handleRespGetReportPrint(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetReportPrint(dataString));
  }

  static void handleRespGetAllSealLog(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetAllSealLog(dataString));
  }

  static void handleRespGetOutputPortStatus(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetOutputPortStatus(dataString));
  }

  static void handleRespUpdateOutputPort(dynamic jsonData) {
    eventBus.fire(EventRespUpdateOutputPort(""));
  }

  static void handleRespGetInputPortStatus(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetInputPortStatus(dataString));
  }

  static void handleRespUpdateInputPort(dynamic jsonData) {
    eventBus.fire(EventRespUpdateInputPort(""));
  }

  static void handleRespScaleInput(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespScaleInput(dataString));
  }

  static void handleRespGetUnstableZeroTare(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventGetUnstableZeroTare(dataString));
  }

  static void handleRespUpdateUnstableZeroTare(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventUnstableZeroTare(dataString));
  }

  static void handleRespOpenOutputPort(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespOpenOutputPort(dataString));
  }

  static void handleRespRawOutputByFmaId(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespRawOutputByFmaId(dataString));
  }

  static void handleRespUnsealByMasterKey(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespUnsealByMasterKey(dataString));
  }

  static void handleFmaTypeEdit(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespAddFormulaType(dataString));
  }

  static void handleFmaTypeDelete(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespAddFormulaType(dataString));
  }

  static void handleFormulaList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespFormulaList(dataString));
  }

  static void handleFormulaAdd(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespAddFormula(dataString));
  }

  static void handleFormulaUpdate(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespEditFormula(dataString));
  }

  static void handleFmaData(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetFmaData(dataString));
  }

  static void handleFormulaDelete(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDelFormula(dataString));
  }

  static void handleFormulaRecList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespFormulaRecList(dataString));
  }

  static void handleOneFmaRecList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespOneFmaRecList(dataString));
  }

  static void handleFormulaRecAdd(dynamic jsonData) {
    eventBus.fire(EventRespFormulaRecAdd(''));
  }

  static void handleRawTypeAdd(dynamic jsonData) {
    eventBus.fire(EventRespRawTypeAdd(''));
  }

  static void handleRawTypeEdit(dynamic jsonData) {
    eventBus.fire(EventRespRawTypeAdd(''));
  }

  static void handleFlowRateList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespFlowRateList(dataString));
  }

  static void handleFlowRateAdd(dynamic jsonData) {
    eventBus.fire(EventRespFlowRateAdd(''));
  }

  static void handleGetAllWgtRecList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetAllWgtRecs(dataString));
  }

  static void handleGetUiConfig(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    handleGetUIConf(dataString);
  }

  static void handleWifiPwdAdd(dynamic jsonData) {
    eventBus.fire(EventRevWifiPwdAdd(''));
  }

  static void handleUpdateUiConfig(dynamic jsonData) {
    eventBus.fire(EventUpdateSettingParam(''));
  }

  static void handleDelWgtRec(dynamic jsonData) {
    eventBus.fire(EventDelAllWgtRecs(''));
  }

  static void handleAddWgtRec(dynamic jsonData) {
    eventBus.fire(EventAddWgtRec(''));
  }

  static void handleExportAllRecs(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventExportAllRecs(dataString));
  }

  static void handleGetAutoNext(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetAutoNext(dataString));
  }

  static void handleGetDraftFmaWgtRecList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetDraftFmaWgtRecList(dataString));
  }

  static void handleCreateDraftFmaWgtRecList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespCreateDraftFmaWgtRecList(dataString));
  }

  static void handleUpdateDraftFmaWgtRecList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespUpdateDraftFmaWgtRecList(dataString));
  }

  static void handleDeleteDraftFmaWgtRecList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDelDraftFmaWgtRecList(dataString));
  }

  static void handleRawTypeDelete(dynamic jsonData) {
    eventBus.fire(EventRespRawTypeAdd(''));
  }

  static void handleGetUIConf(String data) {
    var jsonData = json.decode(data);
    mySettingParam = SettingParam.fromJson(jsonData);

    eventBus.fire(EventSettingParam(mySettingParam));
  }

  static void pasterLicense(String jsonDataString) {
    if (jsonDataString.isNotEmpty) {
      var jsonData = json.decode(jsonDataString);
      try {
        List<dynamic> jsonList = json.decode(jsonDataString);
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
    eventBus.fire(EventLicenseData(jsonDataString));
  }

  static void pasterLicenseKey(String jsonDataString) {
    eventBus.fire(EventCheckLicenseKey(jsonDataString));
  }

  static void pasterProductList(String jsonDataString) {
    String jsonStrings = jsonDataString;
    // final jsonResponse = json.decode(jsonStrings);

    var myPluListFormDb = pluDataFromDbFromJson(jsonStrings);
    if (myPluListFormDb.isNotEmpty) {
      eventBus.fire(EventProductRecList(myPluListFormDb));
    } else {
      myPluListFormDb.clear();
      eventBus.fire(EventProductRecList(myPluListFormDb));
    }
  }

  static void handleAddSysUser(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespAddSysUser(dataString));
  }

  static void handleDeleteSysUser(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDeleteSysUser(dataString));
  }

  static void handleUpdateSysUser(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespUpdateSysUser(dataString));
  }

  static void handleDisableSysUser(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDisableSysUser(dataString));
  }

  static void handleChangePassword(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    mySysUser.isChanged = true;
    eventBus.fire(EventRespChangePassword(dataString));
  }

  static void handleLogin(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespLogin(dataString));
  }

  static void handleGetAllUsers(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetAllUsers(dataString));
  }

  static void handleGetUserDetail(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetUserDetail(dataString));
  }

  static void handleRespGetSysLogList(dynamic jsonData) {
    String data = jsonData['MsgBody'];
    eventBus.fire(EventRespGetSysLogList(data));
  }

  static void handleRespGetCalLogList(dynamic jsonData) {
    String data = jsonData['MsgBody'];
    eventBus.fire(EventRespGetCalLogList(data));
  }

  static void handleRespGetWgtLogList(dynamic jsonData) {
    String data = jsonData['MsgBody'];
    eventBus.fire(EventRespGetWgtLogList(data));
  }

  static void handleRespDelSysLog(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDelSysLog(dataString));
  }

  static void handleRespDelCalLog(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDelCalLog(dataString));
  }

  static void handleRespDelAllCalLog(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDelCalLog(dataString));
  }

  static void handleRespDelWgtLog(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDelWgtLog(dataString));
  }

  static void handleRespExportSysLog(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespExportSysLog(dataString));
  }

  static void handleRespExportWgtLog(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespExportWgtLog(dataString));
  }

  static void handleRespExportCalLog(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespExportCalLog(dataString));
  }

  static void handleRespProductDel(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespProductDel(dataString));
  }

  static void handleRespCheckPluExist(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespExistPlu(dataString));
  }

  static void handleRespExportPluList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespExportPluList(dataString));
  }

  static void handleRespDownAllPlu(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDownAllPlu(dataString));
  }

  static void handleRespPluAdd(dynamic jsonData) {
    eventBus.fire(EventRespPluAdd(''));
  }

  static void handleRespProductAddOne(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespProductAddOne(dataString));
  }

  static void handleRespGetLastProductRec(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespGetLastProductRec(dataString));
  }

  static void handleRespImportRawList(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespImportRawList(dataString));
  }

  static void handleRespDelManyFma(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDelManyFma(dataString));
  }

  static void handleRespDelManyDraft(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDelManyDraft(dataString));
  }

  static void handleRespDelManyRaw(dynamic jsonData) {
    String dataString = jsonData['MsgBody'];
    eventBus.fire(EventRespDelManyRaw(dataString));
  }
}

Future<void> pasterScaleList(String jsonDataString) async {
  String jsonStrings = jsonDataString;
  final jsonResponse = json.decode(jsonStrings);
  myScaleTotalInfo = ScaleTotalInfo.fromJson(jsonResponse);

  if (myScaleTotalInfo.scaleDataList!.isNotEmpty) {
    final tempScalesList = ScaleParser.parseScales(jsonStrings);

    for (int i = 0; i < tempScalesList.length; i++) {
      var tempScale = tempScalesList[i];
      // 查找 myAllScalesList 中是否存在相同 scaleId 的项
      final existingIndex = myAllScalesList
          .indexWhere((scale) => scale.scaleId == tempScale.scaleId);
      if (existingIndex == -1) {
        // 若不存在，则添加新项
        myAllScalesList.add(tempScale);
        String url = GetUrl.getUrl(tempScale.scaleId);
        manager.connect(tempScale.scaleId, url);
      } else {
        // 若存在，则更新相应项的属性
        var existingScale = myAllScalesList[existingIndex];
        tempScale.isOnline = existingScale.isOnline;
        tempScale.scaleModel = existingScale.scaleModel;
        tempScale.scaleSn = existingScale.scaleSn;
      }
    }
    myAllScalesList = List<Scale>.from(tempScalesList);

    List<int> connectedScaleIds = manager.connectedScaleIds;

    for (var key in connectedScaleIds) {
      final existingIndex =
          myAllScalesList.indexWhere((scale) => scale.scaleId == key);
      if (existingIndex == -1) {
        // 若 myAllScalesList 中不存在该 scaleId，则关闭连接
        manager.dispose(key);
      }
    }
  } else {
    myAllScalesList.clear();
    List<int> connectedScaleIds = manager.connectedScaleIds;
    for (var key in connectedScaleIds) {
      manager.dispose(key);
    }
  }
  eventBus.fire(EventRespAddScale('scale list'));
}

Future pasterComMediaInfo(
    String jsonDataString, ScaleDataInfo scaleInfo) async {
  final jsonResponse = json.decode(jsonDataString);
  myCurrentPort = CurrentPort.fromJson(jsonResponse);

  getComScaleList(scaleInfo, myCurrentPort);
}

Future pasterNetMediaInfo(
    String jsonDataString, ScaleDataInfo scaleInfo) async {
  final jsonResponse = json.decode(jsonDataString);
  myNetInfo = NetInfo.fromJson(jsonResponse);
  getNetScaleList(scaleInfo, myNetInfo);
}

Future pasterWifiList(String jsonDataString) async {
  String jsonStrings = jsonDataString;
  final jsonResponse = json.decode(jsonStrings);
  myWifiListInfo = WifiListInfo.fromJson(jsonResponse);

  if (myWifiListInfo.wifidatalist!.isNotEmpty) {
    eventBus.fire(EventWiFiListInfo(myWifiListInfo));
  }
}

Future pasterIpInfo(String jsonDataString) async {
  String jsonStrings = jsonDataString;
  final jsonResponse = json.decode(jsonStrings);
  myIpInfoData = IpInfoData.fromJson(jsonResponse);
  eventBus.fire(EventIpInfoData(myIpInfoData));
}

void getComScaleList(ScaleDataInfo scaleInfo, CurrentPort mediaJson) {
  ComScaleInfo tempScaleInfo =
      ComScaleInfo(1, 1, true, "", 1, 1, 1, 1, "", "", false, "");
  tempScaleInfo.scaleModel = scaleInfo.scaleModel!;

  tempScaleInfo.isOnline = scaleInfo.isOnline!;
  tempScaleInfo.scaleId = scaleInfo.scaleId!;
  tempScaleInfo.tMedia = scaleInfo.tMedia!;
  tempScaleInfo.scaleSn = scaleInfo.scaleSn!;
  tempScaleInfo.isDefault = scaleInfo.isDefault!;
  tempScaleInfo.scaleName = scaleInfo.scaleName!;

  tempScaleInfo.portName = myCurrentPort.devPath!;
  tempScaleInfo.baudRate = myCurrentPort.baud!;
  tempScaleInfo.dataBits = myCurrentPort.dataBits!;
  tempScaleInfo.parity = myCurrentPort.parity!;
  tempScaleInfo.stopBits = myCurrentPort.stopBits!;
  // 查找是否存在相同 scaleId 的秤信息
  final existingIndex = myComScaleList
      .indexWhere((scale) => scale.scaleId == tempScaleInfo.scaleId);
  if (existingIndex != -1) {
    return;
  } else {}
  myComScaleList.add(tempScaleInfo);
  String url = GetUrl.getUrl(scaleInfo.scaleId!);

  manager.connect(scaleInfo.scaleId!, url);
}

void getNetScaleList(ScaleDataInfo scaleInfo, NetInfo netInfo) {
  NetScaleInfoLocal newNetScale = NetScaleInfoLocal();
  newNetScale.scaleModel = scaleInfo.scaleModel!;
  newNetScale.isOnline = scaleInfo.isOnline!;
  newNetScale.scaleId = scaleInfo.scaleId!;
  newNetScale.scaleSn = scaleInfo.scaleSn!;
  newNetScale.tMedia = scaleInfo.tMedia!;
  newNetScale.isDefault = scaleInfo.isDefault!;
  newNetScale.scaleCat = scaleInfo.scaleCat!;
  newNetScale.ip = netInfo.ip;
  newNetScale.port = netInfo.port;
  newNetScale.scaleName = scaleInfo.scaleName!;
  NetScaleListMgr.addScale(myNetScaleList, newNetScale);
  String url = GetUrl.getUrl(scaleInfo.scaleId!);

  manager.connect(scaleInfo.scaleId!, url);
  if (myDefScaleInfo.defScaleId == scaleInfo.scaleId!) {
    DefScaleInfo.getDefScaleInfo(scaleInfo.scaleId!);
  }
}

pasterModifyAck(String jsonDataString) {
  String jsonStrings = jsonDataString;
  final jsonResponse = json.decode(jsonStrings);
  myModifyAck = ModifyAck.fromJson(jsonResponse);

  eventBus.fire(EventRespScaleModify(myModifyAck));
}
