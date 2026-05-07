import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/data/s15_tare_zero.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/wgt_value_data.dart';
import 'package:t_max/dialog/add_raw_info_dialog.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/dialog/fma_type_mgr.dart';
import 'package:t_max/dialog/sel_scale_dialog.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/page_head.dart';
import '../data/language.dart';

class AddFormulaPage extends StatefulWidget {
  const AddFormulaPage({super.key});

  @override
  State<AddFormulaPage> createState() => AddFormulaPageState();
}

class AddFormulaPageState extends State<AddFormulaPage> {
  TextEditingController formulaCodeCtl = TextEditingController();
  TextEditingController formulaNameCtl = TextEditingController();
  TextEditingController formulaModeCtl = TextEditingController(text: 'wgt');
  TextEditingController formulaUnitCtl = TextEditingController(text: 'g');
  TextEditingController formulaTypeCtl = TextEditingController();
  TextEditingController rawMaterialCtl = TextEditingController();
  TextEditingController formulaBarcodeCtl = TextEditingController();

  TextEditingController wgtCtl = TextEditingController(); // 权重
  TextEditingController errorCtl = TextEditingController(); // 误差
  TextEditingController remarkCtl = TextEditingController(); // 备注

  bool isEncrypted = false; // 保密初始值为 false
  bool needContainer = false; // 保密初始值为 false
  bool freeMode = false;
  RawDataInfo? selectedRawDataInfo;
  List<AddFormulaRawWgtInfo> addFormulaRawList = [];
  double totalWgt = 0.0; // 总权重
  // 创建一个映射表，将枚举值与翻译关联起来
  Map<FormulaMode, String> formulaModeTranslation = {
    FormulaMode.wgt: localizedStrings.fWeightMode,
    FormulaMode.pct: localizedStrings.fPctMode,
  };

  int selectedIndex = -1;
  int selScaleId = -1;

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus5;

  Timer? checkWgtStartTimer; // 用于每5秒检查isWgtStart的定时器

  final ValueNotifier<bool> isWgtStartNotifier = ValueNotifier(false);
  final ValueNotifier<String> currentWgtStrNotifier = ValueNotifier('----');
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController1 = ScrollController();

  DateTime? lastDataReceivedTime; // 记录最后一次收到数据的时间

  Timer? _cntAliveTimer;
  // 启动发送存活消息的定时器
  void startCntAliveTimer(int time) {
    _cntAliveTimer?.cancel();

    _cntAliveTimer = Timer(Duration(seconds: time), () {
      if (selScaleId != -1) {
        PublicFunctions.sendScaleAlive(selScaleId);
      }
      startCntAliveTimer(10);
    });
  }

  // 停止发送存活消息的定时器
  void stopCntAliveTimer() {
    _cntAliveTimer?.cancel();
  }

  //  判断一下isWgtStart是不是false，是false的话，就重新发送请求开启连续发送
  void startCheckWgtStartTimer() {
    checkWgtStartTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (isWgtStartNotifier.value == false && selScaleId != -1) {
        PublicFunctions.getWeight(selScaleId);
      }
    });
  }

  void checkDataRevTimer() {
    // 启动一个每秒检查的定时器
    checkWgtStartTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && selScaleId != -1) {
        if (lastDataReceivedTime != null) {
          final timeDifference =
              DateTime.now().difference(lastDataReceivedTime!);
          if (timeDifference.inSeconds >= 2 && isWgtStartNotifier.value) {
            isWgtStartNotifier.value = false;
            currentWgtStrNotifier.value = '----';
            PublicFunctions.getWeight(selScaleId);
            lastDataReceivedTime = null; // 重置时间戳
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startCntAliveTimer(10);
    checkDataRevTimer();
    startCheckWgtStartTimer();
    _eventbus1 = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        ReqWeightCountine tempWeight = ReqWeightCountine();
        tempWeight = event.obj;
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
                final toUnit = formulaUnitCtl.text;

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
      }
    });
    _eventbus2 = eventBus.on<EventRespGetFormulaTypeList>().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });

    _eventbus3 = eventBus.on<EventRespCheckFmaIdAndBarcode>().listen((event) {
      if (mounted) {
        setState(() {
          String dataStr = event.obj;
          if (dataStr != '' && dataStr.contains(',')) {
            List<String> dataList = dataStr.split(',');
            if (dataList.length >= 2) {
              if (dataList[0] == "false" && dataList[1] == "false") {
                showTipInfo(
                    localizedStrings.fFormulaIdAndBarcodeDuplicate, context);
              } else if (dataList[0] == "false" && dataList[1] == "true") {
                showTipInfo(localizedStrings.fFormulaIdDuplicate, context);
              } else if (dataList[0] == "true" && dataList[1] == "false") {
                showTipInfo(localizedStrings.fFormulaBarcodeDuplicate, context);
              } else if (dataList[0] == "true" && dataList[1] == "true") {
                saveFormula(1);
              }
            }
          }
        });
      }
    });

    _eventbus5 = eventBus.on<EventRespGetRawData>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            if (rawDataList.isNotEmpty) {
              selectedRawDataInfo = rawDataList.last;
              rawMaterialCtl.text =
                  '${selectedRawDataInfo!.materialId} ${selectedRawDataInfo!.materialName}';
              selectedIndex = -1; // 重置选中索引
              wgtCtl.text = '';
              errorCtl.text = '';
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    formulaBarcodeCtl.dispose();
    super.dispose();
    checkWgtStartTimer?.cancel();
    _scrollController1.dispose();
    _scrollController.dispose();
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3?.cancel();

    _eventbus5.cancel();
    formulaCodeCtl.dispose();
    formulaNameCtl.dispose();
    formulaModeCtl.dispose();
    formulaUnitCtl.dispose();
    formulaTypeCtl.dispose();
    rawMaterialCtl.dispose();
    wgtCtl.dispose();
    errorCtl.dispose();
    remarkCtl.dispose();
    addFormulaRawList.clear();
    currentWgtStrNotifier.dispose();
    isWgtStartNotifier.dispose();
    checkWgtStartTimer?.cancel();
    stopCntAliveTimer();
    if (selScaleId != -1) {
      PublicFunctions.stopWeight(selScaleId);
    }
  }

  ColorScheme get colorScheme => Theme.of(context).colorScheme;

// 显示新增配方类型对话框
  void showAddFormulaTypeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return AddFormulaTypeDialog();
      },
    );
  }

  void showFormulaTypeMgrDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return FmaTypeMgrDialog();
      },
    );
  }

  //下拉列表框
  showModeDropDownButton(List<FormulaMode> items, String hintText,
      TextEditingController valueCtl) {
    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 16, right: 20),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant), // 设置边框颜色
          borderRadius: BorderRadius.circular(0), // 设置圆角
        ),
        child: DropdownButton<FormulaMode>(
            isExpanded: true,
            value: items.firstWhere(
                (mode) => mode.toString().split('.').last == valueCtl.text,
                orElse: () => items[0]),
            hint: Text(hintText), // 设置提示文本
            underline: SizedBox.shrink(), // 移除下划线
            items: items.map((FormulaMode item) {
              // 设置下拉列表项
              return DropdownMenuItem<FormulaMode>(
                value: item,
                child: Text(
                  formulaModeTranslation[item]!,
                  style: getTextStyle(),
                ),
              );
            }).toList(),
            onChanged: freeMode
                ? null
                : (FormulaMode? newValue) {
                    if (newValue != null) {
                      if (addFormulaRawList.isEmpty) {
                        setState(() {
                          valueCtl.text = newValue
                              .toString()
                              .split('.')
                              .last; // 更新 valueCtl 的值
                        });
                      } else {
                        showDialog(
                          context: context,
                          barrierDismissible: false, // 点击对话框外部不关闭对话框
                          builder: (BuildContext context) {
                            return ShowNormalTipDialog(
                              title: localizedStrings.fTipTitle,
                              msg: localizedStrings.fSwitchModeClearMsg,
                            );
                          },
                        ).then((value) {
                          if (value == null) {
                            return;
                          }
                          if (value) {
                            setState(() {
                              valueCtl.text = newValue
                                  .toString()
                                  .split('.')
                                  .last; // 更新 valueCtl 的值
                              addFormulaRawList.clear();
                              totalWgt = 0;
                              errorCtl.text = '';
                              wgtCtl.text = '';
                              rawMaterialCtl.clear();
                              selectedIndex = -1;
                            });
                          } else {
                            return;
                          }
                        });
                      }
                    }
                  }));
  }

  //下拉列表框
  showUnitDropDownButton(List<FormulaWgtUnit> items, String hintText,
      TextEditingController valueCtl) {
    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 16, right: 20),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant), // 设置边框颜色
          borderRadius: BorderRadius.circular(0), // 设置圆角
        ),
        child: DropdownButton<FormulaWgtUnit>(
            isExpanded: true,
            value: items.firstWhere(
                (mode) => mode.toString().split('.').last == valueCtl.text,
                orElse: () => items[0]),
            hint: Text(hintText), // 设置提示文本
            underline: SizedBox.shrink(), // 移除下划线
            items: items.map((FormulaWgtUnit item) {
              // 设置下拉列表项
              return DropdownMenuItem<FormulaWgtUnit>(
                value: item,
                child: Text(
                  item.name,
                  style: getTextStyle(),
                ),
              );
            }).toList(),
            onChanged: (FormulaWgtUnit? newValue) {
              // 处理下拉列表项选择事件
              if (newValue != null) {
                // 在这里处理选择的值
                // print('Selected: ${newValue.toString().split('.').last}');
                setState(() {
                  valueCtl.text = newValue.name; // 更新 valueCtl 的值
                });
              }
            }));
  }

  //选择类型下拉列表框
  showTypeDropDownButton(String hintText, TextEditingController valueCtl) {
    // 确保当前值在列表中，否则设为 null
    String? currentValue =
        formulaTypeCtl.text == "" ? null : formulaTypeCtl.text;
    if (formulaTypeList.isNotEmpty &&
        currentValue != null &&
        !formulaTypeList.any((item) => item.categoryName == currentValue)) {
      currentValue = null;
    }

    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 16, right: 20),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant), // 设置边框颜色
          borderRadius: BorderRadius.circular(0), // 设置圆角
        ),
        child: DropdownButton<String?>(
            underline: SizedBox(),
            isExpanded: true,
            value: currentValue,
            items: formulaTypeList.isEmpty
                ? [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        localizedStrings.fPleaseSelectCategory,
                        style: getTextStyle(
                          color: colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    )
                  ]
                : [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(localizedStrings.fPleaseSelectCategory,
                          style: getTextStyle(
                            color: colorScheme.surfaceContainerHighest,
                          )),
                    ),
                    ...formulaTypeList.map((CategoryTypeList item) {
                      return DropdownMenuItem<String?>(
                        value: item.categoryName,
                        child: Text(
                          item.categoryName,
                          style: getTextStyle(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    })
                  ],
            onChanged: (value) {
              setState(() {
                formulaTypeCtl.text = value ?? "";
              });
            },
            style: getTextStyle()));
  }

  //选择原料下拉列表框
  showRawDropDownBtn(String hintText) {
    // 确保当前值在列表中，否则设为 null
    String? currentValue =
        rawMaterialCtl.text == "" ? null : rawMaterialCtl.text;
    if (rawDataList.isNotEmpty &&
        currentValue != null &&
        !rawDataList.any((item) =>
            '${item.materialId} ${item.materialName}' == currentValue)) {
      currentValue = null;
    }

    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 16, right: 20),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant), // 设置边框颜色
          borderRadius: BorderRadius.circular(0), // 设置圆角
        ),
        child: DropdownButton<String?>(
            underline: SizedBox(),
            isExpanded: true,
            // 更新判断值
            value: currentValue,
            items: rawDataList.isEmpty
                ? [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(localizedStrings.fSelectRawMaterialHint,
                          style: getTextStyle(
                            color: colorScheme.surfaceContainerHighest,
                          )),
                    )
                  ]
                : [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(localizedStrings.fSelectRawMaterialHint,
                          style: getTextStyle(
                            color: colorScheme.surfaceContainerHighest,
                          )),
                    ),
                    ...rawDataList.map((RawDataInfo item) {
                      // 拼接 materialId 和 materialName
                      String displayText =
                          '${item.materialId} ${item.materialName}';
                      return DropdownMenuItem<String?>(
                        // 使用拼接后的文本作为 value
                        value: displayText,
                        child: Text(
                          displayText,
                          style: getTextStyle(),
                        ),
                      );
                    })
                  ],
            onChanged: (value) {
              if (value == null) {
                setState(() {
                  rawMaterialCtl.text = "";
                });
                return;
              }
              setState(() {
                rawMaterialCtl.text = value;
                selectedRawDataInfo = rawDataList.firstWhere(
                  (item) => '${item.materialId} ${item.materialName}' == value,
                  orElse: () {
                    return RawDataInfo(
                      // 根据 RawDataInfo 类的构造函数传入必要的参数

                      materialId: '',
                      materialName: '',
                      categoryId: 0,
                      ingredient: '',
                      createdBy: '',
                      updatedBy: '',
                      remark: '',
                      recId: -1,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      remark1: '',
                      // 其他必要的参数
                    );
                  },
                );
              });
            },
            style: getTextStyle(
              color: colorScheme.onSurfaceVariant,
            )));
  }

  //输入框
  showInputBox(TextEditingController controller, String hintText) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: getTextStyle(
            color: colorScheme.surfaceContainerHighest, // 设置提示文本颜色
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
        ),
        style: getTextStyle(),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

// 显示编号和模式
  showCodeAndMode(double width) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(children: [
        SizedBox(
          width: width,
          height: 90,
          child: Column(children: [
            showItemNameWithStar(
                context, localizedStrings.fFmaIdLabel + ' ', true),
            showInputBox(formulaCodeCtl, localizedStrings.fInputFormulaIdHint),
          ]),
        ),
      ]),
      Row(children: [
        SizedBox(
          width: width,
          height: 90,
          child: Column(children: [
            showItemNameWithStar(
                context, localizedStrings.fFmaModeCol + " ", true),
            showModeDropDownButton([FormulaMode.wgt, FormulaMode.pct],
                localizedStrings.fSelectFormulaModeHint, formulaModeCtl)
          ]),
        ),
      ]),
    ]);
  }

// 显示名称和单位
  showNameAndUnit(double width) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(children: [
        SizedBox(
          width: width,
          height: 90,
          child: Column(children: [
            showItemNameWithStar(
                context, localizedStrings.fFmaNameLabel + " ", true),
            showInputBox(
                formulaNameCtl, localizedStrings.fInputFormulaNameHint),
          ]),
        ),
      ]),
      Row(children: [
        SizedBox(
          width: width,
          height: 90,
          child: Column(children: [
            showItemNameWithStar(context, localizedStrings.fWgtUnit, true),
            formulaModeCtl.text == FormulaMode.wgt.name
                ? showUnitDropDownButton(
                    [FormulaWgtUnit.g, FormulaWgtUnit.kg, FormulaWgtUnit.lb],
                    localizedStrings.fSelectUnitHint,
                    formulaUnitCtl)
                : Container(
                    height: 48,
                    padding: const EdgeInsets.only(left: 16, right: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: colorScheme.outlineVariant), // 设置边框颜色
                      borderRadius: BorderRadius.circular(0), // 设置圆角
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text("%",
                        style: getTextStyle(), textAlign: TextAlign.left),
                  )
          ]),
        ),
      ]),
    ]);
  }

  //显示自由模式和barcode
  showBarcodeAndFreeMode(double width) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(children: [
        SizedBox(
          width: width,
          height: 90,
          child: Column(children: [
            showItemNameWithStar(
                context, localizedStrings.fFmaBarcode + " ", false),
            showInputBox(formulaBarcodeCtl, localizedStrings.fFmaBarcode),
          ]),
        ),
      ]),
      Row(children: [
        SizedBox(
          width: width,
          height: 90,
          child: Column(children: [
            showItemNameWithStar(context, '', false),
            SizedBox(
              width: width,
              child: showTextButton(
                  context,
                  btnHeight,
                  freeMode
                      ? localizedStrings.btnNormalMode
                      : localizedStrings.btnFreeFormulaMode, () {
                performSwitchFreeMode();
              }, colorScheme.onPrimary, colorScheme.primary,
                  colorScheme.onPrimary),
            )
          ]),
        ),
      ]),
    ]);
  }

// 显示类型和加密  容器
  showTypeAndEncrypt(double width) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(children: [
        SizedBox(
          width: width,
          height: 90,
          child: Column(children: [
            showItemNameWithStar(
                context, localizedStrings.fFmaCategoryCol, false),
            Row(
              children: [
                Expanded(
                  child: showTypeDropDownButton(
                      localizedStrings.fPleaseSelectCategory, formulaTypeCtl),
                ),
                Container(
                  width: 10,
                ),
                showTextButton(
                    context, btnHeight, localizedStrings.fRawCategoryManagement,
                    () {
                  showFormulaTypeMgrDialog();
                }, colorScheme.onPrimary, colorScheme.primary,
                    colorScheme.onPrimary)
              ],
            )
          ]),
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SizedBox(
          width: width / 2,
          height: 90,
          child: Column(children: [
            showItemNameWithStar(context, '', false),
            Row(
              children: [
                Checkbox(
                  value: isEncrypted, // 假设这是一个状态变量，用于跟踪复选框的状态
                  onChanged: (bool? newValue) {
                    setState(() {
                      isEncrypted = newValue!;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    localizedStrings.fConfidential,
                    style: getTextStyle(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ]),
        ),
        SizedBox(
          width: width / 2,
          height: 90,
          child: Column(children: [
            showItemNameWithStar(context, '', false),
            Row(
              children: [
                Checkbox(
                  value: needContainer, // 假设这是一个状态变量，用于跟踪复选框的状态
                  onChanged: (bool? newValue) {
                    setState(() {
                      needContainer = newValue!;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    localizedStrings.fNeedContainer,
                    style: getTextStyle(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ]),
        ),
      ]),
    ]);
  }

  // 显示没有设备的提示对话框
  void showNoDeviceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return ShowNormalTipDialog(
          title: localizedStrings.fTipTitle,
          msg: localizedStrings.gTipNoDeviceAddFirst,
        );
      },
    );
  }

  void performPctMode() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return ShowNormalTipDialog(
          title: localizedStrings.fTipTitle,
          msg: localizedStrings.fConfirmClearAndEnterFreeModeMsg,
        );
      },
    ).then((value) {
      if (value == null) {
        return;
      }
      if (value) {
        // 保存
        setState(() {
          freeMode = !freeMode;
          addFormulaRawList.clear();
          //将模式改为wgt
          formulaModeCtl.text = FormulaMode.wgt.name;
          formulaUnitCtl.text = FormulaWgtUnit.g.name;
          totalWgt = 0;
        });
      } else {
        return;
      }
    });
  }

  void performSwitchFreeMode() {
    if (!freeMode && myAllScalesList.isEmpty) {
      showNoDeviceDialog();
      return;
    }

    if (formulaModeCtl.text == FormulaMode.pct.name) {
      //这个一定是正常模式
      performPctMode();
    } else {
      setState(() {
        freeMode = !freeMode;
      });
    }

    if (!freeMode && selScaleId != -1) {
      //切回正常模式要设置秤为-1，且不去请求称重
      stopWeightAndResetScaleId();
    }
    if (freeMode) {
      //要弹框选择秤
      showSelScaleDialog();
    }
  }

  // 停止称重并重置秤 ID
  void stopWeightAndResetScaleId() {
    PublicFunctions.stopWeight(selScaleId);
    setState(() {
      selScaleId = -1;
    });
  }

  // 向上移动元素
  void moveUp(int index) {
    if (index > 0) {
      setState(() {
        // 交换当前元素和上一个元素的位置
        final temp = addFormulaRawList[index];
        addFormulaRawList[index] = addFormulaRawList[index - 1];
        addFormulaRawList[index - 1] = temp;
        // 更新元素的顺序
        addFormulaRawList[index].sequence = index + 1;
        addFormulaRawList[index - 1].sequence = index;
      });
    }
  }

  // 向下移动元素
  void moveDown(int index) {
    if (index < addFormulaRawList.length - 1) {
      setState(() {
        // 交换当前元素和下一个元素的位置
        final temp = addFormulaRawList[index];
        addFormulaRawList[index] = addFormulaRawList[index + 1];
        addFormulaRawList[index + 1] = temp;
        // 更新元素的顺序
        addFormulaRawList[index].sequence = index + 1;
        addFormulaRawList[index + 1].sequence = index + 2;
      });
    }
  }

  void updateTotalWgt() {
    totalWgt = 0.0;
    if (addFormulaRawList.isEmpty) {
      return;
    }
    for (var item in addFormulaRawList) {
      totalWgt += item.wgt;
    }
    totalWgt = double.parse(totalWgt.toStringAsFixed(3));
  }

  showRawOrderRow(AddFormulaRawWgtInfo item, int index, bool isSelected) {
    return Container(
      height: 48,
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 22,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text('${index + 1}',
                style: getTextStyle(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                )),
          ),
          SizedBox(width: 10),
          showItemInfo(index, isSelected, item)
        ],
      ),
    );
  }

  TextSpan showItemTitle(bool isSelected, String title) {
    return TextSpan(
      text: '$title:  ',
      style: getTextStyle(
        color:
            isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
      ),
    );
  }

  TextSpan showItemContent(bool isSelected, String content) {
    return TextSpan(
      text: content,
      style: getTextStyle(
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
      ),
    );
  }

  Widget showItemDetail(bool isSelected, AddFormulaRawWgtInfo item) {
    return Expanded(
      child: Row(
        children: [
          SizedBox(width: 10),
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  showItemTitle(isSelected, localizedStrings.fFmaNameLabel),
                  showItemContent(isSelected, item.rawDataInfo.materialName!),
                  TextSpan(text: '    '),
                  showItemTitle(
                      isSelected,
                      formulaModeCtl.text == FormulaMode.wgt.name
                          ? localizedStrings.fWeightMode + ":"
                          : localizedStrings.fPctMode),
                  showItemContent(isSelected, item.wgt.toString()),
                  TextSpan(text: '    '),
                  showItemTitle(isSelected, localizedStrings.fAllowableError),
                  showItemContent(isSelected, item.error.toString()),
                  TextSpan(text: '    '),
                  showItemTitle(isSelected, localizedStrings.fIngredientRemark),
                  showItemContent(isSelected, item.rawDataInfo.ingredient!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void performSelectItem(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = -1;
      } else {
        selectedIndex = index;

        selectedRawDataInfo = addFormulaRawList[index].rawDataInfo; // 更新选中的原料信息
        rawMaterialCtl.text =
            '${selectedRawDataInfo!.materialId} ${selectedRawDataInfo!.materialName}';
        wgtCtl.text = addFormulaRawList[index].wgt.toString();
        errorCtl.text = addFormulaRawList[index].error.toString();
      }
    });
  }

  Widget showItemBtn(int index, bool isSelected) {
    return Row(
      children: [
        Container(
          height: 48,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  moveUp(index);
                },
                onHover: (bool hovering) {},
                child: Icon(
                  Icons.keyboard_arrow_up_sharp,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  size: 16,
                ),
              ),
              InkWell(
                hoverColor: colorScheme.primary.withValues(alpha: 0.1),
                onTap: () {
                  moveDown(index);
                },
                onHover: (bool hovering) {},
                child: Icon(
                  Icons.keyboard_arrow_down_sharp,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          iconSize: 24,
          onPressed: () {
            setState(() {
              selectedIndex = -1;
              addFormulaRawList.removeAt(index);
              updateTotalWgt();
            });
          },
          icon: Icon(
            Icons.delete_outline,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
        SizedBox(width: largePadding),
      ],
    );
  }

  Widget showItemInfo(int index, bool isSelected, AddFormulaRawWgtInfo item) {
    return Expanded(
        child: InkWell(
      onTap: () {
        performSelectItem(index);
      },
      child: Container(
        height: 48,
        alignment: Alignment.centerLeft,
        color:
            isSelected ? colorScheme.primary : colorScheme.surfaceContainerLow,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            showItemDetail(isSelected, item),
            showItemBtn(index, isSelected),
          ],
        ),
      ),
    ));
  }

  showContainerOrder() {
    return Container(
      height: 48,
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 22,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '0',
              style: getTextStyle(),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 48,
              alignment: Alignment.centerLeft,
              color: colorScheme.surfaceContainerLow,
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: localizedStrings.fFmaContainer,
                              style: getTextStyle(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void newFma() {
    setState(() {
      formulaCodeCtl.text = '';
      formulaNameCtl.text = '';
      formulaTypeCtl.text = '';
      formulaModeCtl.text = 'wgt';
      formulaUnitCtl.text = 'g';
      addFormulaRawList.clear();
      totalWgt = 0;
      remarkCtl.text = '';
      isEncrypted = false;
      needContainer = false;
      selectedRawDataInfo = null;
      selectedIndex = -1;
      rawMaterialCtl.clear();
      errorCtl.text = '';
      wgtCtl.text = '';
    });
  }

  // 显示添加部分的组件
  Widget showAddWidget(BoxConstraints constraints) {
    return Container(
        height: 360,
        width: (constraints.maxWidth - 20) / 30 * 14,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            SizedBox(
              height: 54,
              child: Row(children: [
                Expanded(
                    child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    localizedStrings.fSetRawMaterialBtn,
                    style: getTitleBoldStyle(),
                  ),
                )),
                TextButton(
                  onPressed: () {
                    showAddRawInfoDialog();
                  },
                  child: Text(localizedStrings.fAddRawMaterialBtn,
                      style: getTextStyle(
                        color: colorScheme.primary,
                      )),
                )
              ]),
            ),

            SizedBox(
              height: 90,
              width: constraints.maxWidth - 20,
              child: Row(children: [
                Expanded(
                  flex: 1,
                  child: Column(children: [
                    showItemNameWithStar(
                        context, localizedStrings.fSelectRawMaterialHint, true),
                    showRawDropDownBtn(
                      localizedStrings.fSelectRawMaterialHint,
                    )
                  ]),
                ),
                SizedBox(
                  width: 20,
                ),
                freeMode ? showScaleWgt() : showNormalWgt()
              ]),
            ),
            SizedBox(
              height: 90,
              child: Row(children: [
                Expanded(
                  flex: 1,
                  child: Column(children: [
                    SizedBox(
                      height: 42,
                      child: showItemNameWithStar(
                          context, localizedStrings.fAllowableError, true),
                    ),
                    SizedBox(
                        height: 48,
                        child: Row(children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {});
                              },
                              controller: errorCtl,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^(0|[1-9]\d*)(\.\d{0,4})?$')),
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(0.0))),
                                hintText: localizedStrings.fInputErrorHint,
                                hintStyle: getTextStyle(
                                  color: colorScheme.surfaceContainerHighest,
                                ),
                                prefixIcon: Container(
                                  width: 30,
                                  alignment: Alignment.center,
                                  child: Text(
                                    showErrorStr,
                                    style: getTextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                suffixIcon: Container(
                                    width: 50,
                                    alignment: Alignment.center,
                                    child: Center(
                                      child: Text(
                                        formulaModeCtl.text ==
                                                FormulaMode.wgt.name
                                            ? formulaUnitCtl.text
                                            : pctStrShow,
                                        style: getTextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    )),
                              ),
                              style: getTextStyle(),
                            ),
                          ),
                        ]))
                  ]),
                ),
                SizedBox(
                  width: 20,
                ),
                freeMode ? showFreeAddBtn() : showNormalAddBtn()
              ]),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
                height: 100,
                color: colorScheme.surfaceContainerLow,
                alignment: Alignment.centerLeft,
                child: Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.topLeft,
                    child: SelectableText(
                      selectedRawDataInfo == null
                          ? ""
                          : selectedRawDataInfo!.ingredient!,
                      style: getTextStyle(),
                    ))),

            // 其他组件
          ],
        ));
  }

  Widget showNormalAddBtn() {
    return Expanded(
        flex: 1,
        child: Column(children: [
          Container(
            height: 42,
          ),
          Row(children: [
            if (selectedIndex == -1)
              Expanded(
                  child: showTextButton(
                      context,
                      btnHeight,
                      localizedStrings.gBtnAdd,
                      (selectedRawDataInfo == null ||
                              wgtCtl.text == '' ||
                              errorCtl.text == '')
                          ? null
                          : () {
                              performAddBtn();
                            },
                      colorScheme.onPrimary,
                      colorScheme.primary,
                      colorScheme.onPrimary)),
            if (selectedIndex != -1)
              Expanded(
                  child: showTextButton(
                      context,
                      btnHeight,
                      localizedStrings.gBtnModify,
                      (selectedRawDataInfo == null ||
                              wgtCtl.text == '' ||
                              errorCtl.text == '')
                          ? null
                          : () {
                              performModifyBtn();
                            },
                      colorScheme.onPrimary,
                      colorScheme.primary,
                      colorScheme.onPrimary)),
            if (selectedIndex != -1)
              SizedBox(
                width: regularPadding,
              ),
            if (selectedIndex != -1)
              Expanded(
                  child: showTextButton(
                      context, btnHeight, localizedStrings.gBtnCancel, () {
                setState(() {
                  wgtCtl.text = '';
                  errorCtl.text = '';
                  rawMaterialCtl.clear();
                  selectedRawDataInfo = null;
                  selectedIndex = -1;
                });
              }, colorScheme.onPrimary, colorScheme.surfaceContainerHighest,
                      colorScheme.onPrimary))
          ]),
        ]));
  }

  Widget showFreeAddBtn() {
    return Expanded(
        flex: 1,
        child: Column(children: [
          Container(
            height: 42,
          ),
          Row(children: [
            if (selectedIndex == -1) showTareBtn(),
            if (selectedIndex == -1)
              SizedBox(
                width: smallPadding,
              ),
            if (selectedIndex == -1) showZeroBtn(),
            if (selectedIndex == -1)
              SizedBox(
                width: smallPadding,
              ),
            if (selectedIndex == -1)
              Expanded(
                  child: showTextButton(
                      context,
                      btnHeight,
                      localizedStrings.gBtnAdd,
                      (selectedRawDataInfo == null || errorCtl.text == '')
                          ? null
                          : () {
                              if (isWgtStartNotifier.value == false ||
                                  currentWgtStrNotifier.value == '----') {
                                showTipInfo(
                                    localizedStrings.fDeviceDisconnected,
                                    context);
                                return;
                              }
                              if ((currentWgtStrNotifier.value.contains('-') ||
                                  currentWgtStrNotifier.value == '0' ||
                                  currentWgtStrNotifier.value == '0.0' ||
                                  currentWgtStrNotifier.value == '0.00' ||
                                  currentWgtStrNotifier.value == '0.000')) {
                                showTipInfo(
                                    localizedStrings.gTipInvalidInput, context);
                                return;
                              }
                              final weight =
                                  double.tryParse(currentWgtStrNotifier.value);
                              if (weight == null) {
                                showTipInfo(
                                    localizedStrings.gTipInvalidInput, context);
                                return;
                              }
                              if (!myReqWeightCountine.msgBody!.isStable) {
                                showTipInfo(
                                    localizedStrings.gTipPleaseStableWeight,
                                    context);
                                return;
                              }

                              wgtCtl.text = currentWgtStrNotifier.value;
                              performAddBtn();
                              tareByScaleId(selScaleId);
                              // PublicFunctions.performTareWithScaleId(
                              //     selScaleId);
                            },
                      colorScheme.onPrimary,
                      colorScheme.primary,
                      colorScheme.onPrimary)),
            if (selectedIndex != -1)
              Expanded(
                  child: showTextButton(
                      context,
                      btnHeight,
                      localizedStrings.gBtnModify,
                      (selectedRawDataInfo == null ||
                              wgtCtl.text == '' ||
                              errorCtl.text == '')
                          ? null
                          : () {
                              performModifyBtn();
                            },
                      colorScheme.onPrimary,
                      colorScheme.primary,
                      colorScheme.onPrimary)),
            if (selectedIndex != -1)
              SizedBox(
                width: regularPadding,
              ),
            if (selectedIndex != -1)
              Expanded(
                  child: showTextButton(
                      context, btnHeight, localizedStrings.gBtnCancel, () {
                setState(() {
                  wgtCtl.text = '';
                  errorCtl.text = '';
                  rawMaterialCtl.clear();
                  selectedRawDataInfo = null;
                  selectedIndex = -1;
                });
              }, colorScheme.onPrimary, colorScheme.surfaceContainerHighest,
                      colorScheme.onPrimary))
          ]),
        ]));
  }

  Widget showTareBtn() {
    return IconButton(
      iconSize: 24,
      color: colorScheme.onPrimary,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          // 设置为矩形形状
          borderRadius: BorderRadius.zero, // 没有圆角，即正方形
        ),
        fixedSize: const Size(48, 48), // 设置固定大小
      ),
      onPressed: () {
        if (isWgtStartNotifier.value == false) {
          showTipInfo(localizedStrings.fDeviceDisconnected, context);
          return;
        }
        tareByScaleId(selScaleId);
        // PublicFunctions.performTareWithScaleId(selScaleId);
      },
      icon: getSvgIcon(performTareSvgIcon(), 40, 35, colorScheme.onPrimary),
    );
  }

  Widget showZeroBtn() {
    return IconButton(
      iconSize: 24,
      color: colorScheme.onPrimary,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          // 设置为矩形形状
          borderRadius: BorderRadius.zero, // 没有圆角，即正方形
        ),
        fixedSize: const Size(48, 48), // 设置固定大小
      ),
      onPressed: () {
        if (isWgtStartNotifier.value == false) {
          showTipInfo(localizedStrings.fDeviceDisconnected, context);
          return;
        }
        // PublicFunctions.performZeroWithScaleId(selScaleId);
        zeroByScaleId(selScaleId);
      },
      icon: getSvgIcon(performZeroSvgIcon(), 40, 35, colorScheme.onPrimary),
    );
  }

  Widget showNormalWgt() {
    return Expanded(
        flex: 1,
        child: Column(children: [
          SizedBox(
            height: 42,
            child: showItemNameWithStar(
                context,
                formulaModeCtl.text == FormulaMode.wgt.name
                    ? localizedStrings.fWeightMode + ':'
                    : localizedStrings.fPctMode + ':',
                true),
          ),
          SizedBox(
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: wgtCtl,
                      onChanged: (value) {
                        setState(() {});
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^(0|[1-9]\d*)(\.\d{0,4})?$')),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(0.0))),
                        hintText: formulaModeCtl.text == FormulaMode.wgt.name
                            ? localizedStrings.fInputWeightHint
                            : localizedStrings.fInputPercentageHint,
                        hintStyle: getTextStyle(
                          color: colorScheme.surfaceContainerHighest,
                        ),
                        suffixIcon: Container(
                            width: 50,
                            alignment: Alignment.center,
                            child: Center(
                              child: Text(
                                formulaModeCtl.text == FormulaMode.wgt.name
                                    ? formulaUnitCtl.text
                                    : pctStrShow,
                                style: getTextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )),
                      ),
                      style: getTextStyle(),
                    ),
                  ),
                ],
              ))
        ]));
  }

  Widget showScaleWgt() {
    if (selectedIndex != -1) return showNormalWgt();
    return Expanded(
        flex: 1,
        child: Column(children: [
          SizedBox(
              height: 42,
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                    height: 42,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(
                        left: regularPadding, right: regularPadding),
                    color: colorScheme.primary,
                    child: Text(
                      formulaModeCtl.text == FormulaMode.wgt.name
                          ? localizedStrings.fWeightMode + ':'
                          : localizedStrings.fPctMode + ':',
                      style: getTextStyle(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ))
                ],
              )),
          SizedBox(
              height: 48,
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                    height: 48,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(
                        left: regularPadding, right: regularPadding),
                    color: colorScheme.primary,
                    child: ValueListenableBuilder<String>(
                      valueListenable: currentWgtStrNotifier,
                      builder: (context, value, child) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft, // 保持文本左对齐
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
                                        .onPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ))
                ],
              ))
        ]));
  }

  void showAddRawInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return AddRawDialog();
      },
    ).then((value) {
      setState(() {});
    });
  }

  void showSelScaleDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return SelScaleDialog();
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          if (selScaleId != -1) {
            stopWeightAndResetScaleId();
          }
          selScaleId = value;
          PublicFunctions.getWeight(selScaleId);
        });
      }
    });
  }

  void performModifyBtn() {
    if (selectedRawDataInfo == null) {
      return;
    }
    double wgt = 0.0;
    if (wgtCtl.text != '') {
      wgt = double.parse(wgtCtl.text);
    }
    double error = 0.0;
    if (errorCtl.text != '') {
      error = double.parse(errorCtl.text);
    }

    AddFormulaRawWgtInfo tempInfo = AddFormulaRawWgtInfo(
        rawDataInfo: selectedRawDataInfo!,
        sequence: selectedIndex,
        wgt: wgt,
        error: error);
    setState(() {
      addFormulaRawList[selectedIndex] = tempInfo;
      updateTotalWgt();
      //清空输入框
      wgtCtl.text = '';
      errorCtl.text = '';
      rawMaterialCtl.clear();
      selectedRawDataInfo = null;
      selectedIndex = -1;
    });
  }

  void performAddBtn() {
    if (selectedRawDataInfo == null) {
      return;
    }
    double wgt = 0.0;
    if (wgtCtl.text != '') {
      wgt = double.parse(wgtCtl.text);
    }
    double error = 0.0;
    if (errorCtl.text != '') {
      error = double.parse(errorCtl.text);
    }

    int num = addFormulaRawList.length + 1;
    AddFormulaRawWgtInfo tempInfo = AddFormulaRawWgtInfo(
        rawDataInfo: selectedRawDataInfo!,
        sequence: num,
        wgt: wgt,
        error: error);
    setState(() {
      addFormulaRawList.add(tempInfo);
      updateTotalWgt();
      //清空输入框
      wgtCtl.text = '';
      errorCtl.text = '';
      rawMaterialCtl.clear();
      selectedRawDataInfo = null;
    });
  }

  //保存之前先检查是否有重复的配方ID和重复的Barcode
  void checkFmaIdAndBarcode() {
    ReqCheckFmaIdAndBarcode reqCheckFmaIdAndBarcode = ReqCheckFmaIdAndBarcode(
      recId: 0, //新增用0表示新增
      formulaId: formulaCodeCtl.text,
      formulaBarcode: formulaBarcodeCtl.text,
    );

    PublicFunctions.checkFmaIdAndBarcode(jsonEncode(reqCheckFmaIdAndBarcode));
  }

  //保存功能
  void saveFormula(int func) {
    //查找配方类别的ID
    int categoryId = 0;
    for (var item in formulaTypeList) {
      if (item.categoryName == formulaTypeCtl.text) {
        categoryId = item.categoryId;
        break;
      }
    }
    ReqFormulaHeader tempHeader = ReqFormulaHeader(
      formulaId: formulaCodeCtl.text,
      formulaKey: 0,
      formulaName: formulaNameCtl.text,
      categoryId: categoryId,
      formulaMode: formulaModeCtl.text,
      formulaUnit: formulaUnitCtl.text,
      totalWeight: totalWgt,
      materialCount: addFormulaRawList.length,
      isEncrypted: isEncrypted,
      needContainer: needContainer,
      createdBy: mySysUser.nickName,
      updatedBy: mySysUser.nickName,
      remark: remarkCtl.text,
      formulaBarcode: formulaBarcodeCtl.text,
    );
    ReqFormulaAddInfo tempReqAddF = ReqFormulaAddInfo(
      header: tempHeader,
      detail: [],
    );
    int no = 1;
    for (var item in addFormulaRawList) {
      ReqFormulaDetail tempDetail = ReqFormulaDetail();
      tempDetail.formulaId = formulaCodeCtl.text;
      tempDetail.materialId = item.rawDataInfo.materialId;
      tempDetail.materialWeight = item.wgt;

      tempDetail.materialPercentage = item.wgt;
      tempDetail.sequence = no++;
      tempDetail.allowableError = item.error;
      tempDetail.remark = '';

      tempReqAddF.detail!.add(tempDetail);
    }

    String jsonStr = formulaAddInfoToJson(tempReqAddF);
    PublicFunctions.addFormulaData(jsonStr);

    if (func == 1) {
      newFma();
    } else {
      Navigator.pop(context);
    }
  }

  TextStyle getTextStyle({Color? color}) {
    return Theme.of(context).textTheme.bodySmall!.apply(
          color: color ?? colorScheme.onSurface,
        );
  }

  TextStyle getTitleBoldStyle({Color? color}) {
    return Theme.of(context).textTheme.labelMedium!.apply(
          color: color ?? colorScheme.onSurface,
        );
  }

  // 显示顺序和删除按钮
  Widget showOrderWidget(BoxConstraints constraints) {
    return Container(
        height: 360,
        width: (constraints.maxWidth - 20) / 30 * 15,
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          children: [
            SizedBox(
              height: 54,
              child: Row(children: [
                Expanded(
                    child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    localizedStrings.fIngredientOrder,
                    style: getTitleBoldStyle(),
                  ),
                )),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formulaModeCtl.text == FormulaMode.wgt.name
                        ? '${localizedStrings.fTotalWeightLabel} :  ${totalWgt.toString()} ${formulaUnitCtl.text}'
                        : '${localizedStrings.fTotalWeightLabel} :  ${totalWgt.toString()} %',
                    style: getTitleBoldStyle(),
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                    style: TextButton.styleFrom(
                      fixedSize: const Size(100, 40),
                      backgroundColor: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                        side: BorderSide(
                          color: colorScheme.outline, // 设置边框颜色
                          width: 1, // 设置边框宽度
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        addFormulaRawList.clear();
                        totalWgt = 0;
                        errorCtl.text = '';
                        wgtCtl.text = '';
                        rawMaterialCtl.clear();
                        selectedIndex = -1;
                      });
                    },
                    child: Text(
                      localizedStrings.fClearBtn,
                      style: getTextStyle(),
                      overflow: TextOverflow.ellipsis,
                    ))
              ]),
            ),
            if (needContainer) showContainerOrder(),
            SizedBox(
              height: needContainer ? 240 : 300,
              child: Scrollbar(
                controller: _scrollController1,
                // 始终显示滚动条
                thumbVisibility: true,
                // 设置滚动条的厚度
                thickness: 8,
                // 设置滚动条的圆角
                radius: const Radius.circular(4),
                child: ListView.builder(
                  controller: _scrollController1,
                  itemCount: addFormulaRawList.length,
                  itemBuilder: (context, index) {
                    final item = addFormulaRawList[index];
                    final isSelected = index == selectedIndex;
                    return showRawOrderRow(item, index, isSelected);
                  },
                ),
              ),
            ),
          ],
        ));
  }

  Widget showBtnRow() {
    return SizedBox(
        height: 86,
        child: Center(
            child: SizedBox(
          width: 400,
          height: 48,
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
                onPressed: formulaCodeCtl.text == '' ||
                        formulaNameCtl.text == '' ||
                        // formulaTypeCtl.text == '' ||
                        formulaModeCtl.text == '' ||
                        formulaUnitCtl.text == '' ||
                        addFormulaRawList.isEmpty
                    ? null
                    : (formulaModeCtl.text == FormulaMode.pct.name &&
                            totalWgt != 100)
                        ? null
                        : () {
                            //先判断是否有重复的ID和名称
                            //先判断formulaDataList是否为空
                            checkFmaIdAndBarcode();
                            // saveFormula(1);
                            //清空所有的内容，做一个干净的配方
                          },
                child: Text(
                  localizedStrings.gBtnSave,
                  style: getTextStyle(
                    color: colorScheme.onPrimary,
                  ),
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
                  foregroundColor: colorScheme.onSurfaceVariant,
                  backgroundColor: colorScheme.outline,
                  fixedSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  localizedStrings.fBackBtn,
                  style: getTextStyle(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ]),
        )));
  }

  Widget showFmaRemark() {
    return Container(
        height: 114,
        alignment: Alignment.centerLeft,
        child: Column(children: [
          Container(
              height: 42,
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(children: [
                Expanded(
                    child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    localizedStrings.fRemarkCol,
                    style: getTitleBoldStyle(),
                  ),
                )),
              ])),
          Container(
              height: 72,
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(children: [
                Expanded(
                    child: SizedBox(
                  height: 72,
                  child: TextField(
                    controller: remarkCtl,
                    style: getTextStyle(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0.0))),
                      hintText: localizedStrings.fInputRemarkHint,
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    maxLines: 5,
                  ),
                ))
              ]))
        ]));
  }

  Widget showMiddlePart(double widthFor3Item) {
    return Expanded(
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true, // 始终显示滚动条
        thickness: 8, // 设置滚动条的厚度
        radius: const Radius.circular(4), // 设置滚动条的圆角
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  height: 202,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        showCodeAndMode(widthFor3Item),
                        showNameAndUnit(widthFor3Item),
                        showTypeAndEncrypt(widthFor3Item + 150),
                        showBarcodeAndFreeMode(widthFor3Item),
                      ])),
              Divider(
                height: 1,
                color: colorScheme.surfaceDim,
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        showAddWidget(constraints),
                        Container(
                          height: 360,
                          padding: const EdgeInsets.only(top: 24),
                          child: VerticalDivider(
                            width: 1,
                            color: colorScheme.surfaceContainerLow,
                          ),
                        ),
                        showOrderWidget(constraints),
                      ],
                    ),
                  );
                },
              ),
              showFmaRemark(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double widthFor3Item =
        (width - 250) / 4 > 380 ? 380 : (width - 250) / 4;
    return Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: Container(
          color: colorScheme.surface,
          child: Column(
            children: [
              pageHeadInfo(context, width - headWidthPadding,
                  localizedStrings.fAddFmaBtn, '', () {
                if (mounted) {
                  Navigator.pop(context);
                }
              }, showHelp: false),
              Divider(
                height: 1,
                color: colorScheme.surfaceDim,
              ),
              showMiddlePart(widthFor3Item),
              showBtnRow()
            ],
          ),
          // ),
        ));
  }
}

// 新增配方时选择的临时原料列表
class AddFormulaRawWgtInfo {
  RawDataInfo rawDataInfo; // 原料信息
  double wgt; // 权重
  int sequence;
  double error; //误差

  bool isSelected;

  AddFormulaRawWgtInfo(
      {required this.rawDataInfo,
      required this.sequence,
      required this.wgt,
      required this.error,
      this.isSelected = false});
}
