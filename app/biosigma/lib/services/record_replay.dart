import 'package:biosigma_core/biosigma_core.dart';

import '../models/calculation_record.dart';
import '../models/calculator_definition.dart';
import '../models/calculator_field.dart';

/// Rejoue un enregistrement v2 avec l'équation actuelle (backlog P1-14,
/// test T-TRC-001). Opération **explicite** : un enregistrement n'est jamais
/// recalculé silencieusement.
class RecordReplay {
  RecordReplay._();

  /// Reconstruit les valeurs de formulaire attendues par `CalculatorDefinition.compute`.
  /// Renvoie `null` si l'enregistrement n'est pas rejouable ou ne correspond
  /// pas à la définition (champ manquant, option inconnue).
  static Map<String, dynamic>? buildValues(CalculatorDefinition definition, CalculationRecord record) {
    if (!record.replayable || record.equationId != definition.meta.id) return null;
    final values = <String, dynamic>{};
    for (final field in definition.fields) {
      final raw = record.rawInputs[field.id];
      if (raw == null && field.kind != FieldKind.enumSelect) return null;
      switch (field.kind) {
        case FieldKind.numberWithUnit:
        case FieldKind.numberFixedUnit:
          final m = raw as Map;
          values[field.id] = NumericEntry((m['value'] as num?)?.toDouble(), m['unit'] as String);
        case FieldKind.boolean:
          values[field.id] = raw as bool;
        case FieldKind.enumSelect:
          final label = (raw as Map?)?['option'] as String?;
          if (label == null) {
            values[field.id] = null;
          } else {
            final matches = field.enumOptions!.where((o) => o.label == label);
            if (matches.isEmpty) return null;
            values[field.id] = matches.first.value;
          }
        case FieldKind.text:
          values[field.id] = raw as String;
      }
    }
    return values;
  }

  /// Rejoue le calcul ; `null` si l'enregistrement n'est pas rejouable.
  static CalculationResult? replay(CalculatorDefinition definition, CalculationRecord record) {
    final values = buildValues(definition, record);
    return values == null ? null : definition.compute(values);
  }
}
