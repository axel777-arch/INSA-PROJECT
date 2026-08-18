import '../models/message_model.dart';
import 'api_client.dart';

class MessagingService {
  final ApiClient apiClient;

  MessagingService({required this.apiClient});

  Future<List<MessageModel>> getMessages() async {
    // API endpoint: GET /api/messages
    return [];
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
