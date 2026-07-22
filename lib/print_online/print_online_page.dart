import 'package:intl/intl.dart';
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
import 'package:t_max/functions/methods.dart';
import 'package:t_max/data/manager_scale_channel.dart';
import 'package:t_max/data/received_wgt_value.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/generated/l10n.dart';

import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:t_max/labeldesign/label_design_data.dart';
import 'package:t_max/labeldesign/label_dropdown_copy.dart';
import 'package:t_max/print_online/print_settings_dialog.dart';
import 'package:t_max/labeldesign/label_element.dart';
import 'package:t_max/labeldesign/label_formatdata.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_max/widget/attibute_widget.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/page_head.dart';
import 'package:t_max/labeldesign/ai_design_dialog.dart';

class PrintOnlinePage extends StatefulWidget {
  final String type;
  final Function(String) onNavigate;
  final String lastRouteName;
  const PrintOnlinePage(
      {super.key,
      required this.type,
      required this.onNavigate,
      required this.lastRouteName});
  @override
  PrintOnlinePageState createState() => PrintOnlinePageState();
}

class PrintOnlinePageState extends State<PrintOnlinePage> {
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
  // 闂傚倷绀侀幖顐﹀磹閻熼偊鐔嗘慨妞诲亾鐠侯垶鏌涢幇闈涙灍闁稿鍔戦弻鏇熺箾閸喒鍋撳Δ鍛殞濡わ絽鍟悡娑㈡煕閺囥劌浜滈柍閿嬫閺屾洟宕堕妸銉ユ懙濡ょ姷鍋炵敮鐔妓囨潏銊х闁糕剝鍔曢悘顏嗙磼瀹€鍕喚闁糕晛瀚板畷妯款槾缂佲偓閳ь剟姊绘担鍦菇闁告柨鐬奸埀顒佸嚬閸橀箖寮鈧畷濂稿即閻愭妲撮梺鑽ゅЬ濞咃綁宕曢妶澶嬪仧?
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
  dynamic _eventWeight;
  ReceiveWgtInfo? _currentWeight;

  // 闂傚倷绀侀幖顐﹀磹閻熼偊鐔嗘慨妞诲亾鐠侯垶鏌涢幇闈涙灍闁哄拋鍓氶幈銊ヮ潨閸℃绠洪梺璇″灡閻熴儵婀侀梺鎸庣箓濡盯鎯屾惔顫簻闁哄倹瀵х粚鍧楁煏閸ャ劌濮嶇€殿喗鎸抽幃銏ゅ传閸曨厺绱?  
  List<List<DraggableElement>> undoStack = [];
  List<List<DraggableElement>> redoStack = [];
  int maxUndoSteps = 100; // 闂傚倷绀侀幖顐︽偋閸愵喖纾婚柟鐐墯閻斿棝鏌涢銏☆棞閻庢凹鍘鹃埀顒傛暩閺佽顫忛悜妯诲劅闁规儳鍘栨竟鏇熺節濞堝灝鏋熺紒鍝勬健瀹曟洟寮婚妷銉﹁緢?

  //闂傚倷鑳剁划顖滄暜椤忓懍绻嗛柛銉墮绾?

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
  final Set<LogicalKeyboardKey> _pressedKeys =
      {}; // 闂傚倷鐒﹀鍨焽閸ф绀夐悗锝庡墲婵櫕銇勯幒宥囧妽濞存嚎鍊濋弻娑欑節閸曨偅鐏堥梺鎼炲€曢鍥箟閹间焦鍋嬮柛顐ゅ枎绾板秵绻濋埛鈧崨顓涙瀰濡ょ姷鍋為崝鏍ь嚗閸曨剙绶炵€光偓閳ь剟骞夐鈧鍝勑ч崶褍顬堥柣搴㈢煯閸楀啿顕ｉ锔绘晣闁靛繆鍓濆▍鏍倵閸忓浜鹃梺鍛婃处閸庣兘鍩￠崒娑樺伎濠电娀娼х€氼剟鎮橀弻銉︾厱闁挎繂鎳忛崯鐐碘偓鍨緲鐎氼剟顢樻總绋跨妞ゆ挾濯崯宥夋⒑鐠囨彃顒㈢紒瀣浮閳ワ箓宕堕妸锕€寮块梺褰掓？缁€浣虹不?

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

    if (myDefScaleInfo.defScaleId != null && myDefScaleInfo.defScaleId! > 0) {
      PublicFunctions.getWeight(myDefScaleInfo.defScaleId!);
    }

    _eventWeight = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        if (event.obj.scaleId == myDefScaleInfo.defScaleId) {
          var msgBody = event.obj.msgBody;
          if (msgBody != null) {
            setState(() {
              _currentWeight = ReceiveWgtInfo(
                weightVal: msgBody.weightVal,
                weightUnit: msgBody.weightUnit,
                isStable: msgBody.isStable,
                isZero: msgBody.isZero,
                isNet: msgBody.isNet,
              );
            });
          }
        }
      }
    });

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
    if (myDefScaleInfo.defScaleId != null && myDefScaleInfo.defScaleId! > 0) {
      PublicFunctions.stopWeight(myDefScaleInfo.defScaleId!);
    }
    _eventWeight?.cancel();
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
    // 闂?ByteData 闂傚倷鑳堕崕鐢稿疾濞戙垺鍋ら柕濞у嫭娈伴柣搴㈢⊕钃卞┑顔界矋閵囧嫰骞掑鍥舵М闁瑰吋娼欓敃銈夊煡?JSON 闂備浇顕х€涒晝绮欓幒妞尖偓鍐醇閵夘喗鏅炴繛杈剧到濠€閬嶅煝?
    final jsonString = bytes.buffer.asUint8List();
    final jsonData = utf8.decode(jsonString);

    deleteAllElements();
    readTextInfoListFromStr(jsonData);
  }

  // 闂備浇顕уù鐑姐€佹繝鍋芥盯宕熼娑樹壕缁绢厼鎳忛悵顏呯箾閻撳海绠绘鐐达耿瀹曟﹢骞撻幒鎾圭发濠电姷顣介崜婵嬨€冮崨顓囨稑鈽夐姀鐘殿槷閻庡箍鍎遍ˇ浼村磹閻戣姤鐓熼柣鏂挎啞缁惰尙绱撳鍕獢闁哄本鐩浠嬪Ω瑜嶉埅鐟邦渻閵堝繗鍚傞柡鍛█楠?
  void _onTextWidthFocusChange() {
    if (!textWidthFocusNode.hasFocus) {
      // 闂備浇顕х换鎰崲閹邦儵娑樷槈閵忕姷顦悗骞垮劚椤︿即宕愭搴ｆ／妞ゆ挾鍋為崳铏圭磼娓氬洤鏋ょ紒杈ㄥ笚瀵板嫭鎯旈鍏碱唲闂備胶纭堕弲娑㈠嫉椤掑倻鐭欏鑸靛姈閸ゆ帡鏌曢崼婵囧櫣妞ゎ剙顦靛铏圭磼濡搫顫庡銈冨灩閿曘儲绌辨繝鍥舵晣闁靛繆鈧枼鍋?
      _focusNode.requestFocus();
    }
  }

  // 婵犲痉鏉库偓鏇㈠磹瑜版帗鏅梺璇叉捣椤㈠﹤鈻嶉弴鐑嗙劷闊洦绋戠粻濠氭煕閹邦厼绲绘慨瑙勫絻閳规垿鍩勯崘鐐暥濠碘槅鍋呴惄顖氱暦濠靛棭鍚嬪璺侯儏閳ь剛鍏橀弻锝夋偄閸涘﹦鍑＄紓鍌氱С缁舵岸寮诲☉銏犲唨闁靛ě鍐ｅ悅婵＄偑鍊ч懙褰掑疾閻樿绠?
  void _onTextHeightFocusChange() {
    if (!textHeightFocusNode.hasFocus) {
      // 闂備浇顕х换鎰崲閹邦儵娑樷槈閵忕姷顦悗骞垮劚椤︿即宕愭搴ｆ／妞ゆ挾鍋為崳铏圭磼娓氬洤鏋ょ紒杈ㄥ笚瀵板嫭鎯旈鍏碱唲闂備胶纭堕弲娑㈠嫉椤掑倻鐭欏鑸靛姈閸ゆ帡鏌曢崼婵囧櫣妞ゎ剙顦靛铏圭磼濡搫顫庡銈冨灩閿曘儲绌辨繝鍥舵晣闁靛繆鈧枼鍋?
      _focusNode.requestFocus();
    }
  }

  // 闂傚倷绀侀幖顐﹀磹缁嬫５娲晝閳ь剟鏁冮姀銈嗗亱闁割偆鍠撶粔鍫曟⒑鐟欏嫬鍔ら柛鐔风仢椤曪綁鎼归锛勭畾濠德板€愰崑鎾翠繆椤愶絿娲寸€规洘绻傞鍏煎緞鐎ｎ亖鍋撻悜鑺ョ厽闁绘柨鎲＄欢鑼磽瀹ュ嫮绐旈柡灞剧洴瀵粙濡歌閳懓顪冮妶蹇氬悅闁哄懐濞€楠?
  void _onTextContentFocusChange() {
    if (!textContentFocusNode.hasFocus) {
      // 闂備浇顕х换鎰崲閹邦儵娑樷槈閵忕姷顦悗骞垮劚椤︿即宕愭搴ｆ／妞ゆ挾鍋為崳铏圭磼娓氬洤鏋ょ紒杈ㄥ笚瀵板嫭鎯旈鍏碱唲闂備胶纭堕弲娑㈠嫉椤掑倻鐭欏鑸靛姈閸ゆ帡鏌曢崼婵囧櫣妞ゎ剙顦靛铏圭磼濡搫顫庡銈冨灩閿曘儲绌辨繝鍥舵晣闁靛繆鈧枼鍋?
      _focusNode.requestFocus();
    }
  }

  // 闂傚倷绀侀幖顐︽偋閸愵喖纾婚柟鐐墯閻斿棝鏌涢銏☆棞婵炶绠戣闁圭増婢樼粻褰掑级閸繂鈷旈柣锝呯－缁辨帗锛愬┑鍡楃睄閻庤娲橀〃濠冧繆閻戣姤鏅滅紓浣股戦弳鐘绘⒒娴ｈ櫣甯涢悽顖ｄ簼娣囧﹪宕堕鈧壕濠氭煥濠靛棭妲搁柣顓燁殕娣囧﹪顢涘顓熷創濡炪倖娉﹂崘鍓у數闁荤姴鎼幖顐︻敂椤愶附鐓?
  void _onMaxLenthFocusChange() {
    if (!maxLenthFocusNode.hasFocus) {
      // 闂備浇顕х换鎰崲閹邦儵娑樷槈閵忕姷顦悗骞垮劚椤︿即宕愭搴ｆ／妞ゆ挾鍋為崳铏圭磼娓氬洤鏋ょ紒杈ㄥ笚瀵板嫭鎯旈鍏碱唲闂備胶纭堕弲娑㈠嫉椤掑倻鐭欏鑸靛姈閸ゆ帡鏌曢崼婵囧櫣妞ゎ剙顦靛铏圭磼濡搫顫庡銈冨灩閿曘儲绌辨繝鍥舵晣闁靛繆鈧枼鍋?
      _focusNode.requestFocus();
    }
  }

  // 闂傚倷绀侀幖顐﹀磹閻熼偊鐔嗘慨妞诲亾鐠侯垶鏌涢幇闈涙灍闁哄拋鍓氶幈銊ヮ潨閸℃ぞ绨界紓浣哄С缁瑩骞冨Δ鈧埥澶娾枍椤撗傜敖缂佽京鍋熼埀顒婄秵閸犳牜绮堥崼鈶╁亾楠炲灝鍔氭繛灞傚€楅悷褔姊绘担绛嬪殐闁稿繑绋撶划鍫熺瑹閳ь剙鐣烽崫鍕殕闁告洦鍋嗛鎺楁⒑闂堟稓澧曟い锔垮嵆瀵偄顫滈埀顒勫蓟?
  void _saveState() {
    // 濠电姷鏁搁崕鎴犵礊閳ь剙顪冮弶鎴炴喐闁逞屽墯閼规儳锕㈤柆宥呯闁荤喐澹嬮弨浠嬫煕閳╁啰鎳呭鍥⒒娴ｅ憡鍟為柟绋挎憸缁棃骞橀鐓庡亶闂佽宕橀崺鏍綖閺囥垺鐓熸俊顖濐嚙缁插鏌ｈ箛鏃傛噰闁?
    final currentState = elements.map((e) => e.copy()).toList();

    undoStack.add(currentState);
    if (undoStack.length > maxUndoSteps) {
      undoStack.removeAt(0);
    }
    if (redoStack.isNotEmpty) {
      redoStack.clear();
    }
  }

  // 闂傚倷绀侀幖顐﹀磹閻熼偊鐔嗘慨妞诲亾鐠侯垶鏌涢幇闈涙灍闁哄拋鍓氶幈銊ヮ潨閸℃绠洪柣搴ｆ暩閺佽顫忛悜妯诲劅闁规儳鍘栨竟鏇㈡⒒娴ｇ儤鍤€闁诲繑绻勭划鏂跨暦閸モ晝顦?
  void _undo() {
    if (undoStack.isNotEmpty) {
      final previousState = undoStack.removeLast();
      redoStack.add(elements.map((e) => e.copy()).toList());
      setState(() {
        elements = previousState;
      });
    }
  }

  // 闂傚倷绀侀幖顐﹀磹閻熼偊鐔嗘慨妞诲亾鐠侯垶鏌涢幇闈涙灍闁哄拋鍓氶幈銊ノ熼幐搴ｃ€愬┑鐐叉噷閸ㄤ粙寮诲☉姘ｅ亾閿濆骸浜炴い锝嗙叀閺岀喐绺介崨濠冩殸闂?
  void _redo() {
    if (redoStack.isNotEmpty) {
      final nextState = redoStack.removeLast();
      undoStack.add(elements.map((e) => e.copy()).toList());
      setState(() {
        elements = nextState;
      });
    }
  }

  //闂傚倸鍊烽悞锕併亹閸愵亞鐭撻柣銏㈩焾閽冪喎鈹戦悩鍙夋悙缂佲偓婢舵劖鐓熸俊顖滃帶閸斿绱掓担宄板祮闁哄备鍓濆鍕槈濮樻唻绱甸梻浣虹帛閻楁鍒掗幘鎰佸殨妞ゆ劧闄勯崑瀣煕椤愶絿绠橀柕?
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
      // 婵犵數鍋涢顓熸叏鐎电硶鍋撳☉鎺撴珚鐎殿喗鎮傚畷姗€鍩￠崘鐐カ闂備礁鎼悧鍛緤婵犳艾鍌ㄦい鎺戝閸嬶綁鏌涢妷顔绘喚闁搞倖鐟ч幉鎼佸级閹稿骸绐涢梺閫炲苯澧紒瀣浮閵嗗啴宕奸妷顔芥櫈婵炶揪绲藉﹢閬嶅煝?
      String contents = await file.readAsString();
      // 闂備浇顕х换鎰崲閹邦儵娑樜旈崨顔间槐閻熸粌绻掗崚鎺楊敇閵忊剝娅嗛梺鍏煎墯閸ㄧ厧煤椤掑嫭鐓熼柣鏂挎憸閹虫洜绱掗幓鎺撳仴闁诡喓鍎遍…銊╁礋椤撴稒鐏冪紓鍌欒閸撴繈骞楅悶瀛ㄩ梻鍌欐祰濡椼劑鎳楅懜鍨珷婵°倐鍋撻柣?
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
      // 濠电姷鏁搁崑鐐哄箰閹间礁绠犻柟鐗堟緲閻撴﹢鏌″搴″箹缂佺姴纾幉鍝ヤ沪鐟欙絾鐎婚梺闈涢獜缁辨洟鍩炲澶嬬厓闁宠桨绀侀弳鏇犵磼?
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
        // 闂備浇宕垫慨宕囨閵堝洦顫曢柡鍥ュ灪閸嬧晛鈹戦悩宕囶暡闁绘帟顕ч…璺ㄦ崉娓氼垰鍓板銈呯箞閸庡弶绌辨繝鍋芥棃鍩€椤掆偓铻炴俊銈呮噹閼稿綊鏌熺紒銏犳灍闁稿骸绉归弻娑㈠即閵娿儰绨婚柣銏╁灡椤ㄥ牏妲?
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
        // 婵犵绱曢崑鎴﹀磹閺囥垺鍋夊┑鍌滎焾绾惧潡鎮楅悽鐢点€婇柛瀣崌濡啫鈽夊姣欍劎绱?
        if ((newPosition.dy).round() == otherElement.position.dy.round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(0, newPosition.dy),
            end: Offset(canvasSize.width, newPosition.dy),
          ));
        }
        // 闂備礁婀遍崢褔鎮洪妸銉冩椽鎮㈤悡搴ｏ紵闁诲海鏁哥涵鍫曞磻閹剧粯顥堟繛鎴炴皑妤旂紓?
        if ((newPosition.dy + movingElement.size.height).round() ==
            (otherElement.position.dy + otherElement.size.height).round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(0, newPosition.dy + movingElement.size.height),
            end: Offset(
                canvasSize.width, newPosition.dy + movingElement.size.height),
          ));
        }
        // 闂佽楠哥紞濠傤焽閼姐倗纾芥慨妯挎硾閻ら箖鏌涢幘鑼额唹闁稿鎹囧Λ鍐ㄢ槈濮樻瘷銊х磽?
        if ((newPosition.dx).round() == otherElement.position.dx.round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(newPosition.dx, 0),
            end: Offset(newPosition.dx, canvasSize.height),
          ));
        }
        // 闂傚倷绀侀幉锟犳偡閵夆晛鍌ㄩ柡宥庡幖閻ら箖鏌涢幘鑼额唹闁稿鎹囧Λ鍐ㄢ槈濮樻瘷銊х磽?
        if ((newPosition.dx + movingElement.size.width).round() ==
            (otherElement.position.dx + otherElement.size.width).round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(newPosition.dx + movingElement.size.width, 0),
            end: Offset(
                newPosition.dx + movingElement.size.width, canvasSize.height),
          ));
        }
        // 缂傚倸鍊风粈渚€藝閹剁瓔鏁嬬憸搴ㄥ箞閵娾晛鐓涢柛娑卞幘椤斿﹪鎮峰鍐闁宠閰ｆ慨鈧柕鍫濇閸擃參姊洪崨濠冨闁稿瀚划鍫熸媴閹肩偐鍋撻幒鎴僵闁逞屽墴瀹曞崬鈻庨幋婵嬬崕濠电姷顣介崜婵嬨€冮崨顓囨盯寮崒婊呯暥閻庡厜鍋撻柛鏇ㄥ亞椤ρ囨⒑閸濆嫮澧㈤柡浣规倐閺屟囧磼閻愬鍘甸柣鐘妼椤︻垶宕愯ぐ鎺濇晝濞寸姴顑嗛悡鐔兼煏婵炲灝鍔氭い蹇婃櫅閳藉寮捄銊ь唹缂備焦顨堥崰鏇⑺囬崜浣虹＜闁哄啫鍊搁弸搴亜閳轰降鍋㈢€规洖宕灃濠电姴鍊归蹇撯攽?
        if ((newPosition.dx + movingElement.size.width).round() ==
            otherElement.position.dx.round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(newPosition.dx + movingElement.size.width, 0),
            end: Offset(
                newPosition.dx + movingElement.size.width, canvasSize.height),
          ));
        }
        // 缂傚倸鍊风粈渚€藝閹剁瓔鏁嬬憸搴ㄥ箞閵娾晛鐓涢柛娑卞幘椤斿﹪鎮峰鍐闁宠閰ｆ慨鈧柕鍫濇閸擃參姊洪崨濠冨闁稿鍊荤划濠氼敍濮樸儮鍋撻幒鎴僵闁逞屽墴瀹曞崬鈻庨幋婵嬬崕濠电姷顣介崜婵嬨€冮崨顓囨盯寮崒婊呯暥閻庡厜鍋撻柛鏇ㄥ亞椤ρ囨⒑閸濆嫮澧㈤柡浣规倐閺屟囧磼閻愬鍘甸柣鐘妼椤︻垶宕愯ぐ鎺濇晝濞寸姴顑嗛悡鐔兼煏婵炲灝鍔氭い蹇婃櫇閹叉悂寮堕幐搴℃殘缂備焦顨堥崰鏇⑺囬崜浣虹＜闁哄啫鍊搁弸搴亜閳轰降鍋㈢€规洖宕灃濠电姴鍊归蹇撯攽?
        if ((newPosition.dx).round() ==
            (otherElement.position.dx + otherElement.size.width).round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(newPosition.dx, 0),
            end: Offset(newPosition.dx, canvasSize.height),
          ));
        }
        // 缂傚倸鍊风粈渚€藝閹剁瓔鏁嬬憸搴ㄥ箞閵娾晛鐓涢柛娑卞幘椤斿﹪鎮峰鍐闁宠閰ｆ慨鈧柕鍫濇閸擃參姊洪崨濠冨濞存粎鍋ら幃鐑藉箛閺夎法楠囬梺鍓插亾缂嶅棗顭囬幇顓滀簻闁靛繒濯崕鎰磼鐎ｎ亶妲归柟顖涙閸ㄩ箖宕橀懠顒傜倳婵犵數鍋涢顓熸叏閻㈠憡鍋嬫俊銈呭暞閺嗘粓鏌ら崫銉︽毄妞も晝鍏橀弻娑㈠箻閼碱剙濡介梺浼欑到瀹曨剟鍩ユ径鎰闁归绀侀崜鐢电磽娴ｈ鈷掗柛鐘查叄閵嗗懏绺界粙鍨€垮┑掳鍊曢敃銈呪枔閸涘﹥鍙?
        if ((newPosition.dy).round() ==
            (otherElement.position.dy + otherElement.size.height).round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(0, newPosition.dy),
            end: Offset(canvasSize.width, newPosition.dy),
          ));
        }
        // 缂傚倸鍊风粈渚€藝閹剁瓔鏁嬬憸搴ㄥ箞閵娾晛鐓涢柛娑卞幘椤斿﹪鎮峰鍐闁宠閰ｆ慨鈧柕鍫濇閸擃參姊洪崨濠冨濞存粎鍋ら幃鐑藉箻鐠囪尙楠囬梺鍓插亾缂嶅棗顭囬幇顓滀簻闁靛繒濯崕鎰磼鐎ｎ亶妲归柟顖涙閸ㄩ箖宕橀懠顒傜倳婵犵數鍋涢顓熸叏閻㈠憡鍋嬫俊銈呭暞閺嗘粓鏌ら崫銉︽毄妞も晝鍏橀弻娑㈠箻閼碱剙濡介梺浼欑到瀹曨剟鍩ユ径鎰缂佹稑缍婄欢瀵哥磽娴ｈ鈷掗柛鐘查叄閵嗗懏绺界粙鍨€垮┑掳鍊曢敃銈呪枔閸涘﹥鍙?
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

        // 闂備礁鎼ˇ顖炴偋閸℃鑰块梺顒€绉撮悿鐐亜閹般劍鍤掓繛鎴欏灩閻掑灚銇勯幒鎴濐仼闁?
        newX = newX.clamp(0, canvasSize.width - movingElement.size.width);
        newY = newY.clamp(0, canvasSize.height - movingElement.size.height);

        Offset newPosition = Offset(newX, newY);

        _calculateAlignmentLines(movingElement, newPosition);

        movingElement.position = newPosition;
        // 闂傚倷绀侀幖顐⒚洪妶澶嬪仱闁靛ň鏅涢拑鐔封攽閻樺弶鎼愮紒鐘茬－閹插摜浠︾憴锝嗙€婚梺闈涢獜缁辨洟鍩炲澶嬬厓闁宠桨绀侀弳鏇犵磼?
        _positionXController.text = newPosition.dx.toInt().toString();
        _positionYController.text = newPosition.dy.toInt().toString();
        _elementWidthController.text = movingElement.size.width.toString();
        _elementHeightController.text = movingElement.size.height.toString();
      });
    } else {
      setState(() {
        alignmentLines.clear();
        // 闂傚倷鑳堕…鍫㈡崲閹扮増鍋嬪┑鐘叉硽婢舵劕宸濋柡澶嬪灱閹芥洟姊洪棃娑辨缂佺姵鍨块妴鍌炲蓟閵夛妇鍘搁梺鍓插亝缁诲秴危瑜版帗鍋ㄦい鏍ㄧ箓閻撴劗绱掗崒娑樻诞闁硅櫕绮撳畷褰掝敃瀹ュ繒鐣甸柡灞剧☉椤繈宕滆缁愭绱撴担浠嬪摵濠㈢懓妫濋獮鏍ㄣ偅閸愩劌绐涘銈嗘尵閸嬬偤鎯侀弮鍫熺厸濠㈣泛锕︽晶鏇熺節閳ь剟鏌嗗鍛煣?
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
        // 闂傚倸鍊风欢锟犲磻閸曨垁鍥箥椤旂懓浜炬慨妯稿劚婵＄晫鈧灚婢樼€氼剟锝炲┑瀣垫晝闁挎洍鍋撴繛鍫熺箞濮婅櫣娑甸崨顖滃姺闂佺鏈笟妤呭磻閵娾晜鈷戦柛婵嗗閺嗐垽鏌涢埡鍌滃⒈缂侇喒鏅犻幊锟犲Χ閸モ晝鍘伴梺鍝勵槺閸嬨倝銆傞敂鐐床闁糕剝绋掗悡?
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
      // 濠电姷鏁搁崑鐐哄箰閹间礁绠犻柟鐗堟緲閻撴﹢鏌″搴″箹缂佺姴纾幉鍝ヤ沪鐟欙絾鐎婚梺闈涢獜缁辨洟鍩炲澶嬬厓闁宠桨绀侀弳鏇犵磼?
      _positionXController.clear();
      _positionYController.clear();
      _elementWidthController.clear();
      _elementHeightController.clear();
    });
  }

  void deleteSelectedElements() {
    _saveState(); // 婵犵數鍎戠徊钘壝洪敂鐐床闁稿瞼鍋為崑銈夋煏婵炲灝濡稿ù婊冪秺閺岀喖骞嗚閺嗚鲸銇勯妶鍛殗闁哄矉绲借灒闁割煈鍠氶崢顐︽⒑?
    setState(() {
      elements.removeWhere((element) => selectedElements.contains(element));
      selectedElements.clear();
      isMovingSelected = false;
      alignmentLines.clear();
      _textController.clear();
      _textWidthController.clear();
      _textHeightController.clear();
      // 濠电姷鏁搁崑鐐哄箰閹间礁绠犻柟鐗堟緲閻撴﹢鏌″搴″箹缂佺姴纾幉鍝ヤ沪鐟欙絾鐎婚梺闈涢獜缁辨洟鍩炲澶嬬厓闁宠桨绀侀弳鏇犵磼?
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
      // 濠电姷鏁搁崑鐐哄箰閹间礁绠犻柟鐗堟緲閻撴﹢鏌″搴″箹缂佺姴纾幉鍝ヤ沪鐟欙絾鐎婚梺闈涢獜缁辨洟鍩炲澶嬬厓闁宠桨绀侀弳鏇犵磼?
      _positionXController.clear();
      _positionYController.clear();
      _elementWidthController.clear();
      _elementHeightController.clear();
    });
  }

  KeyEventResult handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      bool isMovementKey = [
        LogicalKeyboardKey.arrowUp,
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.arrowLeft,
        LogicalKeyboardKey.arrowRight
      ].contains(event.logicalKey);

      if (isMovementKey) {
        if (!_pressedKeys.contains(event.logicalKey)) {
          _saveState();
          _pressedKeys.add(event.logicalKey);
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          moveSelectedElements(const Offset(0, -1));
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          moveSelectedElements(const Offset(0, 1));
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          moveSelectedElements(const Offset(-1, 0));
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          moveSelectedElements(const Offset(1, 0));
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.delete) {
        _saveState();
        deleteSelectedElements();
        return KeyEventResult.handled;
      } else if (HardwareKeyboard.instance.isControlPressed &&
          HardwareKeyboard.instance.isShiftPressed &&
          event.logicalKey == LogicalKeyboardKey.keyZ) {
        _redo();
        return KeyEventResult.handled;
      } else if (HardwareKeyboard.instance.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyZ) {
        _undo();
        return KeyEventResult.handled;
      }
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }
    return KeyEventResult.ignored;
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
      // 闂傚倷绀侀幖顐⒚洪妶澶嬪仱闁靛ň鏅涢拑鐔封攽閻樺弶鎼愮紒鐘茬－閹插摜浠︾憴锝嗙€婚梺闈涢獜缁辨洟鍩炲澶嬬厓闁宠桨绀侀弳鏇犵磼?
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
      // 闂備礁鎼ˇ顖炴偋婵犲洤绠伴柟闂寸閻鏌涢埄鍐剧劷闁崇粯姊婚埀顒€绠嶉崕閬嶅箠韫囨稑纾归柕鍫濇缁犳儳顭跨捄渚剱缂佸矁娉曠槐鎺撴綇閵娧呯暭缂備浇椴哥敮鎺楀煝鎼淬倗鐤€闁规儳顕Σ姗€姊绘担鍛婅础缂侇噮鍨跺畷婵單旈崨顓?
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content:
              Text('Please enter valid numbers for canvas width and height.'),
        ),
      );
      // 婵犵數鍎戠徊钘壝洪敂鐐床闁告劦浜栭崑鎾诲垂椤愶綆妫冮悗瑙勬磸閸ㄤ粙骞冮姀銈呭窛濠电姴娲﹂鏍⒒娴ｅ湱婀介柛鏂跨灱閳ь剚鍑归崳锝咁嚕椤愶箑绀堢憸搴ㄥ汲濠婂牊鐓曢柟鎵虫櫅婵＄霉濠婃劗绉柟?
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
        // 闂備礁鎼ˇ顖炴偋閸℃鑰块梺顒€绉撮悿鐐亜閹般劍鍤掓繛鎴欏灩閻掑灚銇勯幒鎴濐仼闁?
        double newX = selectedElements.first.position.dx
            .clamp(0, canvasSize.width - width);
        double newY = selectedElements.first.position.dy
            .clamp(0, canvasSize.height - height);
        selectedElements.first.position = Offset(newX, newY);
        // 闂傚倷绀侀幖顐⒚洪妶澶嬪仱闁靛ň鏅涢拑鐔封攽閻樺弶鎼愮紒鐘茬－閹插摜浠︾憴锝嗙€婚梺闈涢獜缁辨洟鍩炲澶嬬厓闁宠桨绀侀弳鏇犵磼?
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
        // 婵犵數鍋涢悺銊╁吹鎼淬劌纾归柡宓懏娈鹃梺鑲┾拡閸忔﹢宕戦幘缁樼劵婵炴垶姘ㄩ悡鎾绘⒑缂佹绠ラ柛鐘愁殘缁骞掑Δ鈧敮闂佸疇顫夐崕铏妤ｅ啯鐓曢悘鐐靛亾閻ㄦ垿鎮楅悷閭︽█闁哄矉绻濆畷姗€鈥﹂幋婵嗗婵?
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

  //婵犵數鍋為崹鍫曞箰閹间緡鏁勯柛鈩兠崹鏃傜磼閳ラ檲鈺甤ode
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
            element.style =
                1; // 1婵犵數鍋為崹鍫曞箰妤ｅ啫纾块柕鍫濇媼閻掕姤銇勯弽顐沪闁稿孩锚闇夐柨婵嗘噺閹插憡鎱ㄥΟ绋垮闁宠棄顦甸獮娆撳礃閵娿儳顔愰梺璇查閻忔岸鏁冮姀鐘垫殾闁靛鏅╅弫鍐煥濞戞ê顏╅柡鍛櫊濮婃椽宕崟鍨€嗙紓浣介哺濞茬喖骞冮妷銉叆闁割偆鍠愬▍?婵犵數鍋為崹鍫曞箰妤ｅ啫纾块柕鍫濇媼閻掕姤銇勯弽顐沪闁稿孩锚闇夐柨婵嗘噺閹插憡鎱ㄥΟ绋垮闁宠棄顦甸獮娆撳礃閵娿儳顔戦梻浣圭湽閸庨亶骞婂Ο渚殨闁割煈鍋勭欢鐐烘倵閿濆娑у┑鈥插嵆濮婃椽宕崟鍨€嗙紓浣介哺濞茬喖骞?
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

  //婵犵數鍋為崹鍫曞箰閹间緡鏁勯柛鈩兠崹鏃傜磼閵娿儲绶涢梻浣筋嚙濞寸兘銆佹繝鍋芥盯宕熼娑樹壕?
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

  //婵犵數鍋為崹鍫曞箰閹间緡鏁勯柛鈩兠崹鏃傜磼閳ラ檲鈺甤ode
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
      // 闂備浇顕х换鎰崲閹邦儵娑樷枎閹惧疇鎽曟繝鐢靛Т濞层倗绮堥崒鐐寸厱闁规澘鍚€缁ㄨ姤銇勯敃渚€鍝虹紒缁樼洴閺佹劙宕奸銏☆唲濠电姵顔栭崰姘跺磻閵堝懐鏆︽慨妯挎硾缁狙囨煕椤垵鏋ゅù鐘冲哺閺岋綁鎮欑€电硶妫ㄩ梺鍛婃煥椤戝骞?
      elements.add(newElement);
    });
  }

  void showContextMenu(DraggableElement element, Offset position) {
    copyElement(element);
  }

  /// 闂傚倷绀侀幉锛勬暜濡ゅ啰鐭欓柟瀵稿Х绾句粙鏌熼幑鎰靛殭缂佲偓閸℃ü绻嗛柕鍫濇噹椤忋儵鏌?, 濠电姵顔栭崳顖滃緤閻ｅ本宕查悗锝庡枟閻撳倹绻濇繝鍌滃缂佲偓閸岀偞鐓曢柟鏉垮悁缁ㄨ姤銇勯敃鍌欐喚婵﹥妞介、娆撳垂椤斞勬尰娣囧﹪骞撻幒鎾虫殘缂備礁顑呴ˇ鐢稿春閳ь剚銇勯幒宥堝厡闁?ExpansionTile 缂傚倸鍊搁崐椋庣矆娴ｈ　鍋撳闂寸盎闁?
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
    return ExpansionTile(
      title: Text(tittle,
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.bodySmall!.apply(
                color: Theme.of(context).colorScheme.primary,
              )),
      children: names!.map((name) => _generateWidget(name)).toList(),
    );
  }

  /// 闂傚倷鐒﹂惇褰掑垂婵犳艾绐楅柟鐗堟緲閸?ExpansionTile 婵犵數鍋為崹鍫曞箰閹间緡鏁勯柛銉戔偓閺?ListView 闂傚倷鐒﹂惇褰掑礉瀹€鈧埀顒佸嚬閸撴瑩鎮鹃悜鑺ュ亜闁告縿鍎弸鏍ь渻閵堝懐绠版俊顐ｇ洴閹瞼鈧綆鈧?
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

    /// 婵犵數鍋犻幓顏嗙礊閳ь剚绻涙径瀣鐎殿噮鍋婃俊鍫曞炊閵娿儳褰撮梻渚€娼ч敍蹇涘川椤栨粌甯掓繝鐢靛仜椤曨厽鎱ㄩ幆褉鏋栨繛鎴炲殠娴滃綊鏌涘▎蹇ｆШ妞も晝鍏橀弻鏇熷緞閸績鍋撻弴銏犵厺闊洦绋掗崐鐢电棯椤撶偞鍣烘い銉ヮ樀閹鎲撮崟顐熸灆濡ょ姷鍋為敃銏ょ嵁鐎ｎ喗鍊烽柟缁樺醇?
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
                  width: 150, // 闂傚倷鐒﹂幃鍫曞磿闁秴绠规い鎰堕檮閸嬧晠鏌涢幘妞诲亾闁稿鎸惧☉鐢稿川椤曞懏顥夐梺?
                  height: 36, // 闂傚倷鐒﹂幃鍫曞磿闁秴绠规い鎰堕檮閸嬧晠鏌ｉ幇闈涘⒒婵炲牊顨嗘穱濠囶敍濮橆厽鍎撳?

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

  //闂佽楠哥紞濠傤焽閼姐倗纾芥慨妯挎硾閻ら箖鏌涢锝嗙缂佲偓閸℃ü绻嗛柕鍫濇噹椤忋儵鏌嶈閸撴瑩宕幘顔艰摕鐎光偓閳ь剚绂掗敃鍌氱畾鐟滃繐螣閸℃稒鈷掑ù锝堟閹藉倿鏌涢悩瀹犲闁崇粯鎹囬獮瀣晜閽樺鍋撻悜鑺ョ厽闁绘柨鎲＄欢鍙夋叏閿濆拑宸ラ棁澶嬬節婵犲倸鏋ら柛搴″缁?
//闂傚倷绶氬鑽ゆ嫻閻旂厧绀夐悗锝庡枟閸ゅ牓鏌熸潏楣冩闁抽攱甯￠弻鐔虹磼閵忕姵鐏堥梺鍛婃煟閸庣敻寮诲☉銏犵闁瑰鍎愬Λ锟犳⒑缁夊棗鍠涢煬顒傗偓瑙勬礃缁诲牓骞冮埡鍛闁圭儤娲﹂崬褰掓⒒娴ｅ摜绉洪柡鈧柆宥嗗亱婵°倕鍟犻崑鎾愁潩椤掍礁浠村Δ鐘靛仦鐢喖藝鏉堛劎绠鹃柛鈩冨姇閻忔煡鏌℃担鍝バゅù鐙呯畵瀹曟劙鎮㈡搴¤濠电姷鏁搁崕鎴犵礊閳ь剚銇勯弴鍡楀閸欏繘鏌ｉ幇顒佹儓缂佲偓閸℃稒鐓熺憸蹇浰夐幎銈泃ButtonList闂傚倷娴囧銊╂倿閿旂晫鐝堕柛鈩冪懃閸ㄦ繄鈧箍鍎遍ˇ浼存偂閸屾壕鍋撻崗澶婁壕闁诲函缍嗛崜娑⑺囬鈧娲传閸曨偀鍋撻崸妤€鐒垫い鎺嶈兌閵嗘帡鏌嶇憴鍕诞闁哄矉绻濆畷鐔碱敃閳垛晜瀵栭梻?
  void addFloatButton(name) {
    DraggableElement element = addElementToList(name, lastFontSize);

    setState(() {
      elements.add(element);
    });
  }

  String csv = "";

  void _exportCSV({List<DraggableElement>? exportElements}) async {
    List<DraggableElement> targetElements = exportElements ?? elements;
    List<List<dynamic>> csvData = <List<dynamic>>[];
    // csvData.add(['Time', 'Name']);
    //闂傚倷鑳堕幊鎾绘倶濮樿泛绠扮紒瀣硶閺嗐倝鏌涢幇鐢靛帥婵為棿鍗抽弻銊モ攽閸℃ê娅ら梺绋匡工椤兘寮婚悢琛″亾濞戞瑯鐒藉褎濞婇弻宥堫檨闁告挻鐟╅獮濠冩償閳藉棗娈ㄦ繛瀵稿Т椤戝懐鎲?
    if (_selectedPrintDirection == 'Forward') {
      csvData.add(['ROTATE', '0']);
    } else {
      csvData.add(['ROTATE', '0']);
    }
    int width = int.parse(_widthController.text) * 8;
    int height = int.parse(_heightController.text) * 8;

    //闂傚倷鑳堕幊鎾绘倶濮樿泛绠扮紒瀣硶閺嗐倝鏌涢幇鍏哥敖婵☆偒鍨崇槐鎺斺偓锝庡幗绾爼鏌ｉ幇顒婂伐妞ゎ厼娼″畷濂稿幢濡も偓閺嗙喐鎱?
    csvData.add(['P', width.toString(), height.toString()]);

    for (var i = 0; i < targetElements.length; i++) {
      if (targetElements[i].type.name == 'text') {
        int fontsize = int.parse(targetElements[i].fontSize ?? '0');
        List fontlist = getFontSize(fontsize);
        csvData.add([
          'TB',
          targetElements[i].position.dx.toInt(),
          targetElements[i].position.dy.toInt(),
          targetElements[i].width,
          targetElements[i].height,
          fontlist[0],
          fontlist[1],
          fontlist[2],
          _getstyle(
              targetElements[i].fontBold!, targetElements[i].fontReverse!),
          _getRotation(targetElements[i].rotation!),
          'TEXT',
          targetElements[i].content,
          targetElements[i].index,
        ]);
      } else if (targetElements[i].type.name == 'data') {
        int fontsize = int.parse(targetElements[i].fontSize ?? '0');
        List fontlist = getFontSize(fontsize);
        csvData.add([
          'TB',
          targetElements[i].position.dx.toInt(),
          targetElements[i].position.dy.toInt(),
          targetElements[i].width,
          targetElements[i].height,
          fontlist[0],
          fontlist[1],
          fontlist[2],
          _getstyle(
              targetElements[i].fontBold!, targetElements[i].fontReverse!),
          _getRotation(targetElements[i].rotation!),
          'DATA',
          targetElements[i].varName,
          targetElements[i].defaultValue,
          targetElements[i].alignment,
          targetElements[i].maxLength,
          targetElements[i].index,
        ]);
      } else if (targetElements[i].type.name == 'barcode') {
        String tempContent = '';
        if (targetElements[i].style == 0) {
          tempContent = _barcodeContent(targetElements[i].varcontent!);
        } else {
          tempContent = _barcodeContent1(targetElements[i].varcontent!);
        }
        String barcodeType = '';
        String hrAlignment;
        if (targetElements[i].barcodeType == 'Code128') {
          barcodeType = '1';
        } else if (targetElements[i].barcodeType == 'Code39') {
          barcodeType = 'CODE39';
        } else if (targetElements[i].barcodeType == 'EAN8') {
          barcodeType = 'EAN8';
        } else if (targetElements[i].barcodeType == 'EAN13') {
          barcodeType = 'EAN13';
        } else if (targetElements[i].barcodeType == 'UPC-A') {
          barcodeType = 'UPCA';
        } else if (targetElements[i].barcodeType == 'UPC-E') {
          barcodeType = 'UPCE';
        }
        if (targetElements[i].hralignment == 'Top') {
          hrAlignment = 'TC';
        } else if (targetElements[i].hralignment == 'Bottom') {
          hrAlignment = 'BC';
        } else {
          hrAlignment = 'N';
        }
        csvData.add([
          'B',
          targetElements[i].position.dx.toInt(),
          targetElements[i].position.dy.toInt(),
          targetElements[i].width!.toInt(),
          targetElements[i].height!.toInt(),
          '2',
          barcodeType,
          _getRotation(targetElements[i].rotation!),
          hrAlignment,
          tempContent,
          targetElements[i].index,
        ]);
      } else if (targetElements[i].type.name == 'qrcode') {
        String tempContent = '';
        if (targetElements[i].style == 0) {
          tempContent = _barcodeContent(targetElements[i].varcontent!);
        } else {
          tempContent = _barcodeContent1(targetElements[i].varcontent!);
        }

        String version = '1';
        String errorlevel = '1';

        csvData.add([
          'QR',
          targetElements[i].position.dx.toInt(),
          targetElements[i].position.dy.toInt(),
          version,
          targetElements[i].qrWidth.toString(),
          errorlevel,
          '',
          tempContent,
          targetElements[i].index,
        ]);
      }
      //缂傚倸鍊烽懗鍫曞磻閹惧灈鍋撶粭娑樺枤閻掕姤銇勯弽銊р槈缂佸墎鍋ら弻娑㈠Ψ椤栨粎鏆犻梺?
      // else if (targetElements[i].type.name == 'line') {
      //   if (targetElements[i].lineWidth! <= targetElements[i].x2Pos!) {
      //     csvData.add([
      //       'L',
      //       targetElements[i].position.dx.toInt(),
      //       targetElements[i].position.dy.toInt(),
      //       (targetElements[i].x2Pos! + targetElements[i].position.dx.toInt()).toInt(),
      //       targetElements[i].position.dy.toInt(),
      //       targetElements[i].lineWidth!.toInt(),
      //       0, //缂傚倸鍊烽悞锕€鐣峰Ο琛℃灃闁哄洨濮甸崑鏍ㄣ亜閹板墎鐣遍柛?
      //       targetElements[i].index,
      //     ]);
      //   } else {
      //     csvData.add([
      //       'L',
      //       targetElements[i].position.dx.toInt(),
      //       targetElements[i].position.dy.toInt(),
      //       targetElements[i].position.dx.toInt(),
      //       (targetElements[i].lineWidth! + targetElements[i].position.dy.toInt()).toInt(),
      //       targetElements[i].x2Pos!.toInt(),
      //       0, //缂傚倸鍊烽悞锕€鐣峰Ο琛℃灃闁哄洨濮甸崑鏍ㄣ亜閹板墎鐣遍柛?
      //       targetElements[i].index,
      //     ]);
      //   }
      // }
//x1,y1,x2,y2,lineWidth,lineType,index
      else if (targetElements[i].type.name == 'line') {
        int lineWidth = targetElements[i].size.width.toInt();
        int lineHeight = targetElements[i].size.height.toInt();
        //濠电姷顣藉Σ鍛村垂閸忚偐顩查柣鎰惈閸?
        if (lineHeight <= lineWidth) {
          csvData.add([
            'L',
            targetElements[i].position.dx.toInt(),
            targetElements[i].position.dy.toInt(),
            (lineWidth + targetElements[i].position.dx.toInt()).toInt(),
            targetElements[i].position.dy.toInt(),
            lineHeight,
            0, //缂傚倸鍊烽悞锕€鐣峰Ο琛℃灃闁哄洨濮甸崑鏍ㄣ亜閹板墎鐣遍柛?
            targetElements[i].index,
          ]);
          // print(csvData.last);
        } else {
          csvData.add([
            'L',
            targetElements[i].position.dx.toInt(),
            targetElements[i].position.dy.toInt(),
            targetElements[i].position.dx.toInt(),
            (lineHeight + targetElements[i].position.dy.toInt()).toInt(),
            lineWidth,
            0, //缂傚倸鍊烽悞锕€鐣峰Ο琛℃灃闁哄洨濮甸崑鏍ㄣ亜閹板墎鐣遍柛?
            targetElements[i].index,
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

//濠电姵顔栭崰妤冪紦閸ф纾归柡鍥ｆ嚍閸ヮ剙鐓涢柛鎰ㄦ櫅閺嬪倿姊洪幐搴ｇ畵婵☆偅鐩崺鈧い鎴ｆ硶閻瑧鈧鍠栭悥濂稿极瀹ュ绀嬫い鎾跺仧娴狀垶姊绘担鍛婂暈闁告梹娲熼獮濠冩償椤垶鏅╅梺瑙勫婢ф寮查鍕€堕柣鎰版涧娴滈箖鏌熼悜鎴掓喚闁哄本鐩弫鍐磼閵堝棙顓肩紓鍌欑劍椤ㄥ懘藝閹殿喚鐭欏鑸靛姇閻掑灚銇勯幒鎴濃偓鐢稿磻閹捐埖鍠嗛柛鏇ㄥ弾閺嗏€斥攽閻橆偄浜炬繛杈剧到婢瑰﹤顭囨导瀛樼厪闁割偅绻冮ˉ鐐烘煢閸屾凹鍎旈柡宀嬬秮椤㈡瑩鎳￠妶鍛瀴闂備胶绮〃鍫モ€﹂崼銉晪闁挎繂鐗忛悿鈧柣搴€ラ崘褍顥氶梻浣侯焾閻ジ宕戝☉銏犲偍闁圭虎鍠楅悡娆戠磼鐎ｎ偒鍎ユ俊鎻掔秺閺岋綁濡烽妷锕€娈楅悗娈垮枛閻忔艾顕ラ崟顓涘亾閿濆娑у┑鈥插嵆濮婃椽宕崟鍨€嗙紓浣介哺濞茬喖骞冮妷銉叆闁割偅绻傞崬銊╂⒑缂佹ɑ灏繛鎾棑濞戠敻鍩€椤掍胶绡€闁靛骏绲剧涵楣冩倵濮樼厧娅嶆?
  String _barcodeContent1(List<dynamic> con) {
    final barcodedata =
        StringBuffer(); // 婵犵數鍋犻幓顏嗙礊閳ь剚绻涙径瀣鐎?StringBuffer 闂傚倷绀侀幖顐λ囬銏犵？闁哄被鍎查崐鍨亜閺嶃劌鍤柛銈呯墦閺屾稑鈹戦崱妤婁紑闂佸湱鏅崰鎾舵閹烘嚦鏃傗偓锝庡墰缁愭鏌?
    if (con.isEmpty) {
      return barcodedata.toString();
    }
    for (final item in con) {
      if (barcodedata.isNotEmpty) {
        barcodedata.write(
            ','); // 闂傚倷绶氬鑽ゆ嫻閻旂厧绀夐悘鐐靛亾濞呯娀鏌ｅΟ铏癸紞闁崇粯妫冮弻宥堫檨闁告挻姘ㄧ划娆愬緞閹板灚鏅滈梺鍓插亝缁嬪牓宕戦幘鎰佸悑濠㈣泛顑呴崜顔碱渻閵堝棙顥嗙€规洜鏁婚、妯好洪鍛幈濠殿喗锕╅崜鐔煎矗閸曨兛绻嗙紓浣靛灩濞呭秶鈧娲樼换鍫ュ箖閳哄懏鍊婚柍杞版婢规洖鈹戞幊閸婃劙宕戦幘鑸靛枑闁哄瀵ч崑銉р偓瑙勬礃瀹€绋跨暦閸楃偐妲堟繛鍡樏幃鈺冪磽?
      }
      if (item is Map) {
        if (item['type'] == 'TEXT') {
          barcodedata.write('TEXT,${item['content']}');
        } else {
          var varalignment = 1;
          if (item['alignment'] == 'Center') {
            varalignment = 2;
          } else if (item['alignment'] == 'Right') {
            // 缂傚倸鍊搁崐鐑芥嚄閸洖绐楃€广儱娲ㄩ崡姘舵倵閻㈠憡娅滈柣鎺戯躬閺屾盯鍩勯崗鈺傚灥椤曪綁骞樼紒妯煎幈濠电偞鍨堕悷銉╂倶婵犲洦鐓犻柛顭戝亜閻忔挳鏌熼姘殻鐎规洜鍠栭、妤呭焵椤掑嫬绀堝ù鐓庣摠閻撴洟鏌熼柇锔跨敖缂佷線鏀遍妵鍕敃閵忊晛鍓辩紓?'Left'
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
            // 缂傚倸鍊搁崐鐑芥嚄閸洖绐楃€广儱娲ㄩ崡姘舵倵閻㈠憡娅滈柣鎺戯躬閺屾盯鍩勯崗鈺傚灥椤曪綁骞樼紒妯煎幈濠电偞鍨堕悷銉╂倶婵犲洦鐓犻柛顭戝亜閻忔挳鏌熼姘殻鐎规洜鍠栭、妤呭焵椤掑嫬绀堝ù鐓庣摠閻撴洟鏌熼柇锔跨敖缂佷線鏀遍妵鍕敃閵忊晛鍓辩紓?'Left'
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

        // final file = await _localFilepath; ///////闂傚倷绀侀崥瀣磿閹惰棄搴婇柤鑹扮堪娴滃綊鏌涢妷顔煎闁绘劕锕弻娑樷攽閸℃浼€闂佸搫妫欏姗€婀侀梺鎸庣箓閹虫劘鍊撮梻?
        final file = File(p.join(path));
        // 闂備浇顕х换鎰崲閹邦儵娑樜旈崨顔间槐閻熸粌绻掗崚鎺楊敇閵忊剝娅嗛梺鍏煎墯閸ㄧ厧煤椤掑嫭鈷戦柛娑橈工婵牓鏌ｉ悢鏉戝姦鐎规洩缍佸畷鍗炩槈濡椿妫熼梻浣规偠閸庡姊介崟顖ｆ晝闁芥ê顦Σ?
        // print(formatjson);
        file.writeAsStringSync(formatjson);

        // await loadData();   濠电姵顔栭崰妤冪紦閸ф纾归柡鍥ｆ嚍閸ヮ剙鐓涘〒姘搐閺呯娀姊洪懖鈹炬嫛闁告挻鐩幆鈧柛娑樼摠閻撴洟鏌熼柇锕€骞橀柟鍐插暣閺屾洟宕奸敐鍛呮挾绱掗崒姘毙х€规洖宕灃濠电姴鍟幃娆忊攽閻愯埖褰х紒鍙夊劤鐓ゆ俊顖濇閺嗭附銇勯幒鎴濐仼闁绘劕锕弻锝夊箛椤掑倹鎲奸梻鍌氬缁夊綊寮婚埄鍐ㄧ窞婵炴垶姘ㄩ敍鐔兼⒑缂佹澧紒顔肩Ф缁岸鏌嗗鍛姶闂佸憡鍓崨顖ｆК
      }
    } catch (e) {
      setState(() {
        showTipInfo('$e Save fail', context);
      });
    }
  }

  //闂傚倷绀侀幉锛勬暜閸ヮ剙纾归柡宥庡幖閽冪喖鏌涢妷顔煎婵☆偅锕㈤弻娑㈠Ψ椤栫偞顎嶅銈嗗姃缁瑩寮婚敓鐘茬闂傚牊绋撴禒鈺呮⒑鐠団€崇仧缂佽埖鑹鹃锝嗗閹碱厽鏅┑顔斤供閸橀箖銆呴銏♀拺缂備焦锕╁▓鏃€绻涚拠褏鎮肩紒顕呭弮瀵粙顢橀悙鎻掓尋婵＄偑鍊栭悧妤冨枈瀹ュ纾垮┑鐘叉处閻撶喐銇勮箛鎾搭棞闁哄閰ｉ弻锝夊Χ閸涱収浼€闂侀€炲苯澧紒瀣浮閺佸鈹戦悩顐壕?
  bool isImagePath(String path) {
    // 闂備浇顕у锕傦綖婢舵劖鍎楁い鏂垮⒔娑撳秹鏌ｉ弮鍌氬妺闁哄棙绮嶉幈銊モ攽閸℃瑧鍔稿┑鐐靛帶閻倿寮婚敐澶娢╅柕澶堝労娴犵厧鈹戦悙鑼憼闁挎洏鍨介獮鍐樄鐎规洖鐖兼俊鎼佹晜闁款垰浜炬い鏃€绁硅ぐ鎺撳亹闁告繂瀚崢顐ｇ節閳封偓閸℃銆婃繛瀵稿缁犳挸顕ｉ幘顔藉€烽柡澶嬪灍閸?
    const List<String> imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp'
    ];

    // 闂傚倷绀侀幉锛勬暜濡ゅ啰鐭欓柟瀵稿Х绾句粙鏌熼幑鎰靛殭婵☆偅锕㈤弻娑㈠Ψ椤栫偞顎嶅銈嗗姃缁瑩骞冨Δ鍛仺婵炲牊瀵ч弫顖炴⒑?
    File file = File(path);

    // 濠电姷顣藉Σ鍛村磻閳ь剟鏌涚€ｎ偅宕岄柡宀嬬磿娴狅妇鎷犻幓鎺戭潥闂備礁鎼鍛村疮椤栨粎鐭夐柟鐑橆殕閸ゅ鏌涢…鎴濃偓锝夋晝閸屾稓鍘卞┑顔矫晶浠嬫偩闁秵鐓熼幒鎶藉礉閹存繄鏆?
    if (!file.existsSync()) {
      return false;
    }

    // 闂傚倷绀侀崥瀣磿閹惰棄搴婇柤鑹扮堪娴滃綊鏌涢妷顔煎婵☆偅锕㈤弻娑㈠Ψ椤栫偞顎嶅銈嗗姃缁瑩寮婚敐澶娢╅柕澶堝労娴犵偓绻濋埛鈧崱妯笺€婃繛瀵稿缁犳挸顕ｉ幘顔藉€烽柡澶嬪灍閸?
    String extension = path.substring(path.lastIndexOf('.')).toLowerCase();

    // 闂傚倷绀侀幉锛勬暜閸ヮ剙纾归柡宥庡幖閽冪喖鏌涢妷顔煎缂佺姰鍎甸弻宥嗘姜閹峰苯鍘″┑鐐插悑濡啴寮诲☉姗嗘僵妞ゆ帒鍊愰敐鍡曠箚闁告瑥顦伴崐鎰偓瑙勬磸閸庣敻寮崘顔肩劦妞ゆ巻鍋撻柨鏇樺灲椤㈡棃宕煎┑鍫濃偓鐐烘⒑閸涘﹥瀵欓柛鎰亾濮ｅ牓姊绘担鍛婅础妞わ絼绮欏鎻掆槈閵忊€冲壍閻庡箍鍎遍ˇ顖滄喆閿旈敮鍋撻獮鍨姎闁瑰啿閰ｉ幃妯衡枎閹炬潙浠╁┑鐐村灦閻楁洘淇婂ú顏呯厾?
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
    //闂傚倷绀侀幉锛勬暜閸ヮ剙纾归柡宥庡幖閽冪喖鏌涢妷顔煎缂佺嫏鍥ㄧ叆婵炴垶锚椤忣偊鏌涢妸锕€鈻曢柡灞诲妼閳藉螣娓氼垱顔勭紓鍌欓檷閸斿寮插┑鍫燁潟闁圭儤鏌￠崑鎾绘濞戞瑦鍠愰梺鎼炲妽婵炲﹪寮诲☉銏℃櫆闁告繂瀚‖鍡欑磽娴ｈ娈旀い锕傛涧閻?

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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: width - 10),
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
                              width: 150, // 闂備浇宕垫慨宕囩矆娴ｈ娅犲ù鐘差儐閸嬵亪鏌涢埄鍐槈闁绘劕锕弻娑樷攽閸℃浼€闂佸搫妫旈崡鎶藉箖濡ゅ啯鍏滈柛娑卞櫘濡嫰鏌?
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
                              width: 150, // 闂備浇宕垫慨宕囩矆娴ｈ娅犲ù鐘差儐閸嬵亪鏌涢埄鍐槈闁绘劕锕弻娑樷攽閸℃浼€闂佸搫妫旈崡鎶藉箖濡ゅ啯鍏滈柛娑卞櫘濡嫰鏌?
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
                                width: 80, // 闂備浇宕垫慨宕囩矆娴ｈ娅犲ù鐘差儐閸嬵亪鏌涢埄鍐槈闁绘劕锕弻娑樷攽閸℃浼€闂佸搫妫旈崡鎶藉箖濡ゅ啯鍏滈柛娑卞櫘濡嫰鏌?
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
                                width: 80, // 闂備浇宕垫慨宕囩矆娴ｈ娅犲ù鐘差儐閸嬵亪鏌涢埄鍐槈闁绘劕锕弻娑樷攽閸℃浼€闂佸搫妫旈崡鎶藉箖濡ゅ啯鍏滈柛娑卞櫘濡嫰鏌?
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
                                              .bodySmall), ////濠电姵顔栭崰妤冪紦閸ф纾归柡鍥ｆ嚍閸ヮ剙鐓涢柛娑卞櫘濮婂潡姊洪柅鐐茶嫰婢т即鏌熼懠顒€顣奸柟宄版嚇閹嫰骞掗幘鏉戠３閻庤娲栭悥濂稿箖濞嗗浚鍟呮い鏂垮建?
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
                            _saveFormatToJson(
                                jsonFilePath); //闂傚倷绀侀幉锟犳嚌妤ｅ啫瀚夋い鎺嗗亾妞ゎ亜鍟村畷鎺戔槈濮橈絾鏁垫繝鐢靛█濞佳兾涘☉銏犵闁绘ɑ绁村Σ鍫ユ煙缂併垹鐏犲ù婊呭亾缁绘稓鈧數顭堥瀷濠碘槅鍋勭€氭澘鐣烽搹鍏夊亾閻у摜顔巓n
                          }
                          ////濠电姷鏁搁崕鎴犵礊閳ь剚銇勯弴鍡楀閸欏繘鏌ｉ幇顕呮毌闁稿鎹囧畷鐑筋敇閻愮増鍩涙俊?
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
      ),
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
                    color: Theme.of(context)
                        .colorScheme
                        .primary, // 闂備礁鎼ˇ顖炴偋閹板府缍栧鑸靛姂閳ь兛鑳堕埀顒婄秵閸嬫挾妲愰敐鍡欑瘈濠电姴鍊归ˉ婊勩亜閵夈儳绠婚柡灞诲妼閳藉螣閼测晛濮扮紓鍌欒兌缁垶鎮ч悩璇茶摕鐎光偓閳ь剚绂掗敃鍌涘亗閹煎瓨蓱閻庡ジ姊绘担瑙勩仧婵炵厧娼″畷婵堚偓锝庡厴閸嬫捇妫冨☉娆愭嫳闂佹寧绋掗崝鏇＄亽闂佺绻楅崑鎰板汲閻樺磭绠鹃柟瀵稿仦鐏忕増淇婇崣澶婄瑲缂?
                    width: 1, // 闂備礁鎼ˇ顖炴偋閹板府缍栧鑸靛姂閳ь兛鑳堕埀顒婄秵閸忔﹢宕戦幘鑸靛厹闁告侗鍣Λ鍕煟鎼达綆鏀版繛鍛礈缁?2 闂傚倷鑳堕…鍫㈢矓鐎靛憡宕查柟鐑樻⒒閻?
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        4), // 闂備礁鎼ˇ顖炴偋閹板府缍栧鑸靛姂閳ь兛鑳堕埀顒婄秵閸犳牠骞戦崼鏇熺厱闁斥晛鍟崵顒佺箾绾绡€闁哄本绋戣灃闁逞屽墴閺佸啴濡堕崶顭戝仺闂佺粯鍔曢顓㈠煝?8 闂傚倷鑳堕…鍫㈢矓鐎靛憡宕查柟鐑樻⒒閻?
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
        // 闂備浇宕垫慨宕囩矆娴ｈ娅犲ù鐘差儐閸嬵亪鏌涢埄鍏╂垹绱為崶顒佸仭婵炲棗绻愰鎾煛閳ь剟鏌嗗鍡欏幐閻庡箍鍎遍幊搴∥ｉ懡銈囩＜?
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .primary, // 闂備礁鎼ˇ顖炴偋閹板府缍栧鑸靛姂閳ь兛鑳堕埀顒婄秵閸嬫挾妲愰敐鍡欑瘈濠电姴鍊归ˉ婊勩亜閵夈儳绠伴柍钘夘樀楠炴﹢鎳￠妶鍥╃崶闂備胶顢婃慨銈夊垂閸ф绠?
            width: 1, // 闂備礁鎼ˇ顖炴偋閹板府缍栧鑸靛姂閳ь兛鑳堕埀顒婄秵閸忔﹢宕戦幘鑸靛厹闁告侗鍣Λ鍕煟鎼达綆鏀版繛鍛礈缁?2 闂傚倷鑳堕…鍫㈢矓鐎靛憡宕查柟鐑樻⒒閻?
          ),
          borderRadius: BorderRadius.circular(
              4), // 闂備礁鎼ˇ顖炴偋閹板府缍栧鑸靛姂閳ь兛鑳堕埀顒婄秵閸犳牠骞戦崼鏇熺厱闁斥晛鍟崵顒佺箾绾绡€闁哄本绋戣灃闁逞屽墴閺佸啴濡堕崶顭戝仺闂佺粯鍔曢顓㈠煝?8 闂傚倷鑳堕…鍫㈢矓鐎靛憡宕查柟鐑樻⒒閻?
        ),
        padding:
            EdgeInsets.all(10), // 闂備浇宕垫慨宕囩矆娴ｈ娅犲ù鐘差儐閸嬵亪鏌涢埄鍐槈缂佲偓閸愵喗鐓曟繛鎴炵懃椤ュ鏌ｅ┑鍡欏煟闁诡喖缍婇幃婊兾熼懖鈺冩殸闂?10 闂傚倷鑳堕…鍫㈢矓鐎靛憡宕查柟鐑樻⒒閻?
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

//闂傚倷鐒﹂惇褰掑垂婵傚壊鏁嬬憸蹇曞垝閳哄懏鍊婚柤鎭掑劤閸旀悂姊洪棃娑辩劸闁稿酣浜堕幃?
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
                              fit: BoxFit.fill,));

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
                          //濠殿喗宕块崨顓夛綁鏌ｉ弽鐢垫偧缂侇喗姊婚幏鐘诲箵閹诡偅顨婇弻娑㈠箻瀹曞泦锛勭磼缂佹ɑ鐨戦柍褜鍓氱粙鎺椻€﹂崶銊﹀弿闁归棿绀佺粻?
                          _saveState();
                        },
                        onScaleUpdate: (details) {
                          if (details.scale == 1) {
                            if (selectedElements.contains(element)) {
                              moveSelectedElements(details.focalPointDelta);
                            } else {
                              setState(() {
                                element.position += details.focalPointDelta;
                                // 缂傚倷绀侀ˇ鎶筋敋瑜庨幈銊╁煛閸涱厾鐫勯梺鍓插亝濞插秹宕戦幘鏉戠窞濠㈣泛楠搁獮鈧梺鑽ゅТ濞层垽宕曢柆宥呭偍闁规崘鍩栭～?
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
                          //濠殿喗宕块崨顓夛綁鏌ｉ弽鐢垫偧缂侇喗姊婚幏鐘诲箵閹诡偅顨婇弻娑橆潩椤掑倸鍤紓浣虹帛濮樸劑鍩€椤掍胶鈯曟い顓炴处閹便劑骞栨担鍝ョ暠?
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

  void _showPrintSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const PrintSettingsDialog();
      },
    );
  }

  void _executePrint(List<DraggableElement> previewElements) async {
    _exportCSV(exportElements: previewElements);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String protocol = prefs.getString('printOnline_protocol') ?? 'Lp50';
    String serialPort = prefs.getString('printOnline_serialPort') ?? 'COM1';
    String baudRateStr = prefs.getString('printOnline_baudRate') ?? '9600';
    int baudRate = int.tryParse(baudRateStr) ?? 9600;

    String weightVal = '0.000';
    String weightUnit = 'kg';
    bool isNet = false;
    bool isZero = false;

    if (_currentWeight != null) {
      weightVal = _currentWeight!.weightVal ?? '0.000';
      weightUnit = _currentWeight!.weightUnit ?? 'kg';
      isNet = _currentWeight!.isNet ?? false;
      isZero = _currentWeight!.isZero ?? false;
    }

    Map<String, dynamic> requestBody = {
      'protocol': protocol,
      'serialPort': serialPort,
      'baudRate': baudRate,
      'formatCsv': csv,
      'weightVal': weightVal,
      'weightUnit': weightUnit,
      'isNet': isNet,
      'isZero': isZero,
    };

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:7878/api/print/online'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        if (mounted) showTipInfo('Print command sent successfully', context);
      } else {
        if (mounted) showTipInfo('Failed to print: ${response.body}', context);
      }
    } catch (e) {
      if (mounted) showTipInfo('Error communicating with backend: $e', context);
    }
  }

  void _showPrintPreview() {
    List<DraggableElement> previewElements =
        elements.map((e) => e.copy()).toList();
    for (var element in previewElements) {
      if (element.type == ElementType.data && element.varName != null) {
        String varName = element.varName!.toUpperCase();
        String val = element.varName!;
        if (varName == "GROSS" || varName == "NET") {
          val = _currentWeight?.weightVal ?? '0.000';
        } else if (varName == "TARE") {
          val = '0.000';
        } else if (varName == "WEIGHTUNIT") {
          val = _currentWeight?.weightUnit ?? 'kg';
        } else if (varName == "DATE") {
          val = DateFormat('dd/MM/yyyy').format(DateTime.now());
        } else if (varName == "TIME") {
          val = DateFormat('HH:mm:ss').format(DateTime.now());
        } else if (varName == "NO.") {
          val = "1";
        } else if (varName == "PCS") {
          val = "1";
        }
        element.type = ElementType.text;
        element.content = val;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(localizedStrings.printPreview),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
          content: Container(
            width: canvasSize.width * 1.0,
            height: canvasSize.height * 1.0,
            color: Colors.white,
            child: Stack(
              children: previewElements.map((element) {
                Widget child;
                int quarterTurns = (element.rotation! / 90).round();

                String displayContent = element.content ?? 'Text';

                child = RotatedBox(
                  quarterTurns: quarterTurns,
                  child: SizedBox(
                      width: element.size.width,
                      height: element.size.height,
                      child: Text(displayContent,
                          softWrap: true,
                          style: TextStyle(
                              fontFamily: "simsunb",
                              fontSize:
                                  double.parse(element.fontSize.toString()),
                              color: Colors.black,
                              fontWeight: (element.fontBold == 'true')
                                  ? FontWeight.bold
                                  : FontWeight.normal))),
                );

                return Positioned(
                  left: element.position.dx,
                  top: element.position.dy,
                  child: child,
                );
              }).toList(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _executePrint(previewElements);
              },
              child: Text(localizedStrings.gPrint),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizedStrings.gBtnCancel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final Size screenSize = MediaQuery.of(context).size;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();
    return Focus(
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
                      pageHeadInfo(context, width - headWidthPadding,
                          localizedStrings.printOnline, '',
                          // localizedStrings.gTipPrintOnlinePageHelp,
                          () {
                        formAppSetting = false;
                        Future.delayed(Duration.zero, () {
                          widget.onNavigate(widget.lastRouteName);
                        });
                      }),
                      Expanded(
                          child: Container(
                        color: Theme.of(context).colorScheme.surfaceBright,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 220,
                              color: Theme.of(context).colorScheme.surfaceTint,
                              child: SizedBox(
                                height: height,
                                child: Column(
                                  children: [
                                    SizedBox(height: regularPadding),
                                    Expanded(
                                      child: NewAllScaleListWidget(
                                        listWidth: 220,
                                        selScaleId:
                                            myDefScaleInfo.defScaleId ?? -1,
                                        clickScale: (scale) {
                                          setState(() {
                                            myDefScaleInfo.defScaleId =
                                                scale.scaleId;
                                            PublicFunctions.getWeight(
                                                scale.scaleId);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  showHeadWidget(width - 220),
                                  Container(
                                    height: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                  ),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //闂佽楠哥紞濠傤焽閼姐倗纾芥慨妯挎硾閻ら箖鏌涢锝嗙闁活厽顨嗛幈銊ヮ渻鐠囪弓澹曢梻渚€娼荤徊鎯ь渻娴犲钃熼柛顐犲劚鎯熼梺闈涱槶閸庢娊鍩€?
                                        Container(
                                          width: leftBtnWidth,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
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

                                        //婵犵數鍋為崹鍫曞箹閳哄懎鐭楅柛鎰╁壆濞戙垹閿ゆ俊銈勭娴犳椽鏌ｉ悩鍙夌┛閻忓繑鐟╅、鏃堝箻椤旇В鎷哄銈嗘煥閹碱偅淇婃總鍛婄厱?

                                        Expanded(
                                          flex: 7,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Scrollbar(
                                                  controller:
                                                      horizontalScrollController,
                                                  thumbVisibility: true,
                                                  child: SingleChildScrollView(
                                                    scrollDirection: Axis
                                                        .horizontal, 
                                                    controller:
                                                        horizontalScrollController,
                                                    child: Scrollbar(
                                                      controller:
                                                          verticalScrollController,
                                                      thumbVisibility: false,
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection: Axis
                                                            .vertical, 
                                                        controller:
                                                            verticalScrollController,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          width:
                                                              canvasSize.width +
                                                                  30,
                                                          height: canvasSize
                                                                  .height +
                                                              30,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .surfaceBright,
                                                            border: Border.all(
                                                              width: 0.2,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                            ),
                                                          ),
                                                          child:
                                                              buildCanvasPart(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 150,
                                                    height: 48,
                                                    child: showTextButton(
                                                        context,
                                                        48,
                                                        localizedStrings
                                                            .printPreview, () {
                                                      _showPrintPreview();
                                                    },
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primaryContainer,
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onPrimaryContainer,
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primaryContainer),
                                                  ),
                                                  const SizedBox(width: 30),
                                                  SizedBox(
                                                    width: 150,
                                                    height: 48,
                                                    child: showTextButton(
                                                        context,
                                                        48,
                                                        localizedStrings
                                                            .printSettings, () {
                                                      _showPrintSettings();
                                                    },
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                            ],
                                          ),
                                        ),

                                        //闂傚倷绀侀幉锟犳偡閵夆晛鍌ㄩ柡宥庡幖閻ら箖鏌涢幘鍙夘樂婵炲矈浜弻锝夊箛椤斿厠澶愭煕鐎ｎ偅宕勬い锕€缍婇弻娑欐償閵忊€冲攭閻?
                                        Container(
                                          width: rightBtnWidth,
                                          alignment: Alignment.topLeft,
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          child: Focus(
                                            autofocus: false,
                                            onKeyEvent: (node, event) {
                                              if ((event.logicalKey ==
                                                      LogicalKeyboardKey
                                                          .arrowUp ||
                                                  event.logicalKey ==
                                                      LogicalKeyboardKey
                                                          .arrowDown)) {
                                                // 婵犵數濮伴崹鐓庘枖濞戞埃鍋撳鐓庢珝妤犵偛鍟换婵嬪磼閵堝懏娅婇梻浣瑰濮婂鎼规惔銊ヨ埞闁圭粯甯╅悢鍡涙煠缁嬭法浠涢悘蹇ョ畵閺屸剝绗熼崶褍绫嶅Δ鐘靛仦閸旀牕顕ラ崟顒€绶炵€光偓閳ь剟骞夐鐣岀閻庢稒顭囬惌濠冦亜閹存繂顏╅柍?

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
                            ),
                          ],
                        ),
                      ))
                    ],
                  )));
        }));
  }
}




