import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global font size provider
/// Manages font scaling across the entire application
class FontSizeProvider {
  static const String _fontSizeKey = 'app_font_size_scale';

  // Font size scales
  static const double verySmall = 0.8;
  static const double small = 0.9;
  static const double normal = 1.0;
  static const double large = 1.15;
  static const double veryLarge = 1.3;

  static final List<double> scales = [
    verySmall,
    small,
    normal,
    large,
    veryLarge
  ];
  static final List<String> scaleLabels = [
    'Très petit',
    'Petit',
    'Normal',
    'Grand',
    'Très grand'
  ];

  /// Get scale label
  static String getScaleLabel(double scale) {
    final index = scales.indexOf(scale);
    return index >= 0 ? scaleLabels[index] : 'Normal';
  }

  /// Load saved font size from SharedPreferences
  static Future<double> loadFontSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedScale = prefs.getDouble(_fontSizeKey);
      return savedScale ?? normal;
    } catch (e) {
      return normal;
    }
  }

  /// Save font size to SharedPreferences
  static Future<void> saveFontSize(double scale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_fontSizeKey, scale);
    } catch (e) {
      // Silently fail
    }
  }
}

/// Global notifier for font size
final ValueNotifier<double> fontSizeNotifier =
    ValueNotifier(FontSizeProvider.normal);
