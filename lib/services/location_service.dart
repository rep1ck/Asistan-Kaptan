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

  Future<Position?> current() async {
    try {
      if (!await ensurePermission()) return null;
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      return null;
    }
  }

  Stream<Position> stream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 5,
      ),
    );
  }

  double sogKn(Position p) {
    if (p.speed < 0) return 0;
    return p.speed * 1.94384;
  }

  double? cogDeg(Position p) {
    if (p.heading < 0) return null;
    return p.heading;
  }
}
