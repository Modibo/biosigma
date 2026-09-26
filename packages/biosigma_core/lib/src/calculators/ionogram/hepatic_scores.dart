import 'dart:math' as math;

import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';

double _log10(double x) => math.log(x) / math.ln10;

/// Logarithme népérien, nommé explicitement pour éviter toute confusion
/// avec [_log10] au sein des formules MELD (qui utilisent bien ln, et non
/// log10 — Kamath et al. 2001).
double _ln(double x) => math.log(x);

// ---------------------------------------------------------------------------
// a) Score MELD-Na (Model for End-Stage Liver Disease, avec sodium).
// ---------------------------------------------------------------------------

/// Score MELD (Kamath et al. 2001) et MELD-Na (Kim et al. 2008), utilisés
/// pour la priorisation en transplantation hépatique et le pronostic de la
/// cirrhose. Ne renvoie que la valeur numérique du score ; aucune classe de
/// gravité ni décision de priorisation n'est calculée ou affichée par
/// BioSigma — l'interprétation et la décision clinique restent du ressort
/// du clinicien/du programme de transplantation.
const FormulaMeta meldNaMeta = FormulaMeta(
  id: 'meld_na',
  name: 'Score MELD-Na',
  shortName: 'MELD-Na',
  category: CalculatorCategory.ionogram,
  version:
      'MELD : Kamath et al. 2001 ; MELD-Na : Kim et al. 2008 (bornes '
      "usuelles de l'allocation hépatique — créatinine forcée à 4,0 mg/dL "
      'en cas de dialyse/hémodiafiltration, Na borné 125–137 mmol/L)',
  equation:
      'MELD = 3,78×ln(bilirubine mg/dL, plancher 1,0) + '
      '11,2×ln(INR, plancher 1,0) + '
      '9,57×ln(créatinine mg/dL, plancher 1,0 ; forcée à 4,0 si dialyse '
      '≥ 2 fois/semaine ou hémodiafiltration continue ≥ 24 h dans la '
      'dernière semaine) + 6,43, borné à [6 ; 40]  ;  '
      'Si MELD ≤ 11 : MELD-Na = MELD  ;  '
      'Si MELD > 11 : MELD-Na = MELD + 1,32×(137 − Na) − '
      '0,033×MELD×(137 − Na), avec Na (mmol/L) borné à [125 ; 137] avant '
      'utilisation, puis MELD-Na borné à [6 ; 40]',
  sources: [
    Reference(
      citation:
          'Kamath PS, Wiesner RH, Malinchoc M, et al. A Model to Predict '
          'Survival in Patients With End-Stage Liver Disease. Hepatology. '
          '2001;33(2):464-470.',
      note: 'MELD original',
    ),
    Reference(
      citation:
          'Kim WR, Biggins SW, Kremers WK, et al. Hyponatremia and Mortality '
          'Among Patients on the Liver-Transplant Waiting List. N Engl J '
          'Med. 2008;359(10):1018-1026.',
      note: 'MELD-Na',
    ),
    Reference(
      citation:
          'Wiesner R, Edwards E, Freeman R, et al. Model for End-Stage '
          'Liver Disease (MELD) and Allocation of Donor Livers. '
          'Gastroenterology. 2003;124(1):91-96.',
      note: 'corrélation approximative avec la mortalité à court terme '
          '(adoption UNOS/OPTN)',
    ),
  ],
  applicablePopulation: 'Adulte ≥ 18 ans',
  forbiddenConditions: [
    'Âge < 18 ans (utiliser le score pédiatrique PELD, non implémenté dans '
        'BioSigma).',
  ],
  limitations: [
    "Développé pour la priorisation en transplantation hépatique et le "
        "pronostic de la cirrhose ; ne remplace pas l'évaluation clinique "
        'globale ni les critères additionnels (ex. exceptions MELD, '
        'complications de la cirrhose non capturées par le score).',
    'Le plafonnement de la créatinine à 4,0 mg/dL appliqué ici ne concerne '
        "que le cas de la dialyse/hémodiafiltration, conformément à la "
        "règle d'allocation MELD ; en l'absence de dialyse, une créatinine "
        'mesurée > 4,0 mg/dL n\'est pas plafonnée dans cette implémentation '
        '— vérifier la politique OPTN (ou équivalente) en vigueur si un '
        'plafond général est requis localement.',
    'Le sodium doit provenir d\'un ionogramme fiable ; une hyperglycémie '
        'sévère ou une dysprotéinémie majeure peut fausser la natrémie '
        'mesurée et nécessiter une correction préalable.',
  ],
  helpText:
      'Bilirubine en µmol/L, INR sans unité, sodium en mmol/L. Cocher '
      "« dialyse » si le patient a eu ≥ 2 séances de dialyse dans la "
      "semaine écoulée, ou une hémodiafiltration continue ≥ 24 h.",
);

/// Score MELD-Na. [creatinineValue]/[creatinineUnit] sont convertis en
/// interne en mg/dL via [UnitRegistry] ; [bilirubinUmolL] est fourni
/// directement en µmol/L (pas d'[Analyte] dédié dans BioSigma) et converti
/// en mg/dL par le facteur standard 1/17,1.
CalculationResult calculateMeldNa({
  required double creatinineValue,
  required String creatinineUnit,
  required double bilirubinUmolL,
  required double inr,
  required double sodiumMmolL,
  required bool onDialysis,
}) {
  Validation.raiseIfAny([
    Validation.checkPositive(creatinineValue, 'creatinineValue', 'Créatinine'),
    Validation.checkNonNegative(bilirubinUmolL, 'bilirubinUmolL', 'Bilirubine'),
    Validation.checkPositive(inr, 'inr', 'INR'),
    // Bornes physiologiques larges pour détecter une erreur de saisie
    // manifeste ; le calcul lui-même borne ensuite le sodium à [125 ; 137]
    // conformément à la règle MELD-Na (Kim et al. 2008).
    Validation.checkInRange(sodiumMmolL, 'sodiumMmolL', 'Sodium', min: 100, max: 170),
  ]);

  final creatinineCanonicalUmolL =
      UnitRegistry.toCanonical(Analyte.creatinine, creatinineValue, creatinineUnit);
  final creatinineMgDl =
      UnitRegistry.fromCanonical(Analyte.creatinine, creatinineCanonicalUmolL, 'mg/dL');
  // Facteur standard de conversion bilirubine : mg/dL = µmol/L / 17,1
  // (BioSigma ne dispose pas d'un Analyte dédié à la bilirubine, cf.
  // convention déjà utilisée pour la bilirubine indirecte).
  final bilirubinMgDl = bilirubinUmolL / 17.1;

  // Plancher 1,0 pour bilirubine et INR (règle MELD, toujours appliquée).
  final bilirubinForMeld = bilirubinMgDl < 1.0 ? 1.0 : bilirubinMgDl;
  final inrForMeld = inr < 1.0 ? 1.0 : inr;
  // Créatinine : plancher 1,0 ; forcée à 4,0 en cas de dialyse/HDFC (la
  // dialyse abaisse artificiellement la créatinine mesurée, qui ne reflète
  // alors plus la sévérité réelle de l'insuffisance rénale).
  final creatinineForMeld =
      onDialysis ? 4.0 : (creatinineMgDl < 1.0 ? 1.0 : creatinineMgDl);

  final meldRaw = 3.78 * _ln(bilirubinForMeld) +
      11.2 * _ln(inrForMeld) +
      9.57 * _ln(creatinineForMeld) +
      6.43;
  final meld = meldRaw.clamp(6.0, 40.0);

  double meldNa;
  double? sodiumUsedForAdjustment;
  if (meld <= 11) {
    meldNa = meld;
  } else {
    final sodiumClamped = sodiumMmolL.clamp(125.0, 137.0);
    sodiumUsedForAdjustment = sodiumClamped;
    meldNa = meld +
        1.32 * (137 - sodiumClamped) -
        (0.033 * meld * (137 - sodiumClamped));
  }
  meldNa = meldNa.clamp(6.0, 40.0);

  final String riskBand;
  if (meldNa < 10) {
    riskBand = 'risque de mortalité à court terme (≈ 90 jours) faible';
  } else if (meldNa < 20) {
    riskBand = 'risque de mortalité à court terme (≈ 90 jours) modéré';
  } else if (meldNa < 30) {
    riskBand = 'risque de mortalité à court terme (≈ 90 jours) important';
  } else if (meldNa < 40) {
    riskBand = 'risque de mortalité à court terme (≈ 90 jours) élevé';
  } else {
    riskBand = 'risque de mortalité à court terme (≈ 90 jours) très élevé';
  }

  return CalculationResult(
    formula: meldNaMeta,
    echoedInputs: {
      'Créatinine': creatinineUnit == 'µmol/L'
          ? '${creatinineValue.toStringAsFixed(0)} µmol/L (${creatinineMgDl.toStringAsFixed(2)} mg/dL, '
              '${creatinineForMeld.toStringAsFixed(2)} mg/dL utilisée${onDialysis ? " — forcée à 4,0 (dialyse)" : ""})'
          : '${creatinineValue.toStringAsFixed(2)} $creatinineUnit '
              '(${creatinineForMeld.toStringAsFixed(2)} mg/dL utilisée${onDialysis ? " — forcée à 4,0 (dialyse)" : ""})',
      'Bilirubine':
          '${bilirubinUmolL.toStringAsFixed(1)} µmol/L (${bilirubinForMeld.toStringAsFixed(2)} mg/dL utilisée)',
      'INR': '${inr.toStringAsFixed(2)} (${inrForMeld.toStringAsFixed(2)} utilisé)',
      'Sodium': sodiumUsedForAdjustment != null
          ? '${sodiumMmolL.toStringAsFixed(1)} mmol/L (${sodiumUsedForAdjustment.toStringAsFixed(1)} mmol/L utilisé)'
          : '${sodiumMmolL.toStringAsFixed(1)} mmol/L (non utilisé : MELD ≤ 11)',
      'Dialyse / hémodiafiltration continue ≥ 24 h': onDialysis ? 'Oui' : 'Non',
    },
    values: [
      ResultValue(
        label: 'Score MELD (sans sodium)',
        value: meld,
        unit: '',
        precision: 1,
      ),
      ResultValue(
        label: 'Score MELD-Na',
        value: meldNa,
        unit: '',
        precision: 1,
      ),
    ],
    warnings: [
      CalculationWarning(
        'MELD-Na ≈ ${meldNa.toStringAsFixed(1)} : $riskBand, par '
        'corrélation approximative rapportée dans la littérature de '
        'validation du score (Kamath et al. 2001 ; adoption UNOS/OPTN, '
        'Wiesner et al. 2003) — bandes qualitatives indicatives (< 10 '
        'faible ; 10-19 modéré ; 20-29 important ; 30-39 élevé ; ≥ 40 très '
        'élevé), à ne jamais interpréter comme un pourcentage de mortalité '
        "individuel précis pour un patient donné.",
        severity: WarningSeverity.info,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// b) Score ALBI (Albumin-Bilirubin).
// ---------------------------------------------------------------------------

/// Score ALBI (Albumin-Bilirubin), marqueur objectif et continu de la
/// fonction hépatique (Johnson et al. 2015). Ne renvoie que la valeur
/// numérique du score ; les seuils de grade publiés ne sont mentionnés que
/// dans les limites d'emploi, à titre informatif — BioSigma ne calcule ni
/// n'affiche de grade.
const FormulaMeta albiScoreMeta = FormulaMeta(
  id: 'albi_score',
  name: 'Score ALBI (Albumin-Bilirubin)',
  shortName: 'ALBI',
  category: CalculatorCategory.ionogram,
  version: 'Johnson et al. 2015',
  equation:
      'ALBI = [log10(bilirubine µmol/L) × 0,66] + [albumine g/L × (−0,0852)]',
  sources: [
    Reference(
      citation:
          'Johnson PJ, Berhane S, Kagebayashi C, et al. Assessment of Liver '
          'Function in Patients With Hepatocellular Carcinoma: A New '
          'Evidence-Based Approach-the ALBI Grade. J Clin Oncol. '
          '2015;33(6):550-558.',
    ),
  ],
  applicablePopulation:
      'Adulte (développé et validé initialement chez des patients porteurs '
      "d'un carcinome hépatocellulaire ; utilisé plus largement comme "
      'marqueur continu de la fonction hépatique).',
  limitations: [
    'Les seuils de grade ALBI publiés par Johnson et al. 2015 sont fournis '
        'ici à titre informatif uniquement — grade 1 : ALBI ≤ −2,60 ; '
        'grade 2 : −2,60 < ALBI ≤ −1,39 ; grade 3 : ALBI > −1,39. BioSigma '
        "ne calcule ni n'affiche de grade : seule la valeur numérique du "
        "score est produite, l'interprétation revenant au clinicien.",
    "Développé et validé principalement dans le carcinome hépatocellulaire "
        "; son extrapolation à d'autres hépatopathies doit être prudente.",
  ],
  displayPrecision: 2,
  helpText: 'Bilirubine en µmol/L, albuminémie convertie automatiquement en g/L.',
);

/// Score ALBI, à partir de la bilirubine totale (µmol/L, pas d'[Analyte]
/// dédié dans BioSigma) et de l'albuminémie (convertie en g/L via
/// [UnitRegistry]).
CalculationResult calculateAlbiScore({
  required double bilirubinUmolL,
  required double albuminValue,
  required String albuminUnit,
}) {
  Validation.raiseIfAny([
    Validation.checkPositive(bilirubinUmolL, 'bilirubinUmolL', 'Bilirubine'),
    Validation.checkPositive(albuminValue, 'albuminValue', 'Albuminémie'),
  ]);

  final albuminGL = UnitRegistry.toCanonical(Analyte.albumin, albuminValue, albuminUnit);

  final albi = (_log10(bilirubinUmolL) * 0.66) + (albuminGL * -0.0852);

  final String grade;
  if (albi <= -2.60) {
    grade = 'Grade ALBI 1 (ALBI ≤ −2,60)';
  } else if (albi <= -1.39) {
    grade = 'Grade ALBI 2 (−2,60 < ALBI ≤ −1,39)';
  } else {
    grade = 'Grade ALBI 3 (ALBI > −1,39)';
  }

  return CalculationResult(
    formula: albiScoreMeta,
    echoedInputs: {
      'Bilirubine': '${bilirubinUmolL.toStringAsFixed(1)} µmol/L',
      'Albuminémie': albuminUnit == 'g/L'
          ? '${albuminValue.toStringAsFixed(1)} g/L'
          : '${albuminValue.toStringAsFixed(2)} $albuminUnit (${albuminGL.toStringAsFixed(1)} g/L)',
    },
    values: [
      ResultValue(
        label: 'Score ALBI',
        value: albi,
        unit: '',
        precision: 2,
      ),
    ],
    warnings: [
      CalculationWarning(
        '$grade — grades publiés par Johnson et al. 2015, fournis ici à '
        'titre informatif.',
        severity: WarningSeverity.info,
      ),
    ],
  );
}
