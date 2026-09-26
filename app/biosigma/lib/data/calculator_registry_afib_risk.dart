import 'package:biosigma_core/biosigma_core.dart';

import '../models/calculator_definition.dart';
import '../models/calculator_field.dart';

/// Score HAS-BLED (risque hémorragique sous anticoagulation en fibrillation
/// atriale) — Pisters et al. 2010.
final CalculatorDefinition hasBledScoreDefinition = CalculatorDefinition(
  meta: hasBledScoreMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'hypertensionUncontrolled',
      label: 'Hypertension artérielle non contrôlée',
      kind: FieldKind.boolean,
      helpText: 'Pression artérielle systolique > 160 mmHg.',
    ),
    CalculatorFieldSpec(
      id: 'abnormalRenalFunction',
      label: 'Fonction rénale anormale',
      kind: FieldKind.boolean,
      helpText:
          'Dialyse chronique, transplantation rénale, ou créatininémie '
          '> 200 µmol/L (> 2,26 mg/dL).',
    ),
    CalculatorFieldSpec(
      id: 'abnormalLiverFunction',
      label: 'Fonction hépatique anormale',
      kind: FieldKind.boolean,
      helpText:
          'Hépatopathie chronique (ex. cirrhose) ou bilirubine > 2× la '
          'limite supérieure de la normale associée à des '
          'ASAT/ALAT/phosphatases alcalines > 3× la limite supérieure de '
          'la normale.',
    ),
    CalculatorFieldSpec(
      id: 'strokeHistory',
      label: 'Antécédent d\'accident vasculaire cérébral',
      kind: FieldKind.boolean,
    ),
    CalculatorFieldSpec(
      id: 'bleedingHistoryOrPredisposition',
      label: 'Antécédent d\'hémorragie majeure ou prédisposition hémorragique',
      kind: FieldKind.boolean,
    ),
    CalculatorFieldSpec(
      id: 'labileInr',
      label: 'INR labile',
      kind: FieldKind.boolean,
      helpText:
          'INR instable ou élevé, temps dans la zone thérapeutique '
          '< 60 % — pertinent chez un patient sous antivitamine K.',
    ),
    CalculatorFieldSpec(
      id: 'age',
      label: 'Âge',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'ans',
    ),
    CalculatorFieldSpec(
      id: 'antiplateletOrNsaidUse',
      label: 'Médicaments prédisposant au saignement',
      kind: FieldKind.boolean,
      helpText: 'Antiagrégants plaquettaires ou anti-inflammatoires non stéroïdiens (AINS).',
    ),
    CalculatorFieldSpec(
      id: 'alcoholExcess',
      label: 'Consommation d\'alcool excessive',
      kind: FieldKind.boolean,
      helpText: '≥ 8 verres d\'alcool par semaine.',
    ),
  ],
  compute: (values) {
    final age = values['age'] as NumericEntry;
    return calculateHasBledScore(
      hypertensionUncontrolled: values['hypertensionUncontrolled'] as bool,
      abnormalRenalFunction: values['abnormalRenalFunction'] as bool,
      abnormalLiverFunction: values['abnormalLiverFunction'] as bool,
      strokeHistory: values['strokeHistory'] as bool,
      bleedingHistoryOrPredisposition: values['bleedingHistoryOrPredisposition'] as bool,
      labileInr: values['labileInr'] as bool,
      ageYears: age.value!,
      antiplateletOrNsaidUse: values['antiplateletOrNsaidUse'] as bool,
      alcoholExcess: values['alcoholExcess'] as bool,
    );
  },
);

/// Score CHA₂DS₂-VASc (risque thromboembolique en fibrillation atriale non
/// valvulaire) — Lip et al. 2010.
final CalculatorDefinition cha2ds2VascScoreDefinition = CalculatorDefinition(
  meta: cha2ds2VascScoreMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'congestiveHeartFailureOrLvDysfunction',
      label: 'Insuffisance cardiaque congestive ou dysfonction ventriculaire gauche',
      kind: FieldKind.boolean,
      helpText: 'Insuffisance cardiaque clinique, ou fraction d\'éjection ≤ 40 %.',
    ),
    CalculatorFieldSpec(
      id: 'hypertension',
      label: 'Hypertension artérielle',
      kind: FieldKind.boolean,
      helpText:
          'PA ≥ 140/90 mmHg à plusieurs reprises, ou traitement '
          'antihypertenseur en cours.',
    ),
    CalculatorFieldSpec(
      id: 'age',
      label: 'Âge',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'ans',
      helpText: '0 point si < 65 ans, 1 point si 65-74 ans, 2 points si ≥ 75 ans.',
    ),
    CalculatorFieldSpec(
      id: 'diabetesMellitus',
      label: 'Diabète sucré',
      kind: FieldKind.boolean,
    ),
    CalculatorFieldSpec(
      id: 'strokeTiaOrThromboembolismHistory',
      label: 'Antécédent d\'AVC, d\'AIT ou d\'embolie systémique',
      kind: FieldKind.boolean,
      helpText: 'Vaut 2 points (et non 1).',
    ),
    CalculatorFieldSpec(
      id: 'vascularDisease',
      label: 'Maladie vasculaire',
      kind: FieldKind.boolean,
      helpText: 'Infarctus du myocarde, artériopathie périphérique, ou plaque aortique.',
    ),
    CalculatorFieldSpec(
      id: 'female',
      label: 'Sexe féminin',
      kind: FieldKind.boolean,
      helpText:
          'Modificateur de risque dépendant de l\'âge et des autres '
          'critères, plutôt que facteur de risque indépendant isolé.',
    ),
  ],
  compute: (values) {
    final age = values['age'] as NumericEntry;
    return calculateCha2ds2VascScore(
      congestiveHeartFailureOrLvDysfunction:
          values['congestiveHeartFailureOrLvDysfunction'] as bool,
      hypertension: values['hypertension'] as bool,
      ageYears: age.value!,
      diabetesMellitus: values['diabetesMellitus'] as bool,
      strokeTiaOrThromboembolismHistory:
          values['strokeTiaOrThromboembolismHistory'] as bool,
      vascularDisease: values['vascularDisease'] as bool,
      female: values['female'] as bool,
    );
  },
);

/// Scores de risque en fibrillation atriale (HAS-BLED, CHA₂DS₂-VASc) —
/// fichier séparé pour éviter les conflits de fusion avec d'autres agents
/// travaillant en parallèle sur d'autres calculateurs ; l'agrégation finale
/// (catalog.dart, calculator_registry.dart, biosigma_core.dart) est faite
/// manuellement ensuite.
final List<CalculatorDefinition> afibRiskCalculators = [
  hasBledScoreDefinition,
  cha2ds2VascScoreDefinition,
];
