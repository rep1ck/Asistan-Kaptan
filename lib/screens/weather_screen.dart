import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/maritime_theme.dart';
import '../core/nav_math.dart';
import '../core/astro.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../widgets/nautical_icons.dart';

final _wxProvider = FutureProvider.autoDispose((ref) async {
  final loc = LocationService();
  final pos = await loc.current();
  final lat = pos?.latitude ?? LocationService.defaultLat;
  final lon = pos?.longitude ?? LocationService.defaultLon;
  final cog = pos != null ? loc.cogDeg(pos) : null;
  final sog = pos != null ? loc.sogKn(pos) : 0.0;
  final snap = await WeatherService().fetch(lat, lon);
  final (sr, ss) = Astro.sunTimes(lat, lon, DateTime.now());
  return <String, dynamic>{
    'lat': lat,
    'lon': lon,
    'snap': snap,
    'cog': cog,
    'sog': sog,
    'sunrise': Astro.fmt(sr),
    'sunset': Astro.fmt(ss),
  };
});

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_wxProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DENİZ HAVASI'),
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
          child: Text('Hata: $e',
              style: const TextStyle(color: MaritimeColors.danger)),
        ),
        data: (d) {
          final s = d['snap'] as MarineSnapshot?;
          final lat = d['lat'] as double;
          final lon = d['lon'] as double;
          final cog = d['cog'] as double?;
          final sunrise = d['sunrise'] as String;
          final sunset = d['sunset'] as String;
          if (s == null) {
            return const Center(
              child: Text('Veri alınamadı (internet gerekir)'),
            );
          }
          final rel = MarineSnapshot.relativeWindDir(s.windDir, cog);
          final trend = s.pressureTrend;
          String trendLabel = '—';
          if (trend != null) {
            if (trend > 0.5) {
              trendLabel = '↑ +${trend.toStringAsFixed(1)} hPa';
            } else if (trend < -0.5) {
              trendLabel = '↓ ${trend.toStringAsFixed(1)} hPa';
            } else {
              trendLabel = '→ stabil';
            }
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                          const Text('MEVCUT KONUM',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                  color: MaritimeColors.textMuted)),
                          Text(NavMath.formatLatLon(lat, lon),
                              style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  color: MaritimeColors.textSecondary)),
                          const SizedBox(height: 6),
                          Text('Doğuş $sunrise  ·  Batış $sunset',
                              style: const TextStyle(
                                  fontSize: 12, color: MaritimeColors.amber)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(Icons.air, MaritimeColors.cyan, 'RÜZGAR (TRUE)',
                  '${s.windKn?.toStringAsFixed(1) ?? "—"} kn',
                  s.windDir != null
                      ? '${s.windDir!.toStringAsFixed(0)}° ${NavMath.compass(s.windDir!)}'
                      : 'Yön yok'),
              const SizedBox(height: 10),
              _card(Icons.explore, MaritimeColors.teal, 'RÜZGAR (RELATIVE)',
                  rel != null ? '${rel.toStringAsFixed(0)}°' : '—',
                  cog != null
                      ? 'COG ${cog.toStringAsFixed(0)}° referans'
                      : 'COG bekleniyor'),
              const SizedBox(height: 10),
              _card(Icons.waves, MaritimeColors.teal, 'DALGA',
                  '${s.waveM?.toStringAsFixed(1) ?? "—"} m', 'Dalga yüksekliği'),
              const SizedBox(height: 10),
              _card(Icons.water, MaritimeColors.info, 'SWELL',
                  '${s.swellM?.toStringAsFixed(1) ?? "—"} m', 'Denizüstü dalga'),
              const SizedBox(height: 10),
              _card(Icons.thermostat, MaritimeColors.amber, 'SICAKLIK',
                  '${s.airC?.toStringAsFixed(1) ?? "—"} °C', 'Hava sıcaklığı'),
              const SizedBox(height: 10),
              _card(
                  Icons.speed,
                  MaritimeColors.warning,
                  'BASINÇ',
                  s.pressureHpa != null
                      ? '${s.pressureHpa!.toStringAsFixed(0)} hPa'
                      : '—',
                  'Trend (3s): $trendLabel'),
              const SizedBox(height: 20),
              const Text(
                'Kaynak: Open-Meteo · Yardımcı bilgidir; resmi meteoroloji yerine geçmez.',
                style: TextStyle(fontSize: 11, color: MaritimeColors.textMuted),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(
      IconData icon, Color color, String title, String value, String sub) {
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
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: MaritimeColors.textMuted)),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12, color: MaritimeColors.textSecondary)),
              ],
            ),
          ),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: color)),
        ],
      ),
    );
  }
}
