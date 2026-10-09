import 'package:flutter/material.dart';
import '../core/maritime_theme.dart';
import 'map_screen.dart';
import 'weather_screen.dart';
import 'ports_screen.dart';
import 'logbook_screen.dart';
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
      const PortsScreen(),
      const LogbookScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).navigationBarTheme.backgroundColor,
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.navigation_outlined),
            selectedIcon: Icon(Icons.navigation, color: MaritimeColors.cyan),
            label: 'Seyir',
          ),
          NavigationDestination(
            icon: Icon(Icons.waves_outlined),
            selectedIcon: Icon(Icons.waves, color: MaritimeColors.cyan),
            label: 'Hava',
          ),
          NavigationDestination(
            icon: Icon(Icons.place_outlined),
            selectedIcon: Icon(Icons.place, color: MaritimeColors.cyan),
            label: 'Liman',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: MaritimeColors.cyan),
            label: 'Defter',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune, color: MaritimeColors.cyan),
            label: 'Ayar',
          ),
        ],
      ),
    );
  }
}
