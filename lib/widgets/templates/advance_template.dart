import 'package:flutter/material.dart';

import '../../models/location_data.dart';
import '../../models/sensor_data.dart';
import '../../models/settings_data.dart';
import '../../models/weather_data.dart';
import '../../utils/app_translations.dart';
import '../../utils/constants.dart';
import '../mini_map_widget.dart';
import '../sensor_chip.dart';

class AdvanceTemplate extends StatelessWidget {
  final LocationData loc;
  final WeatherData weather;
  final SensorData sensor;
  final SettingsData settings;
  final String userNote;

  const AdvanceTemplate({
    super.key,
    required this.loc,
    required this.weather,
    required this.sensor,
    required this.settings,
    required this.userNote,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTranslations(settings.language);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final mapSize = (width * 0.22).clamp(62.0, 92.0);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xEE1D2C50), Color(0xEE101827)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black38, blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MapThumb(loc: loc, size: mapSize),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.latitude == 0 && loc.longitude == 0
                              ? t.text('locationUnavailable')
                              : '${loc.city.isNotEmpty ? '${loc.city}, ' : ''}${loc.state.isNotEmpty ? '${loc.state}, ' : ''}${loc.country} ${loc.flagEmoji}'
                                  .trim(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              height: 1.15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (loc.latitude != 0 || loc.longitude != 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            loc.fullAddress,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                height: 1.25),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${t.text('latitude')} ${loc.latitude.toStringAsFixed(6)}°  ${t.text('longitude')} ${loc.longitude.toStringAsFixed(6)}°',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 3),
                        Text(
                          t.format(
                              loc.timestamp, 'EEEE, dd MMMM yyyy • hh:mm a'),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 10.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (userNote.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${t.text('note')}: $userNote',
                            style: const TextStyle(
                                color: AppColors.accentGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (settings.showWatermark) ...[
                    const SizedBox(width: 6),
                    Column(
                      children: [
                        Icon(Icons.camera_alt_rounded,
                            color: AppColors.accentGreen,
                            size: (width * 0.075).clamp(24.0, 32.0)),
                        const Text('GeoTag',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ],
              ),
              if (settings.showWeatherData || settings.showSensorData) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (settings.showWeatherData &&
                        weather.temperatureCelsius != 0)
                      SensorChip(
                          icon: Icons.thermostat_rounded,
                          value:
                              '${weather.temperatureCelsius.toStringAsFixed(1)}°C',
                          color: Colors.orange),
                    if (settings.showWeatherData && weather.windSpeedKmh != 0)
                      SensorChip(
                          icon: Icons.air_rounded,
                          value:
                              '${weather.windSpeedKmh.toStringAsFixed(1)} km/h',
                          color: Colors.cyan),
                    if (settings.showWeatherData &&
                        weather.humidityPercent != 0)
                      SensorChip(
                          icon: Icons.water_drop_rounded,
                          value: '${weather.humidityPercent}%',
                          color: Colors.lightBlue),
                    if (settings.showSensorData && loc.altitude != 0)
                      SensorChip(
                          icon: Icons.landscape_rounded,
                          value: '${loc.altitude.toStringAsFixed(1)} m',
                          color: Colors.green),
                    if (settings.showSensorData &&
                        sensor.magneticFieldMicroTesla != 0)
                      SensorChip(
                          icon: Icons.explore_rounded,
                          value:
                              '${sensor.magneticFieldMicroTesla.toStringAsFixed(1)} µT',
                          color: Colors.purple),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MapThumb extends StatelessWidget {
  final LocationData loc;
  final double size;

  const _MapThumb({required this.loc, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white38, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: MiniMapWidget(latitude: loc.latitude, longitude: loc.longitude),
      ),
    );
  }
}
