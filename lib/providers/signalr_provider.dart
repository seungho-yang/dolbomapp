import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/hub_model.dart';
import '../services/signalr_service.dart';

/// SignalR 상태 관리 Provider
class SignalRProvider with ChangeNotifier {
  final SignalRService _signalRService = SignalRService.instance;

  bool _isConnected = false;
  HubModel? _lastMessage;
  HubMessageModel? _lastChatMessage;

  bool get isConnected => _isConnected;
  HubModel? get lastMessage => _lastMessage;
  HubMessageModel? get lastChatMessage => _lastChatMessage;

  SignalRProvider() {
    // 메시지 수신 리스너 등록
    _signalRService.addListener(_onMessageReceived);
  }

  /// SignalR 연결 시작
  Future<void> connect(String userId) async {
    await _signalRService.initialize(userId);
    _isConnected = _signalRService.isConnected;
    notifyListeners();
  }

  /// SignalR 연결 해제
  Future<void> disconnect() async {
    await _signalRService.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  /// 메시지 수신 처리
  void _onMessageReceived(HubModel hubModel) {
    _lastMessage = hubModel;

    // Dialog 메시지인 경우 파싱
    if (hubModel.isDialog && hubModel.json != null) {
      try {
        final jsonData = jsonDecode(hubModel.json!.toLowerCase());
        _lastChatMessage = HubMessageModel.fromJson(jsonData);
        debugPrint('SignalR Provider: 채팅 메시지 수신 - ${_lastChatMessage?.message}');
      } catch (e) {
        debugPrint('SignalR Provider: 채팅 메시지 파싱 실패 - $e');
      }
    }

    notifyListeners();
  }

  /// 채팅 메시지 전송
  Future<void> sendChatMessage({
    required String id,
    required String message,
    int bot = 0,
    int type = 0,
  }) async {
    final now = DateTime.now().toIso8601String();

    final messageData = {
      'message': message,
      'id': int.tryParse(id) ?? 0,
      'bot': bot,
      'type': type,
      'reception': now,
    };

    final hubModel = HubModel(
      mode: 68, // 'D' for Dialog
      groupName: id,
      json: jsonEncode(messageData),
    );

    await _signalRService.sendMessage(hubModel);
  }

  /// 재연결
  Future<void> reconnect() async {
    await _signalRService.reconnect();
    _isConnected = _signalRService.isConnected;
    notifyListeners();
  }

  @override
  void dispose() {
    _signalRService.removeListener(_onMessageReceived);
    super.dispose();
  }
}
