// ignore_for_file: invalid_use_of_protected_member
part of 'multi_scale_management_page.dart';

extension MultiScaleManagementInfoExt on MultiScaleManagementState {
//串口秤的明细信息
  Widget showSerialScaleInfo() {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return ListView(
            children: [
              SizedBox(
                height: smallPadding,
              ),
              buildItemInfo(
                  showItemNameWithStar(
                      context, localizedStrings.gScaleName, false),
                  showScaleNameInputBox(
                      context,
                      scaleNameCtl,
                      '',
                      IconButton(
                        icon: Icon(Icons.edit_outlined), // 清除按钮图标
                        onPressed: () {
                          setState(() {
                            isRename = true;
                          });
                        },
                      ), (value) {
                    setState(() {});
                  }, isRename),
                  showItemNameWithStar(
                      context, localizedStrings.gModelName, false),
                  showInputBox(context, scaleModelCtl, '', (value) {
                    setState(() {});
                  }, false)),
              SizedBox(
                height: smallPadding,
              ),
              buildItemInfo(
                  showItemNameWithStar(
                      context, localizedStrings.gScaleSn, false),
                  showInputBox(context, snCtl, '', (value) {
                    setState(() {});
                  }, false),
                  showItemNameWithStar(
                      context, localizedStrings.gDataBits, false),
                  showDropDownButton(context, '', dataBitCtl, dataBitsList,
                      (value) {
                    setState(() {
                      if (dataBitsList.contains(value)) {
                        dataBitCtl.text = value!;
                      }
                    });
                  })),
              SizedBox(
                height: smallPadding,
              ),

              buildItemInfo(
                  showItemNameWithStar(
                      context, localizedStrings.gSerialPort, false),
                  showDropDownButton(
                    context,
                    "",
                    comPortCtl,
                    usingComLists,
                    (value) {
                      setState(() {
                        if (value != null && comLists.contains(value)) {
                          comPortCtl.text = value;
                        } else {
                          // 若选择的值不在 comLists 中，清空输入框
                          comPortCtl.clear();
                        }
                        usingComLists = List<String>.from(comLists);
                      });
                    },
                    onTap: () {
                      PublicFunctions.getPortList();
                      if (comLists.isEmpty && comPortCtl.text.isNotEmpty) {
                        comPortCtl.clear();
                      }
                    },
                  ),
                  showItemNameWithStar(
                      context, localizedStrings.gBaudRate, false),
                  showDropDownButton(context, '', baudRateCtl, baudRateList,
                      (value) {
                    setState(() {
                      if (baudRateList.contains(value)) {
                        baudRateCtl.text = value!;
                      }
                    });
                  })),
              SizedBox(
                height: smallPadding,
              ),
              buildItemInfo(
                  showItemNameWithStar(
                      context, localizedStrings.gSerialParity, false),
                  showDropDownButton(context, '', protocolCtl, checkBitsList,
                      (value) {
                    setState(() {
                      if (checkBitsList.contains(value)) {
                        protocolCtl.text = value!;
                      }
                    });
                  }),
                  showItemNameWithStar(
                      context, localizedStrings.gStopBits, false),
                  showDropDownButton(context, '', stopBitCtl, stopBitsList,
                      (value) {
                    setState(() {
                      if (stopBitsList.contains(value)) {
                        stopBitCtl.text = value!;
                      }
                    });
                  })),
              SizedBox(
                height: regularPadding,
              ),
              SizedBox(
                height: regularPadding,
              ),
              buildItemInfo(
                  showItemNameWithStar(context, "Protocol", false),
                  showInputBox(context, protocolNameCtl, '', (value) {}, false),
                  protocolNameCtl.text == 'SCP-X' ? showItemNameWithStar(context, localizedStrings.gModbusStationId, false) : Container(),
                  protocolNameCtl.text == 'SCP-X' ? showInputBox(context, modbusIdCtl, '', (value) {}, false) : Container()),
              SizedBox(
                height: regularPadding,
              ),
              isRename ? showRenameConfirmBtn() : showComPortBtn(),
            ],
          );
        }),
      ),
    );
  }

  Widget showNetworkScaleInfo() {
    return Expanded(
        child: SizedBox(
            width: double.infinity,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return ListView(
                children: [
                  const SizedBox(
                    height: regularPadding,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, localizedStrings.gScaleName, false),
                      showScaleNameInputBox(
                          context,
                          scaleNameCtl,
                          '',
                          IconButton(
                            icon: Icon(Icons.edit_outlined), // 清除按钮图标
                            onPressed: () {
                              setState(() {
                                isRename = true;
                              });
                            },
                          ), (value) {
                        setState(() {});
                      }, isRename),
                      showItemNameWithStar(
                          context, localizedStrings.gModelName, false),
                      showInputBox(context, scaleModelCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, localizedStrings.gScaleSn, false),
                      showInputBox(context, snCtl, '', (value) {
                        setState(() {});
                      }, false),
                      showItemNameWithStar(
                          context, localizedStrings.gTipPort, false),
                      showInputBox(context, portCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: regularPadding,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                width: inputWidth,
                                child: showItemNameWithStar(context,
                                    localizedStrings.gIpAddress, false)),
                            SizedBox(
                                width: inputWidth,
                                child:
                                    showInputBox(context, ipCtl, '', (value) {
                                  setState(() {});
                                }, false))
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            scaleModelCtl.text == "S15"
                                ? SizedBox(
                                    width: inputWidth,
                                    child: showItemNameWithStar(context,
                                        localizedStrings.gSerialPort, false))
                                : SizedBox(
                                    width: inputWidth,
                                  ),
                            scaleModelCtl.text == "S15"
                                ? SizedBox(
                                    width: inputWidth,
                                    child: showInputBox(
                                        context, comPortCtl, '', (value) {
                                      setState(() {});
                                    }, false))
                                : SizedBox(
                                    width: inputWidth,
                                  )
                          ])
                    ],
                  ),
                  if (scaleModelCtl.text == "S15")
                    const SizedBox(
                      height: regularPadding,
                    ),
                  if (scaleModelCtl.text == "S15")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: inputWidth,
                                  child: showItemNameWithStar(context,
                                      localizedStrings.gBaudRate, false)),
                              SizedBox(
                                  width: inputWidth,
                                  child: showInputBox(
                                      context, baudRateCtl, '', (value) {
                                    setState(() {});
                                  }, false))
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: inputWidth,
                              ),
                              SizedBox(
                                width: inputWidth,
                              )
                            ])
                      ],
                    ),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(context, "Protocol", false),
                      showInputBox(context, protocolNameCtl, '', (value) {}, false),
                      protocolNameCtl.text == 'SCP-X' ? showItemNameWithStar(context, localizedStrings.gModbusStationId, false) : Container(),
                      protocolNameCtl.text == 'SCP-X' ? showInputBox(context, modbusIdCtl, '', (value) {}, false) : Container()),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  isRename
                      ? showRenameConfirmBtn()
                      : buttonRow(showModify: true),
                ],
              );
            })));
  }

  Widget showBluetoothScaleInfo() {
    return Expanded(
        child: SizedBox(
            width: double.infinity,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return ListView(
                children: [
                  const SizedBox(
                    height: regularPadding,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, localizedStrings.gScaleName, false),
                      showScaleNameInputBox(
                          context,
                          scaleNameCtl,
                          '',
                          IconButton(
                            icon: Icon(Icons.edit_outlined), // 清除按钮图标
                            onPressed: () {
                              setState(() {
                                isRename = true;
                              });
                            },
                          ), (value) {
                        setState(() {});
                      }, isRename),
                      showItemNameWithStar(
                          context, localizedStrings.gModelName, false),
                      showInputBox(context, scaleModelCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(
                          context, localizedStrings.gScaleSn, false),
                      showInputBox(context, snCtl, '', (value) {
                        setState(() {});
                      }, false),
                      showItemNameWithStar(
                          context, localizedStrings.bluetoothName, false),
                      showInputBox(context, btNameCtl, '', (value) {
                        setState(() {});
                      }, false)),
                  const SizedBox(
                    height: regularPadding,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                width: inputWidth,
                                child: showItemNameWithStar(context,
                                    localizedStrings.bluetoothAddress, false)),
                            SizedBox(
                                width: inputWidth,
                                child:
                                    showInputBox(context, macCtl, '', (value) {
                                  setState(() {});
                                }, false))
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: inputWidth,
                            ),
                            SizedBox(
                              width: inputWidth,
                            )
                          ])
                    ],
                  ),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  buildItemInfo(
                      showItemNameWithStar(context, "Protocol", false),
                      showInputBox(context, protocolNameCtl, '', (value) {}, false),
                      protocolNameCtl.text == 'SCP-X' ? showItemNameWithStar(context, localizedStrings.gModbusStationId, false) : Container(),
                      protocolNameCtl.text == 'SCP-X' ? showInputBox(context, modbusIdCtl, '', (value) {}, false) : Container()),
                  const SizedBox(
                    height: regularPadding,
                  ),
                  isRename ? showRenameConfirmBtn() : buttonRow(),
                ],
              );
            })));
  }

  Widget showComPortBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        showTextButton(
            context,
            btnHeight,
            localizedStrings.gBtnCloseSerialPort,
            isClosePort || isComSetting
                ? null
                : () {
                    PublicFunctions.closeSerialPort(selScaleId);
                    setState(() {
                      isClosePort = true;
                      for (var i = 0; i < myAllScalesList.length; i++) {
                        if (myAllScalesList[i].scaleId == selScaleId) {
                          myAllScalesList[i].isOnline = false;
                        }
                      }
                    });
                  },
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.error,
            Theme.of(context).colorScheme.error),
        const SizedBox(
          width: regularPadding,
        ),
        showTextButton(
            context,
            btnHeight,
            localizedStrings.gBtnOpenSerialPort,
            !isClosePort || isComSetting
                ? null
                : () {
                    PublicFunctions.openSerialPort(selScaleId);
                    setState(() {
                      isClosePort = false;
                    });
                  },
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.onPrimary),
        const SizedBox(
          width: regularPadding,
        ),
        showTextButton(
            context,
            btnHeight,
            localizedStrings.gBtnTestConnect,
            isClosePort || isComSetting || comPortCtl.text == ''
                ? null
                : () {
                    for (var scale in myAllScalesList) {
                      if (scale.tMedia == comScaleType) {
                        final serialConfig =
                            scale.mediaConfig as SerialMediaConfig;
                        if (serialConfig.devPath == comPortCtl.text &&
                            scale.scaleId != selScaleId) {
                          showTipInfo(
                              localizedStrings.gTipPortInUsed + scale.scaleName,
                              context);
                          return;
                        }
                      }
                    }
                    setState(() {
                      serialPortConnect = '';
                      isComSetting = true;
                    });
                    modifyComInfo();
                  },
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.onTertiaryFixedVariant,
            Theme.of(context).colorScheme.onPrimary),
        const SizedBox(
          width: regularPadding,
        ),
      ],
    );
  }

  Widget showRenameConfirmBtn() {
    return isRename
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.gBtnConfirm,
                  scaleNameCtl.text.isNotEmpty && _isModifyName && (getScaleType() != comScaleType || comPortCtl.text.isNotEmpty)
                      ? () {
                          modifyScaleName();
                          isEditing = true;
                        }
                      : null,
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.onPrimary),
              const SizedBox(width: regularPadding),
              showTextButton(context, btnHeight, localizedStrings.gBtnCancel,
                  () {
                setState(() {
                  isAddScale = false;
                  isRename = false;
                  for (var scale in myAllScalesList) {
                    if (scale.scaleId == selScaleId) {
                      scaleNameCtl.text = scale.scaleName;
                    }
                  }

                  if (isComSetting) {
                    isComSetting = false;
                  }
                });
              },
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  Theme.of(context).colorScheme.onPrimary),
            ],
          )
        : const SizedBox();
  }

  Widget buttonRow({bool showModify = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        showTextButton(
            context,
            btnHeight,
            localizedStrings.gBtnTestConnect,
            !isAddScale && !isTesting && !isDel && !isComSetting
                ? () {
                    PublicFunctions.checkSerialPort(selScaleId);
                    setState(() {
                      isTesting = true;
                    });
                  }
                : null,
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.onTertiaryFixedVariant,
            Theme.of(context).colorScheme.onPrimary),
        if (showModify) ...[
          const SizedBox(width: regularPadding),
          showTextButton(
              context,
              btnHeight,
              localizedStrings.gBtnModify,
              !isAddScale && !isTesting && !isDel && !isComSetting
                  ? () {
                      setState(() {
                        editWifiInfo = true;
                      });
                    }
                  : null,
              Theme.of(context).colorScheme.onPrimary,
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.onPrimary),
        ]
      ],
    );
  }

}
