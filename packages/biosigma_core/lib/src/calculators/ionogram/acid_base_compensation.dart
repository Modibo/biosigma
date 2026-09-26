import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../validation.dart';

/// Trouble acido-basique primaire supposé, pour le calcul de la
/// compensation attendue. Chaque valeur correspond à une règle de
/// compensation publiée distincte (Albert-Winters 1967 pour l'acidose
/// métabolique ; Narins-Emmett 1980 pour les cinq autres).
enum PrimaryAcidBaseDisorder {
  acidoseMetabolique('Acidose métabolique'),
  alcaloseMetabolique('Alcalose métabolique'),
  acidoseRespiratoireAigue('Acidose respiratoire aiguë'),
  acidoseRespiratoireChronique('Acidose respiratoire chronique'),
  alcaloseRespiratoireAigue('Alcalose respiratoire aiguë'),
  alcaloseRespiratoireChronique('Alcalose respiratoire chronique');

  const PrimaryAcidBaseDisorder(this.label);

  /// Libellé affiché en français.
  final String label;

  /// `true` si le trouble est métabolique (donnée d'entrée : HCO3 mesuré,
  /// mmol/L) ; `false` s'il est respiratoire (donnée d'entrée : PaCO2
  /// mesurée, mmHg).
  bool get isMetabolic =>
      this == PrimaryAcidBaseDisorder.acidoseMetabolique ||
      this == PrimaryAcidBaseDisorder.alcaloseMetabolique;
}

// ---------------------------------------------------------------------------
// a) Compensation acido-basique attendue.
// ---------------------------------------------------------------------------

/// Compensation acido-basique attendue pour un trouble primaire simple
/// supposé unique. Calcule uniquement la valeur attendue (PaCO2 pour un
/// trouble métabolique primaire, HCO3 pour un trouble respiratoire
/// primaire) et sa fourchette de tolérance publiée ; ne compare jamais à
/// une valeur mesurée et n'émet aucun verdict — la comparaison et
/// l'interprétation (trouble simple vs mixte) reviennent au clinicien.
const FormulaMeta expectedAcidBaseCompensationMeta = FormulaMeta(
  id: 'expected_acid_base_compensation',
  name: 'Compensation acido-basique attendue',
  shortName: 'Compensation attendue',
  category: CalculatorCategory.ionogram,
  version:
      'Acidose métabolique : Albert-Winters 1967  ;  les 5 autres troubles : '
      'Narins-Emmett 1980',
  equation:
      'Acidose métabolique : PaCO2 attendue = (1,5 × HCO3) + 8, ± 2 mmHg  ;  '
      'Alcalose métabolique : PaCO2 attendue = 40 + 0,7×(HCO3 − 24), ± 5 mmHg  ;  '
      'Acidose respiratoire aiguë : HCO3 attendu = 24 + 0,1×(PaCO2 − 40), ± 3 mmol/L  ;  '
      'Acidose respiratoire chronique : HCO3 attendu = 24 + 0,35×(PaCO2 − 40), ± 4 mmol/L  ;  '
      'Alcalose respiratoire aiguë : HCO3 attendu = 24 − 0,2×(40 − PaCO2), ± 2 mmol/L  ;  '
      'Alcalose respiratoire chronique : HCO3 attendu = 24 − 0,4×(40 − PaCO2), ± 4 mmol/L',
  sources: [
    Reference(
      citation:
          'Albert MS, Dell RB, Winters RW. Quantitative Displacement of '
          'Acid-Base Equilibrium in Metabolic Acidosis. Ann Intern Med. '
          '1967;66(2):312-322.',
      note: 'compensation attendue de l\'acidose métabolique',
    ),
    Reference(
      citation:
          'Narins RG, Emmett M. Simple and Mixed Acid-Base Disorders: A '
          'Practical Approach. Medicine (Baltimore). 1980;59(3):161-187.',
      note: 'règles de compensation des 5 autres troubles primaires',
    ),
  ],
  applicablePopulation:
      'Adulte, trouble acido-basique primaire simple supposé unique.',
  forbiddenConditions: [
    'Trouble acido-basique mixte déjà identifié (ces règles supposent un '
        'seul trouble primaire et ne sont pas conçues pour le quantifier).',
  ],
  limitations: [
    "Une valeur mesurée hors de cette fourchette attendue peut suggérer un "
        "trouble acido-basique surajouté (mixte) ; l'interprétation revient "
        'au clinicien — BioSigma ne compare pas à une valeur mesurée et ne '
        'produit aucun verdict.',
    "Les règles de compensation aiguë/chronique pour un trouble "
        "respiratoire dépendent du délai réel d'installation, souvent "
        'incertain en pratique clinique.',
  ],
  helpText:
      'Choisir le trouble primaire, puis saisir la donnée correspondante : '
      'HCO3 mesuré (mmol/L) pour un trouble métabolique, PaCO2 mesurée '
      '(mmHg) pour un trouble respiratoire.',
);

/// Compensation acido-basique attendue pour le [disorder] primaire
/// supposé. [measuredValue] est le HCO3 mesuré (mmol/L) pour un trouble
/// métabolique, ou la PaCO2 mesurée (mmHg) pour un trouble respiratoire.
CalculationResult calculateExpectedAcidBaseCompensation({
  required PrimaryAcidBaseDisorder disorder,
  required double measuredValue,
}) {
  final fieldLabel = disorder.isMetabolic ? 'HCO3 mesuré' : 'PaCO2 mesurée';
  Validation.raiseIfAny([
    disorder.isMetabolic
        // Bornes physiologiques larges (détection d'une erreur de saisie
        // manifeste) : HCO3 en mmol/L.
        ? Validation.checkInRange(measuredValue, 'measuredValue', fieldLabel, min: 3, max: 60)
        // PaCO2 en mmHg.
        : Validation.checkInRange(measuredValue, 'measuredValue', fieldLabel, min: 10, max: 150),
  ]);

  late final double central;
  late final double halfRange;
  late final String resultLabel;
  late final String resultUnit;

  switch (disorder) {
    case PrimaryAcidBaseDisorder.acidoseMetabolique:
      central = (1.5 * measuredValue) + 8;
      halfRange = 2;
      resultLabel = 'PaCO2 attendue';
      resultUnit = 'mmHg';
    case PrimaryAcidBaseDisorder.alcaloseMetabolique:
      central = 40 + 0.7 * (measuredValue - 24);
      halfRange = 5;
      resultLabel = 'PaCO2 attendue';
      resultUnit = 'mmHg';
    case PrimaryAcidBaseDisorder.acidoseRespiratoireAigue:
      central = 24 + 0.1 * (measuredValue - 40);
      halfRange = 3;
      resultLabel = 'HCO3 attendu';
      resultUnit = 'mmol/L';
    case PrimaryAcidBaseDisorder.acidoseRespiratoireChronique:
      central = 24 + 0.35 * (measuredValue - 40);
      halfRange = 4;
      resultLabel = 'HCO3 attendu';
      resultUnit = 'mmol/L';
    case PrimaryAcidBaseDisorder.alcaloseRespiratoireAigue:
      central = 24 - 0.2 * (40 - measuredValue);
      halfRange = 2;
      resultLabel = 'HCO3 attendu';
      resultUnit = 'mmol/L';
    case PrimaryAcidBaseDisorder.alcaloseRespiratoireChronique:
      central = 24 - 0.4 * (40 - measuredValue);
      halfRange = 4;
      resultLabel = 'HCO3 attendu';
      resultUnit = 'mmol/L';
  }

  return CalculationResult(
    formula: expectedAcidBaseCompensationMeta,
    echoedInputs: {
      'Trouble primaire supposé': disorder.label,
      fieldLabel: '${measuredValue.toStringAsFixed(1)} ${disorder.isMetabolic ? "mmol/L" : "mmHg"}',
    },
    values: [
      ResultValue(
        label: '$resultLabel (valeur centrale)',
        value: central,
        unit: resultUnit,
        precision: 1,
      ),
      ResultValue(
        label: 'Demi-amplitude de la fourchette attendue (±)',
        value: halfRange,
        unit: resultUnit,
        precision: 0,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// b) Rapport bicarbonates/chlorures.
// ---------------------------------------------------------------------------

/// Rapport bicarbonates/chlorures, repère rapide simple (sans seuil calculé
/// ni verdict) pouvant orienter vers une acidose hyperchlorémique.
const FormulaMeta bicarbonateChlorideRatioMeta = FormulaMeta(
  id: 'bicarbonate_chloride_ratio',
  name: 'Rapport bicarbonates/chlorures',
  shortName: 'Rapport HCO3/Cl',
  category: CalculatorCategory.ionogram,
  version: 'Rapport simple bicarbonates/chlorures',
  equation: 'Rapport HCO3/Cl = HCO3 (mmol/L) / Cl (mmol/L)',
  sources: [
    Reference(
      citation:
          'Calcul standard de biochimie clinique (rapport simple '
          "bicarbonates/chlorures, utilisé comme repère rapide d'acidose "
          'hyperchlorémique).',
    ),
  ],
  applicablePopulation: 'Tout âge',
  limitations: [
    'Repère rapide non spécifique, sans seuil validé de façon consensuelle '
        "; ne remplace pas le trou anionique ni l'analyse acido-basique "
        'complète (gaz du sang, contexte clinique).',
  ],
  helpText: 'Bicarbonates et chlorures en mmol/L.',
);

/// Rapport bicarbonates/chlorures (HCO3 / Cl, tous deux en mmol/L).
CalculationResult calculateBicarbonateChlorideRatio({
  required double bicarbonateValue,
  required double chlorideValue,
}) {
  Validation.raiseIfAny([
    Validation.checkPositive(bicarbonateValue, 'bicarbonateValue', 'Bicarbonates'),
    Validation.checkPositive(chlorideValue, 'chlorideValue', 'Chlorures'),
  ]);

  final ratio = bicarbonateValue / chlorideValue;

  return CalculationResult(
    formula: bicarbonateChlorideRatioMeta,
    echoedInputs: {
      'Bicarbonates': '${bicarbonateValue.toStringAsFixed(1)} mmol/L',
      'Chlorures': '${chlorideValue.toStringAsFixed(1)} mmol/L',
    },
    values: [
      ResultValue(
        label: 'Rapport bicarbonates/chlorures',
        value: ratio,
        unit: '',
        precision: 2,
      ),
    ],
  );
}
