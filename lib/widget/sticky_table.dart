import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef StickyTableRowBuilder<T> = TableRow Function(
  BuildContext context,
  T item,
  int row,
  List<StickyTableColumn<T>> columnData,
);

typedef StickyTableCellFunction<T, R> = R Function(
  BuildContext context,
  StickyTableColumn<T> title,
  T item,
  int row,
  int column,
);

/// 每一列的构建方式
class StickyTableColumn<T> {
  final String title;
  final bool? sort;
  final bool showSort;
  final Alignment alignment;
  final TableColumnWidth? columnWidth;
  final bool fixedStart;
  final bool fixedEnd;

  StickyTableColumn(
    this.title, {
    this.onTitleClick,
    this.onCellClick,
    this.sort,
    this.showSort = false,
    this.alignment = Alignment.center,
    this.renderTitle,
    this.renderCell,
    this.columnWidth,
    this.fixedStart = false,
    this.fixedEnd = false,
  });

  final Widget Function(BuildContext context, StickyTableColumn<T> title)?
      renderTitle;

  final StickyTableCellFunction<T, Widget>? renderCell;

  final void Function(BuildContext context, StickyTableColumn<T> title)?
      onTitleClick;

  final StickyTableCellFunction<T, void>? onCellClick;
}

/// 表格组件
class StickyTable<T> extends StatefulWidget {
  const StickyTable({
    super.key,
    required this.data,
    required this.columns,
    this.controller, // 添加 controller 参数
    this.titleHeight = 42,
    this.cellHeight = 40,
    this.cellDecoration,
    this.clickedRow,
    this.onRowClick, // 添加 onRowClick 属性
    this.defaultColumnWidth = const FixedColumnWidth(120),
    this.cellPadding,
    this.titleDecoration,
    this.rowDecoration,
    this.tableBorder,
    this.showZebraCrossing = true,
    //  this.zebraCrossingColor = (Colors.white, const Color(0xfff5f5f5)),
    this.zebraCrossingRadius = const Radius.circular(12),
    this.builderSortWidget,
  });

  final ScrollController? controller; // 定义 controller 属性

  final int? clickedRow; // 添加 clickedRow 属性

  ///默认列宽度
  final TableColumnWidth defaultColumnWidth;

  ///列配置
  final List<StickyTableColumn<T>> columns;

  /// 单元格内边距
  final EdgeInsets? cellPadding;

  ///标题描述信息
  final Decoration? titleDecoration;
  final Decoration? rowDecoration;
  final TableBorder? tableBorder;

  ///数据集合
  final List<T> data;

  ///标题高度
  final double titleHeight;

  ///单元格高度
  final double cellHeight;

  ///单元格描述信息
  final StickyTableCellFunction<T, Decoration>? cellDecoration;

  ///显示斑马线
  final bool showZebraCrossing;

  ///斑马线弧度
  final Radius zebraCrossingRadius;

  ///斑马线颜色
  ///斑马线颜色
  // final (Color, Color) zebraCrossingColor;

  ///构建排序组件
  final Widget Function(BuildContext context, StickyTableColumn<T> title)?
      builderSortWidget;

  final void Function(int row)? onRowClick; // 定义 onRowClick 属性

  @override
  State<StickyTable<T>> createState() => _StickyTableState<T>();
}

class _StickyTableState<T> extends State<StickyTable<T>> {
  final scrollControl = SyncScrollController();
  ScrollController? _effectiveController;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_effectiveController!.hasClients) {
        _effectiveController!.jumpTo(0.0);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollControl.dispose();
    if (widget.controller == null) {
      _effectiveController?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fixColumns = <StickyTableColumn<T>>[];
    final columns = <StickyTableColumn<T>>[];
    final fixEndColumns = <StickyTableColumn<T>>[];
    for (var element in widget.columns) {
      if (element.fixedStart) {
        fixColumns.add(element);
      } else if (element.fixedEnd) {
        fixEndColumns.add(element);
      } else {
        columns.add(element);
      }
    }
    return Column(
      children: [
        //标题
        renderTableGroup(context, fixColumns, columns, fixEndColumns, true),
        // 内容
        Expanded(
          child: Scrollbar(
            controller: _effectiveController, // 传递 controller
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _effectiveController, // 传递 controller
              primary: false, // 明确设置 primary 为 false
              physics: const ClampingScrollPhysics(), // 添加 physics
              child: renderTableGroup(
                context,
                fixColumns,
                columns,
                fixEndColumns,
                false,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 渲染组合表格
  Widget renderTableGroup(
    BuildContext context,
    fixColumns,
    columns,
    fixEndColumns,
    onlyTitle,
  ) {
    final scrollController = scrollControl.addAndGet(
      onlyTitle ? "title" : "body",
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (fixColumns.isNotEmpty)
          renderTable(
            context,
            fixColumns,
            isFixedStart: true,
            isFixedEnd: false,
            onlyTitle: onlyTitle,
          ),
        Expanded(
          child: Scrollbar(
            controller: scrollController, // 确保 Scrollbar 使用相同的 ScrollController
            thumbVisibility: true,
            thickness: onlyTitle ? 0 : 8,
            child: SingleChildScrollView(
              controller:
                  scrollController, // 确保 SingleChildScrollView 使用相同的 ScrollController
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: renderTable(
                context,
                columns,
                isFixedStart: false,
                isFixedEnd: false,
                onlyTitle: onlyTitle,
                appendColumnNum: fixColumns.length,
              ),
            ),
          ),
        ),
        if (fixEndColumns.isNotEmpty)
          renderTable(
            context,
            fixEndColumns,
            isFixedStart: false,
            isFixedEnd: true,
            onlyTitle: onlyTitle,
            appendColumnNum: fixColumns.length + columns.length,
          ),
      ],
    );
  }

  ///渲染表格
  Table renderTable(
    BuildContext context,
    List<StickyTableColumn<T>> allColumns, {
    int appendColumnNum = 0,
    bool isFixedStart = false,
    bool isFixedEnd = false,
    bool onlyTitle = false,
  }) {
    final titleDecoration = widget.titleDecoration ??
        const BoxDecoration(
          color: Color(0xffE6EEF4),
        );
    final rowDecoration = widget.rowDecoration ??
        const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xffebebeb), width: 2),
          ),
        );

    const bodyTextColor = Color(0xff666666);

    ///内容
    final bodyColumnWidthMaps = allColumns
        .map((e) => e.columnWidth ?? widget.defaultColumnWidth)
        .toList()
        .asMap();
    return Table(
      defaultColumnWidth: widget.defaultColumnWidth,
      columnWidths: bodyColumnWidthMaps,
      border: widget.tableBorder,
      children: [
        /// 渲染表头
        if (onlyTitle)
          TableRow(
            decoration: titleDecoration,
            children: allColumns
                .map(
                  (e) => InkWell(
                    onTap: () {
                      if (e.onTitleClick != null) {
                        e.onTitleClick!(context, e);
                      }
                    },
                    child: Container(
                      alignment: e.alignment,
                      height: widget.titleHeight,
                      padding: widget.cellPadding ?? const EdgeInsets.all(10),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface, //titleTextColor,
                          fontSize: 14,
                          // fontWeight: FontWeight.w500,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            e.renderTitle != null
                                ? e.renderTitle!(context, e)
                                : renderTitle(context, e),
                            //去掉排序图标
                            // if (e.showSort)
                            //   widget.builderSortWidget != null
                            //       ? widget.builderSortWidget!(context, e)
                            //       : _SortWidget(sortUp: e.sort),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          )

        ///渲染表格内容
        else
          for (var row = 0; row < widget.data.length; row++) ...[
            TableRow(
              decoration: rowDecoration,
              children: allColumns.asMap().entries.map((column) {
                //第几列
                final columnValue = column.key + appendColumnNum;
                return InkWell(
                  onTap: () {
                    // 添加点击行处理
                    if (widget.onRowClick != null) {
                      widget.onRowClick!(row); // 调用 onRowClick 回调
                    }

                    if (widget.cellDecoration != null) {
                      setState(() {
                        // 更新点击行状态
                        if (context is Element) {
                          context.markNeedsBuild();
                        }
                      });
                    }
                    if (column.value.onCellClick != null) {
                      column.value.onCellClick!(
                        context,
                        column.value,
                        widget.data[row],
                        row,
                        columnValue,
                      );
                    }
                  },
                  child: Container(
                    decoration: widget.cellDecoration != null
                        ? widget.cellDecoration!(
                            context,
                            column.value,
                            widget.data[row],
                            row,
                            columnValue,
                          )
                        : zebraCrossingBoxDecoration(row, columnValue),
                    alignment: column.value.alignment,
                    height: widget.cellHeight,
                    padding: widget.cellPadding ?? const EdgeInsets.all(10),
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        color: bodyTextColor,
                        // fontSize: 12,
                        // fontWeight: FontWeight.w500,
                      ),
                      child: column.value.renderCell != null
                          ? column.value.renderCell!(
                              context,
                              column.value,
                              widget.data[row],
                              row,
                              columnValue,
                            )
                          : renderCell(
                              context,
                              column.value,
                              widget.data[row],
                              row,
                              columnValue,
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
      ],
    );
  }

  ///渲染标题
  Widget renderTitle(BuildContext context, StickyTableColumn<T> title) {
    return Text(title.title);
  }

  ///渲染标题
  Widget renderCell(
    BuildContext context,
    StickyTableColumn<T> title,
    T data,
    int row,
    int column,
  ) {
    return const Text("-");
  }

  ///斑马线描述
  BoxDecoration? zebraCrossingBoxDecoration(int row, int column) {
    if (!widget.showZebraCrossing) return null;

    final isFirstColumn = column == 0;
    final isEndColumn = column == widget.columns.length - 1;
    final defaultRadius = widget.zebraCrossingRadius;
    final leftRadius = isFirstColumn ? defaultRadius : Radius.zero;
    final rightRadius = isEndColumn ? defaultRadius : Radius.zero;

    // final (firstColor, secColor) = widget.zebraCrossingColor;
    return BoxDecoration(
      // color: row % 2 == 0 ? firstColor : secColor,
      borderRadius: BorderRadius.only(
        topLeft: leftRadius,
        bottomLeft: leftRadius,
        topRight: rightRadius,
        bottomRight: rightRadius,
      ),
    );
  }
}

///排序组件
class SortWidget extends StatelessWidget {
  const SortWidget({super.key, this.sortUp});

  final bool? sortUp;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Icon(
            Icons.arrow_drop_up,
            color: sortUp == true ? color : null,
            size: 20,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Icon(
            Icons.arrow_drop_down,
            color: sortUp == false ? color : null,
            size: 20,
          ),
        ),
      ],
    );
  }
}

/// Sets up a collection of scroll controllers that mirror their movements to
/// each other.
///
/// Controllers are added and returned via [addAndGet]. The initial offset
/// of the newly created controller is synced to the current offset.
/// Controllers must be `dispose`d when no longer in use to prevent memory
/// leaks and performance degradation.
///
/// If controllers are disposed over the course of the lifetime of this
/// object the corresponding scrollable's should be given unique keys.
/// Without the keys, Flutter may reuse a controller after it has been disposed,
/// which can cause the controller offsets to fall out of sync.
class SyncScrollController {
  SyncScrollController({this.initialScrollOffset = 0.0}) {
    _offsetNotifier = _SyncScrollControllerGroupOffsetNotifier(this);
  }

  final double initialScrollOffset;
  final _allControllers = <String, _SyncScrollController>{};

  late _SyncScrollControllerGroupOffsetNotifier _offsetNotifier;

  /// The current scroll offset of the group.
  double get offset {
    assert(
      _attachedControllers.isNotEmpty,
      'SyncScrollControllerGroup does not have any scroll controllers '
      'attached.',
    );
    return _attachedControllers.first.offset;
  }

  /// Creates a new controller that is Sync to any existing ones.
  ScrollController addAndGet(String key) {
    if (_allControllers.containsKey(key)) {
      return _allControllers[key]!;
    }
    final initialOffset = _attachedControllers.isEmpty
        ? initialScrollOffset
        : _attachedControllers.first.position.pixels;
    final controller = _SyncScrollController(
      this,
      initialScrollOffset: initialOffset,
    );
    _allControllers[key] = controller;
    controller.addListener(_offsetNotifier.notifyListeners);
    return controller;
  }

  /// Adds a callback that will be called when the value of [offset] changes.
  void addOffsetChangedListener(VoidCallback onChanged) {
    _offsetNotifier.addListener(onChanged);
  }

  /// Removes the specified offset changed listener.
  void removeOffsetChangedListener(VoidCallback listener) {
    _offsetNotifier.removeListener(listener);
  }

  Iterable<_SyncScrollController> get _attachedControllers =>
      _allControllers.entries
          .where((entity) => entity.value.hasClients)
          .map((e) => e.value);

  /// Animates the scroll position of all Sync controllers to [offset].
  Future<void> animateTo(
    double offset, {
    required Curve curve,
    required Duration duration,
  }) async {
    final animations = <Future<void>>[];
    for (final controller in _attachedControllers) {
      animations.add(
        controller.animateTo(offset, duration: duration, curve: curve),
      );
    }
    await Future.wait(animations);
  }

  /// Jumps the scroll position of all Sync controllers to [value].
  void jumpTo(double value) {
    for (final controller in _attachedControllers) {
      controller.jumpTo(value);
    }
  }

  /// Resets the scroll position of all Sync controllers to 0.
  void resetScroll() {
    jumpTo(0.0);
  }

  void dispose() {
    final controllers = _allControllers.values.toList();
    for (var value in controllers) {
      value.dispose();
    }
    _allControllers.clear();
  }
}

/// This class provides change notification for [SyncScrollController]'s
/// scroll offset.
///
/// This change notifier de-duplicates change events by only firing listeners
/// when the scroll offset of the group has changed.
class _SyncScrollControllerGroupOffsetNotifier extends ChangeNotifier {
  _SyncScrollControllerGroupOffsetNotifier(this.controllerGroup);

  final SyncScrollController controllerGroup;

  /// The cached offset for the group.
  ///
  /// This value will be used in determining whether to notify listeners.
  double? _cachedOffset;

  @override
  void notifyListeners() {
    final currentOffset = controllerGroup.offset;
    if (currentOffset != _cachedOffset) {
      _cachedOffset = currentOffset;
      super.notifyListeners();
    }
  }
}

/// A scroll controller that mirrors its movements to a peer, which must also
/// be a [_SyncScrollController].
class _SyncScrollController extends ScrollController {
  final SyncScrollController _controllers;

  _SyncScrollController(this._controllers, {required super.initialScrollOffset})
      : super(keepScrollOffset: false);

  @override
  void dispose() {
    _controllers._allControllers.removeWhere((key, value) => value == this);
    super.dispose();
  }

  @override
  void attach(ScrollPosition position) {
    assert(
      position is _SyncScrollPosition,
      '_SyncScrollControllers can only be used with'
      ' _SyncScrollPositions.',
    );
    final _SyncScrollPosition syncPosition = position as _SyncScrollPosition;
    assert(
      syncPosition.owner == this,
      '_SyncScrollPosition cannot change controllers once created.',
    );
    super.attach(position);
  }

  @override
  _SyncScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _SyncScrollPosition(
      this,
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      oldPosition: oldPosition,
    );
  }

  @override
  double get initialScrollOffset => _controllers._attachedControllers.isEmpty
      ? super.initialScrollOffset
      : _controllers.offset;

  @override
  _SyncScrollPosition get position => super.position as _SyncScrollPosition;

  Iterable<_SyncScrollController> get _allPeersWithClients =>
      _controllers._attachedControllers.where((peer) => peer != this);

  bool get canLinkWithPeers => _allPeersWithClients.isNotEmpty;

  Iterable<_SyncScrollActivity> linkWithPeers(_SyncScrollPosition driver) {
    assert(canLinkWithPeers);
    return _allPeersWithClients
        .map((peer) => peer.link(driver))
        .expand((e) => e);
  }

  Iterable<_SyncScrollActivity> link(_SyncScrollPosition driver) {
    assert(hasClients);
    final activities = <_SyncScrollActivity>[];
    for (final position in positions) {
      final syncPosition = position as _SyncScrollPosition;
      activities.add(syncPosition.link(driver));
    }
    return activities;
  }
}

// Implementation details: Whenever position.setPixels or position.forcePixels
// is called on a _SyncScrollPosition (which may happen programmatically, or
// as a result of a user action),  the _SyncScrollPosition creates a
// _SyncScrollActivity for each Sync position and uses it to move to or jump
// to the appropriate offset.
//
// When a new activity begins, the set of peer activities is cleared.
class _SyncScrollPosition extends ScrollPositionWithSingleContext {
  _SyncScrollPosition(
    this.owner, {
    required super.physics,
    required super.context,
    super.initialPixels = null,
    super.oldPosition,
  });

  final _SyncScrollController owner;

  final Set<_SyncScrollActivity> _peerActivities = <_SyncScrollActivity>{};

  // We override hold to propagate it to all peer controllers.
  @override
  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    for (final controller in owner._allPeersWithClients) {
      controller.position._holdInternal();
    }
    return super.hold(holdCancelCallback);
  }

  // Calls hold without propagating to peers.
  void _holdInternal() {
    super.hold(() {});
  }

  @override
  void beginActivity(ScrollActivity? newActivity) {
    if (newActivity == null) {
      return;
    }
    for (var activity in _peerActivities) {
      activity.unlink(this);
    }

    _peerActivities.clear();

    super.beginActivity(newActivity);
  }

  @override
  double setPixels(double newPixels) {
    if (newPixels == pixels) {
      return 0.0;
    }
    updateUserScrollDirection(
      newPixels - pixels > 0.0
          ? ScrollDirection.forward
          : ScrollDirection.reverse,
    );

    if (owner.canLinkWithPeers) {
      _peerActivities.addAll(owner.linkWithPeers(this));
      for (var activity in _peerActivities) {
        activity.moveTo(newPixels);
      }
    }

    return setPixelsInternal(newPixels);
  }

  double setPixelsInternal(double newPixels) {
    return super.setPixels(newPixels);
  }

  @override
  void forcePixels(double value) {
    if (value == pixels) {
      return;
    }
    updateUserScrollDirection(
      value - pixels > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse,
    );

    if (owner.canLinkWithPeers) {
      _peerActivities.addAll(owner.linkWithPeers(this));
      for (var activity in _peerActivities) {
        activity.jumpTo(value);
      }
    }

    forcePixelsInternal(value);
  }

  void forcePixelsInternal(double value) {
    super.forcePixels(value);
  }

  _SyncScrollActivity link(_SyncScrollPosition driver) {
    if (this.activity is! _SyncScrollActivity) {
      beginActivity(_SyncScrollActivity(this));
    }
    final _SyncScrollActivity activity = this.activity as _SyncScrollActivity;
    activity.link(driver);
    return activity;
  }

  void unlink(_SyncScrollActivity activity) {
    _peerActivities.remove(activity);
  }

  @override
  // ignore: unnecessary_overrides, as we want to make it public (overridden method is protected)
  void updateUserScrollDirection(ScrollDirection value) {
    super.updateUserScrollDirection(value);
  }

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('owner: $owner');
  }
}

class _SyncScrollActivity extends ScrollActivity {
  _SyncScrollActivity(_SyncScrollPosition super.delegate);

  @override
  _SyncScrollPosition get delegate => super.delegate as _SyncScrollPosition;

  final Set<_SyncScrollPosition> drivers = <_SyncScrollPosition>{};

  void link(_SyncScrollPosition driver) {
    drivers.add(driver);
  }

  void unlink(_SyncScrollPosition driver) {
    drivers.remove(driver);
    if (drivers.isEmpty) {
      delegate.goIdle();
    }
  }

  @override
  bool get shouldIgnorePointer => true;

  @override
  bool get isScrolling => true;

  // _SyncScrollActivity is not self-driven but moved by calls to the [moveTo]
  // method.
  @override
  double get velocity => 0.0;

  void moveTo(double newPixels) {
    _updateUserScrollDirection();
    delegate.setPixelsInternal(newPixels);
  }

  void jumpTo(double newPixels) {
    _updateUserScrollDirection();
    delegate.forcePixelsInternal(newPixels);
  }

  void _updateUserScrollDirection() {
    assert(drivers.isNotEmpty);
    ScrollDirection commonDirection = drivers.first.userScrollDirection;
    for (var driver in drivers) {
      if (driver.userScrollDirection != commonDirection) {
        commonDirection = ScrollDirection.idle;
      }
    }
    delegate.updateUserScrollDirection(commonDirection);
  }

  @override
  void dispose() {
    for (var driver in drivers) {
      driver.unlink(this);
    }
    super.dispose();
  }
}
