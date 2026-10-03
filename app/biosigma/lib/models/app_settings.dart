/// Séparateur décimal utilisé pour la saisie et l'affichage des nombres.
enum DecimalSeparator { comma, dot }

/// Réglages locaux de l'application, persistés sur l'appareil uniquement
/// (aucune synchronisation, aucune télémétrie). Ne contient jamais
/// d'identité de patient.
class AppSettings {
  const AppSettings({
    this.decimalSeparator = DecimalSeparator.comma,
    this.historyEnabled = false,
    this.ldlDefaultFriedewald = true,
  });

  /// Virgule (convention française) ou point.
  final DecimalSeparator decimalSeparator;

  /// Historique local facultatif, désactivé par défaut (cf. cahier des
  /// charges : opt-in explicite, jamais de valeur par défaut favorisant la
  /// collecte).
  final bool historyEnabled;

  /// Équation présélectionnée à l'ouverture du panel LDL : `true` =
  /// Friedewald, `false` = Sampson. Ne change aucun résultat : l'équation
  /// reste modifiable avant le calcul.
  final bool ldlDefaultFriedewald;

  AppSettings copyWith({
    DecimalSeparator? decimalSeparator,
    bool? historyEnabled,
    bool? ldlDefaultFriedewald,
  }) {
    return AppSettings(
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
      historyEnabled: historyEnabled ?? this.historyEnabled,
      ldlDefaultFriedewald: ldlDefaultFriedewald ?? this.ldlDefaultFriedewald,
    );
  }

  Map<String, dynamic> toJson() => {
        'decimalSeparator': decimalSeparator.name,
        'historyEnabled': historyEnabled,
        'ldlDefaultFriedewald': ldlDefaultFriedewald,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        decimalSeparator: DecimalSeparator.values.firstWhere(
          (e) => e.name == json['decimalSeparator'],
          orElse: () => DecimalSeparator.comma,
        ),
        historyEnabled: json['historyEnabled'] as bool? ?? false,
        ldlDefaultFriedewald: json['ldlDefaultFriedewald'] as bool? ?? true,
      );
}
