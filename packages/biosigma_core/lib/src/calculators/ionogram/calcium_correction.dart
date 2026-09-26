import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';

/// Calcium corrigé pour l'albuminémie (Payne 1973).
const FormulaMeta correctedCalciumAlbuminMeta = FormulaMeta(
  id: 'corrected_calcium_albumin',
  name: "Calcium corrigé pour l'albuminémie",
  shortName: 'Calcium corrigé',
  category: CalculatorCategory.ionogram,
  version: 'Payne 1973',
  equation: 'Ca corrigé (mg/dL) = Ca mesuré (mg/dL) + 0,8 × (4,0 − Albumine g/dL)',
  sources: [
    Reference(
      citation:
          'Payne RB, Little AJ, Williams RB, Milner JR. Interpretation of '
          'Serum Calcium in Patients With Abnormal Serum Proteins. Br Med J. '
          '1973;4(5893):643-646.',
    ),
  ],
  applicablePopulation: 'Tout âge',
  limitations: [
    'Estimation indirecte : ne remplace jamais un calcium ionisé mesuré, qui '
        'doit toujours être saisi et interprété comme une donnée distincte, '
        'jamais déduite automatiquement de ce résultat.',
    "Moins fiable en cas d'acidose ou d'alcalose sévère, ou de "
        'dysprotéinémie marquée (ex. myélome).',
  ],
);

/// Calcium corrigé pour l'albuminémie, formule historique de Payne (1973),
/// exprimée en mg/dL puis reconvertie en mmol/L.
CalculationResult calculateCorrectedCalcium({
  required double calciumValue,
  required String calciumUnit,
  required double albuminValue,
  required String albuminUnit,
}) {
  final calciumError = Validation.checkPositive(calciumValue, 'calciumValue', 'Calcium');
  final albuminError = Validation.checkPositive(albuminValue, 'albuminValue', 'Albuminémie');
  Validation.raiseIfAny([calciumError, albuminError]);

  final calciumMgDl = UnitRegistry.convert(
    Analyte.calcium,
    calciumValue,
    fromUnit: calciumUnit,
    toUnit: 'mg/dL',
  );
  final albuminGDl = UnitRegistry.convert(
    Analyte.albumin,
    albuminValue,
    fromUnit: albuminUnit,
    toUnit: 'g/dL',
  );

  final correctedMgDl = calciumMgDl + 0.8 * (4.0 - albuminGDl);
  final correctedMmolL =
      UnitRegistry.convert(Analyte.calcium, correctedMgDl, fromUnit: 'mg/dL', toUnit: 'mmol/L');

  final String category;
  if (correctedMgDl < 8.5) {
    category = 'hypocalcémie';
  } else if (correctedMgDl <= 10.5) {
    category = 'normal';
  } else {
    category = 'hypercalcémie';
  }

  return CalculationResult(
    formula: correctedCalciumAlbuminMeta,
    echoedInputs: {
      'Calcium': calciumUnit == 'mg/dL'
          ? '${calciumValue.toStringAsFixed(2)} mg/dL'
          : '${calciumValue.toStringAsFixed(2)} $calciumUnit (${calciumMgDl.toStringAsFixed(2)} mg/dL)',
      'Albuminémie': albuminUnit == 'g/dL'
          ? '${albuminValue.toStringAsFixed(1)} g/dL'
          : '${albuminValue.toStringAsFixed(1)} $albuminUnit (${albuminGDl.toStringAsFixed(2)} g/dL)',
    },
    values: [
      ResultValue(
        label: "Calcium corrigé pour l'albuminémie",
        value: correctedMgDl,
        unit: 'mg/dL',
      ),
      ResultValue(
        label: "Calcium corrigé pour l'albuminémie",
        value: correctedMmolL,
        unit: 'mmol/L',
      ),
    ],
    warnings: [
      CalculationWarning(
        'Calcium corrigé : $category (repères usuels de biochimie '
        'clinique standard, appliqués à la valeur corrigée : '
        'hypocalcémie < 8,5 mg/dL [< 2,10 mmol/L] ; normal '
        '8,5-10,5 mg/dL [2,10-2,55 mmol/L] ; hypercalcémie > 10,5 mg/dL '
        '[> 2,55 mmol/L]).',
        severity: WarningSeverity.info,
      ),
    ],
  );
}
