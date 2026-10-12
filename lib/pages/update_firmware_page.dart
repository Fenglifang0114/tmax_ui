//更新软件界面

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';
import '../widget/custom_button.dart';

class UpdateFirmwarePage extends StatefulWidget {
  const UpdateFirmwarePage({super.key});

  @override
  State<UpdateFirmwarePage> createState() => _UpdateFirmwarePageState();
}

class _UpdateFirmwarePageState extends State<UpdateFirmwarePage> {
  TextEditingController zipFileCtl = TextEditingController();
  late ScrollController _fileScrollerController;

  bool showNetworkPage = true;
  bool isSetting = false;

  String _errMsgSerial = '';
  String filePath = '';

  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _fileScrollerController = ScrollController();
    zipFileCtl.text = '';
  }

  @override
  void dispose() {
    _fileScrollerController.dispose();
    zipFileCtl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
          width: width,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surface),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // pageHeadInfo(
                //     context,
                //     width - headWidthPadding,
                //     localizedStrings.menuFirmwareUpdate,
                //     localizedStrings.gTipUpdateFirmwarePageHelp),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 设置主轴对齐方式为居中
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          localizedStrings.gTipFirmwareZipFile,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(
                        width: regularPadding,
                      ),
                      Container(
                        width: 500,
                        height: btnHeight,
                        padding: const EdgeInsets.only(
                            left: smallPadding, right: smallPadding),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(
                                width: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant)),
                        alignment: Alignment.centerLeft,
                        child: SelectableText(
                          zipFileCtl.text,
                          textAlign: TextAlign.left,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                      const SizedBox(
                        width: smallPadding,
                      ),
                      SizedBox(
                          width: 260,
                          child: showTextButton(context, btnHeight,
                              localizedStrings.gBtnSelectZipFirmware, () async {
                            zipFileCtl.text = '';
                            pickFiles(zipFileCtl);
                          },
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondaryContainer,
                              Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 设置主轴对齐方式为居中
                    children: [
                      showTextButton(
                          context,
                          btnHeight,
                          localizedStrings.gBtnDownload,
                          (isSetting || zipFileCtl.text.isEmpty)
                              ? null
                              : () {
                                  setState(() {
                                    _progress = 0.0;
                                    _errMsgSerial = "";
                                  });

                                  useNetworkUpdate();
                                },
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.onPrimary),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
              ])),
    );
  }

  Widget mainContent() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: Text(
              '',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          _buildBtnDownload(),
          SizedBox(
            height: 50,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _fileScrollerController,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 设置主轴对齐方式为居中
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          localizedStrings.gTipFirmwareZipFile,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 400,
                        // height: 40,
                        child: TextField(
                          enabled: false,
                          controller: zipFileCtl,
                          readOnly: true,
                          maxLines: 8,
                          minLines: 1,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      CustomOutlinedButton(
                        btnWidth: 150,
                        btnHeight: 40,
                        icon: Icons.file_open_outlined,
                        text: localizedStrings.gBtnSelectZipFirmware,
                        onPressed: () async {
                          zipFileCtl.text = '';
                          pickFiles(zipFileCtl);
                        },
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  Text(
                    (_errMsgSerial.contains('ok') ||
                            _errMsgSerial.contains('OK'))
                        ? 'OK'
                        : _errMsgSerial,
                    style: TextStyle(
                        fontSize: 16,
                        color: (_errMsgSerial.contains('ok') ||
                                _errMsgSerial.contains('OK') ||
                                _errMsgSerial.contains('started'))
                            ? Theme.of(context)
                                .colorScheme
                                .onTertiaryFixedVariant
                            : Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 10,
                    width: 400,
                    child: (isSetting)
                        ? LinearProgressIndicator(
                            value: _progress > 0 ? _progress : null,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondaryFixed,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary),
                          )
                        : const Text(''),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void useSerialPortUpdate(String force, int scaleId) {
    PublicFunctions.sendFormatToScale("${zipFileCtl.text.trim()},$force", scaleId);
    setState(() {
      _errMsgSerial = localizedStrings.gTipWait;
      isSetting = true;
    });
    Timer(const Duration(seconds: 10), () {
      if (!(_progress > 0) && isSetting) {
        setState(() {
          _errMsgSerial = localizedStrings.gTipRebootForUpdate;
        });
      }
    });
  }

  void useNetworkUpdate() {
    String msg = zipFileCtl.text;
    showSelScaleDialog(sendOnline, msg);
  }

  void showSelScaleDialog(int funcNo, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return SelectScalesPageNew(
          funcNo: funcNo,
          sendMsgStr: msg,
        );
      },
    );
  }

  Widget _buildBtnDownload() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomElevatedButton(
          btnWidth: 150,
          btnHeight: 50,
          icon: Icons.arrow_circle_right_outlined,
          text: localizedStrings.gBtnDownload,
          onPressed: (isSetting || zipFileCtl.text.isEmpty)
              ? null
              : () {
                  setState(() {
                    _progress = 0.0;
                    _errMsgSerial = "";
                  });

                  useNetworkUpdate();
                },
        ),
      ],
    );
  }

  Future pickFiles(TextEditingController showFilePath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result != null) {
      setState(() {
        showFilePath.text = result.files.single.path!;
        filePath = showFilePath.text;
      });
    } else {
      setState(() {
        showFilePath.text = '';
        filePath = '';
      });
    }
  }
}

int normalSend = 1; //正常的发送数据
int sendServerIp = 2; //正常的发送数据
int sendOnline = 3; //仅仅在线发送（无串口）
int comScaleSerialSend = 4; //串口类型

class ScaleDownRes {
  int scaleId;
  String res;
  double process;
  ScaleDownRes(this.scaleId, this.res, this.process);
}

class SelectScalesPageNew extends StatefulWidget {
  final int funcNo;
  final String sendMsgStr;
  final List<String>? jsonList;
  const SelectScalesPageNew({
    required this.funcNo,
    required this.sendMsgStr,
    this.jsonList,
    super.key,
  });

  @override
  SelectScalesPageNewState createState() => SelectScalesPageNewState();
}

class SelectScalesPageNewState extends State<SelectScalesPageNew> {
  final TextEditingController _deviceNameController = TextEditingController();

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;
  dynamic _eventbus9;
  dynamic _eventbus10;
  dynamic _eventbus11;
  dynamic _eventbus12;

  Map<int, bool> checkboxStatesMap = {};
  Map<int, ScaleDownRes> scaleResMap = {};
  Map<int, Timer?> scaleTimerMap = {};

  bool isDownloading = false;

  ComScaleInfo comScale = myComScaleInfo;

  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    _deviceNameController.text = '';

    for (var item in myAllScalesList) {
      checkboxStatesMap[item.scaleId] = false;
    }
    _eventbus1 = eventBus.on<EventDownPrnFmtResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });

    _eventbus2 = eventBus.on<EventDownDefPrnFmtResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });

    _eventbus3 = eventBus.on<EventRespDownPlu>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });

    _eventbus4 = eventBus.on<EventRespInsertPlu>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });

    _eventbus5 = eventBus.on<EventModifyVarValueResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });

    _eventbus6 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) {
        // setState(() {
        //   myFactoryInfoFromScale = event.obj;
        // });
      }
    });

    _eventbus7 = eventBus.on<EventSetServerIPResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });
    _eventbus8 = eventBus.on<EventUpdateFirmWareNetResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });
    _eventbus9 = eventBus.on<EventRespScaleOnline>().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });

    _eventbus10 = eventBus.on<EventRespUpdateFirmware>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        setState(() {
          if (myRespDataFromScale.msgBody.contains('fail')) {
            scaleTimerMap[myRespDataFromScale.scaleId]?.cancel();
          }

          if (!scaleResMap[myRespDataFromScale.scaleId]!.res.contains('ok')) {
            scaleResMap[myRespDataFromScale.scaleId]!.res =
                myRespDataFromScale.msgBody;
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });
    _eventbus11 = eventBus.on<EventRespUpdateFirmwareProcess>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok') ||
            myRespDataFromScale.msgBody.contains('fail')) {
          setState(() {
            if (!scaleResMap[myRespDataFromScale.scaleId]!.res.contains('ok')) {
              scaleResMap[myRespDataFromScale.scaleId]!.res =
                  myRespDataFromScale.msgBody;
            }
            if (checkAllNotEmpty()) {
              isDownloading = false;
            }
          });
        } else {
          if (myRespDataFromScale.msgBody.contains('completed')) {
            updateProgress(100, myRespDataFromScale.scaleId);
            return;
          }

          if (int.tryParse(myRespDataFromScale.msgBody) != null) {
            // 字符串全是数字
            int numericValue = int.parse(myRespDataFromScale.msgBody);
            if (numericValue <= 100) {
              numericValue = (numericValue).toInt();
            }
            updateProgress(numericValue, myRespDataFromScale.scaleId);
          } else {
            setState(() {
              if (!scaleResMap[myRespDataFromScale.scaleId]!
                  .res
                  .contains('ok')) {
                scaleResMap[myRespDataFromScale.scaleId]!.res =
                    myRespDataFromScale.msgBody;
              }
            });
          }
        }
      }
    });

    _eventbus12 = eventBus.on<EventSerialOutputResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            parseRecInfo(myRespDataFromScale.scaleId);
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });
  }

  void updateProgress(int value, int scaleId) {
    setState(() {
      _progress = value.toDouble() / 100;
      scaleResMap[scaleId]!.process = _progress;
      if (scaleResMap[scaleId]!.res != '' &&
          scaleResMap[scaleId]!.res != 'ok') {
        scaleResMap[scaleId]!.res = '';
      }
    });
  }

//根据收到的结果处理
  void parseRecInfo(int scaleId) {
    if (scaleResMap.containsKey(scaleId)) {
      scaleTimerMap[scaleId]!.cancel();
      if (myRespDataFromScale.msgBody.contains('ok')) {
        scaleResMap[scaleId]!.process = 1;
      }
      scaleResMap[scaleId]!.res = myRespDataFromScale.msgBody;
    }
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    _eventbus9.cancel();
    _eventbus10.cancel();
    _eventbus11.cancel();
    _eventbus12.cancel();

    if (scaleTimerMap.isNotEmpty) {
      scaleTimerMap.forEach((int key, Timer? timer) {
        timer!.cancel();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 1035,
        height: 800,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            Container(
                height: dialogTitleheight,
                padding: const EdgeInsets.only(
                    left: largePadding, right: largePadding),
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Container(
                    width: 3,
                    height: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    width: regularPadding,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizedStrings.gBtnDownload,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.cancel,
                        size: 24,
                        color: Theme.of(context).colorScheme.secondaryFixed,
                      ),
                      onPressed: () {
                        PublicFunctions.killBootCommander();
                        Navigator.pop(context, '');
                      })
                ])),
            // 分割线
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            // 中部
            Expanded(
                child: Container(
              padding: const EdgeInsets.all(regularPadding),
              child: Column(children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: myAllScalesList.isNotEmpty
                        ? buildNetScaleInfo()
                        : SizedBox(),
                  ),
                )
              ]),
            )),
            Container(
              height: 62,
              padding: EdgeInsets.only(bottom: regularPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  showTextButton(
                    context,
                    btnHeight,
                    localizedStrings.gBtnStart,
                    !isDownloading && checkSelect()
                        ? () {
                            showDialog(
                              context: context,
                              barrierDismissible: false, // 点击对话框外部不关闭对话框
                              builder: (BuildContext context) {
                                return ShowNormalTipDialog(
                                  title: localizedStrings.fTipTitle,
                                  msg: localizedStrings.gTipConfirmContinue,
                                );
                              },
                            ).then((value) {
                              if (value == null) {
                                return;
                              }
                              if (value) {
                                PublicFunctions.killBootCommander();
                                setState(() {
                                  isDownloading = true;
                                  for (var entry in scaleResMap.entries) {
                                    entry.value.res = "";
                                    scaleResMap[entry.key]!.process = 0;
                                  }
                                });
                                performSend();
                              } else {
                                return;
                              }
                            });
                          }
                        : null,
                    Theme.of(context).colorScheme.onPrimary,
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(width: largePadding),
                  showTextButton(
                    context,
                    btnHeight,
                    localizedStrings.gBtnExit,
                    isDownloading
                        ? null
                        : () {
                            PublicFunctions.killBootCommander();
                            Navigator.of(context).pop();
                          },
                    Theme.of(context).colorScheme.onPrimary,
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildDataCellInfo(double width, String text, Color textColor) {
    return SizedBox(
        width: width,
        child: Text(text,
            maxLines: 1,
            style: TextStyle(
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis));
  }

  Widget buildNetScaleInfo() {
    return DataTable(
      columnSpacing: 8,
      checkboxHorizontalMargin: 8,
      headingTextStyle:
          TextStyle(color: Theme.of(context).colorScheme.onSurface),
      headingRowHeight: 48,
      headingRowColor:
          WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceDim),
      dataTextStyle: Theme.of(context).textTheme.bodySmall!.apply(
          color: Theme.of(context).colorScheme.onSurface, fontSizeFactor: 0.9),
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      columns: [
        DataColumn(
          headingRowAlignment: MainAxisAlignment.start,
          label: SizedBox(),
          columnWidth: FixedColumnWidth(40),
        ),
        DataColumn(
          label: SizedBox(
            width: 80, // 设置固定宽度
            child: Text(
              localizedStrings.gStatus,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 120, // 设置固定宽度
            child: Text(
              localizedStrings.gScaleName,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 150, // 设置固定宽度
            child: Text(
              localizedStrings.gModelName + '/Sn',
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataColumn(
            label: SizedBox(
          width: 100, // 设置固定宽度
          child: Text(
            'Ip/Port',
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataColumn(
            label: SizedBox(
          width: 100, // 设置固定宽度
          child: Text(
            localizedStrings.gProgress,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataColumn(
            label: SizedBox(
          width: 345, // 设置固定宽度
          child: Text(
            localizedStrings.gTipResult,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
          ),
        )),
      ],
      rows: List.generate(
        myAllScalesList.length,
        (index) {
          Scale tempScale = myAllScalesList[index];
          return DataRow(
            color: WidgetStateProperty.all(
                Theme.of(context).colorScheme.surfaceContainerLow),
            cells: [
              DataCell(
                SizedBox(
                  width: 20, // 设置固定宽度
                  child: Checkbox(
                    value: checkboxStatesMap[tempScale.scaleId],
                    onChanged: isDownloading
                        ? null
                        : (value) {
                            setState(() {
                              checkboxStatesMap[tempScale.scaleId] = value!;
                              scaleResMap.clear();
                              checkboxStatesMap.forEach((scaleId, selected) {
                                if (selected) {
                                  int id = scaleId;
                                  ScaleDownRes newMap =
                                      ScaleDownRes(id, '', 0.0);
                                  scaleResMap[id] = newMap;
                                }
                              });
                            });
                          },
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 50,
                  child: Text(
                      tempScale.isOnline
                          ? localizedStrings.gTipOnline
                          : localizedStrings.gTipOffline,
                      maxLines: 2,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          overflow: TextOverflow.ellipsis)),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 120,
                  child: Text(tempScale.scaleName,
                      maxLines: 2,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          overflow: TextOverflow.ellipsis)),
                ),
              ),
              DataCell(
                SizedBox(
                    width: 150, // 设置固定宽度
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                              width: 150,
                              child: Text(
                                tempScale.scaleModel == "TMax"
                                    ? ""
                                    : tempScale.scaleModel,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                                overflow: TextOverflow.ellipsis,
                              )),
                          SizedBox(
                              width: 150,
                              child: Text(
                                  tempScale.scaleModel == "TMax"
                                      ? ""
                                      : tempScale.scaleSn,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                                  overflow: TextOverflow.ellipsis)),
                        ])),
              ),
              DataCell(
                SizedBox(
                    width: 100, // 设置固定宽度
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                              width: 100,
                              child: Text(
                                tempScale.tMedia == comScaleType
                                    ? (tempScale.mediaConfig
                                            as SerialMediaConfig)
                                        .devPath
                                    : tempScale.tMedia == netScaleType
                                        ? (tempScale.mediaConfig
                                                as NetworkMediaConfig)
                                            .ipAddress
                                        : (tempScale.mediaConfig
                                                as BluetoothMediaConfig)
                                            .mac,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              )),
                          SizedBox(
                              width: 100,
                              child: Text(
                                tempScale.tMedia == comScaleType
                                    ? (tempScale.mediaConfig
                                            as SerialMediaConfig)
                                        .baudRate
                                        .toString()
                                    : tempScale.tMedia == netScaleType
                                        ? (tempScale.mediaConfig
                                                as NetworkMediaConfig)
                                            .port
                                            .toString()
                                        : (tempScale.mediaConfig
                                                as BluetoothMediaConfig)
                                            .name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ))
                        ])),
              ),
              DataCell(
                SizedBox(
                  width: 100,
                  child: buildProgess(tempScale.scaleId),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 345,
                  child: Text(getResStr(tempScale.scaleId),
                      maxLines: 2,
                      style: TextStyle(
                          color: getResTextColor(tempScale.scaleId),
                          overflow: TextOverflow.ellipsis)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void showForceDialog(BuildContext context, String tipStr, int scaleId) {
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
            Row(
              children: [
                CustomElevatedButton(
                  btnWidth: 100,
                  btnHeight: 40,
                  icon: Icons.check_circle,
                  text: localizedStrings.gBtnConfirm,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                CustomOutlinedButton(
                  btnWidth: 100,
                  btnHeight: 40,
                  icon: Icons.cancel,
                  text: localizedStrings.gBtnCancel,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        useSerialPortUpdate("1", scaleId);
      }
    });
  }

  bool checkAllNotEmpty() {
    for (var value in scaleResMap.values) {
      if (!(value.res.contains('ok') ||
          value.res.contains('fail') ||
          value.res.contains('error'))) {
        return false;
      }
    }
    return true;
  }

//根据结果显示整个行的颜色
  Color getResBackColor(int id) {
    return getResStr(id).contains('ok')
        ? Theme.of(context).colorScheme.onTertiaryFixedVariant
        : Theme.of(context).colorScheme.surfaceContainerLow;
  }

  double getProcessValue(int id) {
    if (scaleResMap.containsKey(id)) {
      return scaleResMap[id]!.process;
    }
    return 0.0;
  }

  Widget buildProgess(int scaleId) {
    double progessValue = getProcessValue(scaleId);
    return LinearProgressIndicator(
      value: progessValue,
      backgroundColor: Theme.of(context).colorScheme.outline,
    );
  }

  void buildProcessTimer(int downTime) {
    scaleResMap.forEach((int id, ScaleDownRes value) {
      if (myAllScalesList.isEmpty) {
        return;
      }
      Scale tempScale = myAllScalesList[0];
      if (widget.funcNo == sendOnline) {
        for (var scale in myAllScalesList) {
          tempScale = scale;
        }
        if (tempScale.tMedia != comScaleType) {
          final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (scaleResMap[id]!.res.contains('ok')) {
              // setState(() {
              scaleResMap[id]!.process = 1;
              // });
              timer.cancel();
            } else if (scaleResMap[id]!.process < 0.8 &&
                !scaleResMap[id]!
                    .res
                    .contains(localizedStrings.gTipRebootForUpdate)) {
              setState(() {
                scaleResMap[id]!.process += 0.8 / downTime;
              });
            }
          });

          scaleTimerMap[id] = timer;
        }
      } else {
        final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (scaleResMap[id]!.res != "") {
            // setState(() {
            scaleResMap[id]!.process = 1;
            // });
            timer.cancel();
          } else if (scaleResMap[id]!.process < 0.8) {
            setState(() {
              scaleResMap[id]!.process += 0.8 / downTime;
            });
          }
        });

        scaleTimerMap[id] = timer;
      }
    });
  }

  Color getResTextColor(int id) {
    return getResStr(id).contains('ok')
        ? Theme.of(context).colorScheme.primary
        : getResStr(id) != ""
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.onSurface;
  }

//获取下发的结果
  String getResStr(int id) {
    if (scaleResMap.containsKey(id)) {
      if (scaleResMap[id] != null) {
        return scaleResMap[id]!.res;
      } else {
        return "";
      }
    }

    return "";
  }

  bool checkSelect() {
    bool res = false;

    if (checkboxStatesMap.isEmpty) {
      return res;
    }

    if (scaleResMap.isNotEmpty) {
      res = true;
    }

    return res;
  }

  void performSend() {
    scaleResMap.forEach((key, value) {
      sendMessage(key);
    });
    buildProcessTimer(120);
  }

  void sendMessage(int scaleId) {
    if (myAllScalesList.isEmpty) {
      return;
    }
    Scale tempScale = myAllScalesList[0];
    for (var scale in myAllScalesList) {
      if (scaleId == scale.scaleId) {
        tempScale = scale;
      }
    }

    if (widget.funcNo == normalSend) {
      PublicFunctions.sendMsg(scaleId, widget.sendMsgStr);
    } else if (widget.funcNo == sendServerIp) {
      PublicFunctions.sendServerIpToScale(widget.sendMsgStr, scaleId);
    } else if (widget.funcNo == sendOnline) {
      if (tempScale.tMedia == comScaleType) {
        useSerialPortUpdate('0', scaleId);
      } else {
        PublicFunctions.updateFirmWareOnline(widget.sendMsgStr.trim(), scaleId);
      }
    } else if (widget.funcNo == comScaleSerialSend) {
      PublicFunctions.sendOutputFmtToScale(widget.jsonList!, scaleId);
    }
  }

  void useSerialPortUpdate(String force, int scaleId) {
    PublicFunctions.sendFormatToScale("${widget.sendMsgStr.trim()},$force", scaleId);
    setState(() {
      scaleResMap[scaleId]!.res = localizedStrings.gTipRebootForUpdate;
      isDownloading = true;
    });
    // Timer(const Duration(seconds: 2), () {
    //   if (!(_progress > 0) && isDownloading) {
    //     setState(() {
    //       scaleResMap[scaleId]!.res = localizedStrings.gTipRebootForUpdate;
    //     });
    //   }
    // });
  }
}

// 新增秤的弹窗
class AddScaleDialog1 extends StatefulWidget {
  const AddScaleDialog1({super.key});
  @override
  AddScaleDialog1State createState() => AddScaleDialog1State();
}

class AddScaleDialog1State extends State<AddScaleDialog1> {
  bool isComHovered = false;
  bool isWifiHovered = false;
  bool isBtHovered = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 1035,
        height: 600,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            Container(
                height: dialogTitleheight,
                padding: const EdgeInsets.only(
                    left: largePadding, right: largePadding),
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Container(
                    width: 3,
                    height: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    width: regularPadding,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizedStrings.gBtnDownload,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.cancel,
                        size: 24,
                        color: Theme.of(context).colorScheme.secondaryFixed,
                      ),
                      onPressed: () {
                        Navigator.pop(context, '');
                      })
                ])),
            // 分割线
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            // 中部
            Expanded(
              child: Container(
                  padding: const EdgeInsets.all(26),
                  height: 200,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MouseRegion(
                          onEnter: (_) => setState(() => isComHovered = true),
                          onExit: (_) => setState(() => isComHovered = false),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context, 'com');
                            },
                            child: Container(
                                width: 140,
                                height: 120,
                                alignment: Alignment.center,
                                color: isComHovered
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLow,
                                child: getSvgIcon(
                                    serialPortSvgIcon(),
                                    btnHeight,
                                    btnHeight,
                                    isComHovered
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary)),
                          ),
                        ),
                        SizedBox(
                          width: largePadding,
                        ),
                        MouseRegion(
                          onEnter: (_) => setState(() => isWifiHovered = true),
                          onExit: (_) => setState(() => isWifiHovered = false),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context, 'wifi');
                            },
                            child: Container(
                                width: 140,
                                height: 120,
                                alignment: Alignment.center,
                                color: isWifiHovered
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLow,
                                child: getSvgIcon(
                                    networkSvgIcon(),
                                    btnHeight,
                                    btnHeight,
                                    isWifiHovered
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary)),
                          ),
                        ),
                        SizedBox(
                          width: largePadding,
                        ),
                      ])),
            ),
          ],
        ),
      ),
    );
  }
}
