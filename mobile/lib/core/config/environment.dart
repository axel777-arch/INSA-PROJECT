import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get name {
    try {
      return dotenv.isInitialized ? (dotenv.env['ENVIRONMENT'] ?? 'development') : 'development';
    } catch (_) {
      return 'development';
    }
  }

  static String get apiBaseUrl {
    try {
      if (dotenv.isInitialized &&
          dotenv.env['API_BASE_URL'] != null &&
          dotenv.env['API_BASE_URL']!.isNotEmpty) {
        final configured = dotenv.env['API_BASE_URL']!;
        if (!kIsWeb && Platform.isAndroid && configured.contains('localhost')) {
          return configured.replaceAll('localhost', '10.0.2.2');
        }
        return configured;
      }

      if (!kIsWeb && Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api';
      }
      return 'http://localhost:3000/api';
    } catch (_) {
      if (!kIsWeb) {
        try {
          if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
        } catch (_) {}
      }
      return 'http://localhost:3000/api';
    }
  }
}

