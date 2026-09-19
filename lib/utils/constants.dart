import 'package:flutter/material.dart';

class AppColors {
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentCyan = Color(0xFF40C4FF);
  static const Color sensorBlue = Color(0xFF448AFF);
  static const Color dashboardBg = Color(0xCC1A1A2E);   // Semi-transparent navy
  static const Color chipBg = Color(0x33FFFFFF);         // 20% white
  static const Color surfaceDark = Color(0xFF0D0D1A);
}

class AppSizes {
  /// Returns proportional size based on screen width
  static double proportional(BuildContext context, double factor) {
    return MediaQuery.of(context).size.width * factor;
  }
}
