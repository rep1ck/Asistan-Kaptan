import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/maritime_theme.dart';
import '../core/nav_math.dart';
import '../services/ais_service.dart';
import '../services/settings_store.dart';

/// Anchor / MOB / GPX / CPA-line / AIS-filter helpers for MapScreen.
class MapFeatures {
  MapFeatures({
    required this.cruiseKn,
    required this.cpaLimitNm,
    required this.tcpaLimitMin,
    required this.anchorRadiusNm,
    required this.aisRangeNm,
    required this.aisFilter,
  });

  final double cruiseKn;
  final double cpaLimitNm;
  final double tcpaLimitMin;
  final double anchorRadiusNm;
  final double aisRangeNm;
  final AisFilterMode aisFilter;

  bool isDangerous(AisVessel v, LatLng ship, double sog, double? cog) {
    if (cog == null || v.sogKn == null || v.cogDeg == null) return false;
    final r = NavMath.cpaTcpa(
      ownLat: ship.latitude,
      ownLon: ship.longitude,
      ownCogDeg: cog,
      ownSogKn: sog < 0.3 ? cruiseKn : sog,
      tgtLat: v.lat,
      tgtLon: v.lon,
      tgtCogDeg: v.cogDeg!,
      tgtSogKn: v.sogKn!,
    );
    if (r == null) return false;
    return r.isDangerous(cpaLimitNm: cpaLimitNm, tcpaLimitMin: tcpaLimitMin);
  }

  List<AisVessel> filterVessels(
    Map<int, AisVessel> vessels,
    LatLng ship,
    double sog,
    double? cog,
  ) {
    final list = vessels.values.toList();
    if (aisFilter == AisFilterMode.all) return list;
    if (aisFilter == AisFilterMode.near) {
      return list
          .where((v) =>
              NavMath.distanceNm(
                  ship.latitude, ship.longitude, v.lat, v.lon) <=
              aisRangeNm)
          .toList();
    }
    return list.where((v) => isDangerous(v, ship, sog, cog)).toList();
  }

  List<Polyline> cpaLines(
    Map<int, AisVessel> vessels,
    LatLng ship,
    double sog,
    double? cog,
  ) {
    if (cog == null) return [];
    final lines = <Polyline>[];
    for (final v in vessels.values) {
      if (v.sogKn == null || v.cogDeg == null) continue;
      final r = NavMath.cpaTcpa(
        ownLat: ship.latitude,
        ownLon: ship.longitude,
        ownCogDeg: cog,
        ownSogKn: sog < 0.3 ? cruiseKn : sog,
        tgtLat: v.lat,
        tgtLon: v.lon,
        tgtCogDeg: v.cogDeg!,
        tgtSogKn: v.sogKn!,
      );
      if (r == null ||
          !r.isDangerous(cpaLimitNm: cpaLimitNm, tcpaLimitMin: tcpaLimitMin)) {
        continue;
      }
      final cpaPt = LatLng(r.cpaLat, r.cpaLon);
      lines.add(Polyline(
        points: [ship, cpaPt],
        strokeWidth: 2.5,
        color: MaritimeColors.danger.withOpacity(0.75),
      ));
      lines.add(Polyline(
        points: [LatLng(v.lat, v.lon), cpaPt],
        strokeWidth: 2,
        color: MaritimeColors.warning.withOpacity(0.65),
      ));
    }
    return lines;
  }

  static Future<void> exportGpx({
    required LatLng ship,
    required List<LatLng> waypoints,
    LatLng? mob,
    LatLng? anchor,
  }) async {
    final pts = <(double, double, String?)>[];
    pts.add((ship.latitude, ship.longitude, 'OWN'));
    for (var i = 0; i < waypoints.length; i++) {
      final w = waypoints[i];
      pts.add((w.latitude, w.longitude, 'WPT ${i + 1}'));
    }
    if (mob != null) pts.add((mob.latitude, mob.longitude, 'MOB'));
    if (anchor != null) {
      pts.add((anchor.latitude, anchor.longitude, 'ANCHOR'));
    }
    final now = DateTime.now();
    final name =
        'Kaptan_${now.month.toString().padLeft(2, "0")}${now.day.toString().padLeft(2, "0")}_${now.hour.toString().padLeft(2, "0")}${now.minute.toString().padLeft(2, "0")}';
    final gpx = NavMath.toGpx(name: name, points: pts);
    await Clipboard.setData(ClipboardData(text: gpx));
  }
}
