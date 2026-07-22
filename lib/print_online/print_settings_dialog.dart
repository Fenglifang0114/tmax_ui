import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_max/data/cominfoslist_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/widget/common_widget.dart';

class PrintSettingsDialog extends StatefulWidget {
  const PrintSettingsDialog({super.key});

  @override
  State<PrintSettingsDialog> createState() => _PrintSettingsDialogState();
}

class _PrintSettingsDialogState extends State<PrintSettingsDialog> {
  String _selectedSerialPort = 'COM1';
  String _selectedBaudRate = '9600';

  List<String> _serialPorts = [];
  final List<String> _baudRates = [
    '9600',
    '19200',
    '38400',
    '57600',
    '115200'
  ];

  final TextEditingController _serialPortCtl = TextEditingController();
  final TextEditingController _baudRateCtl = TextEditingController();

  StreamSubscription? _eventbusComList;

  @override
  void initState() {
    super.initState();
    _initSerialPorts();
    _loadSettings();
  }

  void _initSerialPorts() {
    // 1. 如果全局缓存 myComInfoList 已有数据，先同步到本地列表
    if (myComInfoList.msgBody != null && myComInfoList.msgBody!.isNotEmpty) {
      _serialPorts = List<String>.from(myComInfoList.msgBody!);
    }

    // 2. 监听后台返回串口列表的 EventComInfoList 事件
    _eventbusComList = eventBus.on<EventComInfoList>().listen((event) {
      if (mounted) {
        ComInfoList infoList = event.obj;
        if (infoList.msgBody != null) {
          setState(() {
            _serialPorts = List<String>.from(infoList.msgBody!);
            if (_serialPorts.isNotEmpty) {
              // 如果选中的串口不在最新返回列表中，默认选择第一个
              if (!_serialPorts.contains(_selectedSerialPort)) {
                _selectedSerialPort = _serialPorts.first;
                _serialPortCtl.text = _selectedSerialPort;
              }
            }
          });
        }
      }
    });

    // 3. 向后台发送请求获取最新串口列表
    PublicFunctions.getPortList();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSerialPort =
          prefs.getString('printOnline_serialPort') ?? 'COM1';
      _selectedBaudRate = prefs.getString('printOnline_baudRate') ?? '9600';

      _serialPortCtl.text = _selectedSerialPort;
      _baudRateCtl.text = _selectedBaudRate;

      if (_serialPorts.isNotEmpty && !_serialPorts.contains(_selectedSerialPort)) {
        _selectedSerialPort = _serialPorts.first;
        _serialPortCtl.text = _selectedSerialPort;
      }
    });
  }

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('printOnline_serialPort', _selectedSerialPort);
    await prefs.setString('printOnline_baudRate', _selectedBaudRate);
  }

  @override
  void dispose() {
    _eventbusComList?.cancel();
    _serialPortCtl.dispose();
    _baudRateCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).printSettings),
      content: SizedBox(
        width: 400,
        height: 150,
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text('Serial Port:',
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                Expanded(
                  child: showDropDownButton(
                      context, '', _serialPortCtl, _serialPorts, (newValue) {
                    setState(() {
                      _selectedSerialPort = newValue!;
                      _serialPortCtl.text = newValue;
                    });
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text('Baud Rate:',
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                Expanded(
                  child: showDropDownButton(
                      context, '', _baudRateCtl, _baudRates, (newValue) {
                    setState(() {
                      _selectedBaudRate = newValue!;
                      _baudRateCtl.text = newValue;
                    });
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(S.of(context).gBtnCancel),
        ),
        TextButton(
          onPressed: () {
            _saveSettings();
            Navigator.of(context).pop(true);
          },
          child: Text(S.of(context).gBtnConfirm),
        ),
      ],
    );
  }
}
