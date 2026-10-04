import 'dart:math' as math;

import '../../models/errors.dart';
import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../models/sex.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';

/// DFG estimé — CKD-EPI créatinine 2021 (sans coefficient racial).
const FormulaMeta ckdEpiCreatinine2021Meta = FormulaMeta(
  id: 'ckd_epi_creatinine_2021',
  name: 'DFG estimé — CKD-EPI créatinine 2021 (sans coefficient racial)',
  shortName: 'CKD-EPI créatinine 2021',
  category: CalculatorCategory.renal,
  version: 'CKD-EPI 2021',
  equation:
      'DFG = 142 × min(Scr/κ,1)^α × max(Scr/κ,1)^-1,200 × 0,9938^Âge × 1,012 [si femme]  '
      '(Scr en mg/dL ; κ=0,7 femme/0,9 homme ; α=-0,241 femme/-0,302 homme)',
  sources: [
    Reference(
      citation:
          'Inker LA, Eneanya ND, Coresh J, et al. New Creatinine- and Cystatin '
          'C-Based Equations to Estimate GFR without Race. N Engl J Med. '
          '2021;385(19):1737-1749.',
    ),
    Reference(
      citation:
          'Kidney Disease: Improving Global Outcomes (KDIGO) CKD Work Group. '
          'KDIGO 2012 Clinical Practice Guideline for the Evaluation and '
          'Management of Chronic Kidney Disease. Kidney Int Suppl. '
          '2013;3(1):1-150.',
      note: 'stades du DFG G1-G5 (interprétation clinique)',
    ),
  ],
  applicablePopulation: 'Adulte ≥ 18 ans',
  forbiddenConditions: ['Âge < 18 ans'],
  analyticalConditions: ['Créatinine sérique standardisée IDMS'],
  limitations: [
    "Non valide en cas d'insuffisance rénale aiguë, de grossesse, de masse "
        "musculaire extrême, de régime végétarien strict ou de "
        "complémentation en créatine.",
    "Ne remplace pas une mesure de clairance lorsque celle-ci est "
        "cliniquement indiquée.",
    "Le diagnostic formel de maladie rénale chronique nécessite la "
        "persistance de l'anomalie du DFG au-delà de 3 mois ; une valeur "
        "isolée oriente sans permettre de conclure (KDIGO).",
  ],
  displayPrecision: 1,
);

/// DFG estimé — CKD-EPI cystatine C 2012.
const FormulaMeta ckdEpiCystatinC2012Meta = FormulaMeta(
  id: 'ckd_epi_cystatin_c_2012',
  name: 'DFG estimé — CKD-EPI cystatine C 2012',
  shortName: 'CKD-EPI cystatine C 2012',
  category: CalculatorCategory.renal,
  version: 'CKD-EPI cystatine C 2012',
  equation:
      'DFG = 133 × min(Cys/0,8,1)^-0,499 × max(Cys/0,8,1)^-1,328 × 0,996^Âge '
      '× 0,932 [si femme]  (Cys en mg/L)',
  sources: [
    Reference(
      citation:
          'Inker LA, Schmid CH, Tighiouart H, et al. Estimating Glomerular '
          'Filtration Rate from Serum Creatinine and Cystatin C. N Engl J '
          'Med. 2012;367(1):20-29.',
    ),
    Reference(
      citation:
          'Kidney Disease: Improving Global Outcomes (KDIGO) CKD Work Group. '
          'KDIGO 2012 Clinical Practice Guideline for the Evaluation and '
          'Management of Chronic Kidney Disease. Kidney Int Suppl. '
          '2013;3(1):1-150.',
      note: 'stades du DFG G1-G5 (interprétation clinique)',
    ),
  ],
  applicablePopulation: 'Adulte ≥ 18 ans',
  forbiddenConditions: ['Âge < 18 ans'],
  analyticalConditions: ['Dosage de cystatine C standardisé (matériau de référence IRMM/ERM-DA471/IFCC)'],
  limitations: [
    "Équations pédiatriques de cystatine C non implémentées ici.",
    "La cystatine C peut être modifiée par l'inflammation, la corticothérapie, "
        "les dysthyroïdies et l'obésité, indépendamment du DFG.",
    "Le diagnostic formel de maladie rénale chronique nécessite la "
        "persistance de l'anomalie du DFG au-delà de 3 mois ; une valeur "
        "isolée oriente sans permettre de conclure (KDIGO).",
  ],
  displayPrecision: 1,
);

/// DFG estimé — CKD-EPI créatinine-cystatine C 2021.
const FormulaMeta ckdEpiCreatinineCystatinC2021Meta = FormulaMeta(
  id: 'ckd_epi_creatinine_cystatin_c_2021',
  name: 'DFG estimé — CKD-EPI créatinine-cystatine C 2021',
  shortName: 'CKD-EPI créatinine-cystatine C 2021',
  category: CalculatorCategory.renal,
  version: 'CKD-EPI créatinine-cystatine C 2021 (version 2 du registre : α corrigés)',
  equation:
      'DFG = 135 × min(Scr/κ,1)^α × max(Scr/κ,1)^-0,544 × min(Cys/0,8,1)^-0,323 '
      '× max(Cys/0,8,1)^-0,778 × 0,9961^Âge × 0,963 [si femme]  '
      '(Scr en mg/dL ; Cys en mg/L ; κ=0,7 femme/0,9 homme ; α=-0,219 femme/-0,144 homme)',
  sources: [
    Reference(
      citation:
          'Inker LA, Eneanya ND, Coresh J, et al. New Creatinine- and Cystatin '
          'C-Based Equations to Estimate GFR without Race. N Engl J Med. '
          '2021;385(19):1737-1749.',
    ),
    Reference(
      citation:
          'Kidney Disease: Improving Global Outcomes (KDIGO) CKD Work Group. '
          'KDIGO 2012 Clinical Practice Guideline for the Evaluation and '
          'Management of Chronic Kidney Disease. Kidney Int Suppl. '
          '2013;3(1):1-150.',
      note: 'stades du DFG G1-G5 (interprétation clinique)',
    ),
  ],
  applicablePopulation: 'Adulte ≥ 18 ans',
  forbiddenConditions: ['Âge < 18 ans'],
  analyticalConditions: [
    'Créatinine sérique standardisée IDMS',
    'Dosage de cystatine C standardisé (matériau de référence IRMM/ERM-DA471/IFCC)',
  ],
  limitations: [
    "Non valide en cas d'insuffisance rénale aiguë, de grossesse, de masse "
        "musculaire extrême, de régime végétarien strict ou de "
        "complémentation en créatine.",
    "Ne remplace pas une mesure de clairance lorsque celle-ci est "
        "cliniquement indiquée.",
    "Le diagnostic formel de maladie rénale chronique nécessite la "
        "persistance de l'anomalie du DFG au-delà de 3 mois ; une valeur "
        "isolée oriente sans permettre de conclure (KDIGO).",
  ],
  displayPrecision: 1,
);

/// Interprétation du DFG selon les catégories KDIGO (stades G1 à G5),
/// communes aux trois équations CKD-EPI de ce fichier.
///
/// Kidney Disease: Improving Global Outcomes (KDIGO) CKD Work Group. KDIGO
/// 2012 Clinical Practice Guideline for the Evaluation and Management of
/// Chronic Kidney Disease. Kidney Int Suppl. 2013;3(1):1-150.
CalculationWarning kdigoGfrStageWarning(double egfr) {
  final String stage;
  final String description;
  if (egfr >= 90) {
    stage = 'G1';
    description = 'normal ou élevé';
  } else if (egfr >= 60) {
    stage = 'G2';
    description = 'légèrement diminué';
  } else if (egfr >= 45) {
    stage = 'G3a';
    description = 'modérément diminué';
  } else if (egfr >= 30) {
    stage = 'G3b';
    description = 'modérément à sévèrement diminué';
  } else if (egfr >= 15) {
    stage = 'G4';
    description = 'sévèrement diminué';
  } else {
    stage = 'G5';
    description = 'insuffisance rénale terminale (ou proche)';
  }
  return CalculationWarning(
    'Stade KDIGO $stage : DFG $description (grille KDIGO — G1 ≥ 90, '
    'G2 60-89, G3a 45-59, G3b 30-44, G4 15-29, G5 < 15 mL/min/1,73 m²). '
    "Une seule mesure oriente vers une maladie rénale chronique sans la "
    "diagnostiquer formellement : le diagnostic de MRC exige la "
    "persistance de l'anomalie au-delà de 3 mois.",
    severity: WarningSeverity.info,
  );
}

String _formatCreatinineEchoed(double value, String unit, double canonicalUmolL, double mgDl) {
  if (unit == 'mg/dL') {
    return '${value.toStringAsFixed(2)} mg/dL (${canonicalUmolL.toStringAsFixed(1)} µmol/L)';
  }
  return '${value.toStringAsFixed(1)} µmol/L (${mgDl.toStringAsFixed(2)} mg/dL)';
}

/// DFG estimé par l'équation CKD-EPI créatinine 2021 (sans coefficient
/// racial), chez l'adulte.
CalculationResult calculateCkdEpiCreatinine2021({
  required double age,
  required Sex sex,
  required double creatinineValue,
  required String creatinineUnit,
  required bool idmsConfirmed,
}) {
  final ageError = Validation.checkPositive(age, 'age', 'Âge');
  final creatinineError =
      Validation.checkPositive(creatinineValue, 'creatinineValue', 'Créatininémie');
  Validation.raiseIfAny([ageError, creatinineError]);

  if (age < 18) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'age',
        message:
            "Cette équation s'applique à l'adulte (≥ 18 ans) ; utiliser "
            "Schwartz bedside chez l'enfant.",
      ),
    ]);
  }

  if (!idmsConfirmed) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'idmsConfirmed',
        message:
            "Confirmez que la créatininémie est standardisée IDMS avant de "
            "calculer ce DFG.",
      ),
    ]);
  }

  final creatinineCanonicalUmolL =
      UnitRegistry.toCanonical(Analyte.creatinine, creatinineValue, creatinineUnit);
  final scrMgDl = UnitRegistry.fromCanonical(Analyte.creatinine, creatinineCanonicalUmolL, 'mg/dL');

  final kappa = sex == Sex.female ? 0.7 : 0.9;
  final alpha = sex == Sex.female ? -0.241 : -0.302;
  final egfr = 142 *
      math.pow(math.min(scrMgDl / kappa, 1), alpha) *
      math.pow(math.max(scrMgDl / kappa, 1), -1.200) *
      math.pow(0.9938, age) *
      (sex == Sex.female ? 1.012 : 1.0);

  return CalculationResult(
    formula: ckdEpiCreatinine2021Meta,
    echoedInputs: {
      'Âge': '${age.toStringAsFixed(0)} ans',
      'Sexe': sex.label,
      'Créatinine':
          _formatCreatinineEchoed(creatinineValue, creatinineUnit, creatinineCanonicalUmolL, scrMgDl),
    },
    values: [
      ResultValue(
        label: 'DFG CKD-EPI créatinine 2021',
        value: egfr.toDouble(),
        unit: 'mL/min/1,73 m²',
        precision: 1,
      ),
    ],
    warnings: [kdigoGfrStageWarning(egfr.toDouble())],
  );
}

/// DFG estimé par l'équation CKD-EPI cystatine C 2012, chez l'adulte.
CalculationResult calculateCkdEpiCystatinC2012({
  required double age,
  required Sex sex,
  required double cystatinCValue,
  required String cystatinCUnit,
}) {
  final ageError = Validation.checkPositive(age, 'age', 'Âge');
  final cystatinCError =
      Validation.checkPositive(cystatinCValue, 'cystatinCValue', 'Cystatine C');
  Validation.raiseIfAny([ageError, cystatinCError]);

  if (age < 18) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'age',
        message:
            "Cette équation s'applique à l'adulte (≥ 18 ans) ; les équations "
            "pédiatriques de cystatine C ne sont pas implémentées dans ce "
            "calculateur.",
      ),
    ]);
  }

  final cystatinCCanonicalMgL =
      UnitRegistry.toCanonical(Analyte.cystatinC, cystatinCValue, cystatinCUnit);

  final egfr = 133 *
      math.pow(math.min(cystatinCCanonicalMgL / 0.8, 1), -0.499) *
      math.pow(math.max(cystatinCCanonicalMgL / 0.8, 1), -1.328) *
      math.pow(0.996, age) *
      (sex == Sex.female ? 0.932 : 1.0);

  return CalculationResult(
    formula: ckdEpiCystatinC2012Meta,
    echoedInputs: {
      'Âge': '${age.toStringAsFixed(0)} ans',
      'Sexe': sex.label,
      'Cystatine C': cystatinCUnit == 'mg/L'
          ? '${cystatinCValue.toStringAsFixed(2)} mg/L'
          : '${cystatinCValue.toStringAsFixed(2)} $cystatinCUnit (${cystatinCCanonicalMgL.toStringAsFixed(2)} mg/L)',
    },
    values: [
      ResultValue(
        label: 'DFG CKD-EPI cystatine C 2012',
        value: egfr.toDouble(),
        unit: 'mL/min/1,73 m²',
        precision: 1,
      ),
    ],
    warnings: [kdigoGfrStageWarning(egfr.toDouble())],
  );
}

/// DFG estimé par l'équation combinée CKD-EPI créatinine-cystatine C 2021,
/// chez l'adulte.
CalculationResult calculateCkdEpiCreatinineCystatinC2021({
  required double age,
  required Sex sex,
  required double creatinineValue,
  required String creatinineUnit,
  required double cystatinCValue,
  required String cystatinCUnit,
  required bool idmsConfirmed,
}) {
  final ageError = Validation.checkPositive(age, 'age', 'Âge');
  final creatinineError =
      Validation.checkPositive(creatinineValue, 'creatinineValue', 'Créatininémie');
  final cystatinCError =
      Validation.checkPositive(cystatinCValue, 'cystatinCValue', 'Cystatine C');
  Validation.raiseIfAny([ageError, creatinineError, cystatinCError]);

  if (age < 18) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'age',
        message:
            "Cette équation s'applique à l'adulte (≥ 18 ans) ; utiliser "
            "Schwartz bedside chez l'enfant.",
      ),
    ]);
  }

  if (!idmsConfirmed) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'idmsConfirmed',
        message:
            "Confirmez que la créatininémie est standardisée IDMS avant de "
            "calculer ce DFG.",
      ),
    ]);
  }

  final creatinineCanonicalUmolL =
      UnitRegistry.toCanonical(Analyte.creatinine, creatinineValue, creatinineUnit);
  final scrMgDl = UnitRegistry.fromCanonical(Analyte.creatinine, creatinineCanonicalUmolL, 'mg/dL');
  final cystatinCCanonicalMgL =
      UnitRegistry.toCanonical(Analyte.cystatinC, cystatinCValue, cystatinCUnit);

  final kappa = sex == Sex.female ? 0.7 : 0.9;
  // Équation combinée 2021 : α = −0,219 (femme) / −0,144 (homme), DIFFÉRENT de
  // l'équation à la créatinine seule (−0,241 / −0,302). Corrigé en version 2
  // de l'équation (la version 1 reprenait par erreur les α de la créatinine
  // seule : surestimation du DFG quand la créatininémie est < κ).
  final alpha = sex == Sex.female ? -0.219 : -0.144;
  final egfr = 135 *
      math.pow(math.min(scrMgDl / kappa, 1), alpha) *
      math.pow(math.max(scrMgDl / kappa, 1), -0.544) *
      math.pow(math.min(cystatinCCanonicalMgL / 0.8, 1), -0.323) *
      math.pow(math.max(cystatinCCanonicalMgL / 0.8, 1), -0.778) *
      math.pow(0.9961, age) *
      (sex == Sex.female ? 0.963 : 1.0);

  return CalculationResult(
    formula: ckdEpiCreatinineCystatinC2021Meta,
    echoedInputs: {
      'Âge': '${age.toStringAsFixed(0)} ans',
      'Sexe': sex.label,
      'Créatinine':
          _formatCreatinineEchoed(creatinineValue, creatinineUnit, creatinineCanonicalUmolL, scrMgDl),
      'Cystatine C': cystatinCUnit == 'mg/L'
          ? '${cystatinCValue.toStringAsFixed(2)} mg/L'
          : '${cystatinCValue.toStringAsFixed(2)} $cystatinCUnit (${cystatinCCanonicalMgL.toStringAsFixed(2)} mg/L)',
    },
    values: [
      ResultValue(
        label: 'DFG CKD-EPI créatinine-cystatine C 2021',
        value: egfr.toDouble(),
        unit: 'mL/min/1,73 m²',
        precision: 1,
      ),
    ],
    warnings: [kdigoGfrStageWarning(egfr.toDouble())],
  );
}
