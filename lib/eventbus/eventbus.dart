import 'package:event_bus/event_bus.dart';

/// 全局唯一的 [EventBus] 消息总线单例。
/// 用于跨 Widget 和跨业务层之间的无状态异步消息传递。
EventBus eventBus = EventBus();

class EventSignal {
  dynamic obj;
  EventSignal(this.obj);
}

class EventDeviceName {
  dynamic obj;
  EventDeviceName(this.obj);
}

class EventTime {
  dynamic obj;
  EventTime(this.obj);
}

class EventDate {
  dynamic obj;
  EventDate(this.obj);
}

class EventUiCmd {
  dynamic obj;
  EventUiCmd(this.obj);
}

class EventWtData {
  dynamic obj;
  EventWtData(this.obj);
}

class EventWeightData {
  dynamic obj;
  EventWeightData(this.obj);
}

class EventReqWeightCountine {
  dynamic obj;
  EventReqWeightCountine(this.obj);
}

class EventDialogData {
  dynamic obj;
  EventDialogData(this.obj);
}

class EventMySysUser {
  dynamic obj;
  EventMySysUser(this.obj);
}

class EventPLuDataSavedOK {
  dynamic obj;
  EventPLuDataSavedOK(this.obj);
}

class EventReportData {
  dynamic obj;
  EventReportData(this.obj);
}

class EventUserData {
  dynamic obj;
  EventUserData(this.obj);
}

class EventWeightParamData {
  dynamic obj;
  EventWeightParamData(this.obj);
}

class EventComportdata {
  dynamic obj;
  EventComportdata(this.obj);
}

class EventSerialinfoData {
  dynamic obj;
  EventSerialinfoData(this.obj);
}

class EventConnInfoList {
  dynamic obj;
  EventConnInfoList(this.obj);
}

class EventNotifyData {
  dynamic obj;
  EventNotifyData(this.obj);
}

class EventRespData {
  dynamic obj;
  EventRespData(this.obj);
}

class EventRespUpdateLic {
  dynamic obj;
  EventRespUpdateLic(this.obj);
}

class EventRespDelScale {
  dynamic obj;
  EventRespDelScale(this.obj);
}

class EventRespAddScale {
  dynamic obj;
  EventRespAddScale(this.obj);
}

class EventRespDetailInfo {
  dynamic obj;
  EventRespDetailInfo(this.obj);
}

class EventShowSealOnce {
  dynamic obj;
  EventShowSealOnce(this.obj);
}

class EventRespNewDetailInfo {
  dynamic obj;
  EventRespNewDetailInfo(this.obj);
}

class EventRespScaleOnline {
  dynamic obj;
  EventRespScaleOnline(this.obj);
}

class EventRespScaleSrvList {
  dynamic obj;
  EventRespScaleSrvList(this.obj);
}

class EventRespDoSrvAction {
  dynamic obj;
  EventRespDoSrvAction(this.obj);
}

class EventRespDetailAdd {
  dynamic obj;
  EventRespDetailAdd(this.obj);
}

class EventRespWifiPwdInfo {
  dynamic obj;
  EventRespWifiPwdInfo(this.obj);
}

class EventRecData {
  dynamic obj;
  EventRecData(this.obj);
}

class EventConnInfo {
  dynamic obj;
  EventConnInfo(this.obj);
}

class EventComInfoList {
  dynamic obj;
  EventComInfoList(this.obj);
}

class EventBtInfoList {
  dynamic obj;
  EventBtInfoList(this.obj);
}

class EventScaleList {
  dynamic obj;
  EventScaleList(this.obj);
}

class EventScaleTotalInfo {
  dynamic obj;
  EventScaleTotalInfo(this.obj);
}

class EventComScaleList {
  dynamic obj;
  EventComScaleList(this.obj);
}

class EventCurrentPort {
  dynamic obj;
  EventCurrentPort(this.obj);
}

class EventSelWeighingScaleId {
  dynamic obj;
  EventSelWeighingScaleId(this.obj);
}

class EventGetScaleRecords {
  dynamic obj;
  EventGetScaleRecords(this.obj);
}

class EventProductRecList {
  dynamic obj;
  EventProductRecList(this.obj);
}

class EventPLuList {
  dynamic obj;
  EventPLuList(this.obj);
}

class EventProductRecInfo {
  dynamic obj;
  EventProductRecInfo(this.obj);
}

class EventSettingParam {
  dynamic obj;
  EventSettingParam(this.obj);
}

class EventUpdateSettingParam {
  dynamic obj;
  EventUpdateSettingParam(this.obj);
}

class EventUserInfoList {
  dynamic obj;
  EventUserInfoList(this.obj);
}

class EventRespScaleModify {
  dynamic obj;
  EventRespScaleModify(this.obj);
}

class EventUserInfo {
  dynamic obj;
  EventUserInfo(this.obj);
}

class EventText {
  dynamic obj;
  EventText(this.obj);
}

class EventRcpText {
  dynamic obj;
  EventRcpText(this.obj);
}

class EventOffset {
  dynamic obj;
  EventOffset(this.obj);
}

class EventRcpOffset {
  dynamic obj;
  EventRcpOffset(this.obj);
}

class EventPageSize {
  dynamic obj;
  EventPageSize(this.obj);
}

class EventCurrentBarCodeRowDataList {
  dynamic obj;
  EventCurrentBarCodeRowDataList(this.obj);
}

class EventSavedBarcodeName {
  dynamic obj;
  EventSavedBarcodeName(this.obj);
}

class EventSavedQrcodeName {
  dynamic obj;
  EventSavedQrcodeName(this.obj);
}

class EventOffsetDataList {
  dynamic obj;
  EventOffsetDataList(this.obj);
}

class EventSelectIndex {
  dynamic obj;
  EventSelectIndex(this.obj);
}

class EventDownPrnFmtResp {
  dynamic obj;
  EventDownPrnFmtResp(this.obj);
}

class EventDownDefPrnFmtResp {
  dynamic obj;
  EventDownDefPrnFmtResp(this.obj);
}

class EventSerialOutputResp {
  dynamic obj;
  EventSerialOutputResp(this.obj);
}

class EventScalePassthData {
  dynamic obj;
  EventScalePassthData(this.obj);
}

class EventOpenScalePassthResp {
  dynamic obj;
  EventOpenScalePassthResp(this.obj);
}

class EventCloseScalePassthResp {
  dynamic obj;
  EventCloseScalePassthResp(this.obj);
}

class EventRegWeightResp {
  dynamic obj;
  EventRegWeightResp(this.obj);
}

class EventUnregWeightResp {
  dynamic obj;
  EventUnregWeightResp(this.obj);
}

class EventSerialPortResponse {
  dynamic obj;
  EventSerialPortResponse(this.obj);
}

class EventSerialPortStatus {
  dynamic obj;
  EventSerialPortStatus(this.obj);
}

class EventLicenseData {
  dynamic obj;
  EventLicenseData(this.obj);
}

class EventServiceOff {
  dynamic obj;
  EventServiceOff(this.obj);
}

class EventUnstableZeroTare {
  dynamic obj;
  EventUnstableZeroTare(this.obj);
}

class EventGetUnstableZeroTare {
  dynamic obj;
  EventGetUnstableZeroTare(this.obj);
}

class EventCheckLicenseKey {
  dynamic obj;
  EventCheckLicenseKey(this.obj);
}

class EventPrinter {
  dynamic obj;
  EventPrinter(this.obj);
}

class EventBarcodetypedata {
  dynamic obj;
  EventBarcodetypedata(this.obj);
}

class EventSelectedControl {
  dynamic obj;
  EventSelectedControl(this.obj);
}

class EventRcpSelectedControl {
  dynamic obj;
  EventRcpSelectedControl(this.obj);
}

class EventWiFiListInfo {
  dynamic obj;
  EventWiFiListInfo(this.obj);
}

class EventIpInfoData {
  dynamic obj;
  EventIpInfoData(this.obj);
}

class EventConnectDynamicIp {
  dynamic obj;
  EventConnectDynamicIp(this.obj);
}

class EventConnectAp {
  dynamic obj;
  EventConnectAp(this.obj);
}

class EventConnectStaticIp {
  dynamic obj;
  EventConnectStaticIp(this.obj);
}

class EventRespUpdateFirmware {
  dynamic obj;
  EventRespUpdateFirmware(this.obj);
}

class EventRespCheckNetScale {
  dynamic obj;
  EventRespCheckNetScale(this.obj);
}

class EventRespCheckComPort {
  dynamic obj;
  EventRespCheckComPort(this.obj);
}

class EventRespUpdateFirmwareProcess {
  dynamic obj;
  EventRespUpdateFirmwareProcess(this.obj);
}

class EventIpInfo {
  dynamic obj;
  EventIpInfo(this.obj);
}

class EventConnectBTResponse {
  dynamic obj;
  EventConnectBTResponse(this.obj);
}

class EventGetAllEepromDateResp {
  dynamic obj;
  EventGetAllEepromDateResp(this.obj);
}

class EventGetOneEepromDateResp {
  dynamic obj;
  EventGetOneEepromDateResp(this.obj);
}

class EventModifyEepromInfoResp {
  dynamic obj;
  EventModifyEepromInfoResp(this.obj);
}

class EventModifyVarValueResp {
  dynamic obj;
  EventModifyVarValueResp(this.obj);
}

class EventSetServerIPResp {
  dynamic obj;
  EventSetServerIPResp(this.obj);
}

class EventUpdateFirmWareNetResp {
  dynamic obj;
  EventUpdateFirmWareNetResp(this.obj);
}

class EventRevGetSealStatus {
  dynamic obj;
  EventRevGetSealStatus(this.obj);
}

class EventRevSoftSeal {
  dynamic obj;
  EventRevSoftSeal(this.obj);
}

class EventRevRemoveSoftSeal {
  dynamic obj;
  EventRevRemoveSoftSeal(this.obj);
}

class EventRevRemoveSoftSealOnce {
  dynamic obj;
  EventRevRemoveSoftSealOnce(this.obj);
}

class EventBTResponse {
  dynamic obj;
  EventBTResponse(this.obj);
}

class EventMessageError {
  dynamic obj;
  EventMessageError(this.obj);
}

class EventGetWifiListError {
  dynamic obj;
  EventGetWifiListError(this.obj);
}

class EventGetIpError {
  dynamic obj;
  EventGetIpError(this.obj);
}

class EventGetWifiApInfo {
  dynamic obj;
  EventGetWifiApInfo(this.obj);
}

class EventRespSetWifiStaticIp {
  dynamic obj;
  EventRespSetWifiStaticIp(this.obj);
}

class EventRespGetIpMode {
  dynamic obj;
  EventRespGetIpMode(this.obj);
}

class EventGetBuildInfo {
  dynamic obj;
  EventGetBuildInfo(this.obj);
}

class EventGetScaleTime {
  dynamic obj;
  EventGetScaleTime(this.obj);
}

class EventSetScaleTime {
  dynamic obj;
  EventSetScaleTime(this.obj);
}

class EventGetWeightErr {
  dynamic obj;
  EventGetWeightErr(this.obj);
}

class EventGetFactoryInfo {
  dynamic obj;
  EventGetFactoryInfo(this.obj);
}

class EventGetBasicData {
  dynamic obj;
  EventGetBasicData(this.obj);
}

class EventSetLimitToScale {
  dynamic obj;
  EventSetLimitToScale(this.obj);
}

class EventSwitchLimitFromScale {
  dynamic obj;
  EventSwitchLimitFromScale(this.obj);
}

class EventRevDetailTail {
  dynamic obj;
  EventRevDetailTail(this.obj);
}

class EventRevExportRecs {
  dynamic obj;
  EventRevExportRecs(this.obj);
}

class EventRevAddRec {
  dynamic obj;
  EventRevAddRec(this.obj);
}

class EventRevCalValue {
  dynamic obj;
  EventRevCalValue(this.obj);
}

class EventRevSetGaduationValue {
  dynamic obj;
  EventRevSetGaduationValue(this.obj);
}

class EventRevSetDecimalValue {
  dynamic obj;
  EventRevSetDecimalValue(this.obj);
}

class EventRevGetWiredIp {
  dynamic obj;
  EventRevGetWiredIp(this.obj);
}

class EventRevSetWiredIp {
  dynamic obj;
  EventRevSetWiredIp(this.obj);
}

class EventRevGetWiredDhcp {
  dynamic obj;
  EventRevGetWiredDhcp(this.obj);
}

class EventRevSetWiredDhcp {
  dynamic obj;
  EventRevSetWiredDhcp(this.obj);
}

class EventRevSetWeightUnit {
  dynamic obj;
  EventRevSetWeightUnit(this.obj);
}

class EventRevGetWeightUnit {
  dynamic obj;
  EventRevGetWeightUnit(this.obj);
}

class EventRevGetGaduation1Value {
  dynamic obj;
  EventRevGetGaduation1Value(this.obj);
}

class EventRevSetGaduation1Value {
  dynamic obj;
  EventRevSetGaduation1Value(this.obj);
}

class EventRevGetDecimalValue {
  dynamic obj;
  EventRevGetDecimalValue(this.obj);
}

class EventRevGetGravAcc {
  dynamic obj;
  EventRevGetGravAcc(this.obj);
}

class EventRevGetMaxRange1 {
  dynamic obj;
  EventRevGetMaxRange1(this.obj);
}

class EventRevGetManualZero {
  dynamic obj;
  EventRevGetManualZero(this.obj);
}

class EventRevGetZeroTracking {
  dynamic obj;
  EventRevGetZeroTracking(this.obj);
}

class EventRevGetInitialZero {
  dynamic obj;
  EventRevGetInitialZero(this.obj);
}

class EventRevWifiPwdAdd {
  dynamic obj;
  EventRevWifiPwdAdd(this.obj);
}

class EventRevCalWeight {
  dynamic obj;
  EventRevCalWeight(this.obj);
}

class EventDeleteRec {
  dynamic obj;
  EventDeleteRec(this.obj);
}

class EventRespDownPlu {
  dynamic obj;
  EventRespDownPlu(this.obj);
}

class EventRespInsertPlu {
  dynamic obj;
  EventRespInsertPlu(this.obj);
}

class EventRespDelPlu {
  dynamic obj;
  EventRespDelPlu(this.obj);
}

class EventRespChangeWiFiMode {
  dynamic obj;
  EventRespChangeWiFiMode(this.obj);
}

class EventRespGetRawTypeList {
  dynamic obj;
  EventRespGetRawTypeList(this.obj);
}

class EventRespGetFormulaTypeList {
  dynamic obj;
  EventRespGetFormulaTypeList(this.obj);
}

class EventRespGetRawDataList {
  dynamic obj;
  EventRespGetRawDataList(this.obj);
}

class EventRespGetRawData {
  dynamic obj;
  EventRespGetRawData(this.obj);
}

class EventRespGetFmaData {
  dynamic obj;
  EventRespGetFmaData(this.obj);
}

class EventRespAddRawData {
  dynamic obj;
  EventRespAddRawData(this.obj);
}

class EventRespDelRawData {
  dynamic obj;
  EventRespDelRawData(this.obj);
}

class EventRespEditRawData {
  dynamic obj;
  EventRespEditRawData(this.obj);
}

class EventRespAddFormulaType {
  dynamic obj;
  EventRespAddFormulaType(this.obj);
}

class EventRespFormulasListByBarcode {
  dynamic obj;
  EventRespFormulasListByBarcode(this.obj);
}

class EventRespCheckFmaIdAndBarcode {
  dynamic obj;
  EventRespCheckFmaIdAndBarcode(this.obj);
}

class EventRespFormulaRecByOrder {
  dynamic obj;
  EventRespFormulaRecByOrder(this.obj);
}

class EventRespUploadServerGet {
  dynamic obj;
  EventRespUploadServerGet(this.obj);
}

class EventRespUploadServerEdit {
  dynamic obj;
  EventRespUploadServerEdit(this.obj);
}

class EventRespFormulaList {
  dynamic obj;
  EventRespFormulaList(this.obj);
}

class EventRespAddFormula {
  dynamic obj;
  EventRespAddFormula(this.obj);
}

/// 修改配方参数指令触发完毕后的回调事件 (Edit Formula Response)。
class EventRespEditFormula {
  dynamic obj;
  EventRespEditFormula(this.obj);
}

class EventRespDelFormula {
  dynamic obj;
  EventRespDelFormula(this.obj);
}

class EventRespFormulaRecList {
  dynamic obj;
  EventRespFormulaRecList(this.obj);
}

class EventRespOneFmaRecList {
  dynamic obj;
  EventRespOneFmaRecList(this.obj);
}

/// 配方记录写入成功后触发的回调事件通知。
class EventRespFormulaRecAdd {
  dynamic obj;
  EventRespFormulaRecAdd(this.obj);
}

class EventRespRawTypeAdd {
  dynamic obj;
  EventRespRawTypeAdd(this.obj);
}

class EventRespFlowRateAdd {
  dynamic obj;
  EventRespFlowRateAdd(this.obj);
}

class EventRespFlowRateList {
  dynamic obj;
  EventRespFlowRateList(this.obj);
}

class EventRespGetAllWgtRecs {
  dynamic obj;
  EventRespGetAllWgtRecs(this.obj);
}

class EventDelAllWgtRecs {
  dynamic obj;
  EventDelAllWgtRecs(this.obj);
}

class EventAddWgtRec {
  dynamic obj;
  EventAddWgtRec(this.obj);
}

class EventExportAllRecs {
  dynamic obj;
  EventExportAllRecs(this.obj);
}

class EventSaveTakeInOutWgt {
  dynamic obj;
  EventSaveTakeInOutWgt(this.obj);
}

class EventRespGetAutoNext {
  dynamic obj;
  EventRespGetAutoNext(this.obj);
}

class EventRespGetReportPrint {
  dynamic obj;
  EventRespGetReportPrint(this.obj);
}

class EventRespGetAllSealLog {
  dynamic obj;
  EventRespGetAllSealLog(this.obj);
}

class EventRespUnsealByMasterKey {
  dynamic obj;
  EventRespUnsealByMasterKey(this.obj);
}

class EventRespGetInputPortStatus {
  dynamic obj;
  EventRespGetInputPortStatus(this.obj);
}

class EventRespUpdateInputPort {
  dynamic obj;
  EventRespUpdateInputPort(this.obj);
}

class EventRespScaleInput {
  dynamic obj;
  EventRespScaleInput(this.obj);
}

class EventRespGetOutputPortStatus {
  dynamic obj;
  EventRespGetOutputPortStatus(this.obj);
}

class EventRespUpdateOutputPort {
  dynamic obj;
  EventRespUpdateOutputPort(this.obj);
}

class EventRespRawOutputByFmaId {
  dynamic obj;
  EventRespRawOutputByFmaId(this.obj);
}

class EventRespOpenOutputPort {
  dynamic obj;
  EventRespOpenOutputPort(this.obj);
}

class EventRespGetDraftFmaWgtRecList {
  dynamic obj;
  EventRespGetDraftFmaWgtRecList(this.obj);
}

class EventRespCreateDraftFmaWgtRecList {
  dynamic obj;
  EventRespCreateDraftFmaWgtRecList(this.obj);
}

class EventRespUpdateDraftFmaWgtRecList {
  dynamic obj;
  EventRespUpdateDraftFmaWgtRecList(this.obj);
}

class EventRespDelDraftFmaWgtRecList {
  dynamic obj;
  EventRespDelDraftFmaWgtRecList(this.obj);
}

class EventRespAddSysUser {
  dynamic obj;
  EventRespAddSysUser(this.obj);
}

class EventRespDeleteSysUser {
  dynamic obj;
  EventRespDeleteSysUser(this.obj);
}

class EventRespUpdateSysUser {
  dynamic obj;
  EventRespUpdateSysUser(this.obj);
}

class EventRespDisableSysUser {
  dynamic obj;
  EventRespDisableSysUser(this.obj);
}

class EventRespChangePassword {
  dynamic obj;
  EventRespChangePassword(this.obj);
}

class EventRespLogin {
  dynamic obj;
  EventRespLogin(this.obj);
}

class EventRespGetAllUsers {
  dynamic obj;
  EventRespGetAllUsers(this.obj);
}

class EventRespGetUserDetail {
  dynamic obj;
  EventRespGetUserDetail(this.obj);
}

class EventRespPluAdd {
  dynamic obj;
  EventRespPluAdd(this.obj);
}

class EventRespProductAddOne {
  dynamic obj;
  EventRespProductAddOne(this.obj);
}

class EventRespGetLastProductRec {
  dynamic obj;
  EventRespGetLastProductRec(this.obj);
}

class EventRespImportRawList {
  dynamic obj;
  EventRespImportRawList(this.obj);
}

class EventRespDelManyRaw {
  dynamic obj;
  EventRespDelManyRaw(this.obj);
}

class EventRespDelManyFma {
  dynamic obj;
  EventRespDelManyFma(this.obj);
}

class EventRespDelManyDraft {
  dynamic obj;
  EventRespDelManyDraft(this.obj);
}

class EventImportRawOK {
  dynamic obj;
  EventImportRawOK(this.obj);
}

class EventImportFmaOK {
  dynamic obj;
  EventImportFmaOK(this.obj);
}

class EventRespGetSysLogList {
  dynamic obj;
  EventRespGetSysLogList(this.obj);
}

class EventRespGetCalLogList {
  dynamic obj;
  EventRespGetCalLogList(this.obj);
}

class EventRespGetWgtLogList {
  dynamic obj;
  EventRespGetWgtLogList(this.obj);
}

class EventRespDelSysLog {
  dynamic obj;
  EventRespDelSysLog(this.obj);
}

class EventRespDelCalLog {
  dynamic obj;
  EventRespDelCalLog(this.obj);
}

class EventRespDelAllCalLog {
  dynamic obj;
  EventRespDelAllCalLog(this.obj);
}

class EventRespDelWgtLog {
  dynamic obj;
  EventRespDelWgtLog(this.obj);
}

class EventRespDelAllScaleLog {
  dynamic obj;
  EventRespDelAllScaleLog(this.obj);
}

class EventRespExportSysLog {
  dynamic obj;
  EventRespExportSysLog(this.obj);
}

class EventRespExportWgtLog {
  dynamic obj;
  EventRespExportWgtLog(this.obj);
}

class EventRespExportCalLog {
  dynamic obj;
  EventRespExportCalLog(this.obj);
}

class EventRespProductDel {
  dynamic obj;
  EventRespProductDel(this.obj);
}

class EventRespExistPlu {
  dynamic obj;
  EventRespExistPlu(this.obj);
}

class EventRespExportPluList {
  dynamic obj;
  EventRespExportPluList(this.obj);
}

class EventRespPluSetting {
  dynamic obj;
  EventRespPluSetting(this.obj);
}

class EventRespDownAllPlu {
  dynamic obj;
  EventRespDownAllPlu(this.obj);
}
