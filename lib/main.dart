import 'package:flutter/material.dart';
import 'screens/breathing_game_screen.dart';

void main() {
  runApp(const RocketBreathingApp());
}

class RocketBreathingApp extends StatelessWidget {
  const RocketBreathingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rocket Breathing Journey',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF0B0B1A),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const BreathingGameScreen(),
    );
  }
}
