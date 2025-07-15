import 'package:flutter/material.dart';

/// Brand palette derived from the Arcana e‑book reader logo
class CustomColors {
  // ─────────────────── Brand colors ───────────────────

  /// Deep‑navy shown in the logo’s backdrop
  static const Color primary = Color(0xFF203050);
  static const Color primaryDark = Color(0xFF1A2840);
  static const Color primaryLight = Color(0xFF314872);

  /// Warm salmon ribbon
  static const Color secondary = Color(0xFFFF7B7B);
  static const Color secondaryLight = Color(0xFFFF9B9B);

  /// Gold wrist‑band highlight
  static const Color accent = Color(0xFFF2D544);
  static const Color accentDark = Color(0xFFE5BF00);

  /// Sparkle blue for info states / interactive focus
  static const Color info = Color(0xFFA1D4F9);
  static const Color infoDark = Color(0xFF7BBCE9);

  // ─────────────────── Surfaces & backgrounds ───────────────────

  /// Parchment tone from the scroll
  static const Color surface = Color(0xFFF4E9DC);
  static const Color surfaceVariant = Color(0xFFF9F4ED);

  static const Color surfaceDark = Color(0xFF172337);

  /// Pure backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color backgroundSecondary = Color(0xFFF9FAFB);

  // ─────────────────── Text ───────────────────

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─────────────────── Semantic states ───────────────────

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // ─────────────────── Cards / elevation ───────────────────

  static const Color cardBackground = surface; // matches parchment
  static const Color cardShadow = Color(0x1A000000);
  static const Color divider = Color(0xFFE5E7EB);

  // ─────────────────── Legacy fallbacks ───────────────────
  static Color normal = primary;
  static Color textNormal = textPrimary;
  static Color textHighlight = secondary;
  static Color textGray = textSecondary;
  static Color textDark = textPrimary;
  static Color textDarkHighlight = primaryDark;

  // ─────────────────── Helper methods ───────────────────
  static Color _withOpacity(Color c, double opacity) =>
      c.withValues(alpha: opacity);

  static Color errorWithOpacity(double opacity) => _withOpacity(error, opacity);
  static Color primaryWithOpacity(double opacity) =>
      _withOpacity(primary, opacity);
  static Color textOnPrimaryWithOpacity(double opacity) =>
      _withOpacity(textOnPrimary, opacity);
  static Color backgroundSecondaryWithOpacity(double opacity) =>
      _withOpacity(backgroundSecondary, opacity);
  static Color dividerWithOpacity(double opacity) =>
      _withOpacity(divider, opacity);
  static Color warningWithOpacity(double opacity) =>
      _withOpacity(warning, opacity);
  static Color infoWithOpacity(double opacity) => _withOpacity(info, opacity);
  static Color textTertiaryWithOpacity(double opacity) =>
      _withOpacity(textTertiary, opacity);
  static Color blackWithOpacity(double opacity) =>
      _withOpacity(Colors.black, opacity);

  static Color dynamicWithOpacity(Color? color, double opacity) =>
      _withOpacity(color ?? primary, opacity);
}
