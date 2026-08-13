//配方导入方法

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/foundation.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/import_fma_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/scale_info_from_db.dart';

//找出配方列表中是否已经存在了此配方
bool isFormulaExist(String formulaId) {
  if (formulaDataList.isEmpty) {
    return false;
  }
  final target = formulaId.trim().toLowerCase();
  return formulaDataList.any((formula) =>
      (formula.header?.formulaId ?? '').trim().toLowerCase() == target);
}

bool isFormulaBarcodeExist(String barcode) {
  if (formulaDataList.isEmpty) {
    return false;
  }
  final target = barcode.trim().toLowerCase();
  return formulaDataList.any((formula) =>
      (formula.header?.formulaBarcode ?? '').trim().toLowerCase() == target);
}

bool isRawExist(String rawId) {
  if (rawDataList.isEmpty) {
    return false;
  }
  final cleanId = rawId.trim().toLowerCase();
  final strippedId = cleanId.replaceFirst(RegExp(r'^0+'), '');
  return rawDataList.any((raw) {
    final matId = (raw.materialId ?? '').trim().toLowerCase();
    final strippedMatId = matId.replaceFirst(RegExp(r'^0+'), '');
    return matId == cleanId || (strippedId.isNotEmpty && strippedId == strippedMatId);
  });
}

// 优化后的导入函数：提前校验字段，过滤无效行
Future<ImportFmaResult> importFormulasFromExcel(File file) async {
  ImportFmaResult result = ImportFmaResult(
    isSuccess: false,
    errorMessage: '',
    importFmaInfoList: [],
  );

  final stopwatch = Stopwatch()..start(); // 用于监控导入性能
  try {
    // 1. 读取CSV并解析
    var bytes = await file.readAsBytes();
    final localizedMap = _getFormulaHeaderMap();
    final decodeResult = _decodeCsvBytes(bytes, localizedMap, fmaHeaders);
    String csvString = decodeResult.content;

    if (decodeResult.matchCount == 0) {
      try {
        csvString = gbk.decode(bytes);
      } catch (e) {
        result.errorMessage = localizedStrings.gMsgUseUtf8;
        return result;
      }
    }
    
    // 增加一步：处理首行可能残留的 BOM 字符
    if (csvString.startsWith('\uFEFF')) {
      csvString = csvString.substring(1);
    }
    List<List<dynamic>> sheetRows = const CsvToListConverter(shouldParseNumbers: false).convert(csvString);

    if (sheetRows.isEmpty) {
      result.errorMessage = localizedStrings.noDataImport;
      return result;
    }

    //大于1000行 提示用户一次读取1000行
    if (sheetRows.length > 1001) {
      result.errorMessage = localizedStrings.max1000Rows;
      return result;
    }

    // 2. 解析表头并映射列索引（关键优化：用索引定位列，避免多次查找）
    final Map<String, int> columnIndexMap = {};

    for (var i = 0; i < sheetRows.first.length; i++) {
      final cell = sheetRows.first[i];
      if (cell != null && cell.toString().isNotEmpty) {
        String header = cell.toString().trim();
        String head = _cleanHeader(header);
        
        // 查找匹配的内部键
        String? internalKey;
        if (fmaHeaders.contains(head)) {
          internalKey = head;
        } else {
          // 查找是否匹配中文/英文本地化名称
          for (var entry in localizedMap.entries) {
            if (_cleanHeader(entry.value) == head) {
              internalKey = entry.key;
              break;
            }
          }
        }

        if (internalKey != null) {
          if (columnIndexMap.containsKey(internalKey)) {
            result.errorMessage =
                localizedStrings.duplicateHeaders + '：$header  ';
            return result;
          }
          columnIndexMap[internalKey] = i;
        }
      }
    }
    //验证表头是否完整
    final missingHeader = _validateHeaders(columnIndexMap.keys.toList());
    if (missingHeader.isNotEmpty) {
      result.errorMessage = localizedStrings.missingHeaders + '：$missingHeader';
      return result;
    }

    int count = 1; //计算序号

    final List<Map<String, dynamic>> validRows = [];
    for (int rowIdx = 1; rowIdx < sheetRows.length; rowIdx++) {
      final row = sheetRows[rowIdx];
      if (_isRowEmpty(row)) {
        debugPrint('跳过空行: $rowIdx');
        continue;
      }

      final rowData = <String, dynamic>{};

      // 4.1 校验Formula Id（非空）
      final formulaIdCol = columnIndexMap['formulaid']!;
      final formulaIdValue = _getCellValue(row, formulaIdCol);
      if (formulaIdValue.isEmpty) {
        result.errorMessage = localizedStrings.formulaIdEmpty +
            ',${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else if (isFormulaExist(formulaIdValue)) {
        result.errorMessage =
            '$formulaIdValue ${localizedStrings.formulaIdExists}, ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else {
        rowData['formulaid'] = formulaIdValue;
        rowData["no"] = count;
        count++;
      }

      // 4.1 校验Formula Barcode
      String barcodeValue = "";
      final barcodeCol = columnIndexMap.containsKey('barcode')
          ? columnIndexMap['barcode']!
          : -1;
      if (barcodeCol == -1) {
        barcodeValue = formulaIdValue;
      } else {
        barcodeValue = _getCellValue(row, barcodeCol);
      }

      if (barcodeValue.isEmpty) {
        barcodeValue = formulaIdValue;
      }
      if (isFormulaBarcodeExist(barcodeValue)) {
        result.errorMessage =
            '$barcodeValue ${localizedStrings.formulaBarcodeExists}, ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      }

      rowData['barcode'] = barcodeValue;

      // 4.2 校验Formula Name（非空）
      final formulaNameCol = columnIndexMap['formulaname']!;
      final formulaName = _getCellValue(row, formulaNameCol).trim();
      if (formulaName.isEmpty) {
        result.errorMessage = localizedStrings.formulaNameEmpty +
            ', ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else {
        rowData['formulaname'] = formulaName;
      }

      // 4.3 校验Mode（非空+合法值）
      final modeCol = columnIndexMap['mode']!;
      final mode = _getCellValue(row, modeCol).trim().toLowerCase();
      if (mode.isEmpty) {
        result.errorMessage = localizedStrings.modeEmpty +
            ', ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else if (!['weight', 'percent', "percentage"].contains(mode)) {
        result.errorMessage = localizedStrings.modeInvalid +
            '：$mode , ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else {
        rowData['mode'] = mode;
        // 当Mode为weight时，校验Weight Unit
        if (mode == 'weight') {
          final weightUnitCol = columnIndexMap['weightunit']!;
          final weightUnit = _getCellValue(row, weightUnitCol).trim();
          if (weightUnit.isEmpty) {
            result.errorMessage = localizedStrings.weightUnitEmpty +
                ', ${localizedStrings.tipRow}:${rowIdx + 1}';
            return result;
          } else {
            rowData['weightunit'] = weightUnit;
          }
        }
      }

      // 4.5 校验Ingredient Id（非空）
      final ingredientIdCol = columnIndexMap['ingredientid']!;
      final ingredientId = _getCellValue(row, ingredientIdCol).trim();
      if (ingredientId.isEmpty) {
        result.errorMessage = localizedStrings.ingredientIdEmpty +
            ', ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else if (!isRawExist(ingredientId)) {
        result.errorMessage = localizedStrings.ingredientIdNotExist +
            ', ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else {
        rowData['ingredientid'] = ingredientId;
      }

      // 4.6 校验Weight/Percent（非空+正数+最多3位小数）
      final weightCol = columnIndexMap['ingredientweight/percentage']!;
      final weightValue = _getCellValue(row, weightCol);
      if (weightValue.isEmpty) {
        result.errorMessage = localizedStrings.weightPercentEmpty +
            ', ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else if (!_isValidDecimal(weightValue,
          maxDecimals: 3, minValue: 0.001)) {
        result.errorMessage = localizedStrings.weightPercentInvalid +
            '：$weightValue , ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else {
        rowData['ingredientweight/percentage'] = double.parse(weightValue);
      }

      // 4.7 校验Allow Error（非空+正数+最多3位小数）
      final errorCol = columnIndexMap['allowableerror']!;
      final errorValue = _getCellValue(row, errorCol);
      if (errorValue.isEmpty) {
        result.errorMessage = localizedStrings.allowErrorEmpty +
            ', ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else if (!_isValidDecimal(errorValue,
          maxDecimals: 3, minValue: 0.001)) {
        result.errorMessage = localizedStrings.allowErrorInvalid +
            '：$errorValue , ${localizedStrings.tipRow}:${rowIdx + 1}';
        return result;
      } else {
        rowData['allowableerror'] = double.parse(errorValue);
      }

      // 4.8 处理可选字段（无需校验，为空则存null）
      rowData['category'] = columnIndexMap.containsKey('category')
          ? _getCellValue(row, columnIndexMap['category']!).trim()
          : "";
      rowData['isconfidential'] = columnIndexMap.containsKey('confidential')
          ? _getCellValue(row, columnIndexMap['confidential']!)
                  .trim()
                  .toLowerCase() ==
              'yes'
          : false;
      rowData['needcontainer'] = columnIndexMap.containsKey('needcontainer')
          ? _getCellValue(row, columnIndexMap['needcontainer']!)
                  .trim()
                  .toLowerCase() ==
              'yes'
          : false;
      rowData['notes'] = columnIndexMap.containsKey('notes')
          ? _getCellValue(row, columnIndexMap['notes']!).trim()
          : "";

      // 4.9 收集行错误或保留有效行

      validRows.add(rowData);
    }

    // 5. 对有效行进行分组和成分顺序校验（数据量已减少，性能提升）
    final formulaGroups = <String, List<Map<String, dynamic>>>{};
    Map<String, String> barcodeList = {};
    for (final row in validRows) {
      final formulaId = row['formulaid'];
      if (!formulaGroups.containsKey(formulaId)) {
        formulaGroups[formulaId] = [];
      }

      final barcode = row['barcode'] as String;
      if (barcodeList.containsKey(barcode) &&
          formulaId != barcodeList[barcode]) {
        result.errorMessage = localizedStrings.formulaBarcodeInconsistent +
            ',  ID :$formulaId  :${barcodeList[barcode]}';
        return result; // 找到一个不一致就终止循环，无需继续检查
      } else {
        barcodeList[barcode] = formulaId;
      }

      formulaGroups[formulaId]!.add(row);
    }

    barcodeList = {};

    // 6. 验证成分编号连续性并构建Formula对象
    final List<ImportFmaInfo> validFormulas = [];
    for (final formulaId in formulaGroups.keys) {
      final groupRows = formulaGroups[formulaId]!;

      // 提取配方基础信息（取第一行的公共字段）
      final firstRow = groupRows.first;
      final formulaName = firstRow['formulaname'] as String;
      final mode = firstRow['mode'] as String;
      final weightUnit =
          mode == 'weight' ? firstRow['weightunit'] as String : null;
      final category = firstRow['category'] as String?;
      final isConfidential = firstRow['isconfidential'] as bool;
      final needContainer = firstRow['needcontainer'] as bool;
      final notes = firstRow['notes'] as String;
      final barcode = firstRow['barcode'] as String;

      // 排序并验证成分编号连续性
      final ingredients = groupRows
          .map((row) => Ingredient(
                ingredientNo: row['no'] as int,
                ingredientId: row['ingredientid'] as String,
                weightOrPercent: row['ingredientweight/percentage'] as double,
                allowError: row['allowableerror'] as double,
              ))
          .toList()
        ..sort((a, b) => a.ingredientNo!.compareTo(b.ingredientNo!));

      final firstFormulaName = firstRow['formulaname'] as String;
      for (final row in groupRows) {
        final currentName = row['formulaname'] as String;
        if (currentName != firstFormulaName) {
          result.errorMessage = localizedStrings.formulaNameInconsistent +
              ', :$currentName  :$firstFormulaName';
          return result; // 找到一个不一致就终止循环，无需继续检查
        }
      }

      final firstBarcodeName = firstRow['barcode'] as String;
      for (final row in groupRows) {
        final currentName = row['barcode'] as String;
        if (currentName != firstBarcodeName) {
          result.errorMessage = localizedStrings.formulaBarcodeInconsistent +
              ', :$currentName  :$firstBarcodeName';
          return result; // 找到一个不一致就终止循环，无需继续检查
        }
      }

      // 重写成分编号从1开始连续
      for (int i = 0; i < ingredients.length; i++) {
        ingredients[i].ingredientNo = i + 1;
      }

      // 检查2：如果是百分比模式，验证总和是否为100（允许±0.01的浮点数误差）

      if (mode == 'percent' || mode == 'percentage') {
        double totalPercent = 0;
        for (var ingredient in ingredients) {
          //只要三位小数计算
          totalPercent +=
              double.parse(ingredient.weightOrPercent!.toStringAsFixed(3));
        }
        totalPercent = double.parse(totalPercent.toStringAsFixed(3));
        // 浮点数比较需用容差，避免精度问题（如99.9999999999或100.0000000001应视为有效）
        if (totalPercent != 100) {
          result.errorMessage = localizedStrings.percentNot100 +
              '${totalPercent.toStringAsFixed(3)}%';
          return result;
        }
      }

      validFormulas.add(ImportFmaInfo(
        formulaId: formulaId,
        formulaName: formulaName,
        mode: mode,
        weightUnit: weightUnit,
        category: category,
        isConfidential: isConfidential,
        needContainer: needContainer,
        ingredients: ingredients,
        notes: notes,
        barcode: barcode,
      ));
    }

    // 7. 输出导入结果和性能数据
    stopwatch.stop();
    final msg =
        '导入完成：成功${validFormulas.length}个配方,耗时${stopwatch.elapsedMilliseconds}ms';
    debugPrint(msg);

    return ImportFmaResult(
        isSuccess: true,
        errorMessage: localizedStrings.tipImporting,
        importFmaInfoList: validFormulas);
  } catch (e) {
    stopwatch.stop();
    return ImportFmaResult(
        isSuccess: false, errorMessage: e.toString(), importFmaInfoList: []);
  }
}

// 辅助函数：获取单元格值（处理空单元格）
String _getCellValue(List<dynamic> row, int colIndex) {
  if (colIndex >= row.length) return '';
  final cell = row[colIndex];
  if (cell == null || cell.toString().isEmpty) return '';
  return cell.toString().trim();
}

// 辅助函数：验证数值是否为正数且最多N位小数
bool _isValidDecimal(String value,
    {required int maxDecimals, required double minValue}) {
  // 正则表达式：匹配正数，最多maxDecimals位小数
  final regex =
      RegExp(r'^[0-9]+(\.[0-9]{1,' + maxDecimals.toString() + r'})?$');
  if (!regex.hasMatch(value)) return false;

  // 验证数值大于minValue（避免0或负数）
  final numValue = double.tryParse(value);
  return numValue != null && numValue > minValue;
}

String _validateHeaders(List<String> headers) {
  for (final header in importFmaHeaders.keys) {
    if (!headers.contains(header)) {
      return importFmaHeaders[header]!;
    }
  }
  return "";
}

const Map<String, String> importFmaHeaders = {
  'formulaid': "Formula Id",
  'formulaname': "Formula Name",
  'mode': "Mode",
  'weightunit': "Weight Unit",
  'ingredientid': "Ingredient Id",
  'ingredientweight/percentage': "Ingredient Weight/Percentage",
  'allowableerror': "Allowable Error",
};

const fmaHeaders = [
  'formulaid',
  'formulaname',
  'barcode',
  'mode',
  'weightunit',
  'category',
  'confidential',
  'needcontainer',
  'ingredientid',
  'ingredientweight/percentage',
  'allowableerror',
  'notes'
];

// 清理表头字符：去除 BOM、空格、星号并转小写
String _cleanHeader(String header) {
  String clean = header.trim();
  // 去除 UTF-8 BOM (\uFEFF)
  if (clean.startsWith('\uFEFF')) {
    clean = clean.substring(1);
  }
  // 去除可能的 misinterpreted BOM (ï»¿)
  if (clean.startsWith('ï»¿')) {
    clean = clean.substring(3);
  }
  return clean.replaceAll(" ", "").replaceAll("*", "").toLowerCase();
}

// 获取配方导入表头与本地化的映射
Map<String, String> _getFormulaHeaderMap() {
  return {
    'formulaid': localizedStrings.fFmaIdLabel,
    'formulaname': localizedStrings.fFmaNameLabel,
    'barcode': localizedStrings.fFmaBarcode,
    'mode': localizedStrings.fFmaModeCol,
    'weightunit': localizedStrings.gTipWeightUnit,
    'category': localizedStrings.fFmaCategoryCol,
    'confidential': localizedStrings.fConfidential,
    'needcontainer': localizedStrings.fFmaContainer,
    'ingredientid': localizedStrings.fMaterialIdCol,
    'ingredientweight/percentage': localizedStrings.fMaterialSingleWeight,
    'allowableerror': localizedStrings.fAllowableError,
    'notes': localizedStrings.fFmaRemark,
  };
}

// 获取原料导入表头与本地化的映射
Map<String, String> _getRawHeaderMap() {
  return {
    'ingredientid': localizedStrings.fMaterialIdCol,
    'ingredientname': localizedStrings.fMaterialNameCol,
    'verificationcode': localizedStrings.fMaterialCodeCol,
    'category': localizedStrings.fFmaCategoryCol,
    'ingredientnotes': localizedStrings.fIngredientRemark,
    'devicename': localizedStrings.gDeviceName,
  };
}

//导入Raw数据
int checkScaleName(String scaleName) {
  for (var scale in myAllScalesList) {
    if (scaleName == scale.scaleName) {
      return scale.scaleId;
    }
  }
  return 0;
}

// 判断一行是否为空的辅助函数
bool _isRowEmpty(List<dynamic> row) {
  return row.every((cell) =>
      cell == null ||
      cell.toString().trim().isEmpty);
}

const Map<String, String> importRawHeaders = {
  'ingredientid': "Ingredient Id",
  'ingredientname': "Ingredient Name",
};

const List<String> rawHeaders = [
  'ingredientid',
  'ingredientname',
  "verificationcode",
  'category',
  'ingredientnotes',
  'devicename'
];

List<String> getRawIdList() {
  List<String> idList = [];
  for (var i = 0; i < rawDataList.length; i++) {
    var id = rawDataList[i].materialId!;

    idList.add(id);
  }
  return idList;
}

Map<String, String> getScaleNameList() {
  Map<String, String> scaleIdNameMap = {};
  for (var i = 0; i < myAllScalesList.length; i++) {
    var scaleId = myAllScalesList[i].scaleId.toString();
    var scaleName = myAllScalesList[i].scaleName;
    scaleIdNameMap[scaleId] = scaleName;
  }
  return scaleIdNameMap;
}

Future<ImportRawResult> importRawFromExcel(File file) async {
  List<String> rawIdList = getRawIdList();
  Map<String, String> scaleNameList = getScaleNameList();
  try {
    // 在后台isolate中执行繁重的Excel解析
    return await compute(_parseExcelInBackground, {
      'filePath': file.path,
      'rawHeaders': rawHeaders,
      'importRawHeaders': importRawHeaders,
      'rowIdList': rawIdList,
      'scaleNameList': scaleNameList,
      'localizedRawHeaders': _getRawHeaderMap(), // 传入当前语言的表头
      'messages': {
        'noDataImport': localizedStrings.noDataImport,
        'max5000Rows': localizedStrings.max5000Rows,
        'missingHeaders': localizedStrings.missingHeaders,
        'tipRow': localizedStrings.tipRow,
        'ingredientNameEmpty': localizedStrings.ingredientNameEmpty,
        'deviceNameNotExist': localizedStrings.deviceNameNotExist,
        'ingredientIdIsEmpty': localizedStrings.ingredientIdIsEmpty,
        'fRawIdDuplicate': localizedStrings.fRawIdDuplicate,
        'duplicateHeaders': localizedStrings.duplicateHeaders,
        'tipImporting': localizedStrings.tipImporting,
        'useUtf8': localizedStrings.gMsgUseUtf8,
      }
    });
  } catch (e) {
    return ImportRawResult(
      isSuccess: false,
      errorMessage: "fail：${e.toString()}",
      importRawList: [],
    );
  }
}

// 在后台isolate中执行的解析函数
ImportRawResult _parseExcelInBackground(params) {
  final importRawHeadersDynamic =
      params['importRawHeaders'] as Map<String, dynamic>;

  // 手动转换为 Map<String, String>
  final Map<String, String> importRawHeaders = {};
  importRawHeadersDynamic.forEach((key, value) {
    importRawHeaders[key] = value.toString();
  });

  final rawHeadersDynamic = params['rawHeaders'] as List<dynamic>;
  final List<String> rawHeaders =
      rawHeadersDynamic.map((e) => e.toString()).toList();
  final rowIdListDynamic = params['rowIdList'] as List<dynamic>;
  final List<String> rowIdList =
      rowIdListDynamic.map((e) => e.toString()).toList();

  final scaleNameListDynamic = params['scaleNameList'] as Map<String, dynamic>;
  final Map<String, String> scaleNameList = scaleNameListDynamic
      .map((key, value) => MapEntry(key.toString(), value.toString()));

  final messagesDynamic = params['messages'] as Map<String, dynamic>;
  final Map<String, String> messages = {};
  messagesDynamic.forEach((key, value) {
    messages[key] = value.toString();
  });

  final filePath = params['filePath'] as String;

  final file = File(filePath);
  final bytes = file.readAsBytesSync();
  final localizedRawHeaders = params['localizedRawHeaders'] as Map<String, dynamic>;
  final Map<String, String> localizedHeadersMap = localizedRawHeaders.map((key, value) => MapEntry(key.toString(), value.toString()));
  final List<String> importHeaders = (params['rawHeaders'] as List<dynamic>).map((e) => e.toString()).toList();
  
  final decodeResult = _decodeCsvBytes(bytes, localizedHeadersMap, importHeaders);
  String csvString = decodeResult.content;

  if (decodeResult.matchCount == 0) {
    try {
      csvString = gbk.decode(bytes);
    } catch (e) {
      return ImportRawResult(
        isSuccess: false,
        errorMessage: messages['useUtf8']!,
        importRawList: [],
      );
    }
  }

  // 增加一步：处理首行可能残留的 BOM 字符
  if (csvString.startsWith('\uFEFF')) {
    csvString = csvString.substring(1);
  }
  List<List<dynamic>> sheetRows = const CsvToListConverter(shouldParseNumbers: false).convert(csvString);

  if (sheetRows.isEmpty) {
    return ImportRawResult(
      isSuccess: false,
      errorMessage: messages['noDataImport']!,
      importRawList: [],
    );
  }

  // 行数检查
  if (sheetRows.length > 5001) {
    return ImportRawResult(
      isSuccess: false,
      errorMessage: messages['max5000Rows']!,
      importRawList: [],
    );
  }

  // 解析表头
  List<String> headers = [];
  List<int> headerIndexList = [];

  for (var i = 0; i < sheetRows.first.length; i++) {
    dynamic cell = sheetRows[0][i];
    if (cell != null && cell.toString().isNotEmpty) {
      String headStr = cell.toString().trim();
      String head = _cleanHeader(headStr);
      
      String? internalKey;
      if (rawHeaders.contains(head)) {
        internalKey = head;
      } else {
        // 查找匹配的本地化名称
        for (var entry in localizedRawHeaders.entries) {
          if (_cleanHeader(entry.value.toString()) == head) {
            internalKey = entry.key;
            break;
          }
        }
      }

      if (internalKey != null) {
        if (headers.contains(internalKey)) {
          return ImportRawResult(
            isSuccess: false,
            errorMessage: '${messages['duplicateHeaders']!}：$headStr',
            importRawList: [],
          );
        }
        headers.add(internalKey);
        headerIndexList.add(i);
      }
    }
  }

  // 验证表头
  String headerError = _validateRawHeadersStatic(headers, importRawHeaders);
  if (headerError != '') {
    return ImportRawResult(
      isSuccess: false,
      errorMessage: '${messages['missingHeaders']!}：$headerError',
      importRawList: [],
    );
  }

  // 解析数据行
  List<String> idList = [];
  List<String> nameList = [];
  List<String> scaleIdList = [];
  List<String> typeList = [];
  List<String> notesList = [];
  List<String> codeList = [];

  for (int rowIndex = 1; rowIndex < sheetRows.length; rowIndex++) {
    var rowData = sheetRows[rowIndex];

    // 跳过空行
    if (_isRowEmptyStatic(rowData)) continue;

    String? id, name, type, notes, code;
    int scaleId = 0;

    for (int col = 0; col < rowData.length; col++) {
      final cellValue = rowData[col];
      final value = cellValue?.toString().trim() ?? '';
      int headerIndex = 0;

      if (!headerIndexList.contains(col)) {
        continue;
      } else {
        headerIndex = headerIndexList.indexOf(col);
      }

      switch (headers[headerIndex]) {
        case 'ingredientid':
          id = value;
          if (id.isEmpty) {
            return ImportRawResult(
              isSuccess: false,
              errorMessage:
                  '${messages['tipRow']!}: ${rowIndex + 1}: ${messages['ingredientIdIsEmpty']!}',
              importRawList: [],
            );
          }
          if (idList.contains(id) || checkRawExist(rowIdList, id)) {
            return ImportRawResult(
              isSuccess: false,
              errorMessage:
                  '${messages['tipRow']!}: ${rowIndex + 1}: $id ${messages['fRawIdDuplicate']!}',
              importRawList: [],
            );
          }

          break;
        case 'ingredientname':
          name = value;
          if (name.isEmpty) {
            return ImportRawResult(
              isSuccess: false,
              errorMessage:
                  '${messages['tipRow']!}: ${rowIndex + 1}: ${messages['ingredientNameEmpty']!}',
              importRawList: [],
            );
          }
          break;
        case 'verificationcode':
          code = value;
          break;
        case 'category':
          type = value;
          break;
        case 'ingredientnotes':
          notes = value;
          break;
        case 'devicename':
          if (value.isNotEmpty) {
            scaleId = _checkScaleNameStatic(scaleNameList, value);
            if (scaleId == 0) {
              return ImportRawResult(
                isSuccess: false,
                errorMessage:
                    '${messages['tipRow']!}: ${rowIndex + 1}: ${messages['deviceNameNotExist']!}',
                importRawList: [],
              );
            }
          }
          break;
      }
    }

    idList.add(id!);
    nameList.add(name!);
    scaleIdList.add(scaleId.toString());
    typeList.add(type ?? '');
    notesList.add(notes ?? '');
    codeList.add(code ?? "");
  }

  List<List<String>> info = [
    idList,
    nameList,
    scaleIdList,
    typeList,
    notesList,
    codeList
  ];

  return ImportRawResult(
    isSuccess: true,
    errorMessage: messages['tipImporting']!,
    importRawList: info,
  );
}

// 静态辅助函数（可在isolate中使用）
bool _isRowEmptyStatic(List<dynamic> row) {
  return row.every((cell) =>
      cell == null ||
      cell.toString().trim().isEmpty);
}

String _validateRawHeadersStatic(
    List<String> headers, Map<String, String> importRawHeaders) {
  for (final header in importRawHeaders.keys) {
    if (!headers.contains(header)) {
      return importRawHeaders[header]!;
    }
  }
  return "";
}

int _checkScaleNameStatic(Map<String, String> scaleNameList, String scaleName) {
  for (final scaleId in scaleNameList.keys) {
    if (scaleName == scaleNameList[scaleId]) {
      return int.parse(scaleId);
    }
  }

  return 0; // 示例实现
}

bool checkRawExist(List<String> rawIdList, String materialId) {
  return rawIdList.any((element) => element == materialId);
}

// 智能解码CSV字节的结果
class _CsvDecodeResult {
  final String content;
  final int matchCount;
  _CsvDecodeResult(this.content, this.matchCount);
}

// 智能解码CSV字节：尝试UTF-8和GBK，并通过匹配表头数量来决定最佳编码
_CsvDecodeResult _decodeCsvBytes(List<int> bytes, Map<String, String> localizedHeaders, List<String> internalHeaders) {
  String tryDecodeUtf8() {
    try {
      if (bytes.length >= 3 && bytes[0] == 0xef && bytes[1] == 0xbb && bytes[2] == 0xbf) {
        return utf8.decode(bytes.sublist(3), allowMalformed: true);
      } else {
        return utf8.decode(bytes, allowMalformed: true);
      }
    } catch (e) {
      return '';
    }
  }

  String tryDecodeGbk() {
    try {
      return gbk.decode(bytes);
    } catch (e) {
      // 容错GBK/GB2312解码：过滤掉无法严格解析的乱码尾部字节
      List<int> validBytes = [];
      for (int i = 0; i < bytes.length; i++) {
        if (bytes[i] <= 0x7F) {
          validBytes.add(bytes[i]); // ASCII
        } else if (i + 1 < bytes.length) {
          if (bytes[i] >= 0x81 && bytes[i] <= 0xFE && bytes[i+1] >= 0x40 && bytes[i+1] <= 0xFE) {
            validBytes.add(bytes[i]);
            validBytes.add(bytes[i+1]);
            i++;
          }
        }
      }
      try {
        return gbk.decode(validBytes);
      } catch (_) {
        return '';
      }
    }
  }

  int countMatches(String csvString) {
    if (csvString.isEmpty) return -1;
    if (csvString.startsWith('\uFEFF')) {
      csvString = csvString.substring(1);
    }
    try {
      List<List<dynamic>> sheetRows = const CsvToListConverter(shouldParseNumbers: false).convert(csvString);
      if (sheetRows.isEmpty) return 0;
      int matchCount = 0;
      for (var cell in sheetRows.first) {
        if (cell != null && cell.toString().isNotEmpty) {
          String head = _cleanHeader(cell.toString().trim());
          if (internalHeaders.contains(head)) {
            matchCount++;
          } else {
            bool found = false;
            for (var entry in localizedHeaders.entries) {
              if (_cleanHeader(entry.value) == head) {
                found = true;
                break;
              }
            }
            if (found) matchCount++;
          }
        }
      }
      return matchCount;
    } catch (e) {
      return -1;
    }
  }

  String utf8Str = tryDecodeUtf8();
  int utf8Matches = countMatches(utf8Str);

  String gbkStr = tryDecodeGbk();
  int gbkMatches = countMatches(gbkStr);

  // 如果GBK匹配表头多，或者UTF-8解码出乱码替换符(\uFFFD)但GBK至少有匹配，则使用GBK
  if ((gbkMatches > utf8Matches && gbkMatches > 0) || (utf8Str.contains('\uFFFD') && gbkMatches > 0)) {
    return _CsvDecodeResult(gbkStr, gbkMatches);
  } else {
    String bestContent = utf8Str.isNotEmpty ? utf8Str : gbkStr;
    int bestMatches = utf8Str.isNotEmpty ? utf8Matches : gbkMatches;
    return _CsvDecodeResult(bestContent, bestMatches < 0 ? 0 : bestMatches);
  }
}

