import 'dart:math' as math;

/// Solar times (UTC-based, then local via DateTime).
class Astro {
  /// Returns (sunrise, sunset) local DateTime for lat/lon on [day].
  static (DateTime?, DateTime?) sunTimes(double lat, double lon, DateTime day) {
    try {
      final jd = _julianDay(day.year, day.month, day.day);
      final rise = _sunEvent(jd, lat, lon, true);
      final set = _sunEvent(jd, lat, lon, false);
      if (rise == null || set == null) return (null, null);
      final base = DateTime.utc(day.year, day.month, day.day);
      DateTime toLocal(double hours) {
        final h = hours.floor();
        final m = ((hours - h) * 60).round();
        return base.add(Duration(hours: h, minutes: m)).toLocal();
      }
      return (toLocal(rise), toLocal(set));
    } catch (_) {
      return (null, null);
    }
  }

  static double _julianDay(int y, int m, int d) {
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;
  }

  static double? _sunEvent(double jd, double lat, double lon, bool rise) {
    final t = (jd - 2451545.0) / 36525.0;
    final L0 = _norm360(280.46646 + 36000.76983 * t);
    final M = _norm360(357.52911 + 35999.05029 * t) * math.pi / 180;
    final C = (1.914602 - 0.004817 * t) * math.sin(M) +
        0.019993 * math.sin(2 * M);
    final sunLong = (L0 + C) * math.pi / 180;
    final eps = (23.439 - 0.0000004 * t) * math.pi / 180;
    final sinDec = math.sin(eps) * math.sin(sunLong);
    final dec = math.asin(sinDec);
    final latR = lat * math.pi / 180;
    final cosH = (math.sin(-0.833 * math.pi / 180) -
            math.sin(latR) * math.sin(dec)) /
        (math.cos(latR) * math.cos(dec));
    if (cosH < -1 || cosH > 1) return null;
    final H = math.acos(cosH) * 180 / math.pi;
    final eqTime = 4 *
        (L0 -
            0.0057183 -
            (math.atan2(math.cos(eps) * math.sin(sunLong), math.cos(sunLong)) *
                    180 /
                    math.pi) -
            lon);
    final solarNoon = 12 - eqTime / 60;
    return rise ? solarNoon - H / 15 : solarNoon + H / 15;
  }

  static double _norm360(double d) {
    var x = d % 360;
    if (x < 0) x += 360;
    return x;
  }

  static String fmt(DateTime? t) {
    if (t == null) return '—';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}
