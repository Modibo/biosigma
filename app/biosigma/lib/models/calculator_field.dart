import 'package:biosigma_core/biosigma_core.dart';

/// Nature d'un champ de saisie dans un écran de calculateur générique.
enum FieldKind {
  /// Nombre avec sélecteur d'unité (lié à un [Analyte] du moteur).
  numberWithUnit,

  /// Nombre dans une unité fixe (affichée en suffixe, non modifiable).
  numberFixedUnit,

  /// Case à cocher (ex. confirmation IDMS, prélèvement à jeun).
  boolean,

  /// Choix exclusif parmi une liste de valeurs typées (ex. [Sex],
  /// `LdlFormula`, `RosnerTimingPhase`).
  enumSelect,

  /// Texte libre court (ex. libellé de l'analyte suivi dans un calcul de
  /// tendance sériée). Rare — préférer les autres natures de champ quand
  /// c'est possible.
  text,
}

/// Une option d'un champ [FieldKind.enumSelect] : la valeur typée réelle
/// (transmise telle quelle à la fonction de calcul) et son libellé
/// d'affichage français.
class EnumFieldOption<T> {
  const EnumFieldOption({required this.value, required this.label, this.description});
  final T value;
  final String label;
  final String? description;
}

/// Valeur saisie pour un champ numérique : la donnée et l'unité choisie
/// par l'utilisateur (avant conversion, qui reste de la responsabilité du
/// moteur de calcul pur).
class NumericEntry {
  const NumericEntry(this.value, this.unit);
  final double? value;
  final String unit;

  NumericEntry copyWith({double? value, String? unit}) =>
      NumericEntry(value ?? this.value, unit ?? this.unit);
}

/// Description déclarative d'un champ de saisie, utilisée par l'écran
/// calculateur générique pour construire le formulaire sans code
/// spécifique par calcul.
class CalculatorFieldSpec {
  const CalculatorFieldSpec({
    required this.id,
    required this.label,
    required this.kind,
    this.analyte,
    this.defaultUnit,
    this.fixedUnitLabel,
    this.helpText,
    this.required = true,
    this.enumOptions,
    this.defaultBoolValue = false,
    this.allowNegative = false,
    this.defaultText,
  });

  final String id;
  final String label;
  final FieldKind kind;

  /// Requis si [kind] == [FieldKind.numberWithUnit] : détermine les unités
  /// proposées via `UnitRegistry.unitsFor(analyte)`.
  final Analyte? analyte;

  /// Unité présélectionnée (par défaut la première de `unitsFor`).
  final String? defaultUnit;

  /// Requis si [kind] == [FieldKind.numberFixedUnit] : unité affichée en
  /// suffixe, non modifiable par l'utilisateur (ex. "mmol/L" pour le
  /// sodium, hors périmètre de conversion du moteur).
  final String? fixedUnitLabel;

  final String? helpText;

  final bool required;

  /// Requis si [kind] == [FieldKind.enumSelect].
  final List<EnumFieldOption>? enumOptions;

  final bool defaultBoolValue;

  /// Si `false` (par défaut), une valeur négative saisie déclenche une
  /// erreur de validation côté interface, avant même l'appel au moteur.
  final bool allowNegative;

  /// Valeur initiale pour [FieldKind.text].
  final String? defaultText;
}
