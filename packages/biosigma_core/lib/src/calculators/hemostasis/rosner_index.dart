import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../validation.dart';

/// Phase de lecture du test de mélange (TCA 1:1) pour l'indice de Rosner.
enum RosnerTimingPhase {
  immediate,
  afterIncubation;

  /// Libellé affiché en français.
  String get label => switch (this) {
        RosnerTimingPhase.immediate => 'Lecture immédiate',
        RosnerTimingPhase.afterIncubation =>
          'Après incubation (typiquement 1-2 h à 37°C)',
      };
}

/// Indice de Rosner (indice d'anticoagulant circulant, test de mélange).
const FormulaMeta rosnerIndexMeta = FormulaMeta(
  id: 'rosner_index',
  name: "Indice de Rosner (indice d'anticoagulant circulant, test de mélange)",
  shortName: 'Indice de Rosner',
  category: CalculatorCategory.hemostasis,
  version: 'Rosner 1987',
  equation:
      'Indice de Rosner (%) = [(TCA mélange 1:1 − TCA plasma témoin normal) '
      '/ TCA plasma patient] × 100',
  sources: [
    Reference(
      citation:
          'Rosner E, Pauzner R, Lusky A, Modan M, Many A. Detection and '
          'Quantitative Evaluation of Lupus Circulating Anticoagulant '
          'Activity. Thromb Haemost. 1987;57(2):144-147.',
    ),
  ],
  applicablePopulation: "Bilan d'allongement inexpliqué du TCA",
  analyticalConditions: [
    'Les trois temps doivent être mesurés avec le même réactif et le même '
        'analyseur, dans les mêmes conditions de prélèvement.',
  ],
  limitations: [
    "L'interprétation et les seuils dépendent du réactif, du protocole "
        '(mélange immédiat vs après incubation) et de la validation locale '
        'du laboratoire.',
    "Un indice élevé ne permet pas à lui seul de conclure à un "
        "anticoagulant circulant de type lupique, ni d'exclure un déficit "
        'en facteur de coagulation.',
  ],
);

/// Calcule l'indice de Rosner à partir des trois temps du test de mélange
/// TCA (mélange 1:1, plasma témoin normal, plasma patient).
CalculationResult calculateRosnerIndex({
  required double mixTimeSeconds,
  required double normalPlasmaTimeSeconds,
  required double patientPlasmaTimeSeconds,
  required RosnerTimingPhase phase,
}) {
  final mixError = Validation.checkPositive(mixTimeSeconds, 'mixTimeSeconds', 'TCA mélange 1:1');
  final normalError = Validation.checkPositive(
      normalPlasmaTimeSeconds, 'normalPlasmaTimeSeconds', 'TCA plasma témoin normal');
  final patientError = Validation.checkPositive(
      patientPlasmaTimeSeconds, 'patientPlasmaTimeSeconds', 'TCA plasma patient');
  Validation.raiseIfAny([mixError, normalError, patientError]);

  final index =
      (mixTimeSeconds - normalPlasmaTimeSeconds) / patientPlasmaTimeSeconds * 100;

  final interpretation = index < 15
      ? "Indice de Rosner < 15 % : évocateur d'une correction du TCA par le "
          'mélange, en faveur d\'un déficit en facteur de coagulation '
          'plutôt que d\'un inhibiteur circulant.'
      : "Indice de Rosner ≥ 15 % : évocateur d'une absence de correction du "
          'TCA par le mélange, en faveur de la présence d\'un inhibiteur '
          'circulant (anticoagulant lupique ou inhibiteur spécifique d\'un '
          'facteur).';

  return CalculationResult(
    formula: rosnerIndexMeta,
    echoedInputs: {
      'TCA mélange 1:1': '${mixTimeSeconds.toStringAsFixed(1)} s',
      'TCA plasma témoin normal': '${normalPlasmaTimeSeconds.toStringAsFixed(1)} s',
      'TCA plasma patient': '${patientPlasmaTimeSeconds.toStringAsFixed(1)} s',
      'Phase': phase.label,
    },
    values: [
      ResultValue(
        label: 'Indice de Rosner — ${phase.label}',
        value: index,
        unit: '%',
      ),
    ],
    warnings: [
      CalculationWarning(
        '$interpretation Ce seuil de 15 % correspond à la convention '
        "interprétative classiquement enseignée à partir des travaux de "
        'Rosner et al. (1987) ; il s\'agit d\'un principe interprétatif '
        "général et non d'une valeur absolue : le seuil exact varie selon "
        'le réactif, le protocole (mélange immédiat ou après incubation) '
        'et la validation locale du laboratoire. Dans tous les cas, des '
        "explorations spécifiques complémentaires (recherche d'anticoagulant "
        'lupique, dosage de facteurs) restent nécessaires pour confirmer '
        "l'hypothèse d'un déficit ou d'un inhibiteur.",
        severity: WarningSeverity.info,
      ),
    ],
  );
}
