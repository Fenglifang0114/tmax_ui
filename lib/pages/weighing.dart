import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/received_wgt_value.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/data/s15_tare_zero.dart';
import 'package:t_max/data/sel_scales_in_app.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';
import 'package:t_max/widget/scale_list.dart';
import 'package:t_max/widget/wgt_value_widget.dart';
import '../../eventbus/eventbus.dart';
import '../../functions/methods.dart';
import '../data/downloadresponse.dart';
import '../data/language.dart';
import '../widget/page_head.dart';

class WeightModePage extends StatefulWidget {
  final Function(String) onNavigate;
  final String lastRouteName;
  const WeightModePage(
      {super.key, required this.onNavigate, required this.lastRouteName});
  @override
  State<WeightModePage> createState() => WeightModePageState();
}

class WeightModePageState extends State<WeightModePage> {
  List<int> mySelScaleIdList = [];

  Map<int, ReceiveWgtInfo> myScaleWgtMap = {};
  bool isFirstLoad = true;

  dynamic eventBus5;
  dynamic eventBus6;

  // 添加定时器变量
  Timer? _scaleCheckTimer;

  @override
  void initState() {
    super.initState();
    // 初始化定时器，每隔10秒执行一次检查
    _scaleCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkSameScale();
    });

    // 初始加载时立即检查一次
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkSameScale();
    });

    eventBus5 = eventBus.on<EventRegWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {
        } else {}
      }
    });

    eventBus6 = eventBus.on<EventUnregWeightResp>().listen((event) {
      if (mounted) {
        myRespDataFromScale = event.obj;
        if (myRespDataFromScale.msgBody.contains('ok')) {}
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isFirstLoad) {
      getSelScaleInApp();
      isFirstLoad = false;
    }
  }

  @override
  void dispose() {
    setSelScaleInApp();
    eventBus5.cancel();
    eventBus6.cancel();
    _scaleCheckTimer?.cancel();

    for (var item in mySelScaleIdList) {
      PublicFunctions.stopWeight(item);
    }

    super.dispose();
  }

  setSelScaleInApp() async {
    await AppSelScalesManager.setIntList(AppNames.weighing, mySelScaleIdList);
  }

  getSelScaleInApp() async {
    List<int> savedScales =
        await AppSelScalesManager.getIntList(AppNames.weighing);
    for (var item in myAllScalesList) {
      if (savedScales.contains(item.scaleId)) {
        addOrRemoveSelScale(item.scaleId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
          width: width,
          decoration:
              BoxDecoration(color: Theme.of(context).colorScheme.surface),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                pageHeadInfo(
                    context,
                    width - headWidthPadding,
                    localizedStrings.menuWeighing,
                    localizedStrings.gTipWeighingPageHelp, () {
                  formAppSetting = false;
                  Future.delayed(Duration.zero, () {
                    widget.onNavigate(widget.lastRouteName);
                  });
                }),
                Container(
                  height: regularPadding,
                  color: Theme.of(context).colorScheme.surfaceDim,
                ),
                Expanded(
                    child: Container(
                  color: Theme.of(context).colorScheme.surfaceTint,
                  child: Row(
                    children: [
                      Container(
                        width: scaleListWidth,
                        color: Theme.of(context).colorScheme.surfaceTint,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                height: btnHeight,
                                padding:
                                    const EdgeInsets.only(left: regularPadding),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  localizedStrings.gTitleDeviceList,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: NewMutiScaleListWidget(
                                  listWidth: scaleListWidth, // 列表宽度
                                  selScaleList: mySelScaleIdList,
                                  clickScale: (scale) {
                                    setState(() {
                                      addOrRemoveSelScale(scale.scaleId);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: firstLayout(context),
                      ),
                    ],
                  ),
                )),
              ])),
    );
  }

  void checkSameScale() {
    if (mySelScaleIdList.length > 1) {
      Map<int, dynamic> scaleMap = {};
      for (var scale in myAllScalesList) {
        scaleMap[scale.scaleId] = scale;
      }

      // 根据物理设备（型号 + 序列号）对选中的秤进行分组
      Map<String, List<Scale>> groups = {};
      for (var scaleId in mySelScaleIdList) {
        var scale = scaleMap[scaleId];
        if (scale != null) {
          String key = "${scale.scaleModel}_${scale.scaleSn}";
          groups.putIfAbsent(key, () => []).add(scale);
        }
      }

      for (var group in groups.values) {
        if (group.length > 1) {
          bool hasSerial = group.any((s) => s.tMedia == 0);
          bool hasNetOrBt = group.any((s) => s.tMedia == 1 || s.tMedia == 2);

          if (hasSerial && hasNetOrBt) {
            // 冲突：同一个物理设备选择了串口和网络/蓝牙的连接方式
            showTipInfo(localizedStrings.tipSameScale, context);

            // 优先级：串口(0) > 网口(1) > 蓝牙(2)。排序并保留最高优先级的连接。
            group.sort((a, b) => a.tMedia.compareTo(b.tMedia));

            // 移除除第一个（优先级最高）之外的所有连接
            for (int i = 1; i < group.length; i++) {
              if (mySelScaleIdList.contains(group[i].scaleId)) {
                addOrRemoveSelScale(group[i].scaleId);
              }
            }
            break; // 每个检查周期只显示一次提示
          }
        }
      }
    }
  }

  void addOrRemoveSelScale(int scaleId) {
    if (mySelScaleIdList.contains(scaleId)) {
      mySelScaleIdList.remove(scaleId);
      PublicFunctions.stopWeight(scaleId);
    } else {
      mySelScaleIdList.add(scaleId);
      PublicFunctions.getWeight(scaleId);
    }
    setSelScaleInApp();
    setState(() {}); // 强制刷新界面
    checkSameScale();
  }

  String getScaleName(int scaleId) {
    String scaleName = "";
    for (var item in myAllScalesList) {
      if (item.scaleId == scaleId) {
        scaleName = item.scaleName;
        return scaleName;
      }
    }

    return scaleName;
  }

  bool getIsS15(int scaleId) {
    for (var item in myAllScalesList) {
      if (item.scaleId == scaleId) {
        return isS15Model(item.scaleModel);
      }
    }

    return false;
  }

  Widget firstLayout(context) {
    return Container(
      padding:
          const EdgeInsets.only(left: regularPadding, bottom: regularPadding),
      color: Theme.of(context).colorScheme.surfaceDim,
      child: ListView.builder(
        itemCount: mySelScaleIdList.length,
        itemBuilder: (context, index) {
          final scaleId = mySelScaleIdList[index];
          return ScaleItemWidget(
            key: ValueKey(scaleId),
            scaleId: scaleId,
            scaleName: getScaleName(scaleId),
            isS15: getIsS15(scaleId),
            isOpenUnstableTareOrZero: unstableZeroTare, //此处需要修改为从数据库获取
          );
        },
      ),
    );
  }
}
