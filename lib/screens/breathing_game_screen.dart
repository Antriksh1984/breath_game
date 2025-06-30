import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import '../widgets/rocket_painter.dart';
import '../widgets/space_background_painter.dart';
import '../widgets/nebula_widget.dart';
import '../utils/space_color_schemes.dart';

class MissionRecord {
  final int missionNumber;
  final double fuelPercentage;
  final int holdTimeSeconds;
  final double distanceKm;
  final DateTime timestamp;

  MissionRecord({
    required this.missionNumber,
    required this.fuelPercentage,
    required this.holdTimeSeconds,
    required this.distanceKm,
    required this.timestamp,
  });

  String get formattedDate {
    return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  double get efficiency {
    return fuelPercentage > 0 ? distanceKm / fuelPercentage : 0.0;
  }
}

class BreathingSession {
  bool _isActive = false;
  bool _isInhaling = true;
  int _currentCycle = 0;
  int _totalCycles = 5;
  int _sessionDuration = 120; // 2 minutes for rocket missions
  int _remainingTime = 120;

  bool get isActive => _isActive;
  bool get isInhaling => _isInhaling;
  int get currentCycle => _currentCycle;
  int get totalCycles => _totalCycles;
  int get sessionDuration => _sessionDuration;
  int get remainingTime => _remainingTime;

  void start() {
    _isActive = true;
    _currentCycle = 0;
    _remainingTime = _sessionDuration;
  }

  void complete() {
    _isActive = false;
  }

  void reset() {
    _isActive = false;
    _currentCycle = 0;
    _remainingTime = _sessionDuration;
    _isInhaling = true;
  }

  void tick() {
    if (_remainingTime > 0) {
      _remainingTime--;
    }
  }

  void nextCycle() {
    _currentCycle++;
  }

  void setInhaling(bool inhaling) {
    _isInhaling = inhaling;
  }
}

enum BreathingPhase {
  ready,
  fueling,
  holding,
  launching,
  complete
}

class BreathingGameScreen extends StatefulWidget {
  const BreathingGameScreen({super.key});

  @override
  State<BreathingGameScreen> createState() => _BreathingGameScreenState();
}

class _BreathingGameScreenState extends State<BreathingGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _rocketController;
  late AnimationController _fuelController;
  late AnimationController _starsController;
  late AnimationController _nebulaController;
  
  late Animation<double> _rocketAnimation;
  late Animation<double> _fuelAnimation;
  late Animation<double> _starsAnimation;
  late Animation<double> _nebulaAnimation;

  Timer? _sessionTimer;
  Timer? _phaseTimer;
  
  late BreathingSession _session;
  
  BreathingPhase _currentPhase = BreathingPhase.ready;
  int _currentColorSchemeIndex = 0;
  
  // Real-time tracking
  bool _isButtonPressed = false;
  DateTime? _phaseStartTime;
  int _currentPhaseDuration = 0;
  
  // Current mission data
  double _fuelPercentage = 0.0; // 0-100%
  double _distanceKm = 0.0; // Based on fuel percentage
  int _holdTimeSeconds = 0;
  
  // Mission records for leaderboard
  List<MissionRecord> _missionRecords = [];
  
  // Phase limits
  final int _maxFuelTime = 10; // 10 seconds = 100% fuel
  final int _maxLaunchTime = 15; // 15 seconds = 150km max distance
  final double _maxDistanceKm = 150.0;

  @override
  void initState() {
    super.initState();
    _session = BreathingSession();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _rocketController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fuelController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _starsController = AnimationController(
      duration: const Duration(milliseconds: 20000),
      vsync: this,
    );

    _nebulaController = AnimationController(
      duration: const Duration(milliseconds: 15000),
      vsync: this,
    );

    _rocketAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _rocketController, curve: Curves.easeInOut));

    _fuelAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fuelController, curve: Curves.linear));

    _starsAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _starsController, curve: Curves.linear));

    _nebulaAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _nebulaController, curve: Curves.linear));

    _starsController.repeat();
    _nebulaController.repeat();
  }

  Color get _currentPrimaryColor {
    final scheme = SpaceColorSchemes.schemes[_currentColorSchemeIndex];
    switch (_currentPhase) {
      case BreathingPhase.fueling:
        return scheme.inhale;
      case BreathingPhase.holding:
        return scheme.hold;
      case BreathingPhase.launching:
        return scheme.exhale;
      default:
        return scheme.inhale;
    }
  }

  String get _phaseInstruction {
    switch (_currentPhase) {
      case BreathingPhase.ready:
        return 'Tap "Start Mission" to begin';
      case BreathingPhase.fueling:
        return 'Hold button to FUEL rocket';
      case BreathingPhase.holding:
        return 'Hold button to MAINTAIN fuel pressure';
      case BreathingPhase.launching:
        return 'Hold button to LAUNCH rocket';
      case BreathingPhase.complete:
        return 'Mission Complete!';
    }
  }

  String get _phaseTitle {
    switch (_currentPhase) {
      case BreathingPhase.ready:
        return 'Ready for Launch';
      case BreathingPhase.fueling:
        return 'Fueling: ${_fuelPercentage.toInt()}% (${_currentPhaseDuration}s)';
      case BreathingPhase.holding:
        return 'Holding: ${_fuelPercentage.toInt()}% (${_currentPhaseDuration}s)';
      case BreathingPhase.launching:
        return 'Launching: ${_distanceKm.toInt()}km (${_currentPhaseDuration}s)';
      case BreathingPhase.complete:
        return 'Mission Success!';
    }
  }

  void _startSession() {
    if (_session.isActive) return;

    setState(() {
      _session.start();
      _currentPhase = BreathingPhase.ready;
      _currentColorSchemeIndex = math.Random().nextInt(SpaceColorSchemes.schemes.length);
      _resetMissionData();
    });

    HapticFeedback.lightImpact();

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _session.tick();
      });

      if (_session.remainingTime <= 0) {
        _endSession();
      }
    });

    // Auto-start fueling phase
    Timer(const Duration(seconds: 1), () {
      if (_session.isActive) {
        _startFuelingPhase();
      }
    });
  }

  void _resetMissionData() {
    _fuelPercentage = 0.0;
    _distanceKm = 0.0;
    _holdTimeSeconds = 0;
    _currentPhaseDuration = 0;
  }

  void _startFuelingPhase() {
    setState(() {
      _currentPhase = BreathingPhase.fueling;
      _fuelPercentage = 0.0;
    });
  }

  void _startHoldingPhase() {
    setState(() {
      _currentPhase = BreathingPhase.holding;
      _holdTimeSeconds = 0;
    });
  }

  void _startLaunchingPhase() {
    setState(() {
      _currentPhase = BreathingPhase.launching;
      _distanceKm = 0.0;
    });
  }

  void _onButtonPressed() {
    if (!_session.isActive || _currentPhase == BreathingPhase.ready || _currentPhase == BreathingPhase.complete) {
      return;
    }

    setState(() {
      _isButtonPressed = true;
      _phaseStartTime = DateTime.now();
      _currentPhaseDuration = 0;
    });

    _startPhaseTimer();
    HapticFeedback.selectionClick();
  }

  void _onButtonReleased() {
    if (!_session.isActive || !_isButtonPressed) return;

    setState(() {
      _isButtonPressed = false;
    });

    _phaseTimer?.cancel();

    // Move to next phase based on current phase
    switch (_currentPhase) {
      case BreathingPhase.fueling:
        if (_fuelPercentage >= 10) { // Minimum 10% fuel
          _startHoldingPhase();
        } else {
          _showWarning('Need at least 10% fuel to proceed!');
          _startFuelingPhase();
        }
        break;
      case BreathingPhase.holding:
        if (_holdTimeSeconds >= 2) { // Minimum 2 seconds hold
          _startLaunchingPhase();
        } else {
          _showWarning('Hold fuel for at least 2 seconds!');
          _startHoldingPhase();
        }
        break;
      case BreathingPhase.launching:
        if (_distanceKm >= 10) { // Minimum 10km travel
          _completeMission();
        } else {
          _showWarning('Launch for at least 10km distance!');
          _startLaunchingPhase();
        }
        break;
      default:
        break;
    }

    HapticFeedback.selectionClick();
  }

  void _startPhaseTimer() {
    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_phaseStartTime != null && _isButtonPressed) {
        final elapsed = DateTime.now().difference(_phaseStartTime!).inMilliseconds;
        final elapsedSeconds = elapsed / 1000.0;
        
        setState(() {
          _currentPhaseDuration = elapsed ~/ 1000;
        });

        _updatePhaseProgress(elapsedSeconds);
      }
    });
  }

  void _updatePhaseProgress(double elapsedSeconds) {
    switch (_currentPhase) {
      case BreathingPhase.fueling:
        // Fuel percentage: 0-100% over _maxFuelTime seconds
        final progress = math.min(elapsedSeconds / _maxFuelTime, 1.0);
        setState(() {
          _fuelPercentage = progress * 100;
        });
        _fuelController.animateTo(progress);
        break;
        
      case BreathingPhase.holding:
        // Just track hold time
        setState(() {
          _holdTimeSeconds = elapsedSeconds.toInt();
        });
        break;
        
      case BreathingPhase.launching:
        // Distance based on fuel percentage and launch time
        // Formula: Distance = (FuelPercentage/100) * (LaunchTime/MaxLaunchTime) * MaxDistance
        final launchProgress = math.min(elapsedSeconds / _maxLaunchTime, 1.0);
        final fuelFactor = _fuelPercentage / 100.0;
        setState(() {
          _distanceKm = fuelFactor * launchProgress * _maxDistanceKm;
        });
        break;
        
      default:
        break;
    }
  }

  void _completeMission() {
    // Record the mission
    final record = MissionRecord(
      missionNumber: _session.currentCycle + 1,
      fuelPercentage: _fuelPercentage,
      holdTimeSeconds: _holdTimeSeconds,
      distanceKm: _distanceKm,
      timestamp: DateTime.now(),
    );

    setState(() {
      _missionRecords.add(record);
      _currentPhase = BreathingPhase.complete;
    });

    _session.nextCycle();
    HapticFeedback.mediumImpact();

    if (_session.currentCycle >= _session.totalCycles) {
      Timer(const Duration(seconds: 2), () => _endSession());
    } else {
      Timer(const Duration(seconds: 3), () {
        _resetMissionData();
        _startFuelingPhase();
      });
    }
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange.withOpacity(0.8),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _endSession() {
    setState(() {
      _session.complete();
      _currentPhase = BreathingPhase.complete;
    });

    _sessionTimer?.cancel();
    _phaseTimer?.cancel();
    _fuelController.reset();

    HapticFeedback.mediumImpact();

    Timer(const Duration(seconds: 3), () {
      setState(() {
        _session.reset();
        _currentPhase = BreathingPhase.ready;
        _resetMissionData();
      });
    });
  }

  void _stopSession() {
    _sessionTimer?.cancel();
    _phaseTimer?.cancel();
    _fuelController.reset();

    setState(() {
      _session.reset();
      _currentPhase = BreathingPhase.ready;
      _resetMissionData();
      _isButtonPressed = false;
    });
  }

  void _showLeaderboard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B0B1A),
        title: Row(
          children: [
            Icon(Icons.leaderboard, color: Colors.purple),
            SizedBox(width: 8),
            Text('Mission Records', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: _missionRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rocket_launch_outlined, size: 64, color: Colors.white30),
                      SizedBox(height: 16),
                      Text('No missions completed yet', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _missionRecords.length,
                  itemBuilder: (context, index) {
                    final record = _missionRecords[index];
                    return Card(
                      color: Colors.black.withOpacity(0.3),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
                        ),
                        title: Text('Mission ${record.missionNumber}', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          'Fuel: ${record.fuelPercentage.toInt()}% • Hold: ${record.holdTimeSeconds}s • Distance: ${record.distanceKm.toInt()}km',
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(record.formattedDate, style: TextStyle(color: Colors.white54)),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rocketController.dispose();
    _fuelController.dispose();
    _starsController.dispose();
    _nebulaController.dispose();
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
            radius: 2.0,
            colors: [
              _currentPrimaryColor.withOpacity(0.1),
              const Color(0xFF0B0B1A),
              const Color(0xFF000000),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Space background
            AnimatedBuilder(
              animation: _starsAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: SpaceBackgroundPainter(
                    starsAnimation: _starsAnimation.value,
                    color: _currentPrimaryColor,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            
            // Nebula effects
            NebulaWidget(
              animation: _nebulaAnimation,
              color: _currentPrimaryColor,
              isActive: _session.isActive,
            ),
            
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  if (_session.isActive) _buildCurrentStats(),
                  Expanded(child: _buildRocketArea()),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rocket_launch, color: _currentPrimaryColor, size: 28),
              const SizedBox(width: 12),
              Text(
                'Rocket Breathing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(width: 12),
              if (_missionRecords.isNotEmpty)
                GestureDetector(
                  onTap: _showLeaderboard,
                  child: Icon(Icons.leaderboard, color: _currentPrimaryColor, size: 28),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_session.isActive) ...[
            Text(
              '${(_session.remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_session.remainingTime % 60).toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 5),
            Text(
              'Mission ${_session.currentCycle + 1} of ${_session.totalCycles}',
              style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 0.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard('Fuel', '${_fuelPercentage.toInt()}%', Icons.local_gas_station),
          _buildStatCard('Hold', '${_holdTimeSeconds}s', Icons.pause),
          _buildStatCard('Distance', '${_distanceKm.toInt()}km', Icons.flight),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _currentPrimaryColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _currentPrimaryColor, size: 16),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRocketArea() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_rocketAnimation, _fuelAnimation]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Rocket visualization
              CustomPaint(
                painter: RocketPainter(
                  fuelLevel: _fuelPercentage / 100.0,
                  travelDistance: _distanceKm / _maxDistanceKm,
                  primaryColor: _currentPrimaryColor,
                  isActive: _session.isActive,
                  currentPhase: _phaseTitle,
                ),
                size: const Size(400, 500),
              ),
              
              // Phase instruction
              Positioned(
                bottom: 50,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: _currentPrimaryColor.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _currentPrimaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getPhaseIcon(), color: _currentPrimaryColor, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        _phaseTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _phaseInstruction,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getPhaseIcon() {
    switch (_currentPhase) {
      case BreathingPhase.fueling:
        return Icons.local_gas_station;
      case BreathingPhase.holding:
        return Icons.pause;
      case BreathingPhase.launching:
        return Icons.flight;
      case BreathingPhase.complete:
        return Icons.check_circle;
      default:
        return Icons.rocket_launch;
    }
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          if (_session.isActive && _currentPhase != BreathingPhase.complete && _currentPhase != BreathingPhase.ready) ...[
            // Main control button
            GestureDetector(
              onTapDown: (_) => _onButtonPressed(),
              onTapUp: (_) => _onButtonReleased(),
              onTapCancel: () => _onButtonReleased(),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _isButtonPressed 
                        ? _currentPrimaryColor.withOpacity(0.8)
                        : _currentPrimaryColor.withOpacity(0.4),
                      _isButtonPressed 
                        ? _currentPrimaryColor.withOpacity(0.4)
                        : _currentPrimaryColor.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(color: _currentPrimaryColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: _currentPrimaryColor.withOpacity(0.5),
                      blurRadius: _isButtonPressed ? 30 : 15,
                      spreadRadius: _isButtonPressed ? 10 : 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isButtonPressed ? Icons.radio_button_checked : Icons.touch_app,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Hold & Release to Control',
              style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 0.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _stopSession,
              icon: const Icon(Icons.stop, size: 20),
              label: const Text('Abort Mission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.red.withOpacity(0.4)),
                ),
              ),
            ),
          ] else if (!_session.isActive) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _startSession,
                  icon: const Icon(Icons.rocket_launch, size: 24),
                  label: const Text('Start Mission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentPrimaryColor.withOpacity(0.2),
                    foregroundColor: _currentPrimaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: _currentPrimaryColor.withOpacity(0.4)),
                    ),
                  ),
                ),
                if (_missionRecords.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _showLeaderboard,
                    icon: const Icon(Icons.leaderboard, size: 24),
                    label: const Text('Records'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.withOpacity(0.2),
                      foregroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.purple.withOpacity(0.4)),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
