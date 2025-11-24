import 'package:flutter/material.dart';
import 'package:ideal_calcule/theme/app_colors.dart';
import 'package:ideal_calcule/theme/app_text_styles.dart';

/// Application theme configuration
class AppTheme {
  /// Create light theme
  static ThemeData lightTheme(double fontScale) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.lightPrimaryStart,
        secondary: AppColors.lightSecondaryStart,
        brightness: Brightness.light,
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightPrimaryStart,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle:
            AppTextStyles.titleLarge(fontScale, color: Colors.white),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.lightCardBorder.withOpacity(0.2)),
        ),
        color: AppColors.lightSurface,
        shadowColor: Colors.black.withOpacity(0.1),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppColors.lightCardBorder.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.lightPrimaryStart, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle:
            AppTextStyles.bodyMedium(fontScale, color: const Color(0xFF5C5C5C)),
        hintStyle:
            AppTextStyles.bodyMedium(fontScale, color: const Color(0xFF9E9E9E)),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.labelLarge(fontScale),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.labelLarge(fontScale),
        ),
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge(fontScale),
        displayMedium: AppTextStyles.displayMedium(fontScale),
        displaySmall: AppTextStyles.displaySmall(fontScale),
        headlineLarge: AppTextStyles.headlineLarge(fontScale),
        headlineMedium: AppTextStyles.headlineMedium(fontScale),
        headlineSmall: AppTextStyles.headlineSmall(fontScale),
        titleLarge: AppTextStyles.titleLarge(fontScale),
        titleMedium: AppTextStyles.titleMedium(fontScale),
        titleSmall: AppTextStyles.titleSmall(fontScale),
        bodyLarge: AppTextStyles.bodyLarge(fontScale),
        bodyMedium: AppTextStyles.bodyMedium(fontScale),
        bodySmall: AppTextStyles.bodySmall(fontScale),
        labelLarge: AppTextStyles.labelLarge(fontScale),
        labelMedium: AppTextStyles.labelMedium(fontScale),
        labelSmall: AppTextStyles.labelSmall(fontScale),
      ),
    );
  }

  /// Create dark theme
  static ThemeData darkTheme(double fontScale) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkPrimaryStart,
        secondary: AppColors.darkSecondaryStart,
        brightness: Brightness.dark,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle:
            AppTextStyles.titleLarge(fontScale, color: Colors.white),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.darkCardBorder.withOpacity(0.3)),
        ),
        color: AppColors.darkSurface,
        shadowColor: Colors.black.withOpacity(0.3),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppColors.darkCardBorder.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.darkPrimaryStart, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle:
            AppTextStyles.bodyMedium(fontScale, color: const Color(0xFFAAAAAA)),
        hintStyle:
            AppTextStyles.bodyMedium(fontScale, color: const Color(0xFF666666)),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.labelLarge(fontScale),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.labelLarge(fontScale),
        ),
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge:
            AppTextStyles.displayLarge(fontScale, color: Colors.white),
        displayMedium:
            AppTextStyles.displayMedium(fontScale, color: Colors.white),
        displaySmall:
            AppTextStyles.displaySmall(fontScale, color: Colors.white),
        headlineLarge:
            AppTextStyles.headlineLarge(fontScale, color: Colors.white),
        headlineMedium:
            AppTextStyles.headlineMedium(fontScale, color: Colors.white),
        headlineSmall:
            AppTextStyles.headlineSmall(fontScale, color: Colors.white),
        titleLarge: AppTextStyles.titleLarge(fontScale, color: Colors.white),
        titleMedium: AppTextStyles.titleMedium(fontScale, color: Colors.white),
        titleSmall: AppTextStyles.titleSmall(fontScale, color: Colors.white),
        bodyLarge: AppTextStyles.bodyLarge(fontScale, color: Colors.white70),
        bodyMedium: AppTextStyles.bodyMedium(fontScale, color: Colors.white70),
        bodySmall: AppTextStyles.bodySmall(fontScale, color: Colors.white60),
        labelLarge: AppTextStyles.labelLarge(fontScale, color: Colors.white),
        labelMedium:
            AppTextStyles.labelMedium(fontScale, color: Colors.white70),
        labelSmall: AppTextStyles.labelSmall(fontScale, color: Colors.white60),
      ),
    );
  }
}
