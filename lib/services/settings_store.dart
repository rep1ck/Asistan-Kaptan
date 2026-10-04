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

class SettingsStore {
  Future<SharedPreferences> get _p async => SharedPreferences.getInstance();

  Future<double> getCpaNm() async => (await _p).getDouble('cpa_nm') ?? 0.5;
  Future<void> setCpaNm(double v) async => (await _p).setDouble('cpa_nm', v);

  Future<double> getTcpaMin() async => (await _p).getDouble('tcpa_min') ?? 15;
  Future<void> setTcpaMin(double v) async => (await _p).setDouble('tcpa_min', v);

  Future<double> getDraftM() async => (await _p).getDouble('draft_m') ?? 8.0;
  Future<void> setDraftM(double v) async => (await _p).setDouble('draft_m', v);

  Future<double> getCruiseKn() async => (await _p).getDouble('cruise_kn') ?? 12.0;
  Future<void> setCruiseKn(double v) async => (await _p).setDouble('cruise_kn', v);

  Future<String> getAisApiKey() async =>
      (await _p).getString('ais_api_key') ?? '';
  Future<void> setAisApiKey(String v) async =>
      (await _p).setString('ais_api_key', v.trim());

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
    final prefs = await _p;
    await prefs.setString(
      'saved_plans',
      jsonEncode(plans.map((p) => p.toJson()).toList()),
    );
  }

  Future<void> deletePlan(String name) async {
    final plans = await getPlans();
    plans.removeWhere((p) => p.name == name);
    final prefs = await _p;
    await prefs.setString(
      'saved_plans',
      jsonEncode(plans.map((p) => p.toJson()).toList()),
    );
  }
}
