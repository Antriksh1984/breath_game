import 'package:flutter/material.dart';

class SpaceColorScheme {
  final Color inhale;
  final Color hold;
  final Color exhale;

  const SpaceColorScheme({
    required this.inhale,
    required this.hold,
    required this.exhale,
  });
}

class SpaceColorSchemes {
  static const List<SpaceColorScheme> schemes = [
    // Rocket Red
    SpaceColorScheme(
      inhale: Color(0xFFFF4444),
      hold: Color(0xFFFF6B35),
      exhale: Color(0xFFFF8E53),
    ),
    // Space Blue
    SpaceColorScheme(
      inhale: Color(0xFF1E90FF),
      hold: Color(0xFF00BFFF),
      exhale: Color(0xFF87CEEB),
    ),
    // Cosmic Purple
    SpaceColorScheme(
      inhale: Color(0xFF8A2BE2),
      hold: Color(0xFF9370DB),
      exhale: Color(0xFFBA55D3),
    ),
    // Solar Orange
    SpaceColorScheme(
      inhale: Color(0xFFFF6347),
      hold: Color(0xFFFF7F50),
      exhale: Color(0xFFFFA500),
    ),
    // Galaxy Green
    SpaceColorScheme(
      inhale: Color(0xFF00FF7F),
      hold: Color(0xFF32CD32),
      exhale: Color(0xFF90EE90),
    ),
    // Aurora Cyan
    SpaceColorScheme(
      inhale: Color(0xFF00FFFF),
      hold: Color(0xFF40E0D0),
      exhale: Color(0xFF7FFFD4),
    ),
  ];
}
