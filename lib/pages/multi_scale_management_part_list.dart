// ignore_for_file: invalid_use_of_protected_member
part of 'multi_scale_management_page.dart';

extension MultiScaleManagementListExt on MultiScaleManagementState {
//正常显示
  Widget showNormalScaleInfo(double maxWidth) {
    return Column(children: [
      Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: scaleListWidth,
          color: Theme.of(context).colorScheme.surfaceTint,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: regularPadding,
                ),
                showAddScaleBtn(),
                Expanded(child: showScaleList(scaleListWidth))
              ],
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant, // 蓝色分隔条颜色
              ),
              selScaleId == -1
                  ? SizedBox()
                  : getScaleType() == comScaleType
                      ? showSerialScaleInfo()
                      : getScaleType() == netScaleType
                          ? showNetworkScaleInfo() //网络秤
                          : showBluetoothScaleInfo(), //蓝牙秤
            ],
          ),
        ),
      ]))
    ]);
  }

  Widget showAddScaleBtn() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: regularPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: textColorBtn(
                context,
                Theme.of(context).colorScheme,
                Theme.of(context).textTheme,
                isTesting || isRename || isDel || isComSetting || isAddScale
                    ? null
                    : () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AddScaleDialog();
                          },
                        ).then((value) {
                          if (value != "") {
                            setState(() {
                              addScaleType = value;
                              isAddScale = true;
                              selScaleId = -1;
                              isRename = false;
                              isAddScale = true;
                              ipCtl.text = "";
                              snCtl.text = "";
                              portCtl.text = "";
                              macCtl.text = "";
                              btNameCtl.text = "";
                              comPortCtl.text = "";
                              scaleModelCtl.text = "";
                              scaleNameCtl.text = "";
                              baudRateCtl.text = "";
                              
                              // 自动分配下一个可用的 Modbus 站号
                              int nextModbusId = 1;
                              List<int> usedIds = myAllScalesList.map((s) => s.modbusId ?? 0).toList();
                              while (usedIds.contains(nextModbusId)) {
                                nextModbusId++;
                              }
                              modbusIdCtl.text = nextModbusId.toString();
                            });
                          }
                        });
                      },
                localizedStrings.gBtnAdd,
                btnHeight,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: textColorBtn(
                context,
                Theme.of(context).colorScheme,
                Theme.of(context).textTheme,
                (isAddScale || isTesting) ||
                        isRename ||
                        isDel ||
                        isComSetting ||
                        selScaleId == -1
                    ? null
                    : () {
                        setState(() {
                          isDel = true;
                          delScale();
                        });
                      },
                localizedStrings.gBtnDelete,
                btnHeight,
                Theme.of(context).colorScheme.error,
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ));
  }

  Widget textColorBtn(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    VoidCallback? func,
    String name,
    double height,
    Color backColor,
    Color fontColor,
  ) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: backColor,
          fixedSize: Size(double.infinity, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        onPressed: func,
        child: Text(
          name,
          style: Theme.of(context).textTheme.bodySmall!.apply(
              color: func == null
                  ? colorScheme.surfaceContainerHighest
                  : fontColor),
          overflow: TextOverflow.ellipsis,
        ));
  }

  showScaleList(double listWidth) {
    return AnimatedContainer(
      color: Theme.of(context).colorScheme.surface,
      width: listWidth,
      duration: Duration(milliseconds: 300),
      child: Column(
        children: [
          SizedBox(
            height: regularPadding,
          ),
          SizedBox(
            height: smallPadding,
          ),
          myAllScalesList.isEmpty
              ? Expanded(child: showNoDeviceWidget(context))
              : showAllDevicesWidget(),
          showAutoScanSwitch(),
        ],
      ),
    );
  }

  Widget showAllDevicesWidget() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: ListView.separated(
          itemCount: myAllScalesList.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: smallPadding),
          itemBuilder: (context, index) {
            final scale = myAllScalesList[index];
            bool isSelect = (scale.scaleId == selScaleId);
            return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isRename = false;
                        selScaleId = scale.scaleId;
                        scaleNameCtl.text = scale.scaleName;
                        scaleModelCtl.text = scale.scaleModel;
                        snCtl.text = scale.scaleSn;
                        modbusIdCtl.text = scale.modbusId?.toString() ?? '0';
                        protocolNameCtl.text = scale.protocolName ?? 'SCP-X';
                        // 判断 scaleModel 是否为 TMax，且 sn 是否为 10 位并以 174 开头

                        if (scale.tMedia == comScaleType) {
                          final serialConfig =
                              scale.mediaConfig as SerialMediaConfig;
                          comPortCtl.text = serialConfig.devPath;
                          dataBitCtl.text = serialConfig.dataBits.toString();
                          baudRateCtl.text = serialConfig.baudRate.toString();

                          usingComLists = List<String>.from(comLists);
                          if (comPortCtl.text.isNotEmpty && !usingComLists.contains(comPortCtl.text)) {
                            usingComLists.add(comPortCtl.text);
                          }
                        } else if (scale.tMedia == netScaleType) {
                          final netConfig =
                              scale.mediaConfig as NetworkMediaConfig;
                          ipCtl.text = netConfig.ipAddress;
                          portCtl.text = netConfig.port.toString();
                          if (scale.scaleModel == "S15") {
                            comPortCtl.text = '';
                            baudRateCtl.text = '';
                            PublicFunctions.getSerialPort(scale.scaleId);
                          }
                        } else {
                          final bluetoothConfig =
                              scale.mediaConfig as BluetoothMediaConfig;
                          macCtl.text = bluetoothConfig.mac;
                          btNameCtl.text = bluetoothConfig.name;
                        }
                        if ((scale.scaleModel == 'T-Max' ||
                                scale.scaleModel == 'TMax') &&
                            scale.scaleSn.length == 10) {
                          scaleModelCtl.text = '';
                          snCtl.text = '';
                        }
                      });
                    },
                    child: Container(
                      height: scaleItemHeight,
                      color: !isSelect
                          ? Theme.of(context).colorScheme.surfaceContainerLow
                          : scale.isOnline
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
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
                                              alignment: Alignment.center,
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
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary))
                                          : Container(
                                              alignment: Alignment.center,
                                              width: iconMenuSize,
                                              height: iconMenuSize,
                                              child: getSvgIcon(
                                                  btSvgIcon(),
                                                  iconMenuSize,
                                                  iconMenuSize,
                                                  (!isSelect)
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary)))),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                      : localizedStrings.gTipOffline,
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
    );
  }

  Widget buildItemInfo(
      Widget title1, Widget content1, Widget title2, Widget content2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: inputWidth, child: title1),
          SizedBox(width: inputWidth, child: content1)
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: inputWidth, child: title2),
          SizedBox(width: inputWidth, child: content2)
        ])
      ],
    );
  }

  Widget showAutoScanSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(localizedStrings.gAutoScanSerialPort, 
               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                 color: Theme.of(context).colorScheme.onSurface
               )),
          Switch(
            value: isAutoScanEnabled,
            onChanged: (val) {
              setState(() {
                isAutoScanEnabled = val;
              });
              PublicFunctions.setAutoScan(val);
            },
          )
        ],
      ),
    );
  }
}
