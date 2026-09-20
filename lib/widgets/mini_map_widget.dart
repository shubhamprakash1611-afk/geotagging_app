import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/settings_data.dart';

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

    final appState = context.watch<AppStateProvider>();
    final mapType = appState.settings.mapType;
    // Earth view needs to be zoomed in 3 levels closer, but max zoom for Google is usually 20-21
    final double zoomLevel = mapType == MapType.earth 
        ? (appState.settings.mapZoomLevel + 3).clamp(10.0, 20.0) 
        : appState.settings.mapZoomLevel;

    // OpenStreetMap (Street) vs Google Hybrid (Earth)
    final urlTemplate = mapType == MapType.earth
        ? 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: FlutterMap(
          key: ValueKey('${mapType.name}_$zoomLevel'),
          options: MapOptions(
            initialCenter: LatLng(latitude, longitude),
            initialZoom: zoomLevel,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none, // Static, non-interactive
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: urlTemplate,
              userAgentPackageName: 'com.geotagging.app',
              // Note: Only use caching for OSM to avoid Google ToS issues, or bypass caching for Earth view.
              tileProvider: mapType == MapType.street 
                  ? const FMTCStore('mapStore').getTileProvider() 
                  : NetworkTileProvider(),
              errorImage: const NetworkImage('https://raw.githubusercontent.com/flutter_map/flutter_map/master/example/assets/map/error.png'),
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


