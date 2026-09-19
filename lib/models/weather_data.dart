class WeatherData {
  final double temperatureCelsius;
  final double windSpeedKmh;
  final int humidityPercent;

  const WeatherData({
    required this.temperatureCelsius,
    required this.windSpeedKmh,
    required this.humidityPercent,
  });

  factory WeatherData.empty() => const WeatherData(
    temperatureCelsius: 0, windSpeedKmh: 0, humidityPercent: 0,
  );

  // Parse the Open-Meteo JSON response
  factory WeatherData.fromOpenMeteoJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    return WeatherData(
      temperatureCelsius: (current['temperature_2m'] as num).toDouble(),
      windSpeedKmh: (current['wind_speed_10m'] as num).toDouble(),
      humidityPercent: (current['relative_humidity_2m'] as num).toInt(),
    );
  }
}
