import 'environment.dart';

class AppConfig {
  final String apiBaseUrl;
  final String environment;

  const AppConfig({required this.apiBaseUrl, required this.environment});

  static AppConfig get current => AppConfig(
        apiBaseUrl: Environment.apiBaseUrl,
        environment: Environment.name,
      );
}
