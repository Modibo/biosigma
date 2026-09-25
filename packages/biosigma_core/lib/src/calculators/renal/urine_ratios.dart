import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';

/// Rapport albumine/créatinine urinaire.
const FormulaMeta urineAlbuminCreatinineRatioMeta = FormulaMeta(
  id: 'urine_albumin_creatinine_ratio',
  name: 'Rapport albumine/créatinine urinaire (ACR)',
  shortName: 'ACR urinaire',
  category: CalculatorCategory.renal,
  version: 'Rapport sur échantillon',
  equation: 'ACR = Albuminurie (mg/L) / Créatininurie (g/L ou mmol/L)',
  sources: [
    Reference(
      citation:
          'Kidney Disease: Improving Global Outcomes (KDIGO) CKD Work Group. '
          'KDIGO 2012 Clinical Practice Guideline for the Evaluation and '
          'Management of Chronic Kidney Disease. Kidney Int Suppl. '
          '2013;3(1):1-150.',
    ),
  ],
  applicablePopulation: 'Tout âge',
  limitations: [
    "Moins précis que la protéinurie des 24 h en cas de variation "
        "importante du débit urinaire (nycthéméral, hydratation).",
  ],
  displayPrecision: 1,
);

/// Rapport protéines/créatinine urinaire.
const FormulaMeta urineProteinCreatinineRatioMeta = FormulaMeta(
  id: 'urine_protein_creatinine_ratio',
  name: 'Rapport protéines/créatinine urinaire (PCR)',
  shortName: 'PCR urinaire',
  category: CalculatorCategory.renal,
  version: 'Rapport sur échantillon',
  equation: 'PCR = Protéinurie totale (mg/L) / Créatininurie (g/L ou mmol/L)',
  sources: [
    Reference(
      citation:
          'Kidney Disease: Improving Global Outcomes (KDIGO) CKD Work Group. '
          'KDIGO 2012 Clinical Practice Guideline for the Evaluation and '
          'Management of Chronic Kidney Disease. Kidney Int Suppl. '
          '2013;3(1):1-150.',
    ),
  ],
  applicablePopulation: 'Tout âge',
  limitations: [
    "Moins précis que la protéinurie des 24 h en cas de variation "
        "importante du débit urinaire (nycthéméral, hydratation).",
  ],
  displayPrecision: 1,
);

/// Clairance urinaire de la créatinine mesurée (urines minutées ou 24 h).
const FormulaMeta creatinineClearanceTimedMeta = FormulaMeta(
  id: 'creatinine_clearance_timed',
  name: 'Clairance de la créatinine MESURÉE (urines minutées ou 24 h)',
  shortName: 'Clairance créatinine mesurée',
  category: CalculatorCategory.renal,
  version: 'Clairance urinaire mesurée (urines minutées ou 24 h)',
  equation: 'ClCr = (Créat. urinaire × Volume urinaire) / (Créat. plasmatique × Durée)',
  sources: [
    Reference(
      citation:
          'National Kidney Foundation. KDOQI Clinical Practice Guidelines '
          'and Clinical Practice Recommendations.',
      note: 'formule classique de bilan de masse pour la clairance urinaire mesurée',
    ),
  ],
  applicablePopulation: 'Tout âge',
  limitations: [
    'Ne corrige pas pour la surface corporelle.',
    'Surestime le DFG réel du fait de la sécrétion tubulaire de créatinine, '
        "notamment aux stades avancés d'insuffisance rénale chronique.",
  ],
  displayPrecision: 1,
);

/// Fraction excrétée du sodium (FeNa).
const FormulaMeta fractionalExcretionSodiumMeta = FormulaMeta(
  id: 'fractional_excretion_sodium',
  name: 'Fraction excrétée du sodium (FeNa)',
  shortName: 'FeNa',
  category: CalculatorCategory.renal,
  version: 'FeNa (Espinel 1976)',
  equation: 'FeNa (%) = (Na urinaire × Créat. plasmatique) / (Na plasmatique × Créat. urinaire) × 100',
  sources: [
    Reference(
      citation:
          'Espinel CH. The FENa Test. Use in the Differential Diagnosis of '
          'Acute Renal Failure. JAMA. 1976;236(6):579-581.',
    ),
  ],
  applicablePopulation: 'Adulte, insuffisance rénale aiguë',
  limitations: [
    'Non interprétable sous diurétiques, en particulier les diurétiques de '
        "l'anse récents ; utiliser alors la fraction excrétée de l'urée.",
  ],
  helpText: 'Sodium en mmol/L (valeurs brutes, sans conversion d\'unité).',
  displayPrecision: 2,
);

/// Fraction excrétée de l'urée (FeUrea).
const FormulaMeta fractionalExcretionUreaMeta = FormulaMeta(
  id: 'fractional_excretion_urea',
  name: "Fraction excrétée de l'urée (FeUrée)",
  shortName: 'FeUrée',
  category: CalculatorCategory.renal,
  version: 'FeUrée (Carvounis 2002)',
  equation: 'FeUrée (%) = (Urée urinaire × Créat. plasmatique) / (Urée plasmatique × Créat. urinaire) × 100',
  sources: [
    Reference(
      citation:
          'Carvounis CP, Nisar S, Guro-Razuman S. Significance of the '
          'Fractional Excretion of Urea in the Differential Diagnosis of '
          'Acute Renal Failure. Kidney Int. 2002;62(6):2223-2229.',
    ),
  ],
  applicablePopulation: 'Adulte, insuffisance rénale aiguë, notamment sous diurétiques de l\'anse',
  limitations: [
    'Peut être altérée par les diurétiques thiazidiques et par un apport '
        'protéique très variable ; moins sensible que le FeNa aux '
        "diurétiques de l'anse.",
  ],
  helpText: "Urée en mmol/L (et non azote uréique / BUN).",
  displayPrecision: 2,
);

String _echoCreatinine(double value, String unit, double canonicalUmolL) {
  return unit == 'µmol/L'
      ? '${value.toStringAsFixed(1)} µmol/L'
      : '${value.toStringAsFixed(2)} $unit (${canonicalUmolL.toStringAsFixed(1)} µmol/L)';
}

CalculationResult _calculateRatio({
  required FormulaMeta formula,
  required String analyteLabel,
  required String resultLabel,
  required double analyteValue,
  required String analyteUnit,
  required double creatinineValue,
  required String creatinineUnit,
}) {
  final analyteError = Validation.checkPositive(analyteValue, 'analyteValue', analyteLabel);
  final creatinineError =
      Validation.checkPositive(creatinineValue, 'creatinineValue', 'Créatininurie');
  Validation.raiseIfAny([analyteError, creatinineError]);

  final analyteMgLCanonical =
      UnitRegistry.toCanonical(Analyte.proteinuria, analyteValue, analyteUnit);
  final creatUmolLCanonical =
      UnitRegistry.toCanonical(Analyte.creatinine, creatinineValue, creatinineUnit);
  final creatMgDl = UnitRegistry.fromCanonical(Analyte.creatinine, creatUmolLCanonical, 'mg/dL');
  final creatGL = creatMgDl * 0.01;
  final creatMmolL = creatUmolLCanonical / 1000;

  final ratioMgG = analyteMgLCanonical / creatGL;
  final ratioMgMmol = analyteMgLCanonical / creatMmolL;

  return CalculationResult(
    formula: formula,
    echoedInputs: {
      analyteLabel: analyteUnit == 'mg/L'
          ? '${analyteValue.toStringAsFixed(1)} mg/L'
          : '${analyteValue.toStringAsFixed(2)} $analyteUnit (${analyteMgLCanonical.toStringAsFixed(1)} mg/L)',
      'Créatininurie': _echoCreatinine(creatinineValue, creatinineUnit, creatUmolLCanonical),
    },
    values: [
      ResultValue(label: resultLabel, value: ratioMgG, unit: 'mg/g', precision: 1),
      ResultValue(label: resultLabel, value: ratioMgMmol, unit: 'mg/mmol', precision: 2),
    ],
  );
}

/// Rapport albumine/créatinine urinaire (ACR), sur échantillon urinaire.
CalculationResult calculateAlbuminCreatinineRatio({
  required double albuminValue,
  required String albuminUnit,
  required double creatinineValue,
  required String creatinineUnit,
}) {
  return _calculateRatio(
    formula: urineAlbuminCreatinineRatioMeta,
    analyteLabel: 'Albuminurie',
    resultLabel: 'Rapport albumine/créatinine urinaire',
    analyteValue: albuminValue,
    analyteUnit: albuminUnit,
    creatinineValue: creatinineValue,
    creatinineUnit: creatinineUnit,
  );
}

/// Rapport protéines/créatinine urinaire (PCR), sur échantillon urinaire.
CalculationResult calculateProteinCreatinineRatio({
  required double proteinValue,
  required String proteinUnit,
  required double creatinineValue,
  required String creatinineUnit,
}) {
  return _calculateRatio(
    formula: urineProteinCreatinineRatioMeta,
    analyteLabel: 'Protéinurie totale',
    resultLabel: 'Rapport protéines/créatinine urinaire',
    analyteValue: proteinValue,
    analyteUnit: proteinUnit,
    creatinineValue: creatinineValue,
    creatinineUnit: creatinineUnit,
  );
}

/// Clairance de la créatinine MESURÉE, à partir d'un recueil urinaire
/// minuté (urines minutées ou 24 h) et d'une créatininémie simultanée.
CalculationResult calculateTimedCreatinineClearance({
  required double urineCreatinineValue,
  required String urineCreatinineUnit,
  required double serumCreatinineValue,
  required String serumCreatinineUnit,
  required double urineVolumeValue,
  required String urineVolumeUnit,
  required double durationValue,
  required String durationUnit,
}) {
  final uCrError =
      Validation.checkPositive(urineCreatinineValue, 'urineCreatinineValue', 'Créatininurie');
  final pCrError =
      Validation.checkPositive(serumCreatinineValue, 'serumCreatinineValue', 'Créatininémie');
  final volumeError =
      Validation.checkPositive(urineVolumeValue, 'urineVolumeValue', 'Volume urinaire');
  final durationError = Validation.checkPositive(durationValue, 'durationValue', 'Durée de recueil');
  Validation.raiseIfAny([uCrError, pCrError, volumeError, durationError]);

  final uCrCanonical =
      UnitRegistry.toCanonical(Analyte.creatinine, urineCreatinineValue, urineCreatinineUnit);
  final pCrCanonical =
      UnitRegistry.toCanonical(Analyte.creatinine, serumCreatinineValue, serumCreatinineUnit);
  final volumeMlCanonical = UnitRegistry.toCanonical(Analyte.volume, urineVolumeValue, urineVolumeUnit);
  final durationMinCanonical = UnitRegistry.toCanonical(Analyte.duration, durationValue, durationUnit);

  final crCl = (uCrCanonical * volumeMlCanonical) / (pCrCanonical * durationMinCanonical);

  return CalculationResult(
    formula: creatinineClearanceTimedMeta,
    echoedInputs: {
      'Créatininurie': _echoCreatinine(urineCreatinineValue, urineCreatinineUnit, uCrCanonical),
      'Créatininémie': _echoCreatinine(serumCreatinineValue, serumCreatinineUnit, pCrCanonical),
      'Volume urinaire': urineVolumeUnit == 'mL'
          ? '${urineVolumeValue.toStringAsFixed(0)} mL'
          : '${urineVolumeValue.toStringAsFixed(3)} $urineVolumeUnit (${volumeMlCanonical.toStringAsFixed(0)} mL)',
      'Durée de recueil': durationUnit == 'min'
          ? '${durationValue.toStringAsFixed(0)} min'
          : '${durationValue.toStringAsFixed(2)} $durationUnit (${durationMinCanonical.toStringAsFixed(0)} min)',
    },
    values: [
      ResultValue(
        label: 'Clairance de la créatinine MESURÉE',
        value: crCl,
        unit: 'mL/min',
        precision: 1,
      ),
    ],
  );
}

/// Fraction excrétée du sodium (FeNa).
CalculationResult calculateFeNa({
  required double urineSodiumValue,
  required double serumSodiumValue,
  required double urineCreatinineValue,
  required String urineCreatinineUnit,
  required double serumCreatinineValue,
  required String serumCreatinineUnit,
}) {
  final uNaError = Validation.checkPositive(urineSodiumValue, 'urineSodiumValue', 'Sodium urinaire');
  final pNaError = Validation.checkPositive(serumSodiumValue, 'serumSodiumValue', 'Sodium plasmatique');
  final uCrError =
      Validation.checkPositive(urineCreatinineValue, 'urineCreatinineValue', 'Créatininurie');
  final pCrError =
      Validation.checkPositive(serumCreatinineValue, 'serumCreatinineValue', 'Créatininémie');
  Validation.raiseIfAny([uNaError, pNaError, uCrError, pCrError]);

  final uCrCanonical =
      UnitRegistry.toCanonical(Analyte.creatinine, urineCreatinineValue, urineCreatinineUnit);
  final pCrCanonical =
      UnitRegistry.toCanonical(Analyte.creatinine, serumCreatinineValue, serumCreatinineUnit);

  final feNa = (urineSodiumValue * pCrCanonical) / (serumSodiumValue * uCrCanonical) * 100;

  return CalculationResult(
    formula: fractionalExcretionSodiumMeta,
    echoedInputs: {
      'Sodium urinaire': '${urineSodiumValue.toStringAsFixed(1)} mmol/L',
      'Sodium plasmatique': '${serumSodiumValue.toStringAsFixed(1)} mmol/L',
      'Créatininurie': _echoCreatinine(urineCreatinineValue, urineCreatinineUnit, uCrCanonical),
      'Créatininémie': _echoCreatinine(serumCreatinineValue, serumCreatinineUnit, pCrCanonical),
    },
    values: [
      ResultValue(label: 'Fraction excrétée du sodium (FeNa)', value: feNa, unit: '%', precision: 2),
    ],
  );
}

/// Fraction excrétée de l'urée (FeUrée).
CalculationResult calculateFeUrea({
  required double urineUreaValue,
  required double serumUreaValue,
  required double urineCreatinineValue,
  required String urineCreatinineUnit,
  required double serumCreatinineValue,
  required String serumCreatinineUnit,
}) {
  final uUreaError = Validation.checkPositive(urineUreaValue, 'urineUreaValue', 'Urée urinaire');
  final sUreaError = Validation.checkPositive(serumUreaValue, 'serumUreaValue', 'Urée plasmatique');
  final uCrError =
      Validation.checkPositive(urineCreatinineValue, 'urineCreatinineValue', 'Créatininurie');
  final pCrError =
      Validation.checkPositive(serumCreatinineValue, 'serumCreatinineValue', 'Créatininémie');
  Validation.raiseIfAny([uUreaError, sUreaError, uCrError, pCrError]);

  final uCrCanonical =
      UnitRegistry.toCanonical(Analyte.creatinine, urineCreatinineValue, urineCreatinineUnit);
  final pCrCanonical =
      UnitRegistry.toCanonical(Analyte.creatinine, serumCreatinineValue, serumCreatinineUnit);

  final feUrea = (urineUreaValue * pCrCanonical) / (serumUreaValue * uCrCanonical) * 100;

  return CalculationResult(
    formula: fractionalExcretionUreaMeta,
    echoedInputs: {
      'Urée urinaire': '${urineUreaValue.toStringAsFixed(1)} mmol/L',
      'Urée plasmatique': '${serumUreaValue.toStringAsFixed(1)} mmol/L',
      'Créatininurie': _echoCreatinine(urineCreatinineValue, urineCreatinineUnit, uCrCanonical),
      'Créatininémie': _echoCreatinine(serumCreatinineValue, serumCreatinineUnit, pCrCanonical),
    },
    values: [
      ResultValue(label: "Fraction excrétée de l'urée (FeUrée)", value: feUrea, unit: '%', precision: 2),
    ],
  );
}
