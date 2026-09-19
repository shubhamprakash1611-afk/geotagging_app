import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {

  /// Fetches current weather from Open-Meteo.
  /// Cost: $0 — No API key, no registration, no billing. 10,000 calls/day free.
  static Future<WeatherData> fetchWeather(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat'
      '&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,wind_speed_10m'
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromOpenMeteoJson(json);
      }
      return WeatherData.empty();
    } catch (e) {
      // Offline fallback — return zeros rather than crashing
      return WeatherData.empty();
    }
  }
}
