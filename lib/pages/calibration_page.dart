import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/downloadresponse.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/log_data.dart';
import 'package:t_max/data/received_wgt_value.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/scale_list.dart';
import '../../functions/methods.dart';
import '../data/language.dart';

const int step1 = 1; //步骤1
const int step2 = 2; //步骤2
const int step3 = 3; //步骤2
const int step4 = 4; //步骤3
const int step5 = 5; //步骤4

const double thisScaleListWidth = 251;

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({super.key});
  @override
  State<CalibrationPage> createState() => CalibrationPageState();
}

class CalibrationPageState extends State<CalibrationPage> {
  ReqWeightCountine tempWeight = ReqWeightCountine();
  TextEditingController scaleRangeCtl = TextEditingController(text: "");
  TextEditingController scaleUnitCtl = TextEditingController(text: "kg");
  TextEditingController scaleCap1Ctl = TextEditingController(text: "10");
  TextEditingController decimalCtl = TextEditingController(text: "0");
  TextEditingController gaduation1Ctl = TextEditingController(text: "1");
  TextEditingController initialZeroCtl = TextEditingController(text: "0");
  TextEditingController zeroTrackingCtl = TextEditingController(text: "0.5d");
  TextEditingController manualZeroCtl = TextEditingController(text: "0");
  TextEditingController unitCtl = TextEditingController(text: "kg");
  TextEditingController gravAccCtl = TextEditingController(text: "9.8"); //重力加速度

  TextEditingController unstableZeroTareCtl =
      TextEditingController(text: unstableZeroTare ? "True" : "False");

  int selScaleId = -1; //选择的秤ID

  DateTime customDate = DateTime.now();
  DateTime customTime = DateTime.now();
  DateTime deviceTime = DateTime.now();

  bool isCalSuccess = false;

  ReceiveWgtInfo? weightInfo;

  int curStep = 1; //当前步骤
  bool isManaul = false;
  bool isFinish = false; //是否完成校准
  bool isCnting = false; //是否正在计数
  bool isStart = false; //是否开始
  bool isCalibration = false; //是否校准

// 存储初始值
  String initialMaxRange1 = '';
  String initialWgtUnit = '';
  String initialInitZero = '';
  String initialManualZero = '';
  String initialZeroTracking = '';
  String initialGravAcc = '';
  String initialDecimal = '';
  String initialGaduation1 = '';
  String currentWgtUnit = '';

  dynamic eventBus1; //接收秤数据
  dynamic eventBus2; //接收秤数据
  dynamic eventBus3; //接收秤数据
  dynamic eventBus4; //接收秤数据
  dynamic eventBus5; //接收秤数据
  dynamic eventBus6; //接收秤数据
  dynamic eventBus7; //接收秤数据
  dynamic eventBus8; //接收秤数据
  dynamic eventBus9; //接收秤数据
  dynamic eventBus10; //接收秤数据
  dynamic eventBus11; //接收秤数据
  dynamic eventBus12; //接收秤数据
  dynamic eventBus13; //接收秤数据
  dynamic eventBus14; //接收秤数据

  //定时发送秤还活着
  Timer? _cntAliveTimer;
  bool _isCntAliveTiming = false;
  bool get isCntAliveTiming => _isCntAliveTiming;
  Timer? startTimer;
  Timer? innerTimer;
  Timer? calHeartBeatTimer;

  double oldWeight = 0;
  double newWeight = 0;

  void startCntAliveTimer(int time) {
    if (_cntAliveTimer != null) {
      _cntAliveTimer!.cancel();
    }

    _isCntAliveTiming = true;
    _cntAliveTimer = Timer(Duration(seconds: time), () {
      PublicFunctions.sendScaleAlive(selScaleId);
      if (!isStart) {
        PublicFunctions.getWeight(selScaleId);
      }
      startCntAliveTimer(10);
    });
  }

  void stopCntAliveTimer() {
    _cntAliveTimer?.cancel();
    _isCntAliveTiming = false;
  }

  void startCalHeartBeatTimer() {
    if (calHeartBeatTimer != null) {
      calHeartBeatTimer!.cancel();
    }

    calHeartBeatTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      PublicFunctions.sendCalHeartBeat(selScaleId);
    });
  }

  void onStartTimer() {
    startTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      isCnting = false; // 重置计时器状态
      innerTimer = Timer(Duration(milliseconds: 1000), () {
        if (!isCnting) {
          isStart = false;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();

    startCntAliveTimer(10);
    onStartTimer();

    startCalHeartBeatTimer();
    weightInfo = ReceiveWgtInfo(
      weightVal: '---------',
      weightUnit: '----',
      isStable: false,
      isZero: false,
      isNet: false,
    );
    eventBus1 = eventBus.on<EventReqWeightCountine>().listen((event) {
      tempWeight = event.obj;

      if (tempWeight.scaleId == selScaleId &&
          mounted &&
          tempWeight.msgBody != null) {
        setState(() {
          isCnting = true;
          isStart = true;
          weightInfo = ReceiveWgtInfo(
            weightVal: tempWeight.msgBody!.weightVal,
            weightUnit: tempWeight.msgBody!.weightUnit,
            isNet: tempWeight.msgBody!.isNet,
            isStable: tempWeight.msgBody!.isStable,
            isZero: tempWeight.msgBody!.isZero,
          );
        });
      }
      if (mounted) {
        for (var item in myAllScalesList) {
          if (item.scaleId == tempWeight.scaleId && !item.isOnline) {
            setState(() {
              item.isOnline = true;
              return;
            });
          }
        }
      }
    });

    eventBus2 = eventBus.on<EventRevCalValue>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (!tempRespData.msgBody.contains('ok') && curStep == step5) {
            setState(() {
              isFinish = true;
              isCalSuccess = false;
            });
          } else if (!tempRespData.msgBody.contains('ok')) {
            showTipInfo(localizedStrings.gTipRedoLastStep, context);
            setState(() {
              curStep = curStep - 1;
              if (curStep < 1) {
                curStep = 1;
              }
            });
          } else if (tempRespData.msgBody.contains('ok') && curStep == step5) {
            setState(() {
              isFinish = true;
              isCalSuccess = true;
            });
          }
        }
      }
    });

    eventBus3 = eventBus.on<EventRevCalWeight>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (!tempRespData.msgBody.contains('ok')) {
            showTipInfo(localizedStrings.gTipRedoLastStep, context);
            setState(() {
              curStep = curStep - 1;
              if (curStep < 1) {
                curStep = 1;
              }
            });
          } else {
            if (curStep == step5) {
              setState(() {
                // 获取校准后的重量间隔200ms
                Future.delayed(Duration(milliseconds: 200), () {
                  setState(() {
                    isFinish = true;
                    isCalSuccess = true;
                    newWeight = double.parse(weightInfo!.weightVal.toString());
                    currentWgtUnit = weightInfo!.weightUnit.toString();

                    CalLog calLog = CalLog(
                        scaleId: selScaleId,
                        type: "single",
                        mode: "1", //标定点数量
                        unit: currentWgtUnit,
                        calValue: scaleRangeCtl.text,
                        before: oldWeight.toString(),
                        after: newWeight.toString(),
                        calError: (newWeight - oldWeight).toStringAsFixed(3),
                        calResult: 'ok');
                    String jsonStr = json.encode(calLog);

                    PublicFunctions.addCalLog(jsonStr);
                  });
                });
              });
            }
          }
        }
      }
    });

    eventBus4 = eventBus.on<EventRevSetDecimalValue>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (!tempRespData.msgBody.contains('ok')) {
            showTipInfo(localizedStrings.gTipSetParameterFail, context);
          } else {
            showTipInfo(localizedStrings.fSuccessMsg, context);
          }
        }
      }
    });

    eventBus5 = eventBus.on<EventRevSetGaduationValue>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (!tempRespData.msgBody.contains('ok')) {
          } else {}
        }
      }
    });

    eventBus6 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
        } else {
          for (var item in myAllScalesList) {
            if (item.scaleId == myRespDataFromScale.scaleId &&
                item.isOnline &&
                myRespDataFromScale.scaleId == selScaleId) {
              setState(() {
                item.isOnline = false;
              });
            }
          }
        }
      }
    });

    eventBus7 = eventBus.on<EventRevGetDecimalValue>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 1 ||
              tempRespData.msgBody.contains('fail')) {
            // showTipInfo('fail,get parameter fail!', context);
            return;
          }

          initialDecimal = tempRespData.msgBody;

          setState(() {
            decimalCtl.text = initialDecimal;
          });
        }
      }
    });
    eventBus8 = eventBus.on<EventRevGetGaduation1Value>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 1 ||
              tempRespData.msgBody.contains('fail')) {
            // showTipInfo('fail,get parameter fail!', context);
            return;
          }
          initialGaduation1 = tempRespData.msgBody;

          setState(() {
            gaduation1Ctl.text = initialGaduation1;
          });
        }
      }
    });

    eventBus9 = eventBus.on<EventRevGetGravAcc>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 7 ||
              tempRespData.msgBody.contains('fail')) {
            showTipInfo(localizedStrings.gTipGetParameterFail, context);
            return;
          }
          initialGravAcc = (tempRespData.msgBody);

          setState(() {
            gravAccCtl.text = initialGravAcc;
          });
          showTipInfo(localizedStrings.fSuccessMsg, context);
        }
      }
    });

    eventBus10 = eventBus.on<EventRevGetInitialZero>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 7 ||
              tempRespData.msgBody.contains('fail')) {
            // showTipInfo('fail,get parameter fail!', context);
            return;
          }
          initialInitZero = (tempRespData.msgBody);
          setState(() {
            initialZeroCtl.text = initialInitZero;
          });
        }
      }
    });

    eventBus11 = eventBus.on<EventRevGetZeroTracking>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 7 ||
              tempRespData.msgBody.contains('fail')) {
            // showTipInfo('fail,get parameter fail!', context);
            return;
          }
          String revStr = tempRespData.msgBody;
          switch (revStr) {
            case '0':
              initialZeroTracking = 'off';
              break;
            case '1':
              initialZeroTracking = '0.5d';
              break;
            case '2':
              initialZeroTracking = '1d';
              break;
            case '3':
              initialZeroTracking = '2d';
              break;
            case '4':
              initialZeroTracking = '3d';
              break;
            case '5':
              initialZeroTracking = '4d';
              break;
            default:
              initialZeroTracking = '';
          }

          setState(() {
            zeroTrackingCtl.text = initialZeroTracking;
          });
        }
      }
    });

    eventBus12 = eventBus.on<EventRevGetManualZero>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 7 ||
              tempRespData.msgBody.contains('fail')) {
            // showTipInfo('fail,get parameter fail!', context);
            return;
          }
          initialManualZero = (tempRespData.msgBody);

          setState(() {
            manualZeroCtl.text = initialManualZero;
          });
        }
      }
    });
    //获取重量单位
    eventBus13 = eventBus.on<EventRevGetWeightUnit>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 1 ||
              tempRespData.msgBody.contains('fail')) {
            // showTipInfo('fail,get parameter fail!', context);

            return;
          }
          initialWgtUnit = tempRespData.msgBody;
          switch (initialWgtUnit) {
            case '0':
              initialWgtUnit = 'kg';
              break;
            case '1':
              initialWgtUnit = 'g';
              break;
            case '2':
              initialWgtUnit = 'lb';
              break;
            default:
              initialWgtUnit = '';
          }
          setState(() {
            unitCtl.text = initialWgtUnit;
          });
        }
      }
    });

    //获取秤的最大量程1
    eventBus14 = eventBus.on<EventRevGetMaxRange1>().listen((event) {
      if (mounted) {
        ChannelResponse tempRespData = ChannelResponse('', '', 0);
        tempRespData = event.obj;
        if (mounted) {
          if (tempRespData.msgBody.length > 7 ||
              tempRespData.msgBody.contains('fail')) {
            // showTipInfo('fail,get parameter fail!', context);
            return;
          }
          initialMaxRange1 = tempRespData.msgBody;

          setState(() {
            scaleCap1Ctl.text = initialMaxRange1;
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
    eventBus2.cancel();
    eventBus3.cancel();
    eventBus4.cancel();
    eventBus5.cancel();
    eventBus6.cancel();
    eventBus7.cancel();
    eventBus8.cancel();
    eventBus9.cancel();
    eventBus10.cancel();
    eventBus11.cancel();
    eventBus12.cancel();
    eventBus13.cancel();
    eventBus14.cancel();

    stopCntAliveTimer();
    startTimer?.cancel();
    calHeartBeatTimer?.cancel();
    if (innerTimer != null) {
      innerTimer!.cancel();
    }

    scaleRangeCtl.dispose();
    scaleUnitCtl.dispose();
    PublicFunctions.stopWeight(selScaleId);

    scaleCap1Ctl.dispose();
    decimalCtl.dispose();
    gaduation1Ctl.dispose();
    initialZeroCtl.dispose();
    zeroTrackingCtl.dispose();
    manualZeroCtl.dispose();
    unitCtl.dispose();
    gravAccCtl.dispose();
    _cntAliveTimer?.cancel();
    innerTimer?.cancel();
    super.dispose();
  }

  void performChangeScale(int scaleId) {
    PublicFunctions.stopWeight(selScaleId);
    setState(() {
      curStep = step1;
      isFinish = false;
      isCalSuccess = false;
      selScaleId = scaleId;
      isStart = false;
      weightInfo = ReceiveWgtInfo(
        weightVal: '---------',
        weightUnit: '----',
        isStable: false,
        isZero: false,
        isNet: false,
      );
      initialMaxRange1 = '';
      initialWgtUnit = '';
      initialInitZero = '';
      initialManualZero = '';
      initialZeroTracking = '';
      initialGravAcc = '';
      initialDecimal = '';
      initialGaduation1 = '';
    });
    getAllParameter();
  }

  void getAllParameter() {
    showTipInfo(localizedStrings.gTipGettingParameter, context);
    PublicFunctions.getMaxRange1(selScaleId);
    PublicFunctions.getWeightUnit(selScaleId);
    PublicFunctions.getInitialZero(selScaleId);
    PublicFunctions.getManualZero(selScaleId);
    PublicFunctions.getZeroTracking(selScaleId);
    PublicFunctions.getGravityAcceleration(selScaleId);
    PublicFunctions.getDecimalValue(selScaleId);
    PublicFunctions.getGaduation1Value(selScaleId);
  }

  showCalibrationWarning() {
    showTipInfo(localizedStrings.gTipCalibrating, context);
  }

  void changeScale(int scaleId) {
    if (curStep != step1 && curStep != step5) {
      showDialog(
        context: context,
        barrierDismissible: false, // 点击对话框外部不关闭对话框
        builder: (BuildContext ctx) {
          return ShowNormalTipDialog(
            title: localizedStrings.fTipTitle,
            msg: localizedStrings.gTipCalibrationWarning,
          );
        },
      ).then((value) {
        if (value == null) {
          return;
        }
        if (value) {
          performChangeScale(scaleId);
        } else {
          return;
        }
      });
    } else {
      performChangeScale(scaleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(body: firstLayout(context, width));
  }

  Widget firstLayout(context, width) {
    return Container(
        width: width,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // pageHeadInfo(context, width - headWidthPadding,
            //     localizedStrings.menuCalibration, ''),
            Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                    width: thisScaleListWidth,
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
                              listWidth: thisScaleListWidth, // 列表宽度
                              selScaleId: selScaleId,
                              clickScale: (scale) {
                                setState(() {
                                  bool isS15 = false;
                                  for (var item in myAllScalesList) {
                                    if (item.scaleId == scale.scaleId) {
                                      if (item.scaleModel != "S15") {
                                        showTipInfo(
                                            "Please select S15 scale", context);
                                      } else {
                                        isS15 = true;
                                      }
                                    }
                                  }
                                  if (isS15) {
                                    changeScale(scale.scaleId);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 1,
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant, //  分隔条颜色
                        ),
                        myAllScalesList.isEmpty
                            ? SizedBox()
                            : Expanded(
                                child: Container(
                                    padding:
                                        const EdgeInsets.all(regularPadding),
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    child: Column(
                                      children: [
                                        showSetParameterBtn(),
                                        if (isCalibration && selScaleId != -1)
                                          ...showCalibrationPart(),
                                        if (!isCalibration && selScaleId != -1)
                                          ...showParameterSettingPart()
                                      ],
                                    )))
                      ],
                    ),
                  ),
                ])),
          ],
        ));
  }

  Widget showTitle(String title) {
    return SizedBox(
      height: 42,
      width: 300,
      child: Row(children: [
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ]),
    );
  }

  List<Widget> showParameterSettingPart() {
    return [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings.gTipMaxRange),
            showCapInputBox(scaleCap1Ctl),
          ]),
        ),
        SizedBox(
          width: largePadding * 2,
        ),
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings.gTipGaduation),
            showDropDownButton(context, '', gaduation1Ctl, [
              '1',
              '2',
              '5',
              '10',
              '20',
              '50',
              '100',
            ], (onValue) {
              setState(() {
                gaduation1Ctl.text = onValue!;
              });
            }),
          ]),
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings.gTipWeightUnit),
            SizedBox(
                child: showDropDownButton(context, '', unitCtl, [
              'kg',
              'g',
              'lb',
            ], (onValue) {
              showDialog(
                context: context,
                barrierDismissible: false, // 点击对话框外部不关闭对话框
                builder: (BuildContext ctx) {
                  return ShowNormalTipDialog(
                    title: localizedStrings.fTipTitle,
                    msg: localizedStrings.gTipSwitchUnit,
                  );
                },
              );
              setState(() {
                unitCtl.text = onValue!;
              });
            })),
          ]),
        ),
        SizedBox(
          width: largePadding * 2,
        ),
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings.gTipDecimal),
            SizedBox(
                child: showDropDownButton(context, '', decimalCtl, [
              '0',
              '1',
              '2',
              '3',
            ], (onValue) {
              setState(() {
                decimalCtl.text = onValue!;
              });
            })),
          ]),
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings.gTipInitialZero),
            SizedBox(
                child: showDropDownButton(context, '', initialZeroCtl,
                    ['0', '2', '3', '4', '10', '20', '50', '100'], (onValue) {
              setState(() {
                initialZeroCtl.text = onValue!;
              });
            })),
          ]),
        ),
        SizedBox(
          width: largePadding * 2,
        ),
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings.gTipManualZero),
            SizedBox(
                child: showDropDownButton(context, '', manualZeroCtl,
                    ['0', '2', '3', '4', '10', '20', '50', '100'], (onValue) {
              setState(() {
                manualZeroCtl.text = onValue!;
              });
            })),
          ]),
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings.gTipZeroTracking),
            //   0:off 1:0.5 2:1 3:2 4:3 5:4
            SizedBox(
                child: showDropDownButton(context, '', zeroTrackingCtl,
                    ['off', '0.5d', '1d', '2d', '3d', '4d'], (onValue) {
              setState(() {
                zeroTrackingCtl.text = onValue!;
              });
            })),
          ]),
        ),
        SizedBox(
          width: largePadding * 2,
        ),
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings.gTipGravityAcceleration),
            showGravAccInputBox(),
          ]),
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 300,
          child: Column(children: [
            showTitle(localizedStrings.gUnstableZeroTare),
            //   0:off 1:0.5 2:1 3:2 4:3 5:4
            SizedBox(
                child: showDropDownButton(
                    context, '', unstableZeroTareCtl, ['True', 'False'],
                    (onValue) {
              setState(() {
                unstableZeroTareCtl.text = onValue!;
                unstableZeroTare = (onValue == "True");
                PublicFunctions.updateUnstableZeroTare(unstableZeroTare);
              });
            })),
          ]),
        ),
        SizedBox(
          width: largePadding * 2,
        ),
        SizedBox(
          width: 300,
        ),
      ]),
      SizedBox(
        height: largePadding,
      ),
      Container(
        height: 60,
        width: 400,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  fixedSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: scaleCap1Ctl.text.isEmpty
                    ? null
                    : () {
                        if (!chackGravAcc()) {
                          showTipInfo(
                              localizedStrings
                                  .gTipGravityAccelerationInputError,
                              context);
                          return;
                        }
                        performModifyParameter();
                      },
                child: Text(
                  localizedStrings.gBtnConfirm,
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  fixedSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () {
                  //取消的话重新获取下参数

                  showTipInfo(localizedStrings.gTipGettingParameter, context);

                  Future.delayed(const Duration(seconds: 2), () {
                    getAllParameter();
                  });
                },
                child: Text(
                  localizedStrings.gBtnCancel,
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ),
    ];
  }

  void performModifyParameter() {
    // 比较并发送修改协议
    if (scaleCap1Ctl.text != initialMaxRange1) {
      PublicFunctions.setMaxRange1(selScaleId, scaleCap1Ctl.text);
    }

    if (unitCtl.text != initialWgtUnit) {
      int unitIndex = 0;
      switch (unitCtl.text) {
        case 'kg':
          unitIndex = 0;
          break;
        case 'g':
          unitIndex = 1;
          break;
        case 'lb':
          unitIndex = 2;
          break;
      }

      PublicFunctions.setWeightUnit(selScaleId, unitIndex.toString());
    }

    if (initialZeroCtl.text != initialInitZero) {
      PublicFunctions.setInitialZero(
          selScaleId, initialZeroCtl.text); // 假设存在此方法
    }

    if (manualZeroCtl.text != initialManualZero) {
      PublicFunctions.setManualZero(selScaleId, manualZeroCtl.text); // 假设存在此方法
    }

    if (zeroTrackingCtl.text != initialZeroTracking) {
      // 0:off 1:0.5 2:1 3:2 4:3 5:4
      int zeroTrackingIndex = 0;
      switch (zeroTrackingCtl.text) {
        case 'off':
          zeroTrackingIndex = 0;
          break;
        case '0.5d':
          zeroTrackingIndex = 1;
          break;
        case '1d':
          zeroTrackingIndex = 2;
          break;
        case '2d':
          zeroTrackingIndex = 3;
          break;
        case '3d':
          zeroTrackingIndex = 4;
          break;
        case '4d':
          zeroTrackingIndex = 5;
          break;
      }
      PublicFunctions.setZeroTracking(selScaleId, zeroTrackingIndex.toString());
    }

    if (gravAccCtl.text != initialGravAcc) {
      String gravAccValue =
          (double.tryParse(gravAccCtl.text)! * 100000).toStringAsFixed(0);
      PublicFunctions.setGravityAcceleration(selScaleId, gravAccValue);
    }

    if (decimalCtl.text != initialDecimal) {
      PublicFunctions.setDecimalValue(selScaleId, decimalCtl.text);
    }

    if (gaduation1Ctl.text != initialGaduation1) {
      PublicFunctions.setGaduation1Value(selScaleId, gaduation1Ctl.text);
    }
    Future.delayed(const Duration(seconds: 2), () {
      getAllParameter();
    });
  }

  bool chackGravAcc() {
    if (gravAccCtl.text == "") {
      return false;
    }
    if (double.parse(gravAccCtl.text) < 9.7 ||
        double.parse(gravAccCtl.text) > 9.9) {
      return false;
    }
    return true;
  }

  Widget showCapInputBox(TextEditingController capCtl) {
    return SizedBox(
      height: inputHeight,
      child: TextField(
        enabled: true,
        controller: capCtl,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          TextInputFormatter.withFunction((oldValue, newValue) {
            if (newValue.text.isEmpty) return newValue; // 允许清空输入
            if (newValue.text.startsWith('0') && newValue.text.length > 1) {
              return oldValue; // 不允许以 0 开头且长度大于 1 的输入
            }
            final intValue = int.tryParse(newValue.text);
            if (intValue != null && intValue > 0) {
              return newValue; // 只允许正整数
            }
            return oldValue;
          }),
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
          hintText: '',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          counterText: '',
        ),
        maxLength: 9,
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .apply(color: Theme.of(context).colorScheme.onSurface),
        onChanged: (onValue) {},
      ),
    );
  }

  Widget showGravAccInputBox() {
    return SizedBox(
      height: inputHeight,
      child: TextField(
        enabled: true,
        controller: gravAccCtl,
        // 允许输入数字和小数点
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          // 修正后的正则表达式，允许9之后直接输入小数点
          FilteringTextInputFormatter.allow(
              RegExp(r'^9(\.?|(\.(7|8)\d{0,4})?)$')),
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
          hintText: '',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .apply(color: Theme.of(context).colorScheme.onSurface),
        onChanged: (onValue) {},
      ),
    );
  }

  List<Widget> showCalibrationPart() {
    return [
      showStepPart(),
      showStepTip(),
      Expanded(
        child: curStep == step1
            ? showStep1()
            : curStep == step2
                ? showStep2()
                : curStep == step3
                    ? showStep3()
                    : curStep == step4
                        ? showStep4()
                        : showStep5(),
      ),
      showBtnRow()
    ];
  }

  Widget showStep2() {
    return Container(
      height: leftBarIconHeight,
      alignment: Alignment.center,
      child: Column(
        children: [
          Expanded(child: SizedBox()),
          SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(flex: 2, child: SizedBox()),
                // 使用 Expanded 让输入框宽度随页面变化
                Expanded(
                    flex: 5, // 分配比例
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(localizedStrings.gTipCalibrationWeight),
                        ),
                        SizedBox(
                          height: inputHeight,
                          child: TextField(
                            controller: scaleRangeCtl,
                            // 只允许输入数字
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly, // 只允许输入数字
                              TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                if (newValue.text.isEmpty) return newValue;
                                final intValue = int.tryParse(newValue.text);
                                if (intValue != null &&
                                    intValue >= 1 &&
                                    intValue <= 999999) {
                                  return newValue;
                                }
                                return oldValue;
                              }),
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0.0))),
                              hintText: localizedStrings.gTipCalibrationWeight,
                              hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface, // 设置提示文本颜色
                              ),
                            ),
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface, // 设置输入文本颜色
                                ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    )),
                SizedBox(
                  width: largePadding,
                ),
                // 使用 Expanded 让下拉按钮宽度随页面变化
                Expanded(
                    flex: 2, // 分配比例
                    child: Column(
                      children: [
                        SizedBox(
                          height: 23,
                        ),
                        showDropDownButton(context, '', scaleUnitCtl, ['kg'],
                            (value) {
                          setState(() {});
                        }),
                      ],
                    )),
                Expanded(flex: 2, child: SizedBox()),
              ],
            ),
          ),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget showStep3() {
    return Container(
      height: leftBarIconHeight,
      alignment: Alignment.center,
      child: Column(
        children: [
          Expanded(child: SizedBox()),
          Container(
            padding: EdgeInsets.all(largePadding),
            child: getSvgIcon(
                stableLightSvgIcon(),
                60,
                60,
                weightInfo!.isStable!
                    ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                    : Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(
                    flex: 5, // 分配比例
                    child: Column(
                      children: [
                        SizedBox(
                          width: 230,
                          child: Text(
                            localizedStrings.gTipBeforeCalibration + ":  ",
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          height: regularPadding,
                        ),
                        Container(
                            width: 230,
                            height: 40,
                            alignment: Alignment.center,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 180,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLowest,
                                    alignment: Alignment.center,
                                    child: Text(
                                      weightInfo!.weightVal.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    height: 40,
                                    alignment: Alignment.center,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLowest,
                                    child: Text(
                                      weightInfo!.weightUnit.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ])),
                      ],
                    )),
              ],
            ),
          ),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget showStep4() {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Container(
        padding: EdgeInsets.all(largePadding),
        child: getSvgIcon(
            stableLightSvgIcon(),
            60,
            60,
            weightInfo!.isStable!
                ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                : Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      Column(children: [
        Container(
          height: 48,
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: localizedStrings.gTipPleaseLoadWeight,
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: Theme.of(context).colorScheme.onSurface,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
                TextSpan(
                  text: '  ${scaleRangeCtl.text} ${scaleUnitCtl.text}',
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: Theme.of(context)
                            .colorScheme
                            .onTertiaryFixedVariant,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
              ],
            ),
          ),
        ),
        Image.asset(
          'assets/images/calibration2.png',
          width: 600,
          height: 70,
          fit: BoxFit.scaleDown,
        ),
      ])
    ]);
  }

  Widget showStep5() {
    return !isFinish
        ? SizedBox()
        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: EdgeInsets.all(largePadding),
              child: getSvgIcon(
                  isCalSuccess ? calSuccessSvgIcon() : calFailSvgIcon(),
                  48,
                  50,
                  isCalSuccess
                      ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                      : Theme.of(context).colorScheme.error),
            ),
            Column(children: [
              Container(
                height: 48,
                alignment: Alignment.center,
                child: Text(
                  isCalSuccess
                      ? localizedStrings.gTipCalibrationSuccess
                      : localizedStrings.gTipCalibrationFailed,
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: isCalSuccess
                            ? Theme.of(context)
                                .colorScheme
                                .onTertiaryFixedVariant
                            : Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
              if (isCalSuccess)
                Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localizedStrings.gTipBeforeCalibration +
                            ":  ${oldWeight.toString()} $currentWgtUnit",
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        localizedStrings.gTipAfterCalibration +
                            ":  ${newWeight.toString()} $currentWgtUnit",
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        localizedStrings.gTipErrorValue +
                            ":  ${(newWeight - oldWeight).toStringAsFixed(3)} $currentWgtUnit",
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
            ])
          ]);
  }

  Widget showStep1() {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Container(
        padding: EdgeInsets.all(largePadding),
        child: getSvgIcon(
            stableLightSvgIcon(),
            60,
            60,
            weightInfo!.isStable!
                ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                : Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      Column(children: [
        // Container(
        //   height: 48,
        //   alignment: Alignment.center,
        //   child: Text(
        //     localizedStrings.gTipPleaseEmptyScalePan,
        //     style: Theme.of(context).textTheme.bodySmall!.apply(
        //           color: Theme.of(context).colorScheme.onSurface,
        //         ),
        //   ),
        // ),
        Image.asset(
          'assets/images/calibration1.png',
          width: 600,
          height: 70,
          fit: BoxFit.scaleDown,
        ),
      ])
    ]);
  }

  Widget showBtnRow() {
    return SizedBox(
        height: 100,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          curStep == step5 || curStep == step1
              ? SizedBox()
              : showTextButton(
                  context, btnHeight, localizedStrings.gBtnPrevious, () {
                  setState(() {
                    curStep = curStep - 1;
                  });
                },
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  Theme.of(context).colorScheme.onSurfaceVariant),
          curStep == step5
              ? SizedBox()
              : SizedBox(
                  width: largePadding,
                ),
          showTextButton(
              context,
              btnHeight,
              curStep == step5 && !isCalSuccess
                  ? localizedStrings.gTipCalibrationAgain
                  : curStep == step5 && isCalSuccess
                      ? localizedStrings.finishBtn
                      : localizedStrings.fNextStepBtn,
              curStep == step4 && scaleRangeCtl.text == ''
                  ? null
                  : isStart && weightInfo!.isStable!
                      ? () {
                          setState(() {
                            if (curStep == step1) {
                              curStep = step2;
                              PublicFunctions.calibrationWeight(
                                  selScaleId, '0');
                            } else if (curStep == step2) {
                              curStep = step3;
                            } else if (curStep == step3) {
                              oldWeight = double.parse(
                                  weightInfo!.weightVal.toString());
                              oldWeight <= 0 ? oldWeight = 0 : oldWeight;
                              curStep = step4;
                            } else if (curStep == step4) {
                              curStep = step5;
                              PublicFunctions.calibrationWeight(
                                  selScaleId, scaleRangeCtl.text);
                            } else if (curStep == step5) {
                              curStep = step1;
                              // isFinish = true?
                            }
                          });
                        }
                      : null,
              Theme.of(context).colorScheme.onPrimary,
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.onPrimary)
        ]));
  }

  Widget showStepTip() {
    String stepTip = getStepTip(curStep);
    return SizedBox(
      height: leftBarIconHeight,
      child: Row(children: [
        Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        Expanded(
          flex: 7,
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              '$curStep. $stepTip ',
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        )
      ]),
    );
  }

  String getStepTip(int stepIndex) {
    switch (stepIndex) {
      case step1:
        return localizedStrings.gTipEmptyScalePanThenNext;
      case step3:
        return localizedStrings.gTipPlaceCalibrationWeight +
            " ${scaleRangeCtl.text} kg";
      case step2:
        return localizedStrings.gTipSetCalibrationWeightThenNext;
      case step4:
        return localizedStrings.gTipLoadWeightThenNext;
      case step5:
        return localizedStrings.gTipCalResult;
      default:
        return "";
    }
  }

  String getStepTitle(int stepIndex) {
    switch (stepIndex) {
      case step1:
        return localizedStrings.gTipEmptyScalePan;
      case step3:
        return localizedStrings.gTipPlaceCalibrationWeight;
      case step2:
        return localizedStrings.gTipSetCalibrationWeight;
      case step4:
        return localizedStrings.gTipPlaceWeight;
      case step5:
        return localizedStrings.gTipCalibrationResult;
      default:
        return "";
    }
  }

  Widget buildStepInfo(
    int stepIndex,
  ) {
    Color initColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    Color fillingColor = Theme.of(context).colorScheme.onPrimary;

    Color textColor = initColor;
    Color leftLineColor = initColor;
    Color rightLineColor = initColor;
    Color circleColor = initColor;
    Color circleTextColor = initColor;

    if (curStep == stepIndex) {
      fillingColor = Theme.of(context).colorScheme.primary; // 已完成的步骤颜色
      textColor = Theme.of(context).colorScheme.primary; // 已完成的步骤颜色
      circleColor = Theme.of(context).colorScheme.primary; // 已完成的步骤颜色
      circleTextColor = Theme.of(context).colorScheme.onPrimary; // 已完成的步骤文字颜色
      leftLineColor = Theme.of(context).colorScheme.primary; // 已完成的步骤左线颜色
    } else if (curStep > stepIndex) {
      fillingColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤颜色
      textColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤文字颜色
      circleColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤颜色
      circleTextColor = Theme.of(context).colorScheme.onPrimary; // 已完成的步骤文字颜色
      leftLineColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤左线颜色

      rightLineColor = curStep - stepIndex > 1
          ? Theme.of(context).colorScheme.onTertiaryFixedVariant
          : Theme.of(context).colorScheme.primary; // 已完成的步骤左线颜色
    }

    if (isFinish && curStep == step5) {
      fillingColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤颜色
      textColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤文字颜色
      circleColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤颜色
      circleTextColor = Theme.of(context).colorScheme.onPrimary; // 已完成的步骤文字颜色
      leftLineColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤左线颜色
      rightLineColor =
          Theme.of(context).colorScheme.onTertiaryFixedVariant; // 已完成的步骤左线颜色
    }

    if (stepIndex == step1) {
      leftLineColor = Colors.transparent;
    }
    if (stepIndex == step5) {
      rightLineColor = Colors.transparent;
    }

    return Expanded(
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: leftLineColor,

                    // 可根据需求修改横线颜色
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fillingColor, // 内部填充白色
                    border: Border.all(
                      color: circleColor,
                      width: 2, // 边框宽度为 2
                    ),
                  ),
                  child: Center(
                    child: Text(
                      stepIndex.toString(), // 可根据需求修改数组，这里以数字 1 为例
                      style: Theme.of(context).textTheme.bodyMedium!.apply(
                            color: circleTextColor, // 文字为灰色,
                          ), // 文字为灰色,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(height: 1, color: rightLineColor // 未完成的步骤颜色
                      ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
                alignment: Alignment.topCenter,
                height: 40,
                child: Text(
                  getStepTitle(stepIndex),
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: textColor, // 文字颜色
                      ),
                  // overflow: TextOverflow.ellipsis, // 超出部分省略号处理
                ))
          ],
        ),
      ),
    );
  }

  Widget showSetParameterBtn() {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: showTextButton(
                context,
                48,
                localizedStrings.menuParameterSetting,
                selScaleId == -1
                    ? null
                    : () {
                        if (curStep != step1 && curStep != step5) {
                          showCalibrationWarning();
                          return;
                        }
                        setState(() {
                          isCalibration = false;
                        });
                      },
                !isCalibration
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                !isCalibration
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceDim,
                Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          SizedBox(
            width: 200,
            child: showTextButton(
                context,
                48,
                localizedStrings.menuCalibration,
                selScaleId == -1
                    ? null
                    : () {
                        setState(() {
                          isCalibration = true;
                        });
                      },
                isCalibration
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                isCalibration
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceDim,
                Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget showStepPart() {
    return Container(
        padding: const EdgeInsets.only(
          top: largePadding,
        ),
        height: 100, //leftBarIconHeight,
        child: Row(
          children: [
            buildStepInfo(step1),
            buildStepInfo(step2),
            buildStepInfo(step3),
            buildStepInfo(step4),
            buildStepInfo(step5),
          ],
        ));
  }
}
