import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/maritime_theme.dart';
import '../main.dart' show nightModeProvider;
import '../services/settings_store.dart';
import '../widgets/nautical_icons.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final store = SettingsStore();
  final aisCtrl = TextEditingController();
  double cpa = 0.5, tcpa = 15, draft = 8, cruise = 12;
  double anchorR = 0.10, aisRange = 5, fuel = 20, loa = 120, beam = 20;
  AisFilterMode aisFilter = AisFilterMode.all;
  bool night = false, keepAwake = true, rings = true, loading = true;

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
    anchorR = await store.getAnchorRadiusNm();
    aisRange = await store.getAisRangeNm();
    aisFilter = await store.getAisFilter();
    night = await store.getNightMode();
    keepAwake = await store.getKeepAwake();
    rings = await store.getRangeRings();
    fuel = await store.getFuelLPerNm();
    loa = await store.getLoaM();
    beam = await store.getBeamM();
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
      appBar: AppBar(title: const Text('GEMİ AYARLARI')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _h('EKRAN', Icons.display_settings),
          SwitchListTile(
            title: const Text('Gece modu (kırmızı köprü)',
                style: TextStyle(color: MaritimeColors.textPrimary)),
            value: night,
            activeColor: MaritimeColors.cyan,
            onChanged: (v) async {
              setState(() => night = v);
              await store.setNightMode(v);
              ref.read(nightModeProvider.notifier).state = v;
            },
          ),
          SwitchListTile(
            title: const Text('Ekranı açık tut',
                style: TextStyle(color: MaritimeColors.textPrimary)),
            value: keepAwake,
            activeColor: MaritimeColors.cyan,
            onChanged: (v) async {
              setState(() => keepAwake = v);
              await store.setKeepAwake(v);
            },
          ),
          SwitchListTile(
            title: const Text('Mesafe halkaları',
                style: TextStyle(color: MaritimeColors.textPrimary)),
            subtitle: const Text('0.5 / 1 / 2 / 5 NM',
                style:
                    TextStyle(color: MaritimeColors.textMuted, fontSize: 12)),
            value: rings,
            activeColor: MaritimeColors.cyan,
            onChanged: (v) async {
              setState(() => rings = v);
              await store.setRangeRings(v);
            },
          ),
          const Divider(),
          _h('TİCARİ GEMİ', Icons.directions_boat),
          _sl('Seyir hızı', cruise, 6, 25, 19, ' kn', (v) => v.toStringAsFixed(0),
              (v) async {
            setState(() => cruise = v);
            await store.setCruiseKn(v);
          }),
          _sl('Draft', draft, 2, 20, 36, ' m', (v) => v.toStringAsFixed(1),
              (v) async {
            setState(() => draft = v);
            await store.setDraftM(v);
          }),
          _sl('LOA (boy)', loa, 20, 400, 38, ' m', (v) => v.toStringAsFixed(0),
              (v) async {
            setState(() => loa = v);
            await store.setLoaM(v);
          }),
          _sl('Beam (genişlik)', beam, 5, 60, 55, ' m',
              (v) => v.toStringAsFixed(0), (v) async {
            setState(() => beam = v);
            await store.setBeamM(v);
          }),
          _sl('Yakıt', fuel, 5, 80, 15, ' L/NM', (v) => v.toStringAsFixed(0),
              (v) async {
            setState(() => fuel = v);
            await store.setFuelLPerNm(v);
          }),
          const Divider(),
          _h('ÇAPA NÖBETİ', Icons.anchor),
          _sl('Alarm yarıçapı', anchorR, 0.05, 0.5, 9, ' NM',
              (v) => v.toStringAsFixed(2), (v) async {
            setState(() => anchorR = v);
            await store.setAnchorRadiusNm(v);
          }),
          const Divider(),
          _h('CPA / TCPA', Icons.warning_amber),
          _sl('CPA eşiği', cpa, 0.1, 3, 29, ' NM', (v) => v.toStringAsFixed(2),
              (v) async {
            setState(() => cpa = v);
            await store.setCpaNm(v);
          }),
          _sl('TCPA eşiği', tcpa, 5, 60, 11, ' dk', (v) => v.toStringAsFixed(0),
              (v) async {
            setState(() => tcpa = v);
            await store.setTcpaMin(v);
          }),
          const Divider(),
          _h('AIS FİLTRE', Icons.filter_alt),
          for (final e in [
            (AisFilterMode.all, 'Tümü'),
            (AisFilterMode.near, 'Yakın'),
            (AisFilterMode.danger, 'Tehlikeli'),
          ])
            RadioListTile<AisFilterMode>(
              dense: true,
              title: Text(e.$2,
                  style: const TextStyle(color: MaritimeColors.textPrimary)),
              value: e.$1,
              groupValue: aisFilter,
              activeColor: MaritimeColors.cyan,
              onChanged: (v) async {
                if (v == null) return;
                setState(() => aisFilter = v);
                await store.setAisFilter(v);
              },
            ),
          _sl('Yakın mesafe', aisRange, 1, 20, 19, ' NM',
              (v) => v.toStringAsFixed(0), (v) async {
            setState(() => aisRange = v);
            await store.setAisRangeNm(v);
          }),
          const Divider(),
          _h('AIS API', Icons.radar),
          TextField(
            controller: aisCtrl,
            obscureText: true,
            style: const TextStyle(color: MaritimeColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'AIS API anahtarı (aisstream.io)',
              labelStyle: const TextStyle(color: MaritimeColors.textMuted),
              filled: true,
              fillColor: MaritimeColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
            child: const Row(children: [
              HelmIcon(size: 32, color: MaritimeColors.cyan),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sürüm',
                        style: TextStyle(
                            fontSize: 12, color: MaritimeColors.textMuted)),
                    Text('1.3.0 Final',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: MaritimeColors.textPrimary)),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _h(String t, IconData i) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Row(children: [
          Icon(i, color: MaritimeColors.cyan, size: 18),
          const SizedBox(width: 8),
          Text(t,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1.2,
                  color: MaritimeColors.cyan)),
        ]),
      );

  Widget _sl(
    String label,
    double value,
    double min,
    double max,
    int div,
    String unit,
    String Function(double) fmt,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: MaritimeGradients.cardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MaritimeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MaritimeColors.textPrimary)),
            const Spacer(),
            Text('${fmt(value)}$unit',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: MaritimeColors.cyan)),
          ]),
          Slider(
              value: value,
              min: min,
              max: max,
              divisions: div,
              onChanged: onChanged),
        ],
      ),
    );
  }
}
