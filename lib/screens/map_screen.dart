import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../core/maritime_theme.dart';
import '../core/nav_math.dart';
import '../models/route_leg.dart';
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
              backgroundColor: MaritimeColors.deepOcean,
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
                          color: MaritimeColors.cyan,
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: HelmIcon(size: 28, color: MaritimeColors.cyan),
                      ),
                    ),
                    ),
                  ),
                  if (target != null)
                    Marker(
                      point: target!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MaritimeColors.amber.withOpacity(0.15),
                          border: Border.all(
                            color: MaritimeColors.amber,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: AnchorIcon(size: 22, color: MaritimeColors.amber),
                        ),
                      ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          // Üst bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _glassBox(
                          child: Row(
                            children: [
                              const CompassIcon(size: 22, color: MaritimeColors.cyan),
                              const SizedBox(width: 8),
                              const Text(
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
                      _iconBtn(
                        Icons.layers,
                        'OpenSeaMap',
                        () => setState(() => seaMarks = !seaMarks),
                      ),
                      _iconBtn(
                        Icons.my_location,
                        'Merkez',
                        () => _map.move(ship, 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _glassBox(
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: MaritimeColors.cyan),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'POS  ${NavMath.formatLatLon(lat, lon)}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: MaritimeColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (target != null) ...[
                    const SizedBox(height: 4),
                    _glassBox(
                      child: Row(
                        children: [
                          const AnchorIcon(size: 16, color: MaritimeColors.amber),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'WPT  ${NavMath.formatLatLon(target!.latitude, target!.longitude)}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: MaritimeColors.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Seyir planı kartı
          if (route != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 92,
              child: _glassBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CompassIcon(size: 18, color: MaritimeColors.cyan),
                        const SizedBox(width: 8),
                        const Text(
                          'SEYIR PLANI',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 1.0,
                            color: MaritimeColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: MaritimeColors.cyan.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'MOTOR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: MaritimeColors.cyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _metric('Mesafe', '${route!.distanceNm.toStringAsFixed(2)} NM'),
                        _metric('Kerteriz', route!.bearingLabel),
                        _metric('ETA', route!.eta(etaSog)),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => setState(() {
                          route = null;
                          target = null;
                        }),
                        icon: const Icon(Icons.close, size: 16, color: MaritimeColors.coral),
                        label: const Text(
                          'Temizle',
                          style: TextStyle(color: MaritimeColors.coral),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Alt SOG/COG göstergesi
          Positioned(
            bottom: 16,
            left: 12,
            right: 12,
            child: Row(
              children: [
                Expanded(
                  child: _glassBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _sogCog('SOG', '${sog.toStringAsFixed(1)} kn'),
                        Container(width: 1, height: 24, color: MaritimeColors.border),
                        _sogCog('COG', cog != null ? '${cog.toStringAsFixed(0)}°' : '—'),
                        Container(width: 1, height: 24, color: MaritimeColors.border),
                        _sogCog('HDG', NavMath.compass(cog ?? 0)),
                      ],
                    ),
                  ),
                ),
              ],
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: MaritimeColors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: MaritimeColors.cyan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: MaritimeGradients.cardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MaritimeColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: MaritimeColors.deepOcean.withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: MaritimeColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            v,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: MaritimeColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: MaritimeColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MaritimeColors.border, width: 1),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, size: 20, color: MaritimeColors.cyan),
            ),
          ),
        ),
      ),
    );
  }
}
