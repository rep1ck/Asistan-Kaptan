import 'package:flutter/material.dart';
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
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          MapScreen(),
          WeatherScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF121A2A),
        indicatorColor: const Color(0xFF1B9AAA),
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.navigation), label: 'Seyir'),
          NavigationDestination(icon: Icon(Icons.cloud), label: 'Hava'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Ayar'),
        ],
      ),
    );
  }
}
