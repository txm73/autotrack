import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/fuel_gauge_card.dart';
import '../widgets/trip_live_card.dart';
import '../widgets/stat_tile.dart';
import 'vehicle_form_screen.dart';
import 'refuel_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  void _showStopTripDialog(BuildContext context) {
    final state = context.read<AppState>();
    final vehicle = state.activeVehicle;
    if (vehicle == null) return;

    final distance = state.tripDistanceKm;
    final fuelUsed = state.liveEstimatedFuelUsed;
    final durationSec = state.tripDurationSeconds;
    final minutes = durationSec ~/ 60;
    final seconds = durationSec % 60;

    String purpose = 'Privat';
    final noteController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.flag_rounded, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('Fahrt abschließen'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Strecke:', '${distance.toStringAsFixed(2)} km'),
                      const SizedBox(height: 6),
                      _buildSummaryRow('Fahrtdauer:', '${minutes}m ${seconds}s'),
                      const SizedBox(height: 6),
                      _buildSummaryRow('Verbrauch:', '${fuelUsed.toStringAsFixed(2)} Liter'),
                      const SizedBox(height: 6),
                      _buildSummaryRow('Neuer KM-Stand:', '${(vehicle.currentMileage + distance).toStringAsFixed(1)} km'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Fahrtzweck:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Privat', 'Arbeitsweg', 'Geschäftlich', 'Urlaub'].map((p) {
                    final isSelected = purpose == p;
                    return ChoiceChip(
                      label: Text(p),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setDialogState(() => purpose = p);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Notiz / Zielort (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // weiter tracken
              },
              child: const Text('Weiterfahren'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await state.stopTrip(
                  purpose: purpose,
                  note: noteController.text.trim(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fahrt erfolgreich im Fahrtenbuch gespeichert!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Speichern & Beenden'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showVehiclePicker(BuildContext context) {
    final state = context.read<AppState>();
    final vehicles = state.vehicles;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fahrzeug auswählen',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...vehicles.map((v) {
                final isSelected = v.id == state.activeVehicleId;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(v.colorValue),
                    child: const Icon(Icons.directions_car, color: Colors.white),
                  ),
                  title: Text(v.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  subtitle: Text('${v.currentMileage.toStringAsFixed(0)} km • ${v.fuelType}'),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                  onTap: () {
                    state.selectActiveVehicle(v.id);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.add_rounded),
                ),
                title: const Text('Neues Auto anlegen'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (c) => const VehicleFormScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final vehicle = state.activeVehicle;

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('AutoTrack')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.directions_car_outlined, size: 72, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Noch kein Fahrzeug vorhanden'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const VehicleFormScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Fahrzeug anlegen'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _showVehiclePicker(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  vehicle.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Fahrzeuge',
            icon: const Icon(Icons.garage_rounded),
            onPressed: () => _showVehiclePicker(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => state.initialize(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Auto Badge Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color(vehicle.colorValue).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(vehicle.colorValue).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_car_rounded, color: Color(vehicle.colorValue), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.name,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${vehicle.licensePlate.isNotEmpty ? "${vehicle.licensePlate} • " : ""}${vehicle.fuelType}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${vehicle.currentMileage.toStringAsFixed(0)} km',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Gesamt-KM',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live-Tracking & Start Card
            TripLiveCard(
              onStart: () async {
                final success = await state.startTrip();
                if (!success && context.mounted && state.lastTrackingError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.lastTrackingError!),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              onStop: () => _showStopTripDialog(context),
            ),
            const SizedBox(height: 16),

            // Tank- & Verbrauchs-Anzeige Card
            FuelGaugeCard(
              vehicle: vehicle,
              onRefuelPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const AddRefuelBottomSheet(),
                );
              },
            ),
            const SizedBox(height: 16),

            // Schnelle Statistik-Kacheln
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    title: 'Fahrten im Log',
                    value: '${state.tripsForActiveVehicle.length}',
                    subtitle: '${state.totalDistanceForActiveVehicle.toStringAsFixed(1)} km erfasst',
                    icon: Icons.history_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    title: 'Tankausgaben',
                    value: '${state.totalMoneySpentForActiveVehicle.toStringAsFixed(0)} €',
                    subtitle: '${state.totalFuelSpentLitersForActiveVehicle.toStringAsFixed(1)} L getankt',
                    icon: Icons.payments_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
