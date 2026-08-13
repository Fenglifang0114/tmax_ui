import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:t_max/pages/update_firmware_page.dart';
import '../data/manager_scale_channel.dart';
import 'package:t_max/functions/methods.dart';
import '../data/download_prt_fmt.dart';
import '../data/language.dart';
import '../data/scalecmd_data.dart';
import '../data/writelog.dart';
import '../widget/custom_button.dart';

class DownReciptPage extends StatefulWidget {
  const DownReciptPage({super.key});

  @override
  State<DownReciptPage> createState() => _DownReciptPageState();
}

// late int connectionType;

class _DownReciptPageState extends State<DownReciptPage> {
  List<String> items = [];
  List<String> paths = [];
  List<String> printFormatSequence = [];
  String errorMessage = ''; //错误信息显示
  String? curruntPickFile = '';
  bool isDownloadClicked = false;
  bool hasDuplicates = false; //判断文件有没有重复序号

  TextEditingController weightController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController weightModeController = TextEditingController();
  TextEditingController accModeController = TextEditingController();
  TextEditingController pcsModeController = TextEditingController();
  TextEditingController pctModeController = TextEditingController();

  late ScrollController _fileScrollerController;
  var currentPath = Directory.current.path;

  Timer? _downloadTimer;

  @override
  void initState() {
    super.initState();
    _fileScrollerController = ScrollController();
    weightModeController.text = '';
    accModeController.text = '';
    pcsModeController.text = '';
    pctModeController.text = '';
  }

  String systemId = '';

  @override
  void dispose() {
    _fileScrollerController.dispose();

    _stopTimer();
    weightController.dispose();
    repsController.dispose();
    weightModeController.dispose();
    accModeController.dispose();
    pcsModeController.dispose();
    pctModeController.dispose();
    _downloadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // final _height = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Container(
            width: width,
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.surface),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // pageHeadInfo(
                  //     context,
                  //     width - headWidthPadding,
                  //     localizedStrings.menuReceiptFormatDownload,
                  //     localizedStrings.gTipReceiptFmtDownPageHelp),
                  Expanded(
                      child: Container(
                    color: Theme.of(context).colorScheme.surfaceTint,
                    child: Container(
                      color: Theme.of(context).colorScheme.surfaceTint,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildMainContent(),
                        ],
                      ),
                    ),
                  )),
                ])));
  }

  Widget _buildMainContent() {
    return Stack(children: [
      SizedBox(
        width: MediaQuery.of(context).size.width - 300,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            _buildDownloading(),
            Expanded(
              flex: 1,
              child: _buildButtonRow(),
            ),
            Expanded(
              flex: 4,
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
                      mainAxisAlignment:
                          MainAxisAlignment.center, // 设置主轴对齐方式为居中
                      children: [
                        SizedBox(
                          width: 200,
                          child: Text(
                            localizedStrings.gReceiptFormat + " 1:",
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
                            controller: weightModeController,
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
                          text: localizedStrings.button_select_format,
                          onPressed: () async {
                            weightModeController.text = '';
                            pickFiles(weightModeController);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // 设置主轴对齐方式为居中
                      children: [
                        SizedBox(
                          width: 200,
                          child: Text(
                            localizedStrings.gReceiptFormat + " 2:",
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 400,
                          child: TextField(
                            controller: accModeController,
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
                          text: localizedStrings.button_select_format,
                          onPressed: () async {
                            accModeController.text = '';
                            pickFiles(accModeController);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // 设置主轴对齐方式为居中
                      children: [
                        SizedBox(
                          width: 200,
                          child: Text(
                            localizedStrings.gReceiptFormat + " 3:",
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 400,
                          child: TextField(
                            controller: pcsModeController,
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
                          text: localizedStrings.button_select_format,
                          onPressed: () async {
                            pcsModeController.text = '';
                            pickFiles(pcsModeController);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildDownloading() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        isDownloadClicked
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomOutlinedButton(
          btnWidth: 150,
          btnHeight: 50,
          icon: Icons.download_outlined,
          text: localizedStrings.gBtnDownload,
          onPressed: (!isDownloadClicked) &&
                  (weightModeController.text.isNotEmpty ||
                      accModeController.text.isNotEmpty ||
                      pcsModeController.text.isNotEmpty ||
                      pctModeController.text.isNotEmpty)
              ? () {
                  _showConfirmationDialog(context);
                }
              : null,
        ),
      ],
    );
  }

  //导出文件到文件夹

  void copyFileToFolder(String sourceFilePath, String destinationFolderPath) {
    File sourceFile = File(sourceFilePath);
    Directory destinationFolder = Directory(destinationFolderPath);

    if (!destinationFolder.existsSync()) {
      destinationFolder.createSync(recursive: true);
    }
    File destinationFile = File(
        '$destinationFolderPath\\${sourceFile.path.split('\\').last}'); // 目标文件路径

    try {
      sourceFile.copySync(destinationFile.path);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(('Save ${destinationFile.path} successful.'),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
          duration: const Duration(seconds: 3),
          backgroundColor:
              Theme.of(context).colorScheme.onTertiaryFixedVariant));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('fail$e',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.error));
    }
  }

  // void _startTimer(int time) {
  //   _downloadTimer = Timer(Duration(seconds: time), () {
  //     setState(() {
  //       isDownloadClicked = false;
  //     });
  //     _stopTimer();

  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text(localizedStrings.gBtnDownload_result_fail,
  //             style: const TextStyle(
  //                 fontSize: 20, fontWeight: FontWeight.normal)), ////此处需要秤回复
  //         duration: const Duration(seconds: 3),
  //         backgroundColor: Theme.of(context).colorScheme.error));
  //   });
  // }

  void _stopTimer() {
    _downloadTimer?.cancel(); // 停止计时器
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
          content: Text(localizedStrings.gConfirmPrnFmtOrderTip),
          actions: <Widget>[
            OutlinedButton(
              child: Text(localizedStrings.gBtnCancel),
              onPressed: () {
                Navigator.of(ctx).pop(false); // 不跳转
              },
            ),
            OutlinedButton(
              child: Text(localizedStrings.gBtnConfirm),
              onPressed: () {
                Navigator.of(ctx).pop(true); // 跳转
              },
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        String msg = getSendMsg(printFormatSequence);
        showSelScaleDialog(1, msg);
      }
    });
  }

  void showSelScaleDialog(int funcNo, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false, // 允许点击空白处关闭对话框
      builder: (context) {
        return SelectScalesPageNew(
          funcNo: funcNo,
          sendMsgStr: msg,
        );
      },
    );
  }

  String getSendMsg(List<String> fmtSequence) {
    myScaleCmd.cmdMode = "down_print_format_to_scale";
    paths.clear();
    if (weightModeController.text.isNotEmpty) {
      paths.add('1${weightModeController.text}');
    }
    if (accModeController.text.isNotEmpty) {
      paths.add('2${accModeController.text}');
    }
    if (pcsModeController.text.isNotEmpty) {
      paths.add('3${pcsModeController.text}');
    }
    if (pctModeController.text.isNotEmpty) {
      paths.add('4${pctModeController.text}');
    }
    if (paths.isEmpty) {
      return "";
    }

    myDownLoadPrtFmt.scaleModel = myDefScaleInfo.defScaleModel ?? '';
    myDownLoadPrtFmt.printerModel = 'Receipt';
    myDownLoadPrtFmt.filePaths = paths;
    myScaleCmd.cmdData = json.encode(myDownLoadPrtFmt);

    writelog(jsonEncode(myScaleCmd));
    return jsonEncode(myScaleCmd);
  }

  void sendFormatToScale(List<String> fmtSequence) async {
    myScaleCmd.cmdMode = "down_print_format_to_scale";
    paths.clear();

    if (weightModeController.text.isNotEmpty) {
      paths.add('1${weightModeController.text}');
    }
    if (accModeController.text.isNotEmpty) {
      paths.add('2${accModeController.text}');
    }
    if (pcsModeController.text.isNotEmpty) {
      paths.add('3${pcsModeController.text}');
    }
    if (pctModeController.text.isNotEmpty) {
      paths.add('4${pctModeController.text}');
    }
    if (paths.isNotEmpty) {
      myDownLoadPrtFmt.scaleModel = myDefScaleInfo.defScaleModel ?? '';
      // myDownLoadPrtFmt.printerModel = 'EPM205';
      myDownLoadPrtFmt.printerModel = 'Receipt';
      myDownLoadPrtFmt.filePaths = paths;

      myScaleCmd.cmdData = json.encode(myDownLoadPrtFmt);
      PublicFunctions.sendMsg(
          myDefScaleInfo.defScaleId!, jsonEncode(myScaleCmd));
    }
    writelog(jsonEncode(myScaleCmd));
  }

  Future pickFiles(TextEditingController showFilePath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // initialDirectory: directory,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['fmt'],
    );
    if (result != null) {
      setState(() {
        showFilePath.text = result.files.single.path!;
      });
    } else {
      setState(() {
        showFilePath.text = '';
      });
    }
  }

  Future<String?> pickFolder() async {
    final folderPath = await FilePicker.platform.getDirectoryPath();
    return folderPath;
  }
}
