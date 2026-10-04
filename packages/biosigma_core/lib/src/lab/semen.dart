import '../models/errors.dart';
import '../models/formula_meta.dart';
import '../models/reference.dart';
import '../models/result.dart';
import '../rounding.dart';

/// Numération des spermatozoïdes selon le manuel de l'OMS (6e éd.), chambre de
/// Neubauer améliorée (backlog P2-06).
///
/// Source : WHO laboratory manual for the examination and processing of human
/// semen, Sixth Edition (OMS, 2021) ; texte fourni par le validateur et lu par
/// l'assistant le 2026-10-04. Tableaux 2.1, 2.3 et 2.4 (§ 2.4.4.5, 2.4.8.4 à
/// 2.4.8.7) et tableau 8.3 (§ 8.1). Les valeurs ont été recopiées par programme
/// depuis le texte du PDF, puis recoupées (voir les tests) ; elles restent à
/// relire par le validateur.
const Reference _whoReference = Reference(
  citation: 'World Health Organization. WHO laboratory manual for the examination and processing of human '
      'semen, Sixth Edition. Geneva: WHO; 2021.',
  note: 'tableaux 2.1, 2.3, 2.4 et 8.3 ; § 2.4.8',
);

const FormulaMeta semenCountMeta = FormulaMeta(
  id: 'lab_semen_count',
  name: 'Spermatozoïdes : concentration et nombre total (OMS, 6e éd.)',
  shortName: 'Count — spermatozoïdes (OMS)',
  category: CalculatorCategory.laboratory,
  version: 'OMS 6e éd. — chambre de Neubauer améliorée, deux chambres en réplicat',
  equation:
      'Somme S = comptage chambre 1 + comptage chambre 2 (même nombre de grands carrés ou de grilles)\n'
      'Concentration (×10⁶/mL) = S / F ;  F = volume compté total (nL) / facteur de dilution\n'
      'Volume compté total (nL) = 2 chambres × (carrés comptés / 25) × 100 nL\n'
      'Accord des réplicats : |A − B| ≤ limite du tableau 2.3 pour la somme S\n'
      'Nombre total (×10⁶ par éjaculat) = concentration (×10⁶/mL) × volume de l\'éjaculat (mL)',
  sources: [_whoReference],
  applicablePopulation: 'Éjaculat humain (examen de base).',
  analyticalConditions: [
    'Chambre de Neubauer améliorée, profondeur 100 µm, lamelle n° 4 (0,44 mm) ; chaque grille de 1 mm × 1 mm '
        'contient 100 nL (OMS § 2.4.8.2).',
    'Dilution dans un fixateur par volumes exacts (tableau 2.1), pipette à déplacement positif pour le sperme.',
    'Compter au moins 200 spermatozoïdes par réplicat (OMS § 2.4.8.1 et 2.4.8.4).',
  ],
  limitations: [
    'Valable pour la chambre de Neubauer améliorée : toute autre chambre exige d\'autres facteurs.',
    'Sommes > 1000 : le tableau 2.3 de l\'OMS s\'arrête à 1000, l\'accord des réplicats n\'est pas évalué.',
    'La concentration est affichée à deux chiffres significatifs (convention de l\'OMS pour la concentration '
        'moyenne ; décision du validateur) ; le calcul n\'est pas arrondi.',
    'Le 5e centile de la population de référence (tableau 8.3, Campbell et al.) n\'est pas une limite entre hommes '
        'fertiles et infertiles (OMS § 8.1.3).',
    'Une absence de spermatozoïdes dans les réplicats ne permet pas de conclure à une azoospermie : celle-ci '
        'exige l\'examen d\'un culot de centrifugation (OMS § 2.4.8.8).',
  ],
  displayPrecision: 2,
);

/// Dilution du sperme (tableau 2.1, § 2.4.4.5).
enum SpermDilution {
  d50('1 : 50 (1 + 49)', 50, 50, 2450, '> 200 spermatozoïdes par champ ×400 (> 800 par champ ×200)'),
  d20('1 : 20 (1 + 19)', 20, 50, 950, '40–200 par champ ×400 (160–800 par champ ×200)'),
  d10('1 : 10 (1 + 9)', 10, 50, 450, '16–40 par champ ×400 (64–160 par champ ×200)'),
  d5('1 : 5 (1 + 4)', 5, 50, 200, '2–15 par champ ×400 (8–64 par champ ×200)'),
  d2('1 : 2 (1 + 1)', 2, 100, 100, '< 2 par champ ×400 (< 8 par champ ×200)');

  const SpermDilution(this.label, this.factor, this.semenMicrolitres, this.fixativeMicrolitres, this.guidance);
  final String label;

  /// Facteur de dilution (volume final / volume de sperme).
  final int factor;
  final int semenMicrolitres;
  final int fixativeMicrolitres;

  /// Observation à l'examen à l'état frais qui oriente vers cette dilution.
  final String guidance;
}

/// Surface comptée dans chaque chambre : grands carrés de la grille centrale
/// (25 par grille) ou grilles entières (9 par chambre ; 100 nL chacune).
enum SpermArea {
  squares5('5 grands carrés', 5),
  squares10('10 grands carrés', 10),
  grids1('1 grille centrale (25 grands carrés)', 25),
  grids2('2 grilles', 50),
  grids3('3 grilles', 75),
  grids4('4 grilles', 100),
  grids5('5 grilles', 125),
  grids6('6 grilles', 150),
  grids7('7 grilles', 175),
  grids8('8 grilles', 200),
  grids9('9 grilles', 225);

  const SpermArea(this.label, this.squares);
  final String label;

  /// Nombre de grands carrés (une grille = 25).
  final int squares;

  /// Volume compté dans une chambre (nL) : une grille contient 100 nL.
  double get volumePerChamberNl => squares / 25 * 100;
}

/// Facteur de correction du tableau 2.4 : concentration (×10⁶/mL) = somme / facteur.
double spermCorrectionFactor(SpermDilution dilution, SpermArea area) =>
    2 * area.volumePerChamberNl / dilution.factor;

/// Une ligne du tableau 2.3.
class ReplicateLimit {
  const ReplicateLimit(this.sumFrom, this.sumTo, this.maxDifference, this.errorPercent);
  final int sumFrom;
  final int sumTo;

  /// Écart maximal accepté entre les deux comptages.
  final int maxDifference;

  /// Erreur du résultat final due au nombre d'observations (%).
  final double errorPercent;
}

/// Tableau 2.3 de l'OMS (de la plus grande somme à la plus petite). La ligne
/// « 22–26 » est imprimée « 22–36 » dans le manuel lui-même (le validateur a
/// confirmé que l'impression est bien « 22–36 », 2026-10-04) : c'est une
/// coquille de l'OMS, car les lignes voisines (17–21 et 27–31) imposent 22–26 ;
/// la limite et l'erreur imprimées sont celles de la somme 22 (loi de Poisson).
const List<(int, int, int, double)> _table23 = [
  (969, 1000, 61, 3.2),
  (938, 968, 60, 3.3),
  (907, 937, 59, 3.3),
  (876, 906, 58, 3.4),
  (846, 875, 57, 3.4),
  (817, 845, 56, 3.5),
  (788, 816, 55, 3.6),
  (760, 787, 54, 3.6),
  (732, 759, 53, 3.7),
  (704, 731, 52, 3.8),
  (678, 703, 51, 3.8),
  (651, 677, 50, 3.9),
  (625, 650, 49, 4.0),
  (600, 624, 48, 4.1),
  (576, 599, 47, 4.2),
  (551, 575, 46, 4.3),
  (528, 550, 45, 4.4),
  (504, 527, 44, 4.5),
  (482, 503, 43, 4.6),
  (460, 481, 42, 4.7),
  (438, 459, 41, 4.8),
  (417, 437, 40, 4.9),
  (396, 416, 39, 5.0),
  (376, 395, 38, 5.2),
  (357, 375, 37, 5.3),
  (338, 356, 36, 5.4),
  (319, 337, 35, 5.6),
  (301, 318, 34, 5.8),
  (284, 300, 33, 5.9),
  (267, 283, 32, 6.1),
  (251, 266, 31, 6.3),
  (235, 250, 30, 6.5),
  (219, 234, 29, 6.8),
  (206, 218, 28, 7.0),
  (190, 205, 27, 7.3),
  (176, 189, 26, 7.5),
  (163, 175, 25, 7.8),
  (150, 162, 24, 8.2),
  (138, 149, 23, 8.5),
  (126, 137, 22, 8.9),
  (115, 125, 21, 9.3),
  (105, 114, 20, 9.8),
  (94, 104, 19, 10.3),
  (85, 93, 18, 10.8),
  (76, 84, 17, 11.5),
  (67, 75, 16, 12.2),
  (59, 66, 15, 13.0),
  (52, 58, 14, 13.9),
  (44, 51, 13, 15.1),
  (38, 43, 12, 16.2),
  (32, 37, 11, 17.7),
  (27, 31, 10, 19.2),
  (22, 26, 9, 21.3),
  (17, 21, 8, 24.3),
  (13, 16, 7, 27.7),
  (10, 12, 6, 31.6),
  (7, 9, 5, 37.8),
  (5, 6, 4, 44.7),
  (3, 4, 3, 57.7),
  (2, 2, 2, 70.7),
  (1, 1, 1, 100.0),
];

final List<ReplicateLimit> replicateLimitTable = [
  for (final (lo, hi, lim, err) in _table23) ReplicateLimit(lo, hi, lim, err),
];

/// Ligne du tableau 2.3 pour une somme, ou `null` (somme nulle ou > 1000).
ReplicateLimit? replicateLimitFor(int sum) {
  for (final r in replicateLimitTable) {
    if (sum >= r.sumFrom && sum <= r.sumTo) return r;
  }
  return null;
}

/// Repères de la population de référence (tableau 8.3 : hommes dont la
/// partenaire a obtenu une grossesse en moins d'un an ; Campbell et al.).
class SemenReference {
  const SemenReference(this.parameter, this.unit, this.n, this.centiles, this.fifthCi);
  final String parameter;
  final String unit;
  final int n;

  /// 2,5e, 5e, 10e, 25e, 50e, 75e, 90e, 95e, 97,5e centiles.
  final List<double> centiles;

  /// Intervalle de confiance à 95 % du 5e centile (texte du tableau).
  final String fifthCi;

  double get p2_5 => centiles[0];
  double get p5 => centiles[1];
  double get median => centiles[4];
}

const List<SemenReference> semenReferences = [
  SemenReference('Volume de l\'éjaculat', 'mL', 3586, [1.0, 1.4, 1.8, 2.3, 3.0, 4.2, 5.5, 6.2, 6.9], '1,3–1,5'),
  SemenReference('Concentration en spermatozoïdes', '×10⁶/mL', 3587, [11, 16, 22, 36, 66, 110, 166, 208, 254], '15–18'),
  SemenReference('Nombre total de spermatozoïdes', '×10⁶ par éjaculat', 3584, [29, 39, 58, 108, 210, 363, 561, 701, 865], '35–40'),
  SemenReference('Mobilité totale (PR + NP)', '%', 3488, [35, 42, 47, 55, 64, 73, 83, 90, 92], '40–43'),
  SemenReference('Mobilité progressive (PR)', '%', 3389, [24, 30, 36, 45, 55, 63, 71, 77, 81], '29–31'),
  SemenReference('Mobilité non progressive (NP)', '%', 3387, [1, 1, 2, 4, 8, 15, 26, 32, 38], '1–1'),
  SemenReference('Spermatozoïdes immobiles (IM)', '%', 2800, [15, 20, 23, 30, 37, 45, 53, 58, 65], '19–20'),
  SemenReference('Vitalité', '%', 1337, [45, 54, 60, 69, 78, 88, 95, 97, 98], '50–56'),
  SemenReference('Formes normales', '%', 3335, [3, 4, 5, 8, 14, 23, 32, 39, 45], '3,9–4,0'),
];

SemenReference _ref(String start) => semenReferences.firstWhere((r) => r.parameter.startsWith(start));

String _fr(double v, [int d = 1]) => v.toStringAsFixed(d).replaceAll('.', ',');

/// Concentration et nombre total de spermatozoïdes à partir de réplicats.
///
/// [replicatePairs] : un à trois couples de comptages (chambre 1, chambre 2),
/// dans l'ordre où ils ont été faits. Le premier couple dont l'écart est
/// acceptable (tableau 2.3) donne la concentration ; si trois couples sont tous
/// trop éloignés, la moyenne des trois sommes est utilisée avec une mise en
/// garde ; avec moins de trois couples tous trop éloignés, le résultat n'est pas
/// donné : un nouveau comptage est demandé (OMS § 2.4.8.4).
CalculationResult calculateSpermConcentration({
  required List<(int, int)> replicatePairs,
  required SpermDilution dilution,
  required SpermArea area,
  double? ejaculateVolumeMl,
}) {
  final errors = <FieldError>[];
  if (replicatePairs.isEmpty || replicatePairs.length > 3) {
    errors.add(const FieldError(fieldId: 'pairs', message: 'Un à trois couples de comptages sont attendus.'));
  }
  for (var i = 0; i < replicatePairs.length; i++) {
    final (a, b) = replicatePairs[i];
    if (a < 0 || b < 0) {
      errors.add(FieldError(fieldId: 'pair${i + 1}', message: 'Les comptages ne peuvent pas être négatifs.'));
    }
  }
  if (ejaculateVolumeMl != null && !(ejaculateVolumeMl > 0)) {
    errors.add(const FieldError(fieldId: 'volume', message: 'Le volume de l\'éjaculat doit être strictement positif.'));
  }
  if (errors.isNotEmpty) throw CalculationInputException(errors);

  final factor = spermCorrectionFactor(dilution, area);
  final warnings = <CalculationWarning>[];
  final attempts = <String>[];

  int? usedIndex;
  for (var i = 0; i < replicatePairs.length; i++) {
    final (a, b) = replicatePairs[i];
    final sum = a + b;
    final row = replicateLimitFor(sum);
    final diff = (a - b).abs();
    final ok = row != null && diff <= row.maxDifference;
    attempts.add('$a et $b (somme $sum, écart $diff'
        '${row == null ? (sum == 0 ? ', somme nulle' : ', hors tableau 2.3') : ', limite ${row.maxDifference}'}) → '
        '${row == null ? (sum == 0 ? 'aucun spermatozoïde' : 'accord non évalué') : ok ? 'accepté' : 'écart trop grand'}');
    if (ok) {
      usedIndex = i;
      break;
    }
    if (row == null && sum > 1000) {
      // Somme hors tableau : l'accord n'est pas évaluable ; on utilise ce couple avec mise en garde.
      usedIndex = i;
      warnings.add(CalculationWarning(
        'Somme $sum > 1000 : le tableau 2.3 de l\'OMS s\'arrête à 1000, l\'accord des réplicats n\'est pas évalué.',
        severity: WarningSeverity.caution,
      ));
      break;
    }
  }

  double? meanSum;
  var averaged = false;
  if (usedIndex != null) {
    final (a, b) = replicatePairs[usedIndex];
    meanSum = (a + b).toDouble();
  } else if (replicatePairs.length == 3) {
    meanSum = replicatePairs.fold<int>(0, (s, p) => s + p.$1 + p.$2) / 3;
    averaged = true;
    warnings.add(const CalculationWarning(
      'Écart trop grand après trois comptages : moyenne des trois sommes utilisée. Signalez dans le compte rendu '
      'l\'incertitude accrue du résultat (OMS § 2.4.8.4).',
      severity: WarningSeverity.caution,
    ));
  } else if (replicatePairs.every((p) => p.$1 + p.$2 == 0)) {
    warnings.add(const CalculationWarning(
      'Aucun spermatozoïde observé dans les réplicats : une absence totale (azoospermie) n\'est suspectée qu\'à ce '
      'stade ; le terme n\'est utilisé qu\'après examen d\'un culot de centrifugation (OMS § 2.4.8.8).',
      severity: WarningSeverity.caution,
    ));
  } else {
    warnings.add(CalculationWarning(
      'Écart entre les réplicats supérieur à la limite du tableau 2.3 : concentration non calculée. Chargez une '
      'nouvelle chambre à partir des dilutions en double et comptez de nouveau (jusqu\'à trois comptages, '
      'OMS § 2.4.8.4).',
      severity: WarningSeverity.caution,
    ));
  }

  final concentration = meanSum == null || meanSum == 0 ? null : meanSum / factor;
  final lookupSum = meanSum?.round();
  final limitRow = lookupSum == null ? null : replicateLimitFor(lookupSum);

  if (usedIndex != null && meanSum != null && meanSum > 0) {
    final (a, b) = replicatePairs[usedIndex];
    if (a < 200 || b < 200) {
      warnings.add(CalculationWarning(
        'Moins de 200 spermatozoïdes comptés dans au moins une chambre ($a et $b) : l\'OMS vise au moins 200 par '
        'réplicat. Étendez le comptage au nombre de carrés ou de grilles supérieur (jusqu\'aux grilles périphériques '
        'si les 25 grands carrés centraux n\'y suffisent pas), puis comptez la même surface dans les deux chambres.',
        severity: WarningSeverity.info,
      ));
    }
    if (a < 25 && b < 25) {
      final bound = 50 / factor;
      warnings.add(CalculationWarning(
        'Moins de 25 spermatozoïdes comptés dans chaque chambre : erreur estimée supérieure à 14 % (tableau 2.3). '
        'Notez dans le compte rendu : « Trop peu de spermatozoïdes comptés pour une détermination exacte de la '
        'concentration (< ${_fr(bound, 3)} ×10⁶/mL) » (OMS § 2.4.8.6).',
        severity: WarningSeverity.caution,
      ));
    }
  }

  double? total;
  if (concentration != null && ejaculateVolumeMl != null) total = concentration * ejaculateVolumeMl;

  if (concentration != null) {
    final r = _ref('Concentration');
    warnings.add(CalculationWarning(
      'Concentration ${concentration < r.p5 ? 'inférieure' : 'supérieure ou égale'} au 5e centile de la population '
      'de référence de l\'OMS (${_fr(r.p5, 0)} ×10⁶/mL, médiane ${_fr(r.median, 0)} ; tableau 8.3, Campbell et al.). '
      'Ce centile n\'est pas une limite entre hommes fertiles et infertiles (OMS § 8.1.3).',
      severity: WarningSeverity.info,
    ));
  }
  if (total != null) {
    final r = _ref('Nombre total');
    warnings.add(CalculationWarning(
      'Nombre total ${total < r.p5 ? 'inférieur' : 'supérieur ou égal'} au 5e centile de la population de référence '
      'de l\'OMS (${_fr(r.p5, 0)} ×10⁶ par éjaculat, médiane ${_fr(r.median, 0)} ; tableau 8.3).',
      severity: WarningSeverity.info,
    ));
  }

  final pairLines = {
    for (var i = 0; i < attempts.length; i++) 'Couple ${i + 1}': attempts[i],
    if (averaged) 'Moyenne des trois sommes': _fr(meanSum!, 1),
  };

  return CalculationResult(
    formula: semenCountMeta,
    echoedInputs: {
      'Dilution': dilution.label,
      'Surface comptée (chaque chambre)': area.label,
      'Facteur de correction F': _fr(factor, factor == factor.roundToDouble() ? 0 : 1),
      ...pairLines,
      if (ejaculateVolumeMl != null) 'Volume de l\'éjaculat': '${_fr(ejaculateVolumeMl, 1)} mL',
    },
    values: [
      // Deux chiffres significatifs, comme l'OMS pour la concentration moyenne (décision du validateur).
      ResultValue(
        label: 'Concentration en spermatozoïdes',
        value: concentration,
        unit: '×10⁶/mL',
        precision: concentration == null ? 2 : RoundingPolicy.decimalsForSignificant(concentration, significant: 2),
      ),
      if (concentration != null)
        ResultValue(
          label: 'Concentration en spermatozoïdes (par mL)',
          value: double.parse((concentration * 1e6).toStringAsPrecision(2)),
          unit: '/mL',
          precision: 0,
        ),
      if (limitRow != null)
        ResultValue(
            label: 'Erreur due au nombre d\'observations (tableau 2.3)', value: limitRow.errorPercent, unit: '%', precision: 1),
      if (ejaculateVolumeMl != null)
        ResultValue(
          label: 'Nombre total de spermatozoïdes par éjaculat',
          value: total,
          unit: '×10⁶',
          // OMS § 2.4.8.7 : entier, sauf une décimale acceptable sous 10 millions.
          precision: total != null && total < 10 ? 1 : 0,
        ),
    ],
    warnings: warnings,
    isComplete: concentration != null,
  );
}
