import 'package:flutter/material.dart';

class AppColors {
  // Modern Sober Palette
  static const Color primary = Color(0xFF1A237E); // Deep Navy Blue
  static const Color secondary = Color(0xFF009688); // Teal
  static const Color accent = Color(0xFFFFC107); // Amber/Gold
  static const Color background = Color(0xFFF5F5F5); // Light Grey
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Dark Mode Palette
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkPrimary = Color(0xFF3949AB);
  static const Color darkSecondary = Color(0xFF26A69A);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Additional colors for widgets
  static const Color lightSurface = Colors.white;
  static const Color lightCardBorder = Color(0xFFE0E0E0);
  static const Color darkCardBorder = Color(0xFF424242);

  static const Color lightPrimaryStart = Color(0xFF1A237E);
  static const Color lightPrimaryEnd = Color(0xFF3949AB);
  static const Color darkPrimaryStart = Color(0xFF3949AB);
  static const Color darkPrimaryEnd = Color(0xFF5C6BC0);

  static const Color lightSecondaryStart = Color(0xFF009688);
  static const Color lightSecondaryEnd = Color(0xFF26A69A);
  static const Color darkSecondaryStart = Color(0xFF26A69A);
  static const Color darkSecondaryEnd = Color(0xFF00897B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightPrimaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightSecondaryGradient = LinearGradient(
    colors: [Color(0xFF009688), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkSecondaryGradient = LinearGradient(
    colors: [Color(0xFF26A69A), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
