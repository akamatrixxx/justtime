import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF3F51B5); // Indigo
  static const primaryDark = Color(0xFF303F9F);
  static const primaryLight = Color(0xFFC5CAE9);
  static const surface = Color(0xFFF5F5F7);
  static const card = Colors.white;

  // State accent colors
  static const work = Color(0xFF1976D2); // Blue
  static const workLight = Color(0xFFBBDEFB);
  static const rest = Color(0xFF7B1FA2); // Purple
  static const restLight = Color(0xFFE1BEE7);
  static const feedback = Color(0xFFF57C00); // Orange
  static const feedbackLight = Color(0xFFFFE0B2);

  // Gradient sets
  static const workGradient = [Color(0xFF1565C0), Color(0xFF42A5F5)];
  static const restGradient = [Color(0xFF6A1B9A), Color(0xFFAB47BC)];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.primary,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryDark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.card,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
