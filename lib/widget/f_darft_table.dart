import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/functions/methods.dart';

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
            '${localizedStrings.tipPageTotal}: ${widget.searchDarfFmaInfoList.length} ${localizedStrings.tipPageItems}',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
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
              _sortAscending = !_sortAscending;
            } else {
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
    if (_sortField == '' || widget.searchDarfFmaInfoList.isEmpty) return;

    setState(() {
      widget.searchDarfFmaInfoList.sort((a, b) {
        dynamic valueA;
        dynamic valueB;

        switch (_sortField) {
          case 'formulaId':
            valueA = a.fmaInfo?.header?.formulaId ?? '';
            valueB = b.fmaInfo?.header?.formulaId ?? '';
            break;
          case 'formulaName':
            valueA = a.fmaInfo?.header?.formulaName ?? '';
            valueB = b.fmaInfo?.header?.formulaName ?? '';
            break;
          case 'orderId':
            valueA = a.fmaRec?.header?.orderId ?? '';
            valueB = b.fmaRec?.header?.orderId ?? '';
            break;
          case 'confidential':
            valueA = a.fmaInfo?.header?.isEncrypted ?? false;
            valueB = b.fmaInfo?.header?.isEncrypted ?? false;
            break;
          case 'mode':
            valueA = a.fmaInfo?.header?.formulaMode ?? '';
            valueB = b.fmaInfo?.header?.formulaMode ?? '';
            break;
          case 'materialCount':
            valueA = a.fmaInfo?.header?.materialCount ?? 0;
            valueB = b.fmaInfo?.header?.materialCount ?? 0;
            break;
          case 'createdAt':
            valueA = a.fmaRec?.header?.createdAt ?? DateTime.now();
            valueB = b.fmaRec?.header?.createdAt ?? DateTime.now();
            break;
          case 'remark':
            valueA = a.fmaInfo?.header?.remark ?? '';
            valueB = b.fmaInfo?.header?.remark ?? '';
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
      getColumnWidget(150, 'formulaId', localizedStrings.fFmaIdLabel, textTheme,
          colorScheme),
      getColumnWidget(200, 'formulaName', localizedStrings.fFmaNameLabel,
          textTheme, colorScheme),
      getColumnWidget(
          200, 'orderId', localizedStrings.fOrderNo, textTheme, colorScheme),
      getColumnWidget(150, 'confidential', localizedStrings.fConfidential,
          textTheme, colorScheme),
      getColumnWidget(
          120, 'mode', localizedStrings.fFmaModeCol, textTheme, colorScheme),
      getColumnWidget(120, 'materialCount',
          localizedStrings.fIngredientCountLabel, textTheme, colorScheme),
      getColumnWidget(200, 'createdAt', localizedStrings.fCreatedAtCol,
          textTheme, colorScheme),
      getColumnWidget(
          500, 'remark', localizedStrings.fRemarkCol, textTheme, colorScheme),
      getColumnWidgetNoSort(
          80, 'delete', localizedStrings.gBtnDelete, textTheme, colorScheme),
    ];
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
    allDarftFmaData.clear();
    allDarftFmaData.addAll(newData);
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
        DataGridCell<bool>(columnName: 'select', value: false),
        DataGridCell<String>(
          columnName: 'formulaId',
          value: darftFma.fmaInfo?.header?.formulaId ?? '',
        ),
        DataGridCell<String>(
          columnName: 'formulaName',
          value: darftFma.fmaInfo?.header?.formulaName ?? '',
        ),
        DataGridCell<String>(
          columnName: 'orderId',
          value: darftFma.fmaRec?.header?.orderId ?? '',
        ),
        DataGridCell<String>(
          columnName: 'confidential',
          value: (darftFma.fmaInfo?.header?.isEncrypted ?? false)
              ? localizedStrings.fConfidential
              : localizedStrings.fPublic,
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
          columnName: 'remark',
          value: darftFma.fmaInfo?.header?.remark ?? '',
        ),
        DataGridCell<Widget>(columnName: 'delete', value: null),
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
              : colorScheme.surface,
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
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

      case 'delete':
        return IconButton(
          icon: Icon(Icons.delete_forever_outlined,
              size: 20, color: colorScheme.error),
          onPressed: () => _deleteDarftFma(darftFma),
        );

      case 'confidential':
        return Text(
          dataGridCell.value.toString(),
          style: textTheme.bodySmall?.copyWith(
            color: (darftFma.fmaInfo?.header?.isEncrypted ?? false)
                ? colorScheme.error
                : colorScheme.onTertiaryFixedVariant,
          ),
          overflow: TextOverflow.ellipsis,
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
                    style: textTheme.bodySmall,
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
        PublicFunctions.deleteDraftRecord(
            darftFma.fmaRec?.header?.orderId ?? '');
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
