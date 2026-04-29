import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:t_max/data/barcoderowdata.dart';
import 'package:t_max/data/encrypt_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/dialog/barcodeedit_dialog.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/dialog/qrcodeedit_dialog.dart';

import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/generated/l10n.dart';

import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:t_max/labeldesign/label_design_data.dart';
import 'package:t_max/labeldesign/label_dropdown_copy.dart';
import 'package:t_max/labeldesign/label_element.dart';
import 'package:t_max/labeldesign/label_formatdata.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_max/widget/attibute_widget.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/page_head.dart';
import 'package:t_max/labeldesign/ai_design_dialog.dart';

class LabelDesignPage extends StatefulWidget {
  final String type;
  final Function(String) onNavigate;
  final String lastRouteName;
  const LabelDesignPage(
      {super.key,
      required this.type,
      required this.onNavigate,
      required this.lastRouteName});
  @override
  LabelDesignPageState createState() => LabelDesignPageState();
}

class LabelDesignPageState extends State<LabelDesignPage> {
  List<DraggableElement> elements = [];
  Offset canvasOffset = Offset.zero;
  Size canvasSize = const Size(440, 400);
  bool isSelecting = false;
  Offset? selectionStart;
  Offset? selectionEnd;
  List<DraggableElement> selectedElements = [];
  bool isMovingSelected = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _widthController = TextEditingController();
  final FocusNode _canvasWidthFocusNode = FocusNode();
  final TextEditingController _heightController = TextEditingController();
  final FocusNode _canvasHeightFocusNode = FocusNode();
  List<AlignmentLine> alignmentLines = [];
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _textWidthController = TextEditingController();
  final TextEditingController _textHeightController = TextEditingController();
  // 新增用于显示控件信息的控制器
  final TextEditingController _positionXController = TextEditingController();
  final TextEditingController _positionYController = TextEditingController();
  final TextEditingController _elementWidthController = TextEditingController();
  final TextEditingController _elementHeightController =
      TextEditingController();
  TextEditingController maxLenthController = TextEditingController();

  dynamic localizedStrings;
  String _selectedPrintDirection = '0';
  String text = "";
  String type = '';
  String lastFontSize = '23';
  String _selectedAlignment = 'Left';
  String _selectedBarcode = '--';
  String _selectedQrcode = '--';
  String _selectedRotation = '0';
  String _selectedHRAlignment = 'Bottom';
  String _selectedQrWidth = '3';
  String _selectFontBold = 'false';
  String _selectFontReverse = 'false';

  late List<String> _savedBarCodeNames = ['--'];
  late List<String> _savedQrcodeNames = ['--'];

  dynamic eventbus3;
  dynamic eventbus4;
  dynamic eventbus5;

  // 新增：操作记录栈
  List<List<DraggableElement>> undoStack = [];
  List<List<DraggableElement>> redoStack = [];
  int maxUndoSteps = 100; // 最大撤销步数

  //焦点

  final FocusNode textWidthFocusNode = FocusNode();
  final FocusNode textHeightFocusNode = FocusNode();
  final FocusNode textContentFocusNode = FocusNode();
  final FocusNode maxLenthFocusNode = FocusNode();
  final FocusNode textFontSizeFocusNode = FocusNode();

  Map<String, String> langVarMap = {};
  Map<String, String> langVarExplMap = {};

  final List<String> _variables = [
    "",
    "Trademark1",
    "Trademark2",
    "Trademark3",
    "Trademark4"
  ];
  TextEditingController selectedVarCtl = TextEditingController();

  final double btnWidth = 150;
  final double textWidth = 120;
  final double topTitleHeight = 300;
  final double topBtnHeight = 120;
  final double leftBtnWidth = 280;
  final double rightBtnWidth = 288;

  TextEditingController printDirectionCtl = TextEditingController(text: '0');
  TextEditingController printerCtl = TextEditingController(text: 'EPM205');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizedStrings = S.of(context);
  }

  @override
  void initState() {
    super.initState();
    barcodeDataReload();
    textWidthFocusNode.addListener(_onTextWidthFocusChange);
    textHeightFocusNode.addListener(_onTextHeightFocusChange);
    textContentFocusNode.addListener(_onTextContentFocusChange);
    maxLenthFocusNode.addListener(_onMaxLenthFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _widthController.text = '55';
    _heightController.text = '50';

    openTemplateJson();
    eventbus3 = eventBus.on<EventSavedBarcodeName>().listen((event) {
      if (mounted) {
        setState(() {
          mySavedBarcodeName = event.obj;
          _savedBarCodeNames = mySavedBarcodeName.savedBarcodeName;
          if (_savedBarCodeNames.isNotEmpty) {
            _selectedBarcode =
                _savedBarCodeNames[_savedBarCodeNames.length - 1];
          } else {
            _savedBarCodeNames = ['--'];
            _selectedBarcode =
                _savedBarCodeNames[_savedBarCodeNames.length - 1];
          }
        });
      }
    });

    eventbus4 = eventBus.on<EventCurrentBarCodeRowDataList>().listen((event) {
      if (mounted) {
        setState(() {
          myBarCodeRowDataList = event.obj;
        });
      }
    });

    eventbus5 = eventBus.on<EventSavedQrcodeName>().listen((event) {
      if (mounted) {
        setState(() {
          mySavedQrcodeName = event.obj;
          _savedQrcodeNames = mySavedQrcodeName.savedQrcodeName;
          if (_savedQrcodeNames.isNotEmpty) {
            _selectedQrcode = _savedQrcodeNames[_savedQrcodeNames.length - 1];
          } else {
            _savedQrcodeNames = ['--'];
            _selectedQrcode = _savedQrcodeNames[_savedQrcodeNames.length - 1];
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _textController.dispose();
    _textWidthController.dispose();
    _textHeightController.dispose();
    _positionXController.dispose();
    _positionYController.dispose();
    _elementWidthController.dispose();
    _elementHeightController.dispose();
    selectedVarCtl.dispose();
    maxLenthController.dispose();
    textWidthFocusNode.removeListener(_onTextWidthFocusChange);
    textHeightFocusNode.removeListener(_onTextHeightFocusChange);
    textContentFocusNode.removeListener(_onTextContentFocusChange);
    maxLenthFocusNode.removeListener(_onMaxLenthFocusChange);

    eventbus3.cancel();
    eventbus4.cancel();
    eventbus5.cancel();

    super.dispose();
  }

  void openTemplateJson() async {
    final ByteData bytes = await rootBundle.load('assets/template/label.json');
    // 将 ByteData 直接转换为 JSON 字符串
    final jsonString = bytes.buffer.asUint8List();
    final jsonData = utf8.decode(jsonString);

    deleteAllElements();
    readTextInfoListFromStr(jsonData);
  }

  // 宽度输入框焦点变化处理
  void _onTextWidthFocusChange() {
    if (!textWidthFocusNode.hasFocus) {
      // 将焦点转移到主焦点节点
      _focusNode.requestFocus();
    }
  }

  // 高度输入框焦点变化处理
  void _onTextHeightFocusChange() {
    if (!textHeightFocusNode.hasFocus) {
      // 将焦点转移到主焦点节点
      _focusNode.requestFocus();
    }
  }

  // 文本输入框焦点变化处理
  void _onTextContentFocusChange() {
    if (!textContentFocusNode.hasFocus) {
      // 将焦点转移到主焦点节点
      _focusNode.requestFocus();
    }
  }

  // 最大长度输入框焦点变化处理
  void _onMaxLenthFocusChange() {
    if (!maxLenthFocusNode.hasFocus) {
      // 将焦点转移到主焦点节点
      _focusNode.requestFocus();
    }
  }

  // 新增：保存当前状态到撤销栈
  void _saveState() {
    // 深拷贝当前元素列表
    final currentState = elements.map((e) => e.copy()).toList();

    undoStack.add(currentState);
    if (undoStack.length > maxUndoSteps) {
      undoStack.removeAt(0);
    }
    if (redoStack.isNotEmpty) {
      redoStack.clear();
    }
  }

  // 新增：撤销操作
  void _undo() {
    if (undoStack.isNotEmpty) {
      final previousState = undoStack.removeLast();
      redoStack.add(elements.map((e) => e.copy()).toList());
      setState(() {
        elements = previousState;
      });
    }
  }

  // 新增：重做操作
  void _redo() {
    if (redoStack.isNotEmpty) {
      final nextState = redoStack.removeLast();
      undoStack.add(elements.map((e) => e.copy()).toList());
      setState(() {
        elements = nextState;
      });
    }
  }

  //重新加载条码数据
  barcodeDataReload() {
    loadData();
  }

  Future<File> get _localFile async {
    final directory = p.dirname(Platform.script.toFilePath());
    return File(p.join(directory, 'barcodedata.json'));
  }

  Future<Map<String, dynamic>?> loadData() async {
    try {
      final file = await _localFile;
      // 从文件中读取字符串
      String contents = await file.readAsString();
      // 将字符串解码为JSON数据
      if (contents.isNotEmpty) {
        pasterBarcodeList(contents);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future pasterBarcodeList(String jsonDataString) async {
    String jsonStrings = jsonDataString;
    final jsonResponse = json.decode(jsonStrings);
    myBarCodeListList = BarCodeListList.fromJson(jsonResponse);
    _saveBarCodeNameToList();
    _saveQrcodeNameToList();
  }

  _saveBarCodeNameToList() {
    if (myBarCodeListList.barCodeListList.isNotEmpty) {
      mySavedBarcodeName.savedBarcodeName.clear();
      for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
        if (myBarCodeListList.barCodeListList[i].barCodeType != 'Qrcode') {
          mySavedBarcodeName.savedBarcodeName
              .add(myBarCodeListList.barCodeListList[i].barCodeName);
        }
      }
      mySavedBarcodeName.savedBarcodeName.add('--');
    } else {
      mySavedBarcodeName.savedBarcodeName.clear();
    }
    eventBus.fire(EventSavedBarcodeName(mySavedBarcodeName));
  }

  _saveQrcodeNameToList() {
    if (myBarCodeListList.barCodeListList.isNotEmpty) {
      mySavedQrcodeName.savedQrcodeName.clear();
      for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
        if (myBarCodeListList.barCodeListList[i].barCodeType == 'Qrcode') {
          mySavedQrcodeName.savedQrcodeName
              .add(myBarCodeListList.barCodeListList[i].barCodeName);
        }
      }
      mySavedQrcodeName.savedQrcodeName.add('--');
    } else {
      mySavedQrcodeName.savedQrcodeName.clear();
    }
    eventBus.fire(EventSavedQrcodeName(mySavedQrcodeName));
  }

  void startSelection(Offset position) {
    _focusNode.requestFocus();
    setState(() {
      isSelecting = true;
      selectionStart = position;
      selectionEnd = position;
      selectedElements.clear();
      isMovingSelected = false;
      alignmentLines.clear();
      _textController.clear();
      _textWidthController.clear();
      _textHeightController.clear();
      // 清空控件信息
      _positionXController.clear();
      _positionYController.clear();
      _elementWidthController.clear();
      _elementHeightController.clear();
    });
  }

  void updateSelection(Offset position) {
    if (isSelecting) {
      setState(() {
        selectionEnd = position;
        // 计算选择框内的元素
        selectedElements = elements.where((element) {
          double left = element.position.dx;
          double top = element.position.dy;
          double right = element.position.dx + element.size.width;
          double bottom = element.position.dy + element.size.height;

          double minX = selectionStart!.dx < selectionEnd!.dx
              ? selectionStart!.dx
              : selectionEnd!.dx;
          double maxX = selectionStart!.dx > selectionEnd!.dx
              ? selectionStart!.dx
              : selectionEnd!.dx;
          double minY = selectionStart!.dy < selectionEnd!.dy
              ? selectionStart!.dy
              : selectionEnd!.dy;
          double maxY = selectionStart!.dy > selectionEnd!.dy
              ? selectionStart!.dy
              : selectionEnd!.dy;

          return left >= minX && right <= maxX && top >= minY && bottom <= maxY;
        }).toList();

        if (selectedElements.length == 1 &&
            (selectedElements.first.type == ElementType.text ||
                selectedElements.first.type == ElementType.data ||
                selectedElements.first.type == ElementType.barcode ||
                selectedElements.first.type == ElementType.line ||
                selectedElements.first.type == ElementType.img)) {
          _textController.text = selectedElements.first.content!;
          _textWidthController.text =
              selectedElements.first.size.width.toString();
          _textHeightController.text =
              selectedElements.first.size.height.toString();
        }
        if (selectedElements.length == 1 &&
            selectedElements.first.type == ElementType.data) {
          maxLenthController.text = selectedElements.first.maxLength.toString();
        }
        if (selectedElements.length == 1) {
          _positionXController.text =
              selectedElements.first.position.dx.toInt().toString();
          _positionYController.text =
              selectedElements.first.position.dy.toInt().toString();
          _elementWidthController.text =
              selectedElements.first.size.width.toString();
          _elementHeightController.text =
              selectedElements.first.size.height.toString();
        } else {
          _positionXController.clear();
          _positionYController.clear();
          _elementWidthController.clear();
          _elementHeightController.clear();
        }
      });
    }
  }

  void endSelection() {
    setState(() {
      isSelecting = false;
      if (selectedElements.isNotEmpty) {
        isMovingSelected = true;
      }
      alignmentLines.clear();
    });
  }

  void _calculateAlignmentLines(
      DraggableElement movingElement, Offset newPosition) {
    for (DraggableElement otherElement in elements) {
      if (!selectedElements.contains(otherElement)) {
        // 顶部对齐
        if ((newPosition.dy).round() == otherElement.position.dy.round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(0, newPosition.dy),
            end: Offset(canvasSize.width, newPosition.dy),
          ));
        }
        // 底部对齐
        if ((newPosition.dy + movingElement.size.height).round() ==
            (otherElement.position.dy + otherElement.size.height).round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(0, newPosition.dy + movingElement.size.height),
            end: Offset(
                canvasSize.width, newPosition.dy + movingElement.size.height),
          ));
        }
        // 左侧对齐
        if ((newPosition.dx).round() == otherElement.position.dx.round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(newPosition.dx, 0),
            end: Offset(newPosition.dx, canvasSize.height),
          ));
        }
        // 右侧对齐
        if ((newPosition.dx + movingElement.size.width).round() ==
            (otherElement.position.dx + otherElement.size.width).round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(newPosition.dx + movingElement.size.width, 0),
            end: Offset(
                newPosition.dx + movingElement.size.width, canvasSize.height),
          ));
        }
        // 移动控件的右侧边框与其他控件的左侧边框对齐
        if ((newPosition.dx + movingElement.size.width).round() ==
            otherElement.position.dx.round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(newPosition.dx + movingElement.size.width, 0),
            end: Offset(
                newPosition.dx + movingElement.size.width, canvasSize.height),
          ));
        }
        // 移动控件的左侧边框与其他控件的右侧边框对齐
        if ((newPosition.dx).round() ==
            (otherElement.position.dx + otherElement.size.width).round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(newPosition.dx, 0),
            end: Offset(newPosition.dx, canvasSize.height),
          ));
        }
        // 移动控件的上边框与其他控件的下边框对齐
        if ((newPosition.dy).round() ==
            (otherElement.position.dy + otherElement.size.height).round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(0, newPosition.dy),
            end: Offset(canvasSize.width, newPosition.dy),
          ));
        }
        // 移动控件的下边框与其他控件的上边框对齐
        if ((newPosition.dy + movingElement.size.height).round() ==
            otherElement.position.dy.round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(0, newPosition.dy + movingElement.size.height),
            end: Offset(
                canvasSize.width, newPosition.dy + movingElement.size.height),
          ));
        }
      }
    }
  }

  void moveSelectedElements(Offset delta) {
    if (selectedElements.length == 1) {
      setState(() {
        alignmentLines.clear();
        DraggableElement movingElement = selectedElements.first;
        double newX = movingElement.position.dx + delta.dx;
        double newY = movingElement.position.dy + delta.dy;
        if (canvasSize.width - movingElement.size.width < 0 ||
            canvasSize.height - movingElement.size.height < 0) {
          return;
        }

        // 边界检查
        newX = newX.clamp(0, canvasSize.width - movingElement.size.width);
        newY = newY.clamp(0, canvasSize.height - movingElement.size.height);

        Offset newPosition = Offset(newX, newY);

        _calculateAlignmentLines(movingElement, newPosition);

        movingElement.position = newPosition;
        // 更新控件信息
        _positionXController.text = newPosition.dx.toInt().toString();
        _positionYController.text = newPosition.dy.toInt().toString();
        _elementWidthController.text = movingElement.size.width.toString();
        _elementHeightController.text = movingElement.size.height.toString();
      });
    } else {
      setState(() {
        alignmentLines.clear();
        // 先检查所有控件是否会超出边界
        bool outOfBounds = false;
        for (DraggableElement element in selectedElements) {
          double newX = element.position.dx + delta.dx;
          double newY = element.position.dy + delta.dy;
          if (newX < 0 ||
              newX > canvasSize.width - element.size.width ||
              newY < 0 ||
              newY > canvasSize.height - element.size.height) {
            outOfBounds = true;
            break;
          }
        }

        if (!outOfBounds) {
          for (DraggableElement element in selectedElements) {
            double newX = element.position.dx + delta.dx;
            double newY = element.position.dy + delta.dy;
            Offset newPosition = Offset(newX, newY);
            _calculateAlignmentLines(element, newPosition);
            element.position = newPosition;
          }
        }
        // 选择多个控件时清空信息
        _positionXController.clear();
        _positionYController.clear();
        _elementWidthController.clear();
        _elementHeightController.clear();
      });
    }
  }

  void clearSelection() {
    _focusNode.requestFocus();
    setState(() {
      selectedElements.clear();
      isMovingSelected = false;
      alignmentLines.clear();
      _textController.clear();
      _textWidthController.clear();
      _textHeightController.clear();
      // 清空控件信息
      _positionXController.clear();
      _positionYController.clear();
      _elementWidthController.clear();
      _elementHeightController.clear();
    });
  }

  void deleteSelectedElements() {
    _saveState(); // 保存当前状态
    setState(() {
      elements.removeWhere((element) => selectedElements.contains(element));
      selectedElements.clear();
      isMovingSelected = false;
      alignmentLines.clear();
      _textController.clear();
      _textWidthController.clear();
      _textHeightController.clear();
      // 清空控件信息
      _positionXController.clear();
      _positionYController.clear();
      _elementWidthController.clear();
      _elementHeightController.clear();
    });
  }

  void deleteAllElements() {
    setState(() {
      elements.clear();
      selectedElements.clear();
      isMovingSelected = false;
      alignmentLines.clear();
      _textController.clear();
      _textWidthController.clear();
      _textHeightController.clear();
      // 清空控件信息
      _positionXController.clear();
      _positionYController.clear();
      _elementWidthController.clear();
      _elementHeightController.clear();
    });
  }

  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _saveState();
        moveSelectedElements(const Offset(0, -1));
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _saveState();
        moveSelectedElements(const Offset(0, 1));
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _saveState();
        moveSelectedElements(const Offset(-1, 0));
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _saveState();
        moveSelectedElements(const Offset(1, 0));
      } else if (event.logicalKey == LogicalKeyboardKey.delete) {
        _saveState();
        deleteSelectedElements();
      } else if (HardwareKeyboard.instance.isControlPressed &&
          HardwareKeyboard.instance.isShiftPressed &&
          event.logicalKey == LogicalKeyboardKey.keyZ) {
        _redo();
      } else if (HardwareKeyboard.instance.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyZ) {
        _undo();
      } else {}
    }
  }

  void selectSingleElement(DraggableElement element) {
    _focusNode.requestFocus();
    setState(() {
      selectedElements = [element];
      isMovingSelected = false;
      alignmentLines.clear();
      if (element.type == ElementType.text ||
          element.type == ElementType.data ||
          element.type == ElementType.barcode ||
          element.type == ElementType.line ||
          element.type == ElementType.img) {
        _textController.text = element.content!;
        _textWidthController.text = element.size.width.toString();
        _textHeightController.text = element.size.height.toString();
      } else {
        _textController.clear();
        _textWidthController.clear();
        _textHeightController.clear();
      }
      // 更新控件信息
      _positionXController.text = element.position.dx.toInt().toString();
      _positionYController.text = element.position.dy.toInt().toString();
      _elementWidthController.text = element.size.width.toString();
      _elementHeightController.text = element.size.height.toString();
      maxLenthController.text = element.maxLength.toString();
      _selectFontBold = element.fontBold.toString();
      _selectFontReverse = element.fontReverse.toString();
      lastFontSize = element.fontSize!;
      _selectedAlignment = element.alignment!;
      _selectedHRAlignment = element.hralignment!;
      _selectedRotation = element.rotation.toString();
      _selectedBarcode = element.barcodeName!;
      _selectedQrcode = element.qrcodeName!;
      _selectedQrWidth = element.qrWidth.toString();
    });
  }

  void updateCanvasSize(BuildContext scaffoldContext) {
    _saveState();
    //_focusNode.requestFocus(); // FIX: Removed to prevent canvas stealing focus while typing width/height
    double? width = double.tryParse(_widthController.text);
    double? height = double.tryParse(_heightController.text);

    if (width != null && height != null && width.isFinite && height.isFinite) {
      setState(() {
        canvasSize = Size(width * 8.toInt(), height * 8.toInt());
      });
    } else {
      // 输入不合法，给出提示
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content:
              Text('Please enter valid numbers for canvas width and height.'),
        ),
      );
      // 保持原来的画布大小
      _widthController.text = (canvasSize.width / 8.toInt()).toString();
      _heightController.text = (canvasSize.height / 8.toInt()).toString();
    }
  }

  void updateTextContent() {
    _saveState();
    // _focusNode.requestFocus(); // FIX: Removed to prevent canvas stealing focus while typing text
    if (selectedElements.length == 1 &&
        selectedElements.first.type == ElementType.text) {
      setState(() {
        selectedElements.first.content = _textController.text;
      });
    }
  }

  void updateMaxLenth(BuildContext scaffoldContext) {
    _saveState();
    // _focusNode.requestFocus(); // FIX: Removed to prevent canvas stealing focus while typing text
    int maxlenthInt = int.tryParse(maxLenthController.text) ?? 0;
    if (maxlenthInt != 0) {
      setState(() {
        selectedElements.first.maxLength = maxlenthInt;
      });
    } else {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Please enter valid numbers.'),
        ),
      );
    }
  }

  void updateTextSize(BuildContext context) {
    _saveState();
    _focusNode.requestFocus();
    double? width = double.tryParse(_textWidthController.text);
    double? height = double.tryParse(_textHeightController.text);

    if (width != null &&
        height != null &&
        width.isFinite &&
        height.isFinite &&
        (canvasSize.width - width) >= 0 &&
        (canvasSize.height - height) >= 0) {
      setState(() {
        selectedElements.first.size = Size(width, height);
        // 边界检查
        double newX = selectedElements.first.position.dx
            .clamp(0, canvasSize.width - width);
        double newY = selectedElements.first.position.dy
            .clamp(0, canvasSize.height - height);
        selectedElements.first.position = Offset(newX, newY);
        // 更新控件信息
        _positionXController.text = newX.toString();
        _positionYController.text = newY.toString();
        _elementWidthController.text = width.toString();
        _elementHeightController.text = height.toString();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text('Please enter valid numbers for width and height.'),
        ),
      );
    }
  }

  void updateFontSize(String value) {
    _saveState();
    _focusNode.requestFocus();
    setState(() {
      selectedElements.first.fontSize = value;
      lastFontSize = value;
    });
  }

  void rotateSelectedElement(String degrees) {
    _saveState();
    _focusNode.requestFocus();
    int degreeInt = int.tryParse(degrees)!;

    if (selectedElements.length == 1) {
      DraggableElement element = selectedElements.first;
      if (element.rotation == degreeInt) {
        return;
      }
      if ((element.rotation == 90 || element.rotation == 270)) {
        double temp = element.size.width;
        element.size = Size(element.size.height, temp);
      }
      setState(() {
        DraggableElement element = selectedElements.first;
        element.rotation = degreeInt;
        _selectedRotation = degrees;
        // 交换宽高以适应旋转
        if ([90, 270].contains(degreeInt)) {
          double temp = element.size.width;
          element.size = Size(element.size.height, temp);
        }
      });
    }
  }

  Future<void> _pickImage() async {
    _saveState();
    _focusNode.requestFocus();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedElements.first.content = pickedFile.path;
      });
    }
  }

  void fontBoldSelectedElement(String value) {
    _saveState();
    _focusNode.requestFocus();
    setState(() {
      selectedElements.first.fontBold = value;
      _selectFontBold = value;
    });
  }

  void fontReverseSelectedElement(String value) {
    _saveState();
    _focusNode.requestFocus();
    setState(() {
      selectedElements.first.fontReverse = value;
      _selectFontReverse = value;
    });
  }

  void alignmentSelectedElement(String value) {
    _saveState();
    _focusNode.requestFocus();
    if (selectedElements.length == 1) {
      setState(() {
        selectedElements.first.alignment = value;
        _selectedAlignment = value;
      });
    }
  }

  int _findVarcontent(String name, String type) {
    int findIndex = -1;
    for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
      if (myBarCodeListList.barCodeListList[i].barCodeName == name &&
          myBarCodeListList.barCodeListList[i].barCodeType == 'Qrcode' &&
          type == 'qrcode') {
        findIndex = i;
        break;
      } else if (myBarCodeListList.barCodeListList[i].barCodeName == name &&
          myBarCodeListList.barCodeListList[i].barCodeType != 'Qrcode' &&
          type != 'qrcode') {
        findIndex = i;
        break;
      }
    }

    return findIndex;
  }

  //下拉Barcode
  void _handleBarcodeSelected(String value) {
    _saveState();
    _focusNode.requestFocus();
    setState(() {
      _selectedBarcode = value;
      DraggableElement element = selectedElements.first;
      if (_selectedBarcode == '--') {
        if (element.style == 0) {
          element.varcontent!.clear();
        }
      } else {
        String totalcontent = '';
        List<dynamic> tempcontent = [];
        setState(() {
          int barcodeIndex =
              _findVarcontent(_selectedBarcode, element.type.name);
          if (barcodeIndex != -1) {
            element.style = 1; // 1为条码库中包含了条码，0为条码库中没有此条码
            element.barcodeType =
                myBarCodeListList.barCodeListList[barcodeIndex].barCodeType;
            element.barcodeName =
                myBarCodeListList.barCodeListList[barcodeIndex].barCodeName;
            for (var j = 0;
                j <
                    myBarCodeListList.barCodeListList[barcodeIndex]
                        .barCodeRowDataList.length;
                j++) {
              tempcontent.add(myBarCodeListList
                  .barCodeListList[barcodeIndex].barCodeRowDataList[j]);
              if (myBarCodeListList.barCodeListList[barcodeIndex]
                      .barCodeRowDataList[j].type ==
                  'TEXT') {
                totalcontent = totalcontent +
                    myBarCodeListList.barCodeListList[barcodeIndex]
                        .barCodeRowDataList[j].content
                        .toString();
              } else {
                totalcontent = totalcontent +
                    myBarCodeListList.barCodeListList[barcodeIndex]
                        .barCodeRowDataList[j].defaultvalue
                        .toString();
              }
            }
          }

          element.varcontent = tempcontent;
          element.content = totalcontent;
        });
      }
    });
  }

  //下拉qr宽度
  void _handleQrWidthSelected(String value) {
    _saveState();
    _focusNode.requestFocus();
    _selectedQrWidth = value;
    double width = double.parse(value) * 21;
    if (width > canvasSize.width || width > canvasSize.height) {
      return;
    }
    DraggableElement element = selectedElements.first;
    setState(() {
      _selectedQrWidth = value;
      element.qrWidth = value;
      element.size = Size(width, width);
    });
  }

  //下拉Barcode
  void _handleQrcodeSelected(String value) {
    _saveState();
    _focusNode.requestFocus();
    _selectedQrcode = value;
    DraggableElement element = selectedElements.first;
    if (_selectedQrcode == '--') {
      if (element.style == 0) {
        element.varcontent!.clear();
      }
      setState(() {
        element.qrcodeName = '--';
      });
    } else {
      setState(() {
        if (_selectedQrcode == '--') {
          if (element.style == 0) {
            element.varcontent!.clear();
          }
        } else {
          List<dynamic> tempcontent = [];
          setState(() {
            int qrcodeIndex =
                _findVarcontent(_selectedQrcode, element.type.name);
            if (qrcodeIndex != -1) {
              element.style = 1;
              element.qrcodeType =
                  myBarCodeListList.barCodeListList[qrcodeIndex].barCodeType;
              element.qrcodeName =
                  myBarCodeListList.barCodeListList[qrcodeIndex].barCodeName;
              for (var j = 0;
                  j <
                      myBarCodeListList.barCodeListList[qrcodeIndex]
                          .barCodeRowDataList.length;
                  j++) {
                tempcontent.add(myBarCodeListList
                    .barCodeListList[qrcodeIndex].barCodeRowDataList[j]);
              }
            }

            element.varcontent = tempcontent;
          });
        }
      });
    }
  }

  void hralignmentSelectedElement(String value) {
    _saveState();
    _focusNode.requestFocus();
    if (selectedElements.length == 1) {
      setState(() {
        selectedElements.first.hralignment = value;
        _selectedHRAlignment = value;
      });
    }
  }

  void copyElement(DraggableElement element) {
    _saveState();
    DraggableElement newElement = copyElementFun(element);
    setState(() {
      // 将新元素添加到列表中
      elements.add(newElement);
    });
  }

  void showContextMenu(DraggableElement element, Offset position) {
    copyElement(element);
  }

  /// 创建列表 , 每个元素都是一个 ExpansionTile 组件
  List<Widget> _buildList(BuildContext context) {
    List<Widget> widgets = [];
    for (var key in varCollection.keys) {
      widgets
          .add(_generateExpansionTileWidget(key, varCollection[key], context));
    }
    return widgets;
  }

  final List<String> _printers = ['EPM205', 'ZEBRA', 'LP50', 'TSC', 'SATO'];

  void getLanguageVarMap() {
    if (langVarMap.isNotEmpty) {
      return;
    }
    langVarMap = {
      "Variable": localizedStrings.l_var_title,
      "Free Text": localizedStrings.l_text_title,
      "BarCode Variable": localizedStrings.l_barcode_title,
      "Qrcode Variable": localizedStrings.l_qrcode_title,
      "Shape": localizedStrings.l_shape_title,
      "Line": localizedStrings.l_line_var,
      "Text": localizedStrings.l_text_var,
      "BarCode": localizedStrings.l_barcode_var,
      "Qrcode": localizedStrings.l_qrcode_var,
      "NO.": localizedStrings.l_no_var,
      "Gross": localizedStrings.l_gross_var,
      "Tare": localizedStrings.l_tare_var,
      "Net": localizedStrings.l_net_var,
      "PCS": localizedStrings.l_pcs_var,
      "WeightUnit": localizedStrings.l_wgt_unit_var,
      "DATE": localizedStrings.l_date_var,
      "TIME": localizedStrings.l_time_var,
      "U.WGT": localizedStrings.l_uwgt_var,
      "U.WU": localizedStrings.l_uwu_var,
      "UnitWeight": localizedStrings.l_unit_wgt_var,
      "Percent": localizedStrings.l_percent_var,
      "TotalWeight": localizedStrings.l_total_wgt_var,
      "TotalCount": localizedStrings.l_total_cnt_var,
      "TotalPcs": localizedStrings.l_total_pcs_var,
    };

    langVarExplMap = {
      "Line": localizedStrings.l_line_expl,
      "Text": localizedStrings.l_text_expl,
      "BarCode": localizedStrings.l_barcode_expl,
      "Qrcode": localizedStrings.l_qrcode_expl,
      "NO.": localizedStrings.l_no_expl,
      "Gross": localizedStrings.l_gross_expl,
      "Tare": localizedStrings.l_tare_expl,
      "Net": localizedStrings.l_net_expl,
      "PCS": localizedStrings.l_pcs_expl,
      "WeightUnit": localizedStrings.l_wgt_unit_expl,
      "DATE": localizedStrings.l_date_expl,
      "TIME": localizedStrings.l_time_expl,
      "U.WGT": localizedStrings.l_uwgt_expl,
      "U.WU": localizedStrings.l_uwu_expl,
      "UnitWeight": localizedStrings.l_unit_wgt_expl,
      "Percent": localizedStrings.l_percent_expl,
      "TotalWeight": localizedStrings.l_total_wgt_expl,
      "TotalCount": localizedStrings.l_total_cnt_expl,
      "TotalPcs": localizedStrings.l_total_pcs_expl,
    };
  }

  Widget _generateExpansionTileWidget(
      tittle, List<String>? names, BuildContext context) {
    final focusNode = FocusNode(canRequestFocus: false);
    return Focus(
      autofocus: false,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.arrowDown) {
          focusNode.unfocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.handled;
      },
      child: FocusableActionDetector(
          focusNode: focusNode,
          child: ExpansionTile(
            title: Text(tittle,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodySmall!.apply(
                      color: Theme.of(context).colorScheme.primary,
                    )),
            children: names!.map((name) => _generateWidget(name)).toList(),
          )),
    );
  }

  /// 生成 ExpansionTile 下的 ListView 的单个组件
  Widget _generateWidget(name) {
    text = name.split(",")[0];
    type = name.split(",")[1];
    getLanguageVarMap();
    String expStr = "";
    if (langVarExplMap[text] != "") {
      expStr = langVarExplMap[text]!;
    }
    if (langVarMap[text] != "") {
      text = langVarMap[text]!;
    }

    /// 使用该组件可以使宽度撑满
    return FractionallySizedBox(
        widthFactor: 1,
        child: Container(
          padding: const EdgeInsets.only(bottom: 10),
          height: 46,
          alignment: Alignment.center,
          child: Tooltip(
            message: expStr,
            preferBelow: false,
            verticalOffset: 10.0,
            waitDuration: const Duration(seconds: 1),
            child: TextButton(
                style: ButtonStyle(
                  side: WidgetStateProperty.all<BorderSide>(BorderSide(
                      width: 1,
                      color: Theme.of(context).colorScheme.outlineVariant)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),
                onPressed: () {
                  _saveState();
                  addFloatButton(name);
                },
                child: Container(
                  width: 150, // 固定宽度
                  height: 36, // 固定高度

                  alignment: Alignment.center,
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                )),
          ),
        ));
  }

  //左侧列表里按钮的点击事件
//在中间部分添加可拖拽控件，并添加到floatButtonList数组里，方便显示
  void addFloatButton(name) {
    DraggableElement element = addElementToList(name, lastFontSize);

    setState(() {
      elements.add(element);
    });
  }

  String csv = "";

  void _exportCSV() async {
    List<List<dynamic>> csvData = <List<dynamic>>[];
    // csvData.add(['Time', 'Name']);
    //打印正向或者反向
    if (_selectedPrintDirection == 'Forward') {
      csvData.add(['ROTATE', '0']);
    } else {
      csvData.add(['ROTATE', '0']);
    }
    int width = int.parse(_widthController.text) * 8;
    int height = int.parse(_heightController.text) * 8;

    //打印纸张大小
    csvData.add(['P', width.toString(), height.toString()]);

    for (var i = 0; i < elements.length; i++) {
      if (elements[i].type.name == 'text') {
        int fontsize = int.parse(elements[i].fontSize ?? '0');
        List fontlist = getFontSize(fontsize);
        csvData.add([
          'TB',
          elements[i].position.dx.toInt(),
          elements[i].position.dy.toInt(),
          elements[i].width,
          elements[i].height,
          fontlist[0],
          fontlist[1],
          fontlist[2],
          _getstyle(elements[i].fontBold!, elements[i].fontReverse!),
          _getRotation(elements[i].rotation!),
          'TEXT',
          elements[i].content,
          elements[i].index,
        ]);
      } else if (elements[i].type.name == 'data') {
        int fontsize = int.parse(elements[i].fontSize ?? '0');
        List fontlist = getFontSize(fontsize);
        csvData.add([
          'TB',
          elements[i].position.dx.toInt(),
          elements[i].position.dy.toInt(),
          elements[i].width,
          elements[i].height,
          fontlist[0],
          fontlist[1],
          fontlist[2],
          _getstyle(elements[i].fontBold!, elements[i].fontReverse!),
          _getRotation(elements[i].rotation!),
          'DATA',
          elements[i].varName,
          elements[i].defaultValue,
          elements[i].alignment,
          elements[i].maxLength,
          elements[i].index,
        ]);
      } else if (elements[i].type.name == 'barcode') {
        String tempContent = '';
        if (elements[i].style == 0) {
          tempContent = _barcodeContent(elements[i].varcontent!);
        } else {
          tempContent = _barcodeContent1(elements[i].varcontent!);
        }
        String barcodeType = '';
        String hrAlignment;
        if (elements[i].barcodeType == 'Code128') {
          barcodeType = '1';
        } else if (elements[i].barcodeType == 'Code39') {
          barcodeType = 'CODE39';
        } else if (elements[i].barcodeType == 'EAN8') {
          barcodeType = 'EAN8';
        } else if (elements[i].barcodeType == 'EAN13') {
          barcodeType = 'EAN13';
        } else if (elements[i].barcodeType == 'UPC-A') {
          barcodeType = 'UPCA';
        } else if (elements[i].barcodeType == 'UPC-E') {
          barcodeType = 'UPCE';
        }
        if (elements[i].hralignment == 'Top') {
          hrAlignment = 'TC';
        } else if (elements[i].hralignment == 'Bottom') {
          hrAlignment = 'BC';
        } else {
          hrAlignment = 'N';
        }
        csvData.add([
          'B',
          elements[i].position.dx.toInt(),
          elements[i].position.dy.toInt(),
          elements[i].width!.toInt(),
          elements[i].height!.toInt(),
          '2',
          barcodeType,
          _getRotation(elements[i].rotation!),
          hrAlignment,
          tempContent,
          elements[i].index,
        ]);
      } else if (elements[i].type.name == 'qrcode') {
        String tempContent = '';
        if (elements[i].style == 0) {
          tempContent = _barcodeContent(elements[i].varcontent!);
        } else {
          tempContent = _barcodeContent1(elements[i].varcontent!);
        }

        String version = '1';
        String errorlevel = '1';

        csvData.add([
          'QR',
          elements[i].position.dx.toInt(),
          elements[i].position.dy.toInt(),
          version,
          elements[i].qrWidth.toString(),
          errorlevel,
          '',
          tempContent,
          elements[i].index,
        ]);
      }
      //线条备份
      // else if (elements[i].type.name == 'line') {
      //   if (elements[i].lineWidth! <= elements[i].x2Pos!) {
      //     csvData.add([
      //       'L',
      //       elements[i].position.dx.toInt(),
      //       elements[i].position.dy.toInt(),
      //       (elements[i].x2Pos! + elements[i].position.dx.toInt()).toInt(),
      //       elements[i].position.dy.toInt(),
      //       elements[i].lineWidth!.toInt(),
      //       0, //线类型
      //       elements[i].index,
      //     ]);
      //   } else {
      //     csvData.add([
      //       'L',
      //       elements[i].position.dx.toInt(),
      //       elements[i].position.dy.toInt(),
      //       elements[i].position.dx.toInt(),
      //       (elements[i].lineWidth! + elements[i].position.dy.toInt()).toInt(),
      //       elements[i].x2Pos!.toInt(),
      //       0, //线类型
      //       elements[i].index,
      //     ]);
      //   }
      // }
//x1,y1,x2,y2,lineWidth,lineType,index
      else if (elements[i].type.name == 'line') {
        int lineWidth = elements[i].size.width.toInt();
        int lineHeight = elements[i].size.height.toInt();
        //横线
        if (lineHeight <= lineWidth) {
          csvData.add([
            'L',
            elements[i].position.dx.toInt(),
            elements[i].position.dy.toInt(),
            (lineWidth + elements[i].position.dx.toInt()).toInt(),
            elements[i].position.dy.toInt(),
            lineHeight,
            0, //线类型
            elements[i].index,
          ]);
          // print(csvData.last);
        } else {
          csvData.add([
            'L',
            elements[i].position.dx.toInt(),
            elements[i].position.dy.toInt(),
            elements[i].position.dx.toInt(),
            (lineHeight + elements[i].position.dy.toInt()).toInt(),
            lineWidth,
            0, //线类型
            elements[i].index,
          ]);
          // print(csvData.last);
        }
      }
    }
    csvData.add(['F', printerCtl.text, 'L']);
    csvData.add(['']);
    csv = const ListToCsvConverter(
      textDelimiter: '',
    ).convert(csvData);
    // print(csv);
  }

  void _saveFormatToCsv(String csv, String path) async {
    final file = File(path);
    csv = myFilePassword.encryptCsv(csv);
    await file.writeAsString(csv, mode: FileMode.write, encoding: utf8);
  }

  String _barcodeContent(List<dynamic> con) {
    var barcodedata = StringBuffer();
    if (con.isEmpty) {
      return barcodedata.toString();
    }
    var varalignment = 1;
    for (var i = 0; i < con.length; i++) {
      if (barcodedata.isNotEmpty) {
        barcodedata.write(',');
      }
      if (con[i].type == 'TEXT') {
        barcodedata.write('${con[i].type},${con[i].content}');
      } else {
        if (con[i].alignment == 'Center') {
          varalignment = 2;
        } else {
          varalignment = 3;
        }
        barcodedata.write(
            'DATA,${con[i].type},${con[i].defaultvalue},$varalignment,${con[i].maxlength}');
      }
    }
    return barcodedata.toString();
  }

//此处解析条码内容，本地不一定有此条码格式。都按没有此条码格式处理
  String _barcodeContent1(List<dynamic> con) {
    final barcodedata = StringBuffer(); // 使用 StringBuffer 来构建字符串
    if (con.isEmpty) {
      return barcodedata.toString();
    }
    for (final item in con) {
      if (barcodedata.isNotEmpty) {
        barcodedata.write(','); // 在前一个项目之后附加逗号分隔符
      }
      if (item is Map) {
        if (item['type'] == 'TEXT') {
          barcodedata.write('TEXT,${item['content']}');
        } else {
          var varalignment = 1;
          if (item['alignment'] == 'Center') {
            varalignment = 2;
          } else if (item['alignment'] == 'Right') {
            // 统一将未命中的情况视为 'Left'
            varalignment = 3;
          }
          barcodedata.write(
              'DATA,${item['type']},${item['defaultvalue']},$varalignment,${item['maxlength']}');
        }
      } else {
        if (item.type == 'TEXT') {
          barcodedata.write('TEXT,${item.content}');
        } else {
          var varalignment = 1;
          if (item.alignment == 'Center') {
            varalignment = 2;
          } else if (item.alignment == 'Right') {
            // 统一将未命中的情况视为 'Left'
            varalignment = 3;
          }
          barcodedata.write(
              'DATA,${item.type},${item.defaultvalue},$varalignment,${item.maxlength}');
        }
      }
    }
    return barcodedata.toString();
  }

  int _getRotation(int rotation) {
    if (rotation == 90) {
      return 1;
    } else if (rotation == 180) {
      return 2;
    } else if (rotation == 270) {
      return 3;
    } else {
      return 0;
    }
  }

  String _getstyle(String fontBold, String fontReverse) {
    if (fontBold == 'true' && fontReverse == 'false') {
      return '2';
    } else if (fontBold == 'true' && fontReverse == 'true') {
      return '3';
    } else if (fontBold == 'false' && fontReverse == 'true') {
      return '1';
    } else {
      return '0';
    }
  }

  List getFontSize(int sFont) {
    int fontsize = 4;
    int width = 1;
    int height = 1;
    if (sFont == 23) {
      fontsize = 4;
    } else if (sFont == 20) {
      fontsize = 1;
    } else if (sFont == 39) {
      fontsize = 1;
      width = 2;
      height = 2;
    } else if (sFont == 46) {
      fontsize = 4;
      width = 2;
      height = 2;
    } else if (sFont == 69) {
      fontsize = 4;
      width = 3;
      height = 3;
    } else if (sFont == 95) {
      width = 4;
      height = 4;
    } else if (sFont == 115) {
      fontsize = 4;
      width = 5;
      height = 5;
    } else if (sFont == 137) {
      width = 6;
      height = 6;
    } else if (sFont == 165) {
      width = 7;
      height = 7;
    } else if (sFont == 170) {
      width = 8;
      height = 8;
    }

    return [fontsize, width, height];
  }

  void _saveFormatToJson(String path) {
    List formatDataList = [];
    for (var i = 0; i < elements.length; i++) {
      FromateItemData formatdata = FromateItemData(
        type: elements[i].type.name,
        xPos: elements[i].position.dx.toInt(),
        yPos: elements[i].position.dy.toInt(),
        width: elements[i].size.width,
        height: elements[i].size.height,
        fontSize: int.parse(elements[i].fontSize!),
        fontWidthRatio: int.parse(elements[i].fontHeightRatio.toString()),
        fontHeightRatio: int.parse(elements[i].fontHeightRatio.toString()),
        alignment: (elements[i].alignment!) == 'Left'
            ? 1
            : (elements[i].alignment!) == 'Center'
                ? 2
                : 3,
        maxLength: int.parse(elements[i].maxLength.toString()),
        rotation: elements[i].rotation!,
        style: int.parse(
            _getstyle(elements[i].fontBold!, elements[i].fontReverse!)),
        tabOrder: elements[i].index!,
        varName: elements[i].varName!,
        content: elements[i].content!,
        defaultValue: elements[i].defaultValue!,
        varcontent: elements[i].varcontent!,
        barcodeName: elements[i].barcodeName!,
        barcodeType: elements[i].barcodeType!,
        hralignment: elements[i].hralignment!,
        x2Pos: elements[i].position.dx.toInt(),
        y2Pos: elements[i].position.dy.toInt(),
        lineWidth: elements[i].lineWidth!,
        qrWidth: elements[i].qrWidth!,
        qrcodeName: elements[i].qrcodeName!,
        qrcodeType: elements[i].qrcodeType!,
        fontBold: elements[i].fontBold!,
        fontReverse: elements[i].fontReverse!,
      );
      formatDataList.add(formatdata);
    }

    _saveFormatDataToJson(formatDataList, path);
  }

  _saveFormatDataToJson(List list, String path) async {
    try {
      if (list.isNotEmpty) {
        String json = jsonEncode(list);
        // print(json);

        FormatContent myFormatContent = FormatContent(
            page: '${_widthController.text}*${_heightController.text}',
            rotation: _selectedPrintDirection,
            content: json,
            printer: printerCtl.text,
            prtType: 'L');

        String formatjson = jsonEncode(myFormatContent);

        // final file = await _localFilepath; ///////获取固定位置
        final file = File(p.join(path));
        // 将字符串写入文件中
        // print(formatjson);
        file.writeAsStringSync(formatjson);

        // await loadData();   此处已经写好了如何捞回来条码信息
      }
    } catch (e) {
      setState(() {
        showTipInfo('$e Save fail', context);
      });
    }
  }

  //判断文件是否是图片且是否真实存在
  bool isImagePath(String path) {
    // 定义常见的图片文件扩展名
    const List<String> imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp'
    ];

    // 创建文件对象
    File file = File(path);

    // 检查文件是否存在
    if (!file.existsSync()) {
      return false;
    }

    // 获取文件的扩展名
    String extension = path.substring(path.lastIndexOf('.')).toLowerCase();

    // 判断扩展名是否在图片扩展名列表中
    return imageExtensions.contains(extension);
  }

  // List<int> stringToGb2312Bytes(String str) {
  //   var encoder = gbk.encode(str);
  //   return encoder.toList();
  // }

  List<int> convertList(List<int> inputList) {
    var resultList = <int>[];
    for (var i = 0; i < inputList.length; i++) {
      var value = (inputList[i] >> 8) & 0xFF;
      if (value != 0) {
        resultList.add(value);
      }
      value = (inputList[i] & 0xFF);
      resultList.add(value);
    }
    return resultList;
  }

  void redrawInterface(List list) {
    //判断条码，二维码在不在

    setState(() {
      for (var i = 0; i < list.length; i++) {
        // temptextItemList[i].index = i;
        FromateItemData formData = list[i];
        String barcodeName = _savedBarCodeNames.contains(formData.barcodeName)
            ? formData.barcodeName
            : '--';
        String qrcodeName = _savedQrcodeNames.contains(formData.qrcodeName)
            ? formData.qrcodeName
            : '--';

        elements.add(DraggableElement(
          position: Offset(formData.xPos.toDouble(), formData.yPos.toDouble()),
          size: Size(formData.width.toDouble(), formData.height.toDouble()),
          type: formData.type == "TEXT" || formData.type == "text"
              ? ElementType.text
              : formData.type == "DATA" || formData.type == "data"
                  ? ElementType.data
                  : formData.type == "BarCode" || formData.type == "barcode"
                      ? ElementType.barcode
                      : formData.type == "Qrcode" || formData.type == "qrcode"
                          ? ElementType.qrcode
                          : formData.type == "Line" || formData.type == "line"
                              ? ElementType.line
                              : formData.type == "IMG" || formData.type == "img"
                                  ? ElementType.img
                                  : ElementType.text,
          index: (i),
          content: formData.content,
          xPos: formData.xPos,
          yPos: formData.yPos,
          width: formData.width,
          height: formData.height,
          fontSize: formData.fontSize.toString(),
          fontWidthRatio: formData.fontWidthRatio,
          fontHeightRatio: formData.fontHeightRatio,
          style: 1,
          rotation: formData.rotation,
          defaultValue: formData.defaultValue,
          alignment: formData.alignment == 1
              ? "Left"
              : formData.alignment == 2
                  ? "Center"
                  : "Right",
          maxLength: formData.maxLength,
          tabOrder: formData.tabOrder,
          varName: formData.varName,
          varcontent: formData.varcontent,
          barcodeName: barcodeName,
          barcodeType: formData.barcodeType,
          hralignment: formData.hralignment,
          x2Pos: formData.x2Pos,
          y2Pos: formData.y2Pos,
          lineWidth: formData.lineWidth,
          qrWidth: formData.qrWidth,
          qrcodeName: qrcodeName,
          qrcodeType: formData.qrcodeType,
          fontBold: formData.fontBold,
          fontReverse: formData.fontReverse,
        ));
      }
    });
  }

  Future _openJsonFile(String path) async {
    try {
      var file = File(p.join(path)); //await _localFilepath;
      String jsonString = await file.readAsString();
      readTextInfoListFromStr(jsonString);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString(),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.normal)),
            duration: const Duration(seconds: 1),
            backgroundColor: Theme.of(context).colorScheme.error));
      }
    }
  }

  Future readTextInfoListFromStr(String dataStr) async {
    List textInfoList = [];

    FormatContent fromatContent = FormatContent.fromJson(jsonDecode(dataStr));
    if (fromatContent.prtType != null && fromatContent.prtType == 'P') {
      showTipInfo(localizedStrings.l_open_fmt_err, context);
      return;
    }

    setState(() {
      List<String> sizes = fromatContent.page.split('*');

      if (sizes.length == 2) {
        String num1 = sizes[0];
        String num2 = sizes[1];
        _widthController.text = num1;
        _heightController.text = num2;
      }

      bool hasPrint =
          _printers.any((element) => element == fromatContent.printer);
      if (hasPrint) {
        printerCtl.text = fromatContent.printer.toString();
      }

      if (printDirections.contains(fromatContent.rotation)) {
        _selectedPrintDirection = fromatContent.rotation;
        printDirectionCtl.text = _selectedPrintDirection;
      }
      updateCanvasSize(context);
    });
    List jsonList = jsonDecode(fromatContent.content);
    for (var json in jsonList) {
      FromateItemData formData = FromateItemData.fromJson(json);
      if (formData.width == 20 || formData.height == 50) {
        formData.width = 70;
        formData.height = 30;
        if (formData.type == "BarCode" || formData.type == "barcode") {
          formData.height = 50;
        }
      }
      textInfoList.add(formData);
    }

    // textInfoList = getElementInfoFromFile(fromatContent.content);

    if (textInfoList.isNotEmpty) {
      redrawInterface(textInfoList);
    }
  }

  void _openAIDesignDialog() {
    showDialog(
      context: context,
      builder: (context) => AIDesignDialog(
        apiKey: 'sk-1ceff395c8a44ad5898f4ab8d540ee0d',
        onApply: (generatedElements, width, height, printer, direction) {
          setState(() {
            _widthController.text = width.toInt().toString();
            _heightController.text = height.toInt().toString();
            printerCtl.text = printer;
            _selectedPrintDirection =
                (direction == '1' ? 'Reverse' : 'Forward');
            printDirectionCtl.text = direction;
            elements = generatedElements;
            updateCanvasSize(context);
          });
        },
      ),
    );
  }

  Widget showHeadWidget(double width) {
    return Container(
      height: topBtnHeight,
      width: width - 10,
      color: Theme.of(context).colorScheme.onPrimary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            child: Row(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: Text(
                                localizedStrings.gPrinter,
                                textAlign: TextAlign.right,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 150, // 设置固定宽度
                              child: showDropDownButton(
                                  context, '', printerCtl, _printers,
                                  (String? newValue) {
                                setState(() {
                                  printerCtl.text = newValue!;
                                });
                              }),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: Text(
                                localizedStrings.gPrintDirection,
                                textAlign: TextAlign.right,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 150, // 设置固定宽度
                              child: showDropDownButton(
                                  context,
                                  '',
                                  printDirectionCtl,
                                  printDirections, (String? newValue) {
                                setState(() {
                                  _selectedPrintDirection = newValue!;
                                });
                              }),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            buildBtnText(localizedStrings.gPageWidth + '(mm):'),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                                width: 80, // 设置固定宽度
                                height: 48,
                                child: showInputBox(
                                    context, _widthController, '', (value) {
                                  updateCanvasSize(context);
                                }, true, focusNode: _canvasWidthFocusNode))
                          ],
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            buildBtnText(
                                localizedStrings.gPageHeight + '(mm):'),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                                width: 80, // 设置固定宽度
                                height: 48,
                                child: showInputBox(
                                    context, _heightController, '', (value) {
                                  updateCanvasSize(context);
                                }, true, focusNode: _canvasHeightFocusNode))
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: btnWidth,
                        height: 40,
                        child: showTextButton(
                            context, 40, localizedStrings.gBtnNewFormat, () {
                          deleteAllElements();
                        },
                            Theme.of(context).colorScheme.onPrimary,
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.onPrimary)),
                    SizedBox(
                        width: btnWidth,
                        height: 40,
                        child: showTextButton(context, 40, 'AI Design', () {
                          _openAIDesignDialog();
                        },
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.onPrimaryContainer,
                            Theme.of(context).colorScheme.primaryContainer)),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: btnWidth,
                        height: 40,
                        child: showTextButton(
                            context, 40, localizedStrings.gBarcodeEdit,
                            () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const MyBarCodeDialog();
                            },
                          ).then((value) {
                            setState(() {
                              _saveBarCodeNameToList();
                            });
                          });
                        },
                            Theme.of(context).colorScheme.onPrimary,
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.onPrimary)),
                    SizedBox(
                        width: btnWidth,
                        height: 40,
                        child: showTextButton(
                            context, 40, localizedStrings.gOpenJson, () async {
                          String filePath = '';
                          try {
                            String executablePath = Platform.resolvedExecutable;
                            var directory = p.dirname(executablePath);

                            final formatfilePath =
                                Directory('$directory\\format');
                            if (!await formatfilePath.exists()) {
                              await formatfilePath.create(recursive: true);
                            }
                            directory = formatfilePath.path;
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              initialDirectory: directory,
                              type: FileType.custom,
                              allowedExtensions: ['json'],
                            );
                            if (result != null && result.files.isNotEmpty) {
                              filePath = result.files.single.path!;
                            }
                          } catch (e) {
                            setState(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Open fail',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall), ////此处需要秤回复
                                      duration: const Duration(seconds: 1),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error));
                            });
                          }
                          if (filePath != '') {
                            deleteAllElements();
                            _openJsonFile(filePath);
                          }
                        },
                            Theme.of(context).colorScheme.onPrimary,
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.onPrimary)),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: btnWidth,
                        height: 40,
                        child: showTextButton(
                            context, 40, localizedStrings.gQrcodeEdit,
                            () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const MyQrcodeDialog();
                            },
                          ).then((value) {
                            setState(() {
                              _saveQrcodeNameToList();
                            });
                          });
                        },
                            Theme.of(context).colorScheme.onPrimary,
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.onPrimary)),
                    SizedBox(
                        width: btnWidth,
                        height: 40,
                        child: showTextButton(
                            context, 40, localizedStrings.gSaveFormat,
                            () async {
                          String executablePath = Platform.resolvedExecutable;
                          var directory = p.dirname(executablePath);
                          final formatfilePath =
                              Directory('$directory\\format');
                          if (!await formatfilePath.exists()) {
                            await formatfilePath.create(recursive: true);
                          }
                          directory = formatfilePath.path;

                          String? outputFile =
                              (await FilePicker.platform.saveFile(
                            initialDirectory: directory,
                            dialogTitle: 'Output file:',
                            type: FileType.custom,
                            allowedExtensions: ['fmt'],
                            fileName: 'format.fmt',
                          ));
                          if (outputFile != null) {
                            if (!outputFile.contains(".fmt")) {
                              outputFile = "$outputFile.fmt";
                            }

                            _exportCSV();
                            _saveFormatToCsv(csv, outputFile);
                            String jsonFilePath =
                                outputFile.replaceAll('.fmt', '.json');
                            _saveFormatToJson(jsonFilePath); //同时保存一份到json
                          }
                          ////添加实现
                        },
                            Theme.of(context).colorScheme.onPrimary,
                            Theme.of(context)
                                .colorScheme
                                .onTertiaryFixedVariant,
                            Theme.of(context).colorScheme.onPrimary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBtnText(String textStr) {
    return SizedBox(
      width: textWidth,
      child: Text(
        textStr,
        textAlign: TextAlign.right,
        style: Theme.of(context).textTheme.bodySmall!.apply(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  _textproperties(DraggableElement element) {
    return [
      buildAttributeText(context, localizedStrings.gAttribute),
      buildDivider(),
      buildTabOrderAndTyptTextNew(
          context, localizedStrings.gTipItemType, element.type.name),
      showRightItemTitleText(context, localizedStrings.gPosition),
      ...buildXYPosition(),
      ...buildShowHeightWidth(),
      showRightItemTitleText(context, localizedStrings.gTextContent),
      buildTextField(
        _textController,
      ),
      ...showFontSize(),
      ...showRotation(),
      ...showFontBold(),
      ...showFontReverse(),
      deleteBtnBuild(),
    ];
  }

  TextField buildTextField(
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      onChanged: (value) {
        updateTextContent();
      },
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  Widget deleteBtnBuild() {
    return SizedBox(
        width: 200,
        child: showTextButton(context, btnHeight, localizedStrings.gBtnDelete,
            () {
          setState(() {
            deleteSelectedElements();
          });
        },
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.error,
            Theme.of(context).colorScheme.onPrimary));
  }

  List<Widget> buildXYPosition() {
    return [
      Row(
        children: [
          Container(
            height: 48,
            width: 50,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(right: smallPadding),
            child: Text("X:",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: TextField(
              enabled: false,
              controller: _positionXController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
        ],
      ),
      SizedBox(
        height: smallPadding,
      ),
      Row(
        children: [
          Container(
            height: 48,
            width: 50,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(right: smallPadding),
            child: Text("Y:",
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: TextField(
              enabled: false,
              controller: _positionYController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> buildShowHeightWidth() {
    return [
      Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(localizedStrings.gPageWidth,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: TextField(
              controller: _textWidthController,
              focusNode: textWidthFocusNode,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.bodySmall!.apply(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              style: Theme.of(context).textTheme.bodySmall,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+(?:\.\d{1,2})?$')),
              ],
              onChanged: (value) {
                updateTextSize(context);
                textWidthFocusNode.requestFocus();
              },
            ),
          ),
        ],
      ),
      Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(localizedStrings.gPageHeight,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: TextField(
              controller: _textHeightController,
              focusNode: textHeightFocusNode,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelStyle: Theme.of(context).textTheme.bodySmall!.apply(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              style: Theme.of(context).textTheme.bodySmall,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+(?:\.\d{1,2})?$')),
              ],
              onChanged: (value) {
                updateTextSize(context);
                textHeightFocusNode.requestFocus();
              },
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> showFontSize() {
    return [
      showRightItemTitleText(context, localizedStrings.gFontSize),
      buildDropdownButton(
        context: context,
        value: lastFontSize.toString(),
        items: fontSizes,
        hintText: localizedStrings.gFontSize,
        onSelect: updateFontSize,
      ),
    ];
  }

  List<Widget> showRotation() {
    return [
      showRightItemTitleText(context, localizedStrings.gRotation),
      buildDropdownButton(
        context: context,
        value: _selectedRotation,
        items: rotations,
        hintText: localizedStrings.gRotation,
        onSelect: rotateSelectedElement,
      ),
    ];
  }

  List<Widget> showFontBold() {
    return [
      showRightItemTitleText(context, localizedStrings.gFontBold),
      buildDropdownButton(
        context: context,
        value: _selectFontBold,
        items: fontBoldReverse,
        hintText: localizedStrings.gFontBold,
        onSelect: fontBoldSelectedElement,
      ),
    ];
  }

  List<Widget> showFontReverse() {
    return [
      showRightItemTitleText(context, localizedStrings.gFontReverse),
      buildDropdownButton(
        context: context,
        value: _selectFontReverse,
        items: fontBoldReverse,
        hintText: localizedStrings.gFontReverse,
        onSelect: fontReverseSelectedElement,
      ),
    ];
  }

  List<Widget> showAlignment() {
    return [
      showRightItemTitleText(context, localizedStrings.gHrAlignment),
      buildDropdownButton(
        context: context,
        value: _selectedAlignment,
        items: alignments,
        hintText: localizedStrings.gHrAlignment,
        onSelect: alignmentSelectedElement,
      ),
    ];
  }

  _varproperties(DraggableElement element) {
    return [
      buildAttributeText(context, localizedStrings.gAttribute),
      buildDivider(),
      buildTabOrderAndTyptTextNew(
          context, localizedStrings.l_var_title, element.varName!),
      showRightItemTitleText(context, localizedStrings.gPosition),
      ...buildXYPosition(),
      ...buildShowHeightWidth(),
      const SizedBox(height: 20),
      SizedBox(
        width: 100,
        child: Text(localizedStrings.gMaxLength,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodySmall),
      ),
      TextField(
        controller: maxLenthController,
        onChanged: (value) {
          updateMaxLenth(context);
        },
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(width: 10),
      ...showAlignment(),
      ...showRotation(),
      ...showFontSize(),
      ...showFontBold(),
      ...showFontReverse(),
      deleteBtnBuild(),
    ];
  }

  _barCodeproperties(DraggableElement element) {
    return [
      buildAttributeText(context, localizedStrings.gAttribute),
      buildDivider(),
      buildTabOrderAndTyptTextNew(
          context, localizedStrings.gTipItemType, element.type.name),
      showRightItemTitleText(context, localizedStrings.gPosition),
      ...buildXYPosition(),
      showRightItemTitleText(context, localizedStrings.gBarcode),
      buildDropdownButton(
        context: context,
        value: _savedBarCodeNames.contains(_selectedBarcode)
            ? _selectedBarcode
            : '--',
        items: _savedBarCodeNames,
        hintText: localizedStrings.gBarcode,
        onSelect: _handleBarcodeSelected,
      ),
      ...buildShowHeightWidth(),
      showRightItemTitleText(context, localizedStrings.gHrAlignment),
      buildDropdownButton(
        context: context,
        value: _selectedHRAlignment,
        items: hralignments,
        hintText: localizedStrings.gHrAlignment,
        onSelect: hralignmentSelectedElement,
      ),
      ...showRotation(),
      const SizedBox(height: 5),
      deleteBtnBuild(),
    ];
  }

  _qrcodeproperties(DraggableElement element) {
    return [
      buildAttributeText(context, localizedStrings.gAttribute),
      buildDivider(),
      buildTabOrderAndTyptTextNew(
          context, localizedStrings.gTipItemType, element.type.name),
      showRightItemTitleText(context, localizedStrings.gPosition),
      ...buildXYPosition(),
      showRightItemTitleText(context, localizedStrings.gQrcode),
      buildDropdownButton(
        context: context,
        value: _savedQrcodeNames.contains(_selectedQrcode)
            ? _selectedQrcode
            : '--',
        items: _savedQrcodeNames,
        hintText: localizedStrings.gQrcode,
        onSelect: _handleQrcodeSelected,
      ),
      showRightItemTitleText(context, localizedStrings.gQrcodeWidth),
      buildDropdownButton(
        context: context,
        value: _selectedQrWidth,
        items: qrWidths,
        hintText: localizedStrings.gQrcodeWidth,
        onSelect: _handleQrWidthSelected,
      ),
      const SizedBox(height: 5),
      deleteBtnBuild(),
    ];
  }

  _lineproperties(DraggableElement element) {
    return [
      buildAttributeText(context, localizedStrings.gAttribute),
      buildDivider(),
      buildTabOrderAndTyptTextNew(
          context, localizedStrings.gTipItemType, element.type.name),
      showRightItemTitleText(context, localizedStrings.gPosition),
      ...buildXYPosition(),
      ...buildShowHeightWidth(),
      const SizedBox(height: 5),
      deleteBtnBuild(),
    ];
  }

  _imageProperties(DraggableElement element) {
    return [
      buildAttributeText(context, localizedStrings.gAttribute),
      buildDivider(),
      buildTabOrderAndTyptTextNew(
          context, localizedStrings.gTipItemType, element.type.name),
      showRightItemTitleText(context, localizedStrings.gPosition),
      ...buildXYPosition(),
      ...buildShowHeightWidth(),
      const SizedBox(
        height: 5,
      ),
      Container(
        height: 20,
        color: Theme.of(context).colorScheme.tertiary,
        child: Text(
          'editor',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall!.apply(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
      SizedBox(
        height: 10,
      ),
      Text(
        localizedStrings.l_var_title,
        style: Theme.of(context).textTheme.bodySmall!.apply(),
      ),
      showVarSelect(),
      SizedBox(
        height: 10,
      ),
      SizedBox(
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Image path:',
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodySmall),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color:
                        Theme.of(context).colorScheme.primary, // 边框颜色，这里使用主题的主色
                    width: 1, // 边框宽度为 2 像素
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // 边框圆角半径为 8 像素
                  ),
                ),
                onPressed: _pickImage,
                child: const Text('Select Image'),
              ),
            ],
          )),
      SizedBox(
        height: 10,
      ),
      Container(
        // 设置边框样式
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary, // 边框颜色为蓝色
            width: 1, // 边框宽度为 2 像素
          ),
          borderRadius: BorderRadius.circular(4), // 边框圆角半径为 8 像素
        ),
        padding: EdgeInsets.all(10), // 设置内边距为 10 像素
        child: Text(
          element.content.toString(),
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.bodySmall!.apply(),
        ),
      ),
      SizedBox(
        height: 10,
      ),
      Text(
        'select_rotation',
        style: Theme.of(context).textTheme.bodySmall!.apply(),
      ),
      buildDropdownButton(
        context: context,
        value: _selectedRotation,
        items: imgRotations,
        hintText: 'Rotation',
        onSelect: rotateSelectedElement,
      ),
      SizedBox(
        height: 10,
      ),
      deleteBtnBuild(),
    ];
  }

  Widget showVarSelect() {
    if (selectedElements.length != 1) {
      return Container();
    }
    if (!_variables.contains(selectedElements.first.varName)) {
      selectedElements.first.varName = "";
    }
    selectedVarCtl.text = selectedElements.first.varName ?? "";
    return DropdownButtonFormField<String>(
      value: selectedVarCtl.text,
      items: _variables
          .map((e) => DropdownMenuItem<String>(
                value: e,
                child: Text(e,
                    style: Theme.of(context).textTheme.bodySmall!.apply()),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedVarCtl.text = value.toString();

          selectedElements.first.varName = selectedVarCtl.text;
        });
      },
    );
  }

  ListView showAttributeInfo() {
    return ListView(
        children: (selectedElements.length != 1)
            ? _selectItem()
            : (selectedElements.first.type == ElementType.text)
                ? _textproperties(selectedElements.first)
                : (selectedElements.first.type == ElementType.data)
                    ? _varproperties(selectedElements.first)
                    : (selectedElements.first.type == ElementType.barcode)
                        ? _barCodeproperties(selectedElements.first)
                        : (selectedElements.first.type == ElementType.qrcode)
                            ? _qrcodeproperties(selectedElements.first)
                            : (selectedElements.first.type ==
                                        ElementType.line ||
                                    selectedElements.first.type ==
                                        ElementType.lineDiagonal)
                                ? _lineproperties(selectedElements.first)
                                : (selectedElements.first.type ==
                                        ElementType.img)
                                    ? _imageProperties(selectedElements.first)
                                    : []);
  }

//画布部分
  Stack buildCanvasPart() {
    return Stack(
      children: [
        Positioned(
          left: canvasOffset.dx,
          top: canvasOffset.dy,
          child: GestureDetector(
            onPanStart: (details) {
              bool isClickOnElement = elements.any((element) {
                double left = element.position.dx;
                double top = element.position.dy;
                double right = element.position.dx + element.size.width;
                double bottom = element.position.dy + element.size.height;
                return details.localPosition.dx >= left &&
                    details.localPosition.dx <= right &&
                    details.localPosition.dy >= top &&
                    details.localPosition.dy <= bottom;
              });

              if (isClickOnElement) {
                if (selectedElements.isEmpty) {
                  startSelection(details.localPosition);
                } else {
                  isMovingSelected = true;
                }
              } else {
                clearSelection();
                if (selectedElements.isEmpty) {
                  startSelection(details.localPosition);
                }
              }
            },
            onPanUpdate: (details) {
              if (isSelecting) {
                updateSelection(details.localPosition);
              } else if (isMovingSelected) {
                moveSelectedElements(details.delta);
              }
            },
            onPanEnd: (details) {
              if (isSelecting) {
                endSelection();
              } else {
                isMovingSelected = false;
              }
            },
            child: Container(
              width: canvasSize.width + 2,
              height: canvasSize.height + 2,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Stack(
                children: [
                  ...elements.map((element) {
                    Widget child;
                    int quarterTurns = (element.rotation! / 90).round();
                    switch (element.type) {
                      case ElementType.text:
                      case ElementType.data:
                        String displayContent = element.content ?? '';
                        if (element.type == ElementType.data &&
                            element.varName != null &&
                            element.varName!.isNotEmpty) {
                          getLanguageVarMap();
                          displayContent = langVarMap[element.varName] ??
                              element.varName ??
                              '';
                        }
                        if (displayContent.isEmpty &&
                            element.type == ElementType.text) {
                          displayContent = 'Text';
                        }

                        child = RotatedBox(
                          quarterTurns: quarterTurns,
                          child: SizedBox(
                              width: element.size.width,
                              height: element.size.height,
                              child: Text(displayContent,
                                  softWrap: true,
                                  style: TextStyle(
                                      fontFamily: "simsunb",
                                      fontSize: double.parse(
                                          element.fontSize.toString()),
                                      color: (element.fontReverse == 'true')
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                      fontWeight: (element.fontBold == 'true')
                                          ? FontWeight.bold
                                          : FontWeight.normal))),
                        );
                        break;

                      case ElementType.line:
                        child = RotatedBox(
                          quarterTurns: quarterTurns,
                          child: Container(
                            width: element.size.width + 2,
                            height: element.size.height + 2,
                            color: Colors.black,
                          ),
                        );
                        break;

                      case ElementType.lineDiagonal:
                        child = RotatedBox(
                          quarterTurns: quarterTurns,
                          child: CustomPaint(
                            painter: DiagonalLinePainter(),
                          ),
                        );
                        break;
                      case ElementType.img:
                        child = RotatedBox(
                            quarterTurns: quarterTurns,
                            child: Image.file(
                              File(element.content == "image"
                                  ? 'assets/images/grey_circle.png'
                                  : element.content!),
                              fit: BoxFit.fill, // 根据需要调整图片的填充方式
                            ));

                        break;
                      case ElementType.barcode:
                        child = RotatedBox(
                          quarterTurns: quarterTurns,
                          child: BarcodeWidget(
                            barcode: getBarcodeType(element.barcodeType!),
                            data: getBarcodeContant(element.barcodeType!),
                            drawText: (element.hralignment == 'Bottom')
                                ? true
                                : false,
                            width: [90, 270].contains(element.rotation)
                                ? element.size.height < 0
                                    ? 20
                                    : element.size.height
                                : element.size.width < 0
                                    ? 20
                                    : element.size.width,
                            height: [90, 270].contains(element.rotation)
                                ? element.size.width < 0
                                    ? 20
                                    : element.size.width
                                : element.size.height < 0
                                    ? 20
                                    : element.size.height,
                          ),
                        );

                        break;

                      case ElementType.qrcode:
                        child = BarcodeWidget(
                          barcode: Barcode.qrCode(),
                          data: element.content!,
                          // width: element.size.width,
                          // height: element.size.height,
                        );
                        break;
                      case ElementType.rectangle:
                        child = RotatedBox(
                          quarterTurns: quarterTurns,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                          ),
                        );
                        break;
                    }

                    Widget elementWidget = Container(
                      width: element.type == ElementType.line
                          ? element.size.width + 2
                          : element.size.width,
                      height: element.type == ElementType.line
                          ? element.size.height + 2
                          : element.size.height,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: element.type == ElementType.text
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .onTertiaryFixedVariant,
                          width: selectedElements.contains(element) ? 2 : 1,
                        ),
                        color: element.fontReverse! == 'true'
                            ? Theme.of(context).colorScheme.onSurface
                            : selectedElements.contains(element)
                                ? Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                : null,
                      ),
                      child: child,
                    );

                    return Positioned(
                      left: element.position.dx,
                      top: element.position.dy,
                      width: element.type == ElementType.line
                          ? element.size.width + 2
                          : element.size.width,
                      height: element.type == ElementType.line
                          ? element.size.height + 2
                          : element.size.height,
                      child: GestureDetector(
                        onTap: () {
                          selectSingleElement(element);
                        },
                        onScaleStart: (details) {
                          //鼠标移动前保存状态
                          _saveState();
                        },
                        onScaleUpdate: (details) {
                          if (details.scale == 1) {
                            if (selectedElements.contains(element)) {
                              moveSelectedElements(details.focalPointDelta);
                            } else {
                              setState(() {
                                element.position += details.focalPointDelta;
                                // 移动时选中该元素
                                selectSingleElement(element);
                              });
                            }
                          } else if (element.type == ElementType.text) {
                            setState(() {
                              element.size = Size(
                                element.size.width * details.scale,
                                element.size.height * details.scale,
                              );
                            });
                          }
                        },
                        onScaleEnd: (details) {
                          //鼠标移动后保存状态
                          _saveState();
                        },
                        onSecondaryTapDown: (details) {
                          showContextMenu(element, details.localPosition);
                        },
                        child: elementWidget,
                      ),
                    );
                  }),
                  if (isSelecting)
                    Positioned(
                      left: selectionStart!.dx < selectionEnd!.dx
                          ? selectionStart!.dx
                          : selectionEnd!.dx,
                      top: selectionStart!.dy < selectionEnd!.dy
                          ? selectionStart!.dy
                          : selectionEnd!.dy,
                      width: (selectionStart!.dx - selectionEnd!.dx).abs(),
                      height: (selectionStart!.dy - selectionEnd!.dy).abs(),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary),
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(10),
                        ),
                      ),
                    ),
                  ...alignmentLines.map((line) {
                    return Positioned(
                      left: 0,
                      top: 0,
                      child: CustomPaint(
                        painter: AlignmentLinePainter(line.start, line.end),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _selectItem() {
    return [
      const SizedBox(height: 100),
      SizedBox(
        height: 50,
        child: Text(
          localizedStrings.gMsgNoElement,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // final Size screenSize = MediaQuery.of(context).size;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();
    return KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: handleKeyEvent,
        child: Builder(builder: (scaffoldContext) {
          return Scaffold(
              body: Container(
                  width: width,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.type == "app")
                        pageHeadInfo(
                            context,
                            width - headWidthPadding,
                            localizedStrings.menuLabelDesign,
                            localizedStrings.gTipLabelDesignPageHelp, () {
                          formAppSetting = false;
                          Future.delayed(Duration.zero, () {
                            widget.onNavigate(widget.lastRouteName);
                          });
                        }),
                      Expanded(
                          child: Container(
                        color: Theme.of(context).colorScheme.surfaceBright,
                        child: Column(
                          children: [
                            showHeadWidget(width),
                            Container(
                              height: 1,
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                            SizedBox(
                              height: (widget.type == "app")
                                  ? height - topTitleHeight
                                  : height -
                                      topTitleHeight +
                                      pageTopTitleHeight,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //左侧变量部分
                                  Container(
                                    width: leftBtnWidth,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    child: Focus(
                                      autofocus: false,
                                      onKeyEvent: (node, event) {
                                        return KeyEventResult.handled;
                                      },
                                      child: ListView(
                                        children: _buildList(context),
                                      ),
                                    ),
                                  ),

                                  //中间画布部分

                                  Expanded(
                                    flex: 7,
                                    child: Scrollbar(
                                      controller: horizontalScrollController,
                                      thumbVisibility: true,
                                      child: SingleChildScrollView(
                                        scrollDirection:
                                            Axis.horizontal, // 垂直滚动
                                        controller: horizontalScrollController,
                                        child: Scrollbar(
                                          controller: verticalScrollController,
                                          thumbVisibility: false,
                                          child: SingleChildScrollView(
                                            scrollDirection:
                                                Axis.vertical, // 水平滚动
                                            controller:
                                                verticalScrollController,
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              width: canvasSize.width + 30,
                                              height: canvasSize.height + 30,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceBright,
                                                border: Border.all(
                                                  width: 0.2,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                              child: buildCanvasPart(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  //右侧属性部分
                                  Container(
                                    width: rightBtnWidth,
                                    alignment: Alignment.topLeft,
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    child: Focus(
                                      autofocus: false,
                                      onKeyEvent: (node, event) {
                                        if ((event.logicalKey ==
                                                LogicalKeyboardKey.arrowUp ||
                                            event.logicalKey ==
                                                LogicalKeyboardKey.arrowDown)) {
                                          // 处理左箭头键按下事件

                                          return KeyEventResult.handled;
                                        } else {
                                          return KeyEventResult.ignored;
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: showAttributeInfo(),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                    ],
                  )));
        }));
  }
}
