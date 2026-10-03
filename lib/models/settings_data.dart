import 'package:camera/camera.dart';

enum GeoTagPlacement { top, bottom }

enum ImageResolution { high, medium, low }

enum MapType { street, earth }

enum AppLanguage { en, hi }

enum CaptureAspectRatio { ratio4x3, ratio9x16, square, full }

extension CaptureAspectRatioLabel on CaptureAspectRatio {
  String get label {
    switch (this) {
      case CaptureAspectRatio.ratio4x3:
        return '3:4';
      case CaptureAspectRatio.ratio9x16:
        return '9:16';
      case CaptureAspectRatio.square:
        return '1:1';
      case CaptureAspectRatio.full:
        return 'Full';
    }
  }
}

class SettingsData {
  final GeoTagPlacement geoTagPlacement;
  final bool geoTagEnabled;
  final ImageResolution imageResolution;
  final bool shutterSoundEnabled;
  final double mapZoomLevel;
  final MapType mapType;
  final String saveDirectory;
  final String activeTemplateId;
  final bool showWeatherData;
  final bool showSensorData;
  final bool showPlusCode;
  final bool showWatermark;
  final bool hapticFeedbackEnabled;
  final AppLanguage language;
  final CaptureAspectRatio captureAspectRatio;

  const SettingsData({
    required this.geoTagPlacement,
    required this.geoTagEnabled,
    required this.imageResolution,
    required this.shutterSoundEnabled,
    required this.mapZoomLevel,
    required this.mapType,
    required this.saveDirectory,
    required this.activeTemplateId,
    required this.showWeatherData,
    required this.showSensorData,
    required this.showPlusCode,
    required this.showWatermark,
    required this.hapticFeedbackEnabled,
    required this.language,
    required this.captureAspectRatio,
  });

  static const SettingsData defaultSettings = SettingsData(
    geoTagPlacement: GeoTagPlacement.bottom,
    geoTagEnabled: true,
    imageResolution: ImageResolution.high,
    shutterSoundEnabled: true,
    mapZoomLevel: 14.0,
    mapType: MapType.street,
    saveDirectory: 'GeoTagCamera',
    activeTemplateId:
        'advance', // Setting 'advance' as default since it matches reference mostly
    showWeatherData: true,
    showSensorData: true,
    showPlusCode: true,
    showWatermark: true,
    hapticFeedbackEnabled: true,
    language: AppLanguage.en,
    captureAspectRatio: CaptureAspectRatio.ratio4x3,
  );

  ResolutionPreset toResolutionPreset() {
    switch (imageResolution) {
      case ImageResolution.high:
        return ResolutionPreset.max;
      case ImageResolution.medium:
        return ResolutionPreset.high;
      case ImageResolution.low:
        return ResolutionPreset.medium;
    }
  }

  SettingsData copyWith({
    GeoTagPlacement? geoTagPlacement,
    bool? geoTagEnabled,
    ImageResolution? imageResolution,
    bool? shutterSoundEnabled,
    double? mapZoomLevel,
    MapType? mapType,
    String? saveDirectory,
    String? activeTemplateId,
    bool? showWeatherData,
    bool? showSensorData,
    bool? showPlusCode,
    bool? showWatermark,
    bool? hapticFeedbackEnabled,
    AppLanguage? language,
    CaptureAspectRatio? captureAspectRatio,
  }) {
    return SettingsData(
      geoTagPlacement: geoTagPlacement ?? this.geoTagPlacement,
      geoTagEnabled: geoTagEnabled ?? this.geoTagEnabled,
      imageResolution: imageResolution ?? this.imageResolution,
      shutterSoundEnabled: shutterSoundEnabled ?? this.shutterSoundEnabled,
      mapZoomLevel: mapZoomLevel ?? this.mapZoomLevel,
      mapType: mapType ?? this.mapType,
      saveDirectory: saveDirectory ?? this.saveDirectory,
      activeTemplateId: activeTemplateId ?? this.activeTemplateId,
      showWeatherData: showWeatherData ?? this.showWeatherData,
      showSensorData: showSensorData ?? this.showSensorData,
      showPlusCode: showPlusCode ?? this.showPlusCode,
      showWatermark: showWatermark ?? this.showWatermark,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      language: language ?? this.language,
      captureAspectRatio: captureAspectRatio ?? this.captureAspectRatio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geoTagPlacement': geoTagPlacement.name,
      'geoTagEnabled': geoTagEnabled,
      'imageResolution': imageResolution.name,
      'shutterSoundEnabled': shutterSoundEnabled,
      'mapZoomLevel': mapZoomLevel,
      'mapType': mapType.name,
      'saveDirectory': saveDirectory,
      'activeTemplateId': activeTemplateId,
      'showWeatherData': showWeatherData,
      'showSensorData': showSensorData,
      'showPlusCode': showPlusCode,
      'showWatermark': showWatermark,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'language': language.name,
      'captureAspectRatio': captureAspectRatio.name,
    };
  }

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      geoTagPlacement: GeoTagPlacement.values
          .byName(json['geoTagPlacement'] ?? GeoTagPlacement.bottom.name),
      geoTagEnabled: json['geoTagEnabled'] ?? true,
      imageResolution: ImageResolution.values
          .byName(json['imageResolution'] ?? ImageResolution.high.name),
      shutterSoundEnabled: json['shutterSoundEnabled'] ?? true,
      mapZoomLevel: (json['mapZoomLevel'] ?? 14.0).toDouble(),
      mapType: MapType.values.byName(json['mapType'] ?? MapType.street.name),
      saveDirectory: json['saveDirectory'] ?? 'GeoTagCamera',
      activeTemplateId: _normalizeTemplateId(json['activeTemplateId']),
      showWeatherData: json['showWeatherData'] ?? true,
      showSensorData: json['showSensorData'] ?? true,
      showPlusCode: json['showPlusCode'] ?? true,
      showWatermark: json['showWatermark'] ?? true,
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] ?? true,
      language:
          AppLanguage.values.byName(json['language'] ?? AppLanguage.en.name),
      captureAspectRatio: CaptureAspectRatio.values.byName(
        json['captureAspectRatio'] ?? CaptureAspectRatio.ratio4x3.name,
      ),
    );
  }

  static String _normalizeTemplateId(dynamic value) {
    const legacyIds = {
      'advance_template': 'advance',
      'advance2_template': 'advance2',
      'advance_2': 'advance2',
      'datetime_template': 'datetime',
      'scan_location_template': 'scan_location',
      'classic_template': 'classic',
      'reporting_template': 'reporting',
      'navigation_template': 'navigation',
    };
    final id = value is String ? value : 'advance';
    return legacyIds[id] ?? id;
  }
}
