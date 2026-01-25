import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

/// GlobalUserInfo - 전역 사용자 정보 관리 (Java의 GlobalLogin과 동일한 역할)
///
/// 사용 방법:
/// ```dart
/// // userId 가져오기 (Java: GlobalLogin.getInstance().getUserInfo().getUserId())
/// final userId = GlobalUserInfo.instance.userId;
///
/// // userId 설정 (Java: GlobalLogin.getInstance().getUserInfo().setUserId())
/// GlobalUserInfo.instance.setUserId('7748');
///
/// // int로 가져오기
/// final userIdInt = GlobalUserInfo.instance.userIdAsInt;
/// ```
class GlobalUserInfo {
  // 싱글톤 인스턴스
  static final GlobalUserInfo _instance = GlobalUserInfo._internal();
  static GlobalUserInfo get instance => _instance;

  GlobalUserInfo._internal();

  // 사용자 정보
  String? _userId;
  String? _email;
  String? _nickname;
  String? _profileImageUrl;
  bool _isTestMode = false;

  // Getters
  String? get userId => _userId;
  String? get email => _email;
  String? get nickname => _nickname;
  String? get profileImageUrl => _profileImageUrl;
  bool get isTestMode => _isTestMode;

  /// userId를 int로 변환하여 반환 (API 호출용)
  int? get userIdAsInt {
    if (_userId == null) return null;
    return int.tryParse(_userId!);
  }

  /// userId 설정 (Java의 setUserId와 동일)
  void setUserId(String userId) {
    _userId = userId;
    debugPrint('GlobalUserInfo: userId 설정됨 - $userId');
  }

  /// 카카오 사용자 정보 설정
  void setKakaoUserInfo({
    required String userId,
    String? email,
    String? nickname,
    String? profileImageUrl,
  }) {
    _userId = userId;
    _email = email;
    _nickname = nickname;
    _profileImageUrl = profileImageUrl;
    _isTestMode = false;
    debugPrint('GlobalUserInfo: 카카오 사용자 정보 설정됨 - userId: $userId');
  }

  /// 테스트 사용자로 설정 (개발용)
  void setTestUser([String? testUserId]) {
    _userId = testUserId ?? TestUserIds.defaultUser;
    _email = 'test@test.com';
    _nickname = '테스트 사용자';
    _profileImageUrl = null;
    _isTestMode = true;
    debugPrint('GlobalUserInfo: 테스트 사용자 설정됨 - userId: $_userId');
  }

  /// 사용자 정보 초기화 (로그아웃 시)
  void clear() {
    _userId = null;
    _email = null;
    _nickname = null;
    _profileImageUrl = null;
    _isTestMode = false;
    debugPrint('GlobalUserInfo: 사용자 정보 초기화됨');
  }

  /// 로그인 여부 확인
  bool get isLoggedIn => _userId != null && _userId!.isNotEmpty;

  @override
  String toString() {
    return 'GlobalUserInfo(userId: $_userId, email: $_email, isTestMode: $_isTestMode)';
  }
}
