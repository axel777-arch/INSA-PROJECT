import 'package:flutter/foundation.dart';
import '../core/config/app_config.dart';

class ApiClient {
  String? _authToken;

  void updateToken(String? token) {
    _authToken = token;
  }

  // Generic request wrappers - to be wired with http/dio package later
  Future<dynamic> get(String endpoint) async {
    final url = '${AppConfig.current.apiBaseUrl}$endpoint';
    debugPrint('GET request to: $url (Token: ${_authToken != null})');
    return null;
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = '${AppConfig.current.apiBaseUrl}$endpoint';
    debugPrint('POST request to: $url | Body: $body');
    return null;
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final url = '${AppConfig.current.apiBaseUrl}$endpoint';
    debugPrint('PATCH request to: $url | Body: $body');
    return null;
  }

  Future<dynamic> delete(String endpoint) async {
    final url = '${AppConfig.current.apiBaseUrl}$endpoint';
    debugPrint('DELETE request to: $url');
    return null;
  }
}
