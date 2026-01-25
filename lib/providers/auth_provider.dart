import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/kakao_login_service.dart';
import '../services/global_user_info.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final KakaoLoginService _kakaoLoginService = KakaoLoginService();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isTestMode = false; // 테스트 모드 플래그
  String? _userId;
  UserModel? _currentUser;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get userId => _userId;
  UserModel? get currentUser => _currentUser;
  String? get error => _error;

  AuthProvider() {
    _checkLoginStatus();
  }

  // 자동 로그인 바이패스 플래그 (개발용)
  static const bool _bypassAutoLogin = false;

  // 로그인 상태 확인 (자동 로그인)
  Future<void> _checkLoginStatus() async {
    // 자동 로그인 바이패스
    if (_bypassAutoLogin) {
      await _clearLoginInfo();
      _isInitialized = true;
      notifyListeners();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(StorageKeys.isLoggedIn) ?? false;
      _userId = prefs.getString(StorageKeys.userId);

      // 저장된 로그인 상태가 있는 경우 토큰 유효성 검증
      if (_isLoggedIn) {
        final hasToken = await _kakaoLoginService.hasToken();
        if (!hasToken) {
          // 토큰이 없으면 로그아웃 처리 (테스트 모드가 아닐 때만)
          if (!_isTestMode) {
            await _clearLoginInfo();
          }
          _isInitialized = true;
          notifyListeners();
          return;
        }

        // 토큰 유효성 검증 (Android 원본의 accessTokenInfo() 호출과 동일)
        final tokenInfo = await _kakaoLoginService.getAccessTokenInfo();
        if (tokenInfo == null) {
          // 토큰이 만료되었거나 유효하지 않으면 로그아웃 처리 (테스트 모드가 아닐 때만)
          if (!_isTestMode) {
            await _clearLoginInfo();
          }
          _isInitialized = true;
          notifyListeners();
          return;
        }

        // 토큰이 유효하면 사용자 정보 가져오기
        final kakaoUser = await _kakaoLoginService.getUserInfo();
        if (kakaoUser != null) {
          _userId = kakaoUser.id.toString();
          debugPrint('자동 로그인 성공: $_userId');
        }
      }
    } catch (e) {
      debugPrint('로그인 상태 확인 실패: $e');
      // 테스트 모드가 아닐 때만 로그인 정보 클리어
      if (!_isTestMode) {
        await _clearLoginInfo();
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  // 로그인 정보 클리어 (내부용)
  Future<void> _clearLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _userId = null;
    _currentUser = null;
    _error = null;
  }

  // 테스트용 사용자 설정 (개발용)
  // Java의 GlobalLogin.getInstance().getUserInfo().setUserId()와 동일
  Future<void> setTestUser([String? userId]) async {
    final testUserId = userId ?? TestUserIds.defaultUser;
    _isTestMode = true; // 테스트 모드 활성화
    _userId = testUserId;
    _isLoggedIn = true;
    _isInitialized = true;

    // GlobalUserInfo 싱글톤에도 설정 (Provider 없이 전역 접근 가능)
    GlobalUserInfo.instance.setTestUser(testUserId);

    debugPrint('테스트 사용자 설정: $testUserId');
    notifyListeners();
  }

  // 카카오 로그인
  Future<bool> loginWithKakao() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. 카카오 로그인
      final token = await _kakaoLoginService.login();

      if (token == null) {
        _error = '로그인이 취소되었습니다.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. 사용자 정보 가져오기
      final kakaoUser = await _kakaoLoginService.getUserInfo();

      if (kakaoUser == null) {
        _error = '사용자 정보를 가져올 수 없습니다.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 3. 서버에 사용자 정보 전송
      final userData = _buildUserDataFromKakaoUser(kakaoUser, token);
      final response = await _apiService.postUser(userData);

      if (response.statusCode == 200) {
        // 4. 로그인 정보 저장
        _currentUser = UserModel.fromJson(userData);
        _userId = kakaoUser.id.toString();
        await _saveLoginInfo(token.accessToken, token.refreshToken ?? '');
        _isLoggedIn = true;
        _isLoading = false;

        // GlobalUserInfo 싱글톤에도 설정 (Provider 없이 전역 접근 가능)
        GlobalUserInfo.instance.setKakaoUserInfo(
          userId: _userId!,
          email: kakaoUser.kakaoAccount?.email,
          nickname: kakaoUser.kakaoAccount?.profile?.nickname,
          profileImageUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        );

        notifyListeners();
        return true;
      }

      _error = '서버 연동에 실패했습니다.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '로그인 중 오류가 발생했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 카카오 사용자 정보를 서버 전송 형식으로 변환
  Map<String, dynamic> _buildUserDataFromKakaoUser(User kakaoUser, OAuthToken token) {
    return {
      'Id': kakaoUser.id.toString(),
      'Token': token.accessToken,
      'RefreshToken': token.refreshToken,
      'Name': kakaoUser.kakaoAccount?.name ?? '',
      'NickName': kakaoUser.kakaoAccount?.profile?.nickname ?? '',
      'Email': kakaoUser.kakaoAccount?.email ?? '',
      'Gender': kakaoUser.kakaoAccount?.gender?.name ?? '',
      'Birthday': kakaoUser.kakaoAccount?.birthday ?? '',
      'PictureUrl': kakaoUser.kakaoAccount?.profile?.profileImageUrl ?? '',
      'LoggedInWithSNSAccount': true,
      'PhoneNumber': kakaoUser.kakaoAccount?.phoneNumber ?? '',
    };
  }

  // 로그인 정보 저장
  Future<void> _saveLoginInfo(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isLoggedIn, true);
    if (_userId != null) {
      await prefs.setString(StorageKeys.userId, _userId!);
    }
    await prefs.setString(StorageKeys.accessToken, accessToken);
    await prefs.setString(StorageKeys.refreshToken, refreshToken);
  }

  // 로그아웃
  Future<void> logout() async {
    // 카카오 로그아웃
    await _kakaoLoginService.logout();

    // 로컬 저장소 클리어
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _isLoggedIn = false;
    _userId = null;
    _currentUser = null;
    _error = null;
    _isTestMode = false;

    // GlobalUserInfo 싱글톤도 클리어
    GlobalUserInfo.instance.clear();

    notifyListeners();
  }

  // 회원 탈퇴
  Future<bool> unlink() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _kakaoLoginService.unlink();

      if (success) {
        await logout();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = '회원 탈퇴에 실패했습니다.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '회원 탈퇴 중 오류가 발생했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Firebase 토큰 저장
  Future<void> saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.fcmToken, token);

    // 서버에 FCM 토큰 전송
    try {
      await _apiService.postNotification({
        'token': token,
        'userId': _userId,
      });
    } catch (e) {
      debugPrint('FCM 토큰 전송 실패: $e');
    }
  }
}
