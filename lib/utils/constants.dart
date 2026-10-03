import 'package:flutter/material.dart';

class AppColors {
  static const Color accentGreen = Color(0xFF39E6A5);
  static const Color accentCyan = Color(0xFF64D2FF);
  static const Color accentViolet = Color(0xFF9A8CFF);
  static const Color brandBlue = Color(0xFF168DFF);
  static const Color brandRed = Color(0xFFFF4A43);
  static const Color brandAmber = Color(0xFFFFB62E);
  static const Color sensorBlue = Color(0xFF67A8FF);
  static const Color background = Color(0xFF060A12);
  static const Color surfaceDark = Color(0xFF101827);
  static const Color surfaceRaised = Color(0xFF172235);
  static const Color outline = Color(0xFF2A3950);
  static const Color textPrimary = Color(0xFFF5F8FC);
  static const Color textSecondary = Color(0xFF9EACC0);
  static const Color dashboardBg = Color(0xE6121C2C);
  static const Color chipBg = Color(0x33FFFFFF); // 20% white

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentGreen, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surfaceRaised, surfaceDark, background],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF168DFF), Color(0xFF48C8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppSizes {
  /// Returns proportional size based on screen width
  static double proportional(BuildContext context, double factor) {
    return MediaQuery.of(context).size.width * factor;
  }
}
