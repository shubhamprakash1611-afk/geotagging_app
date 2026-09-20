import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/location_data.dart';
import '../../models/weather_data.dart';
import '../../models/sensor_data.dart';
import '../../models/settings_data.dart';
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
    final screenW = MediaQuery.of(context).size.width;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.dashboardBg,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screenW * 0.22,
                  height: screenW * 0.22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: MiniMapWidget(
                      latitude: loc.latitude,
                      longitude: loc.longitude,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (loc.latitude == 0 && loc.longitude == 0)
                        Text(loc.locationName.isNotEmpty ? loc.locationName : 'Location unavailable', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))
                      else ...[
                        Text(
                          '${loc.city.isNotEmpty ? '${loc.city}, ' : ''}${loc.state.isNotEmpty ? '${loc.state}, ' : ''}${loc.country} ${loc.flagEmoji}'.trim(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.fullAddress,
                          style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lat ${loc.latitude.toStringAsFixed(6)}° Long ${loc.longitude.toStringAsFixed(6)}°',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy hh:mm a').format(loc.timestamp),
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      if (userNote.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Note: $userNote',
                          style: const TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (settings.showWatermark)
                  Column(
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white70, size: screenW * 0.08),
                      Text('GeoTag', style: TextStyle(color: Colors.white, fontSize: screenW * 0.025, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

