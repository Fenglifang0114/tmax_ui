import 'dart:convert';

// To parse this JSON data, do
//
//     final blueToothInfo = blueToothInfoFromJson(jsonString);

BlueToothInfo blueToothInfoFromJson(String str) =>
    BlueToothInfo.fromJson(json.decode(str));

String blueToothInfoToJson(BlueToothInfo data) => json.encode(data.toJson());

class BlueToothInfo {
  String? mac;
  String? name;

  BlueToothInfo({
    this.mac,
    this.name,
  });

  factory BlueToothInfo.fromJson(Map<String, dynamic> json) => BlueToothInfo(
        mac: json["Mac"],
        name: json["Name"],
      );

  Map<String, dynamic> toJson() => {
        "Mac": mac,
        "Name": name,
      };
}

BlueToothInfo myBluetoothInfo = BlueToothInfo();

class ComScaleInfo {
  int scaleId;
  int tMedia;
  bool isOnline;
  String portName;
  int baudRate;
  int dataBits;
  int parity;
  int stopBits;
  String scaleModel;
  String? innerModel;
  String scaleSn;
  bool isDefault;
  String scaleName;

  ComScaleInfo(
      this.scaleId,
      this.tMedia,
      this.isOnline,
      this.portName,
      this.baudRate,
      this.dataBits,
      this.parity,
      this.stopBits,
      this.scaleModel,
      this.scaleSn,
      this.isDefault,
      this.scaleName,
      {this.innerModel});
}

ComScaleInfo myComScaleInfo =
    ComScaleInfo(1, 1, true, "", 1, 1, 1, 1, "", "", false, "");

List<ComScaleInfo> myComScaleList = []; // 用于存储 串口秤 的列表

class Comportdata {
  String modelName;
  String scaSn;
  String scdescription;
  int id;
  int mediaType;
  String portName;
  int baud;
  int dataBits;
  String parity;
  int stopbits;

  Comportdata(
      this.modelName,
      this.scaSn,
      this.scdescription,
      this.id,
      this.mediaType,
      this.portName,
      this.baud,
      this.dataBits,
      this.parity,
      this.stopbits);
}

Comportdata myComportdata = Comportdata("", "", "", 0, 0, "", 0, 0, "", 0);

NetInfo netInfoFromJson(String str) => NetInfo.fromJson(json.decode(str));

String netInfoToJson(NetInfo data) => json.encode(data.toJson());

class NetInfo {
  String? ip;
  int? port;

  NetInfo({
    required this.ip,
    required this.port,
  });

  factory NetInfo.fromJson(Map<String, dynamic> json) => NetInfo(
        ip: json["Ip"],
        port: json["Port"],
      );

  Map<String, dynamic> toJson() => {
        "Ip": ip,
        "Port": port,
      };
}

NetInfo myNetInfo = NetInfo(ip: "", port: 0);

SerialInfo serialInfoFromJson(String str) =>
    SerialInfo.fromJson(json.decode(str));

String serialInfoToJson(SerialInfo data) => json.encode(data.toJson());

class SerialInfo {
  String devPath;
  int baud;
  int dataBits;
  int stopBits;
  int parity;

  SerialInfo({
    required this.devPath,
    required this.baud,
    required this.dataBits,
    required this.stopBits,
    required this.parity,
  });

  factory SerialInfo.fromJson(Map<String, dynamic> json) => SerialInfo(
        devPath: json["DevPath"],
        baud: json["Baud"],
        dataBits: json["DataBits"],
        stopBits: json["StopBits"],
        parity: json["Parity"],
      );

  Map<String, dynamic> toJson() => {
        "DevPath": devPath,
        "Baud": baud,
        "DataBits": dataBits,
        "StopBits": stopBits,
        "Parity": parity,
      };
}

//本机收到的网络秤的信息，删除只在这个里面进行，串口管理的秤不允许删除

List<NetScaleInfoLocal> myNetScaleList = [];
List<NetScaleInfoLocal> fourScaleList = [];

class NetScaleListMgr {
  static bool delScaleById(List<NetScaleInfoLocal> myNetScaleList, int id) {
    myNetScaleList.removeWhere((scale) => scale.scaleId == id);
    return myNetScaleList.every((scale) => scale.scaleId != id);
  }

  static void addScale(
      List<NetScaleInfoLocal> myNetScaleList, NetScaleInfoLocal netScale) {
    var existingScale = myNetScaleList
        .firstWhere((scale) => scale.scaleId == netScale.scaleId, orElse: () {
      NetScaleInfoLocal newScale = NetScaleInfoLocal(
          isOnline: false,
          scaleModel: "",
          scaleCat: 0,
          scaleSn: "",
          scaleId: -1,
          ip: "",
          port: 0,
          scaleName: "");
      return newScale;
    });
    if (existingScale.scaleId == -1) {
      myNetScaleList.add(netScale);
      return;
    }
    if (existingScale.scaleSn != netScale.scaleSn) {
      myNetScaleList.remove(existingScale);
      myNetScaleList.add(netScale);
    }
  }

  static void updateScale(
      List<NetScaleInfoLocal> myNetScaleList, NetScaleInfoLocal netScale) {
    var existingScale = myNetScaleList
        .firstWhere((scale) => scale.scaleId == netScale.scaleId, orElse: () {
      NetScaleInfoLocal newScale = NetScaleInfoLocal(
          isOnline: false,
          scaleModel: "",
          scaleCat: 0,
          scaleSn: "",
          scaleId: -1,
          ip: "",
          port: 0,
          scaleName: "");
      return newScale;
    });
    if (existingScale.scaleId != -1) {
      myNetScaleList.remove(existingScale);
      myNetScaleList.add(netScale);
    }
  }

  static NetScaleInfoLocal findScaleInfo(
      List<NetScaleInfoLocal> myNetScaleList, int scaleId) {
    NetScaleInfoLocal newScale = NetScaleInfoLocal();
    var existingScale = myNetScaleList
        .firstWhere((scale) => scale.scaleId == scaleId, orElse: () {
      return newScale;
    });
    return existingScale;
  }
}

class NetScaleInfoLocal {
  bool? isOnline;
  String? scaleModel;
  String? innerModel;
  int? scaleCat;
  String? scaleSn;
  int? scaleId;
  int? tMedia;
  bool? isDefault;
  String? ip;
  int? port;
  String? scaleName;

  NetScaleInfoLocal({
    this.isOnline,
    this.scaleModel,
    this.innerModel,
    this.scaleCat,
    this.scaleSn,
    this.scaleId,
    this.tMedia,
    this.isDefault,
    this.ip,
    this.port,
    this.scaleName,
  });
}

class DelScaleInfo {
  int? scaleId;

  DelScaleInfo({
    this.scaleId,
  });

  factory DelScaleInfo.fromJson(Map<String, dynamic> json) => DelScaleInfo(
        scaleId: json["ScaleId"],
      );

  Map<String, dynamic> toJson() => {
        "ScaleId": scaleId,
      };
}

getDefScaleInfo(int defId) {
  if (defId == 1) {}
}

class ScaleIsOnline {
  int? scaleId;
  bool? isOnline;
  String? modelName;
  String? sn;

  ScaleIsOnline({
    this.scaleId,
    this.isOnline,
    this.modelName,
    this.sn,
  });

  factory ScaleIsOnline.fromJson(Map<String, dynamic> json) => ScaleIsOnline(
        scaleId: json["scaleId"],
        isOnline: json["isOnline"],
        modelName: json["modelName"],
        sn: json["sn"],
      );

  Map<String, dynamic> toJson() => {
        "scaleId": scaleId,
        "isOnline": isOnline,
        "modelName": modelName,
        "sn": sn,
      };
}
