import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/vehicle.dart';
import '../providers/app_state.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicleToEdit;

  const VehicleFormScreen({super.key, this.vehicleToEdit});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _plateController;
  late TextEditingController _mileageController;
  late TextEditingController _tankCapacityController;
  late TextEditingController _currentFuelController;
  late TextEditingController _consumptionController;

  String _fuelType = 'Super E10';
  int _colorValue = 0xFF1976D2;

  final List<String> _fuelTypes = [
    'Super 95',
    'Super E10',
    'Super Plus (98)',
    'Diesel',
    'Super E10 / Hybrid',
    'Autogas (LPG)',
    'Erdgas (CNG)',
  ];

  final List<int> _availableColors = [
    0xFF1976D2, // Blue
    0xFF388E3C, // Green
    0xFFD32F2F, // Red
    0xFF7B1FA2, // Purple
    0xFFF57C00, // Orange
    0xFF455A64, // Slate
    0xFF0097A7, // Cyan
  ];

  @override
  void initState() {
    super.initState();
    final v = widget.vehicleToEdit;
    _nameController = TextEditingController(text: v?.name ?? '');
    _plateController = TextEditingController(text: v?.licensePlate ?? '');
    _mileageController = TextEditingController(text: v != null ? v.currentMileage.toStringAsFixed(0) : '45000');
    _tankCapacityController = TextEditingController(text: v != null ? v.tankCapacityLiters.toStringAsFixed(0) : '50');
    _currentFuelController = TextEditingController(text: v != null ? v.currentFuelLiters.toStringAsFixed(1) : '35.0');
    _consumptionController = TextEditingController(text: v != null ? v.avgConsumptionPer100Km.toStringAsFixed(1) : '6.0');

    if (v != null) {
      if (_fuelTypes.contains(v.fuelType)) {
        _fuelType = v.fuelType;
      }
      _colorValue = v.colorValue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _mileageController.dispose();
    _tankCapacityController.dispose();
    _currentFuelController.dispose();
    _consumptionController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    if (!_formKey.currentState!.validate()) return;

    final state = context.read<AppState>();
    final name = _nameController.text.trim();
    final plate = _plateController.text.trim();
    final mileage = double.tryParse(_mileageController.text.replaceAll(',', '.')) ?? 0.0;
    final tankCapacity = double.tryParse(_tankCapacityController.text.replaceAll(',', '.')) ?? 50.0;
    final currentFuel = double.tryParse(_currentFuelController.text.replaceAll(',', '.')) ?? tankCapacity;
    final consumption = double.tryParse(_consumptionController.text.replaceAll(',', '.')) ?? 6.0;

    if (widget.vehicleToEdit != null) {
      final updated = widget.vehicleToEdit!.copyWith(
        name: name,
        licensePlate: plate,
        fuelType: _fuelType,
        currentMileage: mileage,
        tankCapacityLiters: tankCapacity,
        currentFuelLiters: currentFuel,
        avgConsumptionPer100Km: consumption,
        colorValue: _colorValue,
      );
      state.updateVehicle(updated);
    } else {
      final newVehicle = Vehicle(
        id: const Uuid().v4(),
        name: name,
        licensePlate: plate,
        fuelType: _fuelType,
        currentMileage: mileage,
        tankCapacityLiters: tankCapacity,
        currentFuelLiters: currentFuel,
        avgConsumptionPer100Km: consumption,
        colorValue: _colorValue,
      );
      state.addVehicle(newVehicle);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.vehicleToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Fahrzeug bearbeiten' : 'Neues Fahrzeug anlegen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grunddaten',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Modell & Bezeichnung *',
                  hintText: 'z.B. VW Golf 8 GTE',
                  prefixIcon: Icon(Icons.directions_car_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Bitte Namen eingeben' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Kennzeichen (optional)',
                  hintText: 'z.B. M-GT 820E',
                  prefixIcon: Icon(Icons.badge_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _fuelType,
                decoration: const InputDecoration(
                  labelText: 'Kraftstoffart',
                  prefixIcon: Icon(Icons.local_gas_station_rounded),
                  border: OutlineInputBorder(),
                ),
                items: _fuelTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _fuelType = val);
                },
              ),
              const SizedBox(height: 28),
              Text(
                'Kilometerstand & Tank',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mileageController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'KM-Stand *',
                        suffixText: 'km',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Pflichtfeld' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _consumptionController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Ø Verbrauch *',
                        suffixText: 'L/100km',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Pflichtfeld' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tankCapacityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Tankgröße *',
                        suffixText: 'Liter',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Pflichtfeld' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _currentFuelController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Aktueller Tankstand *',
                        suffixText: 'Liter',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => (val == null || val.isEmpty) ? 'Pflichtfeld' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Farbe zur Unterscheidung',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: _availableColors.map((color) {
                  final isSelected = _colorValue == color;
                  return GestureDetector(
                    onTap: () => setState(() => _colorValue = color),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _saveVehicle,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    isEditing ? 'Änderungen speichern' : 'Fahrzeug hinzufügen',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
