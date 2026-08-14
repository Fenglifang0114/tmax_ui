import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/reqweightdata_data.dart';
import 'package:t_max/dialog/add_raw_info_dialog.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/modules/formula/services/scale_live_stream_service.dart';
import 'package:t_max/widget/common_widget.dart';

/// 新增/编辑配方 原料添加与实时抓重/去皮控制组件
class AddFormulaRawAdder extends StatelessWidget {
  final BoxConstraints constraints;
  final TextEditingController rawMaterialCtl;
  final TextEditingController wgtCtl;
  final TextEditingController errorCtl;
  final TextEditingController formulaModeCtl;
  final TextEditingController formulaUnitCtl;
  final RawDataInfo? selectedRawDataInfo;
  final int selectedIndex;
  final bool freeMode;
  final ScaleLiveStreamService scaleLiveStreamService;
  final ValueChanged<RawDataInfo?> onSelectRawData;
  final VoidCallback onAddRawMaterial;
  final VoidCallback onModifyRawMaterial;
  final VoidCallback onCancelEdit;
  final VoidCallback onChanged;

  const AddFormulaRawAdder({
    super.key,
    required this.constraints,
    required this.rawMaterialCtl,
    required this.wgtCtl,
    required this.errorCtl,
    required this.formulaModeCtl,
    required this.formulaUnitCtl,
    required this.selectedRawDataInfo,
    required this.selectedIndex,
    required this.freeMode,
    required this.scaleLiveStreamService,
    required this.onSelectRawData,
    required this.onAddRawMaterial,
    required this.onModifyRawMaterial,
    required this.onCancelEdit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    TextStyle getTextStyle({Color? color}) {
      return textTheme.bodySmall!.apply(
        color: color ?? colorScheme.onSurface,
      );
    }

    TextStyle getTitleBoldStyle({Color? color}) {
      return textTheme.labelMedium!.apply(
        color: color ?? colorScheme.onSurface,
      );
    }

    Widget showRawDropDownBtn(String hintText) {
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
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(0),
        ),
        child: DropdownButton<String?>(
          underline: const SizedBox(),
          isExpanded: true,
          value: currentValue,
          items: rawDataList.isEmpty
              ? [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      localizedStrings.fSelectRawMaterialHint,
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
                      localizedStrings.fSelectRawMaterialHint,
                      style: getTextStyle(
                        color: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  ...rawDataList.map((RawDataInfo item) {
                    String displayText =
                        '${item.materialId} ${item.materialName}';
                    return DropdownMenuItem<String?>(
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
              rawMaterialCtl.text = "";
              onSelectRawData(null);
              return;
            }
            rawMaterialCtl.text = value;
            RawDataInfo selected = rawDataList.firstWhere(
              (item) => '${item.materialId} ${item.materialName}' == value,
              orElse: () => RawDataInfo(
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
              ),
            );
            onSelectRawData(selected);
          },
          style: getTextStyle(color: colorScheme.onSurfaceVariant),
        ),
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
                    ? "${localizedStrings.fWeightMode}:"
                    : "${localizedStrings.fPctMode}:",
                true),
          ),
          SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: wgtCtl,
                    onChanged: (value) => onChanged(),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^(0|[1-9]\d*)(\.\d{0,4})?$')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0.0))),
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
                        ),
                      ),
                    ),
                    style: getTextStyle(),
                  ),
                ),
              ],
            ),
          )
        ]),
      );
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
                          ? "${localizedStrings.fWeightMode}:"
                          : "${localizedStrings.fPctMode}:",
                      style: getTextStyle(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
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
                      valueListenable:
                          scaleLiveStreamService.currentWgtStrNotifier,
                      builder: (context, value, child) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value,
                            maxLines: 1,
                            style: textTheme.titleLarge!.copyWith(
                                fontSize: 48, color: colorScheme.onPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          )
        ]),
      );
    }

    Widget showTareBtn() {
      return IconButton(
        iconSize: 24,
        color: colorScheme.onPrimary,
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.primary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          fixedSize: const Size(48, 48),
        ),
        onPressed: () {
          if (scaleLiveStreamService.isWgtStartNotifier.value == false) {
            showTipInfo(localizedStrings.fDeviceDisconnected, context);
            return;
          }
          scaleLiveStreamService.performTare();
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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          fixedSize: const Size(48, 48),
        ),
        onPressed: () {
          if (scaleLiveStreamService.isWgtStartNotifier.value == false) {
            showTipInfo(localizedStrings.fDeviceDisconnected, context);
            return;
          }
          scaleLiveStreamService.performZero();
        },
        icon: getSvgIcon(performZeroSvgIcon(), 40, 35, colorScheme.onPrimary),
      );
    }

    Widget showNormalAddBtn() {
      return Expanded(
        flex: 1,
        child: Column(children: [
          Container(height: 42),
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
                      : onAddRawMaterial,
                  colorScheme.onPrimary,
                  colorScheme.primary,
                  colorScheme.onPrimary,
                ),
              ),
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
                      : onModifyRawMaterial,
                  colorScheme.onPrimary,
                  colorScheme.primary,
                  colorScheme.onPrimary,
                ),
              ),
            if (selectedIndex != -1) const SizedBox(width: regularPadding),
            if (selectedIndex != -1)
              Expanded(
                child: showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.gBtnCancel,
                  onCancelEdit,
                  colorScheme.onPrimary,
                  colorScheme.surfaceContainerHighest,
                  colorScheme.onPrimary,
                ),
              )
          ]),
        ]),
      );
    }

    Widget showFreeAddBtn() {
      return Expanded(
        flex: 1,
        child: Column(children: [
          Container(height: 42),
          Row(children: [
            if (selectedIndex == -1) showTareBtn(),
            if (selectedIndex == -1) const SizedBox(width: smallPadding),
            if (selectedIndex == -1) showZeroBtn(),
            if (selectedIndex == -1) const SizedBox(width: smallPadding),
            if (selectedIndex == -1)
              Expanded(
                child: showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.gBtnAdd,
                  (selectedRawDataInfo == null || errorCtl.text == '')
                      ? null
                      : () {
                          if (scaleLiveStreamService
                                  .isWgtStartNotifier.value ==
                              false ||
                              scaleLiveStreamService
                                      .currentWgtStrNotifier.value ==
                                  '----') {
                            showTipInfo(
                                localizedStrings.fDeviceDisconnected, context);
                            return;
                          }
                          final currentStr = scaleLiveStreamService
                              .currentWgtStrNotifier.value;
                          if (currentStr.contains('-') ||
                              currentStr == '0' ||
                              currentStr == '0.0' ||
                              currentStr == '0.00' ||
                              currentStr == '0.000') {
                            showTipInfo(
                                localizedStrings.gTipInvalidInput, context);
                            return;
                          }
                          final weight = double.tryParse(currentStr);
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

                          wgtCtl.text = currentStr;
                          onAddRawMaterial();
                          scaleLiveStreamService.performTare();
                        },
                  colorScheme.onPrimary,
                  colorScheme.primary,
                  colorScheme.onPrimary,
                ),
              ),
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
                      : onModifyRawMaterial,
                  colorScheme.onPrimary,
                  colorScheme.primary,
                  colorScheme.onPrimary,
                ),
              ),
            if (selectedIndex != -1) const SizedBox(width: regularPadding),
            if (selectedIndex != -1)
              Expanded(
                child: showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.gBtnCancel,
                  onCancelEdit,
                  colorScheme.onPrimary,
                  colorScheme.surfaceContainerHighest,
                  colorScheme.onPrimary,
                ),
              )
          ]),
        ]),
      );
    }

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
                ),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => AddRawDialog(),
                  ).then((_) => onChanged());
                },
                child: Text(
                  localizedStrings.fAddRawMaterialBtn,
                  style: getTextStyle(color: colorScheme.primary),
                ),
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
              const SizedBox(width: 20),
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
                          onChanged: (value) => onChanged(),
                          controller: errorCtl,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^(0|[1-9]\d*)(\.\d{0,4})?$')),
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
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
                                  formulaModeCtl.text == FormulaMode.wgt.name
                                      ? formulaUnitCtl.text
                                      : pctStrShow,
                                  style: getTextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          style: getTextStyle(),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(width: 20),
              freeMode ? showFreeAddBtn() : showNormalAddBtn()
            ]),
          ),
          const SizedBox(height: 10),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
