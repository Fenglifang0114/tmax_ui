import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';

/// 通用 SfDataGrid 分页控制栏组件
class TablePaginationControl extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final ValueChanged<int> onPageChanged;

  const TablePaginationControl({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.first_page, size: 20),
                onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
                color: currentPage > 1
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed:
                    currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
                color: currentPage > 1
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$currentPage / $totalPages',
                  style: textTheme.bodySmall,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                color: currentPage < totalPages
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              IconButton(
                icon: const Icon(Icons.last_page, size: 20),
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(totalPages)
                    : null,
                color: currentPage < totalPages
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              const SizedBox(width: 16),
              Text(
                localizedStrings.tipJumpPage,
                style: textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                height: 32,
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    final page = int.tryParse(value);
                    if (page != null) {
                      onPageChanged(page);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: regularPadding),
          Text(
            '${localizedStrings.tipPageTotal}: $totalItems ${localizedStrings.tipPageItems}',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// 通用可排序 GridColumn 构建辅助函数
GridColumn buildSortableGridColumn({
  required double width,
  required String columnName,
  required String title,
  required String sortField,
  required bool sortAscending,
  required Function(String) onSort,
  required TextTheme textTheme,
  required ColorScheme colorScheme,
}) {
  return GridColumn(
    width: width,
    allowSorting: true,
    columnName: columnName,
    label: InkWell(
      onTap: () => onSort(columnName),
      child: Container(
        color: colorScheme.surfaceDim,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: textTheme.bodyMedium!.apply(color: colorScheme.onSurface),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (sortField == columnName)
              Icon(
                sortAscending
                    ? Icons.arrow_drop_up_outlined
                    : Icons.arrow_drop_down_outlined,
                size: 22,
              ),
          ],
        ),
      ),
    ),
  );
}

/// 通用不可排序 GridColumn 构建辅助函数
GridColumn buildGridColumnNoSort({
  required double width,
  required String columnName,
  required String title,
  required TextTheme textTheme,
  required ColorScheme colorScheme,
}) {
  return GridColumn(
    width: width,
    allowSorting: false,
    columnName: columnName,
    label: Container(
      color: colorScheme.surfaceDim,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: textTheme.bodyMedium!.apply(color: colorScheme.onSurface),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    ),
  );
}
