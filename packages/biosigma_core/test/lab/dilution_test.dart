// Valeurs attendues calculées à la main.
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void expectFieldError(void Function() body, String fieldId) {
  try {
    body();
    fail('une CalculationInputException était attendue');
  } on CalculationInputException catch (e) {
    expect(e.errors.map((x) => x.fieldId), contains(fieldId), reason: e.toString());
  }
}

ResultValue _find(CalculationResult r, String start) =>
    r.values.firstWhere((v) => v.label.startsWith(start));

void main() {
  group('Dilution simple C1·V1 = C2·V2', () {
    test('C2 : 10 mg/mL, 1 mL → 10 mL donne 1 mg/mL, F = 10, diluant 9 mL', () {
      final r = calculateDilution(
          c1: 10, c1Unit: 'mg/mL', v1: 1, v1Unit: 'mL', v2: 10, v2Unit: 'mL', c2Unit: 'mg/mL');
      expect(_find(r, 'C2').value, closeTo(1, 1e-12));
      expect(_find(r, 'Facteur').value, closeTo(10, 1e-12));
      expect(_find(r, 'Volume de diluant').value, closeTo(9, 1e-12));
    });

    test('V1 : C1 = 100, C2 = 5, V2 = 10 mL → V1 = 0,5 mL', () {
      final r = calculateDilution(
          c1: 100, c1Unit: 'mg/dL', c2: 5, c2Unit: 'mg/dL', v2: 10, v2Unit: 'mL', v1Unit: 'mL');
      expect(_find(r, 'V1').value, closeTo(0.5, 1e-12));
      expect(_find(r, 'V1').unit, 'mL');
    });

    test('V2 : C1 = 20, V1 = 2 mL, C2 = 4 → V2 = 10 mL', () {
      final r = calculateDilution(
          c1: 20, c1Unit: 'g/L', v1: 2, v1Unit: 'mL', c2: 4, c2Unit: 'g/L', v2Unit: 'mL');
      expect(_find(r, 'V2').value, closeTo(10, 1e-12));
    });

    test('C1 : C2 = 1, V2 = 10 mL, V1 = 1 mL → C1 = 10', () {
      final r = calculateDilution(
          c2: 1, c2Unit: 'mmol/L', v1: 1, v1Unit: 'mL', v2: 10, v2Unit: 'mL', c1Unit: 'mmol/L');
      expect(_find(r, 'C1').value, closeTo(10, 1e-12));
    });

    test('unités mélangées : 1 g/L, 100 µL dans 1 mL → 100 mg/L', () {
      final r = calculateDilution(
          c1: 1, c1Unit: 'g/L', v1: 100, v1Unit: 'µL', v2: 1, v2Unit: 'mL', c2Unit: 'mg/L');
      expect(_find(r, 'C2').value, closeTo(100, 1e-9));
      expect(_find(r, 'C2').unit, 'mg/L');
      expect(_find(r, 'Facteur').value, closeTo(10, 1e-9));
      expect(_find(r, 'Volume de diluant').value, closeTo(0.9, 1e-12));
    });

    test('un avertissement explique la notation 1/F', () {
      final r = calculateDilution(
          c1: 10, c1Unit: 'g/L', v1: 1, v1Unit: 'mL', v2: 10, v2Unit: 'mL', c2Unit: 'g/L');
      expect(r.warnings.any((w) => w.message.contains('ambigu')), isTrue);
    });

    test('refus : deux grandeurs manquantes, aucune manquante', () {
      expectFieldError(() => calculateDilution(c1: 10, v1: 1), 'c2');
      expectFieldError(() => calculateDilution(c1: 1, v1: 1, c2: 1, v2: 1), 'c1');
    });

    test('refus : ce n\'est pas une dilution (concentration finale > départ)', () {
      expectFieldError(
          () => calculateDilution(
              c1: 1, c1Unit: 'g/L', v1: 5, v1Unit: 'mL', v2: 1, v2Unit: 'mL', c2Unit: 'g/L'),
          'c2');
    });

    test('refus : natures de concentration différentes, valeurs non positives, unités fausses', () {
      expectFieldError(
          () => calculateDilution(
              c1: 10, c1Unit: 'mg/dL', v1: 1, v2: 10, c2Unit: 'mmol/L'),
          'c2');
      expectFieldError(
          () => calculateDilution(c1: 0, c1Unit: 'g/L', v1: 1, v2: 10, c2Unit: 'g/L'), 'c1');
      expectFieldError(
          () => calculateDilution(c1: 1, c1Unit: 'mL', v1: 1, v2: 10, c2Unit: 'g/L'), 'c1');
      expectFieldError(
          () => calculateDilution(c1: 1, c1Unit: 'g/L', v1: 1, v1Unit: 'g', v2: 10, c2Unit: 'g/L'),
          'v1');
    });
  });

  group('Dilutions en série', () {
    test('facteur 2, 4 tubes, 1 mL : 0,5 mL + 0,5 mL ; tube 4 = 1/16', () {
      final s = calculateSerialDilution(
          stockConcentration: 100,
          concentrationUnit: 'mg/dL',
          factor: 2,
          tubes: 4,
          finalVolume: 1,
          volumeUnit: 'mL');
      expect(s.rows.length, 4);
      expect(s.rows.first.transferredVolume, closeTo(0.5, 1e-12));
      expect(s.rows.first.diluentVolume, closeTo(0.5, 1e-12));
      expect([for (final r in s.rows) r.cumulativeFactor], [2, 4, 8, 16]);
      expect(s.rows.last.concentration, closeTo(6.25, 1e-12));
      expect(s.result.values.last.value, closeTo(6.25, 1e-12));
    });

    test('facteur 10, 3 tubes, 0,9 mL de diluant par mL final = 0,1 mL transféré', () {
      final s = calculateSerialDilution(
          stockConcentration: 1000,
          concentrationUnit: 'mg/L',
          factor: 10,
          tubes: 3,
          finalVolume: 1,
          volumeUnit: 'mL');
      expect(s.rows.first.transferredVolume, closeTo(0.1, 1e-12));
      expect(s.rows.first.diluentVolume, closeTo(0.9, 1e-12));
      expect([for (final r in s.rows) r.concentration], [100, 10, 1]
          .map((v) => closeTo(v, 1e-9)).toList());
    });

    test('refus : facteur ≤ 1, tubes hors 1-20, volume nul, unités incorrectes', () {
      calc({double? f = 2, int? n = 3, double? v = 1, String cu = 'mg/L', String vu = 'mL'}) =>
          () => calculateSerialDilution(
              stockConcentration: 10,
              concentrationUnit: cu,
              factor: f,
              tubes: n,
              finalVolume: v,
              volumeUnit: vu);
      expectFieldError(calc(f: 1), 'factor');
      expectFieldError(calc(f: null), 'factor');
      expectFieldError(calc(n: 0), 'tubes');
      expectFieldError(calc(n: 21), 'tubes');
      expectFieldError(calc(v: 0), 'finalVolume');
      expectFieldError(calc(cu: 'mL'), 'stockConcentration');
      expectFieldError(calc(vu: 'mg'), 'finalVolume');
    });
  });

  group('Facteur cumulé et hors linéarité', () {
    test('produit des facteurs : 2 × 5 = 10', () {
      expect(cumulativeDilutionFactor([2, 5]), 10);
      expect(cumulativeDilutionFactor([1]), 1);
    });

    test('refus : liste vide, facteur < 1, non fini', () {
      expectFieldError(() => cumulativeDilutionFactor([]), 'factors');
      expectFieldError(() => cumulativeDilutionFactor([2, 0.5]), 'factors');
      expectFieldError(() => cumulativeDilutionFactor([double.nan]), 'factors');
    });

    test('résultat dilué 150 dans [10 ; 200], F = 10 → 1500', () {
      final r = calculateOutOfRangeDilution(
          dilutedResult: 150, resultUnit: 'U/L', totalFactor: 10, linearityMin: 10, linearityMax: 200);
      expect(r.values.single.value, closeTo(1500, 1e-9));
      expect(r.isComplete, isTrue);
      expect(r.hasBlockingWarning, isFalse);
    });

    test('résultat dilué hors intervalle : aucun résultat présenté, avertissement bloquant', () {
      final r = calculateOutOfRangeDilution(
          dilutedResult: 250, resultUnit: 'U/L', totalFactor: 10, linearityMin: 10, linearityMax: 200);
      expect(r.values.single.value, isNull);
      expect(r.isComplete, isFalse);
      expect(r.hasBlockingWarning, isTrue);
    });

    test('bornes incluses', () {
      for (final v in [10.0, 200.0]) {
        final r = calculateOutOfRangeDilution(
            dilutedResult: v, resultUnit: 'U/L', totalFactor: 2, linearityMin: 10, linearityMax: 200);
        expect(r.values.single.value, closeTo(v * 2, 1e-9));
      }
    });

    test('refus : facteur < 1, bornes inversées, valeurs absentes', () {
      expectFieldError(
          () => calculateOutOfRangeDilution(
              dilutedResult: 1, resultUnit: 'U/L', totalFactor: 0.5, linearityMin: 0, linearityMax: 2),
          'totalFactor');
      expectFieldError(
          () => calculateOutOfRangeDilution(
              dilutedResult: 1, resultUnit: 'U/L', totalFactor: 2, linearityMin: 5, linearityMax: 2),
          'linearityMax');
      expectFieldError(
          () => calculateOutOfRangeDilution(
              dilutedResult: null, resultUnit: 'U/L', totalFactor: 2, linearityMin: 0, linearityMax: 2),
          'dilutedResult');
    });
  });
}
