import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';

/// Protéinurie — bilan de masse sur la durée réelle de collecte.
const FormulaMeta proteinuria24hMeta = FormulaMeta(
  id: 'proteinuria_24h',
  name: 'Protéinurie des urines de 24 heures (ou recueil minuté)',
  shortName: 'Protéinurie 24 h',
  category: CalculatorCategory.renal,
  version: 'Bilan de masse (concentration × volume recueilli)',
  equation:
      'Protéinurie = Concentration urinaire (mg/L) × Volume recueilli (L), '
      'rapportée à la durée réelle de collecte',
  sources: [
    Reference(
      citation:
          'Kidney Disease: Improving Global Outcomes (KDIGO) CKD Work Group. '
          'KDIGO 2012 Clinical Practice Guideline for the Evaluation and '
          'Management of Chronic Kidney Disease. Kidney Int Suppl. '
          '2013;3(1):1-150.',
      note: "contexte clinique de l'évaluation de la protéinurie",
    ),
  ],
  applicablePopulation: 'Tout âge',
  limitations: [
    "La précision dépend de l'exactitude du recueil (durée réelle, volume "
        "total réellement collecté) déclaré par le patient ou le service de "
        "soins.",
    "Le seuil de 3,5 g/24h retenu pour qualifier une protéinurie de rang "
        "néphrotique est un repère classique de la pratique néphrologique, "
        "non formalisé par une grille de société savante particulière.",
  ],
  displayPrecision: 1,
);

/// Protéinurie mesurée sur un recueil urinaire minuté (typiquement 24 h),
/// par bilan de masse (concentration × volume recueilli), rapportée à la
/// durée réelle de collecte et, si celle-ci diffère de 24 h, extrapolée.
CalculationResult calculateProteinuria24h({
  required double concentrationValue,
  required String concentrationUnit,
  required double volumeValue,
  required String volumeUnit,
  required double durationValue,
  required String durationUnit,
}) {
  final concentrationError = Validation.checkPositive(
      concentrationValue, 'concentrationValue', 'Concentration urinaire');
  final volumeError = Validation.checkPositive(volumeValue, 'volumeValue', 'Volume recueilli');
  final durationError = Validation.checkPositive(durationValue, 'durationValue', 'Durée de recueil');
  Validation.raiseIfAny([concentrationError, volumeError, durationError]);

  final concentrationMgLCanonical =
      UnitRegistry.toCanonical(Analyte.proteinuria, concentrationValue, concentrationUnit);
  final volumeMlCanonical = UnitRegistry.toCanonical(Analyte.volume, volumeValue, volumeUnit);
  final durationMinCanonical = UnitRegistry.toCanonical(Analyte.duration, durationValue, durationUnit);

  final massMg = concentrationMgLCanonical * (volumeMlCanonical / 1000);
  final durationHours = durationMinCanonical / 60;

  final values = <ResultValue>[
    ResultValue(
      label: 'Protéinurie mesurée sur la durée réelle du recueil (${durationHours.toStringAsFixed(1)} h)',
      value: massMg,
      unit: 'mg',
      precision: 1,
    ),
    ResultValue(
      label: 'Protéinurie mesurée sur la durée réelle du recueil (${durationHours.toStringAsFixed(1)} h)',
      value: massMg / 1000,
      unit: 'g',
      precision: 3,
    ),
  ];

  final warnings = <CalculationWarning>[];

  final isExactly24h = (durationMinCanonical - 1440).abs() < 0.5;
  if (isExactly24h) {
    values.add(ResultValue(
      label: 'Protéinurie des 24 heures',
      value: massMg,
      unit: 'mg/24h',
      precision: 1,
    ));
    values.add(ResultValue(
      label: 'Protéinurie des 24 heures',
      value: massMg / 1000,
      unit: 'g/24h',
      precision: 3,
    ));
  } else if (durationMinCanonical < 1440) {
    final extrapolatedMg = massMg * (1440 / durationMinCanonical);
    values.add(ResultValue(
      label:
          'Extrapolation à 24 h (collecte incomplète, ${durationHours.toStringAsFixed(1)} h) — mg',
      value: extrapolatedMg,
      unit: 'mg',
      precision: 1,
    ));
    warnings.add(CalculationWarning(
      'Collecte incomplète (${durationHours.toStringAsFixed(1)} h) : ne pas '
      "confondre la valeur mesurée sur la période réelle avec "
      "l'extrapolation à 24 h.",
      severity: WarningSeverity.caution,
    ));
  } else {
    warnings.add(const CalculationWarning(
      "Durée de recueil supérieure à 24 h : le résultat est rapporté sur la "
      "durée réelle de collecte, non extrapolé.",
      severity: WarningSeverity.caution,
    ));
  }

  // Équivalent ramené à 24 h, à seule fin d'interprétation (identique à la
  // valeur mesurée lorsque le recueil dure exactement 24 h).
  final mgPer24hEquivalent = massMg * (1440 / durationMinCanonical);
  final gPer24hLabel = isExactly24h
      ? '${(mgPer24hEquivalent / 1000).toStringAsFixed(2)} g/24h'
      : '${(mgPer24hEquivalent / 1000).toStringAsFixed(2)} g/24h (estimation '
          'ramenée à 24 h)';
  warnings.add(CalculationWarning(
    mgPer24hEquivalent >= 3500
        ? 'Protéinurie de rang néphrotique ($gPer24hLabel) : seuil '
            "classiquement retenu en pratique néphrologique (≥ 3,5 g/24h)."
        : 'Protéinurie non néphrotique ($gPer24hLabel) : en dessous du '
            "seuil classiquement retenu en pratique néphrologique pour une "
            "protéinurie de rang néphrotique (≥ 3,5 g/24h).",
    severity: WarningSeverity.info,
  ));

  return CalculationResult(
    formula: proteinuria24hMeta,
    echoedInputs: {
      'Concentration urinaire': concentrationUnit == 'mg/L'
          ? '${concentrationValue.toStringAsFixed(1)} mg/L'
          : '${concentrationValue.toStringAsFixed(2)} $concentrationUnit (${concentrationMgLCanonical.toStringAsFixed(1)} mg/L)',
      'Volume recueilli': volumeUnit == 'mL'
          ? '${volumeValue.toStringAsFixed(0)} mL'
          : '${volumeValue.toStringAsFixed(3)} $volumeUnit (${volumeMlCanonical.toStringAsFixed(0)} mL)',
      'Durée de recueil': durationUnit == 'h'
          ? '${durationValue.toStringAsFixed(1)} h'
          : '${durationValue.toStringAsFixed(0)} min (${durationHours.toStringAsFixed(1)} h)',
    },
    values: values,
    warnings: warnings,
  );
}
