import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/import_fma_data.dart';
import 'package:t_max/data/req_formula_data.dart';

List<CategoryTypeList> rawTypeList = [];

List<CategoryTypeList> formulaTypeList = [];

List<RawDataInfo> rawDataList = [];

List<FormulaInfoDb> formulaDataList = [];
List<FormulaInfoDb> searchFmaList = [];

List<DarfFmaInfo> darfFmaInfoList = []; //暂存的配方称重记录和配方明细
List<DraftFmaInfo> get draftFmaInfoList => darfFmaInfoList;

RptPrintSetting rptPrintSetting = RptPrintSetting(); //打印设置

String getFmaTypeName(int fmaTypeId) {
  for (var item in formulaTypeList) {
    if (item.categoryId == fmaTypeId) {
      return item.categoryName;
    }
  }
  return '-';
}

String getRawTypeName(int rawTypeId) {
  for (var item in rawTypeList) {
    if (item.categoryId == rawTypeId) {
      return item.categoryName;
    }
  }
  return '-';
}

// 定义 EncryptedValue 枚举
enum EncryptedValue {
  confidential,
  public,
}

class ExportResult {
  bool isSuccess;
  String? errorMessage;
  ExportResult({required this.isSuccess, this.errorMessage});
}

class ImportFmaResult {
  bool isSuccess;
  String? errorMessage;
  List<ImportFmaInfo> importFmaInfoList;

  ImportFmaResult(
      {required this.isSuccess,
      this.errorMessage,
      required this.importFmaInfoList});
}

class ImportRawResult {
  bool isSuccess;
  String? errorMessage;
  List<List<String>> importRawList;

  ImportRawResult(
      {required this.isSuccess,
      this.errorMessage,
      required this.importRawList});
}

//定义常量的颜色

String noStr = 'no'; //无
String lowStr = 'low'; //低
String highStr = 'high'; //高
String okStr = 'ok'; //正常
String yesStr = 'yes'; //有

String pctStr = 'pct'; //百分比
String wgtStr = 'wgt'; //重量

String pctStrShow = '%'; //百分比
String wgtStrShow = 'g'; //重量

String showErrorStr = '± '; //误差显示格式

//重量或者百分比
enum FormulaMode {
  wgt,
  pct,
}

//重量单位
enum FormulaWgtUnit {
  kg,
  g,
  lb,
}

/// 安全协议结果解析器，避免格式不规范时 int.parse 抛出 FormatException 导致 UI 卡死
class ResultParser {
  /// 判断响应是否成功 (以 "ok," 开头或等于 "ok")
  static bool isSuccess(String? res) {
    if (res == null || res.isEmpty) return false;
    final trimmed = res.trim();
    return trimmed == 'ok' || trimmed.startsWith('ok,') || trimmed.startsWith('ok');
  }

  /// 提取 "ok,52" 或 "ok, 52" 中的 ID，失败返回 null 且不抛出异常
  static int? tryExtractId(String? res) {
    if (res == null || res.isEmpty) return null;
    final trimmed = res.trim();
    if (!trimmed.contains(',')) return null;
    try {
      final parts = trimmed.split(',');
      if (parts.length >= 2) {
        final idStr = parts[1].trim();
        return int.tryParse(idStr);
      }
    } catch (_) {}
    return null;
  }
}

