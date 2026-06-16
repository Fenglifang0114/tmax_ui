import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/btinfodata.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/license_data.dart';
import 'package:t_max/data/modbus_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/scalecmd_data.dart';
import 'package:t_max/data/writelog.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/pages/btlist.dart';
import 'package:t_max/pages/gif.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/no_device_widget.dart';
import '../data/cominfoslist_data.dart';
import '../data/device_data.dart';
import '../data/downloadresponse.dart';
import '../data/ipinfodata.dart';
import '../data/language.dart';
import '../data/manager_scale_channel.dart';
import '../data/modifyresult_data.dart';
import '../data/modifyscale_data.dart';
import '../data/scale_info_from_scale.dart';
import '../data/scalelist_data.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';
import '../widget/page_head.dart';
import 'multi_scale_management_dialog.dart';
part 'multi_scale_management_part_list.dart';
part 'multi_scale_management_part_add.dart';
part 'multi_scale_management_part_edit.dart';
part 'multi_scale_management_part_info.dart';
part 'multi_scale_management_part_modbus.dart';

class MultiScaleManagement extends StatefulWidget {
  const MultiScaleManagement({super.key});

  @override
  State<MultiScaleManagement> createState() => MultiScaleManagementState();
}

class MultiScaleManagementState extends State<MultiScaleManagement> {
  List<int> wifiRssiList = [];
  List<String> bssidList = [];

  TextEditingController scaleModelCtl = TextEditingController(text: '');
  TextEditingController scaleNameCtl = TextEditingController(text: '');
  TextEditingController snCtl = TextEditingController(text: '');
  TextEditingController portCtl = TextEditingController(text: '');
  TextEditingController ipCtl = TextEditingController(text: '');
  TextEditingController dataBitCtl = TextEditingController(text: '8');
  TextEditingController stopBitCtl = TextEditingController(text: '1');
  TextEditingController comPortCtl = TextEditingController(text: '');
  TextEditingController baudRateCtl = TextEditingController(text: '115200');
  TextEditingController protocolCtl = TextEditingController(text: 'None');

  TextEditingController macCtl = TextEditingController(text: '');
  TextEditingController btNameCtl = TextEditingController(text: '');
  TextEditingController modbusIdCtl = TextEditingController(text: '1');

  // Modbus Gateway Settings
  String modbusProtocol = "Modbus TCP";
  TextEditingController modbusTcpPortCtl = TextEditingController(text: "502");
  TextEditingController modbusComPortCtl = TextEditingController();
  TextEditingController modbusBaudRateCtl = TextEditingController(text: "9600");
  TextEditingController modbusDataBitCtl = TextEditingController(text: "8");
  TextEditingController modbusStopBitCtl = TextEditingController(text: "1");
  TextEditingController modbusParityCtl = TextEditingController(text: "None");
  List<String> modbusProtocolList = ["Modbus TCP", "Modbus RTU"];
  List<ModbusServiceInfo> modbusServicesList = [];

  dynamic _eventbusModbus1;
  dynamic _eventbusModbus2;
  dynamic _eventbusModbus3;
  dynamic _eventbusModbus4;

  int selScaleId = -1;

  bool isAddScale = false;
  String addScaleType = '';
  bool isTesting = false;
  bool isRename = false;
  bool _isValidIP = false;
  bool _isModifyName = false;
  bool isEditing = false;
  bool _isNetPort = false;
  bool isDel = false; //是否执行删除
  bool isDC500 = false; //是否是旧的版本的秤
  bool isAddNewScale = false;

  // Modbus UI States
  bool isAddModbus = false;
  bool isEditModbus = false;
  int? currentEditModbusId;

  bool editWifiInfo = false; //是否是修改wifi信息
  bool isBtSearching = false; //是否正在搜索蓝牙设备
  bool isBtSearched = false; //是否搜索完蓝牙设备

  List<BtInfo> btInfoList = [];
  BtInfo selectBtInfo = BtInfo();

  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;
  dynamic _eventbus6;
  dynamic _eventbus7;
  dynamic _eventbus8;
  dynamic _eventbus9;
  dynamic _eventbus10;
  dynamic _eventbus11;
  bool isModifyingSerialPort = false; // 是否正在修改串口

  Timer? checkIsOnlineTimer;
  List<String> comLists = [];
  List<String> usingComLists = [];

  List<String> baudRateList = [
    '115200',
    '57600',
    '38400',
    '19200',
    '14400',
    '9600',
    '4800',
  ];
  List<String> scaleModelList = ['TMax'];
  String scaleModel = myModifyScale.scaleModel.toString();
  List<String> dataBitsList = ['8']; //去掉5,6,7,8
  List<String> stopBitsList = ['1']; //, '1.5', '2'
  List<String> checkBitsList = ['None']; //, 'Odd', 'Even'
  //'Xon/Xoff', 'None', 'Rts/Cts', 'Dsr/Dtr'
  String dialogtype = "com";
  String serialPortConnect = " ";
  bool isComSetting = false;
  bool isClosePort = true;

  RegExp ipRegex = RegExp(
    r'^((\d{1,3}\.){3}\d{1,3})$',
    multiLine: false,
    caseSensitive: false,
  );

  bool _isValidIpAddress(bool tempValid, String value) {
    if (tempValid) {
      List<int?> parts = value.split('.').map(int.tryParse).toList();
      if (parts.any((part) => part == null || part > 255)) {
        tempValid = false;
      }
    }
    return tempValid;
  }

  String _getLocalizedError(String errStr) {
    String lowerErr = errStr.toLowerCase();
    if (lowerErr.contains("access is denied") || lowerErr.contains("occupied")) {
      return "${localizedStrings.gTipOpenPortFailed}: ${localizedStrings.gTipPortInUsed} ($errStr)";
    } else if (lowerErr.contains("open") || lowerErr.contains("failed") || lowerErr.contains("timeout")) {
      return "${localizedStrings.gTipOpenPortFailed} ($errStr)";
    }
    return errStr;
  }

  @override
  void initState() {
    super.initState();
    initScaleList();
    initEventBus();
    PublicFunctions.getPortList();
    PublicFunctions.getScaleList();
    PublicFunctions.getModbusServices();

    checkPortList();

    scaleNameCtl.addListener(_onScaleNameChanged);
    ipCtl.addListener(_onIpChanged);
    portCtl.addListener(_onPortChanged);
  }

  void initScaleList() {}

  void initEventBus() {
    _eventbus1 = eventBus.on<EventRespDelScale>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        setState(() {
          isDel = false;
          if (dataStr.isNotEmpty) {
            if (dataStr.contains('ok')) {
              selScaleId = -1;
              showTipInfo(localizedStrings.fSuccessMsg, context);
              PublicFunctions.getScaleList();
              return;
            }
            if (dataStr.contains('fail') && dataStr.contains('formula')) {
              showTipInfo(localizedStrings.fRawInUseDeleteErrorMsg, context);
              return;
            }

            showTipInfo(dataStr, context);
          }
        });
      }
    });

    _eventbus2 = eventBus.on<EventRespAddScale>().listen((event) {
      if (mounted) {
        setState(() {
          isAddScale = false;
          String dataStr = event.obj;
          if (dataStr.isNotEmpty) {
            if (dataStr.contains('scale list')) {
              if (isAddNewScale) {
                isAddNewScale = false;
                for (Scale tempScale in myAllScalesList) {
                  //找出scaleId最大的
                  if (tempScale.scaleId > selScaleId) {
                    selScaleId = tempScale.scaleId;
                  }
                }
              }
              return;
            }
            dataStr.contains('ok')
                ? showTipInfo(localizedStrings.fSuccessMsg, context)
                : showTipInfo(dataStr, context);
          }
        });
      }
    });

    _eventbus3 = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) {
        myOnlineInfo = event.obj;
        myFactoryInfoFromScale = myOnlineInfo.factInfo!;
        setState(() {
          if (myFactoryInfoFromScale.modelName != '') {
            setScaleStatus(myOnlineInfo.scaleId!, true);
            if (isTesting) {
              showTipInfo(localizedStrings.fSuccessMsg, context);
            }
            if (myFactoryInfoFromScale.modelName == "S15") {
              PublicFunctions.getSerialPort(myOnlineInfo.scaleId!);
            }
          } else {
            setScaleStatus(myOnlineInfo.scaleId!, false);
            if (isTesting) {
              showTipInfo(localizedStrings.gTipConnectFail, context);
            }
          }
          if (isTesting) {
            isTesting = false;
          }
        });
      }
    });
    _eventbus4 = eventBus.on<EventRespScaleOnline>().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });

    _eventbus5 = eventBus.on<EventSerialPortResponse>().listen((event) {
      if (mounted) {
        setState(() {
          myRespDataFromScale = event.obj;

          if (myComScaleInfo.isOnline) {
            myComScaleInfo.isOnline = false;
            showTipInfo(localizedStrings.gTipSerialPortDisconnected, context);
          }
          myComScaleInfo.isOnline = false;
          myComScaleSn.modelName = '';
          myComScaleSn.scaleSn = '';
          myComScaleInfo.isOnline = false;
        });
      }
    });

    _eventbus6 = eventBus.on<EventRespScaleModify>().listen((event) {
      if (mounted) {
        myModifyAck = event.obj;
        isComSetting = false;
        PublicFunctions.getScaleList();
        PublicFunctions.checkSerialPort(selScaleId);
        isTesting = true;
      }
    });

    _eventbus7 = eventBus.on<EventComInfoList>().listen((event) {
      if (mounted) {
        setState(() {
          myComInfoList = event.obj;
          checkPortList();
        });
      }
    });

    _eventbus8 = eventBus.on<EventDeviceName>().listen((event) {
      if (mounted) {
        setState(() {
          myDevicedata = event.obj;
        });
      }
    });
    _eventbus9 = eventBus.on<EventCurrentPort>().listen((event) {
      if (mounted) {
        setState(() {
          myCurrentPort = event.obj;
        });
      }
    });

    _eventbus10 = eventBus.on<EventBtInfoList>().listen((event) {
      if (mounted) {
        var data = event.obj;

        setState(() {
          if (data.isNotEmpty && !data.contains('fail')) {
            btInfoList = btInfoFromJson(data);
            // print(btInfoList);

            //按信号强度排序
            btInfoList.sort((a, b) {
              // 处理null值：null值视为最弱信号
              int rssiA = a.rssi ?? -999;
              int rssiB = b.rssi ?? -999;
              // 降序排列：b.compareTo(a) 或 b.rssi - a.rssi
              return rssiB.compareTo(rssiA);
            });
          }
          isBtSearching = false;
          isBtSearched = true;
        });
      }
    });

    eventBus.on<EventRevGetSerialPort>().listen((event) {
      if (mounted) {
        var obj = event.obj;
        if (obj.msgBody != null && obj.msgBody.toString().isNotEmpty && obj.msgBody.toString() != "fail") {
          setState(() {
            String msg = obj.msgBody.toString();
            List<String> parts = msg.split(',');
            if (parts.isNotEmpty) {
              comPortCtl.text = parts[0];
            }
            if (parts.length > 1) {
              baudRateCtl.text = parts[1];
            }
            
            if (comPortCtl.text.isNotEmpty && !usingComLists.contains(comPortCtl.text)) {
              usingComLists.add(comPortCtl.text);
            }
          });
        }
      }
    });

    _eventbus11 = eventBus.on<EventRevSetSerialPort>().listen((event) {
      if (mounted) {
        var obj = event.obj;
        if (isModifyingSerialPort) {
          setState(() {
            isModifyingSerialPort = false;
            editWifiInfo = false;
            if (obj.msgBody != null && obj.msgBody.toString() == "ok") {
              showTipInfo(localizedStrings.fSuccessMsg, context);
            } else {
              showTipInfo(localizedStrings.gTipConnectFail, context);
            }
          });
        }
      }
    });

    _eventbusModbus1 = eventBus.on<EventRespGetModbusServices>().listen((event) {
      if (mounted) {
        setState(() {
          try {
            var dataList = json.decode(event.obj) as List;
            modbusServicesList = dataList.map((e) => ModbusServiceInfo.fromJson(e)).toList();
          } catch (e) {
            modbusServicesList = [];
          }
        });
      }
    });

    _eventbusModbus2 = eventBus.on<EventRespAddModbusService>().listen((event) {
      if (mounted) {
        if (event.obj.toString().contains("ok")) {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          PublicFunctions.getModbusServices();
        } else {
          showTipInfo(_getLocalizedError(event.obj.toString()), context);
        }
      }
    });

    _eventbusModbus3 = eventBus.on<EventRespEditModbusService>().listen((event) {
      if (mounted) {
        if (event.obj.toString().contains("ok")) {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          PublicFunctions.getModbusServices();
        } else {
          showTipInfo(_getLocalizedError(event.obj.toString()), context);
        }
      }
    });

    _eventbusModbus4 = eventBus.on<EventRespDelModbusService>().listen((event) {
      if (mounted) {
        if (event.obj.toString().contains("ok")) {
          showTipInfo(localizedStrings.fSuccessMsg, context);
          PublicFunctions.getModbusServices();
        } else {
          showTipInfo(_getLocalizedError(event.obj.toString()), context);
        }
      }
    });
  }

  void _onPortChanged() {
    if (portCtl.text.isEmpty) {
      if (_isNetPort) {
        setState(() {
          _isNetPort = false;
        });
      }
      return;
    }

    if (_isNetPort != true) {
      setState(() {
        _isNetPort = true;
      });
    }
  }

  void _onIpChanged() {
    if (ipCtl.text.isEmpty) {
      if (_isValidIP) {
        setState(() {
          _isValidIP = false;
        });
      }
      return;
    }
    bool isValid = validateIpFlag(ipCtl.text);
    if (isValid != _isValidIP) {
      setState(() {
        _isValidIP = isValid;
      });
    }
  }

  void _onScaleNameChanged() {
    if (scaleNameCtl.text.isNotEmpty) {
      bool isValid = isValidScaleName(scaleNameCtl.text);
      if (_isModifyName != isValid) {
        setState(() {
          _isModifyName = isValid;
        });
      }
    } else {
      if (_isModifyName) {
        setState(() {
          _isModifyName = false;
        });
      }
    }
  }

  void setScaleStatus(int scaleId, bool status) {
    for (int i = 0; i < myAllScalesList.length; i++) {
      if (scaleId == myAllScalesList[i].scaleId) {
        setState(() {
          myAllScalesList[i].isOnline = status;
        });
      }
    }
  }

  // void setNetScaleStatus(int scaleId, bool status) {
  //   for (int i = 0; i < scaleNetItems.length; i++) {
  //     if (scaleNetItems[i].scaleId == scaleId) {
  //       scaleNetItems[i].isOnline = status;
  //     }
  //   }
  // }

  @override
  void dispose() {
    _eventbus9?.cancel();
    _eventbus10?.cancel();
    _eventbus11?.cancel();
    _eventbusModbus1?.cancel();
    _eventbusModbus2?.cancel();
    _eventbusModbus3?.cancel();
    _eventbusModbus4?.cancel();
    checkIsOnlineTimer?.cancel();
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    _eventbus7.cancel();
    _eventbus8.cancel();
    _eventbus9.cancel();
    _eventbus6.cancel();
    _eventbus10.cancel();

    scaleNameCtl.dispose();
    ipCtl.dispose();
    portCtl.dispose();
    comPortCtl.dispose();
    baudRateCtl.dispose();
    protocolCtl.dispose();
    dataBitCtl.dispose();
    stopBitCtl.dispose();
    scaleModelCtl.dispose();
    snCtl.dispose();
    macCtl.dispose();
    btNameCtl.dispose();
    modbusIdCtl.dispose();
    modbusTcpPortCtl.dispose();
    modbusComPortCtl.dispose();
    modbusBaudRateCtl.dispose();
    modbusDataBitCtl.dispose();
    modbusStopBitCtl.dispose();
    modbusParityCtl.dispose();
    checkIsOnlineTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;
    tempCurrentPort = myCurrentPort;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            automaticallyImplyLeading: false,
            bottom: TabBar(
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
              tabs: [
                Tab(text: localizedStrings.menuMultiScaleManagement),
                Tab(text: localizedStrings.gModbusServiceManagement),
              ],
            ),
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(), // 禁用滑动切换，避免与内部滑动冲突
          children: [
            editWifiInfo
                ? showEditWifiInfo(maxWidth)
                : isAddScale && addScaleType != ""
                    ? showAddScaleInfo(maxWidth)
                    : showNormalScaleInfo(maxWidth),
            showModbusConfigInfo(maxWidth),
          ],
        ),
      ),
    );
  }

  int getScaleType() {
    //检查是不是串口的秤
    for (int i = 0; i < myAllScalesList.length; i++) {
      if (selScaleId == myAllScalesList[i].scaleId) {
        return myAllScalesList[i].tMedia;
      }
    }
    return 0;
  }

  void modifyComInfo() {
    //串口不能被其他秤使用

    CurrentPort tempPort = CurrentPort();
    tempPort.baud = int.tryParse(baudRateCtl.text);
    tempPort.dataBits = int.tryParse(dataBitCtl.text);
    tempPort.devPath = comPortCtl.text;
    tempPort.parity = 0;
    tempPort.stopBits = 0;

    String infoString = jsonEncode(tempPort);
    myMediaConf.mediaInfoJson = infoString;
    myMediaConf.type = myDevicedata.mediaType;
    myModifyScale.scaleId = selScaleId;
    myModifyScale.scaleModel = scaleModel;
    myModifyScale.mediaConf = myMediaConf;
    myModifyScale.modbusId = int.tryParse(modbusIdCtl.text) ?? 1;
    PublicFunctions.sendModifyInfo(jsonEncode(myModifyScale));
  }

  void checkPortList() {
    if (myComInfoList.msgBody!.isEmpty) {
      comLists = [];
      setState(() {});
    } else {
      comLists = myComInfoList.msgBody!.toList();
    }
  }

  bool validateIpFlag(String value) {
    bool isValid = false;

    setState(() {
      if (value != '') {
        isValid = ipRegex.hasMatch(value);
        isValid = _isValidIpAddress(isValid, value);
      } else {
        isValid = true;
      }
    });
    return isValid;
  }

  void editNetScale() {
    if (scaleModelCtl.text == "S15") {
      String sendStr = comPortCtl.text;
      if (baudRateCtl.text.isNotEmpty) {
        sendStr += ",${baudRateCtl.text}";
      }
      PublicFunctions.setSerialPort(selScaleId, sendStr);
      setState(() {
        isModifyingSerialPort = true;
      });
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && isModifyingSerialPort) {
          setState(() {
            isModifyingSerialPort = false;
            editWifiInfo = false;
          });
        }
      });
      return;
    }

    myNetInfo.ip = ipCtl.text;
    myNetInfo.port = int.tryParse(portCtl.text)!;

    //查找是否有一样的端口和IP
    for (var scale in myAllScalesList) {
      if (scale.scaleId == selScaleId) continue;
      if (scale.tMedia == netScaleType) {
        final netConfig = scale.mediaConfig as NetworkMediaConfig;
        if (netConfig.ipAddress == ipCtl.text &&
            netConfig.port.toString() == portCtl.text) {
          showTipInfo(localizedStrings.ipAddressAndPortIsAlreadyInUse, context);
          return;
        }
      }
    }

    // 校验 Modbus 站号唯一性
    if (modbusIdCtl.text.isEmpty) {
      showTipInfo(localizedStrings.gTipEmpty, context);
      return;
    }
    int currentModbusId = int.tryParse(modbusIdCtl.text) ?? 1;
    for (var scale in myAllScalesList) {
      if (scale.scaleId == selScaleId) continue;
      if (scale.modbusId == currentModbusId) {
        showTipInfo("Modbus 站号 [$currentModbusId] 已被占用", context);
        return;
      }
    }

    myAddNetScale.modbusId = currentModbusId;
    String netInfoStr = jsonEncode(myNetInfo);
    myMediaConf.mediaInfoJson = netInfoStr;
    myMediaConf.type = 1;
    myAddNetScale.scaleId = selScaleId;
    myAddNetScale.scaleModel = scaleModelCtl.text;
    if (myAddNetScale.scaleModel == null || myAddNetScale.scaleModel!.isEmpty) {
      myAddNetScale.scaleModel = 'TMax';
    }
    myAddNetScale.mediaConf = myMediaConf;
    PublicFunctions.sendModifyInfo(jsonEncode(myAddNetScale));
    editWifiInfo = false;
  }

  void addNetScale() {
    int currentModbusId = int.tryParse(modbusIdCtl.text) ?? 1;
    myNetInfo.ip = ipCtl.text;
    myNetInfo.port = int.tryParse(portCtl.text)!;
    String netInfoStr = jsonEncode(myNetInfo);
    myMediaConf.mediaInfoJson = netInfoStr;
    myMediaConf.type = 1;
    myAddNetScale.scaleId = 10;
    myAddNetScale.scaleModel = 'TMax';
    myAddNetScale.mediaConf = myMediaConf;
    myAddNetScale.modbusId = currentModbusId;
    PublicFunctions.sendAddScale(jsonEncode(myAddNetScale));
    isAddNewScale = true;
  }

  void addComScale() {
    CurrentPort tempPort = CurrentPort();
    tempPort.baud = int.tryParse(baudRateCtl.text);
    tempPort.dataBits = int.tryParse(dataBitCtl.text);
    tempPort.devPath = comPortCtl.text;
    tempPort.parity = 0;
    tempPort.stopBits = 0;
    String infoString = jsonEncode(tempPort);
    AddNetScale addNetScale = AddNetScale(scaleModel: 'TMax');
    myMediaConf.mediaInfoJson = infoString;
    myMediaConf.type = 0;
    addNetScale.scaleId = 10;
    addNetScale.scaleModel = 'TMax';
    if (isDC500) {
      addNetScale.scaleModel = 'DC500';
    }
    addNetScale.mediaConf = myMediaConf;
    addNetScale.modbusId = int.tryParse(modbusIdCtl.text) ?? 1;
    PublicFunctions.sendAddScale(jsonEncode(addNetScale));
    isDC500 = false;
    isAddNewScale = true;
  }

  void addBtScale() {
    if (selectBtInfo.mac == null || selectBtInfo.mac == "") {
      return;
    }

    macCtl.text = selectBtInfo.mac ?? "";
    btNameCtl.text = selectBtInfo.name ?? "";

    myBluetoothInfo.mac = selectBtInfo.mac ?? "";
    myBluetoothInfo.name = selectBtInfo.name ?? "";
    String btInfoStr = blueToothInfoToJson(myBluetoothInfo);
    myMediaConf.mediaInfoJson = btInfoStr;
    myMediaConf.type = 2;
    myAddNetScale.scaleId = 10;
    myAddNetScale.scaleModel = 'TMax';
    myAddNetScale.mediaConf = myMediaConf;
    myAddNetScale.modbusId = int.tryParse(modbusIdCtl.text) ?? 1;
    PublicFunctions.sendAddScale(jsonEncode(myAddNetScale));
    isAddNewScale = true;
  }

  bool isValidScaleName(String name) {
    for (Scale tempScale in myAllScalesList) {
      if (tempScale.scaleName == scaleNameCtl.text) {
        return false;
      }
    }
    return true;
  }

  bool checkModbusIdUnique(int modbusId, int currentScaleId) {
    for (var scale in myAllScalesList) {
      if (scale.scaleId != currentScaleId && scale.modbusId == modbusId) {
        return false;
      }
    }
    return true;
  }

  void modifyScaleName() {
    myModifyScaleName.scaleId = selScaleId;
    myModifyScaleName.scaleName = scaleNameCtl.text;
    PublicFunctions.sendModifyScaleName(jsonEncode(myModifyScaleName));
    changeScaleName(myModifyScaleName.scaleId!, myModifyScaleName.scaleName!);
    setState(() {
      isRename = false;
    });
  }

  void changeScaleName(int scaleId, String scaleName) {
    for (var scale in myAllScalesList) {
      if (scale.scaleId == scaleId) {
        scale.scaleName = scaleName;
        break;
      }
    }
  }

  void delScale() {
    Scale? delScaleInfo;
    for (var scale in myAllScalesList) {
      if (scale.scaleId == selScaleId) {
        delScaleInfo = scale;
        break;
      }
    }

    if (delScaleInfo!.mediaConfig.type == btScaleType) {
      PublicFunctions.getBuildInfo(selScaleId);
      Future.delayed(const Duration(seconds: 3), () {
        DelScaleInfo delScale = DelScaleInfo();
        delScale.scaleId = selScaleId;
        String delStr = jsonEncode(delScale);
        PublicFunctions.sendDelScale(delStr);
      });
    } else {
      DelScaleInfo delScale = DelScaleInfo();
      delScale.scaleId = selScaleId;
      String delStr = jsonEncode(delScale);
      PublicFunctions.sendDelScale(delStr);
    }
  }

  void sendStaticIpInfo(String ip, String gateway, String netmask) {
    myScaleCmd.cmdMode = 'set_wifi_static_ip';
    myStaticIpInfo.gateway = gateway;
    myStaticIpInfo.ip = ip;
    myStaticIpInfo.netmask = netmask;
    myScaleCmd.cmdData = jsonEncode(myStaticIpInfo).toString();
    PublicFunctions.sendMsg(myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
  }
}
