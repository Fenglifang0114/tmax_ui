import 'dart:async';

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
import 'package:t_max/data/scale_info_from_db.dart';
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
  // 闂傚倸鍊风粈渚€骞栭锕€纾归柣鐔煎亰閻斿棙鎱ㄥ璇蹭壕閻犱警鍨堕弻娑㈠箛闂堟稒鐏嶉梺绋款儍閸旀垿寮婚弴鐔虹闁割煈鍠掗崑鎾澄旈崨顔兼疄婵°倧绲介崯顖炴偂濞戙垺鐓曢柡鍥ュ妼娴滄粓鏌嶉柨瀣棃闁哄本娲熷畷鍫曞Ω閵夈儲鎳欐俊銈囧Х閸嬬偟鏁悢濡撳洦娼忛妸褏顔曢梺绯曞墲閸旀洟鎮橀鍡欑＜鐎光偓閸曨亝鍠氶梺绯曟櫅鐎氭澘鐣峰Ο娆炬Ь缂備讲鍋撻柍褜鍓熷缁樻媴閸︻厽鑿囬梺鍛婃煥閻ジ鍩€椤掍礁鍤柛姗€绠栧顐︻敋閳ь剙鐣锋總绋垮嵆闁绘劖顔栧Σ鎾⒑閼姐倕鞋婵炲拑缍佸畷鏇㈠Χ婢跺浠?
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
  Timer? _cntAliveTimer;
  Timer? _dataTimeoutTimer;
  bool _isReceivingWeight = false;
  bool _hasNewWeightData = false;

  // 闂傚倸鍊风粈渚€骞栭锕€纾归柣鐔煎亰閻斿棙鎱ㄥ璇蹭壕閻犱警鍨堕弻娑㈠箛闂堟稒鐏嶉梺鍝勬媼閸撴岸骞堥妸銉建闁糕剝顨呯粻娲⒑鐠団€崇仭闁荤喆鍎靛﹢渚€姊洪幐搴ｇ畵婵☆偅鐩幆灞炬償椤兛绨婚梺鍝勫€圭€笛呯矚閸ф鐓忛柛銉ｅ妼婵秶鈧鍠楅幐鎶藉箖閵忋倕浼犻柛鏇ㄥ幒缁?
  List<List<DraggableElement>> undoStack = [];
  List<List<DraggableElement>> redoStack = [];
  int maxUndoSteps =
      100; // 闂傚倸鍊风粈渚€骞栭锔藉亱闁告劦鍠栫壕濠氭煙閻愵剙澧柣鏂挎閺屾盯顢曢姀鈽嗘闁诲孩鍑归崢楣冨焵椤掑倹鏆╅柡浣筋嚙椤繘鎮滃Ο璇插妳闂佽鍎抽崢鏍ㄧ珶閺囩喓绡€婵炲牆鐏濋弸鐔虹磼閸濆嫭鍋ョ€规洘娲熷濠氬Ψ閵夛箒绶?

  //闂傚倸鍊烽懗鍓佸垝椤栨粍鏆滄い蹇撴噸缁诲棝鏌涢妷顔煎缁?

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
      {}; // 闂傚倸鍊烽悞锕€顪冮崹顕呯劷闁秆勵殔缁€澶愭倵閿濆骸澧插┑顔挎珪閵囧嫰骞掑鍥у婵炲瓨鍤庨崐婵嬪蓟濞戞瑧绡€闁告洦鍋呴悘鍫ユ⒑閹肩偛鈧洟顢栭崶顒€绠熼柟闂寸劍閸嬪鏌涢銈呮瀻缁炬澘绉电换婵嬪煕閳ь剟宕ㄩ娑欑€版俊銈囧Х閸嬬偤宕濋弽褜鍤楅柛鏇ㄥ墮缁剁偟鈧厜鍋撻柍褜鍓熼獮澶愵敋閳ь剙顫忛崫鍕懷囧炊瑜嶉‖鍫ユ煟鎼淬垻鐓柛妤€鍟块锝夘敃閿旂粯鏅ｉ梺闈涚箚閸撴繂鈻嶉弽顓熷€甸柛蹇擃槸娴滈箖姊洪崨濠冨闁稿海鍏橀崺锟犲磼濞戞ê浼庢繝鐢靛█濞佳呪偓姘煎墴閹﹢寮婚妷锔惧幈闂佹寧绻傞幊蹇涘疮閻愮鍋撻崹顐ｇ凡閻庢凹鍓熼、妯荤附缁嬭法顦板銈嗘尵婵參宕澶嬧拺閻犲洦褰冮銏㈢磼鐎ｎ偄娴柍銉畵瀹曞爼濡搁敃鈧鍧楁⒑瑜版帗锛熺紒鈧担铏逛笉?

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
      if (_needSendRegWeight(myDefScaleInfo.defScaleId)) {
        PublicFunctions.getWeight(myDefScaleInfo.defScaleId!);
      }
    }

    _eventWeight = eventBus.on<EventReqWeightCountine>().listen((event) {
      if (mounted) {
        if (event.obj.scaleId == myDefScaleInfo.defScaleId) {
          var msgBody = event.obj.msgBody;
          if (msgBody != null) {
            _isReceivingWeight = true;
            _hasNewWeightData = true;
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
    _startScaleAliveTimer();
    _startDataStreamChecker();
  }

  bool _needSendRegWeight(int? scaleId) {
    if (scaleId == null || scaleId <= 0) return false;
    for (var scale in myAllScalesList) {
      if (scale.scaleId == scaleId) {
        String? protocol = scale.protocolName;
        if (protocol != null && protocol.toUpperCase() == 'SCP-X') {
          return true;
        }
        return false;
      }
    }
    return false;
  }

  void _startScaleAliveTimer() {
    _cntAliveTimer?.cancel();
    _cntAliveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      int? scaleId = myDefScaleInfo.defScaleId;
      if (scaleId != null && scaleId > 0) {
        PublicFunctions.sendScaleAlive(scaleId);
        if (!_isReceivingWeight && _needSendRegWeight(scaleId)) {
          PublicFunctions.getWeight(scaleId);
        }
      }
    });
  }

  void _startDataStreamChecker() {
    _dataTimeoutTimer?.cancel();
    _dataTimeoutTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_hasNewWeightData) {
        _isReceivingWeight = false;
      }
      _hasNewWeightData = false;
    });
  }

  void _stopAliveTimers() {
    _cntAliveTimer?.cancel();
    _dataTimeoutTimer?.cancel();
  }

  @override
  void dispose() {
    _stopAliveTimers();
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
      if (_needSendRegWeight(myDefScaleInfo.defScaleId)) {
        PublicFunctions.stopWeight(myDefScaleInfo.defScaleId!);
      }
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
    // 闂?ByteData 闂傚倸鍊烽懗鍫曞磿閻㈢鐤炬繛鎴欏灪閸嬨倝鏌曟繛褍瀚▓浼存煟鎼淬垻鈯曢拑鍗炩攽椤旂晫鐭嬮柕鍥у楠炴帒顓奸崶鑸敌滈梺鐟板悑濞兼瑩鏁冮妶澶婄叀?JSON 闂傚倷娴囬褏鈧稈鏅濈划娆撳箳濡炲皷鍋撻崘顔奸唶闁靛鍠楅弲鐐寸箾鏉堝墽鍒版繝鈧柆宥呯厺?
    final jsonString = bytes.buffer.asUint8List();
    final jsonData = utf8.decode(jsonString);

    deleteAllElements();
    readTextInfoListFromStr(jsonData);
  }

  // 闂傚倷娴囬褍霉閻戝鈧焦绻濋崑鑺ョ洴瀹曠喖顢樺☉妯瑰缂佺虎鍘奸幊蹇涙偟椤忓懐绠鹃柣鎾虫捣缁犵粯顨ラ悙杈捐€跨€规洘锕㈤獮鎾诲箳閹惧湱鍙戞繝鐢靛Х椤ｄ粙宕滃┑瀣ㄢ偓鍐川椤撳洦绋戦埥澶愬閻樻妲烽柣搴＄畭閸庨亶藝娴兼潙纾归柣鎴ｅГ閻撶喖鏌ｉ弬鎸庡暈缂佹儼灏欑槐鎾愁吋閸曨厾鐛㈤梺鍝勬湰閻╊垰顕ｆ禒瀣╃憸宥夊焻閻熼偊娓婚柕鍫濈箺閸氬倿鏌￠崨顖氣枅妤?
  void _onTextWidthFocusChange() {
    if (!textWidthFocusNode.hasFocus) {
      // 闂傚倷娴囬褏鎹㈤幇顔藉床闁归偊鍎靛☉妯锋闁靛繒濮烽ˇ顕€鎮楅獮鍨姎妞わ缚鍗冲畷鎰槹鎼达絾锛忓銈嗘尵閸嬬偤宕抽搹鍦＜濞撴艾娲ら弸銈囩磼鏉堛劌绗氱€垫澘瀚幆鏃堫敊閸忕⒈鍞查梻鍌欒兌绾爼寮插☉銏犲珘妞ゆ帒鍊婚惌娆忣熆閼搁潧濮堥柛銈嗗浮閺屾洟宕煎┑鍥ф濡炪値鍓欓ˇ闈涱潖閾忓湱纾兼俊顖氭惈椤骸顪冮妶鍐ㄧ仼闁挎洏鍎茬粚杈ㄧ節閸ヨ埖鏅ｉ梺闈涚箚閳ь剚鏋奸崑?
      _focusNode.requestFocus();
    }
  }

  // 濠电姴鐥夐弶搴撳亾閺囥垹纾圭憸鐗堝笚閺咁亪姊虹拠鍙夋崳妞ゃ垹锕ら埢宥夊即閻戝棛鍔烽棅顐㈡处缁嬫垹绮绘繝姘厱闁归偊鍘肩徊缁樻叏鐟欏嫬绲婚柍瑙勫灴閸╁嫰宕橀悙顒傛殽婵犵妲呴崑鍛存儎椤栨氨鏆︽繝闈涙－閸氬顭跨捄渚剰闁逞屽墰閸忔﹢寮婚敐澶嬪亜闁告稑锕﹂崙锛勭磽閸屾氨小缂佽埖宀稿璇测槈閵忕姴鍞ㄩ梺闈浤涢崘锝呮倕濠碉紕鍋戦崐褔鎳欒ぐ鎺戠柧闁绘顕х粻?
  void _onTextHeightFocusChange() {
    if (!textHeightFocusNode.hasFocus) {
      // 闂傚倷娴囬褏鎹㈤幇顔藉床闁归偊鍎靛☉妯锋闁靛繒濮烽ˇ顕€鎮楅獮鍨姎妞わ缚鍗冲畷鎰槹鎼达絾锛忓銈嗘尵閸嬬偤宕抽搹鍦＜濞撴艾娲ら弸銈囩磼鏉堛劌绗氱€垫澘瀚幆鏃堫敊閸忕⒈鍞查梻鍌欒兌绾爼寮插☉銏犲珘妞ゆ帒鍊婚惌娆忣熆閼搁潧濮堥柛銈嗗浮閺屾洟宕煎┑鍥ф濡炪値鍓欓ˇ闈涱潖閾忓湱纾兼俊顖氭惈椤骸顪冮妶鍐ㄧ仼闁挎洏鍎茬粚杈ㄧ節閸ヨ埖鏅ｉ梺闈涚箚閳ь剚鏋奸崑?
      _focusNode.requestFocus();
    }
  }

  // 闂傚倸鍊风粈渚€骞栭锕€纾圭紒瀣紩濞差亝鏅濋柍褜鍓熼弫鍐閵堝棗浜遍梺鍓插亞閸犳挾绮旈崼鏇熲拺閻熸瑥瀚崝銈夋煕閻旈浠㈡い鏇秮閹煎綊顢曢敍鍕暰婵犲痉鏉库偓鎰板磻閹剧繝绻嗘い鎰剁悼濞插鈧娲樼换鍌烆敇閸忕厧绶為悗锝庝簴閸嬫捇鎮滈懞銉у幗闂佺粯鏌ㄩ幉锛勬閼碱剛纾界€广儱瀚粣鏃堟煛鐏炲墽娲寸€殿喕绮欐俊姝岊槻闁愁亞鎳撻—鍐Χ韫囨艾鎮呴梺鍝勬噽婵炩偓妤?
  void _onTextContentFocusChange() {
    if (!textContentFocusNode.hasFocus) {
      // 闂傚倷娴囬褏鎹㈤幇顔藉床闁归偊鍎靛☉妯锋闁靛繒濮烽ˇ顕€鎮楅獮鍨姎妞わ缚鍗冲畷鎰槹鎼达絾锛忓銈嗘尵閸嬬偤宕抽搹鍦＜濞撴艾娲ら弸銈囩磼鏉堛劌绗氱€垫澘瀚幆鏃堫敊閸忕⒈鍞查梻鍌欒兌绾爼寮插☉銏犲珘妞ゆ帒鍊婚惌娆忣熆閼搁潧濮堥柛銈嗗浮閺屾洟宕煎┑鍥ф濡炪値鍓欓ˇ闈涱潖閾忓湱纾兼俊顖氭惈椤骸顪冮妶鍐ㄧ仼闁挎洏鍎茬粚杈ㄧ節閸ヨ埖鏅ｉ梺闈涚箚閳ь剚鏋奸崑?
      _focusNode.requestFocus();
    }
  }

  // 闂傚倸鍊风粈渚€骞栭锔藉亱闁告劦鍠栫壕濠氭煙閻愵剙澧柣鏂挎閺屾盯顢曢姀鈽嗘濠电偠顕滅粻鎴ｎ暰闂佸湱澧楀妯肩不瑜版帒绾ч柛顐ｇ箓閳锋棃鏌ｉ敐鍛紞缂佽鲸甯楅敍鎰攽閸℃鐫勯柣搴ゎ潐濞叉﹢銆冩繝鍐х箚闁绘垼濮ら弲婊呯磽娴ｈ偂鎴﹀汲閻樼粯鈷掑ù锝堟鐢盯鎮介锝勭凹濞ｅ洤锕畷鍫曨敆閳ь剛澹曟繝姘叆婵犻潧妫Σ鎼佹煟椤撶噥娈曞ǎ鍥э躬椤㈡稑顫濋鐔峰壍婵＄偑鍊栧▔锕傚礃閸撗冩暩闂佽崵濮撮幖顐﹀箹椤愶富鏁傛い鎰堕檮閻?
  void _onMaxLenthFocusChange() {
    if (!maxLenthFocusNode.hasFocus) {
      // 闂傚倷娴囬褏鎹㈤幇顔藉床闁归偊鍎靛☉妯锋闁靛繒濮烽ˇ顕€鎮楅獮鍨姎妞わ缚鍗冲畷鎰槹鎼达絾锛忓銈嗘尵閸嬬偤宕抽搹鍦＜濞撴艾娲ら弸銈囩磼鏉堛劌绗氱€垫澘瀚幆鏃堫敊閸忕⒈鍞查梻鍌欒兌绾爼寮插☉銏犲珘妞ゆ帒鍊婚惌娆忣熆閼搁潧濮堥柛銈嗗浮閺屾洟宕煎┑鍥ф濡炪値鍓欓ˇ闈涱潖閾忓湱纾兼俊顖氭惈椤骸顪冮妶鍐ㄧ仼闁挎洏鍎茬粚杈ㄧ節閸ヨ埖鏅ｉ梺闈涚箚閳ь剚鏋奸崑?
      _focusNode.requestFocus();
    }
  }

  // 闂傚倸鍊风粈渚€骞栭锕€纾归柣鐔煎亰閻斿棙鎱ㄥ璇蹭壕閻犱警鍨堕弻娑㈠箛闂堟稒鐏嶉梺鍝勬媼閸撴岸骞堥妸銉建闁糕剝銇炵花鐣岀磽娴ｅ搫小缂侇喗鐟╅獮鍐ㄎ旈埀顒勫煡婢跺ň鏋嶆い鎾楀倻鏁栫紓浣戒含閸嬬喖鍩€椤掑﹦绉甸柛鐘崇墱缁牓宕奸埗鈺佷壕妤犵偛鐏濋崝姘箾鐏炲倸鈧鎮疯濮婄粯鎷呯粵瀣異闂佺绻戠粙鎾跺垝閸喓鐟归柍褜鍓欓悾鐑藉传閸曨厽娈曢梺鍛婃处閸嬪棝顢欓幒妤佲拺闂傚牊绋撴晶鏇熴亜閿斿灝宓嗙€殿噮鍋勯～婊堝焵椤掑嫬钃?
  void _saveState() {
    // 婵犵數濮烽弫鎼佸磿閹寸姷绀婇柍褜鍓欓—鍐级閹寸偞鍠愰梺閫炲苯澧柤瑙勫劤閿曘垽鏌嗗鍛唵闂佽崵鍠愭竟瀣绩娴犲鐓曢柍鈺佸暟閹冲懎顫㈤崶顒佲拻濞达絽鎲￠崯鐐烘煙缁嬫寧鎲哥紒顔芥楠炴﹢顢欓悡搴′憾闂備浇顫夊畷姗€宕洪弽顓ㄧ稏闁哄洢鍨洪悡鐔镐繆椤栨繍鍤欑紒鎻掝煼閺岋綀绠涢弮鍌涘櫚闂?
    final currentState = elements.map((e) => e.copy()).toList();

    undoStack.add(currentState);
    if (undoStack.length > maxUndoSteps) {
      undoStack.removeAt(0);
    }
    if (redoStack.isNotEmpty) {
      redoStack.clear();
    }
  }

  // 闂傚倸鍊风粈渚€骞栭锕€纾归柣鐔煎亰閻斿棙鎱ㄥ璇蹭壕閻犱警鍨堕弻娑㈠箛闂堟稒鐏嶉梺鍝勬媼閸撴岸骞堥妸銉建闁糕剝顨呯粻娲煟鎼达絾鏆╅柡浣筋嚙椤繘鎮滃Ο璇插妳闂佽鍎抽崢鏍ㄧ珶閺囥垺鈷掑ù锝囧劋閸も偓闂佽绻戠换鍕垝閺傝法鏆﹂柛銉㈡櫇椤?
  void _undo() {
    if (undoStack.isNotEmpty) {
      final previousState = undoStack.removeLast();
      redoStack.add(elements.map((e) => e.copy()).toList());
      setState(() {
        elements = previousState;
      });
    }
  }

  // 闂傚倸鍊风粈渚€骞栭锕€纾归柣鐔煎亰閻斿棙鎱ㄥ璇蹭壕閻犱警鍨堕弻娑㈠箛闂堟稒鐏嶉梺鍝勬媼閸撴岸骞堥妸銉庣喖骞愭惔锝冣偓鎰攽閻愬弶鍣烽柛銊ょ矙瀵鈽夊锝呬壕闁挎繂楠告禍鐐淬亜閿濆棛鍙€闁哄瞼鍠愮缓浠嬪川婵犲啯娈搁梻?
  void _redo() {
    if (redoStack.isNotEmpty) {
      final nextState = redoStack.removeLast();
      undoStack.add(elements.map((e) => e.copy()).toList());
      setState(() {
        elements = nextState;
      });
    }
  }

  //闂傚倸鍊搁崐鐑芥倿閿曚降浜归柛鎰典簽閻捇鏌ｉ姀銏╃劸闁藉啰鍠庨埞鎴︽偐閸欏鎮欑紓浣插亾濠㈣埖鍔栭悡鐔镐繆椤栨粌甯堕柛鏂款儑缁辨帗鎷呭畡鏉跨ギ闂佸搫澶囬崜婵嗩嚗閸曨偀妲堟慨妯诲敾缁辩敻姊绘担铏瑰笡闁绘顨堥崚鎺楀箻閹颁礁娈ㄥ銈嗗姧闂勫嫰宕戠€ｎ喗鐓曟い鎰剁悼缁犳﹢鏌?
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
      // 濠电姷鏁搁崑娑㈩敋椤撶喐鍙忛悗鐢电《閸嬫挸鈽夐幒鎾寸彋閻庢鍠楅幃鍌氱暦濮椻偓閸╋繝宕橀悙顒傘偒闂傚倷绀侀幖顐︽偋閸涱垰绶ゅ┑鐘宠壘閸屻劍銇勯幒鎴濐仾闁稿缍侀弻娑㈠Ψ椤旂粯鍠氶梺鎼炲€栭悷褔骞夐幖浣哥骇闁圭楠哥粣娑㈡⒑闁偛鑻晶顖滅磼鐎ｎ偄娴柕鍡楀暣瀹曞ジ濡烽鑺ユ珗濠电偠鎻徊钘夛耿闁秴鐓?
      String contents = await file.readAsString();
      // 闂傚倷娴囬褏鎹㈤幇顔藉床闁归偊鍎靛☉妯滄棃宕ㄩ闂存闁荤喐绮岀换鎺楀礆閹烘鏁囬柕蹇婂墲濞呭棝姊洪崗鐓庡闁搞劎鍘х叅妞ゆ帒瀚悡鐔兼煟閺傛寧鎲搁柟铏礈缁辨帡骞撻幒鎾充淮闂佽鍠撻崕閬嶁€﹂妸鈺佺妞ゆ挻绋掗悘鍐磽閸屾瑨顔夐柛鎾寸箞楠炴鎮剁€涖劑姊婚崒娆愮グ婵℃ぜ鍔戦幊妤呮嚋閸偅鐝峰┑掳鍊愰崑鎾绘煟?
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
      // 婵犵數濮烽弫鎼佸磻閻愬搫绠伴柟闂寸缁犵娀鏌熼悧鍫熺凡闁绘挻锕㈤弻鈥愁吋鎼粹€崇缂備胶濮寸壕顓㈠箟閸濄儰娌悷娆欑稻閻庡姊洪棃娑㈢崪缂佽鲸娲熼崺鐐差吋婢跺鍘撻梺瀹犳〃缁€渚€寮抽弴鐘电＜?
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
        // 闂傚倷娴囧畷鍨叏瀹曞洦顐介柕鍫濇处椤洟鏌￠崶銉ョ仾闁稿鏅涢埞鎴︽偐瀹曞浂鏆￠梺缁樺笩椤曆団€︾捄銊﹀磯濞撴凹鍨伴崜鏉款渻閵堝懐绠為柛搴″级缁岃鲸绻濋崑鑺ユ閸┾偓妞ゆ巻鍋撻摶鐐翠繆閵堝懏鍣归柤绋跨秺閺岀喓绱掗姀鐘崇亶闂佺楠哥粔褰掑蓟濞戙垹鍗抽柕濞垮劙缁ㄥ鏌ｉ姀鈺佺仭妞ゃ劌鐗忓Σ?
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
        // 濠电姷顣槐鏇㈠磻閹达箑纾归柡鍥ュ灪閸嬪鈹戦崒婊庣劸缁炬儳娼￠幃妤呮偨閻㈢偣鈧﹪鏌涚€ｎ偅宕屾俊顐㈠暙閳藉顫濆В娆嶅妿缁?
        if ((newPosition.dy).round() == otherElement.position.dy.round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(0, newPosition.dy),
            end: Offset(canvasSize.width, newPosition.dy),
          ));
        }
        // 闂傚倷绀佸﹢閬嶅储瑜旈幃娲Ω閵夊啯妞介幃銏ゆ偂鎼达綇绱甸梺璇叉捣閺佸摜娑甸崼鏇炵；闁瑰墽绮ˉ鍫熺箾閹寸偞鐨戝Δ鏃傜磽?
        if ((newPosition.dy + movingElement.size.height).round() ==
            (otherElement.position.dy + otherElement.size.height).round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(0, newPosition.dy + movingElement.size.height),
            end: Offset(
                canvasSize.width, newPosition.dy + movingElement.size.height),
          ));
        }
        // 闂備浇顕ф鍝ョ礊婵犲偆鐒介柤濮愬€楃壕鑺ユ叏濡寧纭鹃柣銈夌畺閺屾盯骞橀懠棰濆敼闂佺顑嗛幑鍥涢崘銊㈡婵ɑ鐦烽妸褏纾?
        if ((newPosition.dx).round() == otherElement.position.dx.round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(newPosition.dx, 0),
            end: Offset(newPosition.dx, canvasSize.height),
          ));
        }
        // 闂傚倸鍊风粈渚€骞夐敓鐘冲仭闁靛鏅涢崒銊╂煛瀹ュ骸骞栭柣銈夌畺閺屾盯骞橀懠棰濆敼闂佺顑嗛幑鍥涢崘銊㈡婵ɑ鐦烽妸褏纾?
        if ((newPosition.dx + movingElement.size.width).round() ==
            (otherElement.position.dx + otherElement.size.width).round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(newPosition.dx + movingElement.size.width, 0),
            end: Offset(
                newPosition.dx + movingElement.size.width, canvasSize.height),
          ));
        }
        // 缂傚倸鍊搁崐椋庣矆娓氣偓钘濋柟鍓佺摂閺佸鎲告惔銊ョ疄闁靛ň鏅涢悡娑㈡煕濞戝崬骞樻い鏂匡躬閹嘲顭ㄩ崘顓烆伃闂佸疇顕ч柊锝嗘叏閳ь剟鏌曢崼婵囶棞闁告搩鍙冨娲川婵犲啫顦╅梺绋款儏鐎氼喚鍒掗崼鐔稿闁硅偐鍋愰崑鎾诲箳閹搭厽鍍甸梺閫炲苯澧寸€规洖宕埢搴ㄥ箣濠靛宕曟繝鐢靛Х椤ｄ粙宕滃┑瀣ㄢ偓鍐川椤撳洦鐩顕€宕掑鍛殽闁诲骸鍘滈崑鎾绘煕閺囥劌浜炴い蟻鍥ㄢ拺闁告繂瀚晶銏ゆ煛娴ｈ鍊愰柡灞熷洤纾奸柣鎰嚟閸樼敻鏌ｉ悩顔煎妞わ富鍨跺畷鎰亹閹烘繃鏅濇繛瀵稿Т椤戝棝鎮￠悢鍏肩厪濠电偛鐏濋崝姘亜韫囧﹥娅呴柍钘夘樀瀵剛鎹勯妸褜鍞圭紓鍌欑劍椤ㄥ牓宕伴弴鈶哄洭宕滄担铏癸紲闂佸搫鍟崐鎼佸几鎼搭潿浜滈柍杞伴檷閸嬨垻鈧娲栧畷顒冪亙婵犵數濮撮崐褰掝敊韫囨挴鏀?
        if ((newPosition.dx + movingElement.size.width).round() ==
            otherElement.position.dx.round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(newPosition.dx + movingElement.size.width, 0),
            end: Offset(
                newPosition.dx + movingElement.size.width, canvasSize.height),
          ));
        }
        // 缂傚倸鍊搁崐椋庣矆娓氣偓钘濋柟鍓佺摂閺佸鎲告惔銊ョ疄闁靛ň鏅涢悡娑㈡煕濞戝崬骞樻い鏂匡躬閹嘲顭ㄩ崘顓烆伃闂佸疇顕ч柊锝嗘叏閳ь剟鏌曢崼婵囶棞闁告搩鍙冨娲川婵犲啫顦╅梺绋款儏閸婅崵鍒掓繝姘兼晬婵ǜ鍎崑鎾诲箳閹搭厽鍍甸梺閫炲苯澧寸€规洖宕埢搴ㄥ箣濠靛宕曟繝鐢靛Х椤ｄ粙宕滃┑瀣ㄢ偓鍐川椤撳洦鐩顕€宕掑鍛殽闁诲骸鍘滈崑鎾绘煕閺囥劌浜炴い蟻鍥ㄢ拺闁告繂瀚晶銏ゆ煛娴ｈ鍊愰柡灞熷洤纾奸柣鎰嚟閸樼敻鏌ｉ悩顔煎妞わ富鍨跺畷鎰亹閹烘繃鏅濇繛瀵稿Т椤戝棝鎮￠悢鍏肩厪濠电偛鐏濋崝姘亜韫囧﹥娅囬柟鍙夋倐瀵爼骞愭惔鈩冩畼缂傚倷鐒﹂〃鍫ュ窗閺団懞鍥礈娴ｈ櫣锛滈梺鍝勫暙閸婃悂寮告惔顫簻闁宠桨闄嶉崑銏⑩偓瑙勬礀瀹曨剝鐏冩繝鐢靛Т閸婂綊顢欒箛鎾斀?
        if ((newPosition.dx).round() ==
            (otherElement.position.dx + otherElement.size.width).round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(newPosition.dx, 0),
            end: Offset(newPosition.dx, canvasSize.height),
          ));
        }
        // 缂傚倸鍊搁崐椋庣矆娓氣偓钘濋柟鍓佺摂閺佸鎲告惔銊ョ疄闁靛ň鏅涢悡娑㈡煕濞戝崬骞樻い鏂匡躬閹嘲顭ㄩ崘顓烆伃闂佸疇顕ч柊锝嗘叏閳ь剟鏌曢崼婵囶棞闁告搩鍙冨娲川婵犲啫顦╂繛瀛樼矌閸嬨倝骞冮悜钘夌疀闁哄娉曟鍥⒑閸撴彃浜剧紓宥呮椤洭骞囬婊€绨婚梺闈涚箳婵參宕曢幇顔剧＜閻庯綆浜跺Σ褰掓煙椤栨稒顥堥柛銊╃畺瀹曟﹢鎳犻鍌滃€冲┑鐘垫暩閸嬫盯顢氶鐔稿弿闁汇垹鎲￠崑瀣繆閵堝懎鏆為柡鍡樼矒閺屻倝宕妷锔芥瘎濡炪倐鏅濋崗姗€寮诲☉銏犵闁肩⒈鍓欐俊浠嬫⒑娴兼瑧鍒扮€规洦鍓熼崺銉﹀緞閹邦剛顔掗梺褰掝暒缁€渚€宕滈悽鐢电＝濞达綀顫夐埛鎺楁煕閻樻煡鍙勯柕鍡楁噺缁虹晫绮欓崹顔库偓鍨攽鎺抽崐鏇㈡晝閵堝應鏋旈柛娑橈攻閸?
        if ((newPosition.dy).round() ==
            (otherElement.position.dy + otherElement.size.height).round()) {
          alignmentLines.add(AlignmentLine(
            start: Offset(0, newPosition.dy),
            end: Offset(canvasSize.width, newPosition.dy),
          ));
        }
        // 缂傚倸鍊搁崐椋庣矆娓氣偓钘濋柟鍓佺摂閺佸鎲告惔銊ョ疄闁靛ň鏅涢悡娑㈡煕濞戝崬骞樻い鏂匡躬閹嘲顭ㄩ崘顓烆伃闂佸疇顕ч柊锝嗘叏閳ь剟鏌曢崼婵囶棞闁告搩鍙冨娲川婵犲啫顦╂繛瀛樼矌閸嬨倝骞冮悜钘夌閻犲洩灏欐鍥⒑閸撴彃浜剧紓宥呮椤洭骞囬婊€绨婚梺闈涚箳婵參宕曢幇顔剧＜閻庯綆浜跺Σ褰掓煙椤栨稒顥堥柛銊╃畺瀹曟﹢鎳犻鍌滃€冲┑鐘垫暩閸嬫盯顢氶鐔稿弿闁汇垹鎲￠崑瀣繆閵堝懎鏆為柡鍡樼矒閺屻倝宕妷锔芥瘎濡炪倐鏅濋崗姗€寮诲☉銏犵闁肩⒈鍓欐俊浠嬫⒑娴兼瑧鍒扮€规洦鍓熼崺銉﹀緞閹邦剛顔掔紓浣圭☉缂嶅﹦娆㈢€靛摜纾藉ù锝堫潐閳锋帡鏌涢悩鏌ュ弰闁靛棗鎳忕缓鐣岀矙閸喛鈧灝鈹戞幊閸婃洟鏁冮妶鍛灁闁告稑锕ラ崣?
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

        // 闂傚倷绀侀幖顐λ囬鐐村亱闁糕剝顨愰懓鍧楁⒑椤掆偓缁夋挳鎮块悙顑句簻闁硅埇鍔嶉崵鎺撶箾閹存瑥鐏╅柣鎺戠仛閵囧嫰骞掗幋婵愪患闂?
        newX = newX.clamp(0, canvasSize.width - movingElement.size.width);
        newY = newY.clamp(0, canvasSize.height - movingElement.size.height);

        Offset newPosition = Offset(newX, newY);

        _calculateAlignmentLines(movingElement, newPosition);

        movingElement.position = newPosition;
        // 闂傚倸鍊风粈渚€骞栭鈷氭椽濡舵径瀣槐闂侀潧艌閺呮盯鎷戦悢灏佹斀闁绘ê寮堕幖鎰磼閻樿尙锛嶉柟鎻掓憸娴狅妇鎲撮敐鍡欌偓濠氭⒑闂堟盯鐛滅紒杈ㄦ礋閸╃偛顓兼径瀣帗闂佸疇妗ㄧ粈渚€寮抽弴鐘电＜?
        _positionXController.text = newPosition.dx.toInt().toString();
        _positionYController.text = newPosition.dy.toInt().toString();
        _elementWidthController.text = movingElement.size.width.toString();
        _elementHeightController.text = movingElement.size.height.toString();
      });
    } else {
      setState(() {
        alignmentLines.clear();
        // 闂傚倸鍊烽懗鍫曗€﹂崼銏″床闁规壆澧楅崑瀣攽閻樺弶纭藉鑸靛姇瀹告繈鏌℃径瀣伇闁硅姤娲熷娲濞戣鲸顎嗙紓浣哄У閸ㄥ潡濡撮崒鐐茶摕闁靛濡囬崢鎼佹⒑閸撴彃浜濈紒璇茬Т鍗辩憸鐗堝笚閸嬨劍銇勯弽銊х畵闁绘挻鍔楃槐鎺楀磼濞戞ɑ璇為梺纭呮珪缁挸鐣疯ぐ鎺濇晝鐎广儱绻掗悾鐢告煛鐏炲墽鈽夋い顐ｇ箞瀹曟粏顦寸紒鎰殘缁辨挻鎷呮禒瀣懙婵犮垻鎳撳Λ婵嬬嵁閺嶃劊鍋呴柛鎰╁妼缁愭稑顪冮妶鍡樺暗闁稿鍋ら幆渚€寮崼鐔哄幐婵犮垼娉涢敃锔芥櫠閺囩喓绡€闁逞屽墴閺屽棗顓奸崨顖涚叄?
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
        // 闂傚倸鍊搁崐椋庢閿熺姴纾婚柛鏇ㄥ瀬閸ヮ剙绠ユい鏃傛嚀娴滅偓鎱ㄥΟ绋垮姎濠碉紕鏅埀顒€鐏氬妯尖偓姘煎墴閿濈偛鈹戠€ｅ灚鏅濋梺鎸庢磵閸嬫挻绻涢崼鐔虹疄婵﹨娅ｅ☉鐢稿川椤栨粌濮洪梻浣侯焾閺堫剚绗熷Δ鍛；闁靛ň鏅滈埛鎴︽煕濠靛棗顏╅柡鍡愬灲閺屾盯鍩￠崒婊冣拡缂備緡鍠掗弲鐘诲箠閿熺姴围闁搞儮鏅濋崢浼存⒑閸濆嫷妲洪柛瀣ㄥ€濋妴鍌炴晜閻愵剙搴婇梺绯曞墲缁嬫帡鎮?
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
      // 婵犵數濮烽弫鎼佸磻閻愬搫绠伴柟闂寸缁犵娀鏌熼悧鍫熺凡闁绘挻锕㈤弻鈥愁吋鎼粹€崇缂備胶濮寸壕顓㈠箟閸濄儰娌悷娆欑稻閻庡姊洪棃娑㈢崪缂佽鲸娲熼崺鐐差吋婢跺鍘撻梺瀹犳〃缁€渚€寮抽弴鐘电＜?
      _positionXController.clear();
      _positionYController.clear();
      _elementWidthController.clear();
      _elementHeightController.clear();
    });
  }

  void deleteSelectedElements() {
    _saveState(); // 濠电姷鏁搁崕鎴犲緤閽樺娲晜閻愵剙搴婇梺绋跨灱閸嬬偤宕戦妶澶嬬厪濠电偛鐏濇俊绋棵瑰鍐Ш闁哄瞼鍠栭獮鍡氼槻闁哄棜椴搁妵鍕Χ閸涱喖娈楅梺鍝勭焿缁插€熺亽闂佸壊鐓堥崰姘跺储椤愶附鈷?
    setState(() {
      elements.removeWhere((element) => selectedElements.contains(element));
      selectedElements.clear();
      isMovingSelected = false;
      alignmentLines.clear();
      _textController.clear();
      _textWidthController.clear();
      _textHeightController.clear();
      // 婵犵數濮烽弫鎼佸磻閻愬搫绠伴柟闂寸缁犵娀鏌熼悧鍫熺凡闁绘挻锕㈤弻鈥愁吋鎼粹€崇缂備胶濮寸壕顓㈠箟閸濄儰娌悷娆欑稻閻庡姊洪棃娑㈢崪缂佽鲸娲熼崺鐐差吋婢跺鍘撻梺瀹犳〃缁€渚€寮抽弴鐘电＜?
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
      // 婵犵數濮烽弫鎼佸磻閻愬搫绠伴柟闂寸缁犵娀鏌熼悧鍫熺凡闁绘挻锕㈤弻鈥愁吋鎼粹€崇缂備胶濮寸壕顓㈠箟閸濄儰娌悷娆欑稻閻庡姊洪棃娑㈢崪缂佽鲸娲熼崺鐐差吋婢跺鍘撻梺瀹犳〃缁€渚€寮抽弴鐘电＜?
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
      // 闂傚倸鍊风粈渚€骞栭鈷氭椽濡舵径瀣槐闂侀潧艌閺呮盯鎷戦悢灏佹斀闁绘ê寮堕幖鎰磼閻樿尙锛嶉柟鎻掓憸娴狅妇鎲撮敐鍡欌偓濠氭⒑闂堟盯鐛滅紒杈ㄦ礋閸╃偛顓兼径瀣帗闂佸疇妗ㄧ粈渚€寮抽弴鐘电＜?
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
      // 闂傚倷绀侀幖顐λ囬鐐村亱濠电姴娲ょ粻浼存煙闂傚顦﹂柣顓燁殜閺屾盯鍩勯崘鍓у姺闂佸磭绮濠氬焵椤掆偓缁犲秹宕曢柆宥呯疇闊洦绋戠壕褰掓煏閸繃顥犵紒鐘冲劤椤法鎹勬笟顖氬壉缂備礁鐭佸▔鏇犳閹烘挻缍囬柕濞у懐鏆紓鍌欐祰妞村摜鏁幒妤€鐓濋幖娣€楅悿鈧梺瑙勫劤椤曨厼危濮椻偓濮婄粯鎷呴崨濠呯缂備緡鍣崹璺虹暦濠靛柈鏃堝川椤?
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content:
              Text('Please enter valid numbers for canvas width and height.'),
        ),
      );
      // 濠电姷鏁搁崕鎴犲緤閽樺娲晜閻愵剙搴婇梺鍛婂姦娴滄牠宕戦幘璇插瀭妞ゆ劧缍嗗Λ鍐倵鐟欏嫭纾搁柛銊ょ矙楠炲啴濮€閵堝懎绐涙繝鐢靛Т濞诧箓顢撻弽顓熲拻濞达絽婀卞﹢浠嬫煕閺傝法鐏遍柍褜鍓氶崙褰掑闯閿濆拋鍤曟い鎰剁畱缁€鍫㈡喐鎼淬劌姹叉繝濠傜墛閻撴洟鏌熼幍铏珔濠碉紕顭堥湁婵犲﹥鍔楃粔顕€鏌?
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
        // 闂傚倷绀侀幖顐λ囬鐐村亱闁糕剝顨愰懓鍧楁⒑椤掆偓缁夋挳鎮块悙顑句簻闁硅埇鍔嶉崵鎺撶箾閹存瑥鐏╅柣鎺戠仛閵囧嫰骞掗幋婵愪患闂?
        double newX = selectedElements.first.position.dx
            .clamp(0, canvasSize.width - width);
        double newY = selectedElements.first.position.dy
            .clamp(0, canvasSize.height - height);
        selectedElements.first.position = Offset(newX, newY);
        // 闂傚倸鍊风粈渚€骞栭鈷氭椽濡舵径瀣槐闂侀潧艌閺呮盯鎷戦悢灏佹斀闁绘ê寮堕幖鎰磼閻樿尙锛嶉柟鎻掓憸娴狅妇鎲撮敐鍡欌偓濠氭⒑闂堟盯鐛滅紒杈ㄦ礋閸╃偛顓兼径瀣帗闂佸疇妗ㄧ粈渚€寮抽弴鐘电＜?
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
        // 濠电姷鏁搁崑娑㈡偤閵娾晛鍚归幖娣妼绾惧綊鏌″畵顔兼噺濞堥箖姊洪懖鈹炬嫛闁稿繑锕㈠畷鎴﹀箻缂佹鍔靛┑鐐村灦濮樸劑鎮￠幘缁樷拺缂備焦顭囩粻銉╂煕閻樻剚娈樼紒顔碱儔楠炴帒螖閳ь剙鏁梻浣哥枃椤宕曢搹顐ゎ洸濡わ絽鍟悡鏇㈡倶閻愰潧浜鹃柣銊﹀灴閹鎮烽柇锔解枅闂佸搫鐭夌换婵嗙暦濮椻偓閳ワ箓骞嬪┑鍡楊棐濠?
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

  //濠电姷鏁搁崑鐐哄垂閸洖绠伴柟闂寸贰閺佸嫰鏌涢埄鍏狀亪宕归弮鍌滅＜闁炽儵妾查埡鐢de
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
                1; // 1濠电姷鏁搁崑鐐哄垂閸洖绠板Δ锝呭暙绾惧潡鏌曢崼婵囧闁绘帟濮ら妵鍕冀椤愵澀娌梺绋垮閿氶棁澶愭煥濠靛棙鍣洪柟鎻掓啞閹便劌螣缁嬪灝顬堥梺瀹犳椤︾敻鐛▎鎾崇闁靛鍎抽鎰版⒑鐠囨煡顎楅柣蹇斿哺閺佸啴濮€閻樺灚娈鹃梺闈涱槴閺呪晠寮崘顔界叆婵炴垶锚椤忊晠鏌￠崨顏呮珚婵﹥妞藉畷顐﹀礋閸偒鈧棛绱撴担浠嬪摵婵炶尙鍠栭獮鍐Ψ閵夘喚鍙嗛梺鍓插亞閸犳劕鈻?濠电姷鏁搁崑鐐哄垂閸洖绠板Δ锝呭暙绾惧潡鏌曢崼婵囧闁绘帟濮ら妵鍕冀椤愵澀娌梺绋垮閿氶棁澶愭煥濠靛棙鍣洪柟鎻掓啞閹便劌螣缁嬪灝顬堥梺瀹犳椤︾敻鐛▎鎾崇闁靛鍎抽鎴︽⒒娴ｅ湱婀介柛搴ㄤ憾楠炲﹤螣娓氼垰娈ㄩ梺鍓茬厛閸嬪嫮娆㈤悙鐑樺€甸柨婵嗩槹濞懷冣攽閳ユ彃宓嗘慨濠冩そ瀹曨偊宕熼崹顐偓鍡欑磽娴ｄ粙鍝烘繛鑼枛楠?
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

  //濠电姷鏁搁崑鐐哄垂閸洖绠伴柟闂寸贰閺佸嫰鏌涢埄鍏狀亪宕归弮鍌滅＜闁靛鍎茬欢娑㈡⒒娴ｇ瓔鍤欐繛瀵稿厴閵嗕焦绻濋崑鑺ョ洴瀹曠喖顢樺☉妯瑰?
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

  //濠电姷鏁搁崑鐐哄垂閸洖绠伴柟闂寸贰閺佸嫰鏌涢埄鍏狀亪宕归弮鍌滅＜闁炽儵妾查埡鐢de
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
      // 闂傚倷娴囬褏鎹㈤幇顔藉床闁归偊鍎靛☉妯锋瀻闁规儳鐤囬幗鏇熺節閻㈤潧孝婵炲眰鍊楃划鍫ュ磼閻愬鍘遍梺瑙勬緲閸氣偓缂併劏濮ら妵鍕晝娓氣偓閸濊櫣绱掔紒妯兼创闁轰焦鍔欏畷濂割敃閵忊槅鍞叉繝鐢靛У椤旀牠宕板璺虹；闁靛牆鎳愰弳锔芥叏濡寧纭剧紒鐙欏洦鐓曟い顓熷灥閺嬨倕霉閻樺啿鍝洪柡宀嬬秮閹瑧鈧數纭跺Λ銊╂⒑閸涘﹥鐓ユい鎴濐樀楠?
      elements.add(newElement);
    });
  }

  void showContextMenu(DraggableElement element, Offset position) {
    copyElement(element);
  }

  /// 闂傚倸鍊风粈渚€骞夐敍鍕殰婵°倕鍟伴惌娆撴煙鐎电啸缁惧彞绮欓弻鐔煎箲閹伴潧娈紓浣插亾闁糕剝眉缁诲棝鏌曢崼婵囧櫣妞ゅ繈鍎甸弻?, 婵犵數濮甸鏍闯椤栨粌绶ら柣锝呮湰瀹曟煡鎮楅敐搴℃灍闁绘挸鍊圭换婵囩節閸屾粌顣虹紓浣插亾闁稿瞼鍋為悡鏇㈡煙閺夊灝鎮佺紒銊ㄥГ閵囧嫰鏁冮崒娆愬枤濠殿喖锕ュ浠嬨€佸▎鎾冲瀭妞ゆ枮鍕鞍濞ｅ洤锕獮鎾诲箳閹捐櫕娈樼紓鍌欑椤戝懘藝閻㈢鏄ラ柍褜鍓氶妵鍕箳瀹ュ牆鍘￠梺?ExpansionTile 缂傚倸鍊搁崐鎼佸磹妞嬪海鐭嗗ù锝堛€€閸嬫挸顫濋梻瀵哥泿闂?
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

  /// 闂傚倸鍊烽悞锕傛儑瑜版帒鍨傚┑鐘宠壘缁愭鏌熼悧鍫熺凡闁?ExpansionTile 濠电姷鏁搁崑鐐哄垂閸洖绠伴柟闂寸贰閺佸嫰鏌涢妷鎴斿亾闁?ListView 闂傚倸鍊烽悞锕傛儑瑜版帒绀夌€光偓閳ь剟鍩€椤掍礁鍤柛鎾寸懇閹箖鎮滈懞銉ヤ簻闂佸憡绺块崕顕€寮搁弽褜娓婚柕鍫濇噽缁犵増淇婇锝囨创闁诡垰鐬奸埀顒婄秵閳?
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

    /// 濠电姷鏁搁崑鐘诲箵椤忓棛绀婇柍褜鍓氱换娑欏緞鐎ｎ偆顦伴悗娈垮櫘閸嬪﹥淇婇崼鏇炵倞闁靛鍎宠ぐ鎾⒒娓氣偓濞佳囨晬韫囨稑宸濇い鏍ㄧ矊鐢帗绻濋悽闈涗粶妞ゆ洦鍘介幈銊╁箚瑜夐弸鏍ㄧ箾閹寸偛娈犲ù婊冪秺閺屾稑鈻庤箛锝喰ㄥ銈傛櫇閸忔﹢寮婚弴鐔风窞闁割偅绺鹃崑鎾诲即閵忕姷鍘洪棅顐㈡处缁嬫帡宕愰悽鐢垫／妞ゆ挾鍋為崳鐑樸亜閵夈儺妯€闁诡喗顨堥幉鎾礋椤愮喐鐏嗘俊銈囧Х閸嬬偤鏁冮姀銈囧祦閻庯綆鍠楅崐鐑芥煙缂佹ê閱?
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
                  width:
                      150, // 闂傚倸鍊烽悞锕傚箖閸洖纾块梺顒€绉寸粻瑙勩亜閹板爼妾柛瀣ф櫊閺屾盯骞樺璇蹭壕闂佺顑嗛幐鎯р槈閻㈢宸濇い鏇炴噺椤ュ姊?
                  height:
                      36, // 闂傚倸鍊烽悞锕傚箖閸洖纾块梺顒€绉寸粻瑙勩亜閹板爼妾柛瀣ф櫊閺岋綁骞囬棃娑樷拻濠电偛鐗婇〃鍡樼┍婵犲浂鏁嶆慨姗嗗幗閸庢挸顪?

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

  //闂備浇顕ф鍝ョ礊婵犲偆鐒介柤濮愬€楃壕鑺ユ叏濡寧纭鹃柣銈夌畺閺屾盯顢曢敐鍡欘槬缂備讲鍋撻柛鈩兠肩换鍡涙煏閸繃鍣规い蹇嬪劦閺屽秷顧侀柛鎾寸懇瀹曨垶骞橀鑹版憰閻庡厜鍋撻柍褜鍓氱粋鎺楁晝閸屾氨鐣鹃悷婊冪箰铻ｉ柛鈩冪⊕閳锋帒霉閿濆牊顏犻柟钘夊€块弻娑㈡偐鐎圭姴顥濋梺宕囩帛閹瑰洭鐛€ｎ喗鏅滈柦妯侯槴閸嬫捇鎮滈懞銉у幗闂佺粯鏌ㄩ幉锛勬閸欏鍙忛柨婵嗘嫅瀹搞儵妫佹径瀣瘈濠电姴鍊搁弸銈夋煕鎼粹€愁劉缂?
//闂傚倸鍊风欢姘焽閼姐倖瀚婚柣鏃傚帶缁€澶愭倵閿濆骸鏋熼柛銈呯墦閺岀喐娼忔ィ鍐╊€嶉梺鎶芥敱鐢繝寮婚悢铏圭＜闁靛繒濮甸悘鍫ユ⒑閸涘﹥鐓熼柛搴ｆ暬瀵鈽夐姀鐘殿唺闂佺懓顕崕鎰涢敓鐘斥拺缂佸妫楅崰娑㈢叕椤掑倵鍋撶憴鍕缂佽鐗撻獮鍐煛閸涱厾顔岄梺鍦劋濞诧箓宕ぐ鎺撯拻濞达絽鎽滅粔娲煛閳ь剟鏌嗗鍡椾罕濠德板€曢崯鐘诲磻閹炬剚娼╂い鎺嶇娴犳潙螖閻橀潧浠﹂悽顖滃枛钘濋弶鍫涘妿缁犻箖鏌涢埄鍐ㄥ闁诲繑鐓￠弻鈩冩媴閸濄儛銈吤归悪鍛暤鐎规洘鍔欓幃銏☆槹鎼绰ゎ唹婵犵數濮烽弫鎼佸磿閹寸姷绀婇柍褜鍓氶妵鍕即閸℃顏柛娆忕箻閺岋綁骞囬浣瑰創缂備讲鍋撻柛鈩冪⊕閻撶喓鎲歌箛娴板骞庨妶娉傿uttonList闂傚倸鍊峰ù鍥ь浖閵娾晜鍊块柨鏃傛櫕閻濆爼鏌涢埄鍐噧闁搞劍绻勯埀顒€绠嶉崕閬嵥囨导瀛樺亗闁稿本澹曢崑鎾诲礂婢跺﹣澹曢梺璇插嚱缂嶅棝宕滃☉鈶哄洭顢氶埀顒€顫忓ú顏勪紶闁告洦鍋€閸嬫捇宕稿Δ鈧悞鍨亜閹哄秷鍏岄柕鍡樺浮閺屽秶鎲撮崟顐ｈ癁闂佸搫鐭夌换婵嗙暦閻旂⒈鏁冮柍鍨涙櫆鐎垫牠姊?
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
    //闂傚倸鍊烽懗鍫曞箠閹剧粯鍊舵慨妯挎硾缁犳壆绱掔€ｎ厽纭堕柡鍡愬€濋弻娑㈠箛閻㈤潧甯ュ┑鐐烘？閸楁娊寮婚妸銉㈡斀闁糕剝锚濞呫倝姊虹粙鍖″伐妞ゎ厾鍏樺濠氭偄鐞涒€充壕婵炴垶鐟悞钘夘熆瑜庢繛濠囧蓟瀹ュ牜妾ㄩ梺鍛婃尰閻熲晠鐛繝鍐╁劅闁宠棄妫楀▓銊︾箾鐎电孝妞ゆ垵鎳愰幉?
    if (_selectedPrintDirection == 'Forward') {
      csvData.add(['ROTATE', '0']);
    } else {
      csvData.add(['ROTATE', '0']);
    }
    int width = int.parse(_widthController.text) * 8;
    int height = int.parse(_heightController.text) * 8;

    //闂傚倸鍊烽懗鍫曞箠閹剧粯鍊舵慨妯挎硾缁犳壆绱掔€ｎ厽纭堕柡鍡愬€濋弻娑㈠箛閸忓摜鏁栧┑鈽嗗亽閸ㄥ磭妲愰幒鏂哄亾閿濆骸骞楃痪顓炵埣閺岋綁骞囬濠備紣濡炪値鍘煎鈥崇暦婵傜骞㈡俊銈傚亾闁哄棛鍠愰幈?
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
      //缂傚倸鍊搁崐鐑芥嚄閸洖纾婚柟鎯х亪閸嬫挾绮☉妯烘灓闁绘帟濮ら妵鍕冀閵娧€妲堢紓浣稿閸嬨倝寮诲☉銏犖ㄦい鏍ㄧ矌閺嗙娀姊?
      // else if (targetElements[i].type.name == 'line') {
      //   if (targetElements[i].lineWidth! <= targetElements[i].x2Pos!) {
      //     csvData.add([
      //       'L',
      //       targetElements[i].position.dx.toInt(),
      //       targetElements[i].position.dy.toInt(),
      //       (targetElements[i].x2Pos! + targetElements[i].position.dx.toInt()).toInt(),
      //       targetElements[i].position.dy.toInt(),
      //       targetElements[i].lineWidth!.toInt(),
      //       0, //缂傚倸鍊搁崐鐑芥倿閿曗偓閻ｅ嘲螣鐞涒剝鐏冮梺鍝勬川婵敻宕戦弽銊ｄ簻闁规澘澧庨悾閬嶆煕?
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
      //       0, //缂傚倸鍊搁崐鐑芥倿閿曗偓閻ｅ嘲螣鐞涒剝鐏冮梺鍝勬川婵敻宕戦弽銊ｄ簻闁规澘澧庨悾閬嶆煕?
      //       targetElements[i].index,
      //     ]);
      //   }
      // }
//x1,y1,x2,y2,lineWidth,lineType,index
      else if (targetElements[i].type.name == 'line') {
        int lineWidth = targetElements[i].size.width.toInt();
        int lineHeight = targetElements[i].size.height.toInt();
        //婵犵數濮烽。钘壩ｉ崨鏉戝瀭闁稿繗鍋愰々鏌ユ煟閹邦剚鎯堥柛?
        if (lineHeight <= lineWidth) {
          csvData.add([
            'L',
            targetElements[i].position.dx.toInt(),
            targetElements[i].position.dy.toInt(),
            (lineWidth + targetElements[i].position.dx.toInt()).toInt(),
            targetElements[i].position.dy.toInt(),
            lineHeight,
            0, //缂傚倸鍊搁崐鐑芥倿閿曗偓閻ｅ嘲螣鐞涒剝鐏冮梺鍝勬川婵敻宕戦弽銊ｄ簻闁规澘澧庨悾閬嶆煕?
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
            0, //缂傚倸鍊搁崐鐑芥倿閿曗偓閻ｅ嘲螣鐞涒剝鐏冮梺鍝勬川婵敻宕戦弽銊ｄ簻闁规澘澧庨悾閬嶆煕?
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

//婵犵數濮甸鏍窗濡ゅ啰绱﹂柛褎顨呯壕褰掓煛閸ワ絾鍤嶉柛銉墮閻撴盯鏌涢幇銊︽珔闁哄鍊垮娲箰鎼达絿鐣靛┑鈽嗗亝閻╊垶宕洪埀顒併亜閹达絾纭堕柣顓熺懅閳ь剚顔栭崰鏍偉婵傜鏋佺€广儱顦粈瀣亜閹捐泛浠уù鐙€鍨跺缁樻媴閸涘﹤鏆堥梺鍛婃⒐濞茬喖鐛繝鍐╁劅妞ゎ厽鍨堕弲鈺呮⒑鐟欏嫬顥嬪褎顨婂鏌ヮ敆閸曨剙鈧爼鏌ｉ幇鐗堟锭濞存粓绠栭弻鐔兼倻閹存帗鍠氶梺鍝勬湰閻╊垶寮崘顔肩＜闁靛牆妫欓鑲╃磽閸屾瑧鍔嶆い銊ユ嚇钘濋柟娈垮枤閻瑥顭块懜闈涘闁绘帒鐏氶妵鍕箳閹存績鍋撻悽绋跨；闁规崘鍩栭崰鍡涙煕閺囥劌寮鹃柡鍡忊偓鏂ユ斀闁绘﹩鍋勬禍鐐箾鏉堝墽鍒板鐟帮工椤洦瀵肩€涙鍘梺鍓插亝缁诲啴藟閻愮儤鐓㈤柛灞惧嚬閸庢棃鏌″畝瀣М妞ゃ垺鐟╅幊锟犲Χ閸涱収鐎撮梻鍌欒兌缁垶銆冮崼銉⑩偓锕傚醇閵夘喗鏅梺鎸庣箓閻楀繘鎮块埀顒勬煟鎼搭垱鈧儵宕樿椤ユ岸姊绘担渚劸闁活剙銈稿畷鎴濃槈閵忕姴鍋嶉梺鍦檸閸犳鎮″▎鎴犵＜閻庯綆鍋掗崕銉︿繆閹绘帞绉洪柡宀嬬秮婵＄兘濡烽敃鈧▓妤呮倵濞堝灝鏋涢柣蹇旇壘椤曘儵宕熼娑樹壕闁挎繂顦板☉褍鈹戦垾鎻掑祮婵﹥妞藉畷顐﹀礋閸偒鈧棛绱撴担浠嬪摵婵炶尙鍠栭獮鍐Ψ閵夘喚鍙嗛梺鍓插亝缁诲倿宕妸鈺傗拺缂備焦蓱鐏忣厽绻涢幘顕呮婵炴垹鏁婚崺鈧い鎺嶈兌缁♀偓闂侀潧楠忕徊鍓ф兜妤ｅ啯鍊垫慨妯煎帶濞呭秵顨?
  String _barcodeContent1(List<dynamic> con) {
    final barcodedata =
        StringBuffer(); // 濠电姷鏁搁崑鐘诲箵椤忓棛绀婇柍褜鍓氱换娑欏緞鐎ｎ偆顦伴悗?StringBuffer 闂傚倸鍊风粈渚€骞栭位鍥敇閵忕姷锛熼梺鍝勮閸庢煡宕愰崹顐犱簻闁哄秲鍔岄崵顒勬煕閵堝懐澧﹂柡灞剧☉閳规垿宕卞Δ濠佺磻闂備礁婀遍弲顐﹀窗閹捐埖顫曢柟鐑樺殾閺冨倵鍋撻敐搴″缂佹劖顨婇弻?
    if (con.isEmpty) {
      return barcodedata.toString();
    }
    for (final item in con) {
      if (barcodedata.isNotEmpty) {
        barcodedata.write(
            ','); // 闂傚倸鍊风欢姘焽閼姐倖瀚婚柣鏃傚帶缁€澶愭倶閻愰潧浜炬繛鍛█閺岋絽螣閾忕櫢绱為梺宕囩帛濡啴寮诲鍫闂佸憡鎸诲銊у垝濞嗘劕绶為柟鏉跨仛閺呮粓姊洪崜鎻掍簼缂佸鐗撳畷鎴﹀箻閹颁礁鎮戞繝銏ｆ硾椤戝懘宕滈纰辨富闁靛牆妫欓ˉ鍡欌偓瑙勬礈閺佸銆佸Ο濂芥椽顢旈崨顖氬箞婵犳鍠楅敃鈺呭礈閻旂厧鐭楅柛鏇ㄥ厸缁诲棛绱撴担闈涚仼婵炲懎绉堕埀顒冾潐濞叉鎹㈤崼銉ョ畺闁冲搫鎳忛崐濠氭煃鏉炵増顦峰瑙勬礀閳规垶骞婇柛濠冨姍瀹曟垿骞橀懜闈涙瀾闂佸搫顦扮€笛囧磻閵壯€鍋撶憴鍕鐎光偓缁嬭法鏆﹂柛妤冨亹濡插牊绻涢崱妯忣亪骞冮埡鍐＝?
      }
      if (item is Map) {
        if (item['type'] == 'TEXT') {
          barcodedata.write('TEXT,${item['content']}');
        } else {
          var varalignment = 1;
          if (item['alignment'] == 'Center') {
            varalignment = 2;
          } else if (item['alignment'] == 'Right') {
            // 缂傚倸鍊搁崐鎼佸磹閻戣姤鍤勯柛顐ｆ礀缁愭鈧箍鍎卞ú銊╁础濮樿埖鍊甸柣銏犳啞濞呮粓鏌ｉ幒鎴含闁哄本鐩崺鍕礂閳哄倸鐏ユい鏇秮楠炴绱掑Ο鐓庡箞婵犵數鍋為崹鍫曟偡閵夆晜鍊跺┑鐘叉处閻撶娀鏌涢…鎴濅簻闁诲繑鎸抽弻鐔碱敍濮橆剚娈婚悗瑙勬礈閸犳牠銆佸Δ鍛劦妞ゆ帒瀚粈鍫澝归悡搴ｆ憼闁绘挻娲熼弻鐔兼焽閿旇法鏁栫紓浣风窔閺€閬嶅Φ閸曨垼鏁冮柕蹇婃櫅閸撹京绱?'Left'
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
            // 缂傚倸鍊搁崐鎼佸磹閻戣姤鍤勯柛顐ｆ礀缁愭鈧箍鍎卞ú銊╁础濮樿埖鍊甸柣銏犳啞濞呮粓鏌ｉ幒鎴含闁哄本鐩崺鍕礂閳哄倸鐏ユい鏇秮楠炴绱掑Ο鐓庡箞婵犵數鍋為崹鍫曟偡閵夆晜鍊跺┑鐘叉处閻撶娀鏌涢…鎴濅簻闁诲繑鎸抽弻鐔碱敍濮橆剚娈婚悗瑙勬礈閸犳牠銆佸Δ鍛劦妞ゆ帒瀚粈鍫澝归悡搴ｆ憼闁绘挻娲熼弻鐔兼焽閿旇法鏁栫紓浣风窔閺€閬嶅Φ閸曨垼鏁冮柕蹇婃櫅閸撹京绱?'Left'
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

        // final file = await _localFilepath; ///////闂傚倸鍊风粈渚€宕ョ€ｎ喖纾块柟鎯版鎼村﹪鏌ら懝鎵牚濞存粌缍婇弻娑㈠Ψ椤旂厧顫╅梺缁樺姇閿曨亪寮诲☉妯锋斀闁糕剝顨忔导鈧梻浣告惈濡瑥顭垮鈧﹢渚€姊洪幐搴ｇ畵闁硅櫕鍔橀崐鎾⒒?
        final file = File(p.join(path));
        // 闂傚倷娴囬褏鎹㈤幇顔藉床闁归偊鍎靛☉妯滄棃宕ㄩ闂存闁荤喐绮岀换鎺楀礆閹烘鏁囬柕蹇婂墲濞呭棝姊洪崗鐓庡闁搞劎鍘х叅妞ゆ帒瀚埛鎴︽煕濞戞﹫宸ュ┑顔肩墦閺岋綁鎮㈤弶鎴濆Е閻庤娲╃紞浣哥暦閸楃偐妲堟俊顖涙た濡喖姊绘担瑙勫仩闁稿骸顭峰浠嬪礋椤栵絾鏅濋梺鑺ッˇ顐⑽?
        // print(formatjson);
        file.writeAsStringSync(formatjson);

        // await loadData();   婵犵數濮甸鏍窗濡ゅ啰绱﹂柛褎顨呯壕褰掓煛閸ワ絾鍤嶉柛銉墮閻撴稑銆掑顒佹悙闁哄懐濞€濮婃椽鎳栭埞鐐珱闂佸憡鎸婚惄顖炲箚閳ь剟鏌涘☉妯兼憼闁绘挻娲熼弻鐔兼焽閿曗偓楠炴﹢鏌熼崘鎻掓殻闁哄本娲熷畷濂告晲閸涘懏鎸剧槐鎺楀磼濮樻瘷褏鈧娲栧畷顒冪亙婵犵數濮撮崯顖炲箖濞嗗繆鏀介柣鎰煐瑜把呯磼閸欏鍔ら悡銈嗕繆椤栨繃顏犻柡鍡檮閵囧嫰骞掗幋婵愪患闂佺粯鍔曢敃顏堝蓟閿濆绠涙い鎺戝€归幉濂告⒒閸屾艾顏╃紒澶婄秺瀵鍩勯崘銊х獮濠电偞鍨跺銊╂晬閻斿吋鈷戠紓浣诡焽婢ь剛绱掗鑲┬ょ紒顔藉哺閺屽棗顓奸崨顖氬Ф闂備礁鎲￠崜顒勫川椤栵絾袣
      }
    } catch (e) {
      setState(() {
        showTipInfo('$e Save fail', context);
      });
    }
  }

  //闂傚倸鍊风粈渚€骞夐敍鍕殰闁搞儺鍓欑壕褰掓煛瀹ュ骸骞栭柦鍐枛閺屾盯濡烽鐓庮潻濠碘槅鍋呴敃銏ゅ蓟濞戙垹唯妞ゆ牜鍋為宥咁渻閵堝棗濮冪紒顔界懇瀵鏁撻悩鑼槹闂傚倸鐗婄粙鎾寸閳哄懏鈷戦悹鍥ｂ偓宕囦户缂備浇鍩栭懝楣冾敋閿濆棗顕遍柟纰卞幗閺咁剙鈹戦鏂や緵闁告﹢绠栭妴鍛搭敇閵忊檧鎷虹紓鍌欑劍閿曗晛鈻撻弮鈧换娑氭嫚瑜忛幃鑲╃磼椤曞懎寮€殿喕绮欓、姗€鎮欓幓鎺撳皨濠碉紕鍋戦崐鏍偋濡ゅ啫鏋堢€广儱顦壕鍨攽閻樺弶澶勯柣鎾跺枑閵囧嫯绠涢幘鎼闂佸搫顑呴柊锝夊蓟閿濆围闁告侗鍙庢导鈧梻渚€鈧偛鑻晶顖滅磼鐎ｎ偄娴柡浣割儏閳规垿鎮╅顫?
  bool isImagePath(String path) {
    // 闂傚倷娴囬褍顫濋敃鍌︾稏濠㈣埖鍔栭崕妤併亜閺傚灝鈷斿☉鎾崇Ч閺岋綁寮崒姘闂佸搫妫欑划宥夊箞閵娿儮鏀介柛鈩冪懅閸旂鈹戦悙闈涘付闁活厼鍊垮濠氭晲婢跺á鈺呮煏婢跺牆鍔村ù鐘靛帶閳规垿鎮欓懠顒佹喖闂佹寧娲忛崹浠嬬嵁閸愵収妯勯悗瑙勬礀閻栧吋淇婇幖浣规櫆闂佹鍨版禍鐐亜閺冣偓缁佺銇愰幒鎾充汗闂佸憡绻傜€氼噣宕㈤锝囩瘈闁冲皝鍋撻柛鈩冾焽閵嗗﹥绻涚€电顎撶紒鐘虫尭椤曪綁骞橀钘夆偓鐑芥煛婢跺鐏嶉柛?
    const List<String> imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp'
    ];

    // 闂傚倸鍊风粈渚€骞夐敍鍕殰婵°倕鍟伴惌娆撴煙鐎电啸缁惧彞绮欓弻鐔煎箲閹伴潧娈┑鈽嗗亝閿曘垽寮诲☉銏犖ㄦい鏍仦椤庡秴顪冮妶鍡楀缂侇喗鐟╅獮鍐ㄎ旈崨顔间缓濠电偛鐗婄€笛囧极椤栫偞鈷?
    File file = File(path);

    // 婵犵數濮烽。钘壩ｉ崨鏉戠；闁逞屽墴閺屾稓鈧綆鍋呭畷宀勬煛瀹€瀣？濞寸媴濡囬幏鐘诲箵閹烘埈娼ラ梻鍌欑閹碱偊顢栭崨鏉戠柈妞ゆ牗绮庨惌澶愭煙閻戞﹩娈曢柛銈咁儔閺屾盯鈥﹂幋婵冨亾閿濆鏅濋柛灞剧〒閸樺崬鈹戦鐭亝鏅舵禒瀣仼闂侇剙绉甸悡鐔煎箳閹惰棄绀夐柟瀛樼箘閺?
    if (!file.existsSync()) {
      return false;
    }

    // 闂傚倸鍊风粈渚€宕ョ€ｎ喖纾块柟鎯版鎼村﹪鏌ら懝鎵牚濞存粌缍婇弻娑㈠Ψ椤旂厧顫╁┑鈽嗗亝閿曘垽寮诲☉銏犖ㄦい鏍仦椤庡秴顪冮妶鍡楀缂侇喗鐟╁濠氭晲婢跺á鈺呮煏婢跺牆鍔村ù鐘靛亾缁绘繈鍩涢埀顒勫幢濡鈧﹥绻涚€电顎撶紒鐘虫尭椤曪綁骞橀钘夆偓鐑芥煛婢跺鐏嶉柛?
    String extension = path.substring(path.lastIndexOf('.')).toLowerCase();

    // 闂傚倸鍊风粈渚€骞夐敍鍕殰闁搞儺鍓欑壕褰掓煛瀹ュ骸骞栭柦鍐枛閺屾盯濡烽鐓庮潻缂備胶濮伴崕鐢稿蓟瀹ュ棙濮滈柟宄拌嫰閸樷€斥攽閻愭彃鎮戞俊顐㈠暣瀵鈽夊鍡樺兊濡炪倖甯掗崐鎰版晲閸℃洜绠氶梺鍛婄懃椤︿即宕愰幇顔瑰亾鐟欏嫭纾搁柛搴ｆ暬瀵偊宕橀鑲╁姦濡炪倖宸婚崑鎾绘煥閺囨ê鐏叉い銏℃瀹曠厧鈹戦崼婵冨亾閻愮儤鈷戦柛娑橈攻鐎垫瑩鏌涢幇顔间壕婵絽鐗撳缁樻媴閸涘﹨纭€濡炪倧绲肩划娆忣嚕閹绘巻妲堥柕蹇娾偓鍐插闁诲骸绠嶉崕閬嵥囬婊勫枂闁挎棃鏁崑鎾荤嵁閸喖濮庨梺鐟板暱闁帮綁骞冨Ο琛℃瀻闁圭偓娼欐禒鈺佲攽閻愭潙鐏﹂柣妤佹礃娣囧﹤煤椤忓懐鍘?
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
    //闂傚倸鍊风粈渚€骞夐敍鍕殰闁搞儺鍓欑壕褰掓煛瀹ュ骸骞栭柦鍐枛閺屾盯濡烽鐓庮潻缂備胶瀚忛崶銊у弳濠电偞鍨堕敋妞ゅ浚鍋婇弻娑㈠Ω閿曗偓閳绘洟鏌＄仦璇插闁宠棄顦灒濞撴凹鍨遍鍕磽閸屾瑩妾烽柛鏂款樀瀵彃鈹戦崼鐕佹綗闂佸湱鍎ら弻锟犲磻閹剧粯顥堟繛鎴炵懄閸犳劙姊洪幖鐐插濠电偛锕璇测槈閵忊剝娅嗛梺鍛婄箓鐎氼剟鈥栭崱娆戠＝濞达綀顕栧▓鏃€銇勯敃鍌涙锭闁?

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(children: [
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
                              width:
                                  150, // 闂傚倷娴囧畷鍨叏瀹曞洨鐭嗗ù锝堫潐濞呯姴霉閻樺樊鍎愰柛瀣典邯閺屾盯鍩勯崘顏佹闂佺粯鍔曢敃顏堝蓟濞戞ǚ鏀介柛鈩冾殢娴尖偓闂備礁鎼Λ鏃堝础閹惰棄绠栨俊銈呭暞閸忔粓鏌涘☉鍗炴珮婵☆偄瀚伴弻?
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
                              width:
                                  150, // 闂傚倷娴囧畷鍨叏瀹曞洨鐭嗗ù锝堫潐濞呯姴霉閻樺樊鍎愰柛瀣典邯閺屾盯鍩勯崘顏佹闂佺粯鍔曢敃顏堝蓟濞戞ǚ鏀介柛鈩冾殢娴尖偓闂備礁鎼Λ鏃堝础閹惰棄绠栨俊銈呭暞閸忔粓鏌涘☉鍗炴珮婵☆偄瀚伴弻?
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
                                width:
                                    80, // 闂傚倷娴囧畷鍨叏瀹曞洨鐭嗗ù锝堫潐濞呯姴霉閻樺樊鍎愰柛瀣典邯閺屾盯鍩勯崘顏佹闂佺粯鍔曢敃顏堝蓟濞戞ǚ鏀介柛鈩冾殢娴尖偓闂備礁鎼Λ鏃堝础閹惰棄绠栨俊銈呭暞閸忔粓鏌涘☉鍗炴珮婵☆偄瀚伴弻?
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
                                width:
                                    80, // 闂傚倷娴囧畷鍨叏瀹曞洨鐭嗗ù锝堫潐濞呯姴霉閻樺樊鍎愰柛瀣典邯閺屾盯鍩勯崘顏佹闂佺粯鍔曢敃顏堝蓟濞戞ǚ鏀介柛鈩冾殢娴尖偓闂備礁鎼Λ鏃堝础閹惰棄绠栨俊銈呭暞閸忔粓鏌涘☉鍗炴珮婵☆偄瀚伴弻?
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
            const SizedBox(width: 25),
            Container(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
                              context, 40, localizedStrings.gOpenJson,
                              () async {
                            String filePath = '';
                            try {
                              String executablePath =
                                  Platform.resolvedExecutable;
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
                                                .bodySmall), ////婵犵數濮甸鏍窗濡ゅ啰绱﹂柛褎顨呯壕褰掓煛閸ワ絾鍤嶉柛銉墮閻撴盯鏌涘☉鍗炴珮婵﹤娼″娲焻閻愯尪瀚板褌鍗抽弻鐔兼嚑椤掆偓椤ｅジ鏌熷畡鐗堝殗闁诡垰瀚伴獮鎺楀箻閺夋垹锛撻柣搴ゎ潐濞叉牠鎮ユ總绋跨畺婵炲棗娴氶崯鍛亜閺傚灝寤?
                                        duration: const Duration(seconds: 1),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .error));
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
                              _saveFormatToJson(jsonFilePath);
                            }
                            ////婵犵數濮烽弫鎼佸磿閹寸姷绀婇柍褜鍓氶妵鍕即閸℃顏柛娆忕箻閺岋綁骞囬鍛瘜闂佺顑嗛幑鍥х暦閻戠瓔鏁囬柣鎰閸╂稒淇?
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
                        .primary, // 闂傚倷绀侀幖顐λ囬鐐村亱闁规澘搴滅紞鏍ь熆閼搁潧濮傞柍褜鍏涢懗鍫曞焵椤掑﹦绉甸柛瀣尵濡叉劙鏁愰崱娆戠槇婵犵數濮撮崐褰捤夊鍕╀簻闁靛鍎崇粻濠氭煛鐏炶濡奸柍钘夘槸铻ｉ柤娴嬫櫅婵壆绱撻崒娆掑厡缂侇噮鍨堕幃褔鎮╃拠鑼舵憰閻庡厜鍋撻柍褜鍓氱粋鎺楁晝閸屾稑浜楅柟鐓庣摠钃遍柣搴°偢濮婄粯鎷呯憴鍕╀户濠电偟鍘у鈥崇暦濠靛牃鍋撻敐搴″幋闁稿鎹囧Λ鍐ㄢ槈濞嗘劖瀚抽梻浣瑰缁嬫帡宕濋弴锛勪航闂備胶顭堢换妤呭磻閹版澘姹查柣妯虹－缁犻箖鏌熺€电浠﹂悘蹇曞娣囧﹪宕ｆ径濠勭懖缂?
                    width:
                        1, // 闂傚倷绀侀幖顐λ囬鐐村亱闁规澘搴滅紞鏍ь熆閼搁潧濮傞柍褜鍏涢懗鍫曞焵椤掑﹦绉甸柛蹇旓耿瀹曟垿骞橀懜闈涘幑闂佸憡渚楅崳顔嘉涢崟顖涚厽閹艰揪缍嗛弨鐗堢箾閸涱喗绀堢紒?2 闂傚倸鍊烽懗鍫曗€﹂崼銏㈢煋閻庨潧鎲″畷鏌ユ煙閻戞ɑ鈷掗柣?
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        4), // 闂傚倷绀侀幖顐λ囬鐐村亱闁规澘搴滅紞鏍ь熆閼搁潧濮傞柍褜鍏涢懗鍫曞焵椤掑﹦绉甸柛鐘崇墵楠炴垿宕奸弴鐔哄幈闂佹枼鏅涢崯顐﹀吹椤掍胶绠剧痪顓㈩棑缁♀偓闂佸搫鏈粙鎴ｇ亙闂侀€炲苯澧撮柡浣稿暣婵″爼宕堕…鎴濅缓闂備胶绮崝鏇㈩敋椤撱垹鐓?8 闂傚倸鍊烽懗鍫曗€﹂崼銏㈢煋閻庨潧鎲″畷鏌ユ煙閻戞ɑ鈷掗柣?
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
        // 闂傚倷娴囧畷鍨叏瀹曞洨鐭嗗ù锝堫潐濞呯姴霉閻樺樊鍎愰柛瀣典邯閺屾盯鍩勯崗鈺傚灩缁辩偤宕堕浣镐画濠电偛妫楃换鎰邦敂閹绢喗鐓涢柍褜鍓熼弻鍡楊吋閸℃瑥骞愰柣搴＄畭閸庨亶骞婃惔鈭ワ綁鎳￠妶鍥╋紲?
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .primary, // 闂傚倷绀侀幖顐λ囬鐐村亱闁规澘搴滅紞鏍ь熆閼搁潧濮傞柍褜鍏涢懗鍫曞焵椤掑﹦绉甸柛瀣尵濡叉劙鏁愰崱娆戠槇婵犵數濮撮崐褰捤夊鍕╀簻闁靛鍎崇粻浼存煃閽樺妯€妤犵偞锕㈤幊锟犲Χ閸モ晝宕堕梻鍌欒兌椤㈠﹥鎱ㄩ妶澶婂瀭闁秆勵殔缁?
            width:
                1, // 闂傚倷绀侀幖顐λ囬鐐村亱闁规澘搴滅紞鏍ь熆閼搁潧濮傞柍褜鍏涢懗鍫曞焵椤掑﹦绉甸柛蹇旓耿瀹曟垿骞橀懜闈涘幑闂佸憡渚楅崳顔嘉涢崟顖涚厽閹艰揪缍嗛弨鐗堢箾閸涱喗绀堢紒?2 闂傚倸鍊烽懗鍫曗€﹂崼銏㈢煋閻庨潧鎲″畷鏌ユ煙閻戞ɑ鈷掗柣?
          ),
          borderRadius: BorderRadius.circular(
              4), // 闂傚倷绀侀幖顐λ囬鐐村亱闁规澘搴滅紞鏍ь熆閼搁潧濮傞柍褜鍏涢懗鍫曞焵椤掑﹦绉甸柛鐘崇墵楠炴垿宕奸弴鐔哄幈闂佹枼鏅涢崯顐﹀吹椤掍胶绠剧痪顓㈩棑缁♀偓闂佸搫鏈粙鎴ｇ亙闂侀€炲苯澧撮柡浣稿暣婵″爼宕堕…鎴濅缓闂備胶绮崝鏇㈩敋椤撱垹鐓?8 闂傚倸鍊烽懗鍫曗€﹂崼銏㈢煋閻庨潧鎲″畷鏌ユ煙閻戞ɑ鈷掗柣?
        ),
        padding: EdgeInsets.all(
            10), // 闂傚倷娴囧畷鍨叏瀹曞洨鐭嗗ù锝堫潐濞呯姴霉閻樺樊鍎愰柛瀣典邯閺屾盯鍩勯崘顏佹缂備讲鍋撻柛鎰靛枟閻撴洘绻涢幋鐐垫噧妞ゃ儱顑夐弻锝呪攽閸℃瑥鐓熼梺璇″枛缂嶅﹪骞冨鍏剧喖鎳栭埡鍐╂闂?10 闂傚倸鍊烽懗鍫曗€﹂崼銏㈢煋閻庨潧鎲″畷鏌ユ煙閻戞ɑ鈷掗柣?
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

//闂傚倸鍊烽悞锕傛儑瑜版帒鍨傚┑鍌氬閺佸鎲歌箛鏇炲灊闁冲搫鎳忛崐濠氭煠閹帒鍔ら柛鏃€鎮傚娲濞戣京鍔搁梺绋块叄娴滃爼骞?
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
                              fit: BoxFit.fill,
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
                          //婵犳鍠楀畷鍧楀川椤撳缍侀弻锝夊冀閻㈠灚鍋х紓渚囧枟濮婂骞忛悩璇茬闁硅鍋呴〃濠囧蓟濞戙垹绠荤€规洖娉﹂敍鍕＜缂備焦蓱閻ㄦ垿鏌嶈閸撴氨绮欓幒妞烩偓锕傚炊閵婏箑寮块梺褰掓？缁€浣虹不?
                          _saveState();
                        },
                        onScaleUpdate: (details) {
                          if (details.scale == 1) {
                            if (selectedElements.contains(element)) {
                              moveSelectedElements(details.focalPointDelta);
                            } else {
                              setState(() {
                                element.position += details.focalPointDelta;
                                // 缂傚倸鍊风粈渚€藝閹剁瓔鏁嬬憸搴ㄥ箞閵娾晛鐓涢柛娑卞幘閻嫰姊洪崜鎻掍簼婵炴彃绉瑰畷鎴﹀箻閺夋垹绐炴繝銏ｆ硾妤犳悂鐛埀顒勬⒑閼姐倕孝婵炲眰鍨藉畷鏇㈡焼瀹ュ懎鍋嶉梺瑙勫礃閸╂牠锝?
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
                          //婵犳鍠楀畷鍧楀川椤撳缍侀弻锝夊冀閻㈠灚鍋х紓渚囧枟濮婂骞忛悩璇茬闁硅鍋呴〃濠囧蓟濞戞﹩娼╂い鎺戝€搁崵顒傜磽娴ｈ櫣甯涙慨妯稿姂閸┾偓妞ゆ帊鑳堕埊鏇熴亜椤撶偞澶勯柟渚垮姂楠炴牗鎷呴崫銉ф殸?
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
                                          int? oldScaleId =
                                              myDefScaleInfo.defScaleId;
                                          int newScaleId = scale.scaleId;
                                          if (oldScaleId != newScaleId) {
                                            if (oldScaleId != null &&
                                                oldScaleId > 0) {
                                              if (_needSendRegWeight(
                                                  oldScaleId)) {
                                                PublicFunctions.stopWeight(
                                                    oldScaleId);
                                              }
                                            }
                                            myDefScaleInfo.defScaleId =
                                                newScaleId;
                                            DefScaleInfo.getDefScaleInfo(
                                                newScaleId);
                                            if (_needSendRegWeight(
                                                newScaleId)) {
                                              PublicFunctions.getWeight(
                                                  newScaleId);
                                            }
                                            setState(() {});
                                          }
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
                                        //闂備浇顕ф鍝ョ礊婵犲偆鐒介柤濮愬€楃壕鑺ユ叏濡寧纭鹃柣銈夌畺閺屾盯顢曢敐鍡欘槬闂佹椿鍘介〃鍡涘箞閵娿儺娓婚悹鍥紦婢规洟姊绘笟鈧鑽ゅ緤閹屾富濞寸姴顑呴拑鐔兼煕椤愮姴鍔氶幆鐔兼⒑闂堟侗妲堕柛搴㈠▕閸┾偓?
                                        Container(
                                          width: leftBtnWidth - 80,
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

                                        //濠电姷鏁搁崑鐐哄垂閸洖绠归柍鍝勬噹閻鏌涢幇鈺佸婵炴垯鍨归柨銈嗕繆閵堝嫮顦﹀ù鐘虫そ閺岋綁鎮╅崣澶屸敍闁诲繐绻戦悷鈺呫€侀弮鍫濈妞ゆ棁袙閹峰搫顪冮妶鍡樼叆闁圭⒈鍋呮穱濠冪附閸涘﹦鍘?

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
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    controller:
                                                        horizontalScrollController,
                                                    child: Scrollbar(
                                                      controller:
                                                          verticalScrollController,
                                                      thumbVisibility: false,
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.vertical,
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
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 150,
                                                      height: 44,
                                                      child: showTextButton(
                                                          context,
                                                          44,
                                                          localizedStrings
                                                              .printPreview,
                                                          () {
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
                                                    const SizedBox(width: 15),
                                                    SizedBox(
                                                      width: 150,
                                                      height: 44,
                                                      child: showTextButton(
                                                          context,
                                                          44,
                                                          localizedStrings
                                                              .printSettings,
                                                          () {
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
                                              ),
                                            ],
                                          ),
                                        ),

                                        //闂傚倸鍊风粈渚€骞夐敓鐘冲仭闁靛鏅涢崒銊╂煛瀹ュ骸骞栭柣銈夌畺閺屾盯骞橀崣澶樻▊濠电偛鐭堟禍顏堝蓟閿濆绠涙い鏂垮帬婢舵劖鐓曢悗锝庡亝瀹曞嫭銇勯敃鈧紞濠囧蓟濞戞瑦鍎熼柕蹇娾偓鍐叉敪闁?
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
                                                // 濠电姷鏁告慨浼村垂閻撳簶鏋栨繛鎴炲焹閸嬫挸顫濋悡搴㈢彎濡ょ姷鍋涢崯顖滄崲濠靛纾奸柕鍫濇噺濞呭﹪姊绘担鐟邦嚋婵﹤顭烽幖瑙勬償閵娿儴鍩為梺鍦帛鐢晠鎮㈤崱娑欑厾缂佸娉曟禒娑㈡倶韫囥儳鐣甸柡灞稿墲缁楃喖宕惰缁秴螖閻橀潧浠﹂柛鏃€鐗曢銉╁礋椤掆偓缁剁偟鈧厜鍋撻柍褜鍓熼獮澶愵敊閻ｅ瞼顔曢柣搴㈢⊕椤洭鎯屾繝鍐︿簻闁瑰瓨绻傞鈺呮煃?

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
