import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../services/api_service.dart';

/// AlarmProvider - 알람 상태 관리
/// Java의 Alarm.java Fragment와 동일한 역할
class AlarmProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AlarmModel> _alarms = [];
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _error;

  List<AlarmModel> get alarms => _alarms;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;

  /// 알람 목록 조회
  /// GET /alarm?id={userId}
  Future<void> loadAlarms(int userId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('AlarmProvider: 알람 목록 로드 시작 - userId: $userId');
      final response = await _apiService.getAlarms(userId);

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data;
        if (response.data is String) {
          final jsonStr = response.data as String;
          if (jsonStr.isEmpty) {
            _alarms = [];
            _isLoaded = true;
            _isLoading = false;
            notifyListeners();
            return;
          }
          data = jsonDecode(jsonStr);
        } else {
          data = response.data;
        }

        _alarms = data.map((json) => AlarmModel.fromJson(json)).toList();
        _isLoaded = true;
        debugPrint('AlarmProvider: 알람 ${_alarms.length}개 로드 완료');
      } else {
        _alarms = [];
        _isLoaded = true;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('AlarmProvider: 로드 오류 - $e');
      _error = '서버 통신이 원활하지 않습니다.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 알람 추가
  /// POST /alarm
  Future<bool> addAlarm(AlarmModel alarm, int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('AlarmProvider: 알람 추가 - ${alarm.title}');
      final response = await _apiService.postAlarm(alarm.toJson());

      if (response.statusCode == 200) {
        // 서버에서 알람 목록 다시 조회하여 최신 데이터 유지
        await loadAlarms(userId);
        return true;
      }

      _isLoading = false;
      _error = '알람 추가에 실패했습니다.';
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('AlarmProvider: 추가 오류 - $e');
      _error = '서버 통신이 원활하지 않습니다.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 알람 수정
  /// PATCH /alarm?id={userId}
  Future<bool> updateAlarm(int userId, AlarmModel alarm) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('AlarmProvider: 알람 수정 - ${alarm.id}');
      final response = await _apiService.patchAlarm(userId, alarm.toJson());

      if (response.statusCode == 200) {
        // 로컬 데이터 업데이트
        final index = _alarms.indexWhere((a) => a.id == alarm.id);
        if (index != -1) {
          _alarms[index] = alarm;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      _error = '알람 수정에 실패했습니다.';
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('AlarmProvider: 수정 오류 - $e');
      _error = '서버 통신이 원활하지 않습니다.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 알람 삭제
  /// DELETE /alarm?id={alarmId}
  Future<bool> deleteAlarm(String alarmId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('AlarmProvider: 알람 삭제 - $alarmId');
      final response = await _apiService.deleteAlarm(alarmId);

      if (response.statusCode == 200) {
        _alarms.removeWhere((alarm) => alarm.id == alarmId);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      _error = '알람 삭제에 실패했습니다.';
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('AlarmProvider: 삭제 오류 - $e');
      _error = '서버 통신이 원활하지 않습니다.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 알람 ON/OFF 토글
  /// PATCH /alarm?id={userId} with AlarmPatchModel
  Future<bool> toggleAlarm(String alarmId, int userId) async {
    final index = _alarms.indexWhere((alarm) => alarm.id == alarmId);
    if (index == -1) return false;

    final alarm = _alarms[index];
    final newOnState = !(alarm.on ?? false);

    // 즉시 UI 업데이트 (낙관적 업데이트)
    _alarms[index] = alarm.copyWith(on: newOnState);
    notifyListeners();

    try {
      final patchModel = AlarmPatchModel(id: alarmId, on: newOnState);
      final response = await _apiService.patchAlarm(userId, patchModel.toJson());

      if (response.statusCode == 200) {
        debugPrint('AlarmProvider: 알람 토글 성공 - $alarmId: $newOnState');
        return true;
      }

      // 실패 시 롤백
      _alarms[index] = alarm;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('AlarmProvider: 토글 오류 - $e');
      // 실패 시 롤백
      _alarms[index] = alarm;
      notifyListeners();
      return false;
    }
  }

  /// AI ID로 알람 필터링
  List<AlarmModel> getAlarmsByAi(int ai) {
    return _alarms.where((alarm) => alarm.ai == ai).toList();
  }

  /// 검색 (AI ID로)
  List<AlarmModel> searchByAi(String query) {
    if (query.isEmpty) return _alarms;
    return _alarms.where((alarm) =>
      alarm.ai?.toString().contains(query) ?? false
    ).toList();
  }

  /// 데이터 새로고침
  Future<void> refresh(int userId) async {
    _isLoaded = false;
    await loadAlarms(userId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
