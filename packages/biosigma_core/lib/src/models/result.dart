import 'formula_meta.dart';

/// Sévérité d'un avertissement accompagnant un résultat.
enum WarningSeverity {
  /// Information neutre (ex. rappel de convention de notation).
  info,

  /// Point de vigilance clinique ou analytique.
  caution,

  /// Le résultat ne doit pas être utilisé tel quel (ex. hors domaine de
  /// validité) ; l'interface doit le mettre en évidence fortement.
  blocking,
}

/// Avertissement structuré, en français, associé à un résultat.
class CalculationWarning {
  const CalculationWarning(this.message, {this.severity = WarningSeverity.caution});

  final String message;
  final WarningSeverity severity;
}

/// Une valeur numérique de résultat (un calcul peut en produire plusieurs,
/// ex. le panel LDL/non-HDL/ratios, ou les trois DFG CKD-EPI affichés côte
/// à côte).
class ResultValue {
  const ResultValue({
    required this.label,
    required this.value,
    required this.unit,
    this.precision = 2,
  });

  /// Libellé affiché (ex. "DFG CKD-EPI créatinine 2021").
  final String label;

  /// Valeur numérique, ou `null` si non calculable dans le contexte
  /// (ex. cystatine C absente pour le panel combiné).
  final double? value;

  final String unit;

  /// Décimales à l'affichage pour cette valeur précise.
  final int precision;

  bool get isComputed => value != null && value!.isFinite;
}

/// Résultat complet d'un calcul : valeur(s), formule et unités utilisées,
/// version/source, entrées échoïsées, avertissements et limites d'emploi.
/// Ne représente jamais un résultat comme un diagnostic isolé.
class CalculationResult {
  const CalculationResult({
    required this.formula,
    required this.echoedInputs,
    required this.values,
    this.warnings = const [],
    this.isComplete = true,
  });

  final FormulaMeta formula;

  /// Entrées telles qu'utilisées par le calcul, après conversion, pour
  /// affichage ("Créatinine : 88 µmol/L (saisie : 1.0 mg/dL)").
  final Map<String, String> echoedInputs;

  final List<ResultValue> values;

  final List<CalculationWarning> warnings;

  /// `false` pour les scores guidés (ISTH-CIVD, 4Ts) lorsque des données
  /// requises manquent encore : l'interface doit alors afficher
  /// « score incomplet » plutôt qu'inférer la donnée absente.
  final bool isComplete;

  bool get hasBlockingWarning =>
      warnings.any((w) => w.severity == WarningSeverity.blocking);
}
