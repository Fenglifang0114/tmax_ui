import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/dialog/fma_type_mgr.dart';
import 'package:t_max/widget/common_widget.dart';

/// 新增/编辑配方 顶部基础信息与配置表单组件
class AddFormulaHeaderForm extends StatelessWidget {
  final TextEditingController formulaCodeCtl;
  final TextEditingController formulaNameCtl;
  final TextEditingController formulaModeCtl;
  final TextEditingController formulaUnitCtl;
  final TextEditingController formulaTypeCtl;
  final TextEditingController formulaBarcodeCtl;
  final bool isEncrypted;
  final bool needContainer;
  final bool freeMode;
  final double widthFor3Item;
  final bool hasRawItems;
  final Function(bool) onEncryptedChanged;
  final Function(bool) onNeedContainerChanged;
  final VoidCallback onSwitchFreeMode;
  final VoidCallback onClearRawList;
  final VoidCallback onChanged;

  const AddFormulaHeaderForm({
    super.key,
    required this.formulaCodeCtl,
    required this.formulaNameCtl,
    required this.formulaModeCtl,
    required this.formulaUnitCtl,
    required this.formulaTypeCtl,
    required this.formulaBarcodeCtl,
    required this.isEncrypted,
    required this.needContainer,
    required this.freeMode,
    required this.widthFor3Item,
    required this.hasRawItems,
    required this.onEncryptedChanged,
    required this.onNeedContainerChanged,
    required this.onSwitchFreeMode,
    required this.onClearRawList,
    required this.onChanged,
  });

  static const Map<FormulaMode, String> _formulaModeTranslation = {
    FormulaMode.wgt: "重量模式",
    FormulaMode.pct: "百分比模式",
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    TextStyle getTextStyle({Color? color}) {
      return textTheme.bodySmall!.apply(
        color: color ?? colorScheme.onSurface,
      );
    }

    Widget showInputBox(TextEditingController controller, String hintText) {
      return SizedBox(
        height: 48,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: getTextStyle(
              color: colorScheme.surfaceContainerHighest,
            ),
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0))),
          ),
          style: getTextStyle(),
          onChanged: (value) => onChanged(),
        ),
      );
    }

    Widget showModeDropDownButton(List<FormulaMode> items, String hintText,
        TextEditingController valueCtl) {
      return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 16, right: 20),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(0),
        ),
        child: DropdownButton<FormulaMode>(
          isExpanded: true,
          value: items.firstWhere(
              (mode) => mode.toString().split('.').last == valueCtl.text,
              orElse: () => items[0]),
          hint: Text(hintText),
          underline: const SizedBox.shrink(),
          items: items.map((FormulaMode item) {
            return DropdownMenuItem<FormulaMode>(
              value: item,
              child: Text(
                _formulaModeTranslation[item] ??
                    (item == FormulaMode.wgt
                        ? localizedStrings.fWeightMode
                        : localizedStrings.fPctMode),
                style: getTextStyle(),
              ),
            );
          }).toList(),
          onChanged: freeMode
              ? null
              : (FormulaMode? newValue) {
                  if (newValue != null) {
                    if (!hasRawItems) {
                      valueCtl.text = newValue.toString().split('.').last;
                      onChanged();
                    } else {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return ShowNormalTipDialog(
                            title: localizedStrings.fTipTitle,
                            msg: localizedStrings.fSwitchModeClearMsg,
                          );
                        },
                      ).then((value) {
                        if (value == true) {
                          valueCtl.text = newValue.toString().split('.').last;
                          onClearRawList();
                          onChanged();
                        }
                      });
                    }
                  }
                },
        ),
      );
    }

    Widget showUnitDropDownButton(List<FormulaWgtUnit> items, String hintText,
        TextEditingController valueCtl) {
      return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 16, right: 20),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(0),
        ),
        child: DropdownButton<FormulaWgtUnit>(
          isExpanded: true,
          value: items.firstWhere(
              (mode) => mode.toString().split('.').last == valueCtl.text,
              orElse: () => items[0]),
          hint: Text(hintText),
          underline: const SizedBox.shrink(),
          items: items.map((FormulaWgtUnit item) {
            return DropdownMenuItem<FormulaWgtUnit>(
              value: item,
              child: Text(
                item.name,
                style: getTextStyle(),
              ),
            );
          }).toList(),
          onChanged: (FormulaWgtUnit? newValue) {
            if (newValue != null) {
              valueCtl.text = newValue.name;
              onChanged();
            }
          },
        ),
      );
    }

    Widget showTypeDropDownButton(
        String hintText, TextEditingController valueCtl) {
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
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(0),
        ),
        child: DropdownButton<String?>(
          underline: const SizedBox(),
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
                    child: Text(
                      localizedStrings.fPleaseSelectCategory,
                      style: getTextStyle(
                        color: colorScheme.surfaceContainerHighest,
                      ),
                    ),
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
            formulaTypeCtl.text = value ?? "";
            onChanged();
          },
          style: getTextStyle(),
        ),
      );
    }

    Widget showCodeAndMode(double width) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(children: [
            SizedBox(
              width: width,
              height: 90,
              child: Column(children: [
                showItemNameWithStar(
                    context, "${localizedStrings.fFmaIdLabel} ", true),
                showInputBox(
                    formulaCodeCtl, localizedStrings.fInputFormulaIdHint),
              ]),
            ),
          ]),
          Row(children: [
            SizedBox(
              width: width,
              height: 90,
              child: Column(children: [
                showItemNameWithStar(
                    context, "${localizedStrings.fFmaModeCol} ", true),
                showModeDropDownButton([FormulaMode.wgt, FormulaMode.pct],
                    localizedStrings.fSelectFormulaModeHint, formulaModeCtl)
              ]),
            ),
          ]),
        ],
      );
    }

    Widget showNameAndUnit(double width) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(children: [
            SizedBox(
              width: width,
              height: 90,
              child: Column(children: [
                showItemNameWithStar(
                    context, "${localizedStrings.fFmaNameLabel} ", true),
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
                    ? showUnitDropDownButton([
                        FormulaWgtUnit.g,
                        FormulaWgtUnit.kg,
                        FormulaWgtUnit.lb
                      ], localizedStrings.fSelectUnitHint, formulaUnitCtl)
                    : Container(
                        height: 48,
                        padding: const EdgeInsets.only(left: 16, right: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text("%",
                            style: getTextStyle(), textAlign: TextAlign.left),
                      )
              ]),
            ),
          ]),
        ],
      );
    }

    Widget showTypeAndEncrypt(double width) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
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
                          localizedStrings.fPleaseSelectCategory,
                          formulaTypeCtl),
                    ),
                    const SizedBox(width: 10),
                    showTextButton(
                      context,
                      btnHeight,
                      localizedStrings.fRawCategoryManagement,
                      () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) =>
                              const FmaTypeMgrDialog(),
                        ).then((_) => onChanged());
                      },
                      colorScheme.onPrimary,
                      colorScheme.primary,
                      colorScheme.onPrimary,
                    )
                  ],
                )
              ]),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: width / 2,
                height: 90,
                child: Column(children: [
                  showItemNameWithStar(context, '', false),
                  Row(
                    children: [
                      Checkbox(
                        value: isEncrypted,
                        onChanged: (bool? newValue) {
                          if (newValue != null) {
                            onEncryptedChanged(newValue);
                          }
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
                        value: needContainer,
                        onChanged: (bool? newValue) {
                          if (newValue != null) {
                            onNeedContainerChanged(newValue);
                          }
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
            ],
          ),
        ],
      );
    }

    Widget showBarcodeAndFreeMode(double width) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(children: [
            SizedBox(
              width: width,
              height: 90,
              child: Column(children: [
                showItemNameWithStar(
                    context, "${localizedStrings.fFmaBarcode} ", false),
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
                        : localizedStrings.btnFreeFormulaMode,
                    onSwitchFreeMode,
                    colorScheme.onPrimary,
                    colorScheme.primary,
                    colorScheme.onPrimary,
                  ),
                )
              ]),
            ),
          ]),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      height: 202,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          showCodeAndMode(widthFor3Item),
          showNameAndUnit(widthFor3Item),
          showTypeAndEncrypt(widthFor3Item + 150),
          showBarcodeAndFreeMode(widthFor3Item),
        ],
      ),
    );
  }
}
