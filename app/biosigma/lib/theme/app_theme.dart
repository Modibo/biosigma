import 'package:flutter/material.dart';

/// Palette BioSigma : bleu nuit, cyan, corail — identité du monogramme BΣ.
class BioSigmaColors {
  BioSigmaColors._();

  static const navy = Color(0xFF0F2245);
  static const navyDark = Color(0xFF081527);
  static const cyan = Color(0xFF1E9FE0);
  static const cyanLight = Color(0xFF8FF0FF);
  static const coral = Color(0xFFE1382A);
  static const coralLight = Color(0xFFFF8A65);

  static const warningCaution = Color(0xFFB26A00);
  static const warningBlocking = Color(0xFFB3261E);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BioSigmaColors.cyan,
      brightness: Brightness.light,
      primary: BioSigmaColors.cyan,
      secondary: BioSigmaColors.coral,
      tertiary: BioSigmaColors.navy,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF5F8FC),
      appBarTheme: AppBarTheme(
        backgroundColor: BioSigmaColors.navy,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 6),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(backgroundColor: BioSigmaColors.cyan),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BioSigmaColors.cyan,
      brightness: Brightness.dark,
      primary: BioSigmaColors.cyanLight,
      secondary: BioSigmaColors.coralLight,
      surface: BioSigmaColors.navyDark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: BioSigmaColors.navyDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: BioSigmaColors.navy,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
