/// Erreur de saisie rattachée à un champ précis, avec un message en
/// français destiné à être affiché près de ce champ.
class FieldError {
  const FieldError({required this.fieldId, required this.message});

  /// Identifiant du champ concerné (correspond à l'id déclaré dans le
  /// `CalculatorDefinition` de l'application).
  final String fieldId;

  /// Message d'erreur en français, prêt à l'affichage.
  final String message;

  @override
  String toString() => '$fieldId: $message';
}

/// Exception levée par un calculateur lorsque les données saisies ne
/// permettent pas un calcul valide (valeur manquante, négative, nulle
/// interdite par un logarithme ou un dénominateur, unité incompatible,
/// population hors champ d'application, condition analytique non remplie).
///
/// Ne contient jamais de message générique : chaque erreur cible un champ.
class CalculationInputException implements Exception {
  CalculationInputException(this.errors) : assert(errors.isNotEmpty);

  final List<FieldError> errors;

  @override
  String toString() =>
      'CalculationInputException: ${errors.map((e) => e.toString()).join('; ')}';
}
