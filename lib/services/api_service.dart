import 'package:dio/dio.dart';
import 'api_client.dart';
import '../utils/constants.dart';

class ApiService {
  final ApiClient _apiClient = ApiClient.getInstance();

  // 사용자 프로필 조회 (단일)
  Future<Response> getMessageProfile(int id, {String? doll}) async {
    return await _apiClient.get(
      ApiConstants.app,
      queryParameters: doll != null
          ? {'id': id, 'doll': doll}
          : {'id': id},
    );
  }

  // 사용자 프로필 목록 조회
  Future<Response> getMessageProfileList(int id) async {
    return await _apiClient.get(
      ApiConstants.app,
      queryParameters: {'id': id},
    );
  }

  // 사용자 정보 등록
  Future<Response> postUser(Map<String, dynamic> userData) async {
    return await _apiClient.post(
      ApiConstants.app,
      data: userData,
    );
  }

  // Firebase 토큰 전송
  Future<Response> postNotification(Map<String, dynamic> notificationData) async {
    return await _apiClient.post(
      ApiConstants.notification,
      data: notificationData,
    );
  }

  // 알람 조회
  Future<Response> getAlarms(int userId) async {
    return await _apiClient.get(
      ApiConstants.alarm,
      queryParameters: {'id': userId},
    );
  }

  // 알람 추가
  Future<Response> postAlarm(Map<String, dynamic> alarmData) async {
    return await _apiClient.post(
      ApiConstants.alarm,
      data: alarmData,
    );
  }

  // 알람 수정
  Future<Response> patchAlarm(int id, Map<String, dynamic> alarmData) async {
    return await _apiClient.patch(
      ApiConstants.alarm,
      queryParameters: {'id': id},
      data: alarmData,
    );
  }

  // 알람 삭제
  Future<Response> deleteAlarm(String id) async {
    return await _apiClient.delete(
      ApiConstants.alarm,
      queryParameters: {'id': id},
    );
  }

  // AI 정보 조회 (int id)
  Future<Response> getAiByIntId(int id) async {
    return await _apiClient.get(
      ApiConstants.ai,
      queryParameters: {'id': id},
    );
  }

  // AI 정보 조회 (String id)
  Future<Response> getAiByStringId(String id) async {
    return await _apiClient.get(
      ApiConstants.ai,
      queryParameters: {'id': id},
    );
  }

  // AI 프로필 수정
  Future<Response> patchAiProfile(Map<String, dynamic> profileData) async {
    return await _apiClient.patch(
      ApiConstants.ai,
      data: profileData,
    );
  }

  // 위험단어 목록 조회
  Future<Response> getDangerousWords() async {
    return await _apiClient.get(ApiConstants.dangerous);
  }

  // 위험단어 통계 조회
  Future<Response> getDangerousStatistics(String id) async {
    return await _apiClient.get(
      ApiConstants.dangerous,
      queryParameters: {'id': id},
    );
  }

  // 링크 조회
  Future<Response> getLinks() async {
    return await _apiClient.get(ApiConstants.link);
  }

  // 미디어 콘텐츠 조회
  Future<Response> getMediaContents(int code) async {
    return await _apiClient.get(
      ApiConstants.contents,
      queryParameters: {'code': code},
    );
  }

  // 권한 확인
  Future<Response> getAuthorize(int appId, String userId) async {
    return await _apiClient.get(
      ApiConstants.authorize,
      queryParameters: {'app': appId, 'id': userId},
    );
  }

  // 초기화 정보 조회
  Future<Response> getInitialize(String id) async {
    return await _apiClient.get(
      ApiConstants.initialize,
      queryParameters: {'id': id},
    );
  }

  // 초기화 정보 등록
  Future<Response> postInitialize(Map<String, dynamic> initData) async {
    return await _apiClient.post(
      ApiConstants.initialize,
      data: initData,
    );
  }

  // A/S 조회
  Future<Response> getAS(int userId) async {
    return await _apiClient.get(
      ApiConstants.as,
      queryParameters: {'user': userId},
    );
  }

  // A/S 등록
  Future<Response> postAS(Map<String, dynamic> asData) async {
    return await _apiClient.post(
      ApiConstants.as,
      data: asData,
    );
  }

  // 대화 내역 조회
  Future<Response> getMessages(String id) async {
    return await _apiClient.get(
      ApiConstants.dialog,
      queryParameters: {'id': id},
    );
  }

  // 대화 내역 추가 조회 (페이지네이션)
  Future<Response> getMoreMessages(String id, int tick) async {
    return await _apiClient.get(
      ApiConstants.dialog,
      queryParameters: {'id': id, 'tick': tick},
    );
  }

  // 위험 대화 내역 조회 (페이지네이션)
  Future<Response> getDangerMessages(String id, int tick, int order) async {
    return await _apiClient.get(
      ApiConstants.dialog,
      queryParameters: {'id': id, 'tick': tick, 'order': order},
    );
  }

  // 매칭 삭제
  Future<Response> deleteMatching(String aiId, int kakaoId) async {
    return await _apiClient.delete(
      ApiConstants.matching,
      queryParameters: {'ai': aiId, 'kakao': kakaoId},
    );
  }
}
