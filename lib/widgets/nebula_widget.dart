import 'package:flutter/material.dart';
import 'dart:math' as math;

class NebulaWidget extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final bool isActive;

  const NebulaWidget({
    super.key,
    required this.animation,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: NebulaPainter(
            animationValue: animation.value,
            color: color,
            isActive: isActive,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class NebulaPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final bool isActive;

  NebulaPainter({
    required this.animationValue,
    required this.color,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    // Draw nebula clouds
    _drawNebulaCloud(canvas, size, 0.3, 0.2);
    _drawNebulaCloud(canvas, size, 0.7, 0.6);
    _drawNebulaCloud(canvas, size, 0.1, 0.8);
  }

  void _drawNebulaCloud(Canvas canvas, Size size, double xFactor, double yFactor) {
    final centerX = size.width * xFactor;
    final centerY = size.height * yFactor;
    const baseRadius = 80;
    
    // Animated nebula movement
    final offsetX = 20 * math.sin(animationValue * math.pi * 2);
    final offsetY = 15 * math.cos(animationValue * math.pi * 1.5);
    
    final center = Offset(centerX + offsetX, centerY + offsetY);
    
    // Multiple layers for depth
    for (int layer = 0; layer < 3; layer++) {
      final layerRadius = baseRadius * (1 + layer * 0.3);
      final layerOpacity = 0.05 - layer * 0.01;
      
      final nebulaPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withOpacity(layerOpacity),
            color.withOpacity(layerOpacity * 0.5),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: layerRadius))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15 + layer * 5);
      
      canvas.drawCircle(center, layerRadius, nebulaPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
