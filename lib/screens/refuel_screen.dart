import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/refueling.dart';
import '../providers/app_state.dart';

class RefuelScreen extends StatelessWidget {
  const RefuelScreen({super.key});

  void _showAddRefuelDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddRefuelBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final refuelings = state.refuelingsForActiveVehicle;
    final vehicle = state.activeVehicle;

    final dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'de');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tankvorgänge & Kalibrierung'),
        actions: [
          IconButton(
            tooltip: 'Tanken erfassen',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddRefuelDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRefuelDialog(context),
        icon: const Icon(Icons.local_gas_station_rounded),
        label: const Text('Tanken eintragen'),
      ),
      body: vehicle == null
          ? const Center(child: Text('Kein aktives Fahrzeug gewählt'))
          : Column(
              children: [
                // Zusammenfassungs-Banner
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Getankt gesamt',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.totalFuelSpentLitersForActiveVehicle.toStringAsFixed(1)} L',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 36, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.3)),
                      Column(
                        children: [
                          Text(
                            'Ausgaben gesamt',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.totalMoneySpentForActiveVehicle.toStringAsFixed(2)} €',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 36, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.3)),
                      Column(
                        children: [
                          Text(
                            'Aktueller Ø',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${vehicle.avgConsumptionPer100Km.toStringAsFixed(1)} L',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: refuelings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_gas_station_outlined, size: 64, color: theme.colorScheme.outline),
                              const SizedBox(height: 12),
                              Text(
                                'Noch keine Tankvorgänge erfasst',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Trage deine Tankungen ein, um den Realverbrauch präzise zu kalibrieren.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                          itemCount: refuelings.length,
                          separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                          itemBuilder: (ctx, index) {
                            final refuel = refuelings[index];
                            return Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
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
                                              backgroundColor: theme.colorScheme.secondaryContainer,
                                              child: Icon(Icons.local_gas_station, size: 20, color: theme.colorScheme.secondary),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${refuel.liters.toStringAsFixed(2)} Liter',
                                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  dateFormat.format(refuel.date),
                                                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${refuel.totalPrice.toStringAsFixed(2)} €',
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme.primary,
                                              ),
                                            ),
                                            Text(
                                              '${refuel.pricePerLiter.toStringAsFixed(3)} €/L',
                                              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'KM-Stand: ${refuel.mileageAtRefuel.toStringAsFixed(0)} km',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        if (refuel.isFullTank)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Vollgetankt',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (refuel.station.isNotEmpty || refuel.note.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        [refuel.station, refuel.note].where((s) => s.isNotEmpty).join(' • '),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class AddRefuelBottomSheet extends StatefulWidget {
  const AddRefuelBottomSheet({super.key});

  @override
  State<AddRefuelBottomSheet> createState() => _AddRefuelBottomSheetState();
}

class _AddRefuelBottomSheetState extends State<AddRefuelBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _litersController;
  late TextEditingController _pricePerLiterController;
  late TextEditingController _totalPriceController;
  late TextEditingController _mileageController;
  late TextEditingController _stationController;
  late TextEditingController _noteController;

  bool _isFullTank = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    final vehicle = state.activeVehicle;

    _litersController = TextEditingController();
    _pricePerLiterController = TextEditingController(text: '1.759');
    _totalPriceController = TextEditingController();
    _mileageController = TextEditingController(
      text: vehicle != null ? vehicle.currentMileage.toStringAsFixed(0) : '',
    );
    _stationController = TextEditingController();
    _noteController = TextEditingController();

    // Automatische Verknüpfung von Liter und Gesamtpreis
    _litersController.addListener(_recalcTotal);
    _pricePerLiterController.addListener(_recalcTotal);
  }

  void _recalcTotal() {
    final liters = double.tryParse(_litersController.text.replaceAll(',', '.')) ?? 0.0;
    final pricePerL = double.tryParse(_pricePerLiterController.text.replaceAll(',', '.')) ?? 0.0;
    if (liters > 0 && pricePerL > 0) {
      final total = liters * pricePerL;
      _totalPriceController.text = total.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _litersController.dispose();
    _pricePerLiterController.dispose();
    _totalPriceController.dispose();
    _mileageController.dispose();
    _stationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveRefuel() {
    if (!_formKey.currentState!.validate()) return;

    final liters = double.parse(_litersController.text.replaceAll(',', '.'));
    final pricePerL = double.tryParse(_pricePerLiterController.text.replaceAll(',', '.')) ?? 0.0;
    final totalPrice = double.tryParse(_totalPriceController.text.replaceAll(',', '.')) ?? (liters * pricePerL);
    final mileage = double.parse(_mileageController.text.replaceAll(',', '.'));

    final state = context.read<AppState>();
    state.addRefueling(
      liters: liters,
      pricePerLiter: pricePerL,
      totalPrice: totalPrice,
      mileageAtRefuel: mileage,
      isFullTank: _isFullTank,
      station: _stationController.text.trim(),
      note: _noteController.text.trim(),
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tankung erfolgreich gespeichert und Verbrauch kalibriert!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.local_gas_station_rounded, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Tanken erfassen',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _litersController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Getankte Liter *',
                        suffixText: 'L',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Pflichtfeld' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _pricePerLiterController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Preis pro Liter',
                        suffixText: '€/L',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Gesamtpreis',
                        suffixText: '€',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _mileageController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Aktueller KM-Stand *',
                        suffixText: 'km',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Pflichtfeld' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vollbetankung (Tank voll)'),
                subtitle: const Text('Erlaubt die genaue Kalibrierung des realen Verbrauchs'),
                value: _isFullTank,
                onChanged: (val) => setState(() => _isFullTank = val),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stationController,
                decoration: const InputDecoration(
                  labelText: 'Tankstelle / Ort (optional)',
                  hintText: 'z.B. Aral, Shell, Jet',
                  prefixIcon: Icon(Icons.storefront_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Notiz (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _saveRefuel,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text(
                    'Tankung speichern',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
