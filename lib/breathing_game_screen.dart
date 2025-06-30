import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class BreathingGameScreen extends StatefulWidget {
  const BreathingGameScreen({super.key});

  @override
  State<BreathingGameScreen> createState() => _BreathingGameScreenState();
}

class _BreathingGameScreenState extends State<BreathingGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _waveController;
  late AnimationController _shapeController;
  late AnimationController _colorController;
  late AnimationController _rippleController;
  
  late Animation<double> _breathingAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _shapeAnimation;
  late Animation<double> _colorAnimation;
  late Animation<double> _rippleAnimation;

  Timer? _sessionTimer;
  Timer? _phaseTimer;
  
  bool _isSessionActive = false;
  bool _isInhaling = true;
  int _currentCycle = 0;
  final int _totalCycles = 7;
  final int _sessionDuration = 60;
  int _remainingTime = 60;
  
  String _currentPhase = 'Tap to Start';
  int _currentShapeIndex = 0;
  int _currentColorSchemeIndex = 0;
  
  // Dynamic color schemes
  final List<List<Color>> _colorSchemes = [
    [const Color(0xFF4A90E2), const Color(0xFF50C878), const Color(0xFFFF6B6B)], // Blue-Green-Red
    [const Color(0xFF9B59B6), const Color(0xFFE74C3C), const Color(0xFFF39C12)], // Purple-Red-Orange
    [const Color(0xFF1ABC9C), const Color(0xFF3498DB), const Color(0xFFE67E22)], // Teal-Blue-Orange
    [const Color(0xFFE91E63), const Color(0xFF673AB7), const Color(0xFF2196F3)], // Pink-Purple-Blue
    [const Color(0xFF00BCD4), const Color(0xFF4CAF50), const Color(0xFFFFEB3B)], // Cyan-Green-Yellow
  ];
  
  // Shape types
  final List<String> _shapeTypes = ['circle', 'hexagon', 'star', 'flower', 'mandala'];
  
  // Breathing timing
  final int _inhaleTime = 4000;
  final int _holdTime = 1000;
  final int _exhaleTime = 4000;
  final int _pauseTime = 1000;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _breathingController = AnimationController(
      duration: Duration(milliseconds: _inhaleTime),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _shapeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _colorController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _shapeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shapeController,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _pulseController.repeat(reverse: true);
    _particleController.repeat();
    _waveController.repeat(reverse: true);
    _shapeController.repeat(reverse: true);
  }

  Color get _currentPrimaryColor {
    final scheme = _colorSchemes[_currentColorSchemeIndex];
    if (_currentPhase.contains('In')) return scheme[0];
    if (_currentPhase.contains('Hold')) return scheme[1];
    if (_currentPhase.contains('Out')) return scheme[2];
    return scheme[0];
  }

  void _startSession() {
    if (_isSessionActive) return;

    setState(() {
      _isSessionActive = true;
      _currentCycle = 0;
      _remainingTime = _sessionDuration;
      _currentPhase = 'Get Ready...';
      _currentColorSchemeIndex = math.Random().nextInt(_colorSchemes.length);
      _currentShapeIndex = math.Random().nextInt(_shapeTypes.length);
    });

    HapticFeedback.lightImpact();
    _colorController.forward();
    _rippleController.repeat();

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0) {
        _endSession();
      }
    });

    Timer(const Duration(seconds: 2), () {
      if (_isSessionActive) {
        _startBreathingCycle();
      }
    });
  }

  void _startBreathingCycle() {
    if (!_isSessionActive) return;

    _currentCycle++;
    
    // Change shape every few cycles
    if (_currentCycle % 2 == 0) {
      setState(() {
        _currentShapeIndex = (_currentShapeIndex + 1) % _shapeTypes.length;
      });
    }
    
    _startInhale();
  }

  void _startInhale() {
    setState(() {
      _isInhaling = true;
      _currentPhase = 'Breathe In';
    });

    _breathingController.duration = Duration(milliseconds: _inhaleTime);
    _breathingController.forward();
    _colorController.forward();

    HapticFeedback.selectionClick();

    _phaseTimer = Timer(Duration(milliseconds: _inhaleTime), () {
      _startHold(true);
    });
  }

  void _startHold(bool afterInhale) {
    setState(() {
      _currentPhase = afterInhale ? 'Hold' : 'Hold';
    });

    _colorController.forward();

    _phaseTimer = Timer(Duration(milliseconds: _holdTime), () {
      if (afterInhale) {
        _startExhale();
      } else {
        _startNextCycle();
      }
    });
  }

  void _startExhale() {
    setState(() {
      _isInhaling = false;
      _currentPhase = 'Breathe Out';
    });

    _breathingController.duration = Duration(milliseconds: _exhaleTime);
    _breathingController.reverse();
    _colorController.reverse();

    HapticFeedback.selectionClick();

    _phaseTimer = Timer(Duration(milliseconds: _exhaleTime), () {
      _startHold(false);
    });
  }

  void _startNextCycle() {
    if (!_isSessionActive) return;

    if (_currentCycle < _totalCycles && _remainingTime > 0) {
      Timer(Duration(milliseconds: _pauseTime), () {
        _startBreathingCycle();
      });
    } else {
      _endSession();
    }
  }

  void _endSession() {
    setState(() {
      _isSessionActive = false;
      _currentPhase = 'Session Complete!';
    });

    _sessionTimer?.cancel();
    _phaseTimer?.cancel();
    _breathingController.reset();
    _colorController.reset();
    _rippleController.stop();

    HapticFeedback.mediumImpact();

    Timer(const Duration(seconds: 3), () {
      setState(() {
        _currentPhase = 'Tap to Start';
        _remainingTime = _sessionDuration;
        _currentCycle = 0;
      });
    });
  }

  void _stopSession() {
    _sessionTimer?.cancel();
    _phaseTimer?.cancel();
    _breathingController.reset();
    _colorController.reset();
    _rippleController.stop();

    setState(() {
      _isSessionActive = false;
      _currentPhase = 'Tap to Start';
      _remainingTime = _sessionDuration;
      _currentCycle = 0;
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _shapeController.dispose();
    _colorController.dispose();
    _rippleController.dispose();
    _sessionTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              _currentPrimaryColor.withOpacity(0.15),
              const Color(0xFF0A0E27),
              const Color(0xFF000000),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _buildDynamicBreathingShape(),
                  ),
                  _buildControls(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: WaveBackgroundPainter(
            waveAnimation: _waveAnimation.value,
            color: _currentPrimaryColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text(
            'Breathing Exercise',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          if (_isSessionActive) ...[
            Text(
              '${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Cycle $_currentCycle of $_totalCycles • ${_shapeTypes[_currentShapeIndex].toUpperCase()}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDynamicBreathingShape() {
    return Center(
      child: GestureDetector(
        onTap: _isSessionActive ? null : _startSession,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _breathingAnimation,
            _pulseAnimation,
            _particleAnimation,
            _shapeAnimation,
            _colorAnimation,
            _rippleAnimation,
          ]),
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effects
                if (_isSessionActive) ..._buildRippleEffects(),
                
                // Dynamic particles
                ..._buildDynamicParticles(),
                
                // Main dynamic shape
                CustomPaint(
                  painter: DynamicShapePainter(
                    shapeType: _shapeTypes[_currentShapeIndex],
                    breathingValue: _breathingAnimation.value,
                    pulseValue: _isSessionActive ? 1.0 : _pulseAnimation.value,
                    shapeValue: _shapeAnimation.value,
                    colorValue: _colorAnimation.value,
                    primaryColor: _currentPrimaryColor,
                    isActive: _isSessionActive,
                  ),
                  size: const Size(350, 350),
                ),
                
                // Center text with dynamic styling
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _currentPrimaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPhase,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (!_isSessionActive && _currentPhase == 'Tap to Start')
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Tap to begin your journey',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildRippleEffects() {
    return List.generate(3, (index) {
      final delay = index * 0.3;
      final animationValue = (_rippleAnimation.value + delay) % 1.0;
      
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _currentPrimaryColor.withOpacity(0.3 * (1 - animationValue)),
              width: 2,
            ),
          ),
          transform: Matrix4.identity()..scale(0.5 + animationValue * 1.5),
        ),
      );
    });
  }

  List<Widget> _buildDynamicParticles() {
    if (!_isSessionActive) return [];
    
    return List.generate(12, (index) {
      final angle = (index * math.pi * 2) / 12;
      const baseDistance = 180;
      final breathingOffset = _breathingAnimation.value * 50;
      final rotationOffset = _particleAnimation.value * math.pi * 2;
      final distance = baseDistance + breathingOffset + (20 * math.sin(_particleAnimation.value * math.pi * 4));
      
      final x = math.cos(angle + rotationOffset) * distance;
      final y = math.sin(angle + rotationOffset) * distance;
      
      return Transform.translate(
        offset: Offset(x, y),
        child: Container(
          width: 6 + (4 * _breathingAnimation.value),
          height: 6 + (4 * _breathingAnimation.value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _currentPrimaryColor.withOpacity(0.8),
                _currentPrimaryColor.withOpacity(0.2),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _currentPrimaryColor.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_isSessionActive)
            ElevatedButton(
              onPressed: _stopSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(color: Colors.red.withOpacity(0.3)),
                ),
              ),
              child: const Text('Stop'),
            ),
          
          if (!_isSessionActive)
            ElevatedButton(
              onPressed: _startSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentPrimaryColor.withOpacity(0.2),
                foregroundColor: _currentPrimaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(color: _currentPrimaryColor.withOpacity(0.3)),
                ),
              ),
              child: const Text('Start Session'),
            ),
        ],
      ),
    );
  }
}

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
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path = Path();
    const waveHeight = 30.0;
    final waveLength = size.width / 3;

    for (int i = 0; i < 4; i++) {
      path.reset();
      final yOffset = size.height * 0.2 * (i + 1) + waveHeight * math.sin(waveAnimation * math.pi * 2 + i);
      
      path.moveTo(0, yOffset);
      
      for (double x = 0; x <= size.width; x += 5) {
        final y = yOffset + waveHeight * math.sin((x / waveLength) * 2 * math.pi + waveAnimation * math.pi * 2 + i);
        path.lineTo(x, y);
      }
      
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DynamicShapePainter extends CustomPainter {
  final String shapeType;
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
    final baseRadius = size.width * 0.25;
    final animatedRadius = baseRadius * breathingValue * pulseValue;

    switch (shapeType) {
      case 'circle':
        _drawCircle(canvas, center, animatedRadius);
        break;
      case 'hexagon':
        _drawHexagon(canvas, center, animatedRadius);
        break;
      case 'star':
        _drawStar(canvas, center, animatedRadius);
        break;
      case 'flower':
        _drawFlower(canvas, center, animatedRadius);
        break;
      case 'mandala':
        _drawMandala(canvas, center, animatedRadius);
        break;
    }
  }

  void _drawCircle(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.8),
          primaryColor.withOpacity(0.3),
          primaryColor.withOpacity(0.1),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
    
    // Outer ring
    final ringPaint = Paint()
      ..color = primaryColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(center, radius * 1.2, ringPaint);
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius) {
    final path = Path();
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.8),
          primaryColor.withOpacity(0.2),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6 + shapeValue * math.pi / 6;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Draw outline
    final outlinePaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(path, outlinePaint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius) {
    final path = Path();
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.9),
          primaryColor.withOpacity(0.3),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    const points = 8;
    final outerRadius = radius;
    final innerRadius = radius * 0.5;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points + shapeValue * math.pi / 4;
      final currentRadius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawFlower(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    const petals = 8;
    for (int i = 0; i < petals; i++) {
      final angle = (i * math.pi * 2) / petals + shapeValue * math.pi / 4;
      final petalCenter = Offset(
        center.dx + radius * 0.6 * math.cos(angle),
        center.dy + radius * 0.6 * math.sin(angle),
      );
      
      final petalRadius = radius * 0.4 * (0.8 + 0.2 * math.sin(shapeValue * math.pi * 2));
      canvas.drawCircle(petalCenter, petalRadius, paint);
    }
    
    // Center circle
    final centerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.9),
          primaryColor.withOpacity(0.4),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.3));
    
    canvas.drawCircle(center, radius * 0.3, centerPaint);
  }

  void _drawMandala(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw concentric circles with patterns
    for (int ring = 1; ring <= 4; ring++) {
      final ringRadius = radius * ring / 4;
      canvas.drawCircle(center, ringRadius, paint);
      
      // Draw radial lines
      const spokes = 12;
      for (int i = 0; i < spokes; i++) {
        final angle = (i * math.pi * 2) / spokes + shapeValue * math.pi / 6;
        final startRadius = ringRadius * 0.8;
        final endRadius = ringRadius * 1.2;
        
        final start = Offset(
          center.dx + startRadius * math.cos(angle),
          center.dy + startRadius * math.sin(angle),
        );
        final end = Offset(
          center.dx + endRadius * math.cos(angle),
          center.dy + endRadius * math.sin(angle),
        );
        
        canvas.drawLine(start, end, paint);
      }
    }
    
    // Center filled circle
    final centerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.8),
          primaryColor.withOpacity(0.2),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.2));
    
    canvas.drawCircle(center, radius * 0.2, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
