import 'package:flutter/material.dart';
import '../core/maritime_theme.dart';
import '../services/settings_store.dart';
import '../widgets/nautical_icons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final store = SettingsStore();
  final aisCtrl = TextEditingController();
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

  @override
  void dispose() {
    aisCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    cpa = await store.getCpaNm();
    tcpa = await store.getTcpaMin();
    draft = await store.getDraftM();
    cruise = await store.getCruiseKn();
    aisCtrl.text = await store.getAisApiKey();
    if (mounted) setState(() => loading = false);
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
      appBar: AppBar(title: const Text('SHIP SETTINGS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('COMMERCIAL SHIP', Icons.directions_boat),
          const SizedBox(height: 12),
          _sliderCard(
            icon: Icons.speed,
            label: 'Cruise speed',
            value: cruise,
            min: 6,
            max: 25,
            divisions: 19,
            unit: ' kn',
            format: (v) => v.toStringAsFixed(0),
            onChanged: (v) async {
              setState(() => cruise = v);
              await store.setCruiseKn(v);
            },
          ),
          const SizedBox(height: 12),
          _sliderCard(
            icon: Icons.water,
            label: 'Draft',
            value: draft,
            min: 2,
            max: 20,
            divisions: 36,
            unit: ' m',
            format: (v) => v.toStringAsFixed(1),
            onChanged: (v) async {
              setState(() => draft = v);
              await store.setDraftM(v);
            },
          ),
          const Divider(),
          _sectionHeader('CPA / TCPA', Icons.warning_amber),
          const SizedBox(height: 12),
          _sliderCard(
            icon: Icons.social_distance,
            label: 'CPA',
            value: cpa,
            min: 0.1,
            max: 3.0,
            divisions: 29,
            unit: ' NM',
            format: (v) => v.toStringAsFixed(2),
            onChanged: (v) async {
              setState(() => cpa = v);
              await store.setCpaNm(v);
            },
          ),
          const SizedBox(height: 12),
          _sliderCard(
            icon: Icons.timer,
            label: 'TCPA',
            value: tcpa,
            min: 5,
            max: 60,
            divisions: 11,
            unit: ' min',
            format: (v) => v.toStringAsFixed(0),
            onChanged: (v) async {
              setState(() => tcpa = v);
              await store.setTcpaMin(v);
            },
          ),
          const Divider(),
          _sectionHeader('AIS (LIVE SHIPS)', Icons.radar),
          const SizedBox(height: 8),
          const Text(
            'Free API key from aisstream.io (GitHub login). '
            'Then enable AIS in Map → Layers menu.',
            style: TextStyle(fontSize: 12, color: MaritimeColors.textMuted),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: aisCtrl,
            obscureText: true,
            style: const TextStyle(color: MaritimeColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'AIS API key',
              labelStyle: const TextStyle(color: MaritimeColors.textMuted),
              filled: true,
              fillColor: MaritimeColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: MaritimeColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: MaritimeColors.border),
              ),
            ),
            onChanged: (v) => store.setAisApiKey(v),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: MaritimeGradients.cardGradient,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: MaritimeColors.border),
            ),
            child: const Row(
              children: [
                HelmIcon(size: 32, color: MaritimeColors.cyan),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Version',
                          style: TextStyle(
                              fontSize: 12, color: MaritimeColors.textMuted)),
                      Text('1.0.3 AIS',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: MaritimeColors.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: MaritimeColors.cyan, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 1.5,
            color: MaritimeColors.cyan,
          ),
        ),
      ],
    );
  }

  Widget _sliderCard({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required String Function(double) format,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: MaritimeGradients.cardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MaritimeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: MaritimeColors.cyan, size: 20),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: MaritimeColors.textPrimary)),
              const Spacer(),
              Text('${format(value)}$unit',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: MaritimeColors.cyan)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
