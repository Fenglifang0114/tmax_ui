import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/g_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/readoutput.dart';
import 'package:t_max/data/req_formula_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/dialog/raw_type_mgr.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/functions/methods.dart';
import 'package:t_max/widget/common_widget.dart';
import 'package:t_max/widget/dialog_head_style.dart';

////添加原料信息
///
///// 定义新增原料弹框组件
///
///
///
String decodeUnicode(String input) {
  if (input.trim().isEmpty) return input;
  try {
    return input.replaceAllMapped(RegExp(r'\\u([0-9a-zA-Z]{4})'), (match) {
      int code = int.parse(match.group(1)!, radix: 16);
      return String.fromCharCode(code);
    });
  } catch (e) {
    return input;
  }
}

int getRawTypeId(String name) {
  for (var item in rawTypeList) {
    if (item.categoryName == name) {
      return item.categoryId;
    }
  }
  return -1;
}

class AddRawDialog extends StatefulWidget {
  const AddRawDialog({super.key});
  @override
  AddRawDialogState createState() => AddRawDialogState();
}

class AddRawDialogState extends State<AddRawDialog> {
  TextEditingController rawCodeCtl = TextEditingController();
  TextEditingController rawNameCtl = TextEditingController();
  TextEditingController rawRemarkCtl = TextEditingController();
  TextEditingController rawTypeCtl = TextEditingController();
  TextEditingController scaleNameCtl = TextEditingController();
  TextEditingController checkCodeCtl = TextEditingController();
  TextEditingController outputPortCtl = TextEditingController();
  TextEditingController qrCodeScanCtl = TextEditingController();

  bool isCategoryValid = true;
  bool isScaleValid = true;
  bool isOutputValid = true;

  dynamic _eventbus1;
  dynamic _eventbus2;

  List<RespOutputInfo> outputPortStatusList = [];

  @override
  void initState() {
    PublicFunctions.getOutputPortStatus();
    _eventbus1 = eventBus.on<EventRespGetRawTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            rawTypeList = categoryTypeListFromJson(dataStr);
          });
        } else {
          setState(() {
            rawTypeList = [];
          });
        }
      }
    });

    _eventbus2 = eventBus.on<EventRespGetOutputPortStatus>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          try {
            List<RespOutputInfo> tempList = respOutputInfoFromJson(dataStr);

            setState(() {
              if (tempList.isNotEmpty) {
                outputPortStatusList = tempList;
              }
            });
          } catch (e) {
            setState(() {});
          }
        } else {
          setState(() {});
        }
      }
    });
    super.initState();
  }

//

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();

    rawCodeCtl.dispose();
    rawNameCtl.dispose();
    rawRemarkCtl.dispose();
    rawTypeCtl.dispose();
    scaleNameCtl.dispose();
    checkCodeCtl.dispose();
    outputPortCtl.dispose();
    qrCodeScanCtl.dispose();

    super.dispose();
  }

  void parseAndFillQrData(String val) {
    if (val.trim().isEmpty) return;
    try {
      String decodedVal = decodeUnicode(val.trim());
      Map<String, dynamic> data = jsonDecode(decodedVal);

      setState(() {
        // 1. 原料编号 id
        if (data['id'] != null) {
          rawCodeCtl.text = decodeUnicode(data['id'].toString());
        }

        // 2. 原料名称 name
        if (data['name'] != null) {
          rawNameCtl.text = decodeUnicode(data['name'].toString());
        }

        // 3. 验证条码 checkCode
        if (data['checkCode'] != null) {
          checkCodeCtl.text = decodeUnicode(data['checkCode'].toString());
        }

        // 4. 成分说明 ingredient
        if (data['ingredient'] != null) {
          rawRemarkCtl.text = decodeUnicode(data['ingredient'].toString());
        }

        // 5. 原料类别 category
        if (data['category'] != null) {
          String catName = decodeUnicode(data['category'].toString());
          rawTypeCtl.text = catName;
          isCategoryValid = rawTypeList.any((item) => item.categoryName == catName);
        }

        // 6. 选择设备 scaleName
        if (data['scaleName'] != null) {
          String scaleVal = decodeUnicode(data['scaleName'].toString());
          Scale? matchedScale;
          for (var item in myAllScalesList) {
            if (item.scaleId.toString() == scaleVal || item.scaleName == scaleVal) {
              matchedScale = item;
              break;
            }
          }
          if (matchedScale != null) {
            scaleNameCtl.text = matchedScale.scaleId.toString();
            isScaleValid = true;
          } else {
            scaleNameCtl.text = scaleVal;
            isScaleValid = false;
          }
        }

        // 7. 输出口 outputPort
        if (data['outputPort'] != null) {
          String outputVal = decodeUnicode(data['outputPort'].toString());
          outputPortCtl.text = outputVal;
          if (outputVal.isEmpty) {
            isOutputValid = true;
          } else {
            final filteredList = outputPortList.where((item) => item != "0").toList();
            isOutputValid = filteredList.contains(outputVal);
          }
        }
      });
    } catch (e) {
      // 容错捕获：解析非 JSON 字符串时不报错、不崩溃
    }
  }

  TextStyle getTextStyle({Color? color}) {
    return Theme.of(context).textTheme.bodySmall!.apply(
          color: color ?? Theme.of(context).colorScheme.onSurface,
        );
  }

  Widget showTypeDropDownButton(
      String hintText, TextEditingController valueCtl) {
    bool isValid = isCategoryValid;
    String currentVal = rawTypeCtl.text;
    bool isMatch = rawTypeList.any((item) => item.categoryName == currentVal);

    String? selectedValue = isMatch ? currentVal : null;
    bool isCustomInvalid = !isValid && currentVal.isNotEmpty;

    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          localizedStrings.fPleaseSelectCategory,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 12,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
        ),
      ),
      ...rawTypeList.map((CategoryTypeList item) {
        return DropdownMenuItem<String>(
          value: item.categoryName,
          child: Text(item.categoryName,
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
        );
      })
    ];

    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: isValid ? Theme.of(context).colorScheme.outlineVariant : Colors.red,
              width: isValid ? 1 : 1.5),
          borderRadius: BorderRadius.circular(0),
        ),
        child: DropdownButton<String>(
            underline: const SizedBox(),
            isExpanded: true,
            value: selectedValue,
            hint: isCustomInvalid
                ? Text(
                    currentVal,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    localizedStrings.fPleaseSelectCategory,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                  ),
            items: menuItems,
            onChanged: (value) {
              if (value == null) {
                setState(() {
                  rawTypeCtl.text = '';
                  isCategoryValid = true;
                });
                return;
              }

              setState(() {
                rawTypeCtl.text = value.toString();
                isCategoryValid = true;
              });
            },
            style: TextStyle(
              fontSize: 12,
              color: isValid ? Theme.of(context).colorScheme.onSurface : Colors.red,
            )));
  }

//选择秤
  Widget showScaleDropDownBtn(String hintText) {
    bool isValid = isScaleValid;
    String currentVal = scaleNameCtl.text;
    bool isMatch = myAllScalesList.any((item) => item.scaleId.toString() == currentVal);

    String? selectedValue = isMatch ? currentVal : null;
    bool isCustomInvalid = !isValid && currentVal.isNotEmpty;

    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          hintText,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 12,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
        ),
      ),
      ...myAllScalesList.map((Scale item) {
        return DropdownMenuItem<String>(
          value: item.scaleId.toString(),
          child: Text("${item.scaleId}:${item.scaleName}",
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
        );
      })
    ];

    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: isValid ? Theme.of(context).colorScheme.outlineVariant : Colors.red,
              width: isValid ? 1 : 1.5),
          borderRadius: BorderRadius.circular(0),
        ),
        child: DropdownButton<String>(
            underline: const SizedBox(),
            isExpanded: true,
            value: selectedValue,
            hint: isCustomInvalid
                ? Text(
                    currentVal,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    hintText,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                  ),
            items: menuItems,
            onChanged: (value) {
              if (value == null) {
                setState(() {
                  scaleNameCtl.text = '';
                  isScaleValid = true;
                });
                return;
              }

              setState(() {
                scaleNameCtl.text = value.toString();
                isScaleValid = true;
              });
            },
            style: TextStyle(
              fontSize: 12,
              color: isValid ? Theme.of(context).colorScheme.onSurface : Colors.red,
            )));
  }

  String getOutputPortRemarkString(String port) {
    RespOutputInfo? info = outputPortStatusList.firstWhere(
        (element) => element.port.toString() == port,
        orElse: () => RespOutputInfo());
    return info.remark ?? "";
  }

  List<String> outputPortList = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12"
  ];

  //选择输出端口
  Widget showOutputDropDownBtn(String hintText) {
    final filteredList = outputPortList.where((item) => item != "0").toList();

    bool isValid = isOutputValid;
    String currentVal = outputPortCtl.text;
    bool isMatch = filteredList.contains(currentVal);

    String? selectedValue = isMatch ? currentVal : null;
    bool isCustomInvalid = !isValid && currentVal.isNotEmpty;

    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          hintText,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 12,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
        ),
      ),
      ...filteredList.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text("$item    :    ${getOutputPortRemarkString(item)}",
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
        );
      })
    ];

    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: isValid ? Theme.of(context).colorScheme.outlineVariant : Colors.red,
              width: isValid ? 1 : 1.5),
          borderRadius: BorderRadius.circular(0),
        ),
        child: DropdownButton<String>(
            underline: const SizedBox(),
            isExpanded: true,
            value: selectedValue,
            hint: isCustomInvalid
                ? Text(
                    currentVal,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    hintText,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                  ),
            items: menuItems,
            onChanged: (String? value) {
              if (value == null) {
                setState(() {
                  outputPortCtl.text = '';
                  isOutputValid = true;
                });
                return;
              }

              setState(() {
                outputPortCtl.text = value;
                isOutputValid = true;
              });
            },
            style: TextStyle(
              fontSize: 12,
              color: isValid ? Theme.of(context).colorScheme.onSurface : Colors.red,
            )));
  }

  // 显示原料类型管理的对话框
  void showRawTypeMgrDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return RawTypeMgrDialog();
      },
    ).then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // 提取公共的文本样式
    final textStyle = Theme.of(context).textTheme.bodySmall!.apply(
          color: Theme.of(context).colorScheme.onSurface,
          overflow: TextOverflow.ellipsis,
        );

    // 提取输入框的公共装饰
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 665,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(
                context, localizedStrings.fAddRawMaterialBtn, true),

            // 中部
            Expanded(
                child: Column(children: [
              SizedBox(
                // padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                height: 90,
                width: 582,
                child: Row(children: [
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.fMaterialIdCol, true),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: rawCodeCtl,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(0.0))),
                                      hintText: localizedStrings
                                          .fInputRawMaterialIdHint,
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            // 设置提示文本样式
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                          ),
                                      suffixIconConstraints:
                                          BoxConstraints.tight(Size(40, 40)),
                                    ),
                                    onChanged: (value) {
                                      // 处理输入变化事件
                                      // print('Input changed: $value');
                                      setState(() {});
                                    },
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                  )),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.fMaterialNameCol, true),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: rawNameCtl,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(0.0))),
                                      hintText: localizedStrings
                                          .fInputRawMaterialNameHint,
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            // 设置提示文本样式
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                          ),
                                      suffixIconConstraints:
                                          BoxConstraints.tight(Size(40, 40)),
                                    ),
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                  )),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                ]),
              ),
              SizedBox(
                height: 90,
                width: 582,
                child: Row(children: [
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.fFmaCategoryCol, false),
                        showTypeDropDownButton(
                            localizedStrings.fPleaseSelectCategory, rawTypeCtl),
                      ])),
                  SizedBox(
                    width: largePadding,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        Container(
                          height: 42,
                        ),
                        SizedBox(
                          height: btnHeight,
                          child: Row(children: [
                            Expanded(
                              child: showTextButton(context, btnHeight,
                                  localizedStrings.fRawCategoryManagement, () {
                                showRawTypeMgrDialog();
                              },
                                  Theme.of(context).colorScheme.onPrimary,
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.onPrimary),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: largePadding,
                  ),
                ]),
              ),
              SizedBox(
                height: 90,
                width: 582,
                child: Row(children: [
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.selectDevice, false),
                        showScaleDropDownBtn(localizedStrings.selectDevice),
                      ])),
                  SizedBox(
                    width: largePadding,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.verificationCode, false),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline, // 设置边框颜色
                                      width: 1, // 设置边框宽度
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: checkCodeCtl,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '',
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                          ),
                                      suffixIconConstraints:
                                          BoxConstraints.tight(Size(40, 40)),
                                    ),
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: largePadding,
                  ),
                ]),
              ),
              SizedBox(
                height: 90,
                width: 582,
                child: Row(children: [
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.outputPort, false),
                        showOutputDropDownBtn(localizedStrings.outputPort),
                      ])),
                  SizedBox(
                    width: largePadding,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.fQrCodeRecognition, false),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline,
                                      width: 1,
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: qrCodeScanCtl,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10),
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                          ),
                                      suffixIconConstraints:
                                          BoxConstraints.tight(
                                              const Size(40, 40)),
                                    ),
                                    onChanged: (value) {
                                      parseAndFillQrData(value);
                                    },
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: largePadding,
                  ),
                ]),
              ),
              SizedBox(
                height: 150,
                width: 582,
                child: Row(
                  children: [
                    const SizedBox(width: largePadding),
                    Expanded(
                      child: Column(
                        children: [
                          // 标签部分
                          SizedBox(
                              height: 42,
                              child: _LabelSection(textStyle: textStyle)),
                          // 输入框部分
                          Expanded(
                              child: _InputSection(
                                  inputDecoration: inputDecoration,
                                  rawRemarkCtl: rawRemarkCtl)),
                        ],
                      ),
                    ),
                    const SizedBox(width: largePadding),
                  ],
                ),
              ),
            ])),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: (rawCodeCtl.text.isEmpty ||
                              rawNameCtl.text.isEmpty ||
                              !isCategoryValid ||
                              !isScaleValid ||
                              !isOutputValid)
                          ? null
                          : () {
                              // 检查原料是否已经存在
                              for (var item in rawDataList) {
                                if (item.materialId == rawCodeCtl.text) {
                                  showTipInfo(localizedStrings.fRawIdDuplicate,
                                      context);
                                  return;
                                }
                              }

                              int typeId = getRawTypeId(rawTypeCtl.text);
                              if (typeId == -1) {
                                typeId = 0;
                                // return;
                              }
                              int? scaleId = 0;
                              if (scaleNameCtl.text != "") {
                                scaleId = int.tryParse(scaleNameCtl.text);
                              }
                              int output = 0;
                              if (outputPortCtl.text != "") {
                                output = int.tryParse(outputPortCtl.text) ?? 0;
                              }
                              AddRawData data = AddRawData(
                                  materialId: rawCodeCtl.text,
                                  materialName: rawNameCtl.text,
                                  categoryId: typeId,
                                  ingredient: rawRemarkCtl.text,
                                  createdBy: mySysUser.nickName!,
                                  updatedBy: mySysUser.nickName!,
                                  remark: "",
                                  remark1: "",
                                  scaleId: scaleId,
                                  checkCode: checkCodeCtl.text,
                                  output: output);

                              PublicFunctions.addRawData(data);
                              Navigator.pop(context);
                            },
                      child: Text(
                        localizedStrings.gBtnConfirm,
                        style: Theme.of(context).textTheme.labelMedium!.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                              overflow: TextOverflow.ellipsis,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        localizedStrings.gBtnCancel,
                        style: Theme.of(context).textTheme.labelMedium!.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                              overflow: TextOverflow.ellipsis,
                            ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 提取输入框部分为单独的组件
class _InputSection extends StatelessWidget {
  final InputDecoration inputDecoration;
  final TextEditingController rawRemarkCtl;

  const _InputSection(
      {required this.inputDecoration, required this.rawRemarkCtl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: rawRemarkCtl,
            decoration: inputDecoration.copyWith(
              hintText: localizedStrings.fInputIngredientDescHint,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            maxLines: 4,
            style: Theme.of(context).textTheme.bodySmall!.apply(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }
}

// 提取标签部分为单独的组件
class _LabelSection extends StatelessWidget {
  final TextStyle textStyle;

  const _LabelSection({required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              localizedStrings.fIngredientRemark,
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }
}

class EditRawDialog extends StatefulWidget {
  const EditRawDialog({super.key, required this.rawData});
  final RawDataInfo rawData;
  @override
  EditRawDialogState createState() => EditRawDialogState();
}

class EditRawDialogState extends State<EditRawDialog> {
  TextEditingController rawCodeCtl = TextEditingController();
  TextEditingController rawNameCtl = TextEditingController();
  TextEditingController rawRemarkCtl = TextEditingController();
  TextEditingController rawTypeCtl = TextEditingController();
  TextEditingController scaleIdCtl = TextEditingController();
  TextEditingController checkCodeCtl = TextEditingController();
  TextEditingController outputPortCtl = TextEditingController();
  TextEditingController qrCodeScanCtl = TextEditingController();

  bool isCategoryValid = true;
  bool isScaleValid = true;
  bool isOutputValid = true;

  dynamic _eventbus1;

  dynamic _eventbus2;

  List<RespOutputInfo> outputPortStatusList = [];

  @override
  void initState() {
    super.initState();
    rawCodeCtl.text = widget.rawData.materialId!;
    rawNameCtl.text = widget.rawData.materialName!;

    rawRemarkCtl.text = widget.rawData.ingredient!;
    rawTypeCtl.text = getRawTypeName(widget.rawData.categoryId!);
    scaleIdCtl.text =
        (widget.rawData.scaleId == 0 || widget.rawData.scaleId == null)
            ? ""
            : widget.rawData.scaleId.toString();
    checkCodeCtl.text = widget.rawData.checkCode!;
    outputPortCtl.text =
        (widget.rawData.output == 0 || widget.rawData.output == null)
            ? ""
            : widget.rawData.output.toString();
    PublicFunctions.getOutputPortStatus();
    _eventbus1 = eventBus.on<EventRespGetRawTypeList>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '') {
          setState(() {
            rawTypeList = categoryTypeListFromJson(dataStr);
          });
        } else {
          setState(() {
            rawTypeList = [];
          });
        }
      }
    });

    _eventbus2 = eventBus.on<EventRespGetOutputPortStatus>().listen((event) {
      if (mounted) {
        String dataStr = event.obj;
        if (dataStr != '' && dataStr != 'null') {
          try {
            List<RespOutputInfo> tempList = respOutputInfoFromJson(dataStr);

            setState(() {
              if (tempList.isNotEmpty) {
                outputPortStatusList = tempList;
              }
            });
          } catch (e) {
            setState(() {});
          }
        } else {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _eventbus1.cancel();
    _eventbus2.cancel();
    rawCodeCtl.dispose();
    rawNameCtl.dispose();
    rawRemarkCtl.dispose();
    rawTypeCtl.dispose();
    scaleIdCtl.dispose();
    checkCodeCtl.dispose();
    outputPortCtl.dispose();
    qrCodeScanCtl.dispose();

    super.dispose();
  }

  void parseAndFillQrData(String val) {
    if (val.trim().isEmpty) return;
    try {
      String decodedVal = decodeUnicode(val.trim());
      Map<String, dynamic> data = jsonDecode(decodedVal);

      setState(() {
        // 1. 原料编号 id
        if (data['id'] != null) {
          rawCodeCtl.text = decodeUnicode(data['id'].toString());
        }

        // 2. 原料名称 name
        if (data['name'] != null) {
          rawNameCtl.text = decodeUnicode(data['name'].toString());
        }

        // 3. 验证条码 checkCode
        if (data['checkCode'] != null) {
          checkCodeCtl.text = decodeUnicode(data['checkCode'].toString());
        }

        // 4. 成分说明 ingredient
        if (data['ingredient'] != null) {
          rawRemarkCtl.text = decodeUnicode(data['ingredient'].toString());
        }

        // 5. 原料类别 category
        if (data['category'] != null) {
          String catName = decodeUnicode(data['category'].toString());
          rawTypeCtl.text = catName;
          isCategoryValid = rawTypeList.any((item) => item.categoryName == catName);
        }

        // 6. 选择设备 scaleName
        if (data['scaleName'] != null) {
          String scaleVal = decodeUnicode(data['scaleName'].toString());
          Scale? matchedScale;
          for (var item in myAllScalesList) {
            if (item.scaleId.toString() == scaleVal || item.scaleName == scaleVal) {
              matchedScale = item;
              break;
            }
          }
          if (matchedScale != null) {
            scaleIdCtl.text = matchedScale.scaleId.toString();
            isScaleValid = true;
          } else {
            scaleIdCtl.text = scaleVal;
            isScaleValid = false;
          }
        }

        // 7. 输出口 outputPort
        if (data['outputPort'] != null) {
          String outputVal = decodeUnicode(data['outputPort'].toString());
          outputPortCtl.text = outputVal;
          if (outputVal.isEmpty) {
            isOutputValid = true;
          } else {
            final filteredList = outputPortList.where((item) => item != "0").toList();
            isOutputValid = filteredList.contains(outputVal);
          }
        }
      });
    } catch (e) {
      // 容错捕获：解析非 JSON 字符串时不报错、不崩溃
    }
  }

  Widget showTypeDropDownButton(
      String hintText, TextEditingController valueCtl) {
    bool isValid = isCategoryValid;
    String currentVal = rawTypeCtl.text;
    bool isMatch = rawTypeList.any((item) => item.categoryName == currentVal);

    String? selectedValue = isMatch ? currentVal : null;
    bool isCustomInvalid = !isValid && currentVal.isNotEmpty;

    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          localizedStrings.fPleaseSelectCategory,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 12,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
        ),
      ),
      ...rawTypeList.map((CategoryTypeList item) {
        return DropdownMenuItem<String>(
          value: item.categoryName,
          child: Text(item.categoryName,
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
        );
      })
    ];

    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: isValid ? Theme.of(context).colorScheme.outlineVariant : Colors.red,
              width: isValid ? 1 : 1.5),
          borderRadius: BorderRadius.circular(0),
        ),
        child: DropdownButton<String>(
            underline: const SizedBox(),
            isExpanded: true,
            value: selectedValue,
            hint: isCustomInvalid
                ? Text(
                    currentVal,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    localizedStrings.fPleaseSelectCategory,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                  ),
            items: menuItems,
            onChanged: (value) {
              if (value == null) {
                setState(() {
                  rawTypeCtl.text = '';
                  isCategoryValid = true;
                });
                return;
              }

              setState(() {
                rawTypeCtl.text = value.toString();
                isCategoryValid = true;
              });
            },
            style: TextStyle(
              fontSize: 12,
              color: isValid ? Theme.of(context).colorScheme.onSurface : Colors.red,
            )));
  }

//选择秤
  Widget showScaleDropDownBtn(String hintText) {
    bool isValid = isScaleValid;
    String currentVal = scaleIdCtl.text;
    bool isMatch = myAllScalesList.any((item) => item.scaleId.toString() == currentVal);

    String? selectedValue = isMatch ? currentVal : null;
    bool isCustomInvalid = !isValid && currentVal.isNotEmpty;

    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          hintText,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 12,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
        ),
      ),
      ...myAllScalesList.map((Scale item) {
        return DropdownMenuItem<String>(
          value: item.scaleId.toString(),
          child: Text("${item.scaleId}:${item.scaleName}",
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
        );
      })
    ];

    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: isValid ? Theme.of(context).colorScheme.outlineVariant : Colors.red,
              width: isValid ? 1 : 1.5),
          borderRadius: BorderRadius.circular(0),
        ),
        child: DropdownButton<String>(
            underline: const SizedBox(),
            isExpanded: true,
            value: selectedValue,
            hint: isCustomInvalid
                ? Text(
                    currentVal,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    hintText,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                  ),
            items: menuItems,
            onChanged: (value) {
              if (value == null) {
                setState(() {
                  scaleIdCtl.text = '';
                  isScaleValid = true;
                });
                return;
              }

              setState(() {
                scaleIdCtl.text = value.toString();
                isScaleValid = true;
              });
            },
            style: TextStyle(
              fontSize: 12,
              color: isValid ? Theme.of(context).colorScheme.onSurface : Colors.red,
            )));
  }

  String getOutputPortRemarkString(String port) {
    RespOutputInfo? info = outputPortStatusList.firstWhere(
        (element) => element.port.toString() == port,
        orElse: () => RespOutputInfo());
    return info.remark ?? "";
  }

  List<String> outputPortList = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12"
  ];

  //选择输出端口
  Widget showOutputDropDownBtn(String hintText) {
    final filteredList = outputPortList.where((item) => item != "0").toList();

    bool isValid = isOutputValid;
    String currentVal = outputPortCtl.text;
    bool isMatch = filteredList.contains(currentVal);

    String? selectedValue = isMatch ? currentVal : null;
    bool isCustomInvalid = !isValid && currentVal.isNotEmpty;

    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          hintText,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 12,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
        ),
      ),
      ...filteredList.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text("$item    :    ${getOutputPortRemarkString(item)}",
              style: Theme.of(context).textTheme.bodySmall!.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
        );
      })
    ];

    return Container(
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: isValid ? Theme.of(context).colorScheme.outlineVariant : Colors.red,
              width: isValid ? 1 : 1.5),
          borderRadius: BorderRadius.circular(0),
        ),
        child: DropdownButton<String>(
            underline: const SizedBox(),
            isExpanded: true,
            value: selectedValue,
            hint: isCustomInvalid
                ? Text(
                    currentVal,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    hintText,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                  ),
            items: menuItems,
            onChanged: (String? value) {
              if (value == null) {
                setState(() {
                  outputPortCtl.text = '';
                  isOutputValid = true;
                });
                return;
              }

              setState(() {
                outputPortCtl.text = value;
                isOutputValid = true;
              });
            },
            style: TextStyle(
              fontSize: 12,
              color: isValid ? Theme.of(context).colorScheme.onSurface : Colors.red,
            )));
  }

  //// 显示原料类型管理的对话框
  void showRawTypeMgrDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 点击对话框外部不关闭对话框
      builder: (BuildContext context) {
        return RawTypeMgrDialog();
      },
    ).then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 610,
        height: 665,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            // 头部
            ...dialogHeadStyle(context, localizedStrings.fEditMaterial, true),

            // 中部
            Expanded(
                child: Column(children: [
              SizedBox(
                // padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                height: 90,
                width: 582,
                child: Row(children: [
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.fMaterialIdCol, true),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline, // 设置边框颜色
                                      width: 1, // 设置边框宽度
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    enabled: false,
                                    controller: rawCodeCtl,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: localizedStrings
                                          .fInputRawMaterialIdHint,
                                      suffixIconConstraints:
                                          BoxConstraints.tight(Size(40, 40)),
                                    ),
                                    onChanged: (value) {
                                      // 处理输入变化事件
                                      // print('Input changed: $value');
                                      setState(() {});
                                    },
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.fMaterialNameCol, true),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline, // 设置边框颜色
                                      width: 1, // 设置边框宽度
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: rawNameCtl,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: localizedStrings
                                          .fInputRawMaterialNameHint,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            // 设置提示文本样式
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                          ),
                                      suffixIconConstraints:
                                          BoxConstraints.tight(Size(40, 40)),
                                    ),
                                    onChanged: (value) {
                                      // 处理输入变化事件
                                      // print('Input changed: $value');
                                      setState(() {});
                                    },
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                ]),
              ),
              SizedBox(
                height: 90,
                width: 582,
                child: Row(children: [
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.fFmaCategoryCol, false),
                        showTypeDropDownButton(
                            localizedStrings.fPleaseSelectCategory, rawTypeCtl),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        Container(
                          height: 42,
                        ),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Expanded(
                              child: showTextButton(context, btnHeight,
                                  localizedStrings.fRawCategoryManagement, () {
                                showRawTypeMgrDialog();
                              },
                                  Theme.of(context).colorScheme.onPrimary,
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.onPrimary),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                ]),
              ),
              SizedBox(
                height: 90,
                width: 582,
                child: Row(children: [
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.selectDevice, false),
                        showScaleDropDownBtn(localizedStrings.selectDevice),
                      ])),
                  SizedBox(
                    width: largePadding,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.verificationCode, false),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline, // 设置边框颜色
                                      width: 1, // 设置边框宽度
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: checkCodeCtl,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '',
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                          ),
                                      suffixIconConstraints:
                                          BoxConstraints.tight(Size(40, 40)),
                                    ),
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: largePadding,
                  ),
                ]),
              ),
              SizedBox(
                height: 90,
                width: 582,
                child: Row(children: [
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.outputPort, false),
                        showOutputDropDownBtn(localizedStrings.outputPort),
                      ])),
                  SizedBox(
                    width: largePadding,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.fQrCodeRecognition, false),
                        SizedBox(
                          height: 48,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline,
                                      width: 1,
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: qrCodeScanCtl,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10),
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                          ),
                                      suffixIconConstraints:
                                          BoxConstraints.tight(
                                              const Size(40, 40)),
                                    ),
                                    onChanged: (value) {
                                      parseAndFillQrData(value);
                                    },
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: largePadding,
                  ),
                ]),
              ),
              SizedBox(
                height: 116,
                width: 582,
                child: Row(children: [
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(children: [
                        showItemNameWithStar(
                            context, localizedStrings.fIngredientRemark, false),
                        SizedBox(
                          height: 74,
                          child: Row(children: [
                            Expanded(
                              child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline, // 设置边框颜色
                                      width: 1, // 设置边框宽度
                                    ),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: rawRemarkCtl,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: localizedStrings
                                          .fInputIngredientDescHint,
                                      suffixIconConstraints:
                                          BoxConstraints.tight(Size(40, 40)),
                                    ),
                                    maxLines: 3,
                                    onChanged: (value) {
                                      // 处理输入变化事件
                                      // print('Input changed: $value');
                                      setState(() {});
                                    },
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                            ),
                          ]),
                        ),
                      ])),
                  SizedBox(
                    width: 20,
                  ),
                ]),
              ),
            ])),

            // 底部
            Container(
              height: 96,
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: (rawCodeCtl.text.isEmpty ||
                              rawNameCtl.text.isEmpty ||
                              !isCategoryValid ||
                              !isScaleValid ||
                              !isOutputValid)
                          ? null
                          : () {
                                  int typeId = getRawTypeId(rawTypeCtl.text);
                                  if (typeId == -1) {
                                    return;
                                  }
                                  int scaleId = 0;
                                  if (scaleIdCtl.text.isNotEmpty) {
                                    scaleId = int.parse(scaleIdCtl.text);
                                  }
                                  int output = 0;
                                  if (outputPortCtl.text.isNotEmpty) {
                                    output = int.parse(outputPortCtl.text);
                                  }

                                  EditRawData data = EditRawData(
                                    recId: widget.rawData.recId!,
                                    materialId: rawCodeCtl.text,
                                    materialName: rawNameCtl.text,
                                    categoryId: typeId,
                                    ingredient: rawRemarkCtl.text,
                                    createdBy: widget.rawData.createdBy!,
                                    updatedBy: mySysUser.nickName!,
                                    remark: "",
                                    remark1: "",
                                    scaleId: scaleId,
                                    checkCode: checkCodeCtl.text,
                                    output: output,
                                  );
                                  PublicFunctions.editRawData(data);

                                  Navigator.pop(context);
                                },
                      child: Text(
                        localizedStrings.gBtnConfirm,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        fixedSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        localizedStrings.gBtnCancel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
