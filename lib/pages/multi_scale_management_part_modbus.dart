part of 'multi_scale_management_page.dart';

extension MultiScaleManagementModbusExt on MultiScaleManagementState {
  Widget showModbusConfigInfo(double maxWidth) {
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
                showAddModbusBtn(),
                Expanded(child: showModbusList(scaleListWidth))
              ],
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant, // 分隔条
              ),
              (isAddModbus || isEditModbus)
                  ? Expanded(child: _buildModbusForm())
                  : SizedBox(),
            ],
          ),
        ),
      ]))
    ]);
  }

  Widget showAddModbusBtn() {
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
                isAddModbus
                    ? null
                    : () {
                        setState(() {
                          isAddModbus = true;
                          isEditModbus = false;
                          currentEditModbusId = null;
                          modbusIdCtl.clear();
                          modbusProtocol = "Modbus RTU";
                          modbusComPortCtl.clear();
                          modbusBaudRateCtl.text = "9600";
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
                (isAddModbus || !isEditModbus || currentEditModbusId == null)
                    ? null
                    : () {
                        showDialog(
                          context: this.context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: Text(localizedStrings.fTipTitle),
                              content: Text(localizedStrings.gConfirmDeleteModbusService),
                              actions: [
                                TextButton(
                                  child: Text(localizedStrings.gBtnCancel),
                                  onPressed: () => Navigator.of(dialogContext).pop(false),
                                ),
                                TextButton(
                                  child: Text(localizedStrings.gBtnConfirm),
                                  onPressed: () => Navigator.of(dialogContext).pop(true),
                                ),
                              ],
                            );
                          },
                        ).then((value) {
                          if (value == true) {
                            PublicFunctions.delModbusService(currentEditModbusId!);
                            setState(() {
                              isAddModbus = false;
                              isEditModbus = false;
                            });
                          }
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

  Widget showModbusList(double listWidth) {
    return AnimatedContainer(
      color: Theme.of(context).colorScheme.surface,
      width: listWidth,
      duration: Duration(milliseconds: 300),
      child: Column(
        children: [
          SizedBox(height: regularPadding),
          SizedBox(height: smallPadding),
          modbusServicesList.isEmpty
              ? Center(child: Text(localizedStrings.gNoModbusService, style: Theme.of(context).textTheme.bodySmall))
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: ListView.separated(
                      itemCount: modbusServicesList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: smallPadding),
                      itemBuilder: (context, index) {
                        final service = modbusServicesList[index];
                        bool isSelect = (isEditModbus && currentEditModbusId == service.id);
                        return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isEditModbus = true;
                                    isAddModbus = false;
                                    currentEditModbusId = service.id;
                                    modbusIdCtl.text = service.targetModbusId.toString();
                                    modbusProtocol = service.protocol ?? "Modbus RTU";
                                    if (modbusProtocol == "Modbus TCP") {
                                      modbusTcpPortCtl.text = service.port ?? "502";
                                    } else {
                                      modbusComPortCtl.text = service.port ?? "";
                                      modbusBaudRateCtl.text = service.baudRate?.toString() ?? "9600";
                                      if (modbusComPortCtl.text.isNotEmpty && !usingComLists.contains(modbusComPortCtl.text)) {
                                          usingComLists.add(modbusComPortCtl.text);
                                      }
                                    }
                                  });
                                },
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
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .surface
                                                        .withValues(alpha: 0.1),
                                              ),
                                              width: scaleInnerItemHeight,
                                              height: scaleInnerItemHeight,
                                              child: Container(
                                                  alignment: Alignment.center,
                                                  width: iconMenuSize,
                                                  height: iconMenuSize,
                                                  child: Icon(Icons.cable, 
                                                    size: iconMenuSize, 
                                                    color: !isSelect ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary)))),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              "Modbus ID: ${service.targetModbusId}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .apply(
                                                    color: !isSelect
                                                        ? Theme.of(context).colorScheme.primary
                                                        : Theme.of(context).colorScheme.onPrimary,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "${localizedStrings.gProtocol}: ${service.protocol} | "
                                              "${service.protocol == 'Modbus RTU' ? '${localizedStrings.gSerialPort}: ${service.port} | ${localizedStrings.gBaudRate}: ${service.baudRate}' : 'Port: ${service.port}'}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .apply(
                                                    color: isSelect
                                                        ? Theme.of(context).colorScheme.onPrimary
                                                        : Theme.of(context).colorScheme.onTertiaryFixedVariant,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
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

  Widget _buildModbusForm() {
    // 找出所有已存在的 ModbusID，只能选现有的秤的 ModbusID
    List<String> availableModbusIds = [];
    for (var scale in myAllScalesList) {
      if (scale.modbusId != null && scale.modbusId! > 0) {
        availableModbusIds.add(scale.modbusId.toString());
      }
    }
    // 如果是编辑，要保留当前的 ModbusID
    if (isEditModbus && modbusIdCtl.text.isNotEmpty && !availableModbusIds.contains(modbusIdCtl.text)) {
      availableModbusIds.add(modbusIdCtl.text);
    }
    // 去重
    availableModbusIds = availableModbusIds.toSet().toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            subTitleInfo(context, constraints.maxWidth - 50.0,
                isAddModbus ? localizedStrings.gAddModbusService : localizedStrings.gEditModbusService, 
                localizedStrings.gModbusServiceFormDesc),
            Expanded(
          child: ListView(
            children: [
              SizedBox(height: regularPadding),
              buildItemInfo(
                showItemNameWithStar(context, localizedStrings.gCommMode, true),
                showDropDownButton(
                  context,
                  "",
                  TextEditingController(text: modbusProtocol),
                  modbusProtocolList,
                  (value) {
                    if (value != null) {
                      setState(() {
                        modbusProtocol = value;
                      });
                    }
                  },
                ),
                Container(),
                Container(),
              ),
              SizedBox(height: regularPadding),
              if (modbusProtocol == "Modbus TCP")
                buildItemInfo(
                  showItemNameWithStar(context, localizedStrings.gTcpPort, true),
                  showInputBox(context, modbusTcpPortCtl, "e.g., 502", (v) {}, true),
                  showItemNameWithStar(context, localizedStrings.gModbusStationId, true),
                  showDropDownButton(
                    context,
                    "",
                    modbusIdCtl,
                    availableModbusIds,
                    (value) {
                      setState(() {
                        if (value != null) modbusIdCtl.text = value;
                      });
                    },
                  ),
                ),
              if (modbusProtocol == "Modbus RTU")
                buildItemInfo(
                  showItemNameWithStar(context, localizedStrings.gSerialPort, true),
                  showDropDownButton(
                    context,
                    "",
                    modbusComPortCtl,
                    usingComLists,
                    (value) {
                      setState(() {
                        if (value != null && comLists.contains(value)) {
                          modbusComPortCtl.text = value;
                        } else {
                          modbusComPortCtl.clear();
                        }
                        usingComLists = List<String>.from(comLists);
                      });
                    },
                    onTap: () {
                      PublicFunctions.getPortList();
                      if (comLists.isEmpty && modbusComPortCtl.text.isNotEmpty) {
                        modbusComPortCtl.clear();
                      }
                      setState(() {});
                    },
                  ),
                  showItemNameWithStar(context, localizedStrings.gBaudRate, true),
                  showDropDownButton(
                    context,
                    "",
                    modbusBaudRateCtl,
                    baudRateList,
                    (value) {
                      setState(() {
                        if (value != null) {
                          modbusBaudRateCtl.text = value;
                        }
                      });
                    },
                  ),
                ),
              if (modbusProtocol == "Modbus RTU") SizedBox(height: regularPadding),
              if (modbusProtocol == "Modbus RTU")
                buildItemInfo(
                  showItemNameWithStar(context, localizedStrings.gDataBit, true),
                  showInputBox(context, modbusDataBitCtl, "8 (${localizedStrings.gFixed})", (v) {}, false),
                  showItemNameWithStar(context, localizedStrings.gStopBit, true),
                  showInputBox(context, modbusStopBitCtl, "1 (${localizedStrings.gFixed})", (v) {}, false),
                ),
              if (modbusProtocol == "Modbus RTU") SizedBox(height: regularPadding),
              if (modbusProtocol == "Modbus RTU")
                buildItemInfo(
                  showItemNameWithStar(context, localizedStrings.gParityBit, true),
                  showInputBox(context, modbusParityCtl, "None (${localizedStrings.gFixed})", (v) {}, false),
                  showItemNameWithStar(context, localizedStrings.gModbusStationId, true),
                  showDropDownButton(
                    context,
                    "",
                    modbusIdCtl,
                    availableModbusIds,
                    (value) {
                      setState(() {
                        if (value != null) modbusIdCtl.text = value;
                      });
                    },
                  ),
                ),

              SizedBox(height: regularPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  showTextButton(
                      context,
                      btnHeight,
                      localizedStrings.gBtnConfirm,
                      (modbusIdCtl.text.isNotEmpty && (modbusProtocol != "Modbus RTU" || modbusComPortCtl.text.isNotEmpty) && (modbusProtocol != "Modbus TCP" || modbusTcpPortCtl.text.isNotEmpty))
                      ? () {
                        if (modbusIdCtl.text.isEmpty) {
                          showTipInfo(localizedStrings.gModbusIdMissingTip, context);
                          return;
                        }

                        if (modbusProtocol == "Modbus RTU") {
                           if (modbusComPortCtl.text.isEmpty) {
                              showTipInfo(localizedStrings.gSerialPortMissingTip, context);
                              return;
                           }
                           // 防冲突校验：串口是否被普通的秤占用
                           for (var scale in myAllScalesList) {
                              if (scale.tMedia == comScaleType) {
                                 final serialConfig = scale.mediaConfig as SerialMediaConfig;
                                 if (serialConfig.devPath == modbusComPortCtl.text) {
                                    showTipInfo("${localizedStrings.gSerialPort} ${modbusComPortCtl.text} ${localizedStrings.gTipPortInUsed} (${scale.scaleName})", context);
                                    return;
                                 }
                              }
                           }
                           // 防冲突校验：串口是否被其他 Modbus 服务占用
                           for (var ms in modbusServicesList) {
                              if (isEditModbus && ms.id == currentEditModbusId) continue;
                              if (ms.protocol == "Modbus RTU" && ms.port == modbusComPortCtl.text) {
                                  showTipInfo("${localizedStrings.gSerialPort} ${modbusComPortCtl.text} ${localizedStrings.gPortOccupiedTip1} (ID:${ms.id})", context);
                                  return;
                              }
                           }
                        }

                        int targetModbusId = int.tryParse(modbusIdCtl.text) ?? 0;
                        int baudRate = int.tryParse(modbusBaudRateCtl.text) ?? 9600;

                        final Map<String, dynamic> reqData = {
                           "TargetModbusId": targetModbusId,
                           "Protocol": modbusProtocol,
                           "Port": modbusProtocol == "Modbus TCP" ? modbusTcpPortCtl.text : modbusComPortCtl.text,
                           "BaudRate": baudRate,
                        };

                        if (isAddModbus) {
                          PublicFunctions.addModbusService(jsonEncode(reqData));
                        } else if (isEditModbus) {
                          reqData["Id"] = currentEditModbusId;
                          PublicFunctions.editModbusService(jsonEncode(reqData));
                        }
                        
                        setState(() {
                           isAddModbus = false;
                           isEditModbus = false;
                        });
                      }
                      : null,
                      Theme.of(context).colorScheme.onPrimary,
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.onPrimary),
                  const SizedBox(width: regularPadding),
                  showTextButton(
                    context,
                    btnHeight,
                    localizedStrings.gBtnCancel,
                    () {
                      setState(() {
                        isAddModbus = false;
                        isEditModbus = false;
                      });
                    },
                    Theme.of(context).colorScheme.onPrimary,
                    Theme.of(context).colorScheme.onSurfaceVariant,
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
      },
    );
  }

}
