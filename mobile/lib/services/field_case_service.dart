import '../services/api_client.dart';

class FieldCaseService {
  final ApiClient apiClient;

  FieldCaseService({required this.apiClient});

  Future<List<Map<String, dynamic>>> getCases() async {
    final response = await apiClient.get('/field/observations');
    return (response as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> respond(
    String id, {
    required String diagnosis,
    required String recommendation,
    required String internalNotes,
  }) async {
    final response = await apiClient.patch('/field/observations/$id/response', {
      'diagnosis': diagnosis,
      'recommendation': recommendation,
      'internalNotes': internalNotes,
    });
    return Map<String, dynamic>.from(response as Map);
  }
}