import 'dart:convert';
import 'package:t_max/data/new_get_recs.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/sys_user_req.dart';
import 'package:t_max/data/writelog.dart';

import '../common/web_socket_channel.dart';
import '../data/download_prt_fmt.dart';
import '../data/manager_scale_channel.dart';
import '../data/scalecmd_data.dart';

/// 常规称重模式。
const String weighingMode = '0';

/// 检重/误差检测模式。
const String weighingCheckMode = '1';

/// 入库/进料模式。
const String weighingTakeInMode = '2';

/// 出库/发料模式。
const String weighingTakeOutMode = '3';

/// 本项目核心的业务网关请求库。
/// 封装了所有底层向硬件及数据库请求的方法指令（基于 [WebSocket] JSON 通信格式）。
/// 方法命名主要由动词开头，调用 [sendMsgChan0] 统一打包分发至主通道。
class PublicFunctions {
  static void function1() {}

  /// 基础消息下发方法。用于向指定的离散辅秤 [scaleId] 通信。
  static void sendMsg(int scaleId, String str) {
    manager.sendMessage(scaleId, str);
  }

  /// 核心系统消息下发方法。调用单例 [WebSocketManager] 往网关管道投递系统请求指令字符串。
  static void sendMsgChan0(String str) {
    WebSocketManager().sendMessage(str);
  }

  /// 提取系统日志记录。指令：`get_sys_log`。
  static void getSysLog(String jsonStr) {
    myScaleCmd.cmdMode = "get_sys_log";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  /// 读取称重过磅的数据库历史记录列表。指令：`get_scale_log`。
  static void getWgtLogList(String jsonStr) {
    myScaleCmd.cmdMode = "get_scale_log";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  /// 读取设备及仪表的标定作业日志。指令：`get_cal_log`。
  static void getCalLogList(String jsonStr) {
    myScaleCmd.cmdMode = "get_cal_log";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //导出系统日志
  static void exportSysLog(String jsonStr) {
    myScaleCmd.cmdMode = "export_sys_log";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //导出称重日志
  static void exportWgtLog(String jsonStr) {
    myScaleCmd.cmdMode = "export_scale_log";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //导出称重日志
  static void exportCalLog(String jsonStr) {
    myScaleCmd.cmdMode = "export_cal_log";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //增加标定
  static void addCalLog(String jsonStr) {
    myScaleCmd.cmdMode = "add_cal_log";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //删除系统日志
  static void deleteSysLog(String jsonStr) {
    myScaleCmd.cmdMode = "del_sys_log";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //删除称重日志
  static void deleteWgtLog(String jsonStr) {
    myScaleCmd.cmdMode = "del_scale_log";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //删除标定日志
  static void deleteCalLog(String jsonStr) {
    myScaleCmd.cmdMode = "del_cal_log";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //删除所有系统日志
  static void deleteAllSysLog() {
    myScaleCmd.cmdMode = "del_all_sys_log";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void deleteAllWgtLog() {
    myScaleCmd.cmdMode = "del_all_scale_log";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //删除所有标定日志
  static void deleteAllCalLog() {
    myScaleCmd.cmdMode = "del_all_cal_log";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void addUser(String str) {
    myScaleCmd.cmdMode = "add_user";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void modifyUser(String str) {
    myScaleCmd.cmdMode = "modify_user";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void delUser(String str) {
    myScaleCmd.cmdMode = "del_user";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getScaleList() {
    myScaleCmd.cmdMode = "get_scale_list";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getScaleSrvList(int srvId) {
    myScaleCmd.cmdMode = "get_scale_srv_list";
    myScaleCmd.cmdData = srvId.toString();
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  // Modbus Services APIs
  static void getModbusServices() {
    myScaleCmd.cmdMode = "get_modbus_services";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void addModbusService(String jsonStr) {
    myScaleCmd.cmdMode = "add_modbus_service";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void editModbusService(String jsonStr) {
    myScaleCmd.cmdMode = "edit_modbus_service";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void delModbusService(int id) {
    myScaleCmd.cmdMode = "del_modbus_service";
    myScaleCmd.cmdData = '{"Id": $id}';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void setScaleSrvStatus(String dataStr) {
    myScaleCmd.cmdMode = "set_scale_srv_val";
    myScaleCmd.cmdData = dataStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getDetailList() {
    myScaleCmd.cmdMode = "get_detail_list";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getDetailListSrv1() {
    myScaleCmd.cmdMode = "get_detail_list";
    myScaleCmd.cmdData = "";
    String infoStr = jsonEncode(myScaleCmd);
    myScaleCmd.cmdMode = "send_to_srv1";
    myScaleCmd.cmdData = infoStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

//获取最新的一条信息，不要全部列表
  static void getNewDetailFormSrv1() {
    myScaleCmd.cmdMode = "get_new_detail";
    myScaleCmd.cmdData = "";
    String infoStr = jsonEncode(myScaleCmd);
    myScaleCmd.cmdMode = "send_to_srv1";
    myScaleCmd.cmdData = infoStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getProductList() {
    myScaleCmd.cmdMode = "get_product_list";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getPluByPage(String jsonStr) {
    myScaleCmd.cmdMode = "get_plu_by_page";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void clearAllProduct() {
    myScaleCmd.cmdMode = "clear_product";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void checkPluExist(int id, String plu) {
    myScaleCmd.cmdMode = "check_plu_exist";
    myScaleCmd.cmdData = "$id,$plu";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void exportProduct(String jsonStr) {
    myScaleCmd.cmdMode = "export_product";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

//下发所有商品
  static void downAllPlu(String filePath) {
    myScaleCmd.cmdMode = "down_all_plu";
    myScaleCmd.cmdData = filePath;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getLastProductRec() {
    myScaleCmd.cmdMode = "get_last_product_rec";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void addProduct(String str) {
    myScaleCmd.cmdMode = "add_product";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void addOneProduct(String str) {
    myScaleCmd.cmdMode = "add_one_product";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getPluSetting() {
    myScaleCmd.cmdMode = "get_plu_setting";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void modifyProduct(String str) {
    myScaleCmd.cmdMode = "modify_product";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void setPluFields(String str) {
    myScaleCmd.cmdMode = "set_plu_fields";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void enablePlu(String str) {
    myScaleCmd.cmdMode = "update_enabled_plu";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getPortList() {
    myScaleCmd.cmdMode = "get_port_list";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getBtList() {
    myScaleCmd.cmdMode = "get_bt_list";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void delProduct(String str) {
    myScaleCmd.cmdMode = "del_product";
    myScaleCmd.cmdData = str;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void delAllProduct() {
    myScaleCmd.cmdMode = "del_all_product";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void sendModifyInfo(String modifyString) {
    myScaleCmd.cmdMode = "modify_scale";
    myScaleCmd.cmdData = modifyString;
    sendMsgChan0(jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void sendAddScale(String addString) {
    myScaleCmd.cmdMode = "add_scale";
    myScaleCmd.cmdData = addString;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void sendModifyScaleName(String scaleName) {
    myScaleCmd.cmdMode = "modify_scale_name";
    myScaleCmd.cmdData = scaleName;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void sendServiceAction(String actionStr) {
    myScaleCmd.cmdMode = "do_service_action";
    myScaleCmd.cmdData = actionStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void sendDelScale(String delString) {
    myScaleCmd.cmdMode = "del_scale";
    myScaleCmd.cmdData = delString;
    sendMsgChan0(jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void getUserList() {
    myScaleCmd.cmdMode = "get_user_list";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getWifiPwdList() {
    myScaleCmd.cmdMode = "get_wifi_pwd_list";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void addWifiPwd(String wifiStr) {
    myScaleCmd.cmdMode = "add_wifi_pwd";
    myScaleCmd.cmdData = wifiStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void updateLicense(String license) {
    myScaleCmd.cmdMode = "update_license";
    myScaleCmd.cmdData = license;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void checkLicenseKey(String license) {
    myScaleCmd.cmdMode = "check_license_key";
    myScaleCmd.cmdData = license;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getLicense() {
    myScaleCmd.cmdMode = "get_license";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //增加配方类型

  static void addFormulaType(String formulaType) {
    myScaleCmd.cmdMode = "add_formula_type";
    TypeName myTypeName = TypeName(formulaType);
    String jsonstr = jsonEncode(myTypeName);
    myScaleCmd.cmdData = jsonstr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //增加原料类型

  static void addRawType(String formulaType) {
    myScaleCmd.cmdMode = "add_raw_type";
    TypeName myTypeName = TypeName(formulaType);
    String jsonstr = jsonEncode(myTypeName);
    myScaleCmd.cmdData = jsonstr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //删除原料类型
  static void deleteRawType(String name) {
    myScaleCmd.cmdMode = "del_raw_type";
    TypeName myTypeName = TypeName(name);
    String jsonstr = jsonEncode(myTypeName);
    myScaleCmd.cmdData = jsonstr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

//编辑原料类型
  static void editRawType(String newName, int rawId) {
    myScaleCmd.cmdMode = "edit_raw_type";
    TypeIdAndName myTypeName = TypeIdAndName(newName, rawId);
    String jsonstr = jsonEncode(myTypeName);
    myScaleCmd.cmdData = jsonstr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //删除配方类型
  static void deleteFmaType(String name) {
    myScaleCmd.cmdMode = "del_formula_type";
    TypeName myTypeName = TypeName(name);
    String jsonstr = jsonEncode(myTypeName);
    myScaleCmd.cmdData = jsonstr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //根据条码获取配方
  static void getFmaByBarcode(String barcode) {
    myScaleCmd.cmdMode = "get_formula_by_barcode";
    GetFmaDataByBarcode myGetFmaDataByBarcode = GetFmaDataByBarcode(barcode);
    myScaleCmd.cmdData = jsonEncode(myGetFmaDataByBarcode);
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

//编辑配方类型
  static void editFmaType(String newName, int rawId) {
    myScaleCmd.cmdMode = "edit_formula_type";
    TypeIdAndName myTypeName = TypeIdAndName(newName, rawId);
    String jsonstr = jsonEncode(myTypeName);
    myScaleCmd.cmdData = jsonstr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //获取按键设置
  static void getScaleInputSetting() {
    myScaleCmd.cmdMode = "get_input_port";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //获取自动下一步
  static void getAutoNext() {
    myScaleCmd.cmdMode = "get_auto_next";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //更新自动下一步

  static void updateAutoNext(String reqStr) {
    myScaleCmd.cmdMode = "update_auto_next";
    myScaleCmd.cmdData = reqStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //获取原料类型

  static void getRawTypeList() {
    myScaleCmd.cmdMode = "get_raw_type_list";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getFormulaTypeList() {
    myScaleCmd.cmdMode = "get_formula_type_list";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

//删除未使用的配方类型
  static void delUnusedFmaType() async {
    myScaleCmd.cmdMode = "del_unused_fma_type";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //删除未使用的原料类型
  static void delUnusedRawType() async {
    myScaleCmd.cmdMode = "del_unused_raw_type";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getRawData(int id) {
    myScaleCmd.cmdMode = "get_raw_data";
    myScaleCmd.cmdData = id.toString();
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getFmaData(int id) {
    myScaleCmd.cmdMode = "get_fma_data";
    myScaleCmd.cmdData = id.toString();
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //获取打印设置

  static void getPrintSetting() {
    myScaleCmd.cmdMode = "get_report_print_setting";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //编辑打印设置

  static void updateReportPrintSetting(String jsonStr) {
    myScaleCmd.cmdMode = "update_report_print_setting";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getRawList() {
    myScaleCmd.cmdMode = "get_raw_data_list";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void importRawList(String jsonStr) {
    myScaleCmd.cmdMode = "import_raw_list";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void importFmaList(String jsonStr) {
    myScaleCmd.cmdMode = "import_fma_list";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void addRawData(AddRawData data) {
    myScaleCmd.cmdMode = "add_raw_data";
    String jsonStr = addRawDataToJson(data);
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void editRawData(EditRawData data) {
    myScaleCmd.cmdMode = "edit_raw_data";
    String jsonStr = editRawDataToJson(data);
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void deleteRawData(int id) {
    myScaleCmd.cmdMode = "delete_raw_data";
    DeleteRawDataId data = DeleteRawDataId(recId: id);
    myScaleCmd.cmdData = jsonEncode(data);
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

//删除所有原料 或者多选删除
  static void deleteAllRawData(List<int> id) {
    myScaleCmd.cmdMode = "del_many_raw";
    DeleteAllRawDataId data = DeleteAllRawDataId(recId: id);
    myScaleCmd.cmdData = jsonEncode(data);
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //删除配方

  static void deleteFormulaData(int id) {
    myScaleCmd.cmdMode = "delete_formula_data";
    DeleteRawDataId data = DeleteRawDataId(recId: id);
    myScaleCmd.cmdData = jsonEncode(data);
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void deleteAllFormulaData(List<int> id) {
    myScaleCmd.cmdMode = "del_many_fma";
    DeleteAllFormulaDataId data = DeleteAllFormulaDataId(recId: id);
    myScaleCmd.cmdData = jsonEncode(data);
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //检查ID和条码是否重复
  static void checkFmaIdAndBarcode(String jsonStr) {
    myScaleCmd.cmdMode = "check_fma_id_and_barcode";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //增加配方
  static void addFormulaData(String jsonStr) {
    myScaleCmd.cmdMode = "add_formula_data";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //修改配方

  static void editFormulaData(String jsonStr) {
    myScaleCmd.cmdMode = "edit_formula_data";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getFormulaList() {
    myScaleCmd.cmdMode = "get_formula_list";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //获取配方服务器配置
  static void getUploadServerConfig() {
    myScaleCmd.cmdMode = "upload_server_get";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //编辑称重服务器配置
  static void editUploadServerConfig(String jsonStr) {
    myScaleCmd.cmdMode = "upload_server_edit";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //增加称重记录

  static void addFormulaRec(String jsonStr) {
    myScaleCmd.cmdMode = "add_formula_rec";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //获取称重记录

  static void getFormulaRecList() {
    myScaleCmd.cmdMode = "get_formula_rec_list";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //根据配方ID获取配方称重记录
  static void getOneFmaRecsById(String fmaId) {
    myScaleCmd.cmdMode = "get_fma_rec_by_id";
    myScaleCmd.cmdData = fmaId;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  // 增加流速数据
  static void addFlowRateData(String reqFlowRate) {
    myScaleCmd.cmdMode = "add_flow_rate";
    myScaleCmd.cmdData = reqFlowRate;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  // 获取流速数据
  static void getFlowRateData() {
    myScaleCmd.cmdMode = "get_flow_rate_list";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //增加汇总称重记录
  static void addSummaryData(String jsonStr) {
    myScaleCmd.cmdMode = "add_wgt_rec";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void exportAllRecords(
      int mode, String path, List<String> fieldName, Map<String, String> map) {
    ReqExportAllWgtRecs req = ReqExportAllWgtRecs(
        mode: mode, path: path, fieldName: fieldName, translation: map);
    String reqStr = reqExportAllWgtRecsToJson(req);
    myScaleCmd.cmdMode = "export_all_recs";
    myScaleCmd.cmdData = reqStr; //根据scale model scale sn  scale name(别名)
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //获取称重记录
  static void newGetRecords(int mode, int page, int pageSize,
      String sortColumnName, String direction) {
    ReqGetAllWgtRecs reqGetAllWgtRecs = ReqGetAllWgtRecs(
      mode: mode,
      page: page,
      pageSize: pageSize,
      columnName: sortColumnName,
      direction: direction,
    );

    myScaleCmd.cmdMode = "get_all_wgt_rec_list";
    myScaleCmd.cmdData = reqGetAllWgtRecsToJson(reqGetAllWgtRecs);
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //通过配方单号获取称重记录
  static void getFmaByOrderId(String orderId) {
    myScaleCmd.cmdMode = "get_fma_rec_by_order";
    myScaleCmd.cmdData = orderId;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //获取暂存的称重记录
  static void getDraftRecords() {
    myScaleCmd.cmdMode = "get_draft_fma_wgt_rec_list";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //创建暂存的称重记录
  static void createDraftRecord(String jsonStr) {
    myScaleCmd.cmdMode = "create_draft_fma_wgt_rec";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //更新暂存的称重记录
  static void updateDraftRecord(String jsonStr) {
    myScaleCmd.cmdMode = "update_draft_fma_wgt_rec";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //删除暂存的称重记录
  static void deleteDraftRecord(String recId) {
    myScaleCmd.cmdMode = "delete_draft_fma_wgt_rec";
    DeleteDraftFmaId myScaleCmdData = DeleteDraftFmaId(orderId: recId);
    myScaleCmd.cmdData = jsonEncode(myScaleCmdData);
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //删除暂存的称重记录
  static void deleteAllDraftRecord(List<String> recId) {
    myScaleCmd.cmdMode = "del_many_draft_fma";
    DeleteAllDraftFmaId myScaleCmdData = DeleteAllDraftFmaId(orderId: recId);
    myScaleCmd.cmdData = jsonEncode(myScaleCmdData);
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getUIConfNormal(String mode) {
    myScaleCmd.cmdMode = "get_ui_conf";
    myScaleCmd.cmdData = mode;
    // sendMsg(scaleId, jsonEncode(myScaleCmd));
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

//获取不稳定扣重开关
  static void getScaleUnstableZeroTare() {
    myScaleCmd.cmdMode = "get_unstable_zero_tare";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //更新不稳定扣重开关
  static void updateUnstableZeroTare(bool isEnable) {
    myScaleCmd.cmdMode = "update_unstable_zero_tare";
    UnstableZeroTare unstableZeroTareData = UnstableZeroTare(enable: isEnable);
    myScaleCmd.cmdData = unstableZeroTareToJson(unstableZeroTareData);
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void newDeleteAllRecords(int mode) {
    myScaleCmd.cmdMode = "del_wgt_rec";
    ReqDelAllWgtRecs reqData = ReqDelAllWgtRecs(mode: mode);
    String jsonStr = reqDelAllWgtRecsToJson(reqData);
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //关闭boot commander

  static void killBootCommander() {
    myScaleCmd.cmdMode = "kill_boot_commander";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //验证登录
  static void userLogin(String userName, String password, bool autoLogin) {
    SysUserReq sysUserReq = SysUserReq(userName, password, autoLogin);
    String jsonStr = jsonEncode(sysUserReq);
    myScaleCmd.cmdMode = "login";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //登出
  static void logout() {
    myScaleCmd.cmdMode = "logout";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //获取用户信息
  static void getUserInfo(String userName) {
    SysUserNameReq sysUserNameReq = SysUserNameReq(userName);
    String jsonStr = jsonEncode(sysUserNameReq);
    myScaleCmd.cmdMode = "get_user_detail";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //获取所有用户
  static void getAllSysUsers() {
    myScaleCmd.cmdMode = "get_all_users";
    myScaleCmd.cmdData = '';
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //新增用户信息
  static void addSysUser(String jsonData) {
    myScaleCmd.cmdMode = "add_sys_user";
    myScaleCmd.cmdData = jsonData;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //修改密码
  static void modifyPwd(String jsonData) {
    myScaleCmd.cmdMode = "change_password";
    myScaleCmd.cmdData = jsonData;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //删除用户
  static void deleteSysUser(String jsonData) {
    myScaleCmd.cmdMode = "delete_sys_user";
    myScaleCmd.cmdData = jsonData;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

// 禁用用户

  static void enableSysUser(String jsonData) {
    myScaleCmd.cmdMode = "disable_sys_user";
    myScaleCmd.cmdData = jsonData;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //修改用户
  static void updateSysUser(String jsonData) {
    myScaleCmd.cmdMode = "update_sys_user";
    myScaleCmd.cmdData = jsonData;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void getSealLog(String jsonStr) {
    myScaleCmd.cmdMode = "get_all_seal_log";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void unsealByMasterKey(String masterKey) {
    myScaleCmd.cmdMode = "unseal_by_master_key";
    myScaleCmd.cmdData = masterKey;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //更新输入端口状态
  static void updateInputPortStatus(String jsonStr) {
    myScaleCmd.cmdMode = "update_input_port";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //获取输入端口状态
  static void getInputPortStatus() {
    myScaleCmd.cmdMode = "get_input_port";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //获取输出端口状态
  static void getOutputPortStatus() {
    myScaleCmd.cmdMode = "get_output_port";
    myScaleCmd.cmdData = "";
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //根据配方ID获取原料输出端口
  static void getRawOutputByFmaId(String jsonStr) {
    myScaleCmd.cmdMode = "get_raw_output_by_fma_id";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //更新输出端口状态
  static void updateOutputPortStatus(String jsonStr) {
    myScaleCmd.cmdMode = "update_output_port";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //读modbus线圈
  static void readModbusCoils(String jsonStr) {
    myScaleCmd.cmdMode = "read_output_port";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  //写modbus线圈
  static void writeModbusCoils(String jsonStr) {
    myScaleCmd.cmdMode = "open_output_port";
    myScaleCmd.cmdData = jsonStr;
    sendMsgChan0(jsonEncode(myScaleCmd));
  }

  static void deleteAllRecords(int scaleId) {
    String modelName = myDefScaleInfo.defScaleModel == null
        ? ''
        : myDefScaleInfo.defScaleModel!;
    String scaleSn =
        myDefScaleInfo.defScaleSn == null ? '' : myDefScaleInfo.defScaleSn!;

    myScaleCmd.cmdMode = "del_rec";
    myScaleCmd.cmdData = '999999999,0,$modelName,$scaleSn';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void closeSerialPort(int scaleId) {
    myScaleCmd.cmdMode = "close_serial_port";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void openSerialPort(int scaleId) {
    myScaleCmd.cmdMode = "open_serial_port";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void sendFormatToScale(String firmwarePathStr, int scaleId) {
    myScaleCmd.cmdMode = "update_firmware";
    myScaleCmd.cmdData = firmwarePathStr;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void updateFirmWareOnline(String str, int scaleId) {
    myScaleCmd.cmdMode = "update_firmware_wifi";
    myScaleCmd.cmdData = str;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getIpInfo(int scaleId) {
    myScaleCmd.cmdMode = 'get_ip_info';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getApInfo(int scaleId) {
    myScaleCmd.cmdMode = 'get_wifi_info';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getScaleTime(int scaleId) {
    myScaleCmd.cmdMode = 'get_scale_time';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setScaleTime(String time, int scaleId) {
    myScaleCmd.cmdMode = 'set_scale_time';
    myScaleCmd.cmdData = time;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void changeWifiMode(int scaleId) {
    myScaleCmd.cmdMode = 'change_wifi_mode';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void reScanApList(int scaleId) {
    myScaleCmd.cmdMode = 'rescan_ap_list';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getIpMode(int scaleId) {
    myScaleCmd.cmdMode = "get_ip_mode";
    myScaleCmd.cmdData = "";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getWifiList(int scaleId) {
    myScaleCmd.cmdMode = 'get_ap_list';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getWeight(int scaleId) {
    myScaleCmd.cmdMode = "reg_weight_data";
    myScaleCmd.cmdData = "";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void stopWeight(int scaleId) {
    myScaleCmd.cmdMode = "unreg_weight_data";
    myScaleCmd.cmdData = "";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static performZeroWithScaleId(int scaleId) {
    myScaleCmd.cmdMode = "zero";
    myScaleCmd.cmdData = "";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static performTareWithScaleId(int scaleId) {
    myScaleCmd.cmdMode = "tare";
    myScaleCmd.cmdData = "";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static performZeroWithScaleIdUnstable(int scaleId) {
    myScaleCmd.cmdMode = "zero_unstable";
    myScaleCmd.cmdData = "";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static performTareWithScaleIdUnstable(int scaleId) {
    myScaleCmd.cmdMode = "tare_unstable";
    myScaleCmd.cmdData = "";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void openBillSend(int scaleId) {
    //开启结账发送
    myScaleCmd.cmdMode = 'open_bill_send';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  // static void getRecords(int scaleId, String mode) {
  //   myScaleCmd.cmdMode = "get_recs";
  //   myScaleCmd.cmdData =
  //       '$mode,${myDefScaleInfo.defScaleModel},${myDefScaleInfo.defScaleSn},${myDefScaleInfo.defScaleModel}'; //根据scale model scale sn  scale name(别名)
  //   sendMsg(scaleId, jsonEncode(myScaleCmd));
  // }

  static void exportRecords(int scaleId, String mode, String path) {
    myScaleCmd.cmdMode = "export_recs";
    myScaleCmd.cmdData =
        '$mode,${myDefScaleInfo.defScaleModel},${myDefScaleInfo.defScaleSn},${myDefScaleInfo.defScaleModel},$path'; //根据scale model scale sn  scale name(别名)
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getRecords(int scaleId, String mode, int page, int pageSize,
      String sortColumnName, String direction) {
    if (myAllScalesList.isEmpty) {
      return;
    }
    Scale tempScaleInfo = myAllScalesList[0];
    for (var scale in myAllScalesList) {
      if (scale.scaleId == scaleId) {
        tempScaleInfo = scale;
        break;
      }
    }

    myScaleCmd.cmdMode = "get_recs";
    myScaleCmd.cmdData =
        '$mode,${tempScaleInfo.scaleModel},${tempScaleInfo.scaleSn},${tempScaleInfo.scaleModel},$page,$pageSize,$sortColumnName,$direction'; //根据scale model scale sn  scale name(别名)
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void modifyBtPowerStrong(int scaleId) {
    myScaleCmd.cmdMode = "send_data_to_bt";
    // myScaleCmd.cmdData = "TTM:TPL-(+10)";
    myScaleCmd.cmdData = "AT+RFPOWER=78,14,14,14";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void modifyBtPowerNormal(int scaleId) {
    myScaleCmd.cmdMode = "send_data_to_bt";
    // myScaleCmd.cmdData = "TTM:TPL-(+6)";
    myScaleCmd.cmdData = "AT+RFPOWER=78,11,11,11";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void modifyBtPowerWeak(int scaleId) {
    myScaleCmd.cmdMode = "send_data_to_bt";
    // myScaleCmd.cmdData = "TTM:TPL-(0)";
    myScaleCmd.cmdData = "AT+RFPOWER=78,5,5,5";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void getBtName(int scaleId) {
    myScaleCmd.cmdMode = "send_data_to_bt";
    // myScaleCmd.cmdData = "TTM:NAM-?";
    myScaleCmd.cmdData = "AT+BLENAME?";
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void modifyBtName(String btName, int scaleId) {
    myScaleCmd.cmdMode = "modify_bt_name";
    myScaleCmd.cmdData = btName;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void setLowHighLimit(String data, int scaleId) {
    myScaleCmd.cmdMode = "set_limit_to_scale";
    myScaleCmd.cmdData = data;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getOneEepromInfo(String func, int scaleId) {
    myScaleCmd.cmdMode = "get_one_eeprom_info";
    myScaleCmd.cmdData = func;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getAllEepromInfo(int scaleId) {
    myScaleCmd.cmdMode = "get_all_eeprom_info";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void modifyEepromInfo(String dataStr, int scaleId) {
    myScaleCmd.cmdMode = "modify_eeprom_info";
    myScaleCmd.cmdData = dataStr;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setWifiDynamicMode(int scaleId) {
    myScaleCmd.cmdMode = 'set_wifi_dynamic_ip';
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void sendOutputFmtToScale(List<String> list, int scaleId) async {
    myDownLoadSetOutputFmt.filePath = list;
    String json = jsonEncode(myDownLoadSetOutputFmt);
    myScaleCmd.cmdMode = "set_output_format";
    myScaleCmd.cmdData = json;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }

  static void sendServerIpToScale(String str, int scaleId) async {
    myScaleCmd.cmdMode = "set_server_ip";
    myScaleCmd.cmdData = str;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
    // print(jsonEncode(myScaleCmd));
  }

  static void checkSerialPort(int scaleId) {
    myScaleCmd.cmdMode = "check_serial_port";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void sendScaleAlive(int scaleId) {
    myScaleCmd.cmdMode = "send_scale_alive";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getBuildInfo(int scaleId) {
    myScaleCmd.cmdMode = "get_build_info";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getWeightErr(int scaleId) {
    myScaleCmd.cmdMode = "get_weight_err";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getBasicData(int scaleId) {
    myScaleCmd.cmdMode = "get_basic_data";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getSealStatus(int scaleId) {
    myScaleCmd.cmdMode = "get_seal_status";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void softSeal(int scaleId, String sealKey) {
    myScaleCmd.cmdMode = "soft_seal";
    myScaleCmd.cmdData = sealKey;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void removeSoftSeal(int scaleId, String sealKey) {
    myScaleCmd.cmdMode = "remove_soft_seal";
    myScaleCmd.cmdData = sealKey;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void removeSoftSealOnce(int scaleId) {
    myScaleCmd.cmdMode = "remove_soft_seal_once";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  //有线网络设置

  static void getWiredIp(int scaleId) {
    myScaleCmd.cmdMode = "get_wired_ip";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setWiredIp(int scaleId, String ipInfo) {
    myScaleCmd.cmdMode = "set_wired_ip";
    myScaleCmd.cmdData = ipInfo;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setWiredDhcp(int scaleId, String dhcpInfo) {
    myScaleCmd.cmdMode = "set_wired_dhcp";
    myScaleCmd.cmdData = dhcpInfo;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getWiredDhcp(int scaleId) {
    myScaleCmd.cmdMode = "get_wired_dhcp";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void openScalePassth(int scaleId) {
    myScaleCmd.cmdMode = "open_scale_passthrough";
    myScaleCmd.cmdData = 'string';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void changeScalePassth(bool isHex, int scaleId) {
    myScaleCmd.cmdMode = "change_scale_passth_mode";
    if (isHex) {
      myScaleCmd.cmdData = 'hex';
    } else {
      myScaleCmd.cmdData = 'string';
    }

    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void closeScalePassth(int scaleId) {
    myScaleCmd.cmdMode = "close_scale_passthrough";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void closewifiPassth(int scaleId) {
    if (scaleId == 1) {
      myScaleCmd.cmdMode = "dis_passth_mode";
      myScaleCmd.cmdData = '';
      sendMsg(scaleId, jsonEncode(myScaleCmd));
    }
  }

  static void getFactoryInfo(int scaleId) {
    myScaleCmd.cmdMode = "get_factory_info";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void deleteAllRecordsById(int scaleId) {
    DefScaleInfo tempScaleInfo = DefScaleInfo.getScaleInfoById(scaleId);

    myScaleCmd.cmdMode = "del_rec";
    myScaleCmd.cmdData =
        '999999999,0,${tempScaleInfo.defScaleModel},${tempScaleInfo.defScaleSn}';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void deleteAllRecordsCheck(int scaleId) {
    String modelName = myDefScaleInfo.defScaleModel == null
        ? ''
        : myDefScaleInfo.defScaleModel!;
    String scaleSn =
        myDefScaleInfo.defScaleSn == null ? '' : myDefScaleInfo.defScaleSn!;
    myScaleCmd.cmdMode = "del_rec";
    myScaleCmd.cmdData = '999999999,1,$modelName,$scaleSn';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void deleteAllRecordsTakeIn(int scaleId) {
    String modelName = myDefScaleInfo.defScaleModel == null
        ? ''
        : myDefScaleInfo.defScaleModel!;
    String scaleSn =
        myDefScaleInfo.defScaleSn == null ? '' : myDefScaleInfo.defScaleSn!;
    myScaleCmd.cmdMode = "del_rec";
    myScaleCmd.cmdData = '999999999,2,$modelName,$scaleSn';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void deleteAllRecordsTakeOut(int scaleId) {
    String modelName = myDefScaleInfo.defScaleModel == null
        ? ''
        : myDefScaleInfo.defScaleModel!;
    String scaleSn =
        myDefScaleInfo.defScaleSn == null ? '' : myDefScaleInfo.defScaleSn!;
    myScaleCmd.cmdMode = "del_rec";
    myScaleCmd.cmdData = '999999999,3,$modelName,$scaleSn';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getScaleModel(int scaleId) {
    myScaleCmd.cmdMode = "get_model";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  // 关闭发送内码
  static void disContCode(int scaleId) {
    myScaleCmd.cmdMode = "dis_code";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

// 关闭发送内码
  static void enContCode(int scaleId) {
    myScaleCmd.cmdMode = "en_code";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void calibrationWeight(int scaleId, String value) {
    myScaleCmd.cmdMode = "cal_weight";
    myScaleCmd.cmdData = value;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setMaxRange1(int scaleId, String value) {
    myScaleCmd.cmdMode = "set_max_range1";
    myScaleCmd.cmdData = value;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setMaxRange2(int scaleId, String value) {
    myScaleCmd.cmdMode = "set_max_range2";
    myScaleCmd.cmdData = value;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getMaxRange2(int scaleId) {
    myScaleCmd.cmdMode = "get_max_range2";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getMaxRange1(int scaleId) {
    myScaleCmd.cmdMode = "get_max_range1";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void sendCalHeartBeat(int scaleId) {
    myScaleCmd.cmdMode = "send_cal_heart_beat";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setDecimalValue(int scaleId, String value) {
    myScaleCmd.cmdMode = "set_decimal_value";
    myScaleCmd.cmdData = value;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getDecimalValue(int scaleId) {
    myScaleCmd.cmdMode = "get_decimal_value";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getGaduation1Value(int scaleId) {
    myScaleCmd.cmdMode = "get_gaduation1_value";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setGaduation2Value(int scaleId, String value) {
    myScaleCmd.cmdMode = "set_gaduation2_value";
    myScaleCmd.cmdData = value;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getGaduation2Value(int scaleId) {
    myScaleCmd.cmdMode = "get_gaduation2_value";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setGaduation1Value(int scaleId, String value) {
    myScaleCmd.cmdMode = "set_gaduation1_value";
    myScaleCmd.cmdData = value;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setWeightUnit(int scaleId, String value) {
    myScaleCmd.cmdMode = "set_weight_unit";
    myScaleCmd.cmdData = value;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getWeightUnit(int scaleId) {
    myScaleCmd.cmdMode = "get_weight_unit";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setInitialZero(int scaleId, String value) {
    myScaleCmd.cmdMode = "set_initial_zero";
    myScaleCmd.cmdData = value;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getInitialZero(int scaleId) {
    myScaleCmd.cmdMode = "get_initial_zero";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setManualZero(int scaleId, String value) {
    myScaleCmd.cmdMode = "set_manual_zero";
    myScaleCmd.cmdData = value;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getManualZero(int scaleId) {
    myScaleCmd.cmdMode = "get_manual_zero";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setZeroTracking(int scaleId, String value) {
    myScaleCmd.cmdMode = "set_zero_tracking";
    myScaleCmd.cmdData = value;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getZeroTracking(int scaleId) {
    myScaleCmd.cmdMode = "get_zero_tracking";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setGravityAcceleration(int scaleId, String value) {
    myScaleCmd.cmdMode = "set_grav_acc";
    myScaleCmd.cmdData = value;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getGravityAcceleration(int scaleId) {
    myScaleCmd.cmdMode = "get_grav_acc";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void forceUntare(int scaleId) {
    myScaleCmd.cmdMode = "force_untare";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void setSerialPort(int scaleId, String value) {
    myScaleCmd.cmdMode = "set_serial_port";
    myScaleCmd.cmdData = value;
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }

  static void getSerialPort(int scaleId) {
    myScaleCmd.cmdMode = "get_serial_port";
    myScaleCmd.cmdData = '';
    sendMsg(scaleId, jsonEncode(myScaleCmd));
  }
}
