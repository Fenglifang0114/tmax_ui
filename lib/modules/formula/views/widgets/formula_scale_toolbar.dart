import 'package:flutter/material.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/dialog/add_raw_info_dialog.dart';
import 'package:t_max/dialog/show_fma_detail_dialog.dart';
import 'package:t_max/modules/formula/services/formula_io_service.dart';
import 'package:t_max/modules/formula/services/formula_weighing_service.dart';
import 'package:t_max/pages/add_formula_page.dart';
import 'package:t_max/pages/all_fma_wgt_rec_page.dart';
import 'package:t_max/widget/search_fma_barcode.dart';

// 定义 EncryptedValue 枚举
enum EncryptedValue {
  confidential,
  public,
}

// 扩展 EncryptedValue 枚举以添加翻译方法
extension EncryptedValueExtension on EncryptedValue {
  String getTranslation(BuildContext context) {
    switch (this) {
      case EncryptedValue.confidential:
        return localizedStrings.fConfidential;
      case EncryptedValue.public:
        return localizedStrings.fPublic;
    }
  }
}

/// 核心通用按钮构建辅助组件
class ToolbarButtonHelper {
  static Widget buildIconBtn(
      BuildContext context, String tip, String iconPath, Function()? onPressed,
      {bool enabled = true}) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isEnabled = enabled && onPressed != null;
    return Tooltip(
      message: tip,
      child: IconButton(
        iconSize: 24,
        color: colorScheme.onPrimary,
        focusColor: colorScheme.outline,
        hoverColor: colorScheme.outline,
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.primary,
          disabledBackgroundColor: colorScheme.surfaceContainerLow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          fixedSize: const Size(40, 40),
        ),
        onPressed: isEnabled ? onPressed : null,
        icon: getSvgIcon(iconPath, 24, 24,
            isEnabled ? colorScheme.onPrimary : colorScheme.outline),
      ),
    );
  }

  static Widget showAddFormulaIconBtn(
      BuildContext context, String tip, IconData icon, Function()? onPressed,
      {bool enabled = true}) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isEnabled = enabled && onPressed != null;
    return Tooltip(
        message: tip,
        child: IconButton(
          iconSize: 24,
          color: colorScheme.onPrimary,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.onTertiaryFixedVariant,
            disabledBackgroundColor: colorScheme.surfaceContainerLow,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            fixedSize: const Size(40, 40),
          ),
          onPressed: isEnabled ? onPressed : null,
          icon: getSvgIcon(takeInSvgIcon(), 24, 24,
              isEnabled ? colorScheme.onPrimary : colorScheme.outline),
        ));
  }

  static Widget showIconButton(
      BuildContext context, String tip, String iconPath, Function()? onPressed,
      {bool enabled = true}) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isEnabled = enabled && onPressed != null;
    return Tooltip(
      message: tip,
      child: IconButton(
        iconSize: 24,
        color: colorScheme.primary,
        focusColor: colorScheme.outline,
        hoverColor: colorScheme.outline,
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.primary,
          disabledBackgroundColor: colorScheme.surfaceContainerLow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          fixedSize: const Size(40, 40),
        ),
        onPressed: isEnabled ? onPressed : null,
        icon: getSvgIcon(iconPath, 24, 24,
            isEnabled ? colorScheme.onPrimary : colorScheme.outline),
      ),
    );
  }

  static Widget buildDelIconBtn(
      BuildContext context, Function()? onPressed, bool isDisabled) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      iconSize: 24,
      color: colorScheme.outline,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.error,
        disabledBackgroundColor: colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        fixedSize: const Size(40, 40),
      ),
      onPressed: onPressed,
      icon: getSvgIcon(deleteSvgIcon(), 24, 24,
          isDisabled ? colorScheme.outline : colorScheme.onPrimary),
    );
  }
}

/// 配方列表搜索与操作栏
class FormulaSearchHeader extends StatelessWidget {
  final TextEditingController searchFmaIdCtl;
  final TextEditingController searchFmaTypeCtl;
  final TextEditingController searchFmaEncryptedCtl;
  final TextEditingController isFmaEncryptedCtl;
  final List<FormulaInfoDb> selFormulas;
  final int selScaleId;
  final VoidCallback onSearch;
  final VoidCallback onClearSearch;
  final VoidCallback onDeleteSelectedFmas;
  final VoidCallback stopTestScaleOnline;
  final VoidCallback startTestScaleOnline;
  final Function(FormulaInfoDb) onSelectFormula;

  const FormulaSearchHeader({
    super.key,
    required this.searchFmaIdCtl,
    required this.searchFmaTypeCtl,
    required this.searchFmaEncryptedCtl,
    required this.isFmaEncryptedCtl,
    required this.selFormulas,
    required this.selScaleId,
    required this.onSearch,
    required this.onClearSearch,
    required this.onDeleteSelectedFmas,
    required this.stopTestScaleOnline,
    required this.startTestScaleOnline,
    required this.onSelectFormula,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 70,
      color: colorScheme.surface,
      child: Row(children: [
        const SizedBox(width: 20),
        SizedBox(
          width: 180,
          height: 40,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextField(
              style: textTheme.bodySmall!.copyWith(
                color: colorScheme.onSurface,
              ),
              controller: searchFmaIdCtl,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.primary,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 20,
                  ),
                  onPressed: () {
                    searchFmaIdCtl.clear();
                    onSearch();
                  },
                ),
                hintText: localizedStrings.fSearchHint,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintStyle: textTheme.bodySmall!.copyWith(
                  fontSize: 12,
                  color: colorScheme.surfaceContainerHighest,
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onChanged: (value) => onSearch(),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 180,
          height: 40,
          padding: const EdgeInsets.only(left: 16, right: 20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: colorScheme.outline,
              width: 1,
            ),
          ),
          child: DropdownButton<String>(
            underline: const SizedBox(),
            isExpanded: true,
            value: searchFmaTypeCtl.text == "" ? null : searchFmaTypeCtl.text,
            items: formulaTypeList.isEmpty
                ? [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        localizedStrings.fPleaseSelectCategory,
                        style: textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          color: colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    )
                  ]
                : [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        localizedStrings.fPleaseSelectCategory,
                        style: textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          color: colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                    ...formulaTypeList.map((CategoryTypeList item) {
                      return DropdownMenuItem<String>(
                        value: item.categoryName,
                        child: Text(
                          item.categoryName,
                          style: textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      );
                    })
                  ],
            onChanged: (value) {
              if (value == null) return;
              searchFmaTypeCtl.text = value.toString();
              onSearch();
            },
            style: textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 180,
          height: 40,
          padding: const EdgeInsets.only(left: 16, right: 20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: colorScheme.outline,
              width: 1,
            ),
          ),
          child: DropdownButton<EncryptedValue>(
            underline: const SizedBox(),
            isExpanded: true,
            value: searchFmaEncryptedCtl.text == ""
                ? null
                : EncryptedValue.values.firstWhere((element) =>
                    element.getTranslation(context) ==
                    searchFmaEncryptedCtl.text),
            items: [
              DropdownMenuItem<EncryptedValue>(
                value: null,
                child: Text(
                  localizedStrings.fSelectConfidentialityStatusMsg,
                  style: textTheme.bodySmall!.copyWith(
                    fontSize: 12,
                    color: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              ...EncryptedValue.values.map((value) {
                return DropdownMenuItem<EncryptedValue>(
                  value: value,
                  child: Text(
                    value.getTranslation(context),
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }),
            ],
            onChanged: (value) {
              if (value == null) return;
              searchFmaEncryptedCtl.text = value.getTranslation(context);
              isFmaEncryptedCtl.text = value.toString();
              onSearch();
            },
            style: textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Tooltip(
          message: localizedStrings.fClearSearchConditionBtn,
          child: IconButton(
            icon: Icon(
              Icons.cleaning_services_outlined,
              color: colorScheme.primary,
            ),
            onPressed: onClearSearch,
            iconSize: 24,
          ),
        ),
        const Spacer(),
        ToolbarButtonHelper.showAddFormulaIconBtn(
          context,
          localizedStrings.fAddFmaBtn,
          Icons.add_box_outlined,
          () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddFormulaPage()));
          },
          enabled: mySysUser.roleId != operatorRoleId,
        ),
        const SizedBox(width: 12),
        ToolbarButtonHelper.showIconButton(
          context,
          localizedStrings.fFmaBarcode,
          fmaBarcodeIcon(),
          () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SearchFmaBarcodeDialog();
              },
            ).then((fmaValue) {
              if (fmaValue != null && context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ShowFormulaDetailDialog(
                      selectFormula: fmaValue,
                      selectScaleId: selScaleId,
                    );
                  },
                ).then((value) {
                  if (value == true && context.mounted) {
                    onSelectFormula(fmaValue);
                    bool isOk = FormulaWeighingService.checkScaleOnline(
                        fmaValue, selScaleId, context);
                    if (!isOk) return;
                    stopTestScaleOnline();
                    FormulaWeighingService.startWeighting(
                      context: context,
                      selectedFormula: fmaValue,
                      selScaleId: selScaleId,
                      stopTestScaleOnline: stopTestScaleOnline,
                      startTestScaleOnline: startTestScaleOnline,
                    );
                  }
                });
              }
            });
          },
        ),
        const SizedBox(width: 12),
        ToolbarButtonHelper.showIconButton(
          context,
          localizedStrings.fHistoricalWeighingRecordsBtn,
          recordsIcon(),
          () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AllFmaWgtRecPage()));
          },
          enabled: mySysUser.roleId != operatorRoleId,
        ),
        const SizedBox(width: 12),
        ToolbarButtonHelper.showIconButton(
          context,
          localizedStrings.gBtnImport,
          importSvgIcon(),
          () => FormulaIOService.importFormula(context),
          enabled: mySysUser.roleId != operatorRoleId,
        ),
        const SizedBox(width: 12),
        ToolbarButtonHelper.showIconButton(
          context,
          localizedStrings.gBtnExport,
          exportSvgIcon(),
          () => FormulaIOService.exportFormula(context, selFormulas),
          enabled: mySysUser.roleId != operatorRoleId,
        ),
        const SizedBox(width: 12),
        ToolbarButtonHelper.buildIconBtn(
          context,
          localizedStrings.fGetFmaTemplateBtn,
          rawTemplateSvgIcon(),
          () => FormulaIOService.getFmaTemplate(context),
          enabled: mySysUser.roleId != operatorRoleId,
        ),
        const SizedBox(width: regularPadding),
        ToolbarButtonHelper.buildDelIconBtn(
          context,
          (mySysUser.roleId == operatorRoleId || selFormulas.isEmpty)
              ? null
              : onDeleteSelectedFmas,
          mySysUser.roleId == operatorRoleId || selFormulas.isEmpty,
        ),
        const SizedBox(width: 20),
      ]),
    );
  }
}

/// 原料列表搜索与操作栏
class RawSearchHeader extends StatelessWidget {
  final TextEditingController searchRawIdCtl;
  final TextEditingController rawTypeCtl;
  final List<RawDataInfo> selRawList;
  final VoidCallback onSearch;
  final VoidCallback onClearSearch;
  final VoidCallback onDeleteSelectedRaw;
  final VoidCallback onRefresh;

  const RawSearchHeader({
    super.key,
    required this.searchRawIdCtl,
    required this.rawTypeCtl,
    required this.selRawList,
    required this.onSearch,
    required this.onClearSearch,
    required this.onDeleteSelectedRaw,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 70,
      color: colorScheme.surface,
      child: Row(children: [
        const SizedBox(width: 20),
        SizedBox(
          width: 260,
          height: 40,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextField(
              style: textTheme.bodySmall!.copyWith(
                color: colorScheme.onSurface,
              ),
              controller: searchRawIdCtl,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.primary,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 20,
                  ),
                  onPressed: () {
                    searchRawIdCtl.clear();
                    onSearch();
                  },
                ),
                hintText: localizedStrings.fSearchHint,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintStyle: textTheme.bodySmall!.copyWith(
                  fontSize: 12,
                  color: colorScheme.surfaceContainerHighest,
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onChanged: (value) => onSearch(),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 260,
          height: 40,
          padding: const EdgeInsets.only(left: 16, right: 20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: colorScheme.outline,
              width: 1,
            ),
          ),
          child: DropdownButton<String>(
            underline: const SizedBox(),
            isExpanded: true,
            value: rawTypeCtl.text == "" ? null : rawTypeCtl.text,
            items: rawTypeList.isEmpty
                ? [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        localizedStrings.fPleaseSelectCategory,
                        style: textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          color: colorScheme.surfaceContainerHighest,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ]
                : [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        localizedStrings.fPleaseSelectCategory,
                        style: textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          color: colorScheme.surfaceContainerHighest,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...rawTypeList.map((CategoryTypeList item) {
                      return DropdownMenuItem<String>(
                        value: item.categoryName,
                        child: Text(
                          item.categoryName,
                          style: textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    })
                  ],
            onChanged: (value) {
              if (value == null) return;
              rawTypeCtl.text = value.toString();
              onSearch();
            },
            style: textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Tooltip(
          message: localizedStrings.fClearSearchConditionBtn,
          child: IconButton(
            icon: Icon(
              Icons.cleaning_services_outlined,
              color: colorScheme.primary,
            ),
            onPressed: onClearSearch,
            iconSize: 24,
          ),
        ),
        const Spacer(),
        IconButton(
          iconSize: 24,
          color: colorScheme.onPrimary,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.onTertiaryFixedVariant,
            disabledBackgroundColor: colorScheme.surfaceContainerLow,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            fixedSize: const Size(40, 40),
          ),
          onPressed: mySysUser.roleId != operatorRoleId
              ? () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => AddRawDialog(),
                  ).then((value) => onRefresh());
                }
              : null,
          icon: getSvgIcon(
              takeInSvgIcon(),
              24,
              24,
              mySysUser.roleId != operatorRoleId
                  ? colorScheme.onPrimary
                  : colorScheme.outline),
        ),
        const SizedBox(width: regularPadding),
        ToolbarButtonHelper.buildIconBtn(
          context,
          localizedStrings.gBtnExport,
          exportSvgIcon(),
          () => FormulaIOService.exportRaw(context, selRawList),
          enabled: mySysUser.roleId != operatorRoleId,
        ),
        const SizedBox(width: regularPadding),
        ToolbarButtonHelper.buildIconBtn(
          context,
          localizedStrings.gBtnImport,
          importSvgIcon(),
          () => FormulaIOService.importRaw(context),
          enabled: mySysUser.roleId != operatorRoleId,
        ),
        const SizedBox(width: regularPadding),
        ToolbarButtonHelper.buildIconBtn(
          context,
          localizedStrings.fGetRawTemplateBtn,
          rawTemplateSvgIcon(),
          () => FormulaIOService.getRawTemplate(context),
          enabled: mySysUser.roleId != operatorRoleId,
        ),
        const SizedBox(width: regularPadding),
        ToolbarButtonHelper.buildDelIconBtn(
          context,
          (mySysUser.roleId == operatorRoleId || selRawList.isEmpty)
              ? null
              : onDeleteSelectedRaw,
          mySysUser.roleId == operatorRoleId || selRawList.isEmpty,
        ),
        const SizedBox(width: 20),
      ]),
    );
  }
}

/// 草稿称重记录搜索与操作栏
class DraftSearchHeader extends StatelessWidget {
  final TextEditingController searchDarftIdCtl;
  final List<DarfFmaInfo> selDarftFmaList;
  final VoidCallback onSearch;
  final VoidCallback onDeleteDarftFma;

  const DraftSearchHeader({
    super.key,
    required this.searchDarftIdCtl,
    required this.selDarftFmaList,
    required this.onSearch,
    required this.onDeleteDarftFma,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 70,
      color: colorScheme.surface,
      child: Row(children: [
        const SizedBox(width: 20),
        SizedBox(
          width: 245,
          height: 40,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextField(
              style: textTheme.bodySmall!.copyWith(
                color: colorScheme.onSurface,
              ),
              controller: searchDarftIdCtl,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.primary,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 20,
                  ),
                  onPressed: () {
                    searchDarftIdCtl.clear();
                    onSearch();
                  },
                ),
                hintText: localizedStrings.fSearchHint,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintStyle: textTheme.bodySmall!.copyWith(
                  fontSize: 12,
                  color: colorScheme.surfaceContainerHighest,
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onChanged: (value) => onSearch(),
            ),
          ),
        ),
        const Spacer(),
        ToolbarButtonHelper.buildDelIconBtn(
          context,
          selDarftFmaList.isEmpty ? null : onDeleteDarftFma,
          selDarftFmaList.isEmpty,
        ),
        const SizedBox(width: 20),
      ]),
    );
  }
}
