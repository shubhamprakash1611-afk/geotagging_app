import 'package:flutter/material.dart';
import 'permission_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'camera_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Add a small delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 2));

    final cameraStatus = await Permission.camera.status;
    final locationStatus = await Permission.locationWhenInUse.status;

    if (mounted) {
      if (cameraStatus.isGranted && locationStatus.isGranted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CameraScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PermissionScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera, size: 100, color: const Color(0xFF00E676)),
            const SizedBox(height: 20),
            const Text(
              'GeoTag Camera',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Color(0xFF00E676)),
          ],
        ),
      ),
    );
  }
}
