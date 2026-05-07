import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Dark theme matching the Stitch design system
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    
    // Font family setup per design spec (Manrope & Inter)
    textTheme: TextTheme(
      // Headlines use Manrope
      displayLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      displayMedium: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      titleLarge: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      
      // Body & Label use Inter
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
    ),

    // Default card style (glassmorphism base)
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0, // Set to 0; glow is applied manually via shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // Configure small UI element colors
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
  );
}