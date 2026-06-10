class AddNetScale {
  int? scaleId;
  String? scaleModel;
  MediaConf? mediaConf;
  int? modbusId;

  AddNetScale({this.scaleId, this.scaleModel, this.mediaConf, this.modbusId});

  AddNetScale.fromJson(Map<String, dynamic> json) {
    scaleId = json['ScaleId'];
    scaleModel = json['ScaleModel'];
    mediaConf = json['MediaConf'];
    modbusId = json['ModbusId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleId'] = scaleId;
    data['ScaleModel'] = scaleModel;
    data['MediaConf'] = mediaConf;
    data['ModbusId'] = modbusId;
    return data;
  }
}

AddNetScale myAddNetScale = AddNetScale(scaleModel: 'TMax');
AddNetScale myModifyScale = AddNetScale(scaleModel: 'TMax');

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

  ModifyNetScale(
      {this.scaleId, this.scaleModel, this.scaleName, this.mediaConf, this.modbusId});

  ModifyNetScale.fromJson(Map<String, dynamic> json) {
    scaleId = json['ScaleId'];
    scaleModel = json['ScaleModel'];
    scaleName = json['ScaleName'];
    mediaConf = json['MediaConf'];
    modbusId = json['ModbusId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleId'] = scaleId;
    data['ScaleModel'] = scaleModel;
    data['ScaleName'] = scaleName;
    data['MediaConf'] = mediaConf;
    data['ModbusId'] = modbusId;
    return data;
  }
}

ModifyNetScale myModifyNetScale = ModifyNetScale(scaleModel: 'TMax');

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
