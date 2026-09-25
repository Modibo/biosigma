import 'dart:math' as math;

import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../validation.dart';

/// INR (International Normalized Ratio).
const FormulaMeta inrMeta = FormulaMeta(
  id: 'inr',
  name: 'INR (International Normalized Ratio)',
  shortName: 'INR',
  category: CalculatorCategory.hemostasis,
  version: 'Système OMS INR/ISI',
  equation: 'INR = (TP patient / TP moyen normal du laboratoire) ^ ISI',
  sources: [
    Reference(
      citation:
          'Kirkwood TB. Calibration of Clinical Thromboplastins for '
          'International Use. Thromb Haemost. 1983;49:238-244.',
    ),
    Reference(
      citation:
          'World Health Organization Expert Committee on Biological '
          'Standardization. Guidelines for Thromboplastins and Plasma Used '
          'to Control Oral Anticoagulant Therapy.',
    ),
  ],
  applicablePopulation: "Patient sous surveillance du temps de prothrombine",
  analyticalConditions: [
    'ISI (Indice de Sensibilité International) spécifique au couple '
        "réactif/analyseur du laboratoire.",
  ],
  limitations: [
    "Ne fournit aucune recommandation de dose d'anticoagulant ; à "
        "interpréter avec le contexte clinique et l'indication du "
        'traitement.',
  ],
);

/// Calcule l'INR à partir du temps de prothrombine (TP) du patient, du TP
/// moyen normal du laboratoire et de l'ISI du réactif.
CalculationResult calculateInr({
  required double patientPtSeconds,
  required double meanNormalPtSeconds,
  required double isi,
}) {
  final patientError =
      Validation.checkPositive(patientPtSeconds, 'patientPtSeconds', 'TP patient');
  final meanNormalError = Validation.checkPositive(
      meanNormalPtSeconds, 'meanNormalPtSeconds', 'TP moyen normal du laboratoire');
  final isiError = Validation.checkPositive(isi, 'isi', 'ISI');
  Validation.raiseIfAny([patientError, meanNormalError, isiError]);

  final inr = math.pow(patientPtSeconds / meanNormalPtSeconds, isi).toDouble();

  return CalculationResult(
    formula: inrMeta,
    echoedInputs: {
      'TP patient': '${patientPtSeconds.toStringAsFixed(1)} s',
      'TP moyen normal du laboratoire': '${meanNormalPtSeconds.toStringAsFixed(1)} s',
      'ISI': isi.toStringAsFixed(2),
    },
    values: [
      ResultValue(label: 'INR', value: inr, unit: ''),
    ],
  );
}

/// Ratio TCA patient/témoin.
const FormulaMeta apttRatioMeta = FormulaMeta(
  id: 'aptt_ratio',
  name: 'Ratio TCA patient/témoin',
  shortName: 'Ratio TCA',
  category: CalculatorCategory.hemostasis,
  version: 'Calcul standard (rapport de temps)',
  equation: 'Ratio TCA = TCA patient / TCA témoin',
  sources: [
    Reference(
      citation:
          'Calcul standard de biochimie de l\'hémostase (rapport de temps) ; '
          'les valeurs de référence dépendent du réactif et de l\'analyseur '
          'du laboratoire.',
    ),
  ],
  applicablePopulation: "Bilan d'hémostase, surveillance d'un traitement héparinique non fractionné",
  analyticalConditions: [
    'TCA patient et TCA témoin mesurés avec le même réactif et le même '
        'analyseur.',
  ],
  limitations: [
    'Les seuils de référence dépendent du réactif et de l\'analyseur du '
        'laboratoire ; à interpréter avec le contexte clinique.',
  ],
);

/// Calcule le ratio TCA patient/témoin.
CalculationResult calculateAptRatio({
  required double patientAptSeconds,
  required double controlAptSeconds,
}) {
  final patientError =
      Validation.checkPositive(patientAptSeconds, 'patientAptSeconds', 'TCA patient');
  final controlError =
      Validation.checkPositive(controlAptSeconds, 'controlAptSeconds', 'TCA témoin');
  Validation.raiseIfAny([patientError, controlError]);

  final ratio = patientAptSeconds / controlAptSeconds;

  return CalculationResult(
    formula: apttRatioMeta,
    echoedInputs: {
      'TCA patient': '${patientAptSeconds.toStringAsFixed(1)} s',
      'TCA témoin': '${controlAptSeconds.toStringAsFixed(1)} s',
    },
    values: [
      ResultValue(label: 'Ratio TCA patient/témoin', value: ratio, unit: ''),
    ],
  );
}

/// Suivi de valeurs sériées.
const FormulaMeta serialValueTrendMeta = FormulaMeta(
  id: 'serial_value_trend',
  name: 'Suivi de valeurs sériées',
  shortName: 'Suivi sérié',
  category: CalculatorCategory.hemostasis,
  version: 'Calcul arithmétique standard',
  equation:
      'Variation absolue = Valeur actuelle − Valeur précédente ; '
      'Variation relative (%) = (Valeur actuelle − Valeur précédente) / '
      'Valeur précédente × 100',
  sources: [
    Reference(
      citation:
          'Calcul arithmétique standard de variation entre deux mesures '
          'successives.',
    ),
  ],
  applicablePopulation: 'Suivi biologique sérié, tout analyte numérique',
  limitations: [
    "Ne constitue pas une recommandation de dose d'anticoagulant ni de "
        'conduite à tenir ; simple calcul de variation, à interpréter selon '
        'le contexte clinique et la variabilité analytique du test '
        'utilisé.',
  ],
);

/// Calcule la variation absolue et relative entre deux mesures successives
/// d'un même analyte (ex. INR, fibrinogène, plaquettes).
CalculationResult calculateSerialTrend({
  required String analyteLabel,
  required double previousValue,
  required double currentValue,
  required String unit,
}) {
  final previousError =
      Validation.checkProvided(previousValue, 'previousValue', 'Valeur précédente');
  final currentError =
      Validation.checkProvided(currentValue, 'currentValue', 'Valeur actuelle');
  Validation.raiseIfAny([previousError, currentError]);

  final absoluteChange = currentValue - previousValue;

  final values = <ResultValue>[
    ResultValue(label: 'Variation absolue', value: absoluteChange, unit: unit),
  ];
  final warnings = <CalculationWarning>[];

  if (previousValue != 0) {
    final percentChange = (currentValue - previousValue) / previousValue * 100;
    values.add(ResultValue(label: 'Variation relative', value: percentChange, unit: '%'));
  } else {
    values.add(const ResultValue(label: 'Variation relative', value: null, unit: '%'));
    warnings.add(const CalculationWarning(
      'Variation relative non calculable (valeur précédente nulle).',
      severity: WarningSeverity.caution,
    ));
  }

  return CalculationResult(
    formula: serialValueTrendMeta,
    echoedInputs: {
      'Analyte': analyteLabel,
      'Valeur précédente': '${previousValue.toStringAsFixed(2)} $unit',
      'Valeur actuelle': '${currentValue.toStringAsFixed(2)} $unit',
    },
    values: values,
    warnings: warnings,
  );
}
