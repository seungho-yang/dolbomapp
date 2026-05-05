import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';
import 'global_user_info.dart';

/// 백그라운드 메시지 핸들러 (최상위 함수여야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('백그라운드 메시지 수신: ${message.messageId}');
  debugPrint('제목: ${message.notification?.title}');
  debugPrint('내용: ${message.notification?.body}');
}

/// Firebase 서비스 (Java의 FIreBaseService.java와 동일한 역할)
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  static FirebaseService get instance => _instance;

  FirebaseMessaging? _messaging;
  final ApiService _apiService = ApiService();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // 메시지 수신 콜백
  Function(RemoteMessage)? _onMessageReceived;
  Function(RemoteMessage)? _onMessageOpenedApp;

  /// Firebase 초기화
  Future<void> initialize() async {
    try {
      // Firebase 초기화
      await Firebase.initializeApp();
      debugPrint('FirebaseService: Firebase 초기화 완료');

      // FirebaseMessaging 인스턴스 생성
      _messaging = FirebaseMessaging.instance;

      // 백그라운드 메시지 핸들러 등록
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 알림 권한 요청
      await _requestPermission();

      // FCM 토큰 획득
      await _getToken();

      // 포그라운드 메시지 리스너 설정
      _setupMessageListeners();

      debugPrint('FirebaseService: 초기화 완료');
    } catch (e) {
      debugPrint('FirebaseService: 초기화 실패 - $e');
    }
  }

  /// 알림 권한 요청 (Android 13+ 필수)
  Future<void> _requestPermission() async {
    if (_messaging == null) return;
    final settings = await _messaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('FirebaseService: 알림 권한 상태 - ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('FirebaseService: 알림 권한 허용됨');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('FirebaseService: 알림 권한 임시 허용됨');
    } else {
      debugPrint('FirebaseService: 알림 권한 거부됨');
    }
  }

  /// FCM 토큰 획득 (Java MainActivity.getToken()과 동일)
  Future<void> _getToken() async {
    if (_messaging == null) return;
    try {
      _fcmToken = await _messaging!.getToken();
      debugPrint('FirebaseService: FCM 토큰 획득 - $_fcmToken');

      // 토큰 갱신 리스너
      _messaging!.onTokenRefresh.listen((newToken) {
        debugPrint('FirebaseService: FCM 토큰 갱신 - $newToken');
        _fcmToken = newToken;
        _sendTokenToServer(newToken);
      });
    } catch (e) {
      debugPrint('FirebaseService: FCM 토큰 획득 실패 - $e');
    }
  }

  /// 서버에 FCM 토큰 전송 (Java의 postNotification과 동일)
  Future<void> sendTokenToServer() async {
    if (_fcmToken == null) {
      debugPrint('FirebaseService: FCM 토큰이 없습니다.');
      return;
    }
    await _sendTokenToServer(_fcmToken!);
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      final userId = GlobalUserInfo.instance.userId;
      final phone = GlobalUserInfo.instance.phone;

      if (userId == null || userId.isEmpty) {
        debugPrint('FirebaseService: userId가 없어서 토큰 전송 건너뜀');
        return;
      }

      final notificationData = {
        'id': userId,
        'firebaseToken': token,
        'phone': phone ?? '',
      };

      debugPrint('FirebaseService: 서버에 FCM 토큰 전송 - $notificationData');

      final response = await _apiService.postNotification(notificationData);

      if (response.statusCode == 200) {
        debugPrint('FirebaseService: FCM 토큰 서버 전송 성공');
      } else {
        debugPrint('FirebaseService: FCM 토큰 서버 전송 실패 - ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('FirebaseService: FCM 토큰 서버 전송 오류 - $e');
    }
  }

  /// 메시지 리스너 설정
  void _setupMessageListeners() {
    // 포그라운드 메시지 수신
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FirebaseService: 포그라운드 메시지 수신');
      debugPrint('제목: ${message.notification?.title}');
      debugPrint('내용: ${message.notification?.body}');
      debugPrint('데이터: ${message.data}');

      _onMessageReceived?.call(message);
    });

    // 백그라운드에서 알림 클릭 시
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FirebaseService: 알림 클릭으로 앱 열림');
      debugPrint('제목: ${message.notification?.title}');
      debugPrint('내용: ${message.notification?.body}');
      debugPrint('데이터: ${message.data}');

      _onMessageOpenedApp?.call(message);
    });
  }

  /// 앱이 종료된 상태에서 알림으로 열린 경우 처리
  Future<RemoteMessage?> getInitialMessage() async {
    if (_messaging == null) return null;
    return await _messaging!.getInitialMessage();
  }

  /// 메시지 수신 콜백 설정
  void setOnMessageReceived(Function(RemoteMessage) callback) {
    _onMessageReceived = callback;
  }

  /// 알림 클릭 콜백 설정
  void setOnMessageOpenedApp(Function(RemoteMessage) callback) {
    _onMessageOpenedApp = callback;
  }

  /// 위험단어 알림 데이터 파싱 (Java FIreBaseService.showNotification과 동일)
  Map<String, String>? parseDangerousWordNotification(RemoteMessage message) {
    final title = message.notification?.title;
    final body = message.notification?.body;

    if (title == null || body == null) return null;

    // 제목에서 인형 번호 추출 (예: "위험단어 12345")
    final parts = title.split(' ');
    if (parts.length < 2) return null;

    final dollId = parts[1];
    final dangerousWord = body;
    final time = DateTime.now().toIso8601String();

    return {
      'dollId': dollId,
      'message': dangerousWord,
      'time': time,
    };
  }
}
