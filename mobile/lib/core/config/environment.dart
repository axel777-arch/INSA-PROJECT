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
    String url = 'http://localhost:3000/api';
    try {
      if (dotenv.isInitialized && dotenv.env['API_BASE_URL'] != null) {
        url = dotenv.env['API_BASE_URL']!;
      }
    } catch (_) {}

    // On Web (Chrome/Edge) or Desktop, 10.0.2.2 cannot be reached. Use localhost instead.
    if (kIsWeb) {
      if (url.contains('10.0.2.2')) {
        url = url.replaceAll('10.0.2.2', 'localhost');
      }
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // On Android emulators, localhost points to the emulator itself.
      // Replace with 10.0.2.2 so the Android emulator can reach the host machine.
      if (url.contains('localhost')) {
        url = url.replaceAll('localhost', '10.0.2.2');
      } else if (url.contains('127.0.0.1')) {
        url = url.replaceAll('127.0.0.1', '10.0.2.2');
      }
    } else {
      // Windows, macOS, Linux desktop
      if (url.contains('10.0.2.2')) {
        url = url.replaceAll('10.0.2.2', 'localhost');
      }
    }
    return url;
  }
}
