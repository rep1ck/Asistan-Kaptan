import 'package:flutter/material.dart';

/// Denizcilik renk paleti - derin deniz mavisi ve okyanus tonları
class MaritimeColors {
  // Ana tonlar - derin deniz
  static const deepOcean = Color(0xFF06141F);
  static const oceanBlue = Color(0xFF0B1F33);
  static const midnightSea = Color(0xFF0F2A45);
  static const surfaceDark = Color(0xFF132C44);
  static const surfaceLight = Color(0xFF1A3A5C);

  // Aksan renkleri
  static const cyan = Color(0xFF2DD4Df);
  static const teal = Color(0xFF14B8A6);
  static const amber = Color(0xFFF59E0B);
  static const coral = Color(0xFFEF6F6F);
  static const gold = Color(0xFFD4A934);

  // Fonksiyonel
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF2DD4DF);

  // Metin
  static const textPrimary = Color(0xFFE8F4F8);
  static const textSecondary = Color(0xFF8BAEC4);
  static const textMuted = Color(0xFF5A7A92);

  // Hatlar / kenarlıklar
  static const border = Color(0xFF1E4060);
  static const borderLight = Color(0xFF2A5275);
}

/// Denizcilik gradyanları
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

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [MaritimeColors.cyan, MaritimeColors.teal],
  );

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [MaritimeColors.midnightSea, MaritimeColors.surfaceDark],
  );
}

/// Denizcilik teması
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
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: MaritimeColors.surfaceDark,
        indicatorColor: MaritimeColors.cyan,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: MaritimeColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: MaritimeColors.border, width: 1),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: MaritimeColors.cyan,
        inactiveTrackColor: MaritimeColors.surfaceLight,
        thumbColor: MaritimeColors.cyan,
        overlayColor: Color(0x332DD4DF),
        valueIndicatorColor: MaritimeColors.midnightSea,
      ),
      dividerTheme: const DividerThemeData(
        color: MaritimeColors.border,
        thickness: 1,
        space: 32,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: MaritimeColors.textPrimary),
        bodyMedium: TextStyle(color: MaritimeColors.textSecondary),
        bodySmall: TextStyle(color: MaritimeColors.textMuted),
        titleLarge: TextStyle(
          color: MaritimeColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: MaritimeColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
