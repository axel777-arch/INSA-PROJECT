import '../models/message_model.dart';
import 'api_client.dart';

class MessagingService {
  final ApiClient apiClient;

  MessagingService({required this.apiClient});

  Future<List<MessageModel>> getMessages() async {
    final response = await apiClient.get('/messaging');
    return (response as List)
        .map(
          (item) =>
              MessageModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    final response = await apiClient.get('/messaging/contacts');
    return (response as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<MessageModel> sendMessage(String recipientId, String body) async {
    final response = await apiClient.post('/messaging/direct', {
      'recipientId': recipientId,
      'body': body,
    });
    return MessageModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<void> markRead(String id) async {
    await apiClient.patch('/messaging/$id/read', {});
  }

  Future<bool> sendSmsSimulation(String phone, String message) async {
    // API endpoint: POST /api/simulation/sms
    return false;
  }

  Future<bool> startIvrSession(String phone) async {
    // API endpoint: POST /api/simulation/ivr/session
    return false;
  }
}
