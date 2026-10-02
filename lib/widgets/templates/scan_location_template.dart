import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/location_data.dart';
import '../../models/settings_data.dart';
import '../../utils/app_translations.dart';
import '../mini_map_widget.dart';

class ScanLocationTemplate extends StatelessWidget {
  final LocationData loc;
  final SettingsData settings;

  const ScanLocationTemplate(
      {super.key, required this.loc, required this.settings});

  @override
  Widget build(BuildContext context) {
    final t = AppTranslations(settings.language);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final mediaSize = (width * 0.19).clamp(58.0, 82.0);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xF02A4E87), Color(0xF01B2D4D)]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black38, blurRadius: 14, offset: Offset(0, 5))
            ],
          ),
          child: Row(
            children: [
              Container(
                width: mediaSize,
                height: mediaSize,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white54, width: 2)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: MiniMapWidget(
                        latitude: loc.latitude, longitude: loc.longitude)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${loc.city.isNotEmpty ? '${loc.city}, ' : ''}${loc.country} ${loc.flagEmoji}'
                          .trim(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(loc.fullAddress,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 10.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(
                      '${t.text('latitude')}: ${loc.latitude.toStringAsFixed(5)}  ${t.text('longitude')}: ${loc.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(t.format(loc.timestamp, 'dd MMM yyyy • hh:mm a'),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: mediaSize,
                height: mediaSize,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: QrImageView(
                  data:
                      'geo:${loc.latitude},${loc.longitude}?q=${loc.latitude},${loc.longitude}',
                  version: QrVersions.auto,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
