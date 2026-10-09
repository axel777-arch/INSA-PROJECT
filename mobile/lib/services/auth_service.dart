import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/user_session.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  UserModel? _currentUser;

  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Call at app startup (SplashScreen) to restore session from storage.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final userStr = prefs.getString('user');

    if (token != null && userStr != null) {
      _apiClient.updateToken(token);
      try {
        _currentUser = UserModel.fromJson(
          jsonDecode(userStr) as Map<String, dynamic>,
        );
        UserSession.set(_currentUser!);
      } catch (_) {
        await logout();
      }
    }
  }

  /// POST /api/auth/login
  Future<bool> login(
    String usernameOrPhone,
    String password, {
    bool rememberMe = true,
  }) async {
    try {
      final trimmed = usernameOrPhone.trim();
      final isEmail = trimmed.contains('@');
      final payload = <String, dynamic>{
        'identifier': trimmed,
        if (isEmail) 'email': trimmed,
        if (!isEmail) 'phone': trimmed,
        'password': password,
      };

      final response = await _apiClient.post('/auth/login', payload);

      final token = (response['accessToken'] ?? response['token']) as String;
      final userData = response['user'] as Map<String, dynamic>;

      _apiClient.updateToken(token);
      _currentUser = UserModel.fromJson(userData);
      UserSession.set(_currentUser!);

      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString('access_token', token);
        await prefs.setString('user', jsonEncode(_currentUser!.toJson()));
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// POST /api/auth/register
  Future<bool> register({
    required String fullName,
    required String phone,
    required String password,
    required String role,
    required String preferredLanguage,
  }) async {
    try {
      final response = await _apiClient.post('/auth/register', {
        'fullName': fullName.trim(),
        'phone': phone.trim(),
        'password': password,
        'role': role,
        'preferredLanguage': preferredLanguage,
      });
      return response != null;
    } catch (e) {
      debugPrint('[AuthService] register error: $e');
      return false;
    }
  }

  /// GET /api/auth/me — refresh user data from server
  Future<UserModel?> getMe() async {
    try {
      final response = await _apiClient.get('/auth/me');
      if (response == null) return null;
      _currentUser = UserModel.fromJson(response as Map<String, dynamic>);
      UserSession.set(_currentUser!);
      // Persist updated user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(_currentUser!.toJson()));
      return _currentUser;
    } catch (e) {
      debugPrint('[AuthService] getMe error: $e');
      return null;
    }
  }

  /// Clear session from memory + storage. Call on every logout button.
  Future<void> logout() async {
    _currentUser = null;
    await UserSession.clear();
    _apiClient.updateToken(null);
  }
}
