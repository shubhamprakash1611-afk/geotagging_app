import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/location_data.dart';

class DateTimeTemplate extends StatelessWidget {
  final LocationData loc;

  const DateTimeTemplate({
    super.key,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time section
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('hh:mm').format(loc.timestamp),
                style: const TextStyle(color: Colors.black87, fontSize: 32, fontWeight: FontWeight.w900, height: 1.0),
              ),
              Text(
                DateFormat('a').format(loc.timestamp),
                style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(width: 2, height: 60, color: const Color(0xFF00E676)), // Divider
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF00E676), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    DateFormat('dd MMMM yyyy | EEEE').format(loc.timestamp),
                    style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${loc.city.isNotEmpty ? '${loc.city}, ' : ''}${loc.country} ${loc.flagEmoji}'.trim(),
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  loc.fullAddress,
                  style: const TextStyle(color: Colors.black54, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Lat ${loc.latitude.toStringAsFixed(6)}°, Lon ${loc.longitude.toStringAsFixed(6)}°',
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

