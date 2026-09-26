import 'package:biosigma_core/biosigma_core.dart';

import '../models/calculator_definition.dart';
import '../models/calculator_field.dart';

/// Score de Padua (risque thromboembolique veineux, patient hospitalisé en
/// médecine).
final CalculatorDefinition paduaPredictionScoreDefinition = CalculatorDefinition(
  meta: paduaPredictionScoreMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'age',
      label: 'Âge',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'ans',
      helpText: 'Âge en années révolues. Détermine automatiquement le '
          'facteur « âge ≥ 70 ans » (1 point).',
    ),
    CalculatorFieldSpec(
      id: 'activeCancer',
      label: 'Cancer actif',
      kind: FieldKind.boolean,
      helpText: 'Métastases locales, régionales ou à distance, et/ou '
          'chimiothérapie ou radiothérapie dans les 6 mois précédents.',
    ),
    CalculatorFieldSpec(
      id: 'previousVte',
      label: 'Antécédent de maladie thromboembolique veineuse',
      kind: FieldKind.boolean,
      helpText: 'Antécédent de TVP ou d\'embolie pulmonaire, à l\'exclusion '
          'de la thrombose veineuse superficielle.',
    ),
    CalculatorFieldSpec(
      id: 'reducedMobility',
      label: 'Mobilité réduite',
      kind: FieldKind.boolean,
      helpText: 'Alitement avec autorisation d\'aller aux toilettes (par '
          'limitation propre au patient ou sur prescription médicale) '
          'depuis au moins 3 jours.',
    ),
    CalculatorFieldSpec(
      id: 'knownThrombophilicCondition',
      label: 'Thrombophilie connue',
      kind: FieldKind.boolean,
      helpText: 'Déficit en antithrombine, protéine C ou S, facteur V '
          'Leiden, mutation G20210A de la prothrombine, ou syndrome des '
          'antiphospholipides, déjà documenté biologiquement.',
    ),
    CalculatorFieldSpec(
      id: 'recentTraumaOrSurgery',
      label: 'Traumatisme et/ou chirurgie récent(e)',
      kind: FieldKind.boolean,
      helpText: 'Traumatisme ou intervention chirurgicale dans le mois '
          'précédent (≤ 1 mois).',
    ),
    CalculatorFieldSpec(
      id: 'heartOrRespiratoryFailure',
      label: 'Insuffisance cardiaque et/ou respiratoire',
      kind: FieldKind.boolean,
    ),
    CalculatorFieldSpec(
      id: 'acuteMyocardialInfarctionOrIschemicStroke',
      label: 'Infarctus du myocarde aigu ou AVC ischémique',
      kind: FieldKind.boolean,
    ),
    CalculatorFieldSpec(
      id: 'acuteInfectionOrRheumatologicDisorder',
      label: 'Infection aiguë et/ou maladie rhumatologique',
      kind: FieldKind.boolean,
    ),
    CalculatorFieldSpec(
      id: 'obesityBmiOver30',
      label: 'Obésité (IMC ≥ 30)',
      kind: FieldKind.boolean,
    ),
    CalculatorFieldSpec(
      id: 'ongoingHormonalTreatment',
      label: 'Traitement hormonal en cours',
      kind: FieldKind.boolean,
      helpText: 'Contraception orale œstroprogestative, traitement '
          'hormonal substitutif, etc.',
    ),
  ],
  compute: (values) {
    final age = (values['age'] as NumericEntry).value!;
    return calculatePaduaPredictionScore(
      ageYears: age,
      activeCancer: values['activeCancer'] as bool,
      previousVte: values['previousVte'] as bool,
      reducedMobility: values['reducedMobility'] as bool,
      knownThrombophilicCondition: values['knownThrombophilicCondition'] as bool,
      recentTraumaOrSurgery: values['recentTraumaOrSurgery'] as bool,
      heartOrRespiratoryFailure: values['heartOrRespiratoryFailure'] as bool,
      acuteMyocardialInfarctionOrIschemicStroke:
          values['acuteMyocardialInfarctionOrIschemicStroke'] as bool,
      acuteInfectionOrRheumatologicDisorder:
          values['acuteInfectionOrRheumatologicDisorder'] as bool,
      obesityBmiOver30: values['obesityBmiOver30'] as bool,
      ongoingHormonalTreatment: values['ongoingHormonalTreatment'] as bool,
    );
  },
);

/// Score IMPROVE (risque hémorragique, patient hospitalisé en médecine).
final CalculatorDefinition improveBleedingScoreDefinition = CalculatorDefinition(
  meta: improveBleedingScoreMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'age',
      label: 'Âge',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'ans',
      helpText: 'Âge en années révolues. Détermine automatiquement le '
          'palier de points (< 40 / 40-84 / ≥ 85 ans).',
    ),
    const CalculatorFieldSpec(
      id: 'sex',
      label: 'Sexe',
      kind: FieldKind.enumSelect,
      enumOptions: [
        EnumFieldOption(value: Sex.female, label: 'Femme'),
        EnumFieldOption(value: Sex.male, label: 'Homme'),
      ],
    ),
    const CalculatorFieldSpec(
      id: 'gfr',
      label: 'Débit de filtration glomérulaire (DFG)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'mL/min/1,73 m²',
      helpText: 'DFG estimé (ex. CKD-EPI), déjà calculé en amont. '
          'Détermine automatiquement le palier de points (≥ 60 / 30-59 / '
          '< 30).',
    ),
    const CalculatorFieldSpec(
      id: 'plateletCount',
      label: 'Numération plaquettaire',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '×10⁹/L',
      helpText: 'Numération plaquettaire du patient, en ×10⁹/L (= G/L).',
    ),
    const CalculatorFieldSpec(
      id: 'inr',
      label: 'INR',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '',
      helpText: "International Normalized Ratio (INR) à l'admission — "
          'grandeur sans unité. Un INR > 1,5 définit l\'insuffisance '
          'hépatique du modèle.',
    ),
    const CalculatorFieldSpec(
      id: 'icuOrCcuAdmission',
      label: 'Admission en unité de soins intensifs ou continus',
      kind: FieldKind.boolean,
    ),
    const CalculatorFieldSpec(
      id: 'centralVenousCatheter',
      label: 'Cathéter veineux central',
      kind: FieldKind.boolean,
    ),
    const CalculatorFieldSpec(
      id: 'rheumaticDisease',
      label: 'Maladie rhumatologique',
      kind: FieldKind.boolean,
    ),
    const CalculatorFieldSpec(
      id: 'currentCancer',
      label: 'Cancer actuel',
      kind: FieldKind.boolean,
    ),
    const CalculatorFieldSpec(
      id: 'activeGastroduodenalUlcer',
      label: 'Ulcère gastroduodénal actif',
      kind: FieldKind.boolean,
    ),
    const CalculatorFieldSpec(
      id: 'bleedingInPrior3Months',
      label: 'Saignement dans les 3 mois précédents',
      kind: FieldKind.boolean,
    ),
  ],
  compute: (values) {
    final age = (values['age'] as NumericEntry).value!;
    final gfr = (values['gfr'] as NumericEntry).value!;
    final plateletCount = (values['plateletCount'] as NumericEntry).value!;
    final inr = (values['inr'] as NumericEntry).value!;
    return calculateImproveBleedingScore(
      ageYears: age,
      sex: values['sex'] as Sex,
      gfrMlMin173m2: gfr,
      plateletCountGL: plateletCount,
      inr: inr,
      icuOrCcuAdmission: values['icuOrCcuAdmission'] as bool,
      centralVenousCatheter: values['centralVenousCatheter'] as bool,
      rheumaticDisease: values['rheumaticDisease'] as bool,
      currentCancer: values['currentCancer'] as bool,
      activeGastroduodenalUlcer: values['activeGastroduodenalUlcer'] as bool,
      bleedingInPrior3Months: values['bleedingInPrior3Months'] as bool,
    );
  },
);

/// Scores de risque thromboembolique/hémorragique du patient hospitalisé en
/// médecine (Padua, IMPROVE) — fichier séparé pour éviter les conflits de
/// fusion avec d'autres agents travaillant en parallèle ; l'agrégation
/// finale (catalog.dart, calculator_registry.dart, export du barrel
/// biosigma_core.dart) est faite manuellement ensuite.
final List<CalculatorDefinition> hospitalizedVteRiskCalculators = [
  paduaPredictionScoreDefinition,
  improveBleedingScoreDefinition,
];
