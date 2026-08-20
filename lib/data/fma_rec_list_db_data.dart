// To parse this JSON data, do
//
//     final fmaRecFromDb = fmaRecFromDbFromJson(jsonString);

import 'dart:convert';

List<FmaRecFromDb> fmaRecFromDbFromJson(String str) => List<FmaRecFromDb>.from(
    json.decode(str).map((x) => FmaRecFromDb.fromJson(x)));

String fmaRecFromDbToJson(List<FmaRecFromDb> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FmaRecFromDb {
  HeaderRec? header;
  List<DetailRec>? details;

  FmaRecFromDb({
    this.header,
    this.details,
  });

  factory FmaRecFromDb.fromJson(Map<String, dynamic> json) => FmaRecFromDb(
        header:
            json["Header"] == null ? null : HeaderRec.fromJson(json["Header"]),
        details: json["Details"] == null
            ? []
            : List<DetailRec>.from(
                json["Details"]!.map((x) => DetailRec.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Header": header?.toJson(),
        "Details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class DetailRec {
  int? recId;
  String? recordId;
  String? materialId;
  String? materialName;
  int? materialTypeId;
  String? materialTypeName;
  String? ingredient;
  DateTime? materialCreatedAt;
  DateTime? materialUpdatedAt;
  String? materialCreatedBy;
  String? materialUpdatedBy;
  String? materialRemark;
  String? materialRemark1;
  double? materialWeight;
  double? materialPercentage;
  int? sequence;
  double? allowableError;
  String? formulaRemark;
  String? formulaRemark1;
  double? targetWgt;
  double? actualWeight;
  double? actualPercentage;
  double? actualErrorWgt;
  double? actualErrorPct;
  String? isQualified;
  DateTime? lastWeighingTime;
  String? recRemark;
  String? recRemark1;
  int? scaleId;
  String? scaleName;
  String? scaleModel;
  String? scaleSn;

  DetailRec({
    this.recId,
    this.recordId,
    this.materialId,
    this.materialName,
    this.materialTypeId,
    this.materialTypeName,
    this.ingredient,
    this.materialCreatedAt,
    this.materialUpdatedAt,
    this.materialCreatedBy,
    this.materialUpdatedBy,
    this.materialRemark,
    this.materialRemark1,
    this.materialWeight,
    this.materialPercentage,
    this.sequence,
    this.allowableError,
    this.formulaRemark,
    this.formulaRemark1,
    this.targetWgt,
    this.actualWeight,
    this.actualPercentage,
    this.actualErrorWgt,
    this.actualErrorPct,
    this.isQualified,
    this.lastWeighingTime,
    this.recRemark,
    this.recRemark1,
    this.scaleId,
    this.scaleName,
    this.scaleModel,
    this.scaleSn,
  });

  factory DetailRec.fromJson(Map<String, dynamic> json) => DetailRec(
        recId: json["RecId"],
        recordId: json["RecordID"],
        materialId: json["MaterialID"],
        materialName: json["MaterialName"],
        materialTypeId: json["MaterialTypeID"],
        materialTypeName: json["MaterialTypeName"],
        ingredient: json["Ingredient"],
        materialCreatedAt: json["MaterialCreatedAt"] == null
            ? null
            : DateTime.parse(json["MaterialCreatedAt"]).toLocal(),
        materialUpdatedAt: json["MaterialUpdatedAt"] == null
            ? null
            : DateTime.parse(json["MaterialUpdatedAt"]).toLocal(),
        materialCreatedBy: json["MaterialCreatedBy"],
        materialUpdatedBy: json["MaterialUpdatedBy"],
        materialRemark: json["MaterialRemark"],
        materialRemark1: json["MaterialRemark1"],
        materialWeight: json["MaterialWeight"]?.toDouble(),
        materialPercentage: json["MaterialPercentage"]?.toDouble(),
        sequence: json["Sequence"],
        allowableError: json["AllowableError"]?.toDouble(),
        formulaRemark: json["FormulaRemark"],
        formulaRemark1: json["FormulaRemark1"],
        targetWgt: json["TargetWgt"]?.toDouble(),
        actualWeight: json["ActualWeight"]?.toDouble(),
        actualPercentage: json["ActualPercentage"]?.toDouble(),
        actualErrorWgt: json["ActualErrorWgt"]?.toDouble(),
        actualErrorPct: json["ActualErrorPct"]?.toDouble(),
        isQualified: json["IsQualified"],
        lastWeighingTime: json["LastWeighingTime"] == null
            ? null
            : DateTime.parse(json["LastWeighingTime"]).toLocal(),
        recRemark: json["RecRemark"],
        recRemark1: json["RecRemark1"],
        scaleId: json["ScaleId"],
        scaleName: json["ScaleName"],
        scaleModel: json["ScaleModel"],
        scaleSn: json["ScaleSN"],
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "RecordID": recordId,
        "MaterialID": materialId,
        "MaterialName": materialName,
        "MaterialTypeID": materialTypeId,
        "MaterialTypeName": materialTypeName,
        "Ingredient": ingredient,
        "MaterialCreatedAt": materialCreatedAt?.toIso8601String(),
        "MaterialUpdatedAt": materialUpdatedAt?.toIso8601String(),
        "MaterialCreatedBy": materialCreatedBy,
        "MaterialUpdatedBy": materialUpdatedBy,
        "MaterialRemark": materialRemark,
        "MaterialRemark1": materialRemark1,
        "MaterialWeight": materialWeight,
        "MaterialPercentage": materialPercentage,
        "Sequence": sequence,
        "AllowableError": allowableError,
        "FormulaRemark": formulaRemark,
        "FormulaRemark1": formulaRemark1,
        "TargetWgt": targetWgt,
        "ActualWeight": actualWeight,
        "ActualPercentage": actualPercentage,
        "ActualErrorWgt": actualErrorWgt,
        "ActualErrorPct": actualErrorPct,
        "IsQualified": isQualified,
        "LastWeighingTime": lastWeighingTime?.toIso8601String(),
        "RecRemark": recRemark,
        "RecRemark1": recRemark1,
        "ScaleId": scaleId,
        "ScaleName": scaleName,
        "ScaleModel": scaleModel,
        "ScaleSN": scaleSn,
      };
}

class HeaderRec {
  int? recId;
  String? recordId;
  DateTime? recordSaveTime;
  String? headerOperator;
  int? formulaKey;
  String? formulaId;
  String? formulaName;
  int? formulaTypeId;
  String? formulaTypeName;
  String? formulaMode;
  double? totalWeight;
  double? actualTotalWeight;
  String? totalWeightUnit;
  int? materialCount;
  double? error;
  String? isQualified;
  double? actualFmaTotalWgt;
  bool? isEncrypted;
  DateTime? formulaCreatedAt;
  DateTime? formulaUpdatedAt;
  String? formulaCreatedBy;
  String? formulaUpdatedBy;
  String? formulaRemark;
  String? formulaRemark1;
  String? recRemark;
  String? recRemark1;
  int? scaleId;
  String? scaleName;
  String? scaleModel;
  String? scaleSn;
  String? formulaBarcode;

  HeaderRec({
    this.recId,
    this.recordId,
    this.recordSaveTime,
    this.headerOperator,
    this.formulaKey,
    this.formulaId,
    this.formulaName,
    this.formulaTypeId,
    this.formulaTypeName,
    this.formulaMode,
    this.totalWeight,
    this.actualTotalWeight,
    this.totalWeightUnit,
    this.materialCount,
    this.error,
    this.isQualified,
    this.actualFmaTotalWgt,
    this.isEncrypted,
    this.formulaCreatedAt,
    this.formulaUpdatedAt,
    this.formulaCreatedBy,
    this.formulaUpdatedBy,
    this.formulaRemark,
    this.formulaRemark1,
    this.recRemark,
    this.recRemark1,
    this.scaleId,
    this.scaleName,
    this.scaleModel,
    this.scaleSn,
    this.formulaBarcode,
  });

  factory HeaderRec.fromJson(Map<String, dynamic> json) => HeaderRec(
        recId: json["RecId"],
        recordId: json["RecordID"],
        recordSaveTime: json["RecordSaveTime"] == null
            ? null
            : DateTime.parse(json["RecordSaveTime"].toString().replaceAll("Z", "")),
        headerOperator: json["Operator"],
        formulaKey: json["FormulaKey"],
        formulaId: json["FormulaID"],
        formulaName: json["FormulaName"],
        formulaTypeId: json["FormulaTypeId"],
        formulaTypeName: json["FormulaTypeName"],
        formulaMode: json["FormulaMode"],
        totalWeight: json["TotalWeight"]?.toDouble(),
        actualTotalWeight: json["ActualTotalWeight"]?.toDouble(),
        totalWeightUnit: json["TotalWeightUnit"],
        materialCount: json["MaterialCount"],
        error: json["Error"]?.toDouble(),
        isQualified: json["IsQualified"],
        actualFmaTotalWgt: json["ActualFmaTotalWgt"]?.toDouble(),
        isEncrypted: json["IsEncrypted"],
        formulaCreatedAt: json["FormulaCreatedAt"] == null
            ? null
            : DateTime.parse(json["FormulaCreatedAt"].toString().replaceAll("Z", "")),
        formulaUpdatedAt: json["FormulaUpdatedAt"] == null
            ? null
            : DateTime.parse(json["FormulaUpdatedAt"].toString().replaceAll("Z", "")),
        formulaCreatedBy: json["FormulaCreatedBy"],
        formulaUpdatedBy: json["FormulaUpdatedBy"],
        formulaRemark: json["FormulaRemark"],
        formulaRemark1: json["FormulaRemark1"],
        recRemark: json["RecRemark"],
        recRemark1: json["RecRemark1"],
        scaleId: json["ScaleId"],
        scaleName: json["ScaleName"],
        scaleModel: json["ScaleModel"],
        scaleSn: json["ScaleSn"],
        formulaBarcode: json["FormulaBarcode"],
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "RecordID": recordId,
        "RecordSaveTime": recordSaveTime?.toIso8601String(),
        "Operator": headerOperator,
        "FormulaKey": formulaKey,
        "FormulaID": formulaId,
        "FormulaName": formulaName,
        "FormulaTypeId": formulaTypeId,
        "FormulaTypeName": formulaTypeName,
        "FormulaMode": formulaMode,
        "TotalWeight": totalWeight,
        "ActualTotalWeight": actualTotalWeight,
        "TotalWeightUnit": totalWeightUnit,
        "MaterialCount": materialCount,
        "Error": error,
        "IsQualified": isQualified,
        "ActualFmaTotalWgt": actualFmaTotalWgt,
        "IsEncrypted": isEncrypted,
        "FormulaCreatedAt": formulaCreatedAt?.toIso8601String(),
        "FormulaUpdatedAt": formulaUpdatedAt?.toIso8601String(),
        "FormulaCreatedBy": formulaCreatedBy,
        "FormulaUpdatedBy": formulaUpdatedBy,
        "FormulaRemark": formulaRemark,
        "FormulaRemark1": formulaRemark1,
        "RecRemark": recRemark,
        "RecRemark1": recRemark1,
        "ScaleId": scaleId,
        "ScaleName": scaleName,
        "ScaleModel": scaleModel,
        "ScaleSn": scaleSn,
        "FormulaBarcode": formulaBarcode,
      };
}

UploadServerInfo uploadServerInfoFromJson(String str) =>
    UploadServerInfo.fromJson(json.decode(str));

String uploadServerInfoToJson(UploadServerInfo data) =>
    json.encode(data.toJson());

class UploadServerInfo {
  int? recId;
  String? ip;
  String? shareName;
  String? username;
  String? password;
  bool? enable;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? createdBy;
  String? updatedBy;

  UploadServerInfo({
    this.recId,
    this.ip,
    this.shareName,
    this.username,
    this.password,
    this.enable,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory UploadServerInfo.fromJson(Map<String, dynamic> json) =>
      UploadServerInfo(
        recId: json["RecId"],
        ip: json["Ip"],
        shareName: json["ShareName"],
        username: json["Username"],
        password: json["Password"],
        enable: json["Enable"],
        createdAt: json["CreatedAt"] == null
            ? null
            : DateTime.parse(json["CreatedAt"]),
        updatedAt: json["UpdatedAt"] == null
            ? null
            : DateTime.parse(json["UpdatedAt"]),
        createdBy: json["CreatedBy"],
        updatedBy: json["UpdatedBy"],
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "Ip": ip,
        "ShareName": shareName,
        "Username": username,
        "Password": password,
        "Enable": enable,
        "CreatedAt": createdAt?.toIso8601String(),
        "UpdatedAt": updatedAt?.toIso8601String(),
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
      };
}
