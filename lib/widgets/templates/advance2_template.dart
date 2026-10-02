import 'package:flutter/material.dart';

import '../../models/location_data.dart';
import '../../models/sensor_data.dart';
import '../../models/settings_data.dart';
import '../../models/weather_data.dart';
import '../../utils/app_translations.dart';
import '../../utils/constants.dart';
import '../mini_map_widget.dart';

class Advance2Template extends StatelessWidget {
  final LocationData loc;
  final WeatherData weather;
  final SensorData sensor;
  final SettingsData settings;
  final String userNote;

  const Advance2Template({
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
              colors: [Color(0xEE352D55), Color(0xEE16233D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black38, blurRadius: 16, offset: Offset(0, 6))
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: mapSize,
                height: mapSize,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MiniMapWidget(
                      latitude: loc.latitude, longitude: loc.longitude),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.latitude == 0 && loc.longitude == 0
                          ? t.text('locationUnavailable')
                          : '${loc.city.isNotEmpty ? '${loc.city}, ' : ''}${loc.country} ${loc.flagEmoji}'
                              .trim(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(loc.fullAddress,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      '${t.text('latitude')} ${loc.latitude.toStringAsFixed(6)}°  ${t.text('longitude')} ${loc.longitude.toStringAsFixed(6)}°',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(t.format(loc.timestamp, 'dd MMM yyyy • hh:mm a'),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 10.5)),
                    if (userNote.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('${t.text('note')}: $userNote',
                          style: const TextStyle(
                              color: AppColors.accentGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              if (settings.showWatermark) ...[
                const SizedBox(width: 6),
                Icon(Icons.verified_rounded,
                    color: AppColors.accentGreen,
                    size: (width * 0.075).clamp(24.0, 32.0)),
              ],
            ],
          ),
        );
      },
    );
  }
}
