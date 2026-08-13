class AddNetScale {
  int? scaleId;
  String? scaleModel;
  MediaConf? mediaConf;
  int? modbusId;
  String? protocolName;

  AddNetScale({this.scaleId, this.scaleModel, this.mediaConf, this.modbusId, this.protocolName});

  AddNetScale.fromJson(Map<String, dynamic> json) {
    scaleId = json['ScaleId'];
    scaleModel = json['ScaleModel'];
    mediaConf = json['MediaConf'];
    modbusId = json['ModbusId'];
    protocolName = json['ProtocolName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleId'] = scaleId;
    data['ScaleModel'] = scaleModel;
    data['MediaConf'] = mediaConf;
    data['ModbusId'] = modbusId;
    data['ProtocolName'] = protocolName;
    return data;
  }
}

AddNetScale myAddNetScale = AddNetScale(scaleModel: '');
AddNetScale myModifyScale = AddNetScale(scaleModel: '');

class MediaConf {
  int? type;
  String? mediaInfoJson;

  MediaConf({this.type, this.mediaInfoJson});

  MediaConf.fromJson(Map<String, dynamic> json) {
    type = json['Type'];
    mediaInfoJson = json['MediaInfoJson'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Type'] = type;
    data['MediaInfoJson'] = mediaInfoJson;
    return data;
  }
}

MediaConf myMediaConf = MediaConf();

class ModifyNetScale {
  int? scaleId;
  String? scaleModel;
  String? scaleName;
  MediaConf? mediaConf;
  int? modbusId;
  String? protocolName;

  ModifyNetScale(
      {this.scaleId, this.scaleModel, this.scaleName, this.mediaConf, this.modbusId, this.protocolName});

  ModifyNetScale.fromJson(Map<String, dynamic> json) {
    scaleId = json['ScaleId'];
    scaleModel = json['ScaleModel'];
    scaleName = json['ScaleName'];
    mediaConf = json['MediaConf'];
    modbusId = json['ModbusId'];
    protocolName = json['ProtocolName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleId'] = scaleId;
    data['ScaleModel'] = scaleModel;
    data['ScaleName'] = scaleName;
    data['MediaConf'] = mediaConf;
    data['ModbusId'] = modbusId;
    data['ProtocolName'] = protocolName;
    return data;
  }
}

ModifyNetScale myModifyNetScale = ModifyNetScale(scaleModel: '');

class ModifyScaleName {
  int? scaleId;
  String? scaleName;

  ModifyScaleName({this.scaleId, this.scaleName});

  ModifyScaleName.fromJson(Map<String, dynamic> json) {
    scaleId = json['ScaleId'];
    scaleName = json['ScaleName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleId'] = scaleId;
    data['ScaleName'] = scaleName;
    return data;
  }
}

ModifyScaleName myModifyScaleName = ModifyScaleName();
