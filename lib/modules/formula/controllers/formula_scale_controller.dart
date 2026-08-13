import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/modules/formula/repositories/formula_repository.dart';

/// 配方管理与电子秤 ViewModel 控制器
class FormulaScaleController extends ChangeNotifier {
  final FormulaRepository repository = FormulaRepository();

  // 监听器流解构句柄保存
  final List<StreamSubscription> _subscriptions = [];
  Timer? _scaleTimer;

  bool _isInit = false;

  void init() {
    if (_isInit) return;
    _isInit = true;
    _subscribeEventBus();
  }

  void _subscribeEventBus() {
    _subscriptions.add(eventBus.on<EventRespGetRawTypeList>().listen((event) {
      String dataStr = event.obj;
      if (dataStr.isNotEmpty) {
        clearRawSearch();
        repository.updateRawTypes(categoryTypeListFromJson(dataStr));
      } else {
        clearRawSearch();
        repository.updateRawTypes([]);
      }
      notifyListeners();
    }));

    _subscriptions.add(eventBus.on<EventRespGetFormulaTypeList>().listen((event) {
      String dataStr = event.obj;
      if (dataStr.isNotEmpty) {
        clearFmaSearch();
        repository.updateFormulaTypes(categoryTypeListFromJson(dataStr));
      } else {
        clearFmaSearch();
        repository.updateFormulaTypes([]);
      }
      performFmaSearch();
      notifyListeners();
    }));

    _subscriptions.add(eventBus.on<EventRespGetRawDataList>().listen((event) {
      String dataStr = event.obj;
      if (dataStr.isNotEmpty && dataStr != 'null') {
        List<RawDataInfo> temp = rawDataInfoFromJson(dataStr);
        repository.updateRawData(temp);
      } else {
        repository.updateRawData([]);
      }
      notifyListeners();
    }));

    _subscriptions.add(eventBus.on<EventRespFormulaList>().listen((event) {
      String dataStr = event.obj;
      if (dataStr.isNotEmpty && dataStr != 'null') {
        clearFmaSearch();
        List<FormulaInfoDb> tempFmaDataList = formulaInfoDbFromJson(dataStr);
        repository.updateFormulas(tempFmaDataList);
        repository.updateSearchFormulas(List.from(tempFmaDataList));
      } else {
        clearFmaSearch();
        repository.updateFormulas([]);
        repository.updateSearchFormulas([]);
      }
      // 配方列表加载完成后响应式拉取草稿记录
      PublicFunctions.getDraftRecords();
      notifyListeners();
    }));

    _subscriptions.add(eventBus.on<EventRespGetDraftFmaWgtRecList>().listen((event) {
      String dataStr = event.obj;
      if (dataStr.isNotEmpty && dataStr != 'null') {
        List<DarfFmaInfo> tempDrafts = [];
        List<DarfFmaInfoListFromDb> darfFmaInfoListFromDbList =
            darfFmaInfoListFromDbFromJson(dataStr);

        for (var item in darfFmaInfoListFromDbList) {
          DarfFmaInfo tempDarfFma = DarfFmaInfo();
          for (var fmaRec in repository.formulas) {
            if (fmaRec.header?.formulaId != null &&
                fmaRec.header?.formulaId == item.header?.formulaId) {
              tempDarfFma.fmaRec = item;
              tempDarfFma.fmaInfo = fmaRec;
              break;
            }
          }
          tempDrafts.add(tempDarfFma);
        }
        repository.updateDraftFormulas(tempDrafts);
      } else {
        repository.updateDraftFormulas([]);
      }
      notifyListeners();
    }));
  }

  Timer? _fmaSearchDebounce;
  Timer? _rawSearchDebounce;
  Timer? _draftSearchDebounce;

  /// 搜索配方防抖 (300ms)
  void debounceFmaSearch(VoidCallback action) {
    _fmaSearchDebounce?.cancel();
    _fmaSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      action();
      notifyListeners();
    });
  }

  /// 搜索原料防抖 (300ms)
  void debounceRawSearch(VoidCallback action) {
    _rawSearchDebounce?.cancel();
    _rawSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      action();
      notifyListeners();
    });
  }

  /// 搜索草稿防抖 (300ms)
  void debounceDraftSearch(VoidCallback action) {
    _draftSearchDebounce?.cancel();
    _draftSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      action();
      notifyListeners();
    });
  }

  void performFmaSearch() {
    notifyListeners();
  }

  void clearFmaSearch() {
    notifyListeners();
  }

  void clearRawSearch() {
    notifyListeners();
  }

  @override
  void dispose() {
    _scaleTimer?.cancel();
    _fmaSearchDebounce?.cancel();
    _rawSearchDebounce?.cancel();
    _draftSearchDebounce?.cancel();
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
