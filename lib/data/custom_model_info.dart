// 自定义机种信息

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

List<ModelNameInfo> modelNameInfoFromJson(String str) =>
    List<ModelNameInfo>.from(
        json.decode(str).map((x) => ModelNameInfo.fromJson(x)));

String modelNameInfoToJson(List<ModelNameInfo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ModelNameInfo {
  String? category;
  String? customScaleName;
  String? innerScaleName;
  List<SubModel>? subModel;
  String? remark;

  ModelNameInfo({
    this.category,
    this.customScaleName,
    this.innerScaleName,
    this.subModel,
    this.remark,
  });

  ModelNameInfo copyWith({
    String? category,
    String? customScaleName,
    String? innerScaleName,
    List<SubModel>? subModel,
    String? remark,
  }) =>
      ModelNameInfo(
        category: category ?? this.category,
        customScaleName: customScaleName ?? this.customScaleName,
        innerScaleName: innerScaleName ?? this.innerScaleName,
        subModel: subModel ?? this.subModel,
        remark: remark ?? this.remark,
      );

  factory ModelNameInfo.fromJson(Map<String, dynamic> json) => ModelNameInfo(
        category: json["Category"],
        customScaleName: json["CustomScaleName"],
        innerScaleName: json["InnerScaleName"],
        subModel: json["SubModel"] == null
            ? []
            : List<SubModel>.from(
                json["SubModel"]!.map((x) => SubModel.fromJson(x))),
        remark: json["Remark"],
      );

  Map<String, dynamic> toJson() => {
        "Category": category,
        "CustomScaleName": customScaleName,
        "InnerScaleName": innerScaleName,
        "SubModel": subModel == null
            ? []
            : List<dynamic>.from(subModel!.map((x) => x.toJson())),
        "Remark": remark,
      };
}

class SubModel {
  String? modelName;
  String? protocolName;

  SubModel({
    this.modelName,
    this.protocolName,
  });

  SubModel copyWith({
    String? modelName,
    String? protocolName,
  }) =>
      SubModel(
        modelName: modelName ?? this.modelName,
        protocolName: protocolName ?? this.protocolName,
      );

  factory SubModel.fromJson(Map<String, dynamic> json) => SubModel(
        modelName: json["ModelName"],
        protocolName: json["ProtocolName"],
      );

  Map<String, dynamic> toJson() => {
        "ModelName": modelName,
        "ProtocolName": protocolName,
      };
}

//

class ModelNameInfoList {
  List<ModelNameInfo> modelNameInfoList = [];

  ModelNameInfoList(this.modelNameInfoList);

  Future<String> getModelStrFromJson() async {
    try {
      // 1. 获取 exe 所在同级目录
      String exePath = Platform.resolvedExecutable;
      String dirPath = File(exePath).parent.path;
      File jsonFile = File('$dirPath${Platform.pathSeparator}custom_model_name.json');

      // 2. 如果存在，直接读取并返回
      if (jsonFile.existsSync()) {
        return await jsonFile.readAsString();
      }

      // 3. 如果不存在，从 assets 读取 CSV 解析
      String csvData = await rootBundle.loadString('assets/template/scp.csv');
      String generatedJson = _parseCsvToJson(csvData);

      // 4. 将生成的 JSON 写入到 exe 同级目录
      await jsonFile.writeAsString(generatedJson);

      return generatedJson;
    } catch (e) {
      print("getModelStrFromJson error: $e");
      return "";
    }
  }

  String _parseCsvToJson(String csvData) {
    List<String> lines = csvData.split('\n');
    Map<String, Map<String, dynamic>> modelMap = {};

    // 跳过表头，按行解析
    for (int i = 1; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;

      List<String> columns = lines[i].split(',');
      if (columns.length >= 3) {
        String customer = columns[0].trim();
        String inner = columns[1].trim();
        String scpStr = columns[2].trim();

        String mapKey = '${customer}_$inner';

        // 简单大类推断
        String category = "Weighing Scale";
        if (customer.contains("C")) {
          category = "Counting Scale";
        } else if (customer.contains("P")) {
          category = "Pricing Scale";
        }

        if (!modelMap.containsKey(mapKey)) {
          modelMap[mapKey] = {
            "Category": category,
            "CustomScaleName": customer,
            "InnerScaleName": inner,
            "SubModel": [],
            "Remark": ""
          };
        }

        // 分割协议 (SCP-01/SCP-02)
        List<String> protocols = scpStr
            .split('/')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        // 将协议去重追加到 SubModel
        List currentSubModels = modelMap[mapKey]!["SubModel"];
        for (var p in protocols) {
          bool exists = currentSubModels
              .any((element) => element["ProtocolName"] == p);
          if (!exists) {
            currentSubModels.add({
              "ModelName": "",
              "ProtocolName": p
            });
          }
        }
      }
    }

    // 转换为 List 并输出 JSON 字符串，带有缩进以提高可读性
    List<Map<String, dynamic>> resultList = modelMap.values.toList();
    return JsonEncoder.withIndent('  ').convert(resultList);
  }


  getModelName() async {
    String modelStr = "";
    try {
      modelStr = await getModelStrFromJson();
      // print(modelStr);
      if (modelStr.isEmpty) {
        modelStr = defaultModelString;
      }
      modelNameInfoList = modelNameInfoFromJson(modelStr);
      // print(modelNameInfoList);
    } catch (e) {
      modelNameInfoList = modelNameInfoFromJson(defaultModelString);
    }
  }

  String defaultModelString = """[
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "AHW",
        "InnerScaleName": "AHW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "ATW",
        "InnerScaleName": "ATW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-02"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "QHW",
        "InnerScaleName": "QHW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-03"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "JW",
        "InnerScaleName": "JW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-04"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "JWP",
        "InnerScaleName": "JWP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-05"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "ZHW-2",
        "InnerScaleName": "ZHW-2",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-06"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "UTW-2",
        "InnerScaleName": "UTW-2",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-06"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "ROW",
        "InnerScaleName": "ROW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-07"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "PRW",
        "InnerScaleName": "PRW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-08"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "PRWS",
        "InnerScaleName": "PRWS",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "FOX",
        "InnerScaleName": "FOX",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "AW20",
        "InnerScaleName": "AW20",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-09"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "AA7",
        "InnerScaleName": "AA7",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "PCA10",
        "InnerScaleName": "PCA10",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Weighing Scale",
        "CustomScaleName": "XD",
        "InnerScaleName": "XD",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-X"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Counting Scale",
        "CustomScaleName": "AHC",
        "InnerScaleName": "AHC",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-10"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Counting Scale",
        "CustomScaleName": "QHC",
        "InnerScaleName": "QHC",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Counting Scale",
        "CustomScaleName": "QHD",
        "InnerScaleName": "QHD",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Counting Scale",
        "CustomScaleName": "ATC",
        "InnerScaleName": "ATC",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Counting Scale",
        "CustomScaleName": "QCC",
        "InnerScaleName": "QCC",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Counting Scale",
        "CustomScaleName": "JC",
        "InnerScaleName": "JC",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Counting Scale",
        "CustomScaleName": "JCD",
        "InnerScaleName": "JCD",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Counting Scale",
        "CustomScaleName": "ZHC",
        "InnerScaleName": "ZHC",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-11"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Counting Scale",
        "CustomScaleName": "ZCC",
        "InnerScaleName": "ZCC",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Counting Scale",
        "CustomScaleName": "UTC",
        "InnerScaleName": "UTC",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-12"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "ATP",
        "InnerScaleName": "ATP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "ASP",
        "InnerScaleName": "ASP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "AHP",
        "InnerScaleName": "AHP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "ASUP",
        "InnerScaleName": "ASUP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "QTP",
        "InnerScaleName": "QTP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "QSP",
        "InnerScaleName": "QSP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "JP",
        "InnerScaleName": "JP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "JSP",
        "InnerScaleName": "JSP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "JSUP",
        "InnerScaleName": "JSUP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "JPP",
        "InnerScaleName": "JPP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "JPP-N",
        "InnerScaleName": "JPP-N",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "ZTP",
        "InnerScaleName": "ZTP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-12"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "ZSP",
        "InnerScaleName": "ZSP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-12"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "UTP",
        "InnerScaleName": "UTP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-12"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "USP",
        "InnerScaleName": "USP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-12"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "WTP",
        "InnerScaleName": "WTP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-12"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "WSP",
        "InnerScaleName": "WSP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-12"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "APP",
        "InnerScaleName": "APP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-X"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "LPP",
        "InnerScaleName": "LPP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-X"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Pricing Scale",
        "CustomScaleName": "XP",
        "InnerScaleName": "XP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-X"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "RW",
        "InnerScaleName": "RW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-13"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "RWP",
        "InnerScaleName": "RWP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-13"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "RWS",
        "InnerScaleName": "RWS",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-13"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "BW",
        "InnerScaleName": "BW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-03"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "BWS",
        "InnerScaleName": "BWS",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-03"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "CW",
        "InnerScaleName": "CW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-03"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "CWS",
        "InnerScaleName": "CWS",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-03"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "NTW",
        "InnerScaleName": "NTW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-03"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "NSW",
        "InnerScaleName": "NSW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-03"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "VW",
        "InnerScaleName": "VW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-03"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "VC",
        "InnerScaleName": "VC",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "KW",
        "InnerScaleName": "KW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "KP",
        "InnerScaleName": "KP",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "KC",
        "InnerScaleName": "KC",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "EW",
        "InnerScaleName": "EW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "ELW",
        "InnerScaleName": "ELW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "T2000A",
        "InnerScaleName": "T2000A",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "T2200P",
        "InnerScaleName": "T2200P",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "VW-L",
        "InnerScaleName": "VW-L",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-15"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "VW-LC",
        "InnerScaleName": "VW-LC",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "HW",
        "InnerScaleName": "HW",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "HWS",
        "InnerScaleName": "HWS",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Instrument",
        "CustomScaleName": "PDS",
        "InnerScaleName": "PDS",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-14"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Balance Scale",
        "CustomScaleName": "TB",
        "InnerScaleName": "TB",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Balance Scale",
        "CustomScaleName": "THB",
        "InnerScaleName": "THB",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Balance Scale",
        "CustomScaleName": "NHB",
        "InnerScaleName": "NHB",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-16"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Balance Scale",
        "CustomScaleName": "EHB",
        "InnerScaleName": "EHB",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-16"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Balance Scale",
        "CustomScaleName": "IHB",
        "InnerScaleName": "IHB",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-16"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Balance Scale",
        "CustomScaleName": "NHB24",
        "InnerScaleName": "NHB24",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-17"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Balance Scale",
        "CustomScaleName": "EHB24",
        "InnerScaleName": "EHB24",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-17"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Balance Scale",
        "CustomScaleName": "IHB24",
        "InnerScaleName": "IHB24",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-17"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Balance Scale",
        "CustomScaleName": "QHW24",
        "InnerScaleName": "QHW24",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-17"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Balance Scale",
        "CustomScaleName": "DHB",
        "InnerScaleName": "DHB",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-18"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Balance Scale",
        "CustomScaleName": "TB-L",
        "InnerScaleName": "TB-L",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-19"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Medical Scale",
        "CustomScaleName": "M101",
        "InnerScaleName": "M101",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Medical Scale",
        "CustomScaleName": "M105",
        "InnerScaleName": "M105",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Medical Scale",
        "CustomScaleName": "M301",
        "InnerScaleName": "M301",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Medical Scale",
        "CustomScaleName": "M307",
        "InnerScaleName": "M307",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Medical Scale",
        "CustomScaleName": "M302",
        "InnerScaleName": "M302",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Medical Scale",
        "CustomScaleName": "M303",
        "InnerScaleName": "M303",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Medical Scale",
        "CustomScaleName": "M501",
        "InnerScaleName": "M501",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Medical Scale",
        "CustomScaleName": "M503",
        "InnerScaleName": "M503",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Medical Scale",
        "CustomScaleName": "M701",
        "InnerScaleName": "M701",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Medical Scale",
        "CustomScaleName": "M531",
        "InnerScaleName": "M531",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    },
    {
        "Category": "Medical Scale",
        "CustomScaleName": "M533",
        "InnerScaleName": "M533",
        "SubModel": [
            {
                "ModelName": "",
                "ProtocolName": "SCP-01"
            }
        ],
        "Remark": ""
    }
]""";
}
