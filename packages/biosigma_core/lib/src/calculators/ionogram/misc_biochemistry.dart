import 'dart:math' as math;

import '../../models/errors.dart';
import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';

// ---------------------------------------------------------------------------
// a) Capacité totale de fixation du fer (CTF), calculée à partir de la
//    transferrine.
// ---------------------------------------------------------------------------

const FormulaMeta tibcFromTransferrinMeta = FormulaMeta(
  id: 'tibc_from_transferrin',
  name: 'CTF calculée à partir de la transferrine',
  shortName: 'CTF calculée',
  category: CalculatorCategory.ionogram,
  version: 'Facteur usuel ×1,42',
  equation: 'CTF (µg/dL) = Transferrine (mg/dL) × 1,42',
  sources: [
    Reference(
      citation:
          'Facteur de conversion usuel de biochimie clinique (transferrine ↔ '
          'CTF théorique) ; à confirmer selon les recommandations du '
          "fournisseur du réactif du laboratoire.",
    ),
  ],
  applicablePopulation: 'Tout âge',
  limitations: [
    'Facteur approximatif supposant une saturation théorique de la '
        'transferrine en fer ; peut varier légèrement selon la méthode.',
  ],
  helpText: 'Transferrine en mg/dL.',
);

/// Capacité totale de fixation du fer (CTF), estimée à partir de la
/// transferrinémie par le facteur usuel ×1,42.
CalculationResult calculateTibcFromTransferrin({required double transferrinMgDl}) {
  Validation.raiseIfAny([
    Validation.checkPositive(transferrinMgDl, 'transferrinMgDl', 'Transferrine'),
  ]);

  final tibc = transferrinMgDl * 1.42;

  return CalculationResult(
    formula: tibcFromTransferrinMeta,
    echoedInputs: {
      'Transferrine': '${transferrinMgDl.toStringAsFixed(0)} mg/dL',
    },
    values: [
      ResultValue(
        label: 'Capacité totale de fixation du fer (calculée)',
        value: tibc,
        unit: 'µg/dL',
      ),
    ],
    warnings: const [
      CalculationWarning(
        'Repère général (enseignement de biochimie clinique, pas de '
        "guideline unique dédiée à ce facteur de conversion) : la CTF est "
        "usuellement augmentée en cas de carence martiale et diminuée en "
        "cas d'inflammation ou de surcharge en fer ; interpréter par "
        "rapport à l'intervalle de référence propre au laboratoire.",
        severity: WarningSeverity.info,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// b) Coefficient de saturation de la transferrine.
// ---------------------------------------------------------------------------

const FormulaMeta transferrinSaturationMeta = FormulaMeta(
  id: 'transferrin_saturation',
  name: 'Coefficient de saturation de la transferrine',
  shortName: 'Saturation transferrine',
  category: CalculatorCategory.ionogram,
  version: 'Rapport fer sérique / CTF',
  equation: 'Saturation (%) = Fer sérique (µg/dL) / CTF (µg/dL) × 100',
  sources: [
    Reference(
      citation:
          'International Committee for Standardization in Haematology '
          '(ICSH). Recommendations for Measurement of Serum Iron in Serum. '
          'Br J Haematol. 1978;38(2):291-294.',
    ),
    Reference(
      citation:
          'Bacon BR, Adams PC, Kowdley KV, Powell LW, Tavill AS; American '
          'Association for the Study of Liver Diseases. Diagnosis and '
          'Management of Hemochromatosis: 2011 Practice Guideline by the '
          'American Association for the Study of Liver Diseases. '
          'Hepatology. 2011;54(1):328-343.',
      note: "seuils d'interprétation (dépistage de l'hémochromatose)",
    ),
  ],
  applicablePopulation: 'Tout âge',
  limitations: [
    'Facteur de conversion et valeurs de référence dépendants de la méthode '
        'analytique du laboratoire.',
  ],
  helpText:
      'Fer sérique et CTF en µg/dL (utilise calculateTibcFromTransferrin si '
      'seule la transferrine est disponible).',
);

/// Coefficient de saturation de la transferrine (fer sérique / CTF).
CalculationResult calculateTransferrinSaturation({
  required double serumIronUgDl,
  required double tibcUgDl,
}) {
  Validation.raiseIfAny([
    Validation.checkNonNegative(serumIronUgDl, 'serumIronUgDl', 'Fer sérique'),
    Validation.checkPositive(tibcUgDl, 'tibcUgDl', 'CTF'),
  ]);

  final tsat = serumIronUgDl / tibcUgDl * 100;

  final String tsatInterpretation;
  if (tsat > 45) {
    tsatInterpretation =
        'Saturation > 45 % : seuil de dépistage retenu par l\'AASLD 2011 '
        "pour poursuivre les investigations d'une hémochromatose "
        'héréditaire (ex. génotypage HFE).';
  } else if (tsat < 20) {
    tsatInterpretation =
        'Saturation < 20 % : évocatrice d\'une carence en fer.';
  } else {
    tsatInterpretation = 'Saturation dans la zone intermédiaire usuelle '
        '(20-45 %), ni évocatrice de carence martiale, ni du seuil de '
        "dépistage de l'hémochromatose retenu par l'AASLD 2011.";
  }

  return CalculationResult(
    formula: transferrinSaturationMeta,
    echoedInputs: {
      'Fer sérique': '${serumIronUgDl.toStringAsFixed(0)} µg/dL',
      'CTF': '${tibcUgDl.toStringAsFixed(0)} µg/dL',
    },
    values: [
      ResultValue(
        label: 'Coefficient de saturation de la transferrine',
        value: tsat,
        unit: '%',
      ),
    ],
    warnings: [
      CalculationWarning(
        tsatInterpretation,
        severity: WarningSeverity.info,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// c) Globulines et rapport albumine/globulines.
// ---------------------------------------------------------------------------

const FormulaMeta globulinsAgRatioMeta = FormulaMeta(
  id: 'globulins_ag_ratio',
  name: 'Globulines et rapport albumine/globulines',
  shortName: 'Globulines et A/G',
  category: CalculatorCategory.ionogram,
  version: 'Bilan de masse (protéines totales − albuminémie)',
  equation:
      'Globulines (g/L) = Protéines totales (g/L) − Albumine (g/L)  ;  '
      'Rapport A/G = Albumine / Globulines',
  sources: [
    Reference(
      citation:
          'Calcul standard de biochimie clinique (protéines totales − '
          "albuminémie), principe de l'électrophorèse des protéines "
          'sériques.',
    ),
  ],
  applicablePopulation: 'Tout âge',
  limitations: [
    "Estimation indirecte des globulines ; l'électrophorèse des protéines "
        'sériques reste la référence pour caractériser les fractions '
        'protéiques.',
  ],
);

/// Globulines (par différence) et rapport albumine/globulines.
CalculationResult calculateGlobulinsAndRatio({
  required double totalProteinValue,
  required String totalProteinUnit,
  required double albuminValue,
  required String albuminUnit,
}) {
  final totalProteinError =
      Validation.checkPositive(totalProteinValue, 'totalProteinValue', 'Protéines totales');
  final albuminError = Validation.checkPositive(albuminValue, 'albuminValue', 'Albuminémie');
  Validation.raiseIfAny([totalProteinError, albuminError]);

  final tpGL = UnitRegistry.convert(
    Analyte.albumin,
    totalProteinValue,
    fromUnit: totalProteinUnit,
    toUnit: 'g/L',
  );
  final albGL =
      UnitRegistry.convert(Analyte.albumin, albuminValue, fromUnit: albuminUnit, toUnit: 'g/L');

  if (albGL > tpGL) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'albuminValue',
        message: "L'albuminémie ne peut pas dépasser les protéines totales.",
      ),
    ]);
  }

  final globulines = tpGL - albGL;

  final values = <ResultValue>[
    ResultValue(
      label: 'Globulines',
      value: globulines,
      unit: 'g/L',
    ),
  ];

  final warnings = <CalculationWarning>[];

  if (globulines > 0) {
    final ratio = albGL / globulines;
    values.add(ResultValue(
      label: 'Rapport albumine/globulines',
      value: ratio,
      unit: '',
      precision: 2,
    ));
    warnings.add(CalculationWarning(
      ratio < 1
          ? 'Rapport A/G bas ou inversé (< 1) : repère d\'enseignement '
              'classique de biochimie clinique (pas de guideline unique '
              'dédiée), associé notamment à la cirrhose, à un état '
              'inflammatoire chronique ou à une gammapathie monoclonale ; à '
              'corréler avec les autres données cliniques et biologiques '
              '(électrophorèse des protéines).'
          : 'Rapport A/G ≥ 1 : dans la zone habituelle (repère '
              "d'enseignement classique de biochimie clinique ; un rapport "
              'bas ou inversé, < 1, est classiquement associé à la '
              'cirrhose, à un état inflammatoire chronique ou à une '
              'gammapathie monoclonale).',
      severity: WarningSeverity.info,
    ));
  }

  return CalculationResult(
    formula: globulinsAgRatioMeta,
    echoedInputs: {
      'Protéines totales': totalProteinUnit == 'g/L'
          ? '${totalProteinValue.toStringAsFixed(1)} g/L'
          : '${totalProteinValue.toStringAsFixed(2)} $totalProteinUnit (${tpGL.toStringAsFixed(1)} g/L)',
      'Albuminémie': albuminUnit == 'g/L'
          ? '${albuminValue.toStringAsFixed(1)} g/L'
          : '${albuminValue.toStringAsFixed(2)} $albuminUnit (${albGL.toStringAsFixed(1)} g/L)',
    },
    values: values,
    warnings: warnings,
  );
}

// ---------------------------------------------------------------------------
// d) Bilirubine indirecte (bilan de masse totale − directe).
// ---------------------------------------------------------------------------

const FormulaMeta indirectBilirubinMeta = FormulaMeta(
  id: 'indirect_bilirubin',
  name: 'Bilirubine indirecte',
  shortName: 'Bilirubine indirecte',
  category: CalculatorCategory.ionogram,
  version: 'Bilan de masse (totale − directe)',
  equation: 'Bilirubine indirecte = Bilirubine totale − Bilirubine directe',
  sources: [
    Reference(
      citation:
          'Calcul standard de biochimie clinique (bilan de masse bilirubine '
          'totale − directe).',
    ),
  ],
  applicablePopulation: 'Tout âge',
  helpText: 'Bilirubine totale et directe en µmol/L.',
);

/// Bilirubine indirecte, obtenue par différence entre bilirubine totale et
/// bilirubine directe (conjuguée).
CalculationResult calculateIndirectBilirubin({
  required double totalBilirubinUmolL,
  required double directBilirubinUmolL,
}) {
  final totalError =
      Validation.checkNonNegative(totalBilirubinUmolL, 'totalBilirubinUmolL', 'Bilirubine totale');
  final directError = Validation.checkNonNegative(
      directBilirubinUmolL, 'directBilirubinUmolL', 'Bilirubine directe');
  Validation.raiseIfAny([totalError, directError]);

  if (directBilirubinUmolL > totalBilirubinUmolL) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'directBilirubinUmolL',
        message: 'La bilirubine directe ne peut pas dépasser la bilirubine totale.',
      ),
    ]);
  }

  final indirecte = totalBilirubinUmolL - directBilirubinUmolL;

  return CalculationResult(
    formula: indirectBilirubinMeta,
    echoedInputs: {
      'Bilirubine totale': '${totalBilirubinUmolL.toStringAsFixed(1)} µmol/L',
      'Bilirubine directe': '${directBilirubinUmolL.toStringAsFixed(1)} µmol/L',
    },
    values: [
      ResultValue(
        label: 'Bilirubine indirecte',
        value: indirecte,
        unit: 'µmol/L',
      ),
    ],
    warnings: const [
      CalculationWarning(
        "Repère habituel (enseignement de biochimie clinique, pas de "
        "guideline dédiée) : bilirubine totale usuellement < 17 µmol/L "
        "chez l'adulte, majoritairement sous forme indirecte à l'état "
        'normal.',
        severity: WarningSeverity.info,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// e) Rapport ASAT/ALAT (De Ritis).
// ---------------------------------------------------------------------------

const FormulaMeta astAltRatioDeRitisMeta = FormulaMeta(
  id: 'ast_alt_ratio_de_ritis',
  name: 'Rapport ASAT/ALAT (De Ritis)',
  shortName: 'Rapport De Ritis',
  category: CalculatorCategory.ionogram,
  version: 'De Ritis 1957',
  equation: 'Rapport De Ritis = ASAT / ALAT',
  sources: [
    Reference(
      citation:
          'De Ritis F, Coltorti M, Giusti G. An Enzymic Test for the '
          'Diagnosis of Viral Hepatitis; the Transaminase Serum Activities. '
          'Clin Chim Acta. 1957;2(1):70-74.',
    ),
  ],
  applicablePopulation: 'Tout âge',
  helpText: 'ASAT et ALAT en U/L.',
);

/// Rapport ASAT/ALAT (De Ritis).
CalculationResult calculateAstAltRatio({required double astUL, required double altUL}) {
  Validation.raiseIfAny([
    Validation.checkNonNegative(astUL, 'astUL', 'ASAT'),
    Validation.checkPositive(altUL, 'altUL', 'ALAT'),
  ]);

  final ratio = astUL / altUL;

  final String interpretation;
  if (ratio > 2) {
    interpretation =
        'Rapport > 2 : évocateur d\'une hépatite alcoolique, selon un '
        "repère d'enseignement classique (issu des travaux princeps de De "
        'Ritis) — il ne s\'agit pas d\'un seuil diagnostique formellement '
        'endossé par une société savante actuelle.';
  } else if (ratio < 1) {
    interpretation =
        'Rapport < 1 : plus typique d\'une hépatite virale ou de la '
        "majorité des autres causes hépatocellulaires, selon un repère "
        "d'enseignement classique (issu des travaux princeps de De Ritis) "
        '— il ne s\'agit pas d\'un seuil diagnostique formellement endossé '
        'par une société savante actuelle.';
  } else {
    interpretation =
        'Rapport entre 1 et 2 : zone intermédiaire, sans orientation '
        "typique selon ce repère d'enseignement classique ; à interpréter "
        'avec le contexte clinique.';
  }

  return CalculationResult(
    formula: astAltRatioDeRitisMeta,
    echoedInputs: {
      'ASAT': '${astUL.toStringAsFixed(0)} U/L',
      'ALAT': '${altUL.toStringAsFixed(0)} U/L',
    },
    values: [
      ResultValue(
        label: 'Rapport ASAT/ALAT (De Ritis)',
        value: ratio,
        unit: '',
        precision: 2,
      ),
    ],
    warnings: [
      CalculationWarning(
        interpretation,
        severity: WarningSeverity.info,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// f) Score FIB-4.
// ---------------------------------------------------------------------------

const FormulaMeta fib4Meta = FormulaMeta(
  id: 'fib4',
  name: 'Score FIB-4',
  shortName: 'FIB-4',
  category: CalculatorCategory.ionogram,
  version: 'Sterling et al. 2006',
  equation: 'FIB-4 = (Âge × ASAT) / (Plaquettes × √ALAT)',
  sources: [
    Reference(
      citation:
          'Sterling RK, Lissen E, Clumeck N, et al. Development of a Simple '
          'Noninvasive Index to Predict Significant Fibrosis in Patients '
          'With HIV/HCV Coinfection. Hepatology. 2006;43(6):1317-1325.',
    ),
    Reference(
      citation:
          'European Association for the Study of the Liver (EASL). EASL '
          'Clinical Practice Guidelines on Non-Invasive Tests for '
          'Evaluation of Liver Disease Severity and Prognosis. J Hepatol. '
          '2021;75(3):659-689.',
      note: "seuils d'interprétation (repris par les sociétés savantes "
          "d'hépatologie)",
    ),
  ],
  applicablePopulation:
      'Adulte (développé chez les patients co-infectés VIH/VHC ; utilisé '
      'plus largement en hépatologie avec des seuils dépendant du contexte '
      'et de l\'âge — à valider localement).',
  helpText: 'Plaquettes en G/L (×10⁹/L).',
);

/// Score FIB-4, estimation non invasive de la fibrose hépatique.
CalculationResult calculateFib4({
  required double ageYears,
  required double astUL,
  required double plateletsGL,
  required double altUL,
}) {
  Validation.raiseIfAny([
    Validation.checkPositive(ageYears, 'ageYears', 'Âge'),
    Validation.checkNonNegative(astUL, 'astUL', 'ASAT'),
    Validation.checkPositive(plateletsGL, 'plateletsGL', 'Plaquettes'),
    Validation.checkPositive(altUL, 'altUL', 'ALAT'),
  ]);

  final fib4 = (ageYears * astUL) / (plateletsGL * math.sqrt(altUL));

  final String interpretation;
  if (fib4 < 1.30) {
    interpretation = 'FIB-4 < 1,30 : faible probabilité de fibrose avancée.';
  } else if (fib4 <= 2.67) {
    interpretation = 'FIB-4 entre 1,30 et 2,67 : zone indéterminée.';
  } else {
    interpretation = 'FIB-4 > 2,67 : forte probabilité de fibrose avancée.';
  }

  return CalculationResult(
    formula: fib4Meta,
    echoedInputs: {
      'Âge': '${ageYears.toStringAsFixed(0)} ans',
      'ASAT': '${astUL.toStringAsFixed(0)} U/L',
      'Plaquettes': '${plateletsGL.toStringAsFixed(0)} G/L',
      'ALAT': '${altUL.toStringAsFixed(0)} U/L',
    },
    values: [
      ResultValue(
        label: 'Score FIB-4',
        value: fib4,
        unit: '',
        precision: 2,
      ),
    ],
    warnings: [
      CalculationWarning(
        '$interpretation Seuils 1,30 et 2,67 largement repris par les sociétés '
        "savantes d'hépatologie (ex. EASL 2021) pour l'évaluation non invasive "
        "de la fibrose hépatique. L'étude de dérivation originale (Sterling et "
        'al. 2006, patients co-infectés VIH/VHC) avait proposé d\'autres '
        'seuils (1,45 et 3,25) : les seuils dépendent de la population et du '
        'contexte, à valider localement.',
        severity: WarningSeverity.info,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// g) Score APRI.
// ---------------------------------------------------------------------------

const FormulaMeta apriMeta = FormulaMeta(
  id: 'apri',
  name: 'Score APRI',
  shortName: 'APRI',
  category: CalculatorCategory.ionogram,
  version: 'Wai et al. 2003',
  equation: 'APRI = (ASAT / ULN ASAT × 100) / Plaquettes',
  sources: [
    Reference(
      citation:
          'Wai CT, Greenson JK, Fontana RJ, et al. A Simple Noninvasive '
          'Index Can Predict Both Significant Fibrosis and Cirrhosis in '
          'Patients With Chronic Hepatitis C. Hepatology. '
          '2003;38(2):518-526.',
    ),
    Reference(
      citation:
          'World Health Organization. Guidelines for the Care and '
          'Treatment of Persons Diagnosed With Chronic Hepatitis C Virus '
          'Infection. Geneva: WHO; 2016 (updated 2018).',
      note: "seuil de cirrhose (APRI > 2,0) endossé formellement par l'OMS "
          '; les seuils de fibrose significative (≤ 0,5 / > 1,5) '
          'proviennent de la cohorte de dérivation originale (Wai et al. '
          '2003)',
    ),
  ],
  applicablePopulation: 'Adulte',
  helpText:
      "Limite supérieure de la normale (ULN) de l'ASAT définie localement "
      'par le laboratoire, en U/L.',
);

/// Score APRI (AST to Platelet Ratio Index), estimation non invasive de la
/// fibrose hépatique.
CalculationResult calculateApri({
  required double astUL,
  required double astUln,
  required double plateletsGL,
}) {
  Validation.raiseIfAny([
    Validation.checkNonNegative(astUL, 'astUL', 'ASAT'),
    Validation.checkPositive(astUln, 'astUln', "Limite supérieure de la normale de l'ASAT"),
    Validation.checkPositive(plateletsGL, 'plateletsGL', 'Plaquettes'),
  ]);

  final apri = (astUL / astUln * 100) / plateletsGL;

  final String interpretation;
  if (apri <= 0.5) {
    interpretation = 'APRI ≤ 0,5 : faible probabilité de fibrose '
        'significative (seuil de la cohorte de dérivation, Wai et al. '
        '2003).';
  } else if (apri <= 1.5) {
    interpretation = 'APRI entre 0,5 et 1,5 : zone intermédiaire.';
  } else if (apri <= 2.0) {
    interpretation = 'APRI > 1,5 : évocateur d\'une fibrose significative '
        '(seuil de la cohorte de dérivation, Wai et al. 2003).';
  } else {
    interpretation = 'APRI > 2,0 : évocateur d\'une cirrhose — seuil '
        "formellement endossé par les recommandations de l'OMS (2016, "
        'mises à jour 2018) pour l\'hépatite C chronique en contexte de '
        'ressources limitées.';
  }

  return CalculationResult(
    formula: apriMeta,
    echoedInputs: {
      'ASAT': '${astUL.toStringAsFixed(0)} U/L',
      "ULN ASAT": '${astUln.toStringAsFixed(0)} U/L',
      'Plaquettes': '${plateletsGL.toStringAsFixed(0)} G/L',
    },
    values: [
      ResultValue(
        label: 'Score APRI',
        value: apri,
        unit: '',
        precision: 2,
      ),
    ],
    warnings: [
      CalculationWarning(
        interpretation,
        severity: WarningSeverity.info,
      ),
    ],
  );
}
