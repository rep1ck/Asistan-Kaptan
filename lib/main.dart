import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/maritime_theme.dart';
import 'screens/home_shell.dart';

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

class KaptanApp extends StatelessWidget {
  const KaptanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaptan Asistani',
      debugShowCheckedModeBanner: false,
      theme: MaritimeTheme.dark,
      home: const HomeShell(),
    );
  }
}
