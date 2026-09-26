import 'package:biosigma_core/biosigma_core.dart';

import '../models/calculator_definition.dart';
import '../models/calculator_field.dart';

/// Score de Framingham — risque coronarien (« hard CHD ») à 10 ans
/// (Wilson et al. 1998), adulte de 30 à 74 ans sans antécédent de maladie
/// coronarienne connue.
final CalculatorDefinition framinghamRiskScoreDefinition = CalculatorDefinition(
  meta: framinghamRiskScoreMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'age',
      label: 'Âge',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'ans',
      helpText: "Âge en années révolues. Cette équation n'est validée qu'entre 30 et 74 ans.",
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
      id: 'totalCholesterol',
      label: 'Cholestérol total',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.cholesterol,
      helpText: 'Ne nécessite pas de prélèvement à jeun.',
    ),
    const CalculatorFieldSpec(
      id: 'hdl',
      label: 'HDL-cholestérol',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.cholesterol,
      helpText: 'Ne nécessite pas de prélèvement à jeun.',
    ),
    const CalculatorFieldSpec(
      id: 'systolicBloodPressure',
      label: 'Pression artérielle systolique',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmHg',
      helpText: 'Pression artérielle systolique mesurée, en mmHg.',
    ),
    const CalculatorFieldSpec(
      id: 'treatedHypertension',
      label: 'Traitement antihypertenseur en cours',
      kind: FieldKind.boolean,
      helpText:
          "À cocher si le patient est actuellement traité par un ou plusieurs "
          'antihypertenseurs : les points de pression artérielle systolique '
          'diffèrent selon ce statut.',
    ),
    const CalculatorFieldSpec(
      id: 'currentSmoker',
      label: 'Tabagisme actif',
      kind: FieldKind.boolean,
      helpText: 'À cocher si le patient est fumeur actif au moment du calcul.',
    ),
  ],
  compute: (values) {
    final age = (values['age'] as NumericEntry).value!;
    final sex = values['sex'] as Sex;
    final totalCholesterol = values['totalCholesterol'] as NumericEntry;
    final hdl = values['hdl'] as NumericEntry;
    final systolicBloodPressure = (values['systolicBloodPressure'] as NumericEntry).value!;
    final treatedHypertension = values['treatedHypertension'] as bool;
    final currentSmoker = values['currentSmoker'] as bool;
    return calculateFraminghamRiskScore(
      age: age,
      sex: sex,
      totalCholesterolValue: totalCholesterol.value!,
      totalCholesterolUnit: totalCholesterol.unit,
      hdlValue: hdl.value!,
      hdlUnit: hdl.unit,
      systolicBloodPressure: systolicBloodPressure,
      treatedHypertension: treatedHypertension,
      currentSmoker: currentSmoker,
    );
  },
);

/// SCORE2 — risque cardiovasculaire (fatal et non fatal) à 10 ans (SCORE2
/// working group et ESC Cardiovascular risk collaboration, 2021), adulte
/// de 40 à 69 ans apparemment en bonne santé, sans maladie cardiovasculaire
/// athéroscléreuse ni diabète connus.
final CalculatorDefinition score2RiskDefinition = CalculatorDefinition(
  meta: score2RiskMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'age',
      label: 'Âge',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'ans',
      helpText: "Âge en années révolues. SCORE2 n'est validé qu'entre 40 et 69 ans.",
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
    CalculatorFieldSpec(
      id: 'region',
      label: 'Région de risque européenne',
      kind: FieldKind.enumSelect,
      helpText:
          "Aucune région ne couvre l'Afrique subsaharienne : ce choix reste "
          'une approximation nécessaire, à interpréter avec prudence.',
      enumOptions: [
        EnumFieldOption(
          value: RiskRegion.low,
          label: RiskRegion.low.label,
          description: RiskRegion.low.helpText,
        ),
        EnumFieldOption(
          value: RiskRegion.moderate,
          label: RiskRegion.moderate.label,
          description: RiskRegion.moderate.helpText,
        ),
        EnumFieldOption(
          value: RiskRegion.high,
          label: RiskRegion.high.label,
          description: RiskRegion.high.helpText,
        ),
        EnumFieldOption(
          value: RiskRegion.veryHigh,
          label: RiskRegion.veryHigh.label,
          description: RiskRegion.veryHigh.helpText,
        ),
      ],
    ),
    const CalculatorFieldSpec(
      id: 'totalCholesterol',
      label: 'Cholestérol total',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.cholesterol,
      helpText: 'Ne nécessite pas de prélèvement à jeun.',
    ),
    const CalculatorFieldSpec(
      id: 'hdl',
      label: 'HDL-cholestérol',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.cholesterol,
      helpText: 'Ne nécessite pas de prélèvement à jeun.',
    ),
    const CalculatorFieldSpec(
      id: 'systolicBloodPressure',
      label: 'Pression artérielle systolique',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mmHg',
      helpText: 'Pression artérielle systolique mesurée, en mmHg.',
    ),
    const CalculatorFieldSpec(
      id: 'currentSmoker',
      label: 'Tabagisme actif',
      kind: FieldKind.boolean,
      helpText: 'À cocher si le patient est fumeur actif au moment du calcul.',
    ),
  ],
  compute: (values) {
    final age = (values['age'] as NumericEntry).value!;
    final sex = values['sex'] as Sex;
    final region = values['region'] as RiskRegion;
    final totalCholesterol = values['totalCholesterol'] as NumericEntry;
    final hdl = values['hdl'] as NumericEntry;
    final systolicBloodPressure = (values['systolicBloodPressure'] as NumericEntry).value!;
    final currentSmoker = values['currentSmoker'] as bool;
    return calculateScore2Risk(
      age: age,
      sex: sex,
      currentSmoker: currentSmoker,
      systolicBloodPressure: systolicBloodPressure,
      totalCholesterolValue: totalCholesterol.value!,
      totalCholesterolUnit: totalCholesterol.unit,
      hdlValue: hdl.value!,
      hdlUnit: hdl.unit,
      region: region,
    );
  },
);

/// Catalogue des calculateurs de risque cardiovasculaire de BioSigma.
final List<CalculatorDefinition> cardiovascularRiskCalculators = [
  framinghamRiskScoreDefinition,
  score2RiskDefinition,
];
