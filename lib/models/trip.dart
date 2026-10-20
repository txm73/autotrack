import 'dart:convert';

class Trip {
  final String id;
  final String vehicleId;
  final DateTime startTime;
  final DateTime endTime;
  final double distanceKm;
  final int durationSeconds;
  final double startMileage;
  final double endMileage;
  final double estimatedFuelUsedLiters;
  final double avgSpeedKmh;
  final String purpose; // z.B. Privat, Arbeitsweg, Geschäftlich
  final String note;

  Trip({
    required this.id,
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
    required this.distanceKm,
    required this.durationSeconds,
    required this.startMileage,
    required this.endMileage,
    required this.estimatedFuelUsedLiters,
    required this.avgSpeedKmh,
    this.purpose = 'Privat',
    this.note = '',
  });

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m ${seconds}s';
    }
    return '${remainingMinutes}m ${seconds}s';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'distanceKm': distanceKm,
      'durationSeconds': durationSeconds,
      'startMileage': startMileage,
      'endMileage': endMileage,
      'estimatedFuelUsedLiters': estimatedFuelUsedLiters,
      'avgSpeedKmh': avgSpeedKmh,
      'purpose': purpose,
      'note': note,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      startTime: DateTime.tryParse(map['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(map['endTime'] ?? '') ?? DateTime.now(),
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      startMileage: (map['startMileage'] as num?)?.toDouble() ?? 0.0,
      endMileage: (map['endMileage'] as num?)?.toDouble() ?? 0.0,
      estimatedFuelUsedLiters: (map['estimatedFuelUsedLiters'] as num?)?.toDouble() ?? 0.0,
      avgSpeedKmh: (map['avgSpeedKmh'] as num?)?.toDouble() ?? 0.0,
      purpose: map['purpose'] ?? 'Privat',
      note: map['note'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Trip.fromJson(String source) => Trip.fromMap(json.decode(source));
}
