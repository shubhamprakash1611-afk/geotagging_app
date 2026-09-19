import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShutterButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isCapturing;
  final bool hapticFeedbackEnabled;

  const ShutterButton({
    super.key,
    required this.onPressed,
    this.isCapturing = false,
    this.hapticFeedbackEnabled = true,
  });

  @override
  State<ShutterButton> createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<ShutterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    // Haptic feedback
    if (widget.hapticFeedbackEnabled) {
      HapticFeedback.heavyImpact();
    }

    // Scale animation
    await _animController.forward();
    await _animController.reverse();

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isCapturing ? null : _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: SizedBox(
              width: 72,
              height: 72,
              child: Center(
                child: widget.isCapturing
                    ? const SizedBox(
                        width: 58,
                        height: 58,
                        child: CircularProgressIndicator(
                          color: Color(0xFFB5B3E6), // Light purplish color from frames
                          strokeWidth: 4,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
