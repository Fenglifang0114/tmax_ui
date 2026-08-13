import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/pages/edit_darft_fma_page.dart';
import 'package:t_max/pages/edit_formula_page.dart';
import 'package:t_max/pages/fma_wgt_rec_page.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/functions/methods.dart';

class FormulaTable extends StatefulWidget {
  final List<FormulaInfoDb> searchFmaList;
  final ValueChanged<FormulaInfoDb?> onFormulaSelected;
  final ValueChanged<List<FormulaInfoDb>> onMultipleSelected;
  final Function() onDataChanged;

  const FormulaTable({
    super.key,
    required this.searchFmaList,
    required this.onFormulaSelected,
    required this.onMultipleSelected,
    required this.onDataChanged,
  });

  @override
  State<FormulaTable> createState() => _FormulaTableState();
}

class _FormulaTableState extends State<FormulaTable> {
  late FormulaDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final int _pageSize = 20;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _selectAll = false;
  Set<int> _allSelectedIndexes = <int>{}; //选中行的索引
  String _sortField = ''; // 当前排序列名
  bool _sortAscending = true; // 排序方向

  @override
  void initState() {
    super.initState();
    _initializeDataSource();
  }

  void _initializeDataSource() {
    _dataSource = FormulaDataSource(
      context: context,
      allFormulaData: widget.searchFmaList,
      onRowSelected: widget.onFormulaSelected,
      onMultipleSelectionChanged: _updateMultipleSelection,
      onDataChanged: widget.onDataChanged,
    );
    _calculateTotalPages();
  }

  void _calculateTotalPages() {
    _totalPages = (widget.searchFmaList.length / _pageSize).ceil();
    if (_totalPages == 0) _totalPages = 1;
    if (_currentPage > _totalPages) {
      _currentPage = _totalPages;
    }
    _dataSource.updateCurrentPage(_currentPage, _pageSize);
  }

  void _updateMultipleSelection(Set<int> selectedIndexes) {
    // 计算当前页在完整列表中的起始索引
    final pageStartIndex = (_currentPage - 1) * _pageSize;

    // 移除当前页之前的选择（基于完整列表的索引）
    final currentPageIndexes = <int>{};
    for (int i = 0; i < _pageSize; i++) {
      final actualIndex = pageStartIndex + i;
      if (actualIndex < widget.searchFmaList.length) {
        currentPageIndexes.add(actualIndex);
      }
    }
    // 从_allSelectedIndexes中移除当前页的所有索引
    _allSelectedIndexes
        .removeWhere((index) => currentPageIndexes.contains(index));

    // 添加当前页新选中的索引到_allSelectedIndexes
    for (var index in selectedIndexes) {
      final actualIndex = pageStartIndex + index;
      _allSelectedIndexes.add(actualIndex);
    }

    // 构建选中的配方列表并回调
    if (_allSelectedIndexes.length > widget.searchFmaList.length) {
      widget.onMultipleSelected([]);
      return;
    }
    final selectedFormulas = _allSelectedIndexes.map((index) {
      return widget.searchFmaList[index];
    }).toList();

    widget.onMultipleSelected(selectedFormulas);
  }

  void _toggleSelectAll(bool? value) {
    final selectAll = value ?? false;
    setState(() {
      _selectAll = selectAll;
    });

    if (selectAll) {
      // 选中所有项目
      _allSelectedIndexes = Set<int>.from(
          List.generate(widget.searchFmaList.length, (index) => index));

      // 更新当前页的显示选中状态
      final pageStartIndex = (_currentPage - 1) * _pageSize;
      final pageEndIndex = pageStartIndex + _pageSize;

      final currentPageSelectedIndexes = <int>{};
      for (int i = pageStartIndex;
          i < pageEndIndex && i < widget.searchFmaList.length;
          i++) {
        currentPageSelectedIndexes.add(i - pageStartIndex);
      }

      _dataSource.updateSelection(currentPageSelectedIndexes);
      widget.onMultipleSelected(widget.searchFmaList);
    } else {
      // 取消全选
      _allSelectedIndexes.clear();
      _dataSource.updateSelection({});
      widget.onMultipleSelected([]);
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      setState(() {
        _currentPage = page;
      });

      // 计算当前页的索引范围
      final pageStartIndex = (_currentPage - 1) * _pageSize;
      final pageEndIndex = pageStartIndex + _pageSize;

      // 根据_allSelectedIndexes更新当前页的显示选中状态
      final currentPageSelectedIndexes = <int>{};
      for (int i = pageStartIndex;
          i < pageEndIndex && i < widget.searchFmaList.length;
          i++) {
        if (_allSelectedIndexes.contains(i)) {
          currentPageSelectedIndexes.add(i - pageStartIndex);
        }
      }

      _dataSource.updateCurrentPage(_currentPage, _pageSize);
      _dataSource.updateSelection(currentPageSelectedIndexes);

      // 更新全选状态
      setState(() {
        // 只有当所有项目都被选中时，才设置全选为true
        _selectAll =
            _allSelectedIndexes.length == widget.searchFmaList.length &&
                widget.searchFmaList.isNotEmpty;
      });
    }
  }

  void _goToFirstPage() => _goToPage(1);
  void _goToPreviousPage() => _goToPage(_currentPage - 1);
  void _goToNextPage() => _goToPage(_currentPage + 1);
  void _goToLastPage() => _goToPage(_totalPages);

  Widget _buildPaginationControls() {
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
                icon: Icon(Icons.first_page, size: 20),
                onPressed: _currentPage > 1 ? _goToFirstPage : null,
                color: _currentPage > 1
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              IconButton(
                icon: Icon(Icons.chevron_left, size: 20),
                onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                color: _currentPage > 1
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: textTheme.bodySmall,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 20),
                onPressed: _currentPage < _totalPages ? _goToNextPage : null,
                color: _currentPage < _totalPages
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              IconButton(
                icon: Icon(Icons.last_page, size: 20),
                onPressed: _currentPage < _totalPages ? _goToLastPage : null,
                color: _currentPage < _totalPages
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              SizedBox(width: 16),
              Text(
                localizedStrings.tipJumpPage,
                style: textTheme.bodySmall,
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 60,
                height: 32,
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    final page = int.tryParse(value);
                    if (page != null) {
                      _goToPage(page);
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            width: regularPadding,
          ),
          Text(
            '${localizedStrings.tipPageTotal}: ${widget.searchFmaList.length} ${localizedStrings.tipPageItems}',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant FormulaTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchFmaList != widget.searchFmaList) {
      _dataSource.updateData(widget.searchFmaList);
      _calculateTotalPages();
      _clearSelection();
    }
  }

  void _clearSelection() {
    setState(() {
      _selectAll = false;
      _allSelectedIndexes.clear();
    });
    _dataSource.updateSelection({});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            color: colorScheme.surface,
            child: SfDataGrid(
              controller: _dataGridController,
              source: _dataSource,
              headerRowHeight: 48.0,
              frozenColumnsCount: 2,
              footerFrozenColumnsCount: 1,
              columnWidthMode: ColumnWidthMode.fill,
              gridLinesVisibility: GridLinesVisibility.horizontal,
              headerGridLinesVisibility: GridLinesVisibility.none,
              selectionMode: SelectionMode.none,
              columnResizeMode: ColumnResizeMode.onResize,
              allowSorting: false,
              rowHeight: 44,
              columns: _buildColumns(textTheme, colorScheme),
            ),
          ),
        ),
        _buildPaginationControls(),
      ],
    );
  }

  GridColumn getColumnWidget(double width, String columnName, String title,
      TextTheme textTheme, ColorScheme colorScheme) {
    return GridColumn(
      width: width,
      allowSorting: true,
      columnName: columnName,
      label: InkWell(
        onTap: () {
          setState(() {
            if (_sortField == columnName) {
              // 如果已经是当前排序字段，则切换排序顺序
              _sortAscending = !_sortAscending;
            } else {
              // 否则设置为新的排序字段，默认升序
              _sortField = columnName;
              _sortAscending = true;
            }
            _sortData();
          });
        },
        child: Container(
          color: colorScheme.surfaceDim,
          padding: EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style:
                      textTheme.bodyMedium!.apply(color: colorScheme.onSurface),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (_sortField == columnName)
                Icon(
                    _sortAscending
                        ? Icons.arrow_drop_up_outlined
                        : Icons.arrow_drop_down_outlined,
                    size: 22),
            ],
          ),
        ),
      ),
    );
  }

  GridColumn getColumnWidgetNoSort(double width, String columnName,
      String title, TextTheme textTheme, ColorScheme colorScheme) {
    return GridColumn(
      width: width,
      allowSorting: false,
      columnName: columnName,
      label: Container(
        color: colorScheme.surfaceDim,
        padding: EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style:
                    textTheme.bodyMedium!.apply(color: colorScheme.onSurface),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sortData() {
    if (_sortField == '') return; // 无排序字段时不执行

    if (widget.searchFmaList.isEmpty) return;

    setState(() {
      // 根据排序字段和方向对数据源进行排序
      widget.searchFmaList.sort((a, b) {
        dynamic valueA;
        dynamic valueB;
        String categoryA = getFmaTypeName(a.header!.categoryId!);
        String categoryB = getFmaTypeName(b.header!.categoryId!);

        switch (_sortField) {
          case 'formulaId':
            valueA = a.header!.formulaId;
            valueB = b.header!.formulaId;
            break;
          case 'formulaName':
            valueA = a.header!.formulaName;
            valueB = b.header!.formulaName;
            break;
          case 'fmaBarcode':
            valueA = a.header!.formulaBarcode;
            valueB = b.header!.formulaBarcode;
            break;

          case 'category':
            valueA = categoryA;
            valueB = categoryB;
            break;
          case 'confidential':
            valueA = a.header!.isEncrypted;
            valueB = b.header!.isEncrypted;
            break;
          case 'materialCount':
            valueA = a.header!.materialCount ?? 0;
            valueB = b.header!.materialCount ?? 0;
            break;
          case 'createdAt':
            valueA = a.header!.createdAt;
            valueB = b.header!.createdAt;
            break;
          case 'updatedAt':
            valueA = a.header!.updatedAt;
            valueB = b.header!.updatedAt;
            break;

          // 添加其他需要排序的字段
          default:
            valueA = 0;
            valueB = 0;
        }

        // 执行比较
        if (valueA is Comparable && valueB is Comparable) {
          return _sortAscending
              ? valueA.compareTo(valueB)
              : valueB.compareTo(valueA);
        }
        return 0;
      });

      _dataSource.updateData(widget.searchFmaList);
    });
  }

  List<GridColumn> _buildColumns(TextTheme textTheme, ColorScheme colorScheme) {
    return [
      GridColumn(
        width: 40,
        allowSorting: false,
        columnName: 'select',
        label: Container(
          color: colorScheme.surfaceDim,
          alignment: Alignment.center,
          child: Checkbox(
            value: _selectAll,
            onChanged: _toggleSelectAll,
          ),
        ),
      ),
      getColumnWidget(120, 'formulaId', localizedStrings.fFmaIdLabel, textTheme,
          colorScheme),
      getColumnWidget(300, 'formulaName', localizedStrings.fFmaNameLabel,
          textTheme, colorScheme),
      getColumnWidget(150, 'fmaBarcode', localizedStrings.fFmaBarcode,
          textTheme, colorScheme),
      getColumnWidget(150, 'category', localizedStrings.fFmaCategoryCol,
          textTheme, colorScheme),
      getColumnWidget(150, 'confidential', localizedStrings.fConfidential,
          textTheme, colorScheme),
      getColumnWidget(
          120, 'mode', localizedStrings.fFmaModeCol, textTheme, colorScheme),
      getColumnWidget(120, 'materialCount',
          localizedStrings.fIngredientCountLabel, textTheme, colorScheme),
      getColumnWidget(200, 'createdAt', localizedStrings.fCreatedAtCol,
          textTheme, colorScheme),
      getColumnWidget(200, 'updatedAt', localizedStrings.fUpdatedAtCol,
          textTheme, colorScheme),
      getColumnWidget(
          300, 'remark', localizedStrings.fRemarkCol, textTheme, colorScheme),
      getColumnWidgetNoSort(140, 'operation', localizedStrings.fTipOperation,
          textTheme, colorScheme),
    ];
  }
}

class FormulaDataSource extends DataGridSource {
  final BuildContext context;
  final List<FormulaInfoDb> allFormulaData;
  final ValueChanged<FormulaInfoDb?> onRowSelected;
  final ValueChanged<Set<int>> onMultipleSelectionChanged;
  final Function() onDataChanged;

  List<FormulaInfoDb> currentPageData = [];
  List<DataGridRow> _dataGridRows = [];
  Set<int> _selectedRowIndexes = {};
  FormulaInfoDb? _selectedFormula;

  FormulaDataSource({
    required this.context,
    required this.allFormulaData,
    required this.onRowSelected,
    required this.onMultipleSelectionChanged,
    required this.onDataChanged,
  }) {
    updateCurrentPage(1, 20);
  }

  void updateData(List<FormulaInfoDb> newData) {
    allFormulaData.clear();
    allFormulaData.addAll(newData);
    updateCurrentPage(1, 20);
  }

  void updateCurrentPage(int currentPage, int pageSize) {
    final startIndex = (currentPage - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    currentPageData = allFormulaData.sublist(
      startIndex.clamp(0, allFormulaData.length),
      endIndex.clamp(0, allFormulaData.length),
    );

    buildDataGridRows();
    notifyListeners();
  }

  void updateSelection(Set<int> selectedIndexes) {
    _selectedRowIndexes = selectedIndexes;
    notifyListeners();
  }

  void buildDataGridRows() {
    _dataGridRows = currentPageData.map<DataGridRow>((formula) {
      return DataGridRow(cells: [
        DataGridCell<bool>(columnName: 'select', value: false),
        DataGridCell<String>(
          columnName: 'formulaId',
          value: formula.header?.formulaId ?? '',
        ),
        DataGridCell<String>(
          columnName: 'formulaName',
          value: formula.header?.formulaName ?? '',
        ),
        DataGridCell<String>(
          columnName: 'fmaBarcode',
          value: formula.header?.formulaBarcode ?? '',
        ),
        DataGridCell<String>(
          columnName: 'category',
          value: getFmaTypeName(formula.header!.categoryId!),
        ),
        DataGridCell<String>(
          columnName: 'confidential',
          value: formula.header?.isEncrypted ?? false
              ? localizedStrings.fConfidential
              : localizedStrings.fPublic,
        ),
        DataGridCell<String>(
          columnName: 'mode',
          value: formula.header?.formulaMode == 'pct'
              ? localizedStrings.fPctMode
              : localizedStrings.fWeightMode,
        ),
        DataGridCell<String>(
          columnName: 'materialCount',
          value: formula.header?.materialCount?.toString() ?? '0',
        ),
        DataGridCell<String>(
          columnName: 'createdAt',
          value: DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(formula.header?.createdAt ?? DateTime.now()),
        ),
        DataGridCell<String>(
          columnName: 'updatedAt',
          value: DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(formula.header?.updatedAt ?? DateTime.now()),
        ),
        DataGridCell<String>(
          columnName: 'remark',
          value: formula.header?.remark ?? '',
        ),
        DataGridCell<Widget>(columnName: 'operation', value: null),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final int rowIndex = _dataGridRows.indexOf(row);
    final FormulaInfoDb formula = currentPageData[rowIndex];
    final colorScheme = Theme.of(context).colorScheme;

    final bool isMultiSelected = _selectedRowIndexes.contains(rowIndex);
    final bool isSingleSelected =
        _selectedFormula?.header?.formulaId == formula.header?.formulaId;

    return DataGridRowAdapter(
      color: isSingleSelected
          ? colorScheme.primary.withAlpha(20)
          : isMultiSelected
              ? colorScheme.secondary.withAlpha(20)
              : colorScheme.surface,
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          alignment: dataGridCell.columnName == 'select'
              ? Alignment.center
              : Alignment.centerLeft,
          child: _buildCellContent(
              dataGridCell, formula, rowIndex, isMultiSelected),
        );
      }).toList(),
    );
  }

  Widget _buildCellContent(DataGridCell dataGridCell, FormulaInfoDb formula,
      int rowIndex, bool isMultiSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    switch (dataGridCell.columnName) {
      case 'select':
        return Checkbox(
          value: isMultiSelected,
          onChanged: (value) {
            final newSelectedIndexes = Set<int>.from(_selectedRowIndexes);
            if (value ?? false) {
              newSelectedIndexes.add(rowIndex);
            } else {
              newSelectedIndexes.remove(rowIndex);
            }
            onMultipleSelectionChanged(newSelectedIndexes);
            updateSelection(newSelectedIndexes);
          },
        );

      case 'operation':
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.receipt_long_sharp,
                  size: 20,
                  color: mySysUser.roleId != operatorRoleId
                      ? colorScheme.primary
                      : colorScheme.outline),
              onPressed: mySysUser.roleId != operatorRoleId
                  ? () => _showHistoryRecords(formula)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 20,
                  color: mySysUser.roleId != operatorRoleId
                      ? colorScheme.primary
                      : colorScheme.outline),
              onPressed: mySysUser.roleId != operatorRoleId
                  ? () => _editFormula(formula)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.delete_forever_outlined,
                  size: 20,
                  color: mySysUser.roleId != operatorRoleId
                      ? colorScheme.error
                      : colorScheme.outline),
              onPressed: mySysUser.roleId != operatorRoleId
                  ? () => _deleteFormula(formula)
                  : null,
            ),
          ],
        );

      case 'confidential':
        return Text(
          dataGridCell.value.toString(),
          style: textTheme.bodySmall?.copyWith(
            color: formula.header?.isEncrypted ?? false
                ? colorScheme.error
                : colorScheme.onTertiaryFixedVariant,
          ),
          overflow: TextOverflow.ellipsis,
        );

      default:
        return // 将原有的 InkWell 包裹整个行组件，而不是单个文本
            InkWell(
          onTap: () {
            _selectedFormula = formula;
            onRowSelected(formula);
            notifyListeners();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dataGridCell.value.toString(),
                    style: textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 可以添加其他行内组件
              ],
            ),
          ),
        );
    }
  }

  void _showHistoryRecords(FormulaInfoDb formula) {
    final formulaId = formula.header?.formulaId;
    if (formulaId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OneFmaWgtRecPage(fmaId: formulaId),
      ),
    );
  }

  void _editFormula(FormulaInfoDb formula) async {
    final existDraft = darfFmaInfoList.any(
        (fma) => fma.fmaInfo?.header?.formulaId == formula.header?.formulaId);

    if (existDraft) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditDarftFmaPage(editFormulaInfo: formula),
        ),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditFormulaPage(editFormulaInfo: formula),
        ),
      );
    }
    onDataChanged();
  }

  void _deleteFormula(FormulaInfoDb formula) {
    Future.delayed(const Duration(seconds: 1), () {
      final hasDraft = darfFmaInfoList.any(
          (fma) => fma.fmaInfo?.header?.formulaId == formula.header?.formulaId);
      if (!context.mounted) {
        return;
      }
      if (hasDraft) {
        showTipInfo(localizedStrings.formulaDeleteError, context);
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ShowNormalTipDialog(
            title: localizedStrings.fTipTitle,
            msg: localizedStrings.fConfirmDelete,
          );
        },
      ).then((value) {
        if (value == true) {
          PublicFunctions.deleteFormulaData(formula.header?.recId ?? -1);
          onDataChanged();
        }
      });
    });
  }

  @override
  Widget? buildTableSummaryCellWidget(
      GridTableSummaryRow summaryRow,
      GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex,
      String summaryValue) {
    return null;
  }
}
