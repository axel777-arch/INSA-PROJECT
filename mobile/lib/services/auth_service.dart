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

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      _apiClient.updateToken(token);
      try {
        await getMe();
      } catch (e) {
        await logout(); // Invalid token
      }
    }
  }

  Future<bool> login(String usernameOrPhone, String password, {bool rememberMe = false}) async {
    try {
      final response = await _apiClient.post('/auth/login', {
        'identifier': usernameOrPhone,
        'password': password,
      });
      
      final token = response['accessToken'];
      if (token != null) {
        _apiClient.updateToken(token);
        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
        }
        _currentUser = UserModel.fromJson(response['user']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String password,
    required String role,
    required String preferredLanguage,
  }) async {
    try {
      await _apiClient.post('/auth/register', {
        'fullName': fullName,
        'phone': phone,
        'password': password,
        'role': role,
        'preferredLanguage': preferredLanguage,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final response = await _apiClient.get('/auth/me');
      _currentUser = UserModel.fromJson(response['user']);
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return false;
    try {
      final result = await _apiClient.post('/auth/refresh', {'refreshToken': refreshToken});
      _apiClient.updateToken(result['accessToken'] as String);
      await prefs.setString('refresh_token', result['refreshToken'] as String);
      await getMe();
      return true;
    } catch (_) {
      await prefs.remove('refresh_token');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _apiClient.updateToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    try {
      await _apiClient.post('/auth/logout', {});
    } catch (_) {}
  }
}
