import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_max/data/cominfoslist_data.dart';
import 'package:t_max/data/pt10_printer_data.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';

class PrintSettingsDialog extends StatefulWidget {
  const PrintSettingsDialog({super.key});

  @override
  State<PrintSettingsDialog> createState() => _PrintSettingsDialogState();
}

class _PrintSettingsDialogState extends State<PrintSettingsDialog> {
  String _selectedSerialPort = 'COM1';
  String _selectedBaudRate = '9600';

  List<String> _serialPorts = ['COM1', 'COM2', 'COM3', 'COM4', 'COM5'];
  final List<String> _baudRates = ['9600', '115200', '19200', '38400', '57600'];

  final TextEditingController _serialPortCtl = TextEditingController();
  final TextEditingController _baudRateCtl = TextEditingController();

  // Parameter Dropdown Options
  final List<String> _printerBaudRateOptions = ['9600', '115200'];
  final List<String> _speedOptions = ['50mm/s', '75mm/s', '100mm/s', '125mm/s'];
  final List<String> _densityOptions = [
    'Pale',
    'Light',
    'Standard',
    'Medium',
  ];
  final List<String> _paperTypeOptions = ['Continuous', 'Label'];
  final List<String> _paperTakeOptions = ['Off', 'On'];
  final List<String> _beepOptions = ['Off', 'On'];
  final List<String> _coverFeedOptions = ['Off', 'On'];
  final List<String> _powerFeedOptions = ['Off', 'On'];
  final List<String> _languageOptions = [
    'Chinese, Traditional',
    'Chinese, Simplified',
    'Multi-language'
  ];
  final List<String> _autoPaperOptions = ['Off', 'On'];

  // Current Parameters State
  bool _isConnected = false;
  bool _isConnecting = false;

  String _printerBaudRate = '9600';
  String _speed = '100mm/s';
  String _density = 'Standard';
  String _paperType = 'Label';
  String _paperTake = 'On';
  String _beep = 'On';
  String _coverFeed = 'On';
  String _powerFeed = 'Off';
  String _language = 'Chinese, Simplified';
  String _autoPaper = 'Off';

  late TextEditingController _dateCtl;
  late TextEditingController _timeCtl;
  Pt10PrinterParams? _originalParams;

  StreamSubscription? _eventbusComList;
  StreamSubscription? _eventbusPt10Connect;
  StreamSubscription? _eventbusPt10Params;
  StreamSubscription? _eventbusPt10Write;

  @override
  void initState() {
    super.initState();
    _dateCtl = TextEditingController(text: '2026-07-29');
    _timeCtl = TextEditingController(text: '12:20:14');

    _initSerialPorts();
    _loadSettings();

    // Event bus listeners for PT10 events
    _eventbusPt10Connect =
        eventBus.on<EventPt10ConnectResult>().listen((event) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isConnected = event.success;
        });
        if (event.success) {
          showTipInfo('打印机连接成功！', context);
        } else {
          showTipInfo('打印机连接失败: ${event.message}', context);
        }
      }
    });

    _eventbusPt10Write = eventBus.on<EventPt10WriteResult>().listen((event) {
      if (mounted) {
        if (event.success) {
          showTipInfo('打印机参数修改下发成功！', context);
        } else {
          showTipInfo('打印机参数修改失败: ${event.message}', context);
        }
      }
    });

    _eventbusPt10Params = eventBus.on<EventPt10ParamsLoaded>().listen((event) {
      if (mounted) {
        setState(() {
          _isConnected = true;
          _isConnecting = false;
          _originalParams = event.params;

          if (event.params.baudRate == 0) {
            _printerBaudRate = '115200';
          } else if (event.params.baudRate == 1) {
            _printerBaudRate = '9600';
          }

          if (event.params.speed >= 0 &&
              event.params.speed < _speedOptions.length) {
            _speed = _speedOptions[event.params.speed];
          }
          if (event.params.density >= 0 &&
              event.params.density < _densityOptions.length) {
            _density = _densityOptions[event.params.density];
          }
          if (event.params.paperType >= 0 &&
              event.params.paperType < _paperTypeOptions.length) {
            _paperType = _paperTypeOptions[event.params.paperType];
          }
          if (event.params.paperTake >= 0 &&
              event.params.paperTake < _paperTakeOptions.length) {
            _paperTake = _paperTakeOptions[event.params.paperTake];
          }
          if (event.params.beep >= 0 &&
              event.params.beep < _beepOptions.length) {
            _beep = _beepOptions[event.params.beep];
          }
          if (event.params.coverFeed >= 0 &&
              event.params.coverFeed < _coverFeedOptions.length) {
            _coverFeed = _coverFeedOptions[event.params.coverFeed];
          }
          if (event.params.powerFeed >= 0 &&
              event.params.powerFeed < _powerFeedOptions.length) {
            _powerFeed = _powerFeedOptions[event.params.powerFeed];
          }
          if (event.params.language >= 0 &&
              event.params.language < _languageOptions.length) {
            _language = _languageOptions[event.params.language];
          }
          if (event.params.autoPaper >= 0 &&
              event.params.autoPaper < _autoPaperOptions.length) {
            _autoPaper = _autoPaperOptions[event.params.autoPaper];
          }

          _dateCtl.text = event.params.date;
          _timeCtl.text = event.params.time;
        });
      }
    });
  }

  void _initSerialPorts() {
    if (myComInfoList.msgBody != null && myComInfoList.msgBody!.isNotEmpty) {
      _serialPorts = List<String>.from(myComInfoList.msgBody!);
    }

    _eventbusComList = eventBus.on<EventComInfoList>().listen((event) {
      if (mounted) {
        ComInfoList infoList = event.obj;
        if (infoList.msgBody != null && infoList.msgBody!.isNotEmpty) {
          setState(() {
            _serialPorts = List<String>.from(infoList.msgBody!);
            if (!_serialPorts.contains(_selectedSerialPort)) {
              _selectedSerialPort = _serialPorts.first;
              _serialPortCtl.text = _selectedSerialPort;
            }
          });
        }
      }
    });

    PublicFunctions.getPortList();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSerialPort = prefs.getString('printOnline_serialPort') ?? 'COM1';
      _selectedBaudRate = prefs.getString('printOnline_baudRate') ?? '9600';

      _serialPortCtl.text = _selectedSerialPort;
      _baudRateCtl.text = _selectedBaudRate;

      if (_serialPorts.isNotEmpty &&
          !_serialPorts.contains(_selectedSerialPort)) {
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

  void _handleConnect() async {
    _saveSettings();
    setState(() {
      _isConnecting = true;
    });
    PublicFunctions.pt10Connect(
      _selectedSerialPort,
      int.tryParse(_selectedBaudRate) ?? 9600,
    );
  }

  void _handleModify() async {
    if (!_isConnected || _originalParams == null) return;

    Map<String, String> cmdParams = {};

    if (_dateCtl.text != _originalParams!.date) {
      cmdParams["1"] = _dateCtl.text;
    }
    if (_timeCtl.text != _originalParams!.time) {
      cmdParams["2"] = _timeCtl.text;
    }
    int currentBaudRateVal = _printerBaudRate == '115200' ? 0 : 1;
    if (currentBaudRateVal != _originalParams!.baudRate) {
      cmdParams["3"] = currentBaudRateVal.toString();
    }
    int paperTypeVal = _paperTypeOptions.indexOf(_paperType);
    if (paperTypeVal != _originalParams!.paperType && paperTypeVal >= 0) {
      cmdParams["4"] = paperTypeVal.toString();
    }
    int paperTakeVal = _paperTakeOptions.indexOf(_paperTake);
    if (paperTakeVal != _originalParams!.paperTake && paperTakeVal >= 0) {
      cmdParams["5"] = paperTakeVal.toString();
    }
    int speedVal = _speedOptions.indexOf(_speed);
    if (speedVal != _originalParams!.speed && speedVal >= 0) {
      cmdParams["6"] = speedVal.toString();
    }
    int densityVal = _densityOptions.indexOf(_density);
    if (densityVal != _originalParams!.density && densityVal >= 0) {
      cmdParams["7"] = densityVal.toString();
    }
    int coverFeedVal = _coverFeedOptions.indexOf(_coverFeed);
    if (coverFeedVal != _originalParams!.coverFeed && coverFeedVal >= 0) {
      cmdParams["8"] = coverFeedVal.toString();
    }
    int powerFeedVal = _powerFeedOptions.indexOf(_powerFeed);
    if (powerFeedVal != _originalParams!.powerFeed && powerFeedVal >= 0) {
      cmdParams["9"] = powerFeedVal.toString();
    }
    int languageVal = _languageOptions.indexOf(_language);
    if (languageVal != _originalParams!.language && languageVal >= 0) {
      cmdParams["10"] = languageVal.toString();
    }
    int autoPaperVal = _autoPaperOptions.indexOf(_autoPaper);
    if (autoPaperVal != _originalParams!.autoPaper && autoPaperVal >= 0) {
      cmdParams["11"] = autoPaperVal.toString();
    }
    int beepVal = _beepOptions.indexOf(_beep);
    if (beepVal != _originalParams!.beep && beepVal >= 0) {
      cmdParams["12"] = beepVal.toString();
    }

    if (cmdParams.isEmpty) {
      showTipInfo('没有修改任何参数！', context);
      return;
    }

    PublicFunctions.pt10WriteParams(
      _selectedSerialPort,
      int.tryParse(_selectedBaudRate) ?? 9600,
      cmdParams,
    );
  }

  @override
  void dispose() {
    _eventbusComList?.cancel();
    _eventbusPt10Connect?.cancel();
    _eventbusPt10Params?.cancel();
    _eventbusPt10Write?.cancel();
    _serialPortCtl.dispose();
    _baudRateCtl.dispose();
    _dateCtl.dispose();
    _timeCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 850,
        height: 520,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      color: Colors.black,
                      margin: const EdgeInsets.only(right: 8),
                    ),
                    const Text(
                      '连打印机',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.black26),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 20),
            // Body layout: Left serial panel + Right parameter panel
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Serial Panel
                  SizedBox(
                    width: 220,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Serial port',
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 8),
                        _buildDropdownField(_serialPortCtl, _serialPorts,
                            (val) {
                          setState(() {
                            _selectedSerialPort = val!;
                            _serialPortCtl.text = val;
                          });
                        }),
                        const SizedBox(height: 20),
                        const Text('Baud Rate',
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 8),
                        _buildDropdownField(_baudRateCtl, _baudRates, (val) {
                          setState(() {
                            _selectedBaudRate = val!;
                            _baudRateCtl.text = val;
                          });
                        }),
                        const Spacer(),
                        // Bottom left Connect / Connected Button
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _isConnecting ? null : _handleConnect,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isConnected
                                  ? const Color(0xFF10B981) // Green
                                  : const Color(0xFF005696), // Blue
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: _isConnecting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isConnected ? '连接成功' : '连接',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 30),
                  // Right Parameters Panel
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                _buildParamBox('Baud Rate', _printerBaudRate,
                                    _printerBaudRateOptions, (v) => _printerBaudRate = v!),
                                _buildParamBox('Speed', _speed, _speedOptions,
                                    (v) => _speed = v!),
                                _buildParamBox('Density', _density,
                                    _densityOptions, (v) => _density = v!),
                                _buildParamBox('Paper Type', _paperType,
                                    _paperTypeOptions, (v) => _paperType = v!),
                                _buildParamBox('Paper Take', _paperTake,
                                    _paperTakeOptions, (v) => _paperTake = v!),
                                _buildParamBox('Beep', _beep, _beepOptions,
                                    (v) => _beep = v!),
                                _buildParamBox('Cover Feed', _coverFeed,
                                    _coverFeedOptions, (v) => _coverFeed = v!),
                                _buildParamBox('Power Feed', _powerFeed,
                                    _powerFeedOptions, (v) => _powerFeed = v!),
                                _buildParamBox('Launguage', _language,
                                    _languageOptions, (v) => _language = v!),
                                _buildParamBox('Auto Paper', _autoPaper,
                                    _autoPaperOptions, (v) => _autoPaper = v!),
                                _buildTextFieldBox('Date', _dateCtl),
                                _buildTextFieldBox('Time', _timeCtl),
                              ],
                            ),
                          ),
                        ),
                        // Bottom Right Modify Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 140,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _isConnected ? _handleModify : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005696),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                'Modify',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(TextEditingController controller,
      List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(controller.text)
              ? controller.text
              : (items.isNotEmpty ? items.first : null),
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildParamBox(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return SizedBox(
      width: 165,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 4),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: _isConnected ? Colors.white : const Color(0xFFFAFAFA),
              border: Border.all(
                  color: _isConnected ? Colors.black26 : Colors.black12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: options.contains(value)
                    ? value
                    : (options.isNotEmpty ? options.first : null),
                isExpanded: true,
                style: TextStyle(
                    fontSize: 13,
                    color: _isConnected ? Colors.black87 : Colors.black38),
                items: options
                    .map((opt) => DropdownMenuItem(
                          value: opt,
                          child: Text(opt),
                        ))
                    .toList(),
                onChanged: _isConnected
                    ? (val) {
                        setState(() {
                          onChanged(val);
                        });
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldBox(String label, TextEditingController controller) {
    return SizedBox(
      width: 165,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 4),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: _isConnected ? Colors.white : const Color(0xFFFAFAFA),
              border: Border.all(
                  color: _isConnected ? Colors.black26 : Colors.black12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: controller,
              enabled: _isConnected,
              style: TextStyle(
                  fontSize: 13,
                  color: _isConnected ? Colors.black87 : Colors.black38),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
