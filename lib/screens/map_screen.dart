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

  @override
  void initState() {
    super.initState();
    _store.getCruiseKn().then((v) {
      if (mounted) setState(() => cruiseKn = v);
    });
    _store.getAisApiKey().then((k) {
      if (mounted) setState(() => _aisKey = k);
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
    if (h < 1) return '${(h * 60).round()} min';
    return '${h.floor()}h ${((h - h.floor()) * 60).round()}m';
  }

  Future<void> _savePlan() async {
    if (waypoints.isEmpty) return;
    final ctrl = TextEditingController(
      text:
          'Plan ${DateTime.now().hour.toString().padLeft(2, '0')}${DateTime.now().minute.toString().padLeft(2, '0')}',
    );
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MaritimeColors.surfaceDark,
        title: const Text('Save passage plan',
            style: TextStyle(color: MaritimeColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: MaritimeColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Plan name',
            labelStyle: TextStyle(color: MaritimeColors.textMuted),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save',
                style: TextStyle(color: MaritimeColors.cyan)),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await _store.savePlan(SavedPlan(
      name: name,
      waypoints: waypoints.map((w) => [w.latitude, w.longitude]).toList(),
      savedAt: DateTime.now(),
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved: $name'),
        backgroundColor: MaritimeColors.success,
      ),
    );
  }

  Future<void> _loadPlans() async {
    final plans = await _store.getPlans();
    if (!mounted) return;
    if (plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No saved plans'),
          backgroundColor: MaritimeColors.warning,
        ),
      );
      return;
    }
    await showModalBottomSheet(
      context: context,
      backgroundColor: MaritimeColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const Text(
              'SAVED PLANS',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: MaritimeColors.cyan,
              ),
            ),
            const SizedBox(height: 12),
            for (final p in plans)
              ListTile(
                title: Text(p.name,
                    style: const TextStyle(color: MaritimeColors.textPrimary)),
                subtitle: Text(
                  '${p.waypoints.length} WPT · ${p.savedAt.toLocal().toString().substring(0, 16)}',
                  style: const TextStyle(
                      fontSize: 12, color: MaritimeColors.textMuted),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: MaritimeColors.coral),
                  onPressed: () async {
                    await _store.deletePlan(p.name);
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadPlans();
                  },
                ),
                onTap: () {
                  setState(() {
                    waypoints
                      ..clear()
                      ..addAll(p.waypoints.map((e) => LatLng(e[0], e[1])));
                    planMode = true;
                  });
                  Navigator.pop(ctx);
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _toggleAis(LatLng ship) async {
    if (aisOn) {
      await _ais.stop();
      await _aisSub?.cancel();
      setState(() {
        aisOn = false;
        vessels = {};
      });
      return;
    }
    final key = await _store.getAisApiKey();
    _aisKey = key.trim();
    if (_aisKey.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'AIS API key required. Settings → AIS key (free: aisstream.io)',
          ),
          backgroundColor: MaritimeColors.warning,
        ),
      );
      return;
    }
    await _aisSub?.cancel();
    _aisSub = _ais.stream.listen((m) {
      if (mounted) setState(() => vessels = m);
    });
    final ok = await _ais.start(
      apiKey: _aisKey,
      lat: ship.latitude,
      lon: ship.longitude,
      deltaDeg: 1.0,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AIS connect failed: ${_ais.lastError ?? "unknown"}'),
          backgroundColor: MaritimeColors.danger,
        ),
      );
      return;
    }
    setState(() => aisOn = true);
  }

  void _openLayersMenu(LatLng ship) {
    showModalBottomSheet(
      context: context,
      backgroundColor: MaritimeColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: MaritimeColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('MAP LAYERS',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: MaritimeColors.cyan)),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('OpenSeaMap seamarks',
                        style: TextStyle(color: MaritimeColors.textPrimary)),
                    value: seaMarks,
                    activeColor: MaritimeColors.cyan,
                    onChanged: (v) {
                      setState(() => seaMarks = v);
                      setSheet(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('English place names (ESRI)',
                        style: TextStyle(color: MaritimeColors.textPrimary)),
                    value: !useOsm,
                    activeColor: MaritimeColors.cyan,
                    onChanged: (v) {
                      setState(() => useOsm = !v);
                      setSheet(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('AIS vessels (live)',
                        style: TextStyle(color: MaritimeColors.textPrimary)),
                    value: aisOn,
                    activeColor: MaritimeColors.cyan,
                    onChanged: (v) async {
                      Navigator.pop(ctx);
                      await _toggleAis(ship);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                        child: HelmIcon(size: 28, color: MaritimeColors.cyan),
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
                  if (aisOn)
                    for (final v in vessels.values)
                      Marker(
                        point: LatLng(v.lat, v.lon),
                        width: 40,
                        height: 40,
                        child: Tooltip(
                          message:
                              '${v.name}\nSOG ${v.sogKn?.toStringAsFixed(1) ?? "—"} kn',
                          child: const Icon(
                            Icons.directions_boat,
                            color: Color(0xFF4ADE80),
                            size: 28,
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
                      _modeBtn(
                        planMode,
                        Icons.route,
                        planMode ? 'PLAN ON' : 'PLAN',
                        () {
                          setState(() => planMode = !planMode);
                          if (planMode) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Passage plan mode ON — tap map to add WPT'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      _btn(Icons.folder_open, _loadPlans),
                      _btn(Icons.layers, () => _openLayersMenu(ship)),
                      _btn(Icons.my_location, () => _map.move(ship, 11)),
                    ],
                  ),
                  if (planMode) ...[
                    const SizedBox(height: 6),
                    _glass(
                      child: const Row(
                        children: [
                          Icon(Icons.edit_location_alt,
                              size: 16, color: MaritimeColors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'PLAN MODE — tap map to place waypoints',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: MaritimeColors.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  _glass(
                    child: Text(
                      'POS  ${NavMath.formatLatLon(lat, lon)}'
                      '${aisOn ? "   AIS ${vessels.length}" : ""}',
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
                      'Tap map only while PLAN MODE is ON.',
                      style: TextStyle(
                          fontSize: 11, color: MaritimeColors.textMuted),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _metric('Dist', '${totalNm.toStringAsFixed(2)} NM'),
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
                          onPressed: _savePlan,
                          child: const Text('Save',
                              style: TextStyle(color: MaritimeColors.cyan)),
                        ),
                        TextButton(
                          onPressed: _undoLast,
                          child: const Text('Undo',
                              style: TextStyle(color: MaritimeColors.amber)),
                        ),
                        TextButton(
                          onPressed: _clearRoute,
                          child: const Text('Clear',
                              style: TextStyle(color: MaritimeColors.coral)),
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
                  _sogCog('SOG',
                      pos == null ? '—' : '${sog.toStringAsFixed(1)} kn'),
                  Container(
                      width: 1, height: 24, color: MaritimeColors.border),
                  _sogCog('COG',
                      cog == null ? '—' : '${cog.toStringAsFixed(0)}°'),
                  Container(
                      width: 1, height: 24, color: MaritimeColors.border),
                  _sogCog(
                      'CRS', cog == null ? '—' : NavMath.compass(cog)),
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

  Widget _modeBtn(
      bool active, IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        color: active
            ? MaritimeColors.amber.withOpacity(0.25)
            : MaritimeColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? MaritimeColors.amber : MaritimeColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 18,
                    color: active
                        ? MaritimeColors.amber
                        : MaritimeColors.cyan),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? MaritimeColors.amber
                        : MaritimeColors.cyan,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
