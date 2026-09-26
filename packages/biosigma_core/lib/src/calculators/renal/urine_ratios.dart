import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';
import 'ckd_epi.dart' show kdigoGfrStageWarning;

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
      note: "contexte clinique ; catégories A1-A3 de l'albuminurie "
          '(interprétation)',
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
    "Contrairement à l'ACR, le PCR ne fait l'objet d'aucune catégorisation "
        "KDIGO formelle ; la correspondance avec le rang néphrotique "
        "(≥ 3000-3500 mg/g) est une approximation d'usage clinique, non "
        "un seuil de société savante.",
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
    Reference(
      citation:
          'Kidney Disease: Improving Global Outcomes (KDIGO) CKD Work Group. '
          'KDIGO 2012 Clinical Practice Guideline for the Evaluation and '
          'Management of Chronic Kidney Disease. Kidney Int Suppl. '
          '2013;3(1):1-150.',
      note: 'grille de stades du DFG G1-G5 appliquée par analogie, à titre '
          'informatif',
    ),
  ],
  applicablePopulation: 'Tout âge',
  limitations: [
    'Ne corrige pas pour la surface corporelle.',
    'Surestime le DFG réel du fait de la sécrétion tubulaire de créatinine, '
        "notamment aux stades avancés d'insuffisance rénale chronique.",
    "Le positionnement dans les catégories KDIGO ci-dessous est une "
        "approximation informative : la clairance mesurée n'est pas "
        "strictement équivalente au DFG estimé.",
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
      note: "formule et seuils classiques d'interprétation (< 1 % / > 2 %)",
    ),
  ],
  applicablePopulation: 'Adulte, insuffisance rénale aiguë',
  limitations: [
    'Non interprétable sous diurétiques, en particulier les diurétiques de '
        "l'anse récents ; utiliser alors la fraction excrétée de l'urée.",
    "Peu fiable également en cas d'insuffisance rénale chronique "
        "préexistante, de néphropathie aux produits de contraste, de "
        "glycosurie ou de protéinurie abondante préexistante.",
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
      note: "formule et seuils classiques d'interprétation (< 35 % / > 50 %)",
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

/// Catégories KDIGO de l'albuminurie (A1 à A3), sur le rapport
/// albumine/créatinine urinaire.
///
/// Kidney Disease: Improving Global Outcomes (KDIGO) CKD Work Group. KDIGO
/// 2012 Clinical Practice Guideline for the Evaluation and Management of
/// Chronic Kidney Disease. Kidney Int Suppl. 2013;3(1):1-150.
List<CalculationWarning> _uacrKdigoCategoryWarnings(double ratioMgG, double ratioMgMmol) {
  final String category;
  final String description;
  if (ratioMgG < 30) {
    category = 'A1';
    description = 'normale à légèrement augmentée';
  } else if (ratioMgG <= 300) {
    category = 'A2';
    description = 'modérément augmentée';
  } else {
    category = 'A3';
    description = 'sévèrement augmentée';
  }
  return [
    CalculationWarning(
      'Catégorie KDIGO $category : albuminurie $description (grille KDIGO '
      '— A1 < 30 mg/g [< 3 mg/mmol], A2 30-300 mg/g [3-30 mg/mmol], A3 '
      '> 300 mg/g [> 30 mg/mmol]).',
      severity: WarningSeverity.info,
    ),
  ];
}

/// Correspondance informelle du PCR avec le rang néphrotique : le PCR ne
/// fait l'objet d'aucune catégorisation KDIGO officielle (contrairement à
/// l'ACR) — repère de pratique clinique uniquement.
List<CalculationWarning> _upcrInformalNephroticRangeWarnings(double ratioMgG, double ratioMgMmol) {
  return [
    CalculationWarning(
      "Il n'existe pas de catégorisation KDIGO formelle du rapport "
      "protéines/créatinine (contrairement à l'ACR). Par correspondance "
      "approximative d'usage clinique, un PCR ≥ 3000-3500 mg/g (soit ≥ "
      "300-350 mg/mmol) est évocateur d'une protéinurie de rang "
      "néphrotique.",
      severity: WarningSeverity.info,
    ),
  ];
}

CalculationResult _calculateRatio({
  required FormulaMeta formula,
  required String analyteLabel,
  required String resultLabel,
  required double analyteValue,
  required String analyteUnit,
  required double creatinineValue,
  required String creatinineUnit,
  List<CalculationWarning> Function(double ratioMgG, double ratioMgMmol)? interpret,
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
    warnings: interpret == null ? const [] : interpret(ratioMgG, ratioMgMmol),
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
    interpret: _uacrKdigoCategoryWarnings,
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
    interpret: _upcrInformalNephroticRangeWarnings,
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
    warnings: [
      kdigoGfrStageWarning(crCl),
      const CalculationWarning(
        "Approximation informative : la clairance mesurée de la créatinine "
        "n'est pas strictement équivalente au DFG estimé (elle le "
        "surestime, notamment par sécrétion tubulaire de la créatinine) ; "
        "son positionnement dans les catégories KDIGO ci-dessus est donné "
        "à titre indicatif.",
        severity: WarningSeverity.info,
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
    warnings: [_feNaInterpretationWarning(feNa)],
  );
}

/// Interprétation classique de la FeNa dans le bilan étiologique d'une
/// insuffisance rénale aiguë (prérénale vs nécrose tubulaire aiguë).
///
/// Espinel CH. The FENa Test. Use in the Differential Diagnosis of Acute
/// Renal Failure. JAMA. 1976;236(6):579-581.
CalculationWarning _feNaInterpretationWarning(double feNa) {
  final String interpretation;
  if (feNa < 1) {
    interpretation = "évocatrice d'une cause prérénale (hypoperfusion "
        "rénale) plutôt que d'une nécrose tubulaire aiguë";
  } else if (feNa > 2) {
    interpretation = "évocatrice d'une cause rénale intrinsèque (nécrose "
        "tubulaire aiguë) plutôt que d'une cause prérénale";
  } else {
    interpretation = "dans la zone intermédiaire (1-2 %), peu discriminante "
        "entre cause prérénale et nécrose tubulaire aiguë";
  }
  return CalculationWarning(
    'FeNa $interpretation (repères classiques : < 1 % prérénal, > 2 % '
    "nécrose tubulaire aiguë). Non interprétable sous diurétiques ; utiliser "
    "alors la fraction excrétée de l'urée.",
    severity: WarningSeverity.info,
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
    warnings: [_feUreaInterpretationWarning(feUrea)],
  );
}

/// Interprétation classique de la FeUrée, utilisée notamment lorsque les
/// diurétiques rendent la FeNa ininterprétable.
///
/// Carvounis CP, Nisar S, Guro-Razuman S. Significance of the Fractional
/// Excretion of Urea in the Differential Diagnosis of Acute Renal Failure.
/// Kidney Int. 2002;62(6):2223-2229.
CalculationWarning _feUreaInterpretationWarning(double feUrea) {
  final String interpretation;
  if (feUrea < 35) {
    interpretation = "évocatrice d'une cause prérénale";
  } else if (feUrea > 50) {
    interpretation = "évocatrice d'une cause rénale intrinsèque (nécrose "
        "tubulaire aiguë)";
  } else {
    interpretation = "dans la zone intermédiaire (35-50 %), peu "
        "discriminante";
  }
  return CalculationWarning(
    'FeUrée $interpretation (repères classiques, utiles notamment sous '
    "diurétiques quand la FeNa n'est pas interprétable : < 35 % prérénal, "
    "> 50 % nécrose tubulaire aiguë).",
    severity: WarningSeverity.info,
  );
}
