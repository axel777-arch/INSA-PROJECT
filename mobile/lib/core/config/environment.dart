import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get name {
    const fromDefine = String.fromEnvironment('ENVIRONMENT');
    if (fromDefine.isNotEmpty) return fromDefine;
    try {
      return dotenv.isInitialized
          ? (dotenv.env['ENVIRONMENT'] ?? 'development')
          : 'development';
    } catch (_) {
      return 'development';
    }
  }

  static String get apiBaseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    try {
      return dotenv.isInitialized
          ? (dotenv.env['API_BASE_URL'] ?? 'http://localhost:3001/api')
          : 'http://localhost:3001/api';
    } catch (_) {
      return 'http://localhost:3001/api';
    }
  }
}
