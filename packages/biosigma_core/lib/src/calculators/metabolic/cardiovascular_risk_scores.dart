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
  );
}
