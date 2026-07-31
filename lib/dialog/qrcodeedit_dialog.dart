import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:t_max/data/barcoderowdata.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dialog_head_style.dart';
import 'package:t_max/widget/rowdatawidget.dart';

class MyQrcodeDialog extends StatefulWidget {
  const MyQrcodeDialog({super.key});
  @override
  MyQrcodeDialogState createState() => MyQrcodeDialogState();
}

class MyQrcodeDialogState extends State<MyQrcodeDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<BarCodeRowDataInfo> _displayedData = [];
  final List<BarCodeRowDataInfo> _originalData = [];
  final ScrollController _scrollController = ScrollController();

  // 列宽定义
  final Map<String, double> _columnWidths = {
    'barCodeName': 150,
    'barCodeType': 150,
    'type': 120,
    'content': 100,
    'defaultValue': 118,
    'alignment': 120,
    'maxLength': 110,
    'operations': 170,
  };

  double get _totalWidth => _columnWidths.values.reduce((a, b) => a + b);

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _originalData.clear();
    List<BarCodeRowDataInfo> showBarcodeList = [];
    for (var item in myBarCodeListList.barCodeListList) {
      if (item.barCodeType == "Qrcode") {
        showBarcodeList.add(item);
      }
    }
    _originalData.addAll(showBarcodeList);
    _displayedData = List.from(_originalData);
  }

  void _handleExpandChanged(int index) {
    if (index < 0) return;

    setState(() {
      if (index < _displayedData.length) {
        final item = _displayedData[index];
        item.isExpand = !(item.isExpand ?? false);
      }
    });
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayedData = List.from(_originalData);
      } else {
        _displayedData = _originalData.where((item) {
          return item.barCodeName.toLowerCase().contains(query.toLowerCase()) ||
              _containsInRowData(item, query);
        }).toList();
      }
    });
  }

  bool _containsInRowData(BarCodeRowDataInfo item, String query) {
    return item.barCodeRowDataList.any((rowData) =>
        rowData.type.toLowerCase().contains(query.toLowerCase()) ||
        rowData.content.toLowerCase().contains(query.toLowerCase()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        width: 1080,
        height: 680,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withAlpha(50),
            ),
          ],
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(
              context,
              localizedStrings.gQrcodeMgr,
              true,
              onClose: () => Navigator.pop(context),
            ),

            // 内容区域
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(regularPadding),
                child: Column(
                  children: [
                    // 搜索和操作区域
                    _buildActionArea(theme, colorScheme),
                    const SizedBox(height: regularPadding),
                    // 数据表格区域
                    Expanded(
                      child: _displayedData.isEmpty
                          ? _buildEmptyState(theme)
                          : _buildDataTableWithFixedHeader(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionArea(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          // 搜索框
          Expanded(
            child: SizedBox(
              height: btnHeight,
              child: TextField(
                controller: _searchController,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  hintText: localizedStrings.searchName,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withAlpha(128),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: largePadding),

          // 操作按钮
          _buildActionButtons(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        // 清空按钮
        showTextButton(
          context,
          btnHeight,
          localizedStrings.fClearBtn,
          _displayedData.isEmpty ? null : _showClearConfirmationDialog,
          colorScheme.onPrimary,
          colorScheme.error,
          colorScheme.onError,
        ),

        const SizedBox(width: largePadding),

        // 添加按钮
        showTextButton(
          context,
          btnHeight,
          localizedStrings.gBtnAdd,
          _showAddBarCodeDialog,
          colorScheme.onPrimary,
          colorScheme.primary,
          colorScheme.onPrimary,
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code,
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            localizedStrings.noBarCodeDataTip,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(128),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTableWithFixedHeader() {
    return Container(
      decoration: BoxDecoration(
        border:
            Border.all(color: Theme.of(context).dividerColor.withAlpha(128)),
      ),
      child: Column(
        children: [
          // 固定表头
          _buildTableHeader(),

          // 可滚动的内容区域
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              child: SizedBox(
                width: _totalWidth,
                child: Column(
                  children: [
                    for (int index = 0; index < _displayedData.length; index++)
                      _buildMainDataRow(_displayedData[index], index),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 48,
      color: Colors.blue[50],
      child: Row(
        children: [
          _buildHeaderCell(
              localizedStrings.gQrcodeName, _columnWidths['barCodeName']!),
          _buildHeaderCell(
              localizedStrings.gQrcodeType, _columnWidths['barCodeType']!),
          _buildHeaderCell(
              localizedStrings.gBarCodeDataType, _columnWidths['type']!),
          _buildHeaderCell(
              localizedStrings.gBarCodeContent, _columnWidths['content']!),
          _buildHeaderCell(localizedStrings.gBarCodeDefValue,
              _columnWidths['defaultValue']!),
          _buildHeaderCell(
              localizedStrings.gBarCodeAlignment, _columnWidths['alignment']!),
          _buildHeaderCell(
              localizedStrings.gBarCodeMaxLength, _columnWidths['maxLength']!),
          _buildHeaderCell(
              localizedStrings.fTipOperation, _columnWidths['operations']!),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMainDataRow(BarCodeRowDataInfo item, int index) {
    return Column(
      children: [
        // 主数据行
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            border: Border(
                bottom:
                    BorderSide(color: Theme.of(context).colorScheme.surface)),
          ),
          child: Row(
            children: [
              // 条码名称
              _buildDataCell(item.barCodeName, _columnWidths['barCodeName']!),

              // 条码类型
              _buildDataCell(item.barCodeType, _columnWidths['barCodeType']!),

              _buildDataCell('', _columnWidths['type']!),

              _buildDataCell('', _columnWidths['content']!),

              _buildDataCell('', _columnWidths['defaultValue']!),

              _buildDataCell('', _columnWidths['alignment']!),

              Container(
                width: _columnWidths['maxLength']!,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                alignment: Alignment.center,
                child: Text(
                  '',
                  style: const TextStyle(fontSize: 13),
                ),
              ),

              // 展开/收起按钮
              Container(
                  width: _columnWidths['operations']!,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () {
                          _showEditBarCodeDialog(
                              item.barCodeName, item.barCodeType);
                        },
                        color: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.zero,
                        tooltip: localizedStrings.gBtnEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () {
                          showDeleteWidget(item);
                        },
                        color: Theme.of(context).colorScheme.error,
                        padding: EdgeInsets.zero,
                        tooltip: localizedStrings.gBtnDelete,
                      ),
                      IconButton(
                        icon: Icon(
                          item.isExpand ?? false
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        onPressed: () => _handleExpandChanged(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),

        // 展开的明细行
        if (item.isExpand ?? false) _buildDetailRows(item, index),
      ],
    );
  }

  dynamic showDeleteWidget(BarCodeRowDataInfo item) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ShowDeleteTipDialog(
              title: localizedStrings.fTipTitle,
              msg: localizedStrings.fConfirmDelete);
        }).then((value) {
      if (value == true) {
        // 确认删除，执行删除操作
        for (int i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
          if (myBarCodeListList.barCodeListList[i].barCodeName ==
              item.barCodeName) {
            myBarCodeListList.barCodeListList.removeAt(i);
            break;
          }
        }
        setState(() {
          _initializeData();
        });
        _saveDataToJson();
      }
    });
  }

  Widget _buildDataCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildDetailRows(BarCodeRowDataInfo item, int parentIndex) {
    if (item.barCodeRowDataList.isEmpty) {
      return Container(
        height: 40,
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: Text(
            "",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return Column(
      children: item.barCodeRowDataList.asMap().entries.map((entry) {
        final detail = entry.value;

        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom:
                  BorderSide(color: Theme.of(context).colorScheme.surfaceDim),
            ),
          ),
          child: Row(
            children: [
              // 条码名称（明细行留空）
              _buildDetailCell("", _columnWidths['barCodeName']!),

              // 条码类型（明细行留空）
              _buildDetailCell("", _columnWidths['barCodeType']!),

              // 类型
              _buildDetailCell(detail.type, _columnWidths['type']!),

              // 内容
              _buildDetailCell(detail.content, _columnWidths['content']!),

              // 默认值
              _buildDetailCell(
                  detail.type == "TEXT" ? "-" : detail.defaultvalue,
                  _columnWidths['defaultValue']!),

              // 对齐方式
              _buildDetailCell(detail.type == "TEXT" ? "-" : detail.alignment,
                  _columnWidths['alignment']!),

              // 最大长度
              Container(
                width: _columnWidths['maxLength']!,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                alignment: Alignment.center,
                child: Text(
                  detail.type == "TEXT" ? "-" : detail.maxlength.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),

              // 删除按钮
              Container(
                width: _columnWidths['operations']!,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                child: SizedBox(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => ShowDeleteTipDialog(
          title: localizedStrings.fTipTitle,
          msg: localizedStrings.fClearDataBtn),
    ).then((value) {
      if (value == true) {
        // 确认清空，执行清空操作
        _clearAllData();
      }
    });
  }

  void _clearAllData() {
    setState(() {
      for (int i = myBarCodeListList.barCodeListList.length - 1; i >= 0; i--) {
        if (myBarCodeListList.barCodeListList[i].barCodeType == "Qrcode") {
          myBarCodeListList.barCodeListList.removeAt(i);
        }
      }
      _originalData.clear();
      _displayedData.clear();
      _searchController.clear();
      _saveDataToJson();
    });
  }

  Future<File> get _localFile async {
    final directory = p.dirname(Platform.script.toFilePath());
    return File(p.join(directory, 'barcodedata.json'));
  }

  _saveDataToJson() async {
    String json = jsonEncode(myBarCodeListList.barCodeListList);
    if (kDebugMode) {
      print(json);
    }
    final file = await _localFile;
    // 将字符串写入文件中
    file.writeAsStringSync(json);
  }

  void _showAddBarCodeDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          EditBarCodeDialog(selBarcodeName: "", selBarcodeType: "Qrcode"),
    ).then((value) {
      setState(() {
        _initializeData();
      });
    });
  }

  void _showEditBarCodeDialog(String barcodeName, String barcodeType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditBarCodeDialog(
        selBarcodeName: barcodeName,
        selBarcodeType: barcodeType,
      ),
    ).then((value) {
      setState(() {
        _initializeData();
      });
    });
  }
}

class EditBarCodeDialog extends StatefulWidget {
  const EditBarCodeDialog({
    super.key,
    required this.selBarcodeName,
    required this.selBarcodeType,
  });
  final String selBarcodeName;
  final String selBarcodeType;
  @override
  EditBarCodeDialogState createState() => EditBarCodeDialogState();
}

class EditBarCodeDialogState extends State<EditBarCodeDialog> {
  late TextEditingController _barCodeNameCtl;
  BarCodeRowDataInfo editBacode = BarCodeRowDataInfo([], '', '');
  List<BarCodeRowData> editRowList = [];

  String _selectedBarcodeName = '--';

  @override
  void initState() {
    _barCodeNameCtl = TextEditingController(text: '');

    _selBarcodeInfo(widget.selBarcodeName);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        width: 1080,
        height: 680,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withAlpha(50),
            ),
          ],
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(
              context,
              localizedStrings.gQrcodeEdit,
              true,
              onClose: () => Navigator.pop(context),
            ),

            // 内容区域
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(largePadding),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            child: Text(
                              localizedStrings.gQrcodeName,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: showInputBox(
                                context, _barCodeNameCtl, '', (value) {}, true),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          showTextButton(
                            context,
                            btnHeight,
                            localizedStrings.gBtnAdd,
                            _addRowData,
                            colorScheme.onPrimary,
                            colorScheme.primary,
                            colorScheme.onPrimary,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          showTextButton(
                            context,
                            btnHeight,
                            localizedStrings.gBtnSave,
                            _saveRowData,
                            colorScheme.onPrimary,
                            colorScheme.onTertiaryFixedVariant,
                            colorScheme.onPrimary,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          showTextButton(
                            context,
                            btnHeight,
                            localizedStrings.gBtnDelete,
                            _deleteRowData,
                            colorScheme.onPrimary,
                            colorScheme.error,
                            colorScheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.all(5),
                      color: colorScheme.surfaceDim,
                      child: Row(mainAxisSize: MainAxisSize.max, children: [
                        Expanded(
                            child:
                                _buildTitle(localizedStrings.gBarCodeDataType)),
                        Expanded(
                            child:
                                _buildTitle(localizedStrings.gBarCodeContent)),
                        Expanded(
                            child:
                                _buildTitle(localizedStrings.gBarCodeDefValue)),
                        Expanded(
                            child: _buildTitle(
                                localizedStrings.gBarCodeAlignment)),
                        Expanded(
                            child: _buildTitle(
                                localizedStrings.gBarCodeMaxLength)),
                        SizedBox(
                            width: 50,
                            child:
                                _buildTitle(localizedStrings.gBarCodeDelete)),
                      ]),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: editRowList.length,
                        itemBuilder: (context, index) {
                          return RowDataWidget(
                            rowData: editRowList[index],
                            rowDataList: editRowList,
                            onChanged: (value) {
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selBarcodeInfo(String barcodeName) {
    setState(() {
      _selectedBarcodeName = barcodeName;
      _barCodeNameCtl.text = barcodeName;

      for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
        var barcode = myBarCodeListList.barCodeListList[i];

        if (barcode.barCodeName == _selectedBarcodeName &&
            barcode.barCodeType == 'Qrcode') {
          _saveDataList(barcode);

          break;
        }
      }
    });
  }

  Future<File> get _localFile async {
    final directory = p.dirname(Platform.script.toFilePath());
    return File(p.join(directory, 'barcodedata.json'));
  }

  _saveDataList(BarCodeRowDataInfo barcode) {
    String type = '';
    String content = '';
    String defaultvalue = '';
    String alignment = '';
    int maxlength = 0;
    List<BarCodeRowData> tempRowDataList = [];
    for (var j = 0; j < barcode.barCodeRowDataList.length; j++) {
      alignment = barcode.barCodeRowDataList[j].alignment;
      content = barcode.barCodeRowDataList[j].content;
      defaultvalue = barcode.barCodeRowDataList[j].defaultvalue;
      maxlength = barcode.barCodeRowDataList[j].maxlength;
      type = barcode.barCodeRowDataList[j].type;

      tempRowDataList.add(
          BarCodeRowData(type, content, defaultvalue, alignment, maxlength));
    }

    editRowList = tempRowDataList;
  }

  _saveDataToJson() async {
    if (myBarCodeListList.barCodeListList.isNotEmpty) {
      String json = jsonEncode(myBarCodeListList.barCodeListList);
      if (kDebugMode) {
        print(json);
      }
      final file = await _localFile;
      // 将字符串写入文件中
      file.writeAsStringSync(json);

      // await loadData();   此处已经写好了如何捞回来条码信息
    }
  }

  _saveBarCodeNameToList() {
    if (myBarCodeListList.barCodeListList.isNotEmpty) {
      mySavedQrcodeName.savedQrcodeName.clear();
      for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
        if (myBarCodeListList.barCodeListList[i].barCodeType == 'Qrcode') {
          mySavedQrcodeName.savedQrcodeName
              .add(myBarCodeListList.barCodeListList[i].barCodeName);
        }
      }
      mySavedQrcodeName.savedQrcodeName.add('--');
    } else {
      mySavedQrcodeName.savedQrcodeName.clear();
    }
  }

  void _addRowData() {
    if (_barCodeNameCtl.text != '--') {
      setState(() {
        editRowList.add(BarCodeRowData('TEXT', '', '', 'Left', 7));
      });
    } else {
      showTipInfo(localizedStrings.invalidName, context);
    }
  }

  bool _judgeData() {
    bool res = true;

    if (_barCodeNameCtl.text.isNotEmpty && editRowList.isNotEmpty) {
      for (var i = 0; i < editRowList.length; i++) {
        if (editRowList[i].type == 'TEXT') {
          if (editRowList[i].content.isEmpty) {
            showTipInfo(localizedStrings.contentMissing, context);
            res = false;
            return res;
          }
        } else {
          if (editRowList[i].alignment == '--' ||
              editRowList[i].maxlength == 0) {
            showTipInfo(localizedStrings.variableAlignmentEmpty, context);
            res = false;
            return res;
          }
        }
      }

      if (_barCodeNameCtl.text != widget.selBarcodeName) {
        for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
          if (myBarCodeListList.barCodeListList[i].barCodeName ==
                  _barCodeNameCtl.text &&
              myBarCodeListList.barCodeListList[i].barCodeType == 'Qrcode') {
            showTipInfo(localizedStrings.nameAlreadyExists, context);
            res = false;
            return res;
          }
        }
      }
    } else {
      showTipInfo(localizedStrings.nameNotEntered, context);
      res = false;
      return res;
    }
    return res;
  }

  void _saveRowData() {
    setState(() {
      if (!_judgeData()) {
        return;
      }
      editBacode.barCodeName = _barCodeNameCtl.text;
      editBacode.barCodeType = 'Qrcode';
      String tempName = _barCodeNameCtl.text;
      bool isExist = false;

      if (myBarCodeListList.barCodeListList.isNotEmpty) {
        for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
          if (myBarCodeListList.barCodeListList[i].barCodeName ==
                  widget.selBarcodeName &&
              myBarCodeListList.barCodeListList[i].barCodeType == 'Qrcode') {
            myBarCodeListList.barCodeListList.removeAt(i);
            _savingData(tempName);
            isExist = true;
            break;
          }
        }
      }
      if (!isExist) {
        _savingData(tempName);
      }
    });
  }

  void _savingData(String tempName) {
    String type = '';
    String content = '';
    String defaultvalue = '';
    String alignment = '';
    int maxlength = 0;
    List<BarCodeRowData> tempRowDataList = [];
    for (var i = 0; i < editRowList.length; i++) {
      alignment = editRowList[i].alignment;
      content = editRowList[i].content;
      defaultvalue = editRowList[i].defaultvalue;
      maxlength = editRowList[i].maxlength;
      type = editRowList[i].type;

      tempRowDataList.add(
          BarCodeRowData(type, content, defaultvalue, alignment, maxlength));
    }
    myBarCodeListList.barCodeListList.add(BarCodeRowDataInfo(
      tempRowDataList,
      _barCodeNameCtl.text,
      'Qrcode',
    ));
    showTipInfo(localizedStrings.savedSuccessfully + " ($tempName)", context);
    _saveBarCodeNameToList();
    _saveDataToJson();
  }

  void _deleteRowData() {
    setState(() {
      editRowList.clear();
    });
  }
}
