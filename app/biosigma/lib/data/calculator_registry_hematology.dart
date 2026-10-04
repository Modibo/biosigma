import 'package:biosigma_core/biosigma_core.dart';

import '../models/calculator_definition.dart';
import '../models/calculator_field.dart';

/// Calculateurs du domaine « Hématologie — NFS et réticulocytes » :
/// indices discriminants de la microcytose (Mentzer, Shine & Lal, England &
/// Fraser, Green & King, RDWI), panel réticulocytaire (nombre absolu, CRC,
/// RPI) et indices d'inflammation systémique dérivés de la NFS (SII, SIRI).
///
/// Nouveau fichier de glue, non encore raccordé au registre agrégé de
/// l'application (`calculator_registry.dart` / `catalog.dart`) —
/// raccordement fait séparément pour éviter les conflits avec les autres
/// calculateurs en cours d'ajout en parallèle.

/// Indice de Mentzer (VGM / GR, Mentzer 1973).
final CalculatorDefinition mentzerIndexDefinition = CalculatorDefinition(
  meta: mentzerIndexMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'mcv',
      label: 'VGM',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'fL',
    ),
    CalculatorFieldSpec(
      id: 'rbc',
      label: 'GR (numération des globules rouges)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '×10¹²/L',
    ),
  ],
  compute: (values) => calculateMentzerIndex(
    mcvFl: (values['mcv'] as NumericEntry).value!,
    rbcTeraL: (values['rbc'] as NumericEntry).value!,
  ),
);

/// Indice de Shine & Lal ((VGM² × TCMH) / 100, Shine-Lal 1977).
final CalculatorDefinition shineLalIndexDefinition = CalculatorDefinition(
  meta: shineLalIndexMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'mcv',
      label: 'VGM',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'fL',
    ),
    CalculatorFieldSpec(
      id: 'mch',
      label: 'TCMH',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'pg',
    ),
  ],
  compute: (values) => calculateShineLalIndex(
    mcvFl: (values['mcv'] as NumericEntry).value!,
    mchPg: (values['mch'] as NumericEntry).value!,
  ),
);

/// Indice (fonction discriminante) d'England & Fraser
/// (VGM − GR − 5×Hb − 3,4, England-Fraser 1973).
final CalculatorDefinition englandFraserIndexDefinition = CalculatorDefinition(
  meta: englandFraserIndexMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'mcv',
      label: 'VGM',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'fL',
    ),
    CalculatorFieldSpec(
      id: 'rbc',
      label: 'GR (numération des globules rouges)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '×10¹²/L',
    ),
    CalculatorFieldSpec(
      id: 'hb',
      label: 'Hémoglobine',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'g/dL',
    ),
  ],
  compute: (values) => calculateEnglandFraserIndex(
    mcvFl: (values['mcv'] as NumericEntry).value!,
    rbcTeraL: (values['rbc'] as NumericEntry).value!,
    hbGDl: (values['hb'] as NumericEntry).value!,
  ),
);

/// Indice de Green & King ((VGM² × IDR) / (Hb × 100), Green-King 1989).
final CalculatorDefinition greenKingIndexDefinition = CalculatorDefinition(
  meta: greenKingIndexMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'mcv',
      label: 'VGM',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'fL',
    ),
    CalculatorFieldSpec(
      id: 'rdw',
      label: 'IDR (RDW)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '%',
    ),
    CalculatorFieldSpec(
      id: 'hb',
      label: 'Hémoglobine',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'g/dL',
    ),
  ],
  compute: (values) => calculateGreenKingIndex(
    mcvFl: (values['mcv'] as NumericEntry).value!,
    rdwPercent: (values['rdw'] as NumericEntry).value!,
    hbGDl: (values['hb'] as NumericEntry).value!,
  ),
);

/// RDWI (VGM × IDR / GR, Jayabose et al. 1999).
final CalculatorDefinition rdwIndexDefinition = CalculatorDefinition(
  meta: rdwIndexMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'mcv',
      label: 'VGM',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'fL',
    ),
    CalculatorFieldSpec(
      id: 'rdw',
      label: 'IDR (RDW)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '%',
    ),
    CalculatorFieldSpec(
      id: 'rbc',
      label: 'GR (numération des globules rouges)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '×10¹²/L',
    ),
  ],
  compute: (values) => calculateRdwIndex(
    mcvFl: (values['mcv'] as NumericEntry).value!,
    rdwPercent: (values['rdw'] as NumericEntry).value!,
    rbcTeraL: (values['rbc'] as NumericEntry).value!,
  ),
);

/// Panel réticulocytaire : nombre absolu, réticulocytes corrigés (CRC) et
/// indice de production réticulocytaire (RPI) (convention standard +
/// Hillman 1969).
final CalculatorDefinition reticulocyteIndicesPanelDefinition = CalculatorDefinition(
  meta: reticulocyteIndicesPanelMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'reticulocytes',
      label: 'Réticulocytes',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '%',
    ),
    CalculatorFieldSpec(
      id: 'rbc',
      label: 'GR (numération des globules rouges)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '×10¹²/L',
    ),
    CalculatorFieldSpec(
      id: 'hematocrit',
      label: 'Hématocrite',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '%',
    ),
  ],
  compute: (values) => calculateReticulocyteIndicesPanel(
    reticulocytePercent: (values['reticulocytes'] as NumericEntry).value!,
    rbcTeraL: (values['rbc'] as NumericEntry).value!,
    hematocritPercent: (values['hematocrit'] as NumericEntry).value!,
  ),
);

/// SII — Systemic Immune-Inflammation Index ((Plaquettes × Neutrophiles) /
/// Lymphocytes, Hu et al. 2014).
final CalculatorDefinition siiIndexDefinition = CalculatorDefinition(
  meta: siiIndexMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'platelets',
      label: 'Plaquettes',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '×10⁹/L',
    ),
    CalculatorFieldSpec(
      id: 'neutrophils',
      label: 'Neutrophiles (numération absolue)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '×10⁹/L',
    ),
    CalculatorFieldSpec(
      id: 'lymphocytes',
      label: 'Lymphocytes (numération absolue)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '×10⁹/L',
    ),
  ],
  compute: (values) => calculateSiiIndex(
    plateletsGL: (values['platelets'] as NumericEntry).value!,
    neutrophilsGL: (values['neutrophils'] as NumericEntry).value!,
    lymphocytesGL: (values['lymphocytes'] as NumericEntry).value!,
  ),
);

/// SIRI — Systemic Inflammation Response Index ((Neutrophiles × Monocytes)
/// / Lymphocytes, Qi et al. 2016).
final CalculatorDefinition siriIndexDefinition = CalculatorDefinition(
  meta: siriIndexMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'neutrophils',
      label: 'Neutrophiles (numération absolue)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '×10⁹/L',
    ),
    CalculatorFieldSpec(
      id: 'monocytes',
      label: 'Monocytes (numération absolue)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '×10⁹/L',
    ),
    CalculatorFieldSpec(
      id: 'lymphocytes',
      label: 'Lymphocytes (numération absolue)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '×10⁹/L',
    ),
  ],
  compute: (values) => calculateSiriIndex(
    neutrophilsGL: (values['neutrophils'] as NumericEntry).value!,
    monocytesGL: (values['monocytes'] as NumericEntry).value!,
    lymphocytesGL: (values['lymphocytes'] as NumericEntry).value!,
  ),
);

/// Constantes érythrocytaires : VGM, TCMH, CCMH.
final CalculatorDefinition redCellIndicesDefinition = CalculatorDefinition(
  meta: redCellIndicesMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'hemoglobin',
      label: 'Hémoglobine',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: 'g/dL',
    ),
    CalculatorFieldSpec(
      id: 'hematocrit',
      label: 'Hématocrite',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '%',
    ),
    CalculatorFieldSpec(
      id: 'rbc',
      label: 'GR (numération des globules rouges)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '×10¹²/L',
    ),
  ],
  compute: (values) => calculateRedCellIndices(
    hemoglobinGdL: (values['hemoglobin'] as NumericEntry).value!,
    hematocritPercent: (values['hematocrit'] as NumericEntry).value!,
    rbcTeraL: (values['rbc'] as NumericEntry).value!,
  ),
);

/// Valeurs absolues leucocytaires : ANC et ALC.
final CalculatorDefinition absoluteLeukocyteCountsDefinition = CalculatorDefinition(
  meta: absoluteLeukocyteCountsMeta,
  fields: const [
    CalculatorFieldSpec(
      id: 'wbc',
      label: 'Leucocytes',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '×10⁹/L',
    ),
    CalculatorFieldSpec(
      id: 'neutrophils',
      label: 'Neutrophiles segmentés',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '%',
    ),
    CalculatorFieldSpec(
      id: 'bands',
      label: 'Bandes (0 si non comptées)',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '%',
    ),
    CalculatorFieldSpec(
      id: 'lymphocytes',
      label: 'Lymphocytes',
      kind: FieldKind.numberFixedUnit,
      fixedUnitLabel: '%',
    ),
  ],
  compute: (values) => calculateAbsoluteLeukocyteCounts(
    wbcGL: (values['wbc'] as NumericEntry).value!,
    neutrophilsPercent: (values['neutrophils'] as NumericEntry).value!,
    bandsPercent: (values['bands'] as NumericEntry).value!,
    lymphocytesPercent: (values['lymphocytes'] as NumericEntry).value!,
  ),
);

/// Tous les calculateurs du domaine hématologie, prêts à être ajoutés au
/// registre agrégé de l'application.
final List<CalculatorDefinition> hematologyCalculators = [
  mentzerIndexDefinition,
  shineLalIndexDefinition,
  englandFraserIndexDefinition,
  greenKingIndexDefinition,
  rdwIndexDefinition,
  reticulocyteIndicesPanelDefinition,
  siiIndexDefinition,
  siriIndexDefinition,
  redCellIndicesDefinition,
  absoluteLeukocyteCountsDefinition,
];
