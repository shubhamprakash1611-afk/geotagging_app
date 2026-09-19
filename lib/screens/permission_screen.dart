import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'camera_screen.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  Future<void> _requestPermissions(BuildContext context) async {
    // Request all relevant permissions
    await [
      Permission.camera,
      Permission.locationWhenInUse,
      Permission.photos, // iOS & Android 13+
      Permission.storage, // Android <= 12
    ].request();

    // Only strictly block on Camera and Location
    // (Saving to gallery via MediaStore on modern Android doesn't even need storage permissions!)
    final cameraGranted = await Permission.camera.isGranted;
    final locationGranted = await Permission.locationWhenInUse.isGranted;

    if (cameraGranted && locationGranted && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CameraScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_enhance, size: 80, color: Color(0xFF00E676)),
              const SizedBox(height: 24),
              const Text(
                'GPS Map Camera',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                'We need access to your camera, location, and photo library to create geotagged photos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _requestPermissions(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Grant Permissions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
