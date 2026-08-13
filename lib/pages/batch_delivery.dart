import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/timer_manager.dart';
import 'package:t_max/functions/methods.dart';

import '../data/downloadresponse.dart';
import '../data/manager_scale_channel.dart';
import '../data/download_prt_fmt.dart';
import '../data/language.dart';
import '../data/parse_log.dart';

import '../data/scalecmd_data.dart';
import '../data/screen_mgr.dart';
import '../data/writelog.dart';
import '../eventbus/eventbus.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

const int updateFirmwareIndex = 0;
const int downPrintFormatIndex = 1;
const int downOutputFormatIndex = 2;
const int modifyBtNameIndex = 3;
const int setDhcpIndex = 4;
const int setStaticIpIndex = 5;
const int connectApIndex = 6;

class BatchDeliveryPage extends StatefulWidget {
  const BatchDeliveryPage({super.key});

  @override
  State<BatchDeliveryPage> createState() => _BatchDeliveryPageState();
}

class _BatchDeliveryPageState extends State<BatchDeliveryPage> {
  List<String> outputData = [];
  List<CheckBoxData> checkBoxData = [];
  List<Map<String, dynamic>> jsonDataList = [];
  List<String> ipListNew = [];
  String lastIpStr = '';

  final ScrollController _scrollController = ScrollController();
  TextEditingController btNameCtl = TextEditingController();
  TextEditingController wifiNameCtl = TextEditingController();
  TextEditingController ipAddrCtl = TextEditingController();
  TextEditingController firmwarePathCtl = TextEditingController();

  TextEditingController prnFmt1Ctl = TextEditingController();
  TextEditingController prnFmt2Ctl = TextEditingController();
  TextEditingController prnFmt3Ctl = TextEditingController();
  TextEditingController prnFmt4Ctl = TextEditingController();

  TextEditingController serialOutput1Ctl = TextEditingController();
  TextEditingController serialOutput2Ctl = TextEditingController();
  TextEditingController serialOutput3Ctl = TextEditingController();
  TextEditingController serialOutput4Ctl = TextEditingController();
  TextEditingController serialOutput5Ctl = TextEditingController();
  TextEditingController serialOutput6Ctl = TextEditingController();

  String logContent = '';
  late ColorScheme colorScheme;

  bool isUpdateFirmwareSelect = false;
  bool isWifiSelect = false;
  bool isBtSelect = false;
  bool isPrnFmtSelect = false;
  bool isSerialOutput = false;
  bool isModifyBtName = false;
  bool isModifyBtPower = false;
  bool isConnectAp = false;
  bool isConnectDhcp = false;
  bool isConnectStaticIp = false;
  bool isAutoIncrease = false;
  bool isIpListSelect = false;
  bool ipIsUsedUp = false;
  bool isDownloading = false;
  bool btDownloading = false;
  bool wifiCnting = false;
  bool wifiDhcp = false;
  bool wifiStatic = false;

  bool prnFmt1 = false;
  bool prnFmt2 = false;
  bool prnFmt3 = false;
  bool prnFmt4 = false;

  bool updateFwDone = false;
  bool downOtherFunc = false; //除了更新FW还有没有别的需要更新
  bool importFlag = false; //标识当前是否是导入操作

  int downLoadIndex = 0;
  int updateProcess = 0;

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus9;
  dynamic _eventbus10;
  dynamic _eventbus11;

  final TextEditingController _ipListCtl = TextEditingController();

  void getLog() async {
    logContent = await readlog();
    jsonDataList = parseLog(logContent, '');

    String firmwarePathStr = getFirmwarePathFromLog(jsonDataList);
    if (firmwarePathStr.isNotEmpty) {
      setState(() {
        firmwarePathCtl.text = firmwarePathStr;
      });
    }

    String btNameStr = getBtNameFromLog(jsonDataList);
    if (btNameStr.isNotEmpty) {
      setState(() {
        btNameCtl.text = btNameStr;
        isModifyBtName = true;
      });
    }
    String wifiName = getWifiNameFromLog(jsonDataList);
    if (wifiName.isNotEmpty) {
      setState(() {
        wifiNameCtl.text = wifiName;
        isConnectAp = true;
      });
    }
    String ipAddrStr = getIpAddrFromLog(jsonDataList);
    if (isConnectAp && ipAddrStr.isNotEmpty) {
      setState(() {
        lastIpStr = ipAddrStr;
        ipAddrCtl.text = ipAddrStr;
        isConnectStaticIp = true;
      });
    }
    if (isConnectAp && !isConnectStaticIp) {
      isConnectDhcp = true;
    } else {
      isConnectDhcp = false;
    }
    List<String> prnFmtList = getPrintFmtFromLog(jsonDataList);
    if (prnFmtList.isNotEmpty) {
      setState(() {
        for (int i = 0; i < prnFmtList.length; i++) {
          String text = prnFmtList[i];
          if (i == 0) {
            prnFmt1 = true;
            prnFmt1Ctl.text = text.substring(1);
          } else if (i == 1) {
            prnFmt2 = true;
            prnFmt2Ctl.text = text.substring(1);
          } else if (i == 2) {
            prnFmt3 = true;
            prnFmt3Ctl.text = text.substring(1);
          } else if (i == 3) {
            prnFmt4 = true;
            prnFmt4Ctl.text = text.substring(1);
          }
        }
      });
    }

    List<String> serialOutputList = getSerialOutputFromLog(jsonDataList);
    if (serialOutputList.isNotEmpty) {
      setState(() {
        for (int i = 0; i < serialOutputList.length; i++) {
          String text = serialOutputList[i];
          if (i == 0) {
            serialOutput1Ctl.text = text.substring(1);
          } else if (i == 1) {
            serialOutput2Ctl.text = text.substring(1);
          } else if (i == 2) {
            serialOutput3Ctl.text = text.substring(1);
          } else if (i == 3) {
            serialOutput4Ctl.text = text.substring(1);
          } else if (i == 4) {
            serialOutput5Ctl.text = text.substring(1);
          } else if (i == 5) {
            serialOutput6Ctl.text = text.substring(1);
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    cntScaleTimerMgr.startCntScaleTimer(5);
    firmwarePathCtl.text = '';
    ipAddrCtl.text = '';
    wifiNameCtl.text = '';
    btNameCtl.text = '';

    prnFmt1Ctl.text = '';
    prnFmt2Ctl.text = '';
    prnFmt3Ctl.text = '';
    prnFmt4Ctl.text = '';

    checkBoxData = [
      CheckBoxData(
        name: 'Wifi Setting', // 使用翻译字段
        value: false,
      ),
      CheckBoxData(
        name: 'Bluetooth Setting',
        value: true,
      ),
      CheckBoxData(
        name: 'Location Setting',
        value: false,
      ),
    ];
    getLog();

    _eventbus1 = eventBus.on<EventSerialOutputResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            outputData.add(
                '${getDateTime()}:Download Serial OutPut\r\n${myRespDataFromScale.msgBody}\r\n');
          }
        });

        performNextDask();
      }
    });
    _eventbus2 = eventBus.on<EventDownPrnFmtResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            outputData.add(
                '${getDateTime()}:Download Print Format\r\n${myRespDataFromScale.msgBody}\r\n');
          }
        });
        performNextDask();
      }
    });

    _eventbus3 = eventBus.on<EventConnectBTResponse>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;

          if (myRespDataFromScale.msgBody.isNotEmpty) {
            outputData.add(
                '${getDateTime()}:Modify Bluetooth Name\r\n${myRespDataFromScale.msgBody}\r\n');
          }
        });
        performNextDask();
      }
    });
    _eventbus4 = eventBus.on<EventBTResponse>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;

          if (myRespDataFromScale.msgBody.isNotEmpty) {
            outputData.add(
                '${getDateTime()}:Modify Emission Power\r\n${myRespDataFromScale.msgBody}\r\n');
          }
        });
        performNextDask();
      }
    });
    _eventbus5 = eventBus.on<EventConnectAp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            outputData.add(
                '${getDateTime()}:Connect Ap\r\nThe setup is complete.\r\n');
          }
        });
        performNextDask();
      }
    });

    _eventbus6 = eventBus.on<EventConnectStaticIp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            outputData.add(
                '${getDateTime()}:Connect Static Ip\r\n${myRespDataFromScale.msgBody}\r\n');
          }
        });
        performNextDask();
      }
    });
    _eventbus7 = eventBus.on<EventConnectDynamicIp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            outputData.add(
                '${getDateTime()}:Connect Dynamic Ip\r\n${myRespDataFromScale.msgBody}\r\n');
          }
        });
        performNextDask();
      }
    });
    // _eventbus8 = eventBus.on<EventRespCheckNetScale>().listen((event) {
    //   if (mounted) {
    //     setState(() {
    //       myFactoryInfoFromScale = event.obj;
    //       if (myFactoryInfoFromScale.modelName != '') {
    //         myComScaleInfo.isOnline = true;
    //         if (downOtherFunc && isDownloading) {
    //           downOtherFunc = false;
    //           performNextDask();
    //         }
    //       } else {
    //         myComScaleInfo.isOnline = false;
    //       }
    //     });
    //   }
    // });

    _eventbus9 = eventBus.on<EventRespUpdateFirmware>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        setState(() {
          outputData.add(
              '${getDateTime()}:Update Firmware Result\r\n${myRespDataFromScale.msgBody}\r\n');
          scrollToBottom();
        });
        if (myRespDataFromScale.msgBody.contains('ok')) {
          cntScaleTimerMgr.stopCntScaleTimer();
          cntScaleTimerMgr.startCntScaleTimer(5);
          if (!downOtherFunc) {
            performNextDask();
          }
        } else {
          downLoadIndex = 7;
          performNextDask();
        }
      }
    });
    _eventbus10 = eventBus.on<EventRespUpdateFirmwareProcess>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok') ||
            myRespDataFromScale.msgBody.contains('fail')) {
        } else {
          if (int.tryParse(myRespDataFromScale.msgBody) != null) {
            // 字符串全是数字
            int numericValue = int.parse(myRespDataFromScale.msgBody);
            setState(() {
              updateProcess = numericValue;
              if (numericValue < 100 && numericValue * 1.5 < 100.0) {
                numericValue = (numericValue * 1.5).toInt();
              }

              if (outputData[outputData.length - 1]
                  .contains('Update Progress')) {
                outputData[outputData.length - 1] =
                    'Update Progress: $numericValue%';
              } else {
                outputData.add('Update Progress: $numericValue%');
              }
              scrollToBottom();
            });
          } else {}
        }
      }
    });

    _eventbus11 = eventBus.on<EventGetOneEepromDateResp>().listen((event) {
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
          } else {
            myScreenMgr.wifiOrBt = 'off';
          }
          checkWifiOrBtExist();
        });
      }
    });
  }

  void checkWifiOrBtExist() {
    if (myScreenMgr.wifiOrBt == 'off') {
      if (btDownloading) {
        setState(() {
          outputData.add('${getDateTime()}:There is no bluetooth device\r\n');
          btDownloading = false;
          scrollToBottom();
        });

        downLoadIndex++;
        performNextDask();
      } else if (wifiCnting || wifiDhcp || wifiStatic) {
        setState(() {
          outputData.add('${getDateTime()}:There is no wifi device\r\n');
          scrollToBottom();
        });

        wifiCnting = false;
        wifiDhcp = false;
        wifiStatic = false;
        downLoadIndex++;
        performNextDask();
      }
    } else if (myScreenMgr.wifiOrBt == 'bt' && btDownloading) {
      btDownloading = false;
      PublicFunctions.modifyBtName(btNameCtl.text, myDefScaleInfo.defScaleId!);
      downLoadIndex++;
    } else if (myScreenMgr.wifiOrBt == 'wifi' && wifiDhcp) {
      wifiDhcp = false;
      PublicFunctions.setWifiDynamicMode(myDefScaleInfo.defScaleId!);
      downLoadIndex++;
    } else if (myScreenMgr.wifiOrBt == 'wifi' && wifiStatic) {
      wifiStatic = false;
      List<Map<String, dynamic>> filteredList = jsonDataList
          .where((item) => item["Req"] == "set_wifi_static_ip")
          .toList();
      if (filteredList.isNotEmpty) {
        Map<String, dynamic> jsonWifi =
            jsonDecode((filteredList[0])['ReqData']);
        jsonWifi['ip'] = ipAddrCtl.text;
        filteredList[0]['ReqData'] = jsonEncode(jsonWifi);
        PublicFunctions.sendMsg(
            myDefScaleInfo.defScaleId!, jsonEncode(filteredList[0]));
        writelog(jsonEncode(filteredList[0]));
      }
      downLoadIndex++;
    } else if (myScreenMgr.wifiOrBt == 'wifi' && wifiCnting) {
      wifiCnting = false;
      List<Map<String, dynamic>> filteredList =
          jsonDataList.where((item) => item["Req"] == "connect_ap").toList();

      if (filteredList.isNotEmpty) {
        filteredList[0]['Req'] = "connect_ap_one_key";
        PublicFunctions.sendMsg(
            myDefScaleInfo.defScaleId!, jsonEncode(filteredList[0]));
        filteredList[0]['Req'] = "connect_ap";
        writelog(jsonEncode(filteredList[0]));
      }
      downLoadIndex++;
    } else {
      if (myScreenMgr.wifiOrBt == 'wifi') {
        outputData.add('${getDateTime()}:There is no bluetooth device\r\n');
      } else {
        outputData.add('${getDateTime()}:There is no wifi device\r\n');
      }
      scrollToBottom();
      downLoadIndex++;
      performNextDask();
    }
  }

  String getDateTime() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  void performNextDask() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
    performDownload();
  }

  String convertHexToAsciiString(String hexString) {
    final bytes = hexString
        .replaceAll(" ", "")
        .split('')
        .map((e) => int.parse(e, radix: 16))
        .toList();

    final codePoints = List<int>.generate(
        bytes.length ~/ 2, (i) => bytes[i * 2] * 16 + bytes[i * 2 + 1]);
    final asciiCharacters =
        codePoints.map((codePoint) => String.fromCharCode(codePoint)).toList();
    return asciiCharacters.join('');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _eventbus9.cancel();
    _eventbus10.cancel();
    _eventbus11.cancel();
    btNameCtl.dispose();
    wifiNameCtl.dispose();
    ipAddrCtl.dispose();
    firmwarePathCtl.dispose();
    prnFmt1Ctl.dispose();
    prnFmt2Ctl.dispose();
    prnFmt3Ctl.dispose();
    prnFmt4Ctl.dispose();
    serialOutput1Ctl.dispose();
    serialOutput2Ctl.dispose();
    serialOutput3Ctl.dispose();
    serialOutput4Ctl.dispose();
    serialOutput5Ctl.dispose();
    serialOutput6Ctl.dispose();
    _ipListCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          height: 50,
          width: screenSize.width - 10,
          color: colorScheme.primary,
          child: pageHeadDefScale(
            context,
            'Batch Delivery',
            '',
          ),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 3,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    child: titleStyle('Setting'),
                  ),
                  Expanded(
                    flex: 5, // 设置子部件占用空间的比例
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5), // 设置上下边距值
                      child: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isUpdateFirmwareSelect,
                                  onChanged: (value) {
                                    setState(() {
                                      isUpdateFirmwareSelect = value!;
                                    });
                                  },
                                ),
                                textStyle(localizedStrings.firmware_update,
                                    constraints),
                                // 省略部分代码
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: isWifiSelect,
                                  onChanged: (value) {
                                    setState(() {
                                      isWifiSelect = value!;
                                      if (isWifiSelect) {
                                        isBtSelect = false;
                                      }
                                    });
                                  },
                                ),
                                textStyle(localizedStrings.menuWifiSetting,
                                    constraints),
                                // 省略部分代码
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: isBtSelect,
                                  onChanged: (value) {
                                    setState(() {
                                      isBtSelect = value!;
                                      if (isBtSelect) {
                                        isWifiSelect = false;
                                      }
                                    });
                                  },
                                ),
                                textStyle(localizedStrings.bt_setting_title,
                                    constraints),
                                // 省略部分代码
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: isPrnFmtSelect,
                                  onChanged: (value) {
                                    setState(() {
                                      isPrnFmtSelect = value!;
                                    });
                                  },
                                ),
                                textStyle(
                                    localizedStrings.menuLabelFormatDownload,
                                    constraints),
                                // 省略部分代码
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: isSerialOutput,
                                  onChanged: (value) {
                                    setState(() {
                                      isSerialOutput = value!;
                                    });
                                  },
                                ),
                                textStyle(
                                    localizedStrings.gTitleSerialOutputDownload,
                                    constraints),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5), // 设置上下边距值
                            child: CustomElevatedButton(
                              btnWidth: 120,
                              btnHeight: 50,
                              icon: Icons.download_outlined,
                              text: localizedStrings.gBtnDownload,
                              onPressed: isDownloading
                                  ? null
                                  : () {
                                      if (checkDownload()) {
                                        downLoadIndex = 0;
                                        setState(() {
                                          isDownloading = true;
                                          cntScaleTimerMgr.stopCntScaleTimer();
                                        });
                                        performDownload();
                                      }
                                    },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5), // 设置上下边距值
                            child: CustomOutlinedButton(
                              btnWidth: 120,
                              btnHeight: 50,
                              icon: Icons.drive_file_move_outlined,
                              text: localizedStrings.batch_down_export,
                              onPressed: () async {
                                await wirteRecordsName();
                                final selectedFolderPath = await pickFolder();
                                if (selectedFolderPath != null) {
                                  performExport(selectedFolderPath);
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5), // 设置上下边距值
                            child: CustomOutlinedButton(
                              btnWidth: 120,
                              btnHeight: 50,
                              icon: Icons.drive_file_move_rtl_outlined,
                              text: localizedStrings.gBtnImport,
                              onPressed: () async {
                                String str = await pickZipFiles();
                                bool res;
                                if (str == '') {
                                  return;
                                }
                                res = await unZipImportFile(str);
                                if (res) {
                                  cleanAllTextCtl();
                                  getImportFileName();
                                  _getImportLog();
                                  importFlag = true;
                                  if (context.mounted) {
                                    _showErrorDialog(
                                        context, 'Import complete!');
                                  }
                                } else {
                                  if (context.mounted) {
                                    _showErrorDialog(context,
                                        'The exported backup is modified. Not recognizable.');
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      )),
                ],
              )),
          Expanded(
            flex: 9,
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: ListView(
                      children: [
                        titleStyle('Bluetooth:'),
                        isBtSelect && isModifyBtName
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Bt Name',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    height: 30,
                                    child: TextField(
                                      controller: btNameCtl,
                                      readOnly: false,
                                      maxLines: 1,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(
                                child:
                                    Text('', overflow: TextOverflow.ellipsis)),
                        const SizedBox(
                          height: 5,
                        ),
                        titleStyle('WiFi:'),
                        (isWifiSelect && isConnectAp)
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Connect Ap',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    height: 30,
                                    child: TextField(
                                      controller: wifiNameCtl,
                                      readOnly: true,
                                      maxLines: 1,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(
                                child:
                                    Text('', overflow: TextOverflow.ellipsis)),
                        (isWifiSelect && isConnectDhcp)
                            ? const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Set DHCP',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              )
                            : const SizedBox(),
                        isWifiSelect && isConnectStaticIp
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Set Static Ip',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        width: 200,
                                        height: 30,
                                        child: TextField(
                                          controller: ipAddrCtl,
                                          readOnly: false,
                                          maxLines: 1,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  (isWifiSelect && isConnectStaticIp)
                                      ? Row(
                                          children: [
                                            Checkbox(
                                              value: isIpListSelect,
                                              onChanged: (value) {
                                                setState(() {
                                                  isIpListSelect = value!;
                                                  if (isIpListSelect) {
                                                    isAutoIncrease = false;
                                                    getIpListFormFile();
                                                    _showEditIpList(context);
                                                  }
                                                });
                                              },
                                            ),
                                            Text(
                                              'ip List',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                            ),

                                            // 省略部分代码
                                          ],
                                        )
                                      : const SizedBox(),
                                ],
                              )
                            : const SizedBox(),
                        Container(
                          color: colorScheme.scrim,
                          height: 35,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: titleStyle('Firmware Path:'),
                              ),
                              buildSelectFirmWareBtn(firmwarePathCtl),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 67,
                          child: Column(children: [
                            Expanded(
                              child: TextField(
                                controller: firmwarePathCtl,
                                readOnly: true,
                                maxLines: 1,
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                        titleStyle('Print Format:'),
                        Container(
                          color: colorScheme.surfaceBright,
                          height: 35,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              title2ndStyle(
                                  localizedStrings.gTipFreeFormat + " 1:"),
                              buildSelectBtn(prnFmt1Ctl),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 370,
                          child: Column(
                            children: [
                              outputCtlText(prnFmt1Ctl),
                              Container(
                                color: colorScheme.surfaceBright,
                                height: 35,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    title2ndStyle(
                                        localizedStrings.gTipFreeFormat +
                                            " 2:"),
                                    buildSelectBtn(prnFmt2Ctl),
                                  ],
                                ),
                              ),
                              outputCtlText(prnFmt2Ctl),
                              Container(
                                color: colorScheme.surfaceBright,
                                height: 35,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    title2ndStyle(
                                        localizedStrings.gTipFreeFormat +
                                            " 3:"),
                                    buildSelectBtn(prnFmt3Ctl),
                                  ],
                                ),
                              ),
                              outputCtlText(prnFmt3Ctl),
                              Container(
                                color: colorScheme.surfaceBright,
                                height: 35,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    title2ndStyle(localizedStrings.gTotalFmt),
                                    buildSelectBtn(prnFmt4Ctl),
                                  ],
                                ),
                              ),
                              outputCtlText(prnFmt4Ctl),
                            ],
                          ),
                        ),
                        Container(
                          color: colorScheme.scrim,
                          height: 35,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: titleStyle('Serial Output:'),
                              ),
                              buildSelectZipBtn(),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 400,
                          child: Column(
                            children: [
                              outputCtlText(serialOutput1Ctl),
                              outputCtlText(serialOutput2Ctl),
                              outputCtlText(serialOutput3Ctl),
                              outputCtlText(serialOutput4Ctl),
                              outputCtlText(serialOutput5Ctl),
                              outputCtlText(serialOutput6Ctl),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              flex: 5,
              child: Column(
                children: [
                  Text(
                    'Download Result:',
                    style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 20,
                        color: colorScheme.primary),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(10.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary, // 边框颜色
                          width: 1.0, // 边框宽度
                        ),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(10.0)), // 边框圆角
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10.0), // 添加边距
                        itemCount: outputData.length,
                        itemBuilder: (context, index) {
                          return Text(outputData[index]);
                        },
                        controller: _scrollController,
                      ),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  void _getImportLog() async {
    logContent = await readImportlog();
    jsonDataList = parseLog(logContent, '');

    String btNameStr = getBtNameFromLog(jsonDataList);
    if (btNameStr.isNotEmpty) {
      setState(() {
        btNameCtl.text = btNameStr;
        isModifyBtName = true;
      });
    }
    String wifiName = getWifiNameFromLog(jsonDataList);
    if (wifiName.isNotEmpty) {
      setState(() {
        wifiNameCtl.text = wifiName;
        isConnectAp = true;
      });
    }
    String ipAddrStr = getIpAddrFromLog(jsonDataList);
    if (isConnectAp && ipAddrStr.isNotEmpty) {
      setState(() {
        lastIpStr = ipAddrStr;
        ipAddrCtl.text = ipAddrStr;
        isConnectStaticIp = true;
      });
    }
    if (isConnectAp && !isConnectStaticIp) {
      isConnectDhcp = true;
    } else {
      isConnectDhcp = false;
    }
  }

  Future<void> writeRecName(
      String prefix, TextEditingController controller) async {
    if (controller.text.isNotEmpty) {
      List<String> parts = controller.text.split('\\');
      String lastPart = parts.last;
      await writeRecordsName('$prefix:$lastPart');
    } else {
      await writeRecordsName('$prefix:');
    }
  }

  Future<void> wirteRecordsName() async {
    await delRecordsName();
    await writeRecName('firmware', firmwarePathCtl);
    await writeRecName('prnFmt1', prnFmt1Ctl);
    await writeRecName('prnFmt2', prnFmt2Ctl);
    await writeRecName('prnFmt3', prnFmt3Ctl);
    await writeRecName('prnFmt4', prnFmt4Ctl);
    await writeRecName('serialOutput1', serialOutput1Ctl);
    await writeRecName('serialOutput2', serialOutput2Ctl);
    await writeRecName('serialOutput3', serialOutput3Ctl);
    await writeRecName('serialOutput4', serialOutput4Ctl);
    await writeRecName('serialOutput5', serialOutput5Ctl);
    await writeRecName('serialOutput6', serialOutput6Ctl);
  }

  void performExport(String folderPath) {
    String appDirectory = Platform.resolvedExecutable;
    var directory = p.dirname(appDirectory);
    var sourcedir = '$directory\\$myLogDir';
    if (importFlag) {
      copyIpListToLocal();
    }
    copyPrnFmtToLocal(prnFmt1Ctl, sourcedir, 'weight');
    copyPrnFmtToLocal(prnFmt2Ctl, sourcedir, 'acc');
    copyPrnFmtToLocal(prnFmt3Ctl, sourcedir, 'pcs');
    copyPrnFmtToLocal(prnFmt4Ctl, sourcedir, 'percent');
    copyFirmwareToLocal(firmwarePathCtl, sourcedir);
    copySerialToLocal(serialOutput1Ctl, sourcedir);
    copySerialToLocal(serialOutput2Ctl, sourcedir);
    copySerialToLocal(serialOutput3Ctl, sourcedir);
    copySerialToLocal(serialOutput4Ctl, sourcedir);
    copySerialToLocal(serialOutput5Ctl, sourcedir);
    copySerialToLocal(serialOutput6Ctl, sourcedir);
    Directory(folderPath).createSync(recursive: true); // 创建目标文件夹（如果它不存在）
    String zipPath = '$folderPath\\backup.zip';
    Archive archive = createArchiveFromPath(sourcedir);
    saveArchiveToPath(archive, zipPath);
  }

  Archive createArchiveFromPath(String sourcePath) {
    Archive archive = Archive();
    Directory sourceDir = Directory(sourcePath);
    List<FileSystemEntity> entities = sourceDir.listSync(recursive: true);
    List<int> allFileData = [];
    for (var entity in entities) {
      if (entity is File) {
        File file = entity;
        String fileName = file.path.substring(sourceDir.path.length);
        List<int> fileData = file.readAsBytesSync();
        allFileData.addAll(fileData);
        archive.addFile(
            ArchiveFile(fileName, file.lengthSync(), file.readAsBytesSync()));
      }
    }

    final md5 = calculateMD5(allFileData.toString());
    String contentHash = md5.toString();
    // 将整个文件夹内容的哈希值写入metadata.txt文件
    archive.addFile(
        ArchiveFile('metadata.txt', contentHash.length, contentHash.codeUnits));
    return archive;
  }

  String calculateMD5(String input) {
    // 使用MD5算法计算input的哈希值
    var hash = md5.convert(utf8.encode(input)).toString();
    return hash;
  }

  void saveArchiveToPath(Archive archive, String zipPath) {
    File zipFile = File(zipPath);
    List<int>? encoded = ZipEncoder().encode(archive);
    zipFile.writeAsBytesSync(encoded!);
    if (zipPath.length > 66) {
      String last50Characters = zipPath.substring(zipPath.length - 66);
      _showErrorDialog(context, 'Backup successful!\r\n...$last50Characters');
    } else {
      _showErrorDialog(context, 'Backup successful!\r\n$zipPath');
    }
  }

  void copyIpListToLocal() async {
    ipFilePath = await getAppImportPath(myIpListName);
    String destFilePath = await getAppFilePath(myIpListName);
    File file = File(destFilePath);
    copyFile(file.parent.path, ipFilePath);
  }

  void copyPrnFmtToLocal(
      TextEditingController fmtCtl, String destDir, String secendFile) {
    destDir = '$destDir\\$myPrnFormatDir\\$secendFile';
    if (fmtCtl.text.isNotEmpty) {
      var str = fmtCtl.text;
      bool isFirstCharDigit = isDigit(str[0]);
      deleteFilesInDir(destDir);
      if (isFirstCharDigit) {
        copyFile(destDir, str.substring(1));
      } else {
        copyFile(destDir, str);
      }
    }
  }

  void deleteFilesInDir(String path) {
    Directory directory = Directory(path);
    if (directory.existsSync()) {
      directory.listSync().forEach((FileSystemEntity entity) {
        if (entity is File) {
          entity.deleteSync();
        }
      });
    }
  }

  void copySerialToLocal(TextEditingController textCtl, String destDir) {
    destDir = '$destDir\\$mySerialOutput';
    if (textCtl.text.isNotEmpty) {
      var str = textCtl.text;
      bool isFirstCharDigit = isDigit(str[0]);
      if (isFirstCharDigit) {
        copyFile(destDir, str.substring(1));
      } else {
        copyFile(destDir, str);
      }
    }
  }

  void copyFirmwareToLocal(TextEditingController textCtl, String destDir) {
    destDir = '$destDir\\$myFirmwareDir';
    if (textCtl.text.isNotEmpty) {
      var str = textCtl.text;
      bool isFirstCharDigit = isDigit(str[0]);
      if (isFirstCharDigit) {
        copyFile(destDir, str.substring(1));
      } else {
        copyFile(destDir, str);
      }
    }
  }

  bool isDigit(String char) {
    int? digit = int.tryParse(char);
    return digit != null;
  }

  void copyFile(String localPath, String sourceFile) {
    File destFile = File('$localPath\\${sourceFile.split('\\').last}');
    Directory(localPath).createSync(recursive: true);
    if (File(sourceFile).existsSync()) {
      File(sourceFile).copySync(destFile.path);
    }
  }

  void copyFolder(String sourceFolder, String destinationFolder) {
    Directory(sourceFolder)
        .listSync(recursive: true)
        .forEach((FileSystemEntity entity) {
      String relativePath =
          p.relative(entity.path, from: sourceFolder); // 计算相对路径
      String newPath = p.join(destinationFolder, relativePath); // 构建新的路径

      if (entity is Directory) {
        Directory(newPath).createSync(recursive: true); // 创建目标文件夹
      } else if (entity is File) {
        File(entity.path).copySync(newPath); // 复制文件
      }
    });
  }

  Widget outputCtlText(TextEditingController ctlText) {
    return Expanded(
      child: TextField(
        controller: ctlText,
        readOnly: true,
        maxLines: 1,
        style: const TextStyle(overflow: TextOverflow.ellipsis),
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
    );
  }

  Future<String?> pickFolder() async {
    final folderPath = await FilePicker.platform.getDirectoryPath();
    return folderPath;
  }

  Widget buildSelectBtn(TextEditingController textCtl) {
    return CustomElevatedButton(
        btnWidth: 150,
        btnHeight: 30,
        icon: Icons.file_open_outlined,
        text: localizedStrings.button_select_format,
        onPressed: isDownloading
            ? null
            : () async {
                pickFiles(textCtl);
              });
  }

  Widget buildSelectFirmWareBtn(TextEditingController textCtl) {
    return CustomElevatedButton(
        btnWidth: 150,
        btnHeight: 30,
        icon: Icons.file_open_outlined,
        text: localizedStrings.select_firmware_btn,
        onPressed: isDownloading
            ? null
            : () async {
                pickFirmwareFiles(textCtl);
              });
  }

  Widget buildSelectZipBtn() {
    return CustomElevatedButton(
        btnWidth: 150,
        btnHeight: 30,
        icon: Icons.folder_sharp,
        text: localizedStrings.batch_down_slt_folder,
        onPressed: isDownloading
            ? null
            : () async {
                getSerialFiles();
              });
  }

  Future getSerialFiles() async {
    final selectedFolderPath = await pickFolder();
    if (selectedFolderPath != null) {
      serialOutput1Ctl.clear();
      serialOutput2Ctl.clear();
      serialOutput3Ctl.clear();
      serialOutput4Ctl.clear();
      serialOutput5Ctl.clear();
      serialOutput6Ctl.clear();
      String filePath = p.join(selectedFolderPath, 'OL.json');
      File file = File(filePath);
      if (await file.exists()) {
        serialOutput1Ctl.text = filePath;
      }
      filePath = p.join(selectedFolderPath, 'UL.json');
      file = File(filePath);
      if (await file.exists()) {
        serialOutput2Ctl.text = filePath;
      }
      filePath = p.join(selectedFolderPath, 'Weight.json');
      file = File(filePath);
      if (await file.exists()) {
        serialOutput3Ctl.text = filePath;
      }
      filePath = p.join(selectedFolderPath, 'Pcs.json');
      file = File(filePath);
      if (await file.exists()) {
        serialOutput4Ctl.text = filePath;
      }
      filePath = p.join(selectedFolderPath, 'Price.json');
      file = File(filePath);
      if (await file.exists()) {
        serialOutput5Ctl.text = filePath;
      }
      filePath = p.join(selectedFolderPath, 'Percent.json');
      file = File(filePath);
      if (await file.exists()) {
        serialOutput6Ctl.text = filePath;
      }
    }
  }

  Future<String> pickZipFiles() async {
    String str = '';
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // initialDirectory: directory,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result != null) {
      str = result.files.single.path!;
    }
    return str;
  }

  void cleanAllTextCtl() {
    prnFmt1Ctl.clear();
    prnFmt2Ctl.clear();
    prnFmt3Ctl.clear();
    prnFmt4Ctl.clear();
    serialOutput1Ctl.clear();
    serialOutput2Ctl.clear();
    serialOutput3Ctl.clear();
    serialOutput4Ctl.clear();
    serialOutput5Ctl.clear();
    serialOutput6Ctl.clear();
  }

  void recreateDir(String path) {
    Directory directory = Directory(path);
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true); // 删除目录及其子目录文件
    }
    directory.createSync(recursive: true); // 创建目录及其父目录
  }

  Future<bool> unZipImportFile(String zipFilePath) async {
    bool res = false;
    final recPath = await getImportDir();
    if (!await recPath.exists()) {
      await recPath.create(recursive: true);
    }
    var destFolder = recPath.path;
    Directory(destFolder).createSync(recursive: true);
    final bytes = File(zipFilePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    // 获取压缩文件中存储的哈希值
    String storedContentHash = '';
    List<int> allFileData = [];
    for (var file in archive) {
      if (file.name == 'metadata.txt') {
        storedContentHash = utf8.decode(file.content);
        break;
      } else {
        List<int> fileData = file.content;
        allFileData.addAll(fileData);
      }
    }
    if (storedContentHash == '') {
      return res;
    }
    // 计算除metadata.txt外的文件内容哈希值
    String extractedContentHash = calculateMD5(allFileData.toString());
    if (storedContentHash == extractedContentHash) {
      res = true;
    } else {
      return res;
    }
    recreateDir(destFolder);
    for (final file in archive) {
      final fileName = '$destFolder/${file.name}';
      if (file.isFile) {
        File(fileName)
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content as List<int>);
      } else {
        Directory(fileName).createSync(recursive: true);
      }
    }
    return res;
  }

  void getImportFileName() async {
    String recData = await readRecName();
    List<String> lines = recData.split('\r\n');

    Map<String, String> keyToPrefixMap = {
      'firmware': 'firmware',
      'prnFmt1': 'prnFormat\\weight',
      'prnFmt2': 'prnFormat\\acc',
      'prnFmt3': 'prnFormat\\pcs',
      'prnFmt4': 'prnFormat\\percent',
      'serialOutput1': 'serialOutput',
      'serialOutput2': 'serialOutput',
      'serialOutput3': 'serialOutput',
      'serialOutput4': 'serialOutput',
      'serialOutput5': 'serialOutput',
      'serialOutput6': 'serialOutput',
    };

    Map<String, dynamic> keyToCtlMap = {
      'firmware': firmwarePathCtl,
      'prnFmt1': prnFmt1Ctl,
      'prnFmt2': prnFmt2Ctl,
      'prnFmt3': prnFmt3Ctl,
      'prnFmt4': prnFmt4Ctl,
      'serialOutput1': serialOutput1Ctl,
      'serialOutput2': serialOutput2Ctl,
      'serialOutput3': serialOutput3Ctl,
      'serialOutput4': serialOutput4Ctl,
      'serialOutput5': serialOutput5Ctl,
      'serialOutput6': serialOutput6Ctl,
    };

    for (String line in lines) {
      List<String> lineStrList = line.split(':');
      if (lineStrList.length != 2 || lineStrList.last.isEmpty) {
        continue;
      }
      String key = lineStrList.first;
      if (keyToPrefixMap.containsKey(key) &&
          keyToCtlMap.containsKey(key) &&
          lineStrList.last != '') {
        checkNameAndFilePath(
            lineStrList.last, keyToPrefixMap[key]!, keyToCtlMap[key]);
      }
    }
  }

  Future<void> checkNameAndFilePath(
      String fileName, String path, TextEditingController textCtl) async {
    final importPath = await getImportDir();
    String filePath = '${importPath.path}\\$path\\$fileName';
    File destFile = File(filePath);
    if (await destFile.exists()) {
      textCtl.text = filePath;
    }
  }

  void parserOutputZip(String zipFilePath) async {
    final recPath = await getJsonFileDir();
    if (!await recPath.exists()) {
      await recPath.create(recursive: true);
    }
    var destFolder = recPath.path;
    Directory(destFolder).createSync(recursive: true);
    final bytes = File(zipFilePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final fileName = '$destFolder/${file.name}';
      if (file.isFile) {
        File(fileName)
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content as List<int>);
        if (file.name == 'OL.json') {
          serialOutput1Ctl.text = '$destFolder\\${file.name}';
        } else if (file.name == 'UL.json') {
          serialOutput2Ctl.text = '$destFolder\\${file.name}';
        } else if (file.name == 'Weight.json') {
          serialOutput3Ctl.text = '$destFolder\\${file.name}';
        } else if (file.name == 'Pcs.json') {
          serialOutput4Ctl.text = '$destFolder\\${file.name}';
        } else if (file.name == 'Price.json') {
          serialOutput5Ctl.text = '$destFolder\\${file.name}';
        } else if (file.name == 'Percent.json') {
          serialOutput6Ctl.text = '$destFolder\\${file.name}';
        }
      } else {
        Directory(fileName).createSync(recursive: true);
      }
    }
  }

  Future<Directory> getImportDir() async {
    String executablePath = Platform.resolvedExecutable;
    var directory = p.dirname(executablePath);
    return Directory('$directory\\import');
  }

  Future<Directory> getJsonFileDir() async {
    String executablePath = Platform.resolvedExecutable;
    var directory = p.dirname(executablePath);
    return Directory('$directory\\output');
  }

  Future pickFirmwareFiles(TextEditingController showFilePath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // initialDirectory: directory,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['srec'],
    );
    if (result != null) {
      setState(() {
        showFilePath.text = result.files.single.path!;
      });
    } else {
      setState(() {
        showFilePath.text = '';
      });
    }
  }

  Future pickFiles(TextEditingController showFilePath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // initialDirectory: directory,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['fmt'],
    );
    if (result != null) {
      setState(() {
        showFilePath.text = result.files.single.path!;
      });
    } else {
      setState(() {
        showFilePath.text = '';
      });
    }
  }

  ButtonStyle? buildButtonStyle() {
    return !isDownloading
        ? OutlinedButton.styleFrom(
            side: BorderSide(
              width: 1,
              color: colorScheme.primary,
            ),
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: colorScheme.primary, // 设置按钮的背景色
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
            ),
          )
        : OutlinedButton.styleFrom(
            side: BorderSide(
              width: 1,
              color: colorScheme.secondaryFixed,
            ),
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: colorScheme.secondaryFixed, // 设置按钮的背景色
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
            ),
          );
  }

  String ipFilePath = '';

  performAutoIp() {
    if (isValidIPAddress(lastIpStr)) {
      ipListNew = generateIpRange(lastIpStr);
      if (ipListNew.isNotEmpty) {
        ipIsUsedUp = false;
        setState(() {
          ipAddrCtl.text = ipListNew[0];
        });

        ipListNew.removeAt(0);
      } else {
        ipIsUsedUp = true;
      }
    }
  }

  List<String> generateIpRange(String start) {
    List<int> startParts = start.split(".").map((e) => int.parse(e)).toList();
    List<String> ipList = [];
    if (startParts[3] >= 254) {
      return ipList;
    }
    for (var i = startParts[3] + 1; i <= 254; i++) {
      startParts[3] = i;
      ipList.add(
          "${startParts[0]}.${startParts[1]}.${startParts[2]}.${startParts[3]}");
    }
    return ipList;
  }

  getIpListFormFile() async {
    if (importFlag) {
      ipFilePath = await getAppImportPath(myIpListName);
    } else {
      ipFilePath = await getAppFilePath(myIpListName);
    }

    bool fileExists = await File(ipFilePath).exists();
    if (!fileExists) {
      await File(ipFilePath).create(recursive: true);
    } else {
      String fileContent = await File(ipFilePath).readAsString();
      setState(() {
        _ipListCtl.text = fileContent;
      });
    }
  }

  void _showErrorDialog(BuildContext context, String tipStr) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.gTitleConfirm,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: SizedBox(
            width: 300,
            height: 70,
            child: Text(
              tipStr,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          actions: <Widget>[
            SizedBox(
              height: 30,
              child: OutlinedButton(
                child: Text(localizedStrings.gBtnConfirm),
                onPressed: () {
                  Navigator.of(context).pop(true); // 跳转
                },
              ),
            )
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          isDownloading = false;
          cntScaleTimerMgr.stopCntScaleTimer();
          cntScaleTimerMgr.startCntScaleTimer(5);
        });
      }
    });
  }

  void _showEditIpList(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            'Edit Ip List',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: SizedBox(
              width: 400,
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ipListCtl,
                      maxLines: null, // 可以无限制地输入多行文本
                      decoration: const InputDecoration(
                        labelText: 'Edit your ip list here',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              )),
          actions: <Widget>[
            OutlinedButton(
              child: Text(localizedStrings.gBtnCancel),
              onPressed: () {
                setState(() {
                  isIpListSelect = false;
                  ipListNew = [];
                });
                Navigator.of(context).pop(false); // 不跳转
              },
            ),
            OutlinedButton(
              child: Text(localizedStrings.gBtnConfirm),
              onPressed: () {
                if (generateIpList()) {
                  Navigator.of(context).pop(true);
                } else {
                  _showErrorDialog(context, 'ip is not valid');
                }
                // 跳转
              },
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          ipAddrCtl.text = ipListNew[0];
          ipListNew.removeAt(0);
        });
      }
    });
  }

  bool isValidIPAddress(String ipAddress) {
    // IP地址的正则表达式
    RegExp ipRegex = RegExp(
        r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    return ipRegex.hasMatch(ipAddress);
  }

  bool generateIpList() {
    ipListNew = [];
    if (_ipListCtl.text.isNotEmpty) {
      List<String> lines = LineSplitter.split(_ipListCtl.text).toList();

      for (String line in lines) {
        String trimSpaceStr = line.replaceAll(r'\s', '');
        bool isValid = isValidIPAddress(trimSpaceStr);
        if (isValid) {
          ipListNew.add(trimSpaceStr);
        } else {
          return false;
        }
      }
    } else {
      return false;
    }
    File(ipFilePath).writeAsStringSync('');
    for (int i = 0; i < ipListNew.length; i++) {
      File(ipFilePath)
          .writeAsStringSync('${ipListNew[i]}\r\n', mode: FileMode.append);
    }
    if (ipListNew.isNotEmpty) {
      ipIsUsedUp = false;
    }
    return true;
  }

  bool checkDownload() {
    if (!isUpdateFirmwareSelect &&
        !isWifiSelect &&
        !isBtSelect &&
        !isPrnFmtSelect &&
        !isSerialOutput) {
      _showErrorDialog(context, 'No downloads were selected');
      return false;
    }

    if (isUpdateFirmwareSelect && firmwarePathCtl.text == '') {
      _showErrorDialog(context, 'No firmware record');
      return false;
    }

    if (isBtSelect && !isModifyBtName) {
      _showErrorDialog(context, 'No bluetooth record');
      return false;
    }

    if (isBtSelect && btNameCtl.text == '') {
      _showErrorDialog(context, 'Please enter a Bluetooth name');
      return false;
    }
    if (isWifiSelect && !isConnectAp) {
      _showErrorDialog(context, 'No WiFi connection logging');
      return false;
    }

    if (isWifiSelect && !isConnectDhcp && !isConnectStaticIp) {
      _showErrorDialog(context, 'No IP address mode,DHCP or Static');
      return false;
    }
    if (isWifiSelect &&
        isConnectStaticIp &&
        !(isAutoIncrease || isIpListSelect)) {
      _showErrorDialog(context, 'Please select a static IP rule');
      return false;
    }
    if (isWifiSelect &&
        isConnectStaticIp &&
        (isAutoIncrease || isIpListSelect) &&
        ipIsUsedUp) {
      _showErrorDialog(context, 'Static IP addresses have been used up');
      return false;
    }

    if (isPrnFmtSelect &&
        (prnFmt1Ctl.text.isEmpty &&
            prnFmt2Ctl.text.isEmpty &&
            prnFmt3Ctl.text.isEmpty &&
            prnFmt4Ctl.text.isEmpty)) {
      _showErrorDialog(context, 'No print format');
      return false;
    }
    if (isSerialOutput &&
        (serialOutput1Ctl.text.isEmpty &&
            serialOutput2Ctl.text.isEmpty &&
            serialOutput3Ctl.text.isEmpty &&
            serialOutput4Ctl.text.isEmpty &&
            serialOutput5Ctl.text.isEmpty &&
            serialOutput6Ctl.text.isEmpty)) {
      _showErrorDialog(context, 'No Serial Output format');
      return false;
    }

    if (isUpdateFirmwareSelect &&
        (isWifiSelect || isBtSelect || isPrnFmtSelect || isSerialOutput)) {
      downOtherFunc = true;
    } else {
      downOtherFunc = false;
    }

    return true;
  }

  void sendFormatToScale(String firmwarePathStr) {
    myScaleCmd.cmdMode = "update_firmware";
    myScaleCmd.cmdData = firmwarePathStr;
    PublicFunctions.sendMsg(myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
    setState(() {
      outputData.add(localizedStrings.gTipWait);
      scrollToBottom();
    });
    Timer(const Duration(seconds: 5), () {
      if (!(updateProcess > 0)) {
        setState(() {
          outputData.add(localizedStrings.gTipRebootForUpdate);
        });
      }
    });
  }

  Future<List<String>> checkAndAddPath(TextEditingController controller,
      String prefix, List<String> paths) async {
    String path = controller.text;
    if (path.isNotEmpty) {
      File file = File(path);
      if (await file.exists()) {
        paths.add(prefix + path);
      }
    }
    return paths;
  }

  void sendPrnFmtToScale() async {
    myScaleCmd.cmdMode = "down_print_format_to_scale";
    List<String> paths = [];
    paths = await checkAndAddPath(prnFmt1Ctl, '1', paths);
    paths = await checkAndAddPath(prnFmt2Ctl, '2', paths);
    paths = await checkAndAddPath(prnFmt3Ctl, '3', paths);
    paths = await checkAndAddPath(prnFmt4Ctl, '4', paths);

    if (paths.isNotEmpty) {
      myDownLoadPrtFmt.scaleModel = myDefScaleInfo.defScaleModel ?? '';
      myDownLoadPrtFmt.printerModel = 'EPM205';
      myDownLoadPrtFmt.filePaths = paths;

      myScaleCmd.cmdData = json.encode(myDownLoadPrtFmt);
      PublicFunctions.sendMsg(
          myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
    }
    writelog(jsonEncode(myScaleCmd));
  }

  void sendSerialToScale() async {
    List<String> filePaths = [
      serialOutput1Ctl.text,
      serialOutput2Ctl.text,
      serialOutput3Ctl.text,
      serialOutput4Ctl.text,
      serialOutput5Ctl.text,
      serialOutput6Ctl.text,
    ];
    List<String> jsonFilesList = [];
    for (int i = 1; i <= 6; i++) {
      String filePath = filePaths[i - 1];
      if (filePath == '') {
        continue;
      }
      File file = File(filePath);
      if (await file.exists()) {
        jsonFilesList.add('$i$filePath');
      }
    }
    if (jsonFilesList.isNotEmpty) {
      PublicFunctions.sendOutputFmtToScale(
          jsonFilesList, myDefScaleInfo.defScaleId!);
    }
  }

  void performDownload() {
    for (int i = 0; i < 7; i++) {
      if (downLoadIndex == updateFirmwareIndex &&
          isUpdateFirmwareSelect &&
          firmwarePathCtl.text.isNotEmpty) {
        outputData.add('${getDateTime()}:Now update firmware\r\n');
        sendFormatToScale(firmwarePathCtl.text);
        scrollToBottom();
        downLoadIndex++;
        return;
      }
      if (downLoadIndex == downPrintFormatIndex && isPrnFmtSelect) {
        outputData.add('${getDateTime()}:Now set print format\r\n');
        sendPrnFmtToScale();
        scrollToBottom();
        downLoadIndex++;
        return;
      }

      if (downLoadIndex == downOutputFormatIndex && isSerialOutput) {
        outputData.add('${getDateTime()}:Now set output format\r\n');
        sendSerialToScale();
        downLoadIndex++;
        return;
      }

      if (downLoadIndex == modifyBtNameIndex &&
          isBtSelect &&
          isModifyBtName &&
          btNameCtl.text.isNotEmpty) {
        PublicFunctions.getOneEepromInfo(
            'wifi_or_bt', myDefScaleInfo.defScaleId!);
        btDownloading = true;
        outputData.add('${getDateTime()}:Now modify the Bluetooth name\r\n');
        return;
      }

      if (downLoadIndex == setDhcpIndex && isWifiSelect && isConnectDhcp) {
        outputData.add('${getDateTime()}:Now set DHCP\r\n');
        wifiDhcp = true;
        PublicFunctions.getOneEepromInfo(
            'wifi_or_bt', myDefScaleInfo.defScaleId!);
        return;
      }

      if (downLoadIndex == setStaticIpIndex &&
          isWifiSelect &&
          isConnectStaticIp) {
        wifiStatic = true;
        PublicFunctions.getOneEepromInfo(
            'wifi_or_bt', myDefScaleInfo.defScaleId!);
        outputData.add('${getDateTime()}:Now set static ip\r\n');
        if (importFlag) {
          copyIpListToLocal();
        }

        return;
      }

      if (downLoadIndex == connectApIndex && isWifiSelect && isConnectAp) {
        wifiCnting = true;
        PublicFunctions.getOneEepromInfo(
            'wifi_or_bt', myDefScaleInfo.defScaleId!);
        outputData.add('${getDateTime()}:Now set AP info \r\n');

        return;
      }

      downLoadIndex++;
    }

    _showErrorDialog(context, 'This download is complete');
    outputData.add('----------------------------------');
    outputData.add('----------------------------------');
    scrollToBottom();

    if (isWifiSelect &&
        isConnectStaticIp &&
        (isAutoIncrease || isIpListSelect)) {
      if (ipListNew.isNotEmpty) {
        setState(() {
          ipAddrCtl.text = ipListNew[0];
        });

        ipListNew.removeAt(0);
      } else {
        ipIsUsedUp = true;
      }
    }
  }

  void scrollToBottom() {
    // 滚动到底部
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100), // 滚动续时间
        curve: Curves.easeInOut // 滚动曲线
        );
  }

  Widget titleStyle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 30,
      color: colorScheme.scrim,
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: const TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget title2ndStyle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 30,
      color: colorScheme.surfaceBright,
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: const TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget textStyle(String title, BoxConstraints constraint) {
    return SizedBox(
      width: constraint.maxWidth - 35,
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget checkBoxRow(
      String nameString, bool selectFlag, void Function(bool?)? onChanged) {
    // 省略部分代码
    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        Checkbox(
          value: selectFlag,
          onChanged: onChanged,
        ),
        // 省略部分代码
      ],
    );
  }
}

class CheckBoxData {
  final String name;
  bool value;
  CheckBoxData({
    required this.name,
    required this.value,
  });
}
