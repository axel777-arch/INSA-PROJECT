import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import 'api_client.dart';

class MessagingService {
  final ApiClient apiClient;

  MessagingService({required this.apiClient});

  /// GET /api/messages — not yet implemented on the backend (stub returns [])
  Future<List<MessageModel>> getMessages() async {
    debugPrint('[MessagingService] GET /api/messages (not yet implemented)');
    return [];
  }

  /// POST /api/messaging/sms
  /// Sends an SMS message through the backend simulator.
  /// Returns the created message record on success.
  Future<Map<String, dynamic>> sendSmsSimulation({
    required String recipient,
    required String message,
    required String contentId,
    required String createdBy,
  }) async {
    debugPrint('[MessagingService] POST /api/messaging/sms → $recipient');
    final response = await apiClient.post('/messaging/sms', {
      'recipient': recipient,
      'message': message,
      'contentId': contentId,
      'createdBy': createdBy,
    });
    return response as Map<String, dynamic>;
  }

  /// IVR simulation — backend service exists but no HTTP route yet.
  /// Returns a synthetic response so the UI still works.
  Future<Map<String, dynamic>> startIvrSession(String phone) async {
    debugPrint('[MessagingService] startIvrSession($phone) — IVR route pending backend wiring');
    // Simulate the IVR session locally until the backend route is added
    return {
      'sessionId': 'ivr-${DateTime.now().millisecondsSinceEpoch}',
      'phone': phone,
      'status': 'ACTIVE',
      'message': 'Welcome to Agri-Insight Beacon. Press 1 for crop advisories.',
    };
  }
}
