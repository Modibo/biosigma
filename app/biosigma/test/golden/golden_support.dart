// Construction des valeurs de formulaire à partir des entrées canoniques du
// golden master (partagée par le golden master et les tests de traçabilité).
import 'package:biosigma/models/calculator_definition.dart';
import 'package:biosigma/models/calculator_field.dart';
import 'package:biosigma_core/biosigma_core.dart';

import 'golden_inputs.dart';

String defaultUnitOf(CalculatorFieldSpec f) =>
    f.defaultUnit ?? UnitRegistry.unitsFor(f.analyte!).first;

/// Construit la table de valeurs attendue par `CalculatorDefinition.compute`
/// (même forme que l'écran), en appliquant des surcharges éventuelles.
Map<String, dynamic> buildGoldenValues(
  CalculatorDefinition def,
  Map<String, Object> base, {
  String? enumField,
  int? enumIndex,
  String? unitField,
  String? unit,
}) {
  final values = <String, dynamic>{};
  for (final f in def.fields) {
    final given = base[f.id];
    switch (f.kind) {
      case FieldKind.numberWithUnit:
        final value = given is N ? given.value : null;
        var u = given is N ? (given.unit ?? defaultUnitOf(f)) : defaultUnitOf(f);
        if (f.id == unitField) u = unit!;
        values[f.id] = NumericEntry(value, u);
      case FieldKind.numberFixedUnit:
        values[f.id] = NumericEntry(given is N ? given.value : null, f.fixedUnitLabel ?? '');
      case FieldKind.boolean:
        values[f.id] = given is bool ? given : f.defaultBoolValue;
      case FieldKind.enumSelect:
        var index = given is E ? given.index : null;
        if (f.id == enumField) index = enumIndex;
        values[f.id] = index == null ? null : f.enumOptions![index].value;
      case FieldKind.text:
        values[f.id] = given is String ? given : (f.defaultText ?? '');
    }
  }
  return values;
}

