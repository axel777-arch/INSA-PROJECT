import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal();

  String? _authToken;
  bool isOffline = false;

  void updateToken(String? token) {
    _authToken = token;
  }

  Future<dynamic> get(String endpoint) async {
    return _request('GET', endpoint);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    return _request('POST', endpoint, body: body);
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    return _request('PATCH', endpoint, body: body);
  }

  Future<dynamic> delete(String endpoint) async {
    return _request('DELETE', endpoint);
  }

  Future<dynamic> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${AppConfig.current.apiBaseUrl}$endpoint');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_authToken != null) headers['Authorization'] = 'Bearer $_authToken';
    try {
      final response = switch (method) {
        'GET' => await http.get(uri, headers: headers),
        'POST' => await http.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        ),
        'PATCH' => await http.patch(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        ),
        _ => await http.delete(uri, headers: headers),
      };
      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map<String, dynamic>
            ? (decoded['error'] is Map
                  ? decoded['error']['message']
                  : decoded['message'])
            : null;
        throw ApiException(
          message?.toString() ?? 'Request failed (${response.statusCode})',
          response.statusCode,
        );
      }
      isOffline = false;
      return decoded;
    } catch (error) {
      if (error is ApiException) rethrow;
      isOffline = true;
      throw ApiException('Backend unavailable. Showing offline data.', 0);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}
