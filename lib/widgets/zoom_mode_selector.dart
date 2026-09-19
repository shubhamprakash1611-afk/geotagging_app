import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';

class ZoomModeSelector extends StatelessWidget {
  final Function(double) onZoomChanged;
  const ZoomModeSelector({super.key, required this.onZoomChanged});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, state, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Zoom Row ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [1.0, 2.0, 3.0].map((zoom) {
                final isActive = state.currentZoom == zoom;
                return GestureDetector(
                  onTap: () {
                    state.setZoom(zoom);
                    onZoomChanged(zoom);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.accentGreen : Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? AppColors.accentGreen : Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${zoom}x',
                      style: TextStyle(
                        color: isActive ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // --- Mode Row ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['QUICK SHARE', 'PHOTO', 'VIDEO'].map((mode) {
                final isActive = state.currentMode == mode;
                return GestureDetector(
                  onTap: () => state.setMode(mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.accentGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      mode,
                      style: TextStyle(
                        color: isActive ? Colors.black : Colors.white70,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
