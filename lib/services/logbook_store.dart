import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LogEntry {
  final DateTime at;
  final double lat;
  final double lon;
  final double? sogKn;
  final double? cogDeg;
  final String note;

  LogEntry({
    required this.at,
    required this.lat,
    required this.lon,
    this.sogKn,
    this.cogDeg,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
        'at': at.toIso8601String(),
        'lat': lat,
        'lon': lon,
        'sogKn': sogKn,
        'cogDeg': cogDeg,
        'note': note,
      };

  factory LogEntry.fromJson(Map<String, dynamic> j) => LogEntry(
        at: DateTime.tryParse(j['at'] as String? ?? '') ?? DateTime.now(),
        lat: (j['lat'] as num?)?.toDouble() ?? 0,
        lon: (j['lon'] as num?)?.toDouble() ?? 0,
        sogKn: (j['sogKn'] as num?)?.toDouble(),
        cogDeg: (j['cogDeg'] as num?)?.toDouble(),
        note: j['note'] as String? ?? '',
      );
}

class LogbookStore {
  Future<SharedPreferences> get _p async => SharedPreferences.getInstance();

  Future<List<LogEntry>> getEntries() async {
    final raw = (await _p).getString('logbook');
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> add(LogEntry e) async {
    final list = await getEntries();
    list.insert(0, e);
    while (list.length > 200) {
      list.removeLast();
    }
    await (await _p).setString(
      'logbook',
      jsonEncode(list.map((x) => x.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    await (await _p).remove('logbook');
  }
}
