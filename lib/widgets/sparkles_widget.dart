import 'package:flutter/material.dart';
import 'dart:math' as math;

class SparklesWidget extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final bool isActive;

  const SparklesWidget({
    super.key,
    required this.animation,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: SparklesPainter(
            animationValue: animation.value,
            color: color,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class SparklesPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  SparklesPainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    for (int i = 0; i < 50; i++) {
      final sparkleX = (size.width * (i * 0.618034) % 1.0);
      final sparkleY = (size.height * (i * 0.381966) % 1.0);
      
      final sparklePhase = (animationValue + i * 0.1) % 1.0;
      final sparkleOpacity = math.sin(sparklePhase * math.pi).abs();
      final sparkleSize = 1 + sparkleOpacity * 2;
      
      if (sparkleOpacity > 0.1) {
        final sparklePaint = Paint()
          ..color = color.withOpacity(sparkleOpacity * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, sparkleSize);
        
        canvas.drawCircle(
          Offset(sparkleX, sparkleY),
          sparkleSize,
          sparklePaint,
        );
      }
    }

    for (int i = 0; i < 15; i++) {
      final sparkleX = size.width * 0.1 + (size.width * 0.8 * (i / 15.0));
      final sparkleY = size.height * 0.2 + 
                      size.height * 0.6 * math.sin(animationValue * math.pi * 2 + i * 0.4);
      
      final sparklePhase = (animationValue * 0.5 + i * 0.2) % 1.0;
      final sparkleOpacity = (math.sin(sparklePhase * math.pi * 2) + 1) / 2;
      final sparkleSize = 2 + sparkleOpacity * 3;
      
      final sparklePaint = Paint()
        ..color = color.withOpacity(sparkleOpacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, sparkleSize);
      
      canvas.drawCircle(
        Offset(sparkleX, sparkleY),
        sparkleSize,
        sparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
