import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/pages/header_footer_page.dart';
import 'package:t_max/widget/common_widget.dart';
import '../data/manager_scale_channel.dart';
import '../data/barcoderowdata.dart';
import '../data/encrypt_data.dart';
import '../data/formatdata.dart';
import '../data/item_key_list.dart';
import '../data/language.dart';
import '../data/receipt_item.dart';
import '../data/receipt_offset.dart';
import '../data/scalecmd_data.dart';
import '../data/selectedcontrol.dart';
import '../data/writelog.dart';
import '../eventbus/eventbus.dart';
import '../functions/methods.dart';
import '../widget/dropdown_copy.dart';
import '../widget/page_head.dart';
import '../widget/receipt_draggable_floating.dart';
import '../widget/receipt_item.dart';
import 'package:path/path.dart' as p;
import '../widget/receipt_line_painter.dart';

const double receiptLineHeight = 3.9 * 8; //3.9mm *8 个点
const String recieptMode = "P";

class ReceiptDesignPage extends StatefulWidget {
  final String type;
  final Function(String) onNavigate;
  final String lastRouteName;
  const ReceiptDesignPage(
      {super.key,
      required this.type,
      required this.onNavigate,
      required this.lastRouteName});

  @override
  State<ReceiptDesignPage> createState() => _ReceiptDesignPageState();
}

const receiptVarMap = {
  "Free Text": ["Text,TEXT"],
  "Dividing Line": ["Line,Line"],
  "Weight Variable": [
    "NO.,DATA",
    "Gross,DATA",
    "Tare,DATA",
    "Net,DATA",
    "PCS,DATA",
    "WeightUnit,DATA",
    // "Date,DATA",
    // "Time,DATA",
    "DATE,DATA",
    "TIME,DATA",
    "U.WGT,DATA",
    "U.WU,DATA",
    "UnitWeight,DATA",
    "Percent,DATA",
    "TotalWeight,DATA",
    "TotalCount,DATA",
  ],
  "Price Variable": [
    "NO._P,DATA",
    "Header1_P,DATA",
    "Header2_P,DATA",
    "Header3_P,DATA",
    "Footer1_P,DATA",
    "Footer2_P,DATA",
    "Footer3_P,DATA",
    "PLU_ID_P,DATA",
    "PLU_Name_P,DATA",
    "OrderNumber_P,DATA",
    "UnitPrice_P,DATA",
    "PriceUnit_P,DATA",
    "Price_P,DATA",
    "Weight_Pcs_P,DATA",
    // "PreTare_P,DATA",
    "Tare_P,DATA",
    "Unit_P,DATA",
    "DATE,DATA",
    "TIME,DATA",
    "TaxType1_P,DATA",
    "TaxType2_P,DATA",
    "TaxType3_P,DATA",
    "TaxBase1_P,DATA",
    "TaxBase2_P,DATA",
    "TaxBase3_P,DATA",
    "TaxAmount1_P,DATA",
    "TaxAmount2_P,DATA",
    "TaxAmount3_P,DATA",
    "TaxModel_P,DATA",
    "TotalTaxAmount_P,DATA",
    "PaymentAmount_P,DATA",
    "ChangeAmount_P,DATA",
    "Subtotal_P,DATA",
    "Currency_P,DATA",
    "CopyTimes_P,DATA",
    "ModelName_P,DATA",
    "ScaleName_P,DATA",
    "TaxName_P,DATA",
    "SettleAccountTimes_P,DATA",
    "PLU_Tax_P,DATA",
    "TotalNoTax_P,DATA",
  ],
};

class _ReceiptDesignPageState extends State<ReceiptDesignPage> {
  List<ReceiptItem> receiptItemList = [];
  List<ReceiptDraggableFloating> floatButtonList = [];
  GlobalKey _parentKey = GlobalKey();
  List<int> num = [0];
  dynamic name = "Text,TEXT";
  String text = "";
  String type = '';
  int xPos = 0;
  int yPos = 0;
  int width = 0;
  int height = 50;
  int fontSize = 24;
  int fontWidthRatio = 1;
  int fontHeightRatio = 1;
  int style = 0;
  int rotation = 0;
  String varName = '';
  String defaultValue = 'data';
  int alignment = 1;
  int maxLength = 10;
  int tabOrder = 0;
  String content = '';
  String barcodeName = '--';
  String barcodeType = '';
  String hralignment = 'Bottom';
  int x2Pos = 384;
  int y2Pos = 0;
  double lineWidth = 0.5;
  String qrWidth = '3';
  String qrcodename = '--';
  String qrcodeType = 'Qrcode';
  String fontBold = 'false';
  String fontReverse = 'false';
  List<dynamic> varcontent = [];
  // Offset _offset = const Offset(0, 0);
  // bool _isDragging = false;
  final double btnWidth = 220;
  final double textWidth = 120;
  final double topTitleHeight = 300;
  final double topBtnHeight = 120;
  final double leftBtnWidth = 280;
  final double rightBtnWidth = 288;

  TextEditingController textvariable = TextEditingController();
  TextEditingController fontsizevar = TextEditingController();
  TextEditingController xPosvar = TextEditingController();
  TextEditingController yPosvar = TextEditingController();
  TextEditingController x2Posvar = TextEditingController();
  TextEditingController y2Posvar = TextEditingController();
  TextEditingController maxLenthvar = TextEditingController();
  TextEditingController barcodeHeight = TextEditingController();
  TextEditingController lineWidthVar = TextEditingController();
  TextEditingController pageWidth = TextEditingController();
  TextEditingController pageHeight = TextEditingController();
  TextEditingController printDirectionCtl =
      TextEditingController(text: 'Forward');
  TextEditingController printerCtl = TextEditingController(text: 'ESC/POS');

  var count = 0;
  dynamic _eventbus1;
  dynamic _eventbus2;
  dynamic _eventbus3;
  dynamic _eventbus4;
  dynamic _eventbus5;

  final FocusNode _focusNodeContent = FocusNode();
  final FocusNode _focusNodeFontSize = FocusNode();
  final FocusNode _focusNodexPos = FocusNode();
  final FocusNode _focusNodeyPos = FocusNode();
  final FocusNode _focusNodemaxLenth = FocusNode();
  final FocusNode _focusbarcodeHeght = FocusNode();
  final FocusNode _focusNodex2Pos = FocusNode();
  final FocusNode _focusNodey2Pos = FocusNode();
  final FocusNode _focusNodelineWidth = FocusNode();

  String _sltPrtName = 'ESC/POS';
  String _selectedAlignment = 'Left';
  String selectedBarcode = '--';
  String selectedQrcode = '--';
  String _selectedRotation = '0';
  late List<String> _savedBarCodeNames = ['--'];
  late List<String> _savedQrcodeNames = ['--'];
  String selectedHRAlignment = 'Bottom';
  String selectedQr = '3';
  String _sltPrintDir = 'Forward';
  String _selectFontBold = 'false';
  String _selectFontReverse = 'false';
  bool downloadStatus = true;
  String _selectFontsize = '24';
  double myPageWidth = 0;
  double myPageHeight = 0;
  final _lineList = [];

  List<String> paths = [];
  List<DataRow> dataRows = [];

  final List<String> _printers = ['ESC/POS', 'EPM205', 'LP50', 'ZEBRA', "TPUP"];

  final List<String> _printDirections = [
    'Forward',
    'Backward',
  ];
  final List<String> _fontBoldReverse = [
    'true',
    'false',
  ];
  final List<String> _rotations = [
    '0',
    '90',
    '180',
    '270',
  ];
  final List<String> _alignments = [
    'Left',
    'Center',
    'Right',
  ];

  final List<String> _fontSizes = [
    '24',
  ];

  Map<String, String> languageVarMap = {};
  Map<String, String> languageVarExplMap = {};

  String systemId = '';

  @override
  void initState() {
    receiptItemList;
    textvariable.text = myReceiptItemData.content;
    xPosvar.text = myReceiptItemData.xPos.toString();
    yPosvar.text = myReceiptItemData.yPos.toString();
    x2Posvar.text = myReceiptItemData.x2Pos.toString();
    y2Posvar.text = myReceiptItemData.y2Pos.toString();
    pageWidth.text = '55';
    pageHeight.text = '55';
    myPageWidth = 440;
    myPageHeight = 440;
    barcodeDataReload();
    openTemplateJson();
    addfloatbutton(name); //暂时屏蔽掉

    _eventbus1 = eventBus.on<EventRcpText>().listen((event) {
      if (mounted) {
        setState(() {
          myReceiptItemData = event.obj;
          textvariable.text = myReceiptItemData.content;
          fontsizevar.text = myReceiptItemData.fontSize.toString();
          barcodeHeight.text = myReceiptItemData.height.toString();
          _selectedRotation = myReceiptItemData.rotation.toString();
          selectedBarcode = myReceiptItemData.barcodeName;
          selectedQrcode = myReceiptItemData.qrcodeName;
          _selectFontsize = myReceiptItemData.fontSize.toString();
          selectedQr =
              int.parse(myReceiptItemData.qrWidth.toString()).toString();
          if (myReceiptItemData.alignment == 1) {
            _selectedAlignment = 'Left';
          } else if (myReceiptItemData.alignment == 2) {
            _selectedAlignment = 'Center';
          } else if (myReceiptItemData.alignment == 3) {
            _selectedAlignment = 'Right';
          }
          _selectFontBold = myReceiptItemData.fontBold;
          _selectFontReverse = myReceiptItemData.fontReverse;
          selectedHRAlignment = myReceiptItemData.hralignment;
        });
      }
    });
    _eventbus2 = eventBus.on<EventRcpOffset>().listen((event) {
      if (mounted) {
        setState(() {
          myReceiptOffsetData = event.obj;
          xPosvar.text = myReceiptOffsetData.x.toString();
          yPosvar.text = myReceiptOffsetData.y.toString();
          // _onSubmit(xPosvar.text.toString(), 2);
          // _onSubmit(yPosvar.text.toString(), 3);
          if (receiptItemList.isNotEmpty) {
            for (var i = 0; i < receiptItemList.length; i++) {
              if (receiptItemList[i].key == myReceiptOffsetData.key) {
                receiptItemList[i].xPos = myReceiptOffsetData.x.toInt();
                receiptItemList[i].yPos = myReceiptOffsetData.y.toInt();
                myReceiptItemData.tabOrder = receiptItemList[i].index;
                myReceiptItemData.type = receiptItemList[i].type;
                myReceiptItemData.xPos = receiptItemList[i].xPos;
                myReceiptItemData.yPos = receiptItemList[i].yPos;
                myReceiptItemData.height = receiptItemList[i].height;
                myReceiptItemData.width = receiptItemList[i].width;
                myReceiptItemData.style = receiptItemList[i].style;
                myReceiptItemData.fontWidthRatio =
                    receiptItemList[i].fontWidthRatio;
                myReceiptItemData.fontHeightRatio =
                    receiptItemList[i].fontHeightRatio;
                myReceiptItemData.fontSize = receiptItemList[i].fontSize;
                myReceiptItemData.maxLength = receiptItemList[i].maxLength;
                myReceiptItemData.alignment = receiptItemList[i].alignment;
                myReceiptItemData.content = receiptItemList[i].content;
                myReceiptItemData.varcontent = receiptItemList[i].varcontent;
                myReceiptItemData.defaultValue =
                    receiptItemList[i].defaultValue;
                myReceiptItemData.rotation = receiptItemList[i].rotation;
                myReceiptItemData.varName = receiptItemList[i].varName;
                myReceiptItemData.hralignment = receiptItemList[i].hralignment;
                myReceiptItemData.x2Pos = receiptItemList[i].x2Pos;
                myReceiptItemData.y2Pos = receiptItemList[i].y2Pos;
                myReceiptItemData.lineWidth = receiptItemList[i].lineWidth;
                myReceiptItemData.qrWidth = receiptItemList[i].qrWidth;
                myReceiptItemData.barcodeName = receiptItemList[i].barcodeName;
                myReceiptItemData.barcodeType = receiptItemList[i].barcodeType;
                myReceiptItemData.qrcodeName = receiptItemList[i].qrcodeName;
                myReceiptItemData.qrcodeType = receiptItemList[i].qrcodeType;
                myReceiptItemData.fontBold = receiptItemList[i].fontBold;
                myReceiptItemData.fontReverse = receiptItemList[i].fontReverse;

                myReceiptSelCtl.selectid = myReceiptItemData.tabOrder;
                myReceiptSelCtl.isSelect = true;
                eventBus.fire(EventRcpSelectedControl(myReceiptSelCtl));
                eventBus.fire(EventRcpText(myReceiptItemData));
                break;
              }
            }
          }
        });
      }
    });

    _eventbus3 = eventBus.on<EventSavedBarcodeName>().listen((event) {
      if (mounted) {
        setState(() {
          mySavedBarcodeName = event.obj;
          _savedBarCodeNames = mySavedBarcodeName.savedBarcodeName;
          if (_savedBarCodeNames.isNotEmpty) {
            selectedBarcode = _savedBarCodeNames[_savedBarCodeNames.length - 1];
          } else {
            _savedBarCodeNames = ['--'];
            selectedBarcode = _savedBarCodeNames[_savedBarCodeNames.length - 1];
          }
        });
      }
    });

    _eventbus4 = eventBus.on<EventCurrentBarCodeRowDataList>().listen((event) {
      if (mounted) {
        setState(() {
          myBarCodeRowDataList = event.obj;
        });
      }
    });

    _eventbus5 = eventBus.on<EventSavedQrcodeName>().listen((event) {
      if (mounted) {
        setState(() {
          mySavedQrcodeName = event.obj;
          _savedQrcodeNames = mySavedQrcodeName.savedQrcodeName;
          if (_savedQrcodeNames.isNotEmpty) {
            selectedQrcode = _savedQrcodeNames[_savedQrcodeNames.length - 1];
          } else {
            _savedQrcodeNames = ['--'];
            selectedQrcode = _savedQrcodeNames[_savedQrcodeNames.length - 1];
          }
        });
      }
    });

    _focusNodeContent.addListener(() {
      if (!_focusNodeContent.hasFocus) {
        _onSubmit(textvariable.text, 0);
      }
    });
    _focusNodeFontSize.addListener(() {
      if (!_focusNodeFontSize.hasFocus) {
        _onSubmit(fontsizevar.text, 1);
      }
    });
    _focusNodexPos.addListener(() {
      if (!_focusNodexPos.hasFocus) {
        _onSubmit(xPosvar.text, 2);
      }
    });
    _focusNodeyPos.addListener(() {
      if (!_focusNodeyPos.hasFocus) {
        _onSubmit(yPosvar.text, 3);
      }
    });
    // _focusNodex2Pos.addListener(() {
    //   if (!_focusNodex2Pos.hasFocus) {
    //     _onSubmit(x2Posvar.text, 9);
    //   }
    // });
    _focusNodey2Pos.addListener(() {
      if (!_focusNodey2Pos.hasFocus) {
        _onSubmit(y2Posvar.text, 10);
      }
    });
    _focusNodemaxLenth.addListener(() {
      if (!_focusNodemaxLenth.hasFocus) {
        _onSubmit(maxLenthvar.text, 4);
      }
    });

    _focusbarcodeHeght.addListener(() {
      if (!_focusbarcodeHeght.hasFocus) {
        _onSubmit(barcodeHeight.text, 7);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    _eventbus3.cancel();
    _eventbus4.cancel();
    _eventbus5.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    ScrollController scrollController = ScrollController();
    ScrollController scrollController1 = ScrollController();
    return Scaffold(
      body: Container(
          width: width,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surface),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.type == "app")
                  pageHeadInfo(
                      context,
                      width - headWidthPadding,
                      localizedStrings.menuReceiptDesign,
                      localizedStrings.gTipReceiptDesignPageHelp, () {
                    formAppSetting = false;
                    Future.delayed(Duration.zero, () {
                      widget.onNavigate(widget.lastRouteName);
                    });
                  }),
                Expanded(
                    child: Column(
                  children: [
                    showHeadWidget(width), //顶部标题栏

                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    SizedBox(
                      height: height - topTitleHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: leftBtnWidth,
                            child: ListView(
                              children: _buildList(),
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: Scrollbar(
                              controller: scrollController,
                              // isAlwaysShown: true,
                              child: ScrollConfiguration(
                                // 为水平滚动添加自定义行为
                                behavior: _ScrollbarOnlyScrollBehavior(),

                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: scrollController,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    width: 1700,
                                    height: 1000,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceBright,
                                        border: Border.all(
                                            width: 0.2,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface)),
                                    child: ScrollConfiguration(
                                      // 为水平滚动添加自定义行为
                                      behavior: _ScrollbarOnlyScrollBehavior(),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical, // 水平滚动
                                        controller: scrollController1,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  28, 0, 28, 0),
                                              //60mmX60
                                              width: _getPageWidth(),
                                              height: _getPageHeight(),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surfaceTint,
                                                  border: Border.all(
                                                      width: 0.5,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface)),
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                key: _parentKey,
                                                children: [
                                                  _buildLines(), //屏蔽横线
                                                  ...floatButtonList,
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                              width: rightBtnWidth,
                              alignment: Alignment.topLeft,
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: showAttributePart()),
                          const SizedBox(width: 10)
                        ],
                      ),
                    ),
                  ],
                )),
              ])),
    );
  }

  Widget buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  Widget showAttributePart() {
    return Container(
      width: 260,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ListView(
        children: (myReceiptItemData.tabOrder == 9999)
            ? _selectItem()
            : (myReceiptItemData.type == 'TEXT')
                ? _textproperties()
                : (myReceiptItemData.type == 'DATA')
                    ? _varproperties()
                    : (myReceiptItemData.type == 'Line')
                        ? _lineproperties()
                        : _textproperties(),
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
                                  _sltPrtName = newValue!;
                                  printerCtl.text = newValue;
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
                                  _printDirections, (String? newValue) {
                                setState(() {
                                  _sltPrintDir = newValue!;
                                  printDirectionCtl.text = newValue;
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
                                child: showInputBox(context, pageWidth, '',
                                    (value) {
                                  setState(() {});
                                }, true))
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
                                child: showInputBox(context, pageHeight, '',
                                    (value) {
                                  setState(() {});
                                }, true))
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
                        child: showTextButton(context, 40,
                            localizedStrings.menuVariableValueSetting, () {
                          HeaderFooterPage.show(context);
                        },
                            Theme.of(context).colorScheme.onPrimary,
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.onPrimary)),
                    SizedBox(
                        width: btnWidth,
                        height: 40,
                        child: showTextButton(
                            context, 40, localizedStrings.gBtnNewFormat, () {
                          deleteAllItem();
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

                            ///保存数据到csv
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
                              showTipInfo('Open fail', context);
                            });
                          }
                          if (filePath != '') {
                            deleteAllItem();
                            _openJsonFile(filePath);
                          }
                        },
                            Theme.of(context).colorScheme.onPrimary,
                            Theme.of(context).colorScheme.primary,
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

  ButtonStyle buildBtnStyle() {
    return OutlinedButton.styleFrom(
      side: BorderSide(
        width: 1,
        color: Theme.of(context).colorScheme.primary,
      ),
      foregroundColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.onPrimary, // 设置按钮的背景色
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // 设置按钮的圆角
      ),
    );
  }

  void openTemplateJson() async {
    final ByteData bytes =
        await rootBundle.load('assets/template/receipt.json');
    // 将 ByteData 直接转换为 JSON 字符串
    final jsonString = bytes.buffer.asUint8List();
    final jsonData = utf8.decode(jsonString);

    deleteAllItem();
    readTextInfoListFromStr(jsonData);
  }

  Future pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['fmt'],
    );

    if (kDebugMode) {
      print(result);
    }
    if (result != null) {
      paths = result.files.map((e) => e.path!).toList();
      setState(() {
        dataRows = [];
        for (var i = 0; i < paths.length; i++) {
          dataRows.add(
            DataRow(
              cells: [
                DataCell(
                  Text(
                    "File${i + 1}",
                  ),
                ),
                DataCell(
                  Text(
                    paths[i].toString(),
                  ),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  Widget _buildLines() {
    double height = _getPageHeight();
    double width = _getPageWidth();
    int loopTmp = height ~/ (receiptLineHeight);

    _lineList.clear();
    for (var i = 1; i <= loopTmp; i++) {
      var start = Offset(0, receiptLineHeight * i);
      var end = Offset(width, receiptLineHeight * i);
      _lineList.add(Line(start, end));
    }
    return Stack(
      children: [
        for (var i = 0; i < _lineList.length; i++)
          _buildLine(i, _lineList[i].start, _lineList[i].end),
      ],
    );
  }

  // void _updatePosition(PointerMoveEvent pointerMoveEvent) {
  //   double newOffsetX = _offset.dx + pointerMoveEvent.delta.dx;
  //   double newOffsetY = _offset.dy + pointerMoveEvent.delta.dy;

  //   setState(() {
  //     _offset = Offset(newOffsetX, newOffsetY);
  //   });
  // }

  Widget _buildLine(int index, Offset start, Offset end) {
    // _offset = start;

    return Stack(children: [
      Positioned(
        left: 0,
        top: 0,
        width: (start - end).distance,
        height: 50.0,
        child: CustomPaint(
          painter: ReceiptLinePainter(
              startPoint: _lineList[index].start,
              endPoint: _lineList[index].end),
        ),
      ),
    ]);
  }

  String pad0(int num) {
    if (num < 10) {
      return '0${num.toString()}';
    }
    return num.toString();
  }

  String getDateTime() {
    // 1 yymmdd   2 ddmmyy 3 mmddyy
    var currTime = DateTime.now();
    String format = '';

    format =
        "${currTime.year}${pad0(currTime.month)}${pad0(currTime.day)}${pad0(currTime.hour)}${pad0(currTime.minute)}${pad0(currTime.second)}";

    return format;
  }

  double _getPageWidth() {
    if (pageWidth.text.isNotEmpty) {
      double? d = double.tryParse(pageWidth.text);
      if (d != null) {
        myPageWidth = d * 8;
        if (myPageWidth > 1600) {
          myPageWidth = 1600;
          pageWidth.text = '200';
        }
        if (myPageWidth > 40) {
          x2Pos = myPageWidth.toInt() -
              56; //小票55CM  但是打印机实际打印的宽度只有384   55*8-56=384
        }

        return myPageWidth;
      }
      return 0;
    } else {
      return 0;
    }
  }

  double _getPageHeight() {
    if (pageHeight.text.isNotEmpty) {
      double? d = double.tryParse(pageHeight.text);
      if (d != null) {
        myPageHeight = d * 8;
        if (myPageHeight > 1600) {
          myPageHeight = 1600;
          pageHeight.text = '200';
        }
        return myPageHeight;
      }
      return 0;
    } else {
      return 0;
    }
  }

  void sendFormatToScale(String modifyString) async {
    myScaleCmd.cmdMode = "down_print_format_to_scale";
    myScaleCmd.cmdData = modifyString;
    PublicFunctions.sendMsg(myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
    writelog(jsonEncode(myScaleCmd));
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

  String csv = "";
  void _exportCSV() async {
    List<List<dynamic>> csvData = <List<dynamic>>[];

    //打印正向或者反向
    if (_sltPrintDir == 'Forward') {
      csvData.add(['ROTATE', '0']);
    } else {
      csvData.add(['ROTATE', '2']);
    }
    //打印纸张大小
    csvData.add(['P', myPageWidth, myPageHeight]);
    List<ReceiptItem> tempList = List.of(receiptItemList);

    tempList.sort((a, b) {
      if (a.yPos == b.yPos) {
        if (a.type == 'Line' && b.type != 'Line') {
          return -1;
        } else if (a.type != 'Line' && b.type == 'Line') {
          return 1;
        } else {
          return a.xPos.compareTo(b.xPos);
        }
      } else {
        return a.yPos.compareTo(b.yPos);
      }
    });

    for (var i = 0; i < tempList.length; i++) {
      if (tempList[i].type == 'TEXT') {
        List fontlist = getFontSize(tempList[i].fontSize);
        csvData.add([
          'TB',
          tempList[i].xPos,
          tempList[i].yPos,
          tempList[i].width,
          tempList[i].height,
          fontlist[0],
          fontlist[1],
          fontlist[2],
          _getstyle(tempList[i].fontBold, tempList[i].fontReverse),
          _getRotation(tempList[i].rotation),
          tempList[i].type,
          tempList[i].content,
          tempList[i].index,
        ]);
      } else if (tempList[i].type == 'DATA') {
        List fontlist = getFontSize(tempList[i].fontSize);
        csvData.add([
          'TB',
          tempList[i].xPos,
          tempList[i].yPos,
          tempList[i].width,
          tempList[i].height,
          fontlist[0],
          fontlist[1],
          fontlist[2],
          _getstyle(tempList[i].fontBold, tempList[i].fontReverse),
          _getRotation(tempList[i].rotation),
          tempList[i].type,
          tempList[i].varName,
          tempList[i].defaultValue,
          tempList[i].alignment,
          tempList[i].maxLength,
          tempList[i].index,
        ]);
      } else if (tempList[i].type == 'BarCode') {
        String tempContent = '';
        if (tempList[i].style == 0) {
          tempContent = _barcodeContent(tempList[i].varcontent);
        } else {
          tempContent = _barcodeContent1(tempList[i].varcontent);
        }
        String barcodeType = '';
        String hrAlignment;
        if (tempList[i].barcodeType == 'Code128') {
          barcodeType = '1';
        } else if (tempList[i].barcodeType == 'Code39') {
          barcodeType = 'CODE39';
        } else if (tempList[i].barcodeType == 'EAN8') {
          barcodeType = 'EAN8';
        } else if (tempList[i].barcodeType == 'EAN13') {
          barcodeType = 'EAN13';
        } else if (tempList[i].barcodeType == 'UPC-A') {
          barcodeType = 'UPCA';
        } else if (tempList[i].barcodeType == 'UPC-E') {
          barcodeType = 'UPCE';
        }
        if (tempList[i].hralignment == 'Top') {
          hrAlignment = 'TC';
        } else if (tempList[i].hralignment == 'Bottom') {
          hrAlignment = 'BC';
        } else {
          hrAlignment = 'N';
        }
        csvData.add([
          'B',
          tempList[i].xPos,
          tempList[i].yPos,
          tempList[i].width,
          tempList[i].height,
          '2',
          barcodeType,
          _getRotation(tempList[i].rotation),
          hrAlignment,
          tempContent,
          tempList[i].index,
        ]);
      } else if (tempList[i].type == 'Qrcode') {
        String tempContent = '';
        if (tempList[i].style == 0) {
          tempContent = _barcodeContent(tempList[i].varcontent);
        } else {
          tempContent = _barcodeContent1(tempList[i].varcontent);
        }

        String version = '1';
        String errorlevel = '1';

        csvData.add([
          'QR',
          tempList[i].xPos,
          tempList[i].yPos,
          version,
          tempList[i].qrWidth.toString(),
          errorlevel,
          '',
          tempContent,
          tempList[i].index,
        ]);
      } else if (tempList[i].type == 'Line') {
        csvData.add([
          'TB',
          tempList[i].xPos,
          tempList[i].yPos,
          tempList[i].width,
          tempList[i].height,
          '4',
          '1',
          '1',
          '0',
          '0',
          'DATA',
          'StartLoop',
          '',
          '1',
          '0',
          tempList[i].index,
        ]);
      }
    }
    csvData.add(['F', _sltPrtName, recieptMode]);
    csvData.add(['']);
    csv = const ListToCsvConverter(
      textDelimiter: '',
    ).convert(csvData);
  }

  _saveFormatDataToJson(List list, String path) async {
    try {
      if (list.isNotEmpty) {
        String json = jsonEncode(list);
        // print(json);

        FormatContent myFormatContent = FormatContent(
            page: '${pageWidth.text}*${pageHeight.text}',
            rotation: _sltPrintDir,
            content: json,
            printer: _sltPrtName,
            prtType: recieptMode);

        String formatjson = jsonEncode(myFormatContent);

        // final file = await _localFilepath; ///////获取固定位置
        final file = File(p.join(path));
        // 将字符串写入文件中
        file.writeAsStringSync(formatjson);

        // await loadData();   此处已经写好了如何捞回来条码信息
      }
    } catch (e) {
      setState(() {
        showTipInfo('$e Save fail', context);
      });
    }
  }

  Future readTextInfoListFromFile(String path) async {
    var file = File(p.join(path)); //await _localFilepath;
    String jsonString = await file.readAsString();
    readTextInfoListFromStr(jsonString);
  }

  // 读取本地文件中的文本框信息
  Future readTextInfoListFromStr(String dataStr) async {
    List textInfoList = [];
    try {
      FormatContent fromatContent = FormatContent.fromJson(jsonDecode(dataStr));
      setState(() {
        List<String> sizes = fromatContent.page.split('*');

        if (sizes.length == 2) {
          String num1 = sizes[0];
          String num2 = sizes[1];
          pageWidth.text = num1;
          pageHeight.text = num2;
        }

        if (_printDirections.contains(fromatContent.rotation)) {
          _sltPrintDir = fromatContent.rotation;
          printDirectionCtl.text = fromatContent.rotation;
        }

        if (_printers.contains(fromatContent.printer)) {
          _sltPrtName = fromatContent.printer!;
          printerCtl.text = fromatContent.printer!;
        }
      });
      // String jsonItemString = jsonDecode(fromatContent.content);
      List jsonList = jsonDecode(fromatContent.content);
      for (var json in jsonList) {
        FromateItemData formData = FromateItemData.fromJson(json);
        textInfoList.add(formData);
      }
      if (textInfoList.isNotEmpty) {
        redrawInterface(textInfoList);
      }
    } catch (e) {
      showTipInfo(e.toString(), context);
    }
    return textInfoList;
  }

  void deleteAllItem() {
    setState(() {
      receiptItemList.clear();
      myReceiptItemKey.keyList.clear();
      num.clear();
      count = 0;
      floatButtonList.clear();
      _parentKey = GlobalKey();
    });
  }

  void redrawInterface(List list) {
    setState(() {
      for (var i = 0; i < list.length; i++) {
        // tempreceiptItemList[i].index = i;
        FromateItemData formData = list[i];
        num.add(i);
        count = num.length;

        receiptItemList.add(ReceiptItem(
          key: ObjectKey(i),
          index: (i),
          content: formData.content,
          type: formData.type,
          xPos: formData.xPos,
          yPos: formData.yPos,
          width: formData.width,
          height: formData.height,
          fontSize: formData.fontSize,
          fontWidthRatio: formData.fontWidthRatio,
          fontHeightRatio: formData.fontHeightRatio,
          style: 1,
          rotation: formData.rotation,
          defaultValue: formData.defaultValue,
          alignment: formData.alignment,
          maxLength: formData.maxLength,
          tabOrder: formData.tabOrder,
          varName: formData.varName,
          varcontent: formData.varcontent,
          barcodeName: '--',
          barcodeType: formData.barcodeType,
          hralignment: formData.hralignment,
          x2Pos: formData.x2Pos,
          y2Pos: formData.y2Pos,
          lineWidth: formData.lineWidth,
          qrWidth: formData.qrWidth,
          qrcodeName: '--',
          qrcodeType: formData.qrcodeType,
          fontBold: formData.fontBold,
          fontReverse: formData.fontReverse,
        ));
        //中间页面添加最新的可拖拽控件
        floatButtonList.add(ReceiptDraggableFloating(
            index: (receiptItemList[i].index),
            key: receiptItemList[i].key,
            initialOffset: Offset(receiptItemList[i].xPos.toDouble(),
                receiptItemList[i].yPos.toDouble()),
            parentKey: _parentKey,
            onPressed: () {},
            children: [receiptItemList[i]]));
      }
    });
    reconstructItem();
  }

  void _saveFormatToJson(String path) {
    List formatDataList = [];
    for (var i = 0; i < receiptItemList.length; i++) {
      FromateItemData formatdata = FromateItemData(
        type: receiptItemList[i].type,
        xPos: receiptItemList[i].xPos,
        yPos: receiptItemList[i].yPos,
        width: receiptItemList[i].width,
        height: receiptItemList[i].height,
        fontSize: receiptItemList[i].fontSize,
        fontWidthRatio: receiptItemList[i].fontWidthRatio,
        fontHeightRatio: receiptItemList[i].fontHeightRatio,
        alignment: receiptItemList[i].alignment,
        maxLength: receiptItemList[i].maxLength,
        rotation: receiptItemList[i].rotation,
        style: receiptItemList[i].style,
        tabOrder: receiptItemList[i].tabOrder,
        varName: receiptItemList[i].varName,
        content: receiptItemList[i].content,
        defaultValue: receiptItemList[i].defaultValue,
        varcontent: receiptItemList[i].varcontent,
        barcodeName: receiptItemList[i].barcodeName,
        barcodeType: receiptItemList[i].barcodeType,
        hralignment: receiptItemList[i].hralignment,
        x2Pos: receiptItemList[i].x2Pos,
        y2Pos: receiptItemList[i].y2Pos,
        lineWidth: receiptItemList[i].lineWidth,
        qrWidth: receiptItemList[i].qrWidth,
        qrcodeName: receiptItemList[i].qrcodeName,
        qrcodeType: receiptItemList[i].qrcodeType,
        fontBold: receiptItemList[i].fontBold,
        fontReverse: receiptItemList[i].fontReverse,
      );
      formatDataList.add(formatdata);
    }

    _saveFormatDataToJson(formatDataList, path);
  }

  void _saveFormatToCsv(String csv, String path) async {
    final file = File(path);
    csv = myFilePassword.encryptCsv(csv);
    await file.writeAsString(csv, mode: FileMode.write, encoding: utf8);
  }

  // void _saveFormatToCsv(String csv) async {
  //   final directory = Directory.current.path;
  //   final file = File('$directory\\data.csv');
  //   await file.writeAsString(csv);
  // }
//utf8字符串转GB2312编码
  List<int> stringToGb2312Bytes(String str) {
    var encoder = gbk.encode(str);
    return encoder.toList();
  }

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

// 在GBK编码数据开头添加BOM标记
  List<int> addGbkBom(List<int> gbkData) {
    final bom = [0xEF, 0xBB, 0xBF];
    return bom + gbkData;
  }

  void _openJsonFile(String dataStr) {
    readTextInfoListFromFile(dataStr);
  }

  // Future<void> _loadCsvData() async {
  //   List<List<dynamic>> _data = [];
  //   final directory = Directory.current.path;
  //   final csvString = await rootBundle.loadString('$directory\\data.csv');
  //   setState(() {
  //     _data = const CsvToListConverter().convert(csvString);
  //   });
  // }

  // Future _loadCsvData() async {
  //   List<List<dynamic>> _data = [];
  //   String csvFilePath = "G:\\Labeldesign\\t_label\\data.csv";
  //   try {
  //     // 获取文件夹路径
  //     Directory appDocDir = await getApplicationDocumentsDirectory(); // 加载文件内容
  //     File csvFile = File(csvFilePath);
  //     String csvString = await csvFile.readAsString(); // 解析 CSV 文件内容并提取数据
  //     _data = const CsvToListConverter().convert(csvString);
  //   } catch (e) {}
  // }

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
    }

    return barcodedata.toString();
  }

  /// 创建列表 , 每个元素都是一个 ExpansionTile 组件
  List<Widget> _buildList() {
    List<Widget> widgets = [];
    getLanguageVarMap();
    for (var key in receiptVarMap.keys) {
      String keyStr = languageVarMap[key]!;
      widgets.add(_generateExpansionTileWidget(keyStr, receiptVarMap[key]));
    }
    return widgets;
  }

  /// 生成 ExpansionTile 组件 , children 是 [Widget] 组件
  Widget _generateExpansionTileWidget(tittle, List<String>? names) {
    return ExpansionTile(
      title: Text(tittle,
          style: Theme.of(context).textTheme.bodySmall!.apply(
                color: Theme.of(context).colorScheme.primary,
              )),
      children: names!.map((name) => _generateWidget(name)).toList(),
    );
  }

  /// 生成 ExpansionTile 下的 ListView 的单个组件
  Widget _generateWidget(name) {
    text = name.split(",")[0];
    type = name.split(",")[1];
    String expStr = "";
    if (languageVarExplMap[text] != "") {
      expStr = languageVarExplMap[text]!;
    }
    if (languageVarMap[text] != "") {
      text = languageVarMap[text]!;
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
                  count++;
                  num.add(count);
                  myReceiptItemData.tabOrder = count;
                  addfloatbutton(name);
                },
                child: Container(
                  width: 194, // 固定宽度
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

  // void _createLine() {
  //   const start = Offset(10, 100);
  //   const end = Offset(100, 100);
  //   setState(() {
  //     _lineList.add(Line(start, end));
  //   });
  // }

  void _onUpdate(int i) {
    receiptItemList.fillRange(
        i,
        i + 1,
        ReceiptItem(
          key: receiptItemList[i].key,
          index: receiptItemList[i].index,
          xPos: receiptItemList[i].xPos,
          yPos: receiptItemList[i].yPos,
          width: receiptItemList[i].width,
          varName: receiptItemList[i].varName,
          tabOrder: receiptItemList[i].tabOrder,
          style: receiptItemList[i].style,
          rotation: receiptItemList[i].rotation,
          maxLength: receiptItemList[i].maxLength,
          height: receiptItemList[i].height,
          fontWidthRatio: receiptItemList[i].fontWidthRatio,
          fontSize: receiptItemList[i].fontSize,
          fontHeightRatio: receiptItemList[i].fontHeightRatio,
          defaultValue: receiptItemList[i].defaultValue,
          content: receiptItemList[i].content,
          alignment: receiptItemList[i].alignment,
          type: receiptItemList[i].type,
          varcontent: receiptItemList[i].varcontent,
          barcodeName: receiptItemList[i].barcodeName,
          barcodeType: receiptItemList[i].barcodeType,
          hralignment: receiptItemList[i].hralignment,
          x2Pos: receiptItemList[i].x2Pos,
          y2Pos: receiptItemList[i].y2Pos,
          lineWidth: receiptItemList[i].lineWidth,
          qrWidth: receiptItemList[i].qrWidth,
          qrcodeName: receiptItemList[i].qrcodeName,
          qrcodeType: receiptItemList[i].qrcodeType,
          fontBold: receiptItemList[i].fontBold,
          fontReverse: receiptItemList[i].fontReverse,
        ));

    floatButtonList.replaceRange(
      i,
      i + 1,
      [
        ReceiptDraggableFloating(
          key: receiptItemList[i].key,
          index: i,
          initialOffset: Offset(myReceiptOffsetData.x, myReceiptOffsetData.y),
          parentKey: _parentKey,
          onPressed: () {},
          children: [receiptItemList[i]],
        )
      ],
    );
    floatButtonList;
  }

  String getShowVarName(String varName, int num) {
    if (varName.length <= num) {
      // 如果字符串长度小于等于指定长度，补充空格
      return varName.padRight(num);
    } else {
      // 如果字符串长度大于指定长度，截取指定长度
      return varName.substring(0, num);
    }
  }

  // 最后，在执行修改操作的方法中，需要将FocusNode设为失去焦点状态
  void _onSubmit(String s, int indexTemp) {
    // 执行修改操作
    if (indexTemp == 0) {
      //文本内容更新
      //文本框操作
      setState(() {
        myReceiptItemData.content = s.toString();
        for (var i = 0; i < receiptItemList.length; i++) {
          if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
            receiptItemList[i].content = myReceiptItemData.content;

            eventBus.fire(EventRcpText(myReceiptItemData));
            //修改可拖拽控件的信息
            _onUpdate(i);
          }
        }
      });
      _focusNodeContent.unfocus();
    } else if (indexTemp == 1) {
      //字体大小
      RegExp regex =
          RegExp(r"^([1-9]|[1-9]\d|1\d{2}|2[0-4]\d|500)$"); //1-50限制大小
      if (regex.hasMatch(s)) {
        setState(() {
          myReceiptItemData.fontSize = int.tryParse(s.toString())!;
          for (var i = 0; i < receiptItemList.length; i++) {
            if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
              receiptItemList[i].fontSize = myReceiptItemData.fontSize;
              eventBus.fire(EventRcpText(myReceiptItemData));
              _onUpdate(i);
            }
          }
        });
      }
    } else if (indexTemp == 2) {
      //x坐标
      setState(() {
        var ss = double.parse(s.toString());
        myReceiptItemData.xPos = ss.toInt();

        for (var i = 0; i < receiptItemList.length; i++) {
          if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
            receiptItemList[i].xPos = myReceiptItemData.xPos;
            eventBus.fire(EventRcpText(myReceiptItemData));
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 3) {
      //y坐标
      setState(() {
        var ss = double.parse(s.toString());
        myReceiptItemData.yPos = ss.toInt();

        for (var i = 0; i < receiptItemList.length; i++) {
          if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
            receiptItemList[i].yPos = myReceiptItemData.yPos;
            eventBus.fire(EventRcpText(myReceiptItemData));
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 4) {
      //最大长度
      RegExp regex = RegExp(r"^(?:0|[1-9]\d?|100)$"); //1-50限制大小
      if (regex.hasMatch(s)) {
        setState(() {
          myReceiptItemData.maxLength = int.tryParse(s.toString())!;
          for (var i = 0; i < receiptItemList.length; i++) {
            if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
              receiptItemList[i].maxLength = myReceiptItemData.maxLength;
              receiptItemList[i].content = getShowVarName(
                  receiptItemList[i].varName, receiptItemList[i].maxLength);
              eventBus.fire(EventRcpText(myReceiptItemData));
              _onUpdate(i);
            }
          }
        });
      }
      _focusNodemaxLenth.unfocus();
    } else if (indexTemp == 5) {
      //对齐方式
      setState(() {
        myReceiptItemData.alignment = int.tryParse(s.toString())!;
        for (var i = 0; i < receiptItemList.length; i++) {
          if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
            receiptItemList[i].alignment = myReceiptItemData.alignment;
            eventBus.fire(EventRcpText(myReceiptItemData));
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 6) {
      //条码类型
      int objectIndex = _findIndex(myReceiptItemData.tabOrder);
      if (objectIndex == -1) {
        return;
      }
      var tempBacodeName = s;
      String totalcontent = '';
      List<dynamic> tempcontent = [];
      setState(() {
        if (s != '--') {
          int barcodeIndex =
              _findVarcontent(tempBacodeName, myReceiptItemData.type);
          if (barcodeIndex != -1) {
            // myReceiptItemData.varcontent.clear();
            myReceiptItemData.style = 0;
            myReceiptItemData.barcodeType =
                myBarCodeListList.barCodeListList[barcodeIndex].barCodeType;
            myReceiptItemData.barcodeName =
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

          myReceiptItemData.varcontent = tempcontent;
          myReceiptItemData.content = totalcontent;
          receiptItemList[objectIndex].content = myReceiptItemData.content;
          receiptItemList[objectIndex].barcodeName =
              myReceiptItemData.barcodeName;
          receiptItemList[objectIndex].barcodeType =
              myReceiptItemData.barcodeType;
          receiptItemList[objectIndex].varcontent =
              myReceiptItemData.varcontent;
          receiptItemList[objectIndex].style =
              myReceiptItemData.style; //此处说明条码库中有此条码
          eventBus.fire(EventRcpText(myReceiptItemData));
          _onUpdate(objectIndex);
        } else {
          if (receiptItemList[objectIndex].style == 0) {
            myReceiptItemData.varcontent.clear();
            receiptItemList[objectIndex].varcontent =
                myReceiptItemData.varcontent;
            eventBus.fire(EventRcpText(myReceiptItemData));
          }
        }
      });
    } else if (indexTemp == 7) {
      //barcodeheight
      RegExp regex = RegExp(r"^(?:[1-9]|[1-9]\d|[1-4]\d\d|500)$"); //1-500限制大小
      if (regex.hasMatch(s)) {
        setState(() {
          myReceiptItemData.height = int.tryParse(s.toString())!;
          for (var i = 0; i < receiptItemList.length; i++) {
            if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
              receiptItemList[i].height = myReceiptItemData.height;
              eventBus.fire(EventRcpText(myReceiptItemData));
              _onUpdate(i);
            }
          }
        });
      }
      _focusbarcodeHeght.unfocus();
    } else if (indexTemp == 8) {
      //rotation
      setState(() {
        myReceiptItemData.rotation = int.tryParse(s.toString())!;
        for (var i = 0; i < receiptItemList.length; i++) {
          if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
            receiptItemList[i].rotation = myReceiptItemData.rotation;
            eventBus.fire(EventRcpText(myReceiptItemData));
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 9) {
      //rotation
      setState(() {
        myReceiptItemData.hralignment = s;
        for (var i = 0; i < receiptItemList.length; i++) {
          if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
            receiptItemList[i].hralignment = myReceiptItemData.hralignment;
            eventBus.fire(EventRcpText(myReceiptItemData));
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 10) {
      //x2坐标
      setState(() {
        var ss = double.parse(s.toString());
        myReceiptItemData.x2Pos = ss.toInt();

        for (var i = 0; i < receiptItemList.length; i++) {
          if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
            receiptItemList[i].x2Pos = myReceiptItemData.x2Pos;
            eventBus.fire(EventRcpText(myReceiptItemData));
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 11) {
      //y2坐标
      setState(() {
        var ss = double.parse(s.toString());
        myReceiptItemData.y2Pos = ss.toInt();

        for (var i = 0; i < receiptItemList.length; i++) {
          if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
            receiptItemList[i].y2Pos = myReceiptItemData.y2Pos;
            eventBus.fire(EventRcpText(myReceiptItemData));
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 12) {
      //条码类型   barcode
      List<dynamic> tempcontent = [];
      var tempQrcodeName = s;
      setState(() {
        if (s != '--') {
          int qrcodeIndex =
              _findVarcontent(tempQrcodeName, myReceiptItemData.type);
          if (qrcodeIndex != -1) {
            // myReceiptItemData.varcontent.clear();
            myReceiptItemData.style = 0;
            myReceiptItemData.qrcodeType =
                myBarCodeListList.barCodeListList[qrcodeIndex].barCodeType;
            myReceiptItemData.qrcodeName =
                myBarCodeListList.barCodeListList[qrcodeIndex].barCodeName;
            for (var j = 0;
                j <
                    myBarCodeListList
                        .barCodeListList[qrcodeIndex].barCodeRowDataList.length;
                j++) {
              tempcontent.add(myBarCodeListList
                  .barCodeListList[qrcodeIndex].barCodeRowDataList[j]);
            }
          }
          myReceiptItemData.varcontent = tempcontent;
          for (var i = 0; i < receiptItemList.length; i++) {
            if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
              receiptItemList[i].qrcodeName = myReceiptItemData.qrcodeName;
              receiptItemList[i].qrcodeType = myReceiptItemData.qrcodeType;
              receiptItemList[i].varcontent = myReceiptItemData.varcontent;
              receiptItemList[i].style = myReceiptItemData.style;
              eventBus.fire(EventRcpText(myReceiptItemData));
              _onUpdate(i);
            }
          }
        }
      });
    } else if (indexTemp == 13) {
      //qrcode width
      setState(() {
        myReceiptItemData.qrWidth = s;
        for (var i = 0; i < receiptItemList.length; i++) {
          if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
            receiptItemList[i].qrWidth = myReceiptItemData.qrWidth;
            eventBus.fire(EventRcpText(myReceiptItemData));
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 14) {
      //Font bold
      setState(() {
        myReceiptItemData.fontBold = s;
        for (var i = 0; i < receiptItemList.length; i++) {
          if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
            receiptItemList[i].fontBold = myReceiptItemData.fontBold;
            eventBus.fire(EventRcpText(myReceiptItemData));
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 15) {
      //Font reverse
      setState(() {
        myReceiptItemData.fontReverse = s;
        for (var i = 0; i < receiptItemList.length; i++) {
          if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
            receiptItemList[i].fontReverse = myReceiptItemData.fontReverse;
            eventBus.fire(EventRcpText(myReceiptItemData));
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 16) {
      //Font reverse
      setState(() {
        myReceiptItemData.lineWidth = double.parse(s);
        for (var i = 0; i < receiptItemList.length; i++) {
          if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
            receiptItemList[i].lineWidth = myReceiptItemData.lineWidth;
            eventBus.fire(EventRcpText(myReceiptItemData));
            _onUpdate(i);
          }
        }
      });
    } else if (indexTemp == 17) {
      //Font reverse
      setState(() {
        myReceiptItemData.x2Pos = int.parse(s);
        for (var i = 0; i < receiptItemList.length; i++) {
          if (receiptItemList[i].index == myReceiptItemData.tabOrder) {
            receiptItemList[i].x2Pos = myReceiptItemData.x2Pos;
            eventBus.fire(EventRcpText(myReceiptItemData));
            _onUpdate(i);
          }
        }
      });
    }
  }

  int _findIndex(int taborder) {
    int objectIndex = -1;

    for (var i = 0; i < receiptItemList.length; i++) {
      if (receiptItemList[i].index == taborder) {
        objectIndex = i;
        break;
      }
    }
    return objectIndex;
  }

  int _findVarcontent(String name, String type) {
    int findIndex = -1;
    for (var i = 0; i < myBarCodeListList.barCodeListList.length; i++) {
      if (myBarCodeListList.barCodeListList[i].barCodeName == name &&
          myBarCodeListList.barCodeListList[i].barCodeType == 'Qrcode' &&
          type == 'Qrcode') {
        findIndex = i;
        break;
      } else if (myBarCodeListList.barCodeListList[i].barCodeName == name &&
          myBarCodeListList.barCodeListList[i].barCodeType != 'Qrcode' &&
          type != 'Qrcode') {
        findIndex = i;
        break;
      }
    }

    return findIndex;
  }

  //左侧列表里按钮的点击事件
//在中间部分添加可拖拽控件，并添加到floatButtonList数组里，方便显示
  void addfloatbutton(name) {
    text = name.split(",")[0];
    type = name.split(",")[1];
    setState(() {
      myReceiptItemData.tabOrder = count;
      myReceiptItemData.content = text;
      myReceiptItemData.type = type;
      myReceiptItemData.xPos = xPos;
      if (myReceiptItemData.type == 'DATA') {
        myReceiptItemData.content = getShowVarName(text, maxLength);
      }

      receiptItemList.add(ReceiptItem(
        key: ObjectKey(myReceiptItemData.tabOrder),
        index: count,
        content: myReceiptItemData.content,
        type: type,
        xPos: xPos,
        yPos: yPos,
        width: width,
        height: height,
        fontSize: fontSize,
        fontWidthRatio: fontWidthRatio,
        fontHeightRatio: fontHeightRatio,
        style: style,
        rotation: rotation,
        defaultValue: defaultValue,
        alignment: alignment,
        maxLength: maxLength,
        tabOrder: tabOrder,
        varName: text,
        varcontent: varcontent,
        barcodeName: barcodeName,
        barcodeType: barcodeType,
        hralignment: hralignment,
        x2Pos: x2Pos,
        y2Pos: y2Pos,
        lineWidth: lineWidth,
        qrWidth: qrWidth,
        qrcodeName: qrcodename,
        qrcodeType: qrcodeType,
        fontBold: fontBold,
        fontReverse: fontReverse,
      ));

      myReceiptItemKey.keyList.add(ObjectKey(myReceiptItemData.tabOrder));

      //中间页面添加最新的可拖拽控件
      floatButtonList.add(ReceiptDraggableFloating(
          index: (num.length - 1),
          key: ObjectKey(myReceiptItemData.tabOrder),
          initialOffset: const Offset(0, 0),
          parentKey: _parentKey,
          onPressed: () {},
          children: [receiptItemList[num.length - 1]]));
    });
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

      // Map<String, dynamic> data = jsonDecode(contents);
      // return data;
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

  _selectItem() {
    return [
      const SizedBox(height: 100),
      SizedBox(
        height: 50,
        child: Text(
          localizedStrings.gMsgNoElement,
          style: Theme.of(context).textTheme.bodySmall!.apply(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      ),
    ];
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

  TextField buildTextField(TextEditingController controller, String labelText,
      String hintText, int num) {
    controller.text = hintText;
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelStyle: Theme.of(context).textTheme.bodySmall!.apply(),
        hintStyle: Theme.of(context).textTheme.bodySmall!.apply(),
        labelText: labelText,
        hintText: hintText,
      ),
      style: Theme.of(context).textTheme.bodySmall!.apply(),
      onEditingComplete: () {
        _onSubmit(controller.text, num);
      },
      focusNode: (num == 0)
          ? _focusNodeContent
          : (num == 1)
              ? _focusNodeFontSize
              : (num == 2)
                  ? _focusNodexPos
                  : (num == 3)
                      ? _focusNodeyPos
                      : (num == 4)
                          ? _focusNodemaxLenth
                          : (num == 7)
                              ? _focusbarcodeHeght
                              : (num == 17)
                                  ? _focusNodex2Pos
                                  : (num == 10)
                                      ? _focusNodey2Pos
                                      : (num == 16)
                                          ? _focusNodelineWidth
                                          : _focusNodeContent,
    );
  }

//下拉旋转
  void _handleRotationSelected(String value) {
    setState(() {
      _selectedRotation = value;
      _onSubmit(_selectedRotation, 8);
    });
  }

//下拉对齐方式
  void _handleAlignmentSelected(String value) {
    setState(() {
      _selectedAlignment = value;
    });
    if (_selectedAlignment == 'Left') {
      _onSubmit('1', 5);
    } else if (_selectedAlignment == 'Center') {
      _onSubmit('2', 5);
    } else if (_selectedAlignment == 'Right') {
      _onSubmit('3', 5);
    }
  }

//下拉字体加粗
  void _handleFontBoldSelected(String value) {
    setState(() {
      _selectFontBold = value;
      _onSubmit(_selectFontBold, 14);
    });
  }

//下拉反白
  void _handleFontReverseSelected(String value) {
    setState(() {
      _selectFontReverse = value;
      _onSubmit(_selectFontReverse, 15);
    });
  }

  //下拉字体加粗
  void _handleFontSizeSelected(String value) {
    setState(() {
      _selectFontsize = value;
      _onSubmit(_selectFontsize, 1);
    });
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
            child: Text(
              "X:",
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall!.apply(),
            ),
          ),
          Expanded(
            child: TextField(
              enabled: false,
              controller: xPosvar,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),
              onEditingComplete: () {
                _onSubmit(xPosvar.text, 2);
              }, // 点击“完成”按钮后，调用失去焦点方法
              focusNode: _focusNodexPos, // 将FocusNode对象绑定到TextField
              style: Theme.of(context).textTheme.bodySmall!.apply(),
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
            child: Text(
              "Y:",
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall!.apply(),
            ),
          ),
          Expanded(
            child: TextField(
              enabled: false,
              controller: yPosvar,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),
              onEditingComplete: () {
                _onSubmit(yPosvar.text, 3);
              }, // 点击“完成”按钮后，调用失去焦点方法
              focusNode: _focusNodeyPos, // 将FocusNode对象绑定到TextField
              style: Theme.of(context).textTheme.bodySmall!.apply(),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _textproperties() {
    return [
      buildAttitudeText(context, localizedStrings.gAttribute),
      buildDivider(),
      buildTabOrderAndTyptText(context, localizedStrings.gTabOrder,
          myReceiptItemData.tabOrder.toString()),
      buildTabOrderAndTyptText(
          context, localizedStrings.gTipItemType, myReceiptItemData.varName),
      showRightItemTitleText(context, localizedStrings.gPosition),
      ...buildXYPosition(),
      showRightItemTitleText(context, localizedStrings.gTextContent),
      buildTextField(textvariable, "", myReceiptItemData.content.toString(), 0),
      showRightItemTitleText(context, localizedStrings.gFontSize),
      showDropDownButtonValue(context, _selectFontsize, _fontSizes,
          localizedStrings.gFontSize, _handleFontSizeSelected),
      showRightItemTitleText(context, localizedStrings.gRotation),
      showDropDownButtonValue(
        context,
        _selectedRotation,
        _rotations,
        localizedStrings.gRotation,
        _handleRotationSelected,
      ),
      showRightItemTitleText(context, localizedStrings.gFontBold),
      showDropDownButtonValue(
        context,
        _selectFontBold,
        _fontBoldReverse,
        localizedStrings.gFontBold,
        _handleFontBoldSelected,
      ),
      showRightItemTitleText(context, localizedStrings.gFontReverse),
      showDropDownButtonValue(
        context,
        _selectFontReverse,
        _fontBoldReverse,
        localizedStrings.gFontReverse,
        _handleFontReverseSelected,
      ),
      SizedBox(
        height: regularPadding,
      ),
      deleteBtnBuild(),
    ];
  }

  _deleteReceiptItem(int deleteNum) {
    int indexToRemove = -1;
    for (var i = 0; i < receiptItemList.length; i++) {
      if (receiptItemList[i].index == deleteNum) {
        indexToRemove = i;
        break;
      }
    }
    if (indexToRemove >= 0) {
      receiptItemList.removeAt(indexToRemove);
      List<ReceiptItem> tempreceiptItemList = [];
      for (var i = 0; i < receiptItemList.length; i++) {
        tempreceiptItemList.add(receiptItemList[i]);
      }

      receiptItemList.clear();
      myReceiptItemKey.keyList.clear();
      num.removeAt(indexToRemove);
      // count = 0;
      floatButtonList.clear();
      _parentKey = GlobalKey();

      for (var i = 0; i < tempreceiptItemList.length; i++) {
        // tempreceiptItemList[i].index = i;
        receiptItemList.add(tempreceiptItemList[i]);
        myReceiptItemKey.keyList.add(ObjectKey(receiptItemList[i].index));

        floatButtonList.add(ReceiptDraggableFloating(
            index: (receiptItemList[i].index),
            key: ObjectKey(receiptItemList[i].index),
            initialOffset: Offset(receiptItemList[i].xPos.toDouble(),
                receiptItemList[i].yPos.toDouble()),
            parentKey: _parentKey,
            onPressed: () {},
            children: [receiptItemList[i]]));
      }
      myReceiptItemData.tabOrder = 9999;
    }
  }

  void reconstructItem() {
    List<ReceiptItem> tempreceiptItemList = [];
    for (var i = 0; i < receiptItemList.length; i++) {
      tempreceiptItemList.add(receiptItemList[i]);
    }
    receiptItemList.clear();
    myReceiptItemKey.keyList.clear();
    floatButtonList.clear();
    _parentKey = GlobalKey();

    for (var i = 0; i < tempreceiptItemList.length; i++) {
      // tempreceiptItemList[i].index = i;
      receiptItemList.add(tempreceiptItemList[i]);
      myReceiptItemKey.keyList.add(ObjectKey(receiptItemList[i].index));

      floatButtonList.add(ReceiptDraggableFloating(
          index: (receiptItemList[i].index),
          key: ObjectKey(receiptItemList[i].index),
          initialOffset: Offset(receiptItemList[i].xPos.toDouble(),
              receiptItemList[i].yPos.toDouble()),
          parentKey: _parentKey,
          onPressed: () {},
          children: [receiptItemList[i]]));
    }
    myReceiptItemData.tabOrder = 9999;
  }

  List<Widget> _varproperties() {
    return [
      buildAttitudeText(context, localizedStrings.gAttribute),
      buildDivider(),
      buildTabOrderAndTyptText(context, localizedStrings.gTabOrder,
          myReceiptItemData.tabOrder.toString()),
      buildTabOrderAndTyptText(
          context, localizedStrings.gTipItemType, myReceiptItemData.varName),
      showRightItemTitleText(context, localizedStrings.gPosition),
      ...buildXYPosition(),
      showRightItemTitleText(context, localizedStrings.gMaxLength),
      buildTextField(
          maxLenthvar, "", myReceiptItemData.maxLength.toString(), 4),
      showRightItemTitleText(context, localizedStrings.gAlignment),
      showDropDownButtonValue(
        context,
        _selectedAlignment,
        _alignments,
        localizedStrings.gAlignment,
        _handleAlignmentSelected,
      ),
      showRightItemTitleText(context, localizedStrings.gRotation),
      showDropDownButtonValue(
        context,
        _selectedRotation,
        _rotations,
        localizedStrings.gRotation,
        _handleRotationSelected,
      ),
      showRightItemTitleText(context, localizedStrings.gFontSize),
      showDropDownButtonValue(
        context,
        _selectFontsize,
        _fontSizes,
        localizedStrings.gFontSize,
        _handleFontSizeSelected,
      ),
      showRightItemTitleText(context, localizedStrings.gFontBold),
      showDropDownButtonValue(
        context,
        _selectFontBold,
        _fontBoldReverse,
        localizedStrings.gFontBold,
        _handleFontBoldSelected,
      ),
      showRightItemTitleText(context, localizedStrings.gFontReverse),
      showDropDownButtonValue(
        context,
        _selectFontReverse,
        _fontBoldReverse,
        localizedStrings.gFontReverse,
        _handleFontReverseSelected,
      ),
      SizedBox(
        height: regularPadding,
      ),
      deleteBtnBuild(),
    ];
  }

  Widget deleteBtnBuild() {
    return SizedBox(
        width: 200,
        child: showTextButton(context, btnHeight, localizedStrings.gBtnDelete,
            () {
          setState(() {
            _deleteReceiptItem(myReceiptItemData.tabOrder);
          });
        },
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.error,
            Theme.of(context).colorScheme.onPrimary));
  }

  List<Widget> _lineproperties() {
    return [
      buildAttitudeText(context, localizedStrings.gAttribute),
      buildDivider(),
      buildTabOrderAndTyptText(context, localizedStrings.gTabOrder,
          myReceiptItemData.tabOrder.toString()),
      buildTabOrderAndTyptText(
          context, localizedStrings.gTipItemType, myReceiptItemData.varName),
      showRightItemTitleText(context, localizedStrings.gPosition),
      buildTextField(xPosvar, "X1", myReceiptItemData.xPos.toString(), 2),
      buildTextField(yPosvar, "Y1", myReceiptItemData.yPos.toString(), 3),
      buildTextField(
          x2Posvar, "Line Lenth", myReceiptItemData.x2Pos.toString(), 17),
      buildTextField(lineWidthVar, "Line Width",
          myReceiptItemData.lineWidth.toString(), 16),
      SizedBox(
        height: regularPadding,
      ),
      deleteBtnBuild(),
    ];
  }

  void getLanguageVarMap() {
    if (languageVarMap.isNotEmpty) {
      return;
    }
    languageVarMap = {
      "Weight Variable": localizedStrings.l_var_title,
      "Text": localizedStrings.p_text_var,
      "Line": localizedStrings.p_div_line_var,
      "NO._P": localizedStrings.p_no_var,
      "Header1_P": localizedStrings.p_header1_var,
      "Header2_P": localizedStrings.p_Header2_var,
      "Header3_P": localizedStrings.p_header3_var,
      "Footer1_P": localizedStrings.p_footer1_var,
      "Footer2_P": localizedStrings.p_footer2_var,
      "Footer3_P": localizedStrings.p_footer3_var,
      "PLU_ID_P": localizedStrings.p_plu_id_var,
      "PLU_Name_P": localizedStrings.p_plu_name_var,
      "OrderNumber_P": localizedStrings.p_order_number_var,
      "UnitPrice_P": localizedStrings.p_unit_price_var,
      "PriceUnit_P": localizedStrings.p_price_unit_var,
      "Price_P": localizedStrings.p_price_var,
      // "PreTare_P": localizedStrings.p_pre_tare_var,
      ////屏蔽原因：秤上只认pretare ，测试要求显示tare ，没办法只能tare当pretare用。json文件中tare_p的值改成了Pretare_P的值了。
      "Weight_Pcs_P": localizedStrings.p_weight_pcs_var,
      "Unit_P": localizedStrings.p_unit_var,
      "Tare_P": localizedStrings.p_tare_var,
      "DATE": localizedStrings.p_date_var,
      "TIME": localizedStrings.p_time_var,
      "TaxType1_P": localizedStrings.p_tax_type1_var,
      "TaxType2_P": localizedStrings.p_tax_type2_var,
      "TaxType3_P": localizedStrings.p_tax_type3_var,
      "TaxBase1_P": localizedStrings.p_tax_base1_var,
      "TaxBase2_P": localizedStrings.p_tax_base2_var,
      "TaxBase3_P": localizedStrings.p_tax_base3_var,
      "TaxAmount1_P": localizedStrings.p_tax_amount1_var,
      "TaxAmount2_P": localizedStrings.p_tax_amount2_var,
      "TaxAmount3_P": localizedStrings.p_tax_amount3_var,
      "TaxModel_P": localizedStrings.p_tax_model_var,
      "TotalTaxAmount_P": localizedStrings.p_total_tax_amount_var,
      "PaymentAmount_P": localizedStrings.p_payment_amount_P_var,
      "ChangeAmount_P": localizedStrings.p_change_amount_var,
      "Subtotal_P": localizedStrings.p_subtotal_var,
      "Currency_P": localizedStrings.p_currency_var,
      "CopyTimes_P": localizedStrings.p_copy_times_var,
      "ModelName_P": localizedStrings.p_model_name_var,
      "ScaleName_P": localizedStrings.p_scale_name_var,
      "TaxName_P": localizedStrings.p_tax_name_var,
      "SettleAccountTimes_P": localizedStrings.p_settle_account_times_var,
      "PLU_Tax_P": localizedStrings.p_plu_tax_var,
      "TotalNoTax_P": localizedStrings.p_total_no_tax_var,
      "Free Text": localizedStrings.p_text_title,
      "Dividing Line": localizedStrings.p_line_title,
      "Price Variable": localizedStrings.p_price_title,
      "NO.": localizedStrings.l_no_var,
      "Gross": localizedStrings.l_gross_var,
      "Tare": localizedStrings.l_tare_var,
      "Net": localizedStrings.l_net_var,
      "PCS": localizedStrings.l_pcs_var,
      "WeightUnit": localizedStrings.l_wgt_unit_var,
      "U.WGT": localizedStrings.l_uwgt_var,
      "U.WU": localizedStrings.l_uwu_var,
      "UnitWeight": localizedStrings.l_unit_wgt_var,
      "Percent": localizedStrings.l_percent_var,
      "TotalWeight": localizedStrings.l_total_wgt_var,
      "TotalCount": localizedStrings.l_total_cnt_var,
    };

    languageVarExplMap = {
      "Text": localizedStrings.p_text_expl,
      "Line": localizedStrings.p_div_line_expl,
      "NO._P": localizedStrings.p_no_expl,
      "Header1_P": localizedStrings.p_header1_expl,
      "Header2_P": localizedStrings.p_Header2_expl,
      "Header3_P": localizedStrings.p_header3_expl,
      "Footer1_P": localizedStrings.p_footer1_expl,
      "Footer2_P": localizedStrings.p_footer2_expl,
      "Footer3_P": localizedStrings.p_footer3_expl,
      "PLU_ID_P": localizedStrings.p_plu_id_expl,
      "PLU_Name_P": localizedStrings.p_plu_name_expl,
      "OrderNumber_P": localizedStrings.p_order_number_expl,
      "UnitPrice_P": localizedStrings.p_unit_price_expl,
      "PriceUnit_P": localizedStrings.p_price_unit_expl,
      "Price_P": localizedStrings.p_price_expl,
      // "PreTare_P": localizedStrings.p_pre_tare_expl,
      "Weight_Pcs_P": localizedStrings.p_weight_pcs_expl,
      "Unit_P": localizedStrings.p_unit_expl,
      "Tare_P": localizedStrings.p_tare_expl,
      "DATE": localizedStrings.p_date_expl,
      "TIME": localizedStrings.p_time_expl,
      "TaxType1_P": localizedStrings.p_tax_type1_expl,
      "TaxType2_P": localizedStrings.p_tax_type2_expl,
      "TaxType3_P": localizedStrings.p_tax_type3_expl,
      "TaxBase1_P": localizedStrings.p_tax_base1_expl,
      "TaxBase2_P": localizedStrings.p_tax_base2_expl,
      "TaxBase3_P": localizedStrings.p_tax_base3_expl,
      "TaxAmount1_P": localizedStrings.p_tax_amount1_expl,
      "TaxAmount2_P": localizedStrings.p_tax_amount2_expl,
      "TaxAmount3_P": localizedStrings.p_tax_amount3_expl,
      "TaxModel_P": localizedStrings.p_tax_model_expl,
      "TotalTaxAmount_P": localizedStrings.p_total_tax_amount_expl,
      "PaymentAmount_P": localizedStrings.p_payment_amount_P_expl,
      "ChangeAmount_P": localizedStrings.p_change_amount_expl,
      "Subtotal_P": localizedStrings.p_subtotal_expl,
      "Currency_P": localizedStrings.p_currency_expl,
      "CopyTimes_P": localizedStrings.p_copy_times_expl,
      "ModelName_P": localizedStrings.p_model_name_expl,
      "ScaleName_P": localizedStrings.p_scale_name_expl,
      "TaxName_P": localizedStrings.p_tax_name_expl,
      "SettleAccountTimes_P": localizedStrings.p_settle_account_times_expl,
      "PLU_Tax_P": localizedStrings.p_plu_tax_expl,
      "TotalNoTax_P": localizedStrings.p_total_no_tax_expl,
      "Free Text": localizedStrings.p_text_title,
      "Dividing Line": localizedStrings.p_line_title,
      "Price Variable": localizedStrings.p_price_title,
      "NO.": localizedStrings.l_no_expl,
      "Gross": localizedStrings.l_gross_expl,
      "Tare": localizedStrings.l_tare_expl,
      "Net": localizedStrings.l_net_expl,
      "PCS": localizedStrings.l_pcs_expl,
      "WeightUnit": localizedStrings.l_wgt_unit_expl,
      "U.WGT": localizedStrings.l_uwgt_expl,
      "U.WU": localizedStrings.l_uwu_expl,
      "UnitWeight": localizedStrings.l_unit_wgt_expl,
      "Percent": localizedStrings.l_percent_expl,
      "TotalWeight": localizedStrings.l_total_wgt_expl,
      "TotalCount": localizedStrings.l_total_cnt_expl,
    };
  }
}

// showAddComPortDialog(context).then((onValue) {
//   if (kDebugMode) {
//     print(onValue);
//   }
//   setState(() {
//     // items.add(onValue.toString());
//   });
// });

// final result = await Navigator.push(
//   context,
//   MaterialPageRoute(
//       builder: (context) => BarCodeEditPage(value: 'nihao')),
// );
// setState(() {
//   // value = result;
// });

class Circle extends StatelessWidget {
  final int index;
  final Offset position;
  final ValueChanged onPositionChanged;
  const Circle({
    super.key,
    required this.index,
    required this.position,
    required this.onPositionChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 5,
      top: position.dy - 5,
      child: GestureDetector(
        onPanUpdate: (details) => onPositionChanged(position + details.delta),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceTint,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class Line {
  final Offset start;
  final Offset end;
  Line(this.start, this.end);
}

// 自定义滚动行为：只有滚动条本身可以触发滚动
class _ScrollbarOnlyScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        // 空集合，禁用所有设备在内容区域的拖拽滚动
        // 这样只有滚动条本身的拖拽才会触发滚动
      };

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    // 使用 RawScrollbar 确保滚动条本身可以交互
    return RawScrollbar(
      controller: details.controller,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 12,
      radius: const Radius.circular(6),
      // 确保滚动条本身可以交互
      interactive: true,
      child: child,
    );
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    // 禁用过度滚动效果
    return child;
  }
}
