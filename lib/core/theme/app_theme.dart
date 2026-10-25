import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Seed color: modern crisp sapphire/royal blue (familiar, polished, high clarity)
const _seedColor = Color(0xFF2563EB);

class AppTheme {
  // ── Light ──────────────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = FlexThemeData.light(
      colors: FlexSchemeColor.from(
        primary: _seedColor,
        secondary: const Color(0xFF0284C7), // sky
        tertiary: const Color(0xFF8B5CF6), // purple
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 1, // Ultra clean, non-muddy backgrounds
      subThemesData: _subThemes,
      keyColors: const FlexKeyColors(useSecondary: true, useTertiary: true),
      tones: FlexTones.soft(Brightness.light),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: GoogleFonts.interTextTheme(),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50 clean light background
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: const Color(0xFFF8FAFC),
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: Colors.white,
        elevation: 2,
        height: 68,
        indicatorColor: const Color(0xFFEFF6FF), // Soft blue pill
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2563EB),
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFF2563EB), size: 22);
          }
          return const IconThemeData(color: Color(0xFF64748B), size: 22);
        }),
      ),
      chipTheme: base.chipTheme.copyWith(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }

  // ── Dark ───────────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final base = FlexThemeData.dark(
      colors: FlexSchemeColor.from(
        primary: const Color(0xFF60A5FA),
        secondary: const Color(0xFF38BDF8),
        tertiary: const Color(0xFFA78BFA),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 2,
      subThemesData: _subThemes,
      keyColors: const FlexKeyColors(useSecondary: true, useTertiary: true),
      tones: FlexTones.chroma(Brightness.dark),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: GoogleFonts.interTextTheme(),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        color: const Color(0xFF1E293B), // Slate 800
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 2,
        height: 68,
        indicatorColor: const Color(0xFF1E3A8A),
      ),
    );
  }

  static const FlexSubThemesData _subThemes = FlexSubThemesData(
    blendOnLevel: 4,
    blendOnColors: false,
    useMaterial3Typography: true,
    useM2StyleDividerInM3: true,
    defaultRadius: 16.0,
    elevatedButtonSchemeColor: SchemeColor.onPrimary,
    elevatedButtonSecondarySchemeColor: SchemeColor.primary,
    inputDecoratorRadius: 14.0,
    fabUseShape: true,
    fabAlwaysCircular: true,
    fabSchemeColor: SchemeColor.primary,
    popupMenuRadius: 14.0,
    popupMenuElevation: 3.0,
    alignedDropdown: true,
  );
}

// ── Shared helpers ──────────────────────────────────────────────────────────

/// Deterministic, pastel-rich avatar background color from a name string.
Color avatarColorFromName(String name) {
  const colors = [
    Color(0xFF3B82F6), // blue
    Color(0xFF10B981), // emerald
    Color(0xFF8B5CF6), // purple
    Color(0xFFEC4899), // pink
    Color(0xFFF59E0B), // amber
    Color(0xFF06B6D4), // cyan
    Color(0xFF6366F1), // indigo
    Color(0xFF14B8A6), // teal
    Color(0xFFF97316), // orange
  ];
  if (name.isEmpty) return colors[0];
  final index = name.codeUnits.fold(0, (sum, c) => sum + c) % colors.length;
  return colors[index];
}

/// Category color mapping for relationship types
Color colorForCategory(String category) {
  switch (category) {
    case 'Family':
      return const Color(0xFFE11D48); // Rose
    case 'Friend':
      return const Color(0xFF2563EB); // Blue
    case 'Colleague':
      return const Color(0xFF7C3AED); // Purple
    case 'Other':
    default:
      return const Color(0xFF64748B); // Slate
  }
}

/// Health color: green/amber/red based on score.
Color healthColor(int score) {
  if (score >= 60) return const Color(0xFF10B981); // Emerald
  if (score >= 30) return const Color(0xFFF59E0B); // Amber
  return const Color(0xFFEF4444); // Red
}
