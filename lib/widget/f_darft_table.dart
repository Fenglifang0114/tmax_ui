import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/common_table_pagination.dart';

typedef DraftFmaTable = DarftFmaTable;

class DarftFmaTable extends StatefulWidget {
  final List<DarfFmaInfo> searchDarfFmaInfoList;
  final ValueChanged<DarfFmaInfo?> onDarfFmaSelected;
  final ValueChanged<List<DarfFmaInfo>> onMultipleSelected;
  final Function() onDataChanged;

  const DarftFmaTable({
    super.key,
    required this.searchDarfFmaInfoList,
    required this.onDarfFmaSelected,
    required this.onMultipleSelected,
    required this.onDataChanged,
  });

  @override
  State<DarftFmaTable> createState() => _DarftFmaTableState();
}

class _DarftFmaTableState extends State<DarftFmaTable> {
  late DarftFmaDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final int _pageSize = 20;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _selectAll = false;
  Set<int> _allSelectedIndexes = <int>{};
  String _sortField = '';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _initializeDataSource();
  }

  void _initializeDataSource() {
    _dataSource = DarftFmaDataSource(
      context: context,
      allDarftFmaData: widget.searchDarfFmaInfoList,
      onRowSelected: widget.onDarfFmaSelected,
      onMultipleSelectionChanged: _updateMultipleSelection,
      onDataChanged: widget.onDataChanged,
    );
    _calculateTotalPages();
  }

  void _calculateTotalPages() {
    _totalPages = (widget.searchDarfFmaInfoList.length / _pageSize).ceil();
    if (_totalPages == 0) _totalPages = 1;
    if (_currentPage > _totalPages) {
      _currentPage = _totalPages;
    }
    _dataSource.updateCurrentPage(_currentPage, _pageSize);
  }

  void _updateMultipleSelection(Set<int> selectedIndexes) {
    final pageStartIndex = (_currentPage - 1) * _pageSize;
    final currentPageIndexes = <int>{};

    for (int i = 0; i < _pageSize; i++) {
      final actualIndex = pageStartIndex + i;
      if (actualIndex < widget.searchDarfFmaInfoList.length) {
        currentPageIndexes.add(actualIndex);
      }
    }

    _allSelectedIndexes
        .removeWhere((index) => currentPageIndexes.contains(index));

    for (var index in selectedIndexes) {
      final actualIndex = pageStartIndex + index;
      _allSelectedIndexes.add(actualIndex);
    }

    final selectedDarftFmas = _allSelectedIndexes.map((index) {
      return widget.searchDarfFmaInfoList[index];
    }).toList();

    widget.onMultipleSelected(selectedDarftFmas);
  }

  void _toggleSelectAll(bool? value) {
    final selectAll = value ?? false;
    setState(() {
      _selectAll = selectAll;
    });

    if (selectAll) {
      _allSelectedIndexes = Set<int>.from(
          List.generate(widget.searchDarfFmaInfoList.length, (index) => index));

      final pageStartIndex = (_currentPage - 1) * _pageSize;
      final pageEndIndex = pageStartIndex + _pageSize;

      final currentPageSelectedIndexes = <int>{};
      for (int i = pageStartIndex;
          i < pageEndIndex && i < widget.searchDarfFmaInfoList.length;
          i++) {
        currentPageSelectedIndexes.add(i - pageStartIndex);
      }

      _dataSource.updateSelection(currentPageSelectedIndexes);
      widget.onMultipleSelected(widget.searchDarfFmaInfoList);
    } else {
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

      final pageStartIndex = (_currentPage - 1) * _pageSize;
      final pageEndIndex = pageStartIndex + _pageSize;

      final currentPageSelectedIndexes = <int>{};
      for (int i = pageStartIndex;
          i < pageEndIndex && i < widget.searchDarfFmaInfoList.length;
          i++) {
        if (_allSelectedIndexes.contains(i)) {
          currentPageSelectedIndexes.add(i - pageStartIndex);
        }
      }

      _dataSource.updateCurrentPage(_currentPage, _pageSize);
      _dataSource.updateSelection(currentPageSelectedIndexes);

      setState(() {
        _selectAll =
            _allSelectedIndexes.length == widget.searchDarfFmaInfoList.length &&
                widget.searchDarfFmaInfoList.isNotEmpty;
      });
    }
  }

  @override
  void didUpdateWidget(covariant DarftFmaTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchDarfFmaInfoList != widget.searchDarfFmaInfoList) {
      _dataSource.updateData(widget.searchDarfFmaInfoList);
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

  void _handleSort(String columnName) {
    setState(() {
      if (_sortField == columnName) {
        _sortAscending = !_sortAscending;
      } else {
        _sortField = columnName;
        _sortAscending = true;
      }
      _sortData();
    });
  }

  void _sortData() {
    if (_sortField == '' || widget.searchDarfFmaInfoList.isEmpty) return;

    setState(() {
      widget.searchDarfFmaInfoList.sort((a, b) {
        dynamic valueA;
        dynamic valueB;

        switch (_sortField) {
          case 'orderId':
            valueA = a.fmaRec?.header?.orderId;
            valueB = b.fmaRec?.header?.orderId;
            break;
          case 'formulaId':
            valueA = a.fmaInfo?.header?.formulaId;
            valueB = b.fmaInfo?.header?.formulaId;
            break;
          case 'formulaName':
            valueA = a.fmaInfo?.header?.formulaName;
            valueB = b.fmaInfo?.header?.formulaName;
            break;
          case 'fmaBarcode':
            valueA = a.fmaInfo?.header?.formulaBarcode;
            valueB = b.fmaInfo?.header?.formulaBarcode;
            break;
          case 'materialCount':
            valueA = a.fmaInfo?.header?.materialCount ?? 0;
            valueB = b.fmaInfo?.header?.materialCount ?? 0;
            break;
          case 'createdAt':
            valueA = a.fmaRec?.header?.createdAt;
            valueB = b.fmaRec?.header?.createdAt;
            break;
          case 'updatedAt':
            valueA = a.fmaRec?.header?.updatedAt;
            valueB = b.fmaRec?.header?.updatedAt;
            break;
          default:
            valueA = 0;
            valueB = 0;
        }

        if (valueA is Comparable && valueB is Comparable) {
          return _sortAscending
              ? valueA.compareTo(valueB)
              : valueB.compareTo(valueA);
        }
        return 0;
      });

      _dataSource.updateData(widget.searchDarfFmaInfoList);
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
      buildSortableGridColumn(
          width: 250,
          columnName: 'orderId',
          title: localizedStrings.fOrderNo,
          sortField: _sortField,
          sortAscending: _sortAscending,
          onSort: _handleSort,
          textTheme: textTheme,
          colorScheme: colorScheme),
      buildSortableGridColumn(
          width: 150,
          columnName: 'formulaId',
          title: localizedStrings.fFmaIdLabel,
          sortField: _sortField,
          sortAscending: _sortAscending,
          onSort: _handleSort,
          textTheme: textTheme,
          colorScheme: colorScheme),
      buildSortableGridColumn(
          width: 300,
          columnName: 'formulaName',
          title: localizedStrings.fFmaNameLabel,
          sortField: _sortField,
          sortAscending: _sortAscending,
          onSort: _handleSort,
          textTheme: textTheme,
          colorScheme: colorScheme),
      buildSortableGridColumn(
          width: 150,
          columnName: 'fmaBarcode',
          title: localizedStrings.fFmaBarcode,
          sortField: _sortField,
          sortAscending: _sortAscending,
          onSort: _handleSort,
          textTheme: textTheme,
          colorScheme: colorScheme),
      buildSortableGridColumn(
          width: 120,
          columnName: 'mode',
          title: localizedStrings.fFmaModeCol,
          sortField: _sortField,
          sortAscending: _sortAscending,
          onSort: _handleSort,
          textTheme: textTheme,
          colorScheme: colorScheme),
      buildSortableGridColumn(
          width: 120,
          columnName: 'materialCount',
          title: localizedStrings.fIngredientCountLabel,
          sortField: _sortField,
          sortAscending: _sortAscending,
          onSort: _handleSort,
          textTheme: textTheme,
          colorScheme: colorScheme),
      buildSortableGridColumn(
          width: 200,
          columnName: 'createdAt',
          title: localizedStrings.fCreatedAtCol,
          sortField: _sortField,
          sortAscending: _sortAscending,
          onSort: _handleSort,
          textTheme: textTheme,
          colorScheme: colorScheme),
      buildSortableGridColumn(
          width: 200,
          columnName: 'updatedAt',
          title: localizedStrings.fUpdatedAtCol,
          sortField: _sortField,
          sortAscending: _sortAscending,
          onSort: _handleSort,
          textTheme: textTheme,
          colorScheme: colorScheme),
      buildSortableGridColumn(
          width: 300,
          columnName: 'remark',
          title: localizedStrings.fRemarkCol,
          sortField: _sortField,
          sortAscending: _sortAscending,
          onSort: _handleSort,
          textTheme: textTheme,
          colorScheme: colorScheme),
      buildGridColumnNoSort(
          width: 80,
          columnName: 'operation',
          title: localizedStrings.fTipOperation,
          textTheme: textTheme,
          colorScheme: colorScheme),
    ];
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
            color: colorScheme.surfaceContainerHigh,
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
        TablePaginationControl(
          currentPage: _currentPage,
          totalPages: _totalPages,
          totalItems: widget.searchDarfFmaInfoList.length,
          onPageChanged: _goToPage,
        ),
      ],
    );
  }
}

class DarftFmaDataSource extends DataGridSource {
  final BuildContext context;
  final List<DarfFmaInfo> allDarftFmaData;
  final ValueChanged<DarfFmaInfo?> onRowSelected;
  final ValueChanged<Set<int>> onMultipleSelectionChanged;
  final Function() onDataChanged;

  List<DarfFmaInfo> currentPageData = [];
  List<DataGridRow> _dataGridRows = [];
  Set<int> _selectedRowIndexes = {};
  DarfFmaInfo? _selectedDarftFma;

  DarftFmaDataSource({
    required this.context,
    required this.allDarftFmaData,
    required this.onRowSelected,
    required this.onMultipleSelectionChanged,
    required this.onDataChanged,
  }) {
    updateCurrentPage(1, 20);
  }

  void updateData(List<DarfFmaInfo> newData) {
    if (!identical(allDarftFmaData, newData)) {
      allDarftFmaData.clear();
      allDarftFmaData.addAll(newData);
    }
    updateCurrentPage(1, 20);
  }

  void updateCurrentPage(int currentPage, int pageSize) {
    final startIndex = (currentPage - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    currentPageData = allDarftFmaData.sublist(
      startIndex.clamp(0, allDarftFmaData.length),
      endIndex.clamp(0, allDarftFmaData.length),
    );

    buildDataGridRows();
    notifyListeners();
  }

  void updateSelection(Set<int> selectedIndexes) {
    _selectedRowIndexes = selectedIndexes;
    notifyListeners();
  }

  void buildDataGridRows() {
    _dataGridRows = currentPageData.map<DataGridRow>((darftFma) {
      return DataGridRow(cells: [
        const DataGridCell<bool>(columnName: 'select', value: false),
        DataGridCell<String>(
          columnName: 'orderId',
          value: darftFma.fmaRec?.header?.orderId ?? '',
        ),
        DataGridCell<String>(
          columnName: 'formulaId',
          value: darftFma.fmaInfo?.header?.formulaId ?? '',
        ),
        DataGridCell<String>(
          columnName: 'formulaName',
          value: darftFma.fmaInfo?.header?.formulaName ?? '',
        ),
        DataGridCell<String>(
          columnName: 'fmaBarcode',
          value: darftFma.fmaInfo?.header?.formulaBarcode ?? '',
        ),
        DataGridCell<String>(
          columnName: 'mode',
          value: darftFma.fmaInfo?.header?.formulaMode == 'pct'
              ? localizedStrings.fPctMode
              : localizedStrings.fWeightMode,
        ),
        DataGridCell<String>(
          columnName: 'materialCount',
          value: darftFma.fmaInfo?.header?.materialCount?.toString() ?? '0',
        ),
        DataGridCell<String>(
          columnName: 'createdAt',
          value: DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(darftFma.fmaRec?.header?.createdAt ?? DateTime.now()),
        ),
        DataGridCell<String>(
          columnName: 'updatedAt',
          value: DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(darftFma.fmaRec?.header?.updatedAt ?? DateTime.now()),
        ),
        DataGridCell<String>(
          columnName: 'remark',
          value: darftFma.fmaRec?.header?.remark ?? '',
        ),
        const DataGridCell<Widget>(columnName: 'operation', value: null),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final int rowIndex = _dataGridRows.indexOf(row);
    final DarfFmaInfo darftFma = currentPageData[rowIndex];
    final colorScheme = Theme.of(context).colorScheme;

    final bool isMultiSelected = _selectedRowIndexes.contains(rowIndex);
    final bool isSingleSelected = _selectedDarftFma?.fmaRec?.header?.orderId ==
        darftFma.fmaRec?.header?.orderId;

    return DataGridRowAdapter(
      color: isSingleSelected
          ? colorScheme.primary.withAlpha(20)
          : isMultiSelected
              ? colorScheme.secondary.withAlpha(20)
              : colorScheme.surfaceContainerHigh,
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: dataGridCell.columnName == 'select'
              ? Alignment.center
              : Alignment.centerLeft,
          child: _buildCellContent(
              dataGridCell, darftFma, rowIndex, isMultiSelected),
        );
      }).toList(),
    );
  }

  Widget _buildCellContent(DataGridCell dataGridCell, DarfFmaInfo darftFma,
      int rowIndex, bool isMultiSelected) {
    final colorScheme = Theme.of(context).colorScheme;

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
              icon: Icon(Icons.delete_forever_outlined,
                  size: 20,
                  color: mySysUser.roleId != operatorRoleId
                      ? colorScheme.error
                      : colorScheme.outline),
              onPressed: mySysUser.roleId != operatorRoleId
                  ? () => _deleteDarftFma(darftFma)
                  : null,
            ),
          ],
        );

      default:
        return InkWell(
          onTap: () {
            _selectedDarftFma = darftFma;
            onRowSelected(darftFma);
            notifyListeners();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dataGridCell.value.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  void _deleteDarftFma(DarfFmaInfo darftFma) {
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
        PublicFunctions.deleteAllDraftRecord(
            [darftFma.fmaRec?.header?.orderId ?? '']);
        onDataChanged();
      }
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
