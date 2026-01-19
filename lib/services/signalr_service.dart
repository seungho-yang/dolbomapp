import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../models/hub_model.dart';

/// SignalR 이벤트 리스너 인터페이스
typedef HubMessageCallback = void Function(HubModel hubModel);

/// SignalR 서비스 - 실시간 통신 관리
class SignalRService {
  static SignalRService? _instance;
  HubConnection? _hubConnection;

  String? _userId;
  bool _isConnected = false;

  // 이벤트 리스너들
  final List<HubMessageCallback> _listeners = [];

  // 싱글톤 패턴
  static SignalRService get instance {
    _instance ??= SignalRService._internal();
    return _instance!;
  }

  SignalRService._internal();

  bool get isConnected => _isConnected;
  String? get userId => _userId;

  /// SignalR 연결 초기화
  Future<void> initialize(String userId) async {
    if (_hubConnection != null && _isConnected && _userId == userId) {
      debugPrint('SignalR: 이미 연결되어 있습니다.');
      return;
    }

    _userId = userId;

    // 기존 연결이 있으면 종료
    await disconnect();

    final hubUrl = 'https://mrmind.kr/Hub/app?name=$userId';
    debugPrint('SignalR: 연결 시도 - $hubUrl');

    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl)
        .withAutomaticReconnect()
        .build();

    // 연결 상태 변경 리스너
    _hubConnection!.onclose(({error}) {
      debugPrint('SignalR: 연결 종료 - $error');
      _isConnected = false;
    });

    _hubConnection!.onreconnecting(({error}) {
      debugPrint('SignalR: 재연결 시도 중 - $error');
      _isConnected = false;
    });

    _hubConnection!.onreconnected(({connectionId}) {
      debugPrint('SignalR: 재연결 성공 - $connectionId');
      _isConnected = true;
    });

    // 메시지 수신 리스너 등록
    _hubConnection!.on('OnReceiveHermes', _onReceiveMessage);

    // 연결 시작
    await _startConnection();
  }

  /// 연결 시작
  Future<void> _startConnection() async {
    try {
      await _hubConnection?.start();
      _isConnected = true;
      debugPrint('SignalR: 연결 성공');
    } catch (e) {
      debugPrint('SignalR: 연결 실패 - $e');
      _isConnected = false;

      // 5초 후 재연결 시도
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isConnected) {
          _startConnection();
        }
      });
    }
  }

  /// 메시지 수신 처리
  void _onReceiveMessage(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0];
      HubModel? hubModel;

      if (data is Map<String, dynamic>) {
        hubModel = HubModel.fromJson(data);
      } else if (data is String) {
        hubModel = HubModel.fromJson(jsonDecode(data));
      }

      if (hubModel != null) {
        debugPrint('SignalR: 메시지 수신 - mode: ${hubModel.mode}, groupName: ${hubModel.groupName}');

        // 등록된 모든 리스너에게 알림
        for (final listener in _listeners) {
          listener(hubModel);
        }
      }
    } catch (e) {
      debugPrint('SignalR: 메시지 파싱 실패 - $e');
    }
  }

  /// 메시지 전송
  Future<void> sendMessage(HubModel hubModel) async {
    if (!_isConnected || _hubConnection == null) {
      debugPrint('SignalR: 연결되지 않음 - 메시지 전송 실패');
      return;
    }

    try {
      await _hubConnection!.invoke('SendAsync', args: [hubModel.toJson()]);
      debugPrint('SignalR: 메시지 전송 성공');
    } catch (e) {
      debugPrint('SignalR: 메시지 전송 실패 - $e');
    }
  }

  /// 리스너 등록
  void addListener(HubMessageCallback callback) {
    if (!_listeners.contains(callback)) {
      _listeners.add(callback);
    }
  }

  /// 리스너 제거
  void removeListener(HubMessageCallback callback) {
    _listeners.remove(callback);
  }

  /// 모든 리스너 제거
  void clearListeners() {
    _listeners.clear();
  }

  /// 연결 해제
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      try {
        await _hubConnection!.stop();
      } catch (e) {
        debugPrint('SignalR: 연결 해제 실패 - $e');
      }
      _hubConnection = null;
    }
    _isConnected = false;
    debugPrint('SignalR: 연결 해제됨');
  }

  /// 재연결
  Future<void> reconnect() async {
    if (_userId != null) {
      await initialize(_userId!);
    }
  }
}
