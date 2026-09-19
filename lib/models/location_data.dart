class LocationData {
  final double latitude;
  final double longitude;
  final double altitude;          // meters
  final String locationName;      // e.g., "Treetop Hideaways, Georgia, USA"
  final String fullAddress;       // e.g., "576 Chattanooga Valley Rd, Flintstone"
  final String zipCode;
  final String plusCode;          // Open Location Code
  final DateTime timestamp;

  final String city;
  final String state;
  final String country;
  final String countryCode;

  String get flagEmoji {
    if (countryCode.isEmpty || countryCode.length != 2) return '';
    return countryCode.toUpperCase().replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
    );
  }

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.locationName,
    required this.fullAddress,
    required this.zipCode,
    required this.plusCode,
    required this.timestamp,
    this.city = '',
    this.state = '',
    this.country = '',
    this.countryCode = '',
  });

  // Fallback for when location is unavailable
  factory LocationData.empty() => LocationData(
    latitude: 0, longitude: 0, altitude: 0,
    locationName: 'Location unavailable',
    fullAddress: '--', zipCode: '--', plusCode: '--',
    timestamp: DateTime.now(),
    city: '', state: '', country: '', countryCode: '',
  );

  LocationData copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    String? locationName,
    String? fullAddress,
    String? zipCode,
    String? plusCode,
    DateTime? timestamp,
    String? city,
    String? state,
    String? country,
    String? countryCode,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      locationName: locationName ?? this.locationName,
      fullAddress: fullAddress ?? this.fullAddress,
      zipCode: zipCode ?? this.zipCode,
      plusCode: plusCode ?? this.plusCode,
      timestamp: timestamp ?? this.timestamp,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}
