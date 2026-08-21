import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get name => dotenv.env['ENVIRONMENT'] ?? 'development';
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
}
