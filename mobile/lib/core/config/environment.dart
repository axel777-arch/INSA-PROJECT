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
      return dotenv.isInitialized ? (dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api') : 'http://localhost:3000/api';
    } catch (_) {
      return 'http://localhost:3000/api';
    }
  }
}
