import 'package:flutter/material.dart';
import 'shutter_button.dart';
import '../utils/app_translations.dart';
import '../models/settings_data.dart';
import 'zoom_mode_selector.dart';
import '../utils/constants.dart';

class BottomNavBar extends StatelessWidget {
  final VoidCallback onShutterPressed;
  final VoidCallback onCollectionPressed;
  final VoidCallback onMapDataPressed;
  final VoidCallback onCameraFlipPressed;
  final VoidCallback onTemplatesPressed;
  final Function(double) onZoomChanged;
  final bool isCapturing;
  final bool hapticFeedbackEnabled;
  final AppLanguage language;

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
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTranslations(language);

    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xF5172335), AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top:
              BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZoomModeSelector(onZoomChanged: onZoomChanged),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(Icons.photo_library_outlined,
                    t.text('collection'), onCollectionPressed),
                _buildNavItem(
                    Icons.map_outlined, t.text('mapData'), onMapDataPressed),
                ShutterButton(
                  onPressed: onShutterPressed,
                  isCapturing: isCapturing,
                  hapticFeedbackEnabled: hapticFeedbackEnabled,
                ),
                _buildNavItem(Icons.flip_camera_android_rounded,
                    t.text('cameraFlip'), onCameraFlipPressed),
                _buildNavItem(Icons.dashboard_customize_outlined,
                    t.text('template'), onTemplatesPressed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return Tooltip(
      message: label,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: SizedBox(
          width: 58,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.055),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Icon(icon, color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
