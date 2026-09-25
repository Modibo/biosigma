import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';

/// Critère "Thrombopénie" du score 4Ts.
enum FourTsThrombocytopenia {
  twoPoints(2, 'Chute des plaquettes > 50 % ET nadir ≥ 20 G/L'),
  onePoint(1, 'Chute des plaquettes 30-50 % OU nadir 10-19 G/L'),
  zeroPoint(0, 'Chute des plaquettes < 30 % OU nadir < 10 G/L');

  const FourTsThrombocytopenia(this.points, this.description);
  final int points;
  final String description;
}

/// Critère "Chronologie" du score 4Ts.
enum FourTsTiming {
  twoPoints(2,
      'Début net entre le 5e et le 10e jour, ou chute ≤ 1 jour si exposition à l\'héparine dans les 30 derniers jours'),
  onePoint(1,
      'Chute compatible avec le 5e-10e jour mais mal documentée, ou début après le 10e jour, ou chute ≤ 1 jour si exposition 30-100 jours auparavant'),
  zeroPoint(0,
      'Chute des plaquettes récente (< 4 jours) sans exposition récente à l\'héparine');

  const FourTsTiming(this.points, this.description);
  final int points;
  final String description;
}

/// Critère "Thrombose/séquelles" du score 4Ts.
enum FourTsThrombosis {
  twoPoints(2,
      'Nouvelle thrombose confirmée, nécrose cutanée, ou réaction systémique aiguë après bolus IV d\'héparine'),
  onePoint(1,
      'Thrombose progressive ou récidivante, lésions cutanées non nécrotiques, ou thrombose suspectée non confirmée'),
  zeroPoint(0, 'Aucun signe de thrombose ou de séquelle');

  const FourTsThrombosis(this.points, this.description);
  final int points;
  final String description;
}

/// Critère "Autres causes" du score 4Ts.
enum FourTsOtherCauses {
  twoPoints(2, 'Aucune autre cause apparente de thrombopénie'),
  onePoint(1, 'Autre cause possible'),
  zeroPoint(0, 'Autre cause définie et documentée');

  const FourTsOtherCauses(this.points, this.description);
  final int points;
  final String description;
}

/// Score 4Ts (thrombopénie induite par l'héparine).
const FormulaMeta fourTsScoreMeta = FormulaMeta(
  id: 'four_ts_score',
  name: "Score 4Ts (thrombopénie induite par l'héparine)",
  shortName: 'Score 4Ts',
  category: CalculatorCategory.hemostasis,
  version: 'Lo et al. 2006 (Warkentin)',
  equation:
      'Score = points(Thrombopénie) + points(Chronologie) + '
      'points(Thrombose/séquelles) + points(Autres causes) — 0 à 8 '
      'points, voir barème détaillé.',
  sources: [
    Reference(
      citation:
          "Lo GK, Juhl D, Warkentin TE, Sigouin CS, Eichler P, Greinacher "
          "A. Evaluation of Pretest Clinical Score (4 T's) for the "
          'Diagnosis of Heparin-Induced Thrombocytopenia in Two Clinical '
          'Settings. J Thromb Haemost. 2006;4(4):759-765.',
    ),
  ],
  applicablePopulation:
      "Patient sous héparine (ou récemment exposé) présentant une "
      'thrombopénie',
  limitations: [
    "L'interprétation clinique de ce score doit être validée localement "
        'par le biologiste responsable avant toute utilisation en pratique.',
    'Score de probabilité clinique pré-test, ne remplace pas la recherche '
        'biologique d\'anticorps anti-PF4/héparine quand celle-ci est '
        'indiquée.',
  ],
  displayPrecision: 0,
);

/// Calcule le score 4Ts (probabilité clinique pré-test de thrombopénie
/// induite par l'héparine). Si un des quatre critères manque, le score est
/// renvoyé incomplet plutôt que d'inférer la donnée absente.
CalculationResult calculateFourTsScore({
  FourTsThrombocytopenia? thrombocytopenia,
  FourTsTiming? timing,
  FourTsThrombosis? thrombosisSequelae,
  FourTsOtherCauses? otherCauses,
}) {
  if (thrombocytopenia == null ||
      timing == null ||
      thrombosisSequelae == null ||
      otherCauses == null) {
    return CalculationResult(
      formula: fourTsScoreMeta,
      echoedInputs: const {},
      isComplete: false,
      values: const [
        ResultValue(label: 'Score 4Ts', value: null, unit: 'points'),
      ],
      warnings: const [
        CalculationWarning('Score incomplet : renseignez les 4 critères.'),
      ],
    );
  }

  final total = thrombocytopenia.points +
      timing.points +
      thrombosisSequelae.points +
      otherCauses.points;

  return CalculationResult(
    formula: fourTsScoreMeta,
    echoedInputs: {
      'Thrombopénie': thrombocytopenia.description,
      'Chronologie': timing.description,
      'Thrombose/séquelles': thrombosisSequelae.description,
      'Autres causes': otherCauses.description,
    },
    values: [
      ResultValue(
        label: 'Score 4Ts',
        value: total.toDouble(),
        unit: 'points',
        precision: 0,
      ),
    ],
    warnings: [
      CalculationWarning(
        total >= 6
            ? "Score 6-8 : probabilité clinique élevée de thrombopénie "
                "induite par l'héparine (TIH)."
            : (total >= 4
                ? 'Score 4-5 : probabilité clinique intermédiaire de TIH.'
                : 'Score 0-3 : probabilité clinique faible de TIH.'),
        severity: WarningSeverity.info,
      ),
    ],
  );
}
