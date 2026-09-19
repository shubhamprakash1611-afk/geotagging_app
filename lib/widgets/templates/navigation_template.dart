import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../models/location_data.dart';
import '../../models/sensor_data.dart';
import '../../utils/constants.dart';

class NavigationTemplate extends StatelessWidget {
  final LocationData loc;
  final SensorData sensor;

  const NavigationTemplate({
    super.key,
    required this.loc,
    required this.sensor,
  });

  String _getDirection(double azimuth) {
    if (azimuth < 0) azimuth += 360;
    if (azimuth >= 337.5 || azimuth < 22.5) return 'North';
    if (azimuth >= 22.5 && azimuth < 67.5) return 'North East';
    if (azimuth >= 67.5 && azimuth < 112.5) return 'East';
    if (azimuth >= 112.5 && azimuth < 157.5) return 'South East';
    if (azimuth >= 157.5 && azimuth < 202.5) return 'South';
    if (azimuth >= 202.5 && azimuth < 247.5) return 'South West';
    if (azimuth >= 247.5 && azimuth < 292.5) return 'West';
    if (azimuth >= 292.5 && azimuth < 337.5) return 'North West';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    // Basic azimuth approximation from magnetometer for UI purposes
    double azimuth = 0;
    if (sensor.magneticFieldMicroTesla > 0) {
      // Just a mock visualization logic, real compass requires accel + mag
      azimuth = (sensor.magneticFieldMicroTesla * 3.14) % 360.0;
    }

    final screenW = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sensorBlue.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Compass Rose
          SizedBox(
            width: screenW * 0.20,
            height: screenW * 0.20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white38)),
                ),
                Transform.rotate(
                  angle: azimuth * (math.pi / 180) * -1,
                  child: const Icon(Icons.navigation, color: AppColors.sensorBlue, size: 40),
                ),
                const Positioned(top: 2, child: Text('N', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                const Positioned(bottom: 2, child: Text('S', style: TextStyle(color: Colors.white54, fontSize: 10))),
                const Positioned(right: 4, child: Text('E', style: TextStyle(color: Colors.white54, fontSize: 10))),
                const Positioned(left: 4, child: Text('W', style: TextStyle(color: Colors.white54, fontSize: 10))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Facing ${_getDirection(azimuth)}',
                  style: const TextStyle(color: AppColors.sensorBlue, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat('Bearing', '${azimuth.toStringAsFixed(0)}°'),
                    _buildStat('Altitude', '${loc.altitude.toStringAsFixed(1)} m'),
                    _buildStat('Mag. Field', '${sensor.magneticFieldMicroTesla.toStringAsFixed(1)} µT'),
                  ],
                ),
                const Divider(color: Colors.white24, height: 16),
                Text(
                  loc.fullAddress,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${loc.latitude.toStringAsFixed(6)}°, ${loc.longitude.toStringAsFixed(6)}° • ${DateFormat('HH:mm:ss').format(loc.timestamp)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

