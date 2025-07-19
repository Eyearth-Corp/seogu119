
import 'package:flutter/material.dart';
import 'package:seogu119/page/data/dong_list.dart';

class MerchantMarker extends StatelessWidget {
  final Merchant merchant;
  final Dong dong;
  final bool isHighlighted;
  final Animation<double> pulseAnimation;

  static const double _touchTargetSize = 46.0;
  static const double _fontSize = 16.0;

  const MerchantMarker({
    super.key,
    required this.merchant,
    required this.dong,
    required this.isHighlighted,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        final scale = isHighlighted ? pulseAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: _touchTargetSize,
            height: _touchTargetSize,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isHighlighted ? Colors.orange : dong.color,
                width: isHighlighted ? 4 : 3,
              ),
              borderRadius: BorderRadius.circular(_touchTargetSize / 2),
              boxShadow: [
                BoxShadow(
                  color: dong.color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    merchant.id.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: _fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isHighlighted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.orange,
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
