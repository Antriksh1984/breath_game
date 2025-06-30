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
    // Calculate efficiency: Distance per fuel percentage
    return fuelPercentage > 0 ? distanceKm / fuelPercentage : 0.0;
  }
}
