import '../common/web_socket_mgr.dart';
import 'comscaleinfo_data.dart';
import 'scale_info_from_db.dart';

final manager = WebSocketScaleManager();
List<int> webChannelList = [];
String ipAddress = "127.0.0.1";
int webPort = 7878;

class GetUrl {
  static String getUrl(int scaleId) {
    String url = "ws://$ipAddress:$webPort/tmax?scaleid=$scaleId";

    return url;
  }
}

class DefScaleInfo {
  int? defScaleId;
  String? defScaleModel;
  String? defScaleSn;
  String? defScaleName;
  String? defScalePort;
  String? defScaleIp;
  String? defScaleBaud;

  DefScaleInfo(this.defScaleId);

  static void getDefScaleInfo(int scaleId) {
    if (scaleId == 1) {
      myDefScaleInfo.defScaleId = scaleId;
      myDefScaleInfo.defScaleModel = myComScaleInfo.scaleModel;
      myDefScaleInfo.defScaleSn = myComScaleInfo.scaleSn;
      myDefScaleInfo.defScalePort = myComScaleInfo.portName;
      myDefScaleInfo.defScaleBaud = myComScaleInfo.baudRate.toString();
      myDefScaleInfo.defScaleName = myComScaleInfo.scaleName;
      return;
    }

    // 先在 myAllScalesList 中查找
    for (var scale in myAllScalesList) {
      if (scale.scaleId == scaleId) {
        myDefScaleInfo.defScaleId = scaleId;
        myDefScaleInfo.defScaleModel = scale.scaleModel;
        myDefScaleInfo.defScaleSn = scale.scaleSn;
        myDefScaleInfo.defScaleName = scale.scaleName;
        if (scale.mediaConfig is NetworkMediaConfig) {
          var netConfig = scale.mediaConfig as NetworkMediaConfig;
          myDefScaleInfo.defScaleIp = netConfig.ipAddress;
          myDefScaleInfo.defScalePort = netConfig.port.toString();
        } else if (scale.mediaConfig is SerialMediaConfig) {
          var serialConfig = scale.mediaConfig as SerialMediaConfig;
          myDefScaleInfo.defScalePort = serialConfig.devPath;
          myDefScaleInfo.defScaleBaud = serialConfig.baudRate.toString();
        }
        return;
      }
    }

    // 备用：从 myNetScaleList 查找（带空安全保护）
    myDefScaleInfo.defScaleId = scaleId;
    var tempscale = NetScaleListMgr.findScaleInfo(myNetScaleList, scaleId);
    myDefScaleInfo.defScaleModel = tempscale.scaleModel ?? "";
    myDefScaleInfo.defScaleSn = tempscale.scaleSn ?? "";
    myDefScaleInfo.defScalePort =
        tempscale.port != null ? tempscale.port.toString() : "";
    myDefScaleInfo.defScaleIp = tempscale.ip ?? "";
    myDefScaleInfo.defScaleName = tempscale.scaleName ?? "";
  }

  static DefScaleInfo getScaleInfoById(int scaleId) {
    DefScaleInfo tempScaleInfo = DefScaleInfo(1);
    if (scaleId == 1) {
      tempScaleInfo.defScaleId = scaleId;
      tempScaleInfo.defScaleModel = myComScaleInfo.scaleModel;
      tempScaleInfo.defScaleSn = myComScaleInfo.scaleSn;
      tempScaleInfo.defScalePort = myComScaleInfo.portName;
      tempScaleInfo.defScaleBaud = myComScaleInfo.baudRate.toString();
      tempScaleInfo.defScaleName = myComScaleInfo.scaleName;
      return tempScaleInfo;
    }

    for (var scale in myAllScalesList) {
      if (scale.scaleId == scaleId) {
        tempScaleInfo.defScaleId = scaleId;
        tempScaleInfo.defScaleModel = scale.scaleModel;
        tempScaleInfo.defScaleSn = scale.scaleSn;
        tempScaleInfo.defScaleName = scale.scaleName;
        if (scale.mediaConfig is NetworkMediaConfig) {
          var netConfig = scale.mediaConfig as NetworkMediaConfig;
          tempScaleInfo.defScaleIp = netConfig.ipAddress;
          tempScaleInfo.defScalePort = netConfig.port.toString();
        } else if (scale.mediaConfig is SerialMediaConfig) {
          var serialConfig = scale.mediaConfig as SerialMediaConfig;
          tempScaleInfo.defScalePort = serialConfig.devPath;
          tempScaleInfo.defScaleBaud = serialConfig.baudRate.toString();
        }
        return tempScaleInfo;
      }
    }

    tempScaleInfo.defScaleId = scaleId;
    var tempscale = NetScaleListMgr.findScaleInfo(myNetScaleList, scaleId);
    tempScaleInfo.defScaleModel = tempscale.scaleModel ?? "";
    tempScaleInfo.defScaleSn = tempscale.scaleSn ?? "";
    tempScaleInfo.defScalePort =
        tempscale.port != null ? tempscale.port.toString() : "";
    tempScaleInfo.defScaleIp = tempscale.ip ?? "";
    tempScaleInfo.defScaleName = tempscale.scaleName ?? "";
    return tempScaleInfo;
  }
}

DefScaleInfo myDefScaleInfo = DefScaleInfo(1);
