import 'dart:math';

class SensorData {
  final double magneticFieldMicroTesla;  // Total magnitude in µT
  final double azimuth;

  const SensorData({required this.magneticFieldMicroTesla, this.azimuth = 0});

  factory SensorData.empty() => const SensorData(magneticFieldMicroTesla: 0, azimuth: 0);

  /// Compute total magnitude and basic azimuth from raw x,y,z magnetometer readings
  factory SensorData.fromXYZ(double x, double y, double z) {
    double heading = (atan2(y, x) * 180 / pi) + 90; // +90 aligns for portrait orientation on most phones
    if (heading < 0) heading += 360;
    heading = heading % 360;

    return SensorData(
      magneticFieldMicroTesla: sqrt(x * x + y * y + z * z),
      azimuth: heading,
    );
  }
}
