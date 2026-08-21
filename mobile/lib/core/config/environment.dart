class Environment {
  static const String name = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000/api',
  );
}
