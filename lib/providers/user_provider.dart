import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ProfileModel> _users = [];
  ProfileModel? _selectedUser;
  bool _isLoading = false;
  String? _error;

  List<ProfileModel> get users => _users;
  ProfileModel? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 보호대상자 목록 조회
  Future<void> loadUsers(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMessageProfileList(userId);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        _users = data.map((json) {
          // Message_Profile_Model에서 profile 추출
          if (json['profile'] != null) {
            return ProfileModel.fromJson(json['profile']);
          }
          return ProfileModel();
        }).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 특정 보호대상자 선택
  void selectUser(ProfileModel user) {
    _selectedUser = user;
    notifyListeners();
  }

  // 보호대상자 정보 업데이트
  Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.patchAiProfile(profileData);

      if (response.statusCode == 200) {
        // 성공 시 목록 새로고침
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
