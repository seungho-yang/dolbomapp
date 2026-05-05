import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/message_profile_model.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';

/// UserProvider - 보호대상자(인형) 목록 관리
/// Java의 GlobalLogin.getShared_ArrayList().getMessage_profile_models()와 동일한 역할
class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<MessageProfileModel> _users = [];
  ProfileModel? _selectedUser;
  bool _isLoading = false;
  bool _isLoaded = false; // 최초 로드 여부
  String? _error;
  final Set<String> _activeDollIds = {}; // 배터리 수신된 인형 ID

  List<MessageProfileModel> get users => _users;
  ProfileModel? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;

  /// 배터리 수신 여부로 활성 판단
  bool isDollActive(String dollId) => _activeDollIds.contains(dollId);

  /// 보호대상자 목록 조회 (Home.java 생성자의 API 호출과 동일)
  /// GET /app?id={userId}
  Future<void> loadUsers(int userId) async {
    // 이미 로드 중이면 스킵
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('UserProvider: 보호대상자 목록 로드 시작 - userId: $userId');
      debugPrint('UserProvider: API 요청 URL: https://mrmind.kr/mind/app?id=$userId');
      final response = await _apiService.getMessageProfileList(userId);

      debugPrint('UserProvider: API 응답 코드: ${response.statusCode}');
      debugPrint('UserProvider: API 응답 헤더: ${response.headers}');
      debugPrint('UserProvider: API 응답 데이터 타입: ${response.data?.runtimeType}');
      debugPrint('UserProvider: API 응답 데이터: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        // 응답 데이터가 String인 경우 JSON 파싱
        List<dynamic> data;
        if (response.data is String) {
          final jsonStr = response.data as String;
          if (jsonStr.isEmpty) {
            debugPrint('UserProvider: 응답 데이터 비어있음');
            _users = [];
            _isLoaded = true;
            _isLoading = false;
            notifyListeners();
            return;
          }
          data = jsonDecode(jsonStr);
        } else {
          data = response.data;
        }

        debugPrint('UserProvider: 보호대상자 수: ${data.length}');

        _users = data.map((json) {
          final model = MessageProfileModel.fromJson(json);
          // 기본 배터리 이미지 설정
          model.batteryImagePath = 'assets/images/battery.png';
          return model;
        }).toList();

        _isLoaded = true;
        debugPrint('UserProvider: 로드 완료 - ${_users.length}명');
      } else if (response.statusCode == 204) {
        // No Content - 연결된 인형 없음
        debugPrint('UserProvider: 연결된 인형 없음 (204)');
        _users = [];
        _isLoaded = true;
      } else {
        debugPrint('UserProvider: API 응답 실패 - ${response.statusCode}');
        _error = '데이터를 불러오는데 실패했습니다.';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('UserProvider: 로드 오류 - $e');
      _error = '서버 통신이 원활하지 않습니다.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 배터리 상태 업데이트 (SignalR mode 'B' 수신 시)
  void updateBattery(String dollId, double value) {
    _activeDollIds.add(dollId);
    for (var user in _users) {
      if (user.id == dollId) {
        if (value > 0.9) {
          user.batteryImagePath = 'assets/images/full.png';
        } else if (value < 0.2) {
          user.batteryImagePath = 'assets/images/low.png';
        } else {
          user.batteryImagePath = 'assets/images/middle.png';
        }
        notifyListeners();
        break;
      }
    }
  }

  /// 특정 보호대상자의 프로필 선택
  void selectUserProfile(ProfileModel profile) {
    _selectedUser = profile;
    notifyListeners();
  }

  /// 이름으로 검색된 사용자 목록 반환
  List<MessageProfileModel> searchByDollId(String query) {
    if (query.isEmpty) return _users;
    return _users.where((user) =>
      user.id?.contains(query) ?? false
    ).toList();
  }

  /// 보호대상자 프로필 업데이트
  Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.patchAiProfile(profileData);

      if (response.statusCode == 200) {
        // 로컬 데이터 업데이트
        final profileId = profileData['id'];
        if (profileId != null) {
          for (var user in _users) {
            if (user.profile?.id == profileId) {
              user.profile = user.profile!.copyWith(
                name: profileData['name'] as String?,
                protectedPerson: profileData['protectedPerson'] as String?,
                protectedPhone: profileData['protectedPhone'] as String?,
                phone: profileData['phone'] as String?,
                address: profileData['address'] as String?,
                agency: profileData['agency'] as String?,
                male: profileData['male'] as bool?,
              );
              break;
            }
          }
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

  /// 새 인형 추가 (검색 후 연결 시)
  void addUser(MessageProfileModel user) {
    _users.add(user);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 데이터 새로고침
  Future<void> refresh(int userId) async {
    _isLoaded = false;
    await loadUsers(userId);
  }
}
