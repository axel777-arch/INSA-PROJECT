import 'dart:convert';
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
    final response = await _apiClient.post('/auth/login', {
      'identifier': usernameOrPhone.trim(),
      'password': password,
    });

    final token = response['accessToken'] as String;
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
  }

  /// POST /api/auth/register
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
      'role': role,
      'preferredLanguage': preferredLanguage,
    });
    return response != null;
  }

  /// GET /api/auth/me — refresh user data from server
  Future<UserModel?> getMe() async {
    final response = await _apiClient.get('/auth/me');
    _currentUser = UserModel.fromJson(response as Map<String, dynamic>);
    UserSession.set(_currentUser!);
    // Persist updated user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(_currentUser!.toJson()));
    return _currentUser;
  }

  /// Clear session from memory + storage. Call on every logout button.
  Future<void> logout() async {
    _currentUser = null;
    await UserSession.clear();
  }
}
