import 'package:flutter/material.dart';
import 'dart:math' as math;

class SpaceBackgroundPainter extends CustomPainter {
  final double starsAnimation;
  final Color color;

  SpaceBackgroundPainter({
    required this.starsAnimation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw distant stars
    _drawStars(canvas, size);
    
    // Draw moving cosmic dust
    _drawCosmicDust(canvas, size);
    
    // Draw distant galaxies
    _drawDistantGalaxies(canvas, size);
  }

  void _drawStars(Canvas canvas, Size size) {
    // Generate consistent star field
    for (int i = 0; i < 200; i++) {
      final starX = (size.width * (i * 0.618034) % 1.0);
      final starY = (size.height * (i * 0.381966) % 1.0);
      
      // Twinkling effect
      final twinkle = math.sin(starsAnimation * math.pi * 2 + i * 0.1);
      final starOpacity = 0.3 + (twinkle + 1) * 0.3;
      final starSize = 1.0 + twinkle * 0.5;
      
      final paint = Paint()
        ..color = Colors.white.withOpacity(starOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(starX, starY), starSize, paint);
    }
  }

  void _drawCosmicDust(Canvas canvas, Size size) {
    // Floating cosmic dust particles
    for (int i = 0; i < 50; i++) {
      final dustX = (size.width * 0.1 + (size.width * 0.8 * (i / 50.0)) + 
                    starsAnimation * size.width * 0.05) % size.width;
      final dustY = size.height * 0.3 + 
                   size.height * 0.4 * math.sin(starsAnimation * math.pi + i * 0.3);
      
      final dustOpacity = 0.1 + 0.1 * math.sin(starsAnimation * math.pi * 3 + i);
      final dustSize = 1.0 + math.sin(starsAnimation * math.pi * 2 + i) * 0.5;
      
      final dustPaint = Paint()
        ..color = color.withOpacity(dustOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, dustSize);
      
      canvas.drawCircle(Offset(dustX, dustY), dustSize, dustPaint);
    }
  }

  void _drawDistantGalaxies(Canvas canvas, Size size) {
    // Draw a few distant spiral galaxies
    for (int i = 0; i < 3; i++) {
      final galaxyX = size.width * (0.2 + i * 0.3);
      final galaxyY = size.height * (0.15 + i * 0.25);
      final galaxyRadius = 30.0 + i * 10.0;
      
      final galaxyPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(galaxyX, galaxyY), 
          radius: galaxyRadius,
        ));
      
      canvas.drawCircle(Offset(galaxyX, galaxyY), galaxyRadius, galaxyPaint);
      
      // Galaxy spiral arms
      for (int arm = 0; arm < 3; arm++) {
        final path = Path();
        final armAngle = (arm * math.pi * 2 / 3) + starsAnimation * math.pi / 4;
        
        for (double t = 0; t < math.pi * 2; t += 0.1) {
          final spiralRadius = galaxyRadius * 0.3 * (1.0 + t / (math.pi * 2));
          final x = galaxyX + spiralRadius * math.cos(t + armAngle);
          final y = galaxyY + spiralRadius * math.sin(t + armAngle);
          
          if (t == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        
        final armPaint = Paint()
          ..color = color.withOpacity(0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0);
        
        canvas.drawPath(path, armPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
