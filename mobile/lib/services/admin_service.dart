import 'package:flutter/foundation.dart';
import 'api_client.dart';

/// A user account as seen by an administrator.
class AdminUser {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String role; // FARMER, EXTENSION_WORKER, EXPERT, ADMIN
  final String status; // PENDING, APPROVED, REJECTED
  final bool active;

  const AdminUser({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.role,
    required this.status,
    required this.active,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: (json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'FARMER').toString(),
      status: (json['status'] ?? 'APPROVED').toString(),
      active: json['active'] is bool ? json['active'] as bool : true,
    );
  }

  String get roleLabel => switch (role) {
    'EXTENSION_WORKER' => 'Extension Worker',
    'EXPERT' => 'Agricultural Expert',
    'FARMER' => 'Farmer',
    'ADMIN' => 'Administrator',
    _ => role,
  };

  bool get isPending => status == 'PENDING';
}

class AdminAuditLog {
  final String id;
  final String actorName;
  final String actorRole;
  final String action;
  final String target;
  final DateTime timestamp;

  const AdminAuditLog({
    required this.id,
    required this.actorName,
    required this.actorRole,
    required this.action,
    required this.target,
    required this.timestamp,
  });

  factory AdminAuditLog.fromJson(Map<String, dynamic> json) {
    return AdminAuditLog(
      id: (json['id'] ?? '').toString(),
      actorName: (json['actorName'] ?? 'System User').toString(),
      actorRole: (json['actorRole'] ?? 'SYSTEM').toString(),
      action: (json['action'] ?? '').toString(),
      target: (json['target'] ?? '').toString(),
      timestamp: DateTime.parse((json['timestamp'] ?? '').toString()),
    );
  }
}

/// AdminService — user management endpoints (admin role only).
class AdminService {
  final ApiClient apiClient;

  AdminService({required this.apiClient});

  /// GET /api/admin/users
  Future<List<AdminUser>> getUsers() async {
    debugPrint('[AdminService] GET /admin/users');
    final response = await apiClient.get('/admin/users');
    return (response as List<dynamic>)
        .map((data) => AdminUser.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/admin/audit-logs
  Future<List<AdminAuditLog>> getAuditLogs({int limit = 100}) async {
    final response = await apiClient.get('/admin/audit-logs?limit=$limit');
    return (response as List<dynamic>)
        .map((data) => AdminAuditLog.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  /// PATCH /api/admin/users/:id  { status: APPROVED | REJECTED }
  Future<void> setApproval(String id, {required bool approved}) async {
    debugPrint('[AdminService] PATCH /admin/users/$id approved=$approved');
    await apiClient.patch('/admin/users/$id', {
      'status': approved ? 'APPROVED' : 'REJECTED',
    });
  }

  /// PATCH /api/admin/users/:id  { active: true | false }
  Future<void> setActive(String id, {required bool active}) async {
    debugPrint('[AdminService] PATCH /admin/users/$id active=$active');
    await apiClient.patch('/admin/users/$id', {'active': active});
  }
}
