import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_max/data/positions.dart';
import 'package:t_max/data/printer.dart';

import '../../data/item_key_list.dart';
import '../../data/offset.dart';
import '../../data/pagesize.dart';
import '../../data/text.dart';
import '../../eventbus/eventbus.dart';
import 'dash_line_painter.dart';

class DraggableFloatingActionButton extends StatefulWidget {
  final List<Widget> children;
  final Offset initialOffset;
  final VoidCallback onPressed;
  final GlobalKey parentKey;
  final int index;

  // ignore: use_key_in_widget_constructors
  const DraggableFloatingActionButton({
    super.key,
    required this.children,
    required this.initialOffset,
    required this.onPressed,
    required this.parentKey,
    required this.index,
  });

  @override
  State<StatefulWidget> createState() => _DraggableFloatingActionButtonState();
}

class _DraggableFloatingActionButtonState
    extends State<DraggableFloatingActionButton> {
  late final GlobalKey _key = GlobalKey();
  bool _isDragging = false;
  late Offset _offset;
  late Offset _minOffset;
  late Offset _maxOffset;
  late Offset _originOffset;
  final double _currentX = 0;
  final double _currentY = 0;
  final double _currentX1 = 0;
  final double _currentY1 = 0;
  double _minYvalue = 0;
  double _maxYvalue = 0;
  double _minXvalue = 0;
  double _maxXvalue = 0;
  double _minYX1value = 0;
  double _maxYX1value = 0;
  double _minXY1value = 0;
  double _maxXY1value = 0;
  double _minYY1value = 0;
  double _maxYY1value = 0;
  double _minXX1value = 0;
  double _maxXX1value = 0;
  double _minX1Xvalue = 0;
  double _maxX1Xvalue = 0;
  double _minY1Yvalue = 0;
  double _maxY1Yvalue = 0;

  final List<int> _indexesX = [];
  final List<int> _indexesY = [];
  final List<int> _indexesX1 = [];
  final List<int> _indexesY1 = [];
  final List<int> _indexesYY1 = [];
  final List<int> _indexesXX1 = [];
  final List<int> _indexesX1X = [];
  final List<int> _indexesY1Y = [];

  final List<int> _sameXValueYList = []; //X 相同时Y值集合
  final List<int> _sameYValueXList = []; //Y相同时X集合
  final List<int> _sameX1ValueYList = []; //X1相同时Y集合
  final List<int> _sameY1ValueXList = []; //Y1相同时X集合
  final List<int> _sameYY1ValueXList = []; //YY1相同时X集合
  final List<int> _sameXX1ValueYList = []; //XX1相同时Y集合
  final List<int> _sameX1XValueYList = []; //X1X相同时Y集合
  final List<int> _sameY1YValueXList = []; //Y1Y相同时X集合

  StreamSubscription? _subPageSize;
  StreamSubscription? _subPrinter;

  @override
  void initState() {
    super.initState();
    //_offset   当前位置坐标
    _offset = widget.initialOffset;
    WidgetsBinding.instance.addPostFrameCallback(_setBoundary);
    _subPageSize = eventBus.on<EventPageSize>().listen((event) {
      if (mounted) {
        setState(() {
          myPageSize = event.obj;
          WidgetsBinding.instance.addPostFrameCallback(_setBoundary);
        });
      }
    });
    _subPrinter = eventBus.on<EventPrinter>().listen((event) {
      if (mounted) {
        setState(() {
          myPrinter = event.obj;
        });
      }
    });
  }

  @override
  void dispose() {
    _subPageSize?.cancel();
    _subPrinter?.cancel();
    super.dispose();
  }

  void _setBoundary(_) {
    final RenderBox parentRenderBox =
        widget.parentKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox renderBox =
        _key.currentContext?.findRenderObject() as RenderBox;

    try {
      final Size parentSize = parentRenderBox.size;
      final Size size = renderBox.size;

      setState(() {
        //_minOffset 原点
        // if (myPrinter.printer == 'PT566') {
        //   _minOffset = const Offset(10, 20);
        //   _originOffset = const Offset(10, 0);
        // } else {
        //   _minOffset = const Offset(0, 0);
        //   _originOffset = const Offset(0, 0);
        // }
        _minOffset = const Offset(0, 0);
        _originOffset = const Offset(0, 0);
        myOffsetData.width = size.width;
        myOffsetData.height = size.height;
        //_maxOffset X/Y轴最大坐标
        if (myPrinter.printer == 'PT566') {
          _maxOffset = Offset(parentSize.width - size.width - _originOffset.dx,
              parentSize.height - size.height - _originOffset.dy);
        } else {
          _maxOffset = Offset(parentSize.width - size.width - _originOffset.dx,
              parentSize.height - size.height - _originOffset.dy);
        }
        // eventBus.fire(EventOffset(myOffsetData));
      });
    } catch (e) {
      if (kDebugMode) {
        print('catch: $e');
      }
    }
  }

//20230330
  void updatePosition(Offset newOffset) {
    setState(() {
      _offset = newOffset;
    });
  }

  void _updatePosition(PointerMoveEvent pointerMoveEvent) {
    //pointerMoveEvent.delta.dx（y）  X/Y轴偏移量
    //newOffsetX（y） 移动后的位置坐标
    WidgetsBinding.instance.addPostFrameCallback(_setBoundary);
    double newOffsetX = _offset.dx + pointerMoveEvent.delta.dx;
    double newOffsetY = _offset.dy + pointerMoveEvent.delta.dy;
    // if (myPrinter.printer == 'PT566') {
    //   newOffsetY = _offset.dy + pointerMoveEvent.delta.dy + myOffsetData.height;
    // }
    if (newOffsetX < _minOffset.dx) {
      newOffsetX = _minOffset.dx;
    } else if (newOffsetX > _maxOffset.dx) {
      newOffsetX = _maxOffset.dx;
    }

    if (newOffsetY < _minOffset.dy) {
      newOffsetY = _minOffset.dy;
    } else if (newOffsetY > _maxOffset.dy) {
      newOffsetY = _maxOffset.dy;
    }

    setState(() {
      _offset = Offset(newOffsetX, newOffsetY);
    });
  }

  // 新增代码，更新 _keyMap，确保每个 DragabbleFloatingActionButton 的 key 唯一

  @override
  Widget build(BuildContext context) {
    // _key = GlobalKey();
    myOffsetData.x = (_offset.dx.toInt()).roundToDouble();
    myOffsetData.y = ((_offset.dy).toInt()).roundToDouble();
    myOffsetData.key = widget.key!;
    // myOffsetDataList.offsetDataList.add(myOffsetData);

    eventBus.fire(EventOffset(myOffsetData));
    checkPosition();
    return Positioned(
      //移动后的X轴坐标
      left: (_offset.dx.toInt()).roundToDouble(),
      //移动后的Y轴坐标
      top: (_offset.dy.toInt()).roundToDouble(),
      child: Listener(
        onPointerMove: (PointerMoveEvent pointerMoveEvent) {
          _updatePosition(pointerMoveEvent);
          setState(() {
            _isDragging = true;
          });
          // bool isXOverlap = myPositionsList.positionsList.any((position) {
          //   return position.x == (_offset.dx.toInt()).roundToDouble();
          // });
          double currentX = (_offset.dx.toInt()).roundToDouble();
          double currentY = (_offset.dy.toInt()).roundToDouble();
          double currentX1 = currentX + myOffsetData.width;
          double currentY1 = currentY + myOffsetData.height;
          cleanList();
          myPositionsList.positionsList.asMap().forEach((index, element) {
            if (element.key != widget.key! && currentX == element.x) {
              _indexesX.add(index);
              _sameXValueYList
                  .add(myPositionsList.positionsList[index].y.toInt());
              _sameXValueYList
                  .add(myPositionsList.positionsList[index].y1.toInt());
            }
            if (element.key != widget.key! && currentY == element.y) {
              _indexesY.add(index);
              _sameYValueXList
                  .add(myPositionsList.positionsList[index].x.toInt());
              _sameYValueXList
                  .add(myPositionsList.positionsList[index].x1.toInt());
            }
            if (element.key != widget.key! && currentX1 == element.x1) {
              _indexesX1.add(index);
              _sameX1ValueYList
                  .add(myPositionsList.positionsList[index].y.toInt());
              _sameX1ValueYList
                  .add(myPositionsList.positionsList[index].y1.toInt());
            }
            if (element.key != widget.key! && currentY1 == element.y1) {
              _indexesY1.add(index);
              _sameY1ValueXList
                  .add(myPositionsList.positionsList[index].x.toInt());
              _sameY1ValueXList
                  .add(myPositionsList.positionsList[index].x1.toInt());
            }
            if (element.key != widget.key! && currentY == element.y1) {
              _indexesYY1.add(index);
              _sameYY1ValueXList
                  .add(myPositionsList.positionsList[index].x.toInt());
              _sameYY1ValueXList
                  .add(myPositionsList.positionsList[index].x1.toInt());
            }
            if (element.key != widget.key! && currentX == element.x1) {
              _indexesXX1.add(index);
              _sameXX1ValueYList
                  .add(myPositionsList.positionsList[index].y.toInt());
              _sameXX1ValueYList
                  .add(myPositionsList.positionsList[index].y1.toInt());
            }
            if (element.key != widget.key! && currentX1 == element.x) {
              _indexesX1X.add(index);
              _sameX1XValueYList
                  .add(myPositionsList.positionsList[index].y.toInt());
              _sameX1XValueYList
                  .add(myPositionsList.positionsList[index].y1.toInt());
            }
            if (element.key != widget.key! && currentY1 == element.y) {
              _indexesY1Y.add(index);
              _sameY1YValueXList
                  .add(myPositionsList.positionsList[index].x.toInt());
              _sameY1YValueXList
                  .add(myPositionsList.positionsList[index].x1.toInt());
            }
          });

          _minYvalue = checkMinValue(currentY, _sameXValueYList);
          _maxYvalue = checkMaxValue(currentY1, currentY, _sameXValueYList);
          _minXvalue = checkMinValue(currentX, _sameYValueXList);
          _maxXvalue = checkMaxValue(currentX1, currentX, _sameYValueXList);
          _minYX1value = checkMinValue(currentY, _sameX1ValueYList);
          _maxYX1value =
              checkMaxValue(currentY1, currentY, _sameX1ValueYList);
          _minXY1value = checkMinValue(currentX, _sameY1ValueXList);
          _maxXY1value =
              checkMaxValue(currentX1, currentX, _sameY1ValueXList);
          _minYY1value = checkMinValue(currentX, _sameYY1ValueXList);
          _maxYY1value =
              checkMaxValue(currentX1, currentX, _sameYY1ValueXList);
          _minXX1value = checkMinValue(currentY, _sameXX1ValueYList);
          _maxXX1value =
              checkMaxValue(currentY1, currentY, _sameXX1ValueYList);
          _minX1Xvalue = checkMinValue(currentY, _sameX1XValueYList);
          _maxX1Xvalue =
              checkMaxValue(currentY1, currentY, _sameX1XValueYList);
          _minY1Yvalue = checkMinValue(currentX, _sameY1YValueXList);
          _maxY1Yvalue =
              checkMaxValue(currentX1, currentX, _sameY1YValueXList);
        },
        onPointerUp: (PointerUpEvent pointerUpEvent) {
          // if (myPrinter.printer != 'PT566') {
          //   myOffsetData.height = 0;
          // }
          myOffsetData.x = (_offset.dx.toInt()).roundToDouble();
          myOffsetData.y = ((_offset.dy).toInt()).roundToDouble();
          myOffsetData.key = widget.key!;
          // myOffsetDataList.offsetDataList.add(myOffsetData);
          eventBus.fire(EventOffset(myOffsetData));
          myTextData.xPos = myOffsetData.x.toInt();
          myTextData.yPos = myOffsetData.y.toInt();
          eventBus.fire(EventText(myTextData));
          checkPosition();
          if (_isDragging) {
            setState(() {
              _isDragging = false;
              _indexesX.clear();
            });
          } else {
            widget.onPressed();
          }
        },
        onPointerHover: (PointerHoverEvent pointerHoverEvent) {},
        child: Stack(
          key: _key,
          children: [
            ...widget.children,
            if (_isDragging && _indexesX.isNotEmpty)
              CustomPaint(
                painter: SolidLinePainter(
                  color: Theme.of(context).colorScheme.error,
                  p1: Offset(0, _minYvalue),
                  p2: Offset(0, _maxYvalue),
                ),
              ),
            if (_isDragging && _indexesY.isNotEmpty)
              CustomPaint(
                painter: SolidLinePainter(
                  color: Theme.of(context).colorScheme.error,
                  p1: Offset(_minXvalue, 0),
                  p2: Offset(_maxXvalue, 0),
                ),
              ),
            if (_isDragging && _indexesX1.isNotEmpty)
              CustomPaint(
                painter: SolidLinePainter(
                  color: Theme.of(context).colorScheme.error,
                  p1: Offset(myOffsetData.width, _minYX1value),
                  p2: Offset(myOffsetData.width, _maxYX1value),
                ),
              ),
            if (_isDragging && _indexesY1.isNotEmpty)
              CustomPaint(
                painter: SolidLinePainter(
                  color: Theme.of(context).colorScheme.error,
                  p1: Offset(_minXY1value, myOffsetData.height),
                  p2: Offset(_maxXY1value, myOffsetData.height),
                ),
              ),
            if (_isDragging && _indexesYY1.isNotEmpty)
              CustomPaint(
                painter: SolidLinePainter(
                  color: Theme.of(context).colorScheme.error,
                  p1: Offset(_minYY1value, 0),
                  p2: Offset(_maxYY1value, 0),
                ),
              ),
            if (_isDragging && _indexesXX1.isNotEmpty)
              CustomPaint(
                painter: SolidLinePainter(
                  color: Theme.of(context).colorScheme.error,
                  p1: Offset(0, _minXX1value),
                  p2: Offset(0, _maxXX1value),
                ),
              ),
            if (_isDragging && _indexesX1X.isNotEmpty)
              CustomPaint(
                painter: SolidLinePainter(
                  color: Theme.of(context).colorScheme.error,
                  p1: Offset(myOffsetData.width, _minX1Xvalue),
                  p2: Offset(myOffsetData.width, _maxX1Xvalue),
                ),
              ),
            if (_isDragging && _indexesY1Y.isNotEmpty)
              CustomPaint(
                painter: SolidLinePainter(
                  color: Theme.of(context).colorScheme.error,
                  p1: Offset(_minY1Yvalue, myOffsetData.height),
                  p2: Offset(_maxY1Yvalue, myOffsetData.height),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void calculateLocation() {
    myPositionsList.positionsList.asMap().forEach((index, element) {
      if (element.key != widget.key! && _currentX == element.x) {
        _indexesX.add(index);
        _sameXValueYList.add(myPositionsList.positionsList[index].y.toInt());
        _sameXValueYList.add(myPositionsList.positionsList[index].y1.toInt());
      }
      if (element.key != widget.key! && _currentY == element.y) {
        _indexesY.add(index);
        _sameYValueXList.add(myPositionsList.positionsList[index].x.toInt());
        _sameYValueXList.add(myPositionsList.positionsList[index].x1.toInt());
      }
      if (element.key != widget.key! && _currentX1 == element.x1) {
        _indexesX1.add(index);
        _sameX1ValueYList.add(myPositionsList.positionsList[index].y.toInt());
        _sameX1ValueYList.add(myPositionsList.positionsList[index].y1.toInt());
      }
      if (element.key != widget.key! && _currentY1 == element.y1) {
        _indexesY1.add(index);
        _sameY1ValueXList.add(myPositionsList.positionsList[index].x.toInt());
        _sameY1ValueXList.add(myPositionsList.positionsList[index].x1.toInt());
      }
      if (element.key != widget.key! && _currentY == element.y1) {
        _indexesYY1.add(index);
        _sameYY1ValueXList.add(myPositionsList.positionsList[index].x.toInt());
        _sameYY1ValueXList.add(myPositionsList.positionsList[index].x1.toInt());
      }
      if (element.key != widget.key! && _currentX == element.x1) {
        _indexesXX1.add(index);
        _sameXX1ValueYList.add(myPositionsList.positionsList[index].y.toInt());
        _sameXX1ValueYList.add(myPositionsList.positionsList[index].y1.toInt());
      }
      if (element.key != widget.key! && _currentX1 == element.x) {
        _indexesX1X.add(index);
        _sameX1XValueYList.add(myPositionsList.positionsList[index].y.toInt());
        _sameX1XValueYList.add(myPositionsList.positionsList[index].y1.toInt());
      }
      if (element.key != widget.key! && _currentY1 == element.y) {
        _indexesY1Y.add(index);
        _sameY1YValueXList.add(myPositionsList.positionsList[index].x.toInt());
        _sameY1YValueXList.add(myPositionsList.positionsList[index].x1.toInt());
      }
    });
  }

  void cleanList() {
    _indexesX.clear();
    _indexesY.clear();
    _indexesX1.clear();
    _indexesY1.clear();
    _indexesYY1.clear();
    _indexesXX1.clear();
    _indexesX1X.clear();
    _indexesY1Y.clear();
    _sameXValueYList.clear(); //X 相同时Y值集合
    _sameYValueXList.clear(); //Y相同时X集合
    _sameX1ValueYList.clear(); //X1相同时Y集合
    _sameY1ValueXList.clear(); //Y1相同时X集合
    _sameYY1ValueXList.clear();
    _sameXX1ValueYList.clear();
    _sameX1XValueYList.clear();
    _sameY1YValueXList.clear();
  }

  double checkMinValue(double referencevalue, List<int> intListData) {
    double res = 0;
    if (intListData.isNotEmpty) {
      int minValue = intListData.reduce(min);
      if (referencevalue >= minValue) {
        res = minValue - referencevalue;
      }
    }
    return res;
  }

  double checkMaxValue(
      double referencevalue, double referencevalueY, List<int> intListData) {
    double res = 0;

    if (intListData.isNotEmpty) {
      int maxValue = intListData.reduce(max);
      if (referencevalue >= maxValue) {
        res = referencevalue - referencevalueY;
      } else {
        res = maxValue - referencevalueY;
      }
    }
    return res;
  }

  void checkPosition() {
    myPositions = Positions(
        myOffsetData.x,
        myOffsetData.y,
        myOffsetData.x + myOffsetData.width,
        myOffsetData.y + myOffsetData.height,
        widget.key!);

    myPositionsList.positionsList
        .removeWhere((position) => !myItemKey.keyList.contains(position.key));

    if (!isKeyExists(widget.key!, myPositionsList.positionsList)) {
      myPositionsList.positionsList.add(myPositions);
    } else {
      int index = myPositionsList.positionsList
          .indexWhere((element) => element.key == widget.key!);
      myPositionsList.positionsList[index] = myPositions;
    }
  }

  bool isKeyExists(Key key, List<Positions> positionsList) {
    return positionsList.any((element) => element.key == key);
  }
}
