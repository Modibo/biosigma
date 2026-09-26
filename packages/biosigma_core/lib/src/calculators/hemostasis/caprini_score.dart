import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';

/// Score de Caprini (évaluation du risque thromboembolique veineux
/// périopératoire).
///
/// Somme de facteurs de risque individuels valant chacun 1, 2, 3 ou 5
/// points (liste consolidée à partir du modèle original de Caprini et de
/// ses mises à jour ; voir [sources] et le détail des facteurs ci-dessous).
const FormulaMeta capriniScoreMeta = FormulaMeta(
  id: 'caprini_score',
  name: 'Score de Caprini (risque thromboembolique veineux périopératoire)',
  shortName: 'Score de Caprini',
  category: CalculatorCategory.hemostasis,
  version: 'Caprini 2005/2013 (facteurs à 1, 2, 3 et 5 points)',
  equation:
      'Score de Caprini = somme des points de chaque facteur de risque '
      'coché (facteurs à 1, 2, 3 ou 5 points chacun) — voir la liste '
      'détaillée des facteurs dans la fiche technique. Aucune borne '
      'supérieure fixe (les facteurs cumulés s\'additionnent).',
  sources: [
    Reference(
      citation:
          'Caprini JA. Thrombosis risk assessment as a guide to quality '
          'patient care. Dis Mon. 2005;51(2-3):70-78.',
    ),
    Reference(
      citation:
          'Caprini JA. Risk assessment as a guide for the prevention of '
          'the many faces of venous thromboembolism. Am J Surg. '
          '2010;199(1 Suppl):S3-10.',
    ),
    Reference(
      citation:
          'Gould MK, Garcia DA, Wren SM, Karanicolas PJ, Arcelus JI, '
          'Heit JA, Samama CM; American College of Chest Physicians. '
          'Prevention of VTE in nonorthopedic surgical patients: '
          'Antithrombotic Therapy and Prevention of Thrombosis, 9th ed: '
          'American College of Chest Physicians Evidence-Based Clinical '
          'Practice Guidelines. Chest. 2012;141(2 Suppl):e227S-e277S.',
      note:
          'Source des catégories de risque (très faible/faible/modéré/'
          'élevé) et de leurs seuils.',
    ),
  ],
  applicablePopulation:
      'Patient adulte en contexte chirurgical ou périopératoire, pour '
      "guider la décision de thromboprophylaxie. Ne remplace pas l'usage "
      "d'outils spécifiques validés pour d'autres populations (ex. "
      'patient médical non chirurgical : score de Padua/IMPROVE).',
  limitations: [
    'Le score de Caprini a été publié et mis à jour à plusieurs reprises '
        '(1991, 2005, 2010, 2013) ; cette implémentation reprend la liste '
        'de facteurs la plus largement citée en pratique courante et ne '
        'prétend pas couvrir chaque variante ultra-rare publiée dans '
        'certaines versions.',
    'Le résultat doit être confronté au contexte clinique et validé par '
        'le clinicien responsable avant toute décision de '
        'thromboprophylaxie — comme tout résultat de BioSigma.',
    'Les seuils de risque et les recommandations de prophylaxie associées '
        'varient selon la spécialité chirurgicale considérée dans la '
        'littérature (chirurgie générale, orthopédique, plastique, etc.) ; '
        "l'application retient la catégorisation générale la plus "
        'largement citée (ACCP/CHEST, Gould et al. 2012).',
  ],
  displayPrecision: 0,
);

/// Calcule le score de Caprini à partir de la liste de facteurs de risque
/// cochés. Chaque paramètre correspond à un facteur de risque individuel ;
/// `true` si le facteur est présent chez le patient.
///
/// Facteurs à 1 point, 2 points, 3 points et 5 points conformément au
/// modèle de Caprini (2005/2013) — voir [capriniScoreMeta].
CalculationResult calculateCapriniScore({
  // --- Facteurs à 1 point ---
  bool age41to60 = false,
  bool minorSurgeryPlanned = false,
  bool priorMajorSurgeryHistory = false,
  bool varicoseVeins = false,
  bool inflammatoryBowelDiseaseHistory = false,
  bool currentSwollenLegs = false,
  bool obesityBmiOver25 = false,
  bool acuteMyocardialInfarction = false,
  bool congestiveHeartFailureUnder1Month = false,
  bool sepsisUnder1Month = false,
  bool seriousLungDiseaseOrPneumoniaUnder1Month = false,
  bool abnormalPulmonaryFunction = false,
  bool oralContraceptiveOrHormoneReplacementTherapy = false,
  bool pregnancyOrPostpartumUnder1Month = false,
  bool historyOfUnexplainedStillbirthOrRecurrentMiscarriageOrToxemia = false,
  bool medicalPatientCurrentlyOnBedRest = false,
  bool otherRiskFactorNotListed = false,
  // --- Facteurs à 2 points ---
  bool age61to74 = false,
  bool arthroscopicSurgery = false,
  bool malignancyCurrentOrPrevious = false,
  bool majorOpenSurgeryOver45Minutes = false,
  bool laparoscopicSurgeryOver45Minutes = false,
  bool bedConfinementOver72Hours = false,
  bool immobilizingPlasterCast = false,
  bool centralVenousAccess = false,
  // --- Facteurs à 3 points ---
  bool age75OrOlder = false,
  bool historyOfVte = false,
  bool familyHistoryOfVteOrThrombophilia = false,
  bool factorVLeidenPositive = false,
  bool prothrombin20210APositive = false,
  bool elevatedSerumHomocysteine = false,
  bool lupusAnticoagulantPositive = false,
  bool elevatedAnticardiolipinAntibodies = false,
  bool heparinInducedThrombocytopeniaHistory = false,
  bool otherCongenitalOrAcquiredThrombophilia = false,
  // --- Facteurs à 5 points ---
  bool electiveMajorLowerExtremityArthroplasty = false,
  bool hipPelvisOrLegFractureUnder1Month = false,
  bool strokeUnder1Month = false,
  bool multipleTraumaUnder1Month = false,
  bool acuteSpinalCordInjuryWithParalysisUnder1Month = false,
}) {
  final onePointFactors = <String, bool>{
    'Âge 41-60 ans': age41to60,
    'Chirurgie mineure prévue (< 45 min)': minorSurgeryPlanned,
    'Antécédent de chirurgie majeure': priorMajorSurgeryHistory,
    'Varices veineuses': varicoseVeins,
    'Antécédent de maladie inflammatoire chronique de l\'intestin':
        inflammatoryBowelDiseaseHistory,
    'Jambes gonflées (actuellement)': currentSwollenLegs,
    'Obésité (IMC > 25)': obesityBmiOver25,
    'Infarctus du myocarde aigu': acuteMyocardialInfarction,
    'Insuffisance cardiaque congestive (< 1 mois)':
        congestiveHeartFailureUnder1Month,
    'Sepsis (< 1 mois)': sepsisUnder1Month,
    'Maladie pulmonaire grave dont pneumopathie (< 1 mois)':
        seriousLungDiseaseOrPneumoniaUnder1Month,
    'Fonction pulmonaire anormale (ex. BPCO)': abnormalPulmonaryFunction,
    'Contraception orale ou traitement hormonal substitutif':
        oralContraceptiveOrHormoneReplacementTherapy,
    'Grossesse ou post-partum (< 1 mois)': pregnancyOrPostpartumUnder1Month,
    'Antécédent de mort-né inexpliqué, fausses couches à répétition, ou '
            'accouchement prématuré avec toxémie ou retard de croissance':
        historyOfUnexplainedStillbirthOrRecurrentMiscarriageOrToxemia,
    'Patient médical actuellement alité': medicalPatientCurrentlyOnBedRest,
    'Autre facteur de risque non listé': otherRiskFactorNotListed,
  };

  final twoPointFactors = <String, bool>{
    'Âge 61-74 ans': age61to74,
    'Chirurgie arthroscopique': arthroscopicSurgery,
    'Cancer actuel ou antérieur': malignancyCurrentOrPrevious,
    'Chirurgie majeure ouverte (> 45 min)': majorOpenSurgeryOver45Minutes,
    'Chirurgie laparoscopique (> 45 min)': laparoscopicSurgeryOver45Minutes,
    'Alitement/confinement au lit (> 72 h)': bedConfinementOver72Hours,
    'Plâtre immobilisant': immobilizingPlasterCast,
    'Voie veineuse centrale': centralVenousAccess,
  };

  final threePointFactors = <String, bool>{
    'Âge ≥ 75 ans': age75OrOlder,
    'Antécédent personnel de maladie thromboembolique veineuse (TVP/EP)':
        historyOfVte,
    'Antécédent familial de MTEV ou thrombophilie':
        familyHistoryOfVteOrThrombophilia,
    'Facteur V Leiden positif': factorVLeidenPositive,
    'Mutation du gène de la prothrombine 20210A positive':
        prothrombin20210APositive,
    'Hyperhomocystéinémie': elevatedSerumHomocysteine,
    'Anticoagulant lupique positif': lupusAnticoagulantPositive,
    'Anticorps anticardiolipine élevés': elevatedAnticardiolipinAntibodies,
    'Antécédent de thrombopénie induite par l\'héparine (TIH)':
        heparinInducedThrombocytopeniaHistory,
    'Autre thrombophilie congénitale ou acquise':
        otherCongenitalOrAcquiredThrombophilia,
  };

  final fivePointFactors = <String, bool>{
    'Arthroplastie élective majeure du membre inférieur (hanche/genou)':
        electiveMajorLowerExtremityArthroplasty,
    'Fracture de la hanche, du bassin ou d\'un membre inférieur (< 1 mois)':
        hipPelvisOrLegFractureUnder1Month,
    'AVC (< 1 mois)': strokeUnder1Month,
    'Traumatisme multiple/grave (< 1 mois)': multipleTraumaUnder1Month,
    'Lésion médullaire aiguë avec paralysie (< 1 mois)':
        acuteSpinalCordInjuryWithParalysisUnder1Month,
  };

  int pointsFor(Map<String, bool> factors) =>
      factors.values.where((checked) => checked).length;

  final onePointCount = pointsFor(onePointFactors);
  final twoPointCount = pointsFor(twoPointFactors);
  final threePointCount = pointsFor(threePointFactors);
  final fivePointCount = pointsFor(fivePointFactors);

  final total = onePointCount * 1 +
      twoPointCount * 2 +
      threePointCount * 3 +
      fivePointCount * 5;

  String checkedList(Map<String, bool> factors) {
    final checked = factors.entries.where((e) => e.value).map((e) => e.key).toList();
    return checked.isEmpty ? 'Aucun' : checked.join(' ; ');
  }

  final String riskCategoryMessage;
  if (total == 0) {
    riskCategoryMessage =
        'Score = 0 : risque très faible selon les catégories ACCP/CHEST '
        '(Gould et al. 2012) — aucune prophylaxie spécifique au-delà de la '
        "mobilisation précoce n'est généralement recommandée.";
  } else if (total <= 2) {
    riskCategoryMessage =
        'Score 1-2 : risque faible selon les catégories ACCP/CHEST (Gould '
        'et al. 2012) — prophylaxie mécanique généralement suffisante.';
  } else if (total <= 4) {
    riskCategoryMessage =
        'Score 3-4 : risque modéré selon les catégories ACCP/CHEST (Gould '
        'et al. 2012).';
  } else {
    riskCategoryMessage =
        'Score ≥ 5 : risque élevé selon les catégories ACCP/CHEST (Gould '
        'et al. 2012) — une prophylaxie pharmacologique associée à une '
        'prophylaxie mécanique est généralement indiquée, sauf '
        'contre-indication.';
  }

  return CalculationResult(
    formula: capriniScoreMeta,
    echoedInputs: {
      'Facteurs à 1 point cochés ($onePointCount pt)': checkedList(onePointFactors),
      'Facteurs à 2 points cochés (${twoPointCount * 2} pt)': checkedList(twoPointFactors),
      'Facteurs à 3 points cochés (${threePointCount * 3} pt)': checkedList(threePointFactors),
      'Facteurs à 5 points cochés (${fivePointCount * 5} pt)': checkedList(fivePointFactors),
    },
    values: [
      ResultValue(
        label: 'Score de Caprini',
        value: total.toDouble(),
        unit: 'points',
        precision: 0,
      ),
    ],
    warnings: [
      CalculationWarning(
        riskCategoryMessage,
        severity: WarningSeverity.info,
      ),
    ],
  );
}
