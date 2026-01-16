# iOS 카카오 로그인 설정 가이드

## 완료된 설정 ✅

### 1. Info.plist 설정
`ios/Runner/Info.plist`에 다음이 추가되었습니다:

- **CFBundleURLTypes**: 카카오 로그인 리다이렉트 URL 스킴
  - `kakao1899200f5e3244d9354cdd30266e521d`
- **LSApplicationQueriesSchemes**: 카카오톡 앱 확인을 위한 스킴
  - `kakaokompassauth`
  - `kakaolink`
  - `kakaoplus`
- **앱 이름**: "돌봄e음"

### 2. Podfile 생성
`ios/Podfile`이 생성되었으며, 다음 설정이 포함되어 있습니다:

- iOS 13.0 최소 배포 버전 설정
- 카카오 SDK 요구사항 충족

---

## iOS 빌드를 위한 추가 단계

### 1. CocoaPods 의존성 설치

```bash
cd ios
pod install
```

또는 Flutter 명령어 사용:

```bash
flutter pub get
cd ios
pod install
```

### 2. Xcode에서 프로젝트 설정 확인

1. `ios/Runner.xcworkspace` 파일을 Xcode로 엽니다 (`.xcodeproj`가 아닌 `.xcworkspace` 파일을 열어야 합니다)

2. **Runner** 프로젝트 선택 → **General** 탭에서:
   - **Deployment Info** → **iOS** 최소 버전이 **13.0** 이상인지 확인

3. **Signing & Capabilities** 탭에서:
   - 개발용 팀 선택
   - Bundle Identifier 확인/설정

---

## 카카오 개발자 콘솔 설정

### 1. 플랫폼 추가
[카카오 개발자 콘솔](https://developers.kakao.com/)에서:

1. 내 애플리케이션 → 앱 선택
2. **플랫폼** → **iOS 플랫폼 등록**
3. **Bundle ID** 입력 (Xcode에서 확인 가능)

### 2. iOS 설정 확인
- **네이티브 앱 키**: `1899200f5e3244d9354cdd30266e521d`
- **Bundle ID**: `com.example.dolbom_e_eum` (변경 필요 시 수정)

---

## 테스트 방법

### 1. 시뮬레이터에서 테스트
```bash
flutter run -d ios
```

**참고**: 시뮬레이터에서는 카카오톡 앱이 없으므로, 카카오 계정 로그인만 가능합니다.

### 2. 실제 기기에서 테스트
1. Xcode에서 개발용 인증서 설정
2. USB로 기기 연결
3. Flutter 실행:
```bash
flutter run -d <기기_ID>
```

---

## 문제 해결

### Pod 설치 실패
```bash
cd ios
pod deintegrate
pod install
```

### 빌드 오류 (Deployment Target)
Xcode에서:
1. **Runner** 프로젝트 선택
2. **Build Settings** → **Deployment** → **iOS Deployment Target** → **13.0** 설정

### 카카오 로그인 실패
1. 네이티브 앱 키가 올바른지 확인 (`lib/utils/constants.dart`)
2. Info.plist의 URL 스킴 확인
3. 카카오 개발자 콘솔에서 iOS 플랫폼이 등록되었는지 확인

---

## 주의사항

1. **네이티브 앱 키 변경**
   - 현재 테스트용 키가 사용 중입니다
   - 실제 배포 시 본인의 카카오 앱 키로 변경 필요
   - 변경 위치: `lib/utils/constants.dart`

2. **Bundle ID 변경**
   - 현재: `com.example.dolbom_e_eum`
   - 실제 배포 시 고유한 Bundle ID로 변경 필요
   - 카카오 개발자 콘솔에도 동일하게 등록

3. **iOS 13.0 이상 필요**
   - 카카오 Flutter SDK는 iOS 13.0 이상에서만 동작
   - 그 이하 버전을 지원해야 한다면 카카오 로그인 기능 제외 필요
