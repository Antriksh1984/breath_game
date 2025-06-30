import 'package:flutter/material.dart';
import 'dart:math' as math;

class DynamicShapePainter extends CustomPainter {
  final int shapeType;
  final double breathingValue;
  final double pulseValue;
  final double shapeValue;
  final double colorValue;
  final Color primaryColor;
  final bool isActive;

  DynamicShapePainter({
    required this.shapeType,
    required this.breathingValue,
    required this.pulseValue,
    required this.shapeValue,
    required this.colorValue,
    required this.primaryColor,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.2;
    final animatedRadius = baseRadius * breathingValue * pulseValue;

    switch (shapeType) {
      case 0:
        _drawCosmicStar(canvas, center, animatedRadius);
        break;
      case 1:
        _drawSpinningGalaxy(canvas, center, animatedRadius);
        break;
      case 2:
        _drawPulsarNebula(canvas, center, animatedRadius);
        break;
      case 3:
        _drawQuantumPulsar(canvas, center, animatedRadius);
        break;
      case 4:
        _drawCosmicQuasar(canvas, center, animatedRadius);
        break;
    }
  }

  void _drawCosmicStar(Canvas canvas, Offset center, double radius) {
    // Outer cosmic glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.4),
          primaryColor.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 2));

    canvas.drawCircle(center, radius * 2, glowPaint);

    // Main star core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.9),
          primaryColor.withOpacity(0.8),
          primaryColor.withOpacity(0.3),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, corePaint);

    // Star rays
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8 + shapeValue * math.pi / 4;
      final rayLength = radius * 1.5;
      
      final start = Offset(
        center.dx + radius * 0.8 * math.cos(angle),
        center.dy + radius * 0.8 * math.sin(angle),
      );
      final end = Offset(
        center.dx + rayLength * math.cos(angle),
        center.dy + rayLength * math.sin(angle),
      );
      
      final rayPaint = Paint()
        ..color = primaryColor.withOpacity(0.6)
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawSpinningGalaxy(Canvas canvas, Offset center, double radius) {
    // Galaxy core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.8),
          primaryColor.withOpacity(0.6),
          primaryColor.withOpacity(0.2),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.3));

    canvas.drawCircle(center, radius * 0.3, corePaint);

    // Spiral arms
    for (int arm = 0; arm < 3; arm++) {
      final path = Path();
      final armAngle = (arm * math.pi * 2 / 3) + shapeValue * math.pi / 2;
      
      for (double t = 0; t < math.pi * 3; t += 0.1) {
        final spiralRadius = radius * 0.2 + (radius * 0.6 * t / (math.pi * 3));
        final x = center.dx + spiralRadius * math.cos(t + armAngle);
        final y = center.dy + spiralRadius * math.sin(t + armAngle);
        
        if (t == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      final armPaint = Paint()
        ..color = primaryColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawPath(path, armPaint);
    }
  }

  void _drawPulsarNebula(Canvas canvas, Offset center, double radius) {
    // Nebula layers
    for (int layer = 0; layer < 4; layer++) {
      final layerRadius = radius * (0.5 + layer * 0.2);
      final layerOpacity = 0.3 - layer * 0.05;
      
      final nebulaPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            primaryColor.withOpacity(layerOpacity),
            primaryColor.withOpacity(layerOpacity * 0.3),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: layerRadius))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + layer * 2);
      
      canvas.drawCircle(center, layerRadius, nebulaPaint);
    }

    // Pulsar beams
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + shapeValue * math.pi * 2;
      final beamLength = radius * 1.8;
      
      final start = center;
      final end = Offset(
        center.dx + beamLength * math.cos(angle),
        center.dy + beamLength * math.sin(angle),
      );
      
      final beamPaint = Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      canvas.drawLine(start, end, beamPaint);
    }
  }

  void _drawQuantumPulsar(Canvas canvas, Offset center, double radius) {
    // Quantum field rings
    for (int ring = 1; ring <= 5; ring++) {
      final ringRadius = radius * ring / 5;
      final ringOpacity = 0.4 - ring * 0.06;
      
      final ringPaint = Paint()
        ..color = primaryColor.withOpacity(ringOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + ring * 0.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(center, ringRadius, ringPaint);
    }

    // Quantum particles
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi * 2) / 12 + shapeValue * math.pi;
      final particleDistance = radius * (0.7 + 0.3 * math.sin(shapeValue * math.pi * 3 + i));
      final particleCenter = Offset(
        center.dx + particleDistance * math.cos(angle),
        center.dy + particleDistance * math.sin(angle),
      );
      
      final particlePaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(particleCenter, 2, particlePaint);
    }

    // Central core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          primaryColor.withOpacity(0.8),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.2));
    
    canvas.drawCircle(center, radius * 0.2, corePaint);
  }

  void _drawCosmicQuasar(Canvas canvas, Offset center, double radius) {
    // Quasar jets
    final jetPaint = Paint()
      ..color = primaryColor.withOpacity(0.6)
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    // Vertical jets
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 2),
      Offset(center.dx, center.dy + radius * 2),
      jetPaint,
    );

    // Accretion disk
    for (int ring = 1; ring <= 3; ring++) {
      final diskRadius = radius * ring / 3;
      final diskPaint = Paint()
        ..color = primaryColor.withOpacity(0.3 - ring * 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      // Elliptical disk
      final rect = Rect.fromCenter(
        center: center,
        width: diskRadius * 2,
        height: diskRadius * 0.3,
      );
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(shapeValue * math.pi / 4);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawOval(rect, diskPaint);
      canvas.restore();
    }

    // Central black hole
    final blackHolePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black,
          primaryColor.withOpacity(0.8),
          primaryColor.withOpacity(0.3),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.3));
    
    canvas.drawCircle(center, radius * 0.3, blackHolePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
