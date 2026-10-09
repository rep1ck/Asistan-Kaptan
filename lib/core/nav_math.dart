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

  static (double ve, double vn) velocityComponents(double cogDeg, double sogKn) {
    final rad = cogDeg * math.pi / 180;
    return (sogKn * math.sin(rad), sogKn * math.cos(rad));
  }

  static (double lat, double lon) destinationPoint(
    double lat, double lon, double bearingDeg, double distNm,
  ) {
    const r = 3440.065;
    final br = bearingDeg * math.pi / 180;
    final lat1 = lat * math.pi / 180;
    final lon1 = lon * math.pi / 180;
    final ang = distNm / r;
    final lat2 = math.asin(
      math.sin(lat1) * math.cos(ang) +
          math.cos(lat1) * math.sin(ang) * math.cos(br),
    );
    final lon2 = lon1 +
        math.atan2(
          math.sin(br) * math.sin(ang) * math.cos(lat1),
          math.cos(ang) - math.sin(lat1) * math.sin(lat2),
        );
    return (lat2 * 180 / math.pi, ((lon2 * 180 / math.pi + 540) % 360) - 180);
  }

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
      return CpaResult(
        cpaNm: dist,
        tcpaMin: 0,
        rangeNm: dist,
        cpaLat: ownLat,
        cpaLon: ownLon,
      );
    }

    final tHours = -(dx * rve + dy * rvn) / rv2;
    final cpaX = dx + rve * tHours;
    final cpaY = dy + rvn * tHours;
    final cpa = math.sqrt(cpaX * cpaX + cpaY * cpaY);
    final dist = math.sqrt(dx * dx + dy * dy);

    final ownCpaX = ove * tHours;
    final ownCpaY = ovn * tHours;
    final cpaLat = ownLat + ownCpaY / 60;
    final cpaLon = ownLon + ownCpaX / (60 * math.cos(ownLat * math.pi / 180));

    return CpaResult(
      cpaNm: cpa,
      tcpaMin: tHours * 60,
      rangeNm: dist,
      cpaLat: cpaLat,
      cpaLon: cpaLon,
    );
  }

  static String toGpx({
    required String name,
    required List<(double lat, double lon, String? label)> points,
  }) {
    final buf = StringBuffer();
    buf.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buf.writeln(
        '<gpx version="1.1" creator="KaptanAsistani" xmlns="http://www.topografix.com/GPX/1/1">');
    buf.writeln('<metadata><name>${_xml(name)}</name></metadata>');
    buf.writeln('<rte><name>${_xml(name)}</name>');
    for (var i = 0; i < points.length; i++) {
      final (lat, lon, label) = points[i];
      final n = label ?? 'WPT ${i + 1}';
      buf.writeln(
          '  <rtept lat="${lat.toStringAsFixed(6)}" lon="${lon.toStringAsFixed(6)}"><name>${_xml(n)}</name></rtept>');
    }
    buf.writeln('</rte></gpx>');
    return buf.toString();
  }

  static String _xml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

class CpaResult {
  final double cpaNm;
  final double tcpaMin;
  final double rangeNm;
  final double cpaLat;
  final double cpaLon;

  const CpaResult({
    required this.cpaNm,
    required this.tcpaMin,
    required this.rangeNm,
    required this.cpaLat,
    required this.cpaLon,
  });

  bool isDangerous({required double cpaLimitNm, required double tcpaLimitMin}) {
    return tcpaMin > 0 &&
        tcpaMin <= tcpaLimitMin &&
        cpaNm <= cpaLimitNm;
  }

  bool get isApproaching => tcpaMin > 0;
}
