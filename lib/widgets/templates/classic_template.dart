import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/location_data.dart';

class ClassicTemplate extends StatelessWidget {
  final LocationData loc;

  const ClassicTemplate({
    super.key,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        border: const Border(left: BorderSide(color: Color(0xFF00E676), width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF00E676), size: 20),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${loc.city.isNotEmpty ? '${loc.city}, ' : ''}${loc.country} ${loc.flagEmoji}'.trim(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            loc.fullAddress,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${loc.latitude.toStringAsFixed(6)}°, ${loc.longitude.toStringAsFixed(6)}°',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                DateFormat('dd-MMM-yyyy hh:mm a').format(loc.timestamp),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

