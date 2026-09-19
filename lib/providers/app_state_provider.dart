import 'dart:async';
import 'package:flutter/material.dart';
import '../models/location_data.dart';
import '../models/weather_data.dart';
import '../models/sensor_data.dart';
import '../models/settings_data.dart';
import '../models/saved_location.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../services/sensor_service.dart';
import '../services/settings_service.dart';
import '../services/saved_location_service.dart';

class AppStateProvider extends ChangeNotifier {
  // Live Telemetry State
  LocationData _location = LocationData.empty();
  WeatherData _weather = WeatherData.empty();
  SensorData _sensor = SensorData.empty();

  bool _isLocationLoading = true;
  Timer? _locationRetryTimer;
  Timer? _locationRefreshTimer;

  // Settings & Configuration State
  SettingsData _settings = SettingsData.defaultSettings;
  List<SavedLocation> _savedLocations = [];
  String _userNote = '';

  // --- Camera State ---
  bool _isFlashOn = false;
  bool _isGridVisible = false;
  double _currentZoom = 1.0;
  String _currentMode = 'PHOTO'; // PHOTO, VIDEO, QUICK SHARE
  bool _isCapturing = false;

  // --- Getters ---
  LocationData get location {
    final manualLoc = activeManualLocation;
    if (manualLoc != null) {
      return _location.copyWith(
        fullAddress: '${manualLoc.title} - ${manualLoc.address}',
        city: manualLoc.city,
        state: manualLoc.state,
        country: manualLoc.country,
      );
    }
    return _location;
  }
  WeatherData get weather => _weather;
  SensorData get sensor => _sensor;

  bool get isLocationLoading => _isLocationLoading;
  bool get locationAvailable => _location.latitude != 0 || _location.longitude != 0;

  SettingsData get settings => _settings;
  List<SavedLocation> get savedLocations => _savedLocations;

  SavedLocation? get activeManualLocation {
    if (!locationAvailable) return null;
    for (final loc in _savedLocations) {
      if (loc.isInRange(_location.latitude, _location.longitude)) {
        return loc;
      }
    }
    return null;
  }

  String get userNote => _userNote;
  bool get isFlashOn => _isFlashOn;
  bool get isGridVisible => _isGridVisible;
  double get currentZoom => _currentZoom;
  String get currentMode => _currentMode;
  bool get isCapturing => _isCapturing;

  Future<void> updateSettings(SettingsData newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await SettingsService.saveSettings(newSettings);
  }

  Future<void> addSavedLocation(SavedLocation loc) async {
    _savedLocations.add(loc);
    notifyListeners();
    await SavedLocationService.saveLocations(_savedLocations);
  }

  Future<void> removeSavedLocation(String id) async {
    _savedLocations.removeWhere((l) => l.id == id);
    notifyListeners();
    await SavedLocationService.saveLocations(_savedLocations);
  }

  // --- Sensor Service ---
  final SensorService _sensorService = SensorService();

  /// Fire-and-forget setup
  Future<void> initializeAllServices() async {
    _settings = await SettingsService.loadSettings();
    _savedLocations = await SavedLocationService.loadLocations();
    
    _isLocationLoading = true;
    notifyListeners();

    await refreshLocationData();
    
    // Start periodic refresh (every 30 seconds)
    _locationRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_isCapturing) refreshLocationData();
    });

    _sensorService.startListening((data) {
      _sensor = data;
      notifyListeners();
    });
  }

  /// Refresh location and weather (called when user moves significantly)
  @override
  void dispose() {
    _locationRetryTimer?.cancel();
    _locationRefreshTimer?.cancel();
    _sensorService.stopListening();
    super.dispose();
  }

  Future<void> refreshLocationData() async {
    try {
      _location = await LocationService.getCurrentLocation();
      _isLocationLoading = false;
      notifyListeners();
      
      // Stop retry timer if successful
      _locationRetryTimer?.cancel();
      
      // Only fetch weather if location is valid
      if (locationAvailable) {
        _weather = await WeatherService.fetchWeather(
          _location.latitude,
          _location.longitude,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Location/Weather refresh failed: $e');
      if (_isLocationLoading) {
        // Schedule retry
        _locationRetryTimer?.cancel();
        _locationRetryTimer = Timer(const Duration(seconds: 5), refreshLocationData);
      }
    }
  }

  // --- Camera Controls ---
  void toggleFlash() { _isFlashOn = !_isFlashOn; notifyListeners(); }
  void toggleGrid() { _isGridVisible = !_isGridVisible; notifyListeners(); }
  void setZoom(double newZoom) {
    if (newZoom < 1.0) newZoom = 1.0;
    _currentZoom = newZoom;
    notifyListeners();
  }
  void setMode(String m) { _currentMode = m; notifyListeners(); }
  void setCapturing(bool v) { _isCapturing = v; notifyListeners(); }
  void setUserNote(String n) { _userNote = n; notifyListeners(); }

}
