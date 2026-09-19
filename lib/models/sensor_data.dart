import 'dart:math';

class SensorData {
  final double magneticFieldMicroTesla;  // Total magnitude in µT

  const SensorData({required this.magneticFieldMicroTesla});

  factory SensorData.empty() => const SensorData(magneticFieldMicroTesla: 0);

  /// Compute total magnitude from raw x,y,z magnetometer readings
  factory SensorData.fromXYZ(double x, double y, double z) {
    return SensorData(
      magneticFieldMicroTesla: sqrt(x * x + y * y + z * z),
    );
  }
}
