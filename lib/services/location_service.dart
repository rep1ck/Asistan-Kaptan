import 'package:geolocator/geolocator.dart';

class LocationService {
  static const double defaultLat = 41.0082;
  static const double defaultLon = 28.9784;

  Future<bool> ensurePermission() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return false;

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return false;
      return perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  /// Best available fix once (for initial UI).
  Future<Position?> current() async {
    try {
      if (!await ensurePermission()) return null;
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 12),
        );
      } catch (_) {
        return await Geolocator.getLastKnownPosition();
      }
    } catch (_) {
      return null;
    }
  }

  /// Continuous updates — throttled to reduce map rebuild jank.
  /// distanceFilter 8 m: enough for nav, not every GPS jitter tick.
  Stream<Position> stream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 8,
      ),
    );
  }

  double sogKn(Position p) {
    if (p.speed.isNaN || p.speed < 0) return 0;
    return p.speed * 1.94384;
  }

  double? cogDeg(Position p) {
    if (p.heading.isNaN || p.heading < 0) return null;
    return p.heading % 360;
  }

  bool hasFix(Position? p) => p != null;
}
