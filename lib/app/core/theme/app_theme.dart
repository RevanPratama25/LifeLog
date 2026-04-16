import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Kita fokus ke Dark Theme sesuai desain
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    
    // Setup Font Family sesuai desain Stitch (Manrope & Inter)
    textTheme: TextTheme(
      // Headline pakai Manrope
      displayLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      displayMedium: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      titleLarge: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      
      // Body & Label pakai Inter
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
    ),

    // Setup style default untuk Card (Glassmorphism base)
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0, // Kita set 0 karena nanti glow-nya pakai shadow manual
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // Setup warna elemen-elemen kecil
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
  );
}