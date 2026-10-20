import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/vehicle.dart';
import '../models/trip.dart';
import '../models/refueling.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../services/tracking_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final TrackingService _trackingService = TrackingService();
  final Uuid _uuid = const Uuid();

  List<Vehicle> _vehicles = [];
  String? _activeVehicleId;
  List<Trip> _trips = [];
  List<Refueling> _refuelings = [];
  AppSettings _settings = AppSettings();

  bool _isLoading = true;
  String? _lastTrackingError;

  // Live Tracking Status
  bool _isTracking = false;
  DateTime? _tripStartTime;
  int _tripDurationSeconds = 0;
  double _tripDistanceKm = 0.0;
  double _tripCurrentSpeedKmh = 0.0;
  Timer? _stopwatchTimer;

  // Getters
  bool get isLoading => _isLoading;
  List<Vehicle> get vehicles => _vehicles;
  String? get activeVehicleId => _activeVehicleId;
  List<Trip> get trips => _trips;
  List<Refueling> get refuelings => _refuelings;
  AppSettings get settings => _settings;
  String? get lastTrackingError => _lastTrackingError;

  bool get isTracking => _isTracking;
  DateTime? get tripStartTime => _tripStartTime;
  int get tripDurationSeconds => _tripDurationSeconds;
  double get tripDistanceKm => _tripDistanceKm;
  double get tripCurrentSpeedKmh => _tripCurrentSpeedKmh;

  Vehicle? get activeVehicle {
    if (_vehicles.isEmpty) return null;
    return _vehicles.firstWhere(
      (v) => v.id == _activeVehicleId,
      orElse: () => _vehicles.first,
    );
  }

  /// Berechneter geschätzter Verbrauch der aktuellen Live-Fahrt
  double get liveEstimatedFuelUsed {
    final vehicle = activeVehicle;
    if (vehicle == null) return 0.0;
    return (_tripDistanceKm * vehicle.avgConsumptionPer100Km) / 100.0;
  }

  /// Initiales Laden aus dem Speicher
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _settings = await _storageService.loadSettings();
    _vehicles = await _storageService.loadVehicles();
    _activeVehicleId = await _storageService.loadActiveVehicleId();
    if (_activeVehicleId == null && _vehicles.isNotEmpty) {
      _activeVehicleId = _vehicles.first.id;
    }
    _trips = await _storageService.loadTrips();
    _refuelings = await _storageService.loadRefuelings();

    _isLoading = false;
    notifyListeners();
  }

  // ==========================================
  // FAHRZEUG-VERWALTUNG
  // ==========================================

  Future<void> selectActiveVehicle(String vehicleId) async {
    _activeVehicleId = vehicleId;
    await _storageService.saveActiveVehicleId(vehicleId);
    notifyListeners();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    _vehicles.add(vehicle);
    if (_vehicles.length == 1) {
      _activeVehicleId = vehicle.id;
      await _storageService.saveActiveVehicleId(vehicle.id);
    }
    await _storageService.saveVehicles(_vehicles);
    notifyListeners();
  }

  Future<void> updateVehicle(Vehicle updated) async {
    final index = _vehicles.indexWhere((v) => v.id == updated.id);
    if (index != -1) {
      _vehicles[index] = updated;
      await _storageService.saveVehicles(_vehicles);
      notifyListeners();
    }
  }

  Future<void> deleteVehicle(String id) async {
    _vehicles.removeWhere((v) => v.id == id);
    if (_activeVehicleId == id) {
      _activeVehicleId = _vehicles.isNotEmpty ? _vehicles.first.id : null;
      if (_activeVehicleId != null) {
        await _storageService.saveActiveVehicleId(_activeVehicleId!);
      }
    }
    await _storageService.saveVehicles(_vehicles);
    notifyListeners();
  }

  // ==========================================
  // GPS FAHRTEN-TRACKING
  // ==========================================

  Future<bool> startTrip() async {
    if (_isTracking) return true;
    if (activeVehicle == null) {
      _lastTrackingError = 'Kein aktives Fahrzeug ausgewählt.';
      notifyListeners();
      return false;
    }

    _lastTrackingError = null;
    _tripStartTime = DateTime.now();
    _tripDurationSeconds = 0;
    _tripDistanceKm = 0.0;
    _tripCurrentSpeedKmh = 0.0;

    final started = await _trackingService.startTracking(
      simulationMode: _settings.simulatedGpsMode,
      onProgress: (distanceKm, speedKmh) {
        _tripDistanceKm = distanceKm;
        _tripCurrentSpeedKmh = speedKmh;
        notifyListeners();
      },
      onErrorCallback: (err) {
        _lastTrackingError = err;
        notifyListeners();
      },
    );

    if (started) {
      _isTracking = true;
      _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _tripDurationSeconds++;
        notifyListeners();
      });
      notifyListeners();
      return true;
    } else {
      _isTracking = false;
      return false;
    }
  }

  /// Stoppt das Tracking und speichert die Fahrt
  Future<Trip?> stopTrip({
    String purpose = 'Privat',
    String note = '',
  }) async {
    if (!_isTracking) return null;

    final currentVehicle = activeVehicle;
    if (currentVehicle == null) return null;

    final distanceFinal = _trackingService.stopTracking();
    _stopwatchTimer?.cancel();
    _stopwatchTimer = null;

    final endTime = DateTime.now();
    final durationSeconds = _tripDurationSeconds;
    final startMileage = currentVehicle.currentMileage;
    final endMileage = startMileage + distanceFinal;

    // Verbrauch schätzen
    final fuelUsed = (distanceFinal * currentVehicle.avgConsumptionPer100Km) / 100.0;

    // Durchschnittsgeschwindigkeit in km/h
    final hours = durationSeconds / 3600.0;
    final avgSpeed = hours > 0 ? (distanceFinal / hours) : 0.0;

    final newTrip = Trip(
      id: _uuid.v4(),
      vehicleId: currentVehicle.id,
      startTime: _tripStartTime ?? endTime.subtract(Duration(seconds: durationSeconds)),
      endTime: endTime,
      distanceKm: distanceFinal,
      durationSeconds: durationSeconds,
      startMileage: startMileage,
      endMileage: endMileage,
      estimatedFuelUsedLiters: fuelUsed,
      avgSpeedKmh: avgSpeed,
      purpose: purpose,
      note: note,
    );

    // 1. Fahrt speichern
    _trips.insert(0, newTrip);
    await _storageService.saveTrips(_trips);

    // 2. Fahrzeug-Kilometerstand & Tankstand aktualisieren
    final updatedFuel = max(0.0, currentVehicle.currentFuelLiters - fuelUsed);
    final updatedVehicle = currentVehicle.copyWith(
      currentMileage: double.parse(endMileage.toStringAsFixed(1)),
      currentFuelLiters: double.parse(updatedFuel.toStringAsFixed(2)),
    );
    await updateVehicle(updatedVehicle);

    // Reset Tracking State
    _isTracking = false;
    _tripDurationSeconds = 0;
    _tripDistanceKm = 0.0;
    _tripCurrentSpeedKmh = 0.0;
    _tripStartTime = null;

    notifyListeners();
    return newTrip;
  }

  void cancelCurrentTrip() {
    _trackingService.stopTracking();
    _stopwatchTimer?.cancel();
    _stopwatchTimer = null;
    _isTracking = false;
    _tripDurationSeconds = 0;
    _tripDistanceKm = 0.0;
    _tripCurrentSpeedKmh = 0.0;
    _tripStartTime = null;
    notifyListeners();
  }

  // ==========================================
  // TANKEN & VERBRAUCHS-KALIBRIERUNG
  // ==========================================

  Future<void> addRefueling({
    required double liters,
    required double pricePerLiter,
    required double totalPrice,
    required double mileageAtRefuel,
    required bool isFullTank,
    String fuelType = 'Super 95',
    String station = '',
    String note = '',
  }) async {
    final vehicle = activeVehicle;
    if (vehicle == null) return;

    final newRefuel = Refueling(
      id: _uuid.v4(),
      vehicleId: vehicle.id,
      date: DateTime.now(),
      liters: liters,
      pricePerLiter: pricePerLiter,
      totalPrice: totalPrice,
      mileageAtRefuel: mileageAtRefuel,
      isFullTank: isFullTank,
      fuelType: fuelType,
      station: station,
      note: note,
    );

    _refuelings.insert(0, newRefuel);
    await _storageService.saveRefuelings(_refuelings);

    // Wenn vollgetankt: Füllstand = Tankkapazität
    // Sonst: aktueller Stand + getankte Liter (maximal Tankkapazität)
    double newFuelLiters;
    if (isFullTank) {
      newFuelLiters = vehicle.tankCapacityLiters;
    } else {
      newFuelLiters = min(vehicle.tankCapacityLiters, vehicle.currentFuelLiters + liters);
    }

    // Falls zwei Vollbetankungen vorliegen, den Realverbrauch kalibrieren
    double newAvgConsumption = vehicle.avgConsumptionPer100Km;
    if (isFullTank) {
      final prevFull = _refuelings.where((r) => r.vehicleId == vehicle.id && r.isFullTank && r.id != newRefuel.id).toList();
      if (prevFull.isNotEmpty) {
        final lastFull = prevFull.first;
        final deltaKm = mileageAtRefuel - lastFull.mileageAtRefuel;
        if (deltaKm > 20) {
          // Neuer berechneter Realverbrauch: (Liter / deltaKm) * 100
          final calculatedConsumption = (liters / deltaKm) * 100.0;
          if (calculatedConsumption >= 2.0 && calculatedConsumption <= 30.0) {
            // Leicht gewichteter gleitender Durchschnitt (60% bisher, 40% neue Tankung)
            newAvgConsumption = (vehicle.avgConsumptionPer100Km * 0.6) + (calculatedConsumption * 0.4);
            newAvgConsumption = double.parse(newAvgConsumption.toStringAsFixed(2));
          }
        }
      }
    }

    final updatedVehicle = vehicle.copyWith(
      currentMileage: max(vehicle.currentMileage, mileageAtRefuel),
      currentFuelLiters: double.parse(newFuelLiters.toStringAsFixed(2)),
      avgConsumptionPer100Km: newAvgConsumption,
    );

    await updateVehicle(updatedVehicle);
    notifyListeners();
  }

  // ==========================================
  // EINSTELLUNGEN
  // ==========================================

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  // ==========================================
  // STATISTIKEN
  // ==========================================

  List<Trip> get tripsForActiveVehicle {
    final v = activeVehicle;
    if (v == null) return [];
    return _trips.where((t) => t.vehicleId == v.id).toList();
  }

  List<Refueling> get refuelingsForActiveVehicle {
    final v = activeVehicle;
    if (v == null) return [];
    return _refuelings.where((r) => r.vehicleId == v.id).toList();
  }

  double get totalDistanceForActiveVehicle {
    return tripsForActiveVehicle.fold(0.0, (sum, t) => sum + t.distanceKm);
  }

  double get totalFuelSpentLitersForActiveVehicle {
    return refuelingsForActiveVehicle.fold(0.0, (sum, r) => sum + r.liters);
  }

  double get totalMoneySpentForActiveVehicle {
    return refuelingsForActiveVehicle.fold(0.0, (sum, r) => sum + r.totalPrice);
  }
}
