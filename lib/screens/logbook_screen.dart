import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/maritime_theme.dart';
import '../core/nav_math.dart';
import '../services/location_service.dart';
import '../services/logbook_store.dart';

class LogbookScreen extends StatefulWidget {
  const LogbookScreen({super.key});

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  final _store = LogbookStore();
  final _noteCtrl = TextEditingController();
  List<LogEntry> entries = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    entries = await _store.getEntries();
    if (mounted) setState(() => loading = false);
  }

  Future<void> _add() async {
    final loc = LocationService();
    Position? pos;
    try {
      pos = await loc.current();
    } catch (_) {}
    final lat = pos?.latitude ?? LocationService.defaultLat;
    final lon = pos?.longitude ?? LocationService.defaultLon;
    final sog = pos != null ? loc.sogKn(pos) : null;
    final cog = pos != null ? loc.cogDeg(pos) : null;
    final note =
        _noteCtrl.text.trim().isEmpty ? 'Pozisyon kaydı' : _noteCtrl.text.trim();
    await _store.add(LogEntry(
      at: DateTime.now(),
      lat: lat,
      lon: lon,
      sogKn: sog,
      cogDeg: cog,
      note: note,
    ));
    _noteCtrl.clear();
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Kayıt eklendi'),
      backgroundColor: MaritimeColors.success,
    ));
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
        title: const Text('SEYİR DEFTERİ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: MaritimeColors.coral),
            onPressed: () async {
              await _store.clear();
              await _reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteCtrl,
                    style: const TextStyle(color: MaritimeColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Not (opsiyonel)',
                      hintStyle:
                          const TextStyle(color: MaritimeColors.textMuted),
                      filled: true,
                      fillColor: MaritimeColors.surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: MaritimeColors.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                  label: const Text('Kayıt'),
                  style: FilledButton.styleFrom(
                    backgroundColor: MaritimeColors.cyan,
                    foregroundColor: MaritimeColors.deepOcean,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const Center(
                    child: Text('Henüz kayıt yok',
                        style: TextStyle(color: MaritimeColors.textMuted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    itemCount: entries.length,
                    itemBuilder: (_, i) {
                      final e = entries[i];
                      final t = e.at.toLocal();
                      final ts =
                          '${t.day.toString().padLeft(2, '0')}.${t.month.toString().padLeft(2, '0')} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: MaritimeGradients.cardGradient,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: MaritimeColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(ts,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: MaritimeColors.cyan)),
                                const Spacer(),
                                if (e.sogKn != null)
                                  Text('${e.sogKn!.toStringAsFixed(1)} kn',
                                      style: const TextStyle(
                                          color: MaritimeColors.textSecondary,
                                          fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(NavMath.formatLatLon(e.lat, e.lon),
                                style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: MaritimeColors.textSecondary)),
                            if (e.note.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(e.note,
                                  style: const TextStyle(
                                      color: MaritimeColors.textPrimary)),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
