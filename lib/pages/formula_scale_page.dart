import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/f_raw_name.dart';
import 'package:t_max/data/fma_import_raw.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/get_auto_next_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/import_fma_data.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/add_fma_wgt_dialog.dart';
import 'package:t_max/dialog/add_raw_info_dialog.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/dialog/show_fma_detail_dialog.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/add_formula_page.dart';
import 'package:t_max/pages/all_fma_wgt_rec_page.dart';
import 'package:t_max/pages/start_darft_fma_pct_page.dart';
import 'package:t_max/pages/start_fma_pct_page.dart';
import 'package:t_max/pages/start_fma_secret_page.dart';
import 'package:t_max/widget/f_draft_tab.dart';
import 'package:t_max/widget/f_export.dart';
import 'package:t_max/widget/f_fma_tab.dart';
import 'package:t_max/widget/f_open_file.dart';
import 'package:t_max/widget/f_raw_tab.dart';
import 'package:t_max/widget/formula_widget.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/widget/io_output.dart';
import 'package:t_max/widget/page_head.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/search_fma_barcode.dart';
import '../data/language.dart';

// 定义 EncryptedValue 枚举
enum EncryptedValue {
  confidential,
  public,
}

// 扩展 EncryptedValue 枚举以添加翻译方法
extension EncryptedValueExtension on EncryptedValue {
  String getTranslation(BuildContext context) {
    switch (this) {
      case EncryptedValue.confidential:
        return localizedStrings.fConfidential; // 这里可以替换为翻译函数
      case EncryptedValue.public:
        return localizedStrings.fPublic; // 这里可以替换为翻译函数
    }
  }
}

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

  int? _selectedRawIndex; // 新增状态，用于记录当前被点击的原料 index

  final TextEditingController _searchFmaIdCtl = TextEditingController();
  final TextEditingController searchFmaEncryptedCtl = TextEditingController();
  final TextEditingController isFmaEncryptedCtl = TextEditingController();
  final TextEditingController searchFmaTypeCtl = TextEditingController();
  final TextEditingController rawTypeCtl = TextEditingController();
  final TextEditingController _searchRawIdCtl = TextEditingController();
  final TextEditingController _searchDarftIdCtl = TextEditingController();

  final TextEditingController fmaBarcodeCtl = TextEditingController(); //配方条码

  FormulaInfoDb? selectedFormula; //选中的配方，用于展示原料列表
  Detail selectedDetail = Detail(); //配方中选中的原料

  RawDataInfo? selectedRaw;

  int selScaleId = -1; //选择的秤ID
  List<FormulaInfoDb> rawFormulaList = []; //原料和配方的关系表
  // 存储搜索结果
  List<FormulaInfoDb> searchFmaList = [];
  List<FormulaInfoDb> selFormulas = [];
  // 存储搜索结果
  List<RawDataInfo> searchRawList = [];
  List<RawDataInfo> selRawList = [];

  List<DarfFmaInfo> searchDarfFmaInfoList = []; //暂存的配方称重记录和配方明细
  DarfFmaInfo? selectedDarfFma; //选中的配方称重记录和配方明细
  List<DarfFmaInfo> selDarftFmaList = []; //暂存的配方称重记录和配方明细
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

  @override
  void initState() {
    super.initState();
    startTestScaleOnline();

    _tabController = TabController(length: 3, vsync: this);

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
            performFmaSearch(); // 调用搜索方法
          });
        } else {
          setState(() {
            clearFmaSearch();
            formulaTypeList = [];
            performFmaSearch(); // 调用搜索方法
          });
        }
      }
    });
    _eventbus3 = eventBus.on<EventRespGetRawDataList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            _selectedRawIndex = -1; // 重置选中的原料 index
            List<RawDataInfo> temp = rawDataInfoFromJson(dataStr);
            rawDataList.addAll(temp);
            searchRawList = List.from(rawDataList);
          });
        } else {
          setState(() {
            _selectedRawIndex = -1; // 重置选中的原料 index
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
        if (res.startsWith('ok,')) {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          String idStr = res.substring(3);
          int id = int.parse(idStr);
          PublicFunctions.getRawData(id);
        }
      }
    });
    _eventbus5 = eventBus.on<EventRespDelFormula>().listen((event) {
      if (mounted) {
        //删除单条配方，返回配方的ID，用于删除配方和原料关系表
        String res = event.obj;
        //解析 "ok,52"，获取52
        if (res.startsWith('ok,')) {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          String idStr = res.substring(3);
          int id = int.parse(idStr);
          //删除配方和原料关系表中所有包含该配方ID的记录
          formulaDataList.removeWhere((element) => element.header!.recId == id);
          clearFmaSearch();
          performFmaSearch();
          selectedFormula = null;
          showTipInfo(localizedStrings.fSuccessMsg, context);
        }
      }
    });

    _eventbus6 = eventBus.on<EventRespFormulaList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            clearFmaSearch();
            selectedFormula = null; // 重置选中的配方
            selectedDetail = Detail(); // 重置选中的原料
            debugPrint(dataStr);

            List<FormulaInfoDb> tempFmaDataList =
                formulaInfoDbFromJson(dataStr);
            formulaDataList.addAll(tempFmaDataList);
            searchFmaList = List.from(formulaDataList);
          });
        } else {
          setState(() {
            clearFmaSearch();
            selectedFormula = null; // 重置选中的配方
            selectedDetail = Detail(); // 重置选中的原料
            formulaDataList = [];
            searchFmaList = [];
          });
        }
      }
    });

    _eventbus7 = eventBus.on<EventRespAddFormula>().listen((event) {
      if (mounted) {
        String res = event.obj;
        if (res.startsWith('ok,')) {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          String idStr = res.substring(3);
          int id = int.parse(idStr);
          PublicFunctions.getFmaData(id);
          clearFmaSearch();
        }
      }
    });

    _eventbus10 = eventBus.on<EventRespEditRawData>().listen((event) {
      if (mounted) {
        String res = event.obj;
        if (res.startsWith('ok,')) {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          String idStr = res.substring(3);
          int id = int.parse(idStr);
          PublicFunctions.getRawData(id);
        }
      }
    });

    _eventbus11 = eventBus.on<EventRespGetDraftFmaWgtRecList>().listen((event) {
      if (mounted) {
        debugPrint('getDraftFmaWgtRecList');
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          darfFmaInfoList = [];
          selDarftFmaList = [];
          selectedDarfFma = null;
          List<DarfFmaInfoListFromDb> darfFmaInfoListFromDbList =
              darfFmaInfoListFromDbFromJson(dataStr);

          for (var item in darfFmaInfoListFromDbList) {
            //在fmaRecFromDbList中查找对应的配方
            DarfFmaInfo tempDarfFma = DarfFmaInfo();
            for (var fmaRec in formulaDataList) {
              if (fmaRec.header!.formulaId == item.header!.formulaId) {
                tempDarfFma.fmaRec = item;
                tempDarfFma.fmaInfo = fmaRec;
                break;
              }
            }
            darfFmaInfoList.add(tempDarfFma);
          }

          setState(() {
            searchDarfFmaInfoList = List.from(darfFmaInfoList);

            selectedDarfFma = null; // 重置选中的配方称重记录和配方明细
          });
        } else {
          setState(() {
            darfFmaInfoList = []; //暂存的配方记录
            searchDarfFmaInfoList = []; //暂存的配方记录
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
      if (mounted) {
        setState(() {});
      }
    });
    _eventbus14 = eventBus.on<EventRespScaleOnline>().listen((event) {
      if (mounted) {
        setState(() {});
      }
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
        //解析 "ok,52"，获取52
        if (res.startsWith('ok,')) {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          String idStr = res.substring(3);
          int id = int.parse(idStr);
          //删除配方和原料关系表中所有包含该配方ID的记录
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
            _selectedRawIndex = -1; // 重置选中的原料 index
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
            _selectedRawIndex = -1; // 重置选中的原料 index
          });
        }
      }
    });
    _eventbus24 = eventBus.on<EventRespGetFmaData>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            _selectedRawIndex = -1; // 重置选中的原料 index
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
            _selectedRawIndex = -1; // 重置选中的原料 index
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

    //初始化完成再做一次数据加载

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 在这里调用数据加载的方法
      PublicFunctions.getAutoNext();
      PublicFunctions.getRawTypeList();
      PublicFunctions.getFormulaTypeList();
      PublicFunctions.getRawList();
      PublicFunctions.getPrintSetting();

      Future.delayed(const Duration(milliseconds: 500), () {
        PublicFunctions.getFormulaList();
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        // PublicFunctions.getFormulaRecList();
      });
      //等1秒再获取配方称重记录
      Future.delayed(const Duration(milliseconds: 2000), () {
        PublicFunctions.getDraftRecords();
      });
    });
  }

  void getDarftFmaInfo(int id) {
    for (var item in darfFmaInfoList) {
      if (item.fmaInfo!.header!.recId == id) {
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
    super.dispose();

    _tabController.dispose();
    _searchFmaIdCtl.dispose();
    searchFmaEncryptedCtl.dispose();
    searchFmaTypeCtl.dispose();
    _searchRawIdCtl.dispose();
    rawTypeCtl.dispose();
    isFmaEncryptedCtl.dispose();

    rawTypeList.clear();
    formulaTypeList.clear();
    rawDataList.clear();
    formulaDataList.clear();
    darfFmaInfoList.clear();

    searchFmaList.clear();
    searchRawList.clear();
    searchDarfFmaInfoList.clear();

    selectedDetail = Detail(); // 重置选中的原料
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
  }

  void startTestScaleOnline() {
    _onlineTimer?.cancel();

    _onlineTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      for (var scale in myAllScalesList) {
        if (scale.tMedia == comScaleType) {
          PublicFunctions.checkSerialPort(scale.scaleId);
        }
      }
    });
  }

  void stopTestScaleOnline() {
    // 停止发送在线状态
    _onlineTimer?.cancel();
    _onlineTimer = null;
  }

  _updateRawDataSource() {
    //更新原料数据源
    // setState(() {
    //   rawDataList.clear();
    //   searchRawList = [];
    // });
    Future.delayed(const Duration(milliseconds: 100), () {
      // PublicFunctions.getRawList();
    });
  }

  _updateFmaDataSource() {
    //更新FMA数据源
    // setState(() {
    //   formulaDataList.clear();
    //   searchFmaList = [];
    // });
    Future.delayed(const Duration(milliseconds: 100), () {
      // PublicFunctions.getFormulaList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
            color: colorScheme.surfaceDim, //对接时修改颜色值

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
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          children: [
                            showTabBar(),
                            Divider(
                              color: colorScheme.outline,
                              thickness: 1,
                              height: 1,
                            ),
                            //////////////////////////搜索部分
                            if (_selectedTabIndex == 0 && !isExit)
                              showFormulaSearch(),
                            if (_selectedTabIndex == 1 && !isExit)
                              showRawSearch(),
                            if (_selectedTabIndex == 2 && !isExit)
                              showDarftFmaSearch(),

                            //////////////////////////表格部分
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
                                    onDataChanged: _updateFmaDataSource,
                                  ),
                                  RawMaterialTab(
                                    rawDataList: rawDataList,
                                    searchRawList: searchRawList,
                                    onRawSelected: (raw) {
                                      if (raw != null) {
                                        setState(() {
                                          rawFormulaList = [];
                                          for (var formula in formulaDataList) {
                                            for (var detail
                                                in formula.details!) {
                                              if (detail.materialId ==
                                                  raw.materialId) {
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
                                        setState(
                                            () => selRawList = selectedRaws);
                                      } else {
                                        setState(() => selRawList = []);
                                      }
                                    },
                                    onDataChanged: _updateRawDataSource,
                                  ),
                                  DraftFormulaTab(
                                    searchDarfFmaInfoList:
                                        searchDarfFmaInfoList,
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
                                      // 处理多选
                                    },
                                    onDataChanged: _updateFmaDataSource,
                                  ),
                                ],
                              ),
                            ),

                            //////////////////////////底部
                            SizedBox(height: 14),
                            if (_selectedTabIndex == 0) showFormulaBottom(),
                            if (_selectedTabIndex == 1) showRawBottom(),
                            if (_selectedTabIndex == 2) showDarftFmaBottom(),
                            Container(
                              height: 14,
                              color: colorScheme.surface,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )

            // ),
            ));
  }

  void clearFmaSearch() {
    _searchFmaIdCtl.clear();
    searchFmaTypeCtl.clear();
    searchFmaEncryptedCtl.clear();
    isFmaEncryptedCtl.clear();
  }

  // 搜索方法
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

        // 处理配方类别筛选
        bool typeMatch = formulaTypeFilter.isEmpty ||
            formulaType.contains(formulaTypeFilter);

        // 处理保密状态筛选
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

  // 搜索方法
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

        // 处理配方类别筛选
        bool typeMatch =
            rawTypeFilter.isEmpty || rawType.contains(rawTypeFilter);

        return typeMatch;
      }).toList();
    });
  }

  //原料顺序部分
  showDarftRawOrder() {
    return Expanded(
      flex: 6,
      child: Container(
        color: colorScheme.surface,
        child: Column(children: [
          ShowRawTitleWidget(
            text: localizedStrings.fIngredientOrder,
          ),
          showDarftRawOrderDetail(),
        ]),
      ),
    );
  }

  //原料顺序部分
  showRawOrder() {
    return Expanded(
      flex: 6,
      child: Container(
        color: colorScheme.surface,
        child: Column(children: [
          ShowRawTitleWidget(
            text: localizedStrings.fIngredientOrder,
          ),
          showRawOrderDetail(),
        ]),
      ),
    );
  }

  Widget showDarftRawWgtAndUnit(int index, Color? textColor) {
    // ... existing code ...
    final formulaHeader = selectedDarfFma?.fmaInfo!.header;
    final formulaDetail = selectedDarfFma?.fmaInfo!.details?[index];

    if (formulaHeader != null && formulaDetail != null) {
      final weight = formulaDetail.materialWeight;
      final unit = formulaHeader.formulaMode == "pct"
          ? pctStrShow
          : formulaHeader.formulaUnit;
      final displayText = '$weight $unit';

      return Text(
        displayText,
        style: TextStyle(
          color: textColor,
        ),
      );
    } else {
      // 处理数据为空的情况
      return Text(
        '',
        style: TextStyle(
          color: textColor,
        ),
      );
    }
  }

  Widget showRawWgtAndUnit(int index, Color? textColor) {
    // ... existing code ...
    final formulaHeader = selectedFormula?.header;
    final formulaDetail = selectedFormula?.details?[index];

    if (formulaHeader != null && formulaDetail != null) {
      final weight = formulaDetail.materialWeight;
      final unit = formulaHeader.formulaMode == "pct"
          ? pctStrShow
          : formulaHeader.formulaUnit;
      final displayText = '$weight $unit';

      return Text(
        displayText,
        style: TextStyle(
          color: textColor,
        ),
      );
    } else {
      // 处理数据为空的情况
      return Text(
        '',
        style: TextStyle(
          color: textColor,
        ),
      );
    }
  }

  showDarftRawOrderDetail() {
    return Expanded(
      child: ListView.separated(
        // 修改 itemCount
        itemCount: selectedDarfFma?.fmaInfo?.details?.length ?? 0,
        separatorBuilder: (context, index) => SizedBox(height: 10),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                _selectedRawIndex = index; // 更新选中的 index
                selectedDetail = (selectedDarfFma?.fmaInfo?.details?[index] ?? Detail());
              });
              // 这里添加点击事件的处理逻辑
              // print('点击了第 $index 项');
            },
            child: () {
              bool isSelected = _selectedRawIndex == index;
              Color backgroundColor = isSelected
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerLow;
              Color innerContainerColor =
                  isSelected ? colorScheme.primary : colorScheme.surface;
              Color textColor = isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant;
              Color numberTextColor = isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant;

              return Container(
                height: 32,
                color: backgroundColor,
                child: Row(children: [
                  SizedBox(
                    width: 2,
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    color: innerContainerColor,
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: textTheme.bodySmall!.copyWith(
                          color: numberTextColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      // 修改显示内容

                      getRawName(selectedDarfFma
                              ?.fmaInfo!.details![index].materialId! ??
                          ""),

                      style: textTheme.bodySmall!.copyWith(
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 修改显示内容
                  selectedDarfFma?.fmaInfo?.header?.isEncrypted == true
                      ? SizedBox()
                      : showDarftRawWgtAndUnit(index, textColor),
                  SizedBox(
                    width: 10,
                  ),
                ]),
              );
            }(),
          );
        },
      ),
    );
  }

  showRawOrderDetail() {
    return Expanded(
      child: ListView.separated(
        // 修改 itemCount
        itemCount: selectedFormula?.details?.length ?? 0,
        separatorBuilder: (context, index) => SizedBox(height: 10),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                _selectedRawIndex = index; // 更新选中的 index
                selectedDetail = (selectedFormula?.details?[index] ?? Detail());
              });
              // 这里添加点击事件的处理逻辑
              // print('点击了第 $index 项');
            },
            child: () {
              bool isSelected = _selectedRawIndex == index;
              Color backgroundColor = isSelected
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerLow;
              Color innerContainerColor =
                  isSelected ? colorScheme.primary : colorScheme.surface;
              Color textColor = isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant;
              Color numberTextColor = isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant;

              return Container(
                height: 32,
                color: backgroundColor,
                child: Row(children: [
                  SizedBox(
                    width: 2,
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    color: innerContainerColor,
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: textTheme.bodySmall!.copyWith(
                          color: numberTextColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      // 修改显示内容
                      getRawName(
                          selectedFormula?.details![index].materialId! ?? ""),

                      style: textTheme.bodySmall!.copyWith(
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 修改显示内容
                  selectedFormula?.header?.isEncrypted == true
                      ? SizedBox()
                      : showRawWgtAndUnit(index, textColor),
                  SizedBox(
                    width: 10,
                  ),
                ]),
              );
            }(),
          );
        },
      ),
    );
  }

  bool checkScaleOnline(FormulaInfoDb? selectedFormula) {
    if (selectedFormula == null) {
      return false;
    }
    if (selScaleId == -1 &&
        ((selectedFormula.header?.isEncrypted ?? false) ||
            (selectedFormula.header?.needContainer ?? false))) {
      showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
      return false;
    }

    if ((selectedFormula.header?.isEncrypted ?? false) ||
        (selectedFormula.header?.needContainer ?? false)) {
      if (!checkOnline(selScaleId)) {
        return false;
      }
    }

    if ((selectedFormula.header?.isEncrypted ?? false)) {
      return true;
    }

    List<Detail>? details = selectedFormula.details;

    for (var detail in details!) {
      int scaleId = findScaleIdFromRaw(detail.materialId!);

      if (scaleId == 0 && selScaleId == -1) {
        showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
        return false;
      }
      if (scaleId == 0) {
        scaleId = selScaleId;
      }
      if (!checkOnline(scaleId)) {
        return false;
      }
    }
    return true;
  }

  bool checkOnline(int scaleId) {
    for (var scale in myAllScalesList) {
      if (scale.scaleId == scaleId) {
        if (!scale.isOnline) {
          showTipInfo(
              "${scale.scaleName} ${localizedStrings.gTipOffline}", context);
          return false;
        } else {
          return true;
        }
      }
    }
    return false;
  }

  bool checkDarftScaleOnline(DarfFmaInfo? darftFma) {
    if (darftFma == null) {
      return false;
    }
    if (selScaleId == -1 &&
        ((darftFma.fmaInfo?.header?.isEncrypted ?? false) ||
            (darftFma.fmaInfo?.header?.needContainer ?? false))) {
      showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
      return false;
    }

    if ((darftFma.fmaInfo?.header?.isEncrypted ?? false) ||
        (darftFma.fmaInfo?.header?.needContainer ?? false)) {
      if (!checkOnline(selScaleId)) {
        return false;
      }
    }

    if ((darftFma.fmaInfo?.header?.isEncrypted ?? false)) {
      return true;
    }

    List<Detail>? details = darftFma.fmaInfo!.details;

    for (var detail in details!) {
      int scaleId = findScaleIdFromRaw(detail.materialId!);

      if (scaleId == 0 && selScaleId == -1) {
        showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
        return false;
      }

      if (scaleId == 0) {
        scaleId = selScaleId;
      }

      if (!checkOnline(scaleId)) {
        return false;
      }
    }
    return true;
  }

  int findScaleIdFromRaw(String materialId) {
    for (var raw in rawDataList) {
      if (raw.materialId == materialId) {
        return raw.scaleId ?? 0;
      }
    }

    return 0;
  }

  void setAutoNext() {
    ReqAutoNext reqAutoNext = ReqAutoNext(
        autoNext: autoNextStep,
        stableTime: stableTime,
        autoTare: autoTare,
        checkCode: checkCode);

    PublicFunctions.updateAutoNext(reqAutoNextToJson(reqAutoNext));
  }

  showFormulaBottom() {
    return Expanded(
      flex: 4,
      child: Container(
        color: colorScheme.surface,
        child: Column(children: [
          Container(
              height: 48,
              color: colorScheme.surface,
              child: Row(children: [
                const SizedBox(
                  width: regularPadding,
                ),
                Text(
                  localizedStrings.fFmaNameLabel + "：",
                  style: getTextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // 显示配方名称内容
                Expanded(
                  flex: 3,
                  child: Text(
                    selectedFormula?.header?.formulaName ?? "",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // 显示配方编号标签
                Text(
                  localizedStrings.fFmaIdLabel + ": ",
                  style: getTextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // 显示配方编号内容
                Expanded(
                  flex: 1,
                  child: Text(
                    selectedFormula?.header?.formulaId ?? "",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Text(
                  localizedStrings.fIngredientCountLabel + ": ",
                  style: getTextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // 显示配方编号内容
                Expanded(
                  flex: 1,
                  child: Text(
                    selectedFormula?.header?.materialCount.toString() ?? "",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                selectedFormula?.header?.formulaMode != "pct"
                    ? Text(
                        "  ${localizedStrings.fTotalWeightLabel}: ",
                        style: getTextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )
                    : SizedBox(),
                // 显示配方编号内容
                Expanded(
                  flex: 1,
                  child: Text(
                    selectedFormula?.header?.formulaMode == "pct"
                        ? ""
                        : selectedFormula?.header?.totalWeight != null &&
                                selectedFormula?.header?.formulaUnit != null
                            ? " ${selectedFormula!.header!.totalWeight} ${selectedFormula!.header!.formulaUnit}"
                            : " ",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (mySysUser.roleId == superAdminRoleId ||
                    mySysUser.roleId == adminRoleId)
                  Container(
                      width: 44,
                      height: 36,
                      padding: const EdgeInsets.only(left: smallPadding),
                      child: Tooltip(
                        message: checkCode
                            ? localizedStrings.disableIngredientVerification
                            : localizedStrings.enableIngredientVerification,
                        child: IconButton(
                          iconSize: 24,
                          color: colorScheme.onPrimary,
                          hoverColor: colorScheme.primary.withAlpha(20),
                          style: IconButton.styleFrom(
                            backgroundColor: checkCode
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              // 设置为矩形形状
                              borderRadius: BorderRadius.zero, // 没有圆角，即正方形
                            ),
                            fixedSize: const Size(36, 36), // 设置固定大小
                          ),
                          onPressed: () {
                            setState(() {
                              checkCode = !checkCode;
                            });
                            setAutoNext();
                          },
                          icon: getSvgIcon(
                              checkCodeSvgIcon(),
                              24,
                              24,
                              checkCode
                                  ? colorScheme.onPrimary
                                  : colorScheme.outline),
                        ),
                      )),

                const SizedBox(
                  width: regularPadding,
                ),
                SizedBox(
                  width: 80,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.onPrimary,
                      backgroundColor: colorScheme.onTertiaryFixedVariant,
                      fixedSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                      ),
                    ),
                    onPressed: (selectedFormula == null)
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SetOutputPortDialog();
                              },
                            ).then((fmaValue) {
                              if (fmaValue != null) {}
                            });
                          },
                    child: Text(
                      "I/O",
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                const SizedBox(
                  width: regularPadding,
                ),

                SizedBox(
                  width: 150,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.onPrimary,
                      backgroundColor: colorScheme.onTertiaryFixedVariant,
                      fixedSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                      ),
                    ),
                    onPressed: (selectedFormula == null)
                        ? null
                        : () {
                            bool isOk = checkScaleOnline(selectedFormula);
                            if (!isOk) {
                              return;
                            }
                            stopTestScaleOnline();
                            startWeighting();
                          },
                    child: Text(
                      localizedStrings.fStartWeighingBtn,
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
              ])),
          Divider(
            color: colorScheme.outline,
            thickness: 1,
            height: 1,
          ),
          Expanded(
              child: Row(
            children: [
              SizedBox(
                width: 17,
              ),
              showRawOrder(),
              SizedBox(
                width: 16,
              ),
              Expanded(
                flex: 11,
                child: Column(children: [
                  ShowRawTitleWidget(
                    text: localizedStrings.fIngredientRemark,
                  ),
                  RawRemarkTextWidget(
                    text: selectedDetail == Detail()
                        ? ""
                        : selectedDetail.materialId == null
                            ? ""
                            : getRawRemark(selectedDetail.materialId!),
                  )
                ]),
              ),
              SizedBox(
                width: 26,
              ),
              VerticalDivider(
                color: colorScheme.outline,
                width: 1,
              ),
              SizedBox(
                width: 26,
              ),
              Expanded(
                flex: 9,
                child: Column(children: [
                  ShowRawTitleWidget(
                    text: localizedStrings.fFmaRemark,
                  ),
                  RawRemarkTextWidget(
                    text: selectedFormula?.header?.remark ?? "",
                  )
                ]),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ))
        ]),
      ),
    );
  }

  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;

  TextStyle getTextStyle({Color? color}) {
    //返回一个文本样式
    color ??= colorScheme.onSurface;
    return textTheme.bodySmall!.apply(
      color: color,
    );
  }

  TextStyle getTitleTextStyle({Color? color}) {
    //返回一个文本样式
    color ??= colorScheme.onSurface;
    return textTheme.bodyMedium!.apply(
      color: color,
    );
  }

  showRenderCellText(String context, {Color? color}) {
    color ??= colorScheme.onSurfaceVariant;
    return Text(context,
        style: getTextStyle(color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis);
  }

  showRenderTitleText(String title) {
    return Text(title,
        style: getTextStyle(color: colorScheme.onSurface),
        maxLines: 1,
        overflow: TextOverflow.ellipsis);
  }

  showDarftFmaBottom() {
    return Expanded(
      flex: 4,
      child: Container(
        color: colorScheme.surface,
        child: Column(children: [
          Container(
              height: 48,
              color: colorScheme.surface,
              child: Row(children: [
                const SizedBox(
                  width: 20,
                ),
                Text(
                  localizedStrings.fFmaNameLabel + "：",
                  style: getTextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // 显示配方名称内容
                Expanded(
                  flex: 3,
                  child: Text(
                    selectedDarfFma?.fmaInfo!.header!.formulaName ?? "",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // 显示配方编号标签
                Text(
                  localizedStrings.fFmaIdLabel + ": ",
                  style: getTextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // 显示配方编号内容
                Expanded(
                  flex: 1,
                  child: Text(
                    selectedDarfFma?.fmaInfo!.header!.formulaId ?? "",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Text(
                  localizedStrings.fIngredientCountLabel + ": ",
                  style: getTextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // 显示配方编号内容
                Expanded(
                  flex: 1,
                  child: Text(
                    selectedDarfFma?.fmaInfo!.header!.materialCount
                            .toString() ??
                        "",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                selectedDarfFma?.fmaInfo!.header!.formulaMode != "pct"
                    ? Text(
                        "  ${localizedStrings.fTotalWeightLabel}: ",
                        style: getTextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )
                    : SizedBox(),
                // 显示配方编号内容
                Expanded(
                  flex: 1,
                  child: Text(
                    selectedDarfFma?.fmaInfo!.header!.formulaMode == "pct"
                        ? ""
                        : selectedDarfFma?.fmaInfo!.header!.totalWeight !=
                                    null &&
                                selectedDarfFma?.fmaInfo!.header!.formulaUnit !=
                                    null
                            ? " ${(selectedDarfFma?.fmaInfo ?? FormulaInfoDb()).header!.totalWeight} ${(selectedDarfFma?.fmaInfo ?? FormulaInfoDb()).header!.formulaUnit}"
                            : " ",
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: 200,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.onPrimary,
                      backgroundColor: colorScheme.onTertiaryFixedVariant,
                      fixedSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // 可以根据需要调整圆角
                      ),
                    ),
                    onPressed: (selectedDarfFma == null)
                        ? null
                        : () {
                            bool isOk = checkDarftScaleOnline(selectedDarfFma);
                            if (!isOk) {
                              return;
                            }
                            startDarftWeighting();
                          },
                    child: Text(
                      localizedStrings.btnContinueWeighing,
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
              ])),
          Divider(
            color: colorScheme.outline,
            thickness: 1,
            height: 1,
          ),
          Expanded(
              child: Row(
            children: [
              SizedBox(
                width: 17,
              ),
              showDarftRawOrder(),
              SizedBox(
                width: 16,
              ),
              Expanded(
                flex: 11,
                child: Column(children: [
                  ShowRawTitleWidget(
                    text: localizedStrings.fIngredientRemark,
                  ),
                  RawRemarkTextWidget(
                    text: selectedDetail == Detail()
                        ? ""
                        : selectedDetail.remark == null
                            ? ""
                            : selectedDetail.remark!,
                  )
                ]),
              ),
              SizedBox(
                width: 26,
              ),
              VerticalDivider(
                color: colorScheme.outline,
                width: 1,
              ),
              SizedBox(
                width: 26,
              ),
              Expanded(
                flex: 9,
                child: Column(children: [
                  ShowRawTitleWidget(
                    text: localizedStrings.fFmaRemark,
                  ),
                  RawRemarkTextWidget(
                    text: selectedDarfFma?.fmaInfo!.header!.remark ?? "",
                  )
                ]),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ))
        ]),
      ),
    );
  }

  void startWeighting() {
    //检查配方是保密的，还是公开的
    if (selectedFormula == null) {
      return;
    }
    if (selectedFormula?.header?.isEncrypted == false) {
      //检查配方是重量模式还是百分比模式
      if (selectedFormula?.header?.formulaMode == "pct") {
        showDialog(
          context: context,
          builder: (context) {
            return AddFormulaWgtDialog();
          },
        ).then((value) {
          if (value != null && value is Map<String, String>) {
            String formulaWgt = value['formulaWgt'] ?? '';
            String formulaUnit = value['formulaUnit'] ?? '';

            // 先判断这个总重是个数
            if (double.tryParse(formulaWgt) == null) {
              return;
            } else {
              double totalWgt = double.parse(formulaWgt);
              String fmaUnit = formulaUnit;
              if (!mounted) {
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormulaPctWeighingPage(
                    selectFormula: selectedFormula!,
                    selScaleId: selScaleId,
                    totalFmaWgt: totalWgt,
                    fmaUnit: fmaUnit,
                    fromDarft: false,
                  ),
                ),
              ).then((value) {
                startTestScaleOnline();
              });
            }
          }
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormulaPctWeighingPage(
              selectFormula: selectedFormula!,
              selScaleId: selScaleId,
              totalFmaWgt: (selectedFormula?.header?.totalWeight ?? 0.0),
              fmaUnit: (selectedFormula?.header?.formulaUnit ?? ''),
              fromDarft: false,
            ),
          ),
        ).then((value) {
          startTestScaleOnline();
        });
      }
    } else {
      //检查配方是重量模式还是百分比模式
      if (selectedFormula?.header?.formulaMode == "pct") {
        showDialog(
          context: context,
          builder: (context) {
            return AddFormulaWgtDialog();
          },
        ).then((value) {
          if (value != null && value is Map<String, String>) {
            String formulaWgt = value['formulaWgt'] ?? '';
            String formulaUnit = value['formulaUnit'] ?? '';

            // 先判断这个总重是个数
            if (double.tryParse(formulaWgt) == null) {
              return;
            } else {
              double totalWgt = double.parse(formulaWgt);
              String fmaUnit = formulaUnit;
              if (!mounted) {
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormulaSecretWeighingPage(
                    selectFormula: selectedFormula!,
                    selScaleId: selScaleId,
                    totalFmaWgt: totalWgt,
                    fmaUnit: fmaUnit,
                    fromDraft: false,
                    selectDarftInfo: null // 这里传入null，因为不是草稿配方称重，所以不需要草稿信息
                    ,
                  ),
                ),
              ).then((value) {
                startTestScaleOnline();
              });
            }
          }
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormulaSecretWeighingPage(
                selectFormula: selectedFormula!,
                selScaleId: selScaleId,
                totalFmaWgt: (selectedFormula?.header?.totalWeight ?? 0.0),
                fmaUnit: (selectedFormula?.header?.formulaUnit ?? ''),
                fromDraft: false,
                selectDarftInfo: null // 这里传入null，因为不是草稿配方称重，所以不需要草稿信息
                ),
          ),
        ).then((value) {
          startTestScaleOnline();
        });
      }
    }
  }

  void startDarftWeighting() {
    //检查配方是保密的，还是公开的
    if (selectedDarfFma == null) {
      return;
    }
    if (selectedDarfFma?.fmaInfo?.header?.isEncrypted == false) {
      //检查配方是重量模式还是百分比模式
      if (selectedDarfFma?.fmaInfo?.header?.formulaMode == "pct") {
        showDialog(
          context: context,
          builder: (context) {
            return AddFormulaWgtDialog();
          },
        ).then((value) {
          if (value != null && value is Map<String, String>) {
            String formulaWgt = value['formulaWgt'] ?? '';
            String formulaUnit = value['formulaUnit'] ?? '';

            // 先判断这个总重是个数
            if (double.tryParse(formulaWgt) == null) {
              return;
            } else {
              double totalWgt = double.parse(formulaWgt);
              String fmaUnit = formulaUnit;
              if (!mounted) {
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DarftFmaPctWgtPage(
                    selectFormula: (selectedDarfFma?.fmaInfo ?? FormulaInfoDb()),
                    selScaleId: selScaleId,
                    totalFmaWgt: totalWgt,
                    fmaUnit: fmaUnit,
                    fromDarft: false,
                    selectDarftInfo: (selectedDarfFma?.fmaRec ?? DarfFmaInfoListFromDb()),
                  ),
                ),
              );
            }
          }
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DarftFmaPctWgtPage(
              selectFormula: (selectedDarfFma?.fmaInfo ?? FormulaInfoDb()),
              selScaleId: selScaleId,
              totalFmaWgt: (selectedDarfFma?.fmaInfo ?? FormulaInfoDb()).header!.totalWeight!,
              fmaUnit: (selectedDarfFma?.fmaInfo ?? FormulaInfoDb()).header!.formulaUnit!,
              fromDarft: false,
              selectDarftInfo: (selectedDarfFma?.fmaRec ?? DarfFmaInfoListFromDb()),
            ),
          ),
        );
      }
    } else {
      //检查配方是重量模式还是百分比模式
      if (selectedDarfFma?.fmaInfo?.header?.formulaMode == "pct") {
        showDialog(
          context: context,
          builder: (context) {
            return AddFormulaWgtDialog();
          },
        ).then((value) {
          if (value != null && value is Map<String, String>) {
            String formulaWgt = value['formulaWgt'] ?? '';
            String formulaUnit = value['formulaUnit'] ?? '';

            // 先判断这个总重是个数
            if (double.tryParse(formulaWgt) == null) {
              return;
            } else {
              double totalWgt = double.parse(formulaWgt);
              String fmaUnit = formulaUnit;
              if (!mounted) {
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormulaSecretWeighingPage(
                    selectFormula: (selectedDarfFma?.fmaInfo ?? FormulaInfoDb()),
                    selScaleId: selScaleId,
                    totalFmaWgt: totalWgt,
                    fmaUnit: fmaUnit,
                    fromDraft: true,
                    selectDarftInfo: (selectedDarfFma?.fmaRec ?? DarfFmaInfoListFromDb()),
                  ),
                ),
              );
            }
          }
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormulaSecretWeighingPage(
              selectFormula: (selectedDarfFma?.fmaInfo ?? FormulaInfoDb()),
              selScaleId: selScaleId,
              totalFmaWgt: (selectedDarfFma?.fmaInfo ?? FormulaInfoDb()).header!.totalWeight!,
              fmaUnit: (selectedDarfFma?.fmaInfo ?? FormulaInfoDb()).header!.formulaUnit!,
              fromDraft: true,
              selectDarftInfo: (selectedDarfFma?.fmaRec ?? DarfFmaInfoListFromDb()),
            ),
          ),
        );
      }
    }
  }

//原料列表底部
  showRawBottom() {
    return Expanded(
      flex: 3,
      child: Container(
        color: colorScheme.surface,
        child: Column(children: [
          Expanded(
              child: Row(
            children: [
              SizedBox(
                width: 17,
              ),
              Expanded(
                flex: 11,
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 3,
                      height: 14,
                      color: colorScheme.onSurface,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: ShowRawTitleWidget(
                        text: localizedStrings.fInvolvedFmas,
                      ),
                    )
                  ]),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 30,
                          runSpacing: 10,
                          children: [
                            // 遍历 rawFormulaList 展示配方名字并添加点击功能
                            for (var formula in rawFormulaList)
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ShowFormulaDetailDialog(
                                          selectFormula: formula,
                                          selectScaleId: selScaleId,
                                        );
                                      }).then((value) {
                                    if (value) {
                                      selectedFormula = formula;
                                      //判断秤是否在线
                                      bool isOk =
                                          checkScaleOnline(selectedFormula);
                                      if (!isOk) {
                                        return;
                                      }
                                      stopTestScaleOnline();
                                      startWeighting();
                                    }
                                  });
                                },
                                child: IntrinsicWidth(
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    height: 40,
                                    constraints: BoxConstraints(
                                      maxWidth: 300,
                                      minWidth: 100,
                                    ),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    child: Center(
                                      child: Text(
                                        formula.header?.formulaName ?? "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                ]),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ))
        ]),
      ),
    );
  }

  showScaleList() {
    return AnimatedContainer(
      color: colorScheme.surface,
      width: 234,
      duration: Duration(milliseconds: 300),
      child: Column(
        children: [
          SizedBox(height: regularPadding),
          Expanded(
            child: NewAllScaleListWidget(
              listWidth: scaleListWidth, // 列表宽度
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

  showTabBar() {
    return Container(
      height: 54,
      color: colorScheme.surface,
      child: Row(
        children: [
          SizedBox(
            width: 20,
          ),
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
              // 自定义 indicator 样式，添加分隔线
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

  void showAddRawInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return AddRawDialog();
      },
    ).then((value) {
      setState(() {});
    });
  }

  showRawSearch() {
    return Container(
      height: 70,
      color: colorScheme.surface,
      child: Row(children: [
        SizedBox(
          width: 20,
        ),
        SizedBox(
            width: 260,
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                style: textTheme.bodySmall!.copyWith(
                  color: colorScheme.onSurface,
                ),
                controller: _searchRawIdCtl,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.primary,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.clear,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _searchRawIdCtl.clear();
                        performRawSearch(); // 调用搜索方法
                      });
                    },
                  ),
                  hintText: localizedStrings.fSearchHint,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  hintStyle: textTheme.bodySmall!.copyWith(
                    // 设置提示文本样式
                    fontSize: 12,
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    performRawSearch();
                  });
                },
              ),
            )),
        SizedBox(
          width: 14,
        ),
        Container(
            width: 260,
            height: 40,
            padding: const EdgeInsets.only(left: 16, right: 20),
            decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(0),
                border: Border.all(
                  color: colorScheme.outline,
                  width: 1,
                )),
            child: DropdownButton(
                underline: SizedBox(),
                isExpanded: true,
                value: rawTypeCtl.text == "" ? null : rawTypeCtl.text,
                items: rawTypeList.isEmpty
                    ? [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            localizedStrings.fPleaseSelectCategory,
                            style: textTheme.bodySmall!.copyWith(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ]
                    : [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            localizedStrings.fPleaseSelectCategory,
                            style: textTheme.bodySmall!.copyWith(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...rawTypeList.map((CategoryTypeList item) {
                          return DropdownMenuItem<String>(
                            value: item.categoryName,
                            child: Text(
                              item.categoryName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        })
                      ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    rawTypeCtl.text = value.toString();
                    performRawSearch();
                  });
                },
                style: textTheme.bodySmall!.copyWith(
                  color: colorScheme.onSurface,
                ))),
        SizedBox(
          width: 14,
        ),
        Tooltip(
            message: localizedStrings.fClearSearchConditionBtn, // 提示信息
            child: IconButton(
              icon: Icon(
                Icons.cleaning_services_outlined,
                color: colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _searchRawIdCtl.clear();
                  rawTypeCtl.clear();
                  performRawSearch(); // 调用搜索方法
                });
              },
              iconSize: 24,
            )),
        Spacer(),
        //新增原料按钮
        IconButton(
          iconSize: 24,
          color: colorScheme.onPrimary,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.onTertiaryFixedVariant,
            disabledBackgroundColor: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            fixedSize: const Size(40, 40),
          ),
          onPressed: mySysUser.roleId != operatorRoleId
              ? () {
                  showAddRawInfoDialog();
                }
              : null,
          icon: getSvgIcon(
              takeInSvgIcon(),
              24,
              24,
              mySysUser.roleId != operatorRoleId
                  ? colorScheme.onPrimary
                  : colorScheme.outline),
        ),
        SizedBox(
          width: regularPadding,
        ),
        buildIconBtn(
            localizedStrings.gBtnExport, exportSvgIcon(), exportRaw,
            enabled: mySysUser.roleId != operatorRoleId),
        SizedBox(
          width: regularPadding,
        ),
        buildIconBtn(
            localizedStrings.gBtnImport, importSvgIcon(), importRaw,
            enabled: mySysUser.roleId != operatorRoleId),
        SizedBox(
          width: regularPadding,
        ),
        buildIconBtn(localizedStrings.fGetRawTemplateBtn,
            rawTemplateSvgIcon(), getRawTemplate,
            enabled: mySysUser.roleId != operatorRoleId),
        SizedBox(
          width: regularPadding,
        ),
        buildDelIconBtn(
            (mySysUser.roleId == operatorRoleId || selRawList.isEmpty)
                ? null
                : () {
                    _deleteSelectedRaw();
                  },
            mySysUser.roleId == operatorRoleId || selRawList.isEmpty),

        SizedBox(
          width: 20,
        ),
      ]),
    );
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

  Widget buildIconBtn(String tip, String iconPath, Function()? onPressed,
      {bool enabled = true}) {
    final bool isEnabled = enabled && onPressed != null;
    return Tooltip(
      message: tip,
      child: IconButton(
        iconSize: 24,
        color: colorScheme.onPrimary,
        focusColor: colorScheme.outline,
        hoverColor: colorScheme.outline,
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.primary,
          disabledBackgroundColor: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          fixedSize: const Size(40, 40),
        ),
        onPressed: isEnabled ? onPressed : null,
        icon: getSvgIcon(iconPath, 24, 24,
            isEnabled ? colorScheme.onPrimary : colorScheme.outline),
      ),
    );
  }

  showAddFormulaIconBtn(String tip, IconData icon, Function()? onPressed,
      {bool enabled = true}) {
    final bool isEnabled = enabled && onPressed != null;
    return Tooltip(
        message: tip,
        child: IconButton(
          iconSize: 24,
          color: colorScheme.onPrimary,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.onTertiaryFixedVariant,
            disabledBackgroundColor: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            fixedSize: const Size(40, 40),
          ),
          onPressed: isEnabled ? onPressed : null,
          icon: getSvgIcon(takeInSvgIcon(), 24, 24,
              isEnabled ? colorScheme.onPrimary : colorScheme.outline),
        ));
  }

  showIconButton(String tip, String iconPath, Function()? onPressed,
      {bool enabled = true}) {
    final bool isEnabled = enabled && onPressed != null;
    return Tooltip(
      message: tip,
      child: IconButton(
        iconSize: 24,
        color: colorScheme.primary,
        focusColor: colorScheme.outline,
        hoverColor: colorScheme.outline,
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.primary,
          disabledBackgroundColor: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          fixedSize: const Size(40, 40),
        ),
        onPressed: isEnabled ? onPressed : null,
        icon: getSvgIcon(iconPath, 24, 24,
            isEnabled ? colorScheme.onPrimary : colorScheme.outline),
      ),
    );
  }

  void getRawTemplate() async {
    final directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["csv"],
      fileName: 'Ingredient_template.csv',
    ));
    if (outputFile == null) return;

    if (!outputFile.contains(".csv")) {
      outputFile = "$outputFile.csv";
    }
    String filePath = outputFile;
    ExportResult result = await exportRawTemplate(filePath);
    if (!mounted) return;
    if (result.isSuccess) {
      showExportDialog(filePath, context);
    } else {
      showTipInfo(result.errorMessage!, context);
    }
  }

  void getFmaTemplate() async {
    final directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["csv"],
      fileName: 'Formula_template.csv',
    ));
    if (outputFile == null) return;

    if (!outputFile.contains(".csv")) {
      outputFile = "$outputFile.csv";
    }
    String filePath = outputFile;
    ExportResult result = await exportFmaTemplate(filePath);
    if (!mounted) return;
    if (result.isSuccess) {
      showExportDialog(filePath, context);
    } else {
      if (context.mounted) {
        showTipInfo(result.errorMessage!, context);
      }
    }
  }

  void importRaw() async {
    //选择一个csv文件
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null) return;
    File file = File(result.files.single.path!);
    if (!mounted) return;
    showTipInfo(localizedStrings.tipValidating, context);

    //读取csv文件
    ImportRawResult resImport = await importRawFromExcel(file);

    if (!mounted) return;
    if (!resImport.isSuccess) {
      showTipInfo(resImport.errorMessage!, context);
      return;
    }
    showTipInfo(resImport.errorMessage!, context);
    sendRawListInBatches(resImport.importRawList);
  }

  Future<void> sendRawListInBatches(List<List<String>> dataList) async {
    const batchSize = 100;

    // 在后台isolate中准备所有批次数据
    final List<String> allBatches = await compute(_prepareAllBatches, {
      'dataList': dataList,
      'batchSize': batchSize,
      'userName': mySysUser.nickName!,
    });

    int currentBatch = 0;

    for (final jsonStr in allBatches) {
      currentBatch++;

      // 让出UI控制权
      await Future.delayed(Duration.zero);

      // 等待当前批次发送完成
      PublicFunctions.importRawList(jsonStr);

      // 如果不是最后一批，等待下一批信号
      if (currentBatch < allBatches.length) {
        await waitAndSendNext();
      }
    }
    await waitAndSendNext();

    eventBus.fire(EventImportRawOK(''));
  }

// 在后台isolate中准备数据（不阻塞UI）
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

// 修复waitAndSendNext，避免阻塞
  Future<void> waitAndSendNext() async {
    final completer = Completer<void>();
    final timer = Timer(const Duration(minutes: 1), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    // 使用事件监听代替循环等待
    final subscription = eventBus.on<EventRespImportRawList>().listen((event) {
      if (!completer.isCompleted) {
        timer.cancel();
        completer.complete();
      }
    });

    await completer.future;
    subscription.cancel();
  }

  bool checkRawExist(String materialId) {
    return rawDataList.any((element) => element.materialId == materialId);
  }

  bool checkScaleExist(String scaleName) {
    return myAllScalesList.any((element) => element.scaleName == scaleName);
  }

  void importFormula() async {
    //选择一个csv文件
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null) return;
    File file = File(result.files.single.path!);
    if (!mounted) return;
    showTipInfo(localizedStrings.tipValidating, context);
    //读取xlsx文件
    ImportFmaResult importRes = await importFormulasFromExcel(file);
    if (!mounted) return;
    if (!importRes.isSuccess) {
      showTipInfo(importRes.errorMessage!, context);
      return;
    }
    showTipInfo(importRes.errorMessage!, context);
    sendFmaListInBatches(importRes.importFmaInfoList);
  }

  void sendFmaListInBatches(List<ImportFmaInfo> dataList) {
    const batchSize = 100;
    int totalItems = dataList.length;

    // 创建一个定时器的流控制器
    final StreamController<Timer> timerController = StreamController<Timer>();

    // 创建一个定时器，每隔4秒向流中添加一个新的定时器实例
    Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      timerController.add(t);
    });

    // 创建一个索引，用于跟踪当前发送到哪个批次了
    int currentIndex = 0;

    // 监听定时器流，当有新的定时器实例时，发送下一批数据
    timerController.stream.listen((Timer timer) {
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
        // 所有数据发送完毕，关闭定时器流控制器
        timerController.close();
        timer.cancel();
        eventBus.fire(EventImportFmaOK(''));
      }
    });
  }

  //导出原料的json文件，只要导出勾选的原料
  void exportRaw() async {
    if (selRawList.isEmpty) {
      showTipInfo(localizedStrings.gTipNoDataSelected, context);
      return;
    }
    List<RawDataInfo> exportRawList = selRawList;

    final directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["csv"],
      fileName: 'ingredient_list.csv',
    ));
    if (outputFile == null) return;

    if (!outputFile.contains(".csv")) {
      outputFile = "$outputFile.csv";
    }
    String filePath = outputFile;

    // 将 CSV 数据写入文件
    ExportResult result = await exportRawListToCsv(exportRawList, filePath);
    if (!mounted) return;
    if (result.isSuccess) {
      showExportDialog(filePath, context);
    } else {
      showTipInfo(result.errorMessage!, context);
    }
  }

//导出配方的json文件，只要导出勾选的配方
  exportFormula() async {
    if (selFormulas.isEmpty) {
      showTipInfo(localizedStrings.gTipNoDataSelected, context);
      return;
    }
    List<FormulaInfoDb> exportFormulaList = selFormulas;
    final directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      type: FileType.custom,
      dialogTitle: 'Output file:',
      allowedExtensions: ["csv"],
      fileName: 'formula_list.csv',
    ));
    if (outputFile == null) return;

    if (!outputFile.contains(".csv")) {
      outputFile = "$outputFile.csv";
    }
    String filePath = outputFile;

    // 将 CSV 数据写入文件
    ExportResult result =
        await exportFormulaListToCsv(exportFormulaList, filePath);
    if (!mounted) return;
    if (result.isSuccess) {
      showExportDialog(filePath, context);
    } else {
      showTipInfo(result.errorMessage!, context);
    }
  }

  showFormulaSearch() {
    return Container(
      height: 70,
      color: colorScheme.surface,
      child: Row(children: [
        SizedBox(
          width: 20,
        ),
        SizedBox(
            width: 180,
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  controller: _searchFmaIdCtl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchFmaIdCtl.clear();
                          performFmaSearch();
                        });
                      },
                    ),
                    hintText: localizedStrings.fSearchHint,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    hintStyle: textTheme.bodySmall!.copyWith(
                      // 设置提示文本样式
                      fontSize: 12,
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // 这里可以添加搜索逻辑
                      performFmaSearch();
                    });
                  }),
            )),
        SizedBox(
          width: 14,
        ),
        Container(
          width: 180,
          height: 40,
          padding: const EdgeInsets.only(left: 16, right: 20),
          decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(0),
              border: Border.all(
                color: colorScheme.outline,
                width: 1,
              )),
          child: DropdownButton(
            underline: SizedBox(),
            isExpanded: true,
            value: searchFmaTypeCtl.text == "" ? null : searchFmaTypeCtl.text,
            items: formulaTypeList.isEmpty
                ? [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        localizedStrings.fPleaseSelectCategory,
                        style: textTheme.bodySmall!.copyWith(
                          // 设置提示文本样式
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                      ),
                    )
                  ]
                : [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(localizedStrings.fPleaseSelectCategory,
                          style: textTheme.bodySmall!.copyWith(
                            // 设置提示文本样式
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          )),
                    ),
                    ...formulaTypeList.map((CategoryTypeList item) {
                      return DropdownMenuItem<String>(
                        value: item.categoryName,
                        child: Text(
                          item.categoryName,
                          style: textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      );
                    })
                  ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                searchFmaTypeCtl.text = value.toString();
                performFmaSearch();
              });
            },
            style: textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          width: 14,
        ),
        Container(
          width: 180,
          height: 40,
          padding: const EdgeInsets.only(left: 16, right: 20),
          decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(0),
              border: Border.all(
                color: colorScheme.outline,
                width: 1,
              )),
          child: DropdownButton<EncryptedValue>(
            underline: SizedBox(),
            isExpanded: true,
            value: searchFmaEncryptedCtl.text == ""
                ? null
                : EncryptedValue.values.firstWhere((element) =>
                    element.getTranslation(context) ==
                    searchFmaEncryptedCtl.text),
            // 修改 items 部分，添加空状态提示
            items: [
              DropdownMenuItem<EncryptedValue>(
                value: null,
                child: Text(localizedStrings.fSelectConfidentialityStatusMsg,
                    style: textTheme.bodySmall!.copyWith(
                      // 设置提示文本样式
                      fontSize: 12,
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    )),
              ),
              ...EncryptedValue.values.map((value) {
                return DropdownMenuItem<EncryptedValue>(
                  value: value,
                  child: Text(
                    value.getTranslation(context),
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }),
            ],

            onChanged: (value) {
              if (value == null) return;
              setState(() {
                searchFmaEncryptedCtl.text = value.getTranslation(context);
                isFmaEncryptedCtl.text = value.toString();
                performFmaSearch();
              });
            },

            style: textTheme.bodySmall!.copyWith(
              // 设置提示文本样式

              color: colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          width: 14,
        ),
        Tooltip(
            message: localizedStrings.fClearSearchConditionBtn, // 提示信息
            child: IconButton(
              icon: Icon(
                Icons.cleaning_services_outlined,
                color: colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  clearFmaSearch();
                  performFmaSearch(); // 调用搜索方法
                });
              },
              iconSize: 24,
            )),

        Spacer(),
        showAddFormulaIconBtn(
            localizedStrings.fAddFmaBtn, Icons.add_box_outlined, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddFormulaPage()));
        }, enabled: mySysUser.roleId != operatorRoleId),
        SizedBox(
          width: 12,
        ),
        //配方条码搜索
        showIconButton(localizedStrings.fFmaBarcode, fmaBarcodeIcon(), () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SearchFmaBarcodeDialog();
            },
          ).then((fmaValue) {
            if (fmaValue != null) {
              if (mounted) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return ShowFormulaDetailDialog(
                        selectFormula: fmaValue,
                        selectScaleId: selScaleId,
                      );
                    }).then((value) {
                  if (value) {
                    selectedFormula = fmaValue;
                    //判断秤是否在线
                    bool isOk = checkScaleOnline(selectedFormula);
                    if (!isOk) {
                      return;
                    }
                    stopTestScaleOnline();
                    startWeighting();
                  }
                });
              }
            }
          });
        }),
        SizedBox(
          width: 12,
        ),
        //配方称重记录
        showIconButton(
            localizedStrings.fHistoricalWeighingRecordsBtn, recordsIcon(), () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AllFmaWgtRecPage()));
        }, enabled: mySysUser.roleId != operatorRoleId),
        SizedBox(
          width: 12,
        ),
        //导入配方
        showIconButton(
            localizedStrings.gBtnImport, importSvgIcon(), importFormula,
            enabled: mySysUser.roleId != operatorRoleId),
        SizedBox(
          width: 12,
        ),
        //导出配方
        showIconButton(localizedStrings.gBtnExport, exportSvgIcon(), () {
          //导出配方
          exportFormula();
        }, enabled: mySysUser.roleId != operatorRoleId),
        SizedBox(
          width: 12,
        ),
        buildIconBtn(localizedStrings.fGetFmaTemplateBtn,
            rawTemplateSvgIcon(), getFmaTemplate,
            enabled: mySysUser.roleId != operatorRoleId),
        SizedBox(
          width: regularPadding,
        ),
        buildDelIconBtn(
            (mySysUser.roleId == operatorRoleId || selFormulas.isEmpty)
                ? null
                : () {
                    _deleteSelectedFmas();
                  },
            mySysUser.roleId == operatorRoleId || selFormulas.isEmpty),

        SizedBox(
          width: 20,
        ),
      ]),
    );
  }

  showDetailFmaInfo(FormulaInfoDb fmaData) {}

  _deleteSelectedFmas() {
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
        //去掉重复值
        recIds = recIds.toSet().toList();
        PublicFunctions.deleteAllFormulaData(recIds);
      }
    });
  }

  showDarftFmaSearch() {
    return Container(
      height: 70,
      color: colorScheme.surface,
      child: Row(children: [
        SizedBox(
          width: 20,
        ),
        SizedBox(
            width: 245,
            height: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  controller: _searchDarftIdCtl,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchDarftIdCtl.clear();
                          perforDarftSearch();
                        });
                      },
                    ),
                    hintText: localizedStrings.fSearchHint,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    hintStyle: textTheme.bodySmall!.copyWith(
                      // 设置提示文本样式
                      fontSize: 12,
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // 这里可以添加搜索逻辑
                      perforDarftSearch();
                    });
                  }),
            )),
        Spacer(),
        buildDelIconBtn(
            selDarftFmaList.isEmpty
                ? null
                : () {
                    _deleteDarftFma();
                  },
            selDarftFmaList.isEmpty),
        SizedBox(
          width: 20,
        ),
      ]),
    );
  }

  Widget buildDelIconBtn(Function()? onPressed, bool isDisabled) {
    return IconButton(
      iconSize: 24,
      color: colorScheme.outline,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.error,
        disabledBackgroundColor: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        fixedSize: const Size(40, 40),
      ),
      onPressed: onPressed,
      icon: getSvgIcon(deleteSvgIcon(), 24, 24,
          isDisabled ? colorScheme.outline : colorScheme.onPrimary),
    );
  }

  void _deleteDarftFma() {
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
        List<String> orderIds = [];
        for (var darftFma in selDarftFmaList) {
          orderIds.add(darftFma.fmaRec?.header?.orderId ?? '');
        }
        //去掉重复值
        orderIds = orderIds.toSet().toList();
        PublicFunctions.deleteAllDraftRecord(orderIds);
      }
    });
  }

  void perforDarftSearch() {
    final String keyword = _searchDarftIdCtl.text.trim();

    setState(() {
      searchDarfFmaInfoList = darfFmaInfoList.where((item) {
        final formulaId = item.fmaInfo?.header?.formulaId ?? '';
        final formulaName = item.fmaInfo?.header?.formulaName ?? '';

        return formulaId.contains(keyword) || formulaName.contains(keyword);
      }).toList();
    });
  }
}
