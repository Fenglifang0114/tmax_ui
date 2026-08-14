import 'package:flutter/material.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/f_raw_name.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/dialog/show_fma_detail_dialog.dart';
import 'package:t_max/modules/formula/services/formula_weighing_service.dart';

import 'package:t_max/widget/formula_widget.dart';
import 'package:t_max/widget/io_output.dart';
import 'formula_raw_order_list.dart';

/// 配方页签底部操作栏与关联信息面板
class FormulaBottomPanel extends StatelessWidget {
  final FormulaInfoDb? selectedFormula;
  final Detail selectedDetail;
  final int selectedRawIndex;
  final int selScaleId;
  final bool checkCode;
  final VoidCallback onToggleCheckCode;
  final Function(int, Detail) onSelectRawDetail;
  final VoidCallback stopTestScaleOnline;
  final VoidCallback startTestScaleOnline;

  const FormulaBottomPanel({
    super.key,
    required this.selectedFormula,
    required this.selectedDetail,
    required this.selectedRawIndex,
    required this.selScaleId,
    required this.checkCode,
    required this.onToggleCheckCode,
    required this.onSelectRawDetail,
    required this.stopTestScaleOnline,
    required this.startTestScaleOnline,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    TextStyle getTextStyle({Color? color}) {
      color ??= colorScheme.onSurface;
      return textTheme.bodySmall!.apply(color: color);
    }

    return Expanded(
      flex: 4,
      child: Container(
        color: colorScheme.surface,
        child: Column(children: [
          Container(
            height: 48,
            color: colorScheme.surface,
            child: Row(children: [
              const SizedBox(width: regularPadding),
              Text(
                "${localizedStrings.fFmaNameLabel}：",
                style: getTextStyle(color: colorScheme.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Expanded(
                flex: 3,
                child: Text(
                  selectedFormula?.header?.formulaName ?? "",
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                "${localizedStrings.fFmaIdLabel}: ",
                style: getTextStyle(color: colorScheme.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Expanded(
                flex: 1,
                child: Text(
                  selectedFormula?.header?.formulaId ?? "",
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                "${localizedStrings.fIngredientCountLabel}: ",
                style: getTextStyle(color: colorScheme.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Expanded(
                flex: 1,
                child: Text(
                  selectedFormula?.header?.materialCount.toString() ?? "",
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              selectedFormula?.header?.formulaMode != "pct"
                  ? Text(
                      "  ${localizedStrings.fTotalWeightLabel}: ",
                      style: getTextStyle(color: colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  : const SizedBox(),
              Expanded(
                flex: 1,
                child: Text(
                  selectedFormula?.header?.formulaMode == "pct"
                      ? ""
                      : selectedFormula?.header?.totalWeight != null &&
                              selectedFormula?.header?.formulaUnit != null
                          ? " ${selectedFormula!.header!.totalWeight} ${selectedFormula!.header!.formulaUnit}"
                          : " ",
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (mySysUser.roleId == superAdminRoleId ||
                  mySysUser.roleId == adminRoleId)
                Container(
                  width: 44,
                  height: 36,
                  padding: const EdgeInsets.only(left: smallPadding),
                  child: Tooltip(
                    message: checkCode
                        ? localizedStrings.disableIngredientVerification
                        : localizedStrings.enableIngredientVerification,
                    child: IconButton(
                      iconSize: 24,
                      color: colorScheme.onPrimary,
                      hoverColor: colorScheme.primary.withAlpha(20),
                      style: IconButton.styleFrom(
                        backgroundColor: checkCode
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerLow,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        fixedSize: const Size(36, 36),
                      ),
                      onPressed: onToggleCheckCode,
                      icon: getSvgIcon(
                        checkCodeSvgIcon(),
                        24,
                        24,
                        checkCode
                            ? colorScheme.onPrimary
                            : colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: regularPadding),
              SizedBox(
                width: 80,
                height: 36,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: colorScheme.onPrimary,
                    backgroundColor: colorScheme.onTertiaryFixedVariant,
                    fixedSize: const Size(double.infinity, 48),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: (selectedFormula == null)
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                SetOutputPortDialog(),
                          );
                        },
                  child: Text(
                    "I/O",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: regularPadding),
              SizedBox(
                width: 150,
                height: 36,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: colorScheme.onPrimary,
                    backgroundColor: colorScheme.onTertiaryFixedVariant,
                    fixedSize: const Size(double.infinity, 48),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: (selectedFormula == null)
                      ? null
                      : () {
                          bool isOk = FormulaWeighingService.checkScaleOnline(
                              selectedFormula, selScaleId, context);
                          if (!isOk) return;
                          stopTestScaleOnline();
                          FormulaWeighingService.startWeighting(
                            context: context,
                            selectedFormula: selectedFormula,
                            selScaleId: selScaleId,
                            stopTestScaleOnline: stopTestScaleOnline,
                            startTestScaleOnline: startTestScaleOnline,
                          );
                        },
                  child: Text(
                    localizedStrings.fStartWeighingBtn,
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ]),
          ),
          Divider(
            color: colorScheme.outline,
            thickness: 1,
            height: 1,
          ),
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 17),
                Expanded(
                  flex: 6,
                  child: Container(
                    color: colorScheme.surface,
                    child: Column(children: [
                      ShowRawTitleWidget(
                        text: localizedStrings.fIngredientOrder,
                      ),
                      Expanded(
                        child: RawOrderDetailWidget(
                          selectedFormula: selectedFormula,
                          selectedRawIndex: selectedRawIndex,
                          onSelectRawDetail: onSelectRawDetail,
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 11,
                  child: Column(children: [
                    ShowRawTitleWidget(
                      text: localizedStrings.fIngredientRemark,
                    ),
                    RawRemarkTextWidget(
                      text: selectedDetail == Detail()
                          ? ""
                          : selectedDetail.materialId == null
                              ? ""
                              : getRawRemark(selectedDetail.materialId!),
                    )
                  ]),
                ),
                const SizedBox(width: 26),
                VerticalDivider(
                  color: colorScheme.outline,
                  width: 1,
                ),
                const SizedBox(width: 26),
                Expanded(
                  flex: 9,
                  child: Column(children: [
                    ShowRawTitleWidget(
                      text: localizedStrings.fFmaRemark,
                    ),
                    RawRemarkTextWidget(
                      text: selectedFormula?.header?.remark ?? "",
                    )
                  ]),
                ),
                const SizedBox(width: 20),
              ],
            ),
          )
        ]),
      ),
    );
  }
}

/// 原料页签底部关联配方显示面板
class RawBottomPanel extends StatelessWidget {
  final List<FormulaInfoDb> rawFormulaList;
  final int selScaleId;
  final Function(FormulaInfoDb) onSelectFormula;
  final VoidCallback stopTestScaleOnline;
  final VoidCallback startTestScaleOnline;

  const RawBottomPanel({
    super.key,
    required this.rawFormulaList,
    required this.selScaleId,
    required this.onSelectFormula,
    required this.stopTestScaleOnline,
    required this.startTestScaleOnline,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      flex: 3,
      child: Container(
        color: colorScheme.surface,
        child: Column(children: [
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 17),
                Expanded(
                  flex: 11,
                  child: Column(children: [
                    Row(children: [
                      Container(
                        width: 3,
                        height: 14,
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShowRawTitleWidget(
                          text: localizedStrings.fInvolvedFmas,
                        ),
                      )
                    ]),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 30,
                            runSpacing: 10,
                            children: [
                              for (var formula in rawFormulaList)
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ShowFormulaDetailDialog(
                                          selectFormula: formula,
                                          selectScaleId: selScaleId,
                                        );
                                      },
                                    ).then((value) {
                                      if (value == true && context.mounted) {
                                        onSelectFormula(formula);
                                        bool isOk =
                                            FormulaWeighingService.checkScaleOnline(
                                                formula, selScaleId, context);
                                        if (!isOk) return;
                                        stopTestScaleOnline();
                                        FormulaWeighingService.startWeighting(
                                          context: context,
                                          selectedFormula: formula,
                                          selScaleId: selScaleId,
                                          stopTestScaleOnline: stopTestScaleOnline,
                                          startTestScaleOnline: startTestScaleOnline,
                                        );
                                      }
                                    });
                                  },
                                  child: IntrinsicWidth(
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      height: 40,
                                      constraints: const BoxConstraints(
                                        maxWidth: 300,
                                        minWidth: 100,
                                      ),
                                      color: colorScheme.secondaryContainer,
                                      child: Center(
                                        child: Text(
                                          formula.header?.formulaName ?? "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                color: colorScheme.onSurface,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ]),
                ),
                const SizedBox(width: 20),
              ],
            ),
          )
        ]),
      ),
    );
  }
}

/// 草稿记录页签底部操作与关联面板
class DraftBottomPanel extends StatelessWidget {
  final DarfFmaInfo? selectedDarfFma;
  final Detail selectedDetail;
  final int selectedRawIndex;
  final int selScaleId;
  final Function(int, Detail) onSelectRawDetail;

  const DraftBottomPanel({
    super.key,
    required this.selectedDarfFma,
    required this.selectedDetail,
    required this.selectedRawIndex,
    required this.selScaleId,
    required this.onSelectRawDetail,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    TextStyle getTextStyle({Color? color}) {
      color ??= colorScheme.onSurface;
      return textTheme.bodySmall!.apply(color: color);
    }

    return Expanded(
      flex: 4,
      child: Container(
        color: colorScheme.surface,
        child: Column(children: [
          Container(
            height: 48,
            color: colorScheme.surface,
            child: Row(children: [
              const SizedBox(width: 20),
              Text(
                "${localizedStrings.fFmaNameLabel}：",
                style: getTextStyle(color: colorScheme.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Expanded(
                flex: 3,
                child: Text(
                  selectedDarfFma?.fmaInfo!.header!.formulaName ?? "",
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                "${localizedStrings.fFmaIdLabel}: ",
                style: getTextStyle(color: colorScheme.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Expanded(
                flex: 1,
                child: Text(
                  selectedDarfFma?.fmaInfo!.header!.formulaId ?? "",
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                "${localizedStrings.fIngredientCountLabel}: ",
                style: getTextStyle(color: colorScheme.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Expanded(
                flex: 1,
                child: Text(
                  selectedDarfFma?.fmaInfo!.header!.materialCount.toString() ??
                      "",
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              selectedDarfFma?.fmaInfo!.header!.formulaMode != "pct"
                  ? Text(
                      "  ${localizedStrings.fTotalWeightLabel}: ",
                      style: getTextStyle(color: colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  : const SizedBox(),
              Expanded(
                flex: 1,
                child: Text(
                  selectedDarfFma?.fmaInfo!.header!.formulaMode == "pct"
                      ? ""
                      : selectedDarfFma?.fmaInfo!.header!.totalWeight !=
                                  null &&
                              selectedDarfFma?.fmaInfo!.header!.formulaUnit !=
                                  null
                          ? " ${(selectedDarfFma?.fmaInfo ?? FormulaInfoDb()).header!.totalWeight} ${(selectedDarfFma?.fmaInfo ?? FormulaInfoDb()).header!.formulaUnit}"
                          : " ",
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 200,
                height: 36,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: colorScheme.onPrimary,
                    backgroundColor: colorScheme.onTertiaryFixedVariant,
                    fixedSize: const Size(double.infinity, 48),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: (selectedDarfFma == null)
                      ? null
                      : () {
                          bool isOk = FormulaWeighingService.checkDarftScaleOnline(
                              selectedDarfFma, selScaleId, context);
                          if (!isOk) return;
                          FormulaWeighingService.startDarftWeighting(
                            context: context,
                            selectedDarfFma: selectedDarfFma,
                            selScaleId: selScaleId,
                          );
                        },
                  child: Text(
                    localizedStrings.btnContinueWeighing,
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ]),
          ),
          Divider(
            color: colorScheme.outline,
            thickness: 1,
            height: 1,
          ),
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 17),
                Expanded(
                  flex: 6,
                  child: Container(
                    color: colorScheme.surface,
                    child: Column(children: [
                      ShowRawTitleWidget(
                        text: localizedStrings.fIngredientOrder,
                      ),
                      Expanded(
                        child: DraftRawOrderDetailWidget(
                          selectedDarfFma: selectedDarfFma,
                          selectedRawIndex: selectedRawIndex,
                          onSelectRawDetail: onSelectRawDetail,
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 11,
                  child: Column(children: [
                    ShowRawTitleWidget(
                      text: localizedStrings.fIngredientRemark,
                    ),
                    RawRemarkTextWidget(
                      text: selectedDetail == Detail()
                          ? ""
                          : selectedDetail.remark == null
                              ? ""
                              : selectedDetail.remark!,
                    )
                  ]),
                ),
                const SizedBox(width: 26),
                VerticalDivider(
                  color: colorScheme.outline,
                  width: 1,
                ),
                const SizedBox(width: 26),
                Expanded(
                  flex: 9,
                  child: Column(children: [
                    ShowRawTitleWidget(
                      text: localizedStrings.fFmaRemark,
                    ),
                    RawRemarkTextWidget(
                      text: selectedDarfFma?.fmaInfo!.header!.remark ?? "",
                    )
                  ]),
                ),
                const SizedBox(width: 20),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
