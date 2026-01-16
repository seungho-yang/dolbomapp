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
  Future<void> loadMessages(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMessages(userId);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        _messagesByUser[userId] =
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
}
