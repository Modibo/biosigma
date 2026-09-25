import 'package:biosigma_core/biosigma_core.dart';

import '../models/calculator_definition.dart';
import '../models/calculator_field.dart';

/// DFG estimé — CKD-EPI créatinine 2021 (sans coefficient racial), adulte.
final CalculatorDefinition ckdEpiCreatinine2021Definition = CalculatorDefinition(
  meta: ckdEpiCreatinine2021Meta,
  fields: [
    const CalculatorFieldSpec(
      id: 'age',
      label: 'Âge',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'ans',
      helpText: "Âge en années révolues. Cette équation s'applique à l'adulte (≥ 18 ans).",
    ),
    const CalculatorFieldSpec(
      id: 'sex',
      label: 'Sexe',
      kind: FieldKind.enumSelect,
      enumOptions: [
        EnumFieldOption(value: Sex.female, label: 'Femme'),
        EnumFieldOption(value: Sex.male, label: 'Homme'),
      ],
    ),
    const CalculatorFieldSpec(
      id: 'creatinine',
      label: 'Créatininémie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.creatinine,
      helpText: 'Créatinine sérique, dosage standardisé IDMS.',
    ),
    const CalculatorFieldSpec(
      id: 'idmsConfirmed',
      label: 'Créatininémie standardisée IDMS confirmée',
      kind: FieldKind.boolean,
      helpText:
          'À cocher uniquement si le dosage de créatinine est standardisé IDMS ; '
          'indispensable à la validité de cette équation.',
    ),
  ],
  compute: (values) {
    final age = (values['age'] as NumericEntry).value!;
    final sex = values['sex'] as Sex;
    final creatinine = values['creatinine'] as NumericEntry;
    final idmsConfirmed = values['idmsConfirmed'] as bool;
    return calculateCkdEpiCreatinine2021(
      age: age,
      sex: sex,
      creatinineValue: creatinine.value!,
      creatinineUnit: creatinine.unit,
      idmsConfirmed: idmsConfirmed,
    );
  },
);

/// DFG estimé — CKD-EPI cystatine C 2012, adulte.
final CalculatorDefinition ckdEpiCystatinC2012Definition = CalculatorDefinition(
  meta: ckdEpiCystatinC2012Meta,
  fields: [
    const CalculatorFieldSpec(
      id: 'age',
      label: 'Âge',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'ans',
      helpText: "Âge en années révolues. Cette équation s'applique à l'adulte (≥ 18 ans).",
    ),
    const CalculatorFieldSpec(
      id: 'sex',
      label: 'Sexe',
      kind: FieldKind.enumSelect,
      enumOptions: [
        EnumFieldOption(value: Sex.female, label: 'Femme'),
        EnumFieldOption(value: Sex.male, label: 'Homme'),
      ],
    ),
    const CalculatorFieldSpec(
      id: 'cystatinC',
      label: 'Cystatine C',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.cystatinC,
      helpText: 'Dosage de cystatine C standardisé (matériau de référence IRMM/ERM-DA471/IFCC).',
    ),
  ],
  compute: (values) {
    final age = (values['age'] as NumericEntry).value!;
    final sex = values['sex'] as Sex;
    final cystatinC = values['cystatinC'] as NumericEntry;
    return calculateCkdEpiCystatinC2012(
      age: age,
      sex: sex,
      cystatinCValue: cystatinC.value!,
      cystatinCUnit: cystatinC.unit,
    );
  },
);

/// DFG estimé — CKD-EPI créatinine-cystatine C 2021, adulte.
final CalculatorDefinition ckdEpiCreatinineCystatinC2021Definition = CalculatorDefinition(
  meta: ckdEpiCreatinineCystatinC2021Meta,
  fields: [
    const CalculatorFieldSpec(
      id: 'age',
      label: 'Âge',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'ans',
      helpText: "Âge en années révolues. Cette équation s'applique à l'adulte (≥ 18 ans).",
    ),
    const CalculatorFieldSpec(
      id: 'sex',
      label: 'Sexe',
      kind: FieldKind.enumSelect,
      enumOptions: [
        EnumFieldOption(value: Sex.female, label: 'Femme'),
        EnumFieldOption(value: Sex.male, label: 'Homme'),
      ],
    ),
    const CalculatorFieldSpec(
      id: 'creatinine',
      label: 'Créatininémie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.creatinine,
      helpText: 'Créatinine sérique, dosage standardisé IDMS.',
    ),
    const CalculatorFieldSpec(
      id: 'cystatinC',
      label: 'Cystatine C',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.cystatinC,
      helpText: 'Dosage de cystatine C standardisé (matériau de référence IRMM/ERM-DA471/IFCC).',
    ),
    const CalculatorFieldSpec(
      id: 'idmsConfirmed',
      label: 'Créatininémie standardisée IDMS confirmée',
      kind: FieldKind.boolean,
      helpText:
          'À cocher uniquement si le dosage de créatinine est standardisé IDMS ; '
          'indispensable à la validité de cette équation.',
    ),
  ],
  compute: (values) {
    final age = (values['age'] as NumericEntry).value!;
    final sex = values['sex'] as Sex;
    final creatinine = values['creatinine'] as NumericEntry;
    final cystatinC = values['cystatinC'] as NumericEntry;
    final idmsConfirmed = values['idmsConfirmed'] as bool;
    return calculateCkdEpiCreatinineCystatinC2021(
      age: age,
      sex: sex,
      creatinineValue: creatinine.value!,
      creatinineUnit: creatinine.unit,
      cystatinCValue: cystatinC.value!,
      cystatinCUnit: cystatinC.unit,
      idmsConfirmed: idmsConfirmed,
    );
  },
);

/// DFG estimé — Schwartz bedside 2009 (pédiatrie).
final CalculatorDefinition schwartzBedsidePediatricDefinition = CalculatorDefinition(
  meta: schwartzBedsidePediatricMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'age',
      label: 'Âge',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'ans',
      helpText: 'Âge en années. Formule pédiatrique validée de 1 à 18 ans (zone de transition '
          'jusqu\'à 25 ans à interpréter avec prudence).',
    ),
    const CalculatorFieldSpec(
      id: 'height',
      label: 'Taille',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'cm',
      helpText: 'Taille mesurée, en centimètres.',
    ),
    const CalculatorFieldSpec(
      id: 'creatinine',
      label: 'Créatininémie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.creatinine,
      helpText:
          'Créatinine sérique, constante k=0,413 valable pour un dosage standardisé IDMS par '
          'méthode enzymatique.',
    ),
  ],
  compute: (values) {
    final age = (values['age'] as NumericEntry).value!;
    final height = (values['height'] as NumericEntry).value!;
    final creatinine = values['creatinine'] as NumericEntry;
    return calculateSchwartzBedside(
      ageYears: age,
      heightCm: height,
      creatinineValue: creatinine.value!,
      creatinineUnit: creatinine.unit,
    );
  },
);

/// Protéinurie des urines de 24 heures (ou recueil minuté).
final CalculatorDefinition proteinuria24hDefinition = CalculatorDefinition(
  meta: proteinuria24hMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'concentration',
      label: 'Concentration urinaire de protéines',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.proteinuria,
      helpText: 'Concentration de protéines mesurée dans les urines recueillies.',
    ),
    const CalculatorFieldSpec(
      id: 'volume',
      label: 'Volume recueilli',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.volume,
      helpText: 'Volume urinaire total réellement recueilli sur la période de collecte.',
    ),
    const CalculatorFieldSpec(
      id: 'duration',
      label: 'Durée du recueil',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.duration,
      helpText:
          'Durée réelle de la collecte. Si différente de 24 h, une extrapolation à 24 h est '
          'proposée en complément du résultat mesuré.',
    ),
  ],
  compute: (values) {
    final concentration = values['concentration'] as NumericEntry;
    final volume = values['volume'] as NumericEntry;
    final duration = values['duration'] as NumericEntry;
    return calculateProteinuria24h(
      concentrationValue: concentration.value!,
      concentrationUnit: concentration.unit,
      volumeValue: volume.value!,
      volumeUnit: volume.unit,
      durationValue: duration.value!,
      durationUnit: duration.unit,
    );
  },
);

/// Rapport albumine/créatinine urinaire (ACR), sur échantillon.
final CalculatorDefinition urineAlbuminCreatinineRatioDefinition = CalculatorDefinition(
  meta: urineAlbuminCreatinineRatioMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'albuminuria',
      label: 'Albuminurie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.proteinuria,
      helpText: "Concentration d'albumine dans l'échantillon urinaire.",
    ),
    const CalculatorFieldSpec(
      id: 'creatinineUrine',
      label: 'Créatininurie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.creatinine,
      helpText: "Concentration de créatinine dans le même échantillon urinaire.",
    ),
  ],
  compute: (values) {
    final albuminuria = values['albuminuria'] as NumericEntry;
    final creatinineUrine = values['creatinineUrine'] as NumericEntry;
    return calculateAlbuminCreatinineRatio(
      albuminValue: albuminuria.value!,
      albuminUnit: albuminuria.unit,
      creatinineValue: creatinineUrine.value!,
      creatinineUnit: creatinineUrine.unit,
    );
  },
);

/// Rapport protéines/créatinine urinaire (PCR), sur échantillon.
final CalculatorDefinition urineProteinCreatinineRatioDefinition = CalculatorDefinition(
  meta: urineProteinCreatinineRatioMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'proteinuria',
      label: 'Protéinurie totale',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.proteinuria,
      helpText: "Concentration de protéines totales dans l'échantillon urinaire.",
    ),
    const CalculatorFieldSpec(
      id: 'creatinineUrine',
      label: 'Créatininurie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.creatinine,
      helpText: "Concentration de créatinine dans le même échantillon urinaire.",
    ),
  ],
  compute: (values) {
    final proteinuria = values['proteinuria'] as NumericEntry;
    final creatinineUrine = values['creatinineUrine'] as NumericEntry;
    return calculateProteinCreatinineRatio(
      proteinValue: proteinuria.value!,
      proteinUnit: proteinuria.unit,
      creatinineValue: creatinineUrine.value!,
      creatinineUnit: creatinineUrine.unit,
    );
  },
);

/// Clairance de la créatinine MESURÉE (urines minutées ou 24 h).
final CalculatorDefinition creatinineClearanceTimedDefinition = CalculatorDefinition(
  meta: creatinineClearanceTimedMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'urineCreatinine',
      label: 'Créatininurie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.creatinine,
      helpText: 'Concentration de créatinine dans les urines recueillies.',
    ),
    const CalculatorFieldSpec(
      id: 'serumCreatinine',
      label: 'Créatininémie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.creatinine,
      helpText: 'Créatinine sérique prélevée pendant la période de recueil urinaire.',
    ),
    const CalculatorFieldSpec(
      id: 'urineVolume',
      label: 'Volume urinaire',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.volume,
      helpText: 'Volume urinaire total réellement recueilli sur la période de collecte.',
    ),
    const CalculatorFieldSpec(
      id: 'duration',
      label: 'Durée du recueil',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.duration,
      helpText: 'Durée réelle de la collecte urinaire (minutée ou 24 h).',
    ),
  ],
  compute: (values) {
    final urineCreatinine = values['urineCreatinine'] as NumericEntry;
    final serumCreatinine = values['serumCreatinine'] as NumericEntry;
    final urineVolume = values['urineVolume'] as NumericEntry;
    final duration = values['duration'] as NumericEntry;
    return calculateTimedCreatinineClearance(
      urineCreatinineValue: urineCreatinine.value!,
      urineCreatinineUnit: urineCreatinine.unit,
      serumCreatinineValue: serumCreatinine.value!,
      serumCreatinineUnit: serumCreatinine.unit,
      urineVolumeValue: urineVolume.value!,
      urineVolumeUnit: urineVolume.unit,
      durationValue: duration.value!,
      durationUnit: duration.unit,
    );
  },
);

/// Fraction excrétée du sodium (FeNa).
final CalculatorDefinition fractionalExcretionSodiumDefinition = CalculatorDefinition(
  meta: fractionalExcretionSodiumMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'urineSodium',
      label: 'Sodium urinaire',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
      helpText: "Sodium urinaire en mmol/L (valeur brute, hors périmètre de conversion d'unité).",
    ),
    const CalculatorFieldSpec(
      id: 'serumSodium',
      label: 'Sodium plasmatique',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
      helpText: "Sodium plasmatique en mmol/L (valeur brute, hors périmètre de conversion d'unité).",
    ),
    const CalculatorFieldSpec(
      id: 'urineCreatinine',
      label: 'Créatininurie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.creatinine,
      helpText: 'Concentration de créatinine dans le même échantillon urinaire.',
    ),
    const CalculatorFieldSpec(
      id: 'serumCreatinine',
      label: 'Créatininémie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.creatinine,
      helpText: 'Créatinine sérique prélevée simultanément.',
    ),
  ],
  compute: (values) {
    final urineSodium = (values['urineSodium'] as NumericEntry).value!;
    final serumSodium = (values['serumSodium'] as NumericEntry).value!;
    final urineCreatinine = values['urineCreatinine'] as NumericEntry;
    final serumCreatinine = values['serumCreatinine'] as NumericEntry;
    return calculateFeNa(
      urineSodiumValue: urineSodium,
      serumSodiumValue: serumSodium,
      urineCreatinineValue: urineCreatinine.value!,
      urineCreatinineUnit: urineCreatinine.unit,
      serumCreatinineValue: serumCreatinine.value!,
      serumCreatinineUnit: serumCreatinine.unit,
    );
  },
);

/// Fraction excrétée de l'urée (FeUrée).
final CalculatorDefinition fractionalExcretionUreaDefinition = CalculatorDefinition(
  meta: fractionalExcretionUreaMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'urineUrea',
      label: 'Urée urinaire',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
      helpText: 'Urée urinaire en mmol/L, et non azote uréique / BUN.',
    ),
    const CalculatorFieldSpec(
      id: 'serumUrea',
      label: 'Urée plasmatique',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
      helpText: 'Urée plasmatique en mmol/L, et non azote uréique / BUN.',
    ),
    const CalculatorFieldSpec(
      id: 'urineCreatinine',
      label: 'Créatininurie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.creatinine,
      helpText: 'Concentration de créatinine dans le même échantillon urinaire.',
    ),
    const CalculatorFieldSpec(
      id: 'serumCreatinine',
      label: 'Créatininémie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.creatinine,
      helpText: 'Créatinine sérique prélevée simultanément.',
    ),
  ],
  compute: (values) {
    final urineUrea = (values['urineUrea'] as NumericEntry).value!;
    final serumUrea = (values['serumUrea'] as NumericEntry).value!;
    final urineCreatinine = values['urineCreatinine'] as NumericEntry;
    final serumCreatinine = values['serumCreatinine'] as NumericEntry;
    return calculateFeUrea(
      urineUreaValue: urineUrea,
      serumUreaValue: serumUrea,
      urineCreatinineValue: urineCreatinine.value!,
      urineCreatinineUnit: urineCreatinine.unit,
      serumCreatinineValue: serumCreatinine.value!,
      serumCreatinineUnit: serumCreatinine.unit,
    );
  },
);

/// Catalogue des 10 calculateurs rénaux du moteur `biosigma_core`.
final List<CalculatorDefinition> renalCalculators = [
  ckdEpiCreatinine2021Definition,
  ckdEpiCystatinC2012Definition,
  ckdEpiCreatinineCystatinC2021Definition,
  schwartzBedsidePediatricDefinition,
  proteinuria24hDefinition,
  urineAlbuminCreatinineRatioDefinition,
  urineProteinCreatinineRatioDefinition,
  creatinineClearanceTimedDefinition,
  fractionalExcretionSodiumDefinition,
  fractionalExcretionUreaDefinition,
];
