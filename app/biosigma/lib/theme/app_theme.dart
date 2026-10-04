import 'package:flutter/material.dart';

/// Palette BioSigma : bleu nuit, cyan, corail — identité du monogramme BΣ.
class BioSigmaColors {
  BioSigmaColors._();

  static const navy = Color(0xFF0F2245);
  static const navyDark = Color(0xFF081527);
  static const cyan = Color(0xFF1E9FE0);

  /// Variante foncée du cyan pour le texte et les boutons du thème clair :
  /// le cyan de la marque (2,96:1 sur blanc) ne respecte pas le contraste
  /// WCAG AA (4,5:1) ; celle-ci donne 5,7:1 sur blanc.
  static const cyanDeep = Color(0xFF0B6CA3);
  static const cyanLight = Color(0xFF8FF0FF);
  static const coral = Color(0xFFE1382A);

  /// Corail foncé pour du texte sur fond clair (5,5:1 sur blanc).
  static const coralDeep = Color(0xFFC62F22);
  static const coralLight = Color(0xFFFF8A65);

  /// Couleurs d'avertissement : variantes claires distinctes pour le thème
  /// sombre, où les teintes sombres du thème clair perdraient trop de
  /// contraste sur un fond bleu nuit.
  static const warningCaution = Color(0xFF9A5B00);
  static const warningCautionOnDark = Color(0xFFFFB74D);
  static const warningBlocking = Color(0xFFB3261E);
  static const warningBlockingOnDark = Color(0xFFFF6B60);

  /// Sélectionne la variante d'avertissement adaptée à la luminosité du
  /// thème courant — jamais une couleur fixe indépendante du thème.
  static Color warningCautionFor(Brightness brightness) =>
      brightness == Brightness.dark ? warningCautionOnDark : warningCaution;
  static Color warningBlockingFor(Brightness brightness) =>
      brightness == Brightness.dark ? warningBlockingOnDark : warningBlocking;
}

/// Contour discret partagé par toutes les cartes de l'application, plutôt
/// qu'une élévation marquée, pour que chaque carte se détache proprement
/// du fond sans effet « papier flottant ».
RoundedRectangleBorder _cardShape(Color borderColor) => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: borderColor),
    );

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BioSigmaColors.cyan,
      brightness: Brightness.light,
      primary: BioSigmaColors.cyanDeep,
      onPrimary: Colors.white,
      secondary: BioSigmaColors.coralDeep,
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
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: _cardShape(scheme.outlineVariant.withValues(alpha: 0.6)),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(backgroundColor: BioSigmaColors.cyanDeep, foregroundColor: Colors.white),
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
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: _cardShape(scheme.outlineVariant.withValues(alpha: 0.4)),
        color: BioSigmaColors.navy.withValues(alpha: 0.55),
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(backgroundColor: BioSigmaColors.cyanLight, foregroundColor: BioSigmaColors.navyDark),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
