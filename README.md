# AutoTrack 🚗💨
**Moderne Android-App für Fahrzeugverwaltung, GPS-Fahrten-Tracking und Verbrauchsrechner**

Gebaut mit **Flutter & Material 3 (Dark/Light Mode)**.

---

## 🌟 Kernfunktionen

1. **Fahrzeug-Verwaltung (Multi-Car):**
   - Beliebig viele Fahrzeuge mit Name/Modell (z.B. *VW Golf 8 GTE*), Kennzeichen, Kraftstoffart, aktuellem Kilometerstand, Tankgröße und Durchschnittsverbrauch anlegen & verwalten.
   - Schneller Fahrzeugwechsel direkt über das Dashboard oder das "Fahrzeuge"-Menü.

2. **Live GPS-Tracking & Fahrtenbuch:**
   - Großes One-Touch Dashboard-Widget zum Starten und Beenden von Fahrten.
   - Live-Messung über GPS (`geolocator`): Distanz in km, Tempo in km/h, Dauer (Stoppuhr) und fortlaufend geschätzter Benzinverbrauch.
   - Automatisches Hochzählen des Kilometerstands und Abziehen des verbrauchten Kraftstoffs nach Abschluss einer Fahrt.
   - Fahrtenbuch mit Zweck-Kategorien (*Privat, Arbeitsweg, Geschäftlich, Urlaub*) und Notizfeld.
   - **GPS-Simulationsmodus:** Schalter in den Einstellungen, um die App auch im Büro oder im Emulator testen zu können.

3. **Tank- & Reichweiten-Management:**
   - Zirkulärer Material-3 Tankfüllstand-Indikator (Liter und Prozent).
   - Live-Berechnung der verbleibenden Restreichweite (in km) basierend auf aktuellem Tankinhalt und Durchschnittsverbrauch.
   - "Tanken"-Erfassung mit Litern, Preis pro Liter, Gesamtpreis und aktuellem KM-Stand.
   - **Intelligente Kalibrierung:** Bei Vollbetankung berechnet die App den tatsächlichen Realverbrauch anhand der gefahrenen Kilometer seit der letzten Tankung und präzisiert den hinterlegten Durchschnittsverbrauch gleitend.

4. **Modernes UI/UX:**
   - Vollständiger Material 3 Standard mit nativer Dark-Mode-Unterstützung.
   - 5 Navigation-Tabs: *Dashboard, Fahrten, Tanken, Fahrzeuge, Optionen*.

---

## 📁 Projektstruktur

```
autotrack_app/
├── android/                        # Native Android-Konfiguration & Permissions
│   └── app/src/main/
│       └── AndroidManifest.xml     # GPS/Location-Berechtigungen
├── lib/
│   ├── main.dart                   # App-Einstiegspunkt, Theme & NavigationBar
│   ├── models/
│   │   ├── vehicle.dart            # Fahrzeugdaten & Reichweitenrechner
│   │   ├── trip.dart               # GPS-Fahrt & Streckendaten
│   │   ├── refueling.dart          # Tankbelege & Kalibrierungslogik
│   │   └── app_settings.dart       # Nutzersettings (Theme, Einheiten)
│   ├── services/
│   │   ├── storage_service.dart    # SharedPreferences Persistenz
│   │   └── tracking_service.dart   # Geolocator GPS-Stream & Filter
│   ├── providers/
│   │   └── app_state.dart          # Zentraler State-Manager (Provider)
│   ├── screens/
│   │   ├── home_dashboard_screen.dart # Dashboard & Schnellstart
│   │   ├── trips_screen.dart          # Fahrten-Historie
│   │   ├── refuel_screen.dart         # Tank-Historie & Dialog
│   │   ├── vehicles_screen.dart       # Fahrzeugübersicht
│   │   ├── vehicle_form_screen.dart   # Auto anlegen/bearbeiten
│   │   └── settings_screen.dart       # Darkmode & Einheiten
│   └── widgets/
│       ├── fuel_gauge_card.dart       # Tankanzeige & Kreisdiagramm
│       ├── trip_live_card.dart        # Live-Stoppuhr & Tacho
│       └── stat_tile.dart             # Statistik-Kacheln
└── pubspec.yaml
```

---

## 🚀 Bauanleitung für Mac (APK kompilieren)

### 1. Voraussetzungen auf dem Mac prüfen
Falls Flutter noch nicht installiert ist, lade das Flutter SDK herunter oder installiere es via Homebrew:
```bash
brew install --cask flutter
```
Stelle sicher, dass Android Studio mit Android SDK und Command-line Tools eingerichtet ist:
```bash
flutter doctor
```

### 2. Projekt öffnen
Navigiere in das Projektverzeichnis:
```bash
cd /Users/tim/.gemini/antigravity/scratch/autotrack_app
```

### 3. Abhängigkeiten herunterladen
```bash
flutter pub get
```

### 4. Android APK generieren
Führe den Build-Befehl aus:
```bash
# Universelle Release-APK bauen:
flutter build apk --release

# ODER größenoptimierte Split-APKs (z.B. arm64-v8a für moderne Android-Handys):
flutter build apk --split-per-abi
```

Die fertige `.apk`-Datei liegt anschließend in:
```
build/app/outputs/flutter-apk/app-release.apk
```
Diese Datei kannst du direkt per USB, AirDrop/Cloud oder `adb install` auf dein Android-Smartphone übertragen und installieren.
