import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../providers/app_state.dart';
import 'vehicle_form_screen.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  void _confirmDelete(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fahrzeug löschen?'),
        content: Text('Möchtest du "${vehicle.name}" wirklich entfernen? Alle zugehörigen Daten bleiben in der Historie erhalten.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AppState>().deleteVehicle(vehicle.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final vehicles = state.vehicles;
    final activeId = state.activeVehicleId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fahrzeugverwaltung'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const VehicleFormScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Auto anlegen'),
      ),
      body: vehicles.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_car_outlined, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 12),
                  const Text('Keine Fahrzeuge angelegt'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => const VehicleFormScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Erstes Fahrzeug anlegen'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: vehicles.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                final vehicle = vehicles[index];
                final isActive = vehicle.id == activeId;

                return Card(
                  elevation: isActive ? 3 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: isActive
                        ? BorderSide(color: theme.colorScheme.primary, width: 2)
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(vehicle.colorValue),
                              child: const Icon(Icons.directions_car_rounded, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          vehicle.name,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isActive) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Aktiv',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.onPrimaryContainer,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (vehicle.licensePlate.isNotEmpty)
                                    Text(
                                      vehicle.licensePlate,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => VehicleFormScreen(vehicleToEdit: vehicle),
                                  ),
                                );
                              },
                            ),
                            if (vehicles.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _confirmDelete(context, vehicle),
                              ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn('KM-Stand', '${vehicle.currentMileage.toStringAsFixed(0)} km'),
                            _buildInfoColumn('Tankinhalt', '${vehicle.currentFuelLiters.toStringAsFixed(1)} / ${vehicle.tankCapacityLiters.toStringAsFixed(0)} L'),
                            _buildInfoColumn('Ø Verbrauch', '${vehicle.avgConsumptionPer100Km.toStringAsFixed(1)} L/100km'),
                          ],
                        ),
                        if (!isActive) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                state.selectActiveVehicle(vehicle.id);
                              },
                              child: const Text('Als aktives Auto auswählen'),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
