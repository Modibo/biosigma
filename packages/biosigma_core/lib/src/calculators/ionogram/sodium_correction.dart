import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';

/// Sodium corrigé pour hyperglycémie — coefficients de Katz (1973) et de
/// Hillier (1999), toujours calculés et affichés côte à côte.
const FormulaMeta correctedSodiumHyperglycemiaMeta = FormulaMeta(
  id: 'corrected_sodium_hyperglycemia',
  name: 'Sodium corrigé pour hyperglycémie',
  shortName: 'Sodium corrigé',
  category: CalculatorCategory.ionogram,
  version: 'Katz 1973 (coefficient 1,6) et Hillier 1999 (coefficient 2,4)',
  equation:
      'Na corrigé = Na mesuré + coefficient × (Glycémie mg/dL − 100) / 100  '
      '(coefficient = 1,6 [Katz] ou 2,4 [Hillier])',
  sources: [
    Reference(
      citation:
          'Katz MA. Hyperglycemia-Induced Hyponatremia — Calculation of '
          'Expected Serum Sodium Depression. N Engl J Med. '
          '1973;289(16):843-844.',
    ),
    Reference(
      citation:
          'Hillier TA, Abbott RD, Barrett EJ. Hyponatremia: Evaluating the '
          'Correction Factor for Hyperglycemia. Am J Med. '
          '1999;106(4):399-403.',
    ),
  ],
  applicablePopulation: 'Tout âge',
  limitations: [
    'Les deux coefficients sont rapportés dans la littérature ; le '
        'laboratoire doit choisir et documenter celui qu\'il retient en '
        'pratique.',
  ],
);

/// Sodium corrigé pour hyperglycémie, selon les deux coefficients rapportés
/// dans la littérature (Katz 1,6 et Hillier 2,4), toujours calculés
/// ensemble.
CalculationResult calculateCorrectedSodium({
  required double sodiumValue,
  required double glucoseValue,
  required String glucoseUnit,
}) {
  final sodiumError = Validation.checkProvided(sodiumValue, 'sodiumValue', 'Sodium');
  final glucoseError = Validation.checkNonNegative(glucoseValue, 'glucoseValue', 'Glycémie');
  Validation.raiseIfAny([sodiumError, glucoseError]);

  final glucoseMgDl = UnitRegistry.convert(
    Analyte.glucose,
    glucoseValue,
    fromUnit: glucoseUnit,
    toUnit: 'mg/dL',
  );

  final correctionKatz = sodiumValue + 1.6 * (glucoseMgDl - 100) / 100;
  final correctionHillier = sodiumValue + 2.4 * (glucoseMgDl - 100) / 100;

  String categorize(double value) {
    if (value < 135) return 'hyponatrémie';
    if (value <= 145) return 'normal';
    return 'hypernatrémie';
  }

  final warnings = <CalculationWarning>[];
  if (glucoseMgDl <= 100) {
    warnings.add(const CalculationWarning(
      'Correction peu pertinente pour une glycémie ≤ 1,00 g/L (5,55 mmol/L).',
      severity: WarningSeverity.info,
    ));
  }
  warnings.add(CalculationWarning(
    'Repères habituels (mêmes bandes que le sodium non corrigé, biochimie '
    'clinique standard) : < 135 mmol/L hyponatrémie, 135-145 mmol/L '
    'normal, > 145 mmol/L hypernatrémie — appliqués ici à la valeur '
    'corrigée. Coefficient de Katz (1,6) : ${categorize(correctionKatz)} '
    '(${correctionKatz.toStringAsFixed(1)} mmol/L). Coefficient de '
    'Hillier (2,4) : ${categorize(correctionHillier)} '
    '(${correctionHillier.toStringAsFixed(1)} mmol/L).',
    severity: WarningSeverity.info,
  ));

  return CalculationResult(
    formula: correctedSodiumHyperglycemiaMeta,
    echoedInputs: {
      'Sodium': '${sodiumValue.toStringAsFixed(1)} mmol/L',
      'Glycémie': glucoseUnit == 'mg/dL'
          ? '${glucoseValue.toStringAsFixed(0)} mg/dL'
          : '${glucoseValue.toStringAsFixed(2)} $glucoseUnit (${glucoseMgDl.toStringAsFixed(0)} mg/dL)',
    },
    values: [
      ResultValue(
        label: 'Sodium corrigé — coefficient de Katz (1,6)',
        value: correctionKatz,
        unit: 'mmol/L',
      ),
      ResultValue(
        label: 'Sodium corrigé — coefficient de Hillier (2,4)',
        value: correctionHillier,
        unit: 'mmol/L',
      ),
    ],
    warnings: warnings,
  );
}
