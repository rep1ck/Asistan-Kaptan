import 'dart:convert';
import 'package:http/http.dart' as http;

class MarineSnapshot {
  final double? windKn;
  final double? windDir;
  final double? waveM;
  final double? swellM;
  final double? sstC;
  final double? airC;
  final DateTime at;

  MarineSnapshot({
    this.windKn,
    this.windDir,
    this.waveM,
    this.swellM,
    this.sstC,
    this.airC,
    required this.at,
  });
}

class WeatherService {
  Future<MarineSnapshot?> fetch(double lat, double lon) async {
    try {
      final marine = Uri.parse(
        'https://marine-api.open-meteo.com/v1/marine'
        '?latitude=$lat&longitude=$lon'
        '&current=wave_height,swell_wave_height'
        '&timezone=auto',
      );
      final air = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,wind_speed_10m,wind_direction_10m'
        '&wind_speed_unit=kn'
        '&timezone=auto',
      );

      final r1 = await http.get(marine).timeout(const Duration(seconds: 12));
      final r2 = await http.get(air).timeout(const Duration(seconds: 12));
      if (r1.statusCode != 200 || r2.statusCode != 200) return null;

      final m = jsonDecode(r1.body) as Map<String, dynamic>;
      final a = jsonDecode(r2.body) as Map<String, dynamic>;
      final mc = m['current'] as Map<String, dynamic>?;
      final ac = a['current'] as Map<String, dynamic>?;

      return MarineSnapshot(
        windKn: (ac?['wind_speed_10m'] as num?)?.toDouble(),
        windDir: (ac?['wind_direction_10m'] as num?)?.toDouble(),
        waveM: (mc?['wave_height'] as num?)?.toDouble(),
        swellM: (mc?['swell_wave_height'] as num?)?.toDouble(),
        airC: (ac?['temperature_2m'] as num?)?.toDouble(),
        at: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }
}
