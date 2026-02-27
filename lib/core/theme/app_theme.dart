import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Seed color: warm coral-rose
const _seedColor = Color(0xFFE8654E);

class AppTheme {
  // ── Light ──────────────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = FlexThemeData.light(
      colors: FlexSchemeColor.from(primary: _seedColor),
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 8,
      subThemesData: _subThemes,
      keyColors: FlexKeyColors(useSecondary: true, useTertiary: true),
      tones: FlexTones.chroma(Brightness.light),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    );

    return base.copyWith(
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
      ),
      listTileTheme: base.listTileTheme.copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      chipTheme: base.chipTheme.copyWith(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── Dark ───────────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final base = FlexThemeData.dark(
      colors: FlexSchemeColor.from(primary: _seedColor),
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 15,
      subThemesData: _subThemes,
      keyColors: FlexKeyColors(useSecondary: true, useTertiary: true),
      tones: FlexTones.chroma(Brightness.dark),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    );

    return base.copyWith(
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
      ),
      listTileTheme: base.listTileTheme.copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      chipTheme: base.chipTheme.copyWith(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  static const FlexSubThemesData _subThemes = FlexSubThemesData(
    blendOnLevel: 10,
    blendOnColors: false,
    useMaterial3Typography: true,
    useM2StyleDividerInM3: true,
    defaultRadius: 16.0,
    elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
    elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
    outlinedButtonOutlineSchemeColor: SchemeColor.primary,
    toggleButtonsBorderSchemeColor: SchemeColor.primary,
    segmentedButtonSchemeColor: SchemeColor.primary,
    segmentedButtonBorderSchemeColor: SchemeColor.primary,
    unselectedToggleIsColored: true,
    sliderValueTinted: true,
    inputDecoratorSchemeColor: SchemeColor.primary,
    inputDecoratorBackgroundAlpha: 25,
    inputDecoratorUnfocusedHasBorder: false,
    inputDecoratorFocusedBorderWidth: 1.5,
    inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
    inputDecoratorRadius: 12.0,
    fabUseShape: true,
    fabAlwaysCircular: true,
    fabSchemeColor: SchemeColor.primary,
    popupMenuRadius: 10.0,
    popupMenuElevation: 4.0,
    alignedDropdown: true,
    useInputDecoratorThemeInDialogs: true,
    drawerIndicatorRadius: 12.0,
    drawerIndicatorSchemeColor: SchemeColor.primary,
    bottomNavigationBarMutedUnselectedIcon: true,
    bottomNavigationBarMutedUnselectedLabel: true,
    menuRadius: 10.0,
    menuElevation: 4.0,
    menuBarRadius: 0.0,
    menuBarElevation: 2.0,
    menuBarShadowColor: Color(0x00000000),
    navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
    navigationBarMutedUnselectedLabel: false,
    navigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
    navigationBarMutedUnselectedIcon: false,
    navigationBarIndicatorSchemeColor: SchemeColor.primary,
    navigationBarIndicatorOpacity: 1.00,
    navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
    navigationRailMutedUnselectedLabel: false,
    navigationRailSelectedIconSchemeColor: SchemeColor.onPrimary,
    navigationRailMutedUnselectedIcon: false,
    navigationRailIndicatorSchemeColor: SchemeColor.primary,
    navigationRailIndicatorOpacity: 1.00,
    navigationRailBackgroundSchemeColor: SchemeColor.surface,
    navigationRailLabelType: NavigationRailLabelType.all,
  );
}

// ── Shared helpers ──────────────────────────────────────────────────────────

/// Deterministic avatar background color from a name string.
Color avatarColorFromName(String name) {
  const colors = [
    Color(0xFFE57373), // red
    Color(0xFFFF8A65), // deep orange
    Color(0xFFFFB74D), // orange
    Color(0xFFFFD54F), // amber
    Color(0xFFAED581), // light green
    Color(0xFF4DB6AC), // teal
    Color(0xFF4FC3F7), // light blue
    Color(0xFF9575CD), // deep purple
    Color(0xFFF06292), // pink
    Color(0xFF90A4AE), // blue grey
  ];
  final index = name.codeUnits.fold(0, (sum, c) => sum + c) % colors.length;
  return colors[index];
}

/// Health color: green/amber/red based on score.
Color healthColor(int score) {
  if (score >= 60) return const Color(0xFF4CAF50);
  if (score >= 30) return const Color(0xFFFFC107);
  return const Color(0xFFF44336);
}
