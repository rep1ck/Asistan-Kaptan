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
    final night =
        Theme.of(context).colorScheme.primary == MaritimeColors.nightRed;
    final pages = <Widget>[
      const MapScreen(),
      const WeatherScreen(),
      const PortsScreen(),
      const LogbookScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient:
              night ? MaritimeGradients.nightHud : MaritimeGradients.hudBar,
          border: Border(
            top: BorderSide(
              color: night
                  ? MaritimeColors.nightBorder
                  : MaritimeColors.border.withOpacity(0.8),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: (night ? MaritimeColors.nightRed : MaritimeColors.cyan)
                  .withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: [
            _dest(Icons.navigation_outlined, Icons.navigation, 'Seyir', night),
            _dest(Icons.waves_outlined, Icons.waves, 'Hava', night),
            _dest(Icons.place_outlined, Icons.place, 'Liman', night),
            _dest(Icons.menu_book_outlined, Icons.menu_book, 'Defter', night),
            _dest(Icons.tune_outlined, Icons.tune, 'Ayar', night),
          ],
        ),
      ),
    );
  }

  NavigationDestination _dest(
      IconData icon, IconData selected, String label, bool night) {
    final accent = night ? MaritimeColors.nightRed : MaritimeColors.cyan;
    return NavigationDestination(
      icon: Icon(icon,
          color: night ? MaritimeColors.nightMuted : MaritimeColors.textMuted),
      selectedIcon: Icon(selected, color: accent),
      label: label,
    );
  }
}
