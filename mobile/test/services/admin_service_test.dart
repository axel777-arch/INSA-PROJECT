import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/services/admin_service.dart';
import 'package:mobile/services/api_client.dart';

void main() {
  group('AdminService audit logs', () {
    tearDown(ApiClient.clearInstance);

    test('fetches and parses backend audit log records', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/admin/audit-logs');
        expect(request.url.queryParameters['limit'], '4');
        expect(
          request.headers.entries
              .singleWhere(
                (entry) => entry.key.toLowerCase() == 'authorization',
              )
              .value,
          'Bearer admin_token',
        );
        return http.Response(
          jsonEncode([
            {
              'id': 'log-1',
              'actor': 'admin-id',
              'actorName': 'Alem',
              'actorRole': 'ADMIN',
              'action': 'USER_APPROVED',
              'target': 'Extension worker Hana',
              'timestamp': '2026-10-25T12:30:00.000Z',
            },
          ]),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient)
        ..updateToken('admin_token');
      final service = AdminService(apiClient: apiClient);

      final logs = await service.getAuditLogs(limit: 4);

      expect(logs, hasLength(1));
      expect(logs.single.actorName, 'Alem');
      expect(logs.single.actorRole, 'ADMIN');
      expect(logs.single.action, 'USER_APPROVED');
      expect(logs.single.target, 'Extension worker Hana');
      expect(logs.single.timestamp, DateTime.utc(2026, 10, 25, 12, 30));
    });
  });
}
