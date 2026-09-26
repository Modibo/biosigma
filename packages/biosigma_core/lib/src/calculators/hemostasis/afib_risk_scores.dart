import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../validation.dart';

/// Score HAS-BLED (risque hémorragique sous anticoagulation en fibrillation
/// atriale).
///
/// Neuf critères valant chacun 1 point (l'acronyme ne compte que 7 lettres
/// car le « A » regroupe deux critères indépendants — fonction rénale et
/// fonction hépatique — et le « D » en regroupe deux également —
/// médicaments et alcool) :
/// - H : Hypertension artérielle non contrôlée (PA systolique > 160 mmHg).
/// - A : Fonction rénale anormale (dialyse chronique, transplantation
///   rénale, ou créatininémie > 200 µmol/L [> 2,26 mg/dL]).
/// - A : Fonction hépatique anormale (hépatopathie chronique — ex.
///   cirrhose — ou anomalie biologique évocatrice : bilirubine > 2×
///   la limite supérieure de la normale associée à des ASAT/ALAT/phosphatases
///   alcalines > 3× la limite supérieure de la normale).
/// - S : Antécédent d'accident vasculaire cérébral.
/// - B : Antécédent d'hémorragie majeure ou prédisposition hémorragique.
/// - L : INR labile (INR instable ou élevé, temps dans la zone
///   thérapeutique < 60 %) — critère pertinent chez un patient sous
///   antivitamine K.
/// - E : Âge > 65 ans.
/// - D : Médicaments prédisposant au saignement (antiagrégants
///   plaquettaires, anti-inflammatoires non stéroïdiens).
/// - D : Consommation d'alcool excessive (≥ 8 verres/semaine).
const FormulaMeta hasBledScoreMeta = FormulaMeta(
  id: 'has_bled_score',
  name: 'Score HAS-BLED (risque hémorragique sous anticoagulation)',
  shortName: 'Score HAS-BLED',
  category: CalculatorCategory.hemostasis,
  version: 'Pisters et al. 2010',
  equation:
      'Score HAS-BLED = points(Hypertension non contrôlée) + '
      'points(Fonction rénale anormale) + points(Fonction hépatique '
      'anormale) + points(AVC) + points(Hémorragie/prédisposition) + '
      "points(INR labile) + points(Âge > 65 ans) + points(Médicaments "
      "prédisposants) + points(Alcool excessif) — 1 point par critère "
      'présent. Plage : 0 à 9 points.',
  sources: [
    Reference(
      citation:
          'Pisters R, Lane DA, Nieuwlaat R, de Vos CB, Crijns HJGM, Lip '
          'GYH. A Novel User-Friendly Score (HAS-BLED) To Assess 1-Year '
          'Risk of Major Bleeding in Patients With Atrial Fibrillation: '
          'The Euro Heart Survey. Chest. 2010;138(5):1093-1100.',
    ),
    Reference(
      citation:
          'Hindricks G, Potpara T, Dagres N, et al. 2020 ESC Guidelines '
          'for the diagnosis and management of atrial fibrillation '
          'developed in collaboration with the European Association for '
          'Cardio-Thoracic Surgery (EACTS). Eur Heart J. '
          '2021;42(5):373-498.',
      note: "catégorisation du risque et conduite à tenir face à un score élevé",
    ),
  ],
  applicablePopulation:
      'Patient adulte présentant une fibrillation atriale, sous '
      'anticoagulation ou chez qui une anticoagulation est envisagée.',
  limitations: [
    "Score composite fondé sur 9 critères binaires (voir la documentation "
        "du calcul pour la définition précise de chacun — fonction rénale, "
        'fonction hépatique, antécédent hémorragique, INR labile) ; chaque '
        'critère doit être apprécié cliniquement, pas seulement '
        'biologiquement.',
    'Catégorisation usuelle du risque hémorragique annuel (dérivée de '
        'Pisters et al. 2010 et reprise par la littérature ultérieure) : '
        '0-1 point = risque faible, 2 points = risque modéré, ≥ 3 points = '
        "risque élevé. Les taux de saignement annuels précis par score "
        "varient selon les cohortes de validation et ne sont pas repris "
        "ici pour éviter toute valeur numérique non consensuelle.",
    "Un score élevé (≥ 3) ne constitue pas en soi une contre-indication à "
        "l'anticoagulation orale : il doit inciter à corriger les facteurs "
        'de risque hémorragique modifiables et à un suivi clinique plus '
        'rapproché, conformément aux recommandations ESC (Hindricks et '
        'al. 2021).',
    "Le résultat doit être confronté au contexte clinique et validé par "
        'le clinicien responsable avant toute décision thérapeutique — '
        "comme tout résultat de BioSigma.",
  ],
  displayPrecision: 0,
);

/// Calcule le score HAS-BLED (risque hémorragique sous anticoagulation en
/// fibrillation atriale), selon les 9 critères originaux de Pisters et al.
/// (2010).
CalculationResult calculateHasBledScore({
  required bool hypertensionUncontrolled,
  required bool abnormalRenalFunction,
  required bool abnormalLiverFunction,
  required bool strokeHistory,
  required bool bleedingHistoryOrPredisposition,
  required bool labileInr,
  required double ageYears,
  required bool antiplateletOrNsaidUse,
  required bool alcoholExcess,
}) {
  final ageError = Validation.checkInRange(
    ageYears,
    'ageYears',
    'Âge',
    min: 18,
    max: 120,
  );
  Validation.raiseIfAny([ageError]);

  final hypertensionPoints = hypertensionUncontrolled ? 1 : 0;
  final renalPoints = abnormalRenalFunction ? 1 : 0;
  final hepaticPoints = abnormalLiverFunction ? 1 : 0;
  final strokePoints = strokeHistory ? 1 : 0;
  final bleedingPoints = bleedingHistoryOrPredisposition ? 1 : 0;
  final labileInrPoints = labileInr ? 1 : 0;
  final elderlyPoints = ageYears > 65 ? 1 : 0;
  final drugsPoints = antiplateletOrNsaidUse ? 1 : 0;
  final alcoholPoints = alcoholExcess ? 1 : 0;

  final total = hypertensionPoints +
      renalPoints +
      hepaticPoints +
      strokePoints +
      bleedingPoints +
      labileInrPoints +
      elderlyPoints +
      drugsPoints +
      alcoholPoints;

  final String category;
  if (total >= 3) {
    category = 'risque hémorragique élevé';
  } else if (total == 2) {
    category = 'risque hémorragique modéré';
  } else {
    category = 'risque hémorragique faible';
  }

  return CalculationResult(
    formula: hasBledScoreMeta,
    echoedInputs: {
      'Hypertension non contrôlée (PAS > 160 mmHg)':
          hypertensionUncontrolled ? 'Oui → 1 point' : 'Non → 0 point',
      'Fonction rénale anormale': abnormalRenalFunction ? 'Oui → 1 point' : 'Non → 0 point',
      'Fonction hépatique anormale': abnormalLiverFunction ? 'Oui → 1 point' : 'Non → 0 point',
      'Antécédent d\'AVC': strokeHistory ? 'Oui → 1 point' : 'Non → 0 point',
      'Hémorragie/prédisposition': bleedingHistoryOrPredisposition ? 'Oui → 1 point' : 'Non → 0 point',
      'INR labile (TTR < 60 %)': labileInr ? 'Oui → 1 point' : 'Non → 0 point',
      'Âge': '${ageYears.toStringAsFixed(0)} ans → $elderlyPoints point(s)',
      'Médicaments prédisposants (antiagrégants/AINS)':
          antiplateletOrNsaidUse ? 'Oui → 1 point' : 'Non → 0 point',
      'Alcool excessif (≥ 8 verres/semaine)': alcoholExcess ? 'Oui → 1 point' : 'Non → 0 point',
    },
    values: [
      ResultValue(label: 'Score HAS-BLED', value: total.toDouble(), unit: 'points', precision: 0),
    ],
    warnings: [
      CalculationWarning(
        'Score HAS-BLED = $total/9 : $category (catégorisation usuelle '
        '0-1 = faible, 2 = modéré, ≥ 3 = élevé, dérivée de Pisters et al. '
        '2010). Un score élevé doit inciter à corriger les facteurs de '
        'risque hémorragique modifiables et à un suivi rapproché, mais ne '
        "constitue pas à lui seul une contre-indication à l'anticoagulation "
        'orale (ESC, Hindricks et al. 2021).',
        severity: WarningSeverity.info,
      ),
    ],
  );
}

/// Score CHA₂DS₂-VASc (risque thromboembolique en fibrillation atriale non
/// valvulaire).
///
/// Huit critères, neuf points au maximum :
/// - C : Insuffisance cardiaque congestive ou dysfonction ventriculaire
///   gauche (clinique ou fraction d'éjection ≤ 40 %) — 1 point.
/// - H : Hypertension artérielle (PA ≥ 140/90 mmHg à plusieurs reprises,
///   ou traitement antihypertenseur en cours) — 1 point.
/// - A2 : Âge ≥ 75 ans — 2 points.
/// - D : Diabète sucré — 1 point.
/// - S2 : Antécédent d'AVC, d'AIT ou d'embolie systémique — 2 points.
/// - V : Maladie vasculaire (infarctus du myocarde, artériopathie
///   périphérique, plaque aortique) — 1 point.
/// - A : Âge 65-74 ans — 1 point.
/// - Sc : Sexe féminin — 1 point.
const FormulaMeta cha2ds2VascScoreMeta = FormulaMeta(
  id: 'cha2ds2_vasc_score',
  name: 'Score CHA₂DS₂-VASc (risque thromboembolique en fibrillation atriale)',
  shortName: 'Score CHA₂DS₂-VASc',
  category: CalculatorCategory.hemostasis,
  version: 'Lip et al. 2010',
  equation:
      'Score CHA₂DS₂-VASc = points(Insuffisance cardiaque/dysfonction VG) '
      '+ points(HTA) + points(Âge : 0/1/2) + points(Diabète) + '
      "points(AVC/AIT/embolie : 0 ou 2) + points(Maladie vasculaire) + "
      'points(Sexe féminin). Plage : 0 à 9 points.',
  sources: [
    Reference(
      citation:
          'Lip GYH, Nieuwlaat R, Pisters R, Lane DA, Crijns HJGM. '
          'Refining Clinical Risk Stratification for Predicting Stroke '
          'and Thromboembolism in Atrial Fibrillation Using a Novel Risk '
          'Factor-Based Approach: The Euro Heart Survey on Atrial '
          'Fibrillation. Chest. 2010;137(2):263-272.',
    ),
    Reference(
      citation:
          'Joglar JA, Chung MK, Armbruster AL, et al. 2023 '
          'ACC/AHA/ACCP/HRS Guideline for the Diagnosis and Management of '
          'Atrial Fibrillation: A Report of the American College of '
          'Cardiology/American Heart Association Joint Committee on '
          'Clinical Practice Guidelines. Circulation. 2024;149(1):e1-e156.',
      note: "seuils actuels d'indication de l'anticoagulation orale, différenciés selon le sexe",
    ),
  ],
  applicablePopulation:
      'Patient adulte présentant une fibrillation atriale non valvulaire, '
      "pour l'estimation du risque thromboembolique et l'aide à la "
      "décision d'anticoagulation.",
  limitations: [
    "Le sexe féminin est un modificateur de risque dépendant de l'âge et "
        "des autres facteurs, plutôt qu'un facteur de risque indépendant : "
        "un score de 1 chez une femme du seul fait du sexe (aucun autre "
        "critère) correspond à un risque faible et ne justifie pas, à lui "
        "seul, une anticoagulation, selon la formulation retenue par les "
        "recommandations ACC/AHA/ACCP/HRS 2023 (Joglar et al., "
        "Circulation 2024) — qui alignent le seuil de recommandation "
        'formelle (classe I) sur un score ≥ 2 chez l\'homme et ≥ 3 chez '
        'la femme, et le seuil « à envisager » (classe IIa) sur un score '
        'de 1 chez l\'homme ou de 2 chez la femme.',
    "Les recommandations européennes 2024 (Van Gelder IC, Kotecha D, et "
        "al. 2024 ESC Guidelines for the management of atrial "
        "fibrillation. Eur Heart J. 2024;45(36):3314-3414) ont, depuis, "
        "proposé un score dérivé CHA₂DS₂-VA qui retire le sexe comme "
        "critère indépendant (seuils : anticoagulation à envisager si "
        "score ≥ 1, recommandée si score ≥ 2, indépendamment du sexe) ; "
        "ce calculateur reste fondé sur le score CHA₂DS₂-VASc original "
        "(avec le critère de sexe), conformément à sa définition "
        'historique et à son usage encore largement répandu (dont les '
        'recommandations nord-américaines 2023).',
    "Le résultat doit être confronté au contexte clinique global "
        "(y compris le risque hémorragique, ex. score HAS-BLED) et validé "
        'par le clinicien responsable avant toute décision '
        "d'anticoagulation — comme tout résultat de BioSigma.",
  ],
  displayPrecision: 0,
);

/// Calcule le score CHA₂DS₂-VASc (risque thromboembolique en fibrillation
/// atriale non valvulaire), selon les critères originaux de Lip et al.
/// (2010), et fournit une interprétation du seuil d'anticoagulation selon
/// le sexe conformément aux recommandations ACC/AHA/ACCP/HRS 2023.
CalculationResult calculateCha2ds2VascScore({
  required bool congestiveHeartFailureOrLvDysfunction,
  required bool hypertension,
  required double ageYears,
  required bool diabetesMellitus,
  required bool strokeTiaOrThromboembolismHistory,
  required bool vascularDisease,
  required bool female,
}) {
  final ageError = Validation.checkInRange(
    ageYears,
    'ageYears',
    'Âge',
    min: 18,
    max: 120,
  );
  Validation.raiseIfAny([ageError]);

  final chfPoints = congestiveHeartFailureOrLvDysfunction ? 1 : 0;
  final hypertensionPoints = hypertension ? 1 : 0;
  final agePoints = ageYears >= 75
      ? 2
      : ageYears >= 65
          ? 1
          : 0;
  final diabetesPoints = diabetesMellitus ? 1 : 0;
  final strokePoints = strokeTiaOrThromboembolismHistory ? 2 : 0;
  final vascularPoints = vascularDisease ? 1 : 0;
  final sexPoints = female ? 1 : 0;

  final total = chfPoints +
      hypertensionPoints +
      agePoints +
      diabetesPoints +
      strokePoints +
      vascularPoints +
      sexPoints;

  final nonSexTotal = total - sexPoints;

  String interpretation;
  if (!female) {
    if (total == 0) {
      interpretation =
          'Risque thromboembolique faible : anticoagulation non '
          'recommandée sur la seule base de ce score (homme, score 0).';
    } else if (total == 1) {
      interpretation =
          'Anticoagulation orale à envisager (recommandation de classe '
          'IIa) : score de 1 chez un homme.';
    } else {
      interpretation =
          'Anticoagulation orale recommandée (recommandation de classe '
          'I) : score ≥ 2 chez un homme.';
    }
  } else {
    if (nonSexTotal == 0) {
      interpretation =
          'Risque thromboembolique faible : le seul point attribué au '
          'sexe féminin (aucun autre facteur de risque) ne justifie pas, '
          'à lui seul, une anticoagulation.';
    } else if (nonSexTotal == 1) {
      interpretation =
          'Anticoagulation orale à envisager (recommandation de classe '
          'IIa) : score de 2 chez une femme (1 point de facteur de '
          'risque + le point de sexe féminin).';
    } else {
      interpretation =
          'Anticoagulation orale recommandée (recommandation de classe '
          'I) : score ≥ 3 chez une femme.';
    }
  }

  return CalculationResult(
    formula: cha2ds2VascScoreMeta,
    echoedInputs: {
      'Insuffisance cardiaque / dysfonction VG':
          congestiveHeartFailureOrLvDysfunction ? 'Oui → 1 point' : 'Non → 0 point',
      'Hypertension artérielle': hypertension ? 'Oui → 1 point' : 'Non → 0 point',
      'Âge': '${ageYears.toStringAsFixed(0)} ans → $agePoints point(s)',
      'Diabète sucré': diabetesMellitus ? 'Oui → 1 point' : 'Non → 0 point',
      'Antécédent AVC/AIT/embolie': strokeTiaOrThromboembolismHistory
          ? 'Oui → 2 points'
          : 'Non → 0 point',
      'Maladie vasculaire': vascularDisease ? 'Oui → 1 point' : 'Non → 0 point',
      'Sexe féminin': female ? 'Oui → 1 point' : 'Non → 0 point',
    },
    values: [
      ResultValue(
        label: 'Score CHA₂DS₂-VASc',
        value: total.toDouble(),
        unit: 'points',
        precision: 0,
      ),
    ],
    warnings: [
      CalculationWarning(
        'Score CHA₂DS₂-VASc = $total/9. $interpretation Seuils selon '
        'les recommandations ACC/AHA/ACCP/HRS 2023 (Joglar et al., '
        'Circulation 2024;149(1):e1-e156) : ≥ 2 chez l\'homme ou ≥ 3 '
        'chez la femme = anticoagulation recommandée ; 1 chez l\'homme '
        'ou 2 chez la femme = à envisager ; 0 chez l\'homme ou 1 chez '
        'la femme (sexe seul) = risque faible.',
        severity: WarningSeverity.info,
      ),
    ],
  );
}
