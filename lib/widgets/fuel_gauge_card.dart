import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class FuelGaugeCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onRefuelPressed;

  const FuelGaugeCard({
    super.key,
    required this.vehicle,
    required this.onRefuelPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = vehicle.fuelPercentage;
    final remainingLiters = vehicle.currentFuelLiters;
    final totalCapacity = vehicle.tankCapacityLiters;
    final estimatedRange = vehicle.estimatedRemainingRangeKm;

    // Farb-Codierung basierend auf Füllstand
    Color gaugeColor;
    if (percentage > 0.4) {
      gaugeColor = Colors.green;
    } else if (percentage > 0.2) {
      gaugeColor = Colors.orange;
    } else {
      gaugeColor = Colors.redAccent;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_gas_station_rounded, color: gaugeColor, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Tank & Reichweite',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: onRefuelPressed,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tanken'),
                  style: TextButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Kreisanzeige für Tank
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: percentage,
                        strokeWidth: 10,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        color: gaugeColor,
                        strokeCap: StrokeCap.round,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(percentage * 100).toInt()}%',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Füllstand',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetricRow(
                        context,
                        label: 'Tankinhalt',
                        value: '${remainingLiters.toStringAsFixed(1)} / ${totalCapacity.toStringAsFixed(0)} L',
                        icon: Icons.water_drop_outlined,
                      ),
                      const SizedBox(height: 10),
                      _buildMetricRow(
                        context,
                        label: 'Restreichweite ca.',
                        value: '${estimatedRange.toStringAsFixed(0)} km',
                        icon: Icons.speed_rounded,
                        isHighlighted: true,
                      ),
                      const SizedBox(height: 10),
                      _buildMetricRow(
                        context,
                        label: 'Ø Verbrauch',
                        value: '${vehicle.avgConsumptionPer100Km.toStringAsFixed(1)} L / 100km',
                        icon: Icons.trending_up_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    bool isHighlighted = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            color: isHighlighted ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
