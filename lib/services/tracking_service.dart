import 'dart:async';
import 'package:geolocator/geolocator.dart';

class TrackingService {
  StreamSubscription<Position>? _positionSubscription;
  Timer? _simulationTimer;

  Position? _lastPosition;
  double _accumulatedDistanceKm = 0.0;
  double _currentSpeedKmh = 0.0;

  // Callback functions
  void Function(double distanceKm, double speedKmh)? onUpdate;
  void Function(String errorMessage)? onError;

  bool _isTracking = false;
  bool get isTracking => _isTracking;
  double get currentDistanceKm => _accumulatedDistanceKm;
  double get currentSpeedKmh => _currentSpeedKmh;

  /// Prüft und fordert die erforderlichen Standort-Berechtigungen an
  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onError?.call('Standortdienste sind auf diesem Gerät deaktiviert.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        onError?.call('Standortberechtigung wurde abgelehnt.');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      onError?.call('Standortberechtigungen sind dauerhaft abgelehnt. Bitte in den Systemeinstellungen aktivieren.');
      return false;
    }

    return true;
  }

  /// Startet das GPS-Tracking (oder Simulationsmodus, falls gewünscht)
  Future<bool> startTracking({
    required void Function(double distanceKm, double speedKmh) onProgress,
    void Function(String error)? onErrorCallback,
    bool simulationMode = false,
  }) async {
    onUpdate = onProgress;
    onError = onErrorCallback;
    _accumulatedDistanceKm = 0.0;
    _currentSpeedKmh = 0.0;
    _lastPosition = null;

    if (simulationMode) {
      _isTracking = true;
      // Simulation: Jede Sekunde ca. 15 m fahren (entspricht ca. 54 km/h)
      _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isTracking) {
          timer.cancel();
          return;
        }
        _accumulatedDistanceKm += 0.015; // 15 Meter
        _currentSpeedKmh = 54.0;
        onUpdate?.call(_accumulatedDistanceKm, _currentSpeedKmh);
      });
      return true;
    }

    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      return false;
    }

    _isTracking = true;

    // Hochpräzise Standort-Einstellungen mit 3m Distanzfilter gegen GPS-Jitter
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 3,
    );

    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          if (!_isTracking) return;

          // Geschwindigkeitsumrechnung von m/s in km/h
          if (position.speed >= 0) {
            _currentSpeedKmh = position.speed * 3.6;
          }

          if (_lastPosition != null) {
            // Abstand zwischen den Punkten in Metern berechnen
            final distanceInMeters = Geolocator.distanceBetween(
              _lastPosition!.latitude,
              _lastPosition!.longitude,
              position.latitude,
              position.longitude,
            );

            // Jitter filtern: Genauigkeit prüfen und minimale Distanz
            if (position.accuracy <= 25.0 && distanceInMeters >= 2.0) {
              _accumulatedDistanceKm += (distanceInMeters / 1000.0);
            }
          }

          _lastPosition = position;
          onUpdate?.call(_accumulatedDistanceKm, _currentSpeedKmh);
        },
        onError: (err) {
          onError?.call('GPS-Fehler: $err');
        },
      );
      return true;
    } catch (e) {
      onError?.call('Konnte GPS-Tracking nicht starten: $e');
      _isTracking = false;
      return false;
    }
  }

  /// Stoppt das Tracking und gibt die finale Distanz zurück
  double stopTracking() {
    _isTracking = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _currentSpeedKmh = 0.0;
    _lastPosition = null;
    return _accumulatedDistanceKm;
  }
}
