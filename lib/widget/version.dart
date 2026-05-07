import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/company_info.dart';

import '../data/encrypt_data.dart';

String getVersion() {
  return "V1.77";
}

const String companyImage = 'assets/images/company.png';
const String appInfoJson = 'assets/template/app_info.json';

Widget versionInfo(Color? color) {
  return Text(getVersion(),
      style: TextStyle(
        color: color,
        fontSize: 20,
      ),
      textAlign: TextAlign.center);
}

Future openAppJson() async {
  String appInfoData = await rootBundle.loadString(appInfoJson);
  try {
    String decryptData = myFilePassword.decryptCsv(appInfoData);
    Map<String, dynamic> jsonMap = jsonDecode(decryptData);
    myCompanyInfo = CompanyInfo.fromJson(jsonMap);
  } catch (e) {
    if (kDebugMode) {
      print('Failed to parse JSON: $e');
    }
  }
}

//写app_info.json 将json改为字符串，执行下面的函数

// Future openAppJson() async {
//   String appInfoData =
//       await rootBundle.loadString(appInfoJson);
//   String encryptData = myFilePassword.encryptCsv(appInfoData);
//   final file = File(
//       'G:\\T-max\\20230530\\TMaxPcServiceUI\\assets\\template\\app_info.json');
//   await file.writeAsString(encryptData, mode: FileMode.write, encoding: utf8);
//   String decryptData = myFilePassword.decryptCsv(encryptData);
//   // print(decryptData);
//   try {
//     Map<String, dynamic> jsonMap = jsonDecode(decryptData);
//     myCompanyInfo = CompanyInfo.fromJson(jsonMap);
//   } catch (e) {
//     print('Failed to parse JSON: $e');
//   }
// }
