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
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: MaritimeColors.cyan)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('GEMI AYARLARI')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Gemi ayarları bölümü
          _sectionHeader('TICARI GEMI', Icons.directions_boat),
          const SizedBox(height: 12),
          _sliderCard(
            icon: Icons.speed,
            label: 'Sefer hizi (cruise)',
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
            label: 'Taslak (draft)',
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
          // CPA / TCPA bölümü
          _sectionHeader('CPA / TCPA ESIKLERI', Icons.warning_amber),
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
            unit: ' dk',
            format: (v) => v.toStringAsFixed(0),
            onChanged: (v) async {
              setState(() => tcpa = v);
              await store.setTcpaMin(v);
            },
          ),
          const Divider(),
          // Sürüm kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: MaritimeGradients.cardGradient,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: MaritimeColors.border),
            ),
            child: Row(
              children: [
                const HelmIcon(size: 32, color: MaritimeColors.cyan),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Surum',
                        style: TextStyle(
                          fontSize: 12,
                          color: MaritimeColors.textMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '1.0.1 MVP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: MaritimeColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: MaritimeColors.cyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ANDROID',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: MaritimeColors.cyan,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Uyarı kartı
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
                    'Yardimci seyir aracidir. Resmi ENC / ECDIS yerine gecmez.',
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
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MaritimeColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${format(value)}$unit',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: MaritimeColors.cyan,
                ),
              ),
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
