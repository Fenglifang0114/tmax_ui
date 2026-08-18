import 'dart:convert';
import 'dart:io';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/scale_info_from_scale.dart';
import 'package:t_max/data/seal_log.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dialog_head_style.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/version.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/language.dart';
import '../data/timer_manager.dart';

class CalibrationSealPage extends StatefulWidget {
  const CalibrationSealPage({super.key});
  @override
  State<CalibrationSealPage> createState() => CalibrationSealPageState();
}

class CalibrationSealPageState extends State<CalibrationSealPage> {
  dynamic eventBus1;
  dynamic eventBus3;
  dynamic eventBus4;
  dynamic eventBus5;
  dynamic eventBus6;
  dynamic eventBus7;
  dynamic eventBus8;

  bool enabledGetInfo = true;

  String hardSealStatus = ''; //
  String softSealStatus = '';

  TextEditingController olCntCtl = TextEditingController(text: '');
  List<SealLogInfo> sealLogInfoList = [];

  int selScaleId = -1;
  bool isPass = false;
  Future<void> setAppInfo() async {
    await openAppJson();
  }

  bool _sortAscending = true;
  int? _sortColumnIndex;

  @override
  void initState() {
    super.initState();
    cntScaleTimerMgr.stopCntScaleTimer();

    setAppInfo().then((value) => setState(() {}));
    isPass = myLicenseInfo.isValid;

    eventBus1 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) {
        try {
          OnlineInfo myOnlineInfo = event.obj;

          if (selScaleId != myOnlineInfo.scaleId ||
              myOnlineInfo.factInfo!.modelName == "" ||
              myOnlineInfo.factInfo!.scaleSn == "") {
            return;
          }
          Scale? currentScale;
          for (var scale in myAllScalesList) {
            if (scale.scaleId == selScaleId) {
              currentScale = scale;
              break;
            }
          }
          String modelName =
              currentScale?.scaleModel ?? myOnlineInfo.factInfo!.modelName!;

          ReqGetSealLog reqGetSealLog =
              ReqGetSealLog(modelName, myOnlineInfo.factInfo!.scaleSn!);
          String jsonStr = jsonEncode(reqGetSealLog);

          PublicFunctions.getSealLog(jsonStr);
        } catch (e) {
          // print(e);
        }
      }
    });

    eventBus3 = eventBus.on<EventRevGetSealStatus>().listen((event) {
      //修改了ScaleId
      if (mounted) {
        String dataStr = event.obj;
        setState(() {
          enabledGetInfo = true;
        });
        PublicFunctions.checkSerialPort(selScaleId);

        if (dataStr.contains('fail') || dataStr.contains('time out')) {
          showTipInfo(localizedStrings.checkSealFailed, context);
          setState(() {
            softSealStatus = "";
            hardSealStatus = "";
          });
        } else {
          List<String> splitData = dataStr.split(',');

          setState(() {
            hardSealStatus = splitData[0];
            softSealStatus = splitData[1];
          });
        }
      }
    });
    eventBus4 = eventBus.on<EventRevSoftSeal>().listen((event) {
      //修改了ScaleId
      if (mounted) {
        String dataStr = event.obj;
        setState(() {
          enabledGetInfo = true;
        });
        if (dataStr.contains('fail') || dataStr.contains('time out')) {
          showDialog(
            context: context,
            barrierDismissible: false, // 点击对话框外部不关闭对话框
            builder: (BuildContext context) {
              return ShowSealTipDialog(
                title: localizedStrings.fTipTitle,
                msg: localizedStrings.softwareSealAppliedFailed,
                iconPath: failedSvgIcon(),
                iconColor: Theme.of(context).colorScheme.error,
              );
            },
          );
        } else {
          showDialog(
            context: context,
            barrierDismissible: false, // 点击对话框外部不关闭对话框
            builder: (BuildContext context) {
              return ShowSealTipDialog(
                title: localizedStrings.fTipTitle,
                msg: localizedStrings.softwareSealAppliedSuccessfully,
                iconPath: sealOkSvgIcon(),
                iconColor: Theme.of(context).colorScheme.onTertiaryFixedVariant,
              );
            },
          );
          PublicFunctions.getSealStatus(selScaleId);
          setState(() {
            enabledGetInfo = false;
          });
        }
      }
    });
    eventBus5 = eventBus.on<EventRevRemoveSoftSeal>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        setState(() {
          enabledGetInfo = true;
        });
        if (dataStr.contains('fail') || dataStr.contains('time out')) {
          showDialog(
            context: context,
            barrierDismissible: false, // 点击对话框外部不关闭对话框
            builder: (BuildContext context) {
              return ShowUnsealFailedDialog(
                title: localizedStrings.fTipTitle,
                msg: localizedStrings.softwareSealRemovalFailed,
                iconPath: failedSvgIcon(),
                iconColor: Theme.of(context).colorScheme.error,
              );
            },
          );
        } else {
          if (dataStr.contains("ok")) {
            showDialog(
              context: context,
              barrierDismissible: false, // 点击对话框外部不关闭对话框
              builder: (BuildContext context) {
                return ShowSealTipDialog(
                  title: localizedStrings.fTipTitle,
                  msg: localizedStrings.softwareSealRemovedSuccessfully,
                  iconPath: unlockOkSvgIcon(),
                  iconColor:
                      Theme.of(context).colorScheme.onTertiaryFixedVariant,
                );
              },
            ).then((value) {
              PublicFunctions.getSealStatus(selScaleId);
              setState(() {
                enabledGetInfo = false;
              });
            });
          }
        }
      }
    });
    eventBus6 = eventBus.on<EventShowSealOnce>().listen((event) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ShowUnSealOnceDialog(scaleId: selScaleId),
        );
      }
    });

    eventBus7 = eventBus.on<EventRespGetAllSealLog>().listen((event) {
      if (mounted) {
        String jsonStr = event.obj;
        if (jsonStr.isEmpty) {
          setState(() {
            sealLogInfoList = [];
          });
          return;
        }
        try {
          sealLogInfoList = sealLogInfoFromJson(jsonStr);

          setState(() {
            sealLogInfoList
                .sort((a, b) => b.operationTime!.compareTo(a.operationTime!));
          });
        } catch (e) {
          // print(e);
        }
      }
    });

    eventBus8 = eventBus.on<EventRevRemoveSoftSealOnce>().listen((event) {
      //修改了ScaleId
      if (mounted) {
        String dataStr = event.obj;

        if (dataStr.isEmpty) {
          return;
        }

        if (dataStr.contains('fail')) {
          showTipInfo(localizedStrings.removeSealFailed, context);
          return;
        } else {
          PublicFunctions.getSealStatus(selScaleId);
          setState(() {
            enabledGetInfo = false;
          });
        }
      }
    });

    // 在页面构建完成后显示提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (myAllScalesList.isEmpty) {
        showTipInfo(localizedStrings.gTipNoDeviceAddFirst, context);
      } else {
        if (selScaleId == -1) {
          showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
        }
      }
    });
  }

  @override
  void dispose() {
    eventBus1.cancel();
    eventBus3.cancel();
    eventBus4.cancel();
    eventBus5.cancel();
    eventBus6.cancel();
    eventBus7.cancel();
    eventBus8.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: firstLayout(context, width),
    );
  }

  Widget firstLayout(context, width) {
    return Container(
        width: width,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: scaleListWidth,
                  color: Theme.of(context).colorScheme.surfaceTint,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          height: regularPadding,
                        ),
                        Expanded(
                          child: NewAllScaleListWidget(
                            listWidth: scaleListWidth, // 列表宽度
                            selScaleId: selScaleId,
                            clickScale: (scale) {
                              if (!enabledGetInfo) {
                                showTipInfo(
                                    localizedStrings.gTipPerformingOperation,
                                    context);
                                return;
                              }
                              setState(() {
                                changeScale(scale.scaleId);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  color: Theme.of(context).colorScheme.outlineVariant, //  分隔条颜色
                ),
                myAllScalesList.isEmpty
                    ? SizedBox()
                    : Expanded(
                        child: Container(
                        padding: const EdgeInsets.all(largePadding),
                        child: Column(children: [
                          SizedBox(
                              height: 230,
                              child: Column(children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 300,
                                      child: Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceDim,
                                        child: Row(
                                          children: [
                                            Container(
                                                width: 78,
                                                height: 78,
                                                alignment: Alignment.center,
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withAlpha(50),
                                                    ),
                                                    width: scaleItemHeight,
                                                    height: scaleItemHeight,
                                                    child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: 42,
                                                        height: 42,
                                                        child: getSvgIcon(
                                                            hardwareSealSvgIcon(),
                                                            42,
                                                            42,
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary)))),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    localizedStrings
                                                        .hardwareSeal,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .apply(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    hardSealStatus == "true"
                                                        ? localizedStrings
                                                            .sealed
                                                        : hardSealStatus ==
                                                                "false"
                                                            ? localizedStrings
                                                                .notSealed
                                                            : localizedStrings
                                                                .toBeVerified,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .apply(
                                                          color: hardSealStatus ==
                                                                  "true"
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .error
                                                              : hardSealStatus ==
                                                                      "false"
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onTertiaryFixedVariant
                                                                  : Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: largePadding),
                                    SizedBox(
                                      width: 300,
                                      child: Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceDim,
                                        child: Row(
                                          children: [
                                            Container(
                                                width: 78,
                                                height: 78,
                                                alignment: Alignment.center,
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onTertiaryFixedVariant
                                                          .withAlpha(51),
                                                    ),
                                                    width: scaleItemHeight,
                                                    height: scaleItemHeight,
                                                    child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: 42,
                                                        height: 42,
                                                        child: getSvgIcon(
                                                            softwareSealSvgIcon(),
                                                            42,
                                                            42,
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .onTertiaryFixedVariant)))),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    localizedStrings
                                                        .softwareSeal,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .apply(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    softSealStatus == "true"
                                                        ? localizedStrings
                                                            .softwareLocked
                                                        : softSealStatus ==
                                                                "false"
                                                            ? localizedStrings
                                                                .softwareUnlocked
                                                            : localizedStrings
                                                                .toBeVerified,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .apply(
                                                          color: softSealStatus ==
                                                                  "true"
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .error
                                                              : softSealStatus ==
                                                                      "false"
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onTertiaryFixedVariant
                                                                  : Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: showTextButton(
                                          context,
                                          btnHeight,
                                          localizedStrings.checkSeal,
                                          enabledGetInfo
                                              ? () {
                                                  if (selScaleId == -1) {
                                                    showTipInfo(
                                                        localizedStrings
                                                            .gTipSelectDeviceFirst,
                                                        context);
                                                    return;
                                                  }
                                                  PublicFunctions.getSealStatus(
                                                      selScaleId);
                                                  setState(() {
                                                    enabledGetInfo = false;
                                                  });
                                                }
                                              : null,
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    ),
                                    SizedBox(
                                      width: 14,
                                    ),
                                    Container(
                                      child: showTextButton(
                                          context,
                                          btnHeight,
                                          localizedStrings.applySoftwareSeal,
                                          softSealStatus == "false" &&
                                                  enabledGetInfo
                                              ? () {
                                                  String sealCode =
                                                      getSealCode();
                                                  if (sealCode.isEmpty) {
                                                    return;
                                                  }
                                                  PublicFunctions.softSeal(
                                                      selScaleId, sealCode);
                                                  setState(() {
                                                    enabledGetInfo = false;
                                                  });
                                                }
                                              : null,
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          Theme.of(context).colorScheme.error,
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    ),
                                    SizedBox(
                                      width: 14,
                                    ),
                                    Container(
                                      child: showTextButton(
                                          context,
                                          btnHeight,
                                          localizedStrings.removeSoftwareSeal,
                                          softSealStatus == "true" &&
                                                  enabledGetInfo
                                              ? () {
                                                  String sealCode =
                                                      getSealCode();
                                                  if (sealCode.isEmpty) {
                                                    return;
                                                  }

                                                  PublicFunctions
                                                      .removeSoftSeal(
                                                          selScaleId, sealCode);
                                                  setState(() {
                                                    enabledGetInfo = false;
                                                  });
                                                }
                                              : null,
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          Theme.of(context)
                                              .colorScheme
                                              .onTertiaryFixedVariant,
                                          Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    ),
                                  ],
                                ),
                                SizedBox(height: largePadding),
                                Divider(
                                  height: 1,
                                ),
                                SizedBox(height: largePadding),
                              ])),
                          Expanded(
                            child: DataTable2(
                              columnSpacing: 12,
                              horizontalMargin: 12,
                              minWidth: 800,
                              sortColumnIndex: _sortColumnIndex,
                              sortAscending: _sortAscending,
                              headingRowHeight: 45,
                              headingRowColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.surfaceDim),
                              columns: [
                                DataColumn2(
                                  label: Text(
                                    localizedStrings.fTipOperation,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  size: ColumnSize.M,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      sealLogInfoList.sort((a, b) => ascending
                                          ? a.operation!.compareTo(b.operation!)
                                          : b.operation!
                                              .compareTo(a.operation!));
                                    });
                                  },
                                ),
                                DataColumn2(
                                  label: Text(
                                    localizedStrings.operator,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  size: ColumnSize.S,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      sealLogInfoList.sort((a, b) => ascending
                                          ? a.operator!.compareTo(b.operator!)
                                          : b.operator!.compareTo(a.operator!));
                                    });
                                  },
                                ),
                                DataColumn2(
                                  label: Text(
                                    localizedStrings.fCreatedAtCol,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  size: ColumnSize.M,
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      sealLogInfoList.sort((a, b) => ascending
                                          ? a.operationTime!
                                              .compareTo(b.operationTime!)
                                          : b.operationTime!
                                              .compareTo(a.operationTime!));
                                    });
                                  },
                                ),
                              ],
                              rows: sealLogInfoList.map((seallog) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        seallog.operation! == "seal"
                                            ? localizedStrings.fTipSeal
                                            : localizedStrings.fTipUnseal,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: _getDeptColor(
                                                    seallog.operation!)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    DataCell(Text(
                                      seallog.operator!,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                    DataCell(Text(
                                      '${seallog.operationTime!.year}-${seallog.operationTime!.month}-${seallog.operationTime!.day} ${seallog.operationTime!.hour}:${seallog.operationTime!.minute}:${seallog.operationTime!.second}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ]),
                      )),
              ]),
            ),
          ],
        ));
  }

  String getSealCode() {
    if (myConfigCode.isEmpty) {
      showTipInfo(localizedStrings.reAcquireAuthCode, context);
      return "";
    } else {
      String code = myConfigCode;
      // 将处理后的字节转换16进制字符串
      String sealCode = code.length.toString();
      sealCode += code;
      if (sealCode.length < 16) {
        sealCode = sealCode.padRight(16, '0');
      }
      return sealCode.substring(0, 16);
    }
  }

  Widget showTextInfo(String text) {
    return Expanded(
        child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall!.apply(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      overflow: TextOverflow.ellipsis,
    ));
  }

  Widget showTitleInfo(String text) {
    return Expanded(
        child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall!.apply(
            color: Theme.of(context).colorScheme.onSurface,
          ),
      overflow: TextOverflow.ellipsis,
    ));
  }

  //切换的时候要修改掉秤的信息
  void changeScale(int scaleId) {
    setState(() {
      selScaleId = scaleId;
      sealLogInfoList = [];
    });
  }

  Color _getDeptColor(String dept) {
    switch (dept) {
      case 'unseal':
        return Theme.of(context).colorScheme.onTertiaryFixedVariant;
      case 'seal':
        return Theme.of(context).colorScheme.error;
      default:
        return Colors.grey;
    }
  }
}

class Employee {
  final int id;
  final String name;
  final String department;
  final String salary;
  final DateTime joinDate;
  final String performance;

  Employee({
    required this.id,
    required this.name,
    required this.department,
    required this.salary,
    required this.joinDate,
    required this.performance,
  });
}

// 定义弹框
class ShowSealTipDialog extends StatefulWidget {
  const ShowSealTipDialog(
      {super.key,
      required this.title,
      required this.msg,
      required this.iconPath,
      required this.iconColor});
  final String title;
  final String msg;
  final String iconPath;
  final Color iconColor;
  @override
  ShowSealTipDialogState createState() => ShowSealTipDialogState();
}

class ShowSealTipDialogState extends State<ShowSealTipDialog> {
  TextEditingController formulaTypeCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 550,
        height: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(context, widget.title, true, onClose: () {
              Navigator.pop(context, false);
            }),

            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                height: 200,
                width: 380,
                child: Column(children: [
                  SizedBox(height: 20),
                  getSvgIcon(widget.iconPath, 80, 80, widget.iconColor),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.msg,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      fixedSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      localizedStrings.gBtnConfirm,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onPrimary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 定义弹框
class ShowUnsealFailedDialog extends StatefulWidget {
  const ShowUnsealFailedDialog({
    super.key,
    required this.title,
    required this.msg,
    required this.iconPath,
    required this.iconColor,
  });
  final String title;
  final String msg;
  final String iconPath;
  final Color iconColor;

  @override
  ShowUnsealFailedDialogState createState() => ShowUnsealFailedDialogState();
}

class ShowUnsealFailedDialogState extends State<ShowUnsealFailedDialog> {
  TextEditingController formulaTypeCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 550,
        height: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(context, widget.title, true, onClose: () {
              Navigator.pop(context, false);
            }),

            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(26),
                height: 200,
                width: 500,
                child: Column(children: [
                  SizedBox(height: 20),
                  getSvgIcon(widget.iconPath, 80, 80, widget.iconColor),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.msg,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      fixedSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      eventBus.fire(EventShowSealOnce(''));
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      localizedStrings.removeWithCode,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onPrimary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text(
                        localizedStrings.gBtnCancel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 定义弹框
class ShowUnSealOnceDialog extends StatefulWidget {
  const ShowUnSealOnceDialog({super.key, required this.scaleId});
  final int scaleId;

  @override
  ShowUnSealOnceDialogState createState() => ShowUnSealOnceDialogState();
}

class ShowUnSealOnceDialogState extends State<ShowUnSealOnceDialog> {
  TextEditingController fileCtl = TextEditingController();
  bool isFilePickerBusy = false;

  dynamic eventBus2;

  @override
  void initState() {
    super.initState();
    eventBus2 = eventBus.on<EventRespUnsealByMasterKey>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;

        if (dataStr.contains('invalid')) {
          showTipInfo(localizedStrings.invalidData, context);
          return;
        } else if (dataStr.contains('expired')) {
          showTipInfo(localizedStrings.dataExpired, context);
          return;
        }

        if (dataStr.contains("ok")) {
          PublicFunctions.removeSoftSealOnce(widget.scaleId);

          Navigator.pop(context, true);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    eventBus2.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 550,
        height: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(context, localizedStrings.removeWithCode, true,
                onClose: () {
              Navigator.pop(context, false);
            }),

            // 中部
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                height: 200,
                width: 520,
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: showInputBox(context, fileCtl,
                            localizedStrings.removeWithCode, (value) {}, false),
                      ),
                      SizedBox(width: 10),
                      showTextButton(
                          context, btnHeight, localizedStrings.gBtnSelectFile,
                          () async {
                        // 开始选择文件时，将状态设置为忙碌
                        if (isFilePickerBusy) {
                          return;
                        }
                        isFilePickerBusy = true;

                        String filePath = '';
                        try {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['txt'],
                          );
                          if (result != null && result.files.isNotEmpty) {
                            filePath = result.files.single.path!;
                          }
                          setState(() {
                            if (filePath != '') {
                              fileCtl.text = filePath;
                            }
                          });
                        } catch (e) {
                          return;
                        } finally {
                          // 无论选择文件操作成功还是失败，都将状态设置为空闲
                          setState(() {
                            isFilePickerBusy = false;
                          });
                        }
                      },
                          Theme.of(context).colorScheme.onPrimary,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.onPrimary)
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localizedStrings.contactSupplierForRemovalCode,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      fixedSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: fileCtl.text.isNotEmpty
                        ? () async {
                            //打开文件并读取内容
                            try {
                              // 读取文件内容
                              String fileContent =
                                  await File(fileCtl.text).readAsString();

                              String codeStr = fileContent.trim();
                              codeStr = codeStr
                                  .replaceAll(" ", "")
                                  .replaceAll('\n', '')
                                  .replaceAll('\r', '');
                              PublicFunctions.unsealByMasterKey(codeStr);
                            } catch (e) {
                              return;
                            }
                          }
                        : null,
                    child: Text(
                      localizedStrings.removeWithCode,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onPrimary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text(
                        localizedStrings.gBtnCancel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReqGetSealLog {
  String model;
  String sn;
  ReqGetSealLog(this.model, this.sn);
  Map<String, dynamic> toJson() => {
        'Model': model,
        'Sn': sn,
      };
}
