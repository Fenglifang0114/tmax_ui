import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';

RawDataInfo getRawData(String rawId) {
  for (var item in rawDataList) {
    if (item.materialId == rawId) {
      return item;
    }
  }
  return rawDataList.first;
}

String getRawCategoryName(String rawId) {
  int categoryId = 0;
  for (var item in rawDataList) {
    if (item.materialId == rawId) {
      categoryId = item.categoryId!;
    }
  }
  for (var item in rawTypeList) {
    if (item.categoryId == categoryId) {
      return item.categoryName;
    }
  }
  return "-";
}

String getRawName(String rawId) {
  if (rawDictCache.containsKey(rawId)) {
    return rawDictCache[rawId]!;
  }
  for (var item in rawDataList) {
    if (item.materialId == rawId) {
      return item.materialName!;
    }
  }
  return "";
}

String getRawCheckCode(String rawId) {
  for (var item in rawDataList) {
    if (item.materialId == rawId) {
      return item.checkCode!;
    }
  }
  return "";
}

String getRawRemark(String rawId) {
  for (var item in rawDataList) {
    if (item.materialId == rawId) {
      return item.ingredient ?? "";
    }
  }
  return "";
}
