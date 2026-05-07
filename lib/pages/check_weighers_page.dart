//重量收集页面 20250522

import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/new_get_recs.dart';
import 'package:t_max/data/plu_data_source.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/sel_scales_in_app.dart';
import 'package:t_max/data/settingparam_data.dart';
import 'package:t_max/data/weight_report_data.dart';
import 'package:t_max/data/wgt_value_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/dialog/setting_dialog.dart';
import 'package:t_max/dialog/weight_report_feilds_setting.dart';
import 'package:t_max/widget/f_open_file.dart';
import 'package:t_max/widget/page_info.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/total_wgt_common.dart';
import 'package:t_max/widget/wgt_value_check_mode.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../widget/page_head.dart';

class CheckWeighersPage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const CheckWeighersPage(
      {super.key, required this.onNavigate, required this.lastRouteName});
  @override
  State<CheckWeighersPage> createState() => CheckWeighersPageState();
}

class CheckWeighersPageState extends State<CheckWeighersPage> {
  TextEditingController totalWgtUnitCtl = TextEditingController(text: 'kg');
// 使用 ValueNotifier 来存储总重量和稳定状态
  final ValueNotifier<double> totalWeightNotifier = ValueNotifier<double>(0);
  final ValueNotifier<bool> totalWgtStableNotifier = ValueNotifier<bool>(false);

  final Map<int, GlobalKey<CheckWeighersPageState>> _scaleWidgetKeys = {};
  ReqWeightCountine tempWeight = ReqWeightCountine();
  final Map<int, Widget> _scaleWidgetCache = {};
  Map<int, WeightInfo> scaleWeightMap = {}; // 存储每台秤的最新称重数据，键为秤的 ID，值为包含重量和单位的对象
  Map<int, WeightInfo> scaleWgtMapDetail = {}; //存储每台秤的详细数据，组成total weight 的明细数据
  List<int> mySelScaleIdList = [];
  List<ScaleRecInfo> allWgtRecList = [];

  final double scaleWgtWidth = 365;
  late TableState _tableState;

  bool firstGetRec = true;
  bool totalWgtStble = false;
  bool needUpdate = false;
  // 添加定时器变量
  Timer? _scaleCheckTimer;
  bool firstGetSelScale = true;

  dynamic eventBus1;
  dynamic eventBus2;
  dynamic eventBus3;
  dynamic eventBus5;
  dynamic eventBus4;
  dynamic eventBus6;
  dynamic eventBus7;
  dynamic eventBus9;
  dynamic eventBus10;
  dynamic eventBus11;
  dynamic eventBus12;

  @override
  void initState() {
    super.initState();
    myPluInfoList.clear();
    // 初始化 TableState
    mySettingParam.scaleMode = 1;
    _tableState = TableState();
    _tableState.loadPage(1);

    PublicFunctions.getUIConfNormal(wgtCheckMode);
    PublicFunctions.getProductList();
// 初始化定时器，每隔10秒执行一次检查
    _scaleCheckTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      checkSameScale();
    });

    // 初始加载时立即检查一次
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkSameScale();
    });
    eventBus1 = eventBus.on<EventUpdateSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          PublicFunctions.getUIConfNormal(wgtCheckMode);
        });
      }
    });

    eventBus2 = eventBus.on<EventSettingParam>().listen((event) {
      if (mounted) {
        setState(() {
          mySettingParam = event.obj;
          if (firstGetSelScale) {
            firstGetSelScale = false;
            getSelScaleInApp();
          }
        });
      }
    });

    eventBus3 = eventBus.on<EventRevAddRec>().listen((event) {
      if (mounted) {
        _tableState.loadPage(1);
      }
    });

    eventBus4 = eventBus.on<EventRespGetAllWgtRecs>().listen((event) {
      if (mounted) {
        String jsonString = event.obj;

        RevAllWgtRecs getAllWgtInfo = revAllWgtRecsFromJson(jsonString);
        if (getAllWgtInfo.totalCount! > 0) {
          List<ScaleRecInfo>? scaleRecInfos = getAllWgtInfo.scaleRecInfos;

          allWgtRecList.clear();

          allWgtRecList = List<ScaleRecInfo>.from(scaleRecInfos!);

          _tableState.addData(allWgtRecList);
          _tableState.setTotalCount(getAllWgtInfo.totalCount!);
          // _tableState.loadPage(1);
        } else {
          allWgtRecList.clear();
          // wgtRptDataList.clear();
          // updateTableData(getWeightReportData());
        }
      }
    });

    eventBus5 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
        } else {}
      }
    });

    eventBus6 = eventBus.on<EventUnregWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {}
      }
    });

    eventBus7 = eventBus.on<EventDelAllWgtRecs>().listen((event) {
      if (mounted) {
        setState(() {
          _tableState.allData.clear();
          _tableState.loadPage(1);
        });
      }
    });

    eventBus9 = eventBus.on<EventProductRecList>().listen((event) {
      if (mounted) {
        setState(() {
          List<PluDataFromDb> pluInfoList = event.obj;
          for (int i = 0; i < pluInfoList.length; i++) {
            PluData newPlu = PluData(0, 0, 0, 0, '', '', 0, 0, 0, 0, 0, 0, 0,
                '', true, '', 0, 0, '', '');

            newPlu.enabled = pluInfoList[i].enabled ?? true;
            if (!pluInfoList[i].enabled!) {
              continue;
            }
            newPlu.recId = pluInfoList[i].recId;
            newPlu.plu = int.tryParse(pluInfoList[i].plu ?? '0') ?? 0;
            newPlu.productCode =
                int.tryParse(pluInfoList[i].productCode ?? '0') ?? 0;
            newPlu.itemCode = int.tryParse(pluInfoList[i].itemCode ?? '0') ?? 0;
            newPlu.category = pluInfoList[i].category;
            newPlu.productName = pluInfoList[i].productName;
            newPlu.price = double.tryParse(pluInfoList[i].price ?? '0') ?? 0;
            newPlu.taxType = int.tryParse(pluInfoList[i].taxType ?? '0') ?? 0;
            newPlu.generalUnit =
                int.tryParse(pluInfoList[i].generalUnit ?? '0') ?? 0;
            newPlu.unitWeight =
                double.tryParse(pluInfoList[i].unitWeight ?? '0') ?? 0;
            newPlu.pretare =
                double.tryParse(pluInfoList[i].pretare ?? '0') ?? 0;
            newPlu.limitHigh =
                double.tryParse(pluInfoList[i].limitHigh ?? '0') ?? 0;
            newPlu.limitLow =
                double.tryParse(pluInfoList[i].limitLow ?? '0') ?? 0;
            newPlu.creatAt = pluInfoList[i].createdAt?.toIso8601String() ?? " ";
            newPlu.updateAt =
                pluInfoList[i].updatedAt?.toIso8601String() ?? " ";
            newPlu.createBy = pluInfoList[i].createBy;
            newPlu.updateBy = pluInfoList[i].updateBy;
            newPlu.createUser = pluInfoList[i].createUser;
            newPlu.updateUser = pluInfoList[i].updateUser;

            myPluInfoList.add(newPlu);
          }
        });
      }
    });
    eventBus10 = eventBus.on<EventAddWgtRec>().listen((event) {
      if (mounted) {
        _tableState.loadPage(1);
      }
    });

    eventBus11 = eventBus.on<EventDelAllWgtRecs>().listen((event) {
      if (mounted) {
        _tableState.loadPage(1);
      }
    });

    eventBus12 = eventBus.on<EventExportAllRecs>().listen((event) {
      if (mounted) {
        String resString = event.obj;
        if (resString.contains('ok')) {
          String filePath = resString.split(',')[1];
          showExportDialog(filePath, context);
        } else {
          showTipInfo(
              '${localizedStrings.gTipExportFail} ：$resString', context);
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    setState(() {
      for (var item in myReportFeildsMap.keys) {
        _tableState.visibleColumns[item]!.isSelect = myReportFeildsMap[item]!;
      }
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    setSelScaleInApp();
    eventBus1.cancel();
    eventBus2.cancel();
    eventBus3.cancel();
    eventBus4.cancel();
    eventBus5.cancel();
    eventBus6.cancel();
    eventBus7.cancel();

    eventBus9.cancel();
    eventBus10.cancel();
    eventBus11.cancel();
    eventBus12.cancel();

    for (var item in mySelScaleIdList) {
      PublicFunctions.stopWeight(item);
    }
    myPluInfoList.clear();
    totalWgtUnitCtl.clear();
    totalWeightNotifier.dispose();
    totalWgtStableNotifier.dispose();
    _tableState.dispose();
    _scaleCheckTimer?.cancel();

    totalWgtUnitCtl.dispose();
    super.dispose();
  }

  setSelScaleInApp() async {
    await AppSelScalesManager.setIntList(AppNames.chwe, mySelScaleIdList);
  }

  getSelScaleInApp() async {
    List<int> savedScales = await AppSelScalesManager.getIntList(AppNames.chwe);
    for (var item in myAllScalesList) {
      if (savedScales.contains(item.scaleId)) {
        addOrRemoveSelScale(item.scaleId);
      }
    }
  }

  // 更新总重量和稳定状态
  void updateTotalWeightAndStable() {
    double totalWeight = calculateTotalWeight();
    bool totalWgtStable = getTotalWgtStable();
    totalWeightNotifier.value = totalWeight;
    totalWgtStableNotifier.value = totalWgtStable;
  }

  bool getTotalWgtStable() {
    if (mySelScaleIdList.isEmpty) {
      return false;
    }

    // 提前构建一个设备 ID 到设备对象的映射，避免在循环中多次查找
    final scaleIdToScaleMap = <int, Scale>{};
    for (final scale in myAllScalesList) {
      scaleIdToScaleMap[scale.scaleId] = scale;
    }

    int validScaleCount = 0;

    for (final entry in scaleWeightMap.entries) {
      final scaleId = entry.key;

      // 判断选择的设备是不是当前的设备
      if (!mySelScaleIdList.contains(scaleId)) {
        continue;
      }

      final myTempScale = scaleIdToScaleMap[scaleId];
      // 设备不存在或不在线则跳过
      if (myTempScale == null || !myTempScale.isOnline) {
        continue;
      }

      final info = entry.value;
      // 判断这个 value 是不是正的数据
      if (info.weight.contains('-')) {
        continue;
      }

      validScaleCount++;
      if (!info.stable) {
        return false;
      }
    }

    // 没有有效设备则返回 false
    return validScaleCount > 0;
  }

  // 计算总重量
  double calculateTotalWeight() {
    double totalWeight = 0;
    scaleWgtMapDetail = {}; //每次计算都先清空明细数据
    if (myAllScalesList.isEmpty) {
      return 0;
    }
    for (var entry in scaleWeightMap.entries) {
      int scaleId = entry.key;

      //判断选择的设备是不是当前的设备
      if (!mySelScaleIdList.contains(scaleId)) {
        continue;
      }

      Scale myTempScale = myAllScalesList[0];
      for (var item in myAllScalesList) {
        if (item.scaleId == scaleId) {
          myTempScale = item;
          break;
        }
      }
      if (!myTempScale.isOnline) {
        continue;
      }

      WeightInfo info = entry.value;
      //判断这个value是不是正的数据
      if (info.weight.contains('-')) {
        continue;
      }
      //转换为double类型的，最多三位小数
      double weight = double.parse(info.weight);
      // 转换为三位小数
      weight = double.parse(weight.toStringAsFixed(3));
      double convertedWeight =
          convertUnit(weight, info.unit, totalWgtUnitCtl.text);
      double tmpWeight = double.parse(convertedWeight.toStringAsFixed(3));
      totalWeight += tmpWeight;
      scaleWgtMapDetail[scaleId] = WeightInfo(
          weight: tmpWeight.toStringAsFixed(3),
          unit: totalWgtUnitCtl.text,
          stable: info.stable);
    }
    totalWeight = double.parse(totalWeight.toStringAsFixed(3));

    return totalWeight;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
          width: width,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surface),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                myPageHeadInfo(
                    context,
                    width - headWidthPadding,
                    localizedStrings.menuCheckWeighing,
                    localizedStrings.gTipCheckWgtPageHelp),
                Container(
                  height: regularPadding,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                ),
                Expanded(
                    child: Container(
                  color: Theme.of(context).colorScheme.surfaceTint,
                  child: Row(
                    children: [
                      Container(
                        width: appScaleListWidth,
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
                                child: NewMutiScaleListWidget(
                                  listWidth: appScaleListWidth, // 列表宽度
                                  selScaleList: mySelScaleIdList,
                                  clickScale: (scale) {
                                    setState(() {
                                      addOrRemoveSelScale(scale.scaleId);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: regularPadding,
                        color:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                      ),
                      if (mySelScaleIdList.isNotEmpty)
                        showScaleWgt(context, scaleWgtWidth),
                      if (mySelScaleIdList.isNotEmpty)
                        Container(
                          width: regularPadding,
                          color:
                              Theme.of(context).colorScheme.surfaceContainerLow,
                        ),
                      showWgtTable(context) // width - 591 - 36)
                    ],
                  ),
                )),
              ])),
    );
  }

  String getScaleName(int scaleId) {
    String scaleName = "";
    for (var item in myAllScalesList) {
      if (item.scaleId == scaleId) {
        scaleName = item.scaleName;
        return scaleName;
      }
    }
    return scaleName;
  }

//实时查看是否是同一台秤，如果是的话，给出提示，并去掉一个
  void checkSameScale() {
    if (mySelScaleIdList.length > 1) {
      Map<int, dynamic> scaleMap = {};
      for (var scale in myAllScalesList) {
        scaleMap[scale.scaleId] = scale;
      }

      // 根据物理设备（型号 + 序列号）对选中的秤进行分组
      Map<String, List<Scale>> groups = {};
      for (var scaleId in mySelScaleIdList) {
        var scale = scaleMap[scaleId];
        if (scale != null) {
          String key = "${scale.scaleModel}_${scale.scaleSn}";
          groups.putIfAbsent(key, () => []).add(scale);
        }
      }

      for (var group in groups.values) {
        if (group.length > 1) {
          // 冲突：同一个物理设备选择了多种连接方式
          showTipInfo(localizedStrings.tipSameScale, context);

          // 优先级：串口(0) > 网口(1) > 蓝牙(2)。排序并保留最高优先级的连接。
          group.sort((a, b) => a.tMedia.compareTo(b.tMedia));

          // 移除除第一个（优先级最高）之外的所有连接
          for (int i = 1; i < group.length; i++) {
            if (mySelScaleIdList.contains(group[i].scaleId)) {
              addOrRemoveSelScale(group[i].scaleId);
            }
          }
          break; // 每个检查周期只显示一次提示
        }
      }
    }
  }

  void addOrRemoveSelScale(int scaleId) {
    if (mySelScaleIdList.contains(scaleId)) {
      mySelScaleIdList.remove(scaleId);
      PublicFunctions.stopWeight(scaleId);
      // 从缓存和keys中移除
      _scaleWidgetCache.remove(scaleId);
      _scaleWidgetKeys.remove(scaleId);
      // debugPrint('Removed scale widget cache for scaleId: $scaleId');
    } else {
      mySelScaleIdList.add(scaleId);
      PublicFunctions.getWeight(scaleId);
    }
    setState(() {}); // 强制刷新界面
    checkSameScale();
  }

  Widget showScaleWgt(BuildContext context, double width) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Expanded(
              child: Container(
            width: width,
            padding: const EdgeInsets.only(bottom: regularPadding),
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: ListView.builder(
              itemCount: mySelScaleIdList.length,
              itemBuilder: (context, index) {
                final scaleId = mySelScaleIdList[index];
                // 如果key不存在，创建新的GlobalKey
                if (!_scaleWidgetKeys.containsKey(scaleId)) {
                  _scaleWidgetKeys[scaleId] =
                      GlobalKey<CheckWeighersPageState>();
                }
                // 如果缓存不存在，使用稳定的GlobalKey创建新Widget
                if (!_scaleWidgetCache.containsKey(scaleId)) {
                  _scaleWidgetCache[scaleId] = ScaleWgtCheckModeWidget(
                    key: _scaleWidgetKeys[scaleId]!,
                    scaleId: scaleId,
                    scaleName: getScaleName(scaleId),
                    isS15: getIsS15(scaleId),
                  );
                  // debugPrint('Created new scale widget for scaleId: $scaleId');
                } else {
                  // debugPrint('Reused scale widget for scaleId: $scaleId');
                }
                return _scaleWidgetCache[scaleId]!;
              },
            ),
          ))
        ],
      ),
    );
  }

  bool getIsS15(int scaleId) {
    for (var item in myAllScalesList) {
      if (item.scaleId == scaleId) {
        if (item.scaleModel == "S15") {
          return true;
        } else {
          return false;
        }
      }
    }

    return false;
  }

  showWgtTable(BuildContext context) {
    return Expanded(
      child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(
                      left: regularPadding, right: regularPadding),
                  height: 68,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: localizedStrings.gBtnExport,
                        child: IconButton(
                          iconSize: 28,
                          color: Theme.of(context).colorScheme.onPrimary,
                          focusColor: Theme.of(context).colorScheme.outline,
                          hoverColor: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.1),
                          style: IconButton.styleFrom(
                            disabledBackgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              // 设置为矩形形状
                              borderRadius: BorderRadius.zero, // 没有圆角，即正方形
                            ),
                            fixedSize: const Size(28, 28), // 设置固定大小
                          ),
                          onPressed: () async {
                            final directory = Directory.current.path;
                            String? outputFile =
                                (await FilePicker.platform.saveFile(
                              initialDirectory: directory,
                              type: FileType.custom,
                              dialogTitle: 'Output file:',
                              allowedExtensions: ["csv"],
                              fileName: 'report.csv',
                            ));

                            if (outputFile != null) {
                              if (!outputFile.contains(".csv")) {
                                outputFile = "$outputFile.csv";
                              }
                              PublicFunctions.exportAllRecords(
                                  mySettingParam.scaleMode,
                                  outputFile,
                                  mySelFields(),
                                  mySelMap());
                            }
                          },
                          icon: getSvgIcon(
                            exportSvgIcon(),
                            28,
                            28,
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: regularPadding,
                      ),
                      Tooltip(
                        message: localizedStrings.gBtnReportSetting,
                        child: IconButton(
                          iconSize: 28,
                          color: Theme.of(context).colorScheme.onPrimary,
                          focusColor: Theme.of(context).colorScheme.outline,
                          hoverColor: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.1),
                          style: IconButton.styleFrom(
                            disabledBackgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              // 设置为矩形形状
                              borderRadius: BorderRadius.zero, // 没有圆角，即正方形
                            ),
                            fixedSize: const Size(28, 28), // 设置固定大小
                          ),
                          onPressed: () {
                            reportFieldsSettingDialog(context);
                          },
                          icon: getSvgIcon(
                            reportSettingSvgIcon(),
                            28,
                            28,
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: regularPadding,
                      ),
                      Tooltip(
                        message: localizedStrings.gParameterSettingsTitle,
                        child: IconButton(
                          iconSize: 28,
                          color: Theme.of(context).colorScheme.onPrimary,
                          focusColor: Theme.of(context).colorScheme.outline,
                          hoverColor: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.1),
                          style: IconButton.styleFrom(
                            disabledBackgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              // 设置为矩形形状
                              borderRadius: BorderRadius.zero, // 没有圆角，即正方形
                            ),
                            fixedSize: const Size(28, 28), // 设置固定大小
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ParameterSettingDialog();
                                });
                          },
                          icon: getSvgIcon(
                            settingSvgIcon(),
                            28,
                            28,
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      if (mySysUser.roleId != operatorRoleId)
                        SizedBox(
                          width: regularPadding,
                        ),
                      if (mySysUser.roleId != operatorRoleId)
                        Tooltip(
                          message: localizedStrings.gBtnDeleteAll,
                          child: IconButton(
                            iconSize: 28,
                            color: Theme.of(context).colorScheme.onPrimary,
                            focusColor: Theme.of(context).colorScheme.outline,
                            hoverColor: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.1),
                            style: IconButton.styleFrom(
                              disabledBackgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow,
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                              shape: RoundedRectangleBorder(
                                // 设置为矩形形状
                                borderRadius: BorderRadius.zero, // 没有圆角，即正方形
                              ),
                              fixedSize: const Size(28, 28), // 设置固定大小
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false, // 点击对话框外部不关闭对话框
                                builder: (BuildContext context) {
                                  return ShowDeleteTipDialog(
                                    title: localizedStrings.fTipTitle,
                                    msg: localizedStrings.gTipConfirmDeleteAll,
                                  );
                                },
                              ).then((value) {
                                if (value) {
                                  setState(() {
                                    PublicFunctions.newDeleteAllRecords(
                                        mySettingParam.scaleMode);
                                  });
                                }
                              });
                            },
                            icon: getSvgIcon(
                              deleteSvgIcon(),
                              28,
                              28,
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  )),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.surfaceDim,
              ),
              SizedBox(
                height: regularPadding,
              ),
              ChangeNotifierProvider<TableState>.value(
                value: _tableState,
                child: WgtDataTable(),
              ),
            ],
          )),
    );
  }

  void reportFieldsSettingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const ReportSettingDialog();
      },
    ).then((value) {
      if (value) {
        setState(() {
          for (var item in myReportFeildsMap.keys) {
            _tableState.visibleColumns[item]!.isSelect =
                myReportFeildsMap[item]!;
          }
        });
      }
    });
  }

  void paramSettingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return const ParamSettingDialog();
      },
    );
  }

  Widget myPageHeadInfo(
      dynamic context, double maxWidth, String pageTitle, String helpInfo) {
    return Container(
        height: pageTopTitleHeight,
        color: Theme.of(context).colorScheme.surface,
        child: Column(children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                subTitle(context, pageTitle, () {
                  widget.onNavigate(widget.lastRouteName);
                }),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  const SizedBox(
                    width: largePadding,
                  ),
                  PageInfoButton(helpInfo: helpInfo, onRefresh: () {}),
                  const SizedBox(
                    width: largePadding,
                  ),
                ])
              ],
            ),
          ),
          Divider(
            color:
                Theme.of(context).colorScheme.surfaceContainerLow, // 设置分割线的颜色
            height: 1, // 设置分割线的高度
            thickness: 1, // 设置分割线的粗细
          ),
        ]));
  }
}

void sendDataToDb(
  List<int> selScaleList,
  Map<int, WeightInfo> scaleWgtMapDetail,
  double totalWeight,
  String baseUnit,
  PluData? selPlu,
) {
  // 检查必要参数是否为空
  if (selScaleList.isEmpty || scaleWgtMapDetail.isEmpty) return;

  // 提前构建 scaleId 到 Scale 对象的映射
  final scaleIdToScaleMap = <int, Scale>{};
  for (final scale in myAllScalesList) {
    scaleIdToScaleMap[scale.scaleId] = scale;
  }

  // 处理 PluData
  final tempPlu = selPlu ??
      PluData(
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        false,
        '',
        0,
        0,
        '',
        '',
      );

  final newAddRec = ReqAddWgtRec()
    ..mode = mySettingParam.scaleMode
    ..detailRec = [];

  // 构建 Header 通用部分
  final headerCommon = Header(
    id: '1',
    plu: tempPlu.plu?.toString() ?? '',
    productCode: tempPlu.productCode?.toString() ?? '',
    itemCode: tempPlu.itemCode?.toString() ?? '',
    category: tempPlu.category ?? '',
    productName: tempPlu.productName ?? '',
    generalUnit: tempPlu.generalUnit?.toString() ?? '',
    taxType: tempPlu.taxType?.toString() ?? '',
    price: tempPlu.price?.toString() ?? '',
    unitWeight: tempPlu.unitWeight?.toString() ?? '',
    pretare: tempPlu.pretare?.toString() ?? '',
    limitHigh: tempPlu.limitHigh?.toString() ?? '',
    limitLow: tempPlu.limitLow?.toString() ?? '',
    weight: totalWeight.toString(),

    //  baseUnit == 'g'
    //     ? totalWeight.toStringAsFixed(0)
    //     : totalWeight.toString(),
    weightUnit: baseUnit,
    userNo: mySysUser.userId.toString(),
    userName: mySysUser.nickName,
    scaleMode: mySettingParam.scaleMode.toString(),
  );

  if (scaleWgtMapDetail.length == 1) {
    final scaleId = scaleWgtMapDetail.keys.first;
    final tempScale = scaleIdToScaleMap[scaleId]!;
    newAddRec.headRec = headerCommon.copyWith(
      scaleModel: tempScale.scaleModel,
      scaleSn: tempScale.scaleSn,
      scaleName: tempScale.scaleName,
    );
    newAddRec.detailRec = [];
  } else {
    newAddRec.headRec = headerCommon.copyWith(
      scaleModel: '',
      scaleSn: '',
      scaleName: '',
    );
  }

  if (scaleWgtMapDetail.length > 1) {
    // 构建 detailRec
    int seq = 1;
    for (final scaleId in scaleWgtMapDetail.keys) {
      final tempScale = scaleIdToScaleMap[scaleId]!;
      final weightInfo = scaleWgtMapDetail[scaleId]!;
      final weight = weightInfo.weight;
      // baseUnit == 'g'
      //     ? double.parse(weightInfo.weight).toStringAsFixed(0)
      //     : weightInfo.weight;

      newAddRec.detailRec!.add(NewWgtDetail(
        no: seq,
        scaleModel: tempScale.scaleModel,
        scaleSn: tempScale.scaleSn,
        weight: weight,
        weightUnit: baseUnit,
        scaleName: tempScale.scaleName,
      ));
      seq++;
    }
  }

  // 发送数据
  final jsonString = reqAddWgtRecToJson(newAddRec);
  PublicFunctions.addSummaryData(jsonString);
}

Scale getScaleFormAll(int scaleId) {
  for (var item in myAllScalesList) {
    if (item.scaleId == scaleId) {
      return item;
    }
  }
  return myAllScalesList[0];
}
