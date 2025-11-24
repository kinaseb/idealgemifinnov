import 'package:flutter/material.dart';

/// Modern text styles for the application
class AppTextStyles {
  /// Get scaled text style
  static TextStyle _scaled(TextStyle base, double fontScale) {
    return base.copyWith(fontSize: (base.fontSize ?? 14) * fontScale);
  }

  // Display styles
  static TextStyle displayLarge(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          height: 1.12,
          color: color,
        ),
        fontScale,
      );

  static TextStyle displayMedium(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          height: 1.16,
          color: color,
        ),
        fontScale,
      );

  static TextStyle displaySmall(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          height: 1.22,
          color: color,
        ),
        fontScale,
      );

  // Headline styles
  static TextStyle headlineLarge(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.25,
          color: color,
        ),
        fontScale,
      );

  static TextStyle headlineMedium(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.29,
          color: color,
        ),
        fontScale,
      );

  static TextStyle headlineSmall(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.33,
          color: color,
        ),
        fontScale,
      );

  // Title styles
  static TextStyle titleLarge(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.27,
          color: color,
        ),
        fontScale,
      );

  static TextStyle titleMedium(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.50,
          color: color,
        ),
        fontScale,
      );

  static TextStyle titleSmall(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
          color: color,
        ),
        fontScale,
      );

  // Body styles
  static TextStyle bodyLarge(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.50,
          color: color,
        ),
        fontScale,
      );

  static TextStyle bodyMedium(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
          color: color,
        ),
        fontScale,
      );

  static TextStyle bodySmall(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
          color: color,
        ),
        fontScale,
      );

  // Label styles
  static TextStyle labelLarge(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
          color: color,
        ),
        fontScale,
      );

  static TextStyle labelMedium(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
          color: color,
        ),
        fontScale,
      );

  static TextStyle labelSmall(double fontScale, {Color? color}) => _scaled(
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
          color: color,
        ),
        fontScale,
      );
}
