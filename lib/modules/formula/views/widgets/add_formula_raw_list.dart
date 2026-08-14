import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/pages/add_formula_page.dart';

/// 新增/编辑配方 原料顺序与累计权重明细列表组件
class AddFormulaRawList extends StatelessWidget {
  final BoxConstraints constraints;
  final List<AddFormulaRawWgtInfo> addFormulaRawList;
  final double totalWgt;
  final bool needContainer;
  final String formulaMode;
  final String formulaUnit;
  final int selectedIndex;
  final Function(int) onSelectItem;
  final Function(int) onMoveUp;
  final Function(int) onMoveDown;
  final Function(int) onDeleteItem;
  final VoidCallback onClearAll;

  const AddFormulaRawList({
    super.key,
    required this.constraints,
    required this.addFormulaRawList,
    required this.totalWgt,
    required this.needContainer,
    required this.formulaMode,
    required this.formulaUnit,
    required this.selectedIndex,
    required this.onSelectItem,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDeleteItem,
    required this.onClearAll,
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

    TextSpan showItemTitle(bool isSelected, String title) {
      return TextSpan(
        text: '$title:  ',
        style: getTextStyle(
          color: isSelected
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant,
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
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    showItemTitle(isSelected, localizedStrings.fFmaNameLabel),
                    showItemContent(
                        isSelected, item.rawDataInfo.materialName!),
                    const TextSpan(text: '    '),
                    showItemTitle(
                        isSelected,
                        formulaMode == FormulaMode.wgt.name
                            ? "${localizedStrings.fWeightMode}:"
                            : localizedStrings.fPctMode),
                    showItemContent(isSelected, item.wgt.toString()),
                    const TextSpan(text: '    '),
                    showItemTitle(
                        isSelected, localizedStrings.fAllowableError),
                    showItemContent(isSelected, item.error.toString()),
                    const TextSpan(text: '    '),
                    showItemTitle(
                        isSelected, localizedStrings.fIngredientRemark),
                    showItemContent(isSelected, item.rawDataInfo.ingredient!),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
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
                  onTap: () => onMoveUp(index),
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
                  onTap: () => onMoveDown(index),
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
          const SizedBox(width: 10),
          IconButton(
            iconSize: 24,
            onPressed: () => onDeleteItem(index),
            icon: Icon(
              Icons.delete_outline,
              color:
                  isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: largePadding),
        ],
      );
    }

    Widget showRawOrderRow(
        AddFormulaRawWgtInfo item, int index, bool isSelected) {
      return Container(
        height: 48,
        margin: const EdgeInsets.only(bottom: 10),
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
              child: Text(
                '${index + 1}',
                style: getTextStyle(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => onSelectItem(index),
                child: Container(
                  height: 48,
                  alignment: Alignment.centerLeft,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerLow,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      showItemDetail(isSelected, item),
                      showItemBtn(index, isSelected),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget showContainerOrder() {
      return Container(
        height: 48,
        margin: const EdgeInsets.only(bottom: 10),
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
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 48,
                alignment: Alignment.centerLeft,
                color: colorScheme.surfaceContainerLow,
                child: Row(
                  children: [
                    const SizedBox(width: 10),
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
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formulaMode == FormulaMode.wgt.name
                        ? '${localizedStrings.fTotalWeightLabel} :  $totalWgt $formulaUnit'
                        : '${localizedStrings.fTotalWeightLabel} :  $totalWgt %',
                    style: getTitleBoldStyle(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                style: TextButton.styleFrom(
                  fixedSize: const Size(100, 40),
                  backgroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(
                      color: colorScheme.outline,
                      width: 1,
                    ),
                  ),
                ),
                onPressed: onClearAll,
                child: Text(
                  localizedStrings.fClearBtn,
                  style: getTextStyle(),
                  overflow: TextOverflow.ellipsis,
                ),
              )
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
      ),
    );
  }
}
