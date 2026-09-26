import 'package:biosigma_core/biosigma_core.dart';

import '../models/calculator_definition.dart';
import '../models/calculator_field.dart';

/// Score de Caprini (risque thromboembolique veineux périopératoire).
///
/// Fichier séparé des autres registres d'hémostase pour éviter les
/// conflits de fusion avec d'autres agents travaillant en parallèle ;
/// l'agrégation finale (catalog.dart, calculator_registry.dart) est faite
/// manuellement ensuite.
final CalculatorDefinition capriniScoreDefinition = CalculatorDefinition(
  meta: capriniScoreMeta,
  fields: const [
    // --- Facteurs à 1 point ---
    CalculatorFieldSpec(
      id: 'age41to60',
      label: 'Âge 41-60 ans',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'minorSurgeryPlanned',
      label: 'Chirurgie mineure prévue (< 45 min)',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'priorMajorSurgeryHistory',
      label: 'Antécédent de chirurgie majeure',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'varicoseVeins',
      label: 'Varices veineuses',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'inflammatoryBowelDiseaseHistory',
      label: "Antécédent de maladie inflammatoire chronique de l'intestin",
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'currentSwollenLegs',
      label: 'Jambes gonflées (actuellement)',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'obesityBmiOver25',
      label: 'Obésité (IMC > 25 kg/m²)',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'acuteMyocardialInfarction',
      label: 'Infarctus du myocarde aigu',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'congestiveHeartFailureUnder1Month',
      label: 'Insuffisance cardiaque congestive (< 1 mois)',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'sepsisUnder1Month',
      label: 'Sepsis (< 1 mois)',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'seriousLungDiseaseOrPneumoniaUnder1Month',
      label: 'Maladie pulmonaire grave dont pneumopathie (< 1 mois)',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'abnormalPulmonaryFunction',
      label: 'Fonction pulmonaire anormale (ex. BPCO)',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'oralContraceptiveOrHormoneReplacementTherapy',
      label: 'Contraception orale ou traitement hormonal substitutif',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'pregnancyOrPostpartumUnder1Month',
      label: 'Grossesse ou post-partum (< 1 mois)',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'historyOfUnexplainedStillbirthOrRecurrentMiscarriageOrToxemia',
      label:
          'Antécédent de mort-né inexpliqué, fausses couches à répétition, '
          'ou accouchement prématuré avec toxémie ou retard de croissance',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'medicalPatientCurrentlyOnBedRest',
      label: 'Patient médical actuellement alité',
      kind: FieldKind.boolean,
      helpText: '1 point.',
    ),
    CalculatorFieldSpec(
      id: 'otherRiskFactorNotListed',
      label: 'Autre facteur de risque non listé',
      kind: FieldKind.boolean,
      helpText:
          '1 point. Ex. tabagisme, diabète sucré, chimiothérapie, '
          'transfusion sanguine récente, chirurgie prolongée > 2 h.',
    ),
    // --- Facteurs à 2 points ---
    CalculatorFieldSpec(
      id: 'age61to74',
      label: 'Âge 61-74 ans',
      kind: FieldKind.boolean,
      helpText: '2 points.',
    ),
    CalculatorFieldSpec(
      id: 'arthroscopicSurgery',
      label: 'Chirurgie arthroscopique',
      kind: FieldKind.boolean,
      helpText: '2 points.',
    ),
    CalculatorFieldSpec(
      id: 'malignancyCurrentOrPrevious',
      label: 'Cancer actuel ou antérieur',
      kind: FieldKind.boolean,
      helpText: '2 points.',
    ),
    CalculatorFieldSpec(
      id: 'majorOpenSurgeryOver45Minutes',
      label: 'Chirurgie majeure ouverte (> 45 min)',
      kind: FieldKind.boolean,
      helpText: '2 points.',
    ),
    CalculatorFieldSpec(
      id: 'laparoscopicSurgeryOver45Minutes',
      label: 'Chirurgie laparoscopique (> 45 min)',
      kind: FieldKind.boolean,
      helpText: '2 points.',
    ),
    CalculatorFieldSpec(
      id: 'bedConfinementOver72Hours',
      label: 'Alitement / confinement au lit (> 72 h)',
      kind: FieldKind.boolean,
      helpText: '2 points.',
    ),
    CalculatorFieldSpec(
      id: 'immobilizingPlasterCast',
      label: 'Plâtre immobilisant',
      kind: FieldKind.boolean,
      helpText: '2 points.',
    ),
    CalculatorFieldSpec(
      id: 'centralVenousAccess',
      label: 'Voie veineuse centrale',
      kind: FieldKind.boolean,
      helpText: '2 points.',
    ),
    // --- Facteurs à 3 points ---
    CalculatorFieldSpec(
      id: 'age75OrOlder',
      label: 'Âge ≥ 75 ans',
      kind: FieldKind.boolean,
      helpText: '3 points.',
    ),
    CalculatorFieldSpec(
      id: 'historyOfVte',
      label:
          'Antécédent personnel de maladie thromboembolique veineuse (TVP/EP)',
      kind: FieldKind.boolean,
      helpText: '3 points.',
    ),
    CalculatorFieldSpec(
      id: 'familyHistoryOfVteOrThrombophilia',
      label: 'Antécédent familial de MTEV ou thrombophilie',
      kind: FieldKind.boolean,
      helpText: '3 points.',
    ),
    CalculatorFieldSpec(
      id: 'factorVLeidenPositive',
      label: 'Facteur V Leiden positif',
      kind: FieldKind.boolean,
      helpText: '3 points.',
    ),
    CalculatorFieldSpec(
      id: 'prothrombin20210APositive',
      label: 'Mutation du gène de la prothrombine 20210A positive',
      kind: FieldKind.boolean,
      helpText: '3 points.',
    ),
    CalculatorFieldSpec(
      id: 'elevatedSerumHomocysteine',
      label: 'Hyperhomocystéinémie',
      kind: FieldKind.boolean,
      helpText: '3 points.',
    ),
    CalculatorFieldSpec(
      id: 'lupusAnticoagulantPositive',
      label: 'Anticoagulant lupique positif',
      kind: FieldKind.boolean,
      helpText: '3 points.',
    ),
    CalculatorFieldSpec(
      id: 'elevatedAnticardiolipinAntibodies',
      label: 'Anticorps anticardiolipine élevés',
      kind: FieldKind.boolean,
      helpText: '3 points.',
    ),
    CalculatorFieldSpec(
      id: 'heparinInducedThrombocytopeniaHistory',
      label: "Antécédent de thrombopénie induite par l'héparine (TIH)",
      kind: FieldKind.boolean,
      helpText: '3 points.',
    ),
    CalculatorFieldSpec(
      id: 'otherCongenitalOrAcquiredThrombophilia',
      label: 'Autre thrombophilie congénitale ou acquise',
      kind: FieldKind.boolean,
      helpText: '3 points.',
    ),
    // --- Facteurs à 5 points ---
    CalculatorFieldSpec(
      id: 'electiveMajorLowerExtremityArthroplasty',
      label: 'Arthroplastie élective majeure du membre inférieur (hanche/genou)',
      kind: FieldKind.boolean,
      helpText: '5 points.',
    ),
    CalculatorFieldSpec(
      id: 'hipPelvisOrLegFractureUnder1Month',
      label: "Fracture de la hanche, du bassin ou d'un membre inférieur (< 1 mois)",
      kind: FieldKind.boolean,
      helpText: '5 points.',
    ),
    CalculatorFieldSpec(
      id: 'strokeUnder1Month',
      label: 'AVC (< 1 mois)',
      kind: FieldKind.boolean,
      helpText: '5 points.',
    ),
    CalculatorFieldSpec(
      id: 'multipleTraumaUnder1Month',
      label: 'Traumatisme multiple / grave (< 1 mois)',
      kind: FieldKind.boolean,
      helpText: '5 points.',
    ),
    CalculatorFieldSpec(
      id: 'acuteSpinalCordInjuryWithParalysisUnder1Month',
      label: 'Lésion médullaire aiguë avec paralysie (< 1 mois)',
      kind: FieldKind.boolean,
      helpText: '5 points.',
    ),
  ],
  compute: (values) {
    bool b(String id) => values[id] as bool? ?? false;
    return calculateCapriniScore(
      age41to60: b('age41to60'),
      minorSurgeryPlanned: b('minorSurgeryPlanned'),
      priorMajorSurgeryHistory: b('priorMajorSurgeryHistory'),
      varicoseVeins: b('varicoseVeins'),
      inflammatoryBowelDiseaseHistory: b('inflammatoryBowelDiseaseHistory'),
      currentSwollenLegs: b('currentSwollenLegs'),
      obesityBmiOver25: b('obesityBmiOver25'),
      acuteMyocardialInfarction: b('acuteMyocardialInfarction'),
      congestiveHeartFailureUnder1Month: b('congestiveHeartFailureUnder1Month'),
      sepsisUnder1Month: b('sepsisUnder1Month'),
      seriousLungDiseaseOrPneumoniaUnder1Month:
          b('seriousLungDiseaseOrPneumoniaUnder1Month'),
      abnormalPulmonaryFunction: b('abnormalPulmonaryFunction'),
      oralContraceptiveOrHormoneReplacementTherapy:
          b('oralContraceptiveOrHormoneReplacementTherapy'),
      pregnancyOrPostpartumUnder1Month: b('pregnancyOrPostpartumUnder1Month'),
      historyOfUnexplainedStillbirthOrRecurrentMiscarriageOrToxemia:
          b('historyOfUnexplainedStillbirthOrRecurrentMiscarriageOrToxemia'),
      medicalPatientCurrentlyOnBedRest: b('medicalPatientCurrentlyOnBedRest'),
      otherRiskFactorNotListed: b('otherRiskFactorNotListed'),
      age61to74: b('age61to74'),
      arthroscopicSurgery: b('arthroscopicSurgery'),
      malignancyCurrentOrPrevious: b('malignancyCurrentOrPrevious'),
      majorOpenSurgeryOver45Minutes: b('majorOpenSurgeryOver45Minutes'),
      laparoscopicSurgeryOver45Minutes: b('laparoscopicSurgeryOver45Minutes'),
      bedConfinementOver72Hours: b('bedConfinementOver72Hours'),
      immobilizingPlasterCast: b('immobilizingPlasterCast'),
      centralVenousAccess: b('centralVenousAccess'),
      age75OrOlder: b('age75OrOlder'),
      historyOfVte: b('historyOfVte'),
      familyHistoryOfVteOrThrombophilia: b('familyHistoryOfVteOrThrombophilia'),
      factorVLeidenPositive: b('factorVLeidenPositive'),
      prothrombin20210APositive: b('prothrombin20210APositive'),
      elevatedSerumHomocysteine: b('elevatedSerumHomocysteine'),
      lupusAnticoagulantPositive: b('lupusAnticoagulantPositive'),
      elevatedAnticardiolipinAntibodies: b('elevatedAnticardiolipinAntibodies'),
      heparinInducedThrombocytopeniaHistory:
          b('heparinInducedThrombocytopeniaHistory'),
      otherCongenitalOrAcquiredThrombophilia:
          b('otherCongenitalOrAcquiredThrombophilia'),
      electiveMajorLowerExtremityArthroplasty:
          b('electiveMajorLowerExtremityArthroplasty'),
      hipPelvisOrLegFractureUnder1Month: b('hipPelvisOrLegFractureUnder1Month'),
      strokeUnder1Month: b('strokeUnder1Month'),
      multipleTraumaUnder1Month: b('multipleTraumaUnder1Month'),
      acuteSpinalCordInjuryWithParalysisUnder1Month:
          b('acuteSpinalCordInjuryWithParalysisUnder1Month'),
    );
  },
);

/// Calculateurs relatifs au score de Caprini — fichier séparé pour éviter
/// les conflits de fusion avec d'autres agents travaillant en parallèle sur
/// d'autres scores ; l'agrégation finale (catalog.dart,
/// calculator_registry.dart) est faite manuellement ensuite.
final List<CalculatorDefinition> capriniCalculators = [
  capriniScoreDefinition,
];
