import 'package:flutter/material.dart';
import '../models/mission_record.dart';

class LeaderboardWidget extends StatelessWidget {
  final List<MissionRecord> records;

  const LeaderboardWidget({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    // Sort records by distance (best first)
    final sortedRecords = List<MissionRecord>.from(records)
      ..sort((a, b) => b.distanceKm.compareTo(a.distanceKm));

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.2),
                  Colors.blue.withOpacity(0.2),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.leaderboard, color: Colors.purple, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Mission Records',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
          ),
          
          // Stats Summary
          if (records.isNotEmpty) _buildStatsSummary(),
          
          // Records Table
          Expanded(
            child: records.isEmpty
                ? _buildEmptyState()
                : _buildRecordsTable(sortedRecords),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    final totalMissions = records.length;
    final avgDistance = records.map((r) => r.distanceKm).reduce((a, b) => a + b) / totalMissions;
    final bestDistance = records.map((r) => r.distanceKm).reduce((a, b) => a > b ? a : b);
    final avgFuel = records.map((r) => r.fuelPercentage).reduce((a, b) => a + b) / totalMissions;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryItem('Missions', totalMissions.toString(), Icons.rocket_launch),
          _buildSummaryItem('Best', '${bestDistance.toInt()}km', Icons.star),
          _buildSummaryItem('Avg Dist', '${avgDistance.toInt()}km', Icons.trending_up),
          _buildSummaryItem('Avg Fuel', '${avgFuel.toInt()}%', Icons.local_gas_station),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.purple, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rocket_launch_outlined,
            size: 64,
            color: Colors.white30,
          ),
          const SizedBox(height: 16),
          Text(
            'No missions completed yet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first mission to see records here',
            style: TextStyle(
              color: Colors.white50,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsTable(List<MissionRecord> sortedRecords) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(flex: 1, child: _buildHeaderCell('Rank')),
                Expanded(flex: 2, child: _buildHeaderCell('Mission')),
                Expanded(flex: 2, child: _buildHeaderCell('Fuel %')),
                Expanded(flex: 2, child: _buildHeaderCell('Hold')),
                Expanded(flex: 2, child: _buildHeaderCell('Distance')),
                Expanded(flex: 2, child: _buildHeaderCell('Date')),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Table Rows
          ...sortedRecords.asMap().entries.map((entry) {
            final index = entry.key;
            final record = entry.value;
            final isTopThree = index < 3;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isTopThree 
                    ? Colors.amber.withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: isTopThree 
                    ? Border.all(color: Colors.amber.withOpacity(0.3))
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildRankCell(index + 1, isTopThree),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildDataCell('M${record.missionNumber}'),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildDataCell('${record.fuelPercentage.toInt()}%'),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildDataCell('${record.holdTimeSeconds}s'),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildDataCell('${record.distanceKm.toInt()}km'),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildDataCell(record.formattedDate),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRankCell(int rank, bool isTopThree) {
    IconData? icon;
    Color? color;
    
    if (rank == 1) {
      icon = Icons.emoji_events;
      color = Colors.amber;
    } else if (rank == 2) {
      icon = Icons.emoji_events;
      color = Colors.grey[300];
    } else if (rank == 3) {
      icon = Icons.emoji_events;
      color = Colors.orange[300];
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
        ],
        Text(
          '$rank',
          style: TextStyle(
            color: isTopThree ? color ?? Colors.amber : Colors.white70,
            fontSize: 14,
            fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDataCell(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white70,
        fontSize: 13,
      ),
      textAlign: TextAlign.center,
    );
  }
}
