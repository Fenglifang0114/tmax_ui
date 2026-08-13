import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/add_raw_info_dialog.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/functions/methods.dart';

class RawMaterialTable extends StatefulWidget {
  final List<RawDataInfo> searchRawList;
  final ValueChanged<RawDataInfo?> onRawSelected;
  final ValueChanged<List<RawDataInfo>> onMultipleSelected;
  final Function() onDataChanged;

  const RawMaterialTable({
    super.key,
    required this.searchRawList,
    required this.onRawSelected,
    required this.onMultipleSelected,
    required this.onDataChanged,
  });

  @override
  State<RawMaterialTable> createState() => _RawMaterialTableState();
}

class _RawMaterialTableState extends State<RawMaterialTable> {
  late RawMaterialDataSource _dataSource;
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
    _dataSource = RawMaterialDataSource(
      context: context,
      allRawData: widget.searchRawList,
      onRowSelected: widget.onRawSelected,
      onMultipleSelectionChanged: _updateMultipleSelection,
      onDataChanged: widget.onDataChanged,
    );
    _calculateTotalPages();
  }

  void _calculateTotalPages() {
    _totalPages = (widget.searchRawList.length / _pageSize).ceil();
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
      if (actualIndex < widget.searchRawList.length) {
        currentPageIndexes.add(actualIndex);
      }
    }

    _allSelectedIndexes
        .removeWhere((index) => currentPageIndexes.contains(index));

    for (var index in selectedIndexes) {
      final actualIndex = pageStartIndex + index;
      _allSelectedIndexes.add(actualIndex);
    }

    final selectedRaws = _allSelectedIndexes.map((index) {
      return widget.searchRawList[index];
    }).toList();

    widget.onMultipleSelected(selectedRaws);
  }

  void _toggleSelectAll(bool? value) {
    final selectAll = value ?? false;
    setState(() {
      _selectAll = selectAll;
    });

    if (selectAll) {
      _allSelectedIndexes = Set<int>.from(
          List.generate(widget.searchRawList.length, (index) => index));

      final pageStartIndex = (_currentPage - 1) * _pageSize;
      final pageEndIndex = pageStartIndex + _pageSize;

      final currentPageSelectedIndexes = <int>{};
      for (int i = pageStartIndex;
          i < pageEndIndex && i < widget.searchRawList.length;
          i++) {
        currentPageSelectedIndexes.add(i - pageStartIndex);
      }

      _dataSource.updateSelection(currentPageSelectedIndexes);
      widget.onMultipleSelected(widget.searchRawList);
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
          i < pageEndIndex && i < widget.searchRawList.length;
          i++) {
        if (_allSelectedIndexes.contains(i)) {
          currentPageSelectedIndexes.add(i - pageStartIndex);
        }
      }

      _dataSource.updateCurrentPage(_currentPage, _pageSize);
      _dataSource.updateSelection(currentPageSelectedIndexes);

      setState(() {
        _selectAll =
            _allSelectedIndexes.length == widget.searchRawList.length &&
                widget.searchRawList.isNotEmpty;
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
            '${localizedStrings.tipPageTotal}: ${widget.searchRawList.length} ${localizedStrings.tipPageItems}',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant RawMaterialTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchRawList != widget.searchRawList) {
      _dataSource.updateData(widget.searchRawList);
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
    if (_sortField == '' || widget.searchRawList.isEmpty) return;

    setState(() {
      widget.searchRawList.sort((a, b) {
        dynamic valueA;
        dynamic valueB;

        switch (_sortField) {
          case 'materialId':
            valueA = a.materialId;
            valueB = b.materialId;
            break;
          case 'materialName':
            valueA = a.materialName;
            valueB = b.materialName;
            break;
          case 'checkCode':
            valueA = a.checkCode;
            valueB = b.checkCode;
            break;
          case 'scaleName':
            valueA = _getScaleName(a.scaleId);
            valueB = _getScaleName(b.scaleId);
            break;
          case 'category':
            valueA = getRawTypeName(a.categoryId!);
            valueB = getRawTypeName(b.categoryId!);
            break;
          case 'createdAt':
            valueA = a.createdAt;
            valueB = b.createdAt;
            break;
          case 'updatedAt':
            valueA = a.updatedAt;
            valueB = b.updatedAt;
            break;
          case 'ingredient':
            valueA = a.ingredient;
            valueB = b.ingredient;
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

      _dataSource.updateData(widget.searchRawList);
    });
  }

  String _getScaleName(int? scaleId) {
    if (scaleId == null) return '-';
    for (var scale in myAllScalesList) {
      if (scale.scaleId == scaleId) {
        return scale.scaleName;
      }
    }
    return '-';
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
      getColumnWidget(150, 'materialId', localizedStrings.fMaterialIdCol,
          textTheme, colorScheme),
      getColumnWidget(300, 'materialName', localizedStrings.fMaterialNameCol,
          textTheme, colorScheme),
      getColumnWidget(200, 'checkCode', localizedStrings.verificationCode,
          textTheme, colorScheme),
      getColumnWidget(
          150, 'output', localizedStrings.outputPort, textTheme, colorScheme),
      getColumnWidget(150, 'scaleName', localizedStrings.gDeviceName, textTheme,
          colorScheme),
      getColumnWidget(200, 'category', localizedStrings.fRawMaterialTypeNameCol,
          textTheme, colorScheme),
      getColumnWidget(200, 'createdAt', localizedStrings.fCreatedAtCol,
          textTheme, colorScheme),
      getColumnWidget(200, 'updatedAt', localizedStrings.fUpdatedAtCol,
          textTheme, colorScheme),
      getColumnWidget(400, 'ingredient', localizedStrings.fIngredientRemark,
          textTheme, colorScheme),
      getColumnWidgetNoSort(120, 'operation', localizedStrings.fTipOperation,
          textTheme, colorScheme),
    ];
  }
}

class RawMaterialDataSource extends DataGridSource {
  final BuildContext context;
  final List<RawDataInfo> allRawData;
  final ValueChanged<RawDataInfo?> onRowSelected;
  final ValueChanged<Set<int>> onMultipleSelectionChanged;
  final Function() onDataChanged;

  List<RawDataInfo> currentPageData = [];
  List<DataGridRow> _dataGridRows = [];
  Set<int> _selectedRowIndexes = {};
  RawDataInfo? _selectedRaw;

  RawMaterialDataSource({
    required this.context,
    required this.allRawData,
    required this.onRowSelected,
    required this.onMultipleSelectionChanged,
    required this.onDataChanged,
  }) {
    updateCurrentPage(1, 20);
  }

  void updateData(List<RawDataInfo> newData) {
    allRawData.clear();
    allRawData.addAll(newData);
    updateCurrentPage(1, 20);
  }

  void updateCurrentPage(int currentPage, int pageSize) {
    final startIndex = (currentPage - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    currentPageData = allRawData.sublist(
      startIndex.clamp(0, allRawData.length),
      endIndex.clamp(0, allRawData.length),
    );

    buildDataGridRows();
    notifyListeners();
  }

  void updateSelection(Set<int> selectedIndexes) {
    _selectedRowIndexes = selectedIndexes;
    notifyListeners();
  }

  void buildDataGridRows() {
    _dataGridRows = currentPageData.map<DataGridRow>((raw) {
      return DataGridRow(cells: [
        DataGridCell<bool>(columnName: 'select', value: false),
        DataGridCell<String>(
          columnName: 'materialId',
          value: raw.materialId,
        ),
        DataGridCell<String>(
          columnName: 'materialName',
          value: raw.materialName,
        ),
        DataGridCell<String>(
          columnName: 'checkCode',
          value: raw.checkCode,
        ),
        DataGridCell<String>(
          columnName: 'output',
          value: _getOutput(raw.output),
        ),
        DataGridCell<String>(
          columnName: 'scaleName',
          value: _getScaleName(raw.scaleId),
        ),
        DataGridCell<String>(
          columnName: 'category',
          value: getRawTypeName(raw.categoryId!),
        ),
        DataGridCell<String>(
          columnName: 'createdAt',
          value: DateFormat('yyyy-MM-dd HH:mm:ss').format(raw.createdAt!),
        ),
        DataGridCell<String>(
          columnName: 'updatedAt',
          value: DateFormat('yyyy-MM-dd HH:mm:ss').format(raw.updatedAt!),
        ),
        DataGridCell<String>(
          columnName: 'ingredient',
          value: raw.ingredient,
        ),
        DataGridCell<Widget>(columnName: 'operation', value: null),
      ]);
    }).toList();
  }

  String _getOutput(int? output) {
    if (output == null) return '-';
    if (output == 0) {
      return '-';
    }

    return output.toString();
  }

  String _getScaleName(int? scaleId) {
    if (scaleId == null) return '-';
    for (var scale in myAllScalesList) {
      if (scale.scaleId == scaleId) {
        return scale.scaleName;
      }
    }
    return '-';
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final int rowIndex = _dataGridRows.indexOf(row);
    final RawDataInfo raw = currentPageData[rowIndex];
    final colorScheme = Theme.of(context).colorScheme;

    final bool isMultiSelected = _selectedRowIndexes.contains(rowIndex);
    final bool isSingleSelected = _selectedRaw?.materialId == raw.materialId;

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
          child:
              _buildCellContent(dataGridCell, raw, rowIndex, isMultiSelected),
        );
      }).toList(),
    );
  }

  Widget _buildCellContent(DataGridCell dataGridCell, RawDataInfo raw,
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 20,
                  color: mySysUser.roleId != operatorRoleId
                      ? colorScheme.primary
                      : colorScheme.outline),
              onPressed: mySysUser.roleId != operatorRoleId
                  ? () => _editRaw(raw)
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.delete_forever_outlined,
                  size: 20,
                  color: mySysUser.roleId != operatorRoleId
                      ? colorScheme.error
                      : colorScheme.outline),
              onPressed: mySysUser.roleId != operatorRoleId
                  ? () => _deleteRaw(raw)
                  : null,
            )
          ],
        );

      default:
        return InkWell(
          onTap: () {
            _selectedRaw = raw;
            onRowSelected(raw);
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

  void _editRaw(RawDataInfo raw) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EditRawDialog(rawData: raw);
      },
    ).then((value) {
      if (value != null) {
        onDataChanged();
      }
    });
  }

  void _deleteRaw(RawDataInfo raw) {
    // 检查原料是否被配方使用
    bool canDelete = _checkRawDelete(raw);
    if (!canDelete) {
      showTipInfo(localizedStrings.fFormulaInUseDeleteErrorMsg, context);
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
        PublicFunctions.deleteRawData(raw.recId!);
        onDataChanged();
      }
    });
  }

  bool _checkRawDelete(RawDataInfo raw) {
    final targetMaterialId = raw.materialId;
    return formulaDataList.every((formula) {
      return formula.details?.every((detail) {
            return detail.materialId != targetMaterialId;
          }) ??
          true;
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
