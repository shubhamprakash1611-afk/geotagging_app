import 'dart:math' as math;

class SavedLocation {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String country;
  final int rangeMeters;
  final DateTime createdAt;

  const SavedLocation({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    this.rangeMeters = 30,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'rangeMeters': rangeMeters,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['id'],
      title: json['title'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      rangeMeters: json['rangeMeters'] ?? 30,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  double distanceTo(double lat, double lon) {
    const R = 6371e3; // metres
    final phi1 = latitude * math.pi / 180;
    final phi2 = lat * math.pi / 180;
    final deltaPhi = (lat - latitude) * math.pi / 180;
    final deltaLambda = (lon - longitude) * math.pi / 180;

    final a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) * math.cos(phi2) *
        math.sin(deltaLambda / 2) * math.sin(deltaLambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c; // in metres
  }

  bool isInRange(double lat, double lon) {
    return distanceTo(lat, lon) <= rangeMeters;
  }
}

