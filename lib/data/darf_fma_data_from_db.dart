//暂存的配方记录，来自数据库
// To parse this JSON data, do
//
//     final darfFmaInfoListFromDb = darfFmaInfoListFromDbFromJson(jsonString);

import 'dart:convert';

import 'package:t_max/data/formula_from_db_data.dart';

List<DarfFmaInfoListFromDb> darfFmaInfoListFromDbFromJson(String str) =>
    List<DarfFmaInfoListFromDb>.from(
        json.decode(str).map((x) => DarfFmaInfoListFromDb.fromJson(x)));

String darfFmaInfoListFromDbToJson(List<DarfFmaInfoListFromDb> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

String darfFmaInfoFromDbToJson(DarfFmaInfoListFromDb data) =>
    json.encode(data.toJson());

class DarfFmaInfoListFromDb {
  DarfHeader? header;
  List<DarfDetail>? details;

  DarfFmaInfoListFromDb({
    this.header,
    this.details,
  });

  factory DarfFmaInfoListFromDb.fromJson(Map<String, dynamic> json) =>
      DarfFmaInfoListFromDb(
        header:
            json["Header"] == null ? null : DarfHeader.fromJson(json["Header"]),
        details: json["Details"] == null
            ? []
            : List<DarfDetail>.from(
                json["Details"]!.map((x) => DarfDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Header": header?.toJson(),
        "Details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class DarfDetail {
  int? recId;
  String? orderId;
  String? rawMaterialId;
  int? seq;
  double? actualWeight;
  String? actualWeightUnit;
  bool? isContainer;
  String? remark;
  String? remark1;
  String? remark2;
  int? scaleId;
  String? scaleName;
  String? scaleModel;
  String? scaleSn;

  DarfDetail({
    this.recId,
    this.orderId,
    this.rawMaterialId,
    this.seq,
    this.actualWeight,
    this.actualWeightUnit,
    this.isContainer,
    this.remark,
    this.remark1,
    this.remark2,
    this.scaleId,
    this.scaleName,
    this.scaleModel,
    this.scaleSn,
  });

  factory DarfDetail.fromJson(Map<String, dynamic> json) => DarfDetail(
        recId: json["RecID"],
        orderId: json["OrderId"],
        rawMaterialId: json["RawMaterialID"],
        seq: json["Seq"],
        actualWeight: json["ActualWeight"]?.toDouble(),
        actualWeightUnit: json["ActualWeightUnit"],
        isContainer: json["IsContainer"],
        remark: json["Remark"],
        remark1: json["Remark1"],
        remark2: json["Remark2"],
        scaleId: json["ScaleId"],
        scaleName: json["ScaleName"],
        scaleModel: json["ScaleModel"],
        scaleSn: json["ScaleSn"],
      );

  Map<String, dynamic> toJson() => {
        "RecID": recId,
        "OrderId": orderId,
        "RawMaterialID": rawMaterialId,
        "Seq": seq,
        "ActualWeight": actualWeight,
        "ActualWeightUnit": actualWeightUnit,
        "IsContainer": isContainer,
        "Remark": remark,
        "Remark1": remark1,
        "Remark2": remark2,
        "ScaleId": scaleId,
        "ScaleName": scaleName,
        "ScaleModel": scaleModel,
        "ScaleSn": scaleSn,
      };
}

class DarfHeader {
  int? recId;
  String? formulaId;
  String? orderId;
  DateTime? createdAt;
  String? createdBy;
  DateTime? updatedAt;
  String? updatedBy;
  int? status;
  String? remark;
  String? remark1;
  String? remark2;

  DarfHeader({
    this.recId,
    this.formulaId,
    this.orderId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.status,
    this.remark,
    this.remark1,
    this.remark2,
  });

  factory DarfHeader.fromJson(Map<String, dynamic> json) => DarfHeader(
        recId: json["RecID"],
        formulaId: json["FormulaID"],
        orderId: json["OrderId"],
        createdAt: json["CreatedAt"] == null
            ? null
            : DateTime.parse(json["CreatedAt"]).toLocal(),
        createdBy: json["CreatedBy"],
        updatedAt: json["UpdatedAt"] == null
            ? null
            : DateTime.parse(json["UpdatedAt"]).toLocal(),
        updatedBy: json["UpdatedBy"],
        status: json["Status"],
        remark: json["Remark"],
        remark1: json["Remark1"],
        remark2: json["Remark2"],
      );

  Map<String, dynamic> toJson() => {
        "RecID": recId,
        "FormulaID": formulaId,
        "OrderId": orderId,
        "CreatedAt": createdAt?.toIso8601String(),
        "CreatedBy": createdBy,
        "UpdatedAt": updatedAt?.toIso8601String(),
        "UpdatedBy": updatedBy,
        "Status": status,
        "Remark": remark,
        "Remark1": remark1,
        "Remark2": remark2,
      };
}

//显示暂存配方列表的时候使用下面的字段

class DarfFmaInfo {
  DarfFmaInfoListFromDb? fmaRec;
  FormulaInfoDb? fmaInfo;

  DarfFmaInfo({
    this.fmaRec,
    this.fmaInfo,
  });
}

typedef DraftFmaInfo = DarfFmaInfo;
typedef DraftFmaInfoListFromDb = DarfFmaInfoListFromDb;

