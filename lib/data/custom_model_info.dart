// 自定义的机种与协议配置管理

import 'dart:collection';
import 'dart:convert';
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

class ModelNameInfoList {
  List<ModelNameInfo> modelNameInfoList = [];
  bool _isLoaded = false;

  ModelNameInfoList(this.modelNameInfoList);

  /// 核心加载入口：支持内存缓存，避免页面切换/弹窗重复解析 CSV
  Future<void> getModelName({bool forceReload = false}) async {
    // 内存缓存优化：若已解析过且不强制刷，直接返回内存数据（0ms 开销）
    if (_isLoaded && !forceReload && modelNameInfoList.isNotEmpty) {
      return;
    }

    try {
      // 1. 读取 SCP.csv (3列：Customer, Inner, SCP)
      String scpCsvData = await rootBundle.loadString('assets/template/SCP.csv');

      // 2. 读取 ModelCategory.csv (2列：Inner, Category)
      String catCsvData = "";
      try {
        catCsvData = await rootBundle.loadString('assets/template/ModelCategory.csv');
      } catch (_) {
        catCsvData = ""; // 文件缺失时降级处理
      }

      // 3. 内存中解析并生成对象列表
      modelNameInfoList = _parseCsvToModelList(scpCsvData, catCsvData);
      _isLoaded = true;
    } catch (e) {
      print("getModelName 解析异常: $e");
      modelNameInfoList = [];
    }
  }

  /// 内存解析核心算法（鲁棒处理 + 大小写空格容错 + 类别去重 + 智能排序）
  List<ModelNameInfo> _parseCsvToModelList(String scpCsvData, String categoryCsvData) {
    // Step 1: 解析 ModelCategory.csv -> Map<UpperInnerName, Set<Category>>
    // 使用大写+trim键值作为索引做大小写/空格容错，Set自动去重
    Map<String, LinkedHashSet<String>> categoryMap = {};
    
    if (categoryCsvData.trim().isNotEmpty) {
      List<String> catLines = categoryCsvData.replaceAll('\r\n', '\n').split('\n');
      for (int i = 1; i < catLines.length; i++) {
        String line = catLines[i].trim();
        if (line.isEmpty) continue;

        List<String> columns = line.split(',');
        if (columns.length >= 2) {
          String inner = columns[0].trim();
          String category = columns[1].trim();

          if (inner.isNotEmpty && category.isNotEmpty) {
            String lookupKey = inner.toUpperCase(); // 转大写容错
            categoryMap.putIfAbsent(lookupKey, () => LinkedHashSet<String>()).add(category);
          }
        }
      }
    }

    // Step 2: 解析 SCP.csv，按 (客户机种名 + 内部机种名) 唯一 Key 合并协议
    Map<String, ModelNameInfo> mergedModelMap = {};
    List<String> scpLines = scpCsvData.replaceAll('\r\n', '\n').split('\n');

    for (int i = 1; i < scpLines.length; i++) {
      String line = scpLines[i].trim();
      if (line.isEmpty) continue;

      List<String> columns = line.split(',');
      if (columns.length >= 3) {
        String customer = columns[0].trim();
        String inner = columns[1].trim();
        String scpStr = columns[2].trim();

        if (customer.isEmpty || inner.isEmpty) continue;

        // 拼接唯一 Key (客户机种名不同，即为不同记录)
        String mapKey = '${customer}_$inner';

        if (!mergedModelMap.containsKey(mapKey)) {
          mergedModelMap[mapKey] = ModelNameInfo(
            customScaleName: customer,
            innerScaleName: inner,
            subModel: [],
            remark: "",
          );
        }

        // 拆分协议 (如 SCP-01/SCP-02) 并去重追加
        List<String> protocols = scpStr
            .split('/')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        List<SubModel> currentSubModels = mergedModelMap[mapKey]!.subModel!;
        for (var p in protocols) {
          bool exists = currentSubModels.any((element) => element.protocolName == p);
          if (!exists) {
            currentSubModels.add(SubModel(modelName: "", protocolName: p));
          }
        }
      }
    }

    // Step 3: 根据 InnerScaleName 检索分类表，一对多展开
    List<ModelNameInfo> resultList = [];

    mergedModelMap.forEach((key, modelInfo) {
      String inner = modelInfo.innerScaleName ?? "";
      String lookupKey = inner.trim().toUpperCase(); // 检索大写 key
      
      LinkedHashSet<String>? matchedCategories = categoryMap[lookupKey];

      // 未匹配到分类时自动归为 "Other" 英文兜底
      List<String> categoriesToApply = (matchedCategories != null && matchedCategories.isNotEmpty)
          ? matchedCategories.toList()
          : ["Other"];

      // 查到 N 个类别，生成 N 条独立记录
      for (String cat in categoriesToApply) {
        resultList.add(ModelNameInfo(
          category: cat,
          customScaleName: modelInfo.customScaleName,
          innerScaleName: modelInfo.innerScaleName,
          subModel: modelInfo.subModel
              ?.map((e) => SubModel(modelName: e.modelName, protocolName: e.protocolName))
              .toList(),
          remark: modelInfo.remark,
        ));
      }
    });

    return resultList;
  }

  // ==================== UI 辅助便利 API ====================

  /// 获取所有唯一的分类名称列表（按字母排序，且自动将 'Other' 置底）
  List<String> getCategories() {
    Set<String> categories = {};
    bool hasOther = false;

    for (var item in modelNameInfoList) {
      if (item.category != null && item.category!.isNotEmpty) {
        if (item.category == "Other") {
          hasOther = true;
        } else {
          categories.add(item.category!);
        }
      }
    }

    List<String> sortedList = categories.toList()..sort();
    if (hasOther) {
      sortedList.add("Other"); // 保证 Other 始终在最后一位
    }
    return sortedList;
  }

  /// 根据分类名称快速筛选机种列表
  List<ModelNameInfo> getModelsByCategory(String category) {
    return modelNameInfoList.where((e) => e.category == category).toList();
  }
}

