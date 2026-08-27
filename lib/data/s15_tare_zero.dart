import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/functions/methods.dart';

import 'package:t_max/data/g_data.dart';

bool isS15Model(String? modelName) {
  if (modelName == null || modelName.trim().isEmpty) return false;
  String trimmed = modelName.trim();

  // 1. 机种名本身包含 S15
  if (trimmed.toUpperCase().contains("S15")) {
    return true;
  }

  // 2. 通过全局配置表 modelNameInfoData 匹配【内部机种名】
  for (var item in modelNameInfoData.modelNameInfoList) {
    if (item.customScaleName == trimmed || item.innerScaleName == trimmed) {
      if (item.innerScaleName != null &&
          item.innerScaleName!.toUpperCase().contains("S15")) {
        return true;
      }
    }
  }
  return false;
}

bool getIsS15(int scaleId) {
  for (var item in myAllScalesList) {
    if (item.scaleId == scaleId) {
      return isS15Model(item.scaleModel);
    }
  }

  return false;
}

void tareByScaleId(int scaleId) {
  bool isS15 = getIsS15(scaleId);

  if (!isS15) {
    PublicFunctions.performTareWithScaleId(scaleId);
  } else {
    if (unstableZeroTare) {
      //发送不稳定扣重指令
      PublicFunctions.performTareWithScaleIdUnstable(scaleId);
    } else {
      PublicFunctions.performTareWithScaleId(scaleId);
    }
  }
}

void zeroByScaleId(int scaleId) {
  bool isS15 = getIsS15(scaleId);

  if (!isS15) {
    PublicFunctions.performZeroWithScaleId(scaleId);
  } else {
    if (unstableZeroTare) {
      //发送不稳定扣重指令
      PublicFunctions.performZeroWithScaleIdUnstable(scaleId);
    } else {
      PublicFunctions.performZeroWithScaleId(scaleId);
    }
  }
}
