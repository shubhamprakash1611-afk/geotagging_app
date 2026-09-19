import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

class GeoTaggingApp extends StatelessWidget {
  const GeoTaggingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS Map Camera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF00E676),      // Vibrant green accent
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF40C4FF),              // Cyan for sensor icons
          surface: Color(0xFF1A1A2E),                // Deep navy surface
          onSurface: Colors.white,
        ),
        fontFamily: 'Roboto',
        iconTheme: const IconThemeData(color: Colors.white, size: 22),
      ),
      home: const SplashScreen(),
    );
  }
}
