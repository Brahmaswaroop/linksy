import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens inspired by soft neo-modernism, pill components, and pastel aesthetic.
class NeoPalette {
  // Base Canvas & Surfaces
  static const canvasLight = Color(0xFFF4F8FA);
  static const surfaceWhite = Color(0xFFFFFFFF);
  static const inkBlack = Color(0xFF14171F);
  static const cardBorder = Color(0xFFE6ECF1);

  // Text Colors
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);

  // Mint / Emerald (Friends, Healthy)
  static const mintBg = Color(0xFFE8F7F4);
  static const mintBorder = Color(0xFFC6ECE3);
  static const mintText = Color(0xFF0D766E);

  // Sky Blue (Work, Professional, Sync)
  static const skyBg = Color(0xFFE7F1FB);
  static const skyBorder = Color(0xFFCBE0F8);
  static const skyText = Color(0xFF0284C7);

  // Lavender / Violet (Family, Deep Bonds)
  static const lavenderBg = Color(0xFFECE7FA);
  static const lavenderBorder = Color(0xFFD8CEF7);
  static const lavenderText = Color(0xFF7C3AED);

  // Peach / Coral (VIPs, Overdue, Attention)
  static const peachBg = Color(0xFFFDEEE9);
  static const peachBorder = Color(0xFFFBD3C6);
  static const peachText = Color(0xFFEA580C);

  // Karma / Amber (Gamification badge)
  static const amberBg = Color(0xFFFEF3C7);
  static const amberBorder = Color(0xFFFDE68A);
  static const amberText = Color(0xFFD97706);

  // Radii
  static const double radiusCard = 24.0;
  static const double radiusPill = 50.0;
  static const double radiusSm = 16.0;

  // Box Shadows
  static const shadowSoft = [
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const shadowCard = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  // Typography - Plus Jakarta Sans
  static TextStyle titleLarge({Color color = textPrimary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -0.6,
      );

  static TextStyle titleMedium({Color color = textPrimary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.3,
      );

  static TextStyle bodyMedium({Color color = textPrimary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle labelPill({Color color = textPrimary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: color,
      );
}
