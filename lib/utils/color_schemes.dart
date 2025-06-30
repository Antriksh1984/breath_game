import 'package:flutter/material.dart';

class ColorScheme {
  final Color inhale;
  final Color hold;
  final Color exhale;

  const ColorScheme({
    required this.inhale,
    required this.hold,
    required this.exhale,
  });
}

class ColorSchemes {
  static const List<ColorScheme> schemes = [
    ColorScheme(
      inhale: Color(0xFF4A90E2),
      hold: Color(0xFF50C878),
      exhale: Color(0xFFFF6B6B),
    ),
    ColorScheme(
      inhale: Color(0xFF9B59B6),
      hold: Color(0xFFE74C3C),
      exhale: Color(0xFFF39C12),
    ),
    ColorScheme(
      inhale: Color(0xFF1ABC9C),
      hold: Color(0xFF3498DB),
      exhale: Color(0xFFE67E22),
    ),
    ColorScheme(
      inhale: Color(0xFFE91E63),
      hold: Color(0xFF673AB7),
      exhale: Color(0xFF2196F3),
    ),
    ColorScheme(
      inhale: Color(0xFF00BCD4),
      hold: Color(0xFF4CAF50),
      exhale: Color(0xFFFFEB3B),
    ),
    ColorScheme(
      inhale: Color(0xFFFF5722),
      hold: Color(0xFF795548),
      exhale: Color(0xFF607D8B),
    ),
  ];
}
