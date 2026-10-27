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
    if (response is! Map<String, dynamic>) {
      throw const FormatException(
        'The SMS simulator returned an invalid response.',
      );
    }
    return response;
  }

  /// IVR simulation — backend routes mounted under /api/simulation/ivr
  /// Starts a new IVR session via the backend.
  Future<Map<String, dynamic>> startIvrSession(
    String phone, {
    String? farmerId,
  }) async {
    debugPrint('[MessagingService] POST /simulation/ivr/start → $phone');
    try {
      final payload = <String, dynamic>{'phone': phone};
      if (farmerId != null) {
        payload['farmerId'] = farmerId;
      }
      final response = await apiClient.post('/simulation/ivr/start', payload);
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      // Let the screen know the backend is unavailable. It has a local IVR
      // state machine; returning a fake sessionId here makes every key press
      // hit the backend again and the local simulator never advances.
      debugPrint('[MessagingService] startIvrSession failed: $e');
      rethrow;
    }
  }

  /// Sends a DTMF key press to the backend IVR session.
  Future<Map<String, dynamic>> sendIvrDtmf({
    required String sessionId,
    required String key,
  }) async {
    debugPrint(
      '[MessagingService] POST /simulation/ivr/dtmf → key=$key (session=$sessionId)',
    );
    try {
      final response = await apiClient.post('/simulation/ivr/dtmf', {
        'sessionId': sessionId,
        'key': key,
      });
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      // Do not return a success-shaped response on network/API errors. The UI
      // catches this and advances its local simulator instead.
      debugPrint('[MessagingService] sendIvrDtmf failed: $e');
      rethrow;
    }
  }

  /// Ends an IVR simulation session.
  Future<Map<String, dynamic>> endIvrSession(String sessionId) async {
    debugPrint(
      '[MessagingService] POST /simulation/ivr/end → session=$sessionId',
    );
    final response = await apiClient.post('/simulation/ivr/end', {
      'sessionId': sessionId,
    });
    if (response is! Map) {
      throw const FormatException(
        'The IVR simulator returned an invalid response.',
      );
    }
    return Map<String, dynamic>.from(response);
  }
}
