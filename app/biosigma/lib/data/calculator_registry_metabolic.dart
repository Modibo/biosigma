import 'package:biosigma_core/biosigma_core.dart';

import '../models/calculator_definition.dart';
import '../models/calculator_field.dart';

/// QUICKI (Quantitative Insulin Sensitivity Check Index).
final CalculatorDefinition quickiDefinition = CalculatorDefinition(
  meta: quickiMeta,
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
    ),
    CalculatorFieldSpec(
      id: 'fastingConfirmed',
      label: 'Prélèvement réalisé à jeun',
      kind: FieldKind.boolean,
      helpText: 'Le QUICKI exige un prélèvement strictement à jeun (≥ 8 h).',
    ),
  ],
  compute: (values) {
    final fastingInsulin = values['fastingInsulin'] as NumericEntry;
    final fastingGlucose = values['fastingGlucose'] as NumericEntry;
    final fastingConfirmed = values['fastingConfirmed'] as bool;
    return calculateQuicki(
      fastingInsulinValue: fastingInsulin.value!,
      fastingInsulinUnit: fastingInsulin.unit,
      fastingGlucoseValue: fastingGlucose.value!,
      fastingGlucoseUnit: fastingGlucose.unit,
      fastingConfirmed: fastingConfirmed,
    );
  },
);

/// Indice TyG (Triglyceride-Glucose Index).
final CalculatorDefinition tygIndexDefinition = CalculatorDefinition(
  meta: tygMeta,
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
      id: 'fastingConfirmed',
      label: 'Prélèvement réalisé à jeun',
      kind: FieldKind.boolean,
      helpText: "L'indice TyG exige un prélèvement à jeun.",
    ),
  ],
  compute: (values) {
    final triglycerides = values['triglycerides'] as NumericEntry;
    final fastingGlucose = values['fastingGlucose'] as NumericEntry;
    final fastingConfirmed = values['fastingConfirmed'] as bool;
    return calculateTyg(
      triglyceridesValue: triglycerides.value!,
      triglyceridesUnit: triglycerides.unit,
      fastingGlucoseValue: fastingGlucose.value!,
      fastingGlucoseUnit: fastingGlucose.unit,
      fastingConfirmed: fastingConfirmed,
    );
  },
);

/// HOMA-IR (Homeostasis Model Assessment).
final CalculatorDefinition homaIrDefinition = CalculatorDefinition(
  meta: homaIrMeta,
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
    ),
    CalculatorFieldSpec(
      id: 'fastingConfirmed',
      label: 'Prélèvement réalisé à jeun',
      kind: FieldKind.boolean,
      helpText: 'Le HOMA-IR exige un prélèvement à jeun.',
    ),
  ],
  compute: (values) {
    final fastingInsulin = values['fastingInsulin'] as NumericEntry;
    final fastingGlucose = values['fastingGlucose'] as NumericEntry;
    final fastingConfirmed = values['fastingConfirmed'] as bool;
    return calculateHomaIr(
      fastingInsulinValue: fastingInsulin.value!,
      fastingInsulinUnit: fastingInsulin.unit,
      fastingGlucoseValue: fastingGlucose.value!,
      fastingGlucoseUnit: fastingGlucose.unit,
      fastingConfirmed: fastingConfirmed,
    );
  },
);

/// Glycémie moyenne estimée (eAG) à partir de l'HbA1c — étude ADAG.
final CalculatorDefinition estimatedAverageGlucoseAdagDefinition = CalculatorDefinition(
  meta: estimatedAverageGlucoseAdagMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'hba1c',
      label: 'HbA1c',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.hba1c,
    ),
  ],
  compute: (values) {
    final hba1c = values['hba1c'] as NumericEntry;
    return calculateEstimatedAverageGlucose(
      hba1cValue: hba1c.value!,
      hba1cUnit: hba1c.unit,
    );
  },
);

/// Panel lipidique — LDL calculé (Friedewald ou Sampson), non-HDL, ratios
/// athérogènes et cholestérol résiduel.
final CalculatorDefinition ldlPanelDefinition = CalculatorDefinition(
  meta: ldlPanelMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'totalCholesterol',
      label: 'Cholestérol total',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.cholesterol,
    ),
    const CalculatorFieldSpec(
      id: 'hdl',
      label: 'HDL-cholestérol',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.cholesterol,
    ),
    const CalculatorFieldSpec(
      id: 'triglycerides',
      label: 'Triglycérides',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.triglycerides,
    ),
    CalculatorFieldSpec(
      id: 'formula',
      label: 'Équation LDL',
      kind: FieldKind.enumSelect,
      helpText:
          "Friedewald n'est valide que pour des triglycérides < 4,52 mmol/L "
          "(400 mg/dL) ; Sampson étend le domaine de validité jusqu'à "
          "8,90 mmol/L (800 mg/dL).",
      enumOptions: [
        EnumFieldOption(value: LdlFormula.friedewald, label: LdlFormula.friedewald.label),
        EnumFieldOption(value: LdlFormula.sampson, label: LdlFormula.sampson.label),
      ],
    ),
  ],
  compute: (values) {
    final totalCholesterol = values['totalCholesterol'] as NumericEntry;
    final hdl = values['hdl'] as NumericEntry;
    final triglycerides = values['triglycerides'] as NumericEntry;
    final formula = values['formula'] as LdlFormula;
    return calculateLdlPanel(
      totalCholesterolValue: totalCholesterol.value!,
      totalCholesterolUnit: totalCholesterol.unit,
      hdlValue: hdl.value!,
      hdlUnit: hdl.unit,
      triglyceridesValue: triglycerides.value!,
      triglyceridesUnit: triglycerides.unit,
      formula: formula,
    );
  },
);

/// Indice athérogène du plasma (AIP, Dobiásová-Frohlich 2001).
final CalculatorDefinition atherogenicIndexOfPlasmaDefinition = CalculatorDefinition(
  meta: atherogenicIndexOfPlasmaMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'triglycerides',
      label: 'Triglycérides',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.triglycerides,
      helpText:
          "L'AIP est défini exclusivement en mmol/L. Vous pouvez saisir la "
          'valeur dans une autre unité : la conversion est prise en charge '
          'par le moteur de calcul.',
    ),
    CalculatorFieldSpec(
      id: 'hdl',
      label: 'HDL-cholestérol',
      kind: FieldKind.numberWithUnit,
      analyte: Analyte.cholesterol,
      helpText:
          "L'AIP est défini exclusivement en mmol/L. Vous pouvez saisir la "
          'valeur dans une autre unité : la conversion est prise en charge '
          'par le moteur de calcul.',
    ),
  ],
  compute: (values) {
    final triglycerides = values['triglycerides'] as NumericEntry;
    final hdl = values['hdl'] as NumericEntry;
    return calculateAtherogenicIndexOfPlasma(
      triglyceridesValue: triglycerides.value!,
      triglyceridesUnit: triglycerides.unit,
      hdlValue: hdl.value!,
      hdlUnit: hdl.unit,
    );
  },
);

/// Catalogue des calculateurs cardiométaboliques de BioSigma.
final List<CalculatorDefinition> metabolicCalculators = [
  quickiDefinition,
  tygIndexDefinition,
  homaIrDefinition,
  estimatedAverageGlucoseAdagDefinition,
  ldlPanelDefinition,
  atherogenicIndexOfPlasmaDefinition,
];
