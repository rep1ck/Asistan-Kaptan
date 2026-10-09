import 'package:flutter/material.dart';

/// Kaptan Asistanı — köprü konsolu görsel sistemi
class MaritimeColors {
  static const abyss = Color(0xFF020B12);
  static const deepOcean = Color(0xFF06141F);
  static const oceanBlue = Color(0xFF0A1E32);
  static const midnightSea = Color(0xFF0F2A45);
  static const surfaceDark = Color(0xFF122C42);
  static const surfaceMid = Color(0xFF173851);
  static const surfaceLight = Color(0xFF1E4A68);

  static const cyan = Color(0xFF3DE8F0);
  static const cyanDim = Color(0xFF1A9AA3);
  static const cyanGlow = Color(0x663DE8F0);
  static const teal = Color(0xFF2DD4BF);
  static const amber = Color(0xFFFFB020);
  static const gold = Color(0xFFE8C547);
  static const coral = Color(0xFFFF6B6B);
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFFB020);
  static const danger = Color(0xFFFF4757);
  static const info = Color(0xFF3DE8F0);

  static const textPrimary = Color(0xFFF0FAFC);
  static const textSecondary = Color(0xFF9BC4D8);
  static const textMuted = Color(0xFF5E8AA0);

  static const border = Color(0xFF234B68);
  static const borderLight = Color(0xFF2F6488);
  static const borderGlow = Color(0x553DE8F0);

  static const nightBg = Color(0xFF0C0202);
  static const nightSurface = Color(0xFF1A0808);
  static const nightRed = Color(0xFFFF3B3B);
  static const nightDim = Color(0xFFB82828);
  static const nightText = Color(0xFFFFD0D0);
  static const nightMuted = Color(0xFF8A5050);
  static const nightBorder = Color(0xFF4A1818);
}

class MaritimeGradients {
  static const oceanDeck = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF06141F),
      Color(0xFF0A1E32),
      Color(0xFF06141F),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xE6152E44),
      Color(0xCC0A1E32),
      Color(0xE6122C42),
    ],
  );

  static const cardGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF01A3A55),
      Color(0xE00C2238),
    ],
  );

  static const hudBar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xF00A1E32),
      Color(0xE806141F),
    ],
  );

  static const accentLine = LinearGradient(
    colors: [
      Color(0x003DE8F0),
      Color(0xFF3DE8F0),
      Color(0x003DE8F0),
    ],
  );

  static const nightCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF0220A0A),
      Color(0xE00C0202),
    ],
  );

  static const nightHud = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xF01A0808),
      Color(0xE00C0202),
    ],
  );
}

class MaritimeTheme {
  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );
    return base.copyWith(
      scaffoldBackgroundColor: MaritimeColors.deepOcean,
      colorScheme: const ColorScheme.dark(
        primary: MaritimeColors.cyan,
        secondary: MaritimeColors.teal,
        tertiary: MaritimeColors.amber,
        surface: MaritimeColors.surfaceDark,
        error: MaritimeColors.danger,
        onPrimary: MaritimeColors.abyss,
        onSecondary: MaritimeColors.abyss,
        onSurface: MaritimeColors.textPrimary,
        onError: MaritimeColors.textPrimary,
        outline: MaritimeColors.border,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: MaritimeColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
        ),
        iconTheme: IconThemeData(color: MaritimeColors.cyan, size: 22),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MaritimeColors.surfaceDark,
        elevation: 0,
        height: 68,
        indicatorColor: MaritimeColors.cyan.withOpacity(0.18),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: selected ? MaritimeColors.cyan : MaritimeColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? MaritimeColors.cyan : MaritimeColors.textMuted,
          );
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: MaritimeColors.cyan,
        inactiveTrackColor: MaritimeColors.surfaceLight,
        thumbColor: MaritimeColors.cyan,
        overlayColor: MaritimeColors.cyanGlow,
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) {
          return s.contains(WidgetState.selected)
              ? MaritimeColors.cyan
              : MaritimeColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((s) {
          return s.contains(WidgetState.selected)
              ? MaritimeColors.cyan.withOpacity(0.35)
              : MaritimeColors.surfaceLight;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          return s.contains(WidgetState.selected)
              ? MaritimeColors.cyan
              : MaritimeColors.textMuted;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: MaritimeColors.border,
        thickness: 1,
        space: 28,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MaritimeColors.surfaceMid,
        contentTextStyle: const TextStyle(
          color: MaritimeColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: MaritimeColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: MaritimeColors.border),
        ),
        titleTextStyle: const TextStyle(
          color: MaritimeColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MaritimeColors.surfaceDark,
        modalBackgroundColor: MaritimeColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MaritimeColors.oceanBlue,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MaritimeColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MaritimeColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MaritimeColors.cyan, width: 1.5),
        ),
        labelStyle: const TextStyle(color: MaritimeColors.textMuted),
        hintStyle: const TextStyle(color: MaritimeColors.textMuted),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: MaritimeColors.textPrimary),
        bodyMedium: TextStyle(color: MaritimeColors.textPrimary),
        bodySmall: TextStyle(color: MaritimeColors.textSecondary),
        titleLarge: TextStyle(
          color: MaritimeColors.textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
        labelLarge: TextStyle(
          color: MaritimeColors.cyan,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  static ThemeData get night {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );
    return base.copyWith(
      scaffoldBackgroundColor: MaritimeColors.nightBg,
      colorScheme: const ColorScheme.dark(
        primary: MaritimeColors.nightRed,
        secondary: MaritimeColors.nightDim,
        surface: MaritimeColors.nightSurface,
        error: MaritimeColors.nightRed,
        onPrimary: Colors.black,
        onSurface: MaritimeColors.nightText,
        outline: MaritimeColors.nightBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: MaritimeColors.nightText,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
        ),
        iconTheme: IconThemeData(color: MaritimeColors.nightRed),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MaritimeColors.nightSurface,
        elevation: 0,
        height: 68,
        indicatorColor: MaritimeColors.nightRed.withOpacity(0.22),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color:
                selected ? MaritimeColors.nightRed : MaritimeColors.nightMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected
                ? MaritimeColors.nightRed
                : MaritimeColors.nightMuted,
          );
        }),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: MaritimeColors.nightRed,
        inactiveTrackColor: MaritimeColors.nightSurface,
        thumbColor: MaritimeColors.nightRed,
        trackHeight: 3,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(MaritimeColors.nightRed),
        trackColor: WidgetStateProperty.resolveWith((s) {
          return s.contains(WidgetState.selected)
              ? MaritimeColors.nightRed.withOpacity(0.35)
              : MaritimeColors.nightBorder;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: MaritimeColors.nightBorder,
        thickness: 1,
        space: 28,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MaritimeColors.nightSurface,
        contentTextStyle: const TextStyle(
          color: MaritimeColors.nightText,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: MaritimeColors.nightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: MaritimeColors.nightBorder),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: MaritimeColors.nightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}

/// Cam / HUD kart kabuğu
class BridgeGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool glow;
  final bool night;

  const BridgeGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    this.glow = false,
    this.night = false,
  });

  @override
  Widget build(BuildContext context) {
    final isNight = night ||
        Theme.of(context).colorScheme.primary == MaritimeColors.nightRed;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient:
            isNight ? MaritimeGradients.nightCard : MaritimeGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNight
              ? MaritimeColors.nightBorder
              : (glow ? MaritimeColors.borderGlow : MaritimeColors.border),
          width: glow ? 1.2 : 1,
        ),
        boxShadow: [
          if (glow && !isNight)
            BoxShadow(
              color: MaritimeColors.cyan.withOpacity(0.12),
              blurRadius: 16,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class BridgeAccentBar extends StatelessWidget {
  const BridgeAccentBar({super.key});

  @override
  Widget build(BuildContext context) {
    final night =
        Theme.of(context).colorScheme.primary == MaritimeColors.nightRed;
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: night
              ? [
                  Colors.transparent,
                  MaritimeColors.nightRed.withOpacity(0.7),
                  Colors.transparent,
                ]
              : [
                  Colors.transparent,
                  MaritimeColors.cyan.withOpacity(0.7),
                  Colors.transparent,
                ],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class BridgeSectionTitle extends StatelessWidget {
  final String text;
  final IconData? icon;

  const BridgeSectionTitle(this.text, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    final night =
        Theme.of(context).colorScheme.primary == MaritimeColors.nightRed;
    final c = night ? MaritimeColors.nightRed : MaritimeColors.cyan;
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: c, size: 16),
          const SizedBox(width: 8),
        ],
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 2.2,
            color: c,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.withOpacity(0.5), c.withOpacity(0.0)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
