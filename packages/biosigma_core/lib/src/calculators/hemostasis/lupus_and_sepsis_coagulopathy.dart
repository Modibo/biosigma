import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../validation.dart';

/// Rapport normalisé dRVVT (dilute Russell's Viper Venom Time) pour la
/// recherche d'anticoagulant lupique.
const FormulaMeta drvvtNormalizedRatioMeta = FormulaMeta(
  id: 'drvvt_normalized_ratio',
  name: "Rapport normalisé dRVVT (recherche d'anticoagulant lupique)",
  shortName: 'Rapport dRVVT',
  category: CalculatorCategory.hemostasis,
  version: 'ISTH 2009 (Pengo et al.)',
  equation:
      'Ratio de dépistage = Temps de dépistage patient / Temps de dépistage '
      'plasma normal ; Ratio de confirmation = Temps de confirmation '
      '(phospholipides faibles) patient / Temps de confirmation plasma '
      'normal ; Ratio normalisé = Ratio de dépistage / Ratio de '
      'confirmation ; Pourcentage de correction = [(Ratio de dépistage − '
      'Ratio de confirmation) / Ratio de dépistage] × 100.',
  sources: [
    Reference(
      citation:
          'Pengo V, Tripodi A, Reber G, Rand JH, Ortel TL, Galli M, De '
          'Groot PG; Subcommittee on Lupus Anticoagulant/Antiphospholipid '
          'Antibody of the Scientific and Standardisation Committee of the '
          'International Society on Thrombosis and Haemostasis. Update of '
          'the guidelines for lupus anticoagulant detection. J Thromb '
          'Haemost. 2009;7(10):1737-1740.',
    ),
  ],
  applicablePopulation:
      "Bilan de thrombophilie / recherche d'anticoagulant lupique (syndrome "
      'des antiphospholipides), en dehors de tout traitement anticoagulant '
      'interférent lorsque possible.',
  analyticalConditions: [
    'Les quatre temps doivent être mesurés avec le même réactif dRVVT '
        '(dépistage et confirmation à phospholipides faibles) et le même '
        'analyseur.',
  ],
  limitations: [
    "Un rapport normalisé au-dessus de l'intervalle de référence propre au "
        "laboratoire est évocateur d'un anticoagulant lupique, mais "
        "l'interprétation nécessite un intervalle de référence validé "
        'localement, conformément aux critères ISTH — aucun seuil '
        "n'est appliqué automatiquement par l'application.",
    'Selon les critères ISTH, un test positif doit être confirmé par un '
        'second prélèvement à au moins 12 semaines avant de conclure à un '
        'anticoagulant lupique persistant, et corrélé au contexte clinique.',
    'Un traitement anticoagulant (héparine, anti-vitamine K, anticoagulants '
        'oraux directs) peut interférer avec le dRVVT et fausser le rapport.',
  ],
);

/// Calcule le rapport normalisé dRVVT (dépistage, confirmation, ratio
/// normalisé et pourcentage de correction) pour la recherche d'un
/// anticoagulant lupique, selon les critères ISTH (Pengo et al. 2009).
CalculationResult calculateDrvvtNormalizedRatio({
  required double patientScreenSeconds,
  required double normalScreenSeconds,
  required double patientConfirmSeconds,
  required double normalConfirmSeconds,
}) {
  final patientScreenError = Validation.checkPositive(
      patientScreenSeconds, 'patientScreenSeconds', 'Temps de dépistage patient');
  final normalScreenError = Validation.checkPositive(
      normalScreenSeconds, 'normalScreenSeconds', 'Temps de dépistage plasma normal');
  final patientConfirmError = Validation.checkPositive(patientConfirmSeconds,
      'patientConfirmSeconds', 'Temps de confirmation patient');
  final normalConfirmError = Validation.checkPositive(normalConfirmSeconds,
      'normalConfirmSeconds', 'Temps de confirmation plasma normal');
  Validation.raiseIfAny(
      [patientScreenError, normalScreenError, patientConfirmError, normalConfirmError]);

  final screenRatio = patientScreenSeconds / normalScreenSeconds;
  final confirmRatio = patientConfirmSeconds / normalConfirmSeconds;
  final normalizedRatio = screenRatio / confirmRatio;
  final percentCorrection = (screenRatio - confirmRatio) / screenRatio * 100;

  return CalculationResult(
    formula: drvvtNormalizedRatioMeta,
    echoedInputs: {
      'Temps de dépistage patient': '${patientScreenSeconds.toStringAsFixed(1)} s',
      'Temps de dépistage plasma normal': '${normalScreenSeconds.toStringAsFixed(1)} s',
      'Temps de confirmation patient': '${patientConfirmSeconds.toStringAsFixed(1)} s',
      'Temps de confirmation plasma normal': '${normalConfirmSeconds.toStringAsFixed(1)} s',
    },
    values: [
      ResultValue(label: 'Ratio de dépistage', value: screenRatio, unit: '', precision: 2),
      ResultValue(label: 'Ratio de confirmation', value: confirmRatio, unit: '', precision: 2),
      ResultValue(label: 'Ratio normalisé dRVVT', value: normalizedRatio, unit: '', precision: 2),
      ResultValue(
          label: 'Pourcentage de correction', value: percentCorrection, unit: '%', precision: 1),
    ],
  );
}

/// Score SIC (coagulopathie induite par le sepsis / sepsis-induced
/// coagulopathy).
const FormulaMeta sicScoreMeta = FormulaMeta(
  id: 'sic_score',
  name: 'Score SIC (coagulopathie induite par le sepsis)',
  shortName: 'Score SIC',
  category: CalculatorCategory.hemostasis,
  version: 'Iba et al. 2017',
  equation:
      'Score SIC = points(Numération plaquettaire) + points(INR) + '
      'points(Sous-score SOFA respiratoire + cardiovasculaire) — voir '
      'barème détaillé dans la fiche technique. Plage : 0 à 6 points.',
  sources: [
    Reference(
      citation:
          'Iba T, Nisio MD, Levy JH, Kitamura N, Thachil J. New criteria '
          'for sepsis-induced coagulopathy (SIC) following the revised '
          'sepsis definition: a retrospective analysis of a nationwide '
          'survey. BMJ Open. 2017;7(9):e017046.',
    ),
  ],
  applicablePopulation:
      'Patient adulte répondant aux critères de sepsis (Sepsis-3, Singer et '
      'al. 2016) ; ne pas appliquer en dehors de ce contexte clinique.',
  analyticalConditions: [
    'Le sous-score SOFA respiratoire + cardiovasculaire (0 à 4 points au '
        'total) doit être calculé séparément, hors périmètre de ce '
        'calculateur, puis saisi directement.',
  ],
  limitations: [
    'Un score total ≥ 4 définit la coagulopathie induite par le sepsis '
        'selon les critères originaux (Iba et al.) ; cette information est '
        "purement indicative — l'application ne calcule ni n'affiche "
        'automatiquement une conclusion positive/négative.',
    "Ce score n'a été validé que chez des patients répondant aux critères "
        'de sepsis ; il ne doit pas être utilisé comme outil de dépistage '
        'en dehors de ce contexte.',
    "L'interprétation clinique doit être corrélée à l'évolution du patient "
        'et validée par le clinicien responsable.',
  ],
  displayPrecision: 0,
);

/// Calcule le score SIC (coagulopathie induite par le sepsis) à partir de
/// la numération plaquettaire, de l'INR et du sous-score SOFA
/// respiratoire + cardiovasculaire (0 à 4, déjà calculé en amont).
CalculationResult calculateSicScore({
  required double plateletCountGL,
  required double inr,
  required double sofaRespiratoryCardiovascularSubscore,
}) {
  final plateletError = Validation.checkNonNegative(
      plateletCountGL, 'plateletCountGL', 'Numération plaquettaire');
  final inrError = Validation.checkPositive(inr, 'inr', 'INR');
  final sofaError = Validation.checkInRange(
    sofaRespiratoryCardiovascularSubscore,
    'sofaRespiratoryCardiovascularSubscore',
    'Sous-score SOFA respiratoire + cardiovasculaire',
    min: 0,
    max: 4,
  );
  Validation.raiseIfAny([plateletError, inrError, sofaError]);

  final plateletPoints = plateletCountGL >= 150
      ? 0
      : plateletCountGL >= 100
          ? 1
          : 2;

  final inrPoints = inr <= 1.2
      ? 0
      : inr <= 1.4
          ? 1
          : 2;

  final sofaPoints = sofaRespiratoryCardiovascularSubscore == 0
      ? 0
      : sofaRespiratoryCardiovascularSubscore == 1
          ? 1
          : 2;

  final total = plateletPoints + inrPoints + sofaPoints;

  return CalculationResult(
    formula: sicScoreMeta,
    echoedInputs: {
      'Plaquettes':
          '${plateletCountGL.toStringAsFixed(0)} ×10⁹/L → $plateletPoints points',
      'INR': '${inr.toStringAsFixed(2)} → $inrPoints points',
      'Sous-score SOFA respiratoire + cardiovasculaire':
          '${sofaRespiratoryCardiovascularSubscore.toStringAsFixed(0)} → $sofaPoints points',
    },
    values: [
      ResultValue(
        label: 'Score SIC',
        value: total.toDouble(),
        unit: 'points',
        precision: 0,
      ),
    ],
  );
}
