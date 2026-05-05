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

    debugPrint('SignalR Provider: 메시지 수신 - mode: ${hubModel.mode}, groupName: ${hubModel.groupName}');

    // 인증 응답 메시지 ('U' = 85)
    if (hubModel.mode == 85) {
      debugPrint('SignalR Provider: 인증 응답(U) 수신 - json: ${hubModel.json}');
    }

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

    // 배터리 메시지 처리 ('B' = 66)
    if (hubModel.isBattery && hubModel.groupName != null) {
      debugPrint('SignalR Provider: 배터리 수신 - groupName: ${hubModel.groupName}, json: ${hubModel.json}');
      if (hubModel.json != null) {
        try {
          final data = jsonDecode(hubModel.json!);
          final value = (data['Value'] as num?)?.toDouble();
          debugPrint('SignalR Provider: 배터리 값 파싱 - value: $value');
          if (value != null && _onBatteryUpdate != null) {
            _onBatteryUpdate!(hubModel.groupName!, value);
          }
        } catch (e) {
          debugPrint('SignalR Provider: 배터리 파싱 실패 - $e');
        }
      }
    }

    notifyListeners();
  }

  /// 배터리 업데이트 콜백 등록
  void Function(String dollId, double value)? _onBatteryUpdate;
  void setOnBatteryUpdate(void Function(String dollId, double value)? callback) {
    _onBatteryUpdate = callback;
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
