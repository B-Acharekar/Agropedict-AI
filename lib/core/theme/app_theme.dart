import 'package:flutter/material.dart';

class AgroColors {
  const AgroColors._();

  static const primaryGreen = Color(0xFF2E7D32);
  static const freshGreen = Color(0xFF3FA34D);
  static const lightGreen = Color(0xFFE8F5E9);
  static const lime = Color(0xFFC8E6C9);
  static const forest = Color(0xFF14532D);
  static const background = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const warm = Color(0xFFF97316);
  static const earth = Color(0xFFB45309);
  static const ai = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFD84343);
  static const textPrimary = Color(0xFF17351F);
  static const textSecondary = Color(0xFF61706A);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AgroColors.primaryGreen,
      primary: AgroColors.primaryGreen,
      secondary: AgroColors.warm,
      tertiary: AgroColors.warm,
      surface: AgroColors.card,
      surfaceTint: AgroColors.lightGreen,
      error: AgroColors.danger,
      brightness: Brightness.light,
    );
    return _theme(scheme, false);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AgroColors.primaryGreen,
      primary: AgroColors.lightGreen,
      secondary: AgroColors.warm,
      background: const Color(0xFF111A14),
      surface: const Color(0xFF172119),
      brightness: Brightness.dark,
    );
    return _theme(scheme, true);
  }

  static ThemeData _theme(ColorScheme scheme, bool dark) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF111A14) : Colors.white,
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ).apply(
        bodyColor: dark ? Colors.white : AgroColors.textPrimary,
        displayColor: dark ? Colors.white : AgroColors.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1E2B21) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dark ? scheme.outlineVariant : AgroColors.lime),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: dark ? scheme.outlineVariant : AgroColors.lime),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AgroColors.warm, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: AgroColors.primaryGreen,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
