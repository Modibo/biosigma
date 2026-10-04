import 'package:biosigma_core/biosigma_core.dart';

import '../models/calculator_definition.dart';
import '../models/calculator_field.dart';

/// Score MELD-Na (Kamath 2001 / Kim 2008), transplantation hépatique et
/// pronostic de la cirrhose.
final CalculatorDefinition meldNaDefinition = CalculatorDefinition(
  meta: meldNaMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'creatinine',
      label: 'Créatinine',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.creatinine,
    ),
    CalculatorFieldSpec(
      id: 'bilirubin',
      label: 'Bilirubine totale',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'µmol/L',
    ),
    CalculatorFieldSpec(
      id: 'inr',
      label: 'INR',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '',
    ),
    CalculatorFieldSpec(
      id: 'sodium',
      label: 'Sodium',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
    ),
    CalculatorFieldSpec(
      id: 'onDialysis',
      label: 'Dialyse / hémodiafiltration continue',
      kind: FieldKind.boolean,
      helpText:
          'Cocher si le patient a eu ≥ 2 séances de dialyse dans la '
          'semaine écoulée, ou une hémodiafiltration continue ≥ 24 h.',
    ),
  ],
  compute: (values) {
    final creatinine = values['creatinine'] as NumericEntry;
    final onDialysis = values['onDialysis'] as bool;
    return calculateMeldNa(
      creatinineValue: creatinine.value!,
      creatinineUnit: creatinine.unit,
      bilirubinUmolL: (values['bilirubin'] as NumericEntry).value!,
      inr: (values['inr'] as NumericEntry).value!,
      sodiumMmolL: (values['sodium'] as NumericEntry).value!,
      onDialysis: onDialysis,
    );
  },
);

/// Score ALBI (Albumin-Bilirubin, Johnson et al. 2015).
final CalculatorDefinition albiScoreDefinition = CalculatorDefinition(
  meta: albiScoreMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'bilirubin',
      label: 'Bilirubine totale',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'µmol/L',
    ),
    CalculatorFieldSpec(
      id: 'albumin',
      label: 'Albuminémie',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.albumin,
    ),
  ],
  compute: (values) {
    final albumin = values['albumin'] as NumericEntry;
    return calculateAlbiScore(
      bilirubinUmolL: (values['bilirubin'] as NumericEntry).value!,
      albuminValue: albumin.value!,
      albuminUnit: albumin.unit,
    );
  },
);

/// Compensation acido-basique attendue pour un trouble primaire simple
/// supposé unique (Albert-Winters 1967 pour l'acidose métabolique ;
/// Narins-Emmett 1980 pour les cinq autres troubles).
final CalculatorDefinition expectedAcidBaseCompensationDefinition = CalculatorDefinition(
  meta: expectedAcidBaseCompensationMeta,
  fields: [
    CalculatorFieldSpec(
      id: 'disorder',
      label: 'Trouble primaire supposé',
      kind: FieldKind.enumSelect,
      helpText:
          'Choisir le trouble primaire, puis saisir le HCO3 mesuré '
          '(troubles métaboliques) ou la PaCO2 mesurée (troubles '
          'respiratoires) dans le champ correspondant ci-dessous. '
          "L'autre valeur, si vous la saisissez, est comparée à la "
          'fourchette attendue (comparaison descriptive).',
      enumOptions: [
        EnumFieldOption(
          value: PrimaryAcidBaseDisorder.acidoseMetabolique,
          label: PrimaryAcidBaseDisorder.acidoseMetabolique.label,
        ),
        EnumFieldOption(
          value: PrimaryAcidBaseDisorder.alcaloseMetabolique,
          label: PrimaryAcidBaseDisorder.alcaloseMetabolique.label,
        ),
        EnumFieldOption(
          value: PrimaryAcidBaseDisorder.acidoseRespiratoireAigue,
          label: PrimaryAcidBaseDisorder.acidoseRespiratoireAigue.label,
        ),
        EnumFieldOption(
          value: PrimaryAcidBaseDisorder.acidoseRespiratoireChronique,
          label: PrimaryAcidBaseDisorder.acidoseRespiratoireChronique.label,
        ),
        EnumFieldOption(
          value: PrimaryAcidBaseDisorder.alcaloseRespiratoireAigue,
          label: PrimaryAcidBaseDisorder.alcaloseRespiratoireAigue.label,
        ),
        EnumFieldOption(
          value: PrimaryAcidBaseDisorder.alcaloseRespiratoireChronique,
          label: PrimaryAcidBaseDisorder.alcaloseRespiratoireChronique.label,
        ),
      ],
    ),
    const CalculatorFieldSpec(
      id: 'hco3',
      label: 'HCO3 mesuré',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
      required: false,
      helpText:
          "Trouble métabolique : valeur de départ du calcul (requise). "
          'Trouble respiratoire : facultatif, comparé à la fourchette de '
          'HCO3 attendue.',
    ),
    const CalculatorFieldSpec(
      id: 'paco2',
      label: 'PaCO2 mesurée',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmHg',
      required: false,
      helpText:
          "Trouble respiratoire : valeur de départ du calcul (requise). "
          'Trouble métabolique : facultatif, comparée à la fourchette de '
          'PaCO2 attendue.',
    ),
  ],
  compute: (values) {
    final disorder = values['disorder'] as PrimaryAcidBaseDisorder;
    final hco3 = values['hco3'] as NumericEntry;
    final paco2 = values['paco2'] as NumericEntry;
    final measuredValue = disorder.isMetabolic ? hco3.value : paco2.value;
    if (measuredValue == null) {
      throw CalculationInputException([
        FieldError(
          fieldId: disorder.isMetabolic ? 'hco3' : 'paco2',
          message: disorder.isMetabolic
              ? 'Le HCO3 mesuré est requis pour un trouble métabolique.'
              : 'La PaCO2 mesurée est requise pour un trouble respiratoire.',
        ),
      ]);
    }
    // L'autre valeur, si elle est saisie, sert à la comparaison descriptive
    // avec la fourchette attendue (P3-04).
    return calculateExpectedAcidBaseCompensation(
      disorder: disorder,
      measuredValue: measuredValue,
      measuredCompensatoryValue: disorder.isMetabolic ? paco2.value : hco3.value,
    );
  },
);

/// Rapport bicarbonates/chlorures, repère rapide d'acidose
/// hyperchlorémique.
final CalculatorDefinition bicarbonateChlorideRatioDefinition = CalculatorDefinition(
  meta: bicarbonateChlorideRatioMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'bicarbonate',
      label: 'Bicarbonates',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
    ),
    CalculatorFieldSpec(
      id: 'chloride',
      label: 'Chlorures',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmol/L',
    ),
  ],
  compute: (values) {
    return calculateBicarbonateChlorideRatio(
      bicarbonateValue: (values['bicarbonate'] as NumericEntry).value!,
      chlorideValue: (values['chloride'] as NumericEntry).value!,
    );
  },
);

/// Catalogue des calculateurs hépatiques et acido-basiques ajoutés par ce
/// lot (à intégrer au catalogue global par l'agent d'agrégation).
final List<CalculatorDefinition> hepaticAcidBaseCalculators = [
  meldNaDefinition,
  albiScoreDefinition,
  expectedAcidBaseCompensationDefinition,
  bicarbonateChlorideRatioDefinition,
];
