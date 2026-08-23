import 'package:flutter/foundation.dart';
import 'api_client.dart';

class AdminService {
  final ApiClient apiClient;

  AdminService({required this.apiClient});

  Future<Map<String, dynamic>> getOverview() async {
    final response = await apiClient.get('/admin/overview');
    return Map<String, dynamic>.from(response as Map);
  }

  Future<List<Map<String, dynamic>>> getUsers({
    String? search,
    String? role,
    String? status,
  }) async {
    final query = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (role != null && role != 'All') {
      query['role'] = role == 'Agronomy Expert'
          ? 'EXPERT'
          : role.toUpperCase().replaceAll(' ', '_');
    }
    if (status != null && status != 'All') {
      query['status'] = switch (status) {
        'Active' => 'ACTIVE',
        'Disabled' => 'DISABLED',
        _ => status.toUpperCase().replaceAll(' ', '_'),
      };
    }
    final suffix = query.isEmpty
        ? ''
        : '?${query.entries.map((entry) => '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}').join('&')}';
    final response = await apiClient.get('/admin/users$suffix');
    return (response as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> decideUser(String id, bool approved) async {
    final response = await apiClient.post(
      '/admin/users/$id/${approved ? 'approve' : 'reject'}',
      {},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> setUserActive(String id, bool active) async {
    final response = await apiClient.patch('/admin/users/$id/status', {
      'active': active,
    });
    return Map<String, dynamic>.from(response as Map);
  }

  Future<List<Map<String, dynamic>>> getAuditLogs() async {
    try {
      final response = await apiClient.get('/admin/audit-logs');
      return (response as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (error) {
      debugPrint('AdminService audit log error: $error');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    final response = await apiClient.get('/admin/settings');
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> updateSettings(
    Map<String, dynamic> settings,
  ) async {
    final response = await apiClient.patch('/admin/settings', settings);
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> broadcastAlert({
    required String body,
    String? location,
  }) async {
    final response = await apiClient.post('/messaging/broadcast', {
      'body': body,
      if (location != null && location.isNotEmpty) 'location': location,
    });
    return Map<String, dynamic>.from(response as Map);
  }

  Future<void> deleteUser(String id) async {
    await apiClient.delete('/admin/users/$id');
  }
}
