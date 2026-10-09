import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedPlan {
  final String name;
  final List<List<double>> waypoints;
  final DateTime savedAt;

  SavedPlan({
    required this.name,
    required this.waypoints,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'waypoints': waypoints,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedPlan.fromJson(Map<String, dynamic> j) => SavedPlan(
        name: j['name'] as String? ?? 'Plan',
        waypoints: (j['waypoints'] as List? ?? [])
            .map((e) => (e as List).map((x) => (x as num).toDouble()).toList())
            .toList(),
        savedAt: DateTime.tryParse(j['savedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

enum AisFilterMode { all, near, danger }

class SettingsStore {
  Future<SharedPreferences> get _p async => SharedPreferences.getInstance();

  Future<double> getCpaNm() async => (await _p).getDouble('cpa_nm') ?? 0.5;
  Future<void> setCpaNm(double v) async => (await _p).setDouble('cpa_nm', v);

  Future<double> getTcpaMin() async => (await _p).getDouble('tcpa_min') ?? 15;
  Future<void> setTcpaMin(double v) async =>
      (await _p).setDouble('tcpa_min', v);

  Future<double> getDraftM() async => (await _p).getDouble('draft_m') ?? 8.0;
  Future<void> setDraftM(double v) async => (await _p).setDouble('draft_m', v);

  Future<double> getCruiseKn() async =>
      (await _p).getDouble('cruise_kn') ?? 12.0;
  Future<void> setCruiseKn(double v) async =>
      (await _p).setDouble('cruise_kn', v);

  Future<String> getAisApiKey() async =>
      (await _p).getString('ais_api_key') ?? '';
  Future<void> setAisApiKey(String v) async =>
      (await _p).setString('ais_api_key', v.trim());

  Future<double> getAnchorRadiusNm() async =>
      (await _p).getDouble('anchor_radius_nm') ?? 0.10;
  Future<void> setAnchorRadiusNm(double v) async =>
      (await _p).setDouble('anchor_radius_nm', v);

  Future<AisFilterMode> getAisFilter() async {
    final i = (await _p).getInt('ais_filter') ?? 0;
    if (i == 1) return AisFilterMode.near;
    if (i == 2) return AisFilterMode.danger;
    return AisFilterMode.all;
  }

  Future<void> setAisFilter(AisFilterMode m) async {
    final i = m == AisFilterMode.near
        ? 1
        : m == AisFilterMode.danger
            ? 2
            : 0;
    await (await _p).setInt('ais_filter', i);
  }

  Future<double> getAisRangeNm() async =>
      (await _p).getDouble('ais_range_nm') ?? 5.0;
  Future<void> setAisRangeNm(double v) async =>
      (await _p).setDouble('ais_range_nm', v);

  Future<bool> getNightMode() async =>
      (await _p).getBool('night_mode') ?? false;
  Future<void> setNightMode(bool v) async =>
      (await _p).setBool('night_mode', v);

  Future<bool> getKeepAwake() async =>
      (await _p).getBool('keep_awake') ?? true;
  Future<void> setKeepAwake(bool v) async =>
      (await _p).setBool('keep_awake', v);

  Future<bool> getRangeRings() async =>
      (await _p).getBool('range_rings') ?? true;
  Future<void> setRangeRings(bool v) async =>
      (await _p).setBool('range_rings', v);

  Future<double> getFuelLPerNm() async =>
      (await _p).getDouble('fuel_l_per_nm') ?? 20.0;
  Future<void> setFuelLPerNm(double v) async =>
      (await _p).setDouble('fuel_l_per_nm', v);

  Future<double> getLoaM() async => (await _p).getDouble('loa_m') ?? 120.0;
  Future<void> setLoaM(double v) async => (await _p).setDouble('loa_m', v);

  Future<double> getBeamM() async => (await _p).getDouble('beam_m') ?? 20.0;
  Future<void> setBeamM(double v) async => (await _p).setDouble('beam_m', v);

  Future<List<SavedPlan>> getPlans() async {
    final raw = (await _p).getString('saved_plans');
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => SavedPlan.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePlan(SavedPlan plan) async {
    final plans = await getPlans();
    plans.removeWhere((p) => p.name == plan.name);
    plans.insert(0, plan);
    while (plans.length > 30) {
      plans.removeLast();
    }
    await (await _p).setString(
      'saved_plans',
      jsonEncode(plans.map((p) => p.toJson()).toList()),
    );
  }

  Future<void> deletePlan(String name) async {
    final plans = await getPlans();
    plans.removeWhere((p) => p.name == name);
    await (await _p).setString(
      'saved_plans',
      jsonEncode(plans.map((p) => p.toJson()).toList()),
    );
  }
}
