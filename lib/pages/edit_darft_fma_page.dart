//因为含有暂存的配方，所以要限制修改

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/f_raw_name.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/dialog/add_raw_info_dialog.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/dialog/fma_type_mgr.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dialog_head_style.dart';
import '../data/language.dart';

typedef EditDraftFmaPage = EditDarftFmaPage;

class EditDarftFmaPage extends StatefulWidget {
  final FormulaInfoDb editFormulaInfo;

  const EditDarftFmaPage({
    required this.editFormulaInfo,
    super.key,
  });

  @override
  State<EditDarftFmaPage> createState() => EditDarftFmaPageState();
}

class EditDarftFmaPageState extends State<EditDarftFmaPage> {
  TextEditingController formulaCodeCtl = TextEditingController();
  TextEditingController formulaNameCtl = TextEditingController();
  TextEditingController formulaModeCtl = TextEditingController(text: 'wgt');
  TextEditingController formulaUnitCtl = TextEditingController(text: 'g');
  TextEditingController formulaTypeCtl = TextEditingController();
  TextEditingController rawMaterialCtl = TextEditingController();
  TextEditingController formulaBarcodeCtl = TextEditingController(); // 配方条码

  TextEditingController wgtCtl = TextEditingController(); // 权重
  TextEditingController errorCtl = TextEditingController(); // 误差
  TextEditingController remarkCtl = TextEditingController(); // 备注

  bool isEncrypted = false; // 保密初始值为 false
  bool needContainer = false; // 保密初始值为 false
  bool isHaveDarft = true; // 是否有草稿配方
  RawDataInfo? selectedRawDataInfo;
  List<AddFormulaRawWgtInfo> addFormulaRawList = [];
  double totalWgt = 0.0; // 总权重
  // 创建一个映射表，将枚举值与翻译关联起来
  Map<FormulaMode, String> formulaModeTranslation = {
    FormulaMode.wgt: localizedStrings.fWeightMode,
    FormulaMode.pct: localizedStrings.fPctMode,
  };

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    formulaCodeCtl.text = widget.editFormulaInfo.header!.formulaId!;
    formulaBarcodeCtl.text = widget.editFormulaInfo.header!.formulaBarcode!;
    formulaNameCtl.text = widget.editFormulaInfo.header!.formulaName!;
    formulaModeCtl.text = widget.editFormulaInfo.header!.formulaMode!;
    formulaUnitCtl.text = widget.editFormulaInfo.header!.formulaUnit!;
    String fmaTypeName =
        getFmaTypeName(widget.editFormulaInfo.header!.categoryId!);
    formulaTypeCtl.text = fmaTypeName;
    isEncrypted = widget.editFormulaInfo.header!.isEncrypted!;
    needContainer = widget.editFormulaInfo.header!.needContainer!;
    remarkCtl.text = widget.editFormulaInfo.header!.remark!;

    for (var rawInfo in widget.editFormulaInfo.details!) {
      RawDataInfo thisRaw = getRawData(rawInfo.materialId!);
      String rawName = getRawName(thisRaw.materialId!);

      addFormulaRawList.add(AddFormulaRawWgtInfo(
        sequence: rawInfo.sequence!,
        wgt: rawInfo.materialPercentage!,
        error: rawInfo.allowableError!,
        isSelected: false,
        rawDataInfo: RawDataInfo(
            recId: rawInfo.recId!,
            materialId: rawInfo.materialId!,
            materialName: rawName, //-------------------
            categoryId: 0, // 假设为0，实际应用中可能需要从其他地方获取
            ingredient: rawInfo.remark!,
            createdBy: thisRaw.createdBy,
            updatedBy: thisRaw.updatedBy,
            remark: thisRaw.remark,
            createdAt: thisRaw.createdAt,
            updatedAt: thisRaw.updatedAt,
            remark1: rawInfo.remark1! // 假设为默认值，实际应用中可能需要从其他地方获取

            ),
      ));
    }

    if (widget.editFormulaInfo.header!.formulaMode == FormulaMode.pct.name) {
      totalWgt = 100;
    } else {
      totalWgt = widget.editFormulaInfo.header!.totalWeight!; // 总权重
    }
  }

  @override
  void dispose() {
    formulaBarcodeCtl.dispose();
    super.dispose();

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
  }

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
          border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
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
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              );
            }).toList(),
            onChanged: isHaveDarft
                ? null
                : (FormulaMode? newValue) {
                    // 处理下拉列表项选择事件
                    if (newValue != null) {
                      // 在这里处理选择的值
                      //这里要提示修改模式时，需要把原来的数据清空

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
                            // 保存
                            setState(() {
                              valueCtl.text = newValue
                                  .toString()
                                  .split('.')
                                  .last; // 更新 valueCtl 的值
                              addFormulaRawList.clear();
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
          border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
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
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              );
            }).toList(),
            onChanged: isHaveDarft
                ? null
                : (FormulaWgtUnit? newValue) {
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
    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 16, right: 20),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
          borderRadius: BorderRadius.circular(0), // 设置圆角
        ),
        child: DropdownButton(
          underline: SizedBox(),
          isExpanded: true,
          value: formulaTypeCtl.text == "" ? null : formulaTypeCtl.text,
          items: formulaTypeList.isEmpty
              ? [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      localizedStrings.fPleaseSelectCategory,
                      style: Theme.of(context).textTheme.bodySmall!.apply(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                    ),
                  )
                ]
              : [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(localizedStrings.fPleaseSelectCategory,
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            )),
                  ),
                  ...formulaTypeList.map((CategoryTypeList item) {
                    return DropdownMenuItem<String>(
                      value: item.categoryName,
                      child: Text(item.categoryName,
                          style: Theme.of(context).textTheme.bodySmall!.apply(
                                color: Theme.of(context).colorScheme.onSurface,
                              )),
                    );
                  })
                ],
          onChanged: isHaveDarft
              ? null
              : (value) {
                  if (value == null) {
                    setState(() {
                      formulaTypeCtl.text = "";
                    });
                  }
                  setState(() {
                    formulaTypeCtl.text = value.toString();
                  });
                },
          style: Theme.of(context).textTheme.bodySmall!.apply(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ));
  }

  //选择原料下拉列表框
  showRawDropDownBtn(String hintText) {
    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 16, right: 20),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
          borderRadius: BorderRadius.circular(0), // 设置圆角
        ),
        child: DropdownButton(
          underline: SizedBox(),
          isExpanded: true,
          // 更新判断值
          value: rawMaterialCtl.text == "" ? null : rawMaterialCtl.text,
          items: rawDataList.isEmpty
              ? [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(localizedStrings.fSelectRawMaterialHint,
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            )),
                  )
                ]
              : [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(localizedStrings.fSelectRawMaterialHint,
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            )),
                  ),
                  ...rawDataList.map((RawDataInfo item) {
                    // 拼接 materialId 和 materialName
                    String displayText =
                        '${item.materialId} ${item.materialName}';
                    return DropdownMenuItem<String>(
                      // 使用拼接后的文本作为 value
                      value: displayText,
                      child: Text(
                        displayText,
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    );
                  })
                ],
          onChanged: isHaveDarft
              ? null
              : (value) {
                  if (value == null) return;
                  setState(() {
                    rawMaterialCtl.text = value.toString();
                    selectedRawDataInfo = rawDataList.firstWhere(
                      (item) =>
                          '${item.materialId} ${item.materialName}' == value,
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
          style: Theme.of(context).textTheme.bodySmall!.apply(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ));
  }

  //输入框
  showInputBox(TextEditingController controller, String hintText,
      {bool enable = true}) {
    return SizedBox(
      height: 48,
      child: TextField(
        enabled: enable,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest, // 设置提示文本颜色
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
        ),
        style: Theme.of(context).textTheme.bodySmall!.apply(
              color: Theme.of(context).colorScheme.onSurface,
            ),
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
            showInputBox(formulaCodeCtl, localizedStrings.fInputFormulaIdHint,
                enable: false),
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
            showInputBox(formulaNameCtl, localizedStrings.fInputFormulaNameHint,
                enable: false),
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
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant), // 设置边框颜色
                      borderRadius: BorderRadius.circular(0), // 设置圆角
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text("%",
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        textAlign: TextAlign.left),
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
                    context,
                    btnHeight,
                    localizedStrings.fRawCategoryManagement,
                    isHaveDarft
                        ? null
                        : () {
                            showFormulaTypeMgrDialog();
                          },
                    Theme.of(context).colorScheme.onPrimary,
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.onPrimary)
              ],
            )
          ]),
        ),
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SizedBox(
          width: width / 3,
          height: 90,
          child: Column(children: [
            showItemNameWithStar(
                context, localizedStrings.fFmaBarcode + " ", false),
            showInputBox(formulaBarcodeCtl, localizedStrings.fFmaBarcode,
                enable: false),
          ]),
        ),
        SizedBox(
          width: width / 3,
          height: 90,
          child: Column(children: [
            showItemNameWithStar(context, '', false),
            Row(
              children: [
                Checkbox(
                  value: isEncrypted, // 假设这是一个状态变量，用于跟踪复选框的状态
                  onChanged: isHaveDarft
                      ? null
                      : (bool? newValue) {
                          setState(() {
                            isEncrypted = newValue!;
                          });
                        },
                ),
                Expanded(
                  child: Text(
                    localizedStrings.fConfidential,
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ]),
        ),
        SizedBox(
          width: width / 3,
          height: 90,
          child: Column(children: [
            showItemNameWithStar(context, '', false),
            Row(
              children: [
                Checkbox(
                  value: needContainer, // 假设这是一个状态变量，用于跟踪复选框的状态
                  onChanged: isHaveDarft
                      ? null
                      : (bool? newValue) {
                          setState(() {
                            needContainer = newValue!;
                          });
                        },
                ),
                Expanded(
                  child: Text(
                    localizedStrings.fNeedContainer,
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
              child: InkWell(
            onTap: () {
              setState(() {
                if (selectedIndex == index && !isHaveDarft) {
                  selectedIndex = -1;
                } else {
                  selectedIndex = index;

                  selectedRawDataInfo =
                      addFormulaRawList[index].rawDataInfo; // 更新选中的原料信息
                  rawMaterialCtl.text =
                      '${selectedRawDataInfo!.materialId} ${selectedRawDataInfo!.materialName}';
                  wgtCtl.text = addFormulaRawList[index].wgt.toString();
                  errorCtl.text = addFormulaRawList[index].error.toString();
                }
              });
            },
            child: Container(
              height: 48,
              alignment: Alignment.centerLeft,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerLow,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
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
                                  text: localizedStrings.fFmaNameLabel + ':  ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.5),
                                      ),
                                ),
                                TextSpan(
                                  text: item.rawDataInfo.materialName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      ),
                                ),
                                TextSpan(text: '    '),
                                TextSpan(
                                  text: formulaModeCtl.text ==
                                          FormulaMode.wgt.name
                                      ? localizedStrings.fWeightMode + ":"
                                      : localizedStrings.fPctMode + ":",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.5),
                                      ),
                                ),
                                TextSpan(
                                  text: item.wgt.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      ),
                                ),
                                TextSpan(text: '    '),
                                TextSpan(
                                  text: localizedStrings.fAllowableError + ':',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.5),
                                      ),
                                ),
                                TextSpan(
                                  text: item.error.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      ),
                                ),
                                TextSpan(text: '    '),
                                TextSpan(
                                  text:
                                      localizedStrings.fIngredientRemark + ": ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.5),
                                      ),
                                ),
                                TextSpan(
                                  text: item.rawDataInfo.ingredient,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  isHaveDarft
                      ? SizedBox()
                      : Row(
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
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                      size: 16,
                                    ),
                                  ),
                                  InkWell(
                                    hoverColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1),
                                    onTap: () {
                                      moveDown(index);
                                    },
                                    onHover: (bool hovering) {},
                                    child: Icon(
                                      Icons.keyboard_arrow_down_sharp,
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              child: IconButton(
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
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
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
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '0',
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 48,
              alignment: Alignment.centerLeft,
              color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                            style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                ),
                          ),
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
                    style: Theme.of(context).textTheme.labelMedium!.apply(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                )),
                TextButton(
                  onPressed: isHaveDarft
                      ? null
                      : () {
                          showAddRawInfoDialog();
                        },
                  child: Text(localizedStrings.fAddRawMaterialBtn,
                      style: Theme.of(context).textTheme.bodySmall!.apply(
                            color: Theme.of(context).colorScheme.primary,
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
                Expanded(
                    flex: 1,
                    child: Column(children: [
                      showItemNameWithStar(
                          context,
                          formulaModeCtl.text == FormulaMode.wgt.name
                              ? localizedStrings.fWeightMode + ':'
                              : localizedStrings.fPctMode + ':',
                          true),
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(0.0))),
                                    hintText: formulaModeCtl.text ==
                                            FormulaMode.wgt.name
                                        ? localizedStrings.fInputWeightHint
                                        : localizedStrings.fInputPercentageHint,
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .apply(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        )),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                              ),
                            ],
                          ))
                    ]))
              ]),
            ),
            SizedBox(
              height: 90,
              child: Row(children: [
                Expanded(
                  flex: 1,
                  child: Column(children: [
                    showItemNameWithStar(
                        context, localizedStrings.fAllowableError, true),
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
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                    ),
                                prefixIcon: Container(
                                  width: 30,
                                  alignment: Alignment.center,
                                  child: Text(
                                    showErrorStr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .apply(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    )),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .apply(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          ),
                        ]))
                  ]),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
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
                                  Theme.of(context).colorScheme.onPrimary,
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.onPrimary)),
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
                                  Theme.of(context).colorScheme.onPrimary,
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.onPrimary)),
                        if (selectedIndex != -1)
                          SizedBox(
                            width: regularPadding,
                          ),
                        if (selectedIndex != -1)
                          Expanded(
                              child: showTextButton(context, btnHeight,
                                  localizedStrings.gBtnCancel, () {
                            setState(() {
                              wgtCtl.text = '';
                              errorCtl.text = '';
                              rawMaterialCtl.clear();
                              selectedRawDataInfo = null;
                              selectedIndex = -1;
                            });
                          },
                                  Theme.of(context).colorScheme.onPrimary,
                                  Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  Theme.of(context).colorScheme.onPrimary))
                      ]),
                    ]))
              ]),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
                height: 100,
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                alignment: Alignment.centerLeft,
                child: Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.topLeft,
                    child: SelectableText(
                      selectedRawDataInfo == null
                          ? ""
                          : selectedRawDataInfo!.ingredient!,
                      style: Theme.of(context).textTheme.bodySmall!.apply(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ))),

            // 其他组件
          ],
        ));
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

  //保存功能
  void saveFormula(int func) {
    if (formulaDataList.isEmpty) {
      return;
    }

    //查找配方类别的ID
    int categoryId = 0;
    for (var item in formulaTypeList) {
      if (item.categoryName == formulaTypeCtl.text) {
        categoryId = item.categoryId;
        break;
      }
    }
    ReqFormulaHeader tempHeader = ReqFormulaHeader(
      recId: widget.editFormulaInfo.header!.recId,
      formulaId: formulaCodeCtl.text,
      formulaKey: widget.editFormulaInfo.header!.formulaKey,
      formulaName: formulaNameCtl.text,
      categoryId: categoryId,
      formulaMode: formulaModeCtl.text,
      formulaUnit: formulaUnitCtl.text,
      totalWeight: totalWgt,
      materialCount: addFormulaRawList.length,
      isEncrypted: isEncrypted,
      needContainer: needContainer,
      createdBy: widget.editFormulaInfo.header!.createdBy,
      updatedBy: mySysUser.nickName!,
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
    PublicFunctions.editFormulaData(jsonStr);

    Navigator.pop(context);
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
                    style: Theme.of(context).textTheme.labelMedium!.apply(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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
                    style: Theme.of(context).textTheme.labelMedium!.apply(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                    style: TextButton.styleFrom(
                      fixedSize: const Size(100, 40),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                        side: BorderSide(
                          color:
                              Theme.of(context).colorScheme.outline, // 设置边框颜色
                          width: 1, // 设置边框宽度
                        ),
                      ),
                    ),
                    onPressed: isHaveDarft
                        ? null
                        : () {
                            setState(() {
                              addFormulaRawList.clear();
                            });
                          },
                    child: Text(
                      localizedStrings.fClearBtn,
                      style: Theme.of(context).textTheme.bodySmall!.apply(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ))
              ]),
            ),
            if (needContainer) showContainerOrder(),
            SizedBox(
              height: needContainer ? 240 : 300,
              child: ListView.builder(
                itemCount: addFormulaRawList.length,
                itemBuilder: (context, index) {
                  final item = addFormulaRawList[index];
                  final isSelected = index == selectedIndex;
                  return showRawOrderRow(item, index, isSelected);
                },
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
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
                            saveFormula(1);
                          },
                child: Text(
                  localizedStrings.gBtnSave,
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
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
                  foregroundColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  backgroundColor: Theme.of(context).colorScheme.outline,
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
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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
                    style: Theme.of(context).textTheme.labelMedium!.apply(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0.0))),
                      hintText: localizedStrings.fInputRemarkHint,
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    maxLines: 5,
                  ),
                ))
              ]))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double widthFor3Item =
        (width - 300) / 3 > 380 ? 380 : (width - 300) / 3;
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        body: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              ...dialogHeadStyle(
                context,
                localizedStrings.fEditFmaBtn,
                false,
              ),
              Expanded(
                child: SingleChildScrollView(
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
                                showTypeAndEncrypt(widthFor3Item + 200),
                              ])),
                      Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.outline,
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLow,
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
