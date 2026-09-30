import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../core/nav_math.dart';

final _wxProvider = FutureProvider.autoDispose((ref) async {
  final loc = LocationService();
  final pos = await loc.current();
  final lat = pos?.latitude ?? LocationService.defaultLat;
  final lon = pos?.longitude ?? LocationService.defaultLon;
  final snap = await WeatherService().fetch(lat, lon);
  return <String, dynamic>{'lat': lat, 'lon': lon, 'snap': snap};
});

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_wxProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deniz Havasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(_wxProvider),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (d) {
          final s = d['snap'] as MarineSnapshot?;
          final lat = d['lat'] as double;
          final lon = d['lon'] as double;
          if (s == null) {
            return const Center(
              child: Text('Veri alinamadi (internet gerekir)'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                NavMath.formatLatLon(lat, lon),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 16),
              _tile(
                Icons.air,
                'Ruzgar',
                '${s.windKn?.toStringAsFixed(1) ?? "—"} kn',
              ),
              _tile(
                Icons.waves,
                'Dalga',
                '${s.waveM?.toStringAsFixed(1) ?? "—"} m',
              ),
              _tile(
                Icons.waterfall_chart,
                'Swell',
                '${s.swellM?.toStringAsFixed(1) ?? "—"} m',
              ),
              _tile(
                Icons.thermostat,
                'Hava',
                '${s.airC?.toStringAsFixed(1) ?? "—"} °C',
              ),
              const SizedBox(height: 24),
              Text(
                'Kaynak: Open-Meteo\n'
                'Yardimci bilgidir; resmi meteoroloji yerine gecmez.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.45),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(IconData icon, String title, String value) {
    return Card(
      color: const Color(0xFF121A2A),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF5CE1E6)),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}
