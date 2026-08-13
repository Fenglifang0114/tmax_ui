import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/req_formula_data.dart';

/// 统一配方数据仓库层，向下兼容现有全局变量
class FormulaRepository {
  static final FormulaRepository _instance = FormulaRepository._internal();
  factory FormulaRepository() => _instance;
  FormulaRepository._internal();

  List<CategoryTypeList> get rawTypes => rawTypeList;
  List<CategoryTypeList> get formulaTypes => formulaTypeList;
  List<RawDataInfo> get rawData => rawDataList;
  List<FormulaInfoDb> get formulas => formulaDataList;
  List<FormulaInfoDb> get searchFormulas => searchFmaList;
  List<DarfFmaInfo> get draftFormulas => darfFmaInfoList;

  void updateRawTypes(List<CategoryTypeList> list) {
    rawTypeList = List.from(list);
  }

  void updateFormulaTypes(List<CategoryTypeList> list) {
    formulaTypeList = List.from(list);
  }

  void updateRawData(List<RawDataInfo> list) {
    rawDataList = List.from(list);
  }

  void updateFormulas(List<FormulaInfoDb> list) {
    formulaDataList = List.from(list);
  }

  void updateSearchFormulas(List<FormulaInfoDb> list) {
    searchFmaList = List.from(list);
  }

  void updateDraftFormulas(List<DarfFmaInfo> list) {
    darfFmaInfoList = List.from(list);
  }
}
