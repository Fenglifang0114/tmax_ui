//登录请求参数
import 'dart:convert';

class SysUserReq {
  String userName = '';
  String password = '';
  bool autoLogin = false;

  SysUserReq(this.userName, this.password, this.autoLogin);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserName'] = userName;
    data['Password'] = password;
    data['AutoLogin'] = autoLogin;
    return data;
  }
}

//获取用户详细信息时
class SysUserNameReq {
  String userName = '';

  SysUserNameReq(this.userName);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserName'] = userName;

    return data;
  }
}

//删除用户时
class SysUserIdReq {
  int? userId;

  SysUserIdReq(this.userId);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserId'] = userId;

    return data;
  }
}
//删除用户时

ReqDelSysUsers reqDelSysUsersFromJson(String str) =>
    ReqDelSysUsers.fromJson(json.decode(str));

String reqDelSysUsersToJson(ReqDelSysUsers data) => json.encode(data.toJson());

class ReqDelSysUsers {
  List<int>? userIds;

  ReqDelSysUsers({
    this.userIds,
  });

  factory ReqDelSysUsers.fromJson(Map<String, dynamic> json) => ReqDelSysUsers(
        userIds: json["UserIds"] == null
            ? []
            : List<int>.from(json["UserIds"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "UserIds":
            userIds == null ? [] : List<dynamic>.from(userIds!.map((x) => x)),
      };
}

//添加用户

ReqAddSysUser reqAddSysUserFromJson(String str) =>
    ReqAddSysUser.fromJson(json.decode(str));

String reqAddSysUserToJson(ReqAddSysUser data) => json.encode(data.toJson());

class ReqAddSysUser {
  String? userName;
  String? nickName;

  int? roleId;
  String? password;
  bool? isEnabled;
  String? email;
  String? phone;
  int? initialPageId;
  String? remark;
  int? createdBy;
  int? updatedBy;
  List<int>? pagesId;
  String? rfid;

  ReqAddSysUser(
      {this.userName,
      this.nickName,
      this.roleId,
      this.password,
      this.isEnabled,
      this.email,
      this.phone,
      this.initialPageId,
      this.remark,
      this.createdBy,
      this.updatedBy,
      this.pagesId,
      this.rfid});

  factory ReqAddSysUser.fromJson(Map<String, dynamic> json) => ReqAddSysUser(
        userName: json["Username"],
        nickName: json["NickName"],
        roleId: json["RoleId"],
        password: json["Password"],
        isEnabled: json["IsEnabled"],
        email: json["Email"],
        phone: json["Phone"],
        initialPageId: json["InitialPageId"],
        remark: json["Remark"],
        createdBy: json["CreatedBy"],
        updatedBy: json["UpdatedBy"],
        pagesId: json["PagesId"] == null
            ? []
            : List<int>.from(json["PagesId"]!.map((x) => x)),
        rfid: json["Rfid"],
      );

  Map<String, dynamic> toJson() => {
        "Username": userName,
        "NickName": nickName,
        "RoleId": roleId,
        "Password": password,
        "IsEnabled": isEnabled,
        "Email": email,
        "Phone": phone,
        "InitialPageId": initialPageId,
        "Remark": remark,
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "PagesId":
            pagesId == null ? [] : List<dynamic>.from(pagesId!.map((x) => x)),
        "Rfid": rfid,
      };
}

ReqModifyPwd reqModifyPwdFromJson(String str) =>
    ReqModifyPwd.fromJson(json.decode(str));

String reqModifyPwdToJson(ReqModifyPwd data) => json.encode(data.toJson());

class ReqModifyPwd {
  int? userId;
  String? newPassword;

  ReqModifyPwd({
    this.userId,
    this.newPassword,
  });

  factory ReqModifyPwd.fromJson(Map<String, dynamic> json) => ReqModifyPwd(
        userId: json["UserId"],
        newPassword: json["NewPassword"],
      );

  Map<String, dynamic> toJson() => {
        "UserId": userId,
        "NewPassword": newPassword,
      };
}

//启用禁用用户

ReqEnableSysUser reqEnableSysUserFromJson(String str) =>
    ReqEnableSysUser.fromJson(json.decode(str));

String reqEnableSysUserToJson(ReqEnableSysUser data) =>
    json.encode(data.toJson());

class ReqEnableSysUser {
  int? userId;
  bool? isEnabled;

  ReqEnableSysUser({
    this.userId,
    this.isEnabled,
  });

  factory ReqEnableSysUser.fromJson(Map<String, dynamic> json) =>
      ReqEnableSysUser(
        userId: json["UserId"],
        isEnabled: json["IsEnabled"],
      );

  Map<String, dynamic> toJson() => {
        "UserId": userId,
        "IsEnabled": isEnabled,
      };
}

//修改用户信息

ReqUpdateSysUser reqUpdateSysUserFromJson(String str) =>
    ReqUpdateSysUser.fromJson(json.decode(str));

String reqUpdateSysUserToJson(ReqUpdateSysUser data) =>
    json.encode(data.toJson());

class ReqUpdateSysUser {
  UpdateUser? updateUser;
  List<int>? pagesId;

  ReqUpdateSysUser({
    this.updateUser,
    this.pagesId,
  });

  factory ReqUpdateSysUser.fromJson(Map<String, dynamic> json) =>
      ReqUpdateSysUser(
        updateUser: json["UpdateUser"] == null
            ? null
            : UpdateUser.fromJson(json["UpdateUser"]),
        pagesId: json["PagesId"] == null
            ? []
            : List<int>.from(json["PagesId"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "UpdateUser": updateUser?.toJson(),
        "PagesId":
            pagesId == null ? [] : List<dynamic>.from(pagesId!.map((x) => x)),
      };
}

class UpdateUser {
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
  String? rfid;

  UpdateUser({
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
    this.rfid,
  });

  factory UpdateUser.fromJson(Map<String, dynamic> json) => UpdateUser(
        userId: json["userId"],
        userName: json["userName"],
        nickName: json["nickName"],
        roleId: json["roleId"],
        password: json["password"],
        isEnabled: json["isEnabled"],
        email: json["email"],
        phone: json["phone"],
        initialPageId: json["initialPageId"],
        remark: json["remark"],
        createdTime: json["createdTime"] == null
            ? null
            : DateTime.parse(json["createdTime"]).toLocal(),
        updatedTime: json["updatedTime"] == null
            ? null
            : DateTime.parse(json["updatedTime"]).toLocal(),
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        rfid: json["Rfid"] ?? json["rfid"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "userName": userName,
        "nickName": nickName,
        "roleId": roleId,
        "password": password,
        "isEnabled": isEnabled,
        "email": email,
        "phone": phone,
        "initialPageId": initialPageId,
        "remark": remark,
        "createdTime": createdTime?.toIso8601String(),
        "updatedTime": updatedTime?.toIso8601String(),
        "createdBy": createdBy,
        "updatedBy": updatedBy,
        "Rfid": rfid,
      };
}

ReqRfidLogin reqRfidLoginFromJson(String str) =>
    ReqRfidLogin.fromJson(json.decode(str));

String reqRfidLoginToJson(ReqRfidLogin data) => json.encode(data.toJson());

class ReqRfidLogin {
  String? rfid;

  ReqRfidLogin({this.rfid});

  factory ReqRfidLogin.fromJson(Map<String, dynamic> json) => ReqRfidLogin(
        rfid: json["Rfid"],
      );

  Map<String, dynamic> toJson() => {
        "Rfid": rfid,
      };
}
