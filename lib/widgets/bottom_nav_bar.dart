import 'package:flutter/material.dart';
import 'shutter_button.dart';
import '../utils/constants.dart';
import 'zoom_mode_selector.dart';

class BottomNavBar extends StatelessWidget {
  final VoidCallback onShutterPressed;
  final VoidCallback onCollectionPressed;
  final VoidCallback onMapDataPressed;
  final VoidCallback onCameraFlipPressed;
  final VoidCallback onTemplatesPressed;
  final Function(double) onZoomChanged;
  final bool isCapturing;
  final bool hapticFeedbackEnabled;

  const BottomNavBar({
    super.key,
    required this.onShutterPressed,
    required this.onCollectionPressed,
    required this.onMapDataPressed,
    required this.onCameraFlipPressed,
    required this.onTemplatesPressed,
    required this.onZoomChanged,
    this.isCapturing = false,
    this.hapticFeedbackEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZoomModeSelector(onZoomChanged: onZoomChanged),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(Icons.collections, 'Collection', onCollectionPressed),
                _buildNavItem(Icons.map_outlined, 'Map Data', onMapDataPressed),
                ShutterButton(
                  onPressed: onShutterPressed, 
                  isCapturing: isCapturing,
                  hapticFeedbackEnabled: hapticFeedbackEnabled,
                ),
                _buildNavItem(Icons.flip_camera_android, 'Camera Flip', onCameraFlipPressed),
                _buildNavItem(Icons.auto_awesome_mosaic, 'Templates', onTemplatesPressed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
