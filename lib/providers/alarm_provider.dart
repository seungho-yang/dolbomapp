import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../services/api_service.dart';

class AlarmProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AlarmModel> _alarms = [];
  bool _isLoading = false;
  String? _error;

  List<AlarmModel> get alarms => _alarms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 알람 목록 조회
  Future<void> loadAlarms(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getAlarms(userId);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        _alarms = data.map((json) => AlarmModel.fromJson(json)).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 알람 추가
  Future<bool> addAlarm(AlarmModel alarm) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.postAlarm(alarm.toJson());

      if (response.statusCode == 200) {
        _alarms.add(alarm);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 알람 수정
  Future<bool> updateAlarm(int id, AlarmModel alarm) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.patchAlarm(id, alarm.toJson());

      if (response.statusCode == 200) {
        final index = _alarms.indexWhere((a) => a.id == alarm.id);
        if (index != -1) {
          _alarms[index] = alarm;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 알람 삭제
  Future<bool> deleteAlarm(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.deleteAlarm(id);

      if (response.statusCode == 200) {
        _alarms.removeWhere((alarm) => alarm.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 알람 ON/OFF 토글
  void toggleAlarm(String id) {
    final index = _alarms.indexWhere((alarm) => alarm.id == id);
    if (index != -1) {
      final alarm = _alarms[index];
      _alarms[index] = AlarmModel(
        id: alarm.id,
        title: alarm.title,
        contents: alarm.contents,
        on: !(alarm.on ?? false),
        classification: alarm.classification,
        division: alarm.division,
        time: alarm.time,
        ai: alarm.ai,
        name: alarm.name,
      );
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
