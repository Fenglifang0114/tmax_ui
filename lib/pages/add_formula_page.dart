import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/dialog/sel_scale_dialog.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/modules/formula/services/formula_save_service.dart';
import 'package:t_max/modules/formula/services/scale_live_stream_service.dart';
import 'package:t_max/modules/formula/views/widgets/add_formula_header_form.dart';
import 'package:t_max/modules/formula/views/widgets/add_formula_raw_adder.dart';
import 'package:t_max/modules/formula/views/widgets/add_formula_raw_list.dart';
import 'package:t_max/widget/page_head.dart';

class AddFormulaPage extends StatefulWidget {
  const AddFormulaPage({super.key});

  @override
  State<AddFormulaPage> createState() => AddFormulaPageState();
}

class AddFormulaPageState extends State<AddFormulaPage> {
  final TextEditingController formulaCodeCtl = TextEditingController();
  final TextEditingController formulaNameCtl = TextEditingController();
  final TextEditingController formulaModeCtl = TextEditingController(text: 'wgt');
  final TextEditingController formulaUnitCtl = TextEditingController(text: 'g');
  final TextEditingController formulaTypeCtl = TextEditingController();
  final TextEditingController rawMaterialCtl = TextEditingController();
  final TextEditingController formulaBarcodeCtl = TextEditingController();

  final TextEditingController wgtCtl = TextEditingController();
  final TextEditingController errorCtl = TextEditingController();
  final TextEditingController remarkCtl = TextEditingController();

  bool isEncrypted = false;
  bool needContainer = false;
  bool freeMode = false;
  RawDataInfo? selectedRawDataInfo;
  List<AddFormulaRawWgtInfo> addFormulaRawList = [];
  double totalWgt = 0.0;
  int selectedIndex = -1;

  final ScaleLiveStreamService scaleLiveStreamService = ScaleLiveStreamService();

  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus5;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scaleLiveStreamService.init(getTargetUnit: () => formulaUnitCtl.text);

    _eventbus2 = eventBus.on<EventRespGetFormulaTypeList>().listen((event) {
      if (mounted) setState(() {});
    });

    _eventbus3 = eventBus.on<EventRespCheckFmaIdAndBarcode>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr.contains(',')) {
          List<String> dataList = dataStr.split(',');
          if (dataList.length >= 2) {
            if (dataList[0] == "false" && dataList[1] == "false") {
              showTipInfo(
                  localizedStrings.fFormulaIdAndBarcodeDuplicate, context);
            } else if (dataList[0] == "false" && dataList[1] == "true") {
              showTipInfo(localizedStrings.fFormulaIdDuplicate, context);
            } else if (dataList[0] == "true" && dataList[1] == "false") {
              showTipInfo(localizedStrings.fFormulaBarcodeDuplicate, context);
            } else if (dataList[0] == "true" && dataList[1] == "true") {
              _saveFormulaSubmit(1);
            }
          }
        }
      }
    });

    _eventbus5 = eventBus.on<EventRespGetRawData>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          setState(() {
            if (rawDataList.isNotEmpty) {
              selectedRawDataInfo = rawDataList.last;
              rawMaterialCtl.text =
                  '${selectedRawDataInfo!.materialId} ${selectedRawDataInfo!.materialName}';
              selectedIndex = -1;
              wgtCtl.text = '';
              errorCtl.text = '';
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    scaleLiveStreamService.dispose();
    _scrollController.dispose();
    _eventbus2?.cancel();
    _eventbus3?.cancel();
    _eventbus5?.cancel();

    formulaCodeCtl.dispose();
    formulaNameCtl.dispose();
    formulaModeCtl.dispose();
    formulaUnitCtl.dispose();
    formulaTypeCtl.dispose();
    rawMaterialCtl.dispose();
    formulaBarcodeCtl.dispose();
    wgtCtl.dispose();
    errorCtl.dispose();
    remarkCtl.dispose();
    addFormulaRawList.clear();
    super.dispose();
  }

  ColorScheme get colorScheme => Theme.of(context).colorScheme;

  void performSwitchFreeMode() {
    if (!freeMode && myAllScalesList.isEmpty) {
      showNoDeviceDialog();
      return;
    }

    if (formulaModeCtl.text == FormulaMode.pct.name) {
      performPctMode();
    } else {
      setState(() {
        freeMode = !freeMode;
      });
    }

    if (!freeMode && scaleLiveStreamService.selScaleId != -1) {
      scaleLiveStreamService.stopWeightAndResetScaleId();
    }
    if (freeMode) {
      showSelScaleDialog();
    }
  }

  void showNoDeviceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ShowNormalTipDialog(
          title: localizedStrings.fTipTitle,
          msg: localizedStrings.gTipNoDeviceAddFirst,
        );
      },
    );
  }

  void performPctMode() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ShowNormalTipDialog(
          title: localizedStrings.fTipTitle,
          msg: localizedStrings.fConfirmClearAndEnterFreeModeMsg,
        );
      },
    ).then((value) {
      if (value == true) {
        setState(() {
          freeMode = !freeMode;
          addFormulaRawList.clear();
          formulaModeCtl.text = FormulaMode.wgt.name;
          formulaUnitCtl.text = FormulaWgtUnit.g.name;
          totalWgt = 0;
        });
      }
    });
  }

  void showSelScaleDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => SelScaleDialog(),
    ).then((value) {
      if (value != null) {
        setState(() {
          if (scaleLiveStreamService.selScaleId != -1) {
            scaleLiveStreamService.stopWeightAndResetScaleId();
          }
          scaleLiveStreamService.setScaleId(value);
          PublicFunctions.getWeight(value);
        });
      }
    });
  }

  void moveUp(int index) {
    if (index > 0) {
      setState(() {
        final temp = addFormulaRawList[index];
        addFormulaRawList[index] = addFormulaRawList[index - 1];
        addFormulaRawList[index - 1] = temp;
        addFormulaRawList[index].sequence = index + 1;
        addFormulaRawList[index - 1].sequence = index;
      });
    }
  }

  void moveDown(int index) {
    if (index < addFormulaRawList.length - 1) {
      setState(() {
        final temp = addFormulaRawList[index];
        addFormulaRawList[index] = addFormulaRawList[index + 1];
        addFormulaRawList[index + 1] = temp;
        addFormulaRawList[index].sequence = index + 1;
        addFormulaRawList[index + 1].sequence = index + 2;
      });
    }
  }

  void updateTotalWgt() {
    totalWgt = 0.0;
    if (addFormulaRawList.isEmpty) return;
    for (var item in addFormulaRawList) {
      totalWgt += item.wgt;
    }
    totalWgt = double.parse(totalWgt.toStringAsFixed(3));
  }

  void newFma() {
    setState(() {
      formulaCodeCtl.text = '';
      formulaNameCtl.text = '';
      formulaTypeCtl.text = '';
      formulaModeCtl.text = 'wgt';
      formulaUnitCtl.text = 'g';
      addFormulaRawList.clear();
      totalWgt = 0;
      remarkCtl.text = '';
      isEncrypted = false;
      needContainer = false;
      selectedRawDataInfo = null;
      selectedIndex = -1;
      rawMaterialCtl.clear();
      errorCtl.text = '';
      wgtCtl.text = '';
    });
  }

  void performSelectItem(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = -1;
      } else {
        selectedIndex = index;
        selectedRawDataInfo = addFormulaRawList[index].rawDataInfo;
        rawMaterialCtl.text =
            '${selectedRawDataInfo!.materialId} ${selectedRawDataInfo!.materialName}';
        wgtCtl.text = addFormulaRawList[index].wgt.toString();
        errorCtl.text = addFormulaRawList[index].error.toString();
      }
    });
  }

  void performModifyBtn() {
    if (selectedRawDataInfo == null) return;
    double wgt = double.tryParse(wgtCtl.text) ?? 0.0;
    double error = double.tryParse(errorCtl.text) ?? 0.0;

    AddFormulaRawWgtInfo tempInfo = AddFormulaRawWgtInfo(
      rawDataInfo: selectedRawDataInfo!,
      sequence: selectedIndex,
      wgt: wgt,
      error: error,
    );
    setState(() {
      addFormulaRawList[selectedIndex] = tempInfo;
      updateTotalWgt();
      wgtCtl.text = '';
      errorCtl.text = '';
      rawMaterialCtl.clear();
      selectedRawDataInfo = null;
      selectedIndex = -1;
    });
  }

  void performAddBtn() {
    if (selectedRawDataInfo == null) return;
    double wgt = double.tryParse(wgtCtl.text) ?? 0.0;
    double error = double.tryParse(errorCtl.text) ?? 0.0;

    int num = addFormulaRawList.length + 1;
    AddFormulaRawWgtInfo tempInfo = AddFormulaRawWgtInfo(
      rawDataInfo: selectedRawDataInfo!,
      sequence: num,
      wgt: wgt,
      error: error,
    );
    setState(() {
      addFormulaRawList.add(tempInfo);
      updateTotalWgt();
      wgtCtl.text = '';
      errorCtl.text = '';
      rawMaterialCtl.clear();
      selectedRawDataInfo = null;
    });
  }

  void _saveFormulaSubmit(int func) {
    FormulaSaveService.saveFormula(
      context: context,
      func: func,
      formulaId: formulaCodeCtl.text,
      formulaName: formulaNameCtl.text,
      formulaType: formulaTypeCtl.text,
      formulaMode: formulaModeCtl.text,
      formulaUnit: formulaUnitCtl.text,
      formulaBarcode: formulaBarcodeCtl.text,
      remark: remarkCtl.text,
      totalWgt: totalWgt,
      isEncrypted: isEncrypted,
      needContainer: needContainer,
      addFormulaRawList: addFormulaRawList,
      onNewFmaSuccess: newFma,
    );
  }

  TextStyle getTextStyle({Color? color}) {
    return Theme.of(context).textTheme.bodySmall!.apply(
          color: color ?? colorScheme.onSurface,
        );
  }

  TextStyle getTitleBoldStyle({Color? color}) {
    return Theme.of(context).textTheme.labelMedium!.apply(
          color: color ?? colorScheme.onSurface,
        );
  }

  Widget showFmaRemark() {
    return Container(
      height: 114,
      alignment: Alignment.centerLeft,
      child: Column(children: [
        Container(
          height: 42,
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  localizedStrings.fRemarkCol,
                  style: getTitleBoldStyle(),
                ),
              ),
            ),
          ]),
        ),
        Container(
          height: 72,
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(children: [
            Expanded(
              child: SizedBox(
                height: 72,
                child: TextField(
                  controller: remarkCtl,
                  style: getTextStyle(),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0.0))),
                    hintText: localizedStrings.fInputRemarkHint,
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  maxLines: 5,
                ),
              ),
            )
          ]),
        )
      ]),
    );
  }

  Widget showBtnRow() {
    return SizedBox(
      height: 86,
      child: Center(
        child: SizedBox(
          width: 400,
          height: 48,
          child: Row(children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: colorScheme.onPrimary,
                  backgroundColor: colorScheme.primary,
                  fixedSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: formulaCodeCtl.text == '' ||
                        formulaNameCtl.text == '' ||
                        formulaModeCtl.text == '' ||
                        formulaUnitCtl.text == '' ||
                        addFormulaRawList.isEmpty
                    ? null
                    : (formulaModeCtl.text == FormulaMode.pct.name &&
                            totalWgt != 100)
                        ? null
                        : () {
                            FormulaSaveService.checkFmaIdAndBarcode(
                              formulaId: formulaCodeCtl.text,
                              formulaBarcode: formulaBarcodeCtl.text,
                            );
                          },
                child: Text(
                  localizedStrings.gBtnSave,
                  style: getTextStyle(
                    color: colorScheme.onPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                  backgroundColor: colorScheme.outline,
                  fixedSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  localizedStrings.fBackBtn,
                  style: getTextStyle(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget showMiddlePart(double widthFor3Item) {
    return Expanded(
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 8,
        radius: const Radius.circular(4),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              AddFormulaHeaderForm(
                formulaCodeCtl: formulaCodeCtl,
                formulaNameCtl: formulaNameCtl,
                formulaModeCtl: formulaModeCtl,
                formulaUnitCtl: formulaUnitCtl,
                formulaTypeCtl: formulaTypeCtl,
                formulaBarcodeCtl: formulaBarcodeCtl,
                isEncrypted: isEncrypted,
                needContainer: needContainer,
                freeMode: freeMode,
                widthFor3Item: widthFor3Item,
                hasRawItems: addFormulaRawList.isNotEmpty,
                onEncryptedChanged: (val) => setState(() => isEncrypted = val),
                onNeedContainerChanged: (val) =>
                    setState(() => needContainer = val),
                onSwitchFreeMode: performSwitchFreeMode,
                onClearRawList: () {
                  setState(() {
                    addFormulaRawList.clear();
                    totalWgt = 0;
                    errorCtl.text = '';
                    wgtCtl.text = '';
                    rawMaterialCtl.clear();
                    selectedIndex = -1;
                  });
                },
                onChanged: () => setState(() {}),
              ),
              Divider(
                height: 1,
                color: colorScheme.surfaceDim,
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AddFormulaRawAdder(
                          constraints: constraints,
                          rawMaterialCtl: rawMaterialCtl,
                          wgtCtl: wgtCtl,
                          errorCtl: errorCtl,
                          formulaModeCtl: formulaModeCtl,
                          formulaUnitCtl: formulaUnitCtl,
                          selectedRawDataInfo: selectedRawDataInfo,
                          selectedIndex: selectedIndex,
                          freeMode: freeMode,
                          scaleLiveStreamService: scaleLiveStreamService,
                          onSelectRawData: (raw) {
                            setState(() {
                              selectedRawDataInfo = raw;
                            });
                          },
                          onAddRawMaterial: performAddBtn,
                          onModifyRawMaterial: performModifyBtn,
                          onCancelEdit: () {
                            setState(() {
                              wgtCtl.text = '';
                              errorCtl.text = '';
                              rawMaterialCtl.clear();
                              selectedRawDataInfo = null;
                              selectedIndex = -1;
                            });
                          },
                          onChanged: () => setState(() {}),
                        ),
                        Container(
                          height: 360,
                          padding: const EdgeInsets.only(top: 24),
                          child: VerticalDivider(
                            width: 1,
                            color: colorScheme.surfaceContainerLow,
                          ),
                        ),
                        AddFormulaRawList(
                          constraints: constraints,
                          addFormulaRawList: addFormulaRawList,
                          totalWgt: totalWgt,
                          needContainer: needContainer,
                          formulaMode: formulaModeCtl.text,
                          formulaUnit: formulaUnitCtl.text,
                          selectedIndex: selectedIndex,
                          onSelectItem: performSelectItem,
                          onMoveUp: moveUp,
                          onMoveDown: moveDown,
                          onDeleteItem: (index) {
                            setState(() {
                              selectedIndex = -1;
                              addFormulaRawList.removeAt(index);
                              updateTotalWgt();
                            });
                          },
                          onClearAll: () {
                            setState(() {
                              addFormulaRawList.clear();
                              totalWgt = 0;
                              errorCtl.text = '';
                              wgtCtl.text = '';
                              rawMaterialCtl.clear();
                              selectedIndex = -1;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              showFmaRemark(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double widthFor3Item =
        (width - 250) / 4 > 380 ? 380 : (width - 250) / 4;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Container(
        color: colorScheme.surface,
        child: Column(
          children: [
            pageHeadInfo(
              context,
              width - headWidthPadding,
              localizedStrings.fAddFmaBtn,
              '',
              () {
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              showHelp: false,
            ),
            Divider(
              height: 1,
              color: colorScheme.surfaceDim,
            ),
            showMiddlePart(widthFor3Item),
            showBtnRow()
          ],
        ),
      ),
    );
  }
}

class AddFormulaRawWgtInfo {
  RawDataInfo rawDataInfo;
  double wgt;
  int sequence;
  double error;

  bool isSelected;

  AddFormulaRawWgtInfo({
    required this.rawDataInfo,
    required this.sequence,
    required this.wgt,
    required this.error,
    this.isSelected = false,
  });
}
