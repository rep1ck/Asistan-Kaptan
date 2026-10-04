import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../core/maritime_theme.dart';
import '../core/nav_math.dart';
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
  bool seaMarks = true;
  bool useOsm = false;
  double cruiseKn = 12;
  final List<LatLng> waypoints = [];

  @override
  void initState() {
    super.initState();
    _store.getCruiseKn().then((v) {
      if (mounted) setState(() => cruiseKn = v);
    });
  }

  void _onTap(TapPosition tapPosition, LatLng p) {
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
    if (h < 1) return '${(h * 60).round()} min';
    return '${h.floor()}h ${((h - h.floor()) * 60).round()}m';
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_posProvider);
    final loc = ref.read(_locProvider);
    final pos = async.asData?.value;
    final lat = pos?.latitude ?? LocationService.defaultLat;
    final lon = pos?.longitude ?? LocationService.defaultLon;
    final ship = LatLng(lat, lon);
    final sog = pos != null ? loc.sogKn(pos) : 0.0;
    final cog = pos != null ? loc.cogDeg(pos) : null;
    final etaSog = sog > 0.5 ? sog : cruiseKn;
    final nextBrg = _nextBearing(ship);
    final totalNm = _totalNm(ship);
    final routePoints =
        waypoints.isEmpty ? <LatLng>[] : <LatLng>[ship, ...waypoints];

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: ship,
              initialZoom: 9,
              minZoom: 2,
              maxZoom: 18,
              backgroundColor: MaritimeColors.deepOcean,
              onTap: _onTap,
            ),
            children: [
              TileLayer(
                urlTemplate: useOsm
                    ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                    : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.kaptanasistani.app',
              ),
              if (seaMarks)
                TileLayer(
                  urlTemplate:
                      'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.kaptanasistani.app',
                ),
              if (routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 3.5,
                      color: MaritimeColors.cyan,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: ship,
                    width: 48,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MaritimeColors.cyan.withOpacity(0.15),
                        border: Border.all(
                            color: MaritimeColors.cyan, width: 2),
                      ),
                      child: const Center(
                        child:
                            HelmIcon(size: 28, color: MaritimeColors.cyan),
                      ),
                    ),
                  ),
                  for (var i = 0; i < waypoints.length; i++)
                    Marker(
                      point: waypoints[i],
                      width: 36,
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MaritimeColors.amber.withOpacity(0.2),
                          border: Border.all(
                              color: MaritimeColors.amber, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: MaritimeColors.amber,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _glass(
                          child: const Row(
                            children: [
                              CompassIcon(
                                  size: 22, color: MaritimeColors.cyan),
                              SizedBox(width: 8),
                              Text(
                                'KAPTAN ASISTANI',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  fontSize: 13,
                                  color: MaritimeColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _btn(Icons.layers, () =>
                          setState(() => seaMarks = !seaMarks)),
                      _btn(Icons.translate,
                          () => setState(() => useOsm = !useOsm)),
                      _btn(Icons.my_location, () => _map.move(ship, 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _glass(
                    child: Text(
                      'POS  ${NavMath.formatLatLon(lat, lon)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: MaritimeColors.textSecondary,
                      ),
                    ),
                  ),
                  if (waypoints.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _glass(
                      child: Text(
                        'WPT ${waypoints.length}:  ${NavMath.formatLatLon(waypoints.last.latitude, waypoints.last.longitude)}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: MaritimeColors.amber,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (waypoints.isNotEmpty)
            Positioned(
              left: 12,
              right: 12,
              bottom: 92,
              child: _glass(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        CompassIcon(size: 18, color: MaritimeColors.cyan),
                        SizedBox(width: 8),
                        Text(
                          'PASSAGE PLAN',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 1.0,
                            color: MaritimeColors.textPrimary,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'DIRECT / RHUMB',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: MaritimeColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap map to add waypoints along fairways / TSS. '
                      'Not automatic channel routing (needs ENC).',
                      style: TextStyle(
                        fontSize: 11,
                        color: MaritimeColors.textMuted,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _metric(
                            'Dist', '${totalNm.toStringAsFixed(2)} NM'),
                        _metric('Legs', '${waypoints.length}'),
                        _metric(
                          'BRG',
                          nextBrg == null
                              ? '—'
                              : '${nextBrg.toStringAsFixed(0)}° ${NavMath.compass(nextBrg)}',
                        ),
                        _metric('ETA', _eta(etaSog, totalNm)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _undoLast,
                          child: const Text('Undo',
                              style:
                                  TextStyle(color: MaritimeColors.amber)),
                        ),
                        TextButton(
                          onPressed: _clearRoute,
                          child: const Text('Clear',
                              style:
                                  TextStyle(color: MaritimeColors.coral)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 12,
            right: 12,
            child: _glass(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _sogCog('SOG', '${sog.toStringAsFixed(1)} kn'),
                  Container(
                      width: 1, height: 24, color: MaritimeColors.border),
                  _sogCog(
                      'COG',
                      cog != null
                          ? '${cog.toStringAsFixed(0)}°'
                          : '—'),
                  Container(
                      width: 1, height: 24, color: MaritimeColors.border),
                  _sogCog('HDG', NavMath.compass(cog ?? 0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sogCog(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: MaritimeColors.textMuted)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: MaritimeColors.cyan)),
        ],
      ),
    );
  }

  Widget _glass({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: MaritimeGradients.cardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MaritimeColors.border),
      ),
      child: child,
    );
  }

  Widget _metric(String k, String v) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: MaritimeColors.textMuted)),
          const SizedBox(height: 2),
          Text(v,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: MaritimeColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        color: MaritimeColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: MaritimeColors.cyan),
          ),
        ),
      ),
    );
  }
}
