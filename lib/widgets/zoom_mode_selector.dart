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
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [1.0, 2.0, 3.0].map((zoom) {
              final isActive = state.currentZoom == zoom;
              return Semantics(
                button: true,
                selected: isActive,
                label: '${zoom.toStringAsFixed(0)} times zoom',
                child: GestureDetector(
                  onTap: () {
                    state.setZoom(zoom);
                    onZoomChanged(zoom);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 58,
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      gradient: isActive ? AppColors.primaryGradient : null,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.accentGreen
                                    .withValues(alpha: 0.22),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '${zoom.toStringAsFixed(0)}×',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFF042117)
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
