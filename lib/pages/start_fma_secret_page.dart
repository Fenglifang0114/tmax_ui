//保密配方 暂存的和正常称重的公用页面  保密的配方不会有修改配方的按钮
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/f_raw_name.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/formula_wgt_process_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/get_auto_next_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/req_add_fma_rec_data.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/s15_tare_zero.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/fma_process_bar.dart';
import 'package:t_max/widget/sticky_table.dart';
import '../data/language.dart';

class FormulaSecretWeighingPage extends StatefulWidget {
  const FormulaSecretWeighingPage(
      {super.key,
      required this.selectFormula,
      required this.selScaleId,
      required this.totalFmaWgt,
      required this.fmaUnit,
      required this.fromDraft,
      required this.selectDarftInfo});

  final FormulaInfoDb selectFormula;
  final int selScaleId;
  final double totalFmaWgt;
  final String fmaUnit;
  final bool fromDraft; //是否来自草稿
  final DarfFmaInfoListFromDb? selectDarftInfo; //草稿配方信息

  @override
  State<FormulaSecretWeighingPage> createState() =>
      FormulaSecretWeighingPageState();
}

class FormulaSecretWeighingPageState extends State<FormulaSecretWeighingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool sort = false;
  final ScrollController _scrollController =
      ScrollController(); // 添加 ScrollController

  bool selectAll = false; // 添加全选状态
  int clickedRow = 0; // 添加点击行状态
  final TextEditingController encryptedCtl = TextEditingController();
  final TextEditingController formulaTypeCtl = TextEditingController();
  final TextEditingController rawTypeCtl = TextEditingController();
  List<FormulaWgtProcessData> processWgtList = []; //配方中的原料重量集合
  FormulaWgtProcessData selectedProcessWgt = FormulaWgtProcessData(); //选中的原料重量

  double initTotalWeight = 1000.0; //总重量百分比模式传入的总重量
  String totalUnit = 'g'; //总重量百分比模式传入的总重量单位
  bool isWgtStart = false; //是否开始重量
  bool isShowTipDialog = false; //是否显示提示对话框
  bool enableSelRaw = false; //是否启用选择原料  按顺序制作，需要添加补充的时候再去做选择物料
  bool startFormula = false; //是否开始配方  配方开始后，归零和扣重不能使用
  String recRecNumber = ''; //配方订单编号
  double currentRawWgt = 0.000; //当前的原料重量 默认为0
  String fmaUnit = 'g'; //配方重量单位

  bool isEnableNext = true; //是否禁用下一个
  bool isFinish = false; //是否完成
  double needTotalWgt = 0.000; //需要的总重量 默认为0  这个主要是修正后的重量

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;

  dynamic _eventbus4;
  dynamic _eventbus5;

  Timer? setWgtStartFalseTimer; // 用于每3秒将isWgtStart设置为false的定时器
  Timer? checkWgtStartTimer; // 用于每5秒检查isWgtStart的定时器

  late Scale myScale;

  bool autoNextStep = false;
  bool autoTare = false;
  bool checkCode = false;
  final TextEditingController stableTimeCtl = TextEditingController();
  Timer? autoNextStepTimer;
  int stableDurationCounter = 0; // 稳定时长计数器
  final ValueNotifier<bool> autoNextStepNotifier = ValueNotifier(false);
  int stableTime = 0;

  FormulaInfoDb myFmaInfo = FormulaInfoDb(); //当前配方信息
  Timer? _cntAliveTimer;
  // 启动发送存活消息的定时器
  void startCntAliveTimer(int time) {
    _cntAliveTimer?.cancel();

    _cntAliveTimer = Timer(Duration(seconds: time), () {
      if (widget.selScaleId != -1) {
        PublicFunctions.sendScaleAlive(widget.selScaleId);
      }
      startCntAliveTimer(10);
    });
  }

  // 停止发送存活消息的定时器
  void stopCntAliveTimer() {
    _cntAliveTimer?.cancel();
  }

  // 每3秒钟将isWgtStart设置为false
  void startSetWgtStartFalseTimer() {
    setWgtStartFalseTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          isWgtStart = false;
        });
      }
    });
  }

  // 每5秒判断一下isWgtStart是不是false，是false的话，就重新发送请求开启连续发送
  void startCheckWgtStartTimer() {
    checkWgtStartTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (isWgtStart == false) {
        // 重新发送请求开启连续发送
        PublicFunctions.getWeight(widget.selScaleId);
        setState(() {
          myReqWeightCountine.msgBody = null;
        });
      }
    });
  }

  // 启动自动下一步定时器
  void startAutoNextStepTimer() {
    autoNextStepTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (myReqWeightCountine.msgBody == null) {
        stableDurationCounter = 0;
      } else if (!myReqWeightCountine.msgBody!.isStable) {
        stableDurationCounter = 0;
      } else if (myReqWeightCountine.msgBody != null &&
          myReqWeightCountine.msgBody!.isStable &&
          isEnableNext &&
          isWgtStart &&
          checkValueIsOk() == 'ok') {
        stableDurationCounter++;
        if (stableDurationCounter >= stableTime * 10) {
          final isOk = checkValueIsOk();
          if (isOk == "ok" && startFormula) {
            nextStep(isOk); // 执行下一步操作
            stableDurationCounter = 0; // 重置计数器
          }
        }
      }
    });
  }

  // 停止自动下一步定时器
  void stopAutoNextStepTimer() {
    autoNextStepTimer?.cancel();
    autoNextStepTimer = null;
    stableDurationCounter = 0;
  }

  // nextStep 方法
  void nextStep(String isWgtOk) {
    double currentTempWgtValue = currentRawWgt;
    handleOkStatus(isWgtOk, currentTempWgtValue);
  }

//百分比模式下初始化重量和单位
  void initTotalWgtUnit() {
    if (myFmaInfo.header!.formulaMode == 'pct') {
      initTotalWeight = widget.totalFmaWgt;
      initTotalWeight = double.parse(initTotalWeight.toStringAsFixed(3));
      myFmaInfo.header!.formulaUnit = widget.fmaUnit;
      myFmaInfo.header!.totalWeight = initTotalWeight;
      needTotalWgt = initTotalWeight;
    }
  }

  void initWgtList() {
    double minValue = 0.0;
    double maxValue = 0.0;
    double errorWgt = 0.0; //误差重量值
    double targetWgt = 0.0; //目标重量值
    String fmode = myFmaInfo.header!.formulaMode ?? '';
    needTotalWgt = myFmaInfo.header!.totalWeight!;
    //如果包含容器，第一个写容器  修改了此处
    if (myFmaInfo.header!.needContainer!) {
      FormulaWgtProcessData processWgt = FormulaWgtProcessData(
        no: 0,
        rawId: '-',
        rawName: '-',
        fmaMode: fmode,
        targetWgt: 80,
        targetPct: 80,
        currentWgt: 0.0,
        minWgt: 50,
        maxWgt: 100,
        errorWgt: 0,
        errorPct: 0,
        currentErrorWgt: 0.0,
        currentErrorPct: 0.0,
        isOK: 'no', //no 未开始 low: 低，high: 高，ok: 正常 初始值都是 low
      );
      processWgtList.add(processWgt);
    }

    for (var detail in myFmaInfo.details!) {
      if (fmode == 'wgt') {
        minValue = detail.materialWeight! - detail.allowableError!;
        maxValue = detail.materialWeight! + detail.allowableError!;
        errorWgt = detail.allowableError!;
        targetWgt = detail.materialWeight!;
      } else {
        minValue = initTotalWeight * (detail.materialPercentage! / 100) -
            detail.allowableError! * initTotalWeight / 100;
        minValue = double.parse(minValue.toStringAsFixed(3));
        maxValue = initTotalWeight * (detail.materialPercentage! / 100) +
            detail.allowableError! * initTotalWeight / 100;
        maxValue = double.parse(maxValue.toStringAsFixed(3));
        errorWgt = detail.allowableError! * initTotalWeight / 100;
        errorWgt = double.parse(errorWgt.toStringAsFixed(3));
        targetWgt = initTotalWeight * (detail.materialPercentage! / 100);
        targetWgt = double.parse(targetWgt.toStringAsFixed(3));
      }
      String rawName = getRawName(detail.materialId!);
      FormulaWgtProcessData processWgt = FormulaWgtProcessData(
        no: detail.sequence,
        rawId: detail.materialId,
        rawName: rawName,
        fmaMode: fmode,
        targetWgt: targetWgt,
        targetPct: detail.materialPercentage,
        currentWgt: 0.0,
        minWgt: minValue < 0 ? 0 : minValue,
        maxWgt: maxValue,
        errorWgt: errorWgt,
        errorPct: detail.allowableError,
        currentErrorWgt: 0.0,
        currentErrorPct: 0.0,
        isOK: 'no', //no 未开始 low: 低，high: 高，ok: 正常 初始值都是 low
      );
      processWgtList.add(processWgt);
    }
    if (processWgtList.isNotEmpty) {
      selectedProcessWgt = processWgtList[0]; //默认选中第一个原料重量
    }
  }

  void getScaleInfo() {
    PublicFunctions.getWeight(widget.selScaleId);
  }

  //生成订单编号
  void createRecNumber() {
    String company = "F"; // 公司名称
    DateTime now = DateTime.now();
    String year = now.year.toString(); // 取年份的后两位
    String month = now.month.toString().padLeft(2, '0'); // 取月份，不足两位时补零
    String day = now.day.toString().padLeft(2, '0'); // 取日期，不足两位时补零
    String hour = now.hour.toString().padLeft(2, '0'); // 取小时，不足两位时补零
    String minute = now.minute.toString().padLeft(2, '0'); // 取分钟，不足两位时补零
    String second = now.second.toString().padLeft(2, '0'); // 取秒数，不足两位时补零
// 拼接成订单编号
    String orderNumber = "$company-$year$month$day$hour$minute$second";
    recRecNumber = orderNumber;
  }

  // 如果是暂存的配方数据，则需要将暂存的数据赋值给processWgtList
  void initDarftFmaData() {
    double lastNeedTotalWgt = needTotalWgt; // 保存上一次的总重量
    if (widget.selectDarftInfo!.details!.isEmpty) {
      return; // 如果没有暂存数据，则不进行赋值
    }
    for (var detail in widget.selectDarftInfo!.details!) {
      if (detail.isContainer == true) {
        processWgtList[0].currentWgt =
            double.parse((detail.actualWeight ?? 0.0).toStringAsFixed(3));
        continue; // 跳过容器
      } else {
        //找出seq 值一样的再赋值
        for (var wgt in processWgtList) {
          if (wgt.no == detail.seq) {
            wgt.currentWgt =
                double.parse((detail.actualWeight ?? 0.0).toStringAsFixed(3));
            break; // 找到后跳出循环
          }
        }
      }
    }

    // 计算误差并找出超标比例最大的原料
    double maxExceedRatio = 0.0;
    FormulaWgtProcessData? maxExceedWgt;
    for (var wgt in processWgtList) {
      if (wgt.no == 0) continue; // 跳过容器

      double minWgt = wgt.minWgt!;
      double maxWgt = wgt.maxWgt!;
      double currentWgt = wgt.currentWgt!;
      double targetWgt = wgt.targetWgt!;

      // 计算误差

      wgt.currentErrorWgt =
          double.parse((currentWgt - targetWgt).toStringAsFixed(3));
      wgt.currentErrorPct = double.parse(
          (wgt.currentErrorWgt! / targetWgt * 100).toStringAsFixed(3));

      // 判断状态
      if (currentWgt >= minWgt && currentWgt <= maxWgt) {
        wgt.isOK = "ok";
      } else if (currentWgt < minWgt) {
        wgt.isOK = "low";
      } else {
        wgt.isOK = "high";
        double exceedRatio = (currentWgt - maxWgt) / maxWgt;
        if (exceedRatio > maxExceedRatio) {
          maxExceedRatio = exceedRatio;
          maxExceedWgt = wgt;
        }
      }
    }

    // 如果有超标原料，按超标比例最大的重新计算配方目标值
    if (maxExceedWgt != null) {
      double ratio = maxExceedWgt.currentWgt! / maxExceedWgt.targetWgt!;
      ratio = double.parse(ratio.toStringAsFixed(3)); // 保留三位小数
      needTotalWgt = needTotalWgt * ratio; // 更新需要的总重量
      needTotalWgt = double.parse(needTotalWgt.toStringAsFixed(3)); // 保留三位小数

      if (myFmaInfo.header!.formulaMode == 'pct') {
        for (var item in processWgtList) {
          if (item.no == 0) {
            continue;
          }
          item.targetWgt = needTotalWgt * item.targetPct! / 100;
          item.targetWgt = double.parse(item.targetWgt!.toStringAsFixed(3));
          item.errorWgt = needTotalWgt * item.errorPct! / 100;
          item.errorWgt = double.parse(item.errorWgt!.toStringAsFixed(3));
          item.minWgt = item.targetWgt! - item.errorWgt!;
          item.minWgt = double.parse(item.minWgt!.toStringAsFixed(3));
          item.maxWgt = item.targetWgt! + item.errorWgt!;
          item.maxWgt = double.parse(item.maxWgt!.toStringAsFixed(3));
          item.currentErrorWgt = item.currentWgt! - item.targetWgt!;
          item.currentErrorWgt =
              double.parse(item.currentErrorWgt!.toStringAsFixed(3));
          item.isOK = checkIsOk(item.currentWgt!, item.minWgt!, item.maxWgt!);
        }
      } else {
        for (var item in processWgtList) {
          //如果第一个是容器，就不用去计算
          if (item.no == 0) {
            continue;
          }
          item.targetWgt = needTotalWgt * item.targetWgt! / lastNeedTotalWgt;
          item.targetWgt = double.parse(item.targetWgt!.toStringAsFixed(3));
          item.minWgt = item.targetWgt! - item.errorWgt!;
          item.minWgt = double.parse(item.minWgt!.toStringAsFixed(3));
          item.maxWgt = item.targetWgt! + item.errorWgt!;
          item.maxWgt = double.parse(item.maxWgt!.toStringAsFixed(3));
          item.currentErrorWgt = item.currentWgt! - item.targetWgt!;
          item.currentErrorWgt =
              double.parse(item.currentErrorWgt!.toStringAsFixed(3));
          item.isOK = checkIsOk(item.currentWgt!, item.minWgt!, item.maxWgt!);
        }
      }
    }
    findNextRaw();
  }

  @override
  void initState() {
    super.initState();
    myFmaInfo = widget.selectFormula; //获取传入的配方信息
    fmaUnit = widget.fmaUnit; //获取传入的配方单位

    _tabController = TabController(length: 2, vsync: this);
    for (var scale in myAllScalesList) {
      if (scale.scaleId == widget.selScaleId) {
        myScale = scale;
        break;
      }
    }
    autoNextStepNotifier.addListener(() {
      if (autoNextStepNotifier.value) {
        startAutoNextStepTimer();
      } else {
        stopAutoNextStepTimer();
      }
    });
    //将传入的配方信息赋值给processWgtList
    initTotalWgtUnit();
    initWgtList();
    getScaleInfo();

    if (widget.fromDraft) {
      recRecNumber = widget.selectDarftInfo!.header!.orderId!;
      initDarftFmaData();
    } else {
      createRecNumber();
    }

    startCntAliveTimer(10);
    startSetWgtStartFalseTimer();
    startCheckWgtStartTimer();

    PublicFunctions.getAutoNext();

    _eventbus1 = eventBus.on<EventRespGetRawTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            rawTypeList = categoryTypeListFromJson(dataStr);
          });
        } else {
          setState(() {
            rawTypeList = [];
          });
        }
      }
    });
    _eventbus2 = eventBus.on<EventRespGetFormulaTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            formulaTypeList = categoryTypeListFromJson(dataStr);
          });
        } else {
          setState(() {
            formulaTypeList = [];
          });
        }
      }
    });

    _eventbus3 = eventBus.on<EventRespAddFormulaType>().listen((event) {
      if (mounted) {
        PublicFunctions.getFormulaTypeList();
      }
    });

    _eventbus4 = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        setState(() {
          ReqWeightCountine tempWeight = ReqWeightCountine();
          tempWeight = event.obj;
          if (tempWeight.scaleId == myScale.scaleId) {
            myReqWeightCountine = tempWeight;

            // isCnting = true;
            isWgtStart = true;
            if (myReqWeightCountine.msgBody!.weightUnit !=
                    myFmaInfo.header!.formulaUnit &&
                isShowTipDialog == false) {
              isShowTipDialog = true;
              showTipDialog();
            }
            if (myReqWeightCountine.msgBody != null) {
              try {
                currentRawWgt =
                    double.parse(myReqWeightCountine.msgBody!.weightVal);
                // currentRawWgt =
                //     double.parse(myReqWeightCountine.msgBody!.weightVal) -
                //         actualTotalRawWgt;
                currentRawWgt = double.parse(currentRawWgt.toStringAsFixed(3));
                // if (currentRawWgt < 0) {
                //   currentRawWgt = 0.0;
                // }
              } catch (e) {
                // 处理转换失败的情况
                // print('Failed to parse weight value: $e');
                currentRawWgt = 0.0;
              }
            }
          }
        });
      }
    });
    _eventbus5 = eventBus.on<EventRespGetAutoNext>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            autoNextStep = getAutoNextFormDbFromJson(dataStr).autoNext;
            autoNextStepNotifier.value = autoNextStep;
            stableTime = getAutoNextFormDbFromJson(dataStr).stableTime;
            stableTimeCtl.text = stableTime.toString();
            autoTare = getAutoNextFormDbFromJson(dataStr).autoTare;
          });
        } else {
          setState(() {
            autoNextStepNotifier.value = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();

    stopCntAliveTimer();
    setWgtStartFalseTimer?.cancel(); // 取消定时器
    checkWgtStartTimer?.cancel(); // 取消定时器
    stopAutoNextStepTimer();
    stableTimeCtl.dispose();

    autoNextStepNotifier.dispose();
  }

  // 提示切换单位对话框
  void showTipDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return ShowUnitTipDialog(
          title: localizedStrings.fTipTitle,
          msg:
              '${localizedStrings.fWgtUnit} ${myFmaInfo.header!.formulaUnit!},${localizedStrings.fSwitchUnitHint}',
        );
      },
    ).then((value) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            isShowTipDialog = false;
          });
        }
      });
    });
  }

  // 显示新增配方类型对话框
  void showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return ShowDeleteTipDialog(
          title: localizedStrings.fTipTitle,
          msg: localizedStrings.fClearWeighingDataMsg,
        );
      },
    ).then((value) {
      if (value) {
        setState(() {
          //清空所有称重数据
          processWgtList.clear();

          currentRawWgt = 0.0;
          clickedRow = 0;
          startFormula = false;
          isEnableNext = true;

          initWgtList();
        });
      }
    });
  }

  //获取原料OK的数量
  int getOKCount() {
    int count = 0;
    for (var wgt in processWgtList) {
      if (wgt.isOK == okStr) {
        count++;
      }
    }
    return count;
  }

  //检查是否全部OK
  bool checkAllOK() {
    for (var wgt in processWgtList) {
      if (wgt.isOK != okStr && wgt.no != 0) {
        return false;
      }
    }
    return true;
  }

  saveFmaRec(bool isAllOK) {
    //修改了此处
    //通过当前原料的重量计算总的原料的实际重量
    double actualTotalRawWgt = 0.0;
    for (var wgtRec in processWgtList) {
      if (wgtRec.currentWgt != null && wgtRec.no != 0) {
        actualTotalRawWgt += wgtRec.currentWgt!;
      }
    }
    RecHeader recHeader = RecHeader(
      recordId: recRecNumber, //配方订单编号
      recHeaderOperator: mySysUser.nickName!, //操作员
      formulaId: myFmaInfo.header!.formulaId, //配方ID
      formulaTypeName: myFmaInfo.header!.formulaName, //配方名称
      totalWeight: myFmaInfo.header!.totalWeight!, //总重量
      actualFmaTotalWgt: needTotalWgt, //实际配方总重量包括修正的重量
      actualTotalWeight: actualTotalRawWgt, //实际原料总重量
      totalWeightUnit: myFmaInfo.header!.formulaUnit, //总重量单位

      totalMaterialWeightUnit: myFmaInfo.header!.formulaUnit, //总原料重量单位
      isQualified: isAllOK ? 'yes' : 'no', //是否合格
      scaleId: widget.selScaleId, //秤ID
      scaleName: myScale.scaleName, //秤名称
      scaleModel: myScale.scaleModel, //秤型号
      scaleSn: myScale.scaleSn, //秤SN
    );

    List<RecDetail>? reqRecDetailList = []; //配方明细集合
    for (var wgtRec in processWgtList) {
//计算实际百分比
      double actualPct = 0.0;
      if (needTotalWgt != 0) {
        actualPct = wgtRec.currentWgt! / needTotalWgt * 100;
        actualPct = double.parse(actualPct.toStringAsFixed(3));
      }

      RecDetail recDetail = RecDetail(
        recordId: recRecNumber, //配方订单编号
        materialId: wgtRec.rawId, //原料ID
        sequence: wgtRec.no, //顺序
        allowableError: wgtRec.errorWgt, //允许误差
        targetWgt: wgtRec.targetWgt, //目标重量
        actualWeight: wgtRec.currentWgt, //实际重量
        actualWeightUnit: fmaUnit, //实际重量单位
        actualPercentage: actualPct, //实际百分比
        actualErrorWgt: wgtRec.currentErrorWgt, //实际误差重量
        actualErrorPct: wgtRec.currentErrorPct, //实际误差百分比
        isQualified: wgtRec.isOK, //是否合格
        scaleId: myScale.scaleId,
        scaleName: myScale.scaleName,
        scaleModel: myScale.scaleModel, //秤型号
        scaleSn: myScale.scaleSn, //秤SN
      );
      reqRecDetailList.add(recDetail);
    }

    ReqAddFmaRec reqAddFmaRec =
        ReqAddFmaRec(recHeader: recHeader, recDetail: reqRecDetailList); //配方

    PublicFunctions.addFormulaRec(reqAddFmaRecToJson(reqAddFmaRec));
    if (widget.fromDraft) {
      //删除草稿
      PublicFunctions.deleteDraftRecord(recRecNumber);
    }

    setState(() {
      isFinish = true;
      isEnableNext = false;
    });
  }

  final double maxWidth = 360; //最大宽度
  showBottomBtn() {
    return Container(
        height: 76,
        color: Theme.of(context).colorScheme.surface,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: showTextButton(
                context,
                btnHeight,
                localizedStrings.fCompleteIngredientsBtn,
                !isFinish
                    ? () {
                        bool isAllOK = checkAllOK();
                        if (!isAllOK) {
                          showDialog(
                            context: context,
                            barrierDismissible: false, // 点击对话框外部不关闭对话框
                            builder: (BuildContext context) {
                              return ShowNormalTipDialog(
                                title: localizedStrings.fTipTitle,
                                msg: localizedStrings.fFormulaUnqualifiedMsg,
                              );
                            },
                          ).then((value) {
                            if (value == null) {
                              return;
                            }
                            if (value) {
                              // 保存
                              saveFmaRec(isAllOK);
                              PublicFunctions.stopWeight(widget.selScaleId);
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            } else {
                              return;
                            }
                          });
                        } else {
                          saveFmaRec(isAllOK);
                          Navigator.pop(context);
                        }
                      }
                    : null,
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary),
          ),
          SizedBox(
            width: largePadding,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: showTextButton(
                context,
                btnHeight,
                localizedStrings.btnTemporarySave,
                !isEnableNext
                    ? null
                    : () {
                        //已完成，不能暂存，只能结束
                        performDarfFmaSave();
                      },
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary),
          ),
          SizedBox(
            width: largePadding,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: showTextButton(
                context, btnHeight, localizedStrings.fAbandonIngredientsBtn,
                () {
              performAbandonFma();
            },
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.error,
                Theme.of(context).colorScheme.onPrimary),
          ),
          SizedBox(
            width: largePadding,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: showTextButton(
                context, btnHeight, localizedStrings.btnRestart, () {
              showDeleteDialog();
            },
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.error,
                Theme.of(context).colorScheme.onPrimary),
          ),
        ]));
  }

  void performAbandonFma() {
    if (!isFinish) {
      showDialog(
        context: context,
        barrierDismissible: false, // 点击对话框外部不关闭对话框
        builder: (BuildContext context) {
          return ShowDeleteTipDialog(
            title: localizedStrings.fTipTitle,
            msg: localizedStrings.fClearWeighingDataMsg,
          );
        },
      ).then((value) {
        if (value) {
          setState(() {
            PublicFunctions.stopWeight(widget.selScaleId);
            Navigator.pop(context);
          });
        }
      });
    } else {
      PublicFunctions.stopWeight(widget.selScaleId);
      Navigator.pop(context);
    }
  }

  Widget showStartBtn() {
    return Container(
        height: 76,
        color: Theme.of(context).colorScheme.surface,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: showTextButton(
                context,
                btnHeight,
                localizedStrings.gBtnStart,
                isWgtStart
                    ? () {
                        showDialog(
                          context: context,
                          barrierDismissible: false, // 点击对话框外部不关闭对话框
                          builder: (BuildContext context) {
                            return ShowNormalTipDialog(
                              title: localizedStrings.fTipTitle,
                              msg: localizedStrings.tipEnsureWeightCorrect,
                            );
                          },
                        ).then((value) {
                          if (value == null) {
                            return;
                          }
                          if (value) {
                            setState(() {
                              startFormula = true;
                            });
                          }
                        });
                      }
                    : null,
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary),
          ),
        ]));
  }

  void performDarfFmaSave() {
    //先判断出了容器之外有没有原料重量，如果没有原料重量，就不需要暂存
    bool hasRawWeight = false;
    for (var wgtRec in processWgtList) {
      if (wgtRec.no != 0 && wgtRec.currentWgt! > 0) {
        hasRawWeight = true;
        break;
      }
    }

    if (!hasRawWeight) {
      showTipInfo(localizedStrings.tipNoRawMaterialWeightData, context);
      return;
    }

    //通过当前原料的重量计算总的原料的实际重量
    DarfFmaInfoListFromDb tempDarfFmaInfo = DarfFmaInfoListFromDb();
    List<DarfDetail> tempDetails = [];

    for (var wgtRec in processWgtList) {
      if (wgtRec.no == 0) {
        DarfDetail detail = DarfDetail(
            recId: 0,
            orderId: recRecNumber,
            rawMaterialId: '',
            seq: wgtRec.no,
            actualWeight: wgtRec.currentWgt,
            actualWeightUnit: fmaUnit,
            isContainer: true,
            remark: '',
            remark1: '',
            remark2: '');
        tempDetails.add(detail);
        continue; //跳过容器
      }
      DarfDetail detail = DarfDetail(
          recId: 0,
          orderId: recRecNumber,
          rawMaterialId: wgtRec.rawId,
          seq: wgtRec.no,
          actualWeight: wgtRec.currentWgt,
          actualWeightUnit: fmaUnit,
          isContainer: false,
          remark: '',
          remark1: '',
          remark2: '');
      tempDetails.add(detail);
    }

    DarfHeader header = DarfHeader(
      recId: 0,
      orderId: recRecNumber, //配方订单编号
      createdBy: mySysUser.nickName!, //操作员
      formulaId: myFmaInfo.header!.formulaId, //配方ID

      status: 0,
      remark: '',
      remark1: '',
      remark2: '', //备注
    );

    tempDarfFmaInfo.header = header;
    tempDarfFmaInfo.details = tempDetails;

    String jsonStr = darfFmaInfoFromDbToJson(tempDarfFmaInfo);
    if (widget.fromDraft) {
      PublicFunctions.updateDraftRecord(jsonStr);
    } else {
      PublicFunctions.createDraftRecord(jsonStr);
    }

    PublicFunctions.stopWeight(widget.selScaleId);
    darfFmaInfoList = [];
    PublicFunctions.getDraftRecords();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  //传入index判断是否达标
  bool checkIndexIsOK(int index) {
    return processWgtList[index].isOK == "ok" ? true : false;
  }

  showRawOrderDetail() {
    final List<Widget> children = [];
    final List<FormulaWgtProcessData> list = processWgtList;

    for (int index = 0; index < list.length; index++) {
      bool isSelected = clickedRow == index;
      Color backgroundColor = (checkIndexIsOK(index))
          ? Theme.of(context).colorScheme.surfaceContainerLow
          : isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surfaceContainerLow;
      Color innerContainerColor = isSelected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surface;
      Color textColor = (checkIndexIsOK(index))
          ? Theme.of(context).colorScheme.onTertiaryFixedVariant
          : isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant;
      Color numberTextColor = isSelected
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onSurfaceVariant;

      Widget item = InkWell(
        onTap: () {
          setState(() {
            if (enableSelRaw) {
              setState(() {
                clickedRow = index; // 更新选中的 index
                selectedProcessWgt = list[index];
              });
            }
          });
          // 这里添加点击事件的处理逻辑
          // print('点击了第 $index 项');
        },
        child: Container(
          width: (MediaQuery.of(context).size.width - 6 * 10 - 300) /
              5, // 计算每个项的宽度，每行显示 5 个
          height: 32,
          color: backgroundColor,
          child: Row(children: [
            SizedBox(
              width: 2,
            ),
            (checkIndexIsOK(index))
                ? Container(
                    width: 28,
                    height: 28,
                    color: Theme.of(context).colorScheme.onTertiaryFixedVariant,
                    child: Center(
                        child: Icon(Icons.check_circle_outline,
                            size: 24,
                            color: Theme.of(context).colorScheme.onPrimary)),
                  )
                : Container(
                    width: 28,
                    height: 28,
                    color: innerContainerColor,
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: numberTextColor,
                        ),
                      ),
                    ),
                  ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                // 修改显示内容
                list[index].no == 0
                    ? localizedStrings.fFmaContainer
                    : list[index].rawName ?? '',
                style: TextStyle(
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ]),
        ),
      );

      children.add(item);

      // 不是最后一个元素时，添加图标
      if (index < list.length - 1) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(
              Icons.keyboard_double_arrow_right_outlined, // 可替换为你想要的图标
              size: 30,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }
    }

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          spacing: 10, // 水平间距
          runSpacing: 10, // 垂直间距
          alignment: WrapAlignment.start, // 设置为左对齐
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
      color: Theme.of(context).colorScheme.surfaceDim, //对接时修改颜色值
      child:
          // Padding(
          //   padding: const EdgeInsets.all(14.0),
          //   child:
          Column(
        children: [
          showTitleBar(),
          Divider(
            color: Theme.of(context).colorScheme.surfaceDim,
            thickness: 1,
            height: 1,
          ),
          showFormulaInfo(),
          Divider(
            color: Theme.of(context).colorScheme.surfaceDim,
            thickness: 1,
            height: 1,
          ),
          Expanded(
            flex: 9,
            child: Column(children: [
              Container(
                  height: 42,
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(children: [
                    SizedBox(
                      width: 17,
                    ),
                    Expanded(
                      child: Text(localizedStrings.fIngredientOrder),
                    ),
                  ])),
              Expanded(
                child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 17,
                          ),
                          showRawOrderDetail(),
                        ])),
              )
            ]),
          ),
          if (!checkAllOK() && startFormula) showWgtTable(),
          if (!startFormula) showWgtDataAndBtn(),
          if (!checkAllOK() && startFormula) showNextBtn(),
          if (checkAllOK()) showCompleteStatus(),
          // Container(
          //   height: 14,
          //   color: Theme.of(context).colorScheme.surface,
          // ),
          startFormula ? showBottomBtn() : showStartBtn(),
        ],
      ),
    ));
  }

  bool checkRawDelete(Object? data) {
    if (data == null || data is! RawDataInfo) {
      return false;
    }
    final targetMaterialId = data.materialId;
    return formulaDataList.every((formula) {
      return formula.details?.every((detail) {
            return detail.materialId != targetMaterialId;
          }) ??
          true;
    });
  }

  //显示速度

  showSpeed() {
    return SizedBox(
        width: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //当目标值与当前值相差500g以上时，快速
            //当目标值与当前值100到500g之间时，中速
            //当目标值与当前值100g以下时，慢速
            //当当前值大于目标值，不显示
            if (currentRawWgt <=
                selectedProcessWgt.targetWgt! - selectedProcessWgt.currentWgt!)
              IntrinsicWidth(
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  color: Color(0xFFFFB44A),
                  child: Center(
                    child: Text(
                      selectedProcessWgt.targetWgt! -
                                  selectedProcessWgt.currentWgt! -
                                  currentRawWgt >
                              500
                          ? localizedStrings.fHighSpeed
                          : (selectedProcessWgt.targetWgt! -
                                          selectedProcessWgt.currentWgt! -
                                          currentRawWgt <
                                      500) &&
                                  (selectedProcessWgt.targetWgt! -
                                          selectedProcessWgt.currentWgt! -
                                          currentRawWgt >
                                      100)
                              ? localizedStrings.fMediumSpeed
                              : localizedStrings.fLowSpeed,
                      style: TextStyle(
                        color: Colors.black,
                        // 保留文本截断设置，以防空间不足
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ));
  }

//扣重归零等按钮
  Widget showTareZero() {
    return Container(
        height: 52,
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(children: [
          Expanded(
              flex: 1,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                showSpeed(),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 150,
                  child: Row(children: [
                    Expanded(
                      child: btnStyle(
                          localizedStrings.iBtnZero,
                          startFormula
                              ? null
                              : () {
                                  // PublicFunctions.performZeroWithScaleId(
                                  //     widget.selScaleId);
                                  zeroByScaleId(widget.selScaleId);
                                }),
                    ),
                  ]),
                ),
                SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 150,
                  child: Row(children: [
                    Expanded(
                      child: btnStyle(
                          localizedStrings.gBtnTare,
                          startFormula
                              ? null
                              : () {
                                  // PublicFunctions.performTareWithScaleId(
                                  //     widget.selScaleId);
                                  tareByScaleId(myScale.scaleId);
                                }),
                    ),
                  ]),
                ),
              ]))
        ]));
  }

  Widget btnStyle(String title, VoidCallback? onPress) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        fixedSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
            side: BorderSide(
              color: startFormula
                  ? Theme.of(context).colorScheme.outline
                  : Theme.of(context).colorScheme.primary,
            )),
      ),
      onPressed: onPress,
      child: Text(
        title,
        style: showTextStyle(color: Theme.of(context).colorScheme.primary),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  //扣重归零等按钮
  Widget showTareZeroBtn() {
    return Container(
        height: 52,
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(children: [
          Expanded(
              flex: 1,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: 150,
                  child: Row(children: [
                    Expanded(
                      child: btnStyle(
                          localizedStrings.iBtnZero,
                          startFormula
                              ? null
                              : () {
                                  // PublicFunctions.performZeroWithScaleId(
                                  //     widget.selScaleId);
                                  zeroByScaleId(widget.selScaleId);
                                }),
                    ),
                  ]),
                ),
                SizedBox(
                  width: largePadding,
                ),
                SizedBox(
                  width: 150,
                  child: Row(children: [
                    Expanded(
                      child: btnStyle(
                          localizedStrings.gBtnTare,
                          startFormula
                              ? null
                              : () {
                                  // PublicFunctions.performTareWithScaleId(
                                  //     widget.selScaleId);
                                  tareByScaleId(widget.selScaleId);
                                }),
                    ),
                  ]),
                ),
              ]))
        ]));
  }

  //扣重归零等按钮
  showNextBtn() {
    return Container(
        height: 48,
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.only(right: largePadding * 2),
        child: Row(children: [
          Expanded(
              flex: 1,
              child: SizedBox(
                  child: Row(children: [
                Spacer(),
                SizedBox(
                  width: 200,
                  child: showTextButton(
                      context,
                      btnHeight,
                      localizedStrings.fNextStepBtn,
                      isEnableNext
                          ? () {
                              handleNexBtn();
                            }
                          : null,
                      Theme.of(context).colorScheme.onPrimary,
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.onPrimary),
                )
              ]))),
        ]));
  }

  showCompleteStatus() {
    //显示一张图片
    return Expanded(
        flex: 20,
        child: Container(
            color: Theme.of(context).colorScheme.surface,
            alignment: Alignment.center,
            child: Row(children: [
              Expanded(
                child: Container(
                    alignment: Alignment.center,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // SizedBox(
                          //   height: 20,
                          // ),
                          Container(
                              height: 150,
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                "assets/images/complete.png",
                                fit: BoxFit.cover,
                              )),
                          // SizedBox(
                          //   height: 14,
                          // ),
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              localizedStrings.fFormulaCompletedTip,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ])),
              )
            ])));
  }

  showTable() {
    return Expanded(
        flex: 3,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          // 获取表格的最大宽度
          double maxWidth = constraints.maxWidth;
          // 计算表格的实际宽度，减去左侧和右侧的边距
          double tableWidth = maxWidth - 40;
          double columnWidth = tableWidth / 8;
          return Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            color: Theme.of(context).colorScheme.surface,
            child: StickyTable(
              controller: _scrollController, // 传递 ScrollController
              // 修改 data 属性
              data: processWgtList.isEmpty
                  ? []
                  : sort
                      ? processWgtList.reversed.toList()
                      : processWgtList,
              defaultColumnWidth: const FixedColumnWidth(130),
              titleHeight: 48,
              cellHeight: 44,
              clickedRow: clickedRow,
              onRowClick: (row) {
                if (enableSelRaw) {
                  setState(() {
                    clickedRow = row;
                    selectedProcessWgt = processWgtList[row];
                  });
                }
              },

              cellDecoration: (context, column, data, row, columnIndex) {
                // 添加点击行背景色
                if (row == clickedRow) {
                  return BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    border: Border(
                      bottom: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1),
                    ),
                  );
                }
                return BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1),
                  ),
                );
              },
              columns: [
                StickyTableColumn(
                  localizedStrings.gTabOrder,
                  fixedStart: true,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onTitleClick: (context, title) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(const SnackBar(content: Text("排序")));
                    // setState(() {
                    //   sort = !(title.sort ?? false);
                    // });
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text((data as FormulaWgtProcessData).no.toString());
                  },
                  renderTitle: (context, title) {
                    return Text(
                      title.title,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 4, 68, 230)),
                    );
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fMaterialIdCol,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text("年龄$data")));
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text((data as FormulaWgtProcessData).rawId!);
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fMaterialNameCol,
                  columnWidth: FixedColumnWidth(columnWidth),
                  showSort: true,
                  sort: false,
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text("年龄$data")));
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text((data as FormulaWgtProcessData).rawName!);
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fTargetWeightLabel,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text("年龄$data")));
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text(
                        (data as FormulaWgtProcessData).targetWgt.toString());
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fCurrentWeightLabel,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text("年龄$data")));
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text(
                        (data as FormulaWgtProcessData).currentWgt.toString());
                  },
                ),
                StickyTableColumn(
                  "允许误差重量",
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text("年龄$data")));
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text(
                        (data as FormulaWgtProcessData).errorWgt.toString());
                  },
                ),
                StickyTableColumn(
                  "当前误差重量",
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text("年龄$data")));
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text((data as FormulaWgtProcessData)
                        .currentErrorWgt
                        .toString());
                  },
                ),
                StickyTableColumn(
                  "是否达标",
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {
                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text("年龄$data")));
                  },
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text(
                      (data as FormulaWgtProcessData).isOK! == "no"
                          ? "未完成"
                          : (data).isOK! == "ok"
                              ? "已达标"
                              : "未达标",
                      style: TextStyle(
                        color: (data).isOK! == "no"
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : (data).isOK! == "ok"
                                ? Theme.of(context)
                                    .colorScheme
                                    .onTertiaryFixedVariant
                                : Theme.of(context).colorScheme.error,
                      ),
                    );
                  },
                ),
                // StickyTableColumn(
                //   "补充",
                //   fixedEnd: true,
                //   columnWidth: const FixedColumnWidth(50),
                //   renderCell: (context, title, data, row, column) {
                //     return MaterialButton(
                //       onPressed: () {
                //         // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                //         // ScaffoldMessenger.of(
                //         //   context,
                //         // ).showSnackBar(SnackBar(
                //         //     content: Text(
                //         //         "删除${(data as FormulaInfoDb)..header!.formulaName!}成功")));
                //       },
                //       // color: Colors.red,
                //       minWidth: 0,
                //       child: Center(
                //           child: Icon(
                //         size: 20,
                //         Icons.add_comment_outlined,
                //         color: Theme.of(context).colorScheme.primary,
                //       )),
                //     );
                //   },
                // ),
              ],
            ),
          );
        }));
  }

  Widget showMetialName() {
    return SizedBox(
        height: 48,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(
              child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      selectedProcessWgt.no == 0
                          ? localizedStrings.fFmaContainer
                          : selectedProcessWgt.rawName ?? '',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  )))
        ]));
  }

  Widget showWgtDataAndBtn() {
    return Expanded(
      flex: 8,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(
              width: 314,
              child: Row(
                children: [
                  Container(
                    width: 314 - 50,
                    height: 48,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 8.0),
                    constraints: BoxConstraints(
                      minWidth: 314 - 50,
                      maxWidth: 314 - 50,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceDim,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft, // 保持文本左对齐
                      child: Text(
                        (myReqWeightCountine.msgBody == null)
                            ? '-----'
                            : myReqWeightCountine.msgBody!.weightVal,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 48,
                    color: Theme.of(context).colorScheme.surfaceDim,
                    alignment: Alignment.center,
                    child: Text(
                      (myReqWeightCountine.msgBody == null)
                          ? '--'
                          : myReqWeightCountine.msgBody!.weightUnit,
                      style: showTextStyle(),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: regularPadding,
            ),
            showTareZeroBtn()
          ],
        ),
      ),
    );
  }

  Widget showWgtTable() {
    return Expanded(
        flex: 13,
        child: Container(
          color: Theme.of(context).colorScheme.onPrimary,
          child: Column(children: [
            showMetialName(),
            Expanded(
                child: SizedBox(
              child: Row(children: [
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.only(
                      left: regularPadding, right: regularPadding),
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(children: [
                    if (startFormula)
                      Expanded(
                          flex: 1,
                          child: LayoutBuilder(builder: (BuildContext context,
                              BoxConstraints constraints) {
                            double heightLimit = constraints.maxHeight;
                            return SizedBox(
                                child: Column(children: [
                              if (heightLimit > 48)
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(localizedStrings
                                          .fRawMaterialWeightLabel),
                                    )),
                              Expanded(
                                flex: 1,
                                child: LayoutBuilder(
                                  builder: (BuildContext context,
                                      BoxConstraints constraints) {
                                    // 获取 Container 的最大宽度
                                    double maxWidth = constraints.maxWidth;
                                    double maxHeight = constraints.maxHeight;

                                    return Container(
                                      // 使用自定义进度条组件
                                      alignment: Alignment.centerLeft,
                                      child: CustomProgressBar(
                                        value: currentRawWgt < 0
                                            ? 0
                                            : currentRawWgt, // 传入当前值
                                        minValue: double.parse(
                                                    (selectedProcessWgt
                                                                .minWgt! -
                                                            selectedProcessWgt
                                                                .currentWgt!)
                                                        .toStringAsFixed(3)) <
                                                0
                                            ? 0.0
                                            : double.parse((selectedProcessWgt
                                                        .minWgt! -
                                                    selectedProcessWgt
                                                        .currentWgt!)
                                                .toStringAsFixed(3)), // 传入最小值

                                        maxValue: double.parse(
                                                    (selectedProcessWgt
                                                                .maxWgt! -
                                                            selectedProcessWgt
                                                                .currentWgt!)
                                                        .toStringAsFixed(3)) <
                                                0
                                            ? 0.0
                                            : double.parse((selectedProcessWgt
                                                        .maxWgt! -
                                                    selectedProcessWgt
                                                        .currentWgt!)
                                                .toStringAsFixed(3)), // 传入最大值
                                        targetValue: double.parse(
                                                    (selectedProcessWgt
                                                                .targetWgt! -
                                                            selectedProcessWgt
                                                                .currentWgt!)
                                                        .toStringAsFixed(3)) <
                                                0
                                            ? 0.0
                                            : double.parse((selectedProcessWgt
                                                        .targetWgt! -
                                                    selectedProcessWgt
                                                        .currentWgt!)
                                                .toStringAsFixed(3)), // 传入目标值
                                        maxWidth: maxWidth, // 传递最大宽度
                                        maxHeight: maxHeight, // 传递最大高度
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ]));
                          })),

                    startFormula ? showTareZero() : showTareZeroBtn(),

                    if (startFormula)
                      Expanded(
                          flex: 1,
                          child: LayoutBuilder(builder: (BuildContext context,
                              BoxConstraints constraints) {
                            double heightLimit = constraints.maxHeight;
                            return SizedBox(
                                child: Column(children: [
                              if (heightLimit > 48)
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(localizedStrings
                                          .fFormulaProgressLabel),
                                    )),
                              Expanded(
                                flex: 1,
                                child: LayoutBuilder(
                                  builder: (BuildContext context,
                                      BoxConstraints constraints) {
                                    // 获取 Container 的最大宽度
                                    double maxWidth = constraints.maxWidth;
                                    double maxHeight = constraints.maxHeight;

                                    return Container(
                                      // 使用自定义进度条组件
                                      alignment: Alignment.centerLeft,
                                      child: CustomFmaProgressBar(
                                        currentValue: getOKCount(), // 传入当前值
                                        max: processWgtList.isEmpty
                                            ? 1
                                            : processWgtList.length, // 传入最大值

                                        maxWidth: maxWidth, // 传递最大宽度
                                        maxHeight: maxHeight, // 传递最大高度
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ]));
                          })),

                    //重量表格 调试用，无须删除
                    // showTable(),
                    SizedBox(
                      height: 20,
                    )
                  ]),
                )),
                SizedBox(
                  width: 10,
                ),
              ]),
            )),
          ]),
        ));
  }

  showFCode() {
    String id = "";
    if (myFmaInfo.header == null || myFmaInfo.header!.formulaId == null) {
      id = "";
    } else {
      id = myFmaInfo.header!.formulaId!;
    }
    return Expanded(
      child: Text(
        id,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  showFName() {
    String name = "";
    if (myFmaInfo.header == null || myFmaInfo.header!.formulaName == null) {
      name = "";
    } else {
      name = myFmaInfo.header!.formulaName!;
    }
    return Expanded(
      child: Text(
        name,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  showFormulaName() {
    return Container(
      height: 28,
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.centerLeft,
      child: Row(children: [
        // 显示标签部分，设置固定宽度
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 0, // 最小宽度为 0
            maxWidth: 200, // 最大宽度为 200
          ),
          child: Text(
            localizedStrings.fFmaNameLabel + ": ",
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        // 显示编号内容部分，用 Expanded 约束宽度
        showFName()
      ]),
    );
  }
//显示总重和单位

  showTotalWgtAndUnit() {
    final header = myFmaInfo.header;
    final totalWeight = header?.totalWeight;
    final formulaUnit = header?.formulaUnit;

    final displayText = totalWeight != null && formulaUnit != null
        ? '$totalWeight  $formulaUnit'
        : '';

    return Expanded(
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  String checkIsOk(double currValue, double minValue, double maxValue) {
    //判断当前的值是否达标
    String isWgtOk = '';
    if (currValue >= minValue && currValue <= maxValue) {
      isWgtOk = "ok";
    } else if (currValue < minValue) {
      isWgtOk = "low";
    } else if (currValue > maxValue) {
      isWgtOk = "high";
    }
    return isWgtOk;
  }

  String checkValueIsOk() {
    //判断当前的值是否达标
    String isWgtOk = '';
    double minWgt = double.parse(selectedProcessWgt.minWgt!.toStringAsFixed(3));
    double maxWgt = double.parse(selectedProcessWgt.maxWgt!.toStringAsFixed(3));
    if (currentRawWgt + selectedProcessWgt.currentWgt! >= minWgt &&
        currentRawWgt + selectedProcessWgt.currentWgt! <= maxWgt) {
      isWgtOk = "ok";
    } else if (currentRawWgt + selectedProcessWgt.currentWgt! < minWgt) {
      isWgtOk = "low";
    } else if (currentRawWgt + selectedProcessWgt.currentWgt! > maxWgt) {
      isWgtOk = "high";
    }
    return isWgtOk;
  }

  showWgtData() {
    return Expanded(
      flex: 20,
      child: Column(children: [
        Container(
          height: 28,
          color: Theme.of(context).colorScheme.surface,
          alignment: Alignment.centerLeft,
          child: Row(children: [
            // 显示标签部分，设置固定宽度
            Expanded(
              child: Text(
                localizedStrings.fIngredientsDataLabel,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // 显示编号内容部分，用 Expanded 约束宽度
          ]),
        ),
        Expanded(
            child: SizedBox(
          child: Row(children: [
            Expanded(
                flex: 3,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  child: Column(children: [
                    Expanded(
                        flex: 3,
                        child: SizedBox(
                          child: Row(children: [
                            Expanded(
                                child: Container(
                              padding: const EdgeInsets.only(left: 8.0),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                selectedProcessWgt.rawName ?? "",
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )),
                          ]),
                        )),
                    Expanded(
                        flex: 4,
                        child: SizedBox(
                          child: Row(children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: const EdgeInsets.only(left: 8.0),
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft, // 保持文本左对齐
                                  child: Text(
                                    (myReqWeightCountine.msgBody == null)
                                        ? '-----'
                                        : currentRawWgt.toString(),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 48,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    fmaUnit,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )),
                          ]),
                        )),
                  ]),
                )),
            SizedBox(
              width: 14,
            ),
            Expanded(
                flex: 2,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  child: Column(children: [
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                          child: Row(children: [
                            Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    localizedStrings.fTargetWeightLabel,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )),
                          ]),
                        )),
                    Expanded(
                        flex: 2,
                        child: SizedBox(
                          child: Row(children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: const EdgeInsets.only(left: 8.0),
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft, // 保持文本左对齐
                                  child: Text(
                                    double.parse((selectedProcessWgt
                                                    .targetWgt! -
                                                selectedProcessWgt.currentWgt!)
                                            .toStringAsFixed(3))
                                        .toString(),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 48,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    fmaUnit,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )),
                          ]),
                        )),
                  ]),
                )),
            SizedBox(
              width: 14,
            ),
            Expanded(
                flex: 2,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  child: Column(children: [
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                          child: Row(children: [
                            Expanded(
                                child: Container(
                              padding: const EdgeInsets.only(left: 8.0),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                localizedStrings.fAllowableError,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )),
                          ]),
                        )),
                    Expanded(
                        flex: 2,
                        child: SizedBox(
                          child: Row(children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: const EdgeInsets.only(left: 8.0),
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft, // 保持文本左对齐
                                  child: Text(
                                    '$showErrorStr ${selectedProcessWgt.errorWgt}',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 48,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    fmaUnit,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )),
                          ]),
                        )),
                  ]),
                )),
            SizedBox(
              width: 14,
            ),
          ]),
        )),
      ]),
    );
  }

  TextStyle showTitleTextStyle({Color? color}) {
    return Theme.of(context).textTheme.bodyMedium!.apply(
          color: color ?? Theme.of(context).colorScheme.onSurface,
        );
  }

  TextStyle showTextStyle({Color? color}) {
    return Theme.of(context).textTheme.bodySmall!.apply(
          color: color ?? Theme.of(context).colorScheme.onSurface,
        );
  }

  Widget showFmaItem(String title, String content) {
    return Container(
      height: 42,
      alignment: Alignment.centerLeft,
      child: RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(children: [
            TextSpan(
                text: '$title: ',
                style: showTitleTextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            TextSpan(text: content, style: showTitleTextStyle()),
          ])),
    );
  }

  showFormulaInfo() {
    return Container(
        height: 126,
        padding: const EdgeInsets.only(
          left: regularPadding,
          right: regularPadding,
        ),
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  showFmaItem(localizedStrings.fOrderNo, recRecNumber),
                  showFmaItem(localizedStrings.fFmaNameLabel,
                      widget.selectFormula.header!.formulaName!),
                  showFmaItem(localizedStrings.fFmaIdLabel,
                      widget.selectFormula.header!.formulaId!),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                  top: regularPadding, bottom: regularPadding),
              width: largePadding,
              child: VerticalDivider(
                color: Theme.of(context).colorScheme.surfaceDim,
                thickness: 1,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.only(
                    left: regularPadding, right: regularPadding),
                child: Column(
                  children: [
                    Container(
                      height: 42,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizedStrings.fRemarkCol,
                        style: Theme.of(context).textTheme.labelMedium!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Expanded(
                        child: Container(
                      alignment: Alignment.topLeft,
                      child: SelectableText(
                        myFmaInfo.header == null ||
                                myFmaInfo.header!.remark == null
                            ? ""
                            : myFmaInfo.header!.remark!,
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ))
                  ],
                ),
              ),
            ),

            //显示重量
            // showWgtData(),
          ],
        ));
  }

  void handleNexBtn() {
    //判断为空
    if (myReqWeightCountine.msgBody == null) {
      showTipInfo(localizedStrings.fDeviceDisconnected, context);
      return;
    }
    //判断当前是否已经稳定
    if (myReqWeightCountine.msgBody!.isStable == false) {
      showTipInfo(localizedStrings.fStableOperationHint, context);
      return;
    }
    //判断是否已经开始,开始后就不能再归零扣重了
    if (!startFormula) {
      startFormula = true;
    }
    if (selectedProcessWgt.no == 0) {
      //如果是第一个原料，直接赋值，这个原料是容器，直接赋值，执行扣重
      selectedProcessWgt.currentWgt = currentRawWgt;
      selectedProcessWgt.isOK = okStr;
      // PublicFunctions.performTareWithScaleId(widget.selScaleId);
      tareByScaleId(widget.selScaleId);
      //然后去找下一个原料
      findNextRaw();
      return;
    }
    //判断是否合格
    String isWgtOk = checkValueIsOk();

    //不合格，重量轻了 轻了就不让往下走
    if (isWgtOk == 'low') {
      //锁定当前重量
      double currentTempWgtValue = currentRawWgt;
      // 提示太轻
      showDialog(
        context: context,
        barrierDismissible: false, // 点击对话框外部不关闭对话框
        builder: (BuildContext context) {
          return ShowLowWgtTipDialog(
            title: localizedStrings.fTipTitle,
            msg: localizedStrings.fCurrentMaterialWeightInvalidMsg,
          );
        },
      ).then((value) {
        if (value == 1) {
          //继续下一个配料，且记录本次配料
          setState(() {
            //清空所有称重数据

            performLowRow(currentTempWgtValue);
          });
        } else {
          return;
        }
      });
      return;
    } else if (isWgtOk == highStr) {
      //锁定当前重量
      double currentTempWgtValue = currentRawWgt;
      // 提示超重
      showDialog(
        context: context,
        barrierDismissible: false, // 点击对话框外部不关闭对话框
        builder: (BuildContext context) {
          return ShowHignWgtTipDialog(
            title: localizedStrings.fTipTitle,
            msg: localizedStrings.fCurrentMaterialOverweightMsg,
          );
        },
      ).then((value) {
        if (value == 1) {
          //放弃此次配料
          showDeleteDialog();
        } else if (value == 2) {
          //接受修正
          handleReviseWgt(currentTempWgtValue);
          // PublicFunctions.performTareWithScaleId(widget.selScaleId);
          tareByScaleId(widget.selScaleId);
          setState(() {});
        } else {
          return;
        }
      });
    } else {
      double currentTempWgtValue = currentRawWgt;
      handleOkStatus(isWgtOk, currentTempWgtValue);
    }
  }

  performLowRow(double currentTempWgtValue) {
    processWgtList[clickedRow].currentWgt =
        currentTempWgtValue + processWgtList[clickedRow].currentWgt!;
    processWgtList[clickedRow].currentWgt =
        double.parse(processWgtList[clickedRow].currentWgt!.toStringAsFixed(3));
    processWgtList[clickedRow].isOK = 'low';
    processWgtList[clickedRow].currentErrorWgt =
        (processWgtList[clickedRow].currentWgt! -
            processWgtList[clickedRow].targetWgt!);
    processWgtList[clickedRow].currentErrorWgt = double.parse(
        processWgtList[clickedRow].currentErrorWgt!.toStringAsFixed(3));
    // PublicFunctions.performTareWithScaleId(widget.selScaleId);
    tareByScaleId(widget.selScaleId);
    // 从当前行的下一行开始向后查找
    int nextIndex = -1;
    for (int i = clickedRow + 1; i < processWgtList.length; i++) {
      if (processWgtList[i].isOK != 'ok') {
        nextIndex = i;
        break;
      }
    }

    // 如果向后没找到，就从第一行开始查找
    if (nextIndex == -1) {
      for (int i = 0; i < processWgtList.length; i++) {
        if (processWgtList[i].isOK != 'ok') {
          nextIndex = i;
          break;
        }
      }
    }

    // 如果找到了合适的行，更新选中行和选中的原料重量项
    if (nextIndex != -1) {
      clickedRow = nextIndex;
      selectedProcessWgt = processWgtList[clickedRow];
    } else {
      // 若都没找到，回到第一行
      clickedRow = 0;
      selectedProcessWgt = processWgtList[0];
    }
    currentRawWgt = 0.0;
    startFormula = true;
  }

  //重新计算需要的重量
  recalculateWgtList(double lastNeedTotalWgt) {
    //根据模式计算需要的重量
    if (myFmaInfo.header == null || myFmaInfo.header!.formulaMode == null) {
      return;
    }
    String fmaMode = myFmaInfo.header!.formulaMode!;

    if (fmaMode == 'wgt') {
      //按重量
      for (var item in processWgtList) {
        //如果第一个是容器，就不用去计算
        if (item.no == 0) {
          continue;
        }
        item.targetWgt = needTotalWgt * item.targetWgt! / lastNeedTotalWgt;
        item.targetWgt = double.parse(item.targetWgt!.toStringAsFixed(3));
        item.minWgt = item.targetWgt! - item.errorWgt!;
        item.minWgt = double.parse(item.minWgt!.toStringAsFixed(3));
        item.maxWgt = item.targetWgt! + item.errorWgt!;
        item.maxWgt = double.parse(item.maxWgt!.toStringAsFixed(3));
        item.currentErrorWgt = item.currentWgt! - item.targetWgt!;
        item.currentErrorWgt =
            double.parse(item.currentErrorWgt!.toStringAsFixed(3));
        item.isOK = checkIsOk(item.currentWgt!, item.minWgt!, item.maxWgt!);
      }
    } else {
      //按百分比
      for (var item in processWgtList) {
        if (item.no == 0) {
          continue;
        }
        item.targetWgt = needTotalWgt * item.targetPct! / 100;
        item.targetWgt = double.parse(item.targetWgt!.toStringAsFixed(3));
        item.errorWgt = needTotalWgt * item.errorPct! / 100;
        item.errorWgt = double.parse(item.errorWgt!.toStringAsFixed(3));
        item.minWgt = item.targetWgt! - item.errorWgt!;
        item.minWgt = double.parse(item.minWgt!.toStringAsFixed(3));
        item.maxWgt = item.targetWgt! + item.errorWgt!;
        item.maxWgt = double.parse(item.maxWgt!.toStringAsFixed(3));
        item.currentErrorWgt = item.currentWgt! - item.targetWgt!;
        item.currentErrorWgt =
            double.parse(item.currentErrorWgt!.toStringAsFixed(3));
        item.isOK = checkIsOk(item.currentWgt!, item.minWgt!, item.maxWgt!);
      }
    }
  }

//查找下一个原料
  void findNextRaw() {
    //修改了此处

    //重头找第一个不合格的开始处理
    FormulaWgtProcessData nextItem;
    // 先查找 isOK 不为 'ok' 的项
    try {
      nextItem = processWgtList
          .firstWhere((item) => item.isOK != 'ok' && item.no != 0);
      selectedProcessWgt = nextItem; // 更新选中的原料重量项
      //如果有容器
      if (myFmaInfo.header != null && myFmaInfo.header!.needContainer!) {
        clickedRow = selectedProcessWgt.no!; // 更新点击的行索引
      } else {
        clickedRow = selectedProcessWgt.no! - 1; // 更新点击的行索引
      }

      // print(clickedRow);

      currentRawWgt = 0.000;
    } catch (e) {
      // 如果没有 isOK 不为 'ok' 的项，说明配方完成了
      setState(() {
        isEnableNext = false; // 禁用按钮
      });
      showTipInfo(localizedStrings.fFormulaCompletionMsg, context);
      return;
    }
  }

  //重量正常的时候，往下走，不从第一个开始
  void findOkNextRaw() {
    // 先查找 isOK 不为 'ok' 的项
    int nextIndex = -1;
    for (int i = clickedRow + 1; i < processWgtList.length; i++) {
      if (processWgtList[i].isOK != 'ok') {
        nextIndex = i;
        break;
      }
    }
    if (nextIndex == -1) {
      findNextRaw();
      return;
    }
    setState(() {
      clickedRow = nextIndex;

      selectedProcessWgt = processWgtList[clickedRow]; // 更新选中的原料重量项
      //如果有容器
      if (myFmaInfo.header != null && myFmaInfo.header!.needContainer!) {
        clickedRow = selectedProcessWgt.no!; // 更新点击的行索引
      } else {
        clickedRow = selectedProcessWgt.no! - 1; // 更新点击的行索引
      }
      currentRawWgt = 0.000;
    });
  }

  handleReviseWgt(double tmpCurrWgt) {
    //修正重量，将当前的原料重量赋值给目标重量
    if (processWgtList.isNotEmpty) {
      try {
        //先根据当前的重量计算出需要的总重量
        if (myFmaInfo.header != null &&
            myFmaInfo.header!.totalWeight != null &&
            selectedProcessWgt.targetWgt != null &&
            selectedProcessWgt.targetWgt! != 0) {
          double lastNeedTotalWgt = needTotalWgt;
          needTotalWgt = needTotalWgt *
              (tmpCurrWgt + selectedProcessWgt.currentWgt!) /
              selectedProcessWgt.targetWgt!;
          needTotalWgt = double.parse(needTotalWgt.toStringAsFixed(3));
          //赋值给当前的原料重量
          var targetItem = processWgtList
              .firstWhere((item) => item.no == selectedProcessWgt.no);
          targetItem.currentWgt = tmpCurrWgt + targetItem.currentWgt!;
          targetItem.currentWgt =
              double.parse(targetItem.currentWgt!.toStringAsFixed(3));

          //重新计算所有的数据
          recalculateWgtList(lastNeedTotalWgt);
          findNextRaw();
        } else {
          // 处理空值情况
          needTotalWgt = 0.0;
          showTipInfo(localizedStrings.tipFormulaDataError, context);
        }
      } catch (e) {
        return;
      }
    }
  }

  handleOkStatus(String isWgtOk, double currentRawWgt) {
    //将当前的原料重量赋值给目标重量
    if (processWgtList.isNotEmpty) {
      try {
        //重量模式
        var targetItem = processWgtList
            .firstWhere((item) => item.no == selectedProcessWgt.no);
        targetItem.currentWgt = currentRawWgt + selectedProcessWgt.currentWgt!;
        targetItem.isOK = isWgtOk;
        targetItem.currentErrorWgt =
            (targetItem.currentWgt! - selectedProcessWgt.targetWgt!);
        targetItem.currentErrorWgt =
            double.parse(targetItem.currentErrorWgt!.toStringAsFixed(3));
        //百分比模式算出百分比
        if (myFmaInfo.header!.formulaMode! == 'pct') {
          //计算误差的百分比
          if (needTotalWgt > 0) {
            targetItem.currentErrorPct =
                (targetItem.currentErrorWgt! / needTotalWgt) * 100;
            targetItem.currentErrorPct =
                double.parse(targetItem.currentErrorPct!.toStringAsFixed(3));
          }
        }
        // PublicFunctions.performTareWithScaleId(widget.selScaleId);
        tareByScaleId(widget.selScaleId);

        //查找下一个
        findOkNextRaw();

        // print(clickedRow);
      } catch (e) {
        // 处理未找到匹配项的情况
        // print('未找到匹配的原料重量项: $e');
      }
    }
  }

//单据编号
  showTitleBar() {
    return Container(
      height: 54,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
              child: Row(
            children: [
              SizedBox(
                width: largePadding,
              ),
              SizedBox(
                child: IconButton(
                    onPressed: () {
                      if (!startFormula) {
                        PublicFunctions.stopWeight(widget.selScaleId);
                        Navigator.pop(context);
                      } else {
                        performAbandonFma();
                      }
                    },
                    icon: getSvgIcon(returnSvgIcon(), 28, 28,
                        Theme.of(context).colorScheme.primary)),
              ),
              SizedBox(
                width: regularPadding,
              ),
              SizedBox(
                width: maxWidth,
                child: Text(
                  localizedStrings.titleConfidentialWeighingMode,
                  style: Theme.of(context).textTheme.labelMedium!.apply(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )),
          Text(
            localizedStrings.gTipAutoNextStep,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .apply(color: Theme.of(context).colorScheme.onSurface),
          ),
          SizedBox(
            width: regularPadding,
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  autoNextStep = !autoNextStep;
                  autoNextStepNotifier.value = autoNextStep;
                  if (autoNextStep) {
                    stableTimeCtl.text = stableTime.toString();
                  }
                });
                setAutoNext();
              },
              icon: Icon(
                autoNextStep
                    ? Icons.toggle_on_outlined
                    : Icons.toggle_off_outlined,
                color: autoNextStep
                    ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                    : Theme.of(context).colorScheme.onSurface,
              )),
          SizedBox(
            width: regularPadding,
          ),
          if (autoNextStep)
            Text(
              localizedStrings.gTipStableTime,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .apply(color: Theme.of(context).colorScheme.onSurface),
            ),
          if (autoNextStep)
            SizedBox(
              width: regularPadding,
            ),
          if (autoNextStep)
            SizedBox(
              width: 65,
              height: 35,
              child: DropdownButtonFormField<String>(
                borderRadius: BorderRadius.circular(0),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 5, horizontal: 10), // 调整垂直和水平内边距
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant, // 设置边框颜色
                          width: 1.0, // 设置边框宽度
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(0.0))),
                    border: OutlineInputBorder()),
                isExpanded: true,
                value: stableTimeCtl.text == "" ? null : stableTimeCtl.text,
                items: [
                  ...['1', '2', '5', '10'].map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    );
                  })
                ],
                onChanged: (value) {
                  setState(() {
                    stableTimeCtl.text = value!;
                    stableTime = int.tryParse(stableTimeCtl.text) ?? 1;
                  });
                  setAutoNext();
                },
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .apply(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          SizedBox(
            width: 20,
          )
        ],
      ),
    );
  }

  void setAutoNext() {
    ReqAutoNext reqAutoNext = ReqAutoNext(
      autoNext: autoNextStep,
      stableTime: stableTime,
      autoTare: true,
      checkCode: checkCode,
    );

    PublicFunctions.updateAutoNext(reqAutoNextToJson(reqAutoNext));
  }

  showAddFormulaIconBtn(String tip, IconData icon, Function() onPressed) {
    return Tooltip(
        message: tip, // 提示信息
        child: IconButton(
          iconSize: 24,
          color: Theme.of(context).colorScheme.onPrimary,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              // 设置为矩形形状
              borderRadius: BorderRadius.zero, // 没有圆角，即正方形
            ),
            fixedSize: const Size(40, 40), // 设置固定大小
          ),
          onPressed: onPressed,
          icon: Icon(icon),
        ));
  }

  showIconButton(String tip, IconData icon, Function() onPressed) {
    return Tooltip(
      message: tip, // 提示信息
      child: IconButton(
        iconSize: 24,
        color: Theme.of(context).colorScheme.onPrimary,
        focusColor: Theme.of(context).colorScheme.outline,
        hoverColor: Theme.of(context).colorScheme.outline,
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            // 设置为矩形形状
            borderRadius: BorderRadius.zero, // 没有圆角，即正方形
          ),
          fixedSize: const Size(40, 40), // 设置固定大小
        ),
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class HandlerClearButton extends StatelessWidget {
  const HandlerClearButton({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.clear,
        size: 20,
      ),
      onPressed: () => controller.clear(),
    );
  }
}
