class ModbusServiceInfo {
  int? id;
  int? targetModbusId;
  String? protocol; // "RTU" or "TCP"
  String? port; // "COM2" or "502"
  int? baudRate; // 9600

  ModbusServiceInfo({
    this.id,
    this.targetModbusId,
    this.protocol,
    this.port,
    this.baudRate,
  });

  ModbusServiceInfo.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    targetModbusId = json['TargetModbusId'];
    protocol = json['Protocol'];
    port = json['Port'];
    baudRate = json['BaudRate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['TargetModbusId'] = targetModbusId;
    data['Protocol'] = protocol;
    data['Port'] = port;
    data['BaudRate'] = baudRate;
    return data;
  }
}
