import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/message_chat_model.dart';
import '../services/api_service.dart';

class MessageProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  final Map<String, List<MessageChatModel>> _messagesByUser = {};
  bool _isLoading = false;
  String? _error;

  Map<String, List<MessageChatModel>> get messagesByUser => _messagesByUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 특정 사용자의 메시지 목록 조회
  Future<void> loadMessages(String odId) async {
    debugPrint('MessageProvider: loadMessages 시작 - odId: $odId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMessages(odId);
      debugPrint('MessageProvider: API 응답 코드: ${response.statusCode}');
      debugPrint('MessageProvider: API 응답 데이터 타입: ${response.data?.runtimeType}');

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data;
        if (response.data is String) {
          final jsonStr = response.data as String;
          if (jsonStr.isEmpty) {
            _messagesByUser[odId] = [];
            _isLoading = false;
            notifyListeners();
            return;
          }
          data = jsonDecode(jsonStr);
        } else {
          data = response.data;
        }
        debugPrint('MessageProvider: 메시지 수: ${data.length}');
        _messagesByUser[odId] =
            data.map((json) => MessageChatModel.fromJson(json)).toList();
        debugPrint('MessageProvider: 파싱 완료 - ${_messagesByUser[odId]?.length}개');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('MessageProvider: 오류 - $e');
      debugPrint('MessageProvider: 스택트레이스 - $stackTrace');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 추가 메시지 로드 (페이지네이션)
  Future<void> loadMoreMessages(String userId, int tick) async {
    try {
      final response = await _apiService.getMoreMessages(userId, tick);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        final newMessages =
            data.map((json) => MessageChatModel.fromJson(json)).toList();

        if (_messagesByUser[userId] != null) {
          _messagesByUser[userId]!.addAll(newMessages);
        } else {
          _messagesByUser[userId] = newMessages;
        }

        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 위험 메시지 조회
  Future<void> loadDangerMessages(String userId, int tick, int order) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getDangerMessages(userId, tick, order);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        _messagesByUser['danger_$userId'] =
            data.map((json) => MessageChatModel.fromJson(json)).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 특정 사용자의 메시지 가져오기
  List<MessageChatModel> getMessagesForUser(String userId) {
    return _messagesByUser[userId] ?? [];
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 실시간 메시지 추가 (SignalR에서 수신한 메시지)
  void addRealtimeMessage(String odId, MessageChatModel message) {
    if (_messagesByUser[odId] == null) {
      _messagesByUser[odId] = [];
    }

    // 중복 메시지 방지
    final exists = _messagesByUser[odId]!.any((m) =>
        m.message == message.message && m.reception == message.reception);

    if (!exists) {
      _messagesByUser[odId]!.insert(0, message);
      notifyListeners();
    }
  }

  // 특정 사용자의 메시지 캐시 삭제
  void clearMessagesForUser(String userId) {
    _messagesByUser.remove(userId);
    notifyListeners();
  }
}
