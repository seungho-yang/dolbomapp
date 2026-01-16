# 카카오 로그인 통합 가이드

## 📱 지원 플랫폼

- ✅ Android (API 21+)
- ✅ iOS (13.0+)

---

## 🎯 구현 완료 사항

### 1. Flutter 코드
- ✅ 카카오 SDK 초기화 (`main.dart`)
- ✅ 로그인 서비스 구현 (`KakaoLoginService`)
- ✅ 인증 Provider 구현 (`AuthProvider`)
- ✅ 로그인 화면 연동
- ✅ 자동 로그인 체크

### 2. Android 설정
- ✅ AndroidManifest.xml 설정
- ✅ URL 스킴 등록
- ✅ 카카오톡 쿼리 추가
- ✅ 최소 SDK 21 설정

### 3. iOS 설정
- ✅ Info.plist 설정
- ✅ URL 스킴 등록
- ✅ LSApplicationQueriesSchemes 추가
- ✅ Podfile 생성 (iOS 13.0 설정)

---

## 🚀 빠른 시작

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 카카오 개발자 콘솔 설정
1. [카카오 개발자 콘솔](https://developers.kakao.com/) 접속
2. 애플리케이션 생성 또는 선택
3. 플랫폼 추가:
   - **Android**: 패키지명 + 키 해시 등록
   - **iOS**: Bundle ID 등록

### 3. 네이티브 앱 키 확인
- 카카오 개발자 콘솔 → 앱 설정 → 앱 키
- **네이티브 앱 키**를 복사

### 4. 앱 키 설정
`lib/utils/constants.dart` 파일에서:

```dart
class KakaoConstants {
  static const String nativeAppKey = '여기에_네이티브_앱_키_입력';
}
```

### 5. Android 실행
```bash
flutter run -d android
```

### 6. iOS 실행
```bash
cd ios
pod install
cd ..
flutter run -d ios
```

---

## 🔑 로그인 플로우

```
사용자가 로그인 버튼 클릭
    ↓
카카오톡 앱 설치 여부 확인
    ↓
┌──────────┬──────────┐
│ 설치됨    │ 미설치    │
│          │          │
│ 카카오톡  │ 카카오    │
│ 로그인    │ 계정 로그인│
└──────────┴──────────┘
    ↓
카카오 사용자 정보 가져오기
    ↓
서버에 사용자 정보 전송
    ↓
로컬에 토큰 저장
    ↓
메인 페이지로 이동
```

---

## 💻 코드 사용법

### 로그인
```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final success = await authProvider.loginWithKakao();

if (success) {
  // 로그인 성공
  print('사용자 ID: ${authProvider.userId}');
  Navigator.push(...);
} else {
  // 로그인 실패
  print('에러: ${authProvider.error}');
}
```

### 로그아웃
```dart
await authProvider.logout();
```

### 회원 탈퇴
```dart
final success = await authProvider.unlink();
```

### 로그인 상태 확인
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isLoggedIn) {
      return MainPage();
    } else {
      return LoginScreen();
    }
  },
)
```

---

## 🔧 상세 설정

### Android
자세한 내용은 [ANDROID_SETUP.md](./ANDROID_SETUP.md) 참고

**주요 파일:**
- `android/app/src/main/AndroidManifest.xml`
- `android/app/build.gradle.kts`

### iOS
자세한 내용은 [IOS_SETUP.md](./IOS_SETUP.md) 참고

**주요 파일:**
- `ios/Runner/Info.plist`
- `ios/Podfile`

---

## 🐛 문제 해결

### 1. "카카오톡이 설치되어 있지 않습니다" (Android)
- AndroidManifest.xml의 `<queries>` 태그 확인
- 카카오톡 패키지명이 올바르게 추가되었는지 확인

### 2. "URL 스킴을 찾을 수 없습니다"
- Android: AndroidManifest.xml의 URL 스킴 확인
- iOS: Info.plist의 CFBundleURLSchemes 확인
- 네이티브 앱 키가 일치하는지 확인

### 3. "로그인은 성공했지만 서버 연동 실패"
- API 서버 URL 확인 (`lib/utils/constants.dart`)
- 네트워크 연결 확인
- 서버 로그 확인

### 4. iOS 빌드 오류
```bash
cd ios
pod deintegrate
pod install
```

### 5. "Deployment target is too low"
- Xcode에서 Deployment Target을 13.0으로 설정
- Podfile의 platform 버전 확인

---

## 📝 체크리스트

### 배포 전 확인사항

- [ ] 카카오 개발자 콘솔에 앱 등록
- [ ] Android 플랫폼 등록 (패키지명 + 키 해시)
- [ ] iOS 플랫폼 등록 (Bundle ID)
- [ ] 본인의 네이티브 앱 키로 변경
- [ ] Android Package Name 변경 (com.example.* 제거)
- [ ] iOS Bundle ID 변경 (com.example.* 제거)
- [ ] 프로덕션 서버 URL 설정
- [ ] 카카오 로그인 동의 항목 설정
- [ ] 카카오톡 채널 등록 (선택사항)

---

## 🔗 참고 자료

- [Kakao Flutter SDK 공식 문서](https://developers.kakao.com/docs/latest/ko/sdk-download/flutter)
- [카카오 로그인 REST API](https://developers.kakao.com/docs/latest/ko/kakaologin/rest-api)
- [카카오 개발자 포럼](https://devtalk.kakao.com/)

---

## ⚠️ 주의사항

1. **네이티브 앱 키 보안**
   - 네이티브 앱 키는 클라이언트에 노출됨
   - REST API 키나 Admin 키는 절대 클라이언트에 포함하지 말 것
   - 서버-서버 통신에만 사용

2. **테스트 환경**
   - 개발 단계: 테스트 앱으로 등록
   - 배포 단계: 정식 앱으로 전환 필요

3. **개인정보 처리**
   - 카카오 사용자 정보는 카카오 정책에 따라 처리
   - 개인정보 처리방침에 카카오 로그인 명시
   - 필수 동의 항목만 요청

4. **에러 핸들링**
   - 네트워크 오류
   - 사용자 취소
   - 토큰 만료
   - 서버 오류
   → 모든 경우에 대한 UI 피드백 제공

---

## 📞 지원

문제가 발생하면:
1. 이 문서의 **문제 해결** 섹션 확인
2. [카카오 개발자 포럼](https://devtalk.kakao.com/) 검색
3. [Kakao Flutter SDK GitHub](https://github.com/kakao/kakao_flutter_sdk) 이슈 등록
