import 'package:flutter/material.dart';
import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/add_fma_wgt_dialog.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/pages/start_darft_fma_pct_page.dart';
import 'package:t_max/pages/start_fma_pct_page.dart';
import 'package:t_max/pages/start_fma_secret_page.dart';

/// 电子秤检测与称重流程服务类
class FormulaWeighingService {
  /// 查找原料对应绑定的秤 ID
  static int findScaleIdFromRaw(String materialId) {
    for (var raw in rawDataList) {
      if (raw.materialId == materialId) {
        return raw.scaleId ?? 0;
      }
    }
    return 0;
  }

  /// 检查特定电子秤在线状态
  static bool checkOnline(int scaleId, BuildContext context) {
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

  /// 配方称重前检查秤连接状态
  static bool checkScaleOnline(
      FormulaInfoDb? selectedFormula, int selScaleId, BuildContext context) {
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
      if (!checkOnline(selScaleId, context)) {
        return false;
      }
    }

    if ((selectedFormula.header?.isEncrypted ?? false)) {
      return true;
    }

    List<Detail>? details = selectedFormula.details;

    if (details != null) {
      for (var detail in details) {
        int scaleId = findScaleIdFromRaw(detail.materialId!);

        if (scaleId == 0 && selScaleId == -1) {
          showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
          return false;
        }
        if (scaleId == 0) {
          scaleId = selScaleId;
        }
        if (!checkOnline(scaleId, context)) {
          return false;
        }
      }
    }
    return true;
  }

  /// 草稿称重前检查秤连接状态
  static bool checkDarftScaleOnline(
      DarfFmaInfo? darftFma, int selScaleId, BuildContext context) {
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
      if (!checkOnline(selScaleId, context)) {
        return false;
      }
    }

    if ((darftFma.fmaInfo?.header?.isEncrypted ?? false)) {
      return true;
    }

    List<Detail>? details = darftFma.fmaInfo!.details;

    if (details != null) {
      for (var detail in details) {
        int scaleId = findScaleIdFromRaw(detail.materialId!);

        if (scaleId == 0 && selScaleId == -1) {
          showTipInfo(localizedStrings.gTipSelectDeviceFirst, context);
          return false;
        }

        if (scaleId == 0) {
          scaleId = selScaleId;
        }

        if (!checkOnline(scaleId, context)) {
          return false;
        }
      }
    }
    return true;
  }

  /// 开始标准配方称重
  static void startWeighting({
    required BuildContext context,
    required FormulaInfoDb? selectedFormula,
    required int selScaleId,
    required VoidCallback stopTestScaleOnline,
    required VoidCallback startTestScaleOnline,
  }) {
    if (selectedFormula == null) {
      return;
    }
    if (selectedFormula.header?.isEncrypted == false) {
      if (selectedFormula.header?.formulaMode == "pct") {
        showDialog(
          context: context,
          builder: (context) {
            return AddFormulaWgtDialog();
          },
        ).then((value) {
          if (value != null && value is Map<String, String>) {
            String formulaWgt = value['formulaWgt'] ?? '';
            String formulaUnit = value['formulaUnit'] ?? '';

            if (double.tryParse(formulaWgt) == null) {
              return;
            } else {
              double totalWgt = double.parse(formulaWgt);
              String fmaUnit = formulaUnit;
              if (!context.mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormulaPctWeighingPage(
                    selectFormula: selectedFormula,
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
              selectFormula: selectedFormula,
              selScaleId: selScaleId,
              totalFmaWgt: (selectedFormula.header?.totalWeight ?? 0.0),
              fmaUnit: (selectedFormula.header?.formulaUnit ?? ''),
              fromDarft: false,
            ),
          ),
        ).then((value) {
          startTestScaleOnline();
        });
      }
    } else {
      if (selectedFormula.header?.formulaMode == "pct") {
        showDialog(
          context: context,
          builder: (context) {
            return AddFormulaWgtDialog();
          },
        ).then((value) {
          if (value != null && value is Map<String, String>) {
            String formulaWgt = value['formulaWgt'] ?? '';
            String formulaUnit = value['formulaUnit'] ?? '';

            if (double.tryParse(formulaWgt) == null) {
              return;
            } else {
              double totalWgt = double.parse(formulaWgt);
              String fmaUnit = formulaUnit;
              if (!context.mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormulaSecretWeighingPage(
                    selectFormula: selectedFormula,
                    selScaleId: selScaleId,
                    totalFmaWgt: totalWgt,
                    fmaUnit: fmaUnit,
                    fromDraft: false,
                    selectDarftInfo: null,
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
              selectFormula: selectedFormula,
              selScaleId: selScaleId,
              totalFmaWgt: (selectedFormula.header?.totalWeight ?? 0.0),
              fmaUnit: (selectedFormula.header?.formulaUnit ?? ''),
              fromDraft: false,
              selectDarftInfo: null,
            ),
          ),
        ).then((value) {
          startTestScaleOnline();
        });
      }
    }
  }

  /// 开始暂存草稿配方称重
  static void startDarftWeighting({
    required BuildContext context,
    required DarfFmaInfo? selectedDarfFma,
    required int selScaleId,
  }) {
    if (selectedDarfFma == null) {
      return;
    }
    if (selectedDarfFma.fmaInfo?.header?.isEncrypted == false) {
      if (selectedDarfFma.fmaInfo?.header?.formulaMode == "pct") {
        showDialog(
          context: context,
          builder: (context) {
            return AddFormulaWgtDialog();
          },
        ).then((value) {
          if (value != null && value is Map<String, String>) {
            String formulaWgt = value['formulaWgt'] ?? '';
            String formulaUnit = value['formulaUnit'] ?? '';

            if (double.tryParse(formulaWgt) == null) {
              return;
            } else {
              double totalWgt = double.parse(formulaWgt);
              String fmaUnit = formulaUnit;
              if (!context.mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DarftFmaPctWgtPage(
                    selectFormula: (selectedDarfFma.fmaInfo ?? FormulaInfoDb()),
                    selScaleId: selScaleId,
                    totalFmaWgt: totalWgt,
                    fmaUnit: fmaUnit,
                    fromDarft: false,
                    selectDarftInfo: (selectedDarfFma.fmaRec ?? DarfFmaInfoListFromDb()),
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
              selectFormula: (selectedDarfFma.fmaInfo ?? FormulaInfoDb()),
              selScaleId: selScaleId,
              totalFmaWgt: (selectedDarfFma.fmaInfo ?? FormulaInfoDb()).header!.totalWeight!,
              fmaUnit: (selectedDarfFma.fmaInfo ?? FormulaInfoDb()).header!.formulaUnit!,
              fromDarft: false,
              selectDarftInfo: (selectedDarfFma.fmaRec ?? DarfFmaInfoListFromDb()),
            ),
          ),
        );
      }
    } else {
      if (selectedDarfFma.fmaInfo?.header?.formulaMode == "pct") {
        showDialog(
          context: context,
          builder: (context) {
            return AddFormulaWgtDialog();
          },
        ).then((value) {
          if (value != null && value is Map<String, String>) {
            String formulaWgt = value['formulaWgt'] ?? '';
            String formulaUnit = value['formulaUnit'] ?? '';

            if (double.tryParse(formulaWgt) == null) {
              return;
            } else {
              double totalWgt = double.parse(formulaWgt);
              String fmaUnit = formulaUnit;
              if (!context.mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormulaSecretWeighingPage(
                    selectFormula: (selectedDarfFma.fmaInfo ?? FormulaInfoDb()),
                    selScaleId: selScaleId,
                    totalFmaWgt: totalWgt,
                    fmaUnit: fmaUnit,
                    fromDraft: true,
                    selectDarftInfo: (selectedDarfFma.fmaRec ?? DarfFmaInfoListFromDb()),
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
              selectFormula: (selectedDarfFma.fmaInfo ?? FormulaInfoDb()),
              selScaleId: selScaleId,
              totalFmaWgt: (selectedDarfFma.fmaInfo ?? FormulaInfoDb()).header!.totalWeight!,
              fmaUnit: (selectedDarfFma.fmaInfo ?? FormulaInfoDb()).header!.formulaUnit!,
              fromDraft: true,
              selectDarftInfo: (selectedDarfFma.fmaRec ?? DarfFmaInfoListFromDb()),
            ),
          ),
        );
      }
    }
  }
}
