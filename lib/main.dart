import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/maritime_theme.dart';
import 'screens/home_shell.dart';
import 'services/settings_store.dart';

final nightModeProvider = StateProvider<bool>((ref) => false);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: MaritimeColors.deepOcean,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  } catch (_) {}
  runApp(const ProviderScope(child: KaptanApp()));
}

class KaptanApp extends ConsumerStatefulWidget {
  const KaptanApp({super.key});

  @override
  ConsumerState<KaptanApp> createState() => _KaptanAppState();
}

class _KaptanAppState extends ConsumerState<KaptanApp> {
  @override
  void initState() {
    super.initState();
    SettingsStore().getNightMode().then((v) {
      if (mounted) ref.read(nightModeProvider.notifier).state = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    final night = ref.watch(nightModeProvider);
    return MaterialApp(
      title: 'Kaptan Asistani',
      debugShowCheckedModeBanner: false,
      theme: night ? MaritimeTheme.night : MaritimeTheme.dark,
      home: const HomeShell(),
    );
  }
}
