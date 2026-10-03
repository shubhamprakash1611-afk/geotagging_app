import 'package:flutter/material.dart';

import '../models/settings_data.dart';
import '../utils/constants.dart';

class CaptureAspectRatioSelector extends StatelessWidget {
  final CaptureAspectRatio selected;
  final ValueChanged<CaptureAspectRatio> onChanged;

  const CaptureAspectRatioSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Photo aspect ratio',
      child: Container(
        width: (MediaQuery.sizeOf(context).width - 24).clamp(0, 330).toDouble(),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x77000000),
              blurRadius: 22,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: CaptureAspectRatio.values.map((ratio) {
            final isSelected = ratio == selected;
            return Expanded(
              child: Semantics(
                button: true,
                selected: isSelected,
                label: '${ratio.label} aspect ratio',
                child: InkWell(
                  key: ValueKey('aspect-${ratio.name}'),
                  onTap: () => onChanged(ratio),
                  borderRadius: BorderRadius.circular(17),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 1,
                      child: Text(
                        ratio.label,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF042117)
                              : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
