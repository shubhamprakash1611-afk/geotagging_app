import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_data.dart';
import '../utils/plus_code_generator.dart';

class LocationService {

  /// Fetches current GPS position and reverse geocodes it into a full address.
  /// Uses on-device geocoder (Apple Maps on iOS, Google Play Services on Android).
  /// Cost: $0 — all on-device.
  static Future<LocationData> getCurrentLocation({int timeLimitSeconds = 15}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        ).timeout(Duration(seconds: timeLimitSeconds));
      } catch (e) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        throw Exception('Could not determine location');
      }

      // Reverse geocode (on-device, free)
      final placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude,
      );

      final place = placemarks.isNotEmpty ? placemarks.first : null;

      // Generate Plus Code locally (no API needed)
      final plusCode = PlusCodeGenerator.encode(
        position.latitude, position.longitude,
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        locationName: _buildLocationName(place),
        fullAddress: _buildFullAddress(place),
        zipCode: place?.postalCode ?? '--',
        plusCode: plusCode,
        timestamp: DateTime.now(),
        city: place?.locality ?? place?.subLocality ?? '',
        state: place?.administrativeArea ?? '',
        country: place?.country ?? '',
        countryCode: place?.isoCountryCode ?? '',
      );
    } catch (e) {
      final loc = LocationData.empty();
      return loc.copyWith(locationName: 'Error: ${e.toString()}');
    }
  }

  static String _buildLocationName(Placemark? p) {
    if (p == null) return 'Unknown Location';
    return [p.name, p.administrativeArea, p.country]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');
  }

  static String _buildFullAddress(Placemark? p) {
    if (p == null) return '--';
    return [p.street, p.subLocality, p.locality, p.administrativeArea, p.country]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');
  }
}
