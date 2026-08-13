import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:t_max/pages/sel_scales_page.dart';
import '../data/manager_scale_channel.dart';
import 'package:t_max/functions/methods.dart';
import '../data/download_prt_fmt.dart';
import '../data/language.dart';
import '../data/scalecmd_data.dart';
import '../widget/custom_button.dart';
import '../widget/page_head.dart';

class ProductDownloadPage extends StatefulWidget {
  const ProductDownloadPage({super.key});

  @override
  State<ProductDownloadPage> createState() => _ProductDownloadPageState();
}

class _ProductDownloadPageState extends State<ProductDownloadPage> {
  List<String> items = [];
  String filePath = '';
  String errorMessage = ''; //错误信息显示
  String? curruntPickFile = '';

  TextEditingController repsController = TextEditingController();
  TextEditingController pluAllCtl = TextEditingController();
  TextEditingController pluPartCtl = TextEditingController();

  late ScrollController _fileScrollerController;
  var currentPath = Directory.current.path;

  final bool _isShowDownload = true;

  @override
  void initState() {
    super.initState();
    _fileScrollerController = ScrollController();
    pluAllCtl.text = '';
  }

  String systemId = '';

  @override
  void dispose() {
    _fileScrollerController.dispose();

    repsController.dispose();
    pluAllCtl.dispose();
    pluPartCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: pageHeadDesign(
            context,
            localizedStrings.gTitlePluDownload,
            [myDefScaleInfo.defScaleId!],
            '',
          ),
        ),
        body: Container(
          color: Theme.of(context).colorScheme.surfaceTint,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildMainContent(),
            ],
          ),
        ));
  }

  Widget _buildMainContent() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: Text(
              '',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          _buildButtonRow(),
          Expanded(
            child: SingleChildScrollView(
              controller: _fileScrollerController,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 设置主轴对齐方式为居中
                    children: [
                      SizedBox(
                        child: Text(
                          '${localizedStrings.gPluNameLength}   30',
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 设置主轴对齐方式为居中
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          localizedStrings.gTipDownloadAllPlu,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 400,
                        // height: 40,
                        child: TextField(
                          controller: pluAllCtl,
                          readOnly: true,
                          maxLines: 2,
                          minLines: 1,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      CustomOutlinedButton(
                        btnWidth: 150,
                        btnHeight: 40,
                        icon: Icons.file_open_outlined,
                        text: localizedStrings.gBtnSelectPluFile,
                        onPressed: () async {
                          pluAllCtl.text = '';
                          pickFiles(pluAllCtl);
                        },
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      CustomOutlinedButton(
                        btnWidth: 100,
                        btnHeight: 40,
                        icon: Icons.cleaning_services,
                        text: localizedStrings.gBtnClear,
                        onPressed: () {
                          setState(() {
                            pluAllCtl.text = '';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // 设置主轴对齐方式为居中
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          localizedStrings.gTipUpdatePlu,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 400,
                        // height: 40,
                        child: TextField(
                          controller: pluPartCtl,
                          readOnly: true,
                          maxLines: 2,
                          minLines: 1,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      CustomOutlinedButton(
                        btnWidth: 150,
                        btnHeight: 40,
                        icon: Icons.file_open_outlined,
                        text: localizedStrings.gBtnSelectPluFile,
                        onPressed: () async {
                          pluPartCtl.text = '';
                          pickFiles(pluPartCtl);
                        },
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      CustomOutlinedButton(
                        btnWidth: 100,
                        btnHeight: 40,
                        icon: Icons.cleaning_services,
                        text: localizedStrings.gBtnClear,
                        onPressed: () {
                          setState(() {
                            pluPartCtl.text = '';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  !_isShowDownload
                      ? Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary),
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showSelScaleDialog(int funcNo, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return SelectScalesPage(
          funcNo: funcNo,
          sendMsgStr: msg,
        );
      },
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomElevatedButton(
          btnWidth: 150,
          btnHeight: 50,
          icon: Icons.file_copy,
          text: localizedStrings.gBtnGetPluTemplate,
          onPressed: () {
            downloadTemplate();
          },
        ),
        CustomElevatedButton(
          btnWidth: 150,
          btnHeight: 50,
          icon: Icons.download_rounded,
          text: localizedStrings.gBtnDownload,
          onPressed: _isShowDownload
              ? () {
                  _showConfirmationDialog(context);
                }
              : null,
        ),
      ],
    );
  }

  void _showFileSaveCfmDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.gTitleConfirm,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: SizedBox(
            width: 400,
            child: TextField(
              enabled: true,
              readOnly: true,
              maxLines: 2,
              controller: TextEditingController(text: filePath),
              style: const TextStyle(overflow: TextOverflow.ellipsis),
            ),
          ),
          actions: <Widget>[
            CustomElevatedButton(
              btnWidth: 120,
              btnHeight: 40,
              icon: Icons.check_circle,
              text: localizedStrings.gBtnConfirm,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(
            localizedStrings.gTitleConfirm,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: isOneModeDown()
              ? Text(localizedStrings.gConfirmFileTip)
              : Text(localizedStrings.gTipSelectOnePluFile),
          actions: <Widget>[
            Row(
              children: [
                isOneModeDown()
                    ? CustomElevatedButton(
                        btnWidth: 120,
                        btnHeight: 40,
                        icon: Icons.check_circle,
                        text: localizedStrings.gBtnConfirm,
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      )
                    : const SizedBox(),
                const SizedBox(
                  width: 10,
                ),
                CustomOutlinedButton(
                  btnWidth: 120,
                  btnHeight: 40,
                  icon: Icons.cancel,
                  text: localizedStrings.gBtnCancel,
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        // sendFormatToScale();
        String msg = getSendMsg();
        showSelScaleDialog(1, msg);
      }
    });
  }

  bool isOneModeDown() {
    bool res = false;
    if (pluAllCtl.text.isNotEmpty && pluPartCtl.text.isEmpty) {
      res = true;
    } else if (pluAllCtl.text.isEmpty && pluPartCtl.text.isNotEmpty) {
      res = true;
    }

    return res;
  }

  void sendFormatToScale() {
    if (pluAllCtl.text.isNotEmpty) {
      myScaleCmd.cmdMode = "down_plu_to_scale";
      sendFileToScale(pluAllCtl.text);
    } else if (pluPartCtl.text.isNotEmpty) {
      myScaleCmd.cmdMode = "insert_plu_to_scale";
      sendFileToScale(pluPartCtl.text);
    }
  }

  void sendFileToScale(String fmtPath) {
    myDownLoadPluFile.scaleModel = myDefScaleInfo.defScaleModel ?? '';
    myDownLoadPluFile.filePath = fmtPath;
    myDownLoadPluFile.nameMaxLen = 30;
    myScaleCmd.cmdData = json.encode(myDownLoadPluFile);
    PublicFunctions.sendMsg(myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
  }

  String getSendMsg() {
    String fmtPath = "";
    if (pluAllCtl.text.isNotEmpty) {
      myScaleCmd.cmdMode = "down_plu_to_scale";

      fmtPath = pluAllCtl.text;
    } else if (pluPartCtl.text.isNotEmpty) {
      myScaleCmd.cmdMode = "insert_plu_to_scale";
      fmtPath = pluPartCtl.text;
    }
    myDownLoadPluFile.scaleModel = myDefScaleInfo.defScaleModel ?? '';
    myDownLoadPluFile.filePath = fmtPath;
    myDownLoadPluFile.nameMaxLen = 30;
    myScaleCmd.cmdData = json.encode(myDownLoadPluFile);
    return jsonEncode(myScaleCmd);
  }

  void delPluListFromScale(List<String> pluList) {
    myScaleCmd.cmdMode = "del_plu_from_scale";
    myDelPlu.scaleModel = myDefScaleInfo.defScaleModel ?? '';
    myDelPlu.pluId = pluList;
    myScaleCmd.cmdData = json.encode(myDelPlu);
    PublicFunctions.sendMsg(myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
  }

  Future pickFiles(TextEditingController showFilePath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // initialDirectory: directory,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result != null) {
      setState(() {
        showFilePath.text = result.files.single.path!;
        filePath = showFilePath.text;
      });
    } else {
      setState(() {
        showFilePath.text = '';
        filePath = '';
      });
    }
  }

  Future<void> downloadTemplate() async {
    var directory = Directory.current.path;
    String? outputFile = (await FilePicker.platform.saveFile(
      initialDirectory: directory,
      dialogTitle: 'Output file:',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      fileName: 'product_template.xlsx',
    ));
    if (outputFile != null) {
      if (!outputFile.contains(".xlsx")) {
        outputFile = "$outputFile.xlsx";
      }
      File output = File(outputFile); // 将文件路径转换为File对象

      // 读取预置的模板文件
      final ByteData bytes =
          await rootBundle.load('assets/template/product_template.xlsx');
      final buffer = bytes.buffer;

      // 将模板文件保存到指定路径
      try {
        await output.writeAsBytes(
            buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
        if (mounted && context.mounted) {
          _showFileSaveCfmDialog(context, outputFile);
        }
      } catch (e) {
        if (mounted && context.mounted) {
          _showFileSaveCfmDialog(context, e.toString());
        }
      }
    }
  }
}
