// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `EngLish`
  String get gLanguage {
    return Intl.message(
      'EngLish',
      name: 'gLanguage',
      desc: 'This is a prompt for the current language.',
      args: [],
    );
  }

  /// `Connect`
  String get gBtnConnect {
    return Intl.message(
      'Connect',
      name: 'gBtnConnect',
      desc: 'This is a button for testing the connection with the device.',
      args: [],
    );
  }

  /// `Test Connect`
  String get gBtnTestConnect {
    return Intl.message(
      'Test Connect',
      name: 'gBtnTestConnect',
      desc: 'This is a button for testing the connection with the device.',
      args: [],
    );
  }

  /// `Tare`
  String get gBtnTare {
    return Intl.message(
      'Tare',
      name: 'gBtnTare',
      desc: 'This is a button for tare weight.',
      args: [],
    );
  }

  /// `Save`
  String get gBtnSave {
    return Intl.message(
      'Save',
      name: 'gBtnSave',
      desc: 'This is a button for saving.',
      args: [],
    );
  }

  /// `Start`
  String get gBtnStart {
    return Intl.message(
      'Start',
      name: 'gBtnStart',
      desc: 'This is a button for starting.',
      args: [],
    );
  }

  /// `End`
  String get gBtnEnd {
    return Intl.message(
      'End',
      name: 'gBtnEnd',
      desc: 'This is a button for endding.',
      args: [],
    );
  }

  /// `Exit`
  String get gBtnExit {
    return Intl.message(
      'Exit',
      name: 'gBtnExit',
      desc: 'This is a button to exit.',
      args: [],
    );
  }

  /// `Serial port information modification`
  String get gTitleSerialModify {
    return Intl.message(
      'Serial port information modification',
      name: 'gTitleSerialModify',
      desc: 'This is the title for modifying serial port information.',
      args: [],
    );
  }

  /// `Refresh`
  String get gMsgRefresh {
    return Intl.message(
      'Refresh',
      name: 'gMsgRefresh',
      desc: 'This is a button to refresh.',
      args: [],
    );
  }

  /// `Discover SSID`
  String get gFindSsid {
    return Intl.message(
      'Discover SSID',
      name: 'gFindSsid',
      desc: 'This is a prompt for discover ssid.',
      args: [],
    );
  }

  /// `Password`
  String get gPassword {
    return Intl.message(
      'Password',
      name: 'gPassword',
      desc: 'This is a prompt for password.',
      args: [],
    );
  }

  /// `IPv4`
  String get gIpAddress {
    return Intl.message(
      'IPv4',
      name: 'gIpAddress',
      desc: 'This is a prompt for IPv4.',
      args: [],
    );
  }

  /// `Netmask`
  String get gNetmask {
    return Intl.message(
      'Netmask',
      name: 'gNetmask',
      desc: 'This is a prompt for Netmask.',
      args: [],
    );
  }

  /// `Gateway`
  String get gGateway {
    return Intl.message(
      'Gateway',
      name: 'gGateway',
      desc: 'This is a prompt for Gateway.',
      args: [],
    );
  }

  /// `Static`
  String get gBtnStatic {
    return Intl.message(
      'Static',
      name: 'gBtnStatic',
      desc: 'This is a prompt for static IP.',
      args: [],
    );
  }

  /// `Dynamic`
  String get gBtnDynamic {
    return Intl.message(
      'Dynamic',
      name: 'gBtnDynamic',
      desc: 'This is a prompt for dynamic IP.',
      args: [],
    );
  }

  /// `Enter IP information and click the connect button!`
  String get gTipConnectStaticIp {
    return Intl.message(
      'Enter IP information and click the connect button!',
      name: 'gTipConnectStaticIp',
      desc: 'This is a prompt for connnecting static ip.',
      args: [],
    );
  }

  /// `Connecting...`
  String get gTipConnecting {
    return Intl.message(
      'Connecting...',
      name: 'gTipConnecting',
      desc: 'This is a prompt for connnecting.',
      args: [],
    );
  }

  /// `You are already connected!`
  String get gTipConnected {
    return Intl.message(
      'You are already connected!',
      name: 'gTipConnected',
      desc: 'This is a prompt for already connected .',
      args: [],
    );
  }

  /// `Connected AP Info`
  String get gTipConnectedInfo {
    return Intl.message(
      'Connected AP Info',
      name: 'gTipConnectedInfo',
      desc: 'This is a prompt for connected info .',
      args: [],
    );
  }

  /// `Obtaining AP list and Ip info,please wait...`
  String get gTipGetApListAndIP {
    return Intl.message(
      'Obtaining AP list and Ip info,please wait...',
      name: 'gTipGetApListAndIP',
      desc: 'This is a prompt for obtaining AP list and Ip info.',
      args: [],
    );
  }

  /// `Obtaining IP, please wait...`
  String get gTipGetIP {
    return Intl.message(
      'Obtaining IP, please wait...',
      name: 'gTipGetIP',
      desc: 'This is a prompt for obtaining Ip info.',
      args: [],
    );
  }

  /// `Obtaining AP list,please wait...`
  String get gTipGetAPList {
    return Intl.message(
      'Obtaining AP list,please wait...',
      name: 'gTipGetAPList',
      desc: 'This is a prompt for obtaining Ap list.',
      args: [],
    );
  }

  /// `Get Ip OK !`
  String get gTipGetIpOk {
    return Intl.message(
      'Get Ip OK !',
      name: 'gTipGetIpOk',
      desc:
          'This is a prompt indicating that the IP information has been successfully obtained.',
      args: [],
    );
  }

  /// `Get Ip Fail !`
  String get gTipGetIpFail {
    return Intl.message(
      'Get Ip Fail !',
      name: 'gTipGetIpFail',
      desc:
          'This is a prompt indicating that the attempt to obtain IP information has failed.',
      args: [],
    );
  }

  /// `SSID:`
  String get gTipSSID {
    return Intl.message(
      'SSID:',
      name: 'gTipSSID',
      desc: 'This is a prompt for SSID.',
      args: [],
    );
  }

  /// `Strong`
  String get gEPStrong {
    return Intl.message(
      'Strong',
      name: 'gEPStrong',
      desc: 'This is a prompt for the Bluetooth signal strength.',
      args: [],
    );
  }

  /// `Normal`
  String get gEPNormal {
    return Intl.message(
      'Normal',
      name: 'gEPNormal',
      desc: 'This is a prompt for the Bluetooth signal strength.',
      args: [],
    );
  }

  /// `Weak`
  String get gEPWeak {
    return Intl.message(
      'Weak',
      name: 'gEPWeak',
      desc: 'This is a prompt for the Bluetooth signal strength.',
      args: [],
    );
  }

  /// `Device name can not be empty,error.`
  String get gTipDeviceNameEmpty {
    return Intl.message(
      'Device name can not be empty,error.',
      name: 'gTipDeviceNameEmpty',
      desc: 'This is a prompt for empty device name.',
      args: [],
    );
  }

  /// `Time out!`
  String get gTipTimeOut {
    return Intl.message(
      'Time out!',
      name: 'gTipTimeOut',
      desc: 'This is a prompt for time out.',
      args: [],
    );
  }

  /// `Device name`
  String get gDeviceName {
    return Intl.message(
      'Device name',
      name: 'gDeviceName',
      desc: 'This is a prompt for device name.',
      args: [],
    );
  }

  /// `Serial port has been disconnected. Please check the settings.`
  String get gMsgSerialError {
    return Intl.message(
      'Serial port has been disconnected. Please check the settings.',
      name: 'gMsgSerialError',
      desc: 'This is a prompt for serial port has been disconnected.',
      args: [],
    );
  }

  /// `License information`
  String get gTitleLicense {
    return Intl.message(
      'License information',
      name: 'gTitleLicense',
      desc: 'This is a title for license information',
      args: [],
    );
  }

  /// `Printer Protocol:`
  String get gPrinter {
    return Intl.message(
      'Printer Protocol:',
      name: 'gPrinter',
      desc: 'This is a prompt for printer protocol.',
      args: [],
    );
  }

  /// `Direction:`
  String get gPrintDirection {
    return Intl.message(
      'Direction:',
      name: 'gPrintDirection',
      desc: 'This is a prompt regarding the printing direction.',
      args: [],
    );
  }

  /// `Open Json`
  String get gOpenJson {
    return Intl.message(
      'Open Json',
      name: 'gOpenJson',
      desc: 'This is a button about open print format. ',
      args: [],
    );
  }

  /// `QrCode Management`
  String get gQrcodeMgr {
    return Intl.message(
      'QrCode Management',
      name: 'gQrcodeMgr',
      desc: 'This is a prompt for qrcode manager.',
      args: [],
    );
  }

  /// `Barcode Management`
  String get gBarcodeMgr {
    return Intl.message(
      'Barcode Management',
      name: 'gBarcodeMgr',
      desc: 'This is a prompt for barcode manager.',
      args: [],
    );
  }

  /// `BarCode Edit`
  String get gBarcodeEdit {
    return Intl.message(
      'BarCode Edit',
      name: 'gBarcodeEdit',
      desc: 'This is a button about barcode edit.',
      args: [],
    );
  }

  /// `BarCode Type`
  String get gBarcodeType {
    return Intl.message(
      'BarCode Type',
      name: 'gBarcodeType',
      desc: 'This is a button about barcode type.',
      args: [],
    );
  }

  /// `QrCode Type`
  String get gQrcodeType {
    return Intl.message(
      'QrCode Type',
      name: 'gQrcodeType',
      desc: 'This is a button about qrcode type.',
      args: [],
    );
  }

  /// `BarCode Name`
  String get gBarcodeName {
    return Intl.message(
      'BarCode Name',
      name: 'gBarcodeName',
      desc: 'This is a button about barcode name.',
      args: [],
    );
  }

  /// `DATA TYPE`
  String get gBarCodeDataType {
    return Intl.message(
      'DATA TYPE',
      name: 'gBarCodeDataType',
      desc: 'This is a prompt regarding the data type.',
      args: [],
    );
  }

  /// `Content`
  String get gBarCodeContent {
    return Intl.message(
      'Content',
      name: 'gBarCodeContent',
      desc: 'This is a prompt regarding the content.',
      args: [],
    );
  }

  /// `Default Value`
  String get gBarCodeDefValue {
    return Intl.message(
      'Default Value',
      name: 'gBarCodeDefValue',
      desc: 'This is a prompt regarding the default value.',
      args: [],
    );
  }

  /// `Alignment`
  String get gBarCodeAlignment {
    return Intl.message(
      'Alignment',
      name: 'gBarCodeAlignment',
      desc: 'This is a prompt regarding the alignment.',
      args: [],
    );
  }

  /// `Max Length`
  String get gBarCodeMaxLength {
    return Intl.message(
      'Max Length',
      name: 'gBarCodeMaxLength',
      desc: 'This is a prompt regarding the max length.',
      args: [],
    );
  }

  /// `Delete`
  String get gBarCodeDelete {
    return Intl.message(
      'Delete',
      name: 'gBarCodeDelete',
      desc: 'This is a prompt to delete.',
      args: [],
    );
  }

  /// `Qrcode Edit`
  String get gQrcodeEdit {
    return Intl.message(
      'Qrcode Edit',
      name: 'gQrcodeEdit',
      desc: 'This is a button about qrcode edit.',
      args: [],
    );
  }

  /// `Qrcode Name`
  String get gQrcodeName {
    return Intl.message(
      'Qrcode Name',
      name: 'gQrcodeName',
      desc: 'This is a tip about qrcode name.',
      args: [],
    );
  }

  /// `Save Format`
  String get gSaveFormat {
    return Intl.message(
      'Save Format',
      name: 'gSaveFormat',
      desc: 'This is a button to save format.',
      args: [],
    );
  }

  /// `Download`
  String get gBtnDownload {
    return Intl.message(
      'Download',
      name: 'gBtnDownload',
      desc: 'This is a button for downloading.',
      args: [],
    );
  }

  /// `Default Format`
  String get gBtnDownloadDefaultFormat {
    return Intl.message(
      'Default Format',
      name: 'gBtnDownloadDefaultFormat',
      desc: 'This is a button for downloading default format. ',
      args: [],
    );
  }

  /// `Attribute`
  String get gAttribute {
    return Intl.message(
      'Attribute',
      name: 'gAttribute',
      desc: 'This is a prompt about the attributes.',
      args: [],
    );
  }

  /// `Layer order:`
  String get gTabOrder {
    return Intl.message(
      'Layer order:',
      name: 'gTabOrder',
      desc: 'This is a prompt about the order of items in the printing format.',
      args: [],
    );
  }

  /// `No element selected.`
  String get gMsgNoElement {
    return Intl.message(
      'No element selected.',
      name: 'gMsgNoElement',
      desc: 'This is a prompt regarding no item being selected.',
      args: [],
    );
  }

  /// `Width`
  String get gPageWidth {
    return Intl.message(
      'Width',
      name: 'gPageWidth',
      desc: 'This is a prompt about the page width.',
      args: [],
    );
  }

  /// `Height`
  String get gPageHeight {
    return Intl.message(
      'Height',
      name: 'gPageHeight',
      desc: 'This is a prompt about the page height.',
      args: [],
    );
  }

  /// `Text Content:`
  String get gTextContent {
    return Intl.message(
      'Text Content:',
      name: 'gTextContent',
      desc: 'This is a prompt about text content.',
      args: [],
    );
  }

  /// `Font Size:`
  String get gFontSize {
    return Intl.message(
      'Font Size:',
      name: 'gFontSize',
      desc: 'This is a prompt about font size.',
      args: [],
    );
  }

  /// `Rotation:`
  String get gRotation {
    return Intl.message(
      'Rotation:',
      name: 'gRotation',
      desc: 'This is a prompt about rotation.',
      args: [],
    );
  }

  /// `Reverse Contrast:`
  String get gFontReverse {
    return Intl.message(
      'Reverse Contrast:',
      name: 'gFontReverse',
      desc: 'This is a prompt about reverse contrast.',
      args: [],
    );
  }

  /// `HRI Alignment:`
  String get gHrAlignment {
    return Intl.message(
      'HRI Alignment:',
      name: 'gHrAlignment',
      desc: 'This is a prompt about HRI alignment.',
      args: [],
    );
  }

  /// `Delete`
  String get gBtnDelete {
    return Intl.message(
      'Delete',
      name: 'gBtnDelete',
      desc: 'This is a delete button.',
      args: [],
    );
  }

  /// `QRcode:`
  String get gQrcode {
    return Intl.message(
      'QRcode:',
      name: 'gQrcode',
      desc: 'This is a prompt about QRcode',
      args: [],
    );
  }

  /// `Qrcode Width:`
  String get gQrcodeWidth {
    return Intl.message(
      'Qrcode Width:',
      name: 'gQrcodeWidth',
      desc: 'This is a prompt about QRcode width.',
      args: [],
    );
  }

  /// `Position`
  String get gPosition {
    return Intl.message(
      'Position',
      name: 'gPosition',
      desc: 'This is a prompt about position.',
      args: [],
    );
  }

  /// `Bold:`
  String get gFontBold {
    return Intl.message(
      'Bold:',
      name: 'gFontBold',
      desc: 'This is a prompt about font bold.',
      args: [],
    );
  }

  /// `Alignment:`
  String get gAlignment {
    return Intl.message(
      'Alignment:',
      name: 'gAlignment',
      desc: 'This is a prompt about alignment.',
      args: [],
    );
  }

  /// `Max Length:`
  String get gMaxLength {
    return Intl.message(
      'Max Length:',
      name: 'gMaxLength',
      desc: 'This is a prompt about max length.',
      args: [],
    );
  }

  /// `BarCode:`
  String get gBarcode {
    return Intl.message(
      'BarCode:',
      name: 'gBarcode',
      desc: 'This is a prompt about BarCode.',
      args: [],
    );
  }

  /// `Zero`
  String get iBtnZero {
    return Intl.message(
      'Zero',
      name: 'iBtnZero',
      desc: 'This is a zeroing button in T-Industry,',
      args: [],
    );
  }

  /// `Zero`
  String get iTextZero {
    return Intl.message(
      'Zero',
      name: 'iTextZero',
      desc: 'This is a prompt about zero weight in T-Industry,',
      args: [],
    );
  }

  /// `Net`
  String get iTextNet {
    return Intl.message(
      'Net',
      name: 'iTextNet',
      desc: 'This is a prompt about net weight in T-Industry,',
      args: [],
    );
  }

  /// `Stable`
  String get iStable {
    return Intl.message(
      'Stable',
      name: 'iStable',
      desc: 'This is a prompt about stable weight in T-Industry,',
      args: [],
    );
  }

  /// `Unstable Zero/Tare`
  String get gUnstableZeroTare {
    return Intl.message(
      'Unstable Zero/Tare',
      name: 'gUnstableZeroTare',
      desc: 'This is a prompt for unstable zero or tare operation.',
      args: [],
    );
  }

  /// `Setting`
  String get gBtnSetting {
    return Intl.message(
      'Setting',
      name: 'gBtnSetting',
      desc: 'This is a button about setting.',
      args: [],
    );
  }

  /// `Export`
  String get gBtnExport {
    return Intl.message(
      'Export',
      name: 'gBtnExport',
      desc: 'This is a export button.',
      args: [],
    );
  }

  /// `select all`
  String get gSelectAll {
    return Intl.message(
      'select all',
      name: 'gSelectAll',
      desc: 'This is a prompt for selecting all items.',
      args: [],
    );
  }

  /// `PLU Name`
  String get gPluName {
    return Intl.message(
      'PLU Name',
      name: 'gPluName',
      desc: 'This is a prompt about PLU name.',
      args: [],
    );
  }

  /// `Parameter settings`
  String get gParameterSettingsTitle {
    return Intl.message(
      'Parameter settings',
      name: 'gParameterSettingsTitle',
      desc: 'This is a prompt about parameter settings.',
      args: [],
    );
  }

  /// `Save Mode`
  String get save_mode {
    return Intl.message(
      'Save Mode',
      name: 'save_mode',
      desc: 'This is a prompt about saving mode.',
      args: [],
    );
  }

  /// `Manual`
  String get gTipManual {
    return Intl.message(
      'Manual',
      name: 'gTipManual',
      desc: 'This is a prompt about manual mode.',
      args: [],
    );
  }

  /// `Auto`
  String get gTipAuto {
    return Intl.message(
      'Auto',
      name: 'gTipAuto',
      desc: 'This is a prompt about auto mode.',
      args: [],
    );
  }

  /// `Stable Time (s)`
  String get gTipStableTime {
    return Intl.message(
      'Stable Time (s)',
      name: 'gTipStableTime',
      desc: 'This is a prompt about stable time.',
      args: [],
    );
  }

  /// `The value must be under 20 seconds.`
  String get stable_time_error_tip {
    return Intl.message(
      'The value must be under 20 seconds.',
      name: 'stable_time_error_tip',
      desc: '',
      args: [],
    );
  }

  /// `Date Format`
  String get date_format {
    return Intl.message('Date Format', name: 'date_format', desc: '', args: []);
  }

  /// `Date Separator`
  String get gDateSeparator {
    return Intl.message(
      'Date Separator',
      name: 'gDateSeparator',
      desc: 'This is a prompt about date separator.',
      args: [],
    );
  }

  /// `Pretare:`
  String get pretare {
    return Intl.message('Pretare:', name: 'pretare', desc: '', args: []);
  }

  /// `Edit`
  String get gBtnEdit {
    return Intl.message('Edit', name: 'gBtnEdit', desc: '', args: []);
  }

  /// `Back`
  String get button_back {
    return Intl.message('Back', name: 'button_back', desc: '', args: []);
  }

  /// `Select Format`
  String get button_select_format {
    return Intl.message(
      'Select Format',
      name: 'button_select_format',
      desc: '',
      args: [],
    );
  }

  /// `Update Firmware Serial`
  String get firmware_update {
    return Intl.message(
      'Update Firmware Serial',
      name: 'firmware_update',
      desc: '',
      args: [],
    );
  }

  /// `Add License`
  String get button_add_license {
    return Intl.message(
      'Add License',
      name: 'button_add_license',
      desc: '',
      args: [],
    );
  }

  /// `Result`
  String get gTipResult {
    return Intl.message(
      'Result',
      name: 'gTipResult',
      desc: 'This is a tip of add license result.',
      args: [],
    );
  }

  /// `Serial port connected`
  String get txt_serial_port_connected {
    return Intl.message(
      'Serial port connected',
      name: 'txt_serial_port_connected',
      desc: '',
      args: [],
    );
  }

  /// `Unable to connect`
  String get txt_serial_port_connected_fail {
    return Intl.message(
      'Unable to connect',
      name: 'txt_serial_port_connected_fail',
      desc: '',
      args: [],
    );
  }

  /// `Software Information`
  String get gTitleGetBuildInfo {
    return Intl.message(
      'Software Information',
      name: 'gTitleGetBuildInfo',
      desc: '',
      args: [],
    );
  }

  /// `This ID is only to be used by device developers.`
  String get gBuildInfoTip {
    return Intl.message(
      'This ID is only to be used by device developers.',
      name: 'gBuildInfoTip',
      desc: 'This is a tip for build info.',
      args: [],
    );
  }

  /// `OL mode`
  String get serial_page_ol {
    return Intl.message('OL mode', name: 'serial_page_ol', desc: '', args: []);
  }

  /// `UL mode`
  String get serial_page_ul {
    return Intl.message('UL mode', name: 'serial_page_ul', desc: '', args: []);
  }

  /// `Weight mode`
  String get serial_page_weight {
    return Intl.message(
      'Weight mode',
      name: 'serial_page_weight',
      desc: '',
      args: [],
    );
  }

  /// `Counting mode`
  String get serial_page_pcs {
    return Intl.message(
      'Counting mode',
      name: 'serial_page_pcs',
      desc: '',
      args: [],
    );
  }

  /// `Price Computing mode`
  String get serial_page_price {
    return Intl.message(
      'Price Computing mode',
      name: 'serial_page_price',
      desc: '',
      args: [],
    );
  }

  /// `Percent mode`
  String get serial_page_percent {
    return Intl.message(
      'Percent mode',
      name: 'serial_page_percent',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth Setting`
  String get bt_setting_title {
    return Intl.message(
      'Bluetooth Setting',
      name: 'bt_setting_title',
      desc: '',
      args: [],
    );
  }

  /// `Serial Output Download`
  String get gTitleSerialOutputDownload {
    return Intl.message(
      'Serial Output Download',
      name: 'gTitleSerialOutputDownload',
      desc: 'This is a title about serial output download.',
      args: [],
    );
  }

  /// `System Setting`
  String get gSystemSetting {
    return Intl.message(
      'System Setting',
      name: 'gSystemSetting',
      desc: 'This is a title about system setting.',
      args: [],
    );
  }

  /// `Set Language`
  String get gTitleSetLanguage {
    return Intl.message(
      'Set Language',
      name: 'gTitleSetLanguage',
      desc: 'This is a title about language setting.',
      args: [],
    );
  }

  /// `License Info`
  String get gTitleLicenseInfo {
    return Intl.message(
      'License Info',
      name: 'gTitleLicenseInfo',
      desc: 'This is a title about license info.',
      args: [],
    );
  }

  /// `Open preview`
  String get cBtnOpenPreview {
    return Intl.message(
      'Open preview',
      name: 'cBtnOpenPreview',
      desc: ' This is a button about open preview in T-Config.',
      args: [],
    );
  }

  /// `Preview`
  String get gTitlePreview {
    return Intl.message(
      'Preview',
      name: 'gTitlePreview',
      desc: 'This is a preview of the output of a custom serial port protocol.',
      args: [],
    );
  }

  /// `Clear`
  String get gBtnClear {
    return Intl.message(
      'Clear',
      name: 'gBtnClear',
      desc: 'This is a button for clearing.',
      args: [],
    );
  }

  /// `Free format`
  String get gTipFreeFormat {
    return Intl.message(
      'Free format',
      name: 'gTipFreeFormat',
      desc: 'This is a prompt for free format.',
      args: [],
    );
  }

  /// `Total format:`
  String get gTotalFmt {
    return Intl.message(
      'Total format:',
      name: 'gTotalFmt',
      desc: 'This is a prompt for total format.',
      args: [],
    );
  }

  /// `PLU Download`
  String get gTitlePluDownload {
    return Intl.message(
      'PLU Download',
      name: 'gTitlePluDownload',
      desc: 'This is a title about downloading plu.',
      args: [],
    );
  }

  /// `Confirmation`
  String get gTitleConfirm {
    return Intl.message(
      'Confirmation',
      name: 'gTitleConfirm',
      desc: 'This is the title of the confirmation.',
      args: [],
    );
  }

  /// `Please confirm the order of the printing formats.`
  String get gConfirmPrnFmtOrderTip {
    return Intl.message(
      'Please confirm the order of the printing formats.',
      name: 'gConfirmPrnFmtOrderTip',
      desc: 'This is the prompt to confirm the order of the printing format.',
      args: [],
    );
  }

  /// `Please confirm to go to the default print format page.`
  String get jump_confirm_info {
    return Intl.message(
      'Please confirm to go to the default print format page.',
      name: 'jump_confirm_info',
      desc: '',
      args: [],
    );
  }

  /// `Select Firmware`
  String get select_firmware_btn {
    return Intl.message(
      'Select Firmware',
      name: 'select_firmware_btn',
      desc: '',
      args: [],
    );
  }

  /// `Whether to delete all data?`
  String get data_delete_confirm {
    return Intl.message(
      'Whether to delete all data?',
      name: 'data_delete_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Configuration name`
  String get cTipConfigurationName {
    return Intl.message(
      'Configuration name',
      name: 'cTipConfigurationName',
      desc: 'This is a tip about configuration name.',
      args: [],
    );
  }

  /// `Editable`
  String get cTipEditable {
    return Intl.message(
      'Editable',
      name: 'cTipEditable',
      desc: 'This is a tip about whether editing is enabled.',
      args: [],
    );
  }

  /// `Size`
  String get cTipParameterSize {
    return Intl.message(
      'Size',
      name: 'cTipParameterSize',
      desc: 'This is a tip about parameter size.',
      args: [],
    );
  }

  /// `Parameter Type`
  String get cTipParameterTyppe {
    return Intl.message(
      'Parameter Type',
      name: 'cTipParameterTyppe',
      desc: 'This is a tip about parameter type.',
      args: [],
    );
  }

  /// `Parameter Value`
  String get cTipParameterValue {
    return Intl.message(
      'Parameter Value',
      name: 'cTipParameterValue',
      desc: 'This is a title about parameter value.',
      args: [],
    );
  }

  /// `Description`
  String get cTipParameterDesp {
    return Intl.message(
      'Description',
      name: 'cTipParameterDesp',
      desc: 'This is a title about parameter description.',
      args: [],
    );
  }

  /// `Click to submit`
  String get cBtnCommit {
    return Intl.message(
      'Click to submit',
      name: 'cBtnCommit',
      desc: 'This is a button for submitting parameter modifications.',
      args: [],
    );
  }

  /// `No parameters have been modified!`
  String get cTipNotModified {
    return Intl.message(
      'No parameters have been modified!',
      name: 'cTipNotModified',
      desc: 'This is a tip: No parameter modifications.',
      args: [],
    );
  }

  /// `Please make sure the values are correct, continue?`
  String get cTipConfirmModified {
    return Intl.message(
      'Please make sure the values are correct, continue?',
      name: 'cTipConfirmModified',
      desc: 'This is a tip: Please make sure the values are correct, continue?',
      args: [],
    );
  }

  /// `Please check`
  String get cTipCheckValue {
    return Intl.message(
      'Please check',
      name: 'cTipCheckValue',
      desc: 'This is a tip: Please check',
      args: [],
    );
  }

  /// `Please confirm the information.`
  String get gTipConfirmInfo {
    return Intl.message(
      'Please confirm the information.',
      name: 'gTipConfirmInfo',
      desc: 'This is the prompt asking you to confirm the information.',
      args: [],
    );
  }

  /// `Server Ip:`
  String get server_ip {
    return Intl.message('Server Ip:', name: 'server_ip', desc: '', args: []);
  }

  /// `Confirm to return to hompage?`
  String get go_home {
    return Intl.message(
      'Confirm to return to hompage?',
      name: 'go_home',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get appVersionTitle {
    return Intl.message(
      'Version',
      name: 'appVersionTitle',
      desc: 'Title for the application version information',
      args: [],
    );
  }

  /// `Company`
  String get appCompanyTitle {
    return Intl.message(
      'Company',
      name: 'appCompanyTitle',
      desc: 'Title for the application company information',
      args: [],
    );
  }

  /// `Tel`
  String get appTelTitle {
    return Intl.message(
      'Tel',
      name: 'appTelTitle',
      desc: 'Title for the application telephone information',
      args: [],
    );
  }

  /// `Email`
  String get appEmailTitle {
    return Intl.message(
      'Email',
      name: 'appEmailTitle',
      desc: 'Title for the application email information',
      args: [],
    );
  }

  /// `Address`
  String get appAddressTitle {
    return Intl.message(
      'Address',
      name: 'appAddressTitle',
      desc: 'Title for the application address information',
      args: [],
    );
  }

  /// `Website`
  String get appWebTitle {
    return Intl.message(
      'Website',
      name: 'appWebTitle',
      desc: 'Title for the application website information',
      args: [],
    );
  }

  /// `Applicable Models`
  String get appModels {
    return Intl.message(
      'Applicable Models',
      name: 'appModels',
      desc: 'Title for the models that the application is applicable to',
      args: [],
    );
  }

  /// `Free Text`
  String get p_text_title {
    return Intl.message('Free Text', name: 'p_text_title', desc: '', args: []);
  }

  /// `Dividing Line`
  String get p_line_title {
    return Intl.message(
      'Dividing Line',
      name: 'p_line_title',
      desc: '',
      args: [],
    );
  }

  /// `Price Variable`
  String get p_price_title {
    return Intl.message(
      'Price Variable',
      name: 'p_price_title',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get p_text_var {
    return Intl.message('Text', name: 'p_text_var', desc: '', args: []);
  }

  /// `Line`
  String get p_div_line_var {
    return Intl.message('Line', name: 'p_div_line_var', desc: '', args: []);
  }

  /// `NO.`
  String get p_no_var {
    return Intl.message('NO.', name: 'p_no_var', desc: '', args: []);
  }

  /// `Header1`
  String get p_header1_var {
    return Intl.message('Header1', name: 'p_header1_var', desc: '', args: []);
  }

  /// `Header2`
  String get p_Header2_var {
    return Intl.message('Header2', name: 'p_Header2_var', desc: '', args: []);
  }

  /// `Header3`
  String get p_header3_var {
    return Intl.message('Header3', name: 'p_header3_var', desc: '', args: []);
  }

  /// `Footer1`
  String get p_footer1_var {
    return Intl.message('Footer1', name: 'p_footer1_var', desc: '', args: []);
  }

  /// `Footer2`
  String get p_footer2_var {
    return Intl.message('Footer2', name: 'p_footer2_var', desc: '', args: []);
  }

  /// `Footer3`
  String get p_footer3_var {
    return Intl.message('Footer3', name: 'p_footer3_var', desc: '', args: []);
  }

  /// `PLU_ID`
  String get p_plu_id_var {
    return Intl.message('PLU_ID', name: 'p_plu_id_var', desc: '', args: []);
  }

  /// `PLU_Name`
  String get p_plu_name_var {
    return Intl.message('PLU_Name', name: 'p_plu_name_var', desc: '', args: []);
  }

  /// `Order Number`
  String get p_order_number_var {
    return Intl.message(
      'Order Number',
      name: 'p_order_number_var',
      desc: '',
      args: [],
    );
  }

  /// `Unit Price`
  String get p_unit_price_var {
    return Intl.message(
      'Unit Price',
      name: 'p_unit_price_var',
      desc: '',
      args: [],
    );
  }

  /// `Price Unit`
  String get p_price_unit_var {
    return Intl.message(
      'Price Unit',
      name: 'p_price_unit_var',
      desc: '',
      args: [],
    );
  }

  /// `PreTare`
  String get p_pre_tare_var {
    return Intl.message('PreTare', name: 'p_pre_tare_var', desc: '', args: []);
  }

  /// `Unit`
  String get p_unit_var {
    return Intl.message('Unit', name: 'p_unit_var', desc: '', args: []);
  }

  /// `Date`
  String get p_date_var {
    return Intl.message('Date', name: 'p_date_var', desc: '', args: []);
  }

  /// `Tax Type1`
  String get p_tax_type1_var {
    return Intl.message(
      'Tax Type1',
      name: 'p_tax_type1_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Type2`
  String get p_tax_type2_var {
    return Intl.message(
      'Tax Type2',
      name: 'p_tax_type2_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Type3`
  String get p_tax_type3_var {
    return Intl.message(
      'Tax Type3',
      name: 'p_tax_type3_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Base1`
  String get p_tax_base1_var {
    return Intl.message(
      'Tax Base1',
      name: 'p_tax_base1_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Base2`
  String get p_tax_base2_var {
    return Intl.message(
      'Tax Base2',
      name: 'p_tax_base2_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Base3`
  String get p_tax_base3_var {
    return Intl.message(
      'Tax Base3',
      name: 'p_tax_base3_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Amount1`
  String get p_tax_amount1_var {
    return Intl.message(
      'Tax Amount1',
      name: 'p_tax_amount1_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Amount2`
  String get p_tax_amount2_var {
    return Intl.message(
      'Tax Amount2',
      name: 'p_tax_amount2_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Amount3`
  String get p_tax_amount3_var {
    return Intl.message(
      'Tax Amount3',
      name: 'p_tax_amount3_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Model`
  String get p_tax_model_var {
    return Intl.message(
      'Tax Model',
      name: 'p_tax_model_var',
      desc: '',
      args: [],
    );
  }

  /// `Total Tax Amount`
  String get p_total_tax_amount_var {
    return Intl.message(
      'Total Tax Amount',
      name: 'p_total_tax_amount_var',
      desc: '',
      args: [],
    );
  }

  /// `Payment Amount`
  String get p_payment_amount_P_var {
    return Intl.message(
      'Payment Amount',
      name: 'p_payment_amount_P_var',
      desc: '',
      args: [],
    );
  }

  /// `Subtotal`
  String get p_subtotal_var {
    return Intl.message('Subtotal', name: 'p_subtotal_var', desc: '', args: []);
  }

  /// `Currency`
  String get p_currency_var {
    return Intl.message('Currency', name: 'p_currency_var', desc: '', args: []);
  }

  /// `Copy Times`
  String get p_copy_times_var {
    return Intl.message(
      'Copy Times',
      name: 'p_copy_times_var',
      desc: '',
      args: [],
    );
  }

  /// `Model Name`
  String get p_model_name_var {
    return Intl.message(
      'Model Name',
      name: 'p_model_name_var',
      desc: '',
      args: [],
    );
  }

  /// `Scale Name`
  String get p_scale_name_var {
    return Intl.message(
      'Scale Name',
      name: 'p_scale_name_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Name.`
  String get p_tax_name_var {
    return Intl.message(
      'Tax Name.',
      name: 'p_tax_name_var',
      desc: '',
      args: [],
    );
  }

  /// `Settle Account Times.`
  String get p_settle_account_times_var {
    return Intl.message(
      'Settle Account Times.',
      name: 'p_settle_account_times_var',
      desc: '',
      args: [],
    );
  }

  /// `PLU Tax`
  String get p_plu_tax_var {
    return Intl.message('PLU Tax', name: 'p_plu_tax_var', desc: '', args: []);
  }

  /// `Total No Tax`
  String get p_total_no_tax_var {
    return Intl.message(
      'Total No Tax',
      name: 'p_total_no_tax_var',
      desc: '',
      args: [],
    );
  }

  /// `Weight Pcs`
  String get p_weight_pcs_var {
    return Intl.message(
      'Weight Pcs',
      name: 'p_weight_pcs_var',
      desc: '',
      args: [],
    );
  }

  /// `Tare`
  String get p_tare_var {
    return Intl.message('Tare', name: 'p_tare_var', desc: '', args: []);
  }

  /// `Time`
  String get p_time_var {
    return Intl.message('Time', name: 'p_time_var', desc: '', args: []);
  }

  /// `Change Amount`
  String get p_change_amount_var {
    return Intl.message(
      'Change Amount',
      name: 'p_change_amount_var',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get p_price_var {
    return Intl.message('Price', name: 'p_price_var', desc: '', args: []);
  }

  /// `Free text.`
  String get p_text_expl {
    return Intl.message('Free text.', name: 'p_text_expl', desc: '', args: []);
  }

  /// `Loop divider line.`
  String get p_div_line_expl {
    return Intl.message(
      'Loop divider line.',
      name: 'p_div_line_expl',
      desc: '',
      args: [],
    );
  }

  /// `Sequence number value.`
  String get p_no_expl {
    return Intl.message(
      'Sequence number value.',
      name: 'p_no_expl',
      desc: '',
      args: [],
    );
  }

  /// `The first page header.`
  String get p_header1_expl {
    return Intl.message(
      'The first page header.',
      name: 'p_header1_expl',
      desc: '',
      args: [],
    );
  }

  /// `The secend page header.`
  String get p_Header2_expl {
    return Intl.message(
      'The secend page header.',
      name: 'p_Header2_expl',
      desc: '',
      args: [],
    );
  }

  /// `The third page header.`
  String get p_header3_expl {
    return Intl.message(
      'The third page header.',
      name: 'p_header3_expl',
      desc: '',
      args: [],
    );
  }

  /// `The first page footer.`
  String get p_footer1_expl {
    return Intl.message(
      'The first page footer.',
      name: 'p_footer1_expl',
      desc: '',
      args: [],
    );
  }

  /// `The secend page footer.`
  String get p_footer2_expl {
    return Intl.message(
      'The secend page footer.',
      name: 'p_footer2_expl',
      desc: '',
      args: [],
    );
  }

  /// `The third page footer.`
  String get p_footer3_expl {
    return Intl.message(
      'The third page footer.',
      name: 'p_footer3_expl',
      desc: '',
      args: [],
    );
  }

  /// `PLU_ID.`
  String get p_plu_id_expl {
    return Intl.message('PLU_ID.', name: 'p_plu_id_expl', desc: '', args: []);
  }

  /// `PLU_Name.`
  String get p_plu_name_expl {
    return Intl.message(
      'PLU_Name.',
      name: 'p_plu_name_expl',
      desc: '',
      args: [],
    );
  }

  /// `The serial number of the pending order.`
  String get p_order_number_expl {
    return Intl.message(
      'The serial number of the pending order.',
      name: 'p_order_number_expl',
      desc: '',
      args: [],
    );
  }

  /// `Unit Price.`
  String get p_unit_price_expl {
    return Intl.message(
      'Unit Price.',
      name: 'p_unit_price_expl',
      desc: '',
      args: [],
    );
  }

  /// `Price Unit.`
  String get p_price_unit_expl {
    return Intl.message(
      'Price Unit.',
      name: 'p_price_unit_expl',
      desc: '',
      args: [],
    );
  }

  /// `PreTare.`
  String get p_pre_tare_expl {
    return Intl.message(
      'PreTare.',
      name: 'p_pre_tare_expl',
      desc: '',
      args: [],
    );
  }

  /// `Weight Unit.`
  String get p_unit_expl {
    return Intl.message(
      'Weight Unit.',
      name: 'p_unit_expl',
      desc: '',
      args: [],
    );
  }

  /// `Date.`
  String get p_date_expl {
    return Intl.message('Date.', name: 'p_date_expl', desc: '', args: []);
  }

  /// `Tax Type 1.`
  String get p_tax_type1_expl {
    return Intl.message(
      'Tax Type 1.',
      name: 'p_tax_type1_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Type 2.`
  String get p_tax_type2_expl {
    return Intl.message(
      'Tax Type 2.',
      name: 'p_tax_type2_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Type 3.`
  String get p_tax_type3_expl {
    return Intl.message(
      'Tax Type 3.',
      name: 'p_tax_type3_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Base 1.`
  String get p_tax_base1_expl {
    return Intl.message(
      'Tax Base 1.',
      name: 'p_tax_base1_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Base 2.`
  String get p_tax_base2_expl {
    return Intl.message(
      'Tax Base 2.',
      name: 'p_tax_base2_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Base 3.`
  String get p_tax_base3_expl {
    return Intl.message(
      'Tax Base 3.',
      name: 'p_tax_base3_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Amount 1.`
  String get p_tax_amount1_expl {
    return Intl.message(
      'Tax Amount 1.',
      name: 'p_tax_amount1_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Amount 2.`
  String get p_tax_amount2_expl {
    return Intl.message(
      'Tax Amount 2.',
      name: 'p_tax_amount2_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Amount 3.`
  String get p_tax_amount3_expl {
    return Intl.message(
      'Tax Amount 3.',
      name: 'p_tax_amount3_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Model,tax included or tax external.`
  String get p_tax_model_expl {
    return Intl.message(
      'Tax Model,tax included or tax external.',
      name: 'p_tax_model_expl',
      desc: '',
      args: [],
    );
  }

  /// `Total Tax Amount.`
  String get p_total_tax_amount_expl {
    return Intl.message(
      'Total Tax Amount.',
      name: 'p_total_tax_amount_expl',
      desc: '',
      args: [],
    );
  }

  /// `Payment Amount.`
  String get p_payment_amount_P_expl {
    return Intl.message(
      'Payment Amount.',
      name: 'p_payment_amount_P_expl',
      desc: '',
      args: [],
    );
  }

  /// `Subtotal.`
  String get p_subtotal_expl {
    return Intl.message(
      'Subtotal.',
      name: 'p_subtotal_expl',
      desc: '',
      args: [],
    );
  }

  /// `Currency.`
  String get p_currency_expl {
    return Intl.message(
      'Currency.',
      name: 'p_currency_expl',
      desc: '',
      args: [],
    );
  }

  /// `Copy Times.`
  String get p_copy_times_expl {
    return Intl.message(
      'Copy Times.',
      name: 'p_copy_times_expl',
      desc: '',
      args: [],
    );
  }

  /// `Scale Model Name.`
  String get p_model_name_expl {
    return Intl.message(
      'Scale Model Name.',
      name: 'p_model_name_expl',
      desc: '',
      args: [],
    );
  }

  /// `Scale Name.`
  String get p_scale_name_expl {
    return Intl.message(
      'Scale Name.',
      name: 'p_scale_name_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Name.`
  String get p_tax_name_expl {
    return Intl.message(
      'Tax Name.',
      name: 'p_tax_name_expl',
      desc: '',
      args: [],
    );
  }

  /// `Settle Account Times.`
  String get p_settle_account_times_expl {
    return Intl.message(
      'Settle Account Times.',
      name: 'p_settle_account_times_expl',
      desc: '',
      args: [],
    );
  }

  /// `PLU Tax Value.`
  String get p_plu_tax_expl {
    return Intl.message(
      'PLU Tax Value.',
      name: 'p_plu_tax_expl',
      desc: '',
      args: [],
    );
  }

  /// `Total No Tax.`
  String get p_total_no_tax_expl {
    return Intl.message(
      'Total No Tax.',
      name: 'p_total_no_tax_expl',
      desc: '',
      args: [],
    );
  }

  /// `Weight or Pcs.`
  String get p_weight_pcs_expl {
    return Intl.message(
      'Weight or Pcs.',
      name: 'p_weight_pcs_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tare value.`
  String get p_tare_expl {
    return Intl.message('Tare value.', name: 'p_tare_expl', desc: '', args: []);
  }

  /// `Time.`
  String get p_time_expl {
    return Intl.message('Time.', name: 'p_time_expl', desc: '', args: []);
  }

  /// `Change Amount.`
  String get p_change_amount_expl {
    return Intl.message(
      'Change Amount.',
      name: 'p_change_amount_expl',
      desc: '',
      args: [],
    );
  }

  /// `Price value.`
  String get p_price_expl {
    return Intl.message(
      'Price value.',
      name: 'p_price_expl',
      desc: '',
      args: [],
    );
  }

  /// `Variable`
  String get l_var_title {
    return Intl.message('Variable', name: 'l_var_title', desc: '', args: []);
  }

  /// `Free Text`
  String get l_text_title {
    return Intl.message('Free Text', name: 'l_text_title', desc: '', args: []);
  }

  /// `BarCode Variable`
  String get l_barcode_title {
    return Intl.message(
      'BarCode Variable',
      name: 'l_barcode_title',
      desc: '',
      args: [],
    );
  }

  /// `Qrcode Variable`
  String get l_qrcode_title {
    return Intl.message(
      'Qrcode Variable',
      name: 'l_qrcode_title',
      desc: '',
      args: [],
    );
  }

  /// `Shape`
  String get l_shape_title {
    return Intl.message('Shape', name: 'l_shape_title', desc: '', args: []);
  }

  /// `Line`
  String get l_line_var {
    return Intl.message('Line', name: 'l_line_var', desc: '', args: []);
  }

  /// `Text`
  String get l_text_var {
    return Intl.message('Text', name: 'l_text_var', desc: '', args: []);
  }

  /// `BarCode`
  String get l_barcode_var {
    return Intl.message('BarCode', name: 'l_barcode_var', desc: '', args: []);
  }

  /// `Qrcode`
  String get l_qrcode_var {
    return Intl.message('Qrcode', name: 'l_qrcode_var', desc: '', args: []);
  }

  /// `NO.`
  String get l_no_var {
    return Intl.message('NO.', name: 'l_no_var', desc: '', args: []);
  }

  /// `Gross`
  String get l_gross_var {
    return Intl.message('Gross', name: 'l_gross_var', desc: '', args: []);
  }

  /// `Tare`
  String get l_tare_var {
    return Intl.message('Tare', name: 'l_tare_var', desc: '', args: []);
  }

  /// `Net`
  String get l_net_var {
    return Intl.message('Net', name: 'l_net_var', desc: '', args: []);
  }

  /// `PCS`
  String get l_pcs_var {
    return Intl.message('PCS', name: 'l_pcs_var', desc: '', args: []);
  }

  /// `WeightUnit`
  String get l_wgt_unit_var {
    return Intl.message(
      'WeightUnit',
      name: 'l_wgt_unit_var',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get l_date_var {
    return Intl.message('Date', name: 'l_date_var', desc: '', args: []);
  }

  /// `Time`
  String get l_time_var {
    return Intl.message('Time', name: 'l_time_var', desc: '', args: []);
  }

  /// `U.WGT`
  String get l_uwgt_var {
    return Intl.message('U.WGT', name: 'l_uwgt_var', desc: '', args: []);
  }

  /// `U.WU`
  String get l_uwu_var {
    return Intl.message('U.WU', name: 'l_uwu_var', desc: '', args: []);
  }

  /// `UnitWeight`
  String get l_unit_wgt_var {
    return Intl.message(
      'UnitWeight',
      name: 'l_unit_wgt_var',
      desc: '',
      args: [],
    );
  }

  /// `Percent`
  String get l_percent_var {
    return Intl.message('Percent', name: 'l_percent_var', desc: '', args: []);
  }

  /// `TotalWeight`
  String get l_total_wgt_var {
    return Intl.message(
      'TotalWeight',
      name: 'l_total_wgt_var',
      desc: '',
      args: [],
    );
  }

  /// `TotalCount`
  String get l_total_cnt_var {
    return Intl.message(
      'TotalCount',
      name: 'l_total_cnt_var',
      desc: '',
      args: [],
    );
  }

  /// `TotalPcs`
  String get l_total_pcs_var {
    return Intl.message(
      'TotalPcs',
      name: 'l_total_pcs_var',
      desc: '',
      args: [],
    );
  }

  /// `Line`
  String get l_line_expl {
    return Intl.message('Line', name: 'l_line_expl', desc: '', args: []);
  }

  /// `Text`
  String get l_text_expl {
    return Intl.message('Text', name: 'l_text_expl', desc: '', args: []);
  }

  /// `BarCode`
  String get l_barcode_expl {
    return Intl.message('BarCode', name: 'l_barcode_expl', desc: '', args: []);
  }

  /// `Qrcode`
  String get l_qrcode_expl {
    return Intl.message('Qrcode', name: 'l_qrcode_expl', desc: '', args: []);
  }

  /// `NO.`
  String get l_no_expl {
    return Intl.message('NO.', name: 'l_no_expl', desc: '', args: []);
  }

  /// `Gross`
  String get l_gross_expl {
    return Intl.message('Gross', name: 'l_gross_expl', desc: '', args: []);
  }

  /// `Tare`
  String get l_tare_expl {
    return Intl.message('Tare', name: 'l_tare_expl', desc: '', args: []);
  }

  /// `Net`
  String get l_net_expl {
    return Intl.message('Net', name: 'l_net_expl', desc: '', args: []);
  }

  /// `PCS`
  String get l_pcs_expl {
    return Intl.message('PCS', name: 'l_pcs_expl', desc: '', args: []);
  }

  /// `WeightUnit`
  String get l_wgt_unit_expl {
    return Intl.message(
      'WeightUnit',
      name: 'l_wgt_unit_expl',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get l_date_expl {
    return Intl.message('Date', name: 'l_date_expl', desc: '', args: []);
  }

  /// `Time`
  String get l_time_expl {
    return Intl.message('Time', name: 'l_time_expl', desc: '', args: []);
  }

  /// `Universal weight`
  String get l_uwgt_expl {
    return Intl.message(
      'Universal weight',
      name: 'l_uwgt_expl',
      desc: '',
      args: [],
    );
  }

  /// `Universal weight unit`
  String get l_uwu_expl {
    return Intl.message(
      'Universal weight unit',
      name: 'l_uwu_expl',
      desc: '',
      args: [],
    );
  }

  /// `UnitWeight`
  String get l_unit_wgt_expl {
    return Intl.message(
      'UnitWeight',
      name: 'l_unit_wgt_expl',
      desc: '',
      args: [],
    );
  }

  /// `Percent`
  String get l_percent_expl {
    return Intl.message('Percent', name: 'l_percent_expl', desc: '', args: []);
  }

  /// `TotalWeight`
  String get l_total_wgt_expl {
    return Intl.message(
      'TotalWeight',
      name: 'l_total_wgt_expl',
      desc: '',
      args: [],
    );
  }

  /// `TotalCount`
  String get l_total_cnt_expl {
    return Intl.message(
      'TotalCount',
      name: 'l_total_cnt_expl',
      desc: '',
      args: [],
    );
  }

  /// `TotalPcs`
  String get l_total_pcs_expl {
    return Intl.message(
      'TotalPcs',
      name: 'l_total_pcs_expl',
      desc: '',
      args: [],
    );
  }

  /// `Please select the correct print format`
  String get l_open_fmt_err {
    return Intl.message(
      'Please select the correct print format',
      name: 'l_open_fmt_err',
      desc: '',
      args: [],
    );
  }

  /// `Receipt Format`
  String get gReceiptFormat {
    return Intl.message(
      'Receipt Format',
      name: 'gReceiptFormat',
      desc: 'This is the prompt for receipt format.',
      args: [],
    );
  }

  /// `Export`
  String get batch_down_export {
    return Intl.message(
      'Export',
      name: 'batch_down_export',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get gBtnImport {
    return Intl.message('Import', name: 'gBtnImport', desc: '', args: []);
  }

  /// `Select Folder`
  String get batch_down_slt_folder {
    return Intl.message(
      'Select Folder',
      name: 'batch_down_slt_folder',
      desc: '',
      args: [],
    );
  }

  /// `Select Product Excel`
  String get gBtnSelectPluFile {
    return Intl.message(
      'Select Product Excel',
      name: 'gBtnSelectPluFile',
      desc: 'This is a button for selecting the PLU file.',
      args: [],
    );
  }

  /// `Get PLU Template`
  String get gBtnGetPluTemplate {
    return Intl.message(
      'Get PLU Template',
      name: 'gBtnGetPluTemplate',
      desc: 'This is a button for getting the product template.',
      args: [],
    );
  }

  /// `Only one PLU file can be selected`
  String get gTipSelectOnePluFile {
    return Intl.message(
      'Only one PLU file can be selected',
      name: 'gTipSelectOnePluFile',
      desc:
          'This is a prompt for only one PLU file can be selected for downloading',
      args: [],
    );
  }

  /// `Product name max length:`
  String get gPluNameLength {
    return Intl.message(
      'Product name max length:',
      name: 'gPluNameLength',
      desc: '',
      args: [],
    );
  }

  /// `Clear all then download`
  String get gTipDownloadAllPlu {
    return Intl.message(
      'Clear all then download',
      name: 'gTipDownloadAllPlu',
      desc: 'This is the prompt to clear all product data before issuing.',
      args: [],
    );
  }

  /// `Update Products`
  String get gTipUpdatePlu {
    return Intl.message(
      'Update Products',
      name: 'gTipUpdatePlu',
      desc: 'This is the prompt to update products.',
      args: [],
    );
  }

  /// `Select License File`
  String get btn_add_lic_file {
    return Intl.message(
      'Select License File',
      name: 'btn_add_lic_file',
      desc: '',
      args: [],
    );
  }

  /// `Resource Folder`
  String get output_res_folder {
    return Intl.message(
      'Resource Folder',
      name: 'output_res_folder',
      desc: '',
      args: [],
    );
  }

  /// `Select Folder`
  String get output_select_folder {
    return Intl.message(
      'Select Folder',
      name: 'output_select_folder',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm the folder name!`
  String get output_confirm_info {
    return Intl.message(
      'Please confirm the folder name!',
      name: 'output_confirm_info',
      desc: '',
      args: [],
    );
  }

  /// `No files were matched!`
  String get output_no_file {
    return Intl.message(
      'No files were matched!',
      name: 'output_no_file',
      desc: '',
      args: [],
    );
  }

  /// `Please select 1-10 print formats.`
  String get def_fmt_sel_tip {
    return Intl.message(
      'Please select 1-10 print formats.',
      name: 'def_fmt_sel_tip',
      desc: '',
      args: [],
    );
  }

  /// `Default Number`
  String get def_fmt_no_title {
    return Intl.message(
      'Default Number',
      name: 'def_fmt_no_title',
      desc: '',
      args: [],
    );
  }

  /// `File Path`
  String get def_fmt_file_title {
    return Intl.message(
      'File Path',
      name: 'def_fmt_file_title',
      desc: '',
      args: [],
    );
  }

  /// `No data yet`
  String get def_fmt_no_file_tip {
    return Intl.message(
      'No data yet',
      name: 'def_fmt_no_file_tip',
      desc: '',
      args: [],
    );
  }

  /// `The overall print format content is out of scope`
  String get def_fmt_out_range_tip {
    return Intl.message(
      'The overall print format content is out of scope',
      name: 'def_fmt_out_range_tip',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get gStatus {
    return Intl.message(
      'Status',
      name: 'gStatus',
      desc: 'This is the prompt for the scale status.',
      args: [],
    );
  }

  /// `Progress`
  String get gProgress {
    return Intl.message(
      'Progress',
      name: 'gProgress',
      desc: 'This is the prompt for the download progress.',
      args: [],
    );
  }

  /// `Refresh List`
  String get rRefreshListBtn {
    return Intl.message(
      'Refresh List',
      name: 'rRefreshListBtn',
      desc:
          'This is the name of the button for refreshing the retail list in the retail app.',
      args: [],
    );
  }

  /// `Firmware Zip:`
  String get gTipFirmwareZipFile {
    return Intl.message(
      'Firmware Zip:',
      name: 'gTipFirmwareZipFile',
      desc: 'This is the prompt for the Firmware zip file.',
      args: [],
    );
  }

  /// `Select Firmware Zip`
  String get gBtnSelectZipFirmware {
    return Intl.message(
      'Select Firmware Zip',
      name: 'gBtnSelectZipFirmware',
      desc: 'This is the button for selecting the Firmware zip file.',
      args: [],
    );
  }

  /// `Please confirm the file correct.`
  String get gConfirmFileTip {
    return Intl.message(
      'Please confirm the file correct.',
      name: 'gConfirmFileTip',
      desc:
          'This is the prompt to confirm whether the file is correct when downloading.',
      args: [],
    );
  }

  /// `Please wait...`
  String get gTipWait {
    return Intl.message(
      'Please wait...',
      name: 'gTipWait',
      desc: 'This is the prompt for waiting.',
      args: [],
    );
  }

  /// `Please reboot the device to begin update...`
  String get gTipRebootForUpdate {
    return Intl.message(
      'Please reboot the device to begin update...',
      name: 'gTipRebootForUpdate',
      desc:
          'This is the prompt restarting the device for the automatic update.',
      args: [],
    );
  }

  /// `Header`
  String get rTipHeader {
    return Intl.message(
      'Header',
      name: 'rTipHeader',
      desc: 'This is the prompt for Header.',
      args: [],
    );
  }

  /// `Footer`
  String get rTipFooter {
    return Intl.message(
      'Footer',
      name: 'rTipFooter',
      desc: 'This is the prompt for Footer.',
      args: [],
    );
  }

  /// `Operator`
  String get rTipOperator {
    return Intl.message(
      'Operator',
      name: 'rTipOperator',
      desc: 'This is the prompt for Operator.',
      args: [],
    );
  }

  /// `Data Error !`
  String get gTipDataError {
    return Intl.message(
      'Data Error !',
      name: 'gTipDataError',
      desc: 'This is the prompt for data error.',
      args: [],
    );
  }

  /// `New Format`
  String get gBtnNewFormat {
    return Intl.message(
      'New Format',
      name: 'gBtnNewFormat',
      desc: 'This is a button for creating a new printing format.',
      args: [],
    );
  }

  /// `Type:`
  String get gTipItemType {
    return Intl.message(
      'Type:',
      name: 'gTipItemType',
      desc: 'This is the name of an item type,in the printing format page.',
      args: [],
    );
  }

  /// `Save data failed !`
  String get gTipSaveFail {
    return Intl.message(
      'Save data failed !',
      name: 'gTipSaveFail',
      desc: 'This is the prompt for saving flie failed.',
      args: [],
    );
  }

  /// `PLU`
  String get gPluPlu {
    return Intl.message(
      'PLU',
      name: 'gPluPlu',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Product Code`
  String get gPluPluCode {
    return Intl.message(
      'Product Code',
      name: 'gPluPluCode',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Item Code`
  String get gPluItemCode {
    return Intl.message(
      'Item Code',
      name: 'gPluItemCode',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Category`
  String get gPluCategory {
    return Intl.message(
      'Category',
      name: 'gPluCategory',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Product Name`
  String get gPluPluName {
    return Intl.message(
      'Product Name',
      name: 'gPluPluName',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Unit`
  String get gPluWgtUnit {
    return Intl.message(
      'Unit',
      name: 'gPluWgtUnit',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Tax Type`
  String get gPluTaxType {
    return Intl.message(
      'Tax Type',
      name: 'gPluTaxType',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Price`
  String get gPluPrice {
    return Intl.message(
      'Price',
      name: 'gPluPrice',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Unit Weight`
  String get gPluUnitWgt {
    return Intl.message(
      'Unit Weight',
      name: 'gPluUnitWgt',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Pretare`
  String get gPluPretare {
    return Intl.message(
      'Pretare',
      name: 'gPluPretare',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Limit High`
  String get gPluLimitHigh {
    return Intl.message(
      'Limit High',
      name: 'gPluLimitHigh',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Limit Low`
  String get gPluLimitLow {
    return Intl.message(
      'Limit Low',
      name: 'gPluLimitLow',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `PLU Field`
  String get gPluField {
    return Intl.message(
      'PLU Field',
      name: 'gPluField',
      desc: 'This is prompt for PLU field select.',
      args: [],
    );
  }

  /// `Weight`
  String get gRptWeight {
    return Intl.message(
      'Weight',
      name: 'gRptWeight',
      desc: 'This is the prompt regarding weight in the report.',
      args: [],
    );
  }

  /// `Weight Unit`
  String get gRptWeightUnit {
    return Intl.message(
      'Weight Unit',
      name: 'gRptWeightUnit',
      desc: 'This is the prompt regarding weight unit in the report.',
      args: [],
    );
  }

  /// `Date Time`
  String get gRptDateTime {
    return Intl.message(
      'Date Time',
      name: 'gRptDateTime',
      desc: 'This is the prompt regarding date time in the report.',
      args: [],
    );
  }

  /// `Note: When the cell is empty, it will be written as 0 or - .`
  String get gTipImportPluOK {
    return Intl.message(
      'Note: When the cell is empty, it will be written as 0 or - .',
      name: 'gTipImportPluOK',
      desc: 'This is prompt for PLU import.',
      args: [],
    );
  }

  /// `No data`
  String get gTipNoData {
    return Intl.message(
      'No data',
      name: 'gTipNoData',
      desc: 'This is prompt for no data.',
      args: [],
    );
  }

  /// `No data selected.`
  String get gTipNoDataSelected {
    return Intl.message(
      'No data selected.',
      name: 'gTipNoDataSelected',
      desc: 'This is prompt for no data selected.',
      args: [],
    );
  }

  /// `Duplicated`
  String get gTipPluDuplicated {
    return Intl.message(
      'Duplicated',
      name: 'gTipPluDuplicated',
      desc: 'This is prompt for plu duplicated.',
      args: [],
    );
  }

  /// `Install Service`
  String get gTipInstallService {
    return Intl.message(
      'Install Service',
      name: 'gTipInstallService',
      desc: 'This is prompt to install service.',
      args: [],
    );
  }

  /// `Start Service`
  String get gTipStartService {
    return Intl.message(
      'Start Service',
      name: 'gTipStartService',
      desc: 'This is prompt to start service.',
      args: [],
    );
  }

  /// `Stop Service`
  String get gTipStopService {
    return Intl.message(
      'Stop Service',
      name: 'gTipStopService',
      desc: 'This is prompt to stop service.',
      args: [],
    );
  }

  /// `Uninstall Service`
  String get gTipUninstallService {
    return Intl.message(
      'Uninstall Service',
      name: 'gTipUninstallService',
      desc: 'This is prompt to uninstall service.',
      args: [],
    );
  }

  /// `Service Status:`
  String get gTipServiceStatus {
    return Intl.message(
      'Service Status:',
      name: 'gTipServiceStatus',
      desc: 'This is prompt for service status.',
      args: [],
    );
  }

  /// `Service not installed`
  String get gTipServiceUninstalled {
    return Intl.message(
      'Service not installed',
      name: 'gTipServiceUninstalled',
      desc: 'This is prompt for service status.',
      args: [],
    );
  }

  /// `Service Stoped`
  String get gTipServiceStoped {
    return Intl.message(
      'Service Stoped',
      name: 'gTipServiceStoped',
      desc: 'This is prompt for service status.',
      args: [],
    );
  }

  /// `Service is running`
  String get gTipServiceStarted {
    return Intl.message(
      'Service is running',
      name: 'gTipServiceStarted',
      desc: 'This is prompt for service status.',
      args: [],
    );
  }

  /// `Connection lost. Restart app/service..`
  String get gTipServiceOff {
    return Intl.message(
      'Connection lost. Restart app/service..',
      name: 'gTipServiceOff',
      desc: 'This is prompt for service stoped.',
      args: [],
    );
  }

  /// `Modify`
  String get gBtnModify {
    return Intl.message(
      'Modify',
      name: 'gBtnModify',
      desc:
          'This button is used for modifying serial ports or performing other operations.',
      args: [],
    );
  }

  /// `Are you sure to exit the system?`
  String get gTipExitApp {
    return Intl.message(
      'Are you sure to exit the system?',
      name: 'gTipExitApp',
      desc: 'This is prompt to exit the system.',
      args: [],
    );
  }

  /// `Close Port`
  String get gBtnCloseSerialPort {
    return Intl.message(
      'Close Port',
      name: 'gBtnCloseSerialPort',
      desc: 'This is a button to close serial port.',
      args: [],
    );
  }

  /// `Open Port`
  String get gBtnOpenSerialPort {
    return Intl.message(
      'Open Port',
      name: 'gBtnOpenSerialPort',
      desc: 'This is a button to open serial port.',
      args: [],
    );
  }

  /// `Weighing Count`
  String get cTipWeighingCount {
    return Intl.message(
      'Weighing Count',
      name: 'cTipWeighingCount',
      desc: 'This is a tip for weighing count.',
      args: [],
    );
  }

  /// `Abnormal Power-Off Count`
  String get cTipPowerOffCnt {
    return Intl.message(
      'Abnormal Power-Off Count',
      name: 'cTipPowerOffCnt',
      desc: 'This is a tip for abnormal power-off count.',
      args: [],
    );
  }

  /// `Running Time(mins)`
  String get cTipRunningTime {
    return Intl.message(
      'Running Time(mins)',
      name: 'cTipRunningTime',
      desc: 'This is a tip for running time.',
      args: [],
    );
  }

  /// `Power-On Count`
  String get cTipPowerOnCnt {
    return Intl.message(
      'Power-On Count',
      name: 'cTipPowerOnCnt',
      desc: 'This is a tip for power-on count.',
      args: [],
    );
  }

  /// `OL Time(mins)`
  String get cTipOlTime {
    return Intl.message(
      'OL Time(mins)',
      name: 'cTipOlTime',
      desc: 'This is a tip for ol time.',
      args: [],
    );
  }

  /// `UL Time(mins)`
  String get cTipUlTime {
    return Intl.message(
      'UL Time(mins)',
      name: 'cTipUlTime',
      desc: 'This is a tip for ul time.',
      args: [],
    );
  }

  /// `Err4 Count`
  String get cTipErr4Cnt {
    return Intl.message(
      'Err4 Count',
      name: 'cTipErr4Cnt',
      desc: 'This is a tip for err4 count.',
      args: [],
    );
  }

  /// `Err19 Count`
  String get cTipErr19Cnt {
    return Intl.message(
      'Err19 Count',
      name: 'cTipErr19Cnt',
      desc: 'This is a tip for err19 count.',
      args: [],
    );
  }

  /// `Calibration Switch Count`
  String get cTipCalswitchCnt {
    return Intl.message(
      'Calibration Switch Count',
      name: 'cTipCalswitchCnt',
      desc: 'This is a tip for cal switch count.',
      args: [],
    );
  }

  /// `Calibration Count`
  String get cTipCalCnt {
    return Intl.message(
      'Calibration Count',
      name: 'cTipCalCnt',
      desc: 'This is a tip for calibration count.',
      args: [],
    );
  }

  /// `High/Low Setting`
  String get iTitleHLSetting {
    return Intl.message(
      'High/Low Setting',
      name: 'iTitleHLSetting',
      desc: 'This is the title for the upper and lower limits setting.',
      args: [],
    );
  }

  /// `The unit of weight is the same as scale..`
  String get iTipHLUnit {
    return Intl.message(
      'The unit of weight is the same as scale..',
      name: 'iTipHLUnit',
      desc: 'This is a prompt for the unit of checking weight.',
      args: [],
    );
  }

  /// `Help`
  String get gTipHelp {
    return Intl.message(
      'Help',
      name: 'gTipHelp',
      desc: 'This is a tip for help info.',
      args: [],
    );
  }

  /// `Connect via serial port\n1. Connect the scale to the PC device with a serial port cable;\n2. Enter the correct serial port information;\n3. Click [Connect];\n4. If the connection is successful,the left status bar will display Online.\n5. Click [Close Port] to disconnect the serial port connection; Click [Open Port] to open the serial port connection;\n6. If you want to change the scale name, click [Rename] to enter it and click [Confirm].\n\nConnect via Ethernet/Wi-Fi\n1. Click [+] at the top of the left status bar;\n2. Enter the IPv4 (IP Address) and Port (Port Number);\n3. Click [Confirm] to complete the connection.\n\n  (1) Get IP Address\nWi-Fi: Click [Wi-Fi Setting] on the main interface, select the Wi-Fi you want to connect to in the left column, enter the password and click [Connect]. If the connection is successful, the IP Address will be displayed.\nEthernet: After connecting the network cable, enter the scale menu to get the IP Address. (For T-Max, F3-3 COM3 SHOW.)\n  (2) Get Port Number\nWi-Fi: Enter the scale menu to get. (For T-Max, F3-2 COM2 MODE, press the TARE key three times to view the port number.)\nEthernet: Enter the scale menu to get. (For T-Max, F3-3 COM3 PORT, press the TARE key once to view the port number.)\n\nNote:\nTo use Wi-Fi connection, you need to turn on the scale's Wi-Fi function and connect the device running the software to the target Wi-Fi as well.\nTo use Ethernet connection, you need to turn on the network port function of the scale and connect the device running the software to the target Wi-Fi as well.\n`
  String get gTipScaleMgrPageHelp {
    return Intl.message(
      'Connect via serial port\n1. Connect the scale to the PC device with a serial port cable;\n2. Enter the correct serial port information;\n3. Click [Connect];\n4. If the connection is successful,the left status bar will display Online.\n5. Click [Close Port] to disconnect the serial port connection; Click [Open Port] to open the serial port connection;\n6. If you want to change the scale name, click [Rename] to enter it and click [Confirm].\n\nConnect via Ethernet/Wi-Fi\n1. Click [+] at the top of the left status bar;\n2. Enter the IPv4 (IP Address) and Port (Port Number);\n3. Click [Confirm] to complete the connection.\n\n  (1) Get IP Address\nWi-Fi: Click [Wi-Fi Setting] on the main interface, select the Wi-Fi you want to connect to in the left column, enter the password and click [Connect]. If the connection is successful, the IP Address will be displayed.\nEthernet: After connecting the network cable, enter the scale menu to get the IP Address. (For T-Max, F3-3 COM3 SHOW.)\n  (2) Get Port Number\nWi-Fi: Enter the scale menu to get. (For T-Max, F3-2 COM2 MODE, press the TARE key three times to view the port number.)\nEthernet: Enter the scale menu to get. (For T-Max, F3-3 COM3 PORT, press the TARE key once to view the port number.)\n\nNote:\nTo use Wi-Fi connection, you need to turn on the scale\'s Wi-Fi function and connect the device running the software to the target Wi-Fi as well.\nTo use Ethernet connection, you need to turn on the network port function of the scale and connect the device running the software to the target Wi-Fi as well.\n',
      name: 'gTipScaleMgrPageHelp',
      desc: 'This is the help info for the multi-scale management page.',
      args: [],
    );
  }

  /// `1. Select the Wi-Fi you want to connect to from the left menu bar;\n2. Enter the password and click [Connect] to obtain the IP address;\n3. Return to the main interface and enter [Multi-scale Management];\n4. Click [+] at the top of the left status bar, enter the IP address and serial port number;\n5. Click [Confirm] to connect.\n`
  String get gTipWifiSettingPageHelp {
    return Intl.message(
      '1. Select the Wi-Fi you want to connect to from the left menu bar;\n2. Enter the password and click [Connect] to obtain the IP address;\n3. Return to the main interface and enter [Multi-scale Management];\n4. Click [+] at the top of the left status bar, enter the IP address and serial port number;\n5. Click [Confirm] to connect.\n',
      name: 'gTipWifiSettingPageHelp',
      desc: 'This is the help info for the wifi setting page.',
      args: [],
    );
  }

  /// `1. Click [Select Firmware Zip] to upload the file(.zip);\n2. Click [Download];\n3. Select the way to update the firmware: Serial Port or Network(Wi-Fi, Ethernet).\n\nNote: \nUpdate via serial port , the scale will automatically restart;\nUpdate via Wi-Fi or Ethernet, the scale will not automatically restart. You need to manually restart the scale, and the firmware will update. (This method supports selecting multi-scales to update together.)\n`
  String get gTipUpdateFirmwarePageHelp {
    return Intl.message(
      '1. Click [Select Firmware Zip] to upload the file(.zip);\n2. Click [Download];\n3. Select the way to update the firmware: Serial Port or Network(Wi-Fi, Ethernet).\n\nNote: \nUpdate via serial port , the scale will automatically restart;\nUpdate via Wi-Fi or Ethernet, the scale will not automatically restart. You need to manually restart the scale, and the firmware will update. (This method supports selecting multi-scales to update together.)\n',
      name: 'gTipUpdateFirmwarePageHelp',
      desc: 'This is the help info for the update firmware page.',
      args: [],
    );
  }

  /// `1. Follow the prompts to select the corresponding print format for uploading;\n2. Click [Download] to download the format(.fmt);\n3. If multiple networks are connected, you need to select the corresponding network before downloading.\n`
  String get gTipReceiptFmtDownPageHelp {
    return Intl.message(
      '1. Follow the prompts to select the corresponding print format for uploading;\n2. Click [Download] to download the format(.fmt);\n3. If multiple networks are connected, you need to select the corresponding network before downloading.\n',
      name: 'gTipReceiptFmtDownPageHelp',
      desc: 'This is the help info for the receipt format download page.',
      args: [],
    );
  }

  /// `1. Select printer protocol, length and width of the ticket, printing direction and other information;\n2. When editing the print format, there are 4 variables to choose from in the left menu bar;\n Free Text: Text variables that can be freely inputted\n Dividing Line: A horizontal line used for segmentation (after selecting this variable twice, the content in the middle of the variable can appear repeatedly, such as the accumulated content each time)\n Variable: Variables required for weighing scales\n Price Variable: Variables required for the price computing scale\n3. After editing the format, click [Save Format] to save the print format.\n\nNote:\n The weighing scale and pricing scale cannot use the wrong variable, otherwise the printed output will be empty.\n`
  String get gTipReceiptDesignPageHelp {
    return Intl.message(
      '1. Select printer protocol, length and width of the ticket, printing direction and other information;\n2. When editing the print format, there are 4 variables to choose from in the left menu bar;\n Free Text: Text variables that can be freely inputted\n Dividing Line: A horizontal line used for segmentation (after selecting this variable twice, the content in the middle of the variable can appear repeatedly, such as the accumulated content each time)\n Variable: Variables required for weighing scales\n Price Variable: Variables required for the price computing scale\n3. After editing the format, click [Save Format] to save the print format.\n\nNote:\n The weighing scale and pricing scale cannot use the wrong variable, otherwise the printed output will be empty.\n',
      name: 'gTipReceiptDesignPageHelp',
      desc: 'This is the help info for the Receipt Design page.',
      args: [],
    );
  }

  /// `1. Create a new PLU: Click [+] to create a default data PLU.\n2. Import PLU: Click [Import] to select the data sheet, and all PLU data in the sheet will be displayed.\n3. Import PLU from the database: Click [Get Data From DB] will display all PLU data in the database.\n\nNote: \nThe PLU in the database is not the PLU on the scale, but the database in the software backend. The software currently does not have the function to read PLU information from the scale.\n4. Click the [Setting button] to select the PLU information that needs to be displayed.\n5. If you need to modify PLU information, you can directly modify it in the corresponding cell. (Hovering over a cell will display the range of parameters that can be entered.)\n6. Select the PLU to be download and click [Download].\n7. Choose to clear all PLUs on the scale before downloading, or update the corresponding PLUs, and then click [Confirm].\n8. Export in sheet format: Select the PLU to export, click [Export] and choose the folder to export.\n9. Save to backend database: Select the PLU that needs to be saved and then click [Save to DB], choose to clear all PLUs in the backend database before saving, or update the corresponding PLUs, click [Confirm].\n10. Get PLU Template: Click [Get PLU Template] and select the download path to obtain a form template that can be filled out with PLU.\n`
  String get gTipPlueditPageHelp {
    return Intl.message(
      '1. Create a new PLU: Click [+] to create a default data PLU.\n2. Import PLU: Click [Import] to select the data sheet, and all PLU data in the sheet will be displayed.\n3. Import PLU from the database: Click [Get Data From DB] will display all PLU data in the database.\n\nNote: \nThe PLU in the database is not the PLU on the scale, but the database in the software backend. The software currently does not have the function to read PLU information from the scale.\n4. Click the [Setting button] to select the PLU information that needs to be displayed.\n5. If you need to modify PLU information, you can directly modify it in the corresponding cell. (Hovering over a cell will display the range of parameters that can be entered.)\n6. Select the PLU to be download and click [Download].\n7. Choose to clear all PLUs on the scale before downloading, or update the corresponding PLUs, and then click [Confirm].\n8. Export in sheet format: Select the PLU to export, click [Export] and choose the folder to export.\n9. Save to backend database: Select the PLU that needs to be saved and then click [Save to DB], choose to clear all PLUs in the backend database before saving, or update the corresponding PLUs, click [Confirm].\n10. Get PLU Template: Click [Get PLU Template] and select the download path to obtain a form template that can be filled out with PLU.\n',
      name: 'gTipPlueditPageHelp',
      desc: 'This is the help info for the plu edit page.',
      args: [],
    );
  }

  /// `1. This function interface can display the data printed after each checkout;\nIf the service is not installed, you need to click [Service] on the right and click [Install Service]; When prompted that the service has stopped, click [Start Service] and it will prompt that it is running. Finally, click [Confirm] to complete the process;\n2. After the balance is printed, the printing content of each order will be displayed on this interface, click [Refresh List] and you can get the latest records;\n3. Click [Export] and you can download the report.\n\nNote: \nThis function can be used via Ethernet / WiFi, and cannot be used via serial port.`
  String get gTipRetailDetailPageHelp {
    return Intl.message(
      '1. This function interface can display the data printed after each checkout;\nIf the service is not installed, you need to click [Service] on the right and click [Install Service]; When prompted that the service has stopped, click [Start Service] and it will prompt that it is running. Finally, click [Confirm] to complete the process;\n2. After the balance is printed, the printing content of each order will be displayed on this interface, click [Refresh List] and you can get the latest records;\n3. Click [Export] and you can download the report.\n\nNote: \nThis function can be used via Ethernet / WiFi, and cannot be used via serial port.',
      name: 'gTipRetailDetailPageHelp',
      desc: 'This is the help info for the retail detail report page.',
      args: [],
    );
  }

  /// `1. Click [Set Date/Time].\n2. Manually set or synchronize the date and time of the PC device.\n`
  String get gTipDeviceTimePageHelp {
    return Intl.message(
      '1. Click [Set Date/Time].\n2. Manually set or synchronize the date and time of the PC device.\n',
      name: 'gTipDeviceTimePageHelp',
      desc: 'This is the help info for the device time setting page.',
      args: [],
    );
  }

  /// `1. Follow the prompts to select the corresponding print format for uploading;\n2. Click [Download] to download the format(.fmt);\n3. If multiple networks are connected, you need to select the corresponding network before downloading.\n`
  String get gTipLabelFmtDownPageHelp {
    return Intl.message(
      '1. Follow the prompts to select the corresponding print format for uploading;\n2. Click [Download] to download the format(.fmt);\n3. If multiple networks are connected, you need to select the corresponding network before downloading.\n',
      name: 'gTipLabelFmtDownPageHelp',
      desc: 'This is the help info for the label format download page.',
      args: [],
    );
  }

  /// `1. Select printer protocol, length and width of the ticket, printing direction and other information;\n2. When editing the print format, there are 4 variables to choose from in the left menu bar: Free Text, BarCode Variable, QrCode Variable, Variable;\n3. BarCode Edit: Click [BarCode Edit] and then Click [Add]; Select format information such as data type, content, length, etc; Enter the format name and click [Save]; You can select the edited barcode format from the left menu bar.\n4. Qrcode Edit: Same as Barcode.\n5. After editing the format, click [Save Format] to save the print format.\n`
  String get gTipLabelDesignPageHelp {
    return Intl.message(
      '1. Select printer protocol, length and width of the ticket, printing direction and other information;\n2. When editing the print format, there are 4 variables to choose from in the left menu bar: Free Text, BarCode Variable, QrCode Variable, Variable;\n3. BarCode Edit: Click [BarCode Edit] and then Click [Add]; Select format information such as data type, content, length, etc; Enter the format name and click [Save]; You can select the edited barcode format from the left menu bar.\n4. Qrcode Edit: Same as Barcode.\n5. After editing the format, click [Save Format] to save the print format.\n',
      name: 'gTipLabelDesignPageHelp',
      desc: 'This is the help info for the label design page.',
      args: [],
    );
  }

  /// `1. The top menu bar has modes such as weighing, counting, price computing, etc, which can be edited by selecting different modes based on the connected scale;\n2. The left menu bar is for variables, which can be selected according to your needs;\n3. You can click [Open Review] to preview the output results;\n4. After editing the format, click [Download]. Once successful, use the serial port tool to test it.\n\nNote: \nThis function can only be used in serial port connection mode.\n`
  String get gTipSerialDesignPageHelp {
    return Intl.message(
      '1. The top menu bar has modes such as weighing, counting, price computing, etc, which can be edited by selecting different modes based on the connected scale;\n2. The left menu bar is for variables, which can be selected according to your needs;\n3. You can click [Open Review] to preview the output results;\n4. After editing the format, click [Download]. Once successful, use the serial port tool to test it.\n\nNote: \nThis function can only be used in serial port connection mode.\n',
      name: 'gTipSerialDesignPageHelp',
      desc: 'This is the help info for the derial output design page.',
      args: [],
    );
  }

  /// `1. Click [Get Basic Data];\n2. T-Config will automatically collect basic data from the scale and display it synchronously on the interface.\n3. You can click the menu bar button in the upper left corner to select the device you want to switch to.`
  String get gTipBasicDataPageHelp {
    return Intl.message(
      '1. Click [Get Basic Data];\n2. T-Config will automatically collect basic data from the scale and display it synchronously on the interface.\n3. You can click the menu bar button in the upper left corner to select the device you want to switch to.',
      name: 'gTipBasicDataPageHelp',
      desc: 'This is the help info for the basic data page.',
      args: [],
    );
  }

  /// `1. The condition is that there must be weight on the scale. Click [Start] to activate take out scale function. (Only record the decrement of the weighing value during unloading.)\n2. Click [Save] to save the current weighing record;\n3. Click [Show Reports] to display the report;\n4. Click [Setting] to set automatic saving.\n5. In [Setting], you can also set the date format and delimiter for data export;\n6. Enter the PLU number or name in the PLU Name column to call the PLU in the backend database; (The PLU here is not the PLU on the scale)\n7. Click [Report Setting] to select the information displayed for weighing data; (Currently, there are no functional variables available: Product Code, Item Code, User Name, User NO）\n8. Click the arrow in a column of the report title row will sort the report in ascending/descending order.\n9.Click [Export] to export all saved data (xlsx).\n10.Click [End] to stop the function.\n\nNote: \nThe weight in the report refers to the decrement rather than all the weight on the scale.\n`
  String get gTipTakeOutPageHelp {
    return Intl.message(
      '1. The condition is that there must be weight on the scale. Click [Start] to activate take out scale function. (Only record the decrement of the weighing value during unloading.)\n2. Click [Save] to save the current weighing record;\n3. Click [Show Reports] to display the report;\n4. Click [Setting] to set automatic saving.\n5. In [Setting], you can also set the date format and delimiter for data export;\n6. Enter the PLU number or name in the PLU Name column to call the PLU in the backend database; (The PLU here is not the PLU on the scale)\n7. Click [Report Setting] to select the information displayed for weighing data; (Currently, there are no functional variables available: Product Code, Item Code, User Name, User NO）\n8. Click the arrow in a column of the report title row will sort the report in ascending/descending order.\n9.Click [Export] to export all saved data (xlsx).\n10.Click [End] to stop the function.\n\nNote: \nThe weight in the report refers to the decrement rather than all the weight on the scale.\n',
      name: 'gTipTakeOutPageHelp',
      desc: 'This is the help info for the take out scale page.',
      args: [],
    );
  }

  /// `1. Click [Start] to activate increment weighing function. (Only record the increment of the weighing value during loading.)\n2. Click [Save] to save the current weighing record;\n3. Click [Show Reports] to display the report;\n4. Click [Setting] to set automatic saving.\n5. You can also set the date format and delimiter for data export;\n6. Enter the PLU number or name in the PLU Name column to call the PLU in the backend database; (The PLU here is not the PLU on the scale)\n7. Click [Report Setting] to select the information displayed for weighing data; (Currently, there are no functional variables available: Product Code, Item Code, User Name, User NO）\n8. Click the arrow in a column of the report title row will sort the report in ascending/descending order.\n9.Click [Export] to export all saved data (xlsx).\n10.Click [End] to stop the function.\n\nNote: \nThe weight in the report refers to the increment rather than all the weight on the scale.\n`
  String get gTipIncrementWgtPageHelp {
    return Intl.message(
      '1. Click [Start] to activate increment weighing function. (Only record the increment of the weighing value during loading.)\n2. Click [Save] to save the current weighing record;\n3. Click [Show Reports] to display the report;\n4. Click [Setting] to set automatic saving.\n5. You can also set the date format and delimiter for data export;\n6. Enter the PLU number or name in the PLU Name column to call the PLU in the backend database; (The PLU here is not the PLU on the scale)\n7. Click [Report Setting] to select the information displayed for weighing data; (Currently, there are no functional variables available: Product Code, Item Code, User Name, User NO）\n8. Click the arrow in a column of the report title row will sort the report in ascending/descending order.\n9.Click [Export] to export all saved data (xlsx).\n10.Click [End] to stop the function.\n\nNote: \nThe weight in the report refers to the increment rather than all the weight on the scale.\n',
      name: 'gTipIncrementWgtPageHelp',
      desc: 'This is the help info for the increment weighing page.',
      args: [],
    );
  }

  /// `1. Click [Edit] to set the upper and lower limits (the judgment is based on the upper and lower limits set in the background, not on the scale). After setting, place the weight and the corresponding alarm light will light up;\n2. Click [Save] to save the current weighing record;\n3. Click [Show Reports] to display the report;\n4. Click [Setting] to set automatic saving. (Can be set to save when OK, HIGH, LOW, ALL.)\n5. You can also set the date format and delimiter for data export;\n6. Enter the PLU number or name in the [PLU Name] column to call the PLU in the backend database; (The PLU here is not the PLU on the scale)\n7. Click [Report Setting] to select the information displayed for weighing data; (Currently, there are no functional variables available: Product Code, Item Code, User Name, User NO）\n8. Click the arrow in a column of the report title row will sort the report in ascending/descending order.\n9.Click [Export] to export all saved data (xlsx).\n\nNote:\n1. The units for the upper and lower limits are the currently selected units on the scale. After setting the upper and lower limits in the software, the values of the upper and lower limits will not undergo unit conversion when switching units through the scale.\n2. At present, the software determines the upper and lower limits from zero, while on the scale, it starts from 20d.\n`
  String get gTipCheckWgtPageHelp {
    return Intl.message(
      '1. Click [Edit] to set the upper and lower limits (the judgment is based on the upper and lower limits set in the background, not on the scale). After setting, place the weight and the corresponding alarm light will light up;\n2. Click [Save] to save the current weighing record;\n3. Click [Show Reports] to display the report;\n4. Click [Setting] to set automatic saving. (Can be set to save when OK, HIGH, LOW, ALL.)\n5. You can also set the date format and delimiter for data export;\n6. Enter the PLU number or name in the [PLU Name] column to call the PLU in the backend database; (The PLU here is not the PLU on the scale)\n7. Click [Report Setting] to select the information displayed for weighing data; (Currently, there are no functional variables available: Product Code, Item Code, User Name, User NO）\n8. Click the arrow in a column of the report title row will sort the report in ascending/descending order.\n9.Click [Export] to export all saved data (xlsx).\n\nNote:\n1. The units for the upper and lower limits are the currently selected units on the scale. After setting the upper and lower limits in the software, the values of the upper and lower limits will not undergo unit conversion when switching units through the scale.\n2. At present, the software determines the upper and lower limits from zero, while on the scale, it starts from 20d.\n',
      name: 'gTipCheckWgtPageHelp',
      desc: 'This is the help info for the check weighing page.',
      args: [],
    );
  }

  /// `1. Click [Save] to manually save the current weighing data (with no quantity limit); Click [Export] to export all saved data (xlsx);\n2. Click [Setting] and select Save Mode to Auto, it can be set to auto save mode;\n3. You can also set the date format and delimiter for data export;\n4. Enter the PLU number or name in the PLU Name column to call the PLU in the backend database; (The PLU here is not the PLU on the scale)\n5. Click [Report Setting] to select the information displayed for weighing data; (Currently, there are no functional variables available: Product Code、Item Code、User Name、User NO）\n6. Click the arrow in column of the report title row will sort the report in ascending/descending order.\n\nNote: \n1. To save data, you need to clear the scale before saving the next transaction. Zero point will not be saved.\n2. The upper and lower limit variables are the upper and lower limits set in the backend PLU, not the upper and lower limits set on the scale.\n3. The saved data will not be cleared after closing/restarting the software.\n`
  String get gTipWgtDataCollectionHelp {
    return Intl.message(
      '1. Click [Save] to manually save the current weighing data (with no quantity limit); Click [Export] to export all saved data (xlsx);\n2. Click [Setting] and select Save Mode to Auto, it can be set to auto save mode;\n3. You can also set the date format and delimiter for data export;\n4. Enter the PLU number or name in the PLU Name column to call the PLU in the backend database; (The PLU here is not the PLU on the scale)\n5. Click [Report Setting] to select the information displayed for weighing data; (Currently, there are no functional variables available: Product Code、Item Code、User Name、User NO）\n6. Click the arrow in column of the report title row will sort the report in ascending/descending order.\n\nNote: \n1. To save data, you need to clear the scale before saving the next transaction. Zero point will not be saved.\n2. The upper and lower limit variables are the upper and lower limits set in the backend PLU, not the upper and lower limits set on the scale.\n3. The saved data will not be cleared after closing/restarting the software.\n',
      name: 'gTipWgtDataCollectionHelp',
      desc: 'This is the help info for the weighing data collection page.',
      args: [],
    );
  }

  /// `1. Real time display of weighing data on the scale (supporting all units including PCS and PCT);\n2. Click [TARE] and [ZERO] allows for weighing and zeroing operations on the scale;\n3. Click the List button in the upper left corner to view the list of connected devices and make changes.\n\nNote：\n1.This function can be used by connecting to a serial port, Ethernet, or WiFi.\n2.Switching units is done on the scale.\n`
  String get gTipWeighingPageHelp {
    return Intl.message(
      '1. Real time display of weighing data on the scale (supporting all units including PCS and PCT);\n2. Click [TARE] and [ZERO] allows for weighing and zeroing operations on the scale;\n3. Click the List button in the upper left corner to view the list of connected devices and make changes.\n\nNote：\n1.This function can be used by connecting to a serial port, Ethernet, or WiFi.\n2.Switching units is done on the scale.\n',
      name: 'gTipWeighingPageHelp',
      desc: 'This is the help info for the weighing page.',
      args: [],
    );
  }

  /// `1.In the Ingredients List, click [+] to add a new ingredient. Enter the ID, Name, Category, and Description, then click [Confirm].\n 2.Click on a ingredient to view all Formulas that use it. Further click to see detailed formula information.\n 3.In the Formula List, click [+] to create a new formula and enter its details.\n 4.If the total weight of the formula is fixed, select the "Weight" mode, where each ingredient is set with a fixed weight.\n 5.If the total weight is variable, select the "Percentage" mode, where each ingredient is set by ratio. The total ratio must add up to 100% before saving the formula.\n 6.In the Formula List, select the desired formula and click [Start Dosing].\n 7.The software will guide you step-by-step, indicating which ingredient to weigh. When the weight falls within the allowed error range, click [Next] until dosing is complete.\n 8.If a ingredient is overweight, the software will prompt you to either discard dosing or adjust the formula.\n 9.Discard dosing: Clears the data and returns to the Formula List.\n 10.Adjust formula: Resets to the first ingredient, allowing you to add the required weight as prompted until all dosing is completed.\n 11.In the Formula List, you can view all dosing records or records for a single formula, with the option to export them.\n \n Note: If a formula is set to "Confidential", the operator will only see a progress bar for each ingredient during dosing—not the actual weight. The system will guide dosing speed based on the allowed error range.`
  String get gTipFmaPageHelp {
    return Intl.message(
      '1.In the Ingredients List, click [+] to add a new ingredient. Enter the ID, Name, Category, and Description, then click [Confirm].\n 2.Click on a ingredient to view all Formulas that use it. Further click to see detailed formula information.\n 3.In the Formula List, click [+] to create a new formula and enter its details.\n 4.If the total weight of the formula is fixed, select the "Weight" mode, where each ingredient is set with a fixed weight.\n 5.If the total weight is variable, select the "Percentage" mode, where each ingredient is set by ratio. The total ratio must add up to 100% before saving the formula.\n 6.In the Formula List, select the desired formula and click [Start Dosing].\n 7.The software will guide you step-by-step, indicating which ingredient to weigh. When the weight falls within the allowed error range, click [Next] until dosing is complete.\n 8.If a ingredient is overweight, the software will prompt you to either discard dosing or adjust the formula.\n 9.Discard dosing: Clears the data and returns to the Formula List.\n 10.Adjust formula: Resets to the first ingredient, allowing you to add the required weight as prompted until all dosing is completed.\n 11.In the Formula List, you can view all dosing records or records for a single formula, with the option to export them.\n \n Note: If a formula is set to "Confidential", the operator will only see a progress bar for each ingredient during dosing—not the actual weight. The system will guide dosing speed based on the allowed error range.',
      name: 'gTipFmaPageHelp',
      desc: 'This is the help info for the formula management page.',
      args: [],
    );
  }

  /// `1.Place the container on the weighing pan, and after the weight stabilizes, click [Tare].\n2.Click [Start] and pour the liquid into the container.\n3.After completion, click [End]. The software will automatically generate the liquid filling speed changes during this process and analyze the total weight, total time, average speed, maximum speed, and minimum speed.\n4.Click [Show Data Table] to view the liquid filling speed at each moment.\n5.Select the record you want to export and click [Export] to download the data locally.\n\nNote: If there is no weight change for more than 3 seconds during the liquid pouring process, the software will automatically end and generate a record.`
  String get gTipFlowRatePageHelp {
    return Intl.message(
      '1.Place the container on the weighing pan, and after the weight stabilizes, click [Tare].\n2.Click [Start] and pour the liquid into the container.\n3.After completion, click [End]. The software will automatically generate the liquid filling speed changes during this process and analyze the total weight, total time, average speed, maximum speed, and minimum speed.\n4.Click [Show Data Table] to view the liquid filling speed at each moment.\n5.Select the record you want to export and click [Export] to download the data locally.\n\nNote: If there is no weight change for more than 3 seconds during the liquid pouring process, the software will automatically end and generate a record.',
      name: 'gTipFlowRatePageHelp',
      desc: 'This is the help info for the formula management page.',
      args: [],
    );
  }

  /// `Formula List`
  String get fFmaListTab {
    return Intl.message(
      'Formula List',
      name: 'fFmaListTab',
      desc: 'Tab label for formula list',
      args: [],
    );
  }

  /// `Ingredient List`
  String get fRawMaterialListTab {
    return Intl.message(
      'Ingredient List',
      name: 'fRawMaterialListTab',
      desc: 'Tab label for raw material list',
      args: [],
    );
  }

  /// `ID or Name`
  String get fSearchHint {
    return Intl.message(
      'ID or Name',
      name: 'fSearchHint',
      desc: 'Hint text for search input',
      args: [],
    );
  }

  /// `Category`
  String get fPleaseSelectCategory {
    return Intl.message(
      'Category',
      name: 'fPleaseSelectCategory',
      desc: 'Placeholder for category dropdown',
      args: [],
    );
  }

  /// `Add Formula`
  String get fAddFmaBtn {
    return Intl.message(
      'Add Formula',
      name: 'fAddFmaBtn',
      desc: 'Button to add a new formula',
      args: [],
    );
  }

  /// `Edit Formula`
  String get fEditFmaBtn {
    return Intl.message(
      'Edit Formula',
      name: 'fEditFmaBtn',
      desc: 'Button to edit a old formula',
      args: [],
    );
  }

  /// `Records`
  String get fHistoricalWeighingRecordsBtn {
    return Intl.message(
      'Records',
      name: 'fHistoricalWeighingRecordsBtn',
      desc: 'Button to view historical weighing records',
      args: [],
    );
  }

  /// `Get Formula Template`
  String get fGetFmaTemplateBtn {
    return Intl.message(
      'Get Formula Template',
      name: 'fGetFmaTemplateBtn',
      desc: 'Button to get formula template',
      args: [],
    );
  }

  /// `Get Ingredient Template`
  String get fGetRawTemplateBtn {
    return Intl.message(
      'Get Ingredient Template',
      name: 'fGetRawTemplateBtn',
      desc: 'Button to get ingredient template',
      args: [],
    );
  }

  /// `Name`
  String get fFmaNameLabel {
    return Intl.message(
      'Name',
      name: 'fFmaNameLabel',
      desc: 'Label for formula name field',
      args: [],
    );
  }

  /// `ID`
  String get fFmaIdLabel {
    return Intl.message(
      'ID',
      name: 'fFmaIdLabel',
      desc: 'Label for formula ID field',
      args: [],
    );
  }

  /// `Barcode`
  String get fFmaBarcode {
    return Intl.message(
      'Barcode',
      name: 'fFmaBarcode',
      desc: 'Label for formula barcode field',
      args: [],
    );
  }

  /// `Quantity`
  String get fIngredientCountLabel {
    return Intl.message(
      'Quantity',
      name: 'fIngredientCountLabel',
      desc: 'Label for ingredient count display',
      args: [],
    );
  }

  /// `Total Weight`
  String get fTotalWeightLabel {
    return Intl.message(
      'Total Weight',
      name: 'fTotalWeightLabel',
      desc: 'Label for total weight display',
      args: [],
    );
  }

  /// `Start Weighing`
  String get fStartWeighingBtn {
    return Intl.message(
      'Start Weighing',
      name: 'fStartWeighingBtn',
      desc: 'Button to start the weighing process',
      args: [],
    );
  }

  /// `No formula found`
  String get fNoFmaFound {
    return Intl.message(
      'No formula found',
      name: 'fNoFmaFound',
      desc: 'Display text when no formula is found',
      args: [],
    );
  }

  /// `Repeat Weighing`
  String get fRepeatWeighingBtn {
    return Intl.message(
      'Repeat Weighing',
      name: 'fRepeatWeighingBtn',
      desc: 'Label for repeat weighing button',
      args: [],
    );
  }

  /// `Order`
  String get fIngredientOrder {
    return Intl.message(
      'Order',
      name: 'fIngredientOrder',
      desc: 'Section title for ingredient order display',
      args: [],
    );
  }

  /// `Ingredient Notes`
  String get fIngredientRemark {
    return Intl.message(
      'Ingredient Notes',
      name: 'fIngredientRemark',
      desc: 'Section title for ingredient remarks',
      args: [],
    );
  }

  /// `Formula Notes`
  String get fFmaRemark {
    return Intl.message(
      'Formula Notes',
      name: 'fFmaRemark',
      desc: 'Section title for formula remarks',
      args: [],
    );
  }

  /// `Involved Formulas`
  String get fInvolvedFmas {
    return Intl.message(
      'Involved Formulas',
      name: 'fInvolvedFmas',
      desc: 'Section title for formulas involving the raw material',
      args: [],
    );
  }

  /// `Print Formula`
  String get fPrintFmaBtn {
    return Intl.message(
      'Print Formula',
      name: 'fPrintFmaBtn',
      desc: 'Button to print the formula',
      args: [],
    );
  }

  /// `Scale List`
  String get fScaleList {
    return Intl.message(
      'Scale List',
      name: 'fScaleList',
      desc: 'Title for the scale list panel',
      args: [],
    );
  }

  /// `Category`
  String get fRawMaterialTypeNameCol {
    return Intl.message(
      'Category',
      name: 'fRawMaterialTypeNameCol',
      desc: 'Table column title for category name',
      args: [],
    );
  }

  /// `Create Time`
  String get fCreatedAtCol {
    return Intl.message(
      'Create Time',
      name: 'fCreatedAtCol',
      desc: 'Table column title for creation time',
      args: [],
    );
  }

  /// `Update Time`
  String get fUpdatedAtCol {
    return Intl.message(
      'Update Time',
      name: 'fUpdatedAtCol',
      desc: 'Table column title for last update time',
      args: [],
    );
  }

  /// `Operation`
  String get fTipOperation {
    return Intl.message(
      'Operation',
      name: 'fTipOperation',
      desc: 'Table column title for operations',
      args: [],
    );
  }

  /// `Category`
  String get fFmaCategoryCol {
    return Intl.message(
      'Category',
      name: 'fFmaCategoryCol',
      desc: 'Table column title for formula category',
      args: [],
    );
  }

  /// `Mode`
  String get fFmaModeCol {
    return Intl.message(
      'Mode',
      name: 'fFmaModeCol',
      desc: 'Table column title for formula mode (weight/pct)',
      args: [],
    );
  }

  /// `Create Time`
  String get fCreatedTimeCol {
    return Intl.message(
      'Create Time',
      name: 'fCreatedTimeCol',
      desc: 'Table column title for formula creation time',
      args: [],
    );
  }

  /// `Update Time`
  String get fUpdateTimeCol {
    return Intl.message(
      'Update Time',
      name: 'fUpdateTimeCol',
      desc: 'Table column title for formula last update time',
      args: [],
    );
  }

  /// `Notes`
  String get fRemarkCol {
    return Intl.message(
      'Notes',
      name: 'fRemarkCol',
      desc: 'Table column title for formula remarks',
      args: [],
    );
  }

  /// `Confidential`
  String get fConfidential {
    return Intl.message(
      'Confidential',
      name: 'fConfidential',
      desc: 'Display text for confidential formula status',
      args: [],
    );
  }

  /// `Public`
  String get fPublic {
    return Intl.message(
      'Public',
      name: 'fPublic',
      desc: 'Display text for public formula status',
      args: [],
    );
  }

  /// `Weight`
  String get fWeightMode {
    return Intl.message(
      'Weight',
      name: 'fWeightMode',
      desc: 'Display text for weight-based formula mode',
      args: [],
    );
  }

  /// `Percentage`
  String get fPctMode {
    return Intl.message(
      'Percentage',
      name: 'fPctMode',
      desc: 'Display text for percentage-based formula mode',
      args: [],
    );
  }

  /// `Formula Records`
  String get fRecordTitle {
    return Intl.message(
      'Formula Records',
      name: 'fRecordTitle',
      desc: 'Page title for formula weighing records',
      args: [],
    );
  }

  /// `Export Records`
  String get fExportRecordsBtn {
    return Intl.message(
      'Export Records',
      name: 'fExportRecordsBtn',
      desc: 'Button to export selected weighing records',
      args: [],
    );
  }

  /// `No.`
  String get fOrderNo {
    return Intl.message(
      'No.',
      name: 'fOrderNo',
      desc: 'Table column title for record number',
      args: [],
    );
  }

  /// `Formula Total Weight`
  String get fFormulaTotalWeight {
    return Intl.message(
      'Formula Total Weight',
      name: 'fFormulaTotalWeight',
      desc: 'Table column title for formula total weight',
      args: [],
    );
  }

  /// `Actual Total Weight`
  String get fActualTotalWeight {
    return Intl.message(
      'Actual Total Weight',
      name: 'fActualTotalWeight',
      desc: 'Table column title for actual total weight',
      args: [],
    );
  }

  /// `Ingredient Weight`
  String get fMaterialSingleWeight {
    return Intl.message(
      'Ingredient Weight',
      name: 'fMaterialSingleWeight',
      desc: 'Table column title for material single weight',
      args: [],
    );
  }

  /// `Actual Ingredient Weight`
  String get fActualSingleWeight {
    return Intl.message(
      'Actual Ingredient Weight',
      name: 'fActualSingleWeight',
      desc: 'Table column title for actual single weight',
      args: [],
    );
  }

  /// `Allowable Error`
  String get fAllowableError {
    return Intl.message(
      'Allowable Error',
      name: 'fAllowableError',
      desc: 'Table column title for allowable error',
      args: [],
    );
  }

  /// `Actual Error`
  String get fActualError {
    return Intl.message(
      'Actual Error',
      name: 'fActualError',
      desc: 'Table column title for actual error',
      args: [],
    );
  }

  /// `Pass`
  String get fQualificationStatus {
    return Intl.message(
      'Pass',
      name: 'fQualificationStatus',
      desc: 'Table column title for qualification status',
      args: [],
    );
  }

  /// `Ingredient Name`
  String get fMaterialNameCol {
    return Intl.message(
      'Ingredient Name',
      name: 'fMaterialNameCol',
      desc: 'Table column title for material name',
      args: [],
    );
  }

  /// `Ingredient ID`
  String get fMaterialIdCol {
    return Intl.message(
      'Ingredient ID',
      name: 'fMaterialIdCol',
      desc: 'Table column title for material ID',
      args: [],
    );
  }

  /// `Verification Code`
  String get fMaterialCodeCol {
    return Intl.message(
      'Verification Code',
      name: 'fMaterialCodeCol',
      desc: 'Table column title for material code',
      args: [],
    );
  }

  /// `Edit Ingredient`
  String get fEditMaterial {
    return Intl.message(
      'Edit Ingredient',
      name: 'fEditMaterial',
      desc: 'Edit Ingredient page',
      args: [],
    );
  }

  /// `Back`
  String get fBackBtn {
    return Intl.message(
      'Back',
      name: 'fBackBtn',
      desc: 'Button to navigate back to previous page',
      args: [],
    );
  }

  /// `√`
  String get fQualified {
    return Intl.message(
      '√',
      name: 'fQualified',
      desc: 'Display text for qualified status',
      args: [],
    );
  }

  /// `×`
  String get fUnqualified {
    return Intl.message(
      '×',
      name: 'fUnqualified',
      desc: 'Display text for unqualified status',
      args: [],
    );
  }

  /// `Weight Unit`
  String get fWgtUnit {
    return Intl.message(
      'Weight Unit',
      name: 'fWgtUnit',
      desc: 'Display text for weight unit',
      args: [],
    );
  }

  /// `Add Formula Weight`
  String get fAddFormulaWeightTitle {
    return Intl.message(
      'Add Formula Weight',
      name: 'fAddFormulaWeightTitle',
      desc: 'Title of the dialog for adding formula weight',
      args: [],
    );
  }

  /// `Formula Total Weight`
  String get fFormulaTotalWeightLabel {
    return Intl.message(
      'Formula Total Weight',
      name: 'fFormulaTotalWeightLabel',
      desc: 'Label for the formula total weight input field',
      args: [],
    );
  }

  /// `Please enter the formula total weight.`
  String get fInputFormulaTotalWeightHint {
    return Intl.message(
      'Please enter the formula total weight.',
      name: 'fInputFormulaTotalWeightHint',
      desc: 'Hint text for the formula total weight input field',
      args: [],
    );
  }

  /// `Select Unit`
  String get fSelectUnitHint {
    return Intl.message(
      'Select Unit',
      name: 'fSelectUnitHint',
      desc: 'Hint text for the unit selection dropdown',
      args: [],
    );
  }

  /// `Select Ingredient`
  String get fSelectRawMaterialHint {
    return Intl.message(
      'Select Ingredient',
      name: 'fSelectRawMaterialHint',
      desc: 'Placeholder or hint for selecting raw material',
      args: [],
    );
  }

  /// `Please enter the formula ID.`
  String get fInputFormulaIdHint {
    return Intl.message(
      'Please enter the formula ID.',
      name: 'fInputFormulaIdHint',
      desc: 'Hint text for formula ID input field',
      args: [],
    );
  }

  /// `Please select the formula mode.`
  String get fSelectFormulaModeHint {
    return Intl.message(
      'Please select the formula mode.',
      name: 'fSelectFormulaModeHint',
      desc: 'Placeholder for selecting formula mode (weight/pct)',
      args: [],
    );
  }

  /// `Please enter the weight.`
  String get fInputWeightHint {
    return Intl.message(
      'Please enter the weight.',
      name: 'fInputWeightHint',
      desc: 'Hint text for weight input field',
      args: [],
    );
  }

  /// `Please enter the percentage.`
  String get fInputPercentageHint {
    return Intl.message(
      'Please enter the percentage.',
      name: 'fInputPercentageHint',
      desc: 'Hint text for percentage input field',
      args: [],
    );
  }

  /// `Please enter the error.`
  String get fInputErrorHint {
    return Intl.message(
      'Please enter the error.',
      name: 'fInputErrorHint',
      desc: 'Hint text for error input field',
      args: [],
    );
  }

  /// `Clear`
  String get fClearBtn {
    return Intl.message(
      'Clear',
      name: 'fClearBtn',
      desc: 'Text on the clear button',
      args: [],
    );
  }

  /// `Please enter the notes.`
  String get fInputRemarkHint {
    return Intl.message(
      'Please enter the notes.',
      name: 'fInputRemarkHint',
      desc: 'Hint text for remarks input field',
      args: [],
    );
  }

  /// `Formula ID already exists`
  String get fFormulaIdDuplicate {
    return Intl.message(
      'Formula ID already exists',
      name: 'fFormulaIdDuplicate',
      desc: 'Error message for duplicate formula ID',
      args: [],
    );
  }

  /// `Formula barcode already exists`
  String get fFormulaBarcodeDuplicate {
    return Intl.message(
      'Formula barcode already exists',
      name: 'fFormulaBarcodeDuplicate',
      desc: 'Error message for duplicate formula barcode',
      args: [],
    );
  }

  /// `Formula ID and barcode already exist`
  String get fFormulaIdAndBarcodeDuplicate {
    return Intl.message(
      'Formula ID and barcode already exist',
      name: 'fFormulaIdAndBarcodeDuplicate',
      desc: 'Error message for duplicate formula ID and barcode',
      args: [],
    );
  }

  /// `Ingredient Id already exists`
  String get fRawIdDuplicate {
    return Intl.message(
      'Ingredient Id already exists',
      name: 'fRawIdDuplicate',
      desc: 'Error message for duplicate raw ID',
      args: [],
    );
  }

  /// `Set Ingredient`
  String get fSetRawMaterialBtn {
    return Intl.message(
      'Set Ingredient',
      name: 'fSetRawMaterialBtn',
      desc: 'Text on the button to set raw material',
      args: [],
    );
  }

  /// `Please enter the formula name.`
  String get fInputFormulaNameHint {
    return Intl.message(
      'Please enter the formula name.',
      name: 'fInputFormulaNameHint',
      desc: 'Hint text for formula name input field',
      args: [],
    );
  }

  /// `Please enter the formula category.`
  String get fInputFormulaTypeHint {
    return Intl.message(
      'Please enter the formula category.',
      name: 'fInputFormulaTypeHint',
      desc: 'Hint text for formula category input field',
      args: [],
    );
  }

  /// `Add category`
  String get fAddTypeBtn {
    return Intl.message(
      'Add category',
      name: 'fAddTypeBtn',
      desc: 'Text on the button to add category',
      args: [],
    );
  }

  /// `Add Ingredient`
  String get fAddRawMaterialBtn {
    return Intl.message(
      'Add Ingredient',
      name: 'fAddRawMaterialBtn',
      desc: 'Text on the button to add raw material',
      args: [],
    );
  }

  /// `Please enter the ingredient ID.`
  String get fInputRawMaterialIdHint {
    return Intl.message(
      'Please enter the ingredient ID.',
      name: 'fInputRawMaterialIdHint',
      desc: 'Hint text for raw material ID input field',
      args: [],
    );
  }

  /// `Please enter the ingredient name.`
  String get fInputRawMaterialNameHint {
    return Intl.message(
      'Please enter the ingredient name.',
      name: 'fInputRawMaterialNameHint',
      desc: 'Hint text for raw material name input field',
      args: [],
    );
  }

  /// `Please enter the ingredient notes.`
  String get fInputIngredientDescHint {
    return Intl.message(
      'Please enter the ingredient notes.',
      name: 'fInputIngredientDescHint',
      desc: 'Hint text for ingredient description input field',
      args: [],
    );
  }

  /// `Please enter the ingredient category.`
  String get fInputRawMaterialTypeHint {
    return Intl.message(
      'Please enter the ingredient category.',
      name: 'fInputRawMaterialTypeHint',
      desc: 'Hint text for raw material category input field',
      args: [],
    );
  }

  /// `Add Ingredient Category`
  String get fAddRawMaterialTypeBtn {
    return Intl.message(
      'Add Ingredient Category',
      name: 'fAddRawMaterialTypeBtn',
      desc: 'Text on the button to add raw material category',
      args: [],
    );
  }

  /// `Edit Ingredient Category`
  String get fEditRawMaterialTypeBtn {
    return Intl.message(
      'Edit Ingredient Category',
      name: 'fEditRawMaterialTypeBtn',
      desc: 'Text on the button to edit raw material category',
      args: [],
    );
  }

  /// `Edit Formula Category`
  String get fEditFormulaTypeBtn {
    return Intl.message(
      'Edit Formula Category',
      name: 'fEditFormulaTypeBtn',
      desc: 'Text on the button to edit formula category',
      args: [],
    );
  }

  /// `Formula Details`
  String get fFormulaDetailsTitle {
    return Intl.message(
      'Formula Details',
      name: 'fFormulaDetailsTitle',
      desc: 'Title for formula details page or section',
      args: [],
    );
  }

  /// `Prompt`
  String get fTipTitle {
    return Intl.message(
      'Prompt',
      name: 'fTipTitle',
      desc: 'Title for prompt dialog',
      args: [],
    );
  }

  /// `Please switch the device unit.`
  String get fSwitchUnitHint {
    return Intl.message(
      'Please switch the device unit.',
      name: 'fSwitchUnitHint',
      desc: 'Hint to switch device unit',
      args: [],
    );
  }

  /// `Current weighing data will be cleared. Confirm Continue?`
  String get fClearWeighingDataMsg {
    return Intl.message(
      'Current weighing data will be cleared. Confirm Continue?',
      name: 'fClearWeighingDataMsg',
      desc: 'Confirmation message for clearing weighing data',
      args: [],
    );
  }

  /// `Formula not meeting standard. Confirm completion?`
  String get fFormulaUnqualifiedMsg {
    return Intl.message(
      'Formula not meeting standard. Confirm completion?',
      name: 'fFormulaUnqualifiedMsg',
      desc: 'Confirmation message for completing unqualified formula',
      args: [],
    );
  }

  /// `Complete`
  String get fCompleteIngredientsBtn {
    return Intl.message(
      'Complete',
      name: 'fCompleteIngredientsBtn',
      desc: 'Text on the button to complete ingredient weighing',
      args: [],
    );
  }

  /// `Abandon`
  String get fAbandonIngredientsBtn {
    return Intl.message(
      'Abandon',
      name: 'fAbandonIngredientsBtn',
      desc: 'Text on the button to abandon ingredient weighing',
      args: [],
    );
  }

  /// `Record`
  String get fIngredientsRecordTitle {
    return Intl.message(
      'Record',
      name: 'fIngredientsRecordTitle',
      desc: 'Title for ingredients weighing record',
      args: [],
    );
  }

  /// `Target Weight`
  String get fTargetWeightLabel {
    return Intl.message(
      'Target Weight',
      name: 'fTargetWeightLabel',
      desc: 'Label for target weight field',
      args: [],
    );
  }

  /// `Current Weight`
  String get fCurrentWeightLabel {
    return Intl.message(
      'Current Weight',
      name: 'fCurrentWeightLabel',
      desc: 'Label for current weight field',
      args: [],
    );
  }

  /// `Allowable Error`
  String get fAllowableErrorWeightLabel {
    return Intl.message(
      'Allowable Error',
      name: 'fAllowableErrorWeightLabel',
      desc: 'Label for allowable error weight field',
      args: [],
    );
  }

  /// `Current Error`
  String get fCurrentErrorWeightLabel {
    return Intl.message(
      'Current Error',
      name: 'fCurrentErrorWeightLabel',
      desc: 'Label for current error weight field',
      args: [],
    );
  }

  /// `Current ingredient is overweight, please choose to abandon or correct?`
  String get fCurrentMaterialOverweightMsg {
    return Intl.message(
      'Current ingredient is overweight, please choose to abandon or correct?',
      name: 'fCurrentMaterialOverweightMsg',
      desc:
          'Warning message when current raw material is overweight, asking to abandon or correct',
      args: [],
    );
  }

  /// `The current weight of the ingredient is not qualified! Confirm continue?`
  String get fCurrentMaterialWeightInvalidMsg {
    return Intl.message(
      'The current weight of the ingredient is not qualified! Confirm continue?',
      name: 'fCurrentMaterialWeightInvalidMsg',
      desc: 'Error message when current raw material weight is invalid',
      args: [],
    );
  }

  /// `Please complete at least one ingredient weighing!`
  String get fAtLeastOneWeighingTip {
    return Intl.message(
      'Please complete at least one ingredient weighing!',
      name: 'fAtLeastOneWeighingTip',
      desc: 'Tip showing that at least one weighing is required',
      args: [],
    );
  }

  /// `The formula is incomplete or unqualified. Are you sure you want to finish?`
  String get fUnqualifiedConfirmFinishTip {
    return Intl.message(
      'The formula is incomplete or unqualified. Are you sure you want to finish?',
      name: 'fUnqualifiedConfirmFinishTip',
      desc:
          'Confirmation message when user wants to finish an unqualified formula',
      args: [],
    );
  }

  /// `Operation allowed only after stabilization!`
  String get fStableOperationHint {
    return Intl.message(
      'Operation allowed only after stabilization!',
      name: 'fStableOperationHint',
      desc: 'Hint to wait for stability before operation',
      args: [],
    );
  }

  /// `Formula Progress`
  String get fFormulaProgressLabel {
    return Intl.message(
      'Formula Progress',
      name: 'fFormulaProgressLabel',
      desc: 'Label for formula progress display',
      args: [],
    );
  }

  /// `Ingredient Weight`
  String get fRawMaterialWeightLabel {
    return Intl.message(
      'Ingredient Weight',
      name: 'fRawMaterialWeightLabel',
      desc: 'Label for raw material weight field',
      args: [],
    );
  }

  /// `Formula Data`
  String get fIngredientsDataLabel {
    return Intl.message(
      'Formula Data',
      name: 'fIngredientsDataLabel',
      desc: 'Label for ingredient weighing data',
      args: [],
    );
  }

  /// `Incomplete`
  String get fIncompleteStatus {
    return Intl.message(
      'Incomplete',
      name: 'fIncompleteStatus',
      desc: 'Display text for incomplete status',
      args: [],
    );
  }

  /// `Completed!`
  String get fFormulaCompletionMsg {
    return Intl.message(
      'Completed!',
      name: 'fFormulaCompletionMsg',
      desc: 'Completion message for formula',
      args: [],
    );
  }

  /// `Category already exists!`
  String get fTypeExistsMsg {
    return Intl.message(
      'Category already exists!',
      name: 'fTypeExistsMsg',
      desc: 'Error message for existing formula type',
      args: [],
    );
  }

  /// `Formula is in use and cannot be deleted.`
  String get fFormulaInUseDeleteErrorMsg {
    return Intl.message(
      'Formula is in use and cannot be deleted.',
      name: 'fFormulaInUseDeleteErrorMsg',
      desc: 'Error message when deleting a formula that is currently in use',
      args: [],
    );
  }

  /// `Ingredient is in use and cannot be deleted.`
  String get fRawInUseDeleteErrorMsg {
    return Intl.message(
      'Ingredient is in use and cannot be deleted.',
      name: 'fRawInUseDeleteErrorMsg',
      desc: 'Error message when deleting a ingredient that is currently in use',
      args: [],
    );
  }

  /// `No data, please add first.`
  String get fTipNoData {
    return Intl.message(
      'No data, please add first.',
      name: 'fTipNoData',
      desc: 'Text to display when there is no data',
      args: [],
    );
  }

  /// `Category Management`
  String get fRawCategoryManagement {
    return Intl.message(
      'Category Management',
      name: 'fRawCategoryManagement',
      desc: 'Title for category management page',
      args: [],
    );
  }

  /// `Success`
  String get fSuccessMsg {
    return Intl.message(
      'Success',
      name: 'fSuccessMsg',
      desc: 'General success message',
      args: [],
    );
  }

  /// `Clear search conditions`
  String get fClearSearchConditionBtn {
    return Intl.message(
      'Clear search conditions',
      name: 'fClearSearchConditionBtn',
      desc: 'Text on the button to clear all search conditions',
      args: [],
    );
  }

  /// `Correct`
  String get fReviseBtn {
    return Intl.message(
      'Correct',
      name: 'fReviseBtn',
      desc: 'This is a revise button',
      args: [],
    );
  }

  /// `Abandon`
  String get fAbandonBtn {
    return Intl.message(
      'Abandon',
      name: 'fAbandonBtn',
      desc: 'This is a abandon button',
      args: [],
    );
  }

  /// `Confidential`
  String get fSelectConfidentialityStatusMsg {
    return Intl.message(
      'Confidential',
      name: 'fSelectConfidentialityStatusMsg',
      desc:
          'This is used to prompt the user to select the confidentiality status of relevant content.',
      args: [],
    );
  }

  /// `Switching modes will clear the raw material list. Confirm?`
  String get fSwitchModeClearMsg {
    return Intl.message(
      'Switching modes will clear the raw material list. Confirm?',
      name: 'fSwitchModeClearMsg',
      desc:
          'Confirmation message for mode switch that clears raw material list',
      args: [],
    );
  }

  /// `Medium Speed`
  String get fMediumSpeed {
    return Intl.message(
      'Medium Speed',
      name: 'fMediumSpeed',
      desc: 'Prompt message indicating medium speed',
      args: [],
    );
  }

  /// `High Speed`
  String get fHighSpeed {
    return Intl.message(
      'High Speed',
      name: 'fHighSpeed',
      desc: 'Prompt message indicating high speed',
      args: [],
    );
  }

  /// `Low Speed`
  String get fLowSpeed {
    return Intl.message(
      'Low Speed',
      name: 'fLowSpeed',
      desc: 'Prompt message indicating low speed',
      args: [],
    );
  }

  /// `Need Container`
  String get fNeedContainer {
    return Intl.message(
      'Need Container',
      name: 'fNeedContainer',
      desc: 'Prompt message indicating that a container is needed',
      args: [],
    );
  }

  /// `Container`
  String get fFmaContainer {
    return Intl.message(
      'Container',
      name: 'fFmaContainer',
      desc: 'Prompt for container requirement in operations.',
      args: [],
    );
  }

  /// `Next Step`
  String get fNextStepBtn {
    return Intl.message(
      'Next Step',
      name: 'fNextStepBtn',
      desc: 'Button to proceed to the next step',
      args: [],
    );
  }

  /// `Auto Next Step`
  String get gTipAutoNextStep {
    return Intl.message(
      'Auto Next Step',
      name: 'gTipAutoNextStep',
      desc: 'Prompt message indicating automatic mode',
      args: [],
    );
  }

  /// `Auto Tare`
  String get gTipAutoTare {
    return Intl.message(
      'Auto Tare',
      name: 'gTipAutoTare',
      desc: 'Prompt message indicating automatic tare',
      args: [],
    );
  }

  /// `Device disconnected, please check the connection.`
  String get fDeviceDisconnected {
    return Intl.message(
      'Device disconnected, please check the connection.',
      name: 'fDeviceDisconnected',
      desc: 'Prompt when the device is disconnected',
      args: [],
    );
  }

  /// `Save successful`
  String get fSaveSuccess {
    return Intl.message(
      'Save successful',
      name: 'fSaveSuccess',
      desc: 'Success message for saving operation, text',
      args: [],
    );
  }

  /// `The data volume is too small to save`
  String get fDataTooLittle {
    return Intl.message(
      'The data volume is too small to save',
      name: 'fDataTooLittle',
      desc: 'Prompt when the data is too little to save, text',
      args: [],
    );
  }

  /// `Total weight`
  String get fTotalWeight {
    return Intl.message(
      'Total weight',
      name: 'fTotalWeight',
      desc: 'Label for total weight, text',
      args: [],
    );
  }

  /// `Avg.Speed`
  String get fAverageSpeed {
    return Intl.message(
      'Avg.Speed',
      name: 'fAverageSpeed',
      desc: 'Label for average speed, text',
      args: [],
    );
  }

  /// `Max.Speed`
  String get fMaxSpeed {
    return Intl.message(
      'Max.Speed',
      name: 'fMaxSpeed',
      desc: 'Label for maximum speed, text',
      args: [],
    );
  }

  /// `Min.Speed`
  String get fMinSpeed {
    return Intl.message(
      'Min.Speed',
      name: 'fMinSpeed',
      desc: 'Label for minimum speed, text',
      args: [],
    );
  }

  /// `Total time`
  String get fTotalTime {
    return Intl.message(
      'Total time',
      name: 'fTotalTime',
      desc: 'Label for total time, text',
      args: [],
    );
  }

  /// `Time`
  String get fTime {
    return Intl.message(
      'Time',
      name: 'fTime',
      desc: 'Label for time, text',
      args: [],
    );
  }

  /// `Speed`
  String get fSpeed {
    return Intl.message(
      'Speed',
      name: 'fSpeed',
      desc: 'Label for speed, text',
      args: [],
    );
  }

  /// `NO.`
  String get fNo {
    return Intl.message(
      'NO.',
      name: 'fNo',
      desc: 'Label for no., text',
      args: [],
    );
  }

  /// `Curve chart`
  String get fShowCurveChart {
    return Intl.message(
      'Curve chart',
      name: 'fShowCurveChart',
      desc:
          'Button or text to show the flow rate curve chart, can be button or text',
      args: [],
    );
  }

  /// `Data table`
  String get fShowDataTable {
    return Intl.message(
      'Data table',
      name: 'fShowDataTable',
      desc:
          'Button or text to show the flow rate data table, can be button or text',
      args: [],
    );
  }

  /// `Liquid Filling Speed`
  String get fFlowRate {
    return Intl.message(
      'Liquid Filling Speed',
      name: 'fFlowRate',
      desc: 'Label for flow rate, text',
      args: [],
    );
  }

  /// `Confirm delete?`
  String get fConfirmDelete {
    return Intl.message(
      'Confirm delete?',
      name: 'fConfirmDelete',
      desc: 'Prompt message to confirm deletion',
      args: [],
    );
  }

  /// `No records`
  String get fNoRecordTip {
    return Intl.message(
      'No records',
      name: 'fNoRecordTip',
      desc: 'Prompt message indicating there are no records',
      args: [],
    );
  }

  /// `Formula completed`
  String get fFormulaCompletedTip {
    return Intl.message(
      'Formula completed',
      name: 'fFormulaCompletedTip',
      desc: 'Prompt message indicating that the formula has been completed',
      args: [],
    );
  }

  /// `Multi-scale Management`
  String get menuMultiScaleManagement {
    return Intl.message(
      'Multi-scale Management',
      name: 'menuMultiScaleManagement',
      desc: 'Menu item for multi-scale management',
      args: [],
    );
  }

  /// `Device Time`
  String get menuDeviceTime {
    return Intl.message(
      'Device Time',
      name: 'menuDeviceTime',
      desc: 'Menu item for device Time',
      args: [],
    );
  }

  /// `Bluetooth Setting`
  String get menuBluetoothSetting {
    return Intl.message(
      'Bluetooth Setting',
      name: 'menuBluetoothSetting',
      desc: 'Menu item for bluetooth setting',
      args: [],
    );
  }

  /// `Wi-Fi Setting`
  String get menuWifiSetting {
    return Intl.message(
      'Wi-Fi Setting',
      name: 'menuWifiSetting',
      desc: 'Menu item for Wi-Fi setting',
      args: [],
    );
  }

  /// `Firmware Update`
  String get menuFirmwareUpdate {
    return Intl.message(
      'Firmware Update',
      name: 'menuFirmwareUpdate',
      desc: 'Menu item for firmware update',
      args: [],
    );
  }

  /// `Label Design`
  String get menuLabelDesign {
    return Intl.message(
      'Label Design',
      name: 'menuLabelDesign',
      desc: 'Menu item for label design',
      args: [],
    );
  }

  /// `Receipt Design`
  String get menuReceiptDesign {
    return Intl.message(
      'Receipt Design',
      name: 'menuReceiptDesign',
      desc: 'Menu item for receipt design',
      args: [],
    );
  }

  /// `Serial Output Design`
  String get menuSerialOutputDesign {
    return Intl.message(
      'Serial Output Design',
      name: 'menuSerialOutputDesign',
      desc: 'Menu item for serial output design',
      args: [],
    );
  }

  /// `Basic Data Collection`
  String get menuBasicDataCollection {
    return Intl.message(
      'Basic Data Collection',
      name: 'menuBasicDataCollection',
      desc: 'Menu item for basic data collection',
      args: [],
    );
  }

  /// `Ethernet Setting`
  String get menuWiredSetting {
    return Intl.message(
      'Ethernet Setting',
      name: 'menuWiredSetting',
      desc: 'Menu item for wired setting',
      args: [],
    );
  }

  /// `Calibration Lock`
  String get menuSealManagment {
    return Intl.message(
      'Calibration Lock',
      name: 'menuSealManagment',
      desc: 'Menu item for seal management',
      args: [],
    );
  }

  /// `Parameter Setting`
  String get menuParameterSetting {
    return Intl.message(
      'Parameter Setting',
      name: 'menuParameterSetting',
      desc: 'Menu item for parameter setting',
      args: [],
    );
  }

  /// `Weighing`
  String get menuWeighing {
    return Intl.message(
      'Weighing',
      name: 'menuWeighing',
      desc: 'Menu item for weighing',
      args: [],
    );
  }

  /// `PLU Management`
  String get menuPluManagement {
    return Intl.message(
      'PLU Management',
      name: 'menuPluManagement',
      desc: 'Menu item for PLU management',
      args: [],
    );
  }

  /// `Label Format Download`
  String get menuLabelFormatDownload {
    return Intl.message(
      'Label Format Download',
      name: 'menuLabelFormatDownload',
      desc: 'Menu item for label format download',
      args: [],
    );
  }

  /// `Receipt Format Download`
  String get menuReceiptFormatDownload {
    return Intl.message(
      'Receipt Format Download',
      name: 'menuReceiptFormatDownload',
      desc: 'Menu item for receipt format download',
      args: [],
    );
  }

  /// `Retail Report`
  String get menuRetailReport {
    return Intl.message(
      'Retail Report',
      name: 'menuRetailReport',
      desc: 'Menu item for retail report',
      args: [],
    );
  }

  /// `Variable Value Setting`
  String get menuVariableValueSetting {
    return Intl.message(
      'Variable Value Setting',
      name: 'menuVariableValueSetting',
      desc: 'Menu item for variable value setting',
      args: [],
    );
  }

  /// `Weighing Data Collection`
  String get menuWeighingDataCollection {
    return Intl.message(
      'Weighing Data Collection',
      name: 'menuWeighingDataCollection',
      desc: 'Menu item for weighing data collection',
      args: [],
    );
  }

  /// `Check Weighing`
  String get menuCheckWeighing {
    return Intl.message(
      'Check Weighing',
      name: 'menuCheckWeighing',
      desc: 'Menu item for check weighing',
      args: [],
    );
  }

  /// `Increment Weighing`
  String get menuIncrementWeighing {
    return Intl.message(
      'Increment Weighing',
      name: 'menuIncrementWeighing',
      desc: 'Menu item for increment weighing',
      args: [],
    );
  }

  /// `Take Out Scale`
  String get menuTakeOutScale {
    return Intl.message(
      'Take Out Scale',
      name: 'menuTakeOutScale',
      desc: 'Menu item for take out scale',
      args: [],
    );
  }

  /// `Formula`
  String get menuFormula {
    return Intl.message(
      'Formula',
      name: 'menuFormula',
      desc: 'Menu item for formula',
      args: [],
    );
  }

  /// `Liquid Filling Speed`
  String get menuFlowRate {
    return Intl.message(
      'Liquid Filling Speed',
      name: 'menuFlowRate',
      desc: 'Menu item for liquid filling speed',
      args: [],
    );
  }

  /// `Calibration`
  String get menuCalibration {
    return Intl.message(
      'Calibration',
      name: 'menuCalibration',
      desc: 'Menu item for calibration',
      args: [],
    );
  }

  /// `Weighing Setting`
  String get menuWeighingSetting {
    return Intl.message(
      'Weighing Setting',
      name: 'menuWeighingSetting',
      desc: 'Menu item for weighing setting',
      args: [],
    );
  }

  /// `Set Language`
  String get menuLanguageSetting {
    return Intl.message(
      'Set Language',
      name: 'menuLanguageSetting',
      desc: 'Menu item for language setting',
      args: [],
    );
  }

  /// `Application`
  String get menuApplications {
    return Intl.message(
      'Application',
      name: 'menuApplications',
      desc: 'Menu item for applications',
      args: [],
    );
  }

  /// `System Information`
  String get menuSystemInformation {
    return Intl.message(
      'System Information',
      name: 'menuSystemInformation',
      desc: 'Menu item for system information',
      args: [],
    );
  }

  /// `Configuration`
  String get menuConfiguration {
    return Intl.message(
      'Configuration',
      name: 'menuConfiguration',
      desc: 'Menu item for configuration',
      args: [],
    );
  }

  /// `Confirm`
  String get gBtnConfirm {
    return Intl.message(
      'Confirm',
      name: 'gBtnConfirm',
      desc: 'This is a confirmation button.',
      args: [],
    );
  }

  /// `Cancel`
  String get gBtnCancel {
    return Intl.message(
      'Cancel',
      name: 'gBtnCancel',
      desc: 'This is a button to cancel',
      args: [],
    );
  }

  /// `Perpetual`
  String get gTipPerpetual {
    return Intl.message(
      'Perpetual',
      name: 'gTipPerpetual',
      desc: 'This is a tip of the certification expiration date.',
      args: [],
    );
  }

  /// `System Unique ID`
  String get gSystemId {
    return Intl.message(
      'System Unique ID',
      name: 'gSystemId',
      desc: 'This is the prompt for the system authentication ID.',
      args: [],
    );
  }

  /// `Expiration date`
  String get gExpirationDate {
    return Intl.message(
      'Expiration date',
      name: 'gExpirationDate',
      desc: 'This is the prompt for the expiration date.',
      args: [],
    );
  }

  /// `Unactivated`
  String get gTipUnactivated {
    return Intl.message(
      'Unactivated',
      name: 'gTipUnactivated',
      desc: 'This is a tip for unactivated status.',
      args: [],
    );
  }

  /// `Activated`
  String get gTipActivated {
    return Intl.message(
      'Activated',
      name: 'gTipActivated',
      desc: 'This is a tip for activated status.',
      args: [],
    );
  }

  /// `Activate`
  String get gBtnActivate {
    return Intl.message(
      'Activate',
      name: 'gBtnActivate',
      desc: 'This is a button for activating something.',
      args: [],
    );
  }

  /// `Activation Feedback`
  String get gTitleActivationFeedback {
    return Intl.message(
      'Activation Feedback',
      name: 'gTitleActivationFeedback',
      desc: 'This is the title for activation feedback.',
      args: [],
    );
  }

  /// `Pay annually to activate all advanced functions, valid for one year. To purchase, please click ( ℹ️ ) in the top-right corner to contact the software provider.`
  String get gSubtitleConfigFunctionCharge {
    return Intl.message(
      'Pay annually to activate all advanced functions, valid for one year. To purchase, please click ( ℹ️ ) in the top-right corner to contact the software provider.',
      name: 'gSubtitleConfigFunctionCharge',
      desc:
          'This is the subtitle for the configuration function charging method.',
      args: [],
    );
  }

  /// `Pay per function to activate permanently. To purchase, please click ( ℹ️ ) in the top-right corner to contact the software provider.`
  String get gSubtitleAppsCharge {
    return Intl.message(
      'Pay per function to activate permanently. To purchase, please click ( ℹ️ ) in the top-right corner to contact the software provider.',
      name: 'gSubtitleAppsCharge',
      desc: 'This is the subtitle for the apps function charging method.',
      args: [],
    );
  }

  /// `Please select an activation file`
  String get gTipSelectActivationFile {
    return Intl.message(
      'Please select an activation file',
      name: 'gTipSelectActivationFile',
      desc: 'This is a tip to select an activation file.',
      args: [],
    );
  }

  /// `Select File`
  String get gBtnSelectFile {
    return Intl.message(
      'Select File',
      name: 'gBtnSelectFile',
      desc: 'This is a button to select a file.',
      args: [],
    );
  }

  /// `All configuration functions`
  String get gTipAllConfigFunctions {
    return Intl.message(
      'All configuration functions',
      name: 'gTipAllConfigFunctions',
      desc: 'This is a tip for all configuration functions.',
      args: [],
    );
  }

  /// `Date not updated`
  String get gTipDateNotUpdated {
    return Intl.message(
      'Date not updated',
      name: 'gTipDateNotUpdated',
      desc: 'This is a tip indicating that the date has not been updated.',
      args: [],
    );
  }

  /// `Application`
  String get gTitleAppConfig {
    return Intl.message(
      'Application',
      name: 'gTitleAppConfig',
      desc: 'This is the title for application configuration.',
      args: [],
    );
  }

  /// `The uploaded activation file is incorrect. Please upload it again.`
  String get gTipActivationFileError {
    return Intl.message(
      'The uploaded activation file is incorrect. Please upload it again.',
      name: 'gTipActivationFileError',
      desc: 'This is a tip for an incorrect activation file upload.',
      args: [],
    );
  }

  /// `Add`
  String get gBtnAdd {
    return Intl.message(
      'Add',
      name: 'gBtnAdd',
      desc: 'This is a button for adding new items.',
      args: [],
    );
  }

  /// `online`
  String get gTipOnline {
    return Intl.message(
      'online',
      name: 'gTipOnline',
      desc: 'This is a prompt for online information.',
      args: [],
    );
  }

  /// `offline`
  String get gTipOffline {
    return Intl.message(
      'offline',
      name: 'gTipOffline',
      desc: 'This is a prompt for offline information.',
      args: [],
    );
  }

  /// `Scale Name`
  String get gScaleName {
    return Intl.message(
      'Scale Name',
      name: 'gScaleName',
      desc: 'This is the prompt for the scale name.',
      args: [],
    );
  }

  /// `Model Name`
  String get gModelName {
    return Intl.message(
      'Model Name',
      name: 'gModelName',
      desc: 'This is a prompt for model name.',
      args: [],
    );
  }

  /// `SN`
  String get gScaleSn {
    return Intl.message(
      'SN',
      name: 'gScaleSn',
      desc: 'This is a prompt for sn.',
      args: [],
    );
  }

  /// `Data bits`
  String get gDataBits {
    return Intl.message(
      'Data bits',
      name: 'gDataBits',
      desc: 'This is the prompt for data bits.',
      args: [],
    );
  }

  /// `Baud rate`
  String get gBaudRate {
    return Intl.message(
      'Baud rate',
      name: 'gBaudRate',
      desc: 'This is the prompt for baud rate.',
      args: [],
    );
  }

  /// `Parity`
  String get gSerialParity {
    return Intl.message(
      'Parity',
      name: 'gSerialParity',
      desc: 'This is the prompt for parity.',
      args: [],
    );
  }

  /// `Stop bits`
  String get gStopBits {
    return Intl.message(
      'Stop bits',
      name: 'gStopBits',
      desc: 'This is the prompt for stop bits.',
      args: [],
    );
  }

  /// `Serial port`
  String get gSerialPort {
    return Intl.message(
      'Serial port',
      name: 'gSerialPort',
      desc: 'This is the prompt for serial port.',
      args: [],
    );
  }

  /// `Click to refresh`
  String get gTipRefreshPort {
    return Intl.message(
      'Click to refresh',
      name: 'gTipRefreshPort',
      desc: 'This is a tip to click to refresh the list.',
      args: [],
    );
  }

  /// `Port`
  String get gTipPort {
    return Intl.message(
      'Port',
      name: 'gTipPort',
      desc: 'This is a prompt for port number.',
      args: [],
    );
  }

  /// `App Information`
  String get gAppInformation {
    return Intl.message(
      'App Information',
      name: 'gAppInformation',
      desc: 'Title for app-related information',
      args: [],
    );
  }

  /// `Language Setting`
  String get gTitleLanguageSetting {
    return Intl.message(
      'Language Setting',
      name: 'gTitleLanguageSetting',
      desc: 'Title for language setting page',
      args: [],
    );
  }

  /// `Select Language`
  String get gTipSelectLanguage {
    return Intl.message(
      'Select Language',
      name: 'gTipSelectLanguage',
      desc: 'Prompt for selecting language',
      args: [],
    );
  }

  /// `Connect fail`
  String get gTipConnectFail {
    return Intl.message(
      'Connect fail',
      name: 'gTipConnectFail',
      desc: 'This is a prompt message when the connection fails.',
      args: [],
    );
  }

  /// `The serial port disconnected`
  String get gTipSerialPortDisconnected {
    return Intl.message(
      'The serial port disconnected',
      name: 'gTipSerialPortDisconnected',
      desc: 'This is a prompt message when the serial port is disconnected.',
      args: [],
    );
  }

  /// `Sync PC Time`
  String get gBtnSyncPcTime {
    return Intl.message(
      'Sync PC Time',
      name: 'gBtnSyncPcTime',
      desc: 'This is a button about sync pc time.',
      args: [],
    );
  }

  /// `Set Date/Time`
  String get gBtnSetTime {
    return Intl.message(
      'Set Date/Time',
      name: 'gBtnSetTime',
      desc: 'This is a button about set date/time.',
      args: [],
    );
  }

  /// `Sync Time`
  String get gBtnSyncTime {
    return Intl.message(
      'Sync Time',
      name: 'gBtnSyncTime',
      desc: 'This is a button about sync time.',
      args: [],
    );
  }

  /// `Select Date`
  String get gBtnSelectDate {
    return Intl.message(
      'Select Date',
      name: 'gBtnSelectDate',
      desc: 'This is a button about select date.',
      args: [],
    );
  }

  /// `failed to get time`
  String get gTipFailedGetTime {
    return Intl.message(
      'failed to get time',
      name: 'gTipFailedGetTime',
      desc: 'This is a tip about failed to get time.',
      args: [],
    );
  }

  /// `Get name`
  String get gGetBluetoothName {
    return Intl.message(
      'Get name',
      name: 'gGetBluetoothName',
      desc: 'This is a button or action to get the Bluetooth name.',
      args: [],
    );
  }

  /// `Modify name`
  String get gModifyBluetoothName {
    return Intl.message(
      'Modify name',
      name: 'gModifyBluetoothName',
      desc: 'This is a button or action to modify the Bluetooth name.',
      args: [],
    );
  }

  /// `Emission Power:`
  String get gBluetoothEmissionPower {
    return Intl.message(
      'Emission Power:',
      name: 'gBluetoothEmissionPower',
      desc: 'This is a label indicating the Bluetooth emission power.',
      args: [],
    );
  }

  /// `Modify emission power`
  String get gModifyBluetoothEmission {
    return Intl.message(
      'Modify emission power',
      name: 'gModifyBluetoothEmission',
      desc:
          'This is a button or action to modify the Bluetooth emission power.',
      args: [],
    );
  }

  /// `Get Ip`
  String get gBtnGetIp {
    return Intl.message(
      'Get Ip',
      name: 'gBtnGetIp',
      desc: ' This is a button to get the IP address.',
      args: [],
    );
  }

  /// `Incorrect address! e.g. xxx.xxx.xxx.xxx`
  String get gTipErrorIp {
    return Intl.message(
      'Incorrect address! e.g. xxx.xxx.xxx.xxx',
      name: 'gTipErrorIp',
      desc: 'This is a tip for an incorrect IP address.',
      args: [],
    );
  }

  /// `Information`
  String get gTipInformation {
    return Intl.message(
      'Information',
      name: 'gTipInformation',
      desc: 'This is a prompt for information.',
      args: [],
    );
  }

  /// `Value`
  String get gTipValue {
    return Intl.message(
      'Value',
      name: 'gTipValue',
      desc: 'This is a prompt for value.',
      args: [],
    );
  }

  /// `Get Basic Data`
  String get gBtnGetBasicData {
    return Intl.message(
      'Get Basic Data',
      name: 'gBtnGetBasicData',
      desc: 'This is a button to get basic data.',
      args: [],
    );
  }

  /// `Download is successful!`
  String get gTipDownloadOk {
    return Intl.message(
      'Download is successful!',
      name: 'gTipDownloadOk',
      desc: 'This is a tip indicating that the download was successful.',
      args: [],
    );
  }

  /// `Download failed!`
  String get gTipDownloadFail {
    return Intl.message(
      'Download failed!',
      name: 'gTipDownloadFail',
      desc: 'This is a tip indicating that the download failed.',
      args: [],
    );
  }

  /// `Default Value`
  String get gTipDefaultValue {
    return Intl.message(
      'Default Value',
      name: 'gTipDefaultValue',
      desc: 'This is the prompt for the default value.',
      args: [],
    );
  }

  /// `Max Length`
  String get gTipMaxLength {
    return Intl.message(
      'Max Length',
      name: 'gTipMaxLength',
      desc: 'This is the prompt for the maximum length.',
      args: [],
    );
  }

  /// `Filling`
  String get gTipFilling {
    return Intl.message(
      'Filling',
      name: 'gTipFilling',
      desc: 'This is the prompt for filling.',
      args: [],
    );
  }

  /// `Alignment`
  String get gTipAlignment {
    return Intl.message(
      'Alignment',
      name: 'gTipAlignment',
      desc: 'This is the prompt for alignment.',
      args: [],
    );
  }

  /// `Hexadecimal input, please separate with a space, for example: 31 32 33 34 35 36`
  String get gTipHexInput {
    return Intl.message(
      'Hexadecimal input, please separate with a space, for example: 31 32 33 34 35 36',
      name: 'gTipHexInput',
      desc: 'This is the prompt for hexadecimal input, separated by spaces.',
      args: [],
    );
  }

  /// `Text Hexadecimal Property`
  String get gTipTextHexProperty {
    return Intl.message(
      'Text Hexadecimal Property',
      name: 'gTipTextHexProperty',
      desc: 'This is the title for text hexadecimal property.',
      args: [],
    );
  }

  /// `Content`
  String get gTipContent {
    return Intl.message(
      'Content',
      name: 'gTipContent',
      desc: 'This is the prompt for content.',
      args: [],
    );
  }

  /// `Text Property`
  String get gTipTextProperty {
    return Intl.message(
      'Text Property',
      name: 'gTipTextProperty',
      desc: 'This is the title for text property.',
      args: [],
    );
  }

  /// `Enter Property`
  String get gTipEnterProperty {
    return Intl.message(
      'Enter Property',
      name: 'gTipEnterProperty',
      desc: 'This is the title for enter property.',
      args: [],
    );
  }

  /// `Unstable Text`
  String get gTipUnstableText {
    return Intl.message(
      'Unstable Text',
      name: 'gTipUnstableText',
      desc: 'This is the prompt for unstable text.',
      args: [],
    );
  }

  /// `Net Text`
  String get gTipNetText {
    return Intl.message(
      'Net Text',
      name: 'gTipNetText',
      desc: 'This is the prompt for net text.',
      args: [],
    );
  }

  /// `Stable Text`
  String get gTipStableText {
    return Intl.message(
      'Stable Text',
      name: 'gTipStableText',
      desc: 'This is the prompt for stable text.',
      args: [],
    );
  }

  /// `Gross Text`
  String get gTipGrossText {
    return Intl.message(
      'Gross Text',
      name: 'gTipGrossText',
      desc: 'This is the prompt for gross text.',
      args: [],
    );
  }

  /// `Float Property`
  String get gTipFloatProperty {
    return Intl.message(
      'Float Property',
      name: 'gTipFloatProperty',
      desc: 'This is the title for float property.',
      args: [],
    );
  }

  /// `Decimal`
  String get gTipDecimal {
    return Intl.message(
      'Decimal',
      name: 'gTipDecimal',
      desc: 'This is the prompt for decimal places.',
      args: [],
    );
  }

  /// `Add Device`
  String get gTitleAddDevice {
    return Intl.message(
      'Add Device',
      name: 'gTitleAddDevice',
      desc: 'This is the title for adding a device.',
      args: [],
    );
  }

  /// `For serial port connection, a serial cable is required to connect to the PC. For WiFi connection, the device's IP address and port number must be correct.`
  String get gTipAddDevice {
    return Intl.message(
      'For serial port connection, a serial cable is required to connect to the PC. For WiFi connection, the device\'s IP address and port number must be correct.',
      name: 'gTipAddDevice',
      desc: 'This is a tip for adding a device.',
      args: [],
    );
  }

  /// `Empty the scale pan`
  String get gTipEmptyScalePan {
    return Intl.message(
      'Empty the scale pan',
      name: 'gTipEmptyScalePan',
      desc: 'This is a tip to empty the scale pan.',
      args: [],
    );
  }

  /// `Place the calibration weight`
  String get gTipPlaceCalibrationWeight {
    return Intl.message(
      'Place the calibration weight',
      name: 'gTipPlaceCalibrationWeight',
      desc: 'This is a tip to place the calibration weight.',
      args: [],
    );
  }

  /// `Set calibration weight`
  String get gTipSetCalibrationWeight {
    return Intl.message(
      'Set calibration weight',
      name: 'gTipSetCalibrationWeight',
      desc: 'This is a tip to set the calibration weight.',
      args: [],
    );
  }

  /// `Calibration`
  String get gTipPlaceWeight {
    return Intl.message(
      'Calibration',
      name: 'gTipPlaceWeight',
      desc: 'This is a tip to place the weight.',
      args: [],
    );
  }

  /// `Calibration result`
  String get gTipCalibrationResult {
    return Intl.message(
      'Calibration result',
      name: 'gTipCalibrationResult',
      desc: 'This is a tip for the calibration result.',
      args: [],
    );
  }

  /// `Please empty the scale pan and click next`
  String get gTipEmptyScalePanThenNext {
    return Intl.message(
      'Please empty the scale pan and click next',
      name: 'gTipEmptyScalePanThenNext',
      desc: 'This is a tip to empty the scale pan and click next.',
      args: [],
    );
  }

  /// `Please set the calibration weight and click next`
  String get gTipSetCalibrationWeightThenNext {
    return Intl.message(
      'Please set the calibration weight and click next',
      name: 'gTipSetCalibrationWeightThenNext',
      desc: 'This is a tip to set the calibration weight and click next.',
      args: [],
    );
  }

  /// `Please wait for the green light to turn on and click next`
  String get gTipLoadWeightThenNext {
    return Intl.message(
      'Please wait for the green light to turn on and click next',
      name: 'gTipLoadWeightThenNext',
      desc:
          'This is a tip to wait for the green light to turn on and click next.',
      args: [],
    );
  }

  /// `Please empty the scale pan`
  String get gTipPleaseEmptyScalePan {
    return Intl.message(
      'Please empty the scale pan',
      name: 'gTipPleaseEmptyScalePan',
      desc: 'This is a tip to ask to empty the scale pan.',
      args: [],
    );
  }

  /// `Please confirm the weight`
  String get gTipPleaseLoadWeight {
    return Intl.message(
      'Please confirm the weight',
      name: 'gTipPleaseLoadWeight',
      desc: 'This is a tip to ask to confirm the weight.',
      args: [],
    );
  }

  /// `If calibration fails, please click 'Recalibrate'.`
  String get gTipCalResult {
    return Intl.message(
      'If calibration fails, please click \'Recalibrate\'.',
      name: 'gTipCalResult',
      desc: 'This is a tip for calibration result.',
      args: [],
    );
  }

  /// `Calibration failed`
  String get gTipCalibrationFailed {
    return Intl.message(
      'Calibration failed',
      name: 'gTipCalibrationFailed',
      desc: 'This is a tip for calibration failure.',
      args: [],
    );
  }

  /// `Calibration successful`
  String get gTipCalibrationSuccess {
    return Intl.message(
      'Calibration successful',
      name: 'gTipCalibrationSuccess',
      desc: 'This is a tip for successful calibration.',
      args: [],
    );
  }

  /// `Recalibrate`
  String get gTipCalibrationAgain {
    return Intl.message(
      'Recalibrate',
      name: 'gTipCalibrationAgain',
      desc: 'This is a tip to ask to calibrate again.',
      args: [],
    );
  }

  /// `Calibration is in progress. It is recommended to complete the calibration before switching the scale! Are you sure you want to switch?`
  String get gTipCalibrationWarning {
    return Intl.message(
      'Calibration is in progress. It is recommended to complete the calibration before switching the scale! Are you sure you want to switch?',
      name: 'gTipCalibrationWarning',
      desc: 'This is a warning message for calibration.',
      args: [],
    );
  }

  /// `Previous Step`
  String get gBtnPrevious {
    return Intl.message(
      'Previous Step',
      name: 'gBtnPrevious',
      desc: 'This is a button to go back to the previous step.',
      args: [],
    );
  }

  /// `Please enter the calibration weight`
  String get gTipCalibrationWeight {
    return Intl.message(
      'Please enter the calibration weight',
      name: 'gTipCalibrationWeight',
      desc: 'This is a prompt to ask the user to input the calibration weight.',
      args: [],
    );
  }

  /// `Before Calibration`
  String get gTipBeforeCalibration {
    return Intl.message(
      'Before Calibration',
      name: 'gTipBeforeCalibration',
      desc: 'This is a prompt about calibration before.',
      args: [],
    );
  }

  /// `After Calibration`
  String get gTipAfterCalibration {
    return Intl.message(
      'After Calibration',
      name: 'gTipAfterCalibration',
      desc: 'This is a promPt about calibration after.',
      args: [],
    );
  }

  /// `Error Value`
  String get gTipErrorValue {
    return Intl.message(
      'Error Value',
      name: 'gTipErrorValue',
      desc: 'This is a prompt to tell the user the error value.',
      args: [],
    );
  }

  /// `Gaduation`
  String get gTipGaduation {
    return Intl.message(
      'Gaduation',
      name: 'gTipGaduation',
      desc: 'This is the prompt for graduation.',
      args: [],
    );
  }

  /// `Maximum Range`
  String get gTipMaxRange {
    return Intl.message(
      'Maximum Range',
      name: 'gTipMaxRange',
      desc: 'This is the prompt for the maximum range.',
      args: [],
    );
  }

  /// `Weight Unit`
  String get gTipWeightUnit {
    return Intl.message(
      'Weight Unit',
      name: 'gTipWeightUnit',
      desc: 'This is the prompt for the weight unit.',
      args: [],
    );
  }

  /// `Initial Zero Setting`
  String get gTipInitialZero {
    return Intl.message(
      'Initial Zero Setting',
      name: 'gTipInitialZero',
      desc: 'This is the prompt for initial zero setting.',
      args: [],
    );
  }

  /// `Manual Zero Reset`
  String get gTipManualZero {
    return Intl.message(
      'Manual Zero Reset',
      name: 'gTipManualZero',
      desc: 'This is the prompt for manual zero reset.',
      args: [],
    );
  }

  /// `Zero Tracking`
  String get gTipZeroTracking {
    return Intl.message(
      'Zero Tracking',
      name: 'gTipZeroTracking',
      desc: 'This is the prompt for zero tracking.',
      args: [],
    );
  }

  /// `Gravitational Acceleration`
  String get gTipGravityAcceleration {
    return Intl.message(
      'Gravitational Acceleration',
      name: 'gTipGravityAcceleration',
      desc: 'This is the prompt for gravitational acceleration.',
      args: [],
    );
  }

  /// `Gravitational acceleration input error`
  String get gTipGravityAccelerationInputError {
    return Intl.message(
      'Gravitational acceleration input error',
      name: 'gTipGravityAccelerationInputError',
      desc:
          'This is a tip to inform the user that the gravitational acceleration input is incorrect.',
      args: [],
    );
  }

  /// `Fail,Please redo the last step.`
  String get gTipRedoLastStep {
    return Intl.message(
      'Fail,Please redo the last step.',
      name: 'gTipRedoLastStep',
      desc: 'This is a tip to redo the last step.',
      args: [],
    );
  }

  /// `Calibrating...`
  String get gTipCalibrating {
    return Intl.message(
      'Calibrating...',
      name: 'gTipCalibrating',
      desc: 'This is a tip to inform the user that calibration is in progress.',
      args: [],
    );
  }

  /// `Getting parameters, please wait...`
  String get gTipGettingParameter {
    return Intl.message(
      'Getting parameters, please wait...',
      name: 'gTipGettingParameter',
      desc:
          'This is a tip to inform the user that the parameters are being retrieved.',
      args: [],
    );
  }

  /// `get parameter fail`
  String get gTipGetParameterFail {
    return Intl.message(
      'get parameter fail',
      name: 'gTipGetParameterFail',
      desc:
          'This is a tip to inform the user that parameter retrieval has failed.',
      args: [],
    );
  }

  /// `set parameter fail`
  String get gTipSetParameterFail {
    return Intl.message(
      'set parameter fail',
      name: 'gTipSetParameterFail',
      desc:
          'This is a tip to inform the user that parameter setting has failed.',
      args: [],
    );
  }

  /// `When switching units, please also switch the corresponding range.`
  String get gTipSwitchUnit {
    return Intl.message(
      'When switching units, please also switch the corresponding range.',
      name: 'gTipSwitchUnit',
      desc:
          'This is a tip to remind the user to switch the corresponding range when changing the unit.',
      args: [],
    );
  }

  /// `No devices found yet, Please add your device`
  String get gTipNoDevice {
    return Intl.message(
      'No devices found yet, Please add your device',
      name: 'gTipNoDevice',
      desc: 'This is a tip to inform the user that no devices are found.',
      args: [],
    );
  }

  /// `The port is already in use.`
  String get gTipPortInUsed {
    return Intl.message(
      'The port is already in use.',
      name: 'gTipPortInUsed',
      desc: 'This is a tip to inform the user that the port is already in use.',
      args: [],
    );
  }

  /// `Performing operation...`
  String get gTipPerformingOperation {
    return Intl.message(
      'Performing operation...',
      name: 'gTipPerformingOperation',
      desc:
          'This is a tip to inform the user that an operation is being performed.',
      args: [],
    );
  }

  /// `Device List`
  String get gTitleDeviceList {
    return Intl.message(
      'Device List',
      name: 'gTitleDeviceList',
      desc: 'This is the title for the device list.',
      args: [],
    );
  }

  /// `Weight Independent Mode`
  String get gTipStandaloneMode {
    return Intl.message(
      'Weight Independent Mode',
      name: 'gTipStandaloneMode',
      desc: 'This is a tip indicating the standalone operation mode.',
      args: [],
    );
  }

  /// `Weight Summary Mode`
  String get gTipWeightSummationMode {
    return Intl.message(
      'Weight Summary Mode',
      name: 'gTipWeightSummationMode',
      desc: 'This is a tip indicating the weight summation operation mode.',
      args: [],
    );
  }

  /// `Report Setting`
  String get gBtnReportSetting {
    return Intl.message(
      'Report Setting',
      name: 'gBtnReportSetting',
      desc: 'This is a button about report setting.',
      args: [],
    );
  }

  /// `Delete All`
  String get gBtnDeleteAll {
    return Intl.message(
      'Delete All',
      name: 'gBtnDeleteAll',
      desc: 'This is a button for deleting all items.',
      args: [],
    );
  }

  /// `Are you sure you want to delete all data?`
  String get gTipConfirmDeleteAll {
    return Intl.message(
      'Are you sure you want to delete all data?',
      name: 'gTipConfirmDeleteAll',
      desc: 'This is a confirmation prompt for deleting all data.',
      args: [],
    );
  }

  /// `Export successful`
  String get gTipExportSuccess {
    return Intl.message(
      'Export successful',
      name: 'gTipExportSuccess',
      desc: 'This is a prompt for successful export.',
      args: [],
    );
  }

  /// `Export failed`
  String get gTipExportFail {
    return Intl.message(
      'Export failed',
      name: 'gTipExportFail',
      desc: 'This is a prompt for failed export.',
      args: [],
    );
  }

  /// `Save type`
  String get gTipSaveType {
    return Intl.message(
      'Save type',
      name: 'gTipSaveType',
      desc: 'This is the prompt for the save type.',
      args: [],
    );
  }

  /// `The input data is invalid`
  String get gTipInvalidInput {
    return Intl.message(
      'The input data is invalid',
      name: 'gTipInvalidInput',
      desc:
          'This is the prompt for invalid input data, especially for upper and lower limits.',
      args: [],
    );
  }

  /// `Invalid weight data`
  String get gTipInvalidWeightData {
    return Intl.message(
      'Invalid weight data',
      name: 'gTipInvalidWeightData',
      desc: 'This is a prompt for invalid weight data.',
      args: [],
    );
  }

  /// `Function Center`
  String get gBtnConfigSetting {
    return Intl.message(
      'Function Center',
      name: 'gBtnConfigSetting',
      desc: 'This is a button for function center.',
      args: [],
    );
  }

  /// `Free Applications`
  String get gTipFreeApplications {
    return Intl.message(
      'Free Applications',
      name: 'gTipFreeApplications',
      desc: 'This is a tip for free applications.',
      args: [],
    );
  }

  /// `Retail Applications`
  String get gTipRetailApplications {
    return Intl.message(
      'Retail Applications',
      name: 'gTipRetailApplications',
      desc: 'This is a tip for retail applications.',
      args: [],
    );
  }

  /// `Industrial Applications`
  String get gTipIndustrialApplications {
    return Intl.message(
      'Industrial Applications',
      name: 'gTipIndustrialApplications',
      desc: 'This is a tip for industrial applications.',
      args: [],
    );
  }

  /// `Advanced Configuration`
  String get gTipAdvancedConfiguration {
    return Intl.message(
      'Advanced Configuration',
      name: 'gTipAdvancedConfiguration',
      desc: 'This is a tip for advanced configuration.',
      args: [],
    );
  }

  /// `Free Configuration`
  String get gTipFreeConfiguration {
    return Intl.message(
      'Free Configuration',
      name: 'gTipFreeConfiguration',
      desc: 'This is a tip for free configuration.',
      args: [],
    );
  }

  /// `Connect to multiple devices via serial port, Wi-Fi, and Bluetooth.`
  String get subTitleMultiScaleManagement {
    return Intl.message(
      'Connect to multiple devices via serial port, Wi-Fi, and Bluetooth.',
      name: 'subTitleMultiScaleManagement',
      desc: 'SubTitle for multi-scale management',
      args: [],
    );
  }

  /// `Set the device's date and time.`
  String get subTitleDeviceTime {
    return Intl.message(
      'Set the device\'s date and time.',
      name: 'subTitleDeviceTime',
      desc: 'SubTitle for device Time',
      args: [],
    );
  }

  /// `Configure Bluetooth name and signal strength.`
  String get subTitleBluetoothSetting {
    return Intl.message(
      'Configure Bluetooth name and signal strength.',
      name: 'subTitleBluetoothSetting',
      desc: 'SubTitle for bluetooth setting',
      args: [],
    );
  }

  /// `Obtain static/dynamic IP addresses and connect to Wi-Fi.`
  String get subTitleWifiSetting {
    return Intl.message(
      'Obtain static/dynamic IP addresses and connect to Wi-Fi.',
      name: 'subTitleWifiSetting',
      desc: 'SubTitle for Wi-Fi setting',
      args: [],
    );
  }

  /// `Update the scale's firmware via serial port or Wi-Fi.`
  String get subTitleFirmwareUpdate {
    return Intl.message(
      'Update the scale\'s firmware via serial port or Wi-Fi.',
      name: 'subTitleFirmwareUpdate',
      desc: 'SubTitle for firmware update',
      args: [],
    );
  }

  /// `Customize the label printing format.`
  String get subTitleLabelDesign {
    return Intl.message(
      'Customize the label printing format.',
      name: 'subTitleLabelDesign',
      desc: 'SubTitle for label design',
      args: [],
    );
  }

  /// `Customize the receipt printing format.`
  String get subTitleReceiptDesign {
    return Intl.message(
      'Customize the receipt printing format.',
      name: 'subTitleReceiptDesign',
      desc: 'SubTitle for receipt design',
      args: [],
    );
  }

  /// `Customize and download serial port output content.`
  String get subTitleSerialOutputDesign {
    return Intl.message(
      'Customize and download serial port output content.',
      name: 'subTitleSerialOutputDesign',
      desc: 'SubTitle for serial output design',
      args: [],
    );
  }

  /// `Read device usage info from scales to understand any abnormal activity.`
  String get subTitleBasicDataCollection {
    return Intl.message(
      'Read device usage info from scales to understand any abnormal activity.',
      name: 'subTitleBasicDataCollection',
      desc: 'SubTitle for basic data collection',
      args: [],
    );
  }

  /// `Configure the Ethernet IP address.`
  String get subTitleWiredSetting {
    return Intl.message(
      'Configure the Ethernet IP address.',
      name: 'subTitleWiredSetting',
      desc: 'SubTitle for wired setting',
      args: [],
    );
  }

  /// `Enable software calibration lock to further prevent device tampering.`
  String get subTitleSealManagment {
    return Intl.message(
      'Enable software calibration lock to further prevent device tampering.',
      name: 'subTitleSealManagment',
      desc: 'SubTitle for seal management',
      args: [],
    );
  }

  /// `Configure device parameters online.`
  String get subTitleParameterSetting {
    return Intl.message(
      'Configure device parameters online.',
      name: 'subTitleParameterSetting',
      desc: 'SubTitle for parameter setting',
      args: [],
    );
  }

  /// `Display weighing data in real-time, supporting basic operations.`
  String get subTitleWeighing {
    return Intl.message(
      'Display weighing data in real-time, supporting basic operations.',
      name: 'subTitleWeighing',
      desc: 'SubTitle for weighing',
      args: [],
    );
  }

  /// `Batch edit and manage PLUs.`
  String get subTitlePluManagement {
    return Intl.message(
      'Batch edit and manage PLUs.',
      name: 'subTitlePluManagement',
      desc: 'SubTitle for PLU management',
      args: [],
    );
  }

  /// `Download label printing format to the scale.`
  String get subTitleLabelFormatDownload {
    return Intl.message(
      'Download label printing format to the scale.',
      name: 'subTitleLabelFormatDownload',
      desc: 'SubTitle for label format download',
      args: [],
    );
  }

  /// `Download receipt printing format to the scale.`
  String get subTitleReceiptFormatDownload {
    return Intl.message(
      'Download receipt printing format to the scale.',
      name: 'subTitleReceiptFormatDownload',
      desc: 'SubTitle for receipt format download',
      args: [],
    );
  }

  /// `Automatically collect, record, and generate reports for retail data.`
  String get subTitleRetailReport {
    return Intl.message(
      'Automatically collect, record, and generate reports for retail data.',
      name: 'subTitleRetailReport',
      desc: 'SubTitle for retail report',
      args: [],
    );
  }

  /// `Perform online weighing and generate weight data reports.`
  String get subTitleWeighingDataCollection {
    return Intl.message(
      'Perform online weighing and generate weight data reports.',
      name: 'subTitleWeighingDataCollection',
      desc: 'SubTitle for weighing data collection',
      args: [],
    );
  }

  /// `Perform online weight inspection and generate inspection reports.`
  String get subTitleCheckWeighing {
    return Intl.message(
      'Perform online weight inspection and generate inspection reports.',
      name: 'subTitleCheckWeighing',
      desc: 'SubTitle for check weighing',
      args: [],
    );
  }

  /// `Record weight increment during loading and generate data reports.`
  String get subTitleIncrementWeighing {
    return Intl.message(
      'Record weight increment during loading and generate data reports.',
      name: 'subTitleIncrementWeighing',
      desc: 'SubTitle for increment weighing',
      args: [],
    );
  }

  /// `Record weight decrement during unloading  and generate data reports.`
  String get subTitleTakeOutScale {
    return Intl.message(
      'Record weight decrement during unloading  and generate data reports.',
      name: 'subTitleTakeOutScale',
      desc: 'SubTitle for take out scale',
      args: [],
    );
  }

  /// `Formula editing, management, online batching, and data generation.`
  String get subTitleFormula {
    return Intl.message(
      'Formula editing, management, online batching, and data generation.',
      name: 'subTitleFormula',
      desc: 'SubTitle for formula',
      args: [],
    );
  }

  /// `Test liquid filling speed and variation trends.`
  String get subTitleFlowRate {
    return Intl.message(
      'Test liquid filling speed and variation trends.',
      name: 'subTitleFlowRate',
      desc: 'SubTitle for liquid filling speed',
      args: [],
    );
  }

  /// `Weighing parameter setting and calibration for the scales.`
  String get subTitleCalibration {
    return Intl.message(
      'Weighing parameter setting and calibration for the scales.',
      name: 'subTitleCalibration',
      desc: 'SubTitle for weighing setting',
      args: [],
    );
  }

  /// `Page`
  String get tipPage {
    return Intl.message(
      'Page',
      name: 'tipPage',
      desc: 'This is a prompt for the page number.',
      args: [],
    );
  }

  /// ``
  String get tipPageSequnce {
    return Intl.message(
      '',
      name: 'tipPageSequnce',
      desc:
          'This is a prompt for the sequence of the page.  The English part needs no translation.',
      args: [],
    );
  }

  /// `Total`
  String get tipPageTotal {
    return Intl.message(
      'Total',
      name: 'tipPageTotal',
      desc: 'This is a prompt for the total number of pages.',
      args: [],
    );
  }

  /// `Items`
  String get tipPageItems {
    return Intl.message(
      'Items',
      name: 'tipPageItems',
      desc: 'This is a prompt for the total number of items.',
      args: [],
    );
  }

  /// `Please select a device first.`
  String get gTipSelectDeviceFirst {
    return Intl.message(
      'Please select a device first.',
      name: 'gTipSelectDeviceFirst',
      desc: 'Please select a device first.',
      args: [],
    );
  }

  /// `No devices available. Please add a device first.`
  String get gTipNoDeviceAddFirst {
    return Intl.message(
      'No devices available. Please add a device first.',
      name: 'gTipNoDeviceAddFirst',
      desc: 'No devices available. Please add a device first.',
      args: [],
    );
  }

  /// `Retrieving the device time, please wait a moment.`
  String get gTipGettingDeviceTime {
    return Intl.message(
      'Retrieving the device time, please wait a moment.',
      name: 'gTipGettingDeviceTime',
      desc: 'Retrieving the device time, please wait a moment.',
      args: [],
    );
  }

  /// `Restart`
  String get btnRestart {
    return Intl.message(
      'Restart',
      name: 'btnRestart',
      desc: 'Button to restart the operation',
      args: [],
    );
  }

  /// `Temporary Save`
  String get btnTemporarySave {
    return Intl.message(
      'Temporary Save',
      name: 'btnTemporarySave',
      desc: 'Button to temporarily save data',
      args: [],
    );
  }

  /// `Formula data error!`
  String get tipFormulaDataError {
    return Intl.message(
      'Formula data error!',
      name: 'tipFormulaDataError',
      desc: 'Error message indicating formula data error',
      args: [],
    );
  }

  /// `No raw material weight data, no need to save temporarily`
  String get tipNoRawMaterialWeightData {
    return Intl.message(
      'No raw material weight data, no need to save temporarily',
      name: 'tipNoRawMaterialWeightData',
      desc: 'Tip indicating no raw material weight data to save temporarily',
      args: [],
    );
  }

  /// `Temporary Storage Record`
  String get tipTemporarySaveFormulaRecord {
    return Intl.message(
      'Temporary Storage Record',
      name: 'tipTemporarySaveFormulaRecord',
      desc: 'Tip indicating temporarily saving formula weighing record',
      args: [],
    );
  }

  /// `Continue Weighing`
  String get btnContinueWeighing {
    return Intl.message(
      'Continue Weighing',
      name: 'btnContinueWeighing',
      desc: 'Button to continue the weighing process',
      args: [],
    );
  }

  /// `Confidential Weighing Mode`
  String get titleConfidentialWeighingMode {
    return Intl.message(
      'Confidential Weighing Mode',
      name: 'titleConfidentialWeighingMode',
      desc: 'Title for confidential weighing mode',
      args: [],
    );
  }

  /// `Please ensure the current weight data is correct. Do you want to continue?`
  String get tipEnsureWeightCorrect {
    return Intl.message(
      'Please ensure the current weight data is correct. Do you want to continue?',
      name: 'tipEnsureWeightCorrect',
      desc:
          'Tip to ensure the current weight data is correct and ask if to continue',
      args: [],
    );
  }

  /// `Temporary weighing records exist.`
  String get formulaDeleteError {
    return Intl.message(
      'Temporary weighing records exist.',
      name: 'formulaDeleteError',
      desc:
          'Error message when deleting a formula indicating that there are temporary weighing records',
      args: [],
    );
  }

  /// `Free formula mode`
  String get btnFreeFormulaMode {
    return Intl.message(
      'Free formula mode',
      name: 'btnFreeFormulaMode',
      desc: 'Button to enter free formula mode',
      args: [],
    );
  }

  /// `Normal mode`
  String get btnNormalMode {
    return Intl.message(
      'Normal mode',
      name: 'btnNormalMode',
      desc: 'Button to enter normal mode',
      args: [],
    );
  }

  /// `The current data is not saved. Confirm to clear and enable the free formula mode?`
  String get fConfirmClearAndEnterFreeModeMsg {
    return Intl.message(
      'The current data is not saved. Confirm to clear and enable the free formula mode?',
      name: 'fConfirmClearAndEnterFreeModeMsg',
      desc:
          'Confirmation message for clearing unsaved data and entering free formula mode',
      args: [],
    );
  }

  /// `Please first stable the weight.`
  String get gTipPleaseStableWeight {
    return Intl.message(
      'Please first stable the weight.',
      name: 'gTipPleaseStableWeight',
      desc: 'Tip to please first stable the weight',
      args: [],
    );
  }

  /// `Username or password error`
  String get tipLoginError {
    return Intl.message(
      'Username or password error',
      name: 'tipLoginError',
      desc: 'Tip for login error',
      args: [],
    );
  }

  /// `Please enter a username`
  String get tipLoginUsernameEmpty {
    return Intl.message(
      'Please enter a username',
      name: 'tipLoginUsernameEmpty',
      desc: 'Tip for empty username',
      args: [],
    );
  }

  /// `Username cannot be empty`
  String get tipLoginUsernameNotEmpty {
    return Intl.message(
      'Username cannot be empty',
      name: 'tipLoginUsernameNotEmpty',
      desc: 'Tip for non-empty username',
      args: [],
    );
  }

  /// `Please enter a password`
  String get tipLoginPasswordEmpty {
    return Intl.message(
      'Please enter a password',
      name: 'tipLoginPasswordEmpty',
      desc: 'Tip for empty password',
      args: [],
    );
  }

  /// `Password cannot be empty`
  String get tipLoginPasswordNotEmpty {
    return Intl.message(
      'Password cannot be empty',
      name: 'tipLoginPasswordNotEmpty',
      desc: 'Tip for non-empty password',
      args: [],
    );
  }

  /// `Login`
  String get btnLogin {
    return Intl.message(
      'Login',
      name: 'btnLogin',
      desc: 'Button for login',
      args: [],
    );
  }

  /// `Remember password`
  String get tipLoginRemember {
    return Intl.message(
      'Remember password',
      name: 'tipLoginRemember',
      desc: 'Tip for remember password',
      args: [],
    );
  }

  /// `Super Admin`
  String get superAdmin {
    return Intl.message(
      'Super Admin',
      name: 'superAdmin',
      desc: 'Super administrator',
      args: [],
    );
  }

  /// `Admin`
  String get admin {
    return Intl.message(
      'Admin',
      name: 'admin',
      desc: 'Administrator',
      args: [],
    );
  }

  /// `Operator`
  String get operator {
    return Intl.message(
      'Operator',
      name: 'operator',
      desc: 'Operator',
      args: [],
    );
  }

  /// `Account`
  String get userAccount {
    return Intl.message(
      'Account',
      name: 'userAccount',
      desc: 'Account',
      args: [],
    );
  }

  /// `User name`
  String get userUsername {
    return Intl.message(
      'User name',
      name: 'userUsername',
      desc: 'Username',
      args: [],
    );
  }

  /// `Role`
  String get userRole {
    return Intl.message('Role', name: 'userRole', desc: 'Role', args: []);
  }

  /// `Phone number`
  String get userPhone {
    return Intl.message(
      'Phone number',
      name: 'userPhone',
      desc: 'Phone number',
      args: [],
    );
  }

  /// `Email`
  String get userEmail {
    return Intl.message('Email', name: 'userEmail', desc: 'Email', args: []);
  }

  /// `Enabled`
  String get userIsEnabled {
    return Intl.message(
      'Enabled',
      name: 'userIsEnabled',
      desc: 'Is enabled',
      args: [],
    );
  }

  /// `Password`
  String get userPassword {
    return Intl.message(
      'Password',
      name: 'userPassword',
      desc: 'Password',
      args: [],
    );
  }

  /// `Confirm password`
  String get userConfirmPassword {
    return Intl.message(
      'Confirm password',
      name: 'userConfirmPassword',
      desc: 'Confirm password',
      args: [],
    );
  }

  /// `New password`
  String get userNewPassword {
    return Intl.message(
      'New password',
      name: 'userNewPassword',
      desc: 'New password',
      args: [],
    );
  }

  /// `Add user`
  String get userAdd {
    return Intl.message(
      'Add user',
      name: 'userAdd',
      desc: 'Add user',
      args: [],
    );
  }

  /// `Edit user`
  String get userUpdate {
    return Intl.message(
      'Edit user',
      name: 'userUpdate',
      desc: 'Update user',
      args: [],
    );
  }

  /// `User management`
  String get userManagement {
    return Intl.message(
      'User management',
      name: 'userManagement',
      desc: 'User management',
      args: [],
    );
  }

  /// `Basic information`
  String get userBasicInfo {
    return Intl.message(
      'Basic information',
      name: 'userBasicInfo',
      desc: 'Basic information',
      args: [],
    );
  }

  /// `Configuration permissions`
  String get userConfigPermissions {
    return Intl.message(
      'Configuration permissions',
      name: 'userConfigPermissions',
      desc: 'Configuration permissions',
      args: [],
    );
  }

  /// `Application permissions`
  String get userAppPermissions {
    return Intl.message(
      'Application permissions',
      name: 'userAppPermissions',
      desc: 'Application permissions',
      args: [],
    );
  }

  /// `Default initial application`
  String get userDefaultApp {
    return Intl.message(
      'Default initial application',
      name: 'userDefaultApp',
      desc: 'Default initial application',
      args: [],
    );
  }

  /// `Password not same`
  String get tipPasswordNotSame {
    return Intl.message(
      'Password not same',
      name: 'tipPasswordNotSame',
      desc: 'Tip for password not same',
      args: [],
    );
  }

  /// `Change password`
  String get titleChangePassword {
    return Intl.message(
      'Change password',
      name: 'titleChangePassword',
      desc: 'Title for change password',
      args: [],
    );
  }

  /// `Logout`
  String get titleLogout {
    return Intl.message(
      'Logout',
      name: 'titleLogout',
      desc: 'Title for logout',
      args: [],
    );
  }

  /// `No permission`
  String get tipNoPermission {
    return Intl.message(
      'No permission',
      name: 'tipNoPermission',
      desc: 'Tip for no permission',
      args: [],
    );
  }

  /// `Account already exists`
  String get tipAccountExist {
    return Intl.message(
      'Account already exists',
      name: 'tipAccountExist',
      desc: 'Tip for account exist',
      args: [],
    );
  }

  /// `Data`
  String get menuData {
    return Intl.message('Data', name: 'menuData', desc: 'Menu data', args: []);
  }

  /// `Format`
  String get menuFormat {
    return Intl.message(
      'Format',
      name: 'menuFormat',
      desc: 'Menu format',
      args: [],
    );
  }

  /// `Please confirm to continue.`
  String get gTipConfirmContinue {
    return Intl.message(
      'Please confirm to continue.',
      name: 'gTipConfirmContinue',
      desc: 'Tip for confirm continue',
      args: [],
    );
  }

  /// `Activate`
  String get gBtnEnable {
    return Intl.message(
      'Activate',
      name: 'gBtnEnable',
      desc: 'Button for activate',
      args: [],
    );
  }

  /// `Deactivate`
  String get gBtnDisable {
    return Intl.message(
      'Deactivate',
      name: 'gBtnDisable',
      desc: 'Button for deactivate',
      args: [],
    );
  }

  /// `Duplicate PLU ignored during import`
  String get gTipImportPluSame {
    return Intl.message(
      'Duplicate PLU ignored during import',
      name: 'gTipImportPluSame',
      desc: 'Tip for import plu same',
      args: [],
    );
  }

  /// `Some PLUs have been deactivated and cannot be downloaded.`
  String get gTipDownPluDisabled {
    return Intl.message(
      'Some PLUs have been deactivated and cannot be downloaded.',
      name: 'gTipDownPluDisabled',
      desc: 'Tip for download plu disabled',
      args: [],
    );
  }

  /// `Input data incomplete`
  String get fInputDataIncomplete {
    return Intl.message(
      'Input data incomplete',
      name: 'fInputDataIncomplete',
      desc: 'Tip for input data incomplete',
      args: [],
    );
  }

  /// `PLU already exists`
  String get fPluExist {
    return Intl.message(
      'PLU already exists',
      name: 'fPluExist',
      desc: 'Tip for plu exist',
      args: [],
    );
  }

  /// `Jump to`
  String get tipJumpPage {
    return Intl.message(
      'Jump to',
      name: 'tipJumpPage',
      desc: 'Tip for jump page',
      args: [],
    );
  }

  /// `Note: This setting requires Bluetooth to be disconnected from other devices!`
  String get tipBluetoothDisconnect {
    return Intl.message(
      'Note: This setting requires Bluetooth to be disconnected from other devices!',
      name: 'tipBluetoothDisconnect',
      desc: 'Tip for bluetooth disconnect',
      args: [],
    );
  }

  /// `Same scale can't connect simultaneously.`
  String get tipSameScale {
    return Intl.message(
      'Same scale can\'t connect simultaneously.',
      name: 'tipSameScale',
      desc: 'Tip for same scale',
      args: [],
    );
  }

  /// `Open File Location`
  String get gBtnOpenFileLocation {
    return Intl.message(
      'Open File Location',
      name: 'gBtnOpenFileLocation',
      desc: 'Button for open file location',
      args: [],
    );
  }

  /// `Open File`
  String get gBtnOpenFile {
    return Intl.message(
      'Open File',
      name: 'gBtnOpenFile',
      desc: 'Button for open file',
      args: [],
    );
  }

  /// `Unknown export error`
  String get gTipExportError {
    return Intl.message(
      'Unknown export error',
      name: 'gTipExportError',
      desc: 'Tip for export error',
      args: [],
    );
  }

  /// `Export file error or file is occupied`
  String get gTipExportFileError {
    return Intl.message(
      'Export file error or file is occupied',
      name: 'gTipExportFileError',
      desc: 'Tip for export file error',
      args: [],
    );
  }

  /// `Export IO error`
  String get gTipExportIOError {
    return Intl.message(
      'Export IO error',
      name: 'gTipExportIOError',
      desc: 'Tip for export IO error',
      args: [],
    );
  }

  /// `No data to import`
  String get noDataImport {
    return Intl.message(
      'No data to import',
      name: 'noDataImport',
      desc: 'Prompt when there is no data to import from Excel file',
      args: [],
    );
  }

  /// ` Please import up to 1000 rows of data at a time`
  String get max1000Rows {
    return Intl.message(
      ' Please import up to 1000 rows of data at a time',
      name: 'max1000Rows',
      desc: 'Prompt when Excel file contains more than 1000 rows',
      args: [],
    );
  }

  /// ` Please import up to 5000 rows of data at a time`
  String get max5000Rows {
    return Intl.message(
      ' Please import up to 5000 rows of data at a time',
      name: 'max5000Rows',
      desc: 'Prompt when Excel file contains more than 5000 rows',
      args: [],
    );
  }

  /// `Missing fields`
  String get missingHeaders {
    return Intl.message(
      'Missing fields',
      name: 'missingHeaders',
      desc: 'Prompt when required headers are missing in Excel file',
      args: [],
    );
  }

  /// `Formula Id is empty`
  String get formulaIdEmpty {
    return Intl.message(
      'Formula Id is empty',
      name: 'formulaIdEmpty',
      desc: 'Prompt when Formula Id cell is empty',
      args: [],
    );
  }

  /// `already exists`
  String get formulaIdExists {
    return Intl.message(
      'already exists',
      name: 'formulaIdExists',
      desc: 'Prompt when Formula Id already exists in the system',
      args: [],
    );
  }

  /// `Formula Barcode already exists`
  String get formulaBarcodeExists {
    return Intl.message(
      'Formula Barcode already exists',
      name: 'formulaBarcodeExists',
      desc: 'Prompt when Formula Barcode already exists in the system',
      args: [],
    );
  }

  /// `Formula Name is empty`
  String get formulaNameEmpty {
    return Intl.message(
      'Formula Name is empty',
      name: 'formulaNameEmpty',
      desc: 'Prompt when Formula Name cell is empty',
      args: [],
    );
  }

  /// `Mode is empty`
  String get modeEmpty {
    return Intl.message(
      'Mode is empty',
      name: 'modeEmpty',
      desc: 'Prompt when Mode cell is empty',
      args: [],
    );
  }

  /// `Mode must be weight or percent`
  String get modeInvalid {
    return Intl.message(
      'Mode must be weight or percent',
      name: 'modeInvalid',
      desc: 'Prompt when Mode value is invalid',
      args: [],
    );
  }

  /// `Weight Unit cannot be empty when Mode is weight`
  String get weightUnitEmpty {
    return Intl.message(
      'Weight Unit cannot be empty when Mode is weight',
      name: 'weightUnitEmpty',
      desc: 'Prompt when Weight Unit is required for weight mode',
      args: [],
    );
  }

  /// `Ingredient Id is empty`
  String get ingredientIdEmpty {
    return Intl.message(
      'Ingredient Id is empty',
      name: 'ingredientIdEmpty',
      desc: 'Prompt when Ingredient Id cell is empty',
      args: [],
    );
  }

  /// `Ingredient Id does not exist,please import Ingredient first`
  String get ingredientIdNotExist {
    return Intl.message(
      'Ingredient Id does not exist,please import Ingredient first',
      name: 'ingredientIdNotExist',
      desc: 'Prompt when Ingredient Id is not found in the system',
      args: [],
    );
  }

  /// `Ingredient Weight/Percent is empty`
  String get weightPercentEmpty {
    return Intl.message(
      'Ingredient Weight/Percent is empty',
      name: 'weightPercentEmpty',
      desc: 'Prompt when Weight/Percent cell is empty',
      args: [],
    );
  }

  /// `Weight/Percent should > 0 and up to 3 decimal places`
  String get weightPercentInvalid {
    return Intl.message(
      'Weight/Percent should > 0 and up to 3 decimal places',
      name: 'weightPercentInvalid',
      desc: 'Prompt when Weight/Percent value is invalid',
      args: [],
    );
  }

  /// `Allow Error is empty`
  String get allowErrorEmpty {
    return Intl.message(
      'Allow Error is empty',
      name: 'allowErrorEmpty',
      desc: 'Prompt when Allow Error cell is empty',
      args: [],
    );
  }

  /// `Allow Error should > 0 and up to 3 decimal places`
  String get allowErrorInvalid {
    return Intl.message(
      'Allow Error should > 0 and up to 3 decimal places',
      name: 'allowErrorInvalid',
      desc: 'Prompt when Allow Error value is invalid',
      args: [],
    );
  }

  /// `Formula names are inconsistent`
  String get formulaNameInconsistent {
    return Intl.message(
      'Formula names are inconsistent',
      name: 'formulaNameInconsistent',
      desc: 'Prompt when formula names within the same group are inconsistent',
      args: [],
    );
  }

  /// `Barcodes are inconsistent`
  String get formulaBarcodeInconsistent {
    return Intl.message(
      'Barcodes are inconsistent',
      name: 'formulaBarcodeInconsistent',
      desc:
          'Prompt when formula barcodes within the same group are inconsistent',
      args: [],
    );
  }

  /// `Total percentage is not 100%`
  String get percentNot100 {
    return Intl.message(
      'Total percentage is not 100%',
      name: 'percentNot100',
      desc: 'Prompt when percentage total is not 100%',
      args: [],
    );
  }

  /// `row`
  String get tipRow {
    return Intl.message('row', name: 'tipRow', desc: 'Row tip', args: []);
  }

  /// `Checking completed, importing...`
  String get tipImporting {
    return Intl.message(
      'Checking completed, importing...',
      name: 'tipImporting',
      desc: 'Tip for importing',
      args: [],
    );
  }

  /// `Ingredient Id cannot be empty`
  String get ingredientIdIsEmpty {
    return Intl.message(
      'Ingredient Id cannot be empty',
      name: 'ingredientIdIsEmpty',
      desc: 'Prompt when Ingredient Id field is required',
      args: [],
    );
  }

  /// `Device Name does not exist`
  String get deviceNameNotExist {
    return Intl.message(
      'Device Name does not exist',
      name: 'deviceNameNotExist',
      desc: 'Prompt when specified Device Name is not found in the system',
      args: [],
    );
  }

  /// `Ingredient Name cannot be empty`
  String get ingredientNameEmpty {
    return Intl.message(
      'Ingredient Name cannot be empty',
      name: 'ingredientNameEmpty',
      desc: 'Prompt when Ingredient Name field is required',
      args: [],
    );
  }

  /// `Select Device`
  String get selectDevice {
    return Intl.message(
      'Select Device',
      name: 'selectDevice',
      desc: 'Select Device',
      args: [],
    );
  }

  /// `In-use ingredients are protected from deletion. Continue?`
  String get deleteRawInUseConfirm {
    return Intl.message(
      'In-use ingredients are protected from deletion. Continue?',
      name: 'deleteRawInUseConfirm',
      desc: 'Confirm deletion of ingredients currently not in use',
      args: [],
    );
  }

  /// `Deleting the formula will clear its draft records. Continue?`
  String get deleteFormulaWithDraftConfirm {
    return Intl.message(
      'Deleting the formula will clear its draft records. Continue?',
      name: 'deleteFormulaWithDraftConfirm',
      desc: 'Confirm deletion of formula and associated drafts',
      args: [],
    );
  }

  /// `Finish`
  String get finishBtn {
    return Intl.message(
      'Finish',
      name: 'finishBtn',
      desc: 'This is a finish button.',
      args: [],
    );
  }

  /// `Duplicate headers`
  String get duplicateHeaders {
    return Intl.message(
      'Duplicate headers',
      name: 'duplicateHeaders',
      desc: 'Prompt when duplicate headers are found in Excel file',
      args: [],
    );
  }

  /// `Validating data...`
  String get tipValidating {
    return Intl.message(
      'Validating data...',
      name: 'tipValidating',
      desc: 'Tip for validating data',
      args: [],
    );
  }

  /// `Are you sure you want to delete all unused types?`
  String get deleteTypeUnusedConfirm {
    return Intl.message(
      'Are you sure you want to delete all unused types?',
      name: 'deleteTypeUnusedConfirm',
      desc: 'Confirm deletion of types currently not in use',
      args: [],
    );
  }

  /// `Module`
  String get module {
    return Intl.message('Module', name: 'module', desc: 'Module', args: []);
  }

  /// `Function Module`
  String get funcName {
    return Intl.message(
      'Function Module',
      name: 'funcName',
      desc: 'Function Module',
      args: [],
    );
  }

  /// `Operation Type`
  String get operationType {
    return Intl.message(
      'Operation Type',
      name: 'operationType',
      desc: 'Operation Type',
      args: [],
    );
  }

  /// `Details`
  String get operation {
    return Intl.message(
      'Details',
      name: 'operation',
      desc: 'Details of the operation',
      args: [],
    );
  }

  /// `Result`
  String get operationResult {
    return Intl.message(
      'Result',
      name: 'operationResult',
      desc: 'Operation Result',
      args: [],
    );
  }

  /// `Log Management`
  String get logManagement {
    return Intl.message(
      'Log Management',
      name: 'logManagement',
      desc: 'Log Management',
      args: [],
    );
  }

  /// `System Records`
  String get systemRecords {
    return Intl.message(
      'System Records',
      name: 'systemRecords',
      desc: 'System Records',
      args: [],
    );
  }

  /// `Calibration Records`
  String get calibrationRecords {
    return Intl.message(
      'Calibration Records',
      name: 'calibrationRecords',
      desc: 'Calibration Records',
      args: [],
    );
  }

  /// `Weighing Records`
  String get weighingRecords {
    return Intl.message(
      'Weighing Records',
      name: 'weighingRecords',
      desc: 'Weighing Records',
      args: [],
    );
  }

  /// `Delete Log`
  String get deleteLog {
    return Intl.message(
      'Delete Log',
      name: 'deleteLog',
      desc: 'Delete Log',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: 'Delete', args: []);
  }

  /// `Success`
  String get success {
    return Intl.message('Success', name: 'success', desc: 'Success', args: []);
  }

  /// `Failure`
  String get failure {
    return Intl.message('Failure', name: 'failure', desc: 'Failure', args: []);
  }

  /// `System Operation`
  String get systemOperation {
    return Intl.message(
      'System Operation',
      name: 'systemOperation',
      desc: 'System Operation',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: 'Login', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: 'Logout', args: []);
  }

  /// `Log Details`
  String get logDetails {
    return Intl.message(
      'Log Details',
      name: 'logDetails',
      desc: 'Log Details',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: 'Search', args: []);
  }

  /// `Selected`
  String get selected {
    return Intl.message(
      'Selected',
      name: 'selected',
      desc: 'Selected',
      args: [],
    );
  }

  /// `Update`
  String get opUpdate {
    return Intl.message(
      'Update',
      name: 'opUpdate',
      desc: 'Update Operation',
      args: [],
    );
  }

  /// `Enable`
  String get opEnable {
    return Intl.message(
      'Enable',
      name: 'opEnable',
      desc: 'Enable Operation',
      args: [],
    );
  }

  /// `Query`
  String get opQuery {
    return Intl.message(
      'Query',
      name: 'opQuery',
      desc: 'Query Operation',
      args: [],
    );
  }

  /// `Download`
  String get opIssue {
    return Intl.message(
      'Download',
      name: 'opIssue',
      desc: 'Download Operation',
      args: [],
    );
  }

  /// `Import`
  String get opImport {
    return Intl.message(
      'Import',
      name: 'opImport',
      desc: 'Import Operation',
      args: [],
    );
  }

  /// `Export`
  String get opExport {
    return Intl.message(
      'Export',
      name: 'opExport',
      desc: 'Export Operation',
      args: [],
    );
  }

  /// `Setting`
  String get opSetting {
    return Intl.message(
      'Setting',
      name: 'opSetting',
      desc: 'Setting Operation',
      args: [],
    );
  }

  /// `Upload`
  String get opUpload {
    return Intl.message(
      'Upload',
      name: 'opUpload',
      desc: 'Upload Operation',
      args: [],
    );
  }

  /// `Enable or Disable`
  String get enableOrDisable {
    return Intl.message(
      'Enable or Disable',
      name: 'enableOrDisable',
      desc: 'Whether to enable or disable',
      args: [],
    );
  }

  /// `Add Formula`
  String get addFormula {
    return Intl.message(
      'Add Formula',
      name: 'addFormula',
      desc: 'Add formula',
      args: [],
    );
  }

  /// `Delete Formula`
  String get deleteFormula {
    return Intl.message(
      'Delete Formula',
      name: 'deleteFormula',
      desc: 'Delete formula',
      args: [],
    );
  }

  /// `Modify Formula`
  String get modifyFormula {
    return Intl.message(
      'Modify Formula',
      name: 'modifyFormula',
      desc: 'Modify formula',
      args: [],
    );
  }

  /// `Add Formula Category`
  String get addFormulaCategory {
    return Intl.message(
      'Add Formula Category',
      name: 'addFormulaCategory',
      desc: 'Add formula category',
      args: [],
    );
  }

  /// `Delete Formula Category`
  String get deleteFormulaCategory {
    return Intl.message(
      'Delete Formula Category',
      name: 'deleteFormulaCategory',
      desc: 'Delete formula category',
      args: [],
    );
  }

  /// `Modify Formula Category`
  String get modifyFormulaCategory {
    return Intl.message(
      'Modify Formula Category',
      name: 'modifyFormulaCategory',
      desc: 'Modify formula category',
      args: [],
    );
  }

  /// `Clear Unused Formula Category`
  String get clearUnusedFormulaCategory {
    return Intl.message(
      'Clear Unused Formula Category',
      name: 'clearUnusedFormulaCategory',
      desc: 'Clear unused formula category',
      args: [],
    );
  }

  /// `Add Ingredient Category`
  String get addIngredientCategory {
    return Intl.message(
      'Add Ingredient Category',
      name: 'addIngredientCategory',
      desc: 'Add ingredient category',
      args: [],
    );
  }

  /// `Delete Ingredient Category`
  String get deleteIngredientCategory {
    return Intl.message(
      'Delete Ingredient Category',
      name: 'deleteIngredientCategory',
      desc: 'Delete ingredient category',
      args: [],
    );
  }

  /// `Modify Ingredient Category`
  String get modifyIngredientCategory {
    return Intl.message(
      'Modify Ingredient Category',
      name: 'modifyIngredientCategory',
      desc: 'Modify ingredient category',
      args: [],
    );
  }

  /// `Clear Unused Ingredient Category`
  String get clearUnusedIngredientCategory {
    return Intl.message(
      'Clear Unused Ingredient Category',
      name: 'clearUnusedIngredientCategory',
      desc: 'Clear unused ingredient category',
      args: [],
    );
  }

  /// `Add Ingredient`
  String get addIngredient {
    return Intl.message(
      'Add Ingredient',
      name: 'addIngredient',
      desc: 'Add ingredient',
      args: [],
    );
  }

  /// `Delete Ingredient`
  String get deleteIngredient {
    return Intl.message(
      'Delete Ingredient',
      name: 'deleteIngredient',
      desc: 'Delete ingredient',
      args: [],
    );
  }

  /// `Modify Ingredient`
  String get modifyIngredient {
    return Intl.message(
      'Modify Ingredient',
      name: 'modifyIngredient',
      desc: 'Modify ingredient',
      args: [],
    );
  }

  /// `Add Formula Weighing Record`
  String get addFormulaWeighingRecord {
    return Intl.message(
      'Add Formula Weighing Record',
      name: 'addFormulaWeighingRecord',
      desc: 'Add formula weighing record',
      args: [],
    );
  }

  /// `Delete Formula Weighing Record`
  String get deleteFormulaWeighingRecord {
    return Intl.message(
      'Delete Formula Weighing Record',
      name: 'deleteFormulaWeighingRecord',
      desc: 'Delete formula weighing record',
      args: [],
    );
  }

  /// `Add Temporary Weighing Record`
  String get addTemporaryWeighingRecord {
    return Intl.message(
      'Add Temporary Weighing Record',
      name: 'addTemporaryWeighingRecord',
      desc: 'Add temporary weighing record',
      args: [],
    );
  }

  /// `Delete Temporary Weighing Record`
  String get deleteTemporaryWeighingRecord {
    return Intl.message(
      'Delete Temporary Weighing Record',
      name: 'deleteTemporaryWeighingRecord',
      desc: 'Delete temporary weighing record',
      args: [],
    );
  }

  /// `Modify Temporary Weighing Record`
  String get modifyTemporaryWeighingRecord {
    return Intl.message(
      'Modify Temporary Weighing Record',
      name: 'modifyTemporaryWeighingRecord',
      desc: 'Modify temporary weighing record',
      args: [],
    );
  }

  /// `Upload Formula Weighing Record`
  String get uploadFmaWgtRecord {
    return Intl.message(
      'Upload Formula Weighing Record',
      name: 'uploadFmaWgtRecord',
      desc: 'Upload formula weighing record',
      args: [],
    );
  }

  /// `Set Time`
  String get setTime {
    return Intl.message(
      'Set Time',
      name: 'setTime',
      desc: 'Set time',
      args: [],
    );
  }

  /// `Set Name`
  String get setName {
    return Intl.message(
      'Set Name',
      name: 'setName',
      desc: 'Set name',
      args: [],
    );
  }

  /// `Set Power`
  String get setPower {
    return Intl.message(
      'Set Power',
      name: 'setPower',
      desc: 'Set power',
      args: [],
    );
  }

  /// `Calibration Type`
  String get calibrationType {
    return Intl.message(
      'Calibration Type',
      name: 'calibrationType',
      desc: 'Calibration Type',
      args: [],
    );
  }

  /// `Calibration Mode`
  String get calibrationMode {
    return Intl.message(
      'Calibration Mode',
      name: 'calibrationMode',
      desc: 'Calibration Mode',
      args: [],
    );
  }

  /// `Calibration Value`
  String get calibrationValue {
    return Intl.message(
      'Calibration Value',
      name: 'calibrationValue',
      desc: 'Calibration Value',
      args: [],
    );
  }

  /// `Weight Before Calibration`
  String get weightBeforeCalibration {
    return Intl.message(
      'Weight Before Calibration',
      name: 'weightBeforeCalibration',
      desc: 'Weight Before Calibration',
      args: [],
    );
  }

  /// `Weight After Calibration`
  String get weightAfterCalibration {
    return Intl.message(
      'Weight After Calibration',
      name: 'weightAfterCalibration',
      desc: 'Weight After Calibration',
      args: [],
    );
  }

  /// `Calibration Error`
  String get calibrationError {
    return Intl.message(
      'Calibration Error',
      name: 'calibrationError',
      desc: 'Calibration Error',
      args: [],
    );
  }

  /// `Single Point`
  String get singlePoint {
    return Intl.message(
      'Single Point',
      name: 'singlePoint',
      desc: 'Single Point Calibration',
      args: [],
    );
  }

  /// `Multi Point`
  String get multiPoint {
    return Intl.message(
      'Multi Point',
      name: 'multiPoint',
      desc: 'Multi Point Calibration',
      args: [],
    );
  }

  /// `Set up the Super Admin account before creating new accounts.`
  String get pleaseSetSuperAdmin {
    return Intl.message(
      'Set up the Super Admin account before creating new accounts.',
      name: 'pleaseSetSuperAdmin',
      desc: 'Please set super administrator account',
      args: [],
    );
  }

  /// `All data will be cleared. Please confirm ...`
  String get fClearDataBtn {
    return Intl.message(
      'All data will be cleared. Please confirm ...',
      name: 'fClearDataBtn',
      desc: 'Clear all data',
      args: [],
    );
  }

  /// `All PLU will be erased and reloaded. Continue?`
  String get downAllPluTip {
    return Intl.message(
      'All PLU will be erased and reloaded. Continue?',
      name: 'downAllPluTip',
      desc: 'Download all PLU',
      args: [],
    );
  }

  /// `Confirm force clear tare? Please ensure the scale pan is empty.`
  String get tipForceClearTare {
    return Intl.message(
      'Confirm force clear tare? Please ensure the scale pan is empty.',
      name: 'tipForceClearTare',
      desc: 'Force clear tare',
      args: [],
    );
  }

  /// `Force clear tare`
  String get btnForceClearTare {
    return Intl.message(
      'Force clear tare',
      name: 'btnForceClearTare',
      desc: 'Force clear tare',
      args: [],
    );
  }

  /// `No data`
  String get noBarCodeDataTip {
    return Intl.message(
      'No data',
      name: 'noBarCodeDataTip',
      desc: 'No data',
      args: [],
    );
  }

  /// `Search Name`
  String get searchName {
    return Intl.message(
      'Search Name',
      name: 'searchName',
      desc: 'Label for search name field',
      args: [],
    );
  }

  /// `The name is invalid. Please enter a valid name.`
  String get invalidName {
    return Intl.message(
      'The name is invalid. Please enter a valid name.',
      name: 'invalidName',
      desc: 'Error message for invalid name input',
      args: [],
    );
  }

  /// `Content missing.`
  String get contentMissing {
    return Intl.message(
      'Content missing.',
      name: 'contentMissing',
      desc: 'Error message when content is missing',
      args: [],
    );
  }

  /// `Variable alignment cannot be empty or have a length of 0. Please check.`
  String get variableAlignmentEmpty {
    return Intl.message(
      'Variable alignment cannot be empty or have a length of 0. Please check.',
      name: 'variableAlignmentEmpty',
      desc: 'Error message when variable alignment is empty',
      args: [],
    );
  }

  /// `The name already exists. Please check.`
  String get nameAlreadyExists {
    return Intl.message(
      'The name already exists. Please check.',
      name: 'nameAlreadyExists',
      desc: 'Error message when name already exists',
      args: [],
    );
  }

  /// `The name not entered or content is empty, please check!`
  String get nameNotEntered {
    return Intl.message(
      'The name not entered or content is empty, please check!',
      name: 'nameNotEntered',
      desc: 'Error message when name is not entered',
      args: [],
    );
  }

  /// `The content does not meet barcode requirements!`
  String get contentNotMeetBarcode {
    return Intl.message(
      'The content does not meet barcode requirements!',
      name: 'contentNotMeetBarcode',
      desc: 'Error message when content doesn\'t meet barcode requirements',
      args: [],
    );
  }

  /// `The default value does not meet barcode requirements!`
  String get defaultValueNotMeetBarcode {
    return Intl.message(
      'The default value does not meet barcode requirements!',
      name: 'defaultValueNotMeetBarcode',
      desc:
          'Error message when default value doesn\'t meet barcode requirements',
      args: [],
    );
  }

  /// `Barcode exceeds maximum length`
  String get barcodeExceedsMaxLengthShort {
    return Intl.message(
      'Barcode exceeds maximum length',
      name: 'barcodeExceedsMaxLengthShort',
      desc: 'Short error message when barcode exceeds maximum length',
      args: [],
    );
  }

  /// `The length of the barcode should be`
  String get barcodeLengthShouldBe {
    return Intl.message(
      'The length of the barcode should be',
      name: 'barcodeLengthShouldBe',
      desc: 'Message indicating the required barcode length',
      args: [],
    );
  }

  /// `Saved successfully!`
  String get savedSuccessfully {
    return Intl.message(
      'Saved successfully!',
      name: 'savedSuccessfully',
      desc: 'Success message when data is saved successfully',
      args: [],
    );
  }

  /// `Ingredient Verification`
  String get ingredientVerification {
    return Intl.message(
      'Ingredient Verification',
      name: 'ingredientVerification',
      desc: 'Ingredient Verification',
      args: [],
    );
  }

  /// `Skip Ingredient`
  String get skipThisIngredient {
    return Intl.message(
      'Skip Ingredient',
      name: 'skipThisIngredient',
      desc: 'Skip this ingredient',
      args: [],
    );
  }

  /// `No permission`
  String get noPermission {
    return Intl.message(
      'No permission',
      name: 'noPermission',
      desc: 'No permission',
      args: [],
    );
  }

  /// `Disable Ingredient Verification`
  String get disableIngredientVerification {
    return Intl.message(
      'Disable Ingredient Verification',
      name: 'disableIngredientVerification',
      desc: 'Toggle ingredient verification',
      args: [],
    );
  }

  /// `Enable Ingredient Verification`
  String get enableIngredientVerification {
    return Intl.message(
      'Enable Ingredient Verification',
      name: 'enableIngredientVerification',
      desc: 'Toggle ingredient verification',
      args: [],
    );
  }

  /// `Verification code`
  String get verificationCode {
    return Intl.message(
      'Verification code',
      name: 'verificationCode',
      desc: 'Label for verification code field',
      args: [],
    );
  }

  /// `Network`
  String get gNetwork {
    return Intl.message('Network', name: 'gNetwork', desc: 'Network', args: []);
  }

  /// `IP address and port is already in use`
  String get ipAddressAndPortIsAlreadyInUse {
    return Intl.message(
      'IP address and port is already in use',
      name: 'ipAddressAndPortIsAlreadyInUse',
      desc: 'Error message when IP address and port are already in use',
      args: [],
    );
  }

  /// `Auto Sync`
  String get autoSync {
    return Intl.message(
      'Auto Sync',
      name: 'autoSync',
      desc: 'Auto Sync',
      args: [],
    );
  }

  /// `Enable Record Auto Sync`
  String get enableRecordAutoSync {
    return Intl.message(
      'Enable Record Auto Sync',
      name: 'enableRecordAutoSync',
      desc: 'Enable Record Auto Sync',
      args: [],
    );
  }

  /// `Shared Folder Path`
  String get sharedFolderPath {
    return Intl.message(
      'Shared Folder Path',
      name: 'sharedFolderPath',
      desc: 'Shared Folder Path',
      args: [],
    );
  }

  /// `Verification code mismatch, please scan again`
  String get verificationCodeMismatch {
    return Intl.message(
      'Verification code mismatch, please scan again',
      name: 'verificationCodeMismatch',
      desc: 'Verification code mismatch',
      args: [],
    );
  }

  /// `Print Settings`
  String get printSettings {
    return Intl.message(
      'Print Settings',
      name: 'printSettings',
      desc: '',
      args: [],
    );
  }

  /// `Print`
  String get gPrint {
    return Intl.message('Print', name: 'gPrint', desc: 'Print', args: []);
  }

  /// `Set Static IP`
  String get setStaticIP {
    return Intl.message(
      'Set Static IP',
      name: 'setStaticIP',
      desc: 'Action to configure a static IP address',
      args: [],
    );
  }

  /// `Set IP Success`
  String get setIPSuccess {
    return Intl.message(
      'Set IP Success',
      name: 'setIPSuccess',
      desc: 'Success message when IP configuration is applied successfully',
      args: [],
    );
  }

  /// `Set IP Failed`
  String get setIPFailed {
    return Intl.message(
      'Set IP Failed',
      name: 'setIPFailed',
      desc: 'Error message when IP configuration fails',
      args: [],
    );
  }

  /// `Set DHCP Success`
  String get setDHCPSuccess {
    return Intl.message(
      'Set DHCP Success',
      name: 'setDHCPSuccess',
      desc: 'Success message when DHCP configuration is applied successfully',
      args: [],
    );
  }

  /// `Set DHCP Failed`
  String get setDHCPFailed {
    return Intl.message(
      'Set DHCP Failed',
      name: 'setDHCPFailed',
      desc: 'Error message when DHCP configuration fails',
      args: [],
    );
  }

  /// `Please wait 2 seconds...`
  String get pleaseWait {
    return Intl.message(
      'Please wait 2 seconds...',
      name: 'pleaseWait',
      desc: 'Please wait message',
      args: [],
    );
  }

  /// `Hardware Calibration Switch`
  String get hardwareSeal {
    return Intl.message(
      'Hardware Calibration Switch',
      name: 'hardwareSeal',
      desc: 'Term for a hardware-based tamper-proof seal',
      args: [],
    );
  }

  /// `Software Calibration Lock`
  String get softwareSeal {
    return Intl.message(
      'Software Calibration Lock',
      name: 'softwareSeal',
      desc: 'Term for a software-based tamper-proof seal',
      args: [],
    );
  }

  /// `To be verified`
  String get toBeVerified {
    return Intl.message(
      'To be verified',
      name: 'toBeVerified',
      desc: 'Status indicating an item is pending verification',
      args: [],
    );
  }

  /// `Check Status`
  String get checkSeal {
    return Intl.message(
      'Check Status',
      name: 'checkSeal',
      desc: 'Action to inspect or verify the seal status',
      args: [],
    );
  }

  /// `On`
  String get sealed {
    return Intl.message(
      'On',
      name: 'sealed',
      desc: 'Status indicating the device has been sealed',
      args: [],
    );
  }

  /// `Off`
  String get notSealed {
    return Intl.message(
      'Off',
      name: 'notSealed',
      desc: 'Status indicating the device is not sealed',
      args: [],
    );
  }

  /// `Locked`
  String get softwareLocked {
    return Intl.message(
      'Locked',
      name: 'softwareLocked',
      desc: 'Status indicating the software lock is applied',
      args: [],
    );
  }

  /// `Unlocked`
  String get softwareUnlocked {
    return Intl.message(
      'Unlocked',
      name: 'softwareUnlocked',
      desc: 'Status indicating the software lock is removed',
      args: [],
    );
  }

  /// `Common`
  String get commonApp {
    return Intl.message(
      'Common',
      name: 'commonApp',
      desc: 'Common Application',
      args: [],
    );
  }

  /// `Example: 55x50mm label, EPM205 printer. The first line shows net weight and unit, the second line shows a dividing line, and the bottom shows a barcode.`
  String get aiDesignHintText {
    return Intl.message(
      'Example: 55x50mm label, EPM205 printer. The first line shows net weight and unit, the second line shows a dividing line, and the bottom shows a barcode.',
      name: 'aiDesignHintText',
      desc: 'Hint text for AI design prompt input',
      args: [],
    );
  }

  /// `Enable Software Calibration Lock`
  String get applySoftwareSeal {
    return Intl.message(
      'Enable Software Calibration Lock',
      name: 'applySoftwareSeal',
      desc: 'Action to apply a software seal to the device',
      args: [],
    );
  }

  /// `Disable Software Calibration Lock`
  String get removeSoftwareSeal {
    return Intl.message(
      'Disable Software Calibration Lock',
      name: 'removeSoftwareSeal',
      desc: 'Action to remove a software seal from the device',
      args: [],
    );
  }

  /// `Software Calibration Lock Enabled Successfully`
  String get softwareSealAppliedSuccessfully {
    return Intl.message(
      'Software Calibration Lock Enabled Successfully',
      name: 'softwareSealAppliedSuccessfully',
      desc: 'Success message when a software seal is successfully applied',
      args: [],
    );
  }

  /// `Software Calibration Lock Enable Failed`
  String get softwareSealAppliedFailed {
    return Intl.message(
      'Software Calibration Lock Enable Failed',
      name: 'softwareSealAppliedFailed',
      desc: 'Error message when a software seal application fails',
      args: [],
    );
  }

  /// `Software Calibration Lock Disabled Successfully`
  String get softwareSealRemovedSuccessfully {
    return Intl.message(
      'Software Calibration Lock Disabled Successfully',
      name: 'softwareSealRemovedSuccessfully',
      desc: 'Success message when a software seal is successfully removed',
      args: [],
    );
  }

  /// `Software Calibration Lock Disable Failed. \r\nPlease retry. If the issue persists, contact your supplier for an unlock code.`
  String get softwareSealRemovalFailed {
    return Intl.message(
      'Software Calibration Lock Disable Failed. \r\nPlease retry. If the issue persists, contact your supplier for an unlock code.',
      name: 'softwareSealRemovalFailed',
      desc:
          'Error message when software seal removal fails, prompting for a retry or removal code',
      args: [],
    );
  }

  /// `Disable with Unlock Code`
  String get removeWithCode {
    return Intl.message(
      'Disable with Unlock Code',
      name: 'removeWithCode',
      desc: 'Option or button to remove a seal using a special code',
      args: [],
    );
  }

  /// `Check Status Failed`
  String get checkSealFailed {
    return Intl.message(
      'Check Status Failed',
      name: 'checkSealFailed',
      desc: 'Error message when checking the seal status fails',
      args: [],
    );
  }

  /// `Contact your supplier for a removal code`
  String get contactSupplierForRemovalCode {
    return Intl.message(
      'Contact your supplier for a removal code',
      name: 'contactSupplierForRemovalCode',
      desc: 'Prompt to contact the supplier for a removal code',
      args: [],
    );
  }

  /// `Enable Software Calibration Lock`
  String get fTipSeal {
    return Intl.message(
      'Enable Software Calibration Lock',
      name: 'fTipSeal',
      desc: 'Seal',
      args: [],
    );
  }

  /// `Disable Software Calibration Lock`
  String get fTipUnseal {
    return Intl.message(
      'Disable Software Calibration Lock',
      name: 'fTipUnseal',
      desc: 'Unseal',
      args: [],
    );
  }

  /// `Invalid Data`
  String get invalidData {
    return Intl.message(
      'Invalid Data',
      name: 'invalidData',
      desc: 'Error message for invalid data input',
      args: [],
    );
  }

  /// `Data Expired`
  String get dataExpired {
    return Intl.message(
      'Data Expired',
      name: 'dataExpired',
      desc: 'Error message for expired data input',
      args: [],
    );
  }

  /// `Please re-acquire the advanced configuration authorization code.`
  String get reAcquireAuthCode {
    return Intl.message(
      'Please re-acquire the advanced configuration authorization code.',
      name: 'reAcquireAuthCode',
      desc:
          'Prompt to re-acquire the advanced configuration authorization code',
      args: [],
    );
  }

  /// `Software Calibration Lock Disable Failed`
  String get removeSealFailed {
    return Intl.message(
      'Software Calibration Lock Disable Failed',
      name: 'removeSealFailed',
      desc: 'Error message when removing the software seal fails',
      args: [],
    );
  }

  /// `Bluetooth`
  String get bluetooth {
    return Intl.message(
      'Bluetooth',
      name: 'bluetooth',
      desc: 'Bluetooth',
      args: [],
    );
  }

  /// `No bluetooth devices found`
  String get noBluetoothDevicesFound {
    return Intl.message(
      'No bluetooth devices found',
      name: 'noBluetoothDevicesFound',
      desc: 'No Bluetooth devices found',
      args: [],
    );
  }

  /// `Please ensure Bluetooth is enabled`
  String get ensureBluetoothIsEnabled {
    return Intl.message(
      'Please ensure Bluetooth is enabled',
      name: 'ensureBluetoothIsEnabled',
      desc: 'Please ensure Bluetooth is enabled',
      args: [],
    );
  }

  /// `Bluetooth name`
  String get bluetoothName {
    return Intl.message(
      'Bluetooth name',
      name: 'bluetoothName',
      desc: 'Bluetooth name',
      args: [],
    );
  }

  /// `Bluetooth address`
  String get bluetoothAddress {
    return Intl.message(
      'Bluetooth address',
      name: 'bluetoothAddress',
      desc: 'Bluetooth address',
      args: [],
    );
  }

  /// `Scan for Bluetooth devices`
  String get scanBluetoothDevices {
    return Intl.message(
      'Scan for Bluetooth devices',
      name: 'scanBluetoothDevices',
      desc: 'Scan for Bluetooth devices',
      args: [],
    );
  }

  /// `Searching for nearby Bluetooth devices - this may take up to 20 seconds`
  String get searchingBluetoothDevices {
    return Intl.message(
      'Searching for nearby Bluetooth devices - this may take up to 20 seconds',
      name: 'searchingBluetoothDevices',
      desc:
          'Searching for nearby Bluetooth devices - this may take up to 20 seconds',
      args: [],
    );
  }

  /// `Start searching for Bluetooth devices`
  String get startSearchBluetoothDevices {
    return Intl.message(
      'Start searching for Bluetooth devices',
      name: 'startSearchBluetoothDevices',
      desc: 'Start searching for Bluetooth devices',
      args: [],
    );
  }

  /// `I/O Setting`
  String get ioSetting {
    return Intl.message(
      'I/O Setting',
      name: 'ioSetting',
      desc: 'I/O Setting',
      args: [],
    );
  }

  /// `I/O Port`
  String get ioPort {
    return Intl.message('I/O Port', name: 'ioPort', desc: 'I/O Port', args: []);
  }

  /// `Output Port`
  String get outputPort {
    return Intl.message(
      'Output Port',
      name: 'outputPort',
      desc: 'Output Port',
      args: [],
    );
  }

  /// `Delayed Start`
  String get delayedStart {
    return Intl.message(
      'Delayed Start',
      name: 'delayedStart',
      desc: 'Delayed Start',
      args: [],
    );
  }

  /// `Trigger off value`
  String get triggerOffValue {
    return Intl.message(
      'Trigger off value',
      name: 'triggerOffValue',
      desc: 'Trigger off value',
      args: [],
    );
  }

  /// `Failed to open the output port.`
  String get openOutputPortFailed {
    return Intl.message(
      'Failed to open the output port.',
      name: 'openOutputPortFailed',
      desc: 'Failed to open the output port.',
      args: [],
    );
  }

  /// `Input Setting`
  String get inputSetting {
    return Intl.message(
      'Input Setting',
      name: 'inputSetting',
      desc: 'Input Setting',
      args: [],
    );
  }

  /// `Output Setting`
  String get outputSetting {
    return Intl.message(
      'Output Setting',
      name: 'outputSetting',
      desc: 'Output Setting',
      args: [],
    );
  }

  /// `Input`
  String get inputPort {
    return Intl.message('Input', name: 'inputPort', desc: 'Input', args: []);
  }

  /// `Please use UTF-8 encoding`
  String get gMsgUseUtf8 {
    return Intl.message(
      'Please use UTF-8 encoding',
      name: 'gMsgUseUtf8',
      desc: 'Error message when CSV encoding is unrecognized',
      args: [],
    );
  }

  /// `Modifying, please wait...`
  String get gModifyingWait {
    return Intl.message(
      'Modifying, please wait...',
      name: 'gModifyingWait',
      desc: 'Modifying, please wait',
      args: [],
    );
  }

  /// `Modbus Gateway Config`
  String get gModbusServiceManagement {
    return Intl.message(
      'Modbus Gateway Config',
      name: 'gModbusServiceManagement',
      desc: 'Modbus Service Management',
      args: [],
    );
  }

  /// `Add Modbus Service`
  String get gAddModbusService {
    return Intl.message(
      'Add Modbus Service',
      name: 'gAddModbusService',
      desc: 'Add Modbus Service',
      args: [],
    );
  }

  /// `Edit Modbus Service`
  String get gEditModbusService {
    return Intl.message(
      'Edit Modbus Service',
      name: 'gEditModbusService',
      desc: 'Edit Modbus Service',
      args: [],
    );
  }

  /// `Modbus Station ID`
  String get gModbusStationId {
    return Intl.message(
      'Modbus Station ID',
      name: 'gModbusStationId',
      desc: 'Modbus Station ID',
      args: [],
    );
  }

  /// `Configure Modbus parameters for the target scale`
  String get gModbusServiceFormDesc {
    return Intl.message(
      'Configure Modbus parameters for the target scale',
      name: 'gModbusServiceFormDesc',
      desc:
          'Configure Modbus communication parameters for the corresponding scale',
      args: [],
    );
  }

  /// `Target Scale ID`
  String get gBindScaleId {
    return Intl.message(
      'Target Scale ID',
      name: 'gBindScaleId',
      desc: 'Bind Scale Station ID',
      args: [],
    );
  }

  /// `Comm Mode`
  String get gCommMode {
    return Intl.message(
      'Comm Mode',
      name: 'gCommMode',
      desc: 'Communication Mode',
      args: [],
    );
  }

  /// `TCP Port`
  String get gTcpPort {
    return Intl.message(
      'TCP Port',
      name: 'gTcpPort',
      desc: 'TCP Port',
      args: [],
    );
  }

  /// `Data Bit`
  String get gDataBit {
    return Intl.message(
      'Data Bit',
      name: 'gDataBit',
      desc: 'Data Bit',
      args: [],
    );
  }

  /// `Stop Bit`
  String get gStopBit {
    return Intl.message(
      'Stop Bit',
      name: 'gStopBit',
      desc: 'Stop Bit',
      args: [],
    );
  }

  /// `Parity Bit`
  String get gParityBit {
    return Intl.message(
      'Parity Bit',
      name: 'gParityBit',
      desc: 'Parity Bit',
      args: [],
    );
  }

  /// `Please select the scale station ID to bind`
  String get gModbusIdMissingTip {
    return Intl.message(
      'Please select the scale station ID to bind',
      name: 'gModbusIdMissingTip',
      desc: 'Please select the scale station ID to bind',
      args: [],
    );
  }

  /// `Please select a serial port`
  String get gSerialPortMissingTip {
    return Intl.message(
      'Please select a serial port',
      name: 'gSerialPortMissingTip',
      desc: 'Please select serial port',
      args: [],
    );
  }

  /// `No Modbus Services Created`
  String get gNoModbusService {
    return Intl.message(
      'No Modbus Services Created',
      name: 'gNoModbusService',
      desc: 'No Modbus Service Created',
      args: [],
    );
  }

  /// `Fixed`
  String get gFixed {
    return Intl.message('Fixed', name: 'gFixed', desc: 'Fixed', args: []);
  }

  /// `Protocol`
  String get gProtocol {
    return Intl.message(
      'Protocol',
      name: 'gProtocol',
      desc: 'Protocol',
      args: [],
    );
  }

  /// `is occupied by another Modbus service`
  String get gPortOccupiedTip1 {
    return Intl.message(
      'is occupied by another Modbus service',
      name: 'gPortOccupiedTip1',
      desc: 'Occupied by other Modbus service',
      args: [],
    );
  }

  /// `Are you sure you want to delete this Modbus service?`
  String get gConfirmDeleteModbusService {
    return Intl.message(
      'Are you sure you want to delete this Modbus service?',
      name: 'gConfirmDeleteModbusService',
      desc: 'Confirm deleting Modbus service',
      args: [],
    );
  }

  /// `Failed to open serial port`
  String get gTipOpenPortFailed {
    return Intl.message(
      'Failed to open serial port',
      name: 'gTipOpenPortFailed',
      desc: 'Failed to open serial port',
      args: [],
    );
  }

  /// `Auto scan serial port`
  String get gAutoScanSerialPort {
    return Intl.message(
      'Auto scan serial port',
      name: 'gAutoScanSerialPort',
      desc: 'Auto scan serial port',
      args: [],
    );
  }

  /// `Print Online`
  String get printOnline {
    return Intl.message(
      'Print Online',
      name: 'printOnline',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get printPreview {
    return Intl.message('Preview', name: 'printPreview', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
