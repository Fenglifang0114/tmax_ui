import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/functions/methods.dart';

bool getIsS15(int scaleId) {
  for (var item in myAllScalesList) {
    if (item.scaleId == scaleId) {
      if (item.scaleModel == "S15") {
        return true;
      } else {
        return false;
      }
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
