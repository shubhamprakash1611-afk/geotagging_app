import 'package:flutter/material.dart';

import '../../models/location_data.dart';
import '../../models/settings_data.dart';
import '../../utils/app_translations.dart';
import '../mini_map_widget.dart';

class ReportingTemplate extends StatelessWidget {
  final LocationData loc;
  final SettingsData settings;

  const ReportingTemplate(
      {super.key, required this.loc, required this.settings});

  @override
  Widget build(BuildContext context) {
    final t = AppTranslations(settings.language);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final mapSize = (width * 0.18).clamp(58.0, 78.0);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 14, offset: Offset(0, 5))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF00E676), Color(0xFF3CF2A1)]),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_rounded,
                        color: Color(0xFF052E16), size: 17),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(t.text('verifiedCheckIn'),
                          style: const TextStyle(
                              color: Color(0xFF052E16),
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              letterSpacing: 1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(9),
                child: Row(
                  children: [
                    SizedBox(
                      width: mapSize,
                      height: mapSize,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: MiniMapWidget(
                              latitude: loc.latitude,
                              longitude: loc.longitude)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${loc.city.isNotEmpty ? '${loc.city}, ' : ''}${loc.country}'
                                  .trim(),
                              style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(loc.fullAddress,
                              style: const TextStyle(
                                  color: Color(0xFF6B7280), fontSize: 10.5),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${t.text('latitude')}: ${loc.latitude.toStringAsFixed(5)}\n${t.text('longitude')}: ${loc.longitude.toStringAsFixed(5)}',
                                  style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 9.5,
                                      fontFamily: 'monospace'),
                                ),
                              ),
                              Text(t.format(loc.timestamp, 'dd MMM\nHH:mm:ss'),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      color: Color(0xFF4B5563),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
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
