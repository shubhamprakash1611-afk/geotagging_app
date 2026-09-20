import 'dart:convert';
import 'package:camera/camera.dart';

enum GeoTagPlacement { top, bottom }
enum ImageResolution { high, medium, low }
enum MapType { street, earth }

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
  });

  static const SettingsData defaultSettings = SettingsData(
    geoTagPlacement: GeoTagPlacement.bottom,
    geoTagEnabled: true,
    imageResolution: ImageResolution.high,
    shutterSoundEnabled: true,
    mapZoomLevel: 14.0,
    mapType: MapType.street,
    saveDirectory: 'GeoTagCamera',
    activeTemplateId: 'advance', // Setting 'advance' as default since it matches reference mostly
    showWeatherData: true,
    showSensorData: true,
    showPlusCode: true,
    showWatermark: true,
    hapticFeedbackEnabled: true,
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
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
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
    };
  }

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      geoTagPlacement: GeoTagPlacement.values.byName(json['geoTagPlacement'] ?? GeoTagPlacement.bottom.name),
      geoTagEnabled: json['geoTagEnabled'] ?? true,
      imageResolution: ImageResolution.values.byName(json['imageResolution'] ?? ImageResolution.high.name),
      shutterSoundEnabled: json['shutterSoundEnabled'] ?? true,
      mapZoomLevel: (json['mapZoomLevel'] ?? 14.0).toDouble(),
      mapType: MapType.values.byName(json['mapType'] ?? MapType.street.name),
      saveDirectory: json['saveDirectory'] ?? 'GeoTagCamera',
      activeTemplateId: json['activeTemplateId'] ?? 'advance',
      showWeatherData: json['showWeatherData'] ?? true,
      showSensorData: json['showSensorData'] ?? true,
      showPlusCode: json['showPlusCode'] ?? true,
      showWatermark: json['showWatermark'] ?? true,
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] ?? true,
    );
  }
}

