import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class Environment {
  static String get name => dotenv.env['ENVIRONMENT'] ?? 'development';
  static String get apiBaseUrl {
    final configuredUrl = dotenv.env['API_BASE_URL'];
    if (configuredUrl == null || configuredUrl.isEmpty) {
      return 'http://localhost:3000/api';
    }
    if (kIsWeb) {
      return configuredUrl
          .replaceFirst('10.0.2.2', '127.0.0.1')
          .replaceFirst('localhost', '127.0.0.1');
    }
    return configuredUrl;
  }
}
