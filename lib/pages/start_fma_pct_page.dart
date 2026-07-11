import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/f_raw_name.dart';
import 'package:t_max/data/fma_rec_list_db_data.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/formula_wgt_process_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/get_auto_next_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/readoutput.dart';
import 'package:t_max/data/req_add_fma_rec_data.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/s15_tare_zero.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/pages/edit_darft_fma_page.dart';
import 'package:t_max/pages/fma_report_print.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/fma_parameter_setting.dart';
import 'package:t_max/widget/fma_process_bar.dart';
import 'package:t_max/widget/sticky_table.dart';
import '../data/language.dart';

const _completeImagePath = "assets/images/complete.png";

class FormulaPctWeighingPage extends StatefulWidget {
  const FormulaPctWeighingPage(
      {super.key,
      required this.selectFormula,
      required this.selScaleId,
      required this.totalFmaWgt,
      required this.fmaUnit,
      required this.fromDarft //是否来自暂存的数据
      });
  final FormulaInfoDb selectFormula;
  final int selScaleId;
  final double totalFmaWgt;
  final String fmaUnit;
  final bool fromDarft; //是否来自暂存的数据

  @override
  State<FormulaPctWeighingPage> createState() => FormulaPctWeighingPageState();
}

class FormulaPctWeighingPageState extends State<FormulaPctWeighingPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController encryptedCtl = TextEditingController();
  final TextEditingController formulaTypeCtl = TextEditingController();
  final TextEditingController rawTypeCtl = TextEditingController();
  final TextEditingController stableTimeCtl = TextEditingController();

  FormulaWgtProcessData selectedProcessWgt = FormulaWgtProcessData(); //选中的原料重量
  List<FormulaWgtProcessData> processWgtList = []; //配方中的原料重量集合

  String totalUnit = 'g'; //总重量百分比模式传入的总重量单位
  String recRecNumber = ''; //配方订单编号
  String fmaUnit = 'g'; //配方重量单位

  bool sort = false;
  bool selectAll = false; // 添加全选状态
  bool isShowTipDialog = false; //是否显示提示对话框
  bool enableSelRaw = false; //是否启用选择原料  按顺序制作，需要添加补充的时候再去做选择物料
  bool autoTare = false; //是否开启自动扣重  归零和扣重不能使用
  bool isEnableNext = true; //是否禁用下一个
  bool isFinish = false; //是否完成
  bool autoNextStep = false;
  bool checkCodeflag = false; //是否开启校验码  开启后，需要扫描或者输入校验码才能继续
  bool checkCodeOk = true; //当前校验码是否正确
  bool checkCodeDialogShowing = false;
  bool isPrint = false; //是否打印配方
  bool openIoPortFlag = false; //是否打开输出端口 开启后才能自动送出原料开启仓门

  CurrentPortSetting currentPortSetting = CurrentPortSetting(
      isEnable: false,
      isOpen: false,
      portNo: 0,
      triggerValue: 0.0,
      delayedTime: 0); //当前的输出端口设置

  double initTotalWeight = 1000.0; //总重量百分比模式传入的总重量
  double currentRawWgt = 0.000; //当前的原料重量 默认为0
  double needTotalWgt = 0.000; //需要的总重量 默认为0  这个主要是修正后的重量

  FormulaInfoDb myFmaInfo = FormulaInfoDb(); //当前配方信息

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
  dynamic _eventbus13;

  Timer? setWgtStartFalseTimer; // 用于每3秒将isWgtStart设置为false的定时器
  Timer? checkWgtStartTimer; // 用于每5秒检查isWgtStart的定时器
  Timer? autoNextStepTimer;
  Timer? _cntAliveTimer;

  late Scale myScale;

  int clickedRow = 0; // 添加点击行状态
  int currentScaleId = 0; //当前选择的秤ID
  int stableDurationCounter = 0; // 稳定时长计数器
  int stableTime = 0;

  Map<int, bool> scaleMap = {}; //scaleId , isWgtStart
  Map<String, int> rawScaleMap = {}; //原料名称，秤ID

  final ValueNotifier<bool> autoNextStepNotifier = ValueNotifier(false);
  final ValueNotifier<String> currentWgtStrNotifier = ValueNotifier('----');

  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;

  List<RespOutputInfo> outputPortStatusList = [];
  List<RawOutputInfo> rawOutputInfoList = []; // 原料重量信息列表
  List<InputInfo> inputPortStatusList = []; // 输入端口状态列表

  // 启动发送存活消息的定时器
  void startCntAliveTimer(int time) {
    _cntAliveTimer?.cancel();

    _cntAliveTimer = Timer(Duration(seconds: time), () {
      for (var key in scaleMap.keys) {
        PublicFunctions.sendScaleAlive(key);
      }

      startCntAliveTimer(10);
    });
  }

  // 停止发送存活消息的定时器
  void stopCntAliveTimer() {
    _cntAliveTimer?.cancel();
  }

  // 每5秒钟将isWgtStart设置为false
  void startSetWgtStartFalseTimer() {
    setWgtStartFalseTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          for (var key in scaleMap.keys) {
            scaleMap[key] = false;
          }
        });
      }
    });
  }

  // 每5秒判断一下isWgtStart是不是false，是false的话，就重新发送请求开启连续发送
  void startCheckWgtStartTimer() {
    checkWgtStartTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      for (var key in scaleMap.keys) {
        if (scaleMap[key] == false) {
          PublicFunctions.getWeight(key);
        }
      }
    });
  }

  // 启动自动下一步定时器
  void startAutoNextStepTimer() {
    autoNextStepTimer =
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (myReqWeightCountine.msgBody == null) {
        stableDurationCounter = 0;
      } else if (!(myReqWeightCountine.msgBody?.isStable ?? false)) {
        stableDurationCounter = 0;
      } else if (myReqWeightCountine.msgBody != null &&
          myReqWeightCountine.msgBody!.isStable &&
          isEnableNext &&
          scaleMap[myScale.scaleId]! &&
          checkValueIsOk() == 'ok') {
        stableDurationCounter++;
        if (stableDurationCounter >= stableTime * 20) {
          if (checkCodeflag && !checkCodeOk) {
            return;
          }
          final isOk = checkValueIsOk();
          if (isOk == "ok") {
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

  /// 配方单步称算流转核心逻辑。
  /// 当前配料（或容器）重量被计算并在设定的误差率容差范围 [errorWgt] 达标后，切换游标推进到对下一步（下一种原料）的处理。
  void nextStep(String isWgtOk) {
    double currentTempWgtValue = currentRawWgt;
    handleOkStatus(isWgtOk, currentTempWgtValue);
  }

  void _switchScaleByRawId(String rawId) {
    int targetScaleId = widget.selScaleId; // 默认使用选中的秤

    if (rawId == '-') {
      targetScaleId = widget.selScaleId;
    } else {
      targetScaleId = rawScaleMap[rawId] ?? widget.selScaleId;
    }

    for (var scale in myAllScalesList) {
      if (scale.scaleId == targetScaleId) {
        myScale = scale;
        break;
      }
    }
  }

  //初始化秤的列表
  void initScaleMap() {
    if ((myFmaInfo.header?.needContainer ?? false)) {
      scaleMap[widget.selScaleId] = false;
    }
    for (var detail in myFmaInfo.details!) {
      String materialId = detail.materialId!;

      // 如果已经处理过该原料，跳过
      if (rawScaleMap.containsKey(materialId)) {
        continue;
      }

      int scaleId = findScaleIdFromRaw(materialId);

      if (scaleId != 0) {
        // 找到特定秤
        rawScaleMap[materialId] = scaleId;
        if (!scaleMap.containsKey(scaleId)) {
          scaleMap[scaleId] = false;
        }
      } else {
        // 使用默认秤
        rawScaleMap[materialId] = widget.selScaleId;
        if (!scaleMap.containsKey(widget.selScaleId)) {
          scaleMap[widget.selScaleId] = false;
        }
      }
    }
  }

  int findScaleIdFromRaw(String materialId) {
    for (var raw in rawDataList) {
      if (raw.materialId == materialId) {
        return raw.scaleId ?? 0;
      }
    }
    return 0;
  }

  /// 初始化容积及百分比 (Percentage) 计算基准。
  /// 必须根据实际作业中的总预期生产重量 [initTotalWeight] 来实时推算每一种辅料实际需要分配的靶向重量。
  void initTotalWgtUnit() {
    if ((myFmaInfo.header?.formulaMode ?? '') == 'pct') {
      initTotalWeight = widget.totalFmaWgt;
      initTotalWeight = double.parse(initTotalWeight.toStringAsFixed(3));
      myFmaInfo.header?.formulaUnit = widget.fmaUnit;
      myFmaInfo.header?.totalWeight = initTotalWeight;
      needTotalWgt = initTotalWeight;
    }
  }

  void initWgtList() {
    double minValue = 0.0;
    double maxValue = 0.0;
    double errorWgt = 0.0; //误差重量值
    double targetWgt = 0.0; //目标重量值
    String fmode = (myFmaInfo.header?.formulaMode ?? '');
    needTotalWgt = (myFmaInfo.header?.totalWeight ?? 0.0);
    //如果包含容器，第一个写容器  修改了此处
    if ((myFmaInfo.header?.needContainer ?? false)) {
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
          checkCode: '');
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
      String rawCheckCode = getRawCheckCode(detail.materialId!);
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
        checkCode: rawCheckCode,
      );
      processWgtList.add(processWgt);
    }
    if (processWgtList.isNotEmpty) {
      selectedProcessWgt = processWgtList[0]; //默认选中第一个原料重量
      _switchScaleByRawId(selectedProcessWgt.rawId!);
    }
  }

  void getScaleInfo() {
    for (var key in scaleMap.keys) {
      PublicFunctions.getWeight(key);
    }
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

  @override
  void initState() {
    super.initState();
    PublicFunctions.getOutputPortStatus();
    PublicFunctions.getScaleInputSetting();

    GetRawOutputByFmaId getRawOutputByFmaId = GetRawOutputByFmaId(
      formulaId: (widget.selectFormula.header?.formulaId ?? ''),
    );
    PublicFunctions.getRawOutputByFmaId(jsonEncode(getRawOutputByFmaId));

    _initBusinessData();
    _initTimers();
    _initAutoNextListener();
    _initEventBusSubscriptions();
  }

  /// 初始化定时器
  void _initTimers() {
    startSetWgtStartFalseTimer();
    startCheckWgtStartTimer();
    startCntAliveTimer(10);
    PublicFunctions.getAutoNext(); // 获取自动下一步配置
  }

  /// 初始化自动下一步监听
  void _initAutoNextListener() {
    //自动启停定时器
    autoNextStepNotifier.addListener(() {
      if (autoNextStepNotifier.value) {
        startAutoNextStepTimer();
      } else {
        stopAutoNextStepTimer();
      }
    });
  }

  /// 初始化业务基础数据
  void _initBusinessData() {
    myFmaInfo = widget.selectFormula; //将传入的配方信息赋值给myFmaInfo
    fmaUnit = widget.fmaUnit; //将传入的配方单位赋值给fmaUnit

    initScaleMap();
    initTotalWgtUnit();
    initWgtList();
    getScaleInfo();
    createRecNumber();
  }

// 初始化事件总线监听
  void _initEventBusSubscriptions() {
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

    _eventbus4 = eventBus.on<EventRespGetFmaData>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            //查找当前配方，重新计算配方重量
            List<FormulaInfoDb> tempFmaData = formulaInfoDbFromJson(dataStr);

            for (var formula in tempFmaData) {
              if ((formula.header?.formulaId ?? '') ==
                  (myFmaInfo.header?.formulaId ?? '')) {
                myFmaInfo = formula;
                //不能清空，要记录下来当前的重量，重新去计算
                List<FormulaWgtProcessData> oldProcessWgtList =
                    List.from(processWgtList);
                processWgtList.clear(); //清空原有的配方重量列表
                initTotalWgtUnit();
                initWgtList();

                initOldFmaData(oldProcessWgtList);
                break;
              }
            }
          });
        }
      }
    });

    _eventbus5 = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        setState(() {
          ReqWeightCountine tempWeight = ReqWeightCountine();
          tempWeight = event.obj;
          _handleWeightUpdate(tempWeight);
        });
      }
    });

    _eventbus6 = eventBus.on<EventRespGetAutoNext>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            GetAutoNextFormDb getInfoFormDb =
                getAutoNextFormDbFromJson(dataStr);
            autoNextStep = getInfoFormDb.autoNext;
            autoNextStepNotifier.value = autoNextStep;
            stableTime = getInfoFormDb.stableTime;
            stableTimeCtl.text = stableTime.toString();
            autoTare = getInfoFormDb.autoTare;
            checkCodeflag = getInfoFormDb.checkCode;
            if (checkCodeflag) {
              showCheckCodeDialog();
            }
          });
        } else {
          setState(() {
            autoNextStepNotifier.value = false;
          });
        }
      }
    });

    _eventbus7 = eventBus.on<EventRespFormulaRecByOrder>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'fail') {
          setState(() {
            dynamic jsonData = json.decode(dataStr);
            FmaRecFromDb reportData = FmaRecFromDb.fromJson(jsonData);
            // print(reportData.header!.actualFmaTotalWgt);
            if (isPrint) {
              isPrint = false;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return FormulaReportPrint(
                    fmaData: reportData,
                  );
                },
              );
            }
          });
        }
      }
    });
    _eventbus8 = eventBus.on<EventRespGetOutputPortStatus>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          try {
            outputPortStatusList = respOutputInfoFromJson(dataStr);

            setState(() {});
          } catch (e) {
            setState(() {});
          }
        } else {
          setState(() {});
        }
      }
    });

    _eventbus9 = eventBus.on<EventRespRawOutputByFmaId>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && !dataStr.contains("fail")) {
          try {
            List<RawOutputInfo> tempList = rawOutputInfoFromJson(dataStr);

            setState(() {
              rawOutputInfoList = tempList;
            });
          } catch (e) {
            setState(() {});
          }
        } else {
          setState(() {});
        }
      }
    });

    _eventbus10 = eventBus.on<EventRespOpenOutputPort>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr.contains("fail")) {
          showTipInfo(localizedStrings.openOutputPortFailed, context);
        }
      }
    });

    _eventbus11 = eventBus.on<EventRespScaleInput>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          //处理按键事件
          handleInputPortStatus(dataStr);
        }
      }
    });

    _eventbus12 = eventBus.on<EventRespGetOutputPortStatus>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          try {
            outputPortStatusList = respOutputInfoFromJson(dataStr);

            setState(() {});
          } catch (e) {
            setState(() {});
          }
        } else {
          setState(() {});
        }
      }
    });

    _eventbus13 = eventBus.on<EventRespGetInputPortStatus>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          try {
            List<InputInfo> tempList = inputInfoFromJson(dataStr);
            inputPortStatusList = tempList;

            setState(() {});
          } catch (e) {
            setState(() {});
          }
        } else {
          setState(() {});
        }
      }
    });
  }

  void handleInputPortStatus(String dataStr) {
    if (inputPortStatusList.isEmpty) {
      return;
    }

    for (var port in inputPortStatusList) {
      if (port.port.toString() == dataStr) {
        handleInputBtn(port.btn ?? '');
        break;
      }
    }
  }

  void handleInputBtn(String btn) {
    if (btn == 'None') {
      return;
    }
    if (btn == 'Tare') {
      // PublicFunctions.performTareWithScaleId(myScale.scaleId);
      tareByScaleId(myScale.scaleId);
    } else if (btn == 'Zero') {
      // PublicFunctions.performZeroWithScaleId(myScale.scaleId);
      zeroByScaleId(myScale.scaleId);
    } else if (btn == 'Pause') {
      if (!openIoPortFlag) {
        return;
      }
      handleCloseIoPort();
      setState(() {
        openIoPortFlag = false;
      });
    } else if (btn == 'Start') {
      if (openIoPortFlag) {
        return;
      }
      setState(() {
        openIoPortFlag = true;
      });
      handleIoPortStatus();
    }
  }

  /// 销毁EventBus订阅
  void _disposeEventBusSubscriptions() {
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
    _eventbus13.cancel();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    encryptedCtl.dispose();
    formulaTypeCtl.dispose();
    rawTypeCtl.dispose();
    autoNextStepTimer?.cancel();
    _cntAliveTimer?.cancel();
    _eventbus1?.cancel();
    _eventbus2?.cancel();
    _eventbus3?.cancel();
    _eventbus4?.cancel();
    _eventbus5?.cancel();
    _eventbus6?.cancel();
    _eventbus7?.cancel();
    _eventbus8?.cancel();
    _eventbus9?.cancel();
    _eventbus10?.cancel();
    _eventbus11?.cancel();
    _eventbus12?.cancel();
    _eventbus13?.cancel();
    super.dispose();
    _disposeEventBusSubscriptions();
    stopCntAliveTimer();
    currentWgtStrNotifier.dispose();
    setWgtStartFalseTimer?.cancel(); // 取消定时器
    checkWgtStartTimer?.cancel(); // 取消定时器
    stopAutoNextStepTimer();

    autoNextStepNotifier.dispose();
    stableTimeCtl.dispose();
  }

  // 如果是暂存的配方数据，则需要将暂存的数据赋值给processWgtList
  void initOldFmaData(List<FormulaWgtProcessData> oldProcessWgtList) {
    double lastNeedTotalWgt = needTotalWgt; // 保存上一次的总重量
    if (oldProcessWgtList.isEmpty) {
      return; // 如果没有暂存数据，则不进行赋值
    }

    //循环查找oldProcessWgtList中的数据，查看当前的重量是否大于0，
    bool isStart = false; // 判断曾经是否开始配方
    for (var detail in oldProcessWgtList) {
      if (detail.currentWgt != null && detail.currentWgt! > 0) {
        isStart = true;
        break;
      }
    }
    if (!isStart) {
      return; // 如果没有找到大于0的重量，则不进行赋值
    }

    for (var detail in oldProcessWgtList) {
      if (detail.no == 0) {
        processWgtList[0].currentWgt =
            double.parse((detail.currentWgt ?? 0.0).toStringAsFixed(3));
        continue; // 跳过容器
      } else {
        //找出seq 值一样的再赋值
        for (var wgt in processWgtList) {
          if (wgt.no == detail.no) {
            wgt.currentWgt =
                double.parse((detail.currentWgt ?? 0.0).toStringAsFixed(3));
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

      if ((widget.selectFormula.header?.formulaMode ?? '') == 'pct') {
        for (var item in processWgtList) {
          if (item.no == 0) {
            continue;
          }
          item.targetWgt = needTotalWgt * item.targetPct! / 100;
          item.targetWgt =
              (double.tryParse(item.targetWgt?.toStringAsFixed(3) ?? '') ??
                  0.0);
          item.errorWgt = needTotalWgt * item.errorPct! / 100;
          item.errorWgt =
              (double.tryParse(item.errorWgt?.toStringAsFixed(3) ?? '') ?? 0.0);
          item.minWgt = item.targetWgt! - item.errorWgt!;
          item.minWgt =
              (double.tryParse(item.minWgt?.toStringAsFixed(3) ?? '') ?? 0.0);
          item.maxWgt = item.targetWgt! + item.errorWgt!;
          item.maxWgt =
              (double.tryParse(item.maxWgt?.toStringAsFixed(3) ?? '') ?? 0.0);
          item.currentErrorWgt = item.currentWgt! - item.targetWgt!;
          item.currentErrorWgt = (double.tryParse(
                  item.currentErrorWgt?.toStringAsFixed(3) ?? '') ??
              0.0);
          item.isOK = checkIsOk(item.currentWgt!, item.minWgt!, item.maxWgt!);
        }
      } else {
        for (var item in processWgtList) {
          //如果第一个是容器，就不用去计算
          if (item.no == 0) {
            continue;
          }
          item.targetWgt = needTotalWgt * item.targetWgt! / lastNeedTotalWgt;
          item.targetWgt =
              (double.tryParse(item.targetWgt?.toStringAsFixed(3) ?? '') ??
                  0.0);
          item.minWgt = item.targetWgt! - item.errorWgt!;
          item.minWgt =
              (double.tryParse(item.minWgt?.toStringAsFixed(3) ?? '') ?? 0.0);
          item.maxWgt = item.targetWgt! + item.errorWgt!;
          item.maxWgt =
              (double.tryParse(item.maxWgt?.toStringAsFixed(3) ?? '') ?? 0.0);
          item.currentErrorWgt = item.currentWgt! - item.targetWgt!;
          item.currentErrorWgt = (double.tryParse(
                  item.currentErrorWgt?.toStringAsFixed(3) ?? '') ??
              0.0);
          item.isOK = checkIsOk(item.currentWgt!, item.minWgt!, item.maxWgt!);
        }
      }
    }
    findNextRaw();
  }

  //处理和更新重量

  void _handleWeightUpdate(ReqWeightCountine tempWeight) {
    if (scaleMap.containsKey(tempWeight.scaleId)) {
      scaleMap[tempWeight.scaleId!] = true;
    }
    if (tempWeight.scaleId == myScale.scaleId) {
      myReqWeightCountine = tempWeight;
      _checkUnitConsistency();
      if (myReqWeightCountine.msgBody != null) {
        try {
          currentWgtStrNotifier.value =
              (myReqWeightCountine.msgBody?.weightVal ?? ''); // 更新当前重量
          currentRawWgt =
              (double.tryParse(myReqWeightCountine.msgBody?.weightVal ?? '') ??
                  0.0);
          currentRawWgt = double.parse(currentRawWgt.toStringAsFixed(3));
          if (!(myReqWeightCountine.msgBody?.isStable ?? false)) {
            stableDurationCounter = 0;
          }
        } catch (e) {
          currentRawWgt = 0.0;
        }
        handleStopIoPort();
      }
    }
  }

  /// 检查单位一致性（不一致则显示提示）
  void _checkUnitConsistency() {
    if ((myReqWeightCountine.msgBody?.weightUnit ?? '') !=
            (myFmaInfo.header?.formulaUnit ?? '') &&
        isShowTipDialog == false) {
      isShowTipDialog = true;
      _showUnitMismatchTip();
    }
  }

  // 提示切换单位对话框
  void _showUnitMismatchTip() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return ShowUnitTipDialog(
          title: localizedStrings.fTipTitle,
          msg:
              '${localizedStrings.fWgtUnit} ${(myFmaInfo.header?.formulaUnit ?? '')}, ${localizedStrings.fSwitchUnitHint}',
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

  void restartWgt() {
    setState(() {
      //清空所有称重数据
      processWgtList.clear();
      currentRawWgt = 0.0;
      clickedRow = 0;
      isEnableNext = true;

      initWgtList();
    });
    if (checkCodeflag) {
      showCheckCodeDialog();
    } else {
      handleIoPortStatus();
    }
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
        restartWgt();
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
      formulaId: (myFmaInfo.header?.formulaId ?? ''), //配方ID
      formulaTypeName: (myFmaInfo.header?.formulaName ?? ''), //配方名称
      totalWeight: (myFmaInfo.header?.totalWeight ?? 0.0), //总重量
      actualFmaTotalWgt: needTotalWgt, //实际配方总重量包括修正的重量
      actualTotalWeight: actualTotalRawWgt, //实际原料总重量
      totalWeightUnit: (myFmaInfo.header?.formulaUnit ?? ''), //总重量单位

      totalMaterialWeightUnit: (myFmaInfo.header?.formulaUnit ?? ''), //总原料重量单位
      isQualified: isAllOK ? 'yes' : 'no', //是否合格
      scaleId: 0, //秤ID // 明细中包含了秤的信息，表头就不要了
      scaleName: "", //秤名称
      scaleModel: "", //秤型号
      scaleSn: "", //秤SN
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
        scaleId: wgtRec.scaleId, //秤ID
        scaleName: wgtRec.scaleName, //秤名称
        scaleModel: wgtRec.scaleModel, //秤型号
        scaleSn: wgtRec.scaleSn, //秤SN
      );
      reqRecDetailList.add(recDetail);
    }

    ReqAddFmaRec reqAddFmaRec =
        ReqAddFmaRec(recHeader: recHeader, recDetail: reqRecDetailList); //配方

    PublicFunctions.addFormulaRec(reqAddFmaRecToJson(reqAddFmaRec));

    setState(() {
      // isFinish = true;
      isEnableNext = false;
    });
  }

  bool getCanSaveFlag() {
    bool hasRawWeight = false;
    for (var wgtRec in processWgtList) {
      if (wgtRec.no != 0 && wgtRec.currentWgt! > 0) {
        hasRawWeight = true;
        break;
      }
    }
    return hasRawWeight;
  }

  void performDarfFmaSave() {
    //先判断出了容器之外有没有原料重量，如果没有原料重量，就不需要暂存
    bool hasRawWeight = getCanSaveFlag();

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
          remark2: '',
          scaleId: wgtRec.scaleId,
          scaleName: wgtRec.scaleName,
          scaleModel: wgtRec.scaleModel,
          scaleSn: wgtRec.scaleSn,
        );
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
        remark2: '',
        scaleId: wgtRec.scaleId,
        scaleName: wgtRec.scaleName,
        scaleModel: wgtRec.scaleModel,
        scaleSn: wgtRec.scaleSn,
      );
      tempDetails.add(detail);
    }

    DarfHeader header = DarfHeader(
      recId: 0,
      orderId: recRecNumber, //配方订单编号
      createdBy: mySysUser.nickName!, //操作员
      formulaId: (myFmaInfo.header?.formulaId ?? ''), //配方ID

      status: 0,
      remark: '',
      remark1: '',
      remark2: '', //备注
    );

    tempDarfFmaInfo.header = header;
    tempDarfFmaInfo.details = tempDetails;

    String jsonStr = darfFmaInfoFromDbToJson(tempDarfFmaInfo);

    PublicFunctions.createDraftRecord(jsonStr);
    stopAllWgt();
    darfFmaInfoList = [];
    PublicFunctions.getDraftRecords();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  //自动保存配方
  void saveFormula() {
    bool isAllOK = checkAllOK();
    if (!isAllOK) {
      return;
    }
    saveFmaRec(isAllOK);
  }

//完成称重
  void performFinishBtn() {
    stopAllWgt();
    Navigator.pop(context);
  }

  //打印配方
  void performPrintBtn() {
    isPrint = true;
    PublicFunctions.getFmaByOrderId(recRecNumber);
  }

  //重新称重
  void performReWgtBtn() {
    restartWgt();
    createRecNumber();
  }

  void stopAllWgt() {
    for (var key in scaleMap.keys) {
      PublicFunctions.stopWeight(key);
    }
  }

  void performAbandonBtn() {
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
            stopAllWgt();
            closeIoPort();
            Navigator.pop(context);
          });
        } else {
          if (checkCodeflag && !checkCodeOk) {
            showCheckCodeDialog();
          }
        }
      });
    } else {
      stopAllWgt();
      Navigator.pop(context);
    }
  }

  final double maxWidth = 360; //最大宽度
  Widget showBottomBtn() {
    return Container(
        height: 76,
        color: colorScheme.surface,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (checkAllOK())
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.fCompleteIngredientsBtn,
                  !isFinish
                      ? () {
                          performFinishBtn();
                        }
                      : null,
                  colorScheme.onPrimary,
                  colorScheme.primary,
                  colorScheme.onPrimary),
            ),
          if (checkAllOK()) SizedBox(width: regularPadding),
          if (checkAllOK())
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.fPrintFmaBtn,
                  !isFinish
                      ? () {
                          performPrintBtn();
                        }
                      : null,
                  colorScheme.onPrimary,
                  colorScheme.primary,
                  colorScheme.onPrimary),
            ),
          if (checkAllOK()) SizedBox(width: regularPadding),
          if (checkAllOK())
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.fRepeatWeighingBtn,
                  !isFinish
                      ? () {
                          performReWgtBtn();
                        }
                      : null,
                  colorScheme.onPrimary,
                  colorScheme.primary,
                  colorScheme.onPrimary),
            ),
          if (!checkAllOK()) SizedBox(width: regularPadding),
          if (!checkAllOK())
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.btnTemporarySave,
                  !isEnableNext
                      ? null
                      : () {
                          performDarfFmaSave();
                        },
                  colorScheme.onPrimary,
                  colorScheme.primary,
                  colorScheme.onPrimary),
            ),
          if (!checkAllOK()) SizedBox(width: regularPadding),
          if (!checkAllOK())
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.fAbandonIngredientsBtn,
                  !isFinish
                      ? () {
                          performAbandonBtn();
                        }
                      : null,
                  colorScheme.onPrimary,
                  colorScheme.error,
                  colorScheme.onPrimary),
            ),
          if (!checkAllOK()) SizedBox(width: regularPadding),
          if (!checkAllOK())
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.btnRestart,
                  !isFinish
                      ? () {
                          showDeleteDialog();
                        }
                      : null,
                  colorScheme.onPrimary,
                  colorScheme.error,
                  colorScheme.onPrimary),
            ),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
      color: colorScheme.surface, //对接时修改颜色值
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                showTitleBar(),
                Divider(
                  color: colorScheme.outline,
                  thickness: 1,
                  height: 1,
                ),
                showFormulaInfoAndWgt(),
                Divider(
                  color: colorScheme.outline,
                  thickness: 1,
                  height: 1,
                ),
                Container(
                    height: 42,
                    color: colorScheme.surface,
                    child: Row(children: [
                      SizedBox(
                        width: 17,
                      ),
                      Expanded(
                        child: Text(
                          localizedStrings.fIngredientsRecordTitle,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .apply(color: colorScheme.onSurface),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 300, // 最大宽度限制为300
                        ),
                        child: IntrinsicWidth(
                          child: TextButton(
                              onPressed: !isEnableNext
                                  ? null
                                  : () {
                                      // showDeleteTipDialog();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditDarftFmaPage(
                                                    editFormulaInfo: myFmaInfo,
                                                  ))).then((value) {
                                        setState(() {});
                                      });
                                    },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Text(
                                      localizedStrings.fEditFmaBtn,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .apply(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: smallPadding),
                                  Icon(
                                    Icons.mode_edit_outlined,
                                    color: colorScheme.primary,
                                  ),
                                ],
                              )),
                        ),
                      ),
                      SizedBox(width: regularPadding),
                    ])),
                showWgtTable(),
                Container(
                  height: 14,
                  color: colorScheme.surface,
                ),
                showBottomBtn(),
              ],
            ),
          ),
        ],
        // ),
      ),
    ));
  }

  Widget showRawWgtAndUnit(int index, Color? textColor) {
    // ... existing code ...
    final formulaHeader = myFmaInfo.header;
    final formulaDetail = myFmaInfo.details?[index];

    if (formulaHeader != null && formulaDetail != null) {
      final weight = formulaDetail.materialWeight;
      final unit = formulaHeader.formulaMode == "pct"
          ? pctStrShow
          : formulaHeader.formulaUnit;
      final displayText = '$weight $unit';

      return Text(
        displayText,
        style: getTextStyle(color: textColor),
        overflow: TextOverflow.ellipsis,
      );
    } else {
      // 处理数据为空的情况
      return Text(
        '-',
        style: getTextStyle(color: textColor),
        overflow: TextOverflow.ellipsis,
      );
    }
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

  showWgtTable() {
    return Expanded(
        flex: 10,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          // 获取表格的最大宽度
          double maxWidth = constraints.maxWidth;
          // 计算表格的实际宽度，减去左侧和右侧的边距
          int columnCount = 7; // 列数
          if ((myFmaInfo.header?.formulaMode ?? '') == "pct") {
            columnCount = 8;
          }
          double tableWidth = maxWidth - 45 - 80;
          //80 序号
          double columnWidth = tableWidth / columnCount;
          return Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            color: colorScheme.surface,
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
                    _switchScaleByRawId(selectedProcessWgt.rawId!);
                  });
                }
              },
              titleDecoration: BoxDecoration(
                color: colorScheme.surfaceDim,
                border: Border(
                  bottom:
                      BorderSide(color: colorScheme.outlineVariant, width: 1),
                ),
              ),

              cellDecoration: (context, column, data, row, columnIndex) {
                // 添加点击行背景色
                if (row == clickedRow) {
                  return BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    border: Border(
                      bottom: BorderSide(color: colorScheme.primary, width: 1),
                    ),
                  );
                }
                return BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    bottom:
                        BorderSide(color: colorScheme.outlineVariant, width: 1),
                  ),
                );
              },
              columns: [
                StickyTableColumn(
                  localizedStrings.fIngredientOrder,
                  fixedStart: true,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(80),
                  alignment: Alignment.centerLeft,
                  onTitleClick: (context, title) {},
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text(
                      (data as FormulaWgtProcessData).no.toString(),
                      style: getTextStyle(),
                    );
                  },
                  renderTitle: (context, title) {
                    return SizedBox(
                      width: 80 - 20,
                      child: Text(
                        title.title,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle(),
                      ),
                    );
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fMaterialIdCol,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {},
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text((data as FormulaWgtProcessData).rawId!,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant));
                  },
                  renderTitle: (context, title) {
                    return showTableTitle(title.title);
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fMaterialNameCol,
                  columnWidth: FixedColumnWidth(columnWidth),
                  showSort: true,
                  sort: false,
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {},
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text(
                        //修改了此处
                        (data as FormulaWgtProcessData).no == 0
                            ? localizedStrings.fFmaContainer
                            : (data).rawName!,
                        style: getTextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant));
                  },
                  renderTitle: (context, title) {
                    return showTableTitle(title.title);
                  },
                ),
                if ((myFmaInfo.header?.formulaMode ?? '') == "pct")
                  StickyTableColumn(
                    localizedStrings.fPctMode,
                    columnWidth: FixedColumnWidth(columnWidth),
                    showSort: true,
                    sort: false,
                    alignment: Alignment.centerLeft,
                    onCellClick: (context, title, data, row, column) {},
                    // 修改 renderCell 方法
                    renderCell: (context, title, data, row, column) {
                      return Text(
                          (data as FormulaWgtProcessData).targetPct.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: getTextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant));
                    },
                    renderTitle: (context, title) {
                      return showTableTitle(title.title);
                    },
                  ),
                StickyTableColumn(
                  localizedStrings.fTargetWeightLabel,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {},
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text(
                        //修改了此处
                        (data as FormulaWgtProcessData).no == 0
                            ? "-"
                            : (data).targetWgt.toString(),
                        style: getTextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant));
                  },
                  renderTitle: (context, title) {
                    return showTableTitle(title.title);
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fCurrentWeightLabel,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {},
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text(
                        (data as FormulaWgtProcessData).currentWgt.toString(),
                        style: getTextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant));
                  },
                  renderTitle: (context, title) {
                    return showTableTitle(title.title);
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fAllowableErrorWeightLabel,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {},
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text(
                        //修改了此处
                        (data as FormulaWgtProcessData).no == 0
                            ? "-"
                            : "± ${(data).errorWgt}",
                        style: getTextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant));
                  },
                  renderTitle: (context, title) {
                    return showTableTitle(title.title);
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fCurrentErrorWeightLabel,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {},
                  // 修改 renderCell 方法
                  renderCell: (context, title, data, row, column) {
                    return Text(
                        //修改了此处
                        (data as FormulaWgtProcessData).no == 0
                            ? "-"
                            : (data).currentErrorWgt.toString(),
                        style: getTextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant));
                  },
                  renderTitle: (context, title) {
                    return showTableTitle(title.title);
                  },
                ),
                StickyTableColumn(
                  localizedStrings.fQualificationStatus,
                  showSort: true,
                  sort: false,
                  columnWidth: FixedColumnWidth(columnWidth),
                  alignment: Alignment.centerLeft,
                  onCellClick: (context, title, data, row, column) {},
                  renderCell: (context, title, data, row, column) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: columnWidth,
                      ),
                      child: IntrinsicWidth(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(30), // 设置圆角半径为 8
                            color: (data as FormulaWgtProcessData).isOK! == "no"
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1)
                                : (data).isOK! == "ok"
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onTertiaryFixedVariant
                                        .withValues(alpha: 0.1)
                                    : Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withValues(alpha: 0.1),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: smallPadding,
                          ),

                          child: Text(
                            (data).no == 0
                                ? "-"
                                : (data).isOK! == "no"
                                    ? localizedStrings.fIncompleteStatus
                                    : (data).isOK! == "ok"
                                        ? localizedStrings.fQualified
                                        : localizedStrings.fUnqualified,
                            style: textTheme.bodySmall!.apply(
                              color: (data).isOK! == "no"
                                  ? colorScheme.primary
                                  : (data).isOK! == "ok"
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onTertiaryFixedVariant
                                      : colorScheme.error,
                            ),
                          ), // 显示原料重量和单位
                        ),
                      ),
                    );
                  },
                  renderTitle: (context, title) {
                    return showTableTitle(title.title);
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
                //         color: colorScheme.primary,
                //       )),
                //     );
                //   },
                // ),
              ],
            ),
          );
        }));
  }

  showFName() {
    String name = "";
    if (myFmaInfo.header == null || myFmaInfo.header?.formulaName == null) {
      name = "";
    } else {
      name = (myFmaInfo.header?.formulaName ?? '');
    }
    return Expanded(
      child: Text(
        name,
        style: getTitleTextStyle(),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  showFormulaName() {
    return Container(
      height: 28,
      color: colorScheme.surface,
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
            style: getTitleTextStyle(color: colorScheme.onSurfaceVariant),
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
        style: getTitleTextStyle(),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  showFInfo() {
    return Expanded(
      flex: 9,
      child: Column(children: [
        showFormulaName(),
        SizedBox(
          height: 28,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            // 显示标签部分
            Expanded(
              child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: localizedStrings.fFmaIdLabel + ": ",
                        style: getTitleTextStyle(
                            color: colorScheme.onSurfaceVariant),
                      ),
                      TextSpan(
                        text: (myFmaInfo.header?.formulaId ?? ''),
                        style: getTitleTextStyle(),
                      ),
                      TextSpan(
                        text: '  ',
                        style: getTitleTextStyle(),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis),
            ),

            Expanded(
              child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: localizedStrings.fFmaBarcode + ": ",
                        style: getTitleTextStyle(
                            color: colorScheme.onSurfaceVariant),
                      ),
                      TextSpan(
                        text: (myFmaInfo.header?.formulaBarcode ?? ''),
                        style: getTitleTextStyle(),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis),
            )
          ]),
        ),
        Container(
          height: 28,
          color: colorScheme.surface,
          alignment: Alignment.centerLeft,
          child: Row(children: [
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                localizedStrings.fTotalWeightLabel + ": ",
                style: getTitleTextStyle(color: colorScheme.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // 显示编号内容部分，用 Expanded 约束宽度
            showTotalWgtAndUnit()
          ]),
        ),
        Container(
          height: 40,
          color: colorScheme.surface,
          alignment: Alignment.centerLeft,
          child: Row(children: [
            // 显示标签部分，设置固定宽度
            Expanded(
              child: Text(
                localizedStrings.fRemarkCol,
                style: getTitleTextStyle(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // 显示编号内容部分，用 Expanded 约束宽度
          ]),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.topLeft,
            child: SelectableText(
              myFmaInfo.header == null || myFmaInfo.header!.remark == null
                  ? ""
                  : (myFmaInfo.header?.remark ?? ''),
              style: getTextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        )
      ]),
    );
  }

  String checkIsOk(double currValue, double minValue, double maxValue) {
    /// 核心误差界定逻辑。
    /// 将目前底层上报读数累加上原本的皮重（容器和已装填物），并与 [minWgt] 及 [maxWgt] 比对，从而向 UI 层反馈状态色(`ok`, `low`, `high`)。
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
    /// 核心误差界定逻辑。
    /// 将目前底层上报读数累加上原本的皮重（容器和已装填物），并与 [minWgt] 及 [maxWgt] 比对，从而向 UI 层反馈状态色(`ok`, `low`, `high`)。
    String isWgtOk = '';
    double minWgt =
        (double.tryParse(selectedProcessWgt.minWgt?.toStringAsFixed(3) ?? '') ??
            0.0);
    double maxWgt =
        (double.tryParse(selectedProcessWgt.maxWgt?.toStringAsFixed(3) ?? '') ??
            0.0);
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

  showCompleteStatus() {
    //显示一张图片
    return Expanded(
        flex: 20,
        child: Container(
            color: colorScheme.surface,
            alignment: Alignment.center,
            child: Row(children: [
              Expanded(
                child: Container(
                    alignment: Alignment.center,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              height: 150,
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                _completeImagePath,
                                fit: BoxFit.cover,
                              )),
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              localizedStrings.fFormulaCompletedTip,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ])),
              )
            ])));
  }

  Widget _buildScaleName() {
    return Container(
      height: 28,
      color: colorScheme.surface,
      alignment: Alignment.centerLeft,
      child: Row(children: [
        // 显示标签部分，设置固定宽度
        Expanded(
          child: Text(
            '${localizedStrings.gDeviceName} : ${myScale.scaleName}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .apply(color: colorScheme.onSurface),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        // 显示编号内容部分，用 Expanded 约束宽度
      ]),
    );
  }

  Widget showWgtAndProcess() {
    return Expanded(
      flex: 20,
      child: Column(children: [
        _buildScaleName(),
        Expanded(
            child: SizedBox(
          child: Row(children: [
            Expanded(
                flex: 3,
                child: Container(
                  color: colorScheme.surfaceDim,
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
                                //修改了此处
                                selectedProcessWgt.no == 0
                                    ? localizedStrings.fFmaContainer
                                    : selectedProcessWgt.rawName ?? "",
                                maxLines: 1,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),

                                overflow: TextOverflow.ellipsis,
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
                                  child: ValueListenableBuilder<String>(
                                    valueListenable: currentWgtStrNotifier,
                                    builder: (context, value, child) {
                                      return FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment:
                                            Alignment.centerLeft, // 保持文本左对齐
                                        child: Text(
                                          value,
                                          maxLines: 1,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(
                                                  fontSize: 48,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    },
                                  )),
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  alignment: Alignment.bottomRight,
                                  child: Text(fmaUnit,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                      overflow: TextOverflow.ellipsis),
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
                  color: colorScheme.surfaceDim,
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                      overflow: TextOverflow.ellipsis),
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
                                    //修改了此处
                                    selectedProcessWgt.no == 0
                                        ? "--"
                                        : double.parse(
                                                (selectedProcessWgt.targetWgt! -
                                                        selectedProcessWgt
                                                            .currentWgt!)
                                                    .toStringAsFixed(3))
                                            .toString(),
                                    maxLines: 1,
                                    //修改了此处
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                            fontSize: 48,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            overflow: TextOverflow.ellipsis),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                    overflow: TextOverflow.ellipsis,
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
                  color: colorScheme.surfaceDim,
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                overflow: TextOverflow.ellipsis,
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
                                    //修改了此处
                                    selectedProcessWgt.no == 0
                                        ? "--"
                                        : '$showErrorStr ${selectedProcessWgt.errorWgt}',
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          fontSize: 48,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                    overflow: TextOverflow.ellipsis,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                    overflow: TextOverflow.ellipsis,
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
        Expanded(
            child: SizedBox(
          child: Row(children: [
            Expanded(
                flex: 6,
                child: Container(
                  color: colorScheme.surfaceDim,
                  child: Column(children: [
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                            child: Column(children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                color: Color.fromARGB(255, 249, 252, 252),
                                child: Text(
                                    localizedStrings.fRawMaterialWeightLabel,
                                    style: getTextStyle()),
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
                                                (selectedProcessWgt.minWgt! -
                                                        selectedProcessWgt
                                                            .currentWgt!)
                                                    .toStringAsFixed(3)) <
                                            0
                                        ? 0.0
                                        : double.parse((selectedProcessWgt
                                                    .minWgt! -
                                                selectedProcessWgt.currentWgt!)
                                            .toStringAsFixed(3)), // 传入最小值

                                    maxValue: double.parse(
                                                (selectedProcessWgt.maxWgt! -
                                                        selectedProcessWgt
                                                            .currentWgt!)
                                                    .toStringAsFixed(3)) <
                                            0
                                        ? 0.0
                                        : double.parse((selectedProcessWgt
                                                    .maxWgt! -
                                                selectedProcessWgt.currentWgt!)
                                            .toStringAsFixed(3)), // 传入最大值
                                    targetValue: double.parse(
                                                (selectedProcessWgt.targetWgt! -
                                                        selectedProcessWgt
                                                            .currentWgt!)
                                                    .toStringAsFixed(3)) <
                                            0
                                        ? 0.0
                                        : double.parse((selectedProcessWgt
                                                    .targetWgt! -
                                                selectedProcessWgt.currentWgt!)
                                            .toStringAsFixed(3)), // 传入目标值
                                    maxWidth: maxWidth, // 传递最大宽度
                                    maxHeight: maxHeight, // 传递最大高度
                                  ),
                                );
                              },
                            ),
                          ),
                        ]))),
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                            child: Column(children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                color: Color.fromARGB(255, 249, 252, 252),
                                child: Text(
                                    localizedStrings.fFormulaProgressLabel,
                                    style: getTextStyle()),
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
                        ]))),
                    SizedBox(
                      height: 2,
                    )
                  ]),
                )),
            SizedBox(
              width: 10,
            ),
            Expanded(
                flex: 1,
                child: SizedBox(
                    child: Column(children: [
                  Expanded(
                      flex: 1,
                      child: SizedBox(
                        child: Row(children: [
                          Expanded(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              backgroundColor: colorScheme.surface,
                              fixedSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                                  side: BorderSide(
                                    color: colorScheme.primary,
                                  )),
                            ),
                            onPressed: () {
                              // PublicFunctions.performZeroWithScaleId(
                              //     myScale.scaleId);
                              zeroByScaleId(myScale.scaleId);
                            },
                            child: Text(
                              localizedStrings.iBtnZero,
                              //修改了此处

                              style: getTextStyle(color: colorScheme.primary),

                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                        ]),
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Expanded(
                      flex: 1,
                      child: SizedBox(
                        child: Row(children: [
                          Expanded(
                              child: RawMaterialButton(
                            onPressed: () {
                              // PublicFunctions.performTareWithScaleId(
                              //     myScale.scaleId);
                              tareByScaleId(myScale.scaleId);
                            },
                            onLongPress: () {
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
                                  PublicFunctions.forceUntare(myScale.scaleId);
                                }
                              });
                            },
                            fillColor: colorScheme.surface,
                            textStyle:
                                Theme.of(context).textTheme.bodySmall!.apply(
                                      color: colorScheme.primary,
                                    ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(
                                color: colorScheme.primary,
                              ),
                            ),
                            constraints: BoxConstraints(
                              minWidth: double.infinity,
                              minHeight: 48,
                            ),
                            elevation: 0,
                            child: Text(
                              localizedStrings.gBtnTare,
                              style:
                                  Theme.of(context).textTheme.bodySmall!.apply(
                                        color: colorScheme.primary,
                                      ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                        ]),
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Expanded(
                      flex: 1,
                      child: SizedBox(
                        child: Row(children: [
                          Expanded(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: colorScheme.onPrimary,
                              backgroundColor: colorScheme.primary,
                              fixedSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                              ),
                            ),
                            onPressed: isEnableNext
                                ? () {
                                    handleNexBtn();
                                  }
                                : null,
                            child: Text(
                              localizedStrings.fNextStepBtn,
                              style: textTheme.bodySmall!.apply(
                                color: colorScheme.onPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                        ]),
                      )),
                  SizedBox(
                    height: 2,
                  )
                ]))),
          ]),
        )),
      ]),
    );
  }

  Widget showTableTitle(String title) {
    return SizedBox(
        child: Text(title,
            overflow: TextOverflow.ellipsis, style: getTextStyle()));
  }

  TextStyle getTextStyle({Color? color}) {
    //返回一个文本样式
    color ??= colorScheme.onSurface;
    return textTheme.bodySmall!.apply(
      color: color,
    );
  }

  TextStyle getTitleTextStyle({Color? color}) {
    //返回一个文本样式
    color ??= colorScheme.onSurface;
    return textTheme.bodyMedium!.apply(
      color: color,
    );
  }

  showFormulaInfoAndWgt() {
    return Expanded(
      flex: 9,
      child: Container(
        color: colorScheme.surface,
        child: Column(children: [
          Expanded(
              child: Row(
            children: [
              SizedBox(
                width: 17,
              ),
              showFInfo(),
              SizedBox(
                width: 20,
              ),
              VerticalDivider(
                color: colorScheme.outline,
                width: 1,
              ),
              SizedBox(
                width: 20,
              ),
              checkAllOK() ? showCompleteStatus() : showWgtAndProcess(),
              SizedBox(
                width: 20,
              ),
            ],
          ))
        ]),
      ),
    );
  }

  void handleNexBtn() {
    //判断为空
    if (myReqWeightCountine.msgBody == null) {
      showTipInfo(localizedStrings.fDeviceDisconnected, context);
      return;
    }
    //判断当前是否已经稳定
    //20260629  判断下一步的时候如果自动下一步是false，就不判断了
    if (autoNextStep == true) {
      if ((myReqWeightCountine.msgBody?.isStable ?? false) == false) {
        showTipInfo(localizedStrings.fStableOperationHint, context);
        return;
      }
    }

    if (selectedProcessWgt.no == 0) {
      //如果是第一个原料，直接赋值，这个原料是容器，直接赋值，执行扣重
      selectedProcessWgt.currentWgt = currentRawWgt < 0 ? 0 : currentRawWgt;
      selectedProcessWgt.isOK = okStr;
      if (autoTare) {
        // PublicFunctions.performTareWithScaleId(myScale.scaleId);
        tareByScaleId(myScale.scaleId);
      }
      //然后去找下一个原料
      findNextRaw();
      return;
    }
    //判断是否合格
    String isWgtOk = checkValueIsOk();

    //不合格，重量轻了 轻了就不让往下走            轻了也让往下走 @20250718
    if (isWgtOk == 'low') {
      //锁定当前重量
      double currentTempWgtValue = currentRawWgt < 0 ? 0 : currentRawWgt;
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
          if (autoTare) {
            // PublicFunctions.performTareWithScaleId(myScale.scaleId);
            tareByScaleId(myScale.scaleId);
          }
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

//重量轻时执行下一步的操作
  void performLowRow(double currentTempWgtValue) {
    processWgtList[clickedRow].currentWgt =
        currentTempWgtValue + processWgtList[clickedRow].currentWgt!;
    processWgtList[clickedRow].currentWgt = (double.tryParse(
            processWgtList[clickedRow].currentWgt?.toStringAsFixed(3) ?? '') ??
        0.0);
    processWgtList[clickedRow].isOK = 'low';
    processWgtList[clickedRow].currentErrorWgt =
        (processWgtList[clickedRow].currentWgt! -
            processWgtList[clickedRow].targetWgt!);
    processWgtList[clickedRow].currentErrorWgt = double.parse(
        processWgtList[clickedRow].currentErrorWgt!.toStringAsFixed(3));
    if (currentTempWgtValue > 0) {
      processWgtList[clickedRow].scaleId = myScale.scaleId;
      processWgtList[clickedRow].scaleName = myScale.scaleName;
      processWgtList[clickedRow].scaleModel = myScale.scaleModel;
      processWgtList[clickedRow].scaleSn = myScale.scaleSn;
    }
    if (autoTare) {
      // PublicFunctions.performTareWithScaleId(myScale.scaleId);
      tareByScaleId(myScale.scaleId);
    }
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
      _switchScaleByRawId(selectedProcessWgt.rawId!);
    } else {
      // 若都没找到，回到第一行
      clickedRow = 0;
      selectedProcessWgt = processWgtList[0];
      _switchScaleByRawId(selectedProcessWgt.rawId!);
    }
    currentRawWgt = 0.0;

    handleCloseIoPort();

    if (checkCodeflag) {
      showCheckCodeDialog();
    } else {
      handleIoPortStatus();
    }
  }

  /// 根据用户实时修正的期望产出重量重算所有配方成分明细。
  /// 如果业务模式是 'pct'，则每一个成分实际 Target = 新基数 * pct占比，若是绝对质量模式 'wgt' 则保持绝对值。
  recalculateWgtList(double lastNeedTotalWgt) {
    //根据模式计算需要的重量
    if (myFmaInfo.header == null || myFmaInfo.header?.formulaMode == null) {
      return;
    }
    String fmaMode = (myFmaInfo.header?.formulaMode ?? '');

    if (fmaMode == 'wgt') {
      //按重量
      for (var item in processWgtList) {
        //如果第一个是容器，就不用去计算
        if (item.no == 0) {
          continue;
        }
        item.targetWgt = needTotalWgt * item.targetWgt! / lastNeedTotalWgt;
        item.targetWgt =
            (double.tryParse(item.targetWgt?.toStringAsFixed(3) ?? '') ?? 0.0);
        item.minWgt = item.targetWgt! - item.errorWgt!;
        item.minWgt =
            (double.tryParse(item.minWgt?.toStringAsFixed(3) ?? '') ?? 0.0);
        item.maxWgt = item.targetWgt! + item.errorWgt!;
        item.maxWgt =
            (double.tryParse(item.maxWgt?.toStringAsFixed(3) ?? '') ?? 0.0);
        item.currentErrorWgt = item.currentWgt! - item.targetWgt!;
        item.currentErrorWgt =
            (double.tryParse(item.currentErrorWgt?.toStringAsFixed(3) ?? '') ??
                0.0);
        item.isOK = checkIsOk(item.currentWgt!, item.minWgt!, item.maxWgt!);
      }
    } else {
      //按百分比
      for (var item in processWgtList) {
        if (item.no == 0) {
          continue;
        }
        item.targetWgt = needTotalWgt * item.targetPct! / 100;
        item.targetWgt =
            (double.tryParse(item.targetWgt?.toStringAsFixed(3) ?? '') ?? 0.0);
        item.errorWgt = needTotalWgt * item.errorPct! / 100;
        item.errorWgt =
            (double.tryParse(item.errorWgt?.toStringAsFixed(3) ?? '') ?? 0.0);
        item.minWgt = item.targetWgt! - item.errorWgt!;
        item.minWgt =
            (double.tryParse(item.minWgt?.toStringAsFixed(3) ?? '') ?? 0.0);
        item.maxWgt = item.targetWgt! + item.errorWgt!;
        item.maxWgt =
            (double.tryParse(item.maxWgt?.toStringAsFixed(3) ?? '') ?? 0.0);
        item.currentErrorWgt = item.currentWgt! - item.targetWgt!;
        item.currentErrorWgt =
            (double.tryParse(item.currentErrorWgt?.toStringAsFixed(3) ?? '') ??
                0.0);
        item.isOK = checkIsOk(item.currentWgt!, item.minWgt!, item.maxWgt!);
      }
    }
  }

  void handleSkipRaw() {
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
      _switchScaleByRawId(selectedProcessWgt.rawId!);
    } else {
      // 若都没找到，回到第一行
      clickedRow = 0;
      selectedProcessWgt = processWgtList[0];
      _switchScaleByRawId(selectedProcessWgt.rawId!);
    }
    currentRawWgt = 0.0;
    if (checkCodeflag) {
      showCheckCodeDialog();
    }
  }

//查找下一个原料
  void findNextRaw() {
    //从头找第一个不合格的开始处理
    FormulaWgtProcessData nextItem;
    // 先查找 isOK 不为 'ok' 的项
    try {
      nextItem = processWgtList
          .firstWhere((item) => item.isOK != 'ok' && item.no != 0);
      selectedProcessWgt = nextItem; // 更新选中的原料重量项
      _switchScaleByRawId(selectedProcessWgt.rawId!);
      //如果有容器
      if (myFmaInfo.header != null &&
          (myFmaInfo.header?.needContainer ?? false)) {
        clickedRow = selectedProcessWgt.no!; // 更新点击的行索引
      } else {
        clickedRow = selectedProcessWgt.no! - 1; // 更新点击的行索引
      }
      currentRawWgt = 0.000;
      //////弹框提示校验码
      if (checkCodeflag) {
        showCheckCodeDialog();
      } else {
        handleIoPortStatus();
      }
    } catch (e) {
      // 如果没有 isOK 不为 'ok' 的项，说明配方完成了
      setState(() {
        isEnableNext = false; // 禁用按钮
      });
      showTipInfo(localizedStrings.fFormulaCompletionMsg, context);
      handleCloseIoPort();
      //自动保存配方
      saveFormula();
      return;
    }
  }

  void showCheckCodeDialog() {
    if (checkCodeDialogShowing || selectedProcessWgt.no == 0) {
      return;
    }
    checkCodeDialogShowing = true;
    checkCodeOk = false;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ShowCheckCodeDialog(
            title: localizedStrings.ingredientVerification,
            rawId: selectedProcessWgt.rawId!,
            rawName: selectedProcessWgt.rawName!,
            rawCode: selectedProcessWgt.checkCode!,
            canSave: getCanSaveFlag(),
          );
        }).then((value) {
      if (value != null) {
        checkCodeDialogShowing = false;
        if (value == "ok") {
          setState(() {
            checkCodeOk = true;
            handleIoPortStatus();
          });
        } else if (value == "skip") {
          handleSkipRaw();
        } else if (value == "set") {
          showSettigDialog();
        } else if (value == "abandon") {
          performAbandonBtn();
        } else if (value == "save") {
          performDarfFmaSave();
        }
      }
    });
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
      _switchScaleByRawId(selectedProcessWgt.rawId!);
      //如果有容器
      if (myFmaInfo.header != null &&
          (myFmaInfo.header?.needContainer ?? false)) {
        clickedRow = selectedProcessWgt.no!; // 更新点击的行索引
      } else {
        clickedRow = selectedProcessWgt.no! - 1; // 更新点击的行索引
      }
      currentRawWgt = 0.000;
    });
    if (checkCodeflag) {
      showCheckCodeDialog();
    } else {
      handleIoPortStatus();
    }
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
          targetItem.currentWgt = (double.tryParse(
                  targetItem.currentWgt?.toStringAsFixed(3) ?? '') ??
              0.0);
          if (tmpCurrWgt > 0) {
            targetItem.scaleId = myScale.scaleId;
            targetItem.scaleName = myScale.scaleName;
            targetItem.scaleModel = myScale.scaleModel;
            targetItem.scaleSn = myScale.scaleSn;
          }

          //重新计算所有的数据
          recalculateWgtList(lastNeedTotalWgt);
          findNextRaw();
        } else {
          // 处理空值情况
          needTotalWgt = 0.0;
          showTipInfo(localizedStrings.tipFormulaDataError, context);
        }
      } catch (e) {
        return; // 处理未找到匹配项的情况
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
        targetItem.currentWgt =
            (double.tryParse(targetItem.currentWgt?.toStringAsFixed(3) ?? '') ??
                0.0);
        targetItem.isOK = isWgtOk;
        targetItem.currentErrorWgt =
            (targetItem.currentWgt! - selectedProcessWgt.targetWgt!);
        targetItem.currentErrorWgt = (double.tryParse(
                targetItem.currentErrorWgt?.toStringAsFixed(3) ?? '') ??
            0.0);
        //百分比模式算出百分比
        if ((myFmaInfo.header?.formulaMode ?? '') == 'pct') {
          //计算误差的百分比
          if (needTotalWgt > 0) {
            targetItem.currentErrorPct =
                (targetItem.currentErrorWgt! / needTotalWgt) * 100;
            targetItem.currentErrorPct = (double.tryParse(
                    targetItem.currentErrorPct?.toStringAsFixed(3) ?? '') ??
                0.0);
          }
        }
        if (currentRawWgt > 0) {
          targetItem.scaleId = myScale.scaleId;
          targetItem.scaleName = myScale.scaleName;
          targetItem.scaleModel = myScale.scaleModel;
          targetItem.scaleSn = myScale.scaleSn;
        }

        if (autoTare) {
          // PublicFunctions.performTareWithScaleId(myScale.scaleId);
          tareByScaleId(myScale.scaleId);
        }
        handleCloseIoPort();
        //查找下一个
        findOkNextRaw();
      } catch (e) {
        return;
      }
    }
  }

  void handleCloseIoPort() {
    if (!openIoPortFlag ||
        !currentPortSetting.isOpen ||
        !currentPortSetting.isEnable ||
        currentPortSetting.portNo == 0) {
      return;
    }

    closeIoPort();
  }

  //换算单位 重量单位有三种可能，1.kg 2.g 3.lb
  //原单位是g
  //如果是g，不处理
  //如果是kg，将重量转换为kg
  //如果是lb，将重量转换为lb
  //保留最多三位小数
  double convertWeightUnit(double wgt) {
    //如果是0，不处理
    if (wgt == 0) {
      return wgt;
    }

    if ((myFmaInfo.header?.formulaUnit ?? '') == 'g') {
      return wgt;
    } else if ((myFmaInfo.header?.formulaUnit ?? '') == 'kg') {
      wgt = wgt / 1000;
    } else if ((myFmaInfo.header?.formulaUnit ?? '') == 'lb') {
      wgt = wgt / 2.20462;
    }
    wgt = double.parse(wgt.toStringAsFixed(3));
    return wgt;
  }

  void handleStopIoPort() {
    if (!openIoPortFlag ||
        !currentPortSetting.isOpen ||
        !currentPortSetting.isEnable ||
        currentPortSetting.portNo == 0) {
      return;
    }

    try {
      //找出触发关闭的重量值  先进行单位转换
      double triggerWgt = currentPortSetting.triggerValue;
      triggerWgt = convertWeightUnit(triggerWgt);

      //单位转换完成后，判断当前重量是否大于等于触发关闭的重量值
      //触发值是目标值减去触发值
      if (selectedProcessWgt.targetWgt == null) {
        return;
      }

      if (selectedProcessWgt.targetWgt! - selectedProcessWgt.currentWgt! <=
          triggerWgt) {
        return;
      }

      if (selectedProcessWgt.targetWgt! <= triggerWgt) {
        return;
      }

      triggerWgt = selectedProcessWgt.targetWgt! -
          selectedProcessWgt.currentWgt! -
          triggerWgt;
      triggerWgt = double.parse(triggerWgt.toStringAsFixed(3));

      if (currentRawWgt >= triggerWgt) {
        closeIoPort();
      }
    } catch (e) {
      // print(e.toString());
      return;
    }
  }

  Future<void> handleIoPortStatus() async {
    // 前置条件检查保持不变...
    if (!openIoPortFlag) return;
    if (rawOutputInfoList.isEmpty) return;
    if (selectedProcessWgt.no == 0) return;
    if (selectedProcessWgt.isOK == okStr) return;
    if (currentRawWgt >= selectedProcessWgt.targetWgt!) return;
    if (currentRawWgt + selectedProcessWgt.currentWgt! >=
        selectedProcessWgt.targetWgt!) {
      return;
    }
    if ((myReqWeightCountine.msgBody?.weightUnit ?? '') !=
        (myFmaInfo.header?.formulaUnit ?? '')) {
      return;
    }

    // 查找端口配置（保持不变）
    for (var rawOutputInfo in rawOutputInfoList) {
      if (rawOutputInfo.materialId == selectedProcessWgt.rawId) {
        currentPortSetting.isEnable = false;
        currentPortSetting.portNo = rawOutputInfo.output!;
        currentPortSetting.isOpen = false;
        break;
      }
    }

    // 获取端口状态和延迟时间
    for (var portInfo in outputPortStatusList) {
      if (portInfo.port == currentPortSetting.portNo) {
        currentPortSetting.isEnable = portInfo.status!;
        currentPortSetting.triggerValue = portInfo.endValue!;
        currentPortSetting.delayedTime = portInfo.startTime!;
        break;
      }
    }

    if (!currentPortSetting.isEnable || currentPortSetting.portNo == 0) {
      return;
    }
    int delayedTime = currentPortSetting.delayedTime;
    if (delayedTime < 1000) {
      delayedTime = 1000;
    }

    // 延迟后重新检查条件并打开端口
    await Future.delayed(Duration(milliseconds: delayedTime));

    // 重新检查所有关键条件
    if (!await checkConditionsStillValid()) {
      return;
    }

    openIoPort();
  }

// 提取条件检查为单独的方法
  Future<bool> checkConditionsStillValid() {
    // 重新获取最新的状态数据（可能需要从硬件或状态管理获取）
    // 这里需要根据你的实际架构来实现

    return Future.value(openIoPortFlag &&
        rawOutputInfoList.isNotEmpty &&
        selectedProcessWgt.no != 0 &&
        selectedProcessWgt.isOK != okStr &&
        currentRawWgt < selectedProcessWgt.targetWgt! &&
        currentRawWgt + selectedProcessWgt.currentWgt! <
            selectedProcessWgt.targetWgt! &&
        (myReqWeightCountine.msgBody?.weightUnit ?? '') ==
            (myFmaInfo.header?.formulaUnit ?? '') &&
        currentPortSetting.isEnable &&
        currentPortSetting.portNo != 0);
  }

  void openIoPort() {
    if (openIoPortFlag &&
        currentPortSetting.isEnable &&
        currentPortSetting.portNo != 0) {
      ReqPortInfo reqPortInfo =
          ReqPortInfo(portId: currentPortSetting.portNo, status: true);
      String jsonStr = reqPortInfoToJson(reqPortInfo);
      PublicFunctions.writeModbusCoils(jsonStr);
    }
    setState(() {
      currentPortSetting.isOpen = true;
    });
  }

  void closeIoPort() {
    if (openIoPortFlag &&
        currentPortSetting.isOpen &&
        currentPortSetting.portNo != 0) {
      ReqPortInfo reqPortInfo =
          ReqPortInfo(portId: currentPortSetting.portNo, status: false);
      String jsonStr = reqPortInfoToJson(reqPortInfo);
      PublicFunctions.writeModbusCoils(jsonStr);
    }

    setState(() {
      currentPortSetting.isOpen = false;
      currentPortSetting.portNo = 0;
    });
  }

//单据编号
  showTitleBar() {
    return Container(
      height: 54,
      color: colorScheme.surface,
      child: Row(
        children: [
          SizedBox(
            width: 17,
          ),
          Expanded(
              child: Text(
            localizedStrings.fOrderNo + ': $recRecNumber',
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .apply(color: colorScheme.onSurface),
          )),
          SizedBox(
            height: 40,
            child: IconButton(
                iconSize: 35,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: Icon(openIoPortFlag
                    ? Icons.toggle_on_outlined
                    : Icons.toggle_off_outlined),
                tooltip: localizedStrings.ioPort,
                color: openIoPortFlag
                    ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                onPressed: () {
                  setState(() {
                    closeIoPort();
                    openIoPortFlag = !openIoPortFlag;
                  });
                  if (openIoPortFlag) {
                    handleIoPortStatus();
                  }
                }),
          ),
          SizedBox(
            width: 5,
          ),
          SizedBox(
            height: 40,
            child: IconButton(
                iconSize: 24,
                icon: Icon(
                  Icons.cleaning_services_outlined,
                  color: colorScheme.primary,
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
                      PublicFunctions.forceUntare(myScale.scaleId);
                    }
                  });
                }),
          ),
          SizedBox(
            height: 40,
            child: IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: colorScheme.primary,
                ),
                tooltip: localizedStrings.gParameterSettingsTitle,
                onPressed: () {
                  showSettigDialog();
                }),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
    );
  }

  void showSettigDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return FmaParameterSettingDialog(
            autoNextStep: autoNextStep,
            autoTare: autoTare,
            stableTime: stableTime,
            checkCode: checkCodeflag,
          );
        }).then((value) {
      if (value != null && value != false) {
        setState(() {
          autoNextStep = value.autoNextStep;
          autoTare = value.autoTare;
          stableTime = value.stableTime;
          checkCodeflag = value.checkCode;
          stableTimeCtl.text = stableTime.toString();
          autoNextStepNotifier.value = autoNextStep;
        });

        setAutoNext();
        if (checkCodeflag && selectedProcessWgt.no != 0) {
          checkCodeOk == false;
          showCheckCodeDialog();
        }
      } else {
        if (checkCodeflag && selectedProcessWgt.no != 0) {
          checkCodeOk == false;
          showCheckCodeDialog();
        }
      }
    });
  }

  void setAutoNext() {
    ReqAutoNext reqAutoNext = ReqAutoNext(
        autoNext: autoNextStep,
        stableTime: stableTime,
        autoTare: autoTare,
        checkCode: checkCodeflag);

    PublicFunctions.updateAutoNext(reqAutoNextToJson(reqAutoNext));
  }

  showAddFormulaIconBtn(String tip, IconData icon, Function() onPressed) {
    return Tooltip(
        message: tip, // 提示信息
        child: IconButton(
          iconSize: 24,
          color: colorScheme.onPrimary,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primary,
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
        color: colorScheme.onPrimary,
        focusColor: colorScheme.outline,
        hoverColor: colorScheme.outline,
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            // 设置为矩形形状
            borderRadius: BorderRadius.zero, // 没有圆角，即正方形
          ),
          fixedSize: const Size(40, 40), // 设置固定大小
        ),
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
