import 'dart:convert';

class ScaleTotalInfo {
  List<ScaleDataInfo>? scaleDataList;

  ScaleTotalInfo({this.scaleDataList});

  factory ScaleTotalInfo.fromJson(List<dynamic> parsedJson) {
    List<ScaleDataInfo> scaleDataList = <ScaleDataInfo>[];
    scaleDataList = parsedJson.map((i) => ScaleDataInfo.fromJson(i)).toList();

    return ScaleTotalInfo(scaleDataList: scaleDataList);
  }
}

ScaleTotalInfo myScaleTotalInfo = ScaleTotalInfo(scaleDataList: []);

class ScaleDataInfo {
  bool? isOnline;
  String? scaleModel;
  int? scaleCat;
  String? scaleSn;
  int? scaleId;
  int? tMedia;
  MediaInfo? mediaInfo;
  bool? isDefault;
  String? scaleName;
  int? modbusId;

  ScaleDataInfo(
      {this.isOnline,
      this.scaleModel,
      this.scaleSn,
      this.scaleId,
      this.tMedia,
      this.mediaInfo,
      this.scaleCat,
      this.isDefault,
      this.scaleName,
      this.modbusId});

  factory ScaleDataInfo.fromJson(Map<String, dynamic> json) {
    return ScaleDataInfo(
      isOnline: json['IsOnline'],
      scaleModel: json['ScaleModel'],
      scaleSn: json['ScaleSn'],
      scaleId: json['ScaleId'],
      tMedia: json['TMedia'],
      mediaInfo: json['MediaConf'] != null
          ? MediaInfo.fromJson(json['MediaConf'])
          : null,
      scaleCat: json['ScaleCat'],
      isDefault: json['IsDefault'],
      scaleName: json['ScaleName'],
      modbusId: json['ModbusId'],
    );
  }
}

class MediaInfo {
  int? type;
  String? mediaInfoJson;

  MediaInfo({this.type, this.mediaInfoJson});

  factory MediaInfo.fromJson(Map<String, dynamic> json) {
    return MediaInfo(
      type: json['Type'],
      mediaInfoJson: json['MediaInfoJson'],
    );
  }
}

class CurrentPort {
  String? devPath;
  int? baud;
  int? dataBits;
  int? stopBits;
  int? parity;

  CurrentPort(
      {this.devPath, this.baud, this.dataBits, this.stopBits, this.parity});

  CurrentPort.fromJson(Map<String, dynamic> json) {
    devPath = json['DevPath'];
    baud = json['Baud'];
    dataBits = json['DataBits'];
    stopBits = json['StopBits'];
    parity = json['Parity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DevPath'] = devPath;
    data['Baud'] = baud;
    data['DataBits'] = dataBits;
    data['StopBits'] = stopBits;
    data['Parity'] = parity;
    return data;
  }
}

CurrentPort myCurrentPort = CurrentPort();
CurrentPort tempCurrentPort = CurrentPort();

List<SrvScaleInfo> srvScaleListFromJson(String str) => List<SrvScaleInfo>.from(
    json.decode(str).map((x) => SrvScaleInfo.fromJson(x)));

class SrvScaleInfo {
  int scaleId;
  int srvId;
  bool isUsed;

  SrvScaleInfo({
    required this.scaleId,
    required this.srvId,
    required this.isUsed,
  });

  factory SrvScaleInfo.fromJson(Map<String, dynamic> json) => SrvScaleInfo(
        scaleId: json["ScaleId"],
        srvId: json["SrvId"],
        isUsed: json["IsUsed"],
      );

  Map<String, dynamic> toJson() => {
        "ScaleId": scaleId,
        "SrvId": srvId,
        "IsUsed": isUsed,
      };
}

List<SrvScaleInfo> mySrvScaleList = [];
