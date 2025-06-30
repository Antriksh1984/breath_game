import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingParticles extends StatelessWidget {
  final Animation<double> particleAnimation;
  final Animation<double> breathingAnimation;
  final Color color;
  final bool isActive;

  const FloatingParticles({
    super.key,
    required this.particleAnimation,
    required this.breathingAnimation,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: Listenable.merge([particleAnimation, breathingAnimation]),
      builder: (context, child) {
        return Stack(
          children: _buildParticles(),
        );
      },
    );
  }

  List<Widget> _buildParticles() {
    return List.generate(16, (index) {
      final angle = (index * math.pi * 2) / 16;
      const baseDistance = 200.0;
      final breathingOffset = breathingAnimation.value * 60;
      final rotationOffset = particleAnimation.value * math.pi * 2;
      final waveOffset = 25 * math.sin(particleAnimation.value * math.pi * 4 + index * 0.5);
      final distance = baseDistance + breathingOffset + waveOffset;
      
      final x = math.cos(angle + rotationOffset) * distance;
      final y = math.sin(angle + rotationOffset) * distance;
      
      final particleSize = 4 + (6 * breathingAnimation.value) + 
                          2 * math.sin(particleAnimation.value * math.pi * 6 + index);
      
      return Transform.translate(
        offset: Offset(x, y),
        child: Container(
          width: particleSize,
          height: particleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.3),
                color.withOpacity(0.0),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: particleSize * 2,
                spreadRadius: particleSize * 0.5,
              ),
            ],
          ),
        ),
      );
    });
  }
}
