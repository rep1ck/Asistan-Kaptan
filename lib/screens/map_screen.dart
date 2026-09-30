import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../core/nav_math.dart';
import '../models/route_leg.dart';
import '../services/location_service.dart';
import '../services/settings_store.dart';

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
  RouteLeg? route;
  LatLng? target;
  double cruiseKn = 12;

  @override
  void initState() {
    super.initState();
    _store.getCruiseKn().then((v) {
      if (mounted) setState(() => cruiseKn = v);
    });
  }

  void _onTap(TapPosition tapPosition, LatLng p) {
    final pos = ref.read(_posProvider).asData?.value;
    final from = LatLng(
      pos?.latitude ?? LocationService.defaultLat,
      pos?.longitude ?? LocationService.defaultLon,
    );
    setState(() {
      target = p;
      route = RouteLeg(from: from, to: p);
    });
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
              onTap: _onTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kaptanasistani.app',
              ),
              if (seaMarks)
                TileLayer(
                  urlTemplate:
                      'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.kaptanasistani.app',
                ),
              if (route != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [route!.from, route!.to],
                      strokeWidth: 3.5,
                      color: const Color(0xFF5CE1E6),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: ship,
                    width: 44,
                    height: 44,
                    child: const Icon(
                      Icons.navigation,
                      color: Color(0xFF5CE1E6),
                      size: 36,
                    ),
                  ),
                  if (target != null)
                    Marker(
                      point: target!,
                      width: 36,
                      height: 36,
                      child: const Icon(
                        Icons.flag,
                        color: Color(0xFFFF8A00),
                        size: 32,
                      ),
                    ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _box(
                          child: const Text(
                            'KAPTAN ASISTANI',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _iconBtn(
                        Icons.layers,
                        () => setState(() => seaMarks = !seaMarks),
                      ),
                      _iconBtn(
                        Icons.my_location,
                        () => _map.move(ship, 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _box(
                    child: Text(
                      'POS  ${NavMath.formatLatLon(lat, lon)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (target != null) ...[
                    const SizedBox(height: 4),
                    _box(
                      child: Text(
                        'WPT  ${NavMath.formatLatLon(target!.latitude, target!.longitude)}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Color(0xFFFF8A00),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (route != null)
            Positioned(
              left: 10,
              right: 10,
              bottom: 88,
              child: _box(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SEYIR PLANI (MOTOR)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _metric(
                          'Mesafe',
                          '${route!.distanceNm.toStringAsFixed(2)} NM',
                        ),
                        _metric('Kerteriz', route!.bearingLabel),
                        _metric('ETA', route!.eta(etaSog)),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() {
                          route = null;
                          target = null;
                        }),
                        child: const Text('Temizle'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 10,
            child: _box(
              child: Text(
                'SOG ${sog.toStringAsFixed(1)} kn    COG ${cog != null ? "${cog.toStringAsFixed(0)}°" : "—"}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xE0121A2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }

  Widget _metric(String k, String v) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            k,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Text(
            v,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        color: const Color(0xE0121A2A),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }
}
