import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  UserModel? _currentUser;

  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String usernameOrPhone, String password) async {
    // API endpoint: POST /api/auth/login
    // MOCK response logic will be added here
    return false;
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String password,
    required String role,
    required String preferredLanguage,
  }) async {
    // API endpoint: POST /api/auth/register
    return false;
  }

  Future<UserModel?> getMe() async {
    // API endpoint: GET /api/auth/me
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    _apiClient.updateToken(null);
  }
}
