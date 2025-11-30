import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme(double fontScale) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.latoTextTheme().copyWith(
        bodyLarge: GoogleFonts.lato(
            fontSize: 16 * fontScale, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.lato(
            fontSize: 14 * fontScale, color: AppColors.textPrimary),
        bodySmall: GoogleFonts.lato(
            fontSize: 12 * fontScale, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.lato(
            fontSize: 22 * fontScale,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary),
        titleMedium: GoogleFonts.lato(
            fontSize: 18 * fontScale,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        titleSmall: GoogleFonts.lato(
            fontSize: 16 * fontScale,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary),
        labelLarge: GoogleFonts.lato(
            fontSize: 14 * fontScale,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary),
        labelMedium: GoogleFonts.lato(
            fontSize: 12 * fontScale,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary),
        labelSmall: GoogleFonts.lato(
            fontSize: 11 * fontScale,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lato(
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle:
            TextStyle(color: AppColors.textSecondary, fontSize: 16 * fontScale),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.lato(
            fontSize: 16 * fontScale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }

  static ThemeData darkTheme(double fontScale) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: GoogleFonts.lato(
            fontSize: 16 * fontScale, color: AppColors.darkTextPrimary),
        bodyMedium: GoogleFonts.lato(
            fontSize: 14 * fontScale, color: AppColors.darkTextPrimary),
        bodySmall: GoogleFonts.lato(
            fontSize: 12 * fontScale, color: AppColors.darkTextPrimary),
        titleLarge: GoogleFonts.lato(
            fontSize: 22 * fontScale,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTextPrimary),
        titleMedium: GoogleFonts.lato(
            fontSize: 18 * fontScale,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextPrimary),
        titleSmall: GoogleFonts.lato(
            fontSize: 16 * fontScale,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextPrimary),
        labelLarge: GoogleFonts.lato(
            fontSize: 14 * fontScale,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextPrimary),
        labelMedium: GoogleFonts.lato(
            fontSize: 12 * fontScale,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextPrimary),
        labelSmall: GoogleFonts.lato(
            fontSize: 11 * fontScale,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lato(
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
            color: AppColors.darkTextSecondary, fontSize: 16 * fontScale),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.lato(
            fontSize: 16 * fontScale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }
}
