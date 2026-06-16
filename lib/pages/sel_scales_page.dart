import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_max/functions/methods.dart';
import '../../eventbus/eventbus.dart';
import '../data/comscaleinfo_data.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';

import '../data/screen_mgr.dart';
import '../widget/custom_button.dart';

int normalSend = 1; //正常的发送数据
int sendServerIp = 2; //正常的发送数据
int sendOnline = 3; //仅仅在线发送（无串口）

class ScaleDownRes {
  int scaleId;
  String res;
  double process;
  ScaleDownRes(this.scaleId, this.res, this.process);
}

class SelectScalesPage extends StatefulWidget {
  final int funcNo;
  final String sendMsgStr;
  const SelectScalesPage({
    required this.funcNo,
    required this.sendMsgStr,
    super.key,
  });

  @override
  SelectScalesPageState createState() => SelectScalesPageState();
}

class SelectScalesPageState extends State<SelectScalesPage> {
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

  // List<bool> checkboxStates = [];
  Map<int, bool> checkboxStatesMap = {};
  List<NetScaleInfoLocal> scaleNetItems = [];
  Map<int, ScaleDownRes> scaleResMap = {};
  Map<int, Timer?> scaleTimerMap = {};

  bool isDownloading = false;
  bool isSelectCom = false;
  ComScaleInfo comScale = myComScaleInfo;

  @override
  void initState() {
    super.initState();

    _deviceNameController.text = '';
    scaleNetItems = myNetScaleList;
    for (var item in scaleNetItems) {
      checkboxStatesMap[item.scaleId!] = false;
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
    if (scaleTimerMap.isNotEmpty) {
      scaleTimerMap.forEach((int key, Timer? timer) {
        timer!.cancel();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: getDialogTitle(
          context, localizedStrings.gBtnDownload, Icons.download, 800),
      contentPadding: const EdgeInsets.fromLTRB(24, 5, 24, 5),
      content: Container(
          height: 500,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
          child: Column(
            children: [
              widget.funcNo != sendOnline
                  ? buildComScaleInfo()
                  : const SizedBox(),
              widget.funcNo != sendOnline
                  ? Container(
                      height: 2,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : const SizedBox(),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: scaleNetItems.isNotEmpty
                      ? buildNetScaleInfo()
                      : SizedBox(),
                ),
              ),
            ],
          )),
      actions: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Container(
            height: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomOutlinedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.check_circle,
              text: localizedStrings.gBtnConfirm,
              onPressed: !isDownloading && checkSelect()
                  ? () {
                      setState(() {
                        isDownloading = true;
                        scaleResMap.clear();
                      });
                      if (checkSelect()) {
                        performSend();
                      }
                    }
                  : null,
            ),
            const SizedBox(width: 20),
            CustomOutlinedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.cancel,
              text: localizedStrings.gBtnCancel,
              onPressed: isDownloading
                  ? null
                  : () {
                      myScreenMgr.isMainScreen = true;
                      Navigator.of(context).pop();
                    },
            ),
            const SizedBox(width: 16),
          ],
        )
      ],
    );
  }

  Widget buildComScaleInfo() {
    return DataTable(
      headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface),
      columns: [
        DataColumn(label: Text('')),
        DataColumn(label: Text(localizedStrings.gStatus)),
        DataColumn(label: Text(localizedStrings.gScaleName)),
        DataColumn(
            label: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(localizedStrings.gModelName),
            Text('Sn'),
          ],
        )),
        DataColumn(label: Text('COM')),
        DataColumn(label: Text(localizedStrings.gProgress)),
        DataColumn(label: Text(localizedStrings.gTipResult)),
      ],
      rows: List.generate(
        1,
        (index) => DataRow(
          color: WidgetStateProperty.all(getResBackColor(comScale.scaleId)),
          cells: [
            DataCell(Checkbox(
              value: isSelectCom,
              onChanged: isDownloading
                  ? null
                  : (value) {
                      setState(() {
                        isSelectCom = value!;
                        scaleResMap.clear();
                        if (checkboxStatesMap.isNotEmpty && isSelectCom) {
                          for (var item in scaleNetItems) {
                            checkboxStatesMap[item.scaleId!] = false;
                          }
                        }
                      });
                    },
            )),
            DataCell(
              SizedBox(
                width: 50,
                child: Text(
                    comScale.isOnline
                        ? localizedStrings.gTipOnline
                        : localizedStrings.gTipOffline,
                    maxLines: 2,
                    style: TextStyle(
                        color: getResTextColor(comScale.scaleId),
                        overflow: TextOverflow.ellipsis)),
              ),
            ),
            DataCell(
              SizedBox(
                width: 150,
                child: Text(comScale.scaleName,
                    maxLines: 2,
                    style: TextStyle(
                        color: getResTextColor(comScale.scaleId),
                        overflow: TextOverflow.ellipsis)),
              ),
            ),
            DataCell(Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildDataCellInfo(120, comScale.scaleModel,
                      getResTextColor(comScale.scaleId)),
                  buildDataCellInfo(
                      120, comScale.scaleSn, getResTextColor(comScale.scaleId)),
                ])),
            DataCell(
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildDataCellInfo(100, comScale.portName,
                        getResTextColor(comScale.scaleId)),
                    buildDataCellInfo(100, comScale.baudRate.toString(),
                        getResTextColor(comScale.scaleId))
                  ]),
            ),
            DataCell(
              SizedBox(
                width: 80,
                child: buildProgess(comScale.scaleId),
              ),
            ),
            DataCell(
              buildDataCellInfo(400, getResStr(comScale.scaleId),
                  getResTextColor(comScale.scaleId)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDataCellInfo(double width, String text, Color textColor) {
    return SizedBox(
        width: width,
        child: Text(text,
            maxLines: 2,
            style:
                TextStyle(color: textColor, overflow: TextOverflow.ellipsis)));
  }

  Widget buildNetScaleInfo() {
    return DataTable(
      headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface),
      columns: [
        DataColumn(label: Text('')),
        DataColumn(label: Text(localizedStrings.gStatus)),
        DataColumn(label: Text(localizedStrings.gScaleName)),
        DataColumn(
            label: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(localizedStrings.gModelName),
            Text('Sn'),
          ],
        )),
        DataColumn(label: Text('Ip')),
        DataColumn(label: Text(localizedStrings.gProgress)),
        DataColumn(label: Text(localizedStrings.gTipResult)),
      ],
      rows: List.generate(
        scaleNetItems.length,
        (index) => DataRow(
          color: WidgetStateProperty.all(
              getResBackColor(scaleNetItems[index].scaleId!)),
          cells: [
            DataCell(Checkbox(
              value: checkboxStatesMap[scaleNetItems[index].scaleId!],
              onChanged: isDownloading
                  ? null
                  : (value) {
                      setState(() {
                        checkboxStatesMap[scaleNetItems[index].scaleId!] =
                            value!;
                        isSelectCom = false;
                        scaleResMap.clear();
                      });
                    },
            )),
            DataCell(
              SizedBox(
                width: 50,
                child: Text(
                    scaleNetItems[index].isOnline!
                        ? localizedStrings.gTipOnline
                        : localizedStrings.gTipOffline,
                    maxLines: 2,
                    style: TextStyle(
                        color: getResTextColor(scaleNetItems[index].scaleId!),
                        overflow: TextOverflow.ellipsis)),
              ),
            ),
            DataCell(
              SizedBox(
                width: 150,
                child: Text(scaleNetItems[index].scaleName!,
                    maxLines: 2,
                    style: TextStyle(
                        color: getResTextColor(scaleNetItems[index].scaleId!),
                        overflow: TextOverflow.ellipsis)),
              ),
            ),
            DataCell(Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      width: 120,
                      child: Text(
                          scaleNetItems[index].scaleModel! == "TMax"
                              ? ""
                              : scaleNetItems[index].scaleModel!,
                          style: TextStyle(
                              color: getResTextColor(
                                  scaleNetItems[index].scaleId!)))),
                  SizedBox(
                      width: 120,
                      child: Text(
                          scaleNetItems[index].scaleSn!,
                          style: TextStyle(
                              color: getResTextColor(
                                  scaleNetItems[index].scaleId!)))),
                ])),
            DataCell(
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: 100,
                        child: Text(scaleNetItems[index].ip!,
                            style: TextStyle(
                                color: getResTextColor(
                                    scaleNetItems[index].scaleId!)))),
                    SizedBox(
                        width: 100,
                        child: Text(scaleNetItems[index].port!.toString(),
                            style: TextStyle(
                                color: getResTextColor(
                                    scaleNetItems[index].scaleId!))))
                  ]),
            ),
            DataCell(
              SizedBox(
                width: 80,
                child: buildProgess(scaleNetItems[index].scaleId!),
              ),
            ),
            DataCell(
              SizedBox(
                width: 400,
                child: Text(getResStr(scaleNetItems[index].scaleId!),
                    maxLines: 2,
                    style: TextStyle(
                        color: getResTextColor(scaleNetItems[index].scaleId!),
                        overflow: TextOverflow.ellipsis)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool checkAllNotEmpty() {
    for (var value in scaleResMap.values) {
      if (value.res.isEmpty) {
        return false;
      }
    }
    return true;
  }

//根据结果显示整个行的颜色
  Color getResBackColor(int id) {
    return getResStr(id).contains('ok')
        ? Theme.of(context).colorScheme.onTertiaryFixedVariant
        : Theme.of(context).colorScheme.surfaceTint;
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
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (scaleResMap[id]!.res != "") {
          // setState(() {
          scaleResMap[id]!.process = 1;
          // });
          timer.cancel();
        } else if (scaleResMap[id]!.process < 0.9) {
          setState(() {
            scaleResMap[id]!.process += 0.9 / downTime;
          });
        }
      });

      scaleTimerMap[id] = timer;
    });
  }

  Color getResTextColor(int id) {
    return getResStr(id).contains('ok')
        ? Theme.of(context).colorScheme.onPrimary
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
    scaleResMap.clear();
    if (isSelectCom) {
      int id = comScale.scaleId;
      ScaleDownRes newMap = ScaleDownRes(id, '', 0.0);
      scaleResMap[id] = newMap;
      return true;
    }
    if (checkboxStatesMap.isEmpty) {
      return false;
    }

    checkboxStatesMap.forEach((scaleId, selected) {
      if (selected) {
        int id = scaleId;
        ScaleDownRes newMap = ScaleDownRes(id, '', 0.0);
        scaleResMap[id] = newMap;
      }
    });
    if (scaleResMap.isEmpty) {
      return false;
    }

    return true;
  }

  void performSend() {
    scaleResMap.forEach((key, value) {
      sendMessage(key);
    });
    buildProcessTimer(240);
  }

  void sendMessage(int scaleId) {
    if (widget.funcNo == normalSend) {
      PublicFunctions.sendMsg(scaleId, widget.sendMsgStr);
    } else if (widget.funcNo == sendServerIp) {
      PublicFunctions.sendServerIpToScale(widget.sendMsgStr, scaleId);
    } else if (widget.funcNo == sendOnline) {
      PublicFunctions.updateFirmWareOnline(widget.sendMsgStr, scaleId);
    }
  }
}
