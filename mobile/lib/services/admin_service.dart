import 'package:flutter/foundation.dart';
import 'api_client.dart';

class AdminService {
  final ApiClient _apiClient;

  AdminService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// GET /api/admin/users/pending
  Future<List<Map<String, dynamic>>> getPendingUsers() async {
    try {
      final response = await _apiClient.get('/admin/users/pending');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('[AdminService] getPendingUsers error: $e');
      return [];
    }
  }

  /// PATCH /api/admin/users/:id/approve
  Future<bool> approveUser(String id) async {
    try {
      final response = await _apiClient.patch('/admin/users/$id/approve', {});
      return response != null;
    } catch (e) {
      debugPrint('[AdminService] approveUser error: $e');
      return false;
    }
  }

  /// PATCH /api/admin/users/:id/reject
  Future<bool> rejectUser(String id) async {
    try {
      final response = await _apiClient.patch('/admin/users/$id/reject', {});
      return response != null;
    } catch (e) {
      debugPrint('[AdminService] rejectUser error: $e');
      return false;
    }
  }

  /// GET /api/admin/users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _apiClient.get('/admin/users');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('[AdminService] getAllUsers error: $e');
      return [];
    }
  }

  /// PATCH /api/admin/users/:id
  Future<bool> toggleUserStatus(String id, bool active) async {
    try {
      final response = await _apiClient.patch('/admin/users/$id', {'active': active});
      return response != null;
    } catch (e) {
      debugPrint('[AdminService] toggleUserStatus error: $e');
      return false;
    }
  }

  /// GET /api/admin/audit-logs
  Future<List<Map<String, dynamic>>> getAuditLogs() async {
    try {
      final response = await _apiClient.get('/admin/audit-logs');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('[AdminService] getAuditLogs error: $e');
      return [];
    }
  }
}
