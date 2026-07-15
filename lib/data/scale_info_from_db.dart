//解析来自数据库的秤列表

import 'dart:convert';

// 统一的秤接口
abstract class Scale {
  bool get isOnline;
  set isOnline(bool value); // 允许设置
  String get scaleModel;
  set scaleModel(String value); // 允许设置
  String? get innerModel;
  set innerModel(String? value); // 允许设置
  int get scaleCat;
  String get scaleSn;
  set scaleSn(String value); // 允许设置
  int get scaleId;
  int get tMedia;
  bool get isDefault;
  String get scaleName;
  set scaleName(String value); // 允许设置
  bool get sendService;
  int? get modbusId;
  set modbusId(int? value);
  String? get protocolName;
  set protocolName(String? value);

  // 媒体配置接口
  MediaConfig get mediaConfig;
}

// 媒体配置接口
abstract class MediaConfig {
  int get type;
}

// 串口媒体配置
class SerialMediaConfig implements MediaConfig {
  @override
  final int type = 0; // 串口类型

  final String devPath;
  final int baudRate;
  final int dataBits;
  final int stopBits;
  final int parity;

  SerialMediaConfig({
    required this.devPath,
    required this.baudRate,
    required this.dataBits,
    required this.stopBits,
    required this.parity,
  });

  factory SerialMediaConfig.fromJson(Map<String, dynamic> json) {
    return SerialMediaConfig(
      devPath: json['DevPath'] as String,
      baudRate: json['Baud'] as int,
      dataBits: json['DataBits'] as int,
      stopBits: json['StopBits'] as int,
      parity: json['Parity'] as int,
    );
  }
}

// 网口媒体配置
class NetworkMediaConfig implements MediaConfig {
  @override
  final int type = 1; // 网口类型

  final String ipAddress;
  final int port;

  NetworkMediaConfig({
    required this.ipAddress,
    required this.port,
  });

  factory NetworkMediaConfig.fromJson(Map<String, dynamic> json) {
    return NetworkMediaConfig(
      ipAddress: json['Ip'] as String,
      port: json['Port'] as int,
    );
  }
}

//蓝牙媒体配置
class BluetoothMediaConfig implements MediaConfig {
  @override
  final int type = 2; // 蓝牙类型

  final String mac;
  final String name;

  BluetoothMediaConfig({
    required this.mac,
    required this.name,
  });

  factory BluetoothMediaConfig.fromJson(Map<String, dynamic> json) {
    return BluetoothMediaConfig(
      mac: json['Mac'] as String,
      name: json['Name'] as String,
    );
  }
}

// 统一的秤实现类
class UnifiedScale implements Scale {
  late bool _isOnline;

  late String _scaleModel;
  late String _scaleSn;
  late String _scaleName;

  @override
  bool get isOnline => _isOnline;

  @override
  set isOnline(bool value) {
    _isOnline = value;
  }

  @override
  String get scaleModel => _scaleModel;

  @override
  set scaleModel(String value) {
    _scaleModel = value;
  }

  String? _innerModel;

  @override
  String? get innerModel => _innerModel;

  @override
  set innerModel(String? value) {
    _innerModel = value;
  }

  @override
  String get scaleSn => _scaleSn;

  @override
  set scaleSn(String value) {
    _scaleSn = value;
  }

  @override
  final int scaleCat;

  @override
  final int scaleId;

  @override
  final int tMedia;

  @override
  final bool isDefault;

  @override
  String get scaleName => _scaleName;

  @override
  set scaleName(String value) {
    _scaleName = value;
  }

  @override
  final bool sendService;

  int? _modbusId;

  @override
  int? get modbusId => _modbusId;

  @override
  set modbusId(int? value) {
    _modbusId = value;
  }

  String? _protocolName;

  @override
  String? get protocolName => _protocolName;

  @override
  set protocolName(String? value) {
    _protocolName = value;
  }

  @override
  final MediaConfig mediaConfig;

  UnifiedScale({
    required bool isOnline, // 修改为接收 isOnline 参数
    required String scaleModel,
    String? innerModel,
    required this.scaleCat,
    required String scaleSn,
    required this.scaleId,
    required this.tMedia,
    required this.isDefault,
    required String scaleName,
    required this.sendService,
    required this.mediaConfig,
    int? modbusId,
    String? protocolName,
  }) {
    _isOnline = isOnline; // 初始化 _isOnline
    _scaleModel = scaleModel;
    _innerModel = innerModel;
    _scaleSn = scaleSn;
    _scaleName = scaleName;
    _modbusId = modbusId;
    _protocolName = protocolName;
  }

  factory UnifiedScale.fromJson(Map<String, dynamic> json) {
    final mediaConf = json['MediaConf'] as Map<String, dynamic>;
    final mediaType = mediaConf['Type'] as int;
    final mediaInfo = jsonDecode(mediaConf['MediaInfoJson'] as String)
        as Map<String, dynamic>;

    MediaConfig config;
    if (mediaType == 0) {
      config = SerialMediaConfig.fromJson(mediaInfo);
    } else if (mediaType == 1) {
      config = NetworkMediaConfig.fromJson(mediaInfo);
    } else {
      config = BluetoothMediaConfig.fromJson(mediaInfo);
    }

    return UnifiedScale(
      isOnline: json['IsOnline'] as bool,
      scaleModel: json['ScaleModel'] as String,
      innerModel: json['InnerModel'] as String?,
      scaleCat: json['ScaleCat'] as int,
      scaleSn: json['ScaleSn'] as String,
      scaleId: json['ScaleId'] as int,
      tMedia: json['TMedia'] as int,
      isDefault: json['IsDefault'] as bool,
      scaleName: json['ScaleName'] as String,
      sendService: json['SendService'] as bool,
      mediaConfig: config,
      modbusId: json['ModbusId'] as int?,
      protocolName: json['ProtocolName'] as String?,
    );
  }
}

// 解析工具类
class ScaleParser {
  static List<Scale> parseScales(String jsonData) {
    final List<dynamic> jsonList = jsonDecode(jsonData);
    return jsonList
        .map((json) => UnifiedScale.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

List<Scale> myAllScalesList = []; // 用于存储所有秤的列表，包括串口和网口

final int comScaleType = 0; // 串口秤
final int netScaleType = 1; // 网口秤
final int btScaleType = 2; // 蓝牙秤

// // 使用示例
// void main() {
//   const jsonData = '''
//   [
//     {"IsOnline":true,"ScaleModel":"HWS","ScaleCat":5,"ScaleSn":"100080008008","ScaleId":1,"TMedia":0,"MediaConf":{"Type":0,"MediaInfoJson":"{\\"DevPath\\":\\"COM12\\",\\"Baud\\":115200,\\"DataBits\\":8,\\"StopBits\\":0,\\"Parity\\":0}"},"IsDefault":true,"ScaleName":"ComScale","SendService":false},
//     {"IsOnline":false,"ScaleModel":"HWS","ScaleCat":5,"ScaleSn":"100080008008","ScaleId":16,"TMedia":1,"MediaConf":{"Type":1,"MediaInfoJson":"{\\"Ip\\":\\"10.5.52.62\\",\\"Port\\":10022}"},"IsDefault":true,"ScaleName":"Scale16","SendService":false}
//   ]
//   ''';
// final scales = ScaleParser.parseScales(jsonData);
  

//   // 统一处理所有秤，无需关心具体类型
//   for (final scale in scales) {
//     print('${scale.scaleName} (ID: ${scale.scaleId}) - ${scale.isOnline ? '在线' : '离线'}');
    
//     // 根据媒体类型访问特定属性
//     if (scale.mediaConfig is SerialMediaConfig) {
//       final serialConfig = scale.mediaConfig as SerialMediaConfig;
//       print('  串口配置: ${serialConfig.devPath}, ${serialConfig.baudRate}bps');
//     } else if (scale.mediaConfig is NetworkMediaConfig) {
//       final networkConfig = scale.mediaConfig as NetworkMediaConfig;
//       print('  网口配置: ${networkConfig.ipAddress}:${networkConfig.port}');
//     }
//   }
// }