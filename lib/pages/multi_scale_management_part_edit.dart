// ignore_for_file: invalid_use_of_protected_member
part of 'multi_scale_management_page.dart';

extension MultiScaleManagementEditExt on MultiScaleManagementState {
  showEditWifiInfo(double maxWidth) {
    return Column(children: [
      subTitleInfo(context, maxWidth - headWidthPadding,
          localizedStrings.gBtnModify, localizedStrings.gTipScaleMgrPageHelp),
      Expanded(
        child: showEditNetScaleInfo(),
      ),
    ]);
  }

  Widget showEditNetScaleInfo() {
    return ListView(
      children: [
        SizedBox(
          height: regularPadding,
        ),
        buildItemInfo(
            showItemNameWithStar(context, localizedStrings.gIpAddress, false),
            showInputBox(context, ipCtl, '', (value) {
              setState(() {});
            }, scaleModelCtl.text != "S15"),
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
                enabled: scaleModelCtl.text != "S15",
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

        if (scaleModelCtl.text == "S15")
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
            showDropDownButton(
              context,
              "",
              baudRateCtl,
              baudRateList,
              (value) {
                setState(() {
                  if (value != null) {
                    baudRateCtl.text = value;
                  }
                });
              },
            ),
          ),
        if (scaleModelCtl.text == "S15")
          SizedBox(
            height: regularPadding,
          ),
        if (isModifyingSerialPort)
          Padding(
            padding: const EdgeInsets.only(bottom: regularPadding),
            child: Center(
              child: Text(
                localizedStrings.gModifyingWait,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        buildItemInfo(
          showItemNameWithStar(context, "Protocol", false),
          showInputBox(context, protocolNameCtl, '', (value) {}, false),
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
                portCtl.text.isNotEmpty && _isValidIP && !isModifyingSerialPort && (scaleModelCtl.text != 'S15' || comPortCtl.text.isNotEmpty)
                    ? () {
                        editNetScale();
                      }
                    : null,
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.onPrimary),
            const SizedBox(width: regularPadding),
            showTextButton(context, btnHeight, localizedStrings.gBtnCancel, 
                isModifyingSerialPort ? null : () {
              setState(() {
                editWifiInfo = false;
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
