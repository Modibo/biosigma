import 'models/errors.dart';

/// Contrôles de saisie communs à tous les calculateurs, produisant des
/// [FieldError] en français rattachées au champ concerné. Prévient NaN,
/// infini, division par zéro, logarithme de valeur non positive et champs
/// manquants.
class Validation {
  Validation._();

  static FieldError? checkProvided(double? value, String fieldId, String label) {
    if (value == null) {
      return FieldError(fieldId: fieldId, message: '$label est requis.');
    }
    if (value.isNaN || value.isInfinite) {
      return FieldError(fieldId: fieldId, message: '$label doit être un nombre valide.');
    }
    return null;
  }

  static FieldError? checkPositive(double? value, String fieldId, String label) {
    final provided = checkProvided(value, fieldId, label);
    if (provided != null) return provided;
    if (value! <= 0) {
      return FieldError(fieldId: fieldId, message: '$label doit être strictement positif.');
    }
    return null;
  }

  static FieldError? checkNonNegative(double? value, String fieldId, String label) {
    final provided = checkProvided(value, fieldId, label);
    if (provided != null) return provided;
    if (value! < 0) {
      return FieldError(fieldId: fieldId, message: '$label ne peut pas être négatif.');
    }
    return null;
  }

  static FieldError? checkInRange(
    double? value,
    String fieldId,
    String label, {
    required double min,
    required double max,
  }) {
    final provided = checkProvided(value, fieldId, label);
    if (provided != null) return provided;
    if (value! < min || value > max) {
      return FieldError(
        fieldId: fieldId,
        message: '$label doit être compris entre $min et $max.',
      );
    }
    return null;
  }

  /// Rassemble les erreurs non nulles et lève une [CalculationInputException]
  /// si la liste n'est pas vide. À appeler en fin de validation d'un
  /// calculateur, après avoir collecté tous les contrôles de champ.
  static void raiseIfAny(List<FieldError?> checks) {
    final errors = checks.whereType<FieldError>().toList();
    if (errors.isNotEmpty) {
      throw CalculationInputException(errors);
    }
  }
}
