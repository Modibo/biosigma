import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';

/// Augmentation d'un marqueur de fibrine (D-dimères ou PDF) dans le score
/// ISTH de CIVD.
enum FibrinMarkerIncrease {
  none(0, 'Pas d\'augmentation'),
  moderate(2, 'Augmentation modérée'),
  strong(3, 'Augmentation forte');

  const FibrinMarkerIncrease(this.points, this.label);

  final int points;
  final String label;
}

/// Score ISTH de CIVD (coagulation intravasculaire disséminée).
const FormulaMeta isthDicScoreMeta = FormulaMeta(
  id: 'isth_dic_score',
  name: 'Score ISTH de CIVD (coagulation intravasculaire disséminée)',
  shortName: 'Score ISTH-CIVD',
  category: CalculatorCategory.hemostasis,
  version: 'ISTH 2001 (Taylor et al.)',
  equation:
      'Score = points(Plaquettes) + points(Marqueur de fibrine) + '
      "points(Allongement du TP) + points(Fibrinogène) — voir barème "
      'détaillé dans la fiche technique.',
  sources: [
    Reference(
      citation:
          'Taylor FB Jr, Toh CH, Hoots WK, Wada H, Levi M; Scientific '
          'Subcommittee on Disseminated Intravascular Coagulation (DIC) of '
          'the International Society on Thrombosis and Haemostasis (ISTH). '
          'Towards Definition, Clinical and Laboratory Criteria, and a '
          'Scoring System for Disseminated Intravascular Coagulation. '
          'Thromb Haemost. 2001;86(5):1327-1330.',
    ),
  ],
  applicablePopulation:
      'Patient présentant une pathologie associée à un risque de CIVD',
  limitations: [
    'Nécessite un contexte clinique évocateur préalable (case '
        'underlyingDisorderPresent) ; ne jamais appliquer hors de ce '
        'contexte.',
    "L'interprétation clinique de ce score doit être validée localement "
        'par le biologiste responsable avant toute utilisation en pratique.',
    'Le seuil "augmentation modérée/forte" du marqueur de fibrine dépend '
        'du test utilisé (D-dimères ou PDF) et du laboratoire.',
  ],
  displayPrecision: 0,
);

/// Calcule le score ISTH de CIVD (coagulation intravasculaire disséminée).
///
/// Ce score n'est validé que chez un patient présentant une pathologie
/// associée à un risque de CIVD ([underlyingDisorderPresent]) ; en dehors
/// de ce contexte, ou si un critère manque, le score est renvoyé incomplet
/// plutôt que de lever une exception : ce n'est pas une erreur de saisie,
/// mais un critère clinique préalable non rempli ou une saisie encore en
/// cours.
CalculationResult calculateIsthDicScore({
  required bool underlyingDisorderPresent,
  double? plateletCountGL,
  FibrinMarkerIncrease? fibrinMarkerIncrease,
  double? ptProlongationSeconds,
  double? fibrinogenValue,
  String? fibrinogenUnit,
}) {
  if (!underlyingDisorderPresent) {
    return CalculationResult(
      formula: isthDicScoreMeta,
      echoedInputs: const {},
      isComplete: false,
      values: const [
        ResultValue(label: 'Score ISTH-CIVD', value: null, unit: 'points'),
      ],
      warnings: const [
        CalculationWarning(
          "Ce score n'est validé que chez un patient présentant une "
          'pathologie associée à un risque de CIVD ; il n\'est pas '
          'recommandé de l\'appliquer hors de ce contexte.',
          severity: WarningSeverity.caution,
        ),
      ],
    );
  }

  if (plateletCountGL == null ||
      fibrinMarkerIncrease == null ||
      ptProlongationSeconds == null ||
      fibrinogenValue == null) {
    return CalculationResult(
      formula: isthDicScoreMeta,
      echoedInputs: const {},
      isComplete: false,
      values: const [
        ResultValue(label: 'Score ISTH-CIVD', value: null, unit: 'points'),
      ],
      warnings: const [
        CalculationWarning('Score incomplet : renseignez tous les critères.'),
      ],
    );
  }

  final plateletPoints = plateletCountGL < 50
      ? 2
      : plateletCountGL < 100
          ? 1
          : 0;

  final fibrinMarkerPoints = fibrinMarkerIncrease.points;

  final ptPoints = ptProlongationSeconds < 3
      ? 0
      : ptProlongationSeconds < 6
          ? 1
          : 2;

  final fibrinogenCanonicalGL = UnitRegistry.toCanonical(
      Analyte.fibrinogen, fibrinogenValue, fibrinogenUnit ?? 'g/L');
  final fibrinogenPoints = fibrinogenCanonicalGL > 1.0 ? 0 : 1;

  final total = plateletPoints + fibrinMarkerPoints + ptPoints + fibrinogenPoints;

  return CalculationResult(
    formula: isthDicScoreMeta,
    echoedInputs: {
      'Plaquettes': '${plateletCountGL.toStringAsFixed(0)} G/L',
      'Marqueur de fibrine': fibrinMarkerIncrease.label,
      'Allongement du TP': '${ptProlongationSeconds.toStringAsFixed(1)} s',
      'Fibrinogène': '${fibrinogenValue.toStringAsFixed(2)} ${fibrinogenUnit ?? 'g/L'} '
          '(${fibrinogenCanonicalGL.toStringAsFixed(2)} g/L)',
    },
    values: [
      ResultValue(
        label: 'Score ISTH-CIVD',
        value: total.toDouble(),
        unit: 'points',
        precision: 0,
      ),
    ],
    warnings: [
      CalculationWarning(
        total >= 5
            ? 'Score ≥ 5 : compatible avec une CIVD manifeste '
                '(décompensée). À répéter quotidiennement.'
            : "Score < 5 : évocateur d'une CIVD non manifeste (non "
                'décompensée). À répéter dans les 1 à 2 jours suivants.',
        severity: WarningSeverity.info,
      ),
    ],
  );
}
