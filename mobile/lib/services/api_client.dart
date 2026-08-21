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

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${AppConfig.current.apiBaseUrl}$endpoint');
    debugPrint('GET request to: $url (Token: ${_authToken != null})');
    try {
      final response = await client.get(url, headers: _headers);
      _handleError(response);
      return response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      debugPrint('Network error on GET: $e');
      throw ApiException('Network error or backend down: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${AppConfig.current.apiBaseUrl}$endpoint');
    debugPrint('POST request to: $url');
    try {
      final response = await client.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      _handleError(response);
      return response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      debugPrint('Network error on POST: $e');
      throw ApiException('Network error or backend down: $e');
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${AppConfig.current.apiBaseUrl}$endpoint');
    debugPrint('PATCH request to: $url');
    try {
      final response = await client.patch(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      _handleError(response);
      return response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      debugPrint('Network error on PATCH: $e');
      throw ApiException('Network error or backend down: $e');
    }
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
      final response = await client.delete(url, headers: _headers);
      _handleError(response);
      return response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      debugPrint('Network error on DELETE: $e');
      throw ApiException('Network error or backend down: $e');
    }
  }
}
