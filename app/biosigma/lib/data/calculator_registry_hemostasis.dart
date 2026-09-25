import 'package:biosigma_core/biosigma_core.dart';

import '../models/calculator_definition.dart';
import '../models/calculator_field.dart';

/// Indice de Rosner (indice d'anticoagulant circulant, test de mélange).
final CalculatorDefinition rosnerIndexDefinition = CalculatorDefinition(
  meta: rosnerIndexMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'mixTime',
      label: 'Temps du mélange 1:1',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 's',
      helpText: 'TCA mesuré sur le mélange 1:1 plasma patient / plasma témoin normal, en secondes.',
    ),
    const CalculatorFieldSpec(
      id: 'normalPlasmaTime',
      label: 'Temps du plasma témoin normal',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 's',
      helpText: 'TCA du plasma témoin normal (pool de plasmas normaux), en secondes.',
    ),
    const CalculatorFieldSpec(
      id: 'patientPlasmaTime',
      label: 'Temps du plasma patient',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 's',
      helpText: 'TCA du plasma patient pur (non mélangé), en secondes.',
    ),
    CalculatorFieldSpec(
      id: 'phase',
      label: 'Phase',
      kind: FieldKind.enumSelect,
      enumOptions: [
        EnumFieldOption(
          value: RosnerTimingPhase.immediate,
          label: RosnerTimingPhase.immediate.label,
        ),
        EnumFieldOption(
          value: RosnerTimingPhase.afterIncubation,
          label: RosnerTimingPhase.afterIncubation.label,
        ),
      ],
      helpText: 'Lecture immédiate du mélange, ou après incubation (typiquement 1-2 h à 37°C).',
    ),
  ],
  compute: (values) {
    final mixTime = (values['mixTime'] as NumericEntry).value!;
    final normalPlasmaTime = (values['normalPlasmaTime'] as NumericEntry).value!;
    final patientPlasmaTime = (values['patientPlasmaTime'] as NumericEntry).value!;
    final phase = values['phase'] as RosnerTimingPhase;
    return calculateRosnerIndex(
      mixTimeSeconds: mixTime,
      normalPlasmaTimeSeconds: normalPlasmaTime,
      patientPlasmaTimeSeconds: patientPlasmaTime,
      phase: phase,
    );
  },
);

/// INR (International Normalized Ratio).
final CalculatorDefinition inrDefinition = CalculatorDefinition(
  meta: inrMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'patientPt',
      label: 'Temps de Quick (TP) patient',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 's',
      helpText: 'Temps de prothrombine (TP) mesuré chez le patient, en secondes.',
    ),
    const CalculatorFieldSpec(
      id: 'meanNormalPt',
      label: 'TP moyen normal du laboratoire',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 's',
      helpText: 'TP moyen normal (MNPT) déterminé par le laboratoire pour le réactif utilisé, en secondes.',
    ),
    const CalculatorFieldSpec(
      id: 'isi',
      label: 'ISI',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '',
      helpText:
          "Indice de Sensibilité International (ISI) du réactif utilisé — grandeur sans unité "
          '(valeur brute, telle qu\'indiquée par le fabricant du réactif).',
    ),
  ],
  compute: (values) {
    final patientPt = (values['patientPt'] as NumericEntry).value!;
    final meanNormalPt = (values['meanNormalPt'] as NumericEntry).value!;
    final isi = (values['isi'] as NumericEntry).value!;
    return calculateInr(
      patientPtSeconds: patientPt,
      meanNormalPtSeconds: meanNormalPt,
      isi: isi,
    );
  },
);

/// Ratio TCA patient/témoin.
final CalculatorDefinition apttRatioDefinition = CalculatorDefinition(
  meta: apttRatioMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'patientApt',
      label: 'TCA patient',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 's',
      helpText: 'Temps de céphaline activée (TCA) mesuré chez le patient, en secondes.',
    ),
    const CalculatorFieldSpec(
      id: 'controlApt',
      label: 'TCA témoin',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 's',
      helpText: 'TCA du plasma témoin du laboratoire, mesuré avec le même réactif, en secondes.',
    ),
  ],
  compute: (values) {
    final patientApt = (values['patientApt'] as NumericEntry).value!;
    final controlApt = (values['controlApt'] as NumericEntry).value!;
    return calculateAptRatio(
      patientAptSeconds: patientApt,
      controlAptSeconds: controlApt,
    );
  },
);

/// Suivi de valeurs sériées (variation absolue et relative entre deux
/// mesures successives d'un même analyte, ex. INR, fibrinogène).
final CalculatorDefinition serialValueTrendDefinition = CalculatorDefinition(
  meta: serialValueTrendMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'analyteLabel',
      label: 'Nom de l\'analyte suivi',
      kind: FieldKind.text,
      helpText:
          'Tapez le nom de l\'analyte suivi (ex. « INR », « Fibrinogène »), avec son unité si '
          'utile — ce libellé sert de repère dans le résultat.',
    ),
    const CalculatorFieldSpec(
      id: 'previousValue',
      label: 'Valeur précédente',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '',
      helpText:
          'Valeur numérique brute de la mesure précédente, sans conversion d\'unité — précisez '
          'l\'unité dans le nom de l\'analyte ci-dessus si nécessaire.',
    ),
    const CalculatorFieldSpec(
      id: 'currentValue',
      label: 'Valeur actuelle',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '',
      helpText:
          'Valeur numérique brute de la mesure actuelle, sans conversion d\'unité — précisez '
          'l\'unité dans le nom de l\'analyte ci-dessus si nécessaire.',
    ),
  ],
  compute: (values) {
    final analyteLabel = values['analyteLabel'] as String;
    final previousValue = (values['previousValue'] as NumericEntry).value!;
    final currentValue = (values['currentValue'] as NumericEntry).value!;
    return calculateSerialTrend(
      analyteLabel: analyteLabel,
      previousValue: previousValue,
      currentValue: currentValue,
      unit: '',
    );
  },
);

/// Catalogue des 4 calculateurs d'hémostase du moteur `biosigma_core`
/// (hors scores guidés ISTH-CIVD et 4Ts, câblés séparément).
final List<CalculatorDefinition> hemostasisCalculators = [
  rosnerIndexDefinition,
  inrDefinition,
  apttRatioDefinition,
  serialValueTrendDefinition,
];
