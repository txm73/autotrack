import 'dart:convert';

class Refueling {
  final String id;
  final String vehicleId;
  final DateTime date;
  final double liters;
  final double pricePerLiter;
  final double totalPrice;
  final double mileageAtRefuel;
  final bool isFullTank;
  final String fuelType;
  final String station;
  final String note;

  Refueling({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.liters,
    required this.pricePerLiter,
    required this.totalPrice,
    required this.mileageAtRefuel,
    this.isFullTank = true,
    this.fuelType = 'Super 95',
    this.station = '',
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'liters': liters,
      'pricePerLiter': pricePerLiter,
      'totalPrice': totalPrice,
      'mileageAtRefuel': mileageAtRefuel,
      'isFullTank': isFullTank,
      'fuelType': fuelType,
      'station': station,
      'note': note,
    };
  }

  factory Refueling.fromMap(Map<String, dynamic> map) {
    return Refueling(
      id: map['id'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      liters: (map['liters'] as num?)?.toDouble() ?? 0.0,
      pricePerLiter: (map['pricePerLiter'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      mileageAtRefuel: (map['mileageAtRefuel'] as num?)?.toDouble() ?? 0.0,
      isFullTank: map['isFullTank'] ?? true,
      fuelType: map['fuelType'] ?? 'Super 95',
      station: map['station'] ?? '',
      note: map['note'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Refueling.fromJson(String source) => Refueling.fromMap(json.decode(source));
}
