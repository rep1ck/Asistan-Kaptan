import 'package:flutter/material.dart';
import '../core/maritime_theme.dart';
import '../widgets/nautical_icons.dart';
import 'map_screen.dart';
import 'weather_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const MapScreen(),
      const WeatherScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: MaritimeColors.surfaceDark,
          indicatorColor: MaritimeColors.cyan.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: MaritimeColors.cyan,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              );
            }
            return const TextStyle(
              color: MaritimeColors.textMuted,
              fontSize: 12,
            );
          }),
        ),
        child: NavigationBar(
          backgroundColor: MaritimeColors.surfaceDark,
          indicatorColor: MaritimeColors.cyan.withOpacity(0.15),
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: [
            NavigationDestination(
              icon: CompassIcon(size: 26, color: MaritimeColors.textMuted),
              selectedIcon: CompassIcon(size: 26, color: MaritimeColors.cyan),
              label: 'Seyir',
            ),
            NavigationDestination(
              icon: Icon(Icons.waves_outlined, color: MaritimeColors.textMuted, size: 26),
              selectedIcon: const Icon(Icons.waves, color: MaritimeColors.cyan, size: 26),
              label: 'Hava',
            ),
            NavigationDestination(
              icon: AnchorIcon(size: 26, color: MaritimeColors.textMuted),
              selectedIcon: AnchorIcon(size: 26, color: MaritimeColors.cyan),
              label: 'Ayar',
            ),
          ],
        ),
      ),
    );
  }
}
