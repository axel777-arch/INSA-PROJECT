import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  static ApiClient? _instance;

  final http.Client client;

  factory ApiClient({http.Client? client}) {
    _instance ??= ApiClient._internal(client: client ?? http.Client());
    return _instance!;
  }

  @visibleForTesting
  static void clearInstance() {
    _instance = null;
  }

  ApiClient._internal({required this.client});

  String? _authToken;
  bool isOffline = false;

  void updateToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  void _handleError(http.Response response, {String? method, Uri? url}) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    String message = 'An error occurred';
    dynamic details;
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        if (body['error'] is Map<String, dynamic> && body['error']['message'] != null) {
          message = body['error']['message'].toString();
          details = body['error']['details'];
        } else if (body['message'] != null) {
          message = body['message'].toString();
          details = body['errors'] ?? body['details'];
        }
      }
    } catch (_) {}

    if (kDebugMode) {
      debugPrint(
        '⚠️ [API CLIENT ERROR] ${method ?? 'REQUEST'} ${url ?? response.request?.url}\n'
        '   Status: ${response.statusCode}\n'
        '   Error Message: $message\n'
        '   Details: $details\n'
        '   Raw Response: ${response.body}',
      );
    }

    throw ApiException(message, statusCode: response.statusCode, details: details);
  }

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${AppConfig.current.apiBaseUrl}$endpoint');
    if (kDebugMode) {
      debugPrint('🌐 [API CLIENT] GET $url (Auth: ${_authToken != null})');
    }
    try {
      final response = await client.get(url, headers: _headers);
      _handleError(response, method: 'GET', url: url);
      if (kDebugMode) {
        debugPrint('✅ [API CLIENT] GET $url -> ${response.statusCode}');
      }
      return response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      if (kDebugMode) debugPrint('❌ [API CLIENT NETWORK ERROR] GET $url: $e');
      throw ApiException('Network error or backend down: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${AppConfig.current.apiBaseUrl}$endpoint');
    final encodedBody = jsonEncode(body);
    if (kDebugMode) {
      debugPrint('🌐 [API CLIENT] POST $url (Auth: ${_authToken != null})');
      debugPrint('   Request Body: $encodedBody');
    }
    try {
      final response = await client.post(
        url,
        headers: _headers,
        body: encodedBody,
      );
      _handleError(response, method: 'POST', url: url);
      if (kDebugMode) {
        debugPrint('✅ [API CLIENT] POST $url -> ${response.statusCode}');
      }
      return response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      if (kDebugMode) debugPrint('❌ [API CLIENT NETWORK ERROR] POST $url: $e');
      throw ApiException('Network error or backend down: $e');
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${AppConfig.current.apiBaseUrl}$endpoint');
    final encodedBody = jsonEncode(body);
    if (kDebugMode) {
      debugPrint('🌐 [API CLIENT] PATCH $url (Auth: ${_authToken != null})');
      debugPrint('   Request Body: $encodedBody');
    }
    try {
      final response = await client.patch(
        url,
        headers: _headers,
        body: encodedBody,
      );
      _handleError(response, method: 'PATCH', url: url);
      if (kDebugMode) {
        debugPrint('✅ [API CLIENT] PATCH $url -> ${response.statusCode}');
      }
      return response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      if (kDebugMode) debugPrint('❌ [API CLIENT NETWORK ERROR] PATCH $url: $e');
      throw ApiException('Network error or backend down: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('${AppConfig.current.apiBaseUrl}$endpoint');
    if (kDebugMode) {
      debugPrint('🌐 [API CLIENT] DELETE $url (Auth: ${_authToken != null})');
    }
    try {
      final response = await client.delete(url, headers: _headers);
      _handleError(response, method: 'DELETE', url: url);
      if (kDebugMode) {
        debugPrint('✅ [API CLIENT] DELETE $url -> ${response.statusCode}');
      }
      return response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      if (kDebugMode) debugPrint('❌ [API CLIENT NETWORK ERROR] DELETE $url: $e');
      throw ApiException('Network error or backend down: $e');
    }
  }
}
