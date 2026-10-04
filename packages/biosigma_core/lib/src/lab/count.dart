import 'dart:math' as math;

import '../models/errors.dart';
import '../models/formula_meta.dart';
import '../models/reference.dart';
import '../models/result.dart';
import '../validation.dart';
import 'lab_units.dart';

const Reference _toVerify = Reference(
  citation:
      'Concentration = nombre compté / volume compté × facteur de dilution ; volume compté = '
      'surface comptée × profondeur : relations de définition, aucune norme citée — à relire '
      'par le laboratoire.',
);

/// Numération en chambre : concentration cellulaire.
const FormulaMeta cellCountMeta = FormulaMeta(
  id: 'lab_count_concentration',
  name: 'Numération en chambre : concentration cellulaire',
  shortName: 'Count — concentration',
  category: CalculatorCategory.laboratory,
  version: 'Count 1 — N / (surface × profondeur) × dilution',
  equation:
      'Volume compté (µL) = surface comptée (mm²) × profondeur de la chambre (mm)\n'
      'Concentration (cellules/µL) = N × facteur de dilution / volume compté',
  sources: [_toVerify],
  applicablePopulation: 'Sans objet (comptage analytique, indépendant du patient).',
  analyticalConditions: [
    'La surface comptée et la profondeur sont celles de VOTRE chambre (fiche du fabricant). BioSigma propose '
        'les chambres Neubauer améliorée (OMS) et Malassez (documents cités, à confronter à votre fiche) ; '
        'toute autre chambre se saisit en mode « Personnalisée ».',
    'Respecter les règles de bordure (cellules à cheval) de la méthode du laboratoire.',
  ],
  limitations: [
    'Aucune comparaison à des valeurs de référence n\'est faite.',
  ],
  displayPrecision: 4,
);

/// Nombre total de cellules (concentration × volume), distinct de la concentration.
const FormulaMeta totalCountMeta = FormulaMeta(
  id: 'lab_count_total',
  name: 'Nombre total de cellules (concentration × volume)',
  shortName: 'Count — nombre total',
  category: CalculatorCategory.laboratory,
  version: 'Count 1 — N total = concentration × volume',
  equation: 'Nombre total (×10⁶) = concentration (×10⁶/mL) × volume (mL)',
  sources: [_toVerify],
  applicablePopulation: 'Sans objet (comptage analytique).',
  limitations: [
    'La concentration et le nombre total sont deux grandeurs différentes : ne pas les confondre.',
    'Aucun seuil ni valeur de référence (ex. méthode OMS) n\'est embarqué : à confronter à la '
        'méthode et aux références du laboratoire.',
  ],
  displayPrecision: 4,
);

/// Formule de comptage différentiel.
const FormulaMeta differentialMeta = FormulaMeta(
  id: 'lab_count_differential',
  name: 'Formule de comptage différentiel',
  shortName: 'Count — formule',
  category: CalculatorCategory.laboratory,
  version: 'Count 1 — pourcentage = n / total × 100 ; absolu = % × leucocytes / 100',
  equation:
      'Pourcentage = n / N total × 100\n'
      'Valeur absolue = pourcentage × leucocytes (G/L) / 100\n'
      'Leucocytes corrigés = leucocytes × 100 / (100 + érythroblastes pour 100 leucocytes)',
  sources: [_toVerify],
  applicablePopulation: 'Sans objet (comptage analytique).',
  limitations: [
    'Aucune valeur de référence n\'est comparée.',
    'La précision d\'un pourcentage dépend du nombre de cellules comptées.',
  ],
  displayPrecision: 2,
);

/// Concentration cellulaire d'une numération en chambre.
CalculationResult calculateCellCount({
  required int? counted,
  required double? countedAreaMm2,
  required double? depthMm,
  required double? dilutionFactor,
}) {
  Validation.raiseIfAny([
    counted == null || counted < 0
        ? const FieldError(fieldId: 'counted', message: 'Le nombre de cellules comptées doit être un entier ≥ 0.')
        : null,
    Validation.checkPositive(countedAreaMm2, 'countedArea', 'La surface comptée'),
    Validation.checkPositive(depthMm, 'depth', 'La profondeur de la chambre'),
    Validation.checkProvided(dilutionFactor, 'dilution', 'Le facteur de dilution'),
    if (dilutionFactor != null && dilutionFactor < 1)
      const FieldError(fieldId: 'dilution', message: 'Le facteur de dilution doit être ≥ 1 (1 = sans dilution).'),
  ]);

  final volumeUl = countedAreaMm2! * depthMm!; // 1 mm³ = 1 µL
  final perUl = counted! * dilutionFactor! / volumeUl;
  final cv = counted > 0 ? 100 / math.sqrt(counted) : null;

  return CalculationResult(
    formula: cellCountMeta,
    echoedInputs: {
      'Cellules comptées': '$counted',
      'Surface comptée': '$countedAreaMm2 mm²',
      'Profondeur': '$depthMm mm',
      'Volume compté': '$volumeUl µL',
      'Facteur de dilution': '$dilutionFactor',
    },
    values: [
      ResultValue(label: 'Concentration', value: perUl, unit: 'cellules/µL',
          precision: LabUnits.decimalsForSignificant(perUl)),
      ResultValue(label: 'Concentration', value: perUl / 1000, unit: '×10⁹/L  (= ×10⁶/mL)',
          precision: LabUnits.decimalsForSignificant(perUl / 1000)),
      ResultValue(label: 'Concentration', value: perUl / 1e6, unit: '×10¹²/L',
          precision: LabUnits.decimalsForSignificant(perUl / 1e6)),
    ],
    warnings: [
      if (cv != null)
        CalculationWarning(
          'Imprécision statistique théorique du seul comptage (loi de Poisson) : environ '
          '${cv.toStringAsFixed(1)} % pour $counted cellules comptées. Elle ne comprend ni '
          'l\'erreur de pipetage ni l\'erreur de remplissage de la chambre.',
          severity: WarningSeverity.info,
        )
      else
        const CalculationWarning(
          'Aucune cellule comptée : la concentration est inférieure à la limite de détection '
          'de ce comptage, et non « nulle ».',
          severity: WarningSeverity.caution,
        ),
    ],
  );
}

/// Unité de comptage d'une chambre (un rectangle, une grille, un grand carré…).
class ChamberUnit {
  const ChamberUnit(this.label, this.areaMm2, this.maxPerChamber);
  final String label;

  /// Surface d'une unité (mm²).
  final double areaMm2;

  /// Nombre maximal d'unités de ce type dans une chambre (ou une grille de comptage).
  final int maxPerChamber;
}

/// Géométrie d'une chambre de numération : profondeur et unités de comptage.
class CountingChamber {
  const CountingChamber({
    required this.id,
    required this.name,
    required this.depthMm,
    required this.units,
    required this.source,
    this.usage = '',
  });
  final String id;
  final String name;

  /// Profondeur de la chambre (mm), lamelle en place.
  final double depthMm;
  final List<ChamberUnit> units;

  /// Origine des valeurs (à confronter à la fiche de la chambre du laboratoire).
  final String source;

  /// Usage courant cité par les fabricants (facultatif).
  final String usage;
}

const String _marienfeld =
    'Paul Marienfeld, « Counting grids » (fiche technique des grilles, consultée le 2026-10-04)';

/// Chambres proposées. **Les valeurs sont celles de documents cités**, à confronter à la fiche de
/// VOTRE chambre : une chambre non listée se saisit en mode « Personnalisée ». Non proposées, faute de fiche
/// vérifiée en texte brut et parce qu'elles ne servent pas au dénombrement cellulaire médical : McMaster
/// (œufs de parasites), Sedgewick-Rafter (plancton), Howard (moisissures).
const List<CountingChamber> countingChambers = [
  CountingChamber(
    id: 'neubauer_improved',
    name: 'Neubauer améliorée',
    depthMm: 0.1,
    usage: 'sang, liquides biologiques ; sperme (OMS)',
    units: [
      ChamberUnit('grille de 1 mm × 1 mm (100 nL)', 1.0, 9),
      ChamberUnit('grand carré de la grille centrale (1/25 de grille)', 1.0 / 25, 25),
      ChamberUnit('petit carré (0,05 mm × 0,05 mm)', 0.0025, 400),
    ],
    source: 'Manuel de l\'OMS pour l\'examen du sperme, 6e éd. (§ 2.4.8.2, figure 2.5) : neuf grilles de 1 mm × 1 mm '
        'par chambre, profondeur 100 µm (0,1 mm), 100 nL par grille, 25 grands carrés dans la grille centrale. '
        '$_marienfeld : groupes de 0,2 mm × 0,2 mm (25), petits carrés de 0,05 mm × 0,05 mm (16 par groupe).',
  ),
  CountingChamber(
    id: 'neubauer',
    name: 'Neubauer',
    depthMm: 0.1,
    usage: 'sang',
    units: [
      ChamberUnit('grand carré de 1 mm × 1 mm', 1.0, 9),
      ChamberUnit('carré de groupe (0,2 mm × 0,2 mm)', 0.04, 16),
      ChamberUnit('petit carré (0,05 mm × 0,05 mm)', 0.0025, 256),
    ],
    source: '$_marienfeld : profondeur 0,1 mm ; quadrillage de 3 mm × 3 mm en 9 grands carrés de 1 mm ; grand carré '
        'central en 4 × 4 groupes de 0,2 mm × 0,2 mm, chacun en 16 petits carrés de 0,05 mm.',
  ),
  CountingChamber(
    id: 'burker',
    name: 'Bürker',
    depthMm: 0.1,
    usage: 'sang (leucocytes, plaquettes, hématies)',
    units: [
      ChamberUnit('grand carré de 1 mm × 1 mm', 1.0, 9),
      ChamberUnit('petit carré (0,2 mm × 0,2 mm)', 0.04, 144),
    ],
    source: '$_marienfeld : profondeur 0,1 mm ; quadrillage de 9 mm² en 9 grands carrés de 1 mm ; 16 petits carrés de '
        '0,2 mm × 0,2 mm par grand carré.',
  ),
  CountingChamber(
    id: 'burker_turk',
    name: 'Bürker-Türk',
    depthMm: 0.1,
    usage: 'sang',
    units: [
      ChamberUnit('grand carré de 1 mm × 1 mm', 1.0, 9),
      ChamberUnit('petit carré (0,2 mm × 0,2 mm)', 0.04, 144),
      ChamberUnit('plus petit carré (0,05 mm × 0,05 mm, grand carré central)', 0.0025, 256),
    ],
    source: '$_marienfeld : profondeur 0,1 mm ; 9 grands carrés de 1 mm ; 16 petits carrés de 0,2 mm × 0,2 mm par grand '
        'carré ; dans le grand carré central, chacun des 16 petits carrés est subdivisé en 16 carrés de 0,05 mm.',
  ),
  CountingChamber(
    id: 'thoma',
    name: 'Thoma',
    depthMm: 0.1,
    usage: 'sang',
    units: [
      ChamberUnit('grille de 1 mm × 1 mm', 1.0, 1),
      ChamberUnit('carré de groupe (0,2 mm × 0,2 mm)', 0.04, 25),
      ChamberUnit('petit carré (0,05 mm × 0,05 mm)', 0.0025, 400),
    ],
    source: '$_marienfeld : profondeur 0,1 mm ; quadrillage de 1 mm × 1 mm en carrés de groupe de 0,2 mm (comme le '
        'système de Neubauer), chacun en 16 petits carrés de 0,05 mm × 0,05 mm = 0,0025 mm² (soit 400 petits carrés).',
  ),
  CountingChamber(
    id: 'thoma_new',
    name: 'Thoma nouvelle',
    depthMm: 0.1,
    usage: 'sang',
    units: [
      ChamberUnit('carré de groupe (0,2 mm × 0,2 mm)', 0.04, 16),
    ],
    source: '$_marienfeld : profondeur 0,1 mm ; quadrillage de 1,1 mm × 1,1 mm ; 16 carrés de groupe de 0,2 mm de côté '
        'séparés de 0,1 mm, chacun subdivisé en 16 petits carrés (dimension des petits carrés non indiquée : non proposée).',
  ),
  CountingChamber(
    id: 'fuchs_rosenthal',
    name: 'Fuchs-Rosenthal',
    depthMm: 0.2,
    usage: 'liquide cérébro-spinal, liquides pauvres en cellules',
    units: [
      ChamberUnit('grand carré de 1 mm × 1 mm (0,2 µL)', 1.0, 16),
      ChamberUnit('petit carré (0,25 mm × 0,25 mm)', 0.0625, 256),
    ],
    source: '$_marienfeld : profondeur 0,2 mm ; quadrillage de 16 mm² en 16 grands carrés de 1 mm, chacun en 16 petits '
        'carrés de 0,25 mm ; volume total 3,2 µL ; utilisée pour le liquide cérébro-spinal.',
  ),
  CountingChamber(
    id: 'nageotte',
    name: 'Nageotte',
    depthMm: 0.5,
    usage: 'liquide cérébro-spinal, faibles concentrations de leucocytes',
    units: [
      ChamberUnit('bande de 0,25 mm × 10 mm (1,25 µL)', 2.5, 40),
    ],
    source: '$_marienfeld : profondeur 0,5 mm ; surface de 100 mm² divisée en 40 bandes de 0,25 mm × 10 mm = 2,5 mm² '
        '(soit 1,25 µL par bande, 50 µL par quadrillage ; la chambre double compte deux quadrillages).',
  ),
  CountingChamber(
    id: 'malassez',
    name: 'Malassez',
    depthMm: 0.2,
    usage: 'sang, liquide cérébro-spinal',
    units: [
      ChamberUnit('rectangle (0,20 mm × 0,25 mm)', 0.05, 100),
      ChamberUnit('quadrillage entier (100 rectangles, 5 mm², 1 µL)', 5.0, 1),
      ChamberUnit('petit carré (0,05 mm × 0,05 mm, 20 par rectangle)', 0.0025, 2000),
    ],
    source: '$_marienfeld : profondeur 0,2 mm ; quadrillage de 2 mm × 2,5 mm ; grands rectangles de 0,25 × 0,20 = '
        '0,05 mm², chacun en 20 petits carrés de 0,05 mm. Recoupé par Wikipédia « Cellule de Malassez », Bioltrop '
        '(quadrillage total 1 µL, 100 rectangles), Laboratoires Humeau, Dutscher (consultés le 2026-10-04) et par '
        '100 × 0,05 mm² × 0,2 mm = 1 µL.',
  ),
  CountingChamber(
    id: 'makler',
    name: 'Makler (sperme)',
    depthMm: 0.01,
    usage: 'sperme, sans dilution',
    units: [
      ChamberUnit('bande de 10 carrés de 0,1 mm × 0,1 mm (0,1 mm²)', 0.1, 10),
      ChamberUnit('carré de 0,1 mm × 0,1 mm', 0.01, 100),
      ChamberUnit('quadrillage de 1 mm × 1 mm (100 carrés)', 1.0, 1),
    ],
    source: 'Graticules Optics, fiche « Makler Sperm Counting Chamber » et COLO.Science (consultés le 2026-10-04) : '
        'profondeur 10 µm ; lamelle quadrillée de carrés de 1 mm dont la zone centrale est subdivisée en carrés de '
        '0,1 mm (grille de 1 mm² en 100 carrés). Le nombre de spermatozoïdes d\'une bande de 10 carrés donne la '
        'concentration en millions/mL (vérifié par le calcul : 10 × 0,01 mm² × 0,01 mm = 0,001 µL).',
  ),
  CountingChamber(
    id: 'petroff_hausser',
    name: 'Petroff-Hausser (profondeur 0,02 mm)',
    depthMm: 0.02,
    usage: 'bactéries, sperme',
    units: [
      ChamberUnit('grille de 1 mm × 1 mm', 1.0, 9),
      ChamberUnit('carré de groupe (0,2 mm × 0,2 mm)', 0.04, 25),
      ChamberUnit('petit carré (0,05 mm × 0,05 mm)', 0.0025, 400),
    ],
    source: 'Hausser Scientific (fiche du Petroff-Hausser, via Microscope World, consultée le 2026-10-04) : profondeur '
        '0,02 mm ; ruling Neubauer amélioré couvrant 9 mm² ; le millimètre carré central est divisé en 25 groupes de '
        '16 petits carrés ; volume au-dessus d\'un mm² : 0,02 mm³.',
  ),
  CountingChamber(
    id: 'neubauer_improved_depth_001',
    name: 'Neubauer améliorée, profondeur 0,01 mm (Petroff)',
    depthMm: 0.01,
    usage: 'profondeur spéciale',
    units: [
      ChamberUnit('grille de 1 mm × 1 mm', 1.0, 9),
      ChamberUnit('carré de groupe (0,2 mm × 0,2 mm)', 0.04, 25),
      ChamberUnit('petit carré (0,05 mm × 0,05 mm)', 0.0025, 400),
    ],
    source: 'Paul Marienfeld, « Counting chambers with special depth » : Neubauer améliorée (Petroff), profondeur '
        '0,01 mm (consulté le 2026-10-04) ; grille de la Neubauer améliorée.',
  ),
  CountingChamber(
    id: 'neubauer_improved_depth_002',
    name: 'Neubauer améliorée, profondeur 0,02 mm (Petroff)',
    depthMm: 0.02,
    usage: 'profondeur spéciale',
    units: [
      ChamberUnit('grille de 1 mm × 1 mm', 1.0, 9),
      ChamberUnit('carré de groupe (0,2 mm × 0,2 mm)', 0.04, 25),
      ChamberUnit('petit carré (0,05 mm × 0,05 mm)', 0.0025, 400),
    ],
    source: 'Paul Marienfeld, « Counting chambers with special depth » : Neubauer améliorée (Petroff), profondeur '
        '0,02 mm (consulté le 2026-10-04) ; grille de la Neubauer améliorée.',
  ),
  CountingChamber(
    id: 'thoma_helber',
    name: 'Thoma (Helber), profondeur 0,02 mm',
    depthMm: 0.02,
    usage: 'profondeur spéciale',
    units: [
      ChamberUnit('grille de 1 mm × 1 mm', 1.0, 1),
      ChamberUnit('carré de groupe (0,2 mm × 0,2 mm)', 0.04, 25),
      ChamberUnit('petit carré (0,05 mm × 0,05 mm)', 0.0025, 400),
    ],
    source: 'Paul Marienfeld, « Counting chambers with special depth » : Thoma (Helber), profondeur 0,02 mm '
        '(consulté le 2026-10-04) ; grille de la chambre de Thoma.',
  ),
];

CountingChamber? countingChamberById(String id) {
  for (final c in countingChambers) {
    if (c.id == id) return c;
  }
  return null;
}

/// Concentration d'une numération dans une chambre **choisie** : la surface comptée est déduite de
/// l'unité de comptage et de leur nombre ; la profondeur est celle de la chambre.
CalculationResult calculateChamberCount({
  required CountingChamber chamber,
  required ChamberUnit unit,
  required int? unitsCounted,
  required int? counted,
  required double? dilutionFactor,
}) {
  Validation.raiseIfAny([
    unitsCounted == null || unitsCounted < 1
        ? const FieldError(fieldId: 'unitsCounted', message: 'Le nombre d\'unités comptées doit être un entier ≥ 1.')
        : null,
    if (unitsCounted != null && unitsCounted > unit.maxPerChamber)
      FieldError(
        fieldId: 'unitsCounted',
        message: 'Une chambre ${chamber.name} compte au plus ${unit.maxPerChamber} « ${unit.label} » '
            '(vous en avez saisi $unitsCounted).',
      ),
  ]);
  final base = calculateCellCount(
    counted: counted,
    countedAreaMm2: unitsCounted! * unit.areaMm2,
    depthMm: chamber.depthMm,
    dilutionFactor: dilutionFactor,
  );
  return CalculationResult(
    formula: base.formula,
    echoedInputs: {
      'Chambre': chamber.name,
      'Unité comptée': unit.label,
      'Nombre d\'unités comptées': '$unitsCounted',
      ...base.echoedInputs,
    },
    values: base.values,
    warnings: [
      ...base.warnings,
      CalculationWarning(
        'Géométrie de la chambre « ${chamber.name} » reprise de documents cités (${chamber.source}) : à '
        'confronter à la fiche de votre chambre.',
        severity: WarningSeverity.info,
      ),
    ],
    isComplete: base.isComplete,
  );
}

/// Nombre total de cellules : concentration (×10⁶/mL) × volume (mL).
CalculationResult calculateTotalCount({
  required double? concentrationE6PerMl,
  required double? volumeMl,
}) {
  Validation.raiseIfAny([
    Validation.checkNonNegative(concentrationE6PerMl, 'concentration', 'La concentration'),
    Validation.checkPositive(volumeMl, 'volume', 'Le volume'),
  ]);
  final total = concentrationE6PerMl! * volumeMl!;
  return CalculationResult(
    formula: totalCountMeta,
    echoedInputs: {
      'Concentration': '$concentrationE6PerMl ×10⁶/mL',
      'Volume': '$volumeMl mL',
    },
    values: [
      ResultValue(label: 'Nombre total', value: total, unit: '×10⁶',
          precision: LabUnits.decimalsForSignificant(total)),
    ],
    warnings: const [
      CalculationWarning(
        'Concentration et nombre total sont deux grandeurs distinctes. Aucune valeur de '
        'référence n\'est comparée.',
        severity: WarningSeverity.info,
      ),
    ],
  );
}

/// Deux comptages d'un même échantillon : moyenne et écart relatif, **sans
/// seuil d'acceptabilité** (propre à la méthode du laboratoire).
CalculationResult calculateDuplicateCounts({
  required double? concentrationA,
  required double? concentrationB,
  required String unit,
}) {
  Validation.raiseIfAny([
    Validation.checkNonNegative(concentrationA, 'concentrationA', 'Le comptage A'),
    Validation.checkNonNegative(concentrationB, 'concentrationB', 'Le comptage B'),
  ]);
  final mean = (concentrationA! + concentrationB!) / 2;
  final diff = (concentrationA - concentrationB).abs();
  return CalculationResult(
    formula: cellCountMeta,
    echoedInputs: {'Comptage A': '$concentrationA $unit', 'Comptage B': '$concentrationB $unit'},
    values: [
      ResultValue(label: 'Moyenne A/B', value: mean, unit: unit,
          precision: LabUnits.decimalsForSignificant(mean)),
      ResultValue(label: 'Écart A − B (valeur absolue)', value: diff, unit: unit,
          precision: LabUnits.decimalsForSignificant(diff)),
      ResultValue(
          label: 'Écart relatif à la moyenne',
          value: mean > 0 ? diff / mean * 100 : null,
          unit: '%',
          precision: 1),
    ],
    warnings: const [
      CalculationWarning(
        'Le seuil d\'acceptabilité de l\'écart entre deux comptages dépend de la méthode du '
        'laboratoire : BioSigma n\'en applique aucun.',
        severity: WarningSeverity.info,
      ),
    ],
  );
}

/// Formule de comptage différentiel à partir des cellules comptées par type.
///
/// [wbcGL] (leucocytes, G/L) permet les valeurs absolues ; [nrbcPer100Wbc]
/// corrige les leucocytes de la présence d'érythroblastes.
CalculationResult calculateDifferential({
  required Map<String, int> counts,
  double? wbcGL,
  double? nrbcPer100Wbc,
}) {
  final errors = <FieldError?>[
    for (final e in counts.entries)
      e.value < 0
          ? FieldError(fieldId: e.key, message: 'Le comptage « ${e.key} » ne peut pas être négatif.')
          : null,
    if (wbcGL != null) Validation.checkPositive(wbcGL, 'wbc', 'Les leucocytes'),
    if (nrbcPer100Wbc != null) Validation.checkNonNegative(nrbcPer100Wbc, 'nrbc', 'Les érythroblastes'),
  ];
  Validation.raiseIfAny(errors);
  final total = counts.values.fold<int>(0, (a, b) => a + b);
  if (total == 0) {
    throw CalculationInputException(const [
      FieldError(fieldId: 'counts', message: 'Aucune cellule comptée.'),
    ]);
  }

  final correctedWbc =
      wbcGL == null ? null : (nrbcPer100Wbc == null ? wbcGL : wbcGL * 100 / (100 + nrbcPer100Wbc));

  final values = <ResultValue>[];
  for (final e in counts.entries) {
    final pct = e.value / total * 100;
    values.add(ResultValue(label: e.key, value: pct, unit: '%', precision: 1));
    if (correctedWbc != null) {
      final abs = pct * correctedWbc / 100;
      values.add(ResultValue(
          label: '${e.key} — valeur absolue',
          value: abs,
          unit: 'G/L',
          precision: LabUnits.decimalsForSignificant(abs)));
    }
  }

  return CalculationResult(
    formula: differentialMeta,
    echoedInputs: {
      'Cellules comptées (total)': '$total',
      if (wbcGL != null) 'Leucocytes saisis': '$wbcGL G/L',
      if (correctedWbc != null && nrbcPer100Wbc != null && nrbcPer100Wbc > 0)
        'Leucocytes corrigés des érythroblastes': '${correctedWbc.toStringAsFixed(4)} G/L',
    },
    values: values,
    warnings: [
      CalculationWarning(
        'Pourcentages calculés sur $total cellules comptées : la précision d\'un pourcentage '
        'dépend de ce nombre. Aucune valeur de référence n\'est comparée.',
        severity: WarningSeverity.info,
      ),
      if (wbcGL == null)
        const CalculationWarning(
          'Leucocytes non saisis : seuls les pourcentages sont calculés (pas de valeurs absolues).',
          severity: WarningSeverity.info,
        ),
    ],
  );
}
