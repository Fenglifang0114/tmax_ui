import 'dart:convert';
import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:t_max/labeldesign/label_element.dart';
import 'package:t_max/labeldesign/label_formatdata.dart';

Map<String, String> varInScaleMap = {}; //隐藏字段为key，显示字段为value

final List<String> printDirections = [
  '0',
  '90',
  '180',
  '270',
];

final List<String> imgRotations = [
  '0',
  '180',
];

final List<String> fontBoldReverse = [
  'true',
  'false',
];
final List<String> rotations = [
  '0',
  '90',
  '180',
  '270',
];
final List<String> alignments = [
  'Left',
  'Center',
  'Right',
];
final List<String> hralignments = [
  'None',
  'Bottom',
  // 'Top',
];
final List<String> qrWidths = [
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
];

final List<String> fontSizes = [
  // '20', //1 1 1   中文不支持
  '20',
  '21',
  '23', //4 1 1
  // '39', //1 2 2   中文不支持
  '46', //4 2 2
  '69', //4 3 3
  '95', //4 4 4
  '115', //4 5 5
  '137', //4 6 6
  '165', //4 7 7
  '170', //4 8 8
];

const varCollection = {
  "Free Text": ["Text,TEXT"],
  "BarCode Variable": ["BarCode,BarCode"],
  "Qrcode Variable": ["Qrcode,Qrcode"],
  "Shape": ["Line,Line"],
  // "Shape": ["Rectangle,Rectangle", "Circle,Circle", "Line,Line"],
  "Variable": [
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
    "TotalPcs,DATA",
  ],
};

Barcode getBarcodeType(String type) {
  Barcode barcode = Barcode.code128();

  switch (type) {
    case 'Code39':
      barcode = Barcode.code39();
      break;
    case 'Code128':
    case 'Code128_None':
      barcode = Barcode.code128();
      break;
    case 'EAN13':
      barcode = Barcode.ean13();
      break;
    case 'EAN8':
      barcode = Barcode.ean8();
      break;
    case 'UPC-A':
      barcode = Barcode.upcA();
      break;
    case 'UPC-E':
      barcode = Barcode.upcE();
      break;
    case 'Code93':
      barcode = Barcode.code93();
      break;
    default:
      barcode = Barcode.code128();
      break;
  }

  return barcode;
}

String getBarcodeContant(String type) {
  String content = '';
  switch (type) {
    case 'Code39':
      content = "1234567890";
      break;
    case 'Code128':
    case 'Code128_None':
      content = "Barcode";
      break;
    case 'EAN13':
      content = '012345678910';
      break;
    case 'EAN8':
      content = '1234567';
      break;
    case 'UPC-A':
      content = "123456789012";
      break;
    case 'UPC-E':
      content = "123456";
      break;
    case 'Code93':
      content = content;
      break;
    default:
      content = "Barcode";
      break;
  }

  return content;
}

DraggableElement addElementToList(String name, String lastFontSize) {
  int xPos = 10;
  int yPos = 10;
  int style = 0; //条码库中是否有此条码
  int rotation = 0;
  String alignment = "Left";
  int maxLength = 10;
  int tabOrder = 0;
  int x2Pos = 100;
  int y2Pos = 0;
  int fontWidthRatio = 1;
  int fontHeightRatio = 1;

  double width = 150;
  double height = 30;
  double lineWidth = 2;

  String defaultValue = 'data';
  String barcodeName = '--';
  String barcodeType = '';
  String hralignment = 'Bottom';
  String qrWidth = '3';
  String qrcodename = '--';
  String qrcodeType = 'Qrcode';
  String fontBold = 'false';
  String fontReverse = 'false';

  List<dynamic> varcontent = [];

  String text = name.split(",")[0];
  String type = name.split(",")[1];

  String tmpText = text;

  if (type == 'DATA') {
    tmpText = getShowVarName(text, maxLength);
  } else if (type == "BarCode" || type == "IMG") {
    height = 80;
  }

  DraggableElement element = DraggableElement(
    position: Offset(xPos.toDouble(), yPos.toDouble()),
    size: Size(width, height),
    type: ElementType.text,
    index: 0,
    xPos: xPos,
    yPos: yPos,
    width: width,
    height: height,
    fontSize: lastFontSize,
    fontWidthRatio: fontWidthRatio,
    fontHeightRatio: fontHeightRatio,
    alignment: alignment,
    maxLength: maxLength,
    rotation: rotation,
    style: style,
    tabOrder: tabOrder,
    varName: text,
    content: tmpText,
    defaultValue: defaultValue,
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
  );

  if (type == 'DATA' || type == 'data') {
    element.type = ElementType.data;
  } else if (type == "TEXT" || type == "text") {
    element.type = ElementType.text;
  } else if (type == "BarCode" || type == "barcode") {
    element.type = ElementType.barcode;
  } else if (type == "Qrcode" || type == "qrcode") {
    element.type = ElementType.qrcode;
    element.size = Size(3 * 21, 3 * 21);
  } else if (type == "Line" || type == "line") {
    element.type = ElementType.line;
    element.size = Size(100, 2);
  } else if (type == "IMG" || type == "img") {
    element.type = ElementType.img;
    element.varName = "";
  }
  return element;
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

void showConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: Text(
          'Confirmation',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: const Text('There is nothing to save!'),
        actions: <Widget>[
          OutlinedButton(
            child: const Text('Confirm'),
            onPressed: () {
              Navigator.of(context).pop(true); // 跳转
            },
          ),
        ],
      );
    },
  ).then((confirmed) {
    if (confirmed) {}
  });
}

DraggableElement copyElementFun(DraggableElement element) {
  DraggableElement newElement = DraggableElement(
    position: Offset(10, 10),
    size: element.size,
    type: element.type,
    index: element.index,
    xPos: element.xPos,
    yPos: element.yPos,
    width: element.width,
    height: element.height,
    fontSize: element.fontSize,
    fontWidthRatio: element.fontWidthRatio,
    fontHeightRatio: element.fontHeightRatio,
    alignment: element.alignment,
    maxLength: element.maxLength,
    rotation: element.rotation,
    style: element.style,
    tabOrder: element.tabOrder,
    varName: element.varName,
    content: element.content,
    defaultValue: element.defaultValue,
    varcontent: element.varcontent,
    barcodeName: element.barcodeName,
    barcodeType: element.barcodeType,
    hralignment: element.hralignment,
    x2Pos: element.x2Pos,
    y2Pos: element.y2Pos,
    lineWidth: element.lineWidth,
    qrWidth: element.qrWidth,
    qrcodeName: element.qrcodeName,
    qrcodeType: element.qrcodeType,
    fontBold: element.fontBold,
    fontReverse: element.fontReverse,
  );

  return newElement;
}

Future<String> convertImageToBlackAndWhiteBase64(String imagePath) async {
  try {
    // 读取图片文件
    final File file = File(imagePath);

    // 解码图片
    img.Image? originalImage = img.decodeImage(await file.readAsBytes());
    if (originalImage == null) {
      throw Exception('无法解码图片');
    }

    // 调整图片尺寸（例如将宽度设置为 800 像素，高度按比例缩放）
    originalImage = img.copyResize(originalImage, width: 200);

    // 压缩图片（逐步降低质量，直到文件大小小于 100KB）
    int quality = 100;
    Uint8List compressedBytes;
    do {
      compressedBytes = img.encodeJpg(originalImage, quality: quality);
      quality -= 10; // 每次减少质量5%
    } while (compressedBytes.length > 50 * 1024 &&
        quality > 0); // 100KB = 100 * 1024 bytes

    // 解码压缩后的图片
    img.Image compressedImage = img.decodeImage(compressedBytes)!;

    // // 将图片转换为黑白图片
    // final img.Image blackAndWhiteImage = img.grayscale(compressedImage);

    // // 编码为 JPEG 格式
    // final List<int> jpegBytes = img.encodeJpg(blackAndWhiteImage);

    // 将字节数据转换为 Base64 字符串
    final String base64Image = base64Encode(img.encodeJpg(compressedImage));

    return base64Image;
  } catch (e) {
    if (kDebugMode) {
      print('处理图片时出错: $e');
    }
    return '';
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

//处理图片，如果图片太大了要降低图片质量
// Future<String> _processImage(String imgPath) async {
//   var base64Image = await convertImageToBlackAndWhiteBase64(imgPath);
//   return base64Image;
// }

List getElementInfoFromFile(List<FmtContent> tmpContent) {
  List textInfoList = [];

  for (var i = 0; i < tmpContent.length; i++) {
    if (tmpContent[i].type == 'TEXT') {
      FromateItemData formData = FromateItemData(
        type: tmpContent[i].type,
        xPos: tmpContent[i].xPos!,
        yPos: tmpContent[i].yPos!,
        width: tmpContent[i].width!,
        height: tmpContent[i].height!,
        fontSize: tmpContent[i].fontSize!,
        fontWidthRatio: tmpContent[i].fontWidthRatio!,
        fontHeightRatio: tmpContent[i].fontHeightRatio!,
        alignment: 0,
        maxLength: 0,
        rotation: tmpContent[i].rotation!,
        style: 0,
        tabOrder: tmpContent[i].tabOrder,
        varName: '',
        content: tmpContent[i].content!,
        defaultValue: '',
        varcontent: [],
        barcodeName: '--',
        barcodeType: '',
        hralignment: 'Bottom',
        x2Pos: 0,
        y2Pos: 0,
        lineWidth: 0,
        qrWidth: '3',
        qrcodeName: '--',
        qrcodeType: '',
        fontBold: tmpContent[i].fontBold!,
        fontReverse: tmpContent[i].fontReverse!,
      );
      textInfoList.add(formData);
    } else if (tmpContent[i].type == 'DATA') {
      String varName = varInScaleMap[tmpContent[i].varName!]!;
      String contentTmp = getShowVarName(varName, tmpContent[i].maxLength!);
      FromateItemData formData = FromateItemData(
        type: tmpContent[i].type,
        xPos: tmpContent[i].xPos!,
        yPos: tmpContent[i].yPos!,
        width: tmpContent[i].width!,
        height: tmpContent[i].height!,
        fontSize: tmpContent[i].fontSize!,
        fontWidthRatio: tmpContent[i].fontWidthRatio!,
        fontHeightRatio: tmpContent[i].fontHeightRatio!,
        alignment: tmpContent[i].alignment!,
        maxLength: tmpContent[i].maxLength!,
        rotation: tmpContent[i].rotation!,
        style: 0,
        tabOrder: tmpContent[i].tabOrder,
        varName: varName,
        content: contentTmp,
        defaultValue: tmpContent[i].defaultValue!,
        varcontent: [],
        barcodeName: '--',
        barcodeType: '',
        hralignment: 'Bottom',
        x2Pos: 0,
        y2Pos: 0,
        lineWidth: 0,
        qrWidth: '3',
        qrcodeName: '--',
        qrcodeType: '',
        fontBold: tmpContent[i].fontBold!,
        fontReverse: tmpContent[i].fontReverse!,
      );
      textInfoList.add(formData);
    } else if (tmpContent[i].type == 'Line') {
      double width = 0;
      double height = 0;
      if (tmpContent[i].rotation == 90 || tmpContent[i].rotation == 270) {
        width = tmpContent[i].lineWidth!;
        height = (tmpContent[i].y2Pos! - tmpContent[i].yPos!).abs().toDouble();
      } else if (tmpContent[i].xPos == tmpContent[i].x2Pos) {
        height = (tmpContent[i].y2Pos! - tmpContent[i].yPos!).abs().toDouble();
        width = tmpContent[i].lineWidth!;
      } else if (tmpContent[i].y2Pos == tmpContent[i].yPos) {
        height = tmpContent[i].lineWidth!;
        width = (tmpContent[i].x2Pos! - tmpContent[i].xPos!).abs().toDouble();
      }

      FromateItemData formData = FromateItemData(
        type: tmpContent[i].type,
        xPos: tmpContent[i].xPos!,
        yPos: tmpContent[i].yPos!,
        width: width,
        height: height,
        fontSize: 23,
        fontWidthRatio: 1,
        fontHeightRatio: 1,
        alignment: 0,
        maxLength: 0,
        rotation: 0,
        style: 0,
        tabOrder: tmpContent[i].tabOrder,
        varName: '',
        content: '',
        defaultValue: '',
        varcontent: [],
        barcodeName: '--',
        barcodeType: '',
        hralignment: 'Bottom',
        x2Pos: 0,
        y2Pos: 0,
        lineWidth: tmpContent[i].lineWidth!,
        qrWidth: '3',
        qrcodeName: '--',
        qrcodeType: '',
        fontBold: 'false',
        fontReverse: 'false',
      );
      textInfoList.add(formData);
    } else if (tmpContent[i].type == 'IMG') {
      if (tmpContent[i].content! != "image") {
        if (!isImagePath(tmpContent[i].content!)) {
          tmpContent[i].content = "image";
        }
      }
      FromateItemData formData = FromateItemData(
        type: tmpContent[i].type,
        xPos: tmpContent[i].xPos!,
        yPos: tmpContent[i].yPos!,
        width: tmpContent[i].width!,
        height: tmpContent[i].height!,
        fontSize: 23,
        fontWidthRatio: 1,
        fontHeightRatio: 1,
        alignment: 0,
        maxLength: 0,
        rotation: tmpContent[i].rotation!,
        style: 0,
        tabOrder: tmpContent[i].tabOrder,
        varName: tmpContent[i].varName ?? "", //为图片增加变量名字  1013
        content: tmpContent[i].content!,
        defaultValue: tmpContent[i].defaultValue!,
        varcontent: [],
        barcodeName: '--',
        barcodeType: '',
        hralignment: 'Bottom',
        x2Pos: 0,
        y2Pos: 0,
        lineWidth: 0,
        qrWidth: '3',
        qrcodeName: '--',
        qrcodeType: '',
        fontBold: 'false',
        fontReverse: 'false',
      );
      textInfoList.add(formData);
    } else if (tmpContent[i].type == 'BarCode') {
      List<Varcontent> contentList = [];
      if (tmpContent[i].varcontent != []) {
        List<Varcontent>? tempList = tmpContent[i].varcontent;
        for (var j = 0; j < (tempList!).length; j++) {
          if (tempList[j].type == 'TEXT') {
            Varcontent temp = Varcontent(
                type: tempList[j].type,
                content: tempList[j].content,
                defaultvalue: '',
                alignment: '',
                maxlength: 0);
            contentList.add(temp);
          } else if (tempList[j].type != 'TEXT') {
            Varcontent temp = Varcontent(
                type: varInScaleMap[tempList[j].type]!,
                content: '',
                defaultvalue: tempList[j].defaultvalue,
                alignment: tempList[j].alignment,
                maxlength: tempList[j].maxlength);
            contentList.add(temp);
          }
        }
      }

      FromateItemData formData = FromateItemData(
        type: tmpContent[i].type,
        xPos: tmpContent[i].xPos!,
        yPos: tmpContent[i].yPos!,
        width: tmpContent[i].width!,
        height: tmpContent[i].height!,
        fontSize: 23,
        fontWidthRatio: 1,
        fontHeightRatio: 1,
        alignment: 0,
        maxLength: 0,
        rotation: tmpContent[i].rotation!,
        style: tmpContent[i].style!,
        tabOrder: tmpContent[i].tabOrder,
        varName: '',
        content: tmpContent[i].content!,
        defaultValue: '',
        varcontent: contentList,
        barcodeName: tmpContent[i].barcodeName!,
        barcodeType: tmpContent[i].barcodeType!,
        hralignment: tmpContent[i].hralignment!,
        x2Pos: 0,
        y2Pos: 0,
        lineWidth: tmpContent[i].lineWidth!,
        qrWidth: '3',
        qrcodeName: '--',
        qrcodeType: '',
        fontBold: 'false',
        fontReverse: 'false',
      );
      textInfoList.add(formData);
    } else if (tmpContent[i].type == 'Qrcode') {
      List<Varcontent> contentList = [];
      if (tmpContent[i].varcontent != []) {
        List<Varcontent>? tempList = tmpContent[i].varcontent;
        for (var j = 0; j < (tempList!).length; j++) {
          if (tempList[j].type == 'TEXT') {
            Varcontent temp = Varcontent(
                type: tempList[j].type,
                content: tempList[j].content,
                defaultvalue: '',
                alignment: '',
                maxlength: 0);
            contentList.add(temp);
          } else if (tempList[j].type != 'TEXT') {
            Varcontent temp = Varcontent(
                type: varInScaleMap[tempList[j].type]!,
                content: '',
                defaultvalue: tempList[j].defaultvalue,
                alignment: tempList[j].alignment,
                maxlength: tempList[j].maxlength);
            contentList.add(temp);
          }
        }
      }

      FromateItemData formData = FromateItemData(
        type: tmpContent[i].type,
        xPos: tmpContent[i].xPos!,
        yPos: tmpContent[i].yPos!,
        width: int.tryParse(tmpContent[i].qrWidth!)! * 21,
        height: int.tryParse(tmpContent[i].qrWidth!)! * 21,
        fontSize: 23,
        fontWidthRatio: 1,
        fontHeightRatio: 1,
        alignment: 0,
        maxLength: 0,
        rotation: 0,
        style: 0,
        tabOrder: tmpContent[i].tabOrder,
        varName: '',
        content: tmpContent[i].content!,
        defaultValue: '',
        varcontent: contentList,
        barcodeName: '--',
        barcodeType: '',
        hralignment: 'Bottom',
        x2Pos: 0,
        y2Pos: 0,
        lineWidth: tmpContent[i].lineWidth!,
        qrWidth: tmpContent[i].qrWidth!,
        qrcodeName: tmpContent[i].qrcodeName!,
        qrcodeType: tmpContent[i].qrcodeType!,
        fontBold: 'false',
        fontReverse: 'false',
      );
      textInfoList.add(formData);
    }
  }

  return textInfoList;
}
