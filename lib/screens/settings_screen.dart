import 'package:flutter/material.dart';
import '../services/settings_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final store = SettingsStore();
  double cpa = 0.5;
  double tcpa = 15;
  double draft = 8;
  double cruise = 12;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    cpa = await store.getCpaNm();
    tcpa = await store.getTcpaMin();
    draft = await store.getDraftM();
    cruise = await store.getCruiseKn();
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Gemi / Alarm Ayarlari')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('TICARI GEMI', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5CE1E6))),
          const SizedBox(height: 8),
          Text('Sefer hizi (cruise): ${cruise.toStringAsFixed(0)} kn'),
          Slider(
            value: cruise,
            min: 6,
            max: 25,
            divisions: 19,
            label: '${cruise.round()} kn',
            onChanged: (v) async {
              setState(() => cruise = v);
              await store.setCruiseKn(v);
            },
          ),
          Text('Taslak (draft): ${draft.toStringAsFixed(1)} m'),
          Slider(
            value: draft,
            min: 2,
            max: 20,
            divisions: 36,
            label: '${draft.toStringAsFixed(1)} m',
            onChanged: (v) async {
              setState(() => draft = v);
              await store.setDraftM(v);
            },
          ),
          const Divider(height: 32),
          const Text('CPA / TCPA ESİKLERI', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5CE1E6))),
          const SizedBox(height: 4),
          Text('CPA: ${cpa.toStringAsFixed(2)} NM'),
          Slider(
            value: cpa,
            min: 0.1,
            max: 3.0,
            divisions: 29,
            onChanged: (v) async {
              setState(() => cpa = v);
              await store.setCpaNm(v);
            },
          ),
          Text('TCPA: ${tcpa.toStringAsFixed(0)} dk'),
          Slider(
            value: tcpa,
            min: 5,
            max: 60,
            divisions: 11,
            onChanged: (v) async {
              setState(() => tcpa = v);
              await store.setTcpaMin(v);
            },
          ),
          const Divider(height: 32),
          const ListTile(
            title: Text('Surum'),
            trailing: Text('1.0.0 MVP'),
          ),
          ListTile(
            title: const Text('Uyari'),
            subtitle: Text(
              'Yardimci seyir aracidir. Resmi ENC, ECDIS ve koltuk prosedurunun yerine gecmez.',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
