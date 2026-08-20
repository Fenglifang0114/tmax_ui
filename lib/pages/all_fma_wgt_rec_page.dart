import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:t_max/data/fma_rec_list_db_data.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/plu_field_status_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/dialog/fma_rpt_print_setting.dart';
import 'package:t_max/dialog/fma_server_setting.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/all_fma_wgt_widget.dart';
import 'package:t_max/pages/fma_report_print.dart';
import 'package:t_max/widget/f_open_file.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class AllFmaWgtRecPage extends StatefulWidget {
  const AllFmaWgtRecPage({super.key});

  @override
  State<AllFmaWgtRecPage> createState() => _AllFmaWgtRecPageState();
}

class _AllFmaWgtRecPageState extends State<AllFmaWgtRecPage> {
  // 主数据列表
  List<FmaRecFromDb> _fmaRecsList = [];
  List<FmaRecFromDb> _filteredList = [];

  // 用于DataGrid显示的数据
  List<OrderData> _orderDataList = [];

  // DataGrid控制器
  late DataGridController _dataGridController;
  // 搜索
  final TextEditingController _searchCtl = TextEditingController();

  // 分页相关
  int _currentPage = 1;
  final int _pageSize = 20;
  int totalItems = 0;

  // 排序相关
  String _sortColumn = 'orderId';
  bool _sortAscending = true;

  UploadServerInfo uploadServerInfo = UploadServerInfo();

  // 展开/收起状态
  final Map<String, bool> _expandedOrders = {};
  final Map<String, bool> _selectedOrders = {};

  // 全选状态
  bool _selectAll = false;
  dynamic _eventBus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  String? _exportAllPendingPath;
  IOSink? _exportAllSink;
  Timer? _searchDebounce;

  void _fetchDataFromBackend() {
    Map<String, dynamic> reqMap = {
      'page': _currentPage,
      'pageSize': _pageSize,
      'searchText': _searchCtl.text.trim(),
      'sortColumn': _sortColumn,
      'sortAsc': _sortAscending,
    };
    PublicFunctions.getFormulaRecByPage(jsonEncode(reqMap));
  }

  @override
  void initState() {
    super.initState();
    _fetchDataFromBackend();

    PublicFunctions.getUploadServerConfig();
    _dataGridController = DataGridController();
    _initializeData();
    _updateDisplayData();

    _eventBus1 = eventBus.on<EventRespUploadServerGet>().listen((event) {
      if (mounted) {
        String jsonStr = event.obj;
        if (jsonStr != "" && jsonStr != "fail") {
          try {
            uploadServerInfo = UploadServerInfo.fromJson(jsonDecode(jsonStr));
          } catch (e) {
            uploadServerInfo = UploadServerInfo();
          }
        }
      }
    });

    _eventbus2 = eventBus.on<EventRespFormulaRecByPage>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          try {
            var jsonData = jsonDecode(dataStr);
            int total = jsonData['total'] ?? 0;
            List<dynamic> listDynamic = jsonData['list'] ?? [];
            List<FmaRecFromDb> tempFmaRecList =
                fmaRecFromDbFromJson(jsonEncode(listDynamic));

            setState(() {
              _fmaRecsList.clear();
              _fmaRecsList.addAll(tempFmaRecList);
              _filteredList = List.from(_fmaRecsList);
              totalItems = total;

              _expandedOrders.clear();
              _selectedOrders.clear();
              _selectAll = false;

              for (var order in _filteredList) {
                if (order.header?.recordId != null) {
                  _expandedOrders[order.header!.recordId!] = false;
                  _selectedOrders[order.header!.recordId!] = false;
                }
              }
            });
            _updateDisplayData();
          } catch (e) {
            debugPrint('Error parsing formula rec page: $e');
          }
        } else {
          setState(() {
            _fmaRecsList = [];
            _filteredList = [];
            totalItems = 0;
          });
          _updateDisplayData();
        }
      }
    });

    _eventbus3 = eventBus.on<EventRespDelFormulaWgtRecBatch>().listen((event) {
      if (mounted) {
        _fetchDataFromBackend();
      }
    });

    _eventbus4 = eventBus.on<EventRespDelAllFormulaWgtRec>().listen((event) {
      if (mounted) {
        _fetchDataFromBackend();
      }
    });

    _eventbus5 =
        eventBus.on<EventRespAllFormulaRecForExport>().listen((event) async {
      if (mounted && _exportAllPendingPath != null) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          try {
            var chunkJson = jsonDecode(dataStr);
            var chunkMsg = RespExportChunkMsg.fromJson(chunkJson);

            // 首批数据包：创建 IOSink 文件流并写入 18 列 CSV 表头
            if (chunkMsg.isFirst) {
              final file = File(_exportAllPendingPath!);
              _exportAllSink = file.openWrite(mode: FileMode.write);

              final headerRow = [
                'No.',
                localizedStrings.fFmaIdLabel,
                localizedStrings.fFmaNameLabel,
                localizedStrings.fFmaBarcode,
                localizedStrings.fMaterialNameCol,
                localizedStrings.fMaterialIdCol,
                localizedStrings.fFmaModeCol,
                localizedStrings.fConfidential,
                localizedStrings.fFormulaTotalWeight,
                localizedStrings.fActualTotalWeight,
                localizedStrings.fMaterialSingleWeight,
                localizedStrings.fActualSingleWeight,
                localizedStrings.fAllowableError,
                localizedStrings.fActualError,
                localizedStrings.fWgtUnit,
                localizedStrings.fQualificationStatus,
                localizedStrings.fCreatedAtCol,
                localizedStrings.operator,
              ];
              final headerCsv =
                  "${const ListToCsvConverter().convert([headerRow])}\n";
              _exportAllSink!.write(headerCsv);
            }

            // 写入当前批次的数据（不重复写表头）
            if (chunkMsg.list.isNotEmpty && _exportAllSink != null) {
              List<List<dynamic>> chunkData =
                  buildCsvDataFromFmaRecs(chunkMsg.list, includeHeader: false);
              if (chunkData.isNotEmpty) {
                final chunkCsv =
                    "${const ListToCsvConverter().convert(chunkData)}\n";
                _exportAllSink!.write(chunkCsv);
              }
            }

            // 最后一批数据包：关闭文件句柄并弹出完成提示
            if (chunkMsg.isLast) {
              await _exportAllSink?.flush();
              await _exportAllSink?.close();
              _exportAllSink = null;

              String path = _exportAllPendingPath!;
              _exportAllPendingPath = null;

              if (mounted) {
                showExportDialog(path, context);
              }
            }
          } catch (e) {
            _exportAllSink?.close();
            _exportAllSink = null;
            _exportAllPendingPath = null;
            if (mounted) {
              showTipInfo(e.toString(), context);
            }
          }
        } else {
          _exportAllSink?.close();
          _exportAllSink = null;
          _exportAllPendingPath = null;
          if (mounted) {
            showTipInfo(localizedStrings.fNoRecordTip, context);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _eventBus1?.cancel();
    _eventbus2?.cancel();
    _eventbus3?.cancel();
    _eventbus4?.cancel();
    _eventbus5?.cancel();
    _exportAllSink?.close();
    _searchCtl.dispose();
    super.dispose();
  }

  // 初始化模拟数据
  void _initializeData() {
    _fmaRecsList.clear();
    totalItems = 0;
  }

  // 搜索文本变化处理（增加300ms防抖）
  void _onSearchTextChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _currentPage = 1;
      });
      _fetchDataFromBackend();
    });
  }

  // 更新显示数据（构建数据表格行）
  void _updateDisplayData() {
    _orderDataList = [];

    for (final fmaRec in _filteredList) {
      if (fmaRec.header?.recordId == null) continue;

      _orderDataList.add(OrderData(header: fmaRec.header, isHeader: true));

      if (_expandedOrders[fmaRec.header!.recordId!] == true && fmaRec.details != null) {
        for (final detail in fmaRec.details!) {
          _orderDataList.add(
            OrderData(
              header: fmaRec.header,
              details: detail,
              isHeader: false,
            ),
          );
        }
      }
    }

    _selectAll = _selectedOrders.isNotEmpty &&
        _selectedOrders.values.every((value) => value == true);

    if (_orderDataList.isEmpty) {
      _selectAll = false;
    }

    _dataSource?.updateData(
        _orderDataList, _expandedOrders, _selectedOrders, _selectAll);
    setState(() {});
  }

  // 切换订单展开状态
  void _toggleOrderExpansion(String orderId) {
    setState(() {
      _expandedOrders[orderId] = !(_expandedOrders[orderId] ?? false);
      _updateDisplayData();
    });
  }

  void _onSelectionChanged(String orderId) {
    setState(() {
      _selectedOrders[orderId] = !(_selectedOrders[orderId] ?? false);
      _updateDisplayData();
    });
  }

  _handlePrintPressed(String orderId) {
    FmaRecFromDb fmaData = FmaRecFromDb();
    for (var fmaRec in _fmaRecsList) {
      if (fmaRec.header!.recordId == orderId) {
        fmaData = fmaRec;
        break;
      }
    }

    showDialog(
      context: context,
      builder: (context) => FormulaReportPrint(fmaData: fmaData),
    );
  }

  // 处理排序 - 数据库全量排序并重新拉取第1页
  void _handleSort(String columnName) {
    setState(() {
      if (_sortColumn == columnName) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = columnName;
        _sortAscending = true;
      }
      _currentPage = 1;
    });
    _fetchDataFromBackend();
  }

  // 切换页码
  void _goToPage(int page) {
    int maxPage = _totalPages > 0 ? _totalPages : 1;
    int targetPage = page.clamp(1, maxPage);
    if (targetPage == _currentPage && page != 1) return;
    setState(() {
      _currentPage = targetPage;
    });
    _fetchDataFromBackend();
  }

  // 计算总页数
  int get _totalPages => totalItems > 0 ? (totalItems / _pageSize).ceil() : 1;


  // 数据源实例
  OrderDataSource? _dataSource;

  showTitleAndReturn() {
    return Container(
      height: 54,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.keyboard_double_arrow_left_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  localizedStrings.fRecordTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          showTitleAndReturn(),
          Divider(
            color: Theme.of(context).colorScheme.outline,
            thickness: 1,
            height: 1,
          ),
          showFormulaSearch(),
          // 数据表格
          Expanded(
            child: SfDataGrid(
              frozenColumnsCount: 2,
              footerFrozenColumnsCount: 1,
              headerRowHeight: 40,
              rowHeight: 36,
              source: _dataSource ??= OrderDataSource(
                orderDataList: _orderDataList,
                onExpandPressed: _toggleOrderExpansion,
                onPrintPressed: _handlePrintPressed,
                expandedOrders: _expandedOrders,
                selectedOrders: _selectedOrders,
                onSelectionChanged: _onSelectionChanged,
                colorsInfo: <String, Color>{
                  'primary': Theme.of(context).colorScheme.primary,
                  'success':
                      Theme.of(context).colorScheme.onTertiaryFixedVariant,
                  'error': Theme.of(context).colorScheme.error,
                },
              ),
              controller: _dataGridController,
              columns: _buildColumns(),
              columnWidthMode: ColumnWidthMode.fill,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              allowSorting: false, // 禁用DataGrid内置排序
              allowMultiColumnSorting: false,
              onCellTap: (details) {
                // 处理点击事件
                final rowIndex = details.rowColumnIndex.rowIndex - 1;
                if (rowIndex >= 0 && rowIndex < _orderDataList.length) {
                  final orderData = _orderDataList[rowIndex];

                  // 如果是扩展按钮列
                  if (orderData.isHeader) {
                    _toggleOrderExpansion(orderData.header!.recordId!);
                  }
                }
              },
            ),
          ),

          // 分页控件
          _buildPaginationControls(),
        ],
      ),
    );
  }

  // 处理全选/全不选
  void _handleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;

      for (var key in _selectedOrders.keys) {
        _selectedOrders[key] = _selectAll;
      }

      _dataSource?.updateData(
          _orderDataList, _expandedOrders, _selectedOrders, _selectAll);
    });
  }

  // 获取选中数量
  int _getSelectedCount() {
    return _selectedOrders.values.where((item) => item).length;
  }

  // // 更新全选状态
  // void _updateSelectAllState() {
  //   final headerItems = _orderDataList.where((item) => item.isHeader).toList();
  //   if (headerItems.isEmpty) {
  //     setState(() {
  //       _selectAll = false;
  //     });
  //     return;
  //   }

  //   final allSelected = _selectedOrders.values.every((item) => item);

  //   setState(() {
  //     _selectAll = allSelected;
  //   });
  //   _dataSource?.updateData(
  //       _orderDataList, _expandedOrders, _selectedOrders, _selectAll);
  // }

  Widget titleText(String data) {
    return Text(
      data,
      style: Theme.of(context).textTheme.bodySmall!.apply(
            color: Theme.of(context).colorScheme.onSurface,
          ),
      overflow: TextOverflow.ellipsis,
    );
  }

  // 构建列定义
  List<GridColumn> _buildColumns() {
    return [
      GridColumn(
        columnName: 'checkbox',
        width: 40,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Checkbox(
            value: _selectAll,
            onChanged: _handleSelectAll,
          ),
        ),
      ),
      GridColumn(
        columnName: 'orderId',
        width: 160,
        label: InkWell(
          onTap: () => _handleSort('orderId'),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                titleText('No.'),
                const SizedBox(width: 4),
                if (_sortColumn == 'orderId')
                  Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
      // fmaId 列
      GridColumn(
        columnName: 'fmaId',
        width: 120,
        label: SortableHeader(
          columnName: 'fmaId',
          currentSortColumn: _sortColumn,
          sortAscending: _sortAscending,
          onSort: () => _handleSort('fmaId'),
          child: titleText(localizedStrings.fFmaIdLabel),
        ),
      ),

      GridColumn(
        columnName: 'fmaName',
        width: 200,
        label: SortableHeader(
          columnName: 'fmaName',
          currentSortColumn: _sortColumn,
          sortAscending: _sortAscending,
          onSort: () => _handleSort('fmaName'),
          child: titleText(localizedStrings.fFmaNameLabel),
        ),
      ),

      GridColumn(
        columnName: 'barcode',
        width: 150,
        label: SortableHeader(
          columnName: 'barcode',
          currentSortColumn: _sortColumn,
          sortAscending: _sortAscending,
          onSort: () => _handleSort('barcode'),
          child: titleText(localizedStrings.fFmaBarcode),
        ),
      ),

      GridColumn(
        columnName: 'rawName',
        width: 180,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: titleText(
            localizedStrings.fMaterialNameCol,
          ),
        ),
      ),
      GridColumn(
        columnName: 'rawId',
        width: 150,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: titleText(
            localizedStrings.fMaterialIdCol,
          ),
        ),
      ),
      GridColumn(
        columnName: 'mode',
        width: 100,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: titleText(
            localizedStrings.fFmaModeCol,
          ),
        ),
      ),
      GridColumn(
        columnName: 'confidential',
        width: 150,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: titleText(
            localizedStrings.fConfidential,
          ),
        ),
      ),

      GridColumn(
        columnName: 'fmaTotalWeight',
        width: 260,
        label: SortableHeader(
          columnName: 'fmaTotalWeight',
          currentSortColumn: _sortColumn,
          sortAscending: _sortAscending,
          onSort: () => _handleSort('fmaTotalWeight'),
          child: titleText(localizedStrings.fFormulaTotalWeight),
        ),
      ),

      GridColumn(
        columnName: 'actualTotalWeight',
        width: 260,
        label: SortableHeader(
          columnName: 'actualTotalWeight',
          currentSortColumn: _sortColumn,
          sortAscending: _sortAscending,
          onSort: () => _handleSort('actualTotalWeight'),
          child: titleText(localizedStrings.fActualTotalWeight),
        ),
      ),

      GridColumn(
        columnName: 'rawWgt',
        width: 150,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: titleText(
            localizedStrings.fMaterialSingleWeight,
          ),
        ),
      ),
      GridColumn(
        columnName: 'actualRawWgt',
        width: 200,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: titleText(
            localizedStrings.fActualSingleWeight,
          ),
        ),
      ),
      GridColumn(
        columnName: 'allowableError',
        width: 150,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: titleText(
            localizedStrings.fAllowableError,
          ),
        ),
      ),
      GridColumn(
        columnName: 'actualAllowableError',
        width: 150,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: titleText(
            localizedStrings.fActualError,
          ),
        ),
      ),
      GridColumn(
        columnName: 'pass',
        width: 150,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: titleText(
            localizedStrings.fQualificationStatus,
          ),
        ),
      ),
      GridColumn(
        columnName: 'device',
        width: 150,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: titleText(
            localizedStrings.gDeviceName,
          ),
        ),
      ),
      GridColumn(
        columnName: 'time',
        width: 160,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: titleText(
            localizedStrings.fCreatedAtCol,
          ),
        ),
      ),
      GridColumn(
        columnName: 'operator',
        width: 150,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: titleText(
            localizedStrings.operator,
          ),
        ),
      ),
      GridColumn(
        columnName: 'expand',
        width: 120,
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: titleText(
            localizedStrings.fTipOperation,
          ),
        ),
      ),
    ];
  }

  Map<String, FieldNameStatus> getrptFields() {
    Map<String, FieldNameStatus> rptFields = {
      "formulaId": FieldNameStatus(
          localizedStrings.fFmaIdLabel, rptPrintSetting.formulaId ?? true),
      "formulaName": FieldNameStatus(
          localizedStrings.fFmaNameLabel, rptPrintSetting.formulaName ?? true),
      "formulaBarcode": FieldNameStatus(
          localizedStrings.fFmaBarcode, rptPrintSetting.formulaBarcode ?? true),
      "orderId": FieldNameStatus("NO.", rptPrintSetting.orderId ?? true),
      "saveTime": FieldNameStatus(
          localizedStrings.fCreatedAtCol, rptPrintSetting.saveTime ?? true),
      "operator": FieldNameStatus(
          localizedStrings.operator, rptPrintSetting.operator ?? true),
      "rawId": FieldNameStatus(
          localizedStrings.fMaterialIdCol, rptPrintSetting.rawId ?? true),
      "rawName": FieldNameStatus(
          localizedStrings.fMaterialNameCol, rptPrintSetting.rawName ?? true),
      "pass": FieldNameStatus(
          localizedStrings.fQualificationStatus, rptPrintSetting.pass ?? true),
      "fmaTotalWgt": FieldNameStatus(localizedStrings.fFormulaTotalWeight,
          rptPrintSetting.fmaTotalWgt ?? true),
      "actualTotalWgt": FieldNameStatus(localizedStrings.fActualTotalWeight,
          rptPrintSetting.actualTotalWgt ?? true),
      "deviceName": FieldNameStatus(
          localizedStrings.gDeviceName, rptPrintSetting.deviceName ?? true),
      "rawActualErr": FieldNameStatus(
          localizedStrings.fActualError, rptPrintSetting.rawActualErr ?? true),
      "rawActualWgt": FieldNameStatus(localizedStrings.fActualSingleWeight,
          rptPrintSetting.rawActualWgt ?? true),
    };

    return rptFields;
  }

  bool getExportStatus() {
    return _getSelectedCount() > 0;
  }

  List<List<dynamic>> buildCsvDataFromFmaRecs(List<FmaRecFromDb> records,
      {bool includeHeader = true}) {
    List<List<dynamic>> csvData = [];
    if (includeHeader) {
      final header = [
        'No.',
        localizedStrings.fFmaIdLabel,
        localizedStrings.fFmaNameLabel,
        localizedStrings.fFmaBarcode,
        localizedStrings.fMaterialNameCol,
        localizedStrings.fMaterialIdCol,
        localizedStrings.fFmaModeCol,
        localizedStrings.fConfidential,
        localizedStrings.fFormulaTotalWeight,
        localizedStrings.fActualTotalWeight,
        localizedStrings.fMaterialSingleWeight,
        localizedStrings.fActualSingleWeight,
        localizedStrings.fAllowableError,
        localizedStrings.fActualError,
        localizedStrings.fWgtUnit,
        localizedStrings.fQualificationStatus,
        localizedStrings.fCreatedAtCol,
        localizedStrings.operator,
      ];
      csvData.add(header);
    }

    for (var rowData in records) {
      if (rowData.header == null) continue;
      final headerData = rowData.header;

      final headerRow = [
        headerData?.recordId ?? "",
        headerData?.formulaId ?? "",
        headerData?.formulaName ?? "",
        headerData?.formulaBarcode ?? "",
        "",
        "",
        headerData?.formulaMode == 'wgt'
            ? localizedStrings.fWeightMode
            : localizedStrings.fPctMode,
        headerData?.isEncrypted.toString() == "true"
            ? localizedStrings.fConfidential
            : localizedStrings.fPublic,
        headerData?.actualFmaTotalWgt,
        (headerData?.actualTotalWeight != null
            ? headerData?.actualTotalWeight!.toStringAsFixed(3)
            : ''),
        "",
        "",
        "",
        "",
        headerData?.totalWeightUnit,
        headerData?.isQualified.toString() == "yes" ? "Pass" : "Fail",
        headerData?.recordSaveTime != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss')
                .format(headerData!.recordSaveTime!)
            : '',
        headerData?.headerOperator ?? ''
      ];
      csvData.add(headerRow);

      if (rowData.details != null) {
        for (var detail in rowData.details!) {
          final detailRow = [
            "",
            "",
            "",
            "",
            detail.sequence == 0
                ? localizedStrings.fFmaContainer
                : detail.materialName ?? "",
            detail.materialId ?? "",
            "",
            "",
            "",
            "",
            detail.sequence == 0 ||
                    headerData!.isEncrypted.toString() == "true"
                ? '-'
                : detail.targetWgt.toString(),
            (detail.sequence == 0 ||
                    headerData!.isEncrypted.toString() != "true")
                ? detail.actualWeight.toString()
                : "-",
            detail.sequence == 0 ||
                    headerData!.isEncrypted.toString() == "true"
                ? '-'
                : headerData.formulaMode! == "pct"
                    ? (detail.allowableError! *
                            headerData.actualFmaTotalWgt! /
                            100)
                        .toStringAsFixed(3)
                    : detail.allowableError!.toString(),
            detail.sequence == 0 ||
                    headerData!.isEncrypted.toString() == "true"
                ? '-'
                : detail.actualErrorWgt.toString(),
            headerData!.totalWeightUnit!,
            detail.sequence == 0 ||
                    headerData.isEncrypted.toString() == "true"
                ? '-'
                : detail.isQualified.toString() == "ok"
                    ? "Pass"
                    : "Fail",
            "",
            ""
          ];
          csvData.add(detailRow);
        }
      }
    }

    return csvData;
  }

  Future<void> _writeCsvToFile(String path, List<FmaRecFromDb> records) async {
    try {
      final csvData = buildCsvDataFromFmaRecs(records);
      final csv = const ListToCsvConverter().convert(csvData);
      final file = File(path);
      await file.writeAsString(csv);
      if (!mounted) return;
      showExportDialog(path, context);
    } catch (e) {
      if (mounted) {
        showTipInfo(e.toString(), context);
      }
    }
  }

  Future<void> exportWgtRecords(String path) async {
    List<FmaRecFromDb> selectedRecs = [];
    for (var key in _selectedOrders.keys) {
      if (_selectedOrders[key] == true) {
        for (var rec in _fmaRecsList) {
          if (rec.header?.recordId == key) {
            selectedRecs.add(rec);
            break;
          }
        }
      }
    }
    await _writeCsvToFile(path, selectedRecs);
  }

  Future<void> exportSelectedDataToCSV() async {
    final directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["csv"],
      fileName: 'formulaWgt.csv',
    ));
    if (outputFile != null) {
      if (!outputFile.contains(".csv")) {
        outputFile = "$outputFile.csv";
      }
      exportWgtRecords(outputFile);
    }
  }

  Future<void> exportAllDataToCSV() async {
    final directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["csv"],
      fileName: 'formulaWgt_all.csv',
    ));
    if (outputFile != null) {
      if (!outputFile.contains(".csv")) {
        outputFile = "$outputFile.csv";
      }
      _exportAllPendingPath = outputFile;
      Map<String, dynamic> reqMap = {
        'searchText': _searchCtl.text.trim(),
        'sortColumn': _sortColumn,
        'sortAsc': _sortAscending,
      };
      PublicFunctions.getAllFormulaRecForExport(jsonEncode(reqMap));
    }
  }


  showFormulaSearch() {
    return Container(
      height: 60,
      color: Theme.of(context).colorScheme.surface,
      child: Row(children: [
        const SizedBox(width: 10),
        // 添加搜索框
        SizedBox(
          width: 200,
          height: 40,
          child: TextField(
            controller: _searchCtl,
            decoration: InputDecoration(
              hintText: 'No.',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            style: Theme.of(context).textTheme.bodySmall,
            onChanged: (value) {
              _onSearchTextChanged();
            },
          ),
        ),

        const Spacer(),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 160,
            minHeight: 40,
            maxHeight: 40,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: () {
              Map<String, FieldNameStatus> rptFields = getrptFields();
              List<String> selectedFields = [];

              for (String fieldName in rptFields.keys) {
                if (rptFields[fieldName]!.isSelected) {
                  selectedFields.add(fieldName);
                }
              }

              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => PrintRptSelectDialog(
                        options: rptFields,
                        selectedOptions: selectedFields,
                        context: context,
                      )).then((value) {
                if (value != null) {
                  uploadServerInfo = value;
                }
              });
            },
            child: Text(
              localizedStrings.printSettings,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 160,
            minHeight: 40,
            maxHeight: 40,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: () {
              showDialog(
                      context: context,
                      builder: (context) =>
                          FmaServerSettingDialog(info: uploadServerInfo))
                  .then((value) {
                if (value != null) {
                  uploadServerInfo = value;
                }
              });
            },
            child: Text(
              localizedStrings.autoSync, //Sync Settings
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 200,
            minHeight: 40,
            maxHeight: 40,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor:
                  Theme.of(context).colorScheme.onTertiaryFixedVariant,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: (!getExportStatus())
                ? null
                : () {
                    exportSelectedDataToCSV();
                  },
            child: Text(
              localizedStrings.fExportRecordsBtn,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // 导出全部按钮 (Export All) - 纯文字，有记录亮绿、无记录灰色，宽度自适应上限 160
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 160,
            minHeight: 40,
            maxHeight: 40,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: totalItems > 0
                  ? Theme.of(context).colorScheme.onTertiaryFixedVariant
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: totalItems > 0 ? exportAllDataToCSV : null,
            child: Text(
              localizedStrings.fExportAllRecordsBtn ?? 'Export All',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // 清空全部按钮 (Clear All) - 全库无记录时灰色禁用，有记录时红色可点击，宽度自适应上限 140
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 140,
            minHeight: 40,
            maxHeight: 40,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: totalItems > 0
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: totalItems > 0 ? _handleClearAll : null,
            child: Text(
              localizedStrings.fClearAll ?? 'Clear All',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ),
        ),

        const SizedBox(width: 20),
        // 红色批量删除按钮（针对当前页选中的记录）
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: getExportStatus()
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(0),
          ),
          child: IconButton(
            icon:
                const Icon(Icons.delete_outline, size: 20, color: Colors.white),
            onPressed: getExportStatus() ? _handleBatchDelete : null,
          ),
        ),
        const SizedBox(width: 20),
      ]),
    );
  }

  void _handleClearAll() {
    if (totalItems <= 0) return;

    showDialog<bool>(
      context: context,
      builder: (context) => ShowDeleteTipDialog(
        title: localizedStrings.fTipTitle,
        msg: localizedStrings.fConfirmClearAllFmaRecsMsg ??
            '全库所有配方称重记录将被永久清空且无法恢复，确认清空吗？',
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        PublicFunctions.delAllFormulaWgtRec();
      }
    });
  }

  void _handleBatchDelete() {

    List<String> selectedRecordIds = [];
    _selectedOrders.forEach((key, isSelected) {
      if (isSelected) {
        selectedRecordIds.add(key);
      }
    });

    if (selectedRecordIds.isEmpty) return;

    showDialog<bool>(
      context: context,
      builder: (context) => ShowDeleteTipDialog(
        title: localizedStrings.fTipTitle,
        msg: localizedStrings.fConfirmDelete,
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        PublicFunctions.delFormulaWgtRecBatch(selectedRecordIds);
      }
    });
  }

  // 构建分页控件
  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _currentPage == 1 ? null : () => _goToPage(1),
            tooltip: '',
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
                _currentPage == 1 ? null : () => _goToPage(_currentPage - 1),
            tooltip: '',
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: titleText(' $_currentPage   /   $_totalPages  ')),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage == _totalPages
                ? null
                : () => _goToPage(_currentPage + 1),
            tooltip: '',
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _currentPage == _totalPages
                ? null
                : () => _goToPage(_totalPages),
            tooltip: '',
          ),
          const SizedBox(width: 20),
          titleText('Page size: $_pageSize    Total ${_filteredList.length}  ')
        ],
      ),
    );
  }
}
