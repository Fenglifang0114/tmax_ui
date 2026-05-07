//称重共用的重量显示界面 20250521

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/received_wgt_value.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/s15_tare_zero.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/common_widget.dart';

class ScaleItemWidget extends StatefulWidget {
  final int scaleId;
  final String scaleName;
  final bool isS15;
  final bool isOpenUnstableTareOrZero;

  const ScaleItemWidget({
    super.key,
    required this.scaleId,
    required this.scaleName,
    required this.isS15,
    required this.isOpenUnstableTareOrZero,
  });

  @override
  State<ScaleItemWidget> createState() => _ScaleItemWidgetState();
}

class _ScaleItemWidgetState extends State<ScaleItemWidget> {
  ReqWeightCountine tempWeight = ReqWeightCountine();
  ReceiveWgtInfo? weightInfo;
  Timer? startTimer;
  Timer? innerTimer;
  bool isCnting = false;
  bool isStart = false;
  dynamic eventBus1;

  //定时发送秤还活着
  Timer? _cntAliveTimer;
  bool _isCntAliveTiming = false;
  bool get isCntAliveTiming => _isCntAliveTiming;

  void startCntAliveTimer(int time) {
    if (_cntAliveTimer != null) {
      _cntAliveTimer!.cancel();
    }

    _isCntAliveTiming = true;
    _cntAliveTimer = Timer(Duration(seconds: time), () {
      PublicFunctions.sendScaleAlive(widget.scaleId);
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
  }

  @override
  void dispose() {
    eventBus1.cancel();
    startTimer?.cancel();
    innerTimer?.cancel();
    stopCntAliveTimer();
    _cntAliveTimer?.cancel();
    super.dispose();
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
      height: 160,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Container(
              height: 42,
              padding: const EdgeInsets.only(
                  left: regularPadding, right: regularPadding),
              color: Theme.of(context).colorScheme.surface,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.scaleName,
                    style: Theme.of(context).textTheme.bodyMedium!.apply(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
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
                                PublicFunctions.forceUntare(widget.scaleId);
                              }
                            });
                          }),
                    ),
                ],
              )),
          Container(
            height: 1,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
          ),
          Expanded(
            child: Container(
                height: regularPadding,
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.only(
                            left: largePadding, right: largePadding),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildIconAndText(
                                context,
                                localizedStrings.iStable,
                                weightInfo?.isStable,
                                1,
                              ),
                              SizedBox(
                                width: 24,
                              ),
                              _buildIconAndText(
                                context,
                                localizedStrings.iTextNet,
                                weightInfo?.isNet,
                                2,
                              ),
                              SizedBox(
                                width: 24,
                              ),
                              _buildIconAndText(
                                context,
                                localizedStrings.iTextZero,
                                weightInfo?.isZero,
                                3,
                              ),
                            ],
                          ),
                        )),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              child: Container(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown, // 当文字溢出时缩小字体
                              alignment: Alignment.centerRight,
                              child: Text(weightInfo?.weightVal ?? '---------',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge!
                                      .copyWith(
                                        color: isStart
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onTertiaryFixedVariant
                                            : Theme.of(context)
                                                .colorScheme
                                                .error,
                                      )),
                            ),
                          )),
                          Container(
                            width: 80,
                            height: 80,
                            alignment: Alignment.bottomLeft,
                            child: Text(weightInfo?.weightUnit ?? '----',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    )),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: largePadding, right: largePadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          showTextButton(
                              context,
                              36,
                              localizedStrings.gBtnTare,
                              isStart
                                  ? () {
                                      tareByScaleId(widget.scaleId);
                                    }
                                  : null,
                              Theme.of(context).colorScheme.onPrimary,
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.onPrimary),
                          showTextButton(
                              context,
                              36,
                              localizedStrings.iBtnZero,
                              isStart
                                  ? () {
                                      zeroByScaleId(widget.scaleId);
                                    }
                                  : null,
                              Theme.of(context).colorScheme.onPrimary,
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.onPrimary),
                        ],
                      ),
                    ),
                  ],
                )),
          ),
          Container(
            height: regularPadding,
            color: Theme.of(context).colorScheme.surfaceDim,
          ),
        ],
      ),
    );
  }

  Widget _buildIconAndText(
      BuildContext context, String text, bool? isConditionMet, int type) {
    return Align(
        child: Container(
      padding: const EdgeInsets.only(left: 4, right: 4),
      width: 32,
      height: 32,
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
          wgtIconSize,
          20,
          isConditionMet == null
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : isConditionMet
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.surfaceContainerHighest),
    ));
  }
}
