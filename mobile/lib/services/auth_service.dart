import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  UserModel? _currentUser;
  static const String _tokenKey = 'auth_token';

  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(
    String usernameOrPhone,
    String password, {
    bool rememberMe = true,
  }) async {
    final response = await _apiClient.post('/auth/login', {
      'identifier': usernameOrPhone.trim(),
      'password': password,
    });
    _apiClient.updateToken(response['accessToken'] as String?);
    _currentUser = UserModel.fromJson(response['user'] as Map<String, dynamic>);
    final preferences = await SharedPreferences.getInstance();
    if (rememberMe) {
      await preferences.setString(
        'access_token',
        response['accessToken'] as String,
      );
      await preferences.setString('user', jsonEncode(_currentUser!.toJson()));
    }
    return true;
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String password,
    required String role,
    required String preferredLanguage,
  }) async {
    final response = await _apiClient.post('/auth/register', {
      'fullName': fullName.trim(),
      'phone': phone.trim(),
      'password': password,
      'role': role.toUpperCase().replaceAll(' ', '_'),
      'preferredLanguage': 'en',
    });
    return response != null;
  }

  Future<UserModel?> getMe() async {
    final response = await _apiClient.get('/auth/me');
    _currentUser = UserModel.fromJson(response as Map<String, dynamic>);
    return _currentUser;
  }

  Future<void> logout() async {
    _currentUser = null;
    _apiClient.updateToken(null);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('access_token');
    await preferences.remove('user');
  }
}
