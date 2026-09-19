import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class MiniMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MiniMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    // Don't render map if no valid coordinates
    if (latitude == 0 && longitude == 0) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(Icons.map_outlined, color: Colors.white54, size: 30),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(latitude, longitude),
            initialZoom: 14.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none, // Static, non-interactive
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.geotagging.app',
              tileProvider: const FMTCStore('mapStore').getTileProvider(),
              errorImage: const NetworkImage('https://raw.githubusercontent.com/flutter_map/flutter_map/master/example/assets/map/error.png'), // placeholder
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(latitude, longitude),
                  width: 30,
                  height: 30,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

