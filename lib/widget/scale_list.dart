// 共用的秤列表 widget
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_max/data/comscaleinfo_data.dart';
import 'package:t_max/data/home_page_common_data.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/data/scale_info_from_db.dart';
import 'package:t_max/eventbus/eventbus.dart';
import 'package:t_max/widget/no_device_widget.dart';

// 封装成 StatefulWidget
class ScaleListWidget extends StatefulWidget {
  final double listWidth;
  final List<NetScaleInfoLocal> scaleNetItems;
  final int selScaleId;
  final Function()? clickComScale;
  final Function(NetScaleInfoLocal) clickNetScale;

  const ScaleListWidget({
    super.key,
    required this.listWidth,
    required this.scaleNetItems,
    required this.selScaleId,
    this.clickComScale,
    required this.clickNetScale,
  });

  @override
  State<ScaleListWidget> createState() => _ScaleListWidgetState();
}

class _ScaleListWidgetState extends State<ScaleListWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: widget.listWidth,
      child: Column(
        children: [
          SizedBox(height: smallPadding),
          showComScale(context, widget.selScaleId, widget.clickComScale),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: ListView.separated(
                itemCount: widget.scaleNetItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final scale = widget.scaleNetItems[index];
                  bool isSelect = (widget.selScaleId == scale.scaleId!);
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => widget.clickNetScale(scale),
                      child: Container(
                        height: scaleItemHeight,
                        color: !isSelect
                            ? Theme.of(context).colorScheme.surfaceContainerLow
                            : Theme.of(context).colorScheme.primary,
                        child: Row(
                          children: [
                            Container(
                              width: scaleItemHeight,
                              height: scaleItemHeight,
                              alignment: Alignment.center,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  color: !isSelect
                                      ? Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerLowest
                                      : Color.fromRGBO(255, 255, 255, 0.1),
                                ),
                                width: scaleInnerItemHeight,
                                height: scaleInnerItemHeight,
                                child: Icon(
                                  size: iconMenuSize,
                                  Icons.wifi,
                                  color: !isSelect
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    scale.scaleName ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .apply(
                                          color: !isSelect
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    scale.isOnline!
                                        ? localizedStrings.gTipOnline
                                        : localizedStrings.gTipOffline,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .apply(
                                          color: isSelect
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                              : scale.isOnline!
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onTertiaryFixedVariant
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

showComScale(BuildContext context, int selScaleId, Function()? onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: scaleItemHeight,
          color: (selScaleId != 1)
              ? Theme.of(context).colorScheme.surfaceContainerLow
              : Theme.of(context).colorScheme.primary,
          child: Row(
            children: [
              Container(
                width: scaleItemHeight,
                height: scaleItemHeight,
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    color: (selScaleId != 1)
                        ? Theme.of(context).colorScheme.surfaceContainerLowest
                        : Color.fromRGBO(255, 255, 255, 0.1),
                  ),
                  width: scaleInnerItemHeight,
                  height: scaleInnerItemHeight,
                  child: Container(
                    alignment: Alignment.center,
                    width: iconMenuSize,
                    height: iconMenuSize,
                    child: getSvgIcon(
                      serialPortSvgIcon(),
                      iconMenuSize,
                      iconMenuSize,
                      (selScaleId != 1)
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      myComScaleInfo.scaleName,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: (selScaleId != 1)
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onPrimary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      myComScaleInfo.isOnline
                          ? localizedStrings.gTipOnline
                          : localizedStrings.gTipOffline,
                      style: TextStyle(
                        color: (selScaleId == 1)
                            ? Theme.of(context).colorScheme.onPrimary
                            : myComScaleInfo.isOnline
                                ? Theme.of(context)
                                    .colorScheme
                                    .onTertiaryFixedVariant
                                : Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// 封装成 StatefulWidget
class ScaleListComWidget extends StatefulWidget {
  final double listWidth;
  final int selScaleId;
  final Function()? clickComScale;

  const ScaleListComWidget({
    super.key,
    required this.listWidth,
    required this.selScaleId,
    this.clickComScale,
  });

  @override
  State<ScaleListComWidget> createState() => _ScaleListComWidgetState();
}

class _ScaleListComWidgetState extends State<ScaleListComWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: widget.listWidth,
      child: Column(
        children: [
          SizedBox(height: smallPadding),
          showComScale(context, widget.selScaleId, widget.clickComScale),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

//多台秤列表
// 封装成 StatefulWidget
class MutiScaleListWidget extends StatefulWidget {
  final double listWidth;
  final List<NetScaleInfoLocal> scaleNetItems;
  final List<int> selScaleList;
  final Function()? clickComScale;
  final Function(NetScaleInfoLocal) clickNetScale;

  const MutiScaleListWidget({
    super.key,
    required this.listWidth,
    required this.scaleNetItems,
    required this.selScaleList,
    this.clickComScale,
    required this.clickNetScale,
  });

  @override
  State<MutiScaleListWidget> createState() => _MutiScaleListWidgetState();
}

class _MutiScaleListWidgetState extends State<MutiScaleListWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: widget.listWidth,
      child: Column(
        children: [
          SizedBox(height: smallPadding),
          showMutiComScale(context, widget.selScaleList, widget.clickComScale),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: ListView.separated(
                itemCount: widget.scaleNetItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final scale = widget.scaleNetItems[index];
                  bool isSelect =
                      (widget.selScaleList.contains(scale.scaleId!));
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => widget.clickNetScale(scale),
                      child: Container(
                        height: scaleItemHeight,
                        color: !isSelect
                            ? Theme.of(context).colorScheme.surfaceContainerLow
                            : Theme.of(context).colorScheme.primary,
                        child: Row(
                          children: [
                            Container(
                              width: scaleItemHeight,
                              height: scaleItemHeight,
                              alignment: Alignment.center,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  color: !isSelect
                                      ? Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerLowest
                                      : Color.fromRGBO(255, 255, 255, 0.1),
                                ),
                                width: scaleInnerItemHeight,
                                height: scaleInnerItemHeight,
                                child: Icon(
                                  size: iconMenuSize,
                                  Icons.wifi,
                                  color: !isSelect
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    scale.scaleName ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .apply(
                                          color: !isSelect
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    scale.isOnline!
                                        ? localizedStrings.gTipOnline
                                        : localizedStrings.gTipOffline,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .apply(
                                          color: isSelect
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                              : scale.isOnline!
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onTertiaryFixedVariant
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

showMutiComScale(
    BuildContext context, List<int> selScaleList, Function()? onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: scaleItemHeight,
          color: (!selScaleList.contains(1))
              ? Theme.of(context).colorScheme.surfaceContainerLow
              : Theme.of(context).colorScheme.primary,
          child: Row(
            children: [
              Container(
                width: scaleItemHeight,
                height: scaleItemHeight,
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    color: (!selScaleList.contains(1))
                        ? Theme.of(context).colorScheme.surfaceContainerLowest
                        : Color.fromRGBO(255, 255, 255, 0.1),
                  ),
                  width: scaleInnerItemHeight,
                  height: scaleInnerItemHeight,
                  child: Container(
                    alignment: Alignment.center,
                    width: iconMenuSize,
                    height: iconMenuSize,
                    child: getSvgIcon(
                      serialPortSvgIcon(),
                      iconMenuSize,
                      iconMenuSize,
                      (!selScaleList.contains(1))
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      myComScaleInfo.scaleName,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: (!selScaleList.contains(1))
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onPrimary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      myComScaleInfo.isOnline
                          ? localizedStrings.gTipOnline
                          : localizedStrings.gTipOffline,
                      style: TextStyle(
                        color: (selScaleList.contains(1))
                            ? Theme.of(context).colorScheme.onPrimary
                            : myComScaleInfo.isOnline
                                ? Theme.of(context)
                                    .colorScheme
                                    .onTertiaryFixedVariant
                                : Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

//下面是多串口增加后的秤列表

// 封装成 StatefulWidget
class NewAllScaleListWidget extends StatefulWidget {
  final double listWidth;
  final int selScaleId;

  final Function(Scale) clickScale;

  const NewAllScaleListWidget({
    super.key,
    required this.listWidth,
    required this.selScaleId,
    required this.clickScale,
  });

  @override
  State<NewAllScaleListWidget> createState() => _NewAllScaleListWidgetState();
}

class _NewAllScaleListWidgetState extends State<NewAllScaleListWidget> {
  StreamSubscription? _eventbusNet;
  StreamSubscription? _eventbusOnline;

  @override
  void initState() {
    super.initState();
    _eventbusNet = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) setState(() {});
    });
    _eventbusOnline = eventBus.on<EventRespScaleOnline>().listen((event) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _eventbusNet?.cancel();
    _eventbusOnline?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: widget.listWidth,
      child: Column(
        children: [
          SizedBox(height: smallPadding),
          myAllScalesList.isEmpty
              ? showNoDeviceWidget(context)
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: ListView.separated(
                      itemCount: myAllScalesList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: smallPadding),
                      itemBuilder: (context, index) {
                        final scale = myAllScalesList[index];
                        bool isSelect = (widget.selScaleId == scale.scaleId);
                        return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                                onTap: () => widget.clickScale(scale),
                                child: Container(
                                  height: scaleItemHeight,
                                  color: !isSelect
                                      ? Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerLow
                                      : scale.isOnline
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context).colorScheme.error,
                                  child: Row(
                                    children: [
                                      Container(
                                          width: scaleItemHeight,
                                          height: scaleItemHeight,
                                          alignment: Alignment.center,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4)),
                                                color: !isSelect
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .surfaceContainerLowest
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .surface
                                                        .withValues(alpha: 0.1),
                                              ),
                                              width: scaleInnerItemHeight,
                                              height: scaleInnerItemHeight,
                                              child: scale.tMedia == 0
                                                  ? Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: iconMenuSize,
                                                      height: iconMenuSize,
                                                      child: getSvgIcon(
                                                          serialPortSvgIcon(),
                                                          iconMenuSize,
                                                          iconMenuSize,
                                                          (!isSelect)
                                                              ? Theme.of(context)
                                                                  .colorScheme
                                                                  .primary
                                                              : Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary))
                                                  : scale.tMedia == 1
                                                      ? Container(
                                                          alignment:
                                                              Alignment.center,
                                                          width: iconMenuSize,
                                                          height: iconMenuSize,
                                                          child: getSvgIcon(
                                                              networkSvgIcon(),
                                                              iconMenuSize,
                                                              iconMenuSize,
                                                              (!isSelect)
                                                                  ? Theme.of(context)
                                                                      .colorScheme
                                                                      .primary
                                                                  : Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onPrimary))
                                                      : Container(
                                                          alignment:
                                                              Alignment.center,
                                                          width: iconMenuSize,
                                                          height: iconMenuSize,
                                                          child: getSvgIcon(
                                                              btSvgIcon(),
                                                              iconMenuSize,
                                                              iconMenuSize,
                                                              (!isSelect)
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                  : Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onPrimary)))),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              scale.scaleName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .apply(
                                                    color: !isSelect
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              scale.isOnline
                                                  ? localizedStrings.gTipOnline
                                                  : localizedStrings
                                                      .gTipOffline,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .apply(
                                                    color: isSelect
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary
                                                        : scale.isOnline
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .onTertiaryFixedVariant
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .error,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )));
                      },
                    ),
                  ),
                )
        ],
      ),
    );
  }
}

//仅仅显示串口的秤
// 封装成 StatefulWidget
class NewComScaleListWidget extends StatefulWidget {
  final double listWidth;
  final int selScaleId;

  final Function(Scale) clickScale;

  const NewComScaleListWidget({
    super.key,
    required this.listWidth,
    required this.selScaleId,
    required this.clickScale,
  });

  @override
  State<NewComScaleListWidget> createState() => _NewComScaleListWidgetState();
}

class _NewComScaleListWidgetState extends State<NewComScaleListWidget> {
  List<Scale> comScalesList = [];
  StreamSubscription? _eventbusNet;
  StreamSubscription? _eventbusOnline;

  @override
  void initState() {
    super.initState();
    _eventbusNet = eventBus.on<EventRespCheckNetScale>().listen((event) {
      if (mounted) setState(() {});
    });
    _eventbusOnline = eventBus.on<EventRespScaleOnline>().listen((event) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _eventbusNet?.cancel();
    _eventbusOnline?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    comScalesList.clear();
    for (var scale in myAllScalesList) {
      if (scale.tMedia == comScaleType) {
        comScalesList.add(scale);
      }
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: widget.listWidth,
      child: Column(
        children: [
          SizedBox(height: smallPadding),
          comScalesList.isEmpty
              ? showNoDeviceWidget(context)
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: ListView.separated(
                      itemCount: comScalesList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: smallPadding),
                      itemBuilder: (context, index) {
                        final scale = comScalesList[index];
                        bool isSelect = (widget.selScaleId == scale.scaleId);
                        return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                                onTap: () => widget.clickScale(scale),
                                child: Container(
                                  height: scaleItemHeight,
                                  color: !isSelect
                                      ? Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerLow
                                      : scale.isOnline
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context).colorScheme.error,
                                  child: Row(
                                    children: [
                                      Container(
                                          width: scaleItemHeight,
                                          height: scaleItemHeight,
                                          alignment: Alignment.center,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4)),
                                              color: !isSelect
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .surfaceContainerLowest
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .surface
                                                      .withValues(alpha: 0.1),
                                            ),
                                            width: scaleInnerItemHeight,
                                            height: scaleInnerItemHeight,
                                            child: scale.tMedia == 0
                                                ? Container(
                                                    alignment: Alignment.center,
                                                    width: iconMenuSize,
                                                    height: iconMenuSize,
                                                    child: getSvgIcon(
                                                        serialPortSvgIcon(),
                                                        iconMenuSize,
                                                        iconMenuSize,
                                                        (!isSelect)
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .onPrimary))
                                                : scale.tMedia == 1
                                                    ? Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: iconMenuSize,
                                                        height: iconMenuSize,
                                                        child: getSvgIcon(
                                                            networkSvgIcon(),
                                                            iconMenuSize,
                                                            iconMenuSize,
                                                            (!isSelect)
                                                                ? Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimary))
                                                    : Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: iconMenuSize,
                                                        height: iconMenuSize,
                                                        child: getSvgIcon(
                                                            btSvgIcon(),
                                                            iconMenuSize,
                                                            iconMenuSize,
                                                            (!isSelect)
                                                                ? Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimary)),
                                          )),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              scale.scaleName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .apply(
                                                    color: !isSelect
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              scale.isOnline
                                                  ? localizedStrings.gTipOnline
                                                  : localizedStrings
                                                      .gTipOffline,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .apply(
                                                    color: isSelect
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary
                                                        : scale.isOnline
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .onTertiaryFixedVariant
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .error,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )));
                      },
                    ),
                  ),
                )
        ],
      ),
    );
  }
}

//  新的可以选择多台秤的列表
// 封装成 StatefulWidget
class NewMutiScaleListWidget extends StatefulWidget {
  final double listWidth;
  final List<int> selScaleList;

  final Function(Scale) clickScale;

  const NewMutiScaleListWidget({
    super.key,
    required this.listWidth,
    required this.selScaleList,
    required this.clickScale,
  });

  @override
  State<NewMutiScaleListWidget> createState() => _NewMutiScaleListWidgetState();
}

class _NewMutiScaleListWidgetState extends State<NewMutiScaleListWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      Duration(milliseconds: 2000),
      (timer) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: widget.listWidth,
      child: Column(
        children: [
          SizedBox(height: smallPadding),
          myAllScalesList.isEmpty
              ? showNoDeviceWidget(context)
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: ListView.separated(
                      itemCount: myAllScalesList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: smallPadding),
                      itemBuilder: (context, index) {
                        final scale = myAllScalesList[index];

                        bool isSelect =
                            (widget.selScaleList.contains(scale.scaleId));
                        return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                                onTap: () => widget.clickScale(scale),
                                child: Container(
                                  height: scaleItemHeight,
                                  color: !isSelect
                                      ? Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerLow
                                      : scale.isOnline
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context).colorScheme.error,
                                  child: Row(
                                    children: [
                                      Container(
                                          width: scaleItemHeight,
                                          height: scaleItemHeight,
                                          alignment: Alignment.center,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4)),
                                              color: !isSelect
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .surfaceContainerLowest
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .surface
                                                      // 使用 withValues 替代 withOpacity
                                                      .withValues(alpha: 0.1),
                                            ),
                                            width: scaleInnerItemHeight,
                                            height: scaleInnerItemHeight,
                                            child: scale.tMedia == 0
                                                ? Container(
                                                    alignment: Alignment.center,
                                                    width: iconMenuSize,
                                                    height: iconMenuSize,
                                                    child: getSvgIcon(
                                                        serialPortSvgIcon(),
                                                        iconMenuSize,
                                                        iconMenuSize,
                                                        (!isSelect)
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .onPrimary))
                                                : scale.tMedia == 1
                                                    ? Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: iconMenuSize,
                                                        height: iconMenuSize,
                                                        child: getSvgIcon(
                                                            networkSvgIcon(),
                                                            iconMenuSize,
                                                            iconMenuSize,
                                                            (!isSelect)
                                                                ? Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimary))
                                                    : Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: iconMenuSize,
                                                        height: iconMenuSize,
                                                        child: getSvgIcon(
                                                            btSvgIcon(),
                                                            iconMenuSize,
                                                            iconMenuSize,
                                                            (!isSelect)
                                                                ? Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimary)),
                                          )),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              scale.scaleName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .apply(
                                                    color: !isSelect
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  scale.isOnline
                                                      ? localizedStrings
                                                          .gTipOnline
                                                      : localizedStrings
                                                          .gTipOffline,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .apply(
                                                        color: isSelect
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .onPrimary
                                                            : scale.isOnline
                                                                ? Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onTertiaryFixedVariant
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .error,
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Checkbox(
                                                  value: widget.selScaleList
                                                      .contains(scale.scaleId),
                                                  side: WidgetStateBorderSide
                                                      .resolveWith(
                                                          (Set<WidgetState>
                                                              states) {
                                                    if (states.contains(
                                                        WidgetState.selected)) {
                                                      return BorderSide(
                                                          color: Colors.white);
                                                    }
                                                    return BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceContainerHighest);
                                                  }),
                                                  fillColor: WidgetStateProperty
                                                      .resolveWith<Color>(
                                                          (Set<WidgetState>
                                                              states) {
                                                    return Colors.transparent;
                                                  }),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                  ),
                                                  onChanged: (bool? value) {
                                                    widget.clickScale(scale);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )));
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

//  新的可以选择多台秤的列表
// 封装成 StatefulWidget
class NewMutiScaleListWifiWidget extends StatefulWidget {
  final double listWidth;
  final List<int> selScaleList;

  final Function(Scale) clickScale;

  const NewMutiScaleListWifiWidget({
    super.key,
    required this.listWidth,
    required this.selScaleList,
    required this.clickScale,
  });

  @override
  State<NewMutiScaleListWifiWidget> createState() =>
      _NewMutiScaleListWifiWidgetState();
}

class _NewMutiScaleListWifiWidgetState
    extends State<NewMutiScaleListWifiWidget> {
  Timer? _timer;

  List<Scale> scaleNetItems = [];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      Duration(milliseconds: 2000),
      (timer) {
        if (mounted) {
          setState(() {});
        }
      },
    );
    for (int i = 0; i < myAllScalesList.length; i++) {
      if (myAllScalesList[i].tMedia == 1) {
        scaleNetItems.add(myAllScalesList[i]);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      width: widget.listWidth,
      child: Column(
        children: [
          SizedBox(height: smallPadding),
          scaleNetItems.isEmpty
              ? showNoDeviceWidget(context)
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: ListView.separated(
                      itemCount: scaleNetItems.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: smallPadding),
                      itemBuilder: (context, index) {
                        final scale = scaleNetItems[index];

                        bool isSelect =
                            (widget.selScaleList.contains(scale.scaleId));
                        return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                                onTap: () => widget.clickScale(scale),
                                child: Container(
                                  height: scaleItemHeight,
                                  color: !isSelect
                                      ? Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerLow
                                      : scale.isOnline
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context).colorScheme.error,
                                  child: Row(
                                    children: [
                                      Container(
                                          width: scaleItemHeight,
                                          height: scaleItemHeight,
                                          alignment: Alignment.center,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4)),
                                              color: !isSelect
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .surfaceContainerLowest
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .surface
                                                      // 使用 withValues 替代 withOpacity
                                                      .withValues(alpha: 0.1),
                                            ),
                                            width: scaleInnerItemHeight,
                                            height: scaleInnerItemHeight,
                                            child: scale.tMedia == 0
                                                ? Container(
                                                    alignment: Alignment.center,
                                                    width: iconMenuSize,
                                                    height: iconMenuSize,
                                                    child: getSvgIcon(
                                                        serialPortSvgIcon(),
                                                        iconMenuSize,
                                                        iconMenuSize,
                                                        (!isSelect)
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .onPrimary))
                                                : scale.tMedia == 1
                                                    ? Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: iconMenuSize,
                                                        height: iconMenuSize,
                                                        child: getSvgIcon(
                                                            networkSvgIcon(),
                                                            iconMenuSize,
                                                            iconMenuSize,
                                                            (!isSelect)
                                                                ? Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimary))
                                                    : Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: iconMenuSize,
                                                        height: iconMenuSize,
                                                        child: getSvgIcon(
                                                            btSvgIcon(),
                                                            iconMenuSize,
                                                            iconMenuSize,
                                                            (!isSelect)
                                                                ? Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimary)),
                                          )),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              scale.scaleName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .apply(
                                                    color: !isSelect
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  scale.isOnline
                                                      ? localizedStrings
                                                          .gTipOnline
                                                      : localizedStrings
                                                          .gTipOffline,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .apply(
                                                        color: isSelect
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .onPrimary
                                                            : scale.isOnline
                                                                ? Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onTertiaryFixedVariant
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .error,
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Checkbox(
                                                  value: widget.selScaleList
                                                      .contains(scale.scaleId),
                                                  side: WidgetStateBorderSide
                                                      .resolveWith(
                                                          (Set<WidgetState>
                                                              states) {
                                                    if (states.contains(
                                                        WidgetState.selected)) {
                                                      return BorderSide(
                                                          color: Colors.white);
                                                    }
                                                    return BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceContainerHighest);
                                                  }),
                                                  fillColor: WidgetStateProperty
                                                      .resolveWith<Color>(
                                                          (Set<WidgetState>
                                                              states) {
                                                    return Colors.transparent;
                                                  }),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.zero,
                                                  ),
                                                  onChanged: (bool? value) {
                                                    widget.clickScale(scale);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )));
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
