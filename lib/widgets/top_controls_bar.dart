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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xB30A0F1A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
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
          ),
        );
      },
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap,
      {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0x2200E676) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: isActive ? const Color(0xFF00E676) : Colors.white, size: 22),
      ),
    );
  }
}
