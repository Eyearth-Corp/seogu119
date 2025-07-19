
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';

class TouchFeedbackOverlay extends StatelessWidget {
  final bool isSelectionMode;

  const TouchFeedbackOverlay({super.key, required this.isSelectionMode});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24,
      left: 24,
      child: AnimatedOpacity(
        opacity: isSelectionMode ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: GlassContainer(
          height: 60,
          width: 200,
          gradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(0.40),
              Colors.orange.withOpacity(0.10)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderGradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(0.60),
              Colors.orange.withOpacity(0.10)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderColor: Colors.orange.withOpacity(0.3),
          blur: 15,
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Text(
                  '선택 모드',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
