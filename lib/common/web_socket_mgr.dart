import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import '../data/resp_type_data.dart';

class WebSocketScaleManager {
  static final WebSocketScaleManager _instance =
      WebSocketScaleManager._internal();
  factory WebSocketScaleManager() => _instance;
  WebSocketScaleManager._internal();

  // 连接管理
  final Map<int, _ScaleConnection> _connections = {};
  List<int> get connectedScaleIds => _connections.keys.toList();

  // 连接状态流
  final Map<int, StreamController<bool>> _connectionControllers = {};

  // 获取特定scaleId的连接状态流
  Stream<bool> getConnectionStream(int scaleId) {
    if (!_connectionControllers.containsKey(scaleId)) {
      _connectionControllers[scaleId] = StreamController<bool>.broadcast();
    }
    return _connectionControllers[scaleId]!.stream;
  }

  // 检查特定scaleId是否已连接
  bool isConnected(int scaleId) {
    return _connections.containsKey(scaleId) &&
        _connections[scaleId]!.isConnected;
  }

  // 开始进行特定scaleId的连接（支持自动重连）
  Future<void> connect(int scaleId, String url) async {
    // 如果已存在连接且正在连接中，直接返回
    if (_connections.containsKey(scaleId) &&
        (_connections[scaleId]!.isConnected ||
            _connections[scaleId]!.isConnecting)) {
      debugPrint('ScaleId $scaleId 连接已存在或正在连接中');
      return;
    }

    // 清理旧连接
    _cleanupConnection(scaleId);

    // 创建新连接
    final connection = _ScaleConnection(scaleId, url);
    _connections[scaleId] = connection;

    // 初始化连接状态流
    if (!_connectionControllers.containsKey(scaleId)) {
      _connectionControllers[scaleId] = StreamController<bool>.broadcast();
    }

    debugPrint('开始连接 scaleId: $scaleId, URL: $url');

    try {
      await connection.connect();
      _notifyConnectionStatus(scaleId, true);
    } catch (e) {
      debugPrint('ScaleId $scaleId 连接失败: $e');
      _notifyConnectionStatus(scaleId, false);
      // 自动安排重连
      _scheduleReconnect(scaleId, url);
    }
  }

  // 发送消息到特定scaleId的连接
  void sendMessage(int scaleId, String message) {
    if (!_connections.containsKey(scaleId) ||
        !_connections[scaleId]!.isConnected) {
      debugPrint('ScaleId $scaleId 连接未就绪，无法发送消息');
      return;
    }

    try {
      _connections[scaleId]!.sendMessage(message);
    } catch (e) {
      debugPrint('ScaleId $scaleId 消息发送失败: $e');
    }
  }

  /// 发送心跳包到特定scaleId的连接
  void sendHeartPacket(int scaleId) {
    if (!isConnected(scaleId)) return;

    Map<String, dynamic> data = {
      "code": 9999,
      "msg": "heartbeat",
      "timestamp": DateTime.now().millisecondsSinceEpoch
    };
    sendMessage(scaleId, json.encode(data));
  }

  /// 重新连接特定scaleId的socket
  void reconnectSocket(int scaleId) {
    final connection = _connections[scaleId];
    if (connection != null) {
      debugPrint('手动重连 scaleId: $scaleId');
      connection.reconnect();
    }
  }

  // 断开并清理特定scaleId的连接
  void dispose(int scaleId) {
    debugPrint('清理 scaleId: $scaleId 的连接');
    _cleanupConnection(scaleId);
  }

  // 断开所有连接
  void disposeAll() {
    debugPrint('清理所有连接');
    for (final scaleId in _connections.keys.toList()) {
      _cleanupConnection(scaleId);
    }
    _connectionControllers.forEach((_, controller) => controller.close());
    _connectionControllers.clear();
  }

  // 私有方法：清理连接
  void _cleanupConnection(int scaleId) {
    _connections[scaleId]?.dispose();
    _connections.remove(scaleId);
  }

  // 私有方法：通知连接状态
  void _notifyConnectionStatus(int scaleId, bool connected) {
    _connectionControllers[scaleId]?.add(connected);
  }

  // 私有方法：安排自动重连
  void _scheduleReconnect(int scaleId, String url) {
    final connection = _connections[scaleId];
    if (connection != null && !connection.isConnecting) {
      connection.scheduleReconnect();
    }
  }
}

// 单个scale连接管理类
class _ScaleConnection {
  final int scaleId;
  final String url;
  IOWebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectInterval = Duration(seconds: 5);
  final Duration _heartbeatInterval = Duration(seconds: 30);

  _ScaleConnection(this.scaleId, this.url);

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  Future<void> connect() async {
    if (_isConnecting || _isConnected) return;

    _isConnecting = true;
    _stopReconnectTimer();

    try {
      // 关闭现有连接
      await _disconnect();

      // 建立新连接
      final ws = await WebSocket.connect(url).timeout(const Duration(seconds: 5));
      ws.pingInterval = const Duration(seconds: 15);
      _channel = IOWebSocketChannel(ws);

      // 设置监听器
      _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      // 等待连接建立
      await Future.delayed(Duration(milliseconds: 300));

      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;

      // debugPrint('ScaleId $scaleId 连接成功');

      // 启动心跳
      _startHeartbeat();
    } catch (e) {
      _isConnecting = false;
      _isConnected = false;
      debugPrint('ScaleId $scaleId 连接异常: $e');
      scheduleReconnect();
      rethrow;
    }
  }

  void sendMessage(String message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(message);
    }
  }

  void reconnect() {
    _reconnectAttempts = 0;
    connect();
  }

  void scheduleReconnect() {
    if (_reconnectTimer != null ||
        _reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    _reconnectAttempts++;
    debugPrint(
        'ScaleId $scaleId 安排重连，尝试次数: $_reconnectAttempts/$_maxReconnectAttempts');

    _reconnectTimer = Timer(_reconnectInterval, () {
      _reconnectTimer = null;
      if (!_isConnected && !_isConnecting) {
        connect();
      }
    });
  }

  void _onData(dynamic data) {
    if (data != null) {
      if (kDebugMode) {
        print('$scaleId 收到消息:$data');
      }
      if (data.contains('unknown req')) {
        return;
      }
      // debugPrint('ScaleId $scaleId 收到消息: $data');
      _handleMessage(data);
    }
  }

  void _onError(error) {
    debugPrint('ScaleId $scaleId 连接错误: $error');
    _isConnected = false;
    scheduleReconnect();
  }

  void _onDone() {
    debugPrint('ScaleId $scaleId 连接关闭');
    _isConnected = false;
    scheduleReconnect();
  }

  void _handleMessage(dynamic data) {
    try {
      Map<String, dynamic> map = json.decode(data);

      // 处理心跳响应
      if (map['code'] == 9999) {
        // debugPrint('ScaleId $scaleId 收到心跳响应');
        return;
      }

      // 处理业务消息
      if (RespMsgType.handlers.containsKey(map['MsgType'])) {
        var handler = RespMsgType.handlers[map['MsgType']];
        handler!(map);
      }
    } catch (e) {
      debugPrint('ScaleId $scaleId 消息处理错误: $e');
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected) {
        _sendHeartbeat();
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _sendHeartbeat() {
    // 已经启用了底层 websocket pingInterval，不再发送会引起后端解析异常的应用层心跳 JSON
  }

  Future<void> _disconnect() async {
    _stopHeartbeat();
    _stopReconnectTimer();

    _isConnected = false;
    _isConnecting = false;

    try {
      await _channel?.sink.close();
      _channel = null;
    } catch (e) {
      debugPrint('ScaleId $scaleId 断开连接错误: $e');
    }
  }

  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void dispose() {
    _stopHeartbeat();
    _stopReconnectTimer();
    _disconnect();
  }
}

// 使用示例：
// 1. 连接特定scaleId
// await WebSocketScaleManager().connect(1, 'ws://127.0.0.1:7878/tmax?scaleid=1');
//
// 2. 监听连接状态
// WebSocketScaleManager().getConnectionStream(1).listen((connected) {
//   print('ScaleId 1 连接状态: $connected');
// });
//
// 3. 发送消息
// WebSocketScaleManager().sendMessage(1, 'Hello World');
//
// 4. 清理连接
// WebSocketScaleManager().dispose(1);
