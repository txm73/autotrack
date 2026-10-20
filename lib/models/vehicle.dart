import 'dart:convert';

class Vehicle {
  final String id;
  String name;
  String licensePlate;
  String fuelType; // z.B. Benzin, Diesel, Super E10, Hybrid
  double currentMileage; // in km
  double tankCapacityLiters; // z.B. 40.0
  double currentFuelLiters; // aktuell geschätzter Füllstand
  double avgConsumptionPer100Km; // z.B. 5.5 l/100km
  int colorValue; // z.B. 0xFF1E88E5

  Vehicle({
    required this.id,
    required this.name,
    this.licensePlate = '',
    this.fuelType = 'Benzin',
    required this.currentMileage,
    required this.tankCapacityLiters,
    required this.currentFuelLiters,
    required this.avgConsumptionPer100Km,
    this.colorValue = 0xFF1976D2,
  });

  /// Füllstand in Prozent (0.0 bis 1.0)
  double get fuelPercentage {
    if (tankCapacityLiters <= 0) return 0.0;
    return (currentFuelLiters / tankCapacityLiters).clamp(0.0, 1.0);
  }

  /// Geschätzte Restreichweite in Kilometern
  double get estimatedRemainingRangeKm {
    if (avgConsumptionPer100Km <= 0) return 0.0;
    return (currentFuelLiters / avgConsumptionPer100Km) * 100.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'licensePlate': licensePlate,
      'fuelType': fuelType,
      'currentMileage': currentMileage,
      'tankCapacityLiters': tankCapacityLiters,
      'currentFuelLiters': currentFuelLiters,
      'avgConsumptionPer100Km': avgConsumptionPer100Km,
      'colorValue': colorValue,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Neues Fahrzeug',
      licensePlate: map['licensePlate'] ?? '',
      fuelType: map['fuelType'] ?? 'Benzin',
      currentMileage: (map['currentMileage'] as num?)?.toDouble() ?? 0.0,
      tankCapacityLiters: (map['tankCapacityLiters'] as num?)?.toDouble() ?? 50.0,
      currentFuelLiters: (map['currentFuelLiters'] as num?)?.toDouble() ?? 50.0,
      avgConsumptionPer100Km: (map['avgConsumptionPer100Km'] as num?)?.toDouble() ?? 6.5,
      colorValue: map['colorValue'] ?? 0xFF1976D2,
    );
  }

  String toJson() => json.encode(toMap());

  factory Vehicle.fromJson(String source) => Vehicle.fromMap(json.decode(source));

  Vehicle copyWith({
    String? id,
    String? name,
    String? licensePlate,
    String? fuelType,
    double? currentMileage,
    double? tankCapacityLiters,
    double? currentFuelLiters,
    double? avgConsumptionPer100Km,
    int? colorValue,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      licensePlate: licensePlate ?? this.licensePlate,
      fuelType: fuelType ?? this.fuelType,
      currentMileage: currentMileage ?? this.currentMileage,
      tankCapacityLiters: tankCapacityLiters ?? this.tankCapacityLiters,
      currentFuelLiters: currentFuelLiters ?? this.currentFuelLiters,
      avgConsumptionPer100Km: avgConsumptionPer100Km ?? this.avgConsumptionPer100Km,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
