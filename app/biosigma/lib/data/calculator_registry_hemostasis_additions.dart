import 'package:biosigma_core/biosigma_core.dart';

import '../models/calculator_definition.dart';
import '../models/calculator_field.dart';

/// Rapport normalisé dRVVT (recherche d'anticoagulant lupique).
final CalculatorDefinition drvvtNormalizedRatioDefinition = CalculatorDefinition(
  meta: drvvtNormalizedRatioMeta,
  fields: [
    const CalculatorFieldSpec(
      id: 'patientScreen',
      label: 'Temps de dépistage patient',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 's',
      helpText: 'Temps de dépistage dRVVT mesuré chez le patient, en secondes.',
    ),
    const CalculatorFieldSpec(
      id: 'normalScreen',
      label: 'Temps de dépistage plasma normal',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 's',
      helpText: 'Temps de dépistage dRVVT du plasma témoin normal (pool de plasmas normaux), en secondes.',
    ),
    const CalculatorFieldSpec(
      id: 'patientConfirm',
      label: 'Temps de confirmation patient',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 's',
      helpText: 'Temps de confirmation dRVVT (réactif à phospholipides faibles) mesuré chez le patient, en secondes.',
    ),
    const CalculatorFieldSpec(
      id: 'normalConfirm',
      label: 'Temps de confirmation plasma normal',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 's',
      helpText: 'Temps de confirmation dRVVT (réactif à phospholipides faibles) du plasma témoin normal, en secondes.',
    ),
  ],
  compute: (values) {
    final patientScreen = (values['patientScreen'] as NumericEntry).value!;
    final normalScreen = (values['normalScreen'] as NumericEntry).value!;
    final patientConfirm = (values['patientConfirm'] as NumericEntry).value!;
    final normalConfirm = (values['normalConfirm'] as NumericEntry).value!;
    return calculateDrvvtNormalizedRatio(
      patientScreenSeconds: patientScreen,
      normalScreenSeconds: normalScreen,
      patientConfirmSeconds: patientConfirm,
      normalConfirmSeconds: normalConfirm,
    );
  },
);

/// Score SIC (coagulopathie induite par le sepsis).
final CalculatorDefinition sicScoreDefinition = CalculatorDefinition(
  meta: sicScoreMeta,
  fields: [
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
      helpText: 'International Normalized Ratio (INR) du patient — grandeur sans unité.',
    ),
    const CalculatorFieldSpec(
      id: 'sofaRespiratoryCardiovascularSubscore',
      label: 'Sous-score SOFA respiratoire + cardiovasculaire',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'points',
      helpText:
          'Somme des sous-scores SOFA respiratoire et cardiovasculaire (0 à 4 points au total), '
          'calculée séparément avant la saisie ici.',
    ),
  ],
  compute: (values) {
    final plateletCount = (values['plateletCount'] as NumericEntry).value!;
    final inr = (values['inr'] as NumericEntry).value!;
    final sofaSubscore =
        (values['sofaRespiratoryCardiovascularSubscore'] as NumericEntry).value!;
    return calculateSicScore(
      plateletCountGL: plateletCount,
      inr: inr,
      sofaRespiratoryCardiovascularSubscore: sofaSubscore,
    );
  },
);

/// Calculateurs d'hémostase ajoutés (rapport normalisé dRVVT, score SIC) —
/// fichier séparé de `calculator_registry_hemostasis.dart` pour éviter les
/// conflits de fusion avec d'autres agents travaillant en parallèle sur ce
/// domaine ; l'agrégation finale (catalog.dart, calculator_registry.dart)
/// est faite manuellement ensuite.
final List<CalculatorDefinition> hemostasisAdditionsCalculators = [
  drvvtNormalizedRatioDefinition,
  sicScoreDefinition,
];
