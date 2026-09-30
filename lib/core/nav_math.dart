import 'dart:math' as math;

class NavMath {
  static double bearingDeg(double lat1, double lon1, double lat2, double lon2) {
    final r1 = lat1 * math.pi / 180;
    final r2 = lat2 * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final y = math.sin(dLon) * math.cos(r2);
    final x = math.cos(r1) * math.sin(r2) -
        math.sin(r1) * math.cos(r2) * math.cos(dLon);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  static double distanceNm(double lat1, double lon1, double lat2, double lon2) {
    const r = 3440.065;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static String compass(double deg) {
    const d = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return d[((deg + 22.5) % 360 / 45).floor()];
  }

  static String formatLatLon(double lat, double lon) {
    String f(double v, bool isLat) {
      final a = v.abs();
      final deg = a.floor();
      final min = (a - deg) * 60;
      final h = isLat ? (v >= 0 ? 'N' : 'S') : (v >= 0 ? 'E' : 'W');
      return "${deg.toString().padLeft(isLat ? 2 : 3, '0')}°${min.toStringAsFixed(3)}'$h";
    }

    return '${f(lat, true)}  ${f(lon, false)}';
  }

  static double msToKn(double ms) => ms < 0 ? 0 : ms * 1.94384;
}
