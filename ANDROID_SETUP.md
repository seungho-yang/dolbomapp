# Android 카카오 로그인 설정 가이드

## 완료된 설정 ✅

### 1. AndroidManifest.xml
`android/app/src/main/AndroidManifest.xml`에 다음이 추가되었습니다:

```xml
<!-- 인터넷 권한 -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- 카카오 로그인 커스텀 URL 스킴 -->
<activity
    android:name="com.kakao.sdk.flutter.AuthCodeCustomTabsActivity"
    android:exported="true">
    <intent-filter android:label="flutter_web_auth">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="kakao1899200f5e3244d9354cdd30266e521d" android:host="oauth"/>
    </intent-filter>
</activity>

<!-- 카카오톡 앱 확인을 위한 쿼리 -->
<queries>
    <package android:name="com.kakao.talk" />
</queries>
```

### 2. build.gradle.kts
`android/app/build.gradle.kts`에서:

```kotlin
minSdk = 21  // 카카오 SDK 최소 요구사항
```

---

## 카카오 개발자 콘솔 설정

### 1. 앱 등록
[카카오 개발자 콘솔](https://developers.kakao.com/)에서:

1. **내 애플리케이션** → **애플리케이션 추가하기**
2. 앱 이름: "돌봄e음" (또는 원하는 이름)
3. 회사명 입력 (선택)

### 2. Android 플랫폼 추가
1. **앱 설정** → **플랫폼** → **Android 플랫폼 등록**
2. 패키지명 입력: `com.example.dolbom_e_eum`
   - 실제 배포 시 고유한 패키지명으로 변경 필요
3. 마켓 URL: (선택사항)

### 3. 키 해시 등록

#### 개발용 키 해시 생성

**Windows:**
```bash
keytool -exportcert -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android -keypass android | openssl sha1 -binary | openssl base64
```

**Mac/Linux:**
```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64
```

#### 릴리즈용 키 해시 생성

**Windows:**
```bash
keytool -exportcert -alias <릴리즈_키_별칭> -keystore <키스토어_경로> | openssl sha1 -binary | openssl base64
```

**Mac/Linux:**
```bash
keytool -exportcert -alias <릴리즈_키_별칭> -keystore <키스토어_경로> | openssl sha1 -binary | openssl base64
```

생성된 키 해시를 카카오 개발자 콘솔에 등록합니다.

### 4. 네이티브 앱 키 확인
- **앱 설정** → **앱 키**
- **네이티브 앱 키** 복사
- `lib/utils/constants.dart`에 설정:

```dart
class KakaoConstants {
  static const String nativeAppKey = '여기에_복사한_키_입력';
}
```

---

## 빌드 및 실행

### 1. 디버그 빌드
```bash
flutter run -d android
```

### 2. 릴리즈 빌드
```bash
flutter build apk --release
```

또는

```bash
flutter build appbundle --release
```

---

## 패키지명 변경 (배포 시 필수)

### 1. build.gradle.kts 수정
`android/app/build.gradle.kts`:

```kotlin
defaultConfig {
    applicationId = "com.yourcompany.dolbom_e_eum"  // 변경
    // ...
}
```

### 2. AndroidManifest.xml 확인
namespace가 자동으로 업데이트되는지 확인

### 3. 카카오 URL 스킴 업데이트
AndroidManifest.xml의 카카오 URL 스킴도 새 패키지명에 맞게 변경:

```xml
<data android:scheme="kakao새로운_네이티브_앱_키" android:host="oauth"/>
```

### 4. 카카오 개발자 콘솔 업데이트
- 새 패키지명 등록
- 새 키 해시 등록

---

## 문제 해결

### 1. "카카오톡을 찾을 수 없습니다"

**원인**: AndroidManifest.xml의 `<queries>` 태그 누락

**해결**:
```xml
<queries>
    <package android:name="com.kakao.talk" />
</queries>
```

### 2. "인증 코드를 받을 수 없습니다"

**원인**: URL 스킴 설정 오류

**확인사항**:
1. AndroidManifest.xml의 URL 스킴이 `kakao{네이티브_앱_키}` 형식인지
2. 네이티브 앱 키가 정확한지
3. AuthCodeCustomTabsActivity가 올바르게 등록되었는지

### 3. "키 해시가 일치하지 않습니다"

**해결**:
1. 앱에서 실제 사용 중인 키 해시 확인:
```dart
// KakaoLoginService에 임시로 추가
final keyHash = await KakaoSdk.origin;
debugPrint('Current Key Hash: $keyHash');
```
2. 출력된 키 해시를 카카오 개발자 콘솔에 등록

### 4. "최소 SDK 버전 오류"

**해결**:
`android/app/build.gradle.kts`:
```kotlin
minSdk = 21  // 21 이상 설정
```

### 5. Gradle 빌드 오류

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 배포 체크리스트

### Google Play Console 배포 전

- [ ] 패키지명을 고유한 이름으로 변경
- [ ] 릴리즈 키스토어 생성
- [ ] 릴리즈 키 해시를 카카오에 등록
- [ ] 카카오 개발자 콘솔에 릴리즈 패키지명 등록
- [ ] ProGuard/R8 설정 확인
- [ ] 네이티브 앱 키가 올바른지 확인
- [ ] 앱 버전 코드/이름 업데이트

### ProGuard 설정 (선택사항)
`android/app/proguard-rules.pro`:

```proguard
# Kakao SDK
-keep class com.kakao.sdk.** { *; }
-keep class com.kakao.sdk.**$* { *; }
-dontwarn com.kakao.sdk.**
```

---

## 테스트 시나리오

### 1. 카카오톡 설치된 기기
1. 앱 실행
2. 카카오 로그인 버튼 클릭
3. 카카오톡 앱으로 자동 전환
4. 동의 후 로그인
5. 앱으로 돌아와서 로그인 완료 확인

### 2. 카카오톡 미설치 기기
1. 앱 실행
2. 카카오 로그인 버튼 클릭
3. 웹 브라우저로 카카오 로그인 페이지 열림
4. 계정 정보 입력 후 로그인
5. 앱으로 돌아와서 로그인 완료 확인

### 3. 로그아웃 테스트
1. 로그인 상태에서 로그아웃
2. 카카오 토큰 삭제 확인
3. 로컬 저장소 클리어 확인

### 4. 자동 로그인 테스트
1. 로그인 상태에서 앱 종료
2. 앱 재시작
3. 자동으로 메인 페이지로 이동 확인

---

## 참고 자료

- [Kakao Android SDK](https://developers.kakao.com/docs/latest/ko/sdk-download/android)
- [카카오 로그인 가이드](https://developers.kakao.com/docs/latest/ko/kakaologin/android)
- [Flutter 안드로이드 빌드](https://docs.flutter.dev/deployment/android)

---

## 추가 기능

### 카카오톡 공유하기
카카오톡 메시지 전송 기능을 추가하려면:

```dart
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';

// 카카오톡 공유하기
final template = FeedTemplate(...);
await ShareClient.instance.shareDefault(template: template);
```

### 카카오톡 채널
카카오톡 채널 연결 기능을 추가하려면:

```dart
import 'package:kakao_flutter_sdk_talk/kakao_flutter_sdk_talk.dart';

// 카카오톡 채널 채팅
await TalkApi.instance.channelChat(channelPublicId: '_your_channel_id');
```

pubspec.yaml에 추가 패키지 설치 필요:
```yaml
dependencies:
  kakao_flutter_sdk_share: ^1.9.6
  kakao_flutter_sdk_talk: ^1.9.6
```
