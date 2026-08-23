import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherConditions {
  final double temperature;
  final int humidity;
  final double precipitation;
  final DateTime observedAt;

  const WeatherConditions({
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.observedAt,
  });

  String get precipitationLabel {
    if (precipitation >= 5) return 'High';
    if (precipitation >= 1) return 'Moderate';
    return 'Low';
  }
}

class WeatherService {
  final http.Client client;

  WeatherService({http.Client? client}) : client = client ?? http.Client();

  Future<WeatherConditions> getCurrentConditions({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,precipitation',
      'timezone': 'auto',
    });
    final response = await client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Weather service returned ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final current = body['current'] as Map<String, dynamic>;
    return WeatherConditions(
      temperature: (current['temperature_2m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      precipitation: (current['precipitation'] as num).toDouble(),
      observedAt: DateTime.tryParse(current['time'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
