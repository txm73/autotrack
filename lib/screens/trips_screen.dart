import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../providers/app_state.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final trips = state.tripsForActiveVehicle;
    final vehicle = state.activeVehicle;

    final dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'de');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fahrtenbuch & Historie'),
      ),
      body: vehicle == null
          ? const Center(child: Text('Kein aktives Fahrzeug gewählt'))
          : Column(
              children: [
                // Info header
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderStat(
                        context,
                        title: 'Fahrten',
                        value: '${trips.length}',
                      ),
                      _buildHeaderStat(
                        context,
                        title: 'Getrackt gesamt',
                        value: '${state.totalDistanceForActiveVehicle.toStringAsFixed(1)} km',
                      ),
                      _buildHeaderStat(
                        context,
                        title: 'Auto KM-Stand',
                        value: '${vehicle.currentMileage.toStringAsFixed(0)} km',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: trips.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.route_outlined, size: 64, color: theme.colorScheme.outline),
                              const SizedBox(height: 12),
                              Text(
                                'Noch keine Fahrten aufgezeichnet',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Starte auf dem Dashboard das Tracking, um Fahrten automatisch hier zu speichern.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: trips.length,
                          separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                          itemBuilder: (ctx, index) {
                            final trip = trips[index];
                            return _TripCard(trip: trip, dateFormat: dateFormat);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderStat(BuildContext context, {required String title, required String value}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  final DateFormat dateFormat;

  const _TripCard({required this.trip, required this.dateFormat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.navigation_rounded, size: 18, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${trip.distanceKm.toStringAsFixed(2)} km',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          dateFormat.format(trip.startTime),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
                Chip(
                  label: Text(trip.purpose, style: const TextStyle(fontSize: 12)),
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(context, icon: Icons.timer_outlined, label: 'Dauer', value: trip.formattedDuration),
                _buildMetric(context, icon: Icons.speed_rounded, label: 'Ø Tempo', value: '${trip.avgSpeedKmh.toStringAsFixed(0)} km/h'),
                _buildMetric(
                  context,
                  icon: Icons.local_gas_station_rounded,
                  label: 'Verbrauch',
                  value: '${trip.estimatedFuelUsedLiters.toStringAsFixed(2)} L',
                  highlight: true,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KM-Stand: ${trip.startMileage.toStringAsFixed(1)} ➔ ${trip.endMileage.toStringAsFixed(1)} km',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            if (trip.note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Notiz: ${trip.note}',
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(BuildContext context, {required IconData icon, required String label, required String value, bool highlight = false}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: highlight ? theme.colorScheme.primary : theme.colorScheme.outline),
            const SizedBox(width: 4),
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: highlight ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
