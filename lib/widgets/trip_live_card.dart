import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class TripLiveCard extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onStop;

  const TripLiveCard({
    super.key,
    required this.onStart,
    required this.onStop,
  });

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hStr:$mStr:$sStr';
    }
    return '$mStr:$sStr';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final isTracking = state.isTracking;

    if (!isTracking) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.navigation_rounded, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GPS Fahrten-Tracker',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Erfasst Strecke, Zeit & errechnet den Verbrauch',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: const Text(
                    'Fahrt starten',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              if (state.lastTrackingError != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        state.lastTrackingError!,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange[800]),
                      ),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      );
    }

    // Wenn Tracking aktiv ist:
    final distance = state.tripDistanceKm;
    final fuelUsed = state.liveEstimatedFuelUsed;
    final speed = state.tripCurrentSpeedKmh;
    final durationStr = _formatDuration(state.tripDurationSeconds);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'FAHRT WIRD AUFGEZEICHNET',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                Text(
                  durationStr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Distanz & Verbrauch Anzeige
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLiveStat(
                  context,
                  title: 'Strecke',
                  value: distance.toStringAsFixed(2),
                  unit: 'km',
                  icon: Icons.route_rounded,
                ),
                Container(width: 1, height: 48, color: theme.dividerColor),
                _buildLiveStat(
                  context,
                  title: 'Tempo',
                  value: speed.toStringAsFixed(0),
                  unit: 'km/h',
                  icon: Icons.speed_rounded,
                ),
                Container(width: 1, height: 48, color: theme.dividerColor),
                _buildLiveStat(
                  context,
                  title: 'Verbrauch',
                  value: fuelUsed.toStringAsFixed(2),
                  unit: 'Liter',
                  icon: Icons.local_gas_station_rounded,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                IconButton.outlined(
                  onPressed: () {
                    state.cancelCurrentTrip();
                  },
                  tooltip: 'Abbrechen',
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: onStop,
                      icon: const Icon(Icons.stop_rounded, size: 28),
                      label: const Text(
                        'Fahrt beenden',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStat(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$unit • $title',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
