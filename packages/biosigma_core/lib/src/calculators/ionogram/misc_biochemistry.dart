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

  if (globulines > 0) {
    values.add(ResultValue(
      label: 'Rapport albumine/globulines',
      value: albGL / globulines,
      unit: '',
      precision: 2,
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
  );
}
