import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Seed color: warm, calming peach-terracotta
const _seedColor = Color(0xFFF27B66);

class AppTheme {
  // ── Light ──────────────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = FlexThemeData.light(
      colors: FlexSchemeColor.from(primary: _seedColor),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 2, // Very low blend for a clean, flat Daylio look
      subThemesData: _subThemes,
      keyColors: const FlexKeyColors(useSecondary: true, useTertiary: true),
      tones: FlexTones.soft(Brightness.light),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.nunito().fontFamily,
      textTheme: GoogleFonts.nunitoTextTheme(),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(
        0xFFF8F9FA,
      ), // Clean, slightly off-white background
      cardTheme: base.cardTheme.copyWith(
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: const Color(
          0xFFF8F9FA,
        ), // Match scaffold for seamless look
        scrolledUnderElevation: 0, // Keep it perfectly flat even when scrolling
        centerTitle: false,
      ),
      listTileTheme: base.listTileTheme.copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      chipTheme: base.chipTheme.copyWith(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: base.chipTheme.labelStyle?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Dark ───────────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final base = FlexThemeData.dark(
      colors: FlexSchemeColor.from(primary: _seedColor),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 4, // Very low blend for dark mode as well
      subThemesData: _subThemes,
      keyColors: FlexKeyColors(useSecondary: true, useTertiary: true),
      tones: FlexTones.chroma(Brightness.dark),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.nunito().fontFamily,
      textTheme: GoogleFonts.nunitoTextTheme(),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212), // Pure dark background
      cardTheme: base.cardTheme.copyWith(
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: const Color(0xFF121212),
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      listTileTheme: base.listTileTheme.copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      chipTheme: base.chipTheme.copyWith(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: base.chipTheme.labelStyle?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: light.colorScheme.primaryContainer,
        foregroundColor: light.colorScheme.onPrimaryContainer,
      ),
    );
  }

  static const FlexSubThemesData _subThemes = FlexSubThemesData(
    blendOnLevel: 5,
    blendOnColors: false,
    useMaterial3Typography: true,
    useM2StyleDividerInM3: true,
    defaultRadius:
        20.0, // Reduced from 24 for a slightly more structured but playful look
    elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
    elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
    outlinedButtonOutlineSchemeColor: SchemeColor.primary,
    toggleButtonsBorderSchemeColor: SchemeColor.primary,
    segmentedButtonSchemeColor: SchemeColor.primary,
    segmentedButtonBorderSchemeColor: SchemeColor.primary,
    unselectedToggleIsColored: true,
    sliderValueTinted: true,
    inputDecoratorSchemeColor: SchemeColor.primary,
    inputDecoratorBackgroundAlpha: 15, // Softer input backgrounds
    inputDecoratorUnfocusedHasBorder: false,
    inputDecoratorFocusedBorderWidth: 1.5,
    inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
    inputDecoratorRadius: 16.0,
    fabUseShape: true,
    fabAlwaysCircular: true,
    fabSchemeColor: SchemeColor.primaryContainer,
    popupMenuRadius: 16.0,
    popupMenuElevation: 3.0,
    alignedDropdown: true,
    useInputDecoratorThemeInDialogs: true,
    drawerIndicatorRadius: 20.0,
    drawerIndicatorSchemeColor: SchemeColor.primary,
    bottomNavigationBarMutedUnselectedIcon: true,
    bottomNavigationBarMutedUnselectedLabel: true,
    menuRadius: 16.0,
    menuElevation: 3.0,
    menuBarRadius: 0.0,
    menuBarElevation: 1.0,
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

/// Category color mapping for relationship types
Color colorForCategory(String category) {
  switch (category) {
    case 'Family':
      return const Color(0xFFE57373); // red
    case 'Friend':
      return const Color(0xFF42A5F5); // Blue 400
    case 'Colleague':
      return const Color(0xFF9575CD); // deep purple
    case 'Other':
    default:
      return const Color(0xFF90A4AE); // Blue Grey 400
  }
}

/// Health color: green/amber/red based on score.
Color healthColor(int score) {
  if (score >= 60) return const Color(0xFF4CAF50);
  if (score >= 30) return const Color(0xFFFFC107);
  return const Color(0xFFF44336);
}
