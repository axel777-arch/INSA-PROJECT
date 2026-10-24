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
    try {
      final response = await apiClient.post('/messaging/sms', {
        'recipient': recipient,
        'message': message,
        'contentId': contentId,
        'createdBy': createdBy,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[MessagingService] sendSmsSimulation error: $e');
      return {
        'id': 'sim-${DateTime.now().millisecondsSinceEpoch}',
        'recipient': recipient,
        'status': 'QUEUED',
      };
    }
  }

  /// IVR simulation — backend routes mounted under /api/simulation/ivr
  /// Starts a new IVR session via the backend.
  Future<Map<String, dynamic>> startIvrSession(String phone, {String? farmerId}) async {
    debugPrint('[MessagingService] POST /simulation/ivr/start → $phone');
    try {
      final payload = <String, dynamic>{'phone': phone};
      if (farmerId != null) {
        payload['farmerId'] = farmerId;
      }
      final response = await apiClient.post('/simulation/ivr/start', payload);
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      debugPrint('[MessagingService] startIvrSession fallback on error: $e');
      return {
        'sessionId': 'ivr-${DateTime.now().millisecondsSinceEpoch}',
        'phone': phone,
        'status': 'IN_PROGRESS',
        'currentMenu': 'language',
        'prompt': 'Welcome to Agri-Insight Beacon. Please select your language. Press 1 for English, 2 for Amharic, 3 for Afaan Oromoo.',
        'message': 'Welcome to Agri-Insight Beacon. Please select your language. Press 1 for English, 2 for Amharic, 3 for Afaan Oromoo.',
      };
    }
  }

  /// Sends a DTMF key press to the backend IVR session.
  Future<Map<String, dynamic>> sendIvrDtmf({
    required String sessionId,
    required String key,
  }) async {
    debugPrint('[MessagingService] POST /simulation/ivr/dtmf → key=$key (session=$sessionId)');
    try {
      final response = await apiClient.post('/simulation/ivr/dtmf', {
        'sessionId': sessionId,
        'key': key,
      });
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      debugPrint('[MessagingService] sendIvrDtmf error: $e');
      return {'sessionId': sessionId, 'status': 'IN_PROGRESS'};
    }
  }

  /// Ends an IVR simulation session.
  Future<Map<String, dynamic>> endIvrSession(String sessionId) async {
    debugPrint('[MessagingService] POST /simulation/ivr/end → session=$sessionId');
    try {
      final response = await apiClient.post('/simulation/ivr/end', {
        'sessionId': sessionId,
      });
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      debugPrint('[MessagingService] endIvrSession error: $e');
      return {'sessionId': sessionId, 'status': 'COMPLETED'};
    }
  }
}
