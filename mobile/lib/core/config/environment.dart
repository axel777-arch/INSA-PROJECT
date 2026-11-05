import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get name {
    try {
      return dotenv.isInitialized
          ? (dotenv.env['ENVIRONMENT'] ?? 'production')
          : 'production';
    } catch (_) {
      return 'production';
    }
  }

  static String get apiBaseUrl {
    try {
      return dotenv.isInitialized
          ? (dotenv.env['API_BASE_URL'] ??
              'https://agri-insight-api-qb1q.onrender.com/api')
          : 'https://agri-insight-api-qb1q.onrender.com/api';
    } catch (_) {
      return 'https://agri-insight-api-qb1q.onrender.com/api';
    }
  }
}
