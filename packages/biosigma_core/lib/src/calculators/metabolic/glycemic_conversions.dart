import '../../models/errors.dart';
import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';

/// Glycémie moyenne estimée (eAG) à partir de l'HbA1c — étude ADAG.
const FormulaMeta estimatedAverageGlucoseAdagMeta = FormulaMeta(
  id: 'estimated_average_glucose_adag',
  name: "Glycémie moyenne estimée (eAG) à partir de l'HbA1c",
  shortName: 'eAG (ADAG)',
  category: CalculatorCategory.metabolic,
  version: 'ADAG (Nathan 2008)',
  equation: 'eAG (mg/dL) = 28,7 × HbA1c(%) − 46,7',
  sources: [
    Reference(
      citation:
          'Nathan DM, Kuenen J, Borg R, Zheng H, Schoenfeld D, Heine RJ; '
          'A1c-Derived Average Glucose (ADAG) Study Group. Translating the '
          'A1C Assay Into Estimated Average Glucose Values. Diabetes Care. '
          '2008;31(8):1473-1478.',
    ),
  ],
  applicablePopulation: 'Adulte',
  forbiddenConditions: [
    'Hémoglobinopathie, anémie hémolytique, carence martiale, grossesse ou '
        "insuffisance rénale terminale affectant la durée de vie "
        "érythrocytaire — l'HbA1c ne reflète alors plus fidèlement la "
        "glycémie moyenne.",
  ],
  limitations: [
    "Estimation statistique de population ; peut différer notablement de "
        "la moyenne glycémique individuelle réelle (auto-surveillance ou "
        "capteur continu).",
  ],
);

/// Glycémie moyenne estimée (eAG) à partir d'une HbA1c (NGSP % ou IFCC
/// mmol/mol), selon l'équation ADAG (Nathan 2008).
CalculationResult calculateEstimatedAverageGlucose({
  required double hba1cValue,
  required String hba1cUnit,
}) {
  final hba1cError = Validation.checkPositive(hba1cValue, 'hba1cValue', 'HbA1c');
  Validation.raiseIfAny([hba1cError]);

  if (!UnitRegistry.unitsFor(Analyte.hba1c).contains(hba1cUnit)) {
    throw CalculationInputException([
      FieldError(
        fieldId: 'hba1cUnit',
        message: 'Unité "$hba1cUnit" inconnue pour l\'HbA1c.',
      ),
    ]);
  }

  final a1cPercent = UnitRegistry.toCanonical(Analyte.hba1c, hba1cValue, hba1cUnit);
  final eagMgDl = 28.7 * a1cPercent - 46.7;
  final eagMmolL = UnitRegistry.convert(Analyte.glucose, eagMgDl, fromUnit: 'mg/dL', toUnit: 'mmol/L');

  return CalculationResult(
    formula: estimatedAverageGlucoseAdagMeta,
    echoedInputs: {
      'HbA1c':
          '${hba1cValue.toStringAsFixed(2)} $hba1cUnit (${a1cPercent.toStringAsFixed(2)} % NGSP)',
    },
    values: [
      ResultValue(label: 'eAG', value: eagMgDl, unit: 'mg/dL', precision: 1),
      ResultValue(label: 'eAG', value: eagMmolL, unit: 'mmol/L', precision: 2),
    ],
  );
}
