import 'dart:math' as math;

import '../../models/errors.dart';
import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';

/// QUICKI (Quantitative Insulin Sensitivity Check Index).
const FormulaMeta quickiMeta = FormulaMeta(
  id: 'quicki',
  name: 'QUICKI (Quantitative Insulin Sensitivity Check Index)',
  shortName: 'QUICKI',
  category: CalculatorCategory.metabolic,
  version: 'Katz 2000',
  equation:
      'QUICKI = 1 / [log10(Insulinémie à jeun, µU/mL) + log10(Glycémie à '
      'jeun, mg/dL)]',
  sources: [
    Reference(
      citation:
          'Katz A, Nambi SS, Mather K, et al. Quantitative Insulin '
          'Sensitivity Check Index: A Simple, Accurate Method for Assessing '
          'Insulin Sensitivity In Humans. J Clin Endocrinol Metab. '
          '2000;85(7):2402-2410.',
    ),
  ],
  applicablePopulation: 'Adulte, prélèvement strictement à jeun',
  analyticalConditions: [
    "Prélèvement à jeun (≥ 8 h)",
    "Dosage d'insuline standardisé",
  ],
  limitations: [
    "Indice indirect d'insulinosensibilité, non une mesure directe "
        "(référence : clamp euglycémique hyperinsulinémique).",
  ],
  displayPrecision: 4,
);

/// Indice TyG (Triglyceride-Glucose Index).
const FormulaMeta tygMeta = FormulaMeta(
  id: 'tyg_index',
  name: 'Indice TyG (Triglyceride-Glucose Index)',
  shortName: 'TyG',
  category: CalculatorCategory.metabolic,
  version: 'Simental-Mendía 2008 — convention TG(mg/dL)×Glu(mg/dL)/2',
  equation:
      'TyG = ln[(Triglycérides à jeun, mg/dL × Glycémie à jeun, mg/dL) / 2]',
  sources: [
    Reference(
      citation:
          'Simental-Mendía LE, Rodríguez-Morán M, Guerrero-Romero F. The '
          'Product of Fasting Glucose and Triglycerides As Surrogate for '
          'Identifying Insulin Resistance in Apparently Healthy Subjects. '
          'Metab Syndr Relat Disord. 2008;6(4):299-304.',
    ),
  ],
  applicablePopulation: 'Adulte, prélèvement à jeun',
  limitations: [
    "Il existe dans la littérature d'autres conventions de notation ou de "
        "placement des parenthèses pour le TyG (ex. unités mmol/L, ou "
        "dénominateur différent) : ne jamais comparer ce résultat à un "
        "seuil publié pour une autre convention.",
  ],
  displayPrecision: 3,
);

/// HOMA-IR (Homeostasis Model Assessment).
const FormulaMeta homaIrMeta = FormulaMeta(
  id: 'homa_ir',
  name: 'HOMA-IR (Homeostasis Model Assessment)',
  shortName: 'HOMA-IR',
  category: CalculatorCategory.metabolic,
  version: 'Matthews 1985 — forme SI (glycémie mmol/L, diviseur 22,5)',
  equation: 'HOMA-IR = (Glycémie à jeun, mmol/L × Insulinémie à jeun, µU/mL) / 22,5',
  sources: [
    Reference(
      citation:
          'Matthews DR, Hosker JP, Rudenski AS, Naylor BA, Treacher DF, '
          'Turner RC. Homeostasis Model Assessment: Insulin Resistance and '
          'Beta-Cell Function From Fasting Plasma Glucose and Insulin '
          'Concentrations in Man. Diabetologia. 1985;28(7):412-419.',
    ),
  ],
  applicablePopulation: 'Adulte, prélèvement à jeun',
  limitations: [
    "Indice indirect d'insulinorésistance (référence : clamp euglycémique "
        "hyperinsulinémique).",
    "Forme équivalente en mg/dL : HOMA-IR = (Glycémie mg/dL × Insulinémie "
        "µU/mL) / 405 — donne le même résultat numérique à la conversion "
        "près.",
    "Les seuils publiés varient selon la population et la méthode de "
        "dosage de l'insuline — à valider localement.",
  ],
  displayPrecision: 2,
);

double _log10(double x) => math.log(x) / math.ln10;

/// Avertissement honnête d'absence de seuil consensuel de société savante
/// pour les indices d'insulinorésistance/sensibilité (QUICKI, TyG, HOMA-IR) :
/// voir la RÈGLE DE SÉCURITÉ CRITIQUE — ne jamais présenter un seuil publié
/// dans une étude de population comme une recommandation d'une société
/// savante (ADA/EASD/IDF) pour ces indices.
const CalculationWarning _noConsensusThresholdQuicki = CalculationWarning(
  "Aucun seuil diagnostique consensuel n'est actuellement recommandé par une "
  'société savante (ADA/EASD/IDF) pour le QUICKI ; à titre purement '
  "informatif, des seuils ont été proposés dans certaines études de "
  'population (ex. QUICKI < 0,33-0,35 évocateur d\'une insulinorésistance), '
  "mais ce sont des seuils de recherche spécifiques à leur population "
  "d'étude, à ne pas généraliser ni utiliser comme seuil diagnostique "
  'universel.',
  severity: WarningSeverity.info,
);

const CalculationWarning _noConsensusThresholdTyg = CalculationWarning(
  "Aucun seuil diagnostique consensuel n'est actuellement recommandé par une "
  "société savante (ADA/EASD/IDF) pour l'indice TyG ; à titre purement "
  'informatif, des seuils ont été proposés dans certaines études de '
  "population (ex. TyG > 4,5 évocateur d'une insulinorésistance), mais ce "
  "sont des seuils de recherche spécifiques à leur population d'étude (et à "
  "la convention de notation utilisée), à ne pas généraliser ni utiliser "
  'comme seuil diagnostique universel.',
  severity: WarningSeverity.info,
);

const CalculationWarning _noConsensusThresholdHomaIr = CalculationWarning(
  "Aucun seuil diagnostique consensuel n'est actuellement recommandé par une "
  "société savante (ADA/EASD/IDF) pour le HOMA-IR ; à titre purement "
  'informatif, des seuils ont été proposés dans certaines études de '
  "population (ex. HOMA-IR > 2,5), mais ce sont des seuils de recherche "
  "spécifiques à leur population d'étude et à la méthode de dosage de "
  "l'insuline, à ne pas généraliser ni utiliser comme seuil diagnostique "
  'universel.',
  severity: WarningSeverity.info,
);

void _checkFastingConfirmed(bool fastingConfirmed) {
  if (!fastingConfirmed) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'fastingConfirmed',
        message: "Confirmez que le prélèvement est réalisé à jeun.",
      ),
    ]);
  }
}

/// QUICKI (Katz 2000) à partir de l'insulinémie et de la glycémie à jeun.
CalculationResult calculateQuicki({
  required double fastingInsulinValue,
  required String fastingInsulinUnit,
  required double fastingGlucoseValue,
  required String fastingGlucoseUnit,
  required bool fastingConfirmed,
}) {
  final insulinError =
      Validation.checkPositive(fastingInsulinValue, 'fastingInsulinValue', 'Insulinémie à jeun');
  final glucoseError =
      Validation.checkPositive(fastingGlucoseValue, 'fastingGlucoseValue', 'Glycémie à jeun');
  Validation.raiseIfAny([insulinError, glucoseError]);
  _checkFastingConfirmed(fastingConfirmed);

  final insulinUUmL =
      UnitRegistry.toCanonical(Analyte.insulin, fastingInsulinValue, fastingInsulinUnit);
  final glucoseCanonicalMmolL =
      UnitRegistry.toCanonical(Analyte.glucose, fastingGlucoseValue, fastingGlucoseUnit);
  final glucoseMgDl = UnitRegistry.fromCanonical(Analyte.glucose, glucoseCanonicalMmolL, 'mg/dL');

  final quicki = 1 / (_log10(insulinUUmL) + _log10(glucoseMgDl));

  return CalculationResult(
    formula: quickiMeta,
    echoedInputs: {
      'Insulinémie à jeun':
          '${fastingInsulinValue.toStringAsFixed(2)} $fastingInsulinUnit (${insulinUUmL.toStringAsFixed(2)} µU/mL)',
      'Glycémie à jeun':
          '${fastingGlucoseValue.toStringAsFixed(2)} $fastingGlucoseUnit '
              '(${glucoseCanonicalMmolL.toStringAsFixed(3)} mmol/L, ${glucoseMgDl.toStringAsFixed(1)} mg/dL)',
      'Prélèvement à jeun': 'confirmé',
    },
    values: [
      ResultValue(label: 'QUICKI', value: quicki, unit: '', precision: 4),
    ],
    warnings: const [_noConsensusThresholdQuicki],
  );
}

/// Indice TyG (Simental-Mendía 2008) à partir des triglycérides et de la
/// glycémie à jeun, exprimés en mg/dL.
CalculationResult calculateTyg({
  required double triglyceridesValue,
  required String triglyceridesUnit,
  required double fastingGlucoseValue,
  required String fastingGlucoseUnit,
  required bool fastingConfirmed,
}) {
  final tgError =
      Validation.checkPositive(triglyceridesValue, 'triglyceridesValue', 'Triglycérides à jeun');
  final glucoseError =
      Validation.checkPositive(fastingGlucoseValue, 'fastingGlucoseValue', 'Glycémie à jeun');
  Validation.raiseIfAny([tgError, glucoseError]);
  _checkFastingConfirmed(fastingConfirmed);

  final tgCanonicalMmolL =
      UnitRegistry.toCanonical(Analyte.triglycerides, triglyceridesValue, triglyceridesUnit);
  final tgMgDl = UnitRegistry.fromCanonical(Analyte.triglycerides, tgCanonicalMmolL, 'mg/dL');
  final glucoseCanonicalMmolL =
      UnitRegistry.toCanonical(Analyte.glucose, fastingGlucoseValue, fastingGlucoseUnit);
  final glucoseMgDl = UnitRegistry.fromCanonical(Analyte.glucose, glucoseCanonicalMmolL, 'mg/dL');

  final tyg = math.log((tgMgDl * glucoseMgDl) / 2);

  return CalculationResult(
    formula: tygMeta,
    echoedInputs: {
      'Triglycérides à jeun':
          '${triglyceridesValue.toStringAsFixed(2)} $triglyceridesUnit (${tgMgDl.toStringAsFixed(1)} mg/dL)',
      'Glycémie à jeun':
          '${fastingGlucoseValue.toStringAsFixed(2)} $fastingGlucoseUnit (${glucoseMgDl.toStringAsFixed(1)} mg/dL)',
      'Prélèvement à jeun': 'confirmé',
    },
    values: [
      ResultValue(label: 'Indice TyG', value: tyg, unit: '', precision: 3),
    ],
    warnings: const [_noConsensusThresholdTyg],
  );
}

/// HOMA-IR (Matthews 1985, forme SI) à partir de l'insulinémie et de la
/// glycémie à jeun.
CalculationResult calculateHomaIr({
  required double fastingInsulinValue,
  required String fastingInsulinUnit,
  required double fastingGlucoseValue,
  required String fastingGlucoseUnit,
  required bool fastingConfirmed,
}) {
  final insulinError =
      Validation.checkPositive(fastingInsulinValue, 'fastingInsulinValue', 'Insulinémie à jeun');
  final glucoseError =
      Validation.checkPositive(fastingGlucoseValue, 'fastingGlucoseValue', 'Glycémie à jeun');
  Validation.raiseIfAny([insulinError, glucoseError]);
  _checkFastingConfirmed(fastingConfirmed);

  final insulinUUmL =
      UnitRegistry.toCanonical(Analyte.insulin, fastingInsulinValue, fastingInsulinUnit);
  final glucoseMmolL =
      UnitRegistry.toCanonical(Analyte.glucose, fastingGlucoseValue, fastingGlucoseUnit);

  final homaIr = (glucoseMmolL * insulinUUmL) / 22.5;

  return CalculationResult(
    formula: homaIrMeta,
    echoedInputs: {
      'Insulinémie à jeun':
          '${fastingInsulinValue.toStringAsFixed(2)} $fastingInsulinUnit (${insulinUUmL.toStringAsFixed(2)} µU/mL)',
      'Glycémie à jeun':
          '${fastingGlucoseValue.toStringAsFixed(2)} $fastingGlucoseUnit (${glucoseMmolL.toStringAsFixed(3)} mmol/L)',
      'Prélèvement à jeun': 'confirmé',
    },
    values: [
      ResultValue(label: 'HOMA-IR', value: homaIr, unit: '', precision: 2),
    ],
    warnings: const [_noConsensusThresholdHomaIr],
  );
}
