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
    'La surface comptée et la profondeur sont celles de VOTRE chambre (fiche du fabricant) : '
        'BioSigma n\'embarque aucune géométrie de chambre.',
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
