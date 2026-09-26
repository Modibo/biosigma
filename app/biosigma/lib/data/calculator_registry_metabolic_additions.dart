import 'package:biosigma_core/biosigma_core.dart';

import '../models/calculator_definition.dart';
import '../models/calculator_field.dart';

/// IMC (BMI) — poids (kg) et taille (cm), sans conversion d'unité (les
/// deux seules unités utilisées en pratique clinique francophone).
final CalculatorDefinition bmiDefinition = CalculatorDefinition(
  meta: bmiMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'weightKg',
      label: 'Poids',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'kg',
    ),
    CalculatorFieldSpec(
      id: 'heightCm',
      label: 'Taille',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'cm',
    ),
  ],
  compute: (values) {
    final weightKg = values['weightKg'] as NumericEntry;
    final heightCm = values['heightCm'] as NumericEntry;
    return calculateBmi(
      weightKgValue: weightKg.value!,
      heightCmValue: heightCm.value!,
    );
  },
);

/// Indice TyG-IMC (Triglyceride Glucose-BMI, Er 2016).
final CalculatorDefinition tygBmiDefinition = CalculatorDefinition(
  meta: tygBmiMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'triglycerides',
      label: 'Triglycérides à jeun',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.triglycerides,
    ),
    CalculatorFieldSpec(
      id: 'fastingGlucose',
      label: 'Glycémie à jeun',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.glucose,
    ),
    CalculatorFieldSpec(
      id: 'weightKg',
      label: 'Poids',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'kg',
    ),
    CalculatorFieldSpec(
      id: 'heightCm',
      label: 'Taille',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'cm',
    ),
    CalculatorFieldSpec(
      id: 'fastingConfirmed',
      label: 'Prélèvement réalisé à jeun',
      kind: FieldKind.boolean,
      helpText: "Le TyG-IMC exige un prélèvement à jeun (triglycérides et "
          'glycémie).',
    ),
  ],
  compute: (values) {
    final triglycerides = values['triglycerides'] as NumericEntry;
    final fastingGlucose = values['fastingGlucose'] as NumericEntry;
    final weightKg = values['weightKg'] as NumericEntry;
    final heightCm = values['heightCm'] as NumericEntry;
    final fastingConfirmed = values['fastingConfirmed'] as bool;
    return calculateTygBmi(
      triglyceridesValue: triglycerides.value!,
      triglyceridesUnit: triglycerides.unit,
      fastingGlucoseValue: fastingGlucose.value!,
      fastingGlucoseUnit: fastingGlucose.unit,
      weightKgValue: weightKg.value!,
      heightCmValue: heightCm.value!,
      fastingConfirmed: fastingConfirmed,
    );
  },
);

/// HOMA-β (fonction des cellules β, Matthews 1985).
final CalculatorDefinition homaBetaDefinition = CalculatorDefinition(
  meta: homaBetaMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'fastingInsulin',
      label: 'Insulinémie à jeun',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.insulin,
    ),
    CalculatorFieldSpec(
      id: 'fastingGlucose',
      label: 'Glycémie à jeun',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.glucose,
      helpText: 'Doit être strictement supérieure à 3,5 mmol/L (0,63 g/L) '
          'pour que le calcul soit possible.',
    ),
    CalculatorFieldSpec(
      id: 'fastingConfirmed',
      label: 'Prélèvement réalisé à jeun',
      kind: FieldKind.boolean,
      helpText: 'Le HOMA-β exige un prélèvement à jeun.',
    ),
  ],
  compute: (values) {
    final fastingInsulin = values['fastingInsulin'] as NumericEntry;
    final fastingGlucose = values['fastingGlucose'] as NumericEntry;
    final fastingConfirmed = values['fastingConfirmed'] as bool;
    return calculateHomaBeta(
      fastingInsulinValue: fastingInsulin.value!,
      fastingInsulinUnit: fastingInsulin.unit,
      fastingGlucoseValue: fastingGlucose.value!,
      fastingGlucoseUnit: fastingGlucose.unit,
      fastingConfirmed: fastingConfirmed,
    );
  },
);

/// Rapport cholestérol total/HDL-C (indice de Castelli I).
final CalculatorDefinition ctHdlRatioDefinition = CalculatorDefinition(
  meta: ctHdlRatioMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'totalCholesterol',
      label: 'Cholestérol total',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.cholesterol,
    ),
    CalculatorFieldSpec(
      id: 'hdl',
      label: 'HDL-cholestérol',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.cholesterol,
    ),
  ],
  compute: (values) {
    final totalCholesterol = values['totalCholesterol'] as NumericEntry;
    final hdl = values['hdl'] as NumericEntry;
    return calculateCtHdlRatio(
      totalCholesterolValue: totalCholesterol.value!,
      totalCholesterolUnit: totalCholesterol.unit,
      hdlValue: hdl.value!,
      hdlUnit: hdl.unit,
    );
  },
);

/// Rapport ApoB/ApoA1 (Walldius-Jungner 2006) — apolipoprotéines en g/L,
/// unité internationale unique en pratique, sans sélecteur d'unité.
final CalculatorDefinition apoBApoA1RatioDefinition = CalculatorDefinition(
  meta: apoBApoA1RatioMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'apoB',
      label: 'Apolipoprotéine B (ApoB)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'g/L',
    ),
    CalculatorFieldSpec(
      id: 'apoA1',
      label: 'Apolipoprotéine A1 (ApoA1)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'g/L',
    ),
  ],
  compute: (values) {
    final apoB = values['apoB'] as NumericEntry;
    final apoA1 = values['apoA1'] as NumericEntry;
    return calculateApoBApoA1Ratio(
      apoBValue: apoB.value!,
      apoA1Value: apoA1.value!,
    );
  },
);

/// Calculateurs cardiométaboliques additionnels (anthropométrie et ratios)
/// de BioSigma — à fusionner par l'agrégateur avec [metabolicCalculators]
/// une fois le barrel `biosigma_core.dart` et `catalog.dart` mis à jour.
final List<CalculatorDefinition> metabolicAdditionsCalculators = [
  bmiDefinition,
  tygBmiDefinition,
  homaBetaDefinition,
  ctHdlRatioDefinition,
  apoBApoA1RatioDefinition,
];
