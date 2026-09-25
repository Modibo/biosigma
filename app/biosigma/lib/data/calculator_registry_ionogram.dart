import 'package:biosigma_core/biosigma_core.dart';

import '../models/calculator_definition.dart';
import '../models/calculator_field.dart';

/// Trou anionique (Emmett-Narins 1977, ± potassium), avec correction
/// optionnelle pour l'albuminémie (Figge 1998).
final CalculatorDefinition anionGapDefinition = CalculatorDefinition(
  meta: anionGapMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'sodium',
      label: 'Sodium',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
    ),
    CalculatorFieldSpec(
      id: 'chloride',
      label: 'Chlore',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
    ),
    CalculatorFieldSpec(
      id: 'bicarbonate',
      label: 'Bicarbonates',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
    ),
    CalculatorFieldSpec(
      id: 'potassium',
      label: 'Potassium',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
      required: false,
      helpText: 'Optionnel : ajoute la variante du trou anionique incluant le potassium.',
    ),
    CalculatorFieldSpec(
      id: 'albumin',
      label: 'Albuminémie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.albumin,
      required: false,
      helpText:
          "Optionnel : ajoute le trou anionique corrigé pour l'albuminémie "
          '(convention de Figge 1998).',
    ),
  ],
  compute: (values) {
    final albumin = values['albumin'] as NumericEntry;
    return calculateAnionGap(
      sodiumValue: (values['sodium'] as NumericEntry).value!,
      chlorideValue: (values['chloride'] as NumericEntry).value!,
      bicarbonateValue: (values['bicarbonate'] as NumericEntry).value!,
      potassiumValue: (values['potassium'] as NumericEntry).value,
      albuminValue: albumin.value,
      albuminUnit: albumin.value == null ? null : albumin.unit,
    );
  },
);

/// Osmolarité calculée (Smithline-Gardner 1976) et trou osmolaire optionnel
/// lorsqu'une osmolalité mesurée par osmométrie est disponible.
final CalculatorDefinition calculatedOsmolarityOsmolarGapDefinition = CalculatorDefinition(
  meta: calculatedOsmolarityOsmolarGapMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'sodium',
      label: 'Sodium',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
    ),
    CalculatorFieldSpec(
      id: 'glucose',
      label: 'Glycémie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.glucose,
    ),
    CalculatorFieldSpec(
      id: 'urea',
      label: 'Urée',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
      helpText: 'Urée en mmol/L — et non azote uréique / BUN.',
    ),
    CalculatorFieldSpec(
      id: 'measuredOsmolality',
      label: 'Osmolalité mesurée',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mOsm/kg',
      required: false,
      helpText: 'Uniquement si mesurée par osmométrie — ne jamais estimer.',
    ),
  ],
  compute: (values) {
    final glucose = values['glucose'] as NumericEntry;
    return calculateCalculatedOsmolarity(
      sodiumValue: (values['sodium'] as NumericEntry).value!,
      glucoseValue: glucose.value!,
      glucoseUnit: glucose.unit,
      ureaValue: (values['urea'] as NumericEntry).value!,
      measuredOsmolalityValue: (values['measuredOsmolality'] as NumericEntry).value,
    );
  },
);

/// Sodium corrigé pour hyperglycémie — coefficients de Katz (1973) et de
/// Hillier (1999), toujours calculés côte à côte.
final CalculatorDefinition correctedSodiumHyperglycemiaDefinition = CalculatorDefinition(
  meta: correctedSodiumHyperglycemiaMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'sodiumMeasured',
      label: 'Sodium mesuré',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
    ),
    CalculatorFieldSpec(
      id: 'glucose',
      label: 'Glycémie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.glucose,
    ),
  ],
  compute: (values) {
    final glucose = values['glucose'] as NumericEntry;
    return calculateCorrectedSodium(
      sodiumValue: (values['sodiumMeasured'] as NumericEntry).value!,
      glucoseValue: glucose.value!,
      glucoseUnit: glucose.unit,
    );
  },
);

/// Calcium corrigé pour l'albuminémie (Payne 1973).
final CalculatorDefinition correctedCalciumAlbuminDefinition = CalculatorDefinition(
  meta: correctedCalciumAlbuminMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'calcium',
      label: 'Calcium total',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.calcium,
    ),
    CalculatorFieldSpec(
      id: 'albumin',
      label: 'Albuminémie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.albumin,
    ),
  ],
  compute: (values) {
    final calcium = values['calcium'] as NumericEntry;
    final albumin = values['albumin'] as NumericEntry;
    return calculateCorrectedCalcium(
      calciumValue: calcium.value!,
      calciumUnit: calcium.unit,
      albuminValue: albumin.value!,
      albuminUnit: albumin.unit,
    );
  },
);

/// Capacité totale de fixation du fer (CTF), estimée à partir de la
/// transferrinémie par le facteur usuel ×1,42.
final CalculatorDefinition tibcFromTransferrinDefinition = CalculatorDefinition(
  meta: tibcFromTransferrinMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'transferrin',
      label: 'Transferrine',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mg/dL',
    ),
  ],
  compute: (values) {
    return calculateTibcFromTransferrin(
      transferrinMgDl: (values['transferrin'] as NumericEntry).value!,
    );
  },
);

/// Coefficient de saturation de la transferrine (fer sérique / CTF).
final CalculatorDefinition transferrinSaturationDefinition = CalculatorDefinition(
  meta: transferrinSaturationMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'serumIron',
      label: 'Fer sérique',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'µg/dL',
    ),
    CalculatorFieldSpec(
      id: 'tibc',
      label: 'CTF',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'µg/dL',
      helpText: 'Utiliser le calculateur CTF si seule la transferrine est disponible.',
    ),
  ],
  compute: (values) {
    return calculateTransferrinSaturation(
      serumIronUgDl: (values['serumIron'] as NumericEntry).value!,
      tibcUgDl: (values['tibc'] as NumericEntry).value!,
    );
  },
);

/// Globulines (par différence) et rapport albumine/globulines.
final CalculatorDefinition globulinsAgRatioDefinition = CalculatorDefinition(
  meta: globulinsAgRatioMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'totalProtein',
      label: 'Protéines totales',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.albumin,
    ),
    CalculatorFieldSpec(
      id: 'albumin',
      label: 'Albuminémie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.albumin,
    ),
  ],
  compute: (values) {
    final totalProtein = values['totalProtein'] as NumericEntry;
    final albumin = values['albumin'] as NumericEntry;
    return calculateGlobulinsAndRatio(
      totalProteinValue: totalProtein.value!,
      totalProteinUnit: totalProtein.unit,
      albuminValue: albumin.value!,
      albuminUnit: albumin.unit,
    );
  },
);

/// Bilirubine indirecte, obtenue par différence entre bilirubine totale et
/// bilirubine directe (conjuguée).
final CalculatorDefinition indirectBilirubinDefinition = CalculatorDefinition(
  meta: indirectBilirubinMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'totalBilirubin',
      label: 'Bilirubine totale',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'µmol/L',
    ),
    CalculatorFieldSpec(
      id: 'directBilirubin',
      label: 'Bilirubine directe',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'µmol/L',
    ),
  ],
  compute: (values) {
    return calculateIndirectBilirubin(
      totalBilirubinUmolL: (values['totalBilirubin'] as NumericEntry).value!,
      directBilirubinUmolL: (values['directBilirubin'] as NumericEntry).value!,
    );
  },
);

/// Rapport ASAT/ALAT (De Ritis 1957).
final CalculatorDefinition astAltRatioDeRitisDefinition = CalculatorDefinition(
  meta: astAltRatioDeRitisMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'ast',
      label: 'ASAT',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'U/L',
    ),
    CalculatorFieldSpec(
      id: 'alt',
      label: 'ALAT',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'U/L',
    ),
  ],
  compute: (values) {
    return calculateAstAltRatio(
      astUL: (values['ast'] as NumericEntry).value!,
      altUL: (values['alt'] as NumericEntry).value!,
    );
  },
);

/// Score FIB-4, estimation non invasive de la fibrose hépatique (Sterling
/// et al. 2006).
final CalculatorDefinition fib4Definition = CalculatorDefinition(
  meta: fib4Meta,
  fields: const [
    CalculatorFieldSpec(
      id: 'age',
      label: 'Âge',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'ans',
    ),
    CalculatorFieldSpec(
      id: 'ast',
      label: 'ASAT',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'U/L',
    ),
    CalculatorFieldSpec(
      id: 'platelets',
      label: 'Plaquettes',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'G/L',
    ),
    CalculatorFieldSpec(
      id: 'alt',
      label: 'ALAT',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'U/L',
    ),
  ],
  compute: (values) {
    return calculateFib4(
      ageYears: (values['age'] as NumericEntry).value!,
      astUL: (values['ast'] as NumericEntry).value!,
      plateletsGL: (values['platelets'] as NumericEntry).value!,
      altUL: (values['alt'] as NumericEntry).value!,
    );
  },
);

/// Score APRI (AST to Platelet Ratio Index), estimation non invasive de la
/// fibrose hépatique (Wai et al. 2003).
final CalculatorDefinition apriDefinition = CalculatorDefinition(
  meta: apriMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'ast',
      label: 'ASAT',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'U/L',
    ),
    CalculatorFieldSpec(
      id: 'astUln',
      label: "Limite supérieure de la normale de l'ASAT du laboratoire",
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'U/L',
      helpText: 'Valeur définie localement par votre laboratoire, jamais une valeur universelle.',
    ),
    CalculatorFieldSpec(
      id: 'platelets',
      label: 'Plaquettes',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'G/L',
    ),
  ],
  compute: (values) {
    return calculateApri(
      astUL: (values['ast'] as NumericEntry).value!,
      astUln: (values['astUln'] as NumericEntry).value!,
      plateletsGL: (values['platelets'] as NumericEntry).value!,
    );
  },
);

/// Catalogue des calculateurs d'ionogramme et de biochimie générale de
/// BioSigma.
final List<CalculatorDefinition> ionogramCalculators = [
  anionGapDefinition,
  calculatedOsmolarityOsmolarGapDefinition,
  correctedSodiumHyperglycemiaDefinition,
  correctedCalciumAlbuminDefinition,
  tibcFromTransferrinDefinition,
  transferrinSaturationDefinition,
  globulinsAgRatioDefinition,
  indirectBilirubinDefinition,
  astAltRatioDeRitisDefinition,
  fib4Definition,
  apriDefinition,
];
