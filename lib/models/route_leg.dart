import 'package:latlong2/latlong.dart';
import '../core/nav_math.dart';

class RouteLeg {
  final LatLng from;
  final LatLng to;
  final double distanceNm;
  final double bearingDeg;

  RouteLeg({required this.from, required this.to})
      : distanceNm = NavMath.distanceNm(
            from.latitude, from.longitude, to.latitude, to.longitude),
        bearingDeg = NavMath.bearingDeg(
            from.latitude, from.longitude, to.latitude, to.longitude);

  String get bearingLabel =>
      '${bearingDeg.toStringAsFixed(0)}° ${NavMath.compass(bearingDeg)}';

  String eta(double sogKn) {
    if (sogKn < 0.3) sogKn = 12;
    final h = distanceNm / sogKn;
    if (h < 1) return '${(h * 60).round()} dk';
    return '${h.floor()}sa ${((h - h.floor()) * 60).round()}dk';
  }
}
