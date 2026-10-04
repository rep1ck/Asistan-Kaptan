import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/maritime_theme.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../core/nav_math.dart';
import '../widgets/nautical_icons.dart';

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
        title: const Text('DENIZ HAVASI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: MaritimeColors.cyan),
            onPressed: () => ref.invalidate(_wxProvider),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: MaritimeColors.cyan),
        ),
        error: (e, _) => Center(
          child: Text('Hata: $e', style: const TextStyle(color: MaritimeColors.danger)),
        ),
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
              // Konum kartı
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: MaritimeGradients.cardGradient,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: MaritimeColors.border),
                ),
                child: Row(
                  children: [
                    const CompassIcon(size: 28, color: MaritimeColors.cyan),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MEVCUT KONUM',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: MaritimeColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NavMath.formatLatLon(lat, lon),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: MaritimeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Rüzgar kartı
              _weatherCard(
                icon: Icons.air,
                iconColor: MaritimeColors.cyan,
                title: 'RUZGAR',
                value: '${s.windKn?.toStringAsFixed(1) ?? "—"} kn',
                subtitle: s.windDir != null
                    ? '${s.windDir!.toStringAsFixed(0)}° ${NavMath.compass(s.windDir!)}'
                    : 'Yon verisi yok',
              ),
              const SizedBox(height: 12),
              // Dalga kartı
              _weatherCard(
                icon: Icons.waves,
                iconColor: MaritimeColors.teal,
                title: 'DALGA',
                value: '${s.waveM?.toStringAsFixed(1) ?? "—"} m',
                subtitle: 'Dalga yuksekligi',
              ),
              const SizedBox(height: 12),
              // Swell kartı
              _weatherCard(
                icon: Icons.water,
                iconColor: MaritimeColors.info,
                title: 'SWELL',
                value: '${s.swellM?.toStringAsFixed(1) ?? "—"} m',
                subtitle: 'Deniz ustu dalga',
              ),
              const SizedBox(height: 12),
              // Sıcaklık kartı
              _weatherCard(
                icon: Icons.thermostat,
                iconColor: MaritimeColors.amber,
                title: 'HAVA SICAKLIGI',
                value: '${s.airC?.toStringAsFixed(1) ?? "—"} °C',
                subtitle: 'Hava sicakligi',
              ),
              const SizedBox(height: 24),
              // Uyarı
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: MaritimeColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: MaritimeColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: MaritimeColors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Kaynak: Open-Meteo\nYardimci bilgidir; resmi meteoroloji yerine gecmez.',
                        style: TextStyle(
                          fontSize: 12,
                          color: MaritimeColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _weatherCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: MaritimeGradients.cardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MaritimeColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: MaritimeColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: MaritimeColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}
