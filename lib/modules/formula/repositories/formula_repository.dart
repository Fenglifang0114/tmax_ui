import 'package:flutter/foundation.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/req_formula_data.dart';

/// 统一配方数据仓库层 (单例 + 响应式 ValueNotifier + 向下兼容代理)
class FormulaRepository {
  static final FormulaRepository _instance = FormulaRepository._internal();
  factory FormulaRepository() => _instance;
  FormulaRepository._internal();

  // 内部响应式状态推流通道 (ValueNotifier)
  final ValueNotifier<List<CategoryTypeList>> rawTypesNotifier = ValueNotifier([]);
  final ValueNotifier<List<CategoryTypeList>> formulaTypesNotifier = ValueNotifier([]);
  final ValueNotifier<List<RawDataInfo>> rawDataNotifier = ValueNotifier([]);
  final ValueNotifier<List<FormulaInfoDb>> formulasNotifier = ValueNotifier([]);
  final ValueNotifier<List<FormulaInfoDb>> searchFormulasNotifier = ValueNotifier([]);
  final ValueNotifier<List<DarfFmaInfo>> draftFormulasNotifier = ValueNotifier([]);

  // Getter 访问器 (自动透传获取当前最新数据)
  List<CategoryTypeList> get rawTypes => rawTypesNotifier.value.isNotEmpty ? rawTypesNotifier.value : rawTypeList;
  List<CategoryTypeList> get formulaTypes => formulaTypesNotifier.value.isNotEmpty ? formulaTypesNotifier.value : formulaTypeList;
  List<RawDataInfo> get rawData => rawDataNotifier.value.isNotEmpty ? rawDataNotifier.value : rawDataList;
  List<FormulaInfoDb> get formulas => formulasNotifier.value.isNotEmpty ? formulasNotifier.value : formulaDataList;
  List<FormulaInfoDb> get searchFormulas => searchFormulasNotifier.value.isNotEmpty ? searchFormulasNotifier.value : searchFmaList;
  List<DarfFmaInfo> get draftFormulas => draftFormulasNotifier.value.isNotEmpty ? draftFormulasNotifier.value : darfFmaInfoList;

  /// 更新原料类型列表并触发响应式广播通知
  void updateRawTypes(List<CategoryTypeList> list) {
    rawTypeList = List.from(list);
    rawTypesNotifier.value = List.from(list);
  }

  /// 更新配方类型列表并触发响应式广播通知
  void updateFormulaTypes(List<CategoryTypeList> list) {
    formulaTypeList = List.from(list);
    formulaTypesNotifier.value = List.from(list);
  }

  /// 更新原料数据列表并触发响应式广播通知
  void updateRawData(List<RawDataInfo> list) {
    rawDataList = List.from(list);
    rawDataNotifier.value = List.from(list);
  }

  /// 更新配方数据列表并触发响应式广播通知
  void updateFormulas(List<FormulaInfoDb> list) {
    formulaDataList = List.from(list);
    formulasNotifier.value = List.from(list);
  }

  /// 更新搜索配方结果列表并触发响应式广播通知
  void updateSearchFormulas(List<FormulaInfoDb> list) {
    searchFmaList = List.from(list);
    searchFormulasNotifier.value = List.from(list);
  }

  /// 更新草稿记录列表并触发响应式广播通知
  void updateDraftFormulas(List<DarfFmaInfo> list) {
    darfFmaInfoList = List.from(list);
    draftFormulasNotifier.value = List.from(list);
  }
}
