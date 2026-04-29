import 'package:flutter/material.dart';
import 'package:t_max/data/btinfodata.dart';
import 'package:t_max/data/icons.dart';
import 'package:t_max/data/language.dart';

class BtInfoListWidget extends StatefulWidget {
  final List<BtInfo> devices;
  final bool showSignalStrength;
  final VoidCallback? onRefresh;
  final Function(BtInfo)? onDeviceTap;
  final bool multiSelect;
  final bool sortByRSSI; // 是否按信号强度排序

  const BtInfoListWidget({
    super.key,
    required this.devices,
    this.showSignalStrength = true,
    this.onRefresh,
    this.onDeviceTap,
    this.multiSelect = false,
    this.sortByRSSI = true, // 默认按信号强度排序
  });

  @override
  BtInfoListWidgetState createState() => BtInfoListWidgetState();
}

class BtInfoListWidgetState extends State<BtInfoListWidget> {
  final Set<int> _selectedIndices = <int>{};
  final Set<String> _selectedMacs = <String>{};

  // 获取排序后的设备列表（信号强的在前面）
  List<BtInfo> get _sortedDevices {
    List<BtInfo> devices = List.from(widget.devices);

    if (widget.sortByRSSI) {
      // 按信号强度降序排序（信号最强的排前面）
      devices.sort((a, b) => (b.rssi ?? -999).compareTo(a.rssi ?? -999));
    }

    return devices;
  }

  @override
  Widget build(BuildContext context) {
    List<BtInfo> sortedDevices = _sortedDevices;

    if (sortedDevices.isEmpty) {
      return _buildEmptyState();
    }

    // 创建左右交替的布局
    List<Widget> leftColumn = [];
    List<Widget> rightColumn = [];

    // 交替分配设备到左右两列
    for (int i = 0; i < sortedDevices.length; i++) {
      // 找到原始索引
      int originalIndex = widget.devices.indexOf(sortedDevices[i]);
      Widget deviceItem = _buildDeviceItem(sortedDevices[i], originalIndex, i);

      if (i % 2 == 0) {
        // 偶数索引放左列
        leftColumn.add(deviceItem);
        if (i + 1 < sortedDevices.length) {
          leftColumn.add(SizedBox(height: 12));
        }
      } else {
        // 奇数索引放右列
        rightColumn.add(deviceItem);
        if (i + 1 < sortedDevices.length) {
          rightColumn.add(SizedBox(height: 12));
        }
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
        await Future.delayed(Duration(milliseconds: 500));
        if (mounted) {
          setState(() {
            _selectedIndices.clear();
            _selectedMacs.clear();
          });
        }
      },
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左列
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: leftColumn,
                ),
              ),
              SizedBox(width: 12),
              // 右列
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rightColumn,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(BtInfo device, int originalIndex, int sortedIndex) {
    bool isSelected = _selectedIndices.contains(originalIndex) ||
        (device.mac != null && _selectedMacs.contains(device.mac));

    String displayName =
        device.name?.isNotEmpty == true ? device.name! : 'Unknown Device';
    String displayMac = device.mac ?? 'N/A';

    return GestureDetector(
      onTap: () {
        _handleDeviceTap(device, originalIndex);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceDim,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 蓝牙图标和名称
            SizedBox(
              width: 40,
              height: 40,
              child: getSvgIcon(
                btDeviceSvgIcon(),
                40,
                40,
                isSelected
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),

            SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 设备名称
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.surface
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),

                  SizedBox(height: 4),

                  // MAC地址
                  Text(
                    displayMac,
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                          color: isSelected
                              ? Theme.of(context).colorScheme.surface
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            SizedBox(width: 8),

            // 信号强度信息
            SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 信号强度图标
                  if (widget.showSignalStrength && device.rssi != null)
                    buildWifiIcon(isSelected, device.rssi!),
                  SizedBox(height: 4),
                  // 信号强度值
                  if (widget.showSignalStrength && device.rssi != null)
                    Text(
                      '${device.rssi} dBm',
                      style: Theme.of(context).textTheme.bodySmall!.apply(
                            color: isSelected
                                ? Theme.of(context).colorScheme.surface
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                      textAlign: TextAlign.right,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWifiIcon(bool isSelected, int rssi) {
    double iconSize = 20;

    // 根据信号强度选择不同的图标
    String iconPath;
    if (rssi >= -70) {
      iconPath = isSelected ? bt4WhiteSvgIcon() : bt4BlueSvgIcon();
    } else if (rssi >= -85) {
      iconPath = isSelected ? bt3WhiteSvgIcon() : bt3BlueSvgIcon();
    } else if (rssi >= -100) {
      iconPath = isSelected ? bt2WhiteSvgIcon() : bt2BlueSvgIcon();
    } else {
      iconPath = isSelected ? bt1WhiteSvgIcon() : bt1BlueSvgIcon();
    }

    return Image.asset(
      iconPath,
      width: iconSize,
      height: iconSize,
      fit: BoxFit.contain,
    );
  }

  void _handleDeviceTap(BtInfo device, int index) {
    setState(() {
      if (widget.multiSelect) {
        if (_selectedIndices.contains(index)) {
          _selectedIndices.remove(index);
          if (device.mac != null) {
            _selectedMacs.remove(device.mac);
          }
        } else {
          _selectedIndices.add(index);
          if (device.mac != null) {
            _selectedMacs.add(device.mac!);
          }
        }
      } else {
        _selectedIndices.clear();
        _selectedMacs.clear();
        _selectedIndices.add(index);
        if (device.mac != null) {
          _selectedMacs.add(device.mac!);
        }
      }
    });

    if (widget.onDeviceTap != null) {
      widget.onDeviceTap!(device);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 64,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16),
          Text(
            localizedStrings.noBluetoothDevicesFound,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            localizedStrings.ensureBluetoothIsEnabled,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 20),
          if (widget.onRefresh != null)
            ElevatedButton.icon(
              onPressed: widget.onRefresh,
              icon: Icon(Icons.refresh, size: 18),
              label: Text(localizedStrings.scanBluetoothDevices),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
        ],
      ),
    );
  }

  List<BtInfo> getSelectedDevices() {
    List<BtInfo> selected = [];
    for (int i = 0; i < widget.devices.length; i++) {
      if (_selectedIndices.contains(i) ||
          (widget.devices[i].mac != null &&
              _selectedMacs.contains(widget.devices[i].mac))) {
        selected.add(widget.devices[i]);
      }
    }
    return selected;
  }

  void clearSelection() {
    setState(() {
      _selectedIndices.clear();
      _selectedMacs.clear();
    });
  }
}

// 如果希望更紧凑的布局，可以尝试这种网格布局
class AlternatingGridBtInfoList extends StatefulWidget {
  final List<BtInfo> devices;
  final bool sortByRSSI;

  const AlternatingGridBtInfoList({
    super.key,
    required this.devices,
    this.sortByRSSI = true,
  });

  @override
  AlternatingGridBtInfoListState createState() =>
      AlternatingGridBtInfoListState();
}

class AlternatingGridBtInfoListState extends State<AlternatingGridBtInfoList> {
  @override
  Widget build(BuildContext context) {
    List<BtInfo> sortedDevices = List.from(widget.devices);
    if (widget.sortByRSSI) {
      sortedDevices.sort((a, b) => (b.rssi ?? -999).compareTo(a.rssi ?? -999));
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: (sortedDevices.length / 2).ceil(),
      itemBuilder: (context, rowIndex) {
        List<Widget> rowChildren = [];

        // 如果这一行只有一个设备，添加一个占位符
        if (rowChildren.length == 1) {
          rowChildren.add(Expanded(child: SizedBox()));
        }

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        );
      },
    );
  }

  Widget buildWifiIcon(bool isSelected, int rssi) {
    double iconSize = 14;

    String iconPath;
    if (rssi >= -70) {
      iconPath = isSelected ? wifi4WhiteSvgIcon() : wifi4BlueSvgIcon();
    } else if (rssi >= -85) {
      iconPath = isSelected ? wifi3WhiteSvgIcon() : wifi3BlueSvgIcon();
    } else if (rssi >= -100) {
      iconPath = isSelected ? wifi2WhiteSvgIcon() : wifi2BlueSvgIcon();
    } else {
      iconPath = isSelected ? wifi1WhiteSvgIcon() : wifi1BlueSvgIcon();
    }

    return Image.asset(
      iconPath,
      width: iconSize,
      height: iconSize,
      fit: BoxFit.contain,
    );
  }
}
