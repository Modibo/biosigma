import '../../models/formula_meta.dart';
import '../../models/reference.dart';
import '../../models/result.dart';
import '../../validation.dart';

/// Constantes érythrocytaires (VGM, TCMH, CCMH) et valeurs absolues
/// leucocytaires (ANC, ALC) : **relations de définition** appliquées aux
/// résultats d'une numération formule sanguine. Aucun intervalle de
/// référence ni seuil n'est comparé (ils dépendent de l'âge, du sexe, de
/// l'origine et de la méthode du laboratoire).

const Reference _definition = Reference(
  citation:
      'Relations de définition des constantes érythrocytaires (VGM = Ht / GR ; TCMH = Hb / GR ; '
      'CCMH = Hb / Ht), attribuées à Wintrobe : citation primaire à compléter par le laboratoire. '
      'Valeurs absolues leucocytaires : pourcentage × numération leucocytaire / 100.',
  note: 'à relire par le laboratoire',
);

// ---------------------------------------------------------------------------
// a) Constantes érythrocytaires.
// ---------------------------------------------------------------------------

const FormulaMeta redCellIndicesMeta = FormulaMeta(
  id: 'red_cell_indices',
  name: 'Constantes érythrocytaires (VGM, TCMH, CCMH)',
  shortName: 'VGM, TCMH, CCMH',
  category: CalculatorCategory.hematology,
  version: 'Constantes érythrocytaires (définitions)',
  equation:
      'VGM (fL) = Ht (%) × 10 / GR (×10¹²/L)\n'
      'TCMH (pg) = Hb (g/dL) × 10 / GR (×10¹²/L)\n'
      'CCMH (g/dL) = Hb (g/dL) × 100 / Ht (%)',
  sources: [_definition],
  applicablePopulation: 'Tout âge (les intervalles de référence, eux, dépendent de l\'âge et du sexe).',
  analyticalConditions: [
    'Hb, hématocrite et numération des globules rouges issus du même prélèvement et du même automate.',
    'Si l\'automate mesure directement le VGM (et calcule l\'hématocrite), saisir la valeur mesurée '
        'de l\'hématocrite : le VGM recalculé ici peut différer de quelques dixièmes.',
  ],
  limitations: [
    'Aucun intervalle de référence n\'est comparé : il dépend de l\'âge, du sexe, de la méthode.',
    'Agglutinines froides, hyperleucocytose majeure, hyperlipémie : les trois valeurs saisies '
        'peuvent être faussées, donc les constantes aussi.',
  ],
  displayPrecision: 1,
  helpText: 'Hb en g/dL, hématocrite en %, numération des globules rouges en ×10¹²/L.',
);

/// VGM, TCMH et CCMH à partir de l'hémoglobine, de l'hématocrite et de la
/// numération des globules rouges.
CalculationResult calculateRedCellIndices({
  required double hemoglobinGdL,
  required double hematocritPercent,
  required double rbcTeraL,
}) {
  Validation.raiseIfAny([
    Validation.checkPositive(hemoglobinGdL, 'hemoglobin', 'Hémoglobine'),
    Validation.checkInRange(hematocritPercent, 'hematocrit', 'Hématocrite', min: 0.0000001, max: 100),
    Validation.checkPositive(rbcTeraL, 'rbc', 'Numération des globules rouges (GR)'),
  ]);

  final mcv = hematocritPercent * 10 / rbcTeraL;
  final mch = hemoglobinGdL * 10 / rbcTeraL;
  final mchc = hemoglobinGdL * 100 / hematocritPercent;

  return CalculationResult(
    formula: redCellIndicesMeta,
    echoedInputs: {
      'Hémoglobine': '${hemoglobinGdL.toStringAsFixed(1)} g/dL',
      'Hématocrite': '${hematocritPercent.toStringAsFixed(1)} %',
      'GR': '${rbcTeraL.toStringAsFixed(2)} ×10¹²/L',
    },
    values: [
      ResultValue(label: 'VGM', value: mcv, unit: 'fL', precision: 1),
      ResultValue(label: 'TCMH', value: mch, unit: 'pg', precision: 1),
      ResultValue(label: 'CCMH', value: mchc, unit: 'g/dL', precision: 1),
    ],
    warnings: const [
      CalculationWarning(
        'Aucun intervalle de référence n\'est comparé : il dépend de l\'âge, du sexe et de la '
        'méthode de votre laboratoire.',
        severity: WarningSeverity.info,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// b) Valeurs absolues leucocytaires (ANC, ALC).
// ---------------------------------------------------------------------------

const FormulaMeta absoluteLeukocyteCountsMeta = FormulaMeta(
  id: 'absolute_leukocyte_counts',
  name: 'Valeurs absolues leucocytaires (ANC, ALC)',
  shortName: 'ANC, ALC',
  category: CalculatorCategory.hematology,
  version: 'Valeurs absolues (définition)',
  equation:
      'ANC (×10⁹/L) = Leucocytes (×10⁹/L) × [Neutrophiles segmentés (%) + Bandes (%)] / 100\n'
      'ALC (×10⁹/L) = Leucocytes (×10⁹/L) × Lymphocytes (%) / 100',
  sources: [_definition],
  applicablePopulation: 'Tout âge (les seuils cliniques, eux, dépendent de l\'âge et de l\'origine).',
  analyticalConditions: [
    'Pourcentages issus d\'une formule leucocytaire manuelle ou automatisée portant sur un nombre '
        'suffisant de cellules ; leucocytes corrigés des érythroblastes si nécessaire (module Count).',
  ],
  limitations: [
    'Aucun seuil (neutropénie, lymphopénie…) n\'est appliqué : ils dépendent de l\'âge, de '
        'l\'origine et du contexte clinique.',
    'La précision d\'un pourcentage dépend du nombre de cellules comptées.',
  ],
  displayPrecision: 2,
  helpText: 'Leucocytes en ×10⁹/L ; pourcentages de la formule leucocytaire. Bandes : 0 si non comptées.',
);

/// ANC et ALC à partir des leucocytes et de la formule leucocytaire.
CalculationResult calculateAbsoluteLeukocyteCounts({
  required double wbcGL,
  required double neutrophilsPercent,
  required double bandsPercent,
  required double lymphocytesPercent,
}) {
  Validation.raiseIfAny([
    Validation.checkPositive(wbcGL, 'wbc', 'Leucocytes'),
    Validation.checkInRange(neutrophilsPercent, 'neutrophils', 'Neutrophiles segmentés', min: 0, max: 100),
    Validation.checkInRange(bandsPercent, 'bands', 'Bandes', min: 0, max: 100),
    Validation.checkInRange(lymphocytesPercent, 'lymphocytes', 'Lymphocytes', min: 0, max: 100),
  ]);

  final warnings = <CalculationWarning>[
    const CalculationWarning(
      'Aucun seuil n\'est appliqué : neutropénie, lymphopénie ou leur gravité dépendent de l\'âge, '
      'de l\'origine et du contexte clinique.',
      severity: WarningSeverity.info,
    ),
  ];
  if (neutrophilsPercent + bandsPercent + lymphocytesPercent > 100) {
    warnings.add(const CalculationWarning(
      'La somme neutrophiles + bandes + lymphocytes dépasse 100 % : formule leucocytaire incohérente, '
      'les valeurs absolues ne sont pas fiables.',
      severity: WarningSeverity.blocking,
    ));
  }

  final anc = wbcGL * (neutrophilsPercent + bandsPercent) / 100;
  final alc = wbcGL * lymphocytesPercent / 100;

  return CalculationResult(
    formula: absoluteLeukocyteCountsMeta,
    echoedInputs: {
      'Leucocytes': '${wbcGL.toStringAsFixed(2)} ×10⁹/L',
      'Neutrophiles segmentés': '${neutrophilsPercent.toStringAsFixed(1)} %',
      'Bandes': '${bandsPercent.toStringAsFixed(1)} %',
      'Lymphocytes': '${lymphocytesPercent.toStringAsFixed(1)} %',
    },
    values: [
      ResultValue(label: 'ANC (polynucléaires neutrophiles)', value: anc, unit: '×10⁹/L', precision: 2),
      ResultValue(label: 'ANC', value: anc * 1000, unit: '/µL', precision: 0),
      ResultValue(label: 'ALC (lymphocytes)', value: alc, unit: '×10⁹/L', precision: 2),
      ResultValue(label: 'ALC', value: alc * 1000, unit: '/µL', precision: 0),
    ],
    warnings: warnings,
  );
}
