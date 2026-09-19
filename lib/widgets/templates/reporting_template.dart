import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/location_data.dart';
import '../mini_map_widget.dart';

class ReportingTemplate extends StatelessWidget {
  final LocationData loc;

  const ReportingTemplate({
    super.key,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF00E676),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.black, size: 16),
                SizedBox(width: 6),
                Text('VERIFIED CHECK-IN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  width: screenW * 0.18,
                  height: screenW * 0.18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: MiniMapWidget(
                      latitude: loc.latitude,
                      longitude: loc.longitude,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${loc.city.isNotEmpty ? '${loc.city}, ' : ''}${loc.country}'.trim(),
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        loc.fullAddress,
                        style: const TextStyle(color: Colors.black54, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lat: ${loc.latitude.toStringAsFixed(5)}\nLon: ${loc.longitude.toStringAsFixed(5)}',
                            style: const TextStyle(color: Colors.black54, fontSize: 10, fontFamily: 'monospace'),
                          ),
                          Text(
                            DateFormat('dd MMM\nHH:mm:ss').format(loc.timestamp),
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
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
  }
}

