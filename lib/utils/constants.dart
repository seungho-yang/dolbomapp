class ApiConstants {
  static const String baseUrl = 'https://mrmind.kr/mind/';

  // 엔드포인트
  static const String app = 'app';
  static const String notification = 'notification';
  static const String alarm = 'alarm';
  static const String ai = 'ai';
  static const String dangerous = 'dangerous';
  static const String link = 'link';
  static const String contents = 'contents';
  static const String authorize = 'authorize';
  static const String initialize = 'initialize';
  static const String as = 'as';
  static const String dialog = 'dialog';
  static const String matching = 'matching';
}

class StorageKeys {
  static const String userId = 'user_id';
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String kakaoToken = 'kakao_token';
  static const String fcmToken = 'fcm_token';
  static const String isLoggedIn = 'is_logged_in';
}

class KakaoConstants {
  // TODO: 실제 카카오 앱 키로 변경 필요
  static const String nativeAppKey = '1899200f5e3244d9354cdd30266e521d';
}

/// 테스트용 더미 userId (카카오 로그인 연동 전 개발용)
class TestUserIds {
  // 실제 카카오 사용자 ID
  static const String kakaoUser = '2285656840';

  // 인형 ID (dialog API용)
  static const String doll1 = '7748';
  static const String doll2 = '4616';

  // 기본 테스트 사용자 (카카오 사용자 ID)
  static const String defaultUser = kakaoUser;

  // 모든 테스트 사용자 목록
  static const List<String> all = [kakaoUser, doll1, doll2];
}
