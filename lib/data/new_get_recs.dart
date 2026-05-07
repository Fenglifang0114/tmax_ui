// To parse this JSON data, do
//
//     final reqGetAllWgtRecs = reqGetAllWgtRecsFromJson(jsonString);

import 'dart:convert';

ReqGetAllWgtRecs reqGetAllWgtRecsFromJson(String str) =>
    ReqGetAllWgtRecs.fromJson(json.decode(str));

String reqGetAllWgtRecsToJson(ReqGetAllWgtRecs data) =>
    json.encode(data.toJson());

class ReqGetAllWgtRecs {
  int? mode;
  int? page;
  int? pageSize;
  String? columnName;
  String? direction;

  ReqGetAllWgtRecs({
    this.mode,
    this.page,
    this.pageSize,
    this.columnName,
    this.direction,
  });

  factory ReqGetAllWgtRecs.fromJson(Map<String, dynamic> json) =>
      ReqGetAllWgtRecs(
        mode: json["Mode"],
        page: json["Page"],
        pageSize: json["PageSize"],
        columnName: json["ColumnName"],
        direction: json["Direction"],
      );

  Map<String, dynamic> toJson() => {
        "Mode": mode,
        "Page": page,
        "PageSize": pageSize,
        "ColumnName": columnName,
        "Direction": direction,
      };
}

//从数据库获取的数据
// To parse this JSON data, do
//
//     final revAllWgtRecs = revAllWgtRecsFromJson(jsonString);

RevAllWgtRecs revAllWgtRecsFromJson(String str) =>
    RevAllWgtRecs.fromJson(json.decode(str));

String revAllWgtRecsToJson(RevAllWgtRecs data) => json.encode(data.toJson());

class RevAllWgtRecs {
  List<ScaleRecInfo>? scaleRecInfos;
  int? totalCount;

  RevAllWgtRecs({
    this.scaleRecInfos,
    this.totalCount,
  });

  factory RevAllWgtRecs.fromJson(Map<String, dynamic> json) => RevAllWgtRecs(
        scaleRecInfos: json["scale_rec_infos"] == null
            ? []
            : List<ScaleRecInfo>.from(
                json["scale_rec_infos"]!.map((x) => ScaleRecInfo.fromJson(x))),
        totalCount: json["total_count"],
      );

  Map<String, dynamic> toJson() => {
        "scale_rec_infos": scaleRecInfos == null
            ? []
            : List<dynamic>.from(scaleRecInfos!.map((x) => x.toJson())),
        "total_count": totalCount,
      };
}

class ScaleRecInfo {
  Header? header;
  List<NewWgtDetail>? details;

  ScaleRecInfo({
    this.header,
    this.details,
  });

  factory ScaleRecInfo.fromJson(Map<String, dynamic> json) => ScaleRecInfo(
        header: json["Header"] == null ? null : Header.fromJson(json["Header"]),
        details: json["Details"] == null
            ? []
            : List<NewWgtDetail>.from(
                json["Details"]!.map((x) => NewWgtDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Header": header?.toJson(),
        "Details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class NewWgtDetail {
  int? recId;
  int? headId;
  int? no;
  String? scaleModel;
  String? scaleSn;
  String? weight;
  String? weightUnit;
  String? scaleName;
  DateTime? createdAt;

  NewWgtDetail({
    this.recId,
    this.headId,
    this.no,
    this.scaleModel,
    this.scaleSn,
    this.weight,
    this.weightUnit,
    this.scaleName,
    this.createdAt,
  });

  factory NewWgtDetail.fromJson(Map<String, dynamic> json) => NewWgtDetail(
        recId: json["RecId"],
        headId: json["HeadId"],
        no: json["No"],
        scaleModel: json["ScaleModel"],
        scaleSn: json["ScaleSn"],
        weight: json["Weight"],
        weightUnit: json["WeightUnit"],
        scaleName: json["ScaleName"],
        createdAt: json["CreatedAt"] == null
            ? null
            : DateTime.parse(json["CreatedAt"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "HeadId": headId,
        "No": no,
        "ScaleModel": scaleModel,
        "ScaleSn": scaleSn,
        "Weight": weight,
        "WeightUnit": weightUnit,
        "ScaleName": scaleName,
        "CreatedAt": createdAt?.toIso8601String(),
      };
}

class Header {
  int? recId;
  String? id;
  String? scaleModel;
  String? scaleSn;
  String? plu;
  String? productCode;
  String? itemCode;
  String? category;
  String? productName;
  String? generalUnit;
  String? taxType;
  String? price;
  String? unitWeight;
  String? pretare;
  String? limitHigh;
  String? limitLow;
  String? weight;
  String? weightUnit;
  String? userNo;
  String? userName;
  String? scaleMode;
  String? scaleName;
  DateTime? createdAt;

  Header({
    this.recId,
    this.id,
    this.scaleModel,
    this.scaleSn,
    this.plu,
    this.productCode,
    this.itemCode,
    this.category,
    this.productName,
    this.generalUnit,
    this.taxType,
    this.price,
    this.unitWeight,
    this.pretare,
    this.limitHigh,
    this.limitLow,
    this.weight,
    this.weightUnit,
    this.userNo,
    this.userName,
    this.scaleMode,
    this.scaleName,
    this.createdAt,
  });

  Header copyWith({
    String? id,
    String? scaleModel,
    String? scaleSn,
    String? plu,
    String? productCode,
    String? itemCode,
    String? category,
    String? productName,
    String? generalUnit,
    String? taxType,
    String? price,
    String? unitWeight,
    String? pretare,
    String? limitHigh,
    String? limitLow,
    String? weight,
    String? weightUnit,
    String? userNo,
    String? userName,
    String? scaleMode,
    String? scaleName,
    DateTime? createdAt,
  }) =>
      Header(
        id: id ?? this.id,
        scaleModel: scaleModel ?? this.scaleModel,
        scaleSn: scaleSn ?? this.scaleSn,
        plu: plu ?? this.plu,
        productCode: productCode ?? this.productCode,
        itemCode: itemCode ?? this.itemCode,
        category: category ?? this.category,
        productName: productName ?? this.productName,
        generalUnit: generalUnit ?? this.generalUnit,
        taxType: taxType ?? this.taxType,
        price: price ?? this.price,
        unitWeight: unitWeight ?? this.unitWeight,
        pretare: pretare ?? this.pretare,
        limitHigh: limitHigh ?? this.limitHigh,
        limitLow: limitLow ?? this.limitLow,
        weight: weight ?? this.weight,
        weightUnit: weightUnit ?? this.weightUnit,
        userNo: userNo ?? this.userNo,
        userName: userName ?? this.userName,
        scaleMode: scaleMode ?? this.scaleMode,
        scaleName: scaleName ?? this.scaleName,
        createdAt: createdAt ?? this.createdAt,
      );

  factory Header.fromJson(Map<String, dynamic> json) => Header(
        recId: json["RecId"],
        id: json["Id"],
        scaleModel: json["ScaleModel"],
        scaleSn: json["ScaleSn"],
        plu: json["Plu"],
        productCode: json["ProductCode"],
        itemCode: json["ItemCode"],
        category: json["Category"],
        productName: json["ProductName"],
        generalUnit: json["GeneralUnit"],
        taxType: json["TaxType"],
        price: json["Price"],
        unitWeight: json["UnitWeight"],
        pretare: json["Pretare"],
        limitHigh: json["LimitHigh"],
        limitLow: json["LimitLow"],
        weight: json["Weight"],
        weightUnit: json["WeightUnit"],
        userNo: json["UserNo"],
        userName: json["UserName"],
        scaleMode: json["ScaleMode"],
        scaleName: json["ScaleName"],
        createdAt: json["CreatedAt"] == null
            ? null
            : DateTime.parse(json["CreatedAt"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "Id": id,
        "ScaleModel": scaleModel,
        "ScaleSn": scaleSn,
        "Plu": plu,
        "ProductCode": productCode,
        "ItemCode": itemCode,
        "Category": category,
        "ProductName": productName,
        "GeneralUnit": generalUnit,
        "TaxType": taxType,
        "Price": price,
        "UnitWeight": unitWeight,
        "Pretare": pretare,
        "LimitHigh": limitHigh,
        "LimitLow": limitLow,
        "Weight": weight,
        "WeightUnit": weightUnit,
        "UserNo": userNo,
        "UserName": userName,
        "ScaleMode": scaleMode,
        "ScaleName": scaleName,
        "CreatedAt": createdAt?.toIso8601String(),
      };
}

//以上解析

ReqDelAllWgtRecs reqDelAllWgtRecsFromJson(String str) =>
    ReqDelAllWgtRecs.fromJson(json.decode(str));

String reqDelAllWgtRecsToJson(ReqDelAllWgtRecs data) =>
    json.encode(data.toJson());

class ReqDelAllWgtRecs {
  int? mode;

  ReqDelAllWgtRecs({
    this.mode,
  });

  factory ReqDelAllWgtRecs.fromJson(Map<String, dynamic> json) =>
      ReqDelAllWgtRecs(
        mode: json["Mode"],
      );

  Map<String, dynamic> toJson() => {
        "Mode": mode,
      };
}

//请求增加汇总的称重记录

ReqAddWgtRec reqAddWgtRecFromJson(String str) =>
    ReqAddWgtRec.fromJson(json.decode(str));

String reqAddWgtRecToJson(ReqAddWgtRec data) => json.encode(data.toJson());

class ReqAddWgtRec {
  int? mode;
  Header? headRec;
  List<NewWgtDetail>? detailRec;

  ReqAddWgtRec({
    this.mode,
    this.headRec,
    this.detailRec,
  });

  factory ReqAddWgtRec.fromJson(Map<String, dynamic> json) => ReqAddWgtRec(
        mode: json["Mode"],
        headRec:
            json["HeadRec"] == null ? null : Header.fromJson(json["HeadRec"]),
        detailRec: json["DetailRec"] == null
            ? []
            : List<NewWgtDetail>.from(
                json["DetailRec"]!.map((x) => NewWgtDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Mode": mode,
        "HeadRec": headRec?.toJson(),
        "DetailRec": detailRec == null
            ? []
            : List<dynamic>.from(detailRec!.map((x) => x.toJson())),
      };
}

//请求导出所有数据

String reqExportAllWgtRecsToJson(ReqExportAllWgtRecs data) =>
    json.encode(data.toJson());

class ReqExportAllWgtRecs {
  int? mode;
  String? path;
  List<String>? fieldName;
  Map<String, String>? translation;

  ReqExportAllWgtRecs({
    this.mode,
    this.path,
    this.fieldName,
    this.translation,
  });

  Map<String, dynamic> toJson() => {
        "Mode": mode,
        "Path": path,
        "FieldName": fieldName,
        "Translation": translation,
      };
}

UnstableZeroTare unstableZeroTareFromJson(String str) =>
    UnstableZeroTare.fromJson(json.decode(str));

String unstableZeroTareToJson(UnstableZeroTare data) =>
    json.encode(data.toJson());

class UnstableZeroTare {
  bool? enable;

  UnstableZeroTare({
    this.enable,
  });

  factory UnstableZeroTare.fromJson(Map<String, dynamic> json) =>
      UnstableZeroTare(
        enable: json["Enable"],
      );

  Map<String, dynamic> toJson() => {
        "Enable": enable,
      };
}
