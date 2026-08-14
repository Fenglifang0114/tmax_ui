import 'package:flutter/material.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/f_raw_name.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';

/// 标准配方的原料顺序明细列表
class RawOrderDetailWidget extends StatelessWidget {
  final FormulaInfoDb? selectedFormula;
  final int selectedRawIndex;
  final Function(int, Detail) onSelectRawDetail;

  const RawOrderDetailWidget({
    super.key,
    required this.selectedFormula,
    required this.selectedRawIndex,
    required this.onSelectRawDetail,
  });

  Widget _showRawWgtAndUnit(
      BuildContext context, int index, Color? textColor) {
    final formulaHeader = selectedFormula?.header;
    final formulaDetail = selectedFormula?.details?[index];

    if (formulaHeader != null && formulaDetail != null) {
      final weight = formulaDetail.materialWeight;
      final unit = formulaHeader.formulaMode == "pct"
          ? pctStrShow
          : formulaHeader.formulaUnit;
      final displayText = '$weight $unit';

      return Text(
        displayText,
        style: TextStyle(
          color: textColor,
        ),
      );
    } else {
      return Text(
        '',
        style: TextStyle(
          color: textColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView.separated(
      itemCount: selectedFormula?.details?.length ?? 0,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            final detail = selectedFormula?.details?[index] ?? Detail();
            onSelectRawDetail(index, detail);
          },
          child: () {
            bool isSelected = selectedRawIndex == index;
            Color backgroundColor = isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerLow;
            Color innerContainerColor =
                isSelected ? colorScheme.primary : colorScheme.surface;
            Color textColor = isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant;
            Color numberTextColor = isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant;

            return Container(
              height: 32,
              color: backgroundColor,
              child: Row(children: [
                const SizedBox(width: 2),
                Container(
                  width: 28,
                  height: 28,
                  color: innerContainerColor,
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: textTheme.bodySmall!.copyWith(
                        color: numberTextColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    getRawName(
                        selectedFormula?.details![index].materialId! ?? ""),
                    style: textTheme.bodySmall!.copyWith(
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                selectedFormula?.header?.isEncrypted == true
                    ? const SizedBox()
                    : _showRawWgtAndUnit(context, index, textColor),
                const SizedBox(width: 10),
              ]),
            );
          }(),
        );
      },
    );
  }
}

/// 草稿配方的原料顺序明细列表
class DraftRawOrderDetailWidget extends StatelessWidget {
  final DarfFmaInfo? selectedDarfFma;
  final int selectedRawIndex;
  final Function(int, Detail) onSelectRawDetail;

  const DraftRawOrderDetailWidget({
    super.key,
    required this.selectedDarfFma,
    required this.selectedRawIndex,
    required this.onSelectRawDetail,
  });

  Widget _showDarftRawWgtAndUnit(
      BuildContext context, int index, Color? textColor) {
    final formulaHeader = selectedDarfFma?.fmaInfo!.header;
    final formulaDetail = selectedDarfFma?.fmaInfo!.details?[index];

    if (formulaHeader != null && formulaDetail != null) {
      final weight = formulaDetail.materialWeight;
      final unit = formulaHeader.formulaMode == "pct"
          ? pctStrShow
          : formulaHeader.formulaUnit;
      final displayText = '$weight $unit';

      return Text(
        displayText,
        style: TextStyle(
          color: textColor,
        ),
      );
    } else {
      return Text(
        '',
        style: TextStyle(
          color: textColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView.separated(
      itemCount: selectedDarfFma?.fmaInfo?.details?.length ?? 0,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            final detail = selectedDarfFma?.fmaInfo?.details?[index] ?? Detail();
            onSelectRawDetail(index, detail);
          },
          child: () {
            bool isSelected = selectedRawIndex == index;
            Color backgroundColor = isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerLow;
            Color innerContainerColor =
                isSelected ? colorScheme.primary : colorScheme.surface;
            Color textColor = isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant;
            Color numberTextColor = isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant;

            return Container(
              height: 32,
              color: backgroundColor,
              child: Row(children: [
                const SizedBox(width: 2),
                Container(
                  width: 28,
                  height: 28,
                  color: innerContainerColor,
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: textTheme.bodySmall!.copyWith(
                        color: numberTextColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    getRawName(selectedDarfFma
                            ?.fmaInfo!.details![index].materialId! ??
                        ""),
                    style: textTheme.bodySmall!.copyWith(
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                selectedDarfFma?.fmaInfo?.header?.isEncrypted == true
                    ? const SizedBox()
                    : _showDarftRawWgtAndUnit(context, index, textColor),
                const SizedBox(width: 10),
              ]),
            );
          }(),
        );
      },
    );
  }
}
