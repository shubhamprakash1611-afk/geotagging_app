import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_data.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';

class TopControlsBar extends StatelessWidget {
  final VoidCallback onFlashToggled;
  final VoidCallback onAspectRatioPressed;
  final VoidCallback onSettingsPressed;

  const TopControlsBar({
    super.key,
    required this.onFlashToggled,
    required this.onAspectRatioPressed,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, state, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ControlGroup(
                  children: [
                    _buildIconButton(
                      state.isFlashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      () {
                        state.toggleFlash();
                        onFlashToggled();
                      },
                      tooltip: state.isFlashOn
                          ? 'Flash enabled for capture'
                          : 'Flash disabled',
                      isActive: state.isFlashOn,
                    ),
                    Container(
                      width: 1,
                      height: 22,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    _buildIconButton(
                      Icons.aspect_ratio_rounded,
                      onAspectRatioPressed,
                      tooltip:
                          'Photo ratio: ${state.settings.captureAspectRatio.label}',
                    ),
                    Container(
                      width: 1,
                      height: 22,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    _buildIconButton(
                      Icons.grid_3x3_rounded,
                      () => state.toggleGrid(),
                      tooltip: 'Composition grid',
                      isActive: state.isGridVisible,
                    ),
                  ],
                ),
                _ControlGroup(
                  children: [
                    _buildIconButton(
                      Icons.tune_rounded,
                      onSettingsPressed,
                      tooltip: 'Settings',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onTap, {
    required String tooltip,
    bool isActive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: isActive ? const Color(0xFF042117) : AppColors.textPrimary,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class _ControlGroup extends StatelessWidget {
  final List<Widget> children;

  const _ControlGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceRaised.withValues(alpha: 0.88),
            AppColors.background.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
