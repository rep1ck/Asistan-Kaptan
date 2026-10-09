import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../core/maritime_theme.dart';
import '../core/nav_math.dart';
import '../services/ais_service.dart';
import '../services/location_service.dart';
import '../services/settings_store.dart';
import '../widgets/nautical_icons.dart';

final _locProvider = Provider((_) => LocationService());

final _posProvider = StreamProvider<Position?>((ref) async* {
  final loc = ref.read(_locProvider);
  try {
    if (!await loc.ensurePermission()) {
      yield null;
      return;
    }
    final first = await loc.current();
    if (first != null) yield first;
    yield* loc.stream();
  } catch (_) {
    yield null;
  }
});

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _map = MapController();
  final _store = SettingsStore();
  final _ais = AisService();
  bool seaMarks = true;
  bool useOsm = false;
  bool aisOn = false;
  bool planMode = false;
  double cruiseKn = 12;
  final List<LatLng> waypoints = [];
  Map<int, AisVessel> vessels = {};
  StreamSubscription? _aisSub;
  String _aisKey = '';
  double _cpaLimitNm = 0.5;
  double _tcpaLimitMin = 15;

  @override
  void initState() {
    super.initState();
    _store.getCruiseKn().then((v) {
      if (mounted) setState(() => cruiseKn = v);
    });
    _store.getAisApiKey().then((k) {
      if (mounted) setState(() => _aisKey = k);
    });
    _store.getCpaNm().then((v) {
      if (mounted) setState(() => _cpaLimitNm = v);
    });
    _store.getTcpaMin().then((v) {
      if (mounted) setState(() => _tcpaLimitMin = v);
    });
  }

  @override
  void dispose() {
    _aisSub?.cancel();
    _ais.dispose();
    super.dispose();
  }

  void _onTap(TapPosition tapPosition, LatLng p) {
    if (!planMode) return;
    setState(() => waypoints.add(p));
  }

  void _clearRoute() => setState(() => waypoints.clear());

  void _undoLast() {
    setState(() {
      if (waypoints.isNotEmpty) waypoints.removeLast();
    });
  }

  double _totalNm(LatLng ship) {
    if (waypoints.isEmpty) return 0;
    double t = 0;
    LatLng prev = ship;
    for (final w in waypoints) {
      t += NavMath.distanceNm(
          prev.latitude, prev.longitude, w.latitude, w.longitude);
      prev = w;
    }
    return t;
  }

  double? _nextBearing(LatLng ship) {
    if (waypoints.isEmpty) return null;
    final a = waypoints.length == 1 ? ship : waypoints[waypoints.length - 2];
    final b = waypoints.last;
    return NavMath.bearingDeg(
        a.latitude, a.longitude, b.latitude, b.longitude);
  }

  String _eta(double sog, double nm) {
    if (nm <= 0) return '—';
    if (sog < 0.3) sog = cruiseKn;
    final h = nm / sog;
    if (h < 1) return '${(h * 60).round()} dk';
    return '${h.floor()}sa ${((h - h.floor()) * 60).round()}dk';
  }

  // RESTORE_PARTIAL - full file continues in next commit
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Loading map…')),
    );
  }
}
