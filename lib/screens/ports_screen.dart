import 'package:flutter/material.dart';
import '../core/maritime_theme.dart';
import '../core/nav_math.dart';
import '../core/astro.dart';
import '../data/turkish_ports.dart';
import '../services/location_service.dart';

class PortsScreen extends StatefulWidget {
  const PortsScreen({super.key});

  @override
  State<PortsScreen> createState() => _PortsScreenState();
}

class _PortsScreenState extends State<PortsScreen> {
  double lat = LocationService.defaultLat;
  double lon = LocationService.defaultLon;
  List<PortDistance> near = [];
  String sunrise = '—';
  String sunset = '—';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loc = LocationService();
    final pos = await loc.current();
    lat = pos?.latitude ?? LocationService.defaultLat;
    lon = pos?.longitude ?? LocationService.defaultLon;
    near = nearestPorts(lat, lon, limit: 12);
    final (sr, ss) = Astro.sunTimes(lat, lon, DateTime.now());
    sunrise = Astro.fmt(sr);
    sunset = Astro.fmt(ss);
    if (mounted) setState(() => loading = false);
  }

  IconData _icon(String kind) {
    switch (kind) {
      case 'faro':
        return Icons.lightbulb_outline;
      case 'darbogaz':
        return Icons.horizontal_rule;
      default:
        return Icons.anchor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: MaritimeColors.cyan)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('LİMAN / FARO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: MaritimeColors.cyan),
            onPressed: () {
              setState(() => loading = true);
              _load();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: MaritimeGradients.cardGradient,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: MaritimeColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(NavMath.formatLatLon(lat, lon),
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        color: MaritimeColors.textSecondary)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.wb_sunny_outlined,
                        color: MaritimeColors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text('Doğuş $sunrise',
                        style:
                            const TextStyle(color: MaritimeColors.textPrimary)),
                    const Spacer(),
                    const Icon(Icons.nights_stay_outlined,
                        color: MaritimeColors.cyan, size: 20),
                    const SizedBox(width: 8),
                    Text('Batış $sunset',
                        style:
                            const TextStyle(color: MaritimeColors.textPrimary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('YAKIN REFERANSLAR',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: MaritimeColors.cyan)),
          const SizedBox(height: 10),
          for (final p in near)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: MaritimeGradients.cardGradient,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MaritimeColors.border),
              ),
              child: Row(
                children: [
                  Icon(_icon(p.port.kind),
                      color: MaritimeColors.cyan, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.port.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: MaritimeColors.textPrimary)),
                        Text(p.port.kind,
                            style: const TextStyle(
                                fontSize: 11,
                                color: MaritimeColors.textMuted)),
                      ],
                    ),
                  ),
                  Text('${p.nm.toStringAsFixed(1)} NM',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: MaritimeColors.cyan)),
                  const SizedBox(width: 8),
                  Text('${p.bearing.toStringAsFixed(0)}°',
                      style: const TextStyle(
                          fontSize: 12,
                          color: MaritimeColors.textSecondary)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
