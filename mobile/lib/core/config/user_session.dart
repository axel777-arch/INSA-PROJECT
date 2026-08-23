import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../services/api_client.dart';

/// Singleton-style accessor for the currently authenticated user.
/// Reads from SharedPreferences so every screen can show the real name
/// without passing it through navigation arguments.
class UserSession {
  static UserModel? _user;

  /// Returns the cached user, loading from prefs on first call.
  static Future<UserModel?> get() async {
    if (_user != null) return _user;
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('user');
    if (json == null) return null;
    try {
      _user = UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      _user = null;
    }
    return _user;
  }

  /// Call after login to cache the user in memory.
  static void set(UserModel user) {
    _user = user;
  }

  /// Call on logout to clear both memory and persistent storage.
  static Future<void> clear() async {
    _user = null;
    ApiClient().updateToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user');
  }

  /// Convenience: user's display name or fallback.
  static String get displayName => _user?.fullName ?? 'User';

  /// Convenience: user's role.
  static String get role => _user?.role ?? '';

  /// Convenience: user's id.
  static String get id => _user?.id ?? '';
}
