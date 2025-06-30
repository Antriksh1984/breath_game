import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveBackgroundPainter extends CustomPainter {
  final double waveAnimation;
  final Color color;

  WaveBackgroundPainter({
    required this.waveAnimation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final path = Path();
    const waveHeight = 40.0;
    final waveLength = size.width / 2.5;

    for (int layer = 0; layer < 5; layer++) {
      path.reset();
      final layerOpacity = 0.03 + (layer * 0.02);
      final layerPaint = Paint()
        ..color = color.withOpacity(layerOpacity)
        ..style = PaintingStyle.fill;

      final yOffset = size.height * 0.15 * (layer + 1) + 
                     waveHeight * math.sin(waveAnimation * math.pi * 2 + layer * 0.5);
      
      path.moveTo(0, yOffset);
      
      for (double x = 0; x <= size.width; x += waveLength / 4) {
        final y1 = yOffset + waveHeight * math.sin((x / waveLength) * 2 * math.pi + 
                   waveAnimation * math.pi * 2 + layer * 0.3);
        final y2 = yOffset + waveHeight * math.sin(((x + waveLength / 4) / waveLength) * 2 * math.pi + 
                   waveAnimation * math.pi * 2 + layer * 0.3);
        
        path.quadraticBezierTo(x, y1, x + waveLength / 4, y2);
      }
      
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      
      canvas.drawPath(path, layerPaint);
    }

    for (int i = 0; i < 20; i++) {
      final particleX = (size.width * i / 20 + waveAnimation * size.width * 0.1) % size.width;
      final particleY = size.height * 0.3 + 
                       30 * math.sin(waveAnimation * math.pi * 2 + i * 0.5);
      
      final particlePaint = Paint()
        ..color = color.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(
        Offset(particleX, particleY), 
        2 + math.sin(waveAnimation * math.pi * 4 + i) * 1, 
        particlePaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
