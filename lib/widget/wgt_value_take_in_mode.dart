//称重共用的重量显示界面 20250521

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:t_max/data/const_var_data.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/plu_data_source.dart';
import 'package:t_max/data/received_wgt_value.dart';
import 'package:t_max/data/record_data.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/s15_tare_zero.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/settingparam_data.dart';

import 'package:t_max/data/weight_report_data.dart';
import 'package:t_max/data/weight_rpt.dart';
import 'package:t_max/data/wgt_rpt_data_source.dart';
import 'package:t_max/data/wgt_value_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/plu_select.dart';

/// 入库/进料模式核心面板视图 (Take-In Weighing View)。
/// 用于处理物料进入仓库或装调时的动态重量获取，附带轮询记录与锁定操作。
class ScaleWgtTakeInWidget extends StatefulWidget {
  final int scaleId;
  final String scaleName;
  final bool isS15;

  const ScaleWgtTakeInWidget({
    super.key,
    required this.scaleId,
    required this.scaleName,
    required this.isS15,
  });

  @override
  State<ScaleWgtTakeInWidget> createState() => _ScaleWgtTakeInWidgetState();
}

class _ScaleWgtTakeInWidgetState extends State<ScaleWgtTakeInWidget> {
  ReqWeightCountine tempWeight = ReqWeightCountine();
  ReceiveWgtInfo? weightInfo;
  Timer? startTimer;
  Timer? innerTimer;
  bool isCnting = false;
  bool isStart = false;
  bool startTakeIn = false;

  dynamic eventBus1;
  dynamic eventBus2;
  dynamic eventBus3;
  dynamic eventBus4;
  dynamic eventBus6;
  dynamic eventBus7;

  late int dateformat;
  late double zeroRange;
  List<WeightReportData> weightReportDatas = <WeightReportData>[];
  List<WeightReportData> wgtRptDataList = [];
  final DataGridController _dataGridController = DataGridController();

  PluData? selectedPluData; // 用于存储选中的PluData

  late int weightMode; // 手动保存，1 ，2，稳定保存

  final int cstManualSave = 1;
  final int cstStableSave = 2;

  int _stableSaveTime = 0;
  bool firstGetRec = true;
  late bool _isSaveBtnEnable;
  bool lastStableStatus = false;
  int maxRecId = 0;
  late Scale tempDefScaleInfo;

  final ScrollController _horizontalScrollController = ScrollController();

  GetScaleRecords currGetScaleRecords = GetScaleRecords(weightRecords: []);

  final ValueNotifier<ReceiveWgtInfo?> _wgtInfoNotifier = ValueNotifier(null);
  final ValueNotifier<double> _takeInWgtNotifier = ValueNotifier(0.0);

  bool _isCntAliveTiming = false;
  bool get isCntAliveTiming => _isCntAliveTiming;
  bool _hasPassedZero = false; // 标记是否经过 0 点

//定时发送秤还活着
  Timer? _cntAliveTimer;
  Timer? _stableTimer; // 稳定状态计时器
  int _currentStableDuration = 0; // 当前稳定状态持续时间

  double lastWgtValue = 0.000;
  double takeInWgtvalue = 0.000;

  void startCntAliveTimer(int time) {
    if (_cntAliveTimer != null) {
      _cntAliveTimer!.cancel();
    }

    _isCntAliveTiming = true;
    _cntAliveTimer = Timer(Duration(seconds: time), () {
      PublicFunctions.sendScaleAlive(widget.scaleId); //只管串口
      if (!isStart) {
        PublicFunctions.getWeight(widget.scaleId);
      }
      startCntAliveTimer(10);
    });
  }

  void stopCntAliveTimer() {
    _cntAliveTimer?.cancel();
    _isCntAliveTiming = false;
  }

  @override
  void initState() {
    super.initState();
    onStartTimer();
    startCntAliveTimer(10);
    for (int i = 0; i < myAllScalesList.length; i++) {
      if (myAllScalesList[i].scaleId == widget.scaleId) {
        tempDefScaleInfo = myAllScalesList[i];
      }
    }

    sortColumnName = 'Id';
    sortDirectValue = DataGridSortDirection.descending;

    if (mySettingParam.recMode == msgManual) {
      weightMode = cstManualSave;
      _isSaveBtnEnable = true;
    } else {
      _isSaveBtnEnable = false;
      weightMode = cstStableSave;
    }

    weightMode = (mySettingParam.recMode == msgManual)
        ? cstManualSave
        : (mySettingParam.recMode == msgAuto)
            ? cstStableSave
            : cstManualSave;
    dateformat = int.tryParse(mySettingParam.dateFormat) ?? 0;
    zeroRange = double.tryParse(mySettingParam.zeroRange) ?? 0.0;
    String timeString = (mySettingParam.stableTime == "")
        ? "0"
        : mySettingParam.stableTime.toString();
    _stableSaveTime = int.tryParse(timeString) ?? 0;
    if (weightMode == cstStableSave) {
      _isSaveBtnEnable = false;
    } else {
      _isSaveBtnEnable = true;
    }

    weightInfo = ReceiveWgtInfo(
      weightVal: '---------',
      weightUnit: '----',
      isStable: false,
      isZero: false,
      isNet: false,
    );

    eventBus1 = eventBus.on<EventReqWeightCountine>().listen((event) {
      tempWeight = event.obj;
      if (tempWeight.scaleId == widget.scaleId &&
          mounted &&
          tempWeight.msgBody != null) {
        isCnting = true;
        weightInfo = ReceiveWgtInfo(
          weightVal: tempWeight.msgBody!.weightVal,
          weightUnit: tempWeight.msgBody!.weightUnit,
          isNet: tempWeight.msgBody!.isNet,
          isStable: tempWeight.msgBody!.isStable,
          isZero: tempWeight.msgBody!.isZero,
        );
        double? nowWeightVal = double.tryParse(weightInfo!.weightVal!);
        if (nowWeightVal == null) {
          takeInWgtvalue = 0.000;
        } else {
          takeInWgtvalue = nowWeightVal - lastWgtValue;
        }

        _wgtInfoNotifier.value = weightInfo;
        _takeInWgtNotifier.value = takeInWgtvalue;

        if (!isStart) {
          setState(() {
            isStart = true;
          });
        }

        if (!startTakeIn) {
          return;
        }
        if (mySettingParam.wgtMode == 1) {
          // 记录每台秤的增量
          scaleWeightMapCommon[widget.scaleId] = WeightInfo(
              weight: takeInWgtvalue.toString(),
              unit: weightInfo!.weightUnit!,
              stable: weightInfo!.isStable!);
          return;
        }
        _checkStableStatus();
      } else {}
      if (mounted) {
        for (var scale in myAllScalesList) {
          if (scale.scaleId == tempWeight.scaleId && scale.isOnline == false) {
            setState(() {
              scale.isOnline = true;
            });
          }
        }
      }
    });
    eventBus2 = eventBus.on<EventSaveTakeInOutWgt>().listen((event) {
      if (mounted) {
        if (isStart && startTakeIn) {
          lastWgtValue = double.tryParse(weightInfo?.weightVal ?? '0') ?? 0.0;
        }
      }
    });

    eventBus3 = eventBus.on<EventSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          mySettingParam = event.obj;
          weightMode = (mySettingParam.recMode == msgManual)
              ? cstManualSave
              : (mySettingParam.recMode == msgAuto)
                  ? cstStableSave
                  : cstManualSave;
          dateformat = int.tryParse(mySettingParam.dateFormat) ?? 0;
          zeroRange = double.tryParse(mySettingParam.zeroRange) ?? 0.0;
          String timeString = (mySettingParam.stableTime == "")
              ? "0"
              : mySettingParam.stableTime.toString();
          _stableSaveTime = int.tryParse(timeString) ?? 0;
          if (weightMode == cstStableSave) {
            _isSaveBtnEnable = false;
          } else {
            _isSaveBtnEnable = true;
          }
        });
      }
    });

    eventBus4 = eventBus.on<EventGetScaleRecords>().listen((event) {
      if (mounted) {
        setState(() {
          currGetScaleRecords = event.obj;
          if (currGetScaleRecords.weightRecords!.isNotEmpty) {
            late Scale tempScale;
            for (var scale in myAllScalesList) {
              if (scale.scaleId == widget.scaleId) {
                tempScale = scale;
              }
            }

            if (currGetScaleRecords.weightRecords![0].scaleModel ==
                    tempScale.scaleModel &&
                currGetScaleRecords.weightRecords![0].scaleSn ==
                    tempScale.scaleSn) {
              wgtRptDataList.clear();
              _addDBdataToReport();
              getWeightReportData();
              if (firstGetRec) {
                int maxId =
                    int.tryParse(currGetScaleRecords.weightRecords![0].id!) ??
                        0;
                maxRecId = maxId;

                // 遍历 weightRecords 列表
                for (var record in currGetScaleRecords.weightRecords!) {
                  int currentId = int.tryParse(record.id!) ?? 0;
                  if (currentId > maxId) {
                    maxId = currentId;
                    maxRecId = maxId;
                  }
                }
              }
            }
          } else {
            // wgtRptDataList.clear();
            // updateTableData(getWeightReportData());
          }
        });
      }
    });

    eventBus6 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains(msgOk)) {
          setState(() {
            isStart = true;
          });
        } else {}
      }
    });

    eventBus7 = eventBus.on<EventRevExportRecs>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody != "") {
          if (mounted && context.mounted) {
            // showConfirmationDialog(context, myRespDataFromScale.msgBody);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    eventBus1.cancel();
    eventBus2.cancel();
    eventBus3.cancel();
    eventBus4.cancel();
    eventBus6.cancel();
    eventBus7.cancel();

    _horizontalScrollController.dispose();
    _dataGridController.dispose();

    startTimer?.cancel();
    innerTimer?.cancel();
    _stableTimer?.cancel();
    stopCntAliveTimer();
    _wgtInfoNotifier.dispose();
    _takeInWgtNotifier.dispose();
    super.dispose();
  }

  //稳定保存逻辑

  void _checkStableStatus() {
    // 检查是否经过 0 点

    // 判断是否为稳定保存模式且 _stableSaveTime 大于 0
    if (weightMode == cstStableSave && _stableSaveTime > 0) {
      // 检查是否经过 0 点 加法秤不需要过0点
      if (weightInfo!.isStable!) {
        _hasPassedZero = true;
      }
      if (weightInfo!.isStable!) {
        // 检查重量数据是否有效
        if (takeInWgtvalue > 0 && _hasPassedZero) {
          if (_stableTimer == null) {
            _currentStableDuration = 0;
            _stableTimer = Timer.periodic(Duration(seconds: 1), (timer) {
              if (!mounted) return;
              _currentStableDuration++;
              if (_currentStableDuration >= _stableSaveTime) {
                _stableTimer?.cancel();
                _stableTimer = null;
                _currentStableDuration = 0;
                _saveWeightData();
              }
            });
          }
        } else {
          _resetStableTimer();
        }
      } else {
        _resetStableTimer();
      }
    }
  }

  // 重置稳定状态计时器
  void _resetStableTimer() {
    _stableTimer?.cancel();
    _stableTimer = null;
    _currentStableDuration = 0;
  }

  // 保存重量数据
  void _saveWeightData() {
    if (_hasPassedZero && weightInfo!.isStable!) {
      if (takeInWgtvalue > 0) {
        _changeSaveButton();
        _hasPassedZero = false; // 保存后重置经过 0 点标记
      }
    }
  }

  List<WeightReportData> getWeightReportData() {
    return wgtRptDataList;
  }

  void _addDBdataToReport() {
    addDBdataToReport(wgtRptDataList, mySettingParam, dateformat);
  }

  void onStartTimer() {
    startTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      isCnting = false; // 重置计时器状态
      innerTimer = Timer(Duration(milliseconds: 2500), () {
        if (!isCnting) {
          isStart = false;
          if (mounted) {
            setState(() {
              weightInfo = ReceiveWgtInfo(
                weightVal: '---------',
                weightUnit: '----',
                isStable: false,
                isZero: false,
                isNet: false,
              );
            });
            for (var scale in myAllScalesList) {
              if (scale.scaleId == widget.scaleId && scale.isOnline == true) {
                setState(() {
                  scale.isOnline = false;
                });
                break;
              }
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: regularPadding),
        height: 215,
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Column(children: [
          Container(
            height: 200,
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.only(
                left: regularPadding, right: regularPadding),
            child: Column(
              children: [
                Container(
                    height: btnHeight,
                    color: Theme.of(context).colorScheme.surface,
                    alignment: Alignment.centerLeft,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 170,
                            child: Text(
                              widget.scaleName,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .apply(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (mySettingParam.wgtMode == 0)
                            showSelPluWidget(140, 40, (value) {
                              setState(() {
                                selectedPluData = value;
                              });
                            }),
                        ])),
                Container(
                  height: 1,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                ),
                ValueListenableBuilder<ReceiveWgtInfo?>(
                  valueListenable: _wgtInfoNotifier,
                  builder: (context, info, child) {
                    final currentInfo = info ?? weightInfo;
                    return Column(
                      children: [
                        Container(
                            height: 52,
                            color: Theme.of(context).colorScheme.surface,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 104,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildIconAndText(
                                        context,
                                        localizedStrings.iStable,
                                        currentInfo?.isStable,
                                        1,
                                      ),
                                      _buildIconAndText(
                                        context,
                                        localizedStrings.iTextNet,
                                        currentInfo?.isNet,
                                        2,
                                      ),
                                      _buildIconAndText(
                                        context,
                                        localizedStrings.iTextZero,
                                        currentInfo?.isZero,
                                        3,
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                if (widget.isS15)
                                  SizedBox(
                                    height: 40,
                                    child: IconButton(
                                        icon: Icon(
                                          Icons.cleaning_services_outlined,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        tooltip: localizedStrings.btnForceClearTare,
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return ShowNormalTipDialog(
                                                title: localizedStrings.fTipTitle,
                                                msg: localizedStrings.tipForceClearTare,
                                              );
                                            },
                                          ).then((value) {
                                            if (value == null) {
                                              return;
                                            }
                                            if (value) {
                                              PublicFunctions.forceUntare(
                                                  widget.scaleId);
                                            }
                                          });
                                        }),
                                  ),
                                showBtnWidget()
                              ],
                            )),
                        Divider(
                          height: 1,
                          color: Theme.of(context).colorScheme.surfaceContainerLow,
                        ),
                        SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                  child: Container(
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown, // 当文字溢出时缩小字体
                                  alignment: Alignment.centerRight,
                                  child: Text(currentInfo?.weightVal ?? '---------',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge!
                                          .copyWith(
                                            fontSize: 40,
                                            color: isStart
                                                ? Theme.of(context).colorScheme.primary
                                                : Theme.of(context).colorScheme.error,
                                          )),
                                ),
                              )),
                              Container(
                                width: 60,
                                height: 50,
                                alignment: Alignment.bottomLeft,
                                child: Text(currentInfo?.weightUnit ?? '----',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyLarge!.apply(
                                          color:
                                              Theme.of(context).colorScheme.onSurface,
                                        )),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                  child: Container(
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown, // 当文字溢出时缩小字体
                                  alignment: Alignment.centerRight,
                                  child: ValueListenableBuilder<double>(
                                    valueListenable: _takeInWgtNotifier,
                                    builder: (context, takeInVal, child) {
                                      return Text(
                                          !isStart
                                              ? '---------'
                                              : startTakeIn
                                                  ? takeInVal.toStringAsFixed(3)
                                                  : currentInfo?.weightVal ?? '---------',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge!
                                              .copyWith(
                                                fontSize: 28,
                                                color: isStart
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onTertiaryFixedVariant
                                                    : Theme.of(context).colorScheme.error,
                                              ));
                                    },
                                  ),
                                ),
                              )),
                              Container(
                                width: 60,
                                height: 48,
                                alignment: Alignment.bottomLeft,
                                child: Text(currentInfo?.weightUnit ?? '----',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyLarge!.apply(
                                          color:
                                              Theme.of(context).colorScheme.onSurface,
                                        )),
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ]));
  }

  Widget showBtnWidget() {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          showPerformIconBtn(
              performTareSvgIcon(),
              localizedStrings.gBtnTare,
              isStart
                  ? () {
                      tareByScaleId(widget.scaleId);
                    }
                  : null,
              Theme.of(context).colorScheme.primary),
          SizedBox(
            width: smallPadding,
          ),
          showPerformIconBtn(
              performZeroSvgIcon(),
              localizedStrings.iBtnZero,
              isStart
                  ? () {
                      zeroByScaleId(widget.scaleId);
                    }
                  : null,
              Theme.of(context).colorScheme.primary),
          SizedBox(
            width: smallPadding,
          ),
          if (!startTakeIn)
            showPerformIconBtn(
                startWgtSvgIcon(),
                localizedStrings.gBtnStart,
                isStart
                    ? () {
                        setState(() {
                          startTakeIn = true;
                          lastWgtValue = (double.tryParse(
                                  weightInfo?.weightVal ?? '0.000') ??
                              0.0);
                        });
                      }
                    : null,
                Theme.of(context).colorScheme.primary),
          if (startTakeIn)
            showPerformIconBtn(
                endWgtSvgIcon(),
                localizedStrings.gBtnEnd,
                isStart
                    ? () {
                        setState(() {
                          startTakeIn = false;
                          lastWgtValue = 0.000;
                        });
                      }
                    : null,
                Theme.of(context).colorScheme.error),
          if (mySettingParam.wgtMode == 0)
            SizedBox(
              width: smallPadding,
            ),
          if (mySettingParam.wgtMode == 0)
            Tooltip(
              message: localizedStrings.gBtnSave,
              child: IconButton(
                iconSize: 28,
                color: Theme.of(context).colorScheme.primary,
                focusColor: Theme.of(context).colorScheme.outline,
                hoverColor: Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withValues(alpha: 0.1),
                style: IconButton.styleFrom(
                  disabledBackgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerLow,
                  backgroundColor:
                      Theme.of(context).colorScheme.onTertiaryFixedVariant,
                  shape: RoundedRectangleBorder(
                    // 设置为矩形形状
                    borderRadius: BorderRadius.zero, // 没有圆角，即正方形
                  ),
                  fixedSize: const Size(28, 28), // 设置固定大小
                ),
                onPressed: isStart && _isSaveBtnEnable && weightInfo!.isStable!
                    ? () {
                        _changeSaveButton();
                      }
                    : null,
                icon: getSvgIcon(
                  saveSvgIcon(),
                  28,
                  28,
                  isStart && _isSaveBtnEnable && weightInfo!.isStable!
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
        ],
      ),
    );
  }

  final iconBtnSize = 28.0;

  Widget showPerformIconBtn(
      String iconPath, String title, VoidCallback? onPressed, Color color) {
    return Tooltip(
        message: title,
        child: IconButton(
            iconSize: iconBtnSize,
            color: color,
            focusColor: Theme.of(context).colorScheme.outline,
            hoverColor:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1),
            style: IconButton.styleFrom(
              // 当按钮不可用时，设置背景颜色为灰色
              disabledBackgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLow,
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                // 设置为矩形形状
                borderRadius: BorderRadius.zero, // 没有圆角，即正方形
              ),
              fixedSize: Size(iconBtnSize, iconBtnSize), // 设置固定大小
            ),
            onPressed: onPressed,
            icon: getSvgIcon(
                iconPath,
                iconBtnSize,
                iconBtnSize,
                isStart
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.surfaceContainerHighest)));
  }

  _changeSaveButton() {
    setState(() {
      String wgtValue = '';
      if (weightInfo!.weightVal!.contains('-')) {
        showTipInfo(localizedStrings.gTipInvalidWeightData, context);
        return;
      }
      if (startTakeIn && takeInWgtvalue <= 0) {
        showTipInfo(localizedStrings.gTipInvalidWeightData, context);
        return;
      }
      if (!startTakeIn) {
        wgtValue = weightInfo!.weightVal!;
        double temp = double.tryParse(wgtValue) ?? 0.0;
        if (temp <= 0) {
          showTipInfo(localizedStrings.gTipInvalidWeightData, context);
          return;
        }
      } else {
        wgtValue = weightInfo!.weightUnit == 'g'
            ? (takeInWgtvalue).toStringAsFixed(0)
            : (takeInWgtvalue).toStringAsFixed(3);
        lastWgtValue = double.tryParse(weightInfo?.weightVal ?? '0') ?? 0.0;
      }

      _addWeightToReport(wgtValue);
      sendReportDataToDB();
    });
  }

  void sendReportDataToDB() {
    sendRptDataToDB(
        wgtRptDataList, mySettingParam.scaleMode.toString(), widget.scaleId);
  }

  void _addWeightToReport(String wgtValue) {
    PluData? tempPlu = PluData(null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, '', '');
    if (selectedPluData != null) {
      tempPlu = selectedPluData;
    }

    maxRecId++;

    WeightReportData addData = WeightReportData(
      (maxRecId).toString(),
      tempDefScaleInfo.scaleModel,
      tempDefScaleInfo.scaleSn,
      (tempPlu!.plu == null) ? "" : tempPlu.plu.toString(),
      (tempPlu.productCode == null) ? "" : tempPlu.productCode.toString(),

      (tempPlu.itemCode == null) ? "" : tempPlu.itemCode.toString(),

      (tempPlu.category == null) ? "" : tempPlu.category.toString(),

      (tempPlu.productName == null) ? "" : tempPlu.productName.toString(),

      (tempPlu.generalUnit == null) ? "" : tempPlu.generalUnit.toString(),

      (tempPlu.taxType == null) ? "" : tempPlu.taxType.toString(),

      (tempPlu.price == null) ? "" : tempPlu.price.toString(),

      (tempPlu.unitWeight == null) ? "" : tempPlu.unitWeight.toString(),

      (tempPlu.pretare == null) ? "" : tempPlu.pretare.toString(),

      (tempPlu.limitHigh == null) ? "" : tempPlu.limitHigh.toString(),

      (tempPlu.limitLow == null) ? "" : tempPlu.limitLow.toString(),

      wgtValue,
      (weightInfo?.weightUnit == '----') ? (" ") : (weightInfo!.weightUnit!),
      mySysUser.userName ?? "",
      mySysUser.nickName ?? "",

      tempDefScaleInfo.scaleName, //此处应该是秤机种名
      getDateTime(mySettingParam.dateSeparator, dateformat),
    );
    wgtRptDataList.add(addData);
  }

  Widget showIconBtn(
      String message, Function()? onPressed, Color bkColor, Widget icon) {
    return Tooltip(
        message: message,
        child: IconButton(
          iconSize: 24,
          hoverColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          style: IconButton.styleFrom(
            backgroundColor: bkColor,
            shape: RoundedRectangleBorder(
              // 设置为矩形形状
              borderRadius: BorderRadius.zero, // 没有圆角，即正方形
            ),
            fixedSize: const Size(40, 40), // 设置固定大小
          ),
          onPressed: onPressed,
          icon: icon,
        ));
  }

  Widget _buildIconAndText(
      BuildContext context, String text, bool? isConditionMet, int type) {
    return Align(
        child: Container(
      padding: const EdgeInsets.only(left: 4, right: 4),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isConditionMet == null
              ? Theme.of(context).colorScheme.outlineVariant
              : isConditionMet
                  ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                  : Theme.of(context).colorScheme.outlineVariant),
      child: getSvgIcon(
          type == 1
              ? stableSvgIcon()
              : type == 2
                  ? netSvgIcon()
                  : zeroSvgIcon(),
          24,
          20,
          isConditionMet == null
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : isConditionMet
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.surfaceContainerHighest),
    ));
  }
}
