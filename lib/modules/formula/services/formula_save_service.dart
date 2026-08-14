import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/pages/add_formula_page.dart';

/// 配方重名校验与 JSON 序列化提交保存服务类
class FormulaSaveService {
  /// 向后台发送重名校验请求
  static void checkFmaIdAndBarcode({
    required String formulaId,
    required String formulaBarcode,
  }) {
    ReqCheckFmaIdAndBarcode reqCheckFmaIdAndBarcode = ReqCheckFmaIdAndBarcode(
      recId: 0,
      formulaId: formulaId,
      formulaBarcode: formulaBarcode,
    );

    PublicFunctions.checkFmaIdAndBarcode(jsonEncode(reqCheckFmaIdAndBarcode));
  }

  /// 执行保存配方主从明细逻辑
  static void saveFormula({
    required BuildContext context,
    required int func,
    required String formulaId,
    required String formulaName,
    required String formulaType,
    required String formulaMode,
    required String formulaUnit,
    required String formulaBarcode,
    required String remark,
    required double totalWgt,
    required bool isEncrypted,
    required bool needContainer,
    required List<AddFormulaRawWgtInfo> addFormulaRawList,
    required VoidCallback onNewFmaSuccess,
  }) {
    int categoryId = 0;
    for (var item in formulaTypeList) {
      if (item.categoryName == formulaType) {
        categoryId = item.categoryId;
        break;
      }
    }

    ReqFormulaHeader tempHeader = ReqFormulaHeader(
      formulaId: formulaId,
      formulaKey: 0,
      formulaName: formulaName,
      categoryId: categoryId,
      formulaMode: formulaMode,
      formulaUnit: formulaUnit,
      totalWeight: totalWgt,
      materialCount: addFormulaRawList.length,
      isEncrypted: isEncrypted,
      needContainer: needContainer,
      createdBy: mySysUser.nickName,
      updatedBy: mySysUser.nickName,
      remark: remark,
      formulaBarcode: formulaBarcode,
    );

    ReqFormulaAddInfo tempReqAddF = ReqFormulaAddInfo(
      header: tempHeader,
      detail: [],
    );

    int no = 1;
    for (var item in addFormulaRawList) {
      ReqFormulaDetail tempDetail = ReqFormulaDetail();
      tempDetail.formulaId = formulaId;
      tempDetail.materialId = item.rawDataInfo.materialId;
      tempDetail.materialWeight = item.wgt;
      tempDetail.materialPercentage = item.wgt;
      tempDetail.sequence = no++;
      tempDetail.allowableError = item.error;
      tempDetail.remark = '';

      tempReqAddF.detail!.add(tempDetail);
    }

    String jsonStr = formulaAddInfoToJson(tempReqAddF);
    PublicFunctions.addFormulaData(jsonStr);

    if (func == 1) {
      onNewFmaSuccess();
    } else {
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
