import 'dart:math' as math;

import '../models/errors.dart';
import '../models/formula_meta.dart';
import '../models/reference.dart';
import '../models/result.dart';
import '../validation.dart';

/// Dénombrement de colonies : UFC/mL.
const FormulaMeta cfuMeta = FormulaMeta(
  id: 'lab_micro_cfu',
  name: 'Dénombrement de colonies (UFC/mL)',
  shortName: 'Microbiology — UFC/mL',
  category: CalculatorCategory.laboratory,
  version: 'Microbiology 1 — UFC/mL = colonies × 10^k / volume ensemencé',
  equation:
      'UFC/mL (boîte) = nombre de colonies / (volume ensemencé (mL) × 10^(−k))\n'
      'avec 10^(−k) = dilution de la suspension ensemencée\n'
      'Moyenne = moyenne arithmétique des boîtes dont le nombre de colonies est dans l\'intervalle saisi',
  sources: [
    Reference(
      citation:
          'Relation de définition du dénombrement après dilutions décimales : aucune norme citée. '
          'L\'intervalle de dénombrement acceptable dépend de la norme ou de la méthode du '
          'laboratoire et n\'est PAS embarqué — à relire par le laboratoire.',
    ),
  ],
  applicablePopulation: 'Sans objet (analyse d\'un échantillon ou d\'une suspension).',
  analyticalConditions: [
    'L\'intervalle de colonies dénombrables (bornes basse et haute) est saisi par l\'utilisateur, '
        'selon la norme ou la procédure du laboratoire.',
  ],
  limitations: [
    'La moyenne retenue est une moyenne arithmétique simple des boîtes dans l\'intervalle ; '
        'elle ne remplace pas la formule d\'une norme (ex. dilutions successives pondérées).',
    'Une boîte sans colonie donne une limite de détection, jamais « 0 UFC/mL ».',
    'Les UFC ne sont pas équivalentes à une densité optique ni à un standard de McFarland : '
        'aucune correspondance universelle n\'existe, aucune n\'est proposée.',
  ],
  displayPrecision: 2,
);

/// Une boîte de Pétri dénombrée.
class PlateCount {
  const PlateCount({
    required this.colonies,
    required this.dilutionExponent,
    required this.platedVolumeMl,
  });

  final int? colonies;

  /// k tel que la suspension ensemencée est diluée 10^(−k) (0 = non diluée).
  final int? dilutionExponent;
  final double? platedVolumeMl;
}

String _sci(double v) {
  if (v == 0) return '0';
  final exp = (math.log(v) / math.ln10).floor();
  final mant = v / math.pow(10, exp);
  return '${mant.toStringAsFixed(2)} × 10^$exp';
}

/// UFC/mL par boîte et moyenne des boîtes retenues.
///
/// [countMin]/[countMax] (colonies par boîte) sont saisis par l'utilisateur ;
/// s'ils sont absents, toutes les boîtes comptées sont retenues, avec un
/// avertissement.
CalculationResult calculateCfu({
  required List<PlateCount> plates,
  int? countMin,
  int? countMax,
}) {
  if (plates.isEmpty) {
    throw CalculationInputException(const [
      FieldError(fieldId: 'plates', message: 'Saisissez au moins une boîte.'),
    ]);
  }
  final errors = <FieldError?>[];
  for (var i = 0; i < plates.length; i++) {
    final p = plates[i];
    final n = i + 1;
    if (p.colonies == null || p.colonies! < 0) {
      errors.add(FieldError(
          fieldId: 'colonies$i', message: 'Boîte $n : le nombre de colonies doit être un entier ≥ 0.'));
    }
    if (p.dilutionExponent == null || p.dilutionExponent! < 0 || p.dilutionExponent! > 12) {
      errors.add(FieldError(
          fieldId: 'exponent$i', message: 'Boîte $n : l\'exposant de dilution doit être un entier de 0 à 12.'));
    }
    errors.add(Validation.checkPositive(p.platedVolumeMl, 'volume$i', 'Boîte $n : le volume ensemencé'));
  }
  if (countMin != null && countMin < 0) {
    errors.add(const FieldError(fieldId: 'countMin', message: 'La borne basse ne peut pas être négative.'));
  }
  if (countMin != null && countMax != null && countMin >= countMax) {
    errors.add(const FieldError(fieldId: 'countMax', message: 'La borne haute doit dépasser la borne basse.'));
  }
  Validation.raiseIfAny(errors);

  final values = <ResultValue>[];
  final retained = <double>[];
  final notes = <String>[];
  for (var i = 0; i < plates.length; i++) {
    final p = plates[i];
    final n = i + 1;
    final factor = math.pow(10, p.dilutionExponent!).toDouble();
    if (p.colonies == 0) {
      final limit = factor / p.platedVolumeMl!;
      values.add(ResultValue(label: 'Boîte $n (10^-${p.dilutionExponent})', value: null, unit: 'UFC/mL'));
      notes.add('Boîte $n : aucune colonie — résultat « < ${_sci(limit)} UFC/mL » (limite de détection), pas zéro.');
      continue;
    }
    final cfu = p.colonies! * factor / p.platedVolumeMl!;
    final inRange = (countMin == null || p.colonies! >= countMin) &&
        (countMax == null || p.colonies! <= countMax);
    values.add(ResultValue(
        label: 'Boîte $n (10^-${p.dilutionExponent}, ${p.colonies} colonies)'
            '${inRange ? '' : ' — hors intervalle'}',
        value: cfu,
        unit: 'UFC/mL',
        precision: 0));
    if (inRange) retained.add(cfu);
  }

  final hasRange = countMin != null || countMax != null;
  double? mean;
  if (retained.isNotEmpty) {
    mean = retained.reduce((a, b) => a + b) / retained.length;
    values.add(ResultValue(label: 'Moyenne des boîtes retenues (${retained.length})', value: mean, unit: 'UFC/mL', precision: 0));
    values.add(ResultValue(
        label: 'log10 (UFC/mL) de la moyenne',
        value: math.log(mean) / math.ln10,
        unit: 'log10',
        precision: 2));
  }

  return CalculationResult(
    formula: cfuMeta,
    isComplete: mean != null,
    echoedInputs: {
      'Boîtes saisies': '${plates.length}',
      'Intervalle de colonies retenu': hasRange
          ? '${countMin ?? '—'} à ${countMax ?? '—'} colonies par boîte (saisi)'
          : 'non précisé : toutes les boîtes avec colonies sont retenues',
    },
    values: values,
    warnings: [
      ...notes.map((m) => CalculationWarning(m, severity: WarningSeverity.info)),
      if (mean == null)
        const CalculationWarning(
          'Aucune boîte exploitable (aucune colonie, ou nombre de colonies hors de l\'intervalle '
          'saisi) : pas de résultat présenté. Refaire avec une autre dilution selon la procédure '
          'du laboratoire.',
          severity: WarningSeverity.blocking,
        ),
      if (!hasRange)
        const CalculationWarning(
          'Intervalle de dénombrement non précisé : l\'exactitude d\'une boîte très chargée ou '
          'très peu chargée n\'est pas contrôlée. Saisissez les bornes de votre norme.',
          severity: WarningSeverity.caution,
        ),
      const CalculationWarning(
        'Moyenne arithmétique simple des boîtes retenues ; ne remplace pas la formule d\'une norme.',
        severity: WarningSeverity.info,
      ),
    ],
  );
}
