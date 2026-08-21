import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/fma_import_raw.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/import_fma_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/f_export.dart';
import 'package:t_max/widget/f_open_file.dart';

/// 配方与原料数据 I/O 服务类（包含 CSV/Excel 导入导出、批处理分发）
class FormulaIOService {
  /// 下载原料模板
  static Future<void> getRawTemplate(BuildContext context) async {
    final directory = Directory.current.path;
    String? outputFile = await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["csv"],
      fileName: 'Ingredient_template.csv',
    );
    if (outputFile == null) return;

    if (!outputFile.contains(".csv")) {
      outputFile = "$outputFile.csv";
    }
    String filePath = outputFile;
    ExportResult result = await exportRawTemplate(filePath);
    if (!context.mounted) return;
    if (result.isSuccess) {
      showExportDialog(filePath, context);
    } else {
      showTipInfo(result.errorMessage!, context);
    }
  }

  /// 下载配方模板
  static Future<void> getFmaTemplate(BuildContext context) async {
    final directory = Directory.current.path;
    String? outputFile = await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["csv"],
      fileName: 'Formula_template.csv',
    );
    if (outputFile == null) return;

    if (!outputFile.contains(".csv")) {
      outputFile = "$outputFile.csv";
    }
    String filePath = outputFile;
    ExportResult result = await exportFmaTemplate(filePath);
    if (!context.mounted) return;
    if (result.isSuccess) {
      showExportDialog(filePath, context);
    } else {
      if (context.mounted) {
        showTipInfo(result.errorMessage!, context);
      }
    }
  }

  /// 导入原料 CSV
  static Future<void> importRaw(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null) return;
    File file = File(result.files.single.path!);
    if (!context.mounted) return;
    showTipInfo(localizedStrings.tipValidating, context);

    ImportRawResult resImport = await importRawFromExcel(file);

    if (!context.mounted) return;
    if (!resImport.isSuccess) {
      showTipInfo(resImport.errorMessage!, context);
      return;
    }
    showTipInfo(resImport.errorMessage!, context);
    sendRawListInBatches(resImport.importRawList);
  }

  /// 原料分批次发送后台
  static Future<void> sendRawListInBatches(List<List<String>> dataList) async {
    const batchSize = 100;

    final List<String> allBatches = await compute(_prepareAllBatches, {
      'dataList': dataList,
      'batchSize': batchSize,
      'userName': mySysUser.nickName!,
    });

    int currentBatch = 0;

    for (final jsonStr in allBatches) {
      currentBatch++;

      await Future.delayed(Duration.zero);

      PublicFunctions.importRawList(jsonStr);

      if (currentBatch < allBatches.length) {
        await waitAndSendNext();
      }
    }
    await waitAndSendNext();

    eventBus.fire(EventImportRawOK(''));
  }

  /// 后台 Isolate 中准备原料批次数据
  static List<String> _prepareAllBatches(Map<String, dynamic> params) {
    final dataList = params['dataList'] as List<List<String>>;
    final batchSize = params['batchSize'] as int;
    final userName = params['userName'] as String;

    List<String> batches = [];
    int totalItems = dataList[0].length;

    for (int start = 0; start < totalItems; start += batchSize) {
      int end =
          (start + batchSize) < totalItems ? (start + batchSize) : totalItems;

      List<RawInfo> batch = [];
      for (int i = start; i < end; i++) {
        batch.add(RawInfo(
          materialId: dataList[0][i],
          materialName: dataList[1][i],
          scaleId: int.tryParse(dataList[2][i]) ?? 0,
          categoryName: dataList[3][i],
          ingredient: dataList[4][i],
          checkCode: dataList[5][i],
        ));
      }

      batches.add(importRawListToJson(ImportRawList(
        rawInfo: batch,
        createdBy: userName,
      )));
    }

    return batches;
  }

  /// 等待发送下一批次的事件响应
  static Future<void> waitAndSendNext() async {
    final completer = Completer<void>();
    final timer = Timer(const Duration(minutes: 1), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    final subscription = eventBus.on<EventRespImportRawList>().listen((event) {
      if (!completer.isCompleted) {
        timer.cancel();
        completer.complete();
      }
    });

    await completer.future;
    subscription.cancel();
  }

  /// 导入配方 CSV
  static Future<void> importFormula(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null) return;
    File file = File(result.files.single.path!);
    if (!context.mounted) return;
    showTipInfo(localizedStrings.tipValidating, context);

    ImportFmaResult importRes = await importFormulasFromExcel(file);
    if (!context.mounted) return;
    if (!importRes.isSuccess) {
      showTipInfo(importRes.errorMessage!, context);
      return;
    }
    showTipInfo(importRes.errorMessage!, context);
    sendFmaListInBatches(importRes.importFmaInfoList);
  }

  /// 配方分批次发送后台
  static void sendFmaListInBatches(List<ImportFmaInfo> dataList) {
    const batchSize = 100;
    int totalItems = dataList.length;

    final StreamController<Timer> timerController = StreamController<Timer>();

    Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      timerController.add(t);
    });

    int currentIndex = 0;

    timerController.stream.listen((Timer timer) {
      try {
        debugPrint('Sending batch ${currentIndex + 1}...');
        if (currentIndex < totalItems) {
          int endIndex = currentIndex + batchSize;
          endIndex = endIndex < totalItems ? endIndex : totalItems;
          List<ImportFmaInfo> batch = [];

          for (int i = currentIndex; i < endIndex; i++) {
            batch.add(dataList[i]);
          }

          FmaImportFmt importFmaList = FmaImportFmt(
            fmaInfo: batch,
            createBy: mySysUser.nickName!,
          );

          String jsonStr = importFmaInfoToJson(importFmaList);
          PublicFunctions.importFmaList(jsonStr);

          currentIndex += batchSize;
        } else {
          timerController.close();
          timer.cancel();
          eventBus.fire(EventImportFmaOK(''));
        }
      } catch (e) {
        timerController.close();
        timer.cancel();
        debugPrint("sendFmaListInBatches error: $e");
      }
    });
  }

  /// 导出原料 CSV
  static Future<void> exportRaw(
      BuildContext context, List<RawDataInfo> selRawList) async {
    if (selRawList.isEmpty) {
      showTipInfo(localizedStrings.gTipNoDataSelected, context);
      return;
    }
    List<RawDataInfo> exportRawList = selRawList;

    final directory = Directory.current.path;
    String? outputFile = await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["csv"],
      fileName: 'ingredient_list.csv',
    );
    if (outputFile == null) return;

    if (!outputFile.contains(".csv")) {
      outputFile = "$outputFile.csv";
    }
    String filePath = outputFile;

    ExportResult result = await exportRawListToCsv(exportRawList, filePath);
    if (!context.mounted) return;
    if (result.isSuccess) {
      showExportDialog(filePath, context);
    } else {
      showTipInfo(result.errorMessage!, context);
    }
  }

  /// 导出配方 CSV
  static Future<void> exportFormula(
      BuildContext context, List<FormulaInfoDb> selFormulas) async {
    if (selFormulas.isEmpty) {
      showTipInfo(localizedStrings.gTipNoDataSelected, context);
      return;
    }
    List<FormulaInfoDb> exportFormulaList = selFormulas;
    final directory = Directory.current.path;
    String? outputFile = await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["csv"],
      fileName: 'formula_list.csv',
    );
    if (outputFile == null) return;

    if (!outputFile.contains(".csv")) {
      outputFile = "$outputFile.csv";
    }
    String filePath = outputFile;

    ExportResult result =
        await exportFormulaListToCsv(exportFormulaList, filePath);
    if (!context.mounted) return;
    if (result.isSuccess) {
      showExportDialog(filePath, context);
    } else {
      showTipInfo(result.errorMessage!, context);
    }
  }
}
