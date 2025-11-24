import 'package:flutter/material.dart';

/// Modern color palette for the application
class AppColors {
  // Light theme colors
  static const lightPrimaryStart = Color(0xFF667eea);
  static const lightPrimaryEnd = Color(0xFF764ba2);
  static const lightSecondaryStart = Color(0xFF00d2ff);
  static const lightSecondaryEnd = Color(0xFF3a7bd5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightBackground = Color(0xFFF8F9FA);
  static const lightCardBorder = Color(0xFFE0E0E0);

  // Dark theme colors
  static const darkPrimaryStart = Color(0xFF667eea);
  static const darkPrimaryEnd = Color(0xFF764ba2);
  static const darkSecondaryStart = Color(0xFF00d2ff);
  static const darkSecondaryEnd = Color(0xFF3a7bd5);
  static const darkSurface = Color(0xFF1A1A2E);
  static const darkBackground = Color(0xFF0F0F1E);
  static const darkCardBorder = Color(0xFF2A2A3E);

  // Gradients
  static const lightPrimaryGradient = LinearGradient(
    colors: [lightPrimaryStart, lightPrimaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const lightSecondaryGradient = LinearGradient(
    colors: [lightSecondaryStart, lightSecondaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkPrimaryGradient = LinearGradient(
    colors: [darkPrimaryStart, darkPrimaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkSecondaryGradient = LinearGradient(
    colors: [darkSecondaryStart, darkSecondaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Utility colors
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFEF5350);
  static const warning = Color(0xFFFF9800);
  static const info = Color(0xFF2196F3);
}
