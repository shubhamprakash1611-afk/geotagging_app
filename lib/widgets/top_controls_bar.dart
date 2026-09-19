import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class TopControlsBar extends StatelessWidget {
  final VoidCallback onFlashToggled;
  final VoidCallback onSettingsPressed;

  const TopControlsBar({
    super.key,
    required this.onFlashToggled,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, state, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconButton(
                  state.isFlashOn ? Icons.flash_on : Icons.flash_off,
                  () {
                    state.toggleFlash();
                    onFlashToggled();
                  },
                  isActive: state.isFlashOn,
                ),
                _buildIconButton(
                  Icons.aspect_ratio,
                  () {}, // TODO: Cycle aspect ratios
                ),
                _buildIconButton(
                  Icons.grid_on,
                  () => state.toggleGrid(),
                  isActive: state.isGridVisible,
                ),
                _buildIconButton(
                  Icons.settings,
                  onSettingsPressed,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? const Color(0xFF00E676) : Colors.white, size: 22),
      ),
    );
  }
}
