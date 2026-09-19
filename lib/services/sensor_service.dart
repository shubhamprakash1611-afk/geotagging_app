import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sensor_data.dart';

class SensorService {
  StreamSubscription<MagnetometerEvent>? _subscription;
  SensorData _latest = SensorData.empty();

  SensorData get latest => _latest;

  /// Start listening to the device magnetometer.
  /// Cost: $0 — reads physical hardware sensor.
  void startListening(void Function(SensorData) onData) {
    _subscription = magnetometerEventStream(
      samplingPeriod: const Duration(milliseconds: 500),
    ).listen((event) {
      _latest = SensorData.fromXYZ(event.x, event.y, event.z);
      onData(_latest);
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}
