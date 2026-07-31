import 'package:flutter/material.dart';
import 'package:t_max/data/barcodetype.dart';

import '../../data/barcoderowdata.dart';
import '../../eventbus/eventbus.dart';

class RowDataWidget extends StatefulWidget {
  final BarCodeRowData rowData;
  final List<BarCodeRowData> rowDataList;
  //回调
  final ValueChanged<bool>? onChanged;

  const RowDataWidget(
      {super.key,
      required this.rowData,
      required this.rowDataList,
      required this.onChanged});

  @override
  RowDataWidgetState createState() => RowDataWidgetState();
}

class RowDataWidgetState extends State<RowDataWidget> {
  final List<String> _types = [
    'TEXT',
    'NO.',
    'Gross',
    'Tare',
    'Net',
    'PCS',
    'WeightUnit',
    'U.WGT',
    'U.WU',
    'UnitWeight',
    'Percent',
    'TotalWeight',
    'TotalCount',
    'TotalPcs',
  ];

  final List<String> _alignments = [
    '--',
    'Left',
    'Center',
    'Right',
  ];

  late String _selectedType;
  late String _selectedAlignment;

  late TextEditingController _textEditingController;
  late TextEditingController _defaultvalueController;
  late TextEditingController _maxLengthController;
  final TextEditingController _textMaxLengthController =
      TextEditingController(text: '-');

  @override
  void initState() {
    super.initState();
    _selectedType = widget.rowData.type;
    _selectedAlignment = widget.rowData.alignment;
    _textEditingController =
        TextEditingController(text: widget.rowData.content);
    _defaultvalueController =
        TextEditingController(text: widget.rowData.defaultvalue);
    _maxLengthController =
        TextEditingController(text: widget.rowData.maxlength.toString());

    eventBus.on<EventBarcodetypedata>().listen((event) {
      if (mounted) {
        setState(() {
          myBarcodetypedata = event.obj;
        });
      }
    });
  }

  @override
  void dispose() {
    _defaultvalueController.dispose();
    _maxLengthController.dispose();
    _textEditingController.dispose();
    _textMaxLengthController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _selectedType = widget.rowData.type;
    if (_selectedType == 'Pcs') {
      _selectedType = 'PCS';
      widget.rowData.type = 'PCS';
    }
    if (!_types.contains(_selectedType)) {
      _selectedType = 'TEXT';
      widget.rowData.type = 'TEXT';
    }
    _selectedAlignment = widget.rowData.alignment;
    _textEditingController =
        TextEditingController(text: widget.rowData.content);
    _defaultvalueController =
        TextEditingController(text: widget.rowData.defaultvalue);
    _maxLengthController =
        TextEditingController(text: widget.rowData.maxlength.toString());
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: DropdownButton<String>(
            value: _selectedType,
            underline: Container(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedType = newValue!;
                widget.rowData.type = _selectedType;
                if (_selectedType == 'TEXT') {
                  widget.rowData.maxlength = 7;
                  widget.rowData.defaultvalue = "";
                  widget.rowData.alignment = 'Left';
                } else {
                  widget.rowData.content = "";
                  if (widget.rowData.alignment == '--') {
                    widget.rowData.alignment = 'Left';
                  }
                }
              });
            },
            items: _types.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(right: 20),
              child: TextField(
                enabled: (_selectedType == 'TEXT') ? true : false,
                controller: _textEditingController,
                decoration: const InputDecoration(
                    hintText: 'Enter text',
                    contentPadding: EdgeInsets.only(left: 10)),
                textAlign: TextAlign.left,
                onChanged: (value) {
                  widget.rowData.content = value;
                },
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )),
        Expanded(
          flex: 1,
          child: Container(
            margin: EdgeInsets.only(right: 20),
            child: TextField(
              enabled: (_selectedType == 'TEXT') ? false : true,
              controller: _defaultvalueController,
              decoration: const InputDecoration(
                  hintText: 'default value',
                  contentPadding: EdgeInsets.only(left: 10)),
              textAlign: TextAlign.left,
              onChanged: (value) {
                widget.rowData.defaultvalue = value;
              },
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: DropdownButton<String>(
            value: _selectedAlignment,
            underline: Container(),
            onChanged: (_selectedType == 'TEXT')
                ? null
                : (String? newValue) {
                    setState(() {
                      _selectedAlignment = newValue!;
                      widget.rowData.alignment = _selectedAlignment;
                    });
                  },
            items: _alignments.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(_selectedType == 'TEXT' ? '--' : value,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis),
              );
            }).toList(),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.only(right: 20),
            child: TextField(
              enabled: (_selectedType == 'TEXT') ? false : true,
              keyboardType: TextInputType.number,
              controller: (_selectedType == 'TEXT')
                  ? _textMaxLengthController
                  : _maxLengthController,
              decoration: const InputDecoration(
                  hintText: 'Enter max length',
                  contentPadding: EdgeInsets.only(left: 10)),
              textAlign: TextAlign.left,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  RegExp regex = RegExp(r"^[1-9]$|^[1-4]\d$|^50$"); //1-50限制大小
                  if (regex.hasMatch(value)) {
                    int tempvalue = int.parse(value.toString());
                    widget.rowData.maxlength = tempvalue;
                    widget.rowData.defaultvalue = "";
                  }
                }
              },
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: IconButton(
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: widget.rowData.canDelete
                ? () {
                    setState(() {
                      widget.rowDataList
                          .removeWhere((rowData) => rowData == widget.rowData);
                    });
                    widget.onChanged!(true);
                  }
                : null,
          ),
        )
      ],
    );
  }
}
