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
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (_) {
        // Fallback: last known
        return await Geolocator.getLastKnownPosition();
      }
    } catch (_) {
      return null;
    }
  }

  /// Continuous updates — distanceFilter 0 so SOG/COG keep refreshing.
  Stream<Position> stream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    );
  }

  /// SOG in knots. GPS speed is m/s; invalid/negative → 0.
  double sogKn(Position p) {
    if (p.speed.isNaN || p.speed < 0) return 0;
    return p.speed * 1.94384;
  }

  /// COG degrees true. GPS heading invalid when stationary (often -1).
  double? cogDeg(Position p) {
    if (p.heading.isNaN || p.heading < 0) return null;
    // Some devices report 0 when unknown while stopped — treat slow speed carefully
    if (p.speed >= 0 && p.speed < 0.3 && p.heading == 0) {
      // Ambiguous; still show 0 only if we trust it — keep value
    }
    return p.heading % 360;
  }

  bool hasFix(Position? p) => p != null;
}
