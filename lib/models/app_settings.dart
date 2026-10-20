import 'dart:convert';

class AppSettings {
  final bool? isDarkMode; // null = System, true = Dark, false = Light
  final String distanceUnit; // "km" oder "mi"
  final String fuelUnit; // "L" oder "gal"
  final String currencySymbol; // "€", "$", "CHF"
  final bool enableGpsBackgroundNotice;
  final bool simulatedGpsMode; // Zum Testen auf Emulatoren / Indoor

  AppSettings({
    this.isDarkMode,
    this.distanceUnit = 'km',
    this.fuelUnit = 'L',
    this.currencySymbol = '€',
    this.enableGpsBackgroundNotice = true,
    this.simulatedGpsMode = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'distanceUnit': distanceUnit,
      'fuelUnit': fuelUnit,
      'currencySymbol': currencySymbol,
      'enableGpsBackgroundNotice': enableGpsBackgroundNotice,
      'simulatedGpsMode': simulatedGpsMode,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      isDarkMode: map['isDarkMode'] as bool?,
      distanceUnit: map['distanceUnit'] ?? 'km',
      fuelUnit: map['fuelUnit'] ?? 'L',
      currencySymbol: map['currencySymbol'] ?? '€',
      enableGpsBackgroundNotice: map['enableGpsBackgroundNotice'] ?? true,
      simulatedGpsMode: map['simulatedGpsMode'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppSettings.fromJson(String source) => AppSettings.fromMap(json.decode(source));

  AppSettings copyWith({
    bool? isDarkMode,
    bool clearDarkMode = false,
    String? distanceUnit,
    String? fuelUnit,
    String? currencySymbol,
    bool? enableGpsBackgroundNotice,
    bool? simulatedGpsMode,
  }) {
    return AppSettings(
      isDarkMode: clearDarkMode ? null : (isDarkMode ?? this.isDarkMode),
      distanceUnit: distanceUnit ?? this.distanceUnit,
      fuelUnit: fuelUnit ?? this.fuelUnit,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      enableGpsBackgroundNotice: enableGpsBackgroundNotice ?? this.enableGpsBackgroundNotice,
      simulatedGpsMode: simulatedGpsMode ?? this.simulatedGpsMode,
    );
  }
}
