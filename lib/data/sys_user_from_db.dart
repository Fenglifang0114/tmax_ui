// To parse this JSON data, do
//
//     final sysUserDetailFromDb = sysUserDetailFromDbFromJson(jsonString);

import 'dart:convert';

SysUserDetailFromDb sysUserDetailFromDbFromJson(String str) =>
    SysUserDetailFromDb.fromJson(json.decode(str));

String sysUserDetailFromDbToJson(SysUserDetailFromDb data) =>
    json.encode(data.toJson());

class SysUserDetailFromDb {
  int? userId;
  String? userName;
  String? nickName;
  String? password;
  String? email;
  String? phone;
  bool? isEnabled;
  int? roleId;
  String? roleName;
  int? initialPageId;
  bool? isChanged;
  List<int>? pageIdList;
  String? rfid;

  SysUserDetailFromDb({
    this.userId,
    this.userName,
    this.nickName,
    this.password,
    this.email,
    this.phone,
    this.isEnabled,
    this.roleId,
    this.roleName,
    this.initialPageId,
    this.isChanged,
    this.pageIdList,
    this.rfid,
  });

  factory SysUserDetailFromDb.fromJson(Map<String, dynamic> json) =>
      SysUserDetailFromDb(
        userId: json["userId"],
        userName: json["userName"],
        nickName: json["nickName"],
        password: json["password"],
        email: json["email"],
        phone: json["phone"],
        isEnabled: json["isEnabled"],
        roleId: json["roleId"],
        roleName: json["roleName"],
        initialPageId: json["initialPageId"],
        isChanged: json["isChanged"] ?? false,
        pageIdList: json["pageIdList"] == null
            ? []
            : List<int>.from(json["pageIdList"]!.map((x) => x)),
        rfid: json["rfid"] ?? json["Rfid"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "userName": userName,
        "nickName": nickName,
        "password": password,
        "email": email,
        "phone": phone,
        "isEnabled": isEnabled,
        "roleId": roleId,
        "roleName": roleName,
        "initialPageId": initialPageId,
        "isChanged": isChanged,
        "pageIdList": pageIdList == null
            ? []
            : List<dynamic>.from(pageIdList!.map((x) => x)),
        "rfid": rfid,
      };
}

//全部的系统用户
// To parse this JSON data, do
//
//     final sysUserFromDb = sysUserFromDbFromJson(jsonString);

List<SysUserFromDb> sysUserFromDbFromJson(String str) =>
    List<SysUserFromDb>.from(
        json.decode(str).map((x) => SysUserFromDb.fromJson(x)));

String sysUserFromDbToJson(List<SysUserFromDb> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SysUserFromDb {
  int? userId;
  String? userName;
  String? nickName;

  int? roleId;
  String? password;
  bool? isEnabled;
  String? email;
  String? phone;
  int? initialPageId;
  String? remark;
  DateTime? createdTime;
  DateTime? updatedTime;
  int? createdBy;
  int? updatedBy;
  bool? isChanged;
  String? rfid;

  SysUserFromDb({
    this.userId,
    this.userName,
    this.nickName,
    this.roleId,
    this.password,
    this.isEnabled,
    this.email,
    this.phone,
    this.initialPageId,
    this.remark,
    this.createdTime,
    this.updatedTime,
    this.createdBy,
    this.updatedBy,
    this.isChanged,
    this.rfid,
  });

  factory SysUserFromDb.fromJson(Map<String, dynamic> json) => SysUserFromDb(
        userId: json["UserId"],
        userName: json["UserName"],
        nickName: json["NickName"],
        roleId: json["RoleId"],
        password: json["Password"],
        isEnabled: json["IsEnabled"],
        email: json["Email"],
        phone: json["Phone"],
        initialPageId: json["InitialPageId"],
        remark: json["Remark"],
        createdTime: json["CreatedTime"] == null
            ? null
            : DateTime.parse(json["CreatedTime"]).toLocal(),
        updatedTime: json["UpdatedTime"] == null
            ? null
            : DateTime.parse(json["UpdatedTime"]).toLocal(),
        createdBy: json["CreatedBy"],
        updatedBy: json["UpdatedBy"],
        isChanged: json["IsChanged"] ?? false,
        rfid: json["Rfid"] ?? json["rfid"],
      );

  Map<String, dynamic> toJson() => {
        "UserId": userId,
        "UserName": userName,
        "NickName": nickName,
        "RoleId": roleId,
        "Password": password,
        "IsEnabled": isEnabled,
        "Email": email,
        "Phone": phone,
        "InitialPageId": initialPageId,
        "Remark": remark,
        "CreatedTime": createdTime?.toIso8601String(),
        "UpdatedTime": updatedTime?.toIso8601String(),
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "IsChanged": isChanged,
        "Rfid": rfid,
      };
}
