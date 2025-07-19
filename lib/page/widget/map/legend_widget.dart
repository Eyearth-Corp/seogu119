
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';

class LegendWidget extends StatelessWidget {
  final bool showTerrain;
  final bool showNumber;
  final bool showDongName;
  final bool showDongAreas;
  final ValueChanged<bool> onTerrainVisibilityChanged;
  final ValueChanged<bool> onNumberVisibilityChanged;
  final ValueChanged<bool> onDongNameVisibilityChanged;
  final ValueChanged<bool> onDongAreasVisibilityChanged;

  const LegendWidget({
    super.key,
    required this.showTerrain,
    required this.showNumber,
    required this.showDongName,
    required this.showDongAreas,
    required this.onTerrainVisibilityChanged,
    required this.onNumberVisibilityChanged,
    required this.onDongNameVisibilityChanged,
    required this.onDongAreasVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: GlassContainer(
        height: 110,
        width: double.infinity,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.40),
            Colors.white.withOpacity(0.10)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.60),
            Colors.white.withOpacity(0.10)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Colors.white.withOpacity(0.3),
        blur: 15,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildEnhancedToggle(
                      title: '지형',
                      icon: Icons.terrain,
                      value: showTerrain,
                      onChanged: onTerrainVisibilityChanged,
                    ),
                  ),
                  Expanded(
                    child: _buildEnhancedToggle(
                      title: '번호',
                      icon: Icons.numbers,
                      value: showNumber,
                      onChanged: onNumberVisibilityChanged,
                    ),
                  ),
                  Expanded(
                    child: _buildEnhancedToggle(
                      title: '동이름',
                      icon: Icons.location_city,
                      value: showDongName,
                      onChanged: onDongNameVisibilityChanged,
                    ),
                  ),
                  Expanded(
                    child: _buildEnhancedToggle(
                      title: '구역',
                      icon: Icons.map,
                      value: showDongAreas,
                      onChanged: onDongAreasVisibilityChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedToggle({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value ? Colors.blue.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? Colors.blue : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: value ? Colors.blue : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: value ? Colors.blue : Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
