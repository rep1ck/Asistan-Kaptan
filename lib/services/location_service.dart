import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/nav_math.dart';

class LocationService {
  static const double defaultLat = 41.0082;
  static const double defaultLon = 28.9784;

  Future<bool> ensurePermission() async {
    try {
      final s = await Permission.locationWhenInUse.request();
      return s.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<Position?> current() async {
    try {
      if (!await ensurePermission()) return null;
      if (!await Geolocator.isLocationServiceEnabled()) return null;
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

  double sogKn(Position p) => NavMath.msToKn(p.speed);

  double? cogDeg(Position p) {
    if (p.heading < 0) return null;
    return p.heading;
  }

  Position get fallback => Position(
        latitude: defaultLat,
        longitude: defaultLon,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
}
