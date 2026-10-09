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

  /// Convert heading (deg) + speed (kn) to east/north velocity components (kn).
  static (double ve, double vn) velocityComponents(double cogDeg, double sogKn) {
    final rad = cogDeg * math.pi / 180;
    return (sogKn * math.sin(rad), sogKn * math.cos(rad));
  }

  /// CPA / TCPA between own ship and target.
  /// Returns null if relative speed is essentially zero.
  static CpaResult? cpaTcpa({
    required double ownLat,
    required double ownLon,
    required double ownCogDeg,
    required double ownSogKn,
    required double tgtLat,
    required double tgtLon,
    required double tgtCogDeg,
    required double tgtSogKn,
  }) {
    final meanLat = (ownLat + tgtLat) / 2 * math.pi / 180;
    final dx = (tgtLon - ownLon) * 60 * math.cos(meanLat);
    final dy = (tgtLat - ownLat) * 60;

    final (ove, ovn) = velocityComponents(ownCogDeg, ownSogKn);
    final (tve, tvn) = velocityComponents(tgtCogDeg, tgtSogKn);
    final rve = tve - ove;
    final rvn = tvn - ovn;

    final rv2 = rve * rve + rvn * rvn;
    if (rv2 < 1e-8) {
      final dist = math.sqrt(dx * dx + dy * dy);
      return CpaResult(cpaNm: dist, tcpaMin: 0, rangeNm: dist);
    }

    final tHours = -(dx * rve + dy * rvn) / rv2;
    final cpaX = dx + rve * tHours;
    final cpaY = dy + rvn * tHours;
    final cpa = math.sqrt(cpaX * cpaX + cpaY * cpaY);
    final dist = math.sqrt(dx * dx + dy * dy);

    return CpaResult(
      cpaNm: cpa,
      tcpaMin: tHours * 60,
      rangeNm: dist,
    );
  }
}

class CpaResult {
  final double cpaNm;
  final double tcpaMin;
  final double rangeNm;

  const CpaResult({
    required this.cpaNm,
    required this.tcpaMin,
    required this.rangeNm,
  });

  bool isDangerous({required double cpaLimitNm, required double tcpaLimitMin}) {
    return tcpaMin > 0 &&
        tcpaMin <= tcpaLimitMin &&
        cpaNm <= cpaLimitNm;
  }

  bool get isApproaching => tcpaMin > 0;
}
