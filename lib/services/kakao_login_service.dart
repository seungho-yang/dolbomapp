import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class KakaoLoginService {
  // 싱글톤 패턴
  static final KakaoLoginService _instance = KakaoLoginService._internal();
  factory KakaoLoginService() => _instance;
  KakaoLoginService._internal();

  // 카카오 SDK 초기화
  static void initialize(String nativeAppKey) {
    KakaoSdk.init(nativeAppKey: nativeAppKey);
  }

  // 키 해시 가져오기 (카카오 개발자 콘솔 등록용)
  static Future<String> getKeyHash() async {
    try {
      final keyHash = await KakaoSdk.origin;
      return keyHash;
    } catch (e) {
      debugPrint('키 해시 가져오기 실패: $e');
      return '키 해시를 가져올 수 없습니다';
    }
  }

  // 카카오 로그인 (카카오톡 앱 우선, 없으면 카카오 계정 로그인)
  Future<OAuthToken?> login() async {
    try {
      // 카카오톡 설치 여부 확인
      bool kakaoTalkInstalled = await isKakaoTalkInstalled();
      debugPrint('========================================');
      debugPrint('카카오톡 설치 여부: $kakaoTalkInstalled');
      debugPrint('========================================');

      OAuthToken token;

      if (kakaoTalkInstalled) {
        // 카카오톡으로 로그인
        debugPrint('카카오톡 앱으로 로그인 시도...');
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
          debugPrint('카카오톡 앱 로그인 성공');
          return token;
        } catch (error) {
          debugPrint('카카오톡 앱 로그인 실패: $error');
          // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우
          // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리
          if (error is PlatformException && error.code == 'CANCELED') {
            return null;
          }
          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
          debugPrint('카카오 계정으로 로그인 시도...');
          token = await UserApi.instance.loginWithKakaoAccount();
          return token;
        }
      } else {
        // 카카오계정으로 로그인
        debugPrint('카카오톡 미설치 - 카카오 계정으로 로그인 시도...');
        token = await UserApi.instance.loginWithKakaoAccount();
        return token;
      }
    } catch (error) {
      debugPrint('카카오 로그인 실패: $error');
      return null;
    }
  }

  // 사용자 정보 가져오기
  Future<User?> getUserInfo() async {
    try {
      User user = await UserApi.instance.me();
      return user;
    } catch (error) {
      debugPrint('사용자 정보 요청 실패: $error');
      return null;
    }
  }

  // 로그아웃
  Future<bool> logout() async {
    try {
      await UserApi.instance.logout();
      return true;
    } catch (error) {
      debugPrint('로그아웃 실패: $error');
      return false;
    }
  }

  // 회원 탈퇴
  Future<bool> unlink() async {
    try {
      await UserApi.instance.unlink();
      return true;
    } catch (error) {
      debugPrint('회원 탈퇴 실패: $error');
      return false;
    }
  }

  // 토큰 정보 확인
  Future<AccessTokenInfo?> getAccessTokenInfo() async {
    try {
      AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
      return tokenInfo;
    } catch (error) {
      debugPrint('토큰 정보 확인 실패: $error');
      return null;
    }
  }

  // 토큰 존재 여부 확인
  Future<bool> hasToken() async {
    return await AuthApi.instance.hasToken();
  }
}
