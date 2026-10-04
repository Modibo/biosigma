import '../models/errors.dart';
import '../models/formula_meta.dart';
import '../models/reference.dart';
import '../models/result.dart';
import '../validation.dart';
import 'lab_units.dart';

const Reference _conservation = Reference(
  citation:
      'Conservation de la quantité de soluté lors d\'une dilution (C1·V1 = C2·V2) : '
      'relation élémentaire, aucune norme citée — à relire par le laboratoire.',
);

const String _notationWarning =
    'Notation : le facteur de dilution F = volume final / volume de départ. « 1/F » '
    'désigne 1 volume de solution dans F volumes au total ; le rapport « 1:n » est '
    'ambigu (n parties au total ou n parties de diluant) et n\'est pas utilisé ici.';

/// Dilution simple : C1·V1 = C2·V2.
const FormulaMeta dilutionMeta = FormulaMeta(
  id: 'lab_dilution_c1v1',
  name: 'Dilution simple (C1·V1 = C2·V2)',
  shortName: 'Dilute',
  category: CalculatorCategory.laboratory,
  version: 'Dilute 1 — conservation de la quantité de soluté',
  equation: 'C1 × V1 = C2 × V2 ;  F = C1 / C2 = V2 / V1 ;  V diluant = V2 − V1',
  sources: [_conservation],
  applicablePopulation: 'Sans objet (calcul de préparation, indépendant du patient).',
  analyticalConditions: [
    'Le soluté ne doit ni réagir ni se perdre (adsorption, évaporation) pendant la dilution.',
    'Les volumes sont supposés additifs (V2 = V1 + V diluant).',
  ],
  limitations: [
    'Calcul théorique : ne tient compte ni de l\'exactitude des pipettes, ni du volume mort, '
        'ni de la possibilité réelle de prélever le volume calculé (contrôle de pipetabilité '
        'non encore disponible).',
  ],
  displayPrecision: 4,
  helpText: 'Renseignez trois des quatre grandeurs : la quatrième est calculée.',
);

/// Série de dilutions (facteur constant de tube en tube).
const FormulaMeta serialDilutionMeta = FormulaMeta(
  id: 'lab_dilution_series',
  name: 'Dilutions en série',
  shortName: 'Dilutions en série',
  category: CalculatorCategory.laboratory,
  version: 'Dilute 1 — série à facteur constant',
  equation:
      'Tube k : dilution cumulée = F^k ;  concentration = C0 / F^k\n'
      'Volume transféré = V final / F ;  volume de diluant = V final − V transféré',
  sources: [_conservation],
  applicablePopulation: 'Sans objet (calcul de préparation, indépendant du patient).',
  analyticalConditions: [
    'Mélange homogène à chaque étape ; changement d\'embout entre les tubes.',
  ],
  limitations: [
    'Calcul théorique : volume mort, exactitude des pipettes et erreurs cumulées par étape '
        'ne sont pas modélisés.',
    'Le tableau suppose que chaque tube reçoit le volume transféré du tube précédent '
        'et que le volume final de chaque tube est identique.',
  ],
  displayPrecision: 4,
);

/// Résultat original d'un échantillon dilué.
const FormulaMeta outOfRangeDilutionMeta = FormulaMeta(
  id: 'lab_dilution_out_of_range',
  name: 'Résultat après dilution (hors linéarité)',
  shortName: 'Hors linéarité',
  category: CalculatorCategory.laboratory,
  version: 'Dilute 1 — résultat original = résultat dilué × facteur total',
  equation: 'Résultat original = résultat dilué × F total ;  F total = produit des facteurs de chaque étape',
  sources: [_conservation],
  applicablePopulation: 'Sans objet (calcul analytique, indépendant du patient).',
  analyticalConditions: [
    'L\'intervalle de linéarité est celui de la méthode et de l\'automate du laboratoire : '
        'il est saisi par l\'utilisateur, BioSigma n\'en fournit aucun.',
    'La dilution doit être réalisée avec le diluant prévu par le fabricant du réactif.',
  ],
  limitations: [
    'Le résultat n\'est présenté comme exploitable que si le résultat dilué est dans '
        'l\'intervalle de linéarité saisi. Une matrice diluée peut se comporter autrement '
        '(effet de matrice) : la conformité à la procédure du laboratoire reste à vérifier.',
  ],
  displayPrecision: 4,
);

double _positive(double? v, String id, String label, List<FieldError?> errors) {
  errors.add(Validation.checkPositive(v, id, label));
  return v ?? double.nan;
}

/// Résout C1·V1 = C2·V2 : exactement une des quatre grandeurs doit être
/// absente (`null`) ; elle est calculée dans l'unité demandée.
///
/// C1/C2 doivent être de même grandeur (concentrations convertibles), V1/V2
/// aussi. Une « dilution » qui augmenterait la concentration est refusée.
CalculationResult calculateDilution({
  double? c1,
  String c1Unit = 'mol/L',
  double? v1,
  String v1Unit = 'mL',
  double? c2,
  String c2Unit = 'mol/L',
  double? v2,
  String v2Unit = 'mL',
}) {
  final missing = [
    if (c1 == null) 'c1',
    if (v1 == null) 'v1',
    if (c2 == null) 'c2',
    if (v2 == null) 'v2',
  ];
  if (missing.length != 1) {
    throw CalculationInputException([
      FieldError(
        fieldId: missing.isEmpty ? 'c1' : missing.first,
        message: missing.isEmpty
            ? 'Laissez vide la grandeur à calculer : les quatre sont déjà renseignées.'
            : 'Renseignez trois grandeurs sur quatre ; ${missing.length} sont vides.',
      ),
    ]);
  }

  final u = {
    'c1': LabUnits.require(c1Unit, 'c1', 'C1'),
    'c2': LabUnits.require(c2Unit, 'c2', 'C2'),
    'v1': LabUnits.require(v1Unit, 'v1', 'V1'),
    'v2': LabUnits.require(v2Unit, 'v2', 'V2'),
  };
  final unitErrors = <FieldError?>[
    for (final id in ['c1', 'c2'])
      u[id]!.isConcentration
          ? null
          : FieldError(fieldId: id, message: 'Une concentration est attendue (ex. mg/dL, mmol/L).'),
    for (final id in ['v1', 'v2'])
      u[id]!.dimension == LabDimension.volume
          ? null
          : FieldError(fieldId: id, message: 'Un volume est attendu (ex. mL, µL).'),
    if (u['c1']!.isConcentration &&
        u['c2']!.isConcentration &&
        u['c1']!.dimension != u['c2']!.dimension)
      const FieldError(
          fieldId: 'c2',
          message: 'C1 et C2 doivent être de même nature (massique, molaire ou en équivalents) : '
              'utilisez Convert pour changer de nature.'),
  ];
  Validation.raiseIfAny(unitErrors);

  final errors = <FieldError?>[];
  final b1 = c1 == null ? double.nan : _positive(c1, 'c1', 'C1', errors) * u['c1']!.factorToBase;
  final bv1 = v1 == null ? double.nan : _positive(v1, 'v1', 'V1', errors) * u['v1']!.factorToBase;
  final b2 = c2 == null ? double.nan : _positive(c2, 'c2', 'C2', errors) * u['c2']!.factorToBase;
  final bv2 = v2 == null ? double.nan : _positive(v2, 'v2', 'V2', errors) * u['v2']!.factorToBase;
  Validation.raiseIfAny(errors);

  var cc1 = b1, vv1 = bv1, cc2 = b2, vv2 = bv2;
  switch (missing.single) {
    case 'c2':
      cc2 = cc1 * vv1 / vv2;
    case 'v2':
      vv2 = cc1 * vv1 / cc2;
    case 'c1':
      cc1 = cc2 * vv2 / vv1;
    case 'v1':
      vv1 = cc2 * vv2 / cc1;
  }

  if (cc2 > cc1 * (1 + 1e-12) || vv2 < vv1 * (1 - 1e-12)) {
    throw CalculationInputException([
      FieldError(
        fieldId: missing.single,
        message: 'Ces valeurs ne décrivent pas une dilution : la concentration finale '
            'serait supérieure à la concentration de départ (ou le volume final inférieur '
            'au volume prélevé). Vérifiez les valeurs et les unités.',
      ),
    ]);
  }

  final factor = cc1 / cc2;
  final diluentBase = vv2 - vv1;
  String show(String id) => switch (id) {
        'c1' => '${c1 ?? '(calculée)'} ${u['c1']}',
        'v1' => '${v1 ?? '(calculé)'} ${u['v1']}',
        'c2' => '${c2 ?? '(calculée)'} ${u['c2']}',
        _ => '${v2 ?? '(calculé)'} ${u['v2']}',
      };

  final computedId = missing.single;
  final unknownValue = switch (computedId) {
    'c1' => cc1 / u['c1']!.factorToBase,
    'c2' => cc2 / u['c2']!.factorToBase,
    'v1' => vv1 / u['v1']!.factorToBase,
    _ => vv2 / u['v2']!.factorToBase,
  };
  final unknownLabel = switch (computedId) {
    'c1' => 'C1 (concentration de départ)',
    'c2' => 'C2 (concentration finale)',
    'v1' => 'V1 (volume à prélever)',
    _ => 'V2 (volume final)',
  };
  final unknownUnit = u[computedId]!.symbol;

  return CalculationResult(
    formula: dilutionMeta,
    echoedInputs: {
      'C1': show('c1'),
      'V1': show('v1'),
      'C2': show('c2'),
      'V2': show('v2'),
    },
    values: [
      ResultValue(
        label: unknownLabel,
        value: unknownValue,
        unit: unknownUnit,
        precision: LabUnits.decimalsForSignificant(unknownValue),
      ),
      ResultValue(label: 'Facteur de dilution F (= C1/C2 = V2/V1)', value: factor, unit: '', precision: 4),
      ResultValue(
        label: 'Volume de diluant à ajouter (V2 − V1)',
        value: diluentBase / u['v2']!.factorToBase,
        unit: u['v2']!.symbol,
        precision: LabUnits.decimalsForSignificant(diluentBase / u['v2']!.factorToBase),
      ),
    ],
    warnings: const [
      CalculationWarning(_notationWarning, severity: WarningSeverity.info),
      CalculationWarning(
        'Calcul théorique : vérifiez que le volume à prélever est réalisable avec votre '
        'matériel (volume minimal et exactitude de la pipette).',
        severity: WarningSeverity.info,
      ),
    ],
  );
}

/// Une ligne du tableau de dilutions en série.
class SerialDilutionRow {
  const SerialDilutionRow({
    required this.tube,
    required this.transferredVolume,
    required this.diluentVolume,
    required this.stepFactor,
    required this.cumulativeFactor,
    required this.concentration,
  });

  final int tube;

  /// Volume transféré depuis le tube précédent (ou la solution mère pour le tube 1).
  final double transferredVolume;
  final double diluentVolume;
  final double stepFactor;
  final double cumulativeFactor;
  final double concentration;
}

class SerialDilutionResult {
  const SerialDilutionResult({required this.result, required this.rows});
  final CalculationResult result;
  final List<SerialDilutionRow> rows;
}

/// Dilutions en série à facteur constant [factor] (> 1), [tubes] tubes
/// (1 à 20), volume final identique [finalVolume] dans chaque tube.
SerialDilutionResult calculateSerialDilution({
  required double? stockConcentration,
  required String concentrationUnit,
  required double? factor,
  required int? tubes,
  required double? finalVolume,
  required String volumeUnit,
}) {
  final concUnit = LabUnits.require(concentrationUnit, 'stockConcentration', 'la concentration');
  final volUnit = LabUnits.require(volumeUnit, 'finalVolume', 'le volume');
  Validation.raiseIfAny([
    concUnit.isConcentration
        ? null
        : const FieldError(fieldId: 'stockConcentration', message: 'Une concentration est attendue.'),
    volUnit.dimension == LabDimension.volume
        ? null
        : const FieldError(fieldId: 'finalVolume', message: 'Un volume est attendu.'),
  ]);
  Validation.raiseIfAny([
    Validation.checkPositive(stockConcentration, 'stockConcentration', 'La concentration de départ'),
    Validation.checkPositive(factor, 'factor', 'Le facteur de dilution'),
    if (factor != null && factor <= 1)
      const FieldError(fieldId: 'factor', message: 'Le facteur de dilution doit être supérieur à 1.'),
    tubes == null || tubes < 1 || tubes > 20
        ? const FieldError(fieldId: 'tubes', message: 'Le nombre de tubes doit être compris entre 1 et 20.')
        : null,
    Validation.checkPositive(finalVolume, 'finalVolume', 'Le volume final par tube'),
  ]);

  final transferred = finalVolume! / factor!;
  final diluent = finalVolume - transferred;
  final rows = <SerialDilutionRow>[
    for (var k = 1; k <= tubes!; k++)
      SerialDilutionRow(
        tube: k,
        transferredVolume: transferred,
        diluentVolume: diluent,
        stepFactor: factor,
        cumulativeFactor: _pow(factor, k),
        concentration: stockConcentration! / _pow(factor, k),
      ),
  ];

  final last = rows.last;
  return SerialDilutionResult(
    rows: rows,
    result: CalculationResult(
      formula: serialDilutionMeta,
      echoedInputs: {
        'Concentration de départ': '$stockConcentration ${concUnit.symbol}',
        'Facteur par étape': '$factor',
        'Nombre de tubes': '$tubes',
        'Volume final par tube': '$finalVolume ${volUnit.symbol}',
      },
      values: [
        ResultValue(
          label: 'Volume transféré à chaque étape',
          value: transferred,
          unit: volUnit.symbol,
          precision: LabUnits.decimalsForSignificant(transferred),
        ),
        ResultValue(
          label: 'Volume de diluant par tube',
          value: diluent,
          unit: volUnit.symbol,
          precision: LabUnits.decimalsForSignificant(diluent),
        ),
        ResultValue(
          label: 'Dilution cumulée au tube $tubes',
          value: last.cumulativeFactor,
          unit: '',
          precision: 4,
        ),
        ResultValue(
          label: 'Concentration au tube $tubes',
          value: last.concentration,
          unit: concUnit.symbol,
          precision: LabUnits.decimalsForSignificant(last.concentration),
        ),
      ],
      warnings: const [
        CalculationWarning(_notationWarning, severity: WarningSeverity.info),
        CalculationWarning(
          'Calcul théorique : vérifiez que le volume transféré est réalisable avec votre matériel.',
          severity: WarningSeverity.info,
        ),
      ],
    ),
  );
}

double _pow(double base, int exponent) {
  var out = 1.0;
  for (var i = 0; i < exponent; i++) {
    out *= base;
  }
  return out;
}

/// Produit des facteurs de dilution de chaque étape (chaque facteur ≥ 1).
double cumulativeDilutionFactor(List<double> stepFactors) {
  if (stepFactors.isEmpty) {
    throw CalculationInputException(const [
      FieldError(fieldId: 'factors', message: 'Saisissez au moins un facteur de dilution.'),
    ]);
  }
  var total = 1.0;
  for (final f in stepFactors) {
    if (!f.isFinite || f < 1) {
      throw CalculationInputException(const [
        FieldError(
            fieldId: 'factors',
            message: 'Chaque facteur de dilution doit être supérieur ou égal à 1.'),
      ]);
    }
    total *= f;
  }
  return total;
}

/// Résultat original d'un échantillon dilué : résultat dilué × facteur
/// total, uniquement si le résultat dilué est dans l'intervalle de linéarité
/// saisi ([linearityMin], [linearityMax]) ; sinon le calcul est présenté
/// comme non exploitable (avertissement bloquant).
CalculationResult calculateOutOfRangeDilution({
  required double? dilutedResult,
  required String resultUnit,
  required double? totalFactor,
  required double? linearityMin,
  required double? linearityMax,
}) {
  Validation.raiseIfAny([
    Validation.checkNonNegative(dilutedResult, 'dilutedResult', 'Le résultat dilué'),
    Validation.checkProvided(totalFactor, 'totalFactor', 'Le facteur de dilution total'),
    if (totalFactor != null && totalFactor < 1)
      const FieldError(fieldId: 'totalFactor', message: 'Le facteur de dilution total doit être supérieur ou égal à 1.'),
    Validation.checkNonNegative(linearityMin, 'linearityMin', 'La limite basse de linéarité'),
    Validation.checkPositive(linearityMax, 'linearityMax', 'La limite haute de linéarité'),
    if (linearityMin != null && linearityMax != null && linearityMin >= linearityMax)
      const FieldError(fieldId: 'linearityMax', message: 'La limite haute doit dépasser la limite basse.'),
  ]);

  final original = dilutedResult! * totalFactor!;
  final inRange = dilutedResult >= linearityMin! && dilutedResult <= linearityMax!;
  return CalculationResult(
    formula: outOfRangeDilutionMeta,
    isComplete: inRange,
    echoedInputs: {
      'Résultat dilué': '$dilutedResult $resultUnit',
      'Facteur de dilution total': '$totalFactor',
      'Intervalle de linéarité saisi': '$linearityMin à $linearityMax $resultUnit',
    },
    values: [
      ResultValue(
        label: 'Résultat original (dilué × facteur)',
        value: inRange ? original : null,
        unit: resultUnit,
        precision: LabUnits.decimalsForSignificant(original),
      ),
    ],
    warnings: [
      if (!inRange)
        CalculationWarning(
          'Le résultat dilué ($dilutedResult $resultUnit) est hors de l\'intervalle de '
          'linéarité saisi ($linearityMin à $linearityMax $resultUnit) : le résultat original '
          'n\'est pas présenté. Diluer davantage ou concentrer selon la procédure du laboratoire, '
          'puis refaire le dosage.',
          severity: WarningSeverity.blocking,
        )
      else
        const CalculationWarning(
          'Résultat valable seulement si la dilution a été faite avec le diluant et selon la '
          'procédure du laboratoire.',
          severity: WarningSeverity.info,
        ),
      const CalculationWarning(_notationWarning, severity: WarningSeverity.info),
    ],
  );
}
