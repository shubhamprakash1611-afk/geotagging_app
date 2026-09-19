import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/location_data.dart';
import '../../models/settings_data.dart';
import '../../utils/constants.dart';
import '../mini_map_widget.dart';

class ScanLocationTemplate extends StatelessWidget {
  final LocationData loc;
  final SettingsData settings;

  const ScanLocationTemplate({
    super.key,
    required this.loc,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3C72).withValues(alpha: 0.85), // Dark blue theme
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: screenW * 0.20,
              height: screenW * 0.20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white54, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${loc.city.isNotEmpty ? '${loc.city}, ' : ''}${loc.country}'.trim(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loc.fullAddress,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Lat: ${loc.latitude.toStringAsFixed(5)}, Lon: ${loc.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(loc.timestamp),
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: QrImageView(
                data: 'geo:${loc.latitude},${loc.longitude}',
                version: QrVersions.auto,
                size: screenW * 0.18,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

