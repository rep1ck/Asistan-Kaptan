import 'package:shared_preferences/shared_preferences.dart';

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
}
