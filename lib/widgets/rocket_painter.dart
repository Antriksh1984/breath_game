import 'package:flutter/material.dart';
import 'dart:math' as math;

class RocketPainter extends CustomPainter {
  final double fuelLevel; // 0.0 to 1.0
  final double travelDistance; // 0.0 to 1.0 (percentage of max distance)
  final Color primaryColor;
  final bool isActive;
  final String currentPhase;

  RocketPainter({
    required this.fuelLevel,
    required this.travelDistance,
    required this.primaryColor,
    required this.isActive,
    required this.currentPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Calculate rocket position based on travel distance
    final rocketY = center.dy - (travelDistance * size.height * 0.25);
    final rocketCenter = Offset(center.dx, rocketY);
    
    // Draw launch pad
    _drawLaunchPad(canvas, size, center);
    
    // Draw fuel gauge
    _drawFuelGauge(canvas, size);
    
    // Draw distance meter
    _drawDistanceMeter(canvas, size);
    
    // Draw rocket
    _drawRocket(canvas, rocketCenter);
    
    // Draw rocket exhaust if launching
    if (currentPhase.contains('Launch') && travelDistance > 0) {
      _drawRocketExhaust(canvas, rocketCenter);
    }
    
    // Draw fuel effects if fueling
    if (currentPhase.contains('Fuel') && fuelLevel > 0) {
      _drawFuelEffects(canvas, center);
    }
  }

  void _drawLaunchPad(Canvas canvas, Size size, Offset center) {
    // Launch pad base
    final padPaint = Paint()
      ..color = Colors.grey.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    final padRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.85),
        width: 120,
        height: 20,
      ),
      const Radius.circular(10),
    );
    
    canvas.drawRRect(padRect, padPaint);
    
    // Launch pad details
    final detailPaint = Paint()
      ..color = primaryColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRRect(padRect, detailPaint);
    
    // Support pillars
    for (int i = 0; i < 3; i++) {
      final pillarX = center.dx - 40 + (i * 40);
      canvas.drawLine(
        Offset(pillarX, size.height * 0.85 - 10),
        Offset(pillarX, size.height * 0.85 + 30),
        Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..strokeWidth = 4,
      );
    }
  }

  void _drawFuelGauge(Canvas canvas, Size size) {
    final gaugeCenter = Offset(size.width * 0.15, size.height * 0.3);
    final gaugeHeight = size.height * 0.4;
    const gaugeWidth = 30.0;
    
    // Gauge background
    final gaugeBg = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final gaugeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: gaugeCenter,
        width: gaugeWidth,
        height: gaugeHeight,
      ),
      const Radius.circular(15),
    );
    
    canvas.drawRRect(gaugeRect, gaugeBg);
    
    // Fuel level
    if (fuelLevel > 0) {
      final fuelPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            primaryColor.withOpacity(0.8),
            primaryColor.withOpacity(0.4),
          ],
        ).createShader(Rect.fromLTWH(
          gaugeCenter.dx - gaugeWidth / 2,
          gaugeCenter.dy + gaugeHeight / 2 - (gaugeHeight * fuelLevel),
          gaugeWidth,
          gaugeHeight * fuelLevel,
        ));
      
      final fuelRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          gaugeCenter.dx - gaugeWidth / 2,
          gaugeCenter.dy + gaugeHeight / 2 - (gaugeHeight * fuelLevel),
          gaugeWidth,
          gaugeHeight * fuelLevel,
        ),
        const Radius.circular(15),
      );
      
      canvas.drawRRect(fuelRect, fuelPaint);
    }
    
    // Gauge border
    canvas.drawRRect(
      gaugeRect,
      Paint()
        ..color = primaryColor.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    
    // Fuel percentage text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'FUEL\n${(fuelLevel * 100).toInt()}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        gaugeCenter.dx - textPainter.width / 2,
        gaugeCenter.dy + gaugeHeight / 2 + 15,
      ),
    );
  }

  void _drawDistanceMeter(Canvas canvas, Size size) {
    final meterCenter = Offset(size.width * 0.85, size.height * 0.3);
    final meterHeight = size.height * 0.4;
    const meterWidth = 30.0;
    
    // Meter background
    final meterBg = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final meterRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: meterCenter,
        width: meterWidth,
        height: meterHeight,
      ),
      const Radius.circular(15),
    );
    
    canvas.drawRRect(meterRect, meterBg);
    
    // Distance traveled
    if (travelDistance > 0) {
      final distancePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            primaryColor.withOpacity(0.8),
            primaryColor.withOpacity(0.4),
          ],
        ).createShader(Rect.fromLTWH(
          meterCenter.dx - meterWidth / 2,
          meterCenter.dy + meterHeight / 2 - (meterHeight * travelDistance),
          meterWidth,
          meterHeight * travelDistance,
        ));
      
      final distanceRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          meterCenter.dx - meterWidth / 2,
          meterCenter.dy + meterHeight / 2 - (meterHeight * travelDistance),
          meterWidth,
          meterHeight * travelDistance,
        ),
        const Radius.circular(15),
      );
      
      canvas.drawRRect(distanceRect, distancePaint);
    }
    
    // Meter border
    canvas.drawRRect(
      meterRect,
      Paint()
        ..color = primaryColor.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    
    // Distance text
    final distanceKm = (travelDistance * 150).toInt(); // Max 150km
    final distanceText = TextPainter(
      text: TextSpan(
        text: 'DIST\n${distanceKm}km',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    distanceText.layout();
    distanceText.paint(
      canvas,
      Offset(
        meterCenter.dx - distanceText.width / 2,
        meterCenter.dy + meterHeight / 2 + 15,
      ),
    );
  }

  void _drawRocket(Canvas canvas, Offset center) {
    // Rocket body
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          Colors.grey.shade300,
        ],
      ).createShader(Rect.fromCenter(center: center, width: 40, height: 100));
    
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 40, height: 100),
      const Radius.circular(20),
    );
    
    canvas.drawRRect(bodyRect, bodyPaint);
    
    // Rocket nose cone
    final nosePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    final nosePath = Path();
    nosePath.moveTo(center.dx, center.dy - 70);
    nosePath.lineTo(center.dx - 20, center.dy - 50);
    nosePath.lineTo(center.dx + 20, center.dy - 50);
    nosePath.close();
    
    canvas.drawPath(nosePath, nosePaint);
    
    // Rocket fins
    final finPaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    // Left fin
    final leftFin = Path();
    leftFin.moveTo(center.dx - 20, center.dy + 30);
    leftFin.lineTo(center.dx - 35, center.dy + 50);
    leftFin.lineTo(center.dx - 20, center.dy + 50);
    leftFin.close();
    canvas.drawPath(leftFin, finPaint);
    
    // Right fin
    final rightFin = Path();
    rightFin.moveTo(center.dx + 20, center.dy + 30);
    rightFin.lineTo(center.dx + 35, center.dy + 50);
    rightFin.lineTo(center.dx + 20, center.dy + 50);
    rightFin.close();
    canvas.drawPath(rightFin, finPaint);
    
    // Rocket details
    final detailPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Windows
    canvas.drawCircle(
      Offset(center.dx, center.dy - 20),
      8,
      Paint()..color = Colors.lightBlue.withOpacity(0.7),
    );
    
    canvas.drawCircle(
      Offset(center.dx, center.dy - 20),
      8,
      detailPaint,
    );
    
    // Body stripes
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(center.dx - 15, center.dy - 10 + (i * 15)),
        Offset(center.dx + 15, center.dy - 10 + (i * 15)),
        detailPaint,
      );
    }
  }

  void _drawRocketExhaust(Canvas canvas, Offset rocketCenter) {
    final exhaustCenter = Offset(rocketCenter.dx, rocketCenter.dy + 60);
    
    // Main exhaust flame
    final flamePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          Colors.orange,
          Colors.red.withOpacity(0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: exhaustCenter, radius: 40));
    
    final flamePath = Path();
    flamePath.moveTo(exhaustCenter.dx - 15, exhaustCenter.dy - 20);
    flamePath.quadraticBezierTo(
      exhaustCenter.dx - 25, exhaustCenter.dy + 20,
      exhaustCenter.dx, exhaustCenter.dy + 60,
    );
    flamePath.quadraticBezierTo(
      exhaustCenter.dx + 25, exhaustCenter.dy + 20,
      exhaustCenter.dx + 15, exhaustCenter.dy - 20,
    );
    flamePath.close();
    
    canvas.drawPath(flamePath, flamePaint);
    
    // Exhaust particles
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final particleDistance = 30 + (i * 5);
      final particleCenter = Offset(
        exhaustCenter.dx + particleDistance * math.cos(angle) * 0.3,
        exhaustCenter.dy + particleDistance * math.sin(angle).abs() + 20,
      );
      
      canvas.drawCircle(
        particleCenter,
        3 - (i * 0.3),
        Paint()
          ..color = Colors.orange.withOpacity(0.7 - i * 0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  void _drawFuelEffects(Canvas canvas, Offset center) {
    // Fuel injection effects
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6;
      const effectDistance = 80;
      final effectCenter = Offset(
        center.dx + effectDistance * math.cos(angle),
        center.dy + effectDistance * math.sin(angle),
      );
      
      final effectPaint = Paint()
        ..color = primaryColor.withOpacity(0.6 * fuelLevel)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawCircle(effectCenter, 4 * fuelLevel, effectPaint);
      
      // Fuel stream lines
      canvas.drawLine(
        effectCenter,
        Offset(center.dx, center.dy + 40),
        Paint()
          ..color = primaryColor.withOpacity(0.4 * fuelLevel)
          ..strokeWidth = 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
