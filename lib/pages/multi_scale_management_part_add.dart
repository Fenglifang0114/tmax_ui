// ignore_for_file: invalid_use_of_protected_member
part of 'multi_scale_management_page.dart';

extension MultiScaleManagementAddExt on MultiScaleManagementState {
//增加秤时显示
  Widget showAddScaleInfo(double maxWidth) {
    return Column(children: [
      if (addScaleType == "bt" && isBtSearched && !isBtSearching)
        Row(
          children: [
            subTitleInfo(
                context,
                maxWidth - headWidthPadding,
                localizedStrings.gBtnAdd,
                localizedStrings.gTipScaleMgrPageHelp),
            Spacer(),
            TextButton(
              onPressed: () {
                PublicFunctions.getBtList();
                setState(() {
                  btInfoList.clear();
                  selectBtInfo = BtInfo();
                  isBtSearching = true;
                });
              },
              child: Text(localizedStrings.gMsgRefresh,
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: Theme.of(context).colorScheme.primary,
                      )),
            ),
          ],
        ),
      if (addScaleType != "bt")
        subTitleInfo(context, maxWidth - headWidthPadding,
            localizedStrings.gBtnAdd, localizedStrings.gTipScaleMgrPageHelp),
      Expanded(
        child: addScaleType == "com"
            ? showAddComScaleInfo()
            : addScaleType == "wifi"
                ? showAddNetScaleInfo()
                : showAddBtScaleInfo(),
      ),
    ]);
  }

  Widget showAddComScaleInfo() {
    return ListView(
      children: [
        SizedBox(
          height: regularPadding,
        ),

        buildItemInfo(
            showItemNameWithStar(context, localizedStrings.gSerialPort, false),
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
            showItemNameWithStar(context, localizedStrings.gBaudRate, false),
            showDropDownButton(context, '', baudRateCtl, baudRateList, (value) {
              setState(() {
                if (baudRateList.contains(value)) {
                  baudRateCtl.text = value!;
                }
              });
            })),
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
            showItemNameWithStar(context, localizedStrings.gStopBits, false),
            showDropDownButton(context, '', stopBitCtl, stopBitsList, (value) {
              setState(() {
                if (stopBitsList.contains(value)) {
                  stopBitCtl.text = value!;
                }
              });
            })),
        buildItemInfo(
          showItemNameWithStar(context, localizedStrings.gDataBits, false),
          showDropDownButton(context, '', dataBitCtl, dataBitsList, (value) {
            setState(() {
              if (dataBitsList.contains(value)) {
                dataBitCtl.text = value!;
              }
            });
          }),
          showItemNameWithStar(context, "Protocol", false),
          showDropDownButton(context, '', protocolNameCtl, protocolList, (value) {
            setState(() {
              if (protocolList.contains(value)) {
                protocolNameCtl.text = value!;
              }
            });
          }),
        ),
        SizedBox(
          height: regularPadding,
        ),
        buildItemInfo(
          protocolNameCtl.text == 'SCP-X' ? showItemNameWithStar(context, localizedStrings.gModbusStationId, true) : Container(),
          protocolNameCtl.text == 'SCP-X' ? showInputBox(context, modbusIdCtl, '1~247', (value) {
            setState(() {});
          }, true) : Container(),
          showItemNameWithStar(context, localizedStrings.gModelName, false),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: inputHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    scaleModelCtl.text,
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(width: smallPadding),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  fixedSize: Size(100, inputHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ModelSelectionScreen(
                        modelList: modelNameInfoData.modelNameInfoList,
                        onChanged: (value) {},
                      );
                    },
                  ).then((selectedModel) {
                    if (selectedModel != null && selectedModel is ModelNameInfo) {
                      setState(() {
                        scaleModelCtl.text = selectedModel.customScaleName ?? selectedModel.innerScaleName ?? '';
                      });
                    }
                  });
                },
                child: Text(
                  "Select",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: regularPadding,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showTextButton(
                context,
                btnHeight,
                localizedStrings.gBtnConfirm,
                comPortCtl.text.isNotEmpty
                    ? () {
                        for (var scale in myAllScalesList) {
                          if (scale.tMedia == comScaleType) {
                            final serialConfig =
                                scale.mediaConfig as SerialMediaConfig;
                            if (serialConfig.devPath == comPortCtl.text) {
                              showTipInfo(
                                  localizedStrings.gTipPortInUsed +
                                      scale.scaleName,
                                  context);
                              return;
                            }
                          }
                        }
                        int mId = int.tryParse(modbusIdCtl.text) ?? 1;
                        if (!checkModbusIdUnique(mId, -1)) {
                          showTipInfo("Modbus 站号 [$mId] 已被占用", context);
                          return;
                        }

                        isAddScale = false;
                        isRename = false;
                        addScaleType = '';

                        addComScale();
                      }
                    : null,
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: regularPadding),
            showTextButton(context, btnHeight, localizedStrings.gBtnCancel, () {
              setState(() {
                isAddScale = false;
                isRename = false;
                addScaleType = '';
                selScaleId = -1;
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
      ],
    );
  }

  //PublicFunctions.getBtList();
  Widget showAddBtScaleInfo() {
    if (isBtSearching) {
      return SizedBox(
          child: Column(
        children: [
          SizedBox(
            height: regularPadding,
          ),
          SizedBox(
            height: 60,
          ),
          showGif(),
          SizedBox(
            height: 80,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizedStrings.searchingBluetoothDevices,
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.gBtnConfirm,
                  macCtl.text.isNotEmpty && btNameCtl.text.isNotEmpty
                      ? () {
                          isAddScale = false;
                          isRename = false;
                          addScaleType = '';

                          addBtScale();
                        }
                      : null,
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.onPrimary),
              const SizedBox(width: regularPadding),
              SizedBox(
                width: regularPadding,
              ),
              showTextButton(context, btnHeight, localizedStrings.gBtnCancel,
                  () {
                setState(() {
                  isAddScale = false;
                  isRename = false;
                  addScaleType = '';
                  selScaleId = -1;

                  if (isComSetting) {
                    isComSetting = false;
                  }
                });
              },
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  Theme.of(context).colorScheme.onPrimary),
            ],
          ),
          SizedBox(
            height: regularPadding * 2,
          ),
        ],
      ));
    } else if (isBtSearched) {
      return SizedBox(
          child: Column(
        children: [
          // 设备列表
          Expanded(
            child: btInfoList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth_disabled,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          localizedStrings.noBluetoothDevicesFound,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 8),
                        Text(
                          localizedStrings.ensureBluetoothIsEnabled,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : BtInfoListWidget(
                    devices: btInfoList,
                    onRefresh: () {
                      // 刷新逻辑
                    },
                    onDeviceTap: (device) {
                      setState(() {
                        selectBtInfo = device;
                      });
                    },
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              showItemNameWithStar(context, "Protocol", false),
              SizedBox(width: 10),
              Container(
                width: 100,
                child: showDropDownButton(context, '', protocolNameCtl, protocolList, (value) {
                  setState(() {
                    if (protocolList.contains(value)) {
                      protocolNameCtl.text = value!;
                    }
                  });
                }),
              ),
              if (protocolNameCtl.text == 'SCP-X') ...[
                SizedBox(width: 20),
                showItemNameWithStar(context, localizedStrings.gModbusStationId, true),
                SizedBox(width: 10),
                Container(
                  width: 100,
                  child: showInputBox(context, modbusIdCtl, '1~247', (value) {
                    setState(() {});
                  }, true),
                ),
              ],
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.gBtnConfirm,
                  selectBtInfo.mac != null
                      ? () {
                          int mId = int.tryParse(modbusIdCtl.text) ?? 1;
                          if (!checkModbusIdUnique(mId, -1)) {
                            showTipInfo("Modbus 站号 [$mId] 已被占用", context);
                            return;
                          }

                          isAddScale = false;
                          isRename = false;
                          addScaleType = '';

                          isBtSearching = false;
                          isBtSearched = false;

                          addBtScale();
                        }
                      : null,
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.onPrimary),
              const SizedBox(width: regularPadding),
              SizedBox(
                width: regularPadding,
              ),
              showTextButton(context, btnHeight, localizedStrings.gBtnCancel,
                  () {
                setState(() {
                  isAddScale = false;
                  isRename = false;
                  addScaleType = '';
                  selScaleId = -1;
                  selectBtInfo = BtInfo();
                  btInfoList.clear();
                  isBtSearching = false;
                  isBtSearched = false;

                  if (isComSetting) {
                    isComSetting = false;
                  }
                });
              },
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  Theme.of(context).colorScheme.onPrimary),
            ],
          ),
          SizedBox(
            height: regularPadding * 2,
          ),
        ],
      ));
    } else {
      return SizedBox(
          child: Column(
        children: [
          SizedBox(
            height: regularPadding,
          ),
          SizedBox(
            height: 60,
          ),
          Image.asset(
            'assets/images/bt_tips.png',
            width: 600,
            height: 100,
            fit: BoxFit.scaleDown,
          ),
          SizedBox(
            height: 80,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                child: showTextButton(context, btnHeight,
                    localizedStrings.startSearchBluetoothDevices, () {
                  PublicFunctions.getBtList();
                  setState(() {
                    isBtSearching = true;
                  });
                },
                    Theme.of(context).colorScheme.onPrimary,
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.onPrimary),
              ),
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              showTextButton(
                  context,
                  btnHeight,
                  localizedStrings.gBtnConfirm,
                  portCtl.text.isNotEmpty && _isValidIP
                      ? () {
                          isAddScale = false;
                          isRename = false;
                          addScaleType = '';

                          addNetScale();
                        }
                      : null,
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.onPrimary),
              const SizedBox(width: regularPadding),
              SizedBox(
                width: regularPadding,
              ),
              showTextButton(context, btnHeight, localizedStrings.gBtnCancel,
                  () {
                setState(() {
                  isAddScale = false;
                  isRename = false;
                  addScaleType = '';
                  selScaleId = -1;

                  if (isComSetting) {
                    isComSetting = false;
                  }
                });
              },
                  Theme.of(context).colorScheme.onPrimary,
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  Theme.of(context).colorScheme.onPrimary),
            ],
          ),
          SizedBox(
            height: regularPadding * 2,
          ),
        ],
      ));
    }
  }

  Widget showAddNetScaleInfo() {
    return ListView(
      children: [
        SizedBox(
          height: regularPadding,
        ),
        buildItemInfo(
            showItemNameWithStar(context, localizedStrings.gIpAddress, false),
            showInputBox(context, ipCtl, '', (value) {
              setState(() {});
            }, true),
            showItemNameWithStar(context, localizedStrings.gTipPort, false),
            Container(
              height: inputHeight,
              padding: const EdgeInsets.only(left: 16, right: 20),
              decoration: BoxDecoration(
                border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outlineVariant), // 设置边框颜色
                borderRadius: BorderRadius.circular(0), // 设置圆角
              ),
              child: TextField(
                controller: portCtl,
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface, // 设置提示文本颜色
                  ),
                  border: InputBorder.none, // 移除默认边框
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.allow(RegExp(
                      r'^([1-9]|[1-9]\d|[1-9]\d{2}|[1-9]\d{3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])$')), // 允许输入数字
                ],
                style: Theme.of(context).textTheme.bodySmall!.apply(
                      color:
                          Theme.of(context).colorScheme.onSurface, // 设置输入文本颜色
                    ),
                onChanged: (value) {
                  setState(() {});
                }, // 监听文本变化,
              ),
            )),
        SizedBox(
          height: regularPadding,
        ),
        buildItemInfo(
          showItemNameWithStar(context, "Protocol", false),
          showDropDownButton(context, '', protocolNameCtl, protocolList, (value) {
            setState(() {
              if (protocolList.contains(value)) {
                protocolNameCtl.text = value!;
              }
            });
          }),
          protocolNameCtl.text == 'SCP-X' ? showItemNameWithStar(context, localizedStrings.gModbusStationId, true) : Container(),
          protocolNameCtl.text == 'SCP-X' ? showInputBox(context, modbusIdCtl, '1~247', (value) {
            setState(() {});
          }, true) : Container(),
        ),
        SizedBox(
          height: regularPadding,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showTextButton(
                context,
                btnHeight,
                localizedStrings.gBtnConfirm,
                portCtl.text.isNotEmpty && _isValidIP
                    ? () {
                        int mId = int.tryParse(modbusIdCtl.text) ?? 1;
                        if (!checkModbusIdUnique(mId, -1)) {
                          showTipInfo("Modbus 站号 [$mId] 已被占用", context);
                          return;
                        }

                        isAddScale = false;
                        isRename = false;
                        addScaleType = '';

                        addNetScale();
                      }
                    : null,
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: regularPadding),
            showTextButton(context, btnHeight, localizedStrings.gBtnCancel, () {
              setState(() {
                isAddScale = false;
                isRename = false;
                addScaleType = '';
                selScaleId = -1;

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
      ],
    );
  }

}
