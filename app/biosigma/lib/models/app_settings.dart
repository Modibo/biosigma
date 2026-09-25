/// Séparateur décimal utilisé pour la saisie et l'affichage des nombres.
enum DecimalSeparator { comma, dot }

/// Réglages locaux de l'application, persistés sur l'appareil uniquement
/// (aucune synchronisation, aucune télémétrie). Ne contient jamais
/// d'identité de patient.
class AppSettings {
  const AppSettings({
    this.decimalSeparator = DecimalSeparator.comma,
    this.displayPrecision = 2,
    this.historyEnabled = false,
    this.localInterpretationsValidated = false,
    this.ldlDefaultFriedewald = true,
    this.sodiumCorrectionUsesKatz = true,
  });

  /// Virgule (convention française) ou point.
  final DecimalSeparator decimalSeparator;

  /// Décimales affichées par défaut quand un calcul ne fixe pas sa propre
  /// précision (`FormulaMeta.displayPrecision` a toujours priorité).
  final int displayPrecision;

  /// Historique local facultatif, désactivé par défaut (cf. cahier des
  /// charges : opt-in explicite, jamais de valeur par défaut favorisant la
  /// collecte).
  final bool historyEnabled;

  /// Coché par le biologiste responsable : autorise l'affichage du texte
  /// d'interprétation des scores ISTH-CIVD et 4Ts. Décoché par défaut.
  final bool localInterpretationsValidated;

  /// `true` = Friedewald par défaut pour le panel LDL ; `false` = Sampson.
  /// Choix reconfigurable par le laboratoire, sans valeur imposée.
  final bool ldlDefaultFriedewald;

  /// `true` = coefficient de Katz (1,6) mis en avant pour le sodium
  /// corrigé ; les deux valeurs restent toujours affichées.
  final bool sodiumCorrectionUsesKatz;

  AppSettings copyWith({
    DecimalSeparator? decimalSeparator,
    int? displayPrecision,
    bool? historyEnabled,
    bool? localInterpretationsValidated,
    bool? ldlDefaultFriedewald,
    bool? sodiumCorrectionUsesKatz,
  }) {
    return AppSettings(
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
      displayPrecision: displayPrecision ?? this.displayPrecision,
      historyEnabled: historyEnabled ?? this.historyEnabled,
      localInterpretationsValidated:
          localInterpretationsValidated ?? this.localInterpretationsValidated,
      ldlDefaultFriedewald: ldlDefaultFriedewald ?? this.ldlDefaultFriedewald,
      sodiumCorrectionUsesKatz: sodiumCorrectionUsesKatz ?? this.sodiumCorrectionUsesKatz,
    );
  }

  Map<String, dynamic> toJson() => {
        'decimalSeparator': decimalSeparator.name,
        'displayPrecision': displayPrecision,
        'historyEnabled': historyEnabled,
        'localInterpretationsValidated': localInterpretationsValidated,
        'ldlDefaultFriedewald': ldlDefaultFriedewald,
        'sodiumCorrectionUsesKatz': sodiumCorrectionUsesKatz,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        decimalSeparator: DecimalSeparator.values.firstWhere(
          (e) => e.name == json['decimalSeparator'],
          orElse: () => DecimalSeparator.comma,
        ),
        displayPrecision: json['displayPrecision'] as int? ?? 2,
        historyEnabled: json['historyEnabled'] as bool? ?? false,
        localInterpretationsValidated: json['localInterpretationsValidated'] as bool? ?? false,
        ldlDefaultFriedewald: json['ldlDefaultFriedewald'] as bool? ?? true,
        sodiumCorrectionUsesKatz: json['sodiumCorrectionUsesKatz'] as bool? ?? true,
      );
}
