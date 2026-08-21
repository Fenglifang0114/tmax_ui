import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/s15_tare_zero.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/wgt_value_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';

/// 硬件电子秤实时称重推流、心跳保活与去皮/归零服务类
class ScaleLiveStreamService {
  int selScaleId = -1;
  Timer? _cntAliveTimer;
  Timer? checkWgtStartTimer;
  Timer? _checkDataRevTimer;
  StreamSubscription? _eventbusSubscription;

  final ValueNotifier<bool> isWgtStartNotifier = ValueNotifier(false);
  final ValueNotifier<String> currentWgtStrNotifier = ValueNotifier('----');
  DateTime? lastDataReceivedTime;

  /// 初始化并监听电子秤推流广播
  void init({required String Function() getTargetUnit}) {
    startCntAliveTimer(10);
    checkDataRevTimer();
    startCheckWgtStartTimer();

    _eventbusSubscription =
        eventBus.on<EventReqWeightCountine>().listen((event) {
      ReqWeightCountine tempWeight = event.obj;
      if (tempWeight.scaleId == selScaleId) {
        myReqWeightCountine = tempWeight;
        lastDataReceivedTime = DateTime.now();
        isWgtStartNotifier.value = true;

        if (myReqWeightCountine.msgBody != null) {
          try {
            final weightStr = myReqWeightCountine.msgBody!.weightVal;
            final weight = double.tryParse(weightStr);
            if (weight != null &&
                weightStr != '' &&
                ['g', 'kg', 'lb']
                    .contains(myReqWeightCountine.msgBody!.weightUnit)) {
              final fromUnit = myReqWeightCountine.msgBody!.weightUnit;
              final toUnit = getTargetUnit();

              final convertedWeight = convertUnit(weight, fromUnit, toUnit);
              if (toUnit == 'g') {
                currentWgtStrNotifier.value =
                    convertedWeight.toStringAsFixed(0);
              } else {
                currentWgtStrNotifier.value =
                    convertedWeight.toStringAsFixed(3);
              }
            } else {
              currentWgtStrNotifier.value = weightStr;
            }
          } catch (e) {
            return;
          }
        }

        for (Scale scale in myAllScalesList) {
          if (scale.scaleId == selScaleId && !scale.isOnline) {
            scale.isOnline = true;
          }
        }
      }
    });
  }

  /// 设置当前绑定的秤 ID
  void setScaleId(int scaleId) {
    selScaleId = scaleId;
  }

  /// 启动 10s 硬件存活心跳定时器
  void startCntAliveTimer(int time) {
    _cntAliveTimer?.cancel();
    _cntAliveTimer = Timer(Duration(seconds: time), () {
      if (selScaleId != -1) {
        PublicFunctions.sendScaleAlive(selScaleId);
      }
      startCntAliveTimer(10);
    });
  }

  /// 停止心跳定时器
  void stopCntAliveTimer() {
    _cntAliveTimer?.cancel();
  }

  /// 10s 校验推流开启状态，防漏发
  void startCheckWgtStartTimer() {
    checkWgtStartTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (isWgtStartNotifier.value == false && selScaleId != -1) {
        PublicFunctions.getWeight(selScaleId);
      }
    });
  }

  /// 1s 超时检测，超过2s没收到数据重置并重新请求
  void checkDataRevTimer() {
    _checkDataRevTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (selScaleId != -1) {
        if (lastDataReceivedTime != null) {
          final timeDifference =
              DateTime.now().difference(lastDataReceivedTime!);
          if (timeDifference.inSeconds >= 2 && isWgtStartNotifier.value) {
            isWgtStartNotifier.value = false;
            currentWgtStrNotifier.value = '----';
            PublicFunctions.getWeight(selScaleId);
            lastDataReceivedTime = null;
          }
        }
      }
    });
  }

  /// 停止称重并重置秤 ID
  void stopWeightAndResetScaleId() {
    if (selScaleId != -1) {
      PublicFunctions.stopWeight(selScaleId);
    }
    selScaleId = -1;
  }

  /// 下发电子秤去皮指令
  void performTare() {
    if (selScaleId != -1) {
      tareByScaleId(selScaleId);
    }
  }

  /// 下发电子秤归零指令
  void performZero() {
    if (selScaleId != -1) {
      zeroByScaleId(selScaleId);
    }
  }

  /// 页面销毁清理
  void dispose() {
    _eventbusSubscription?.cancel();
    checkWgtStartTimer?.cancel();
    _checkDataRevTimer?.cancel();
    stopCntAliveTimer();
    if (selScaleId != -1) {
      PublicFunctions.stopWeight(selScaleId);
    }
    currentWgtStrNotifier.dispose();
    isWgtStartNotifier.dispose();
  }
}
