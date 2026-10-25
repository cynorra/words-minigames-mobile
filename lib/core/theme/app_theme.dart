import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  // Brand
  static const String brandName = 'Cynnora';

  // Eye-friendly Modern Game Theme Palette (Deep space, neon lavander & cyber mint)
  // Dark Theme Colors (Eye-friendly dark indigo / deep slate)
  static const Color darkBackground = Color(0xFF0F111A); // Deep restful space slate
  static const Color darkSurface = Color(0xFF181B26); // Card background
  static const Color darkSurfaceElevated = Color(0xFF222738); // Elevated layer
  static const Color darkPrimary = Color(0xFF8B5CF6); // Vibrant Lavender/Violet
  static const Color darkSecondary = Color(0xFF06B6D4); // Cyber Cyan/Mint
  static const Color darkAccent = Color(0xFFF59E0B); // Soft Amber
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkOnSecondary = Color(0xFF0F172A);
  static const Color darkOnBackground = Color(0xFFF1F5F9);
  static const Color darkOnSurface = Color(0xFFE2E8F0);
  static const Color darkOnSurfaceMuted = Color(0xFF94A3B8);
  static const Color darkError = Color(0xFFF87171);
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkWarning = Color(0xFFFBBF24);

  // Light Theme Colors (Soft paper/smoke with crisp contrast)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightPrimary = Color(0xFF7C3AED);
  static const Color lightSecondary = Color(0xFF0891B2);
  static const Color lightAccent = Color(0xFFD97706);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF0F172A);
  static const Color lightOnSurface = Color(0xFF1E293B);
  static const Color lightOnSurfaceMuted = Color(0xFF64748B);
  static const Color lightError = Color(0xFFEF4444);
  static const Color lightSuccess = Color(0xFF10B981);
  static const Color lightWarning = Color(0xFFF59E0B);

  // Extended & Game Specific Colors
  static const Color vividGreen = Color(0xFF10B981);
  static const Color vividGreenAlt = Color(0xFF059669);
  static const Color goldYellow = Color(0xFFFBBF24);
  static const Color overlayDark = Color(0x990F111A);

  static const Color slotBorder = Color(0xFF8B5CF6);
  static const Color slotBackground = Color(0xFF181B26);
  static const Color questionMark = Color(0xFF64748B);
  static const Color darkSlotBorder = Color(0xFFA78BFA);
  static const Color darkSlotBackground = Color(0xFF181B26);
  static const Color darkQuestionMark = Color(0xFF94A3B8);

  static const Color lightSlotBorder = Color(0xFF7C3AED);
  static const Color lightSlotBackground = Color(0xFFF1F5F9);
  static const Color lightSlotText = Color(0xFF4C1D95);

  // Modern Gradients for 2026+ Gaming Style
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x338B5CF6), Color(0x0506B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightSurface,
        onPrimary: lightOnPrimary,
        onSecondary: lightOnSecondary,
        onSurface: lightOnSurface,
        onSurfaceVariant: lightOnSurfaceMuted,
        error: lightError,
      ),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightOnBackground,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: lightOnPrimary,
          elevation: 2,
          shadowColor: lightPrimary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largeSpacing,
            vertical: AppConstants.mediumSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.largeRadius),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeRadius),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      textTheme: ThemeData.light().textTheme,
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkSurface,
        onPrimary: darkOnPrimary,
        onSecondary: darkOnSecondary,
        onSurface: darkOnSurface,
        onSurfaceVariant: darkOnSurfaceMuted,
        error: darkError,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkOnBackground,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkOnPrimary,
          elevation: 4,
          shadowColor: darkPrimary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largeSpacing,
            vertical: AppConstants.mediumSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.largeRadius),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeRadius),
          side: const BorderSide(color: Color(0xFF2A3042), width: 1),
        ),
      ),
      textTheme: ThemeData.dark().textTheme,
    );
  }
}
