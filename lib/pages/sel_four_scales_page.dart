import 'package:flutter/material.dart';
import 'package:t_max/pages/production_line_page.dart';
import '../../eventbus/eventbus.dart';
import '../data/comscaleinfo_data.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../data/screen_mgr.dart';
import '../widget/custom_button.dart';
import 'four_weightings.dart';

const weightingMode = 1;
const checkWeightingMode = 2;

class SltFourScalesPage extends StatefulWidget {
  final int mode;
  const SltFourScalesPage({
    required this.mode,
    super.key,
  });

  @override
  SltFourScalesPageState createState() => SltFourScalesPageState();
}

class SltFourScalesPageState extends State<SltFourScalesPage> {
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;

  List<bool> checkboxStates = [];
  List<NetScaleInfoLocal> scaleNetItems = [];
  int scaleNum = 0;
  List<Map<int, String>> scaleResMap = [];
  bool isDownloading = false;
  bool isSelectCom = false;
  ComScaleInfo comScale = myComScaleInfo;

  @override
  void initState() {
    super.initState();

    scaleNum = (myNetScaleList.length);
    if (scaleNum > 0) {
      checkboxStates = List.filled(scaleNum, false);
    }

    scaleNetItems = myNetScaleList;
    _eventbus1 = eventBus.on<EventDownPrnFmtResp>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;
          if (myRespDataFromScale.msgBody.isNotEmpty) {
            int id = myRespDataFromScale.scaleId;
            for (var map in scaleResMap) {
              if (map.containsKey(id)) {
                map[id] = myRespDataFromScale.msgBody;
                break; // 找到并修改后就可以退出循环了
              }
            }
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
            int id = myRespDataFromScale.scaleId;
            for (var map in scaleResMap) {
              if (map.containsKey(id)) {
                map[id] = myRespDataFromScale.msgBody;
                break; // 找到并修改后就可以退出循环了
              }
            }
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
            int id = myRespDataFromScale.scaleId;
            for (var map in scaleResMap) {
              if (map.containsKey(id)) {
                map[id] = myRespDataFromScale.msgBody;
                break; // 找到并修改后就可以退出循环了
              }
            }
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
            int id = myRespDataFromScale.scaleId;
            for (var map in scaleResMap) {
              if (map.containsKey(id)) {
                map[id] = myRespDataFromScale.msgBody;
                break; // 找到并修改后就可以退出循环了
              }
            }
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
            int id = myRespDataFromScale.scaleId;
            for (var map in scaleResMap) {
              if (map.containsKey(id)) {
                map[id] = myRespDataFromScale.msgBody;
                break; // 找到并修改后就可以退出循环了
              }
            }
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
            int id = myRespDataFromScale.scaleId;
            for (var map in scaleResMap) {
              if (map.containsKey(id)) {
                map[id] = myRespDataFromScale.msgBody;
                break; // 找到并修改后就可以退出循环了
              }
            }
          }

          if (checkAllNotEmpty()) {
            isDownloading = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus6.cancel();
    _eventbus7.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: getDialogTitle(context, 'Select Scales', Icons.scale, 800),
      contentPadding: EdgeInsets.fromLTRB(24, 5, 24, 5),
      content: Container(
          height: 500,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surfaceTint),
          child: Column(
            children: [
              // buildComScaleInfo(),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: buildNetScaleInfo(),
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
              onPressed: isDownloading || !checkSelect()
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      setState(() {
                        isDownloading = true;
                        scaleResMap.clear();
                      });
                      if (checkSelect()) {
                        performSend();
                      }
                    },
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
      columns: const [
        DataColumn(label: Text('Select')),
        DataColumn(
            label: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('ModelName'),
            Text('Sn'),
          ],
        )),
        DataColumn(label: Text('COM')),
        DataColumn(label: Text('Baud')),
        DataColumn(label: Text('Result')),
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
                        if (scaleNum > 0 && isSelectCom) {
                          checkboxStates = List.filled(scaleNum, false);
                        }
                      });
                    },
            )),
            DataCell(Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildDataCellInfo(
                      150,
                      comScale.scaleModel == "TMax" ? "" : comScale.scaleModel,
                      getResTextColor(comScale.scaleId)),
                  buildDataCellInfo(
                      150,
                      comScale.scaleModel == "TMax" ? "" : comScale.scaleSn,
                      getResTextColor(comScale.scaleId)),
                ])),
            DataCell(buildDataCellInfo(
                150, comScale.portName, getResTextColor(comScale.scaleId))),
            DataCell(buildDataCellInfo(60, comScale.baudRate.toString(),
                getResTextColor(comScale.scaleId))),
            DataCell(
              buildDataCellInfo(300, getResStr(comScale.scaleId),
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
      columns: const [
        DataColumn(label: Text('Select')),
        DataColumn(
            label: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('ModelName'),
            Text('Sn'),
          ],
        )),
        DataColumn(label: Text('Ip')),
        DataColumn(label: Text('Port')),
        DataColumn(label: Text('Result')),
      ],
      rows: List.generate(
        scaleNum,
        (index) => DataRow(
          color: WidgetStateProperty.all(
              getResBackColor(scaleNetItems[index].scaleId!)),
          cells: [
            DataCell(Checkbox(
              value: checkboxStates[index],
              onChanged: isDownloading
                  ? null
                  : (value) {
                      setState(() {
                        checkboxStates[index] = value!;
                        isSelectCom = false;
                        scaleResMap.clear();
                      });
                    },
            )),
            DataCell(Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      width: 150,
                      child: Text(
                          scaleNetItems[index].scaleModel! == "TMax"
                              ? ""
                              : scaleNetItems[index].scaleModel!,
                          style: TextStyle(
                              color: getResTextColor(
                                  scaleNetItems[index].scaleId!)))),
                  SizedBox(
                      width: 150,
                      child: Text(
                          scaleNetItems[index].scaleSn!,
                          style: TextStyle(
                              color: getResTextColor(
                                  scaleNetItems[index].scaleId!)))),
                ])),
            DataCell(SizedBox(
                width: 150,
                child: Text(scaleNetItems[index].ip!,
                    style: TextStyle(
                        color:
                            getResTextColor(scaleNetItems[index].scaleId!))))),
            DataCell(SizedBox(
                width: 60,
                child: Text(scaleNetItems[index].port!.toString(),
                    style: TextStyle(
                        color:
                            getResTextColor(scaleNetItems[index].scaleId!))))),
            DataCell(
              SizedBox(
                width: 300,
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
    for (var map in scaleResMap) {
      for (var value in map.values) {
        if (value == "") {
          return false;
        }
      }
    }
    return true;
  }

  Color getResBackColor(int id) {
    return getResStr(id).contains('ok')
        ? Theme.of(context).colorScheme.onTertiaryFixedVariant
        : Theme.of(context).colorScheme.surfaceTint;
  }

  Color getResTextColor(int id) {
    return getResStr(id).contains('ok')
        ? Theme.of(context).colorScheme.onPrimary
        : getResStr(id) != ""
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.onSurface;
  }

  String getResStr(int id) {
    for (var map in scaleResMap) {
      if (map.containsKey(id)) {
        if (map[id] != null) {
          return map[id]!;
        } else {
          return "";
        }
      }
    }
    return "";
  }

  bool checkSelect() {
    if (checkboxStates.isEmpty) {
      return false;
    }
    scaleResMap.clear();

    for (int i = 0; i < checkboxStates.length; i++) {
      if (checkboxStates[i]) {
        int id = scaleNetItems[i].scaleId!;
        Map<int, String> newMap = {id: ""};
        scaleResMap.add(newMap);
      }
    }

    // if (isSelectCom) {
    //   int id = comScale.scaleId;
    //   Map<int, String> newMap = {id: ""};
    //   scaleResMap.add(newMap);
    // }

    if (scaleResMap.isEmpty) {
      return false;
    }
    if (scaleResMap.length > 4) {
      return false;
    }

    return true;
  }

  void performSend() {
    fourScaleList.clear();
    for (var map in scaleResMap) {
      map.forEach((key, value) {
        // print(key);
        NetScaleInfoLocal tempScale =
            NetScaleListMgr.findScaleInfo(myNetScaleList, key);
        fourScaleList.add(tempScale);
      });
    }
    if (widget.mode == weightingMode) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FourWeightsPage()),
      );
    } else if (widget.mode == checkWeightingMode) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProductionLinePage()),
      );
    }
  }
}
