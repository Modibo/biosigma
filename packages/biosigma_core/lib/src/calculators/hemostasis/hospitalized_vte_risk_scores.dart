import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../models/sex.dart';
import '../../validation.dart';

/// Score de Padua (risque thromboembolique veineux du patient hospitalisé
/// en médecine).
///
/// Modèle de prédiction dérivé et validé par Barbar et al. (2010) chez des
/// patients adultes hospitalisés en service de médecine (non chirurgical),
/// composé de 11 facteurs de risque valant chacun 1, 2 ou 3 points. Un
/// score ≥ 4 définit le risque élevé (thromboprophylaxie pharmacologique
/// généralement indiquée), repris par les recommandations ASH 2018.
const FormulaMeta paduaPredictionScoreMeta = FormulaMeta(
  id: 'padua_prediction_score',
  name:
      'Score de Padua (risque thromboembolique veineux, patient hospitalisé '
      'en médecine)',
  shortName: 'Score de Padua',
  category: CalculatorCategory.hemostasis,
  version: 'Barbar et al. 2010 (Padua Prediction Score)',
  equation:
      'Score de Padua = 3×[cancer actif] + 3×[antécédent de maladie '
      'thromboembolique veineuse, hors thrombose veineuse superficielle] + '
      "3×[mobilité réduite (alitement avec autorisation d'aller aux "
      'toilettes) ≥ 3 jours] + 3×[thrombophilie connue] + 2×[traumatisme '
      'et/ou chirurgie récent(e), ≤ 1 mois] + 1×[âge ≥ 70 ans] + '
      '1×[insuffisance cardiaque et/ou respiratoire] + 1×[infarctus du '
      'myocarde aigu ou AVC ischémique] + 1×[infection aiguë et/ou maladie '
      'rhumatologique] + 1×[obésité, IMC ≥ 30] + 1×[traitement hormonal en '
      'cours]. Plage : 0 à 20 points.',
  sources: [
    Reference(
      citation:
          'Barbar S, Noventa F, Rossetto V, Ferrari A, Brandolin B, '
          'Perlati M, De Bon E, Tormene D, Pagnan A, Prandoni P. A risk '
          'assessment model for the identification of hospitalized medical '
          'patients at risk for venous thromboembolism: the Padua '
          'Prediction Score. J Thromb Haemost. 2010;8(11):2450-2457.',
    ),
    Reference(
      citation:
          'Schünemann HJ, Cushman M, Burnett AE, Kahn SR, '
          'Beyer-Westendorf J, Spencer FA, et al. American Society of '
          'Hematology 2018 guidelines for management of venous '
          'thromboembolism: prophylaxis for hospitalized and '
          'nonhospitalized medical patients. Blood Adv. '
          '2018;2(22):3198-3225.',
      note:
          'Recommande l\'utilisation du score de Padua (seuil ≥ 4) pour '
          "orienter la thromboprophylaxie pharmacologique chez l'adulte "
          'hospitalisé en médecine, mise en balance avec le risque '
          'hémorragique (ex. score IMPROVE).',
    ),
  ],
  applicablePopulation:
      'Patient adulte (≥ 18 ans) hospitalisé en service de médecine (non '
      "chirurgical, hors réanimation), pour orienter la décision d'une "
      'thromboprophylaxie pharmacologique.',
  limitations: [
    'Un score ≥ 4 définit le risque élevé de maladie thromboembolique '
        'veineuse (thromboprophylaxie pharmacologique généralement '
        "indiquée en l'absence de contre-indication) ; un score < 4 "
        'définit le risque faible, selon les critères originaux (Barbar '
        'et al. 2010) repris par les recommandations ASH 2018.',
    "Cancer actif : métastases locales, régionales ou à distance, et/ou "
        'chimiothérapie ou radiothérapie dans les 6 mois précédents '
        '(définition de l\'étude originale).',
    'Mobilité réduite : alitement avec autorisation d\'aller aux toilettes '
        "(par limitation propre au patient ou sur prescription médicale) "
        'pendant au moins 3 jours (définition de l\'étude originale).',
    'Thrombophilie connue : déficit en antithrombine, protéine C ou S, '
        'facteur V Leiden, mutation G20210A du gène de la prothrombine, ou '
        'syndrome des antiphospholipides, déjà documenté biologiquement — '
        'ne doit pas être présumée en l\'absence de confirmation.',
    'Ce score évalue uniquement le risque thromboembolique veineux ; la '
        'décision de thromboprophylaxie pharmacologique doit toujours être '
        'mise en balance avec le risque hémorragique du patient (ex. '
        'score IMPROVE), les deux scores étant conçus pour un usage '
        'conjoint (ASH 2018) — sans lien automatique entre les deux '
        'calculateurs dans cette application.',
    "Validé chez l'adulte hospitalisé en service de médecine uniquement ; "
        'ne s\'applique pas au patient chirurgical (préférer le score de '
        'Caprini) ni au patient obstétrical ou de réanimation.',
    "Le résultat doit être confronté au contexte clinique et validé par "
        'le clinicien responsable avant toute décision de '
        'thromboprophylaxie.',
  ],
  displayPrecision: 0,
);

/// Calcule le score de Padua à partir de l'âge et des 10 autres facteurs de
/// risque binaires (présents/absents) définis par Barbar et al. (2010).
///
/// [ageYears] détermine automatiquement le facteur « âge ≥ 70 ans »
/// (1 point) ; les autres facteurs sont transmis directement.
CalculationResult calculatePaduaPredictionScore({
  required double ageYears,
  required bool activeCancer,
  required bool previousVte,
  required bool reducedMobility,
  required bool knownThrombophilicCondition,
  required bool recentTraumaOrSurgery,
  required bool heartOrRespiratoryFailure,
  required bool acuteMyocardialInfarctionOrIschemicStroke,
  required bool acuteInfectionOrRheumatologicDisorder,
  required bool obesityBmiOver30,
  required bool ongoingHormonalTreatment,
}) {
  final ageError =
      Validation.checkInRange(ageYears, 'ageYears', 'Âge', min: 18, max: 120);
  Validation.raiseIfAny([ageError]);

  final ageOver70 = ageYears >= 70;

  final threePointFactors = <String, bool>{
    'Cancer actif (métastases et/ou chimiothérapie/radiothérapie dans les '
            '6 derniers mois)':
        activeCancer,
    "Antécédent de maladie thromboembolique veineuse (hors thrombose "
            'veineuse superficielle)':
        previousVte,
    "Mobilité réduite (alitement avec autorisation d'aller aux toilettes, "
            '≥ 3 jours)':
        reducedMobility,
    'Thrombophilie connue (documentée biologiquement)':
        knownThrombophilicCondition,
  };

  final twoPointFactors = <String, bool>{
    'Traumatisme et/ou chirurgie récent(e) (≤ 1 mois)': recentTraumaOrSurgery,
  };

  final onePointFactors = <String, bool>{
    'Âge ≥ 70 ans': ageOver70,
    'Insuffisance cardiaque et/ou respiratoire': heartOrRespiratoryFailure,
    'Infarctus du myocarde aigu ou AVC ischémique':
        acuteMyocardialInfarctionOrIschemicStroke,
    'Infection aiguë et/ou maladie rhumatologique':
        acuteInfectionOrRheumatologicDisorder,
    'Obésité (IMC ≥ 30)': obesityBmiOver30,
    'Traitement hormonal en cours': ongoingHormonalTreatment,
  };

  int countChecked(Map<String, bool> factors) =>
      factors.values.where((checked) => checked).length;

  String checkedList(Map<String, bool> factors) {
    final checked = factors.entries.where((e) => e.value).map((e) => e.key).toList();
    return checked.isEmpty ? 'Aucun' : checked.join(' ; ');
  }

  final threeCount = countChecked(threePointFactors);
  final twoCount = countChecked(twoPointFactors);
  final oneCount = countChecked(onePointFactors);

  final total = threeCount * 3 + twoCount * 2 + oneCount * 1;

  final highRisk = total >= 4;

  return CalculationResult(
    formula: paduaPredictionScoreMeta,
    echoedInputs: {
      'Âge': '${ageYears.toStringAsFixed(0)} ans',
      'Facteurs à 3 points cochés (${threeCount * 3} pt)':
          checkedList(threePointFactors),
      'Facteurs à 2 points cochés (${twoCount * 2} pt)':
          checkedList(twoPointFactors),
      'Facteurs à 1 point cochés ($oneCount pt)':
          checkedList(onePointFactors),
    },
    values: [
      ResultValue(
        label: 'Score de Padua',
        value: total.toDouble(),
        unit: 'points',
        precision: 0,
      ),
    ],
    warnings: [
      CalculationWarning(
        highRisk
            ? 'Score ≥ 4 : risque élevé de maladie thromboembolique '
                'veineuse selon les critères originaux (Barbar et al. '
                '2010) — une thromboprophylaxie pharmacologique est '
                "généralement indiquée en l'absence de contre-indication "
                '(ASH 2018), après évaluation du risque hémorragique '
                '(ex. score IMPROVE).'
            : 'Score < 4 : risque faible de maladie thromboembolique '
                'veineuse selon les critères originaux (Barbar et al. '
                "2010) — une thromboprophylaxie pharmacologique n'est "
                'généralement pas indiquée sur ce seul critère (ASH 2018).',
        severity: WarningSeverity.info,
      ),
    ],
  );
}

/// Score IMPROVE (risque hémorragique du patient hospitalisé en médecine).
///
/// Modèle de prédiction dérivé et validé par Decousus et al. (2011, IMPROVE
/// Investigators) chez des patients adultes hospitalisés en service de
/// médecine, composé de facteurs de risque à points non entiers (0,5 point
/// près). Un score ≥ 7 définit le risque hémorragique élevé.
const FormulaMeta improveBleedingScoreMeta = FormulaMeta(
  id: 'improve_bleeding_score',
  name: 'Score IMPROVE (risque hémorragique, patient hospitalisé en '
      'médecine)',
  shortName: 'Score IMPROVE (hémorragie)',
  category: CalculatorCategory.hemostasis,
  version: 'Decousus et al. 2011 (IMPROVE Bleeding Risk Score)',
  equation:
      'Score IMPROVE = 1×[insuffisance rénale modérée, DFG 30-59 '
      'mL/min/1,73 m²] + 1×[sexe masculin] + 1,5×[âge 40-84 ans] + '
      '2×[cancer actuel] + 2×[maladie rhumatologique] + 2×[cathéter '
      'veineux central] + 2,5×[admission en unité de soins intensifs ou '
      'continus] + 2,5×[insuffisance rénale sévère, DFG < 30 mL/min/'
      '1,73 m²] + 2,5×[insuffisance hépatique, INR > 1,5] + 3,5×[âge '
      '≥ 85 ans] + 4×[plaquettes < 50×10⁹/L] + 4×[saignement dans les 3 '
      'mois précédents] + 4,5×[ulcère gastroduodénal actif]. Les paliers '
      "d'âge et de fonction rénale sont mutuellement exclusifs (un seul "
      "palier compté par facteur). Plage : 0 à 30,5 points.",
  sources: [
    Reference(
      citation:
          'Decousus H, Tapson VF, Bergmann JF, Chong BH, Froehlich JB, '
          'Kakkar AK, Merli GJ, Monreal M, Nakamura M, Pavanello R, '
          'Pini M, Piovella F, Spencer FA, Spyropoulos AC, Turpie AGG, '
          'Zotz RB, Fitzgerald G, Anderson FA Jr; IMPROVE Investigators. '
          'Factors at admission associated with bleeding risk in medical '
          'patients: findings from the IMPROVE investigators. Chest. '
          '2011;139(1):69-79.',
    ),
    Reference(
      citation:
          'Schünemann HJ, Cushman M, Burnett AE, Kahn SR, '
          'Beyer-Westendorf J, Spencer FA, et al. American Society of '
          'Hematology 2018 guidelines for management of venous '
          'thromboembolism: prophylaxis for hospitalized and '
          'nonhospitalized medical patients. Blood Adv. '
          '2018;2(22):3198-3225.',
      note:
          "Recommande la mise en balance systématique du risque "
          'thromboembolique (ex. score de Padua) et du risque '
          'hémorragique (score IMPROVE, seuil ≥ 7) avant toute '
          'thromboprophylaxie pharmacologique.',
    ),
  ],
  applicablePopulation:
      'Patient adulte (≥ 18 ans) hospitalisé en service de médecine, pour '
      'évaluer le risque hémorragique avant une éventuelle '
      'thromboprophylaxie pharmacologique.',
  analyticalConditions: [
    'Le débit de filtration glomérulaire (DFG) doit être renseigné en '
        'mL/min/1,73 m² (ex. CKD-EPI), déjà calculé en amont.',
    "L'INR doit être mesuré à l'admission, hors traitement anticoagulant "
        'correcteur si possible.',
  ],
  limitations: [
    'Un score ≥ 7 définit le risque hémorragique élevé ; un score < 7 '
        "définit l'absence de risque hémorragique accru, selon les "
        'critères originaux (Decousus et al. 2011).',
    'Les paliers d\'âge (< 40 / 40-84 / ≥ 85 ans) et de fonction rénale '
        '(≥ 60 / 30-59 / < 30 mL/min/1,73 m²) sont mutuellement exclusifs : '
        'seul le palier le plus élevé atteint est compté, jamais leur '
        'somme.',
    'Ce score évalue uniquement le risque hémorragique ; la décision de '
        'thromboprophylaxie pharmacologique doit toujours être mise en '
        'balance avec le risque thromboembolique veineux du patient (ex. '
        'score de Padua), les deux scores étant conçus pour un usage '
        'conjoint (ASH 2018) — sans lien automatique entre les deux '
        'calculateurs dans cette application.',
    "Le résultat doit être confronté au contexte clinique et validé par "
        'le clinicien responsable avant toute décision de '
        'thromboprophylaxie.',
  ],
  displayPrecision: 1,
);

/// Calcule le score IMPROVE de risque hémorragique à partir de l'âge, du
/// sexe, du DFG, de la numération plaquettaire, de l'INR et des facteurs
/// de risque binaires définis par Decousus et al. (2011).
CalculationResult calculateImproveBleedingScore({
  required double ageYears,
  required Sex sex,
  required double gfrMlMin173m2,
  required double plateletCountGL,
  required double inr,
  required bool icuOrCcuAdmission,
  required bool centralVenousCatheter,
  required bool rheumaticDisease,
  required bool currentCancer,
  required bool activeGastroduodenalUlcer,
  required bool bleedingInPrior3Months,
}) {
  final ageError =
      Validation.checkInRange(ageYears, 'ageYears', 'Âge', min: 18, max: 120);
  final gfrError = Validation.checkInRange(
      gfrMlMin173m2, 'gfrMlMin173m2', 'DFG',
      min: 0, max: 250);
  final plateletError = Validation.checkNonNegative(
      plateletCountGL, 'plateletCountGL', 'Numération plaquettaire');
  final inrError = Validation.checkPositive(inr, 'inr', 'INR');
  Validation.raiseIfAny([ageError, gfrError, plateletError, inrError]);

  double agePoints;
  String ageLabel;
  if (ageYears >= 85) {
    agePoints = 3.5;
    ageLabel = 'Âge ≥ 85 ans';
  } else if (ageYears >= 40) {
    agePoints = 1.5;
    ageLabel = 'Âge 40-84 ans';
  } else {
    agePoints = 0;
    ageLabel = 'Âge < 40 ans';
  }

  double renalPoints;
  String renalLabel;
  if (gfrMlMin173m2 < 30) {
    renalPoints = 2.5;
    renalLabel = 'Insuffisance rénale sévère (DFG < 30 mL/min/1,73 m²)';
  } else if (gfrMlMin173m2 < 60) {
    renalPoints = 1;
    renalLabel = 'Insuffisance rénale modérée (DFG 30-59 mL/min/1,73 m²)';
  } else {
    renalPoints = 0;
    renalLabel = 'DFG ≥ 60 mL/min/1,73 m² (pas de majoration)';
  }

  final sexPoints = sex == Sex.male ? 1.0 : 0.0;
  final hepaticFailure = inr > 1.5;
  final hepaticPoints = hepaticFailure ? 2.5 : 0.0;
  final thrombocytopenia = plateletCountGL < 50;
  final plateletPoints = thrombocytopenia ? 4.0 : 0.0;
  final icuPoints = icuOrCcuAdmission ? 2.5 : 0.0;
  final cvcPoints = centralVenousCatheter ? 2.0 : 0.0;
  final rheumaticPoints = rheumaticDisease ? 2.0 : 0.0;
  final cancerPoints = currentCancer ? 2.0 : 0.0;
  final ulcerPoints = activeGastroduodenalUlcer ? 4.5 : 0.0;
  final bleedingPoints = bleedingInPrior3Months ? 4.0 : 0.0;

  final total = agePoints +
      renalPoints +
      sexPoints +
      hepaticPoints +
      plateletPoints +
      icuPoints +
      cvcPoints +
      rheumaticPoints +
      cancerPoints +
      ulcerPoints +
      bleedingPoints;

  final highRisk = total >= 7;

  final checkedBinary = <String>[
    if (sex == Sex.male) 'Sexe masculin (1 pt)',
    if (hepaticFailure) 'Insuffisance hépatique, INR > 1,5 (2,5 pt)',
    if (thrombocytopenia) 'Plaquettes < 50×10⁹/L (4 pt)',
    if (icuOrCcuAdmission)
      'Admission en unité de soins intensifs ou continus (2,5 pt)',
    if (centralVenousCatheter) 'Cathéter veineux central (2 pt)',
    if (rheumaticDisease) 'Maladie rhumatologique (2 pt)',
    if (currentCancer) 'Cancer actuel (2 pt)',
    if (activeGastroduodenalUlcer) 'Ulcère gastroduodénal actif (4,5 pt)',
    if (bleedingInPrior3Months)
      'Saignement dans les 3 mois précédents (4 pt)',
  ];

  return CalculationResult(
    formula: improveBleedingScoreMeta,
    echoedInputs: {
      'Âge': '${ageYears.toStringAsFixed(0)} ans → $ageLabel '
          '(${agePoints.toStringAsFixed(1)} pt)',
      'Sexe': sex.label,
      'DFG': '${gfrMlMin173m2.toStringAsFixed(0)} mL/min/1,73 m² → '
          '$renalLabel (${renalPoints.toStringAsFixed(1)} pt)',
      'Numération plaquettaire':
          '${plateletCountGL.toStringAsFixed(0)} ×10⁹/L',
      'INR': inr.toStringAsFixed(2),
      'Facteurs binaires présents':
          checkedBinary.isEmpty ? 'Aucun' : checkedBinary.join(' ; '),
    },
    values: [
      ResultValue(
        label: 'Score IMPROVE (hémorragie)',
        value: total,
        unit: 'points',
        precision: 1,
      ),
    ],
    warnings: [
      CalculationWarning(
        highRisk
            ? 'Score ≥ 7 : risque hémorragique élevé selon les critères '
                'originaux (Decousus et al. 2011) — à mettre en balance '
                'avec le risque thromboembolique veineux (ex. score de '
                'Padua) avant toute thromboprophylaxie pharmacologique '
                '(ASH 2018).'
            : "Score < 7 : pas de risque hémorragique accru identifié "
                'selon les critères originaux (Decousus et al. 2011).',
        severity: WarningSeverity.info,
      ),
    ],
  );
}
