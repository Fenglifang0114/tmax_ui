import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:t_max/generated/l10n.dart';
import 'package:t_max/widget/common_widget.dart';

class PrintSettingsDialog extends StatefulWidget {
  const PrintSettingsDialog({super.key});

  @override
  State<PrintSettingsDialog> createState() => _PrintSettingsDialogState();
}

class _PrintSettingsDialogState extends State<PrintSettingsDialog> {
  String _selectedProtocol = 'Lp50';
  String _selectedSerialPort = 'COM1';
  String _selectedBaudRate = '9600';

  final List<String> _protocols = ['Lp50', 'Tsc', 'Epl'];
  final List<String> _serialPorts = List.generate(20, (index) => 'COM${index + 1}');
  final List<String> _baudRates = ['9600', '19200', '38400', '57600', '115200'];

  final TextEditingController _protocolCtl = TextEditingController();
  final TextEditingController _serialPortCtl = TextEditingController();
  final TextEditingController _baudRateCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedProtocol = prefs.getString('printOnline_protocol') ?? 'Lp50';
      _selectedSerialPort = prefs.getString('printOnline_serialPort') ?? 'COM1';
      _selectedBaudRate = prefs.getString('printOnline_baudRate') ?? '9600';

      _protocolCtl.text = _selectedProtocol;
      _serialPortCtl.text = _selectedSerialPort;
      _baudRateCtl.text = _selectedBaudRate;
    });
  }

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('printOnline_protocol', _selectedProtocol);
    await prefs.setString('printOnline_serialPort', _selectedSerialPort);
    await prefs.setString('printOnline_baudRate', _selectedBaudRate);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).printSettings),
      content: SizedBox(
        width: 400,
        height: 250,
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text('Protocol:', style: Theme.of(context).textTheme.bodyMedium),
                ),
                Expanded(
                  child: showDropDownButton(context, '', _protocolCtl, _protocols, (newValue) {
                    setState(() {
                      _selectedProtocol = newValue!;
                      _protocolCtl.text = newValue;
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
                  child: Text('Serial Port:', style: Theme.of(context).textTheme.bodyMedium),
                ),
                Expanded(
                  child: showDropDownButton(context, '', _serialPortCtl, _serialPorts, (newValue) {
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
                  child: Text('Baud Rate:', style: Theme.of(context).textTheme.bodyMedium),
                ),
                Expanded(
                  child: showDropDownButton(context, '', _baudRateCtl, _baudRates, (newValue) {
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
