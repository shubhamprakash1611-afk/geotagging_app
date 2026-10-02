import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/location_data.dart';
import '../../models/sensor_data.dart';
import '../../models/settings_data.dart';
import '../../utils/app_translations.dart';
import '../../utils/constants.dart';
import '../mini_map_widget.dart';

class NavigationTemplate extends StatelessWidget {
  final LocationData loc;
  final SensorData sensor;
  final SettingsData settings;

  const NavigationTemplate(
      {super.key,
      required this.loc,
      required this.sensor,
      required this.settings});

  String _directionKey(double azimuth) {
    final normalized = (azimuth % 360 + 360) % 360;
    if (normalized < 22.5 || normalized >= 337.5) return 'north';
    if (normalized < 67.5) return 'northEast';
    if (normalized < 112.5) return 'east';
    if (normalized < 157.5) return 'southEast';
    if (normalized < 202.5) return 'south';
    if (normalized < 247.5) return 'southWest';
    if (normalized < 292.5) return 'west';
    return 'northWest';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTranslations(settings.language);
    final azimuth = (sensor.azimuth % 360 + 360) % 360;
    final direction = t.text(_directionKey(azimuth));

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final compassSize = (width * 0.29).clamp(94.0, 122.0);
        final mapSize = (width * 0.145).clamp(48.0, 62.0);

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xF02B3446), Color(0xF0111827)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black38, blurRadius: 14, offset: Offset(0, 5))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.explore_rounded,
                      color: AppColors.accentGreen, size: 17),
                  const SizedBox(width: 6),
                  Text(t.text('navigationCompass'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: compassSize,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: -azimuth * math.pi / 180,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white54, width: 2)),
                                      child: const Stack(
                                        children: [
                                          Positioned(
                                              top: 4,
                                              left: 0,
                                              right: 0,
                                              child: Text('N',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color:
                                                          AppColors.accentGreen,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                          Positioned(
                                              bottom: 4,
                                              left: 0,
                                              right: 0,
                                              child: Text('S',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white60,
                                                      fontSize: 10))),
                                          Positioned(
                                              left: 5,
                                              top: 0,
                                              bottom: 0,
                                              child: Center(
                                                  child: Text('W',
                                                      style: TextStyle(
                                                          color: Colors.white60,
                                                          fontSize: 10)))),
                                          Positioned(
                                              right: 5,
                                              top: 0,
                                              bottom: 0,
                                              child: Center(
                                                  child: Text('E',
                                                      style: TextStyle(
                                                          color: Colors.white60,
                                                          fontSize: 10)))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text('${azimuth.toStringAsFixed(0)}°',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800)),
                                  const Positioned(
                                      top: 0,
                                      child: Icon(Icons.arrow_drop_down_rounded,
                                          color: AppColors.accentGreen,
                                          size: 18)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text('${t.text('facing')} $direction',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700),
                              maxLines: 2),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${loc.city.isNotEmpty ? '${loc.city}, ' : ''}${loc.state.isNotEmpty ? '${loc.state}, ' : ''}${loc.country} ${loc.flagEmoji}'
                                        .trim(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                    width: mapSize,
                                    height: mapSize,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: MiniMapWidget(
                                            latitude: loc.latitude,
                                            longitude: loc.longitude))),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(loc.fullAddress,
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 9.5),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(
                                '${t.text('latitude')} ${loc.latitude.toStringAsFixed(5)}°  ${t.text('longitude')} ${loc.longitude.toStringAsFixed(5)}°',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 9),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(
                                t.format(
                                    loc.timestamp, 'dd MMM yyyy • hh:mm a'),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 9)),
                            const SizedBox(height: 2),
                            Text(
                                '${t.text('bearing')}: ${azimuth.toStringAsFixed(1)}°',
                                style: const TextStyle(
                                    color: AppColors.accentGreen,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 10,
                              runSpacing: 4,
                              children: [
                                _Stat(
                                    icon: Icons.landscape_rounded,
                                    value:
                                        '${loc.altitude.toStringAsFixed(0)} m',
                                    color: Colors.orangeAccent),
                                _Stat(
                                    icon: Icons.explore_rounded,
                                    value:
                                        '${sensor.magneticFieldMicroTesla.toStringAsFixed(1)} µT',
                                    color: Colors.redAccent),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _Stat({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 3),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 9)),
      ],
    );
  }
}
