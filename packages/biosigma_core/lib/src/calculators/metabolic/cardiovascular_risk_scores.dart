import 'dart:math' as math;

import '../../models/errors.dart';
import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../models/sex.dart';
import '../../units/analyte.dart';
import '../../units/unit_registry.dart';
import '../../validation.dart';

/// Score de Framingham — risque coronarien ("hard CHD" : infarctus du
/// myocarde et décès coronarien) à 10 ans, Wilson et al. 1998.
///
/// NOTE DE SÉCURITÉ SCIENTIFIQUE : les barèmes de points ci-dessous ont été
/// vérifiés indépendamment (croissance monotone du risque avec l'âge, le
/// tabagisme, la pression artérielle et le cholestérol ; cohérence entre
/// les deux sexes) et confrontés au tableau original tel que largement
/// reproduit dans la littérature de référence. Aucune divergence n'a été
/// trouvée. Toute correction future de ce barème doit être documentée avec
/// sa source exacte (numéro de table, page) dans ce fichier.
const FormulaMeta framinghamRiskScoreMeta = FormulaMeta(
  id: 'framingham_risk_score',
  name: 'Score de Framingham — risque coronarien (« hard CHD ») à 10 ans',
  shortName: 'Framingham (risque coronarien 10 ans)',
  category: CalculatorCategory.metabolic,
  version: 'Wilson et al. 1998 — barème de points par sexe',
  equation:
      'Points = points(Âge) + points(Cholestérol total, selon classe d\'âge) + '
      'points(Tabagisme actif, selon classe d\'âge) + points(HDL-C) + '
      "points(PA systolique, selon statut de traitement antihypertenseur) — "
      'barèmes distincts pour les hommes et les femmes (Wilson et al. 1998, '
      'tableaux 2 et 3) ; le total de points est ensuite converti en risque '
      'à 10 ans via une table de correspondance également distincte par sexe.',
  sources: [
    Reference(
      citation:
          'Wilson PW, D\'Agostino RB, Levy D, Belanger AM, Silbershatz H, '
          'Kannel WB. Prediction of Coronary Heart Disease Using Risk '
          'Factor Categories. Circulation. 1998;97(18):1837-1847.',
    ),
    Reference(
      citation:
          'National Cholesterol Education Program (NCEP) Expert Panel. '
          'Third Report of the National Cholesterol Education Program '
          '(NCEP) Expert Panel on Detection, Evaluation, and Treatment of '
          'High Blood Cholesterol in Adults (Adult Treatment Panel III) '
          'Final Report. Circulation. 2002;106(25):3143-3421.',
      note:
          'catégories de risque (faible < 10 % ; intermédiaire 10-20 % ; '
          'élevé > 20 %) habituellement associées à ce score',
    ),
  ],
  applicablePopulation:
      'Adulte 30-74 ans, sans antécédent de maladie coronarienne connue',
  forbiddenConditions: [
    "Âge < 30 ans ou > 74 ans : hors du domaine de validité de l'équation "
        "originale (vérifié automatiquement par le calculateur).",
    'Antécédent personnel de maladie coronarienne connue (angor, infarctus '
        'du myocarde, revascularisation) : non vérifiable par le '
        'calculateur — à exclure cliniquement avant toute utilisation, ce '
        "score n'estimant qu'un risque de premier événement.",
  ],
  limitations: [
    'Estime uniquement le risque de « hard CHD » (infarctus du myocarde et '
        'décès coronarien) à 10 ans : ne couvre ni l\'accident vasculaire '
        "cérébral, ni l'insuffisance cardiaque, ni l'artériopathie "
        'périphérique — à la différence de scores de risque cardiovasculaire '
        'global plus récents (ex. SCORE2).',
    'Le cholestérol total et le HDL-cholestérol utilisés dans cette '
        "équation ne nécessitent pas de prélèvement à jeun (à la différence "
        'des paramètres dérivés des triglycérides).',
    "Développée et validée dans des cohortes majoritairement blanches "
        "nord-américaines des années 1970-1980 ; sa calibration peut ne pas "
        "s'appliquer directement à d'autres populations (ex. population "
        "malienne) — à interpréter avec prudence, notamment en valeur "
        "absolue de risque.",
  ],
  displayPrecision: 0,
);

/// Bande de risque à 10 ans issue de la table de correspondance
/// points → risque (%). Certaines bandes extrêmes de la table originale
/// sont exprimées comme "< 1 %" ou "≥ 30 %" plutôt que par une valeur
/// exacte.
///
/// CONVENTION DE REPRÉSENTATION (documentée ici car [ResultValue.value] est
/// un simple `double?`) : pour ces deux bandes ouvertes, on retourne la
/// borne de la classe (1 pour "< 1 %", 30 pour "≥ 30 %") comme valeur
/// numérique, et le qualificatif exact ("<" ou "≥") est reporté dans le
/// libellé du [ResultValue] ainsi que dans les entrées échoïsées, afin que
/// l'interface n'affiche jamais "1 %" ou "30 %" comme une valeur exacte
/// sans le qualificatif visible.
class _RiskBand {
  const _RiskBand(this.boundaryValue, {this.qualifier});

  final double boundaryValue;

  /// `null` si la table donne une valeur exacte ; sinon `'<'` ou `'≥'`.
  final String? qualifier;

  String get displayLabel => qualifier == null
      ? 'Risque coronarien (« hard CHD ») à 10 ans'
      : 'Risque coronarien (« hard CHD ») à 10 ans '
          '($qualifier ${boundaryValue.toStringAsFixed(0)} %, valeur affichée = '
          'borne ${qualifier == '<' ? 'supérieure' : 'inférieure'} de la classe)';
}

/// Bande d'âge en décennies (20-39, 40-49, 50-59, 60-69, 70-79) utilisée
/// pour indexer les tables de points « cholestérol total » et
/// « tabagisme », qui varient par décennie plutôt que par tranche de 5 ans.
int _decadeBandIndex(double age) {
  if (age < 40) return 0; // 20-39 (borne basse pratique : 30 ans, cf. validation)
  if (age < 50) return 1; // 40-49
  if (age < 60) return 2; // 50-59
  if (age < 70) return 3; // 60-69
  return 4; // 70-79
}

/// Bande de cholestérol total en mg/dL : <160, 160-199, 200-239, 240-279,
/// ≥280.
int _totalCholesterolBandIndex(double tcMgDl) {
  if (tcMgDl < 160) return 0;
  if (tcMgDl < 200) return 1;
  if (tcMgDl < 240) return 2;
  if (tcMgDl < 280) return 3;
  return 4;
}

/// Bande de pression artérielle systolique en mmHg : <120, 120-129,
/// 130-139, 140-159, ≥160.
int _systolicBandIndex(double sbpMmHg) {
  if (sbpMmHg < 120) return 0;
  if (sbpMmHg < 130) return 1;
  if (sbpMmHg < 140) return 2;
  if (sbpMmHg < 160) return 3;
  return 4;
}

/// Points d'âge — hommes (tranches de 5 ans, 20-34 à 75-79).
int _agePointsMen(double age) {
  if (age < 35) return -9; // 20-34
  if (age < 40) return -4; // 35-39
  if (age < 45) return 0; // 40-44
  if (age < 50) return 3; // 45-49
  if (age < 55) return 6; // 50-54
  if (age < 60) return 8; // 55-59
  if (age < 65) return 10; // 60-64
  if (age < 70) return 11; // 65-69
  if (age < 75) return 12; // 70-74
  return 13; // 75-79 (hors du domaine validé 30-74, table complète pour référence)
}

/// Points d'âge — femmes (tranches de 5 ans, 20-34 à 75-79).
int _agePointsWomen(double age) {
  if (age < 35) return -7; // 20-34
  if (age < 40) return -3; // 35-39
  if (age < 45) return 0; // 40-44
  if (age < 50) return 3; // 45-49
  if (age < 55) return 6; // 50-54
  if (age < 60) return 8; // 55-59
  if (age < 65) return 10; // 60-64
  if (age < 70) return 12; // 65-69
  if (age < 75) return 14; // 70-74
  return 16; // 75-79 (hors du domaine validé 30-74, table complète pour référence)
}

/// Points de cholestérol total — hommes, [décade][bande de cholestérol].
const List<List<int>> _menTotalCholesterolPoints = [
  [0, 4, 7, 9, 11], // 20-39
  [0, 3, 5, 6, 8], // 40-49
  [0, 2, 3, 4, 5], // 50-59
  [0, 1, 1, 2, 3], // 60-69
  [0, 0, 0, 1, 1], // 70-79
];

/// Points de cholestérol total — femmes, [décade][bande de cholestérol].
const List<List<int>> _womenTotalCholesterolPoints = [
  [0, 4, 8, 11, 13], // 20-39
  [0, 3, 6, 8, 10], // 40-49
  [0, 2, 4, 5, 7], // 50-59
  [0, 1, 2, 3, 4], // 60-69
  [0, 1, 1, 2, 2], // 70-79
];

/// Points de tabagisme actif — hommes, par décade (0 si non-fumeur).
const List<int> _menSmokerPoints = [8, 5, 3, 1, 1];

/// Points de tabagisme actif — femmes, par décade (0 si non-fumeur).
const List<int> _womenSmokerPoints = [9, 7, 4, 2, 1];

/// Points de HDL-cholestérol (mg/dL), identiques pour les deux sexes.
int _hdlPoints(double hdlMgDl) {
  if (hdlMgDl >= 60) return -1;
  if (hdlMgDl >= 50) return 0;
  if (hdlMgDl >= 40) return 1;
  return 2;
}

/// Points de PA systolique — hommes, non traitée, par bande.
const List<int> _menSbpUntreated = [0, 0, 1, 1, 2];

/// Points de PA systolique — hommes, traitée, par bande.
const List<int> _menSbpTreated = [0, 1, 2, 2, 3];

/// Points de PA systolique — femmes, non traitée, par bande.
const List<int> _womenSbpUntreated = [0, 1, 2, 3, 4];

/// Points de PA systolique — femmes, traitée, par bande.
const List<int> _womenSbpTreated = [0, 3, 4, 5, 6];

/// Table de correspondance points → risque à 10 ans (%), hommes.
_RiskBand _menRiskForPoints(int points) {
  if (points < 0) return const _RiskBand(1, qualifier: '<');
  if (points >= 17) return const _RiskBand(30, qualifier: '≥');
  const table = {
    0: 1, 1: 1, 2: 1, 3: 1, 4: 1, //
    5: 2, 6: 2, 7: 3, 8: 4, 9: 5, //
    10: 6, 11: 8, 12: 10, 13: 12, 14: 16, //
    15: 20, 16: 25, //
  };
  return _RiskBand(table[points]!.toDouble());
}

/// Catégorie de risque cardiovasculaire (cadre NCEP ATP III 2002),
/// habituellement utilisée conjointement avec le score de Framingham
/// (« hard CHD ») à 10 ans : faible < 10 % ; intermédiaire (« modérément
/// élevé ») 10-20 % ; élevé (équivalent à une maladie coronarienne établie)
/// > 20 %.
String _atpIIIRiskCategory(double riskPercent) {
  if (riskPercent < 10) return 'risque faible (< 10 %)';
  if (riskPercent <= 20) {
    return 'risque intermédiaire/modérément élevé (10-20 %)';
  }
  return 'risque élevé, équivalent à une maladie coronarienne établie (> 20 %)';
}

/// Table de correspondance points → risque à 10 ans (%), femmes.
_RiskBand _womenRiskForPoints(int points) {
  if (points < 9) return const _RiskBand(1, qualifier: '<');
  if (points >= 25) return const _RiskBand(30, qualifier: '≥');
  const table = {
    9: 1, 10: 1, 11: 1, 12: 1, //
    13: 2, 14: 2, 15: 3, 16: 4, 17: 5, //
    18: 6, 19: 8, 20: 11, 21: 14, 22: 17, //
    23: 22, 24: 27, //
  };
  return _RiskBand(table[points]!.toDouble());
}

/// Calcule le score de Framingham (Wilson et al. 1998) de risque coronarien
/// (« hard CHD ») à 10 ans, chez l'adulte de 30 à 74 ans sans antécédent de
/// maladie coronarienne connue.
CalculationResult calculateFraminghamRiskScore({
  required double age,
  required Sex sex,
  required double totalCholesterolValue,
  required String totalCholesterolUnit,
  required double hdlValue,
  required String hdlUnit,
  required double systolicBloodPressure,
  required bool treatedHypertension,
  required bool currentSmoker,
}) {
  final ageError = Validation.checkPositive(age, 'age', 'Âge');
  final tcError = Validation.checkPositive(
      totalCholesterolValue, 'totalCholesterolValue', 'Cholestérol total');
  final hdlError = Validation.checkPositive(hdlValue, 'hdlValue', 'HDL-cholestérol');
  final sbpError = Validation.checkPositive(
      systolicBloodPressure, 'systolicBloodPressure', 'Pression artérielle systolique');
  Validation.raiseIfAny([ageError, tcError, hdlError, sbpError]);

  if (age < 30 || age > 74) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'age',
        message:
            "Le score de Framingham (Wilson et al. 1998) n'est validé "
            "qu'entre 30 et 74 ans ; en dehors de cet intervalle, l'équation "
            "extrapolerait sans validation et ne doit pas être utilisée.",
      ),
    ]);
  }

  final tcMmolL =
      UnitRegistry.toCanonical(Analyte.cholesterol, totalCholesterolValue, totalCholesterolUnit);
  final tcMgDl = UnitRegistry.fromCanonical(Analyte.cholesterol, tcMmolL, 'mg/dL');
  final hdlMmolL = UnitRegistry.toCanonical(Analyte.cholesterol, hdlValue, hdlUnit);
  final hdlMgDl = UnitRegistry.fromCanonical(Analyte.cholesterol, hdlMmolL, 'mg/dL');

  final decadeIndex = _decadeBandIndex(age);
  final tcBandIndex = _totalCholesterolBandIndex(tcMgDl);
  final sbpBandIndex = _systolicBandIndex(systolicBloodPressure);
  final hdlPointsValue = _hdlPoints(hdlMgDl);

  final int agePointsValue;
  final int tcPointsValue;
  final int smokingPointsValue;
  final int sbpPointsValue;
  final _RiskBand riskBand;

  if (sex == Sex.male) {
    agePointsValue = _agePointsMen(age);
    tcPointsValue = _menTotalCholesterolPoints[decadeIndex][tcBandIndex];
    smokingPointsValue = currentSmoker ? _menSmokerPoints[decadeIndex] : 0;
    sbpPointsValue =
        treatedHypertension ? _menSbpTreated[sbpBandIndex] : _menSbpUntreated[sbpBandIndex];
  } else {
    agePointsValue = _agePointsWomen(age);
    tcPointsValue = _womenTotalCholesterolPoints[decadeIndex][tcBandIndex];
    smokingPointsValue = currentSmoker ? _womenSmokerPoints[decadeIndex] : 0;
    sbpPointsValue =
        treatedHypertension ? _womenSbpTreated[sbpBandIndex] : _womenSbpUntreated[sbpBandIndex];
  }

  final totalPoints =
      agePointsValue + tcPointsValue + smokingPointsValue + hdlPointsValue + sbpPointsValue;

  riskBand =
      sex == Sex.male ? _menRiskForPoints(totalPoints) : _womenRiskForPoints(totalPoints);

  return CalculationResult(
    formula: framinghamRiskScoreMeta,
    echoedInputs: {
      'Âge': '${age.toStringAsFixed(0)} ans (points : $agePointsValue)',
      'Sexe': sex.label,
      'Cholestérol total':
          '${totalCholesterolValue.toStringAsFixed(2)} $totalCholesterolUnit '
              '(${tcMgDl.toStringAsFixed(1)} mg/dL, points : $tcPointsValue)',
      'HDL-cholestérol': '${hdlValue.toStringAsFixed(2)} $hdlUnit '
          '(${hdlMgDl.toStringAsFixed(1)} mg/dL, points : $hdlPointsValue)',
      'Tabagisme actif': currentSmoker
          ? 'Oui (points : $smokingPointsValue)'
          : 'Non (points : 0)',
      'Pression artérielle systolique':
          '${systolicBloodPressure.toStringAsFixed(0)} mmHg (points : $sbpPointsValue)',
      'Traitement antihypertenseur': treatedHypertension ? 'Oui' : 'Non',
    },
    values: [
      ResultValue(
        label: 'Score de points (Framingham)',
        value: totalPoints.toDouble(),
        unit: 'points',
        precision: 0,
      ),
      ResultValue(
        label: riskBand.displayLabel,
        value: riskBand.boundaryValue,
        unit: '%',
        precision: 0,
      ),
    ],
    warnings: [
      CalculationWarning(
        'Catégorie de risque selon le cadre du NCEP ATP III (2002), '
        'habituellement utilisé conjointement avec ce score : '
        '${_atpIIIRiskCategory(riskBand.boundaryValue)}. Cette catégorie ne '
        'remplace pas une évaluation clinique globale ni les '
        'recommandations de prise en charge actuelles.',
        severity: WarningSeverity.info,
      ),
    ],
  );
}

// =============================================================================
// SCORE2 — risque cardiovasculaire (fatal et non fatal) à 10 ans.
// =============================================================================
//
// SCORE2 working group and ESC Cardiovascular risk collaboration (Hageman
// SHJ, McKay AJ, Ueda P, et al). SCORE2 risk prediction algorithms: new
// models to estimate 10-year risk of cardiovascular disease in Europe. Eur
// Heart J. 2021;42(25):2439-2454. DOI: 10.1093/eurheartj/ehab309.
//
// NOTE DE SÉCURITÉ SCIENTIFIQUE — traçabilité de la vérification des
// coefficients (lue en ligne pour cette implémentation, jamais reconstituée
// de mémoire) :
//
// 1) Structure du modèle (5 covariables — âge, tabagisme, pression
//    artérielle systolique, cholestérol total, HDL-cholestérol —, chacune
//    sauf l'âge portant un terme d'interaction avec l'âge ; 4 régions de
//    risque européennes ; population 40-69 ans sans MCV athéroscléreuse ni
//    diabète connus) confirmée par le texte intégral de l'article original
//    (PMC8248998, miroir NIH de l'article, consulté directement) :
//    « We used sex-specific and competing risk-adjusted models, including
//    age, smoking status, systolic blood pressure, and total- and
//    HDL-cholesterol » et « age-interactions were added for all
//    predictors » et « SCORE2 risk models are intended for use in people
//    aged 40-69 years ».
//    https://pmc.ncbi.nlm.nih.gov/articles/PMC8248998/
//
// 2) IMPORTANT — le cholestérol total et le HDL-cholestérol sont deux
//    covariables SÉPARÉES du modèle ajusté (chacune avec son propre
//    coefficient et son propre terme d'interaction avec l'âge) : ce n'est
//    PAS le cholestérol non-HDL qui sert de covariable unique. Le même
//    texte intégral le précise explicitement à propos des abaques
//    imprimées : « For practical and presentational purposes, the charts
//    are displayed according to non-HDL-cholesterol rather than total
//    cholesterol and HDL-cholesterol » — le non-HDL n'est qu'une
//    convention d'affichage des abaques, pas une covariable du modèle.
//
// 3) Valeurs numériques exactes (9 coefficients bêta par sexe, constante de
//    survie de base à 10 ans par sexe, et les 8 facteurs d'échelle de
//    recalibration régionale scale1/scale2 — 4 régions × 2 sexes) vérifiées
//    par recoupement de DEUX implémentations open source indépendantes,
//    de langages et d'auteurs différents, qui concordent au chiffre près
//    (4 décimales) sur chacune des valeurs utilisées ci-dessous :
//      - Package R « RiskScorescvd » (CRAN ; méthodologie publiée dans Open
//        Heart), fonction SCORE2, qui cite explicitement « SCORE2 Updated
//        Supplementary Material page 9 » et le titre exact de l'article
//        source :
//        https://raw.githubusercontent.com/dvicencio/RiskScorescvd/main/R/11_SCORE2_func.R
//      - Application .NET MAUI « CVDRiskScores » (dépôt indépendant),
//        Services/SCORE2/Score2Calculator.cs :
//        https://raw.githubusercontent.com/fauxtix/CVDRiskScores/master/Services/SCORE2/Score2Calculator.cs
//    Les deux sources n'étant accessibles qu'en implémentation logicielle
//    (les tableaux numériques de l'annexe supplémentaire officielle de
//    l'article n'ont pas pu être récupérés directement en texte lisible),
//    cette concordance stricte entre deux implémentations indépendantes est
//    le niveau de preuve retenu ici.
//
// 4) Répartition des pays par région de risque vérifiée par recoupement de
//    deux sources indépendantes, concordantes à l'exception d'un seul pays
//    (Slovénie, omise du tableau Evidencio mais présente dans « risque
//    modéré » sur les deux sources) :
//      - Notice d'utilisation SCORE2 v5 (juillet 2025) d'Evidencio,
//        dispositif médical marqué CE citant le même article source :
//        https://www.evidencio.com/models/download/manual/11061/5.0/EN
//      - Outil officiel HeartScore de l'ESC (European Society of
//        Cardiology) : https://www.heartscore.org/en_GB/heartscore-europe-risk-regions
//
// 5) Catégories de risque par bande d'âge (interprétation, pas le calcul
//    lui-même) vérifiées de façon identique sur la notice Evidencio
//    ci-dessus (qui cite les recommandations ESC 2021 et ESC diabète 2023)
//    et dans la documentation du package RiskScorescvd ci-dessus.
//
// Toute correction future de ces valeurs doit être documentée avec sa
// source exacte (URL et passage cité) dans ce commentaire.

/// Région de risque cardiovasculaire européenne SCORE2 (4 régions, établies
/// par le groupe de travail SCORE2 selon la mortalité cardiovasculaire
/// standardisée par pays — OMS). Chaque région a ses propres facteurs de
/// recalibration (scale1/scale2, par sexe).
///
/// Aucune région ne couvre l'Afrique subsaharienne : pour un patient
/// malien, le choix d'une région reste une approximation nécessaire, à
/// documenter et interpréter avec prudence (voir les limites de
/// [score2RiskMeta]).
enum RiskRegion {
  low(
    'Risque faible',
    "Pays à mortalité cardiovasculaire standardisée < 100/100 000. "
        'Exemples : France, Espagne, Belgique, Pays-Bas, Suisse, Danemark, '
        'Norvège, Luxembourg, Royaume-Uni, Israël (liste non exhaustive).',
  ),
  moderate(
    'Risque modéré',
    "Pays à mortalité cardiovasculaire standardisée 100 à < 150/100 000. "
        'Exemples : Allemagne, Italie, Portugal, Grèce, Autriche, Irlande, '
        'Islande, Suède, Finlande, Chypre, Malte, Slovénie, Saint-Marin '
        '(liste non exhaustive).',
  ),
  high(
    'Risque élevé',
    "Pays à mortalité cardiovasculaire standardisée 150 à < 300/100 000. "
        'Exemples : Pologne, République tchèque, Croatie, Hongrie, '
        'Slovaquie, Estonie, Turquie, Albanie, Bosnie-Herzégovine, '
        'Kazakhstan (liste non exhaustive).',
  ),
  veryHigh(
    'Risque très élevé',
    "Pays à mortalité cardiovasculaire standardisée ≥ 300/100 000. "
        'Exemples : Russie, Ukraine, Roumanie, Bulgarie, Biélorussie, '
        'Lituanie, Lettonie, Serbie, Macédoine du Nord, Moldavie, Géorgie, '
        "Arménie, Azerbaïdjan, ainsi que plusieurs pays d'Afrique du Nord "
        'et du Moyen-Orient inclus dans la cohorte de calibration (Algérie, '
        'Maroc, Tunisie, Égypte, Liban, Libye, Syrie) (liste non '
        'exhaustive).',
  );

  const RiskRegion(this.label, this.helpText);

  /// Libellé affiché en français.
  final String label;

  /// Aide contextuelle : seuil OMS et exemples de pays (non exhaustifs).
  final String helpText;
}

/// Neuf coefficients bêta (échelle de Cox) et constante de survie de base à
/// 10 ans (`baselineSurvival`, notée S0(10) ou λ dans l'article), pour un
/// sexe donné. Valeurs vérifiées — voir la note de sécurité scientifique
/// ci-dessus.
class _Score2Coefficients {
  const _Score2Coefficients({
    required this.age,
    required this.smoking,
    required this.systolicBloodPressure,
    required this.totalCholesterol,
    required this.hdl,
    required this.ageSmoking,
    required this.ageSystolicBloodPressure,
    required this.ageTotalCholesterol,
    required this.ageHdl,
    required this.baselineSurvival,
  });

  final double age;
  final double smoking;
  final double systolicBloodPressure;
  final double totalCholesterol;
  final double hdl;
  final double ageSmoking;
  final double ageSystolicBloodPressure;
  final double ageTotalCholesterol;
  final double ageHdl;

  /// Survie de base à 10 ans, aux valeurs centrées des covariables.
  final double baselineSurvival;
}

const _Score2Coefficients _score2CoefficientsMen = _Score2Coefficients(
  age: 0.3742,
  smoking: 0.6012,
  systolicBloodPressure: 0.2777,
  totalCholesterol: 0.1458,
  hdl: -0.2698,
  ageSmoking: -0.0755,
  ageSystolicBloodPressure: -0.0255,
  ageTotalCholesterol: -0.0281,
  ageHdl: 0.0426,
  baselineSurvival: 0.9605,
);

const _Score2Coefficients _score2CoefficientsWomen = _Score2Coefficients(
  age: 0.4648,
  smoking: 0.7744,
  systolicBloodPressure: 0.3131,
  totalCholesterol: 0.1002,
  hdl: -0.2606,
  ageSmoking: -0.1088,
  ageSystolicBloodPressure: -0.0277,
  ageTotalCholesterol: -0.0226,
  ageHdl: 0.0613,
  baselineSurvival: 0.9776,
);

/// Facteurs d'échelle de recalibration régionale (transformation
/// complementary log-log), spécifiques à la région et au sexe.
class _Score2RegionScale {
  const _Score2RegionScale(this.scale1, this.scale2);

  final double scale1;
  final double scale2;
}

const Map<RiskRegion, _Score2RegionScale> _score2ScaleMen = {
  RiskRegion.low: _Score2RegionScale(-0.5699, 0.7476),
  RiskRegion.moderate: _Score2RegionScale(-0.1565, 0.8009),
  RiskRegion.high: _Score2RegionScale(0.3207, 0.9360),
  RiskRegion.veryHigh: _Score2RegionScale(0.5836, 0.8294),
};

const Map<RiskRegion, _Score2RegionScale> _score2ScaleWomen = {
  RiskRegion.low: _Score2RegionScale(-0.7380, 0.7019),
  RiskRegion.moderate: _Score2RegionScale(-0.3143, 0.7701),
  RiskRegion.high: _Score2RegionScale(0.5710, 0.9369),
  RiskRegion.veryHigh: _Score2RegionScale(0.9412, 0.8329),
};

/// Catégorie de risque ESC 2021 (Visseren et al., voir [score2RiskMeta]),
/// selon la bande d'âge — seules les deux bandes pertinentes pour le
/// domaine de validité 40-69 ans de SCORE2 sont utilisées ici (la bande
/// ≥ 70 ans concerne SCORE2-OP, non implémenté).
String _score2RiskCategory(double age, double riskPercent) {
  if (age < 50) {
    if (riskPercent < 2.5) return 'risque faible à modéré (< 2,5 %)';
    if (riskPercent < 7.5) return 'risque élevé (2,5 à < 7,5 %)';
    return 'risque très élevé (≥ 7,5 %)';
  }
  // 50-69 ans (domaine de validité SCORE2 restant).
  if (riskPercent < 5) return 'risque faible à modéré (< 5 %)';
  if (riskPercent < 10) return 'risque élevé (5 à < 10 %)';
  return 'risque très élevé (≥ 10 %)';
}

/// SCORE2 — risque cardiovasculaire (fatal et non fatal) à 10 ans, chez
/// l'adulte de 40 à 69 ans apparemment en bonne santé, sans maladie
/// cardiovasculaire athéroscléreuse ni diabète connus (SCORE2 working
/// group et ESC Cardiovascular risk collaboration, 2021).
const FormulaMeta score2RiskMeta = FormulaMeta(
  id: 'score2_risk',
  name: 'SCORE2 — risque cardiovasculaire (fatal et non fatal) à 10 ans',
  shortName: 'SCORE2 (risque CV 10 ans)',
  category: CalculatorCategory.metabolic,
  version:
      'SCORE2 (SCORE2 working group et ESC Cardiovascular risk '
      'collaboration, 2021) — modèle de Cox par sexe avec termes '
      "d'interaction avec l'âge, recalibré selon 4 régions de risque "
      'européennes.',
  equation:
      'Prédicteur linéaire LP = β_âge×((Âge−60)/5) + β_tabac×Tabac + '
      'β_PAS×((PAS−120)/20) + β_CT×((CT−6)/1) + β_HDL×((HDL−1,3)/0,5) + '
      'termes d\'interaction [β_âge×tabac + β_âge×PAS + β_âge×CT + '
      "β_âge×HDL] × ((Âge−60)/5) — coefficients β distincts pour chaque "
      'sexe. Risque non calibré x = 1 − S0(10)^exp(LP), où S0(10) est la '
      'survie de base à 10 ans (par sexe). Risque calibré selon la région = '
      '1 − exp(−exp(scale1 + scale2 × ln(−ln(1−x)))), où scale1/scale2 '
      'sont les facteurs de recalibration propres à la région de risque et '
      'au sexe. CT = cholestérol total, HDL = HDL-cholestérol (mmol/L), '
      'PAS = pression artérielle systolique (mmHg), Tabac = 1 si fumeur '
      'actif sinon 0.',
  sources: [
    Reference(
      citation:
          'Hageman SHJ, McKay AJ, Ueda P, et al (SCORE2 working group and '
          'ESC Cardiovascular risk collaboration). SCORE2 risk prediction '
          'algorithms: new models to estimate 10-year risk of '
          'cardiovascular disease in Europe. Eur Heart J. '
          '2021;42(25):2439-2454.',
    ),
    Reference(
      citation:
          'Visseren FLJ, Mach F, Smulders YM, et al. 2021 ESC Guidelines '
          'on cardiovascular disease prevention in clinical practice. Eur '
          'Heart J. 2021;42(34):3227-3337.',
      note: 'catégories de risque par bande d\'âge (interprétation)',
    ),
  ],
  applicablePopulation:
      'Adulte de 40 à 69 ans, apparemment en bonne santé, sans maladie '
      'cardiovasculaire athéroscléreuse ni diabète (type 1 ou 2) connus.',
  forbiddenConditions: [
    "Âge < 40 ans ou > 69 ans : hors du domaine de validité de SCORE2 "
        '(vérifié automatiquement par le calculateur) — au-delà de 69 ans, '
        "le modèle dédié SCORE2-OP s'applique (non implémenté dans "
        'BioSigma).',
    'Maladie cardiovasculaire athéroscléreuse connue (coronaropathie, '
        'AVC/AIT, artériopathie périphérique) : non vérifiable par le '
        'calculateur — à exclure cliniquement, SCORE2 n\'estimant qu\'un '
        'risque de premier événement en prévention primaire.',
    'Diabète (type 1 ou 2) connu : non vérifiable par le calculateur — à '
        'exclure cliniquement ; un modèle dédié (SCORE2-Diabetes) existe '
        'pour cette population et n\'est pas implémenté dans BioSigma.',
  ],
  limitations: [
    'Développé et validé dans des cohortes européennes uniquement ; les 4 '
        "régions de recalibration ne couvrent aucun pays d'Afrique "
        "subsaharienne — l'application à une population malienne constitue "
        "une extrapolation hors du domaine de validation externe, à "
        "interpréter avec une prudence accrue, en particulier pour la "
        'valeur absolue du risque.',
    'Le cholestérol total et le HDL-cholestérol sont deux covariables '
        'distinctes du modèle statistique ajusté (chacune avec son propre '
        "coefficient et son propre terme d'interaction avec l'âge). Le "
        'cholestérol non-HDL affiché avec le résultat (calculé comme total '
        '− HDL) est fourni à titre informatif seulement — c\'est cette '
        "grandeur qui sert d'axe de lecture aux abaques SCORE2 imprimées "
        "par l'ESC, mais elle n'entre pas elle-même dans le calcul.",
    'Estime le risque combiné d\'événements cardiovasculaires fatals ET '
        'non fatals (infarctus du myocarde, AVC), à la différence du score '
        'de Framingham (« hard CHD » = infarctus et décès coronarien '
        'uniquement) implémenté par ailleurs dans BioSigma.',
    'Le choix de la région de risque européenne est une approximation '
        "nécessaire en l'absence de région propre à l'Afrique de l'Ouest ; "
        'ce choix doit être documenté et interprété avec prudence.',
  ],
  helpText:
      'Choisir la région de risque européenne la plus proche du profil '
      "épidémiologique cardiovasculaire du patient — aucune région ne "
      "couvre l'Afrique subsaharienne, ce choix reste une approximation. "
      'Le cholestérol total et le HDL-cholestérol ne nécessitent pas de '
      'prélèvement à jeun.',
  displayPrecision: 1,
);

/// Calcule le risque cardiovasculaire SCORE2 (fatal et non fatal) à 10 ans,
/// chez l'adulte de 40 à 69 ans apparemment en bonne santé, sans maladie
/// cardiovasculaire athéroscléreuse ni diabète connus.
CalculationResult calculateScore2Risk({
  required double age,
  required Sex sex,
  required bool currentSmoker,
  required double systolicBloodPressure,
  required double totalCholesterolValue,
  required String totalCholesterolUnit,
  required double hdlValue,
  required String hdlUnit,
  required RiskRegion region,
}) {
  final ageError = Validation.checkPositive(age, 'age', 'Âge');
  final sbpError = Validation.checkPositive(
      systolicBloodPressure, 'systolicBloodPressure', 'Pression artérielle systolique');
  final tcError = Validation.checkPositive(
      totalCholesterolValue, 'totalCholesterolValue', 'Cholestérol total');
  final hdlError = Validation.checkPositive(hdlValue, 'hdlValue', 'HDL-cholestérol');
  Validation.raiseIfAny([ageError, sbpError, tcError, hdlError]);

  if (age < 40 || age > 69) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'age',
        message:
            "SCORE2 (SCORE2 working group, 2021) n'est destiné qu'aux "
            "adultes de 40 à 69 ans ; en dehors de cet intervalle, "
            "l'équation extrapolerait sans validation et ne doit pas être "
            "utilisée (SCORE2-OP, non implémenté, s'applique au-delà de "
            '69 ans).',
      ),
    ]);
  }

  final tcMmolL =
      UnitRegistry.toCanonical(Analyte.cholesterol, totalCholesterolValue, totalCholesterolUnit);
  final hdlMmolL = UnitRegistry.toCanonical(Analyte.cholesterol, hdlValue, hdlUnit);

  if (hdlMmolL >= tcMmolL) {
    throw CalculationInputException([
      const FieldError(
        fieldId: 'hdl',
        message:
            'Le HDL-cholestérol ne peut pas être supérieur ou égal au '
            'cholestérol total.',
      ),
    ]);
  }

  final nonHdlMmolL = tcMmolL - hdlMmolL;

  final coefficients = sex == Sex.male ? _score2CoefficientsMen : _score2CoefficientsWomen;
  final scaleByRegion = sex == Sex.male ? _score2ScaleMen : _score2ScaleWomen;
  final scale = scaleByRegion[region]!;

  final centeredAge = (age - 60) / 5;
  final centeredSbp = (systolicBloodPressure - 120) / 20;
  final centeredTc = (tcMmolL - 6) / 1;
  final centeredHdl = (hdlMmolL - 1.3) / 0.5;
  final smoke = currentSmoker ? 1.0 : 0.0;

  final linearPredictor = coefficients.age * centeredAge +
      coefficients.smoking * smoke +
      coefficients.systolicBloodPressure * centeredSbp +
      coefficients.totalCholesterol * centeredTc +
      coefficients.hdl * centeredHdl +
      coefficients.ageSmoking * centeredAge * smoke +
      coefficients.ageSystolicBloodPressure * centeredAge * centeredSbp +
      coefficients.ageTotalCholesterol * centeredAge * centeredTc +
      coefficients.ageHdl * centeredAge * centeredHdl;

  final baselinePower =
      math.pow(coefficients.baselineSurvival, math.exp(linearPredictor)).toDouble();
  var uncalibratedRisk = 1 - baselinePower;
  // Garde-fou numérique : évite log(0) / log(nombre négatif) en cas de
  // profil de risque extrême (proche de 0 % ou 100 %).
  if (uncalibratedRisk <= 0) uncalibratedRisk = 1e-12;
  if (uncalibratedRisk >= 1) uncalibratedRisk = 1 - 1e-12;

  final complementaryLogLog = math.log(-math.log(1 - uncalibratedRisk));
  final calibratedRisk =
      1 - math.exp(-math.exp(scale.scale1 + scale.scale2 * complementaryLogLog));
  final riskPercent = calibratedRisk * 100;

  return CalculationResult(
    formula: score2RiskMeta,
    echoedInputs: {
      'Âge': '${age.toStringAsFixed(0)} ans',
      'Sexe': sex.label,
      'Région de risque': region.label,
      'Tabagisme actif': currentSmoker ? 'Oui' : 'Non',
      'Pression artérielle systolique': '${systolicBloodPressure.toStringAsFixed(0)} mmHg',
      'Cholestérol total':
          '${totalCholesterolValue.toStringAsFixed(2)} $totalCholesterolUnit '
              '(${tcMmolL.toStringAsFixed(2)} mmol/L)',
      'HDL-cholestérol': '${hdlValue.toStringAsFixed(2)} $hdlUnit '
          '(${hdlMmolL.toStringAsFixed(2)} mmol/L)',
      'Cholestérol non-HDL (informatif, non utilisé dans le calcul)':
          '${nonHdlMmolL.toStringAsFixed(2)} mmol/L',
    },
    values: [
      ResultValue(
        label: 'Risque SCORE2 à 10 ans (événements fatals et non fatals)',
        value: riskPercent,
        unit: '%',
        precision: 1,
      ),
    ],
    warnings: [
      CalculationWarning(
        'Catégorie de risque selon les recommandations ESC 2021 '
        '(Visseren et al.), pour la bande d\'âge concernée : '
        '${_score2RiskCategory(age, riskPercent)}. Cette catégorie ne '
        'remplace pas une évaluation clinique globale ni les '
        'recommandations de prise en charge actuelles.',
        severity: WarningSeverity.info,
      ),
      const CalculationWarning(
        "Modèle dérivé et calibré sur des cohortes européennes : aucune "
        "des 4 régions de risque SCORE2 ne couvre l'Afrique subsaharienne. "
        'Le choix de région ci-dessus est une approximation nécessaire ; '
        'le risque absolu affiché doit être interprété avec une prudence '
        'accrue dans ce contexte.',
        severity: WarningSeverity.caution,
      ),
    ],
  );
}
