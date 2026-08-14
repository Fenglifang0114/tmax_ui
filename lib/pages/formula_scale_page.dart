import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/get_auto_next_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/modules/formula/controllers/formula_scale_controller.dart';
import 'package:t_max/modules/formula/views/widgets/formula_scale_bottom.dart';
import 'package:t_max/modules/formula/views/widgets/formula_scale_toolbar.dart';
import 'package:t_max/widget/f_draft_tab.dart';
import 'package:t_max/widget/f_fma_tab.dart';
import 'package:t_max/widget/f_raw_tab.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/widget/page_head.dart';
import 'package:t_max/widget/scale_list.dart';

class FormulationScalePage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const FormulationScalePage(
      {super.key, required this.onNavigate, required this.lastRouteName});
  @override
  State<FormulationScalePage> createState() => FormulationScalePageState();
}

class FormulationScalePageState extends State<FormulationScalePage>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late TabController _tabController;

  int? _selectedRawIndex;

  final TextEditingController _searchFmaIdCtl = TextEditingController();
  final TextEditingController searchFmaEncryptedCtl = TextEditingController();
  final TextEditingController isFmaEncryptedCtl = TextEditingController();
  final TextEditingController searchFmaTypeCtl = TextEditingController();
  final TextEditingController rawTypeCtl = TextEditingController();
  final TextEditingController _searchRawIdCtl = TextEditingController();
  final TextEditingController _searchDarftIdCtl = TextEditingController();
  final TextEditingController fmaBarcodeCtl = TextEditingController();

  FormulaInfoDb? selectedFormula;
  Detail selectedDetail = Detail();
  RawDataInfo? selectedRaw;

  int selScaleId = -1;
  List<FormulaInfoDb> rawFormulaList = [];
  List<FormulaInfoDb> searchFmaList = [];
  List<FormulaInfoDb> selFormulas = [];
  List<RawDataInfo> searchRawList = [];
  List<RawDataInfo> selRawList = [];

  List<DarfFmaInfo> searchDarfFmaInfoList = [];
  DarfFmaInfo? selectedDarfFma;
  List<DarfFmaInfo> selDarftFmaList = [];
  Timer? _onlineTimer;

  bool sendNext = false;
  bool isExit = false;
  bool checkCode = false;

  bool autoNextStep = false;
  int stableTime = 0;
  bool autoTare = false;

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;

  dynamic _eventbus10;
  dynamic _eventbus11;
  dynamic _eventbus12;
  dynamic _eventbus13;
  dynamic _eventbus14;
  dynamic _eventbus15;
  dynamic _eventbus16;
  dynamic _eventbus17;
  dynamic _eventbus18;
  dynamic _eventbus19;
  dynamic _eventbus20;
  dynamic _eventbus21;
  dynamic _eventbus22;
  dynamic _eventbus23;
  dynamic _eventbus24;
  dynamic _eventbus25;
  dynamic _eventbus26;

  final FormulaScaleController _controller = FormulaScaleController();

  @override
  void initState() {
    super.initState();
    _controller.init();
    startTestScaleOnline();

    _tabController = TabController(length: 3, vsync: this);

    _subscribeEventBus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PublicFunctions.getAutoNext();
      PublicFunctions.getRawTypeList();
      PublicFunctions.getFormulaTypeList();
      PublicFunctions.getRawList();
      PublicFunctions.getPrintSetting();
      PublicFunctions.getFormulaList();
    });
  }

  void _subscribeEventBus() {
    _eventbus1 = eventBus.on<EventRespGetRawTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            clearRawSearch();
            rawTypeList = categoryTypeListFromJson(dataStr);
          });
        } else {
          setState(() {
            clearRawSearch();
            rawTypeList = [];
          });
        }
      }
    });

    _eventbus2 = eventBus.on<EventRespGetFormulaTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            clearFmaSearch();
            formulaTypeList = categoryTypeListFromJson(dataStr);
            performFmaSearch();
          });
        } else {
          setState(() {
            clearFmaSearch();
            formulaTypeList = [];
            performFmaSearch();
          });
        }
      }
    });

    _eventbus3 = eventBus.on<EventRespGetRawDataList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            _selectedRawIndex = -1;
            List<RawDataInfo> temp = rawDataInfoFromJson(dataStr);
            rawDataList = List.from(temp);
            searchRawList = List.from(rawDataList);
          });
        } else {
          setState(() {
            _selectedRawIndex = -1;
            rawFormulaList = [];
            rawDataList = [];
            searchRawList = [];
          });
        }
      }
    });

    _eventbus4 = eventBus.on<EventRespAddRawData>().listen((event) {
      if (mounted) {
        String res = event.obj;
        int? id = ResultParser.tryExtractId(res);
        if (id != null) {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          PublicFunctions.getRawData(id);
        }
      }
    });

    _eventbus5 = eventBus.on<EventRespDelFormula>().listen((event) {
      if (mounted) {
        String res = event.obj;
        int? id = ResultParser.tryExtractId(res);
        if (id != null) {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          formulaDataList.removeWhere((element) => element.header?.recId == id);
          clearFmaSearch();
          performFmaSearch();
          selectedFormula = null;
        }
      }
    });

    _eventbus6 = eventBus.on<EventRespFormulaList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            clearFmaSearch();
            selectedFormula = null;
            selectedDetail = Detail();
            List<FormulaInfoDb> tempFmaDataList =
                formulaInfoDbFromJson(dataStr);
            formulaDataList = List.from(tempFmaDataList);
            searchFmaList = List.from(formulaDataList);
          });
        } else {
          setState(() {
            clearFmaSearch();
            selectedFormula = null;
            selectedDetail = Detail();
            formulaDataList = [];
            searchFmaList = [];
          });
        }
        PublicFunctions.getDraftRecords();
      }
    });

    _eventbus7 = eventBus.on<EventRespAddFormula>().listen((event) {
      if (mounted) {
        String res = event.obj;
        int? id = ResultParser.tryExtractId(res);
        if (id != null) {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          PublicFunctions.getFmaData(id);
          clearFmaSearch();
        }
      }
    });

    _eventbus10 = eventBus.on<EventRespEditRawData>().listen((event) {
      if (mounted) {
        String res = event.obj;
        int? id = ResultParser.tryExtractId(res);
        if (id != null) {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          PublicFunctions.getRawData(id);
        }
      }
    });

    _eventbus11 = eventBus.on<EventRespGetDraftFmaWgtRecList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          darfFmaInfoList = [];
          selDarftFmaList = [];
          selectedDarfFma = null;
          List<DarfFmaInfoListFromDb> darfFmaInfoListFromDbList =
              darfFmaInfoListFromDbFromJson(dataStr);

          for (var item in darfFmaInfoListFromDbList) {
            DarfFmaInfo tempDarfFma = DarfFmaInfo();
            for (var fmaRec in formulaDataList) {
              if (fmaRec.header?.formulaId != null &&
                  fmaRec.header?.formulaId == item.header?.formulaId) {
                tempDarfFma.fmaRec = item;
                tempDarfFma.fmaInfo = fmaRec;
                break;
              }
            }
            darfFmaInfoList.add(tempDarfFma);
          }

          setState(() {
            searchDarfFmaInfoList = List.from(darfFmaInfoList);
            selectedDarfFma = null;
          });
        } else {
          setState(() {
            darfFmaInfoList = [];
            searchDarfFmaInfoList = [];
            selDarftFmaList = [];
            selectedDarfFma = null;
          });
        }
      }
    });

    _eventbus12 = eventBus.on<EventRespDelDraftFmaWgtRecList>().listen((event) {
      if (mounted) {
        showTipInfo(localizedStrings.fSuccessMsg, context);
        darfFmaInfoList = [];
        searchDarfFmaInfoList = [];
        selDarftFmaList = [];
        selectedDarfFma = null;
        PublicFunctions.getDraftRecords();
      }
    });

    _eventbus13 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) setState(() {});
    });

    _eventbus14 = eventBus.on<EventRespScaleOnline>().listen((event) {
      if (mounted) setState(() {});
    });

    _eventbus15 = eventBus.on<EventImportRawOK>().listen((event) {
      if (mounted) {
        rawDataList = [];
        searchRawList = [];
        PublicFunctions.getRawList();
        PublicFunctions.getRawTypeList();
      }
    });

    _eventbus16 =
        eventBus.on<EventRespCreateDraftFmaWgtRecList>().listen((event) {
      if (mounted) {
        showTipInfo(localizedStrings.fSuccessMsg, context);
        setState(() {
          darfFmaInfoList = [];
          searchDarfFmaInfoList = [];
        });

        PublicFunctions.getDraftRecords();
      }
    });

    _eventbus17 = eventBus.on<EventImportFmaOK>().listen((event) {
      if (mounted) {
        formulaDataList = [];
        PublicFunctions.getFormulaList();
        PublicFunctions.getFormulaTypeList();
      }
    });

    _eventbus18 = eventBus.on<EventRespDelManyRaw>().listen((event) {
      if (mounted) {
        rawDataList = [];
        searchRawList = [];
        selRawList = [];
        selectedRaw = null;
        PublicFunctions.getRawList();
      }
    });

    _eventbus19 = eventBus.on<EventRespDelManyFma>().listen((event) {
      if (mounted) {
        formulaDataList = [];
        searchFmaList = [];
        selFormulas = [];
        selectedFormula = null;
        PublicFunctions.getFormulaList();
        darfFmaInfoList = [];
        searchDarfFmaInfoList = [];
        selDarftFmaList = [];
        selectedDarfFma = null;
        PublicFunctions.getDraftRecords();
      }
    });

    _eventbus20 = eventBus.on<EventRespDelManyDraft>().listen((event) {
      if (mounted) {
        darfFmaInfoList = [];
        searchDarfFmaInfoList = [];
        selDarftFmaList = [];
        selectedDarfFma = null;
        PublicFunctions.getDraftRecords();
      }
    });

    _eventbus21 = eventBus.on<EventRespDelRawData>().listen((event) {
      if (mounted) {
        String res = event.obj;
        if (res.startsWith('ok,')) {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          String idStr = res.substring(3);
          int id = int.parse(idStr);
          rawDataList.removeWhere((element) => element.recId == id);
          clearRawSearch();
          performRawSearch();
          selectedRaw = null;
          showTipInfo(localizedStrings.fSuccessMsg, context);
        }
      }
    });

    _eventbus22 = eventBus.on<EventRespEditFormula>().listen((event) {
      if (mounted) {
        String res = event.obj;
        if (res.startsWith('ok,')) {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          String idStr = res.substring(3);
          int id = int.parse(idStr);
          PublicFunctions.getFmaData(id);
          selectedFormula = null;
          clearFmaSearch();
          performFmaSearch();
        }
      }
    });

    _eventbus23 = eventBus.on<EventRespGetRawData>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            _selectedRawIndex = -1;
            clearRawSearch();
            List<RawDataInfo> temp = rawDataInfoFromJson(dataStr);
            bool findRaw = false;
            for (int i = 0; i < rawDataList.length; i++) {
              if (rawDataList[i].recId == temp.first.recId) {
                rawDataList[i] = temp.first;
                findRaw = true;
                break;
              }
            }
            if (!findRaw) {
              rawDataList.add(temp.first);
            }

            searchRawList = List.from(rawDataList);
          });
        } else {
          setState(() {
            _selectedRawIndex = -1;
          });
        }
      }
    });

    _eventbus24 = eventBus.on<EventRespGetFmaData>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            _selectedRawIndex = -1;
            List<FormulaInfoDb> tempFmaData = formulaInfoDbFromJson(dataStr);
            bool findFma = false;
            for (int i = 0; i < formulaDataList.length; i++) {
              if (formulaDataList[i].header?.recId ==
                  tempFmaData.first.header?.recId) {
                formulaDataList[i] = tempFmaData.first;
                findFma = true;
                getDarftFmaInfo(tempFmaData.first.header?.recId ?? 0);
                break;
              }
            }
            if (!findFma) {
              formulaDataList.add(tempFmaData.first);
            }
            searchFmaList = List.from(formulaDataList);
          });
        } else {
          setState(() {
            _selectedRawIndex = -1;
          });
        }
      }
    });

    _eventbus25 = eventBus.on<EventRespGetAutoNext>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            GetAutoNextFormDb getInfoFormDb =
                getAutoNextFormDbFromJson(dataStr);
            autoNextStep = getInfoFormDb.autoNext;
            stableTime = getInfoFormDb.stableTime;
            autoTare = getInfoFormDb.autoTare;
            checkCode = getInfoFormDb.checkCode;
          });
        }
      }
    });

    _eventbus26 = eventBus.on<EventRespGetReportPrint>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          try {
            rptPrintSetting = rptPrintSettingFromJson(dataStr);
          } catch (e) {
            return;
          }
        }
      }
    });
  }

  void getDarftFmaInfo(int id) {
    for (var item in darfFmaInfoList) {
      if (item.fmaInfo?.header?.recId == id) {
        darfFmaInfoList = [];
        searchDarfFmaInfoList = [];
        selDarftFmaList = [];
        selectedDarfFma = null;

        PublicFunctions.getDraftRecords();
        break;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    _searchFmaIdCtl.dispose();
    searchFmaEncryptedCtl.dispose();
    searchFmaTypeCtl.dispose();
    _searchRawIdCtl.dispose();
    rawTypeCtl.dispose();
    isFmaEncryptedCtl.dispose();
    _searchDarftIdCtl.dispose();
    fmaBarcodeCtl.dispose();

    rawTypeList.clear();
    formulaTypeList.clear();
    rawDataList.clear();
    formulaDataList.clear();
    darfFmaInfoList.clear();

    searchFmaList.clear();
    searchRawList.clear();
    searchDarfFmaInfoList.clear();

    selectedDetail = Detail();
    stopTestScaleOnline();

    _eventbus1?.cancel();
    _eventbus2?.cancel();
    _eventbus3?.cancel();
    _eventbus4?.cancel();
    _eventbus5?.cancel();
    _eventbus6?.cancel();
    _eventbus7?.cancel();
    _eventbus10?.cancel();
    _eventbus11?.cancel();
    _eventbus12?.cancel();
    _eventbus13?.cancel();
    _eventbus14?.cancel();
    _eventbus15?.cancel();
    _eventbus16?.cancel();
    _eventbus17?.cancel();
    _eventbus18?.cancel();
    _eventbus19?.cancel();
    _eventbus20?.cancel();
    _eventbus21?.cancel();
    _eventbus22?.cancel();
    _eventbus23?.cancel();
    _eventbus24?.cancel();
    _eventbus25?.cancel();
    _eventbus26?.cancel();

    super.dispose();
  }

  void startTestScaleOnline() {
    _onlineTimer?.cancel();
    _onlineTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      for (var scale in myAllScalesList) {
        if (scale.tMedia == comScaleType) {
          PublicFunctions.checkSerialPort(scale.scaleId);
        }
      }
    });
  }

  void stopTestScaleOnline() {
    _onlineTimer?.cancel();
    _onlineTimer = null;
  }

  void clearFmaSearch() {
    _searchFmaIdCtl.clear();
    searchFmaTypeCtl.clear();
    searchFmaEncryptedCtl.clear();
    isFmaEncryptedCtl.clear();
  }

  void performFmaSearch() {
    final String keyword = _searchFmaIdCtl.text.trim();
    final String formulaTypeFilter = searchFmaTypeCtl.text.trim();
    final String encryptedFilter = searchFmaEncryptedCtl.text.trim();

    setState(() {
      searchFmaList = formulaDataList.where((formula) {
        final formulaId = (formula.header?.formulaId ?? '');
        final formulaName = (formula.header?.formulaName ?? '');
        return formulaId.contains(keyword) || formulaName.contains(keyword);
      }).where((element) {
        final formulaType = getFmaTypeName((element.header?.categoryId ?? 0));
        final formulaEncrypted = (element.header?.isEncrypted ?? false);

        bool typeMatch = formulaTypeFilter.isEmpty ||
            formulaType.contains(formulaTypeFilter);

        bool encryptedMatch = true;
        if (encryptedFilter.isNotEmpty) {
          bool isEncrypted = encryptedFilter == localizedStrings.fConfidential;
          encryptedMatch = formulaEncrypted == isEncrypted;
        }

        return typeMatch && encryptedMatch;
      }).toList();
    });
  }

  void clearRawSearch() {
    _searchRawIdCtl.clear();
    rawTypeCtl.clear();
  }

  void performRawSearch() {
    final String keyword = _searchRawIdCtl.text.trim();
    final String rawTypeFilter = rawTypeCtl.text.trim();

    setState(() {
      searchRawList = rawDataList.where((raw) {
        final rawId = raw.materialId!;
        final rawName = raw.materialName!;
        return rawId.contains(keyword) || rawName.contains(keyword);
      }).where((element) {
        String type = getRawTypeName(element.categoryId!);
        final rawType = type;

        bool typeMatch =
            rawTypeFilter.isEmpty || rawType.contains(rawTypeFilter);

        return typeMatch;
      }).toList();
    });
  }

  void perforDarftSearch() {
    final String keyword = _searchDarftIdCtl.text.trim();
    setState(() {
      searchDarfFmaInfoList = darfFmaInfoList.where((darf) {
        final formulaId = (darf.fmaInfo?.header?.formulaId ?? '');
        final formulaName = (darf.fmaInfo?.header?.formulaName ?? '');
        return formulaId.contains(keyword) || formulaName.contains(keyword);
      }).toList();
    });
  }

  void setAutoNext() {
    ReqAutoNext reqAutoNext = ReqAutoNext(
        autoNext: autoNextStep,
        stableTime: stableTime,
        autoTare: autoTare,
        checkCode: checkCode);

    PublicFunctions.updateAutoNext(reqAutoNextToJson(reqAutoNext));
  }

  void _deleteSelectedRaw() {
    if (selRawList.isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ShowNormalTipDialog(
          title: localizedStrings.fTipTitle,
          msg: localizedStrings.deleteRawInUseConfirm,
        );
      },
    ).then((value) {
      if (value == true) {
        List<int> recIds = [];
        for (var raw in selRawList) {
          recIds.add(raw.recId!);
        }
        recIds = recIds.toSet().toList();
        PublicFunctions.deleteAllRawData(recIds);
      }
    });
  }

  void _deleteSelectedFmas() {
    if (selFormulas.isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ShowNormalTipDialog(
          title: localizedStrings.fTipTitle,
          msg: localizedStrings.deleteFormulaWithDraftConfirm,
        );
      },
    ).then((value) {
      if (value == true) {
        List<int> recIds = [];
        for (var fma in selFormulas) {
          recIds.add(fma.header?.recId ?? 0);
        }
        recIds = recIds.toSet().toList();
        PublicFunctions.deleteAllFormulaData(recIds);
      }
    });
  }

  void _deleteDarftFma() {
    if (selDarftFmaList.isEmpty) return;
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
        List<String> recIds = [];
        for (var darf in selDarftFmaList) {
          if (darf.fmaRec?.header?.orderId != null) {
            recIds.add(darf.fmaRec!.header!.orderId!);
          }
        }
        recIds = recIds.toSet().toList();
        PublicFunctions.deleteAllDraftRecord(recIds);
      }
    });
  }

  ColorScheme get colorScheme => Theme.of(context).colorScheme;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: colorScheme.surfaceDim,
        child: Column(
          children: [
            pageHeadInfo(
                context,
                width - headWidthPadding,
                localizedStrings.menuFormula,
                localizedStrings.gTipFmaPageHelp, () {
              setState(() {
                isExit = true;
              });
              formAppSetting = false;
              Future.delayed(Duration.zero, () {
                widget.onNavigate(widget.lastRouteName);
              });
            }),
            Container(
              height: regularPadding,
              color: colorScheme.surfaceDim,
            ),
            Expanded(
              child: Row(
                children: [
                  showScaleList(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      children: [
                        showTabBar(),
                        Divider(
                          color: colorScheme.outline,
                          thickness: 1,
                          height: 1,
                        ),
                        // 搜索工具栏部分
                        if (_selectedTabIndex == 0 && !isExit)
                          FormulaSearchHeader(
                            searchFmaIdCtl: _searchFmaIdCtl,
                            searchFmaTypeCtl: searchFmaTypeCtl,
                            searchFmaEncryptedCtl: searchFmaEncryptedCtl,
                            isFmaEncryptedCtl: isFmaEncryptedCtl,
                            selFormulas: selFormulas,
                            selScaleId: selScaleId,
                            onSearch: performFmaSearch,
                            onClearSearch: () {
                              clearFmaSearch();
                              performFmaSearch();
                            },
                            onDeleteSelectedFmas: _deleteSelectedFmas,
                            stopTestScaleOnline: stopTestScaleOnline,
                            startTestScaleOnline: startTestScaleOnline,
                            onSelectFormula: (fma) {
                              setState(() {
                                selectedFormula = fma;
                              });
                            },
                          ),
                        if (_selectedTabIndex == 1 && !isExit)
                          RawSearchHeader(
                            searchRawIdCtl: _searchRawIdCtl,
                            rawTypeCtl: rawTypeCtl,
                            selRawList: selRawList,
                            onSearch: performRawSearch,
                            onClearSearch: () {
                              clearRawSearch();
                              performRawSearch();
                            },
                            onDeleteSelectedRaw: _deleteSelectedRaw,
                            onRefresh: () => setState(() {}),
                          ),
                        if (_selectedTabIndex == 2 && !isExit)
                          DraftSearchHeader(
                            searchDarftIdCtl: _searchDarftIdCtl,
                            selDarftFmaList: selDarftFmaList,
                            onSearch: perforDarftSearch,
                            onDeleteDarftFma: _deleteDarftFma,
                          ),

                        // 表格主体部分
                        Expanded(
                          flex: 8,
                          child: IndexedStack(
                            index: _selectedTabIndex,
                            children: [
                              FormulaTab(
                                searchFmaList: searchFmaList,
                                onFormulaSelected: (formula) {
                                  if (formula == null) {
                                    setState(() => selectedFormula = null);
                                    return;
                                  }
                                  setState(() {
                                    _selectedRawIndex = -1;
                                    selectedDetail = Detail();
                                    selectedFormula = formula;
                                  });
                                },
                                onMultipleSelected: (selectedFormulas) {
                                  if (selectedFormulas.isEmpty) {
                                    setState(() => selFormulas = []);
                                  } else {
                                    setState(() {
                                      selFormulas = selectedFormulas;
                                    });
                                  }
                                },
                                onDataChanged: () {},
                              ),
                              RawMaterialTab(
                                rawDataList: rawDataList,
                                searchRawList: searchRawList,
                                onRawSelected: (raw) {
                                  if (raw != null) {
                                    setState(() {
                                      rawFormulaList = [];
                                      for (var formula in formulaDataList) {
                                        for (var detail in formula.details!) {
                                          if (detail.materialId == raw.materialId) {
                                            rawFormulaList.add(formula);
                                            break;
                                          }
                                        }
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      rawFormulaList = [];
                                    });
                                  }
                                },
                                onMultipleSelected: (selectedRaws) {
                                  if (selectedRaws.isNotEmpty) {
                                    setState(() => selRawList = selectedRaws);
                                  } else {
                                    setState(() => selRawList = []);
                                  }
                                },
                                onDataChanged: () {},
                              ),
                              DraftFormulaTab(
                                searchDarfFmaInfoList: searchDarfFmaInfoList,
                                onDarfFmaSelected: (DarfFmaInfo? darfFma) {
                                  if (darfFma != null) {
                                    setState(() {
                                      selectedDarfFma = darfFma;
                                    });
                                  } else {
                                    setState(() {
                                      selectedDarfFma = null;
                                    });
                                  }
                                },
                                onMultipleSelected: (darfFmas) {
                                  if (darfFmas.isNotEmpty) {
                                    setState(() {
                                      selDarftFmaList = darfFmas;
                                    });
                                  } else {
                                    setState(() {
                                      selDarftFmaList = [];
                                    });
                                  }
                                },
                                onDataChanged: () {},
                              ),
                            ],
                          ),
                        ),

                        // 底部操作与关联面板部分
                        const SizedBox(height: 14),
                        if (_selectedTabIndex == 0)
                          FormulaBottomPanel(
                            selectedFormula: selectedFormula,
                            selectedDetail: selectedDetail,
                            selectedRawIndex: _selectedRawIndex ?? -1,
                            selScaleId: selScaleId,
                            checkCode: checkCode,
                            onToggleCheckCode: () {
                              setState(() {
                                checkCode = !checkCode;
                              });
                              setAutoNext();
                            },
                            onSelectRawDetail: (index, detail) {
                              setState(() {
                                _selectedRawIndex = index;
                                selectedDetail = detail;
                              });
                            },
                            stopTestScaleOnline: stopTestScaleOnline,
                            startTestScaleOnline: startTestScaleOnline,
                          ),
                        if (_selectedTabIndex == 1)
                          RawBottomPanel(
                            rawFormulaList: rawFormulaList,
                            selScaleId: selScaleId,
                            onSelectFormula: (formula) {
                              setState(() {
                                selectedFormula = formula;
                              });
                            },
                            stopTestScaleOnline: stopTestScaleOnline,
                            startTestScaleOnline: startTestScaleOnline,
                          ),
                        if (_selectedTabIndex == 2)
                          DraftBottomPanel(
                            selectedDarfFma: selectedDarfFma,
                            selectedDetail: selectedDetail,
                            selectedRawIndex: _selectedRawIndex ?? -1,
                            selScaleId: selScaleId,
                            onSelectRawDetail: (index, detail) {
                              setState(() {
                                _selectedRawIndex = index;
                                selectedDetail = detail;
                              });
                            },
                          ),
                        Container(
                          height: 14,
                          color: colorScheme.surface,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showScaleList() {
    return AnimatedContainer(
      color: colorScheme.surface,
      width: 234,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          const SizedBox(height: regularPadding),
          Expanded(
            child: NewAllScaleListWidget(
              listWidth: scaleListWidth,
              selScaleId: selScaleId,
              clickScale: (scale) {
                setState(() {
                  selScaleId = scale.scaleId;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget showTabBar() {
    return Container(
      height: 54,
      color: colorScheme.surface,
      child: Row(
        children: [
          const SizedBox(width: 20),
          Expanded(
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: localizedStrings.fFmaListTab),
                Tab(text: localizedStrings.fRawMaterialListTab),
                Tab(text: localizedStrings.tipTemporarySaveFormulaRecord),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
