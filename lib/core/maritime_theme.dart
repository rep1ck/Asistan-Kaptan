import 'package:flutter/material.dart';

class MaritimeColors {
  static const deepOcean = Color(0xFF06141F);
  static const oceanBlue = Color(0xFF0B1F33);
  static const midnightSea = Color(0xFF0F2A45);
  static const surfaceDark = Color(0xFF132C44);
  static const surfaceLight = Color(0xFF1A3A5C);
  static const cyan = Color(0xFF2DD4DF);
  static const teal = Color(0xFF14B8A6);
  static const amber = Color(0xFFF59E0B);
  static const coral = Color(0xFFEF6F6F);
  static const gold = Color(0xFFD4A934);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF2DD4DF);
  static const textPrimary = Color(0xFFE8F4F8);
  static const textSecondary = Color(0xFF8BAEC4);
  static const textMuted = Color(0xFF5A7A92);
  static const border = Color(0xFF1E4060);
  static const borderLight = Color(0xFF2A5275);
  static const nightBg = Color(0xFF1A0505);
  static const nightSurface = Color(0xFF2A0A0A);
  static const nightRed = Color(0xFFFF4444);
  static const nightDim = Color(0xFFAA3333);
  static const nightText = Color(0xFFFFCCCC);
  static const nightMuted = Color(0xFF996666);
}

class MaritimeGradients {
  static const oceanDeck = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [MaritimeColors.deepOcean, MaritimeColors.oceanBlue],
  );
  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [MaritimeColors.surfaceDark, MaritimeColors.oceanBlue],
  );
  static const nightCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [MaritimeColors.nightSurface, MaritimeColors.nightBg],
  );
}

class MaritimeTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: MaritimeColors.deepOcean,
      colorScheme: const ColorScheme.dark(
        primary: MaritimeColors.cyan,
        secondary: MaritimeColors.teal,
        surface: MaritimeColors.surfaceDark,
        error: MaritimeColors.danger,
        onPrimary: MaritimeColors.deepOcean,
        onSurface: MaritimeColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: MaritimeColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: MaritimeColors.cyan),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MaritimeColors.surfaceDark,
        indicatorColor: MaritimeColors.cyan.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: MaritimeColors.cyan,
        inactiveTrackColor: MaritimeColors.surfaceLight,
        thumbColor: MaritimeColors.cyan,
        overlayColor: Color(0x332DD4DF),
      ),
      dividerTheme: const DividerThemeData(
        color: MaritimeColors.border,
        thickness: 1,
        space: 32,
      ),
    );
  }

  static ThemeData get night {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: MaritimeColors.nightBg,
      colorScheme: const ColorScheme.dark(
        primary: MaritimeColors.nightRed,
        secondary: MaritimeColors.nightDim,
        surface: MaritimeColors.nightSurface,
        error: MaritimeColors.nightRed,
        onPrimary: Colors.black,
        onSurface: MaritimeColors.nightText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: MaritimeColors.nightText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: MaritimeColors.nightRed),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MaritimeColors.nightSurface,
        indicatorColor: MaritimeColors.nightRed.withOpacity(0.25),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: MaritimeColors.nightRed,
        inactiveTrackColor: MaritimeColors.nightSurface,
        thumbColor: MaritimeColors.nightRed,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF4A1515),
        thickness: 1,
        space: 32,
      ),
    );
  }
}
