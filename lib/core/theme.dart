import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Premium Palette
  static const Color primaryColor = Color(0xFF0F766E); // Deep Teal
  static const Color primaryDarkColor = Color(0xFF115E59);
  static const Color primaryLightColor = Color(0xFFCCFBF1);
  
  static const Color secondaryColor = Color(0xFFF59E0B); // Amber / Gold
  static const Color secondaryLightColor = Color(0xFFFEF3C7);
  
  static const Color backgroundColor = Color(0xFFF8FAFC); // Soft Slate Gray
  static const Color surfaceColor = Colors.white;
  static const Color textDark = Color(0xFF0F172A); // Slate 900
  static const Color textMuted = Color(0xFF64748B); // Slate 500
  
  static const Color outlineColor = Color(0xFFE2E8F0); // Slate 200
  static const Color borderLight = Color(0xFFF1F5F9); // Slate 100

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        onSurface: textDark,
        surfaceContainerHighest: Color(0xFFF1F5F9),
        error: const Color(0xFFEF4444),
        errorContainer: const Color(0xFFFEE2E2),
        onErrorContainer: const Color(0xFF991B1B),
        outline: const Color(0xFFCBD5E1),
        outlineVariant: outlineColor,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textDark),
        actionsIconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: outlineColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        labelStyle: const TextStyle(color: textMuted, fontSize: 14),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: outlineColor,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
