import '../../models/errors.dart';
import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';

/// DFG estimé — Schwartz bedside 2009 (pédiatrie).
const FormulaMeta schwartzBedsidePediatricMeta = FormulaMeta(
  id: 'schwartz_bedside_pediatric',
  name: 'DFG estimé — Schwartz bedside (formule pédiatrique)',
  shortName: 'Schwartz bedside',
  category: CalculatorCategory.renal,
  version: 'Schwartz bedside 2009 (k=0,413)',
  equation: 'DFG = 0,413 × Taille(cm) / Créatinine(mg/dL)',
  sources: [
    Reference(
      citation:
          'Schwartz GJ, Muñoz A, Schneider MF, et al. New Equations to '
          'Estimate GFR in Children with CKD. J Am Soc Nephrol. '
          '2009;20(3):629-637.',
    ),
  ],
  applicablePopulation:
      'Enfant et adolescent, 1 à 18 ans (zone de transition 18-25 ans à '
      'interpréter avec prudence)',
  forbiddenConditions: ['Âge < 1 an ou > 25 ans'],
  analyticalConditions: [
    'Constante k=0,413 valable pour une créatinine standardisée IDMS dosée '
        'par méthode enzymatique.',
  ],
  limitations: [
    "Ne pas appliquer automatiquement CKD-EPI (adulte) chez l'enfant.",
    "La constante k historique de Schwartz était différente (0,55) pour une "
        "créatinine dosée par méthode de Jaffé non standardisée IDMS.",
  ],
  displayPrecision: 1,
);

/// DFG estimé chez l'enfant par la formule Schwartz bedside 2009.
CalculationResult calculateSchwartzBedside({
  required double ageYears,
  required double heightCm,
  required double creatinineValue,
  required String creatinineUnit,
}) {
  final ageError = Validation.checkPositive(ageYears, 'ageYears', 'Âge');
  final heightError = Validation.checkPositive(heightCm, 'heightCm', 'Taille');
  final creatinineError =
      Validation.checkPositive(creatinineValue, 'creatinineValue', 'Créatininémie');
  Validation.raiseIfAny([ageError, heightError, creatinineError]);

  if (ageYears < 1 || ageYears > 25) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'ageYears',
        message:
            "Cette formule s'applique de 1 à 25 ans ; au-delà, utiliser "
            "l'équation CKD-EPI adulte.",
      ),
    ]);
  }

  final creatinineCanonicalUmolL =
      UnitRegistry.toCanonical(Analyte.creatinine, creatinineValue, creatinineUnit);
  final scrMgDl = UnitRegistry.fromCanonical(Analyte.creatinine, creatinineCanonicalUmolL, 'mg/dL');

  final egfr = 0.413 * heightCm / scrMgDl;

  final warnings = <CalculationWarning>[];
  if (ageYears >= 18 && ageYears <= 25) {
    warnings.add(const CalculationWarning(
      "Zone de transition jeune adulte : envisager selon le contexte "
      "clinique l'équation CKD-EPI adulte.",
      severity: WarningSeverity.caution,
    ));
  }

  return CalculationResult(
    formula: schwartzBedsidePediatricMeta,
    echoedInputs: {
      'Âge': '${ageYears.toStringAsFixed(1)} ans',
      'Taille': '${heightCm.toStringAsFixed(1)} cm',
      'Créatinine': creatinineUnit == 'mg/dL'
          ? '${creatinineValue.toStringAsFixed(2)} mg/dL (${creatinineCanonicalUmolL.toStringAsFixed(1)} µmol/L)'
          : '${creatinineValue.toStringAsFixed(1)} µmol/L (${scrMgDl.toStringAsFixed(2)} mg/dL)',
    },
    values: [
      ResultValue(
        label: 'DFG Schwartz bedside',
        value: egfr,
        unit: 'mL/min/1,73 m²',
        precision: 1,
      ),
    ],
    warnings: warnings,
  );
}
