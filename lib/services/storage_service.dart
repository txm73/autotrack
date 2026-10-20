import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';
import '../models/trip.dart';
import '../models/refueling.dart';
import '../models/app_settings.dart';

class StorageService {
  static const _keyVehicles = 'autotrack_vehicles';
  static const _keyActiveVehicleId = 'autotrack_active_vehicle_id';
  static const _keyTrips = 'autotrack_trips';
  static const _keyRefuelings = 'autotrack_refuelings';
  static const _keySettings = 'autotrack_settings';

  Future<List<Vehicle>> loadVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyVehicles);
    if (list == null || list.isEmpty) {
      // Standard-Fahrzeug als Erstausstattung (VW Golf 8 GTE laut Nutzerwunsch)
      final defaultCar = Vehicle(
        id: 'default_golf_gte',
        name: 'VW Golf 8 GTE',
        licensePlate: 'M-GTE 800',
        fuelType: 'Super E10 / Hybrid',
        currentMileage: 45280.0,
        tankCapacityLiters: 40.0,
        currentFuelLiters: 31.5,
        avgConsumptionPer100Km: 5.4,
        colorValue: 0xFF007ACC,
      );
      await saveVehicles([defaultCar]);
      await saveActiveVehicleId(defaultCar.id);
      return [defaultCar];
    }
    return list.map((item) => Vehicle.fromJson(item)).toList();
  }

  Future<void> saveVehicles(List<Vehicle> vehicles) async {
    final prefs = await SharedPreferences.getInstance();
    final list = vehicles.map((v) => v.toJson()).toList();
    await prefs.setStringList(_keyVehicles, list);
  }

  Future<String?> loadActiveVehicleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyActiveVehicleId);
  }

  Future<void> saveActiveVehicleId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveVehicleId, id);
  }

  Future<List<Trip>> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyTrips);
    if (list == null) return [];
    return list.map((item) => Trip.fromJson(item)).toList();
  }

  Future<void> saveTrips(List<Trip> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final list = trips.map((t) => t.toJson()).toList();
    await prefs.setStringList(_keyTrips, list);
  }

  Future<List<Refueling>> loadRefuelings() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyRefuelings);
    if (list == null) return [];
    return list.map((item) => Refueling.fromJson(item)).toList();
  }

  Future<void> saveRefuelings(List<Refueling> refuelings) async {
    final prefs = await SharedPreferences.getInstance();
    final list = refuelings.map((r) => r.toJson()).toList();
    await prefs.setStringList(_keyRefuelings, list);
  }

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keySettings);
    if (jsonStr == null) return AppSettings();
    try {
      return AppSettings.fromJson(jsonStr);
    } catch (_) {
      return AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, settings.toJson());
  }
}
