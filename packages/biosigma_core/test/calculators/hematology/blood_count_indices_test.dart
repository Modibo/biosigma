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

ResultValue v(CalculationResult r, String label, {String? unit}) =>
    r.values.firstWhere((x) => x.label == label && (unit == null || x.unit == unit));

void main() {
  group('Constantes érythrocytaires', () {
    test('Hb 15 g/dL, Ht 45 %, GR 5 : VGM 90 fL, TCMH 30 pg, CCMH 33,33 g/dL', () {
      final r = calculateRedCellIndices(hemoglobinGdL: 15, hematocritPercent: 45, rbcTeraL: 5);
      expect(v(r, 'VGM').value, closeTo(90, 1e-12)); // 450 / 5
      expect(v(r, 'TCMH').value, closeTo(30, 1e-12)); // 150 / 5
      expect(v(r, 'CCMH').value, closeTo(1500 / 45, 1e-12)); // 33,333…
      expect(v(r, 'VGM').unit, 'fL');
      expect(v(r, 'TCMH').unit, 'pg');
      expect(v(r, 'CCMH').unit, 'g/dL');
    });

    test('anémie : Hb 9, Ht 28, GR 3,6 → VGM 77,78 ; TCMH 25 ; CCMH 32,14', () {
      final r = calculateRedCellIndices(hemoglobinGdL: 9, hematocritPercent: 28, rbcTeraL: 3.6);
      expect(v(r, 'VGM').value, closeTo(280 / 3.6, 1e-9));
      expect(v(r, 'VGM').value, closeTo(77.78, 5e-3));
      expect(v(r, 'TCMH').value, closeTo(25, 1e-12));
      expect(v(r, 'CCMH').value, closeTo(900 / 28, 1e-9));
    });

    test('aucun intervalle de référence n\'est comparé', () {
      final r = calculateRedCellIndices(hemoglobinGdL: 15, hematocritPercent: 45, rbcTeraL: 5);
      expect(r.warnings.single.message, contains('Aucun intervalle de référence'));
      expect(r.hasBlockingWarning, isFalse);
    });

    test('hématocrite 100 % accepté, au-delà refusé', () {
      expect(calculateRedCellIndices(hemoglobinGdL: 30, hematocritPercent: 100, rbcTeraL: 10).values.first.value,
          closeTo(100, 1e-12));
      expectFieldError(
          () => calculateRedCellIndices(hemoglobinGdL: 15, hematocritPercent: 101, rbcTeraL: 5), 'hematocrit');
    });

    test('refus : valeurs nulles ou négatives', () {
      expectFieldError(() => calculateRedCellIndices(hemoglobinGdL: 0, hematocritPercent: 45, rbcTeraL: 5), 'hemoglobin');
      expectFieldError(() => calculateRedCellIndices(hemoglobinGdL: 15, hematocritPercent: 0, rbcTeraL: 5), 'hematocrit');
      expectFieldError(() => calculateRedCellIndices(hemoglobinGdL: 15, hematocritPercent: 45, rbcTeraL: -1), 'rbc');
    });
  });

  group('Valeurs absolues leucocytaires', () {
    test('8 ×10⁹/L, neutrophiles 60 %, bandes 5 %, lymphocytes 30 % → ANC 5,2 ; ALC 2,4', () {
      final r = calculateAbsoluteLeukocyteCounts(
          wbcGL: 8, neutrophilsPercent: 60, bandsPercent: 5, lymphocytesPercent: 30);
      expect(v(r, 'ANC (polynucléaires neutrophiles)').value, closeTo(5.2, 1e-12));
      expect(v(r, 'ANC', unit: '/µL').value, closeTo(5200, 1e-9));
      expect(v(r, 'ALC (lymphocytes)').value, closeTo(2.4, 1e-12));
      expect(v(r, 'ALC', unit: '/µL').value, closeTo(2400, 1e-9));
    });

    test('bandes à 0 : ANC = leucocytes × neutrophiles / 100', () {
      final r = calculateAbsoluteLeukocyteCounts(
          wbcGL: 4.5, neutrophilsPercent: 40, bandsPercent: 0, lymphocytesPercent: 50);
      expect(v(r, 'ANC (polynucléaires neutrophiles)').value, closeTo(1.8, 1e-12));
      expect(v(r, 'ALC (lymphocytes)').value, closeTo(2.25, 1e-12));
    });

    test('aucun seuil de neutropénie ou de lymphopénie n\'est appliqué', () {
      final r = calculateAbsoluteLeukocyteCounts(
          wbcGL: 1.0, neutrophilsPercent: 10, bandsPercent: 0, lymphocytesPercent: 80);
      final text = r.warnings.map((w) => w.message.toLowerCase()).join(' ');
      expect(text, contains('aucun seuil'));
      expect(r.hasBlockingWarning, isFalse);
    });

    test('formule incohérente (somme > 100 %) : avertissement bloquant', () {
      final r = calculateAbsoluteLeukocyteCounts(
          wbcGL: 8, neutrophilsPercent: 70, bandsPercent: 20, lymphocytesPercent: 30);
      expect(r.hasBlockingWarning, isTrue);
    });

    test('refus : leucocytes nuls, pourcentage hors 0-100, négatif', () {
      expectFieldError(
          () => calculateAbsoluteLeukocyteCounts(wbcGL: 0, neutrophilsPercent: 50, bandsPercent: 0, lymphocytesPercent: 30), 'wbc');
      expectFieldError(
          () => calculateAbsoluteLeukocyteCounts(wbcGL: 8, neutrophilsPercent: 101, bandsPercent: 0, lymphocytesPercent: 30), 'neutrophils');
      expectFieldError(
          () => calculateAbsoluteLeukocyteCounts(wbcGL: 8, neutrophilsPercent: 50, bandsPercent: -1, lymphocytesPercent: 30), 'bands');
      expectFieldError(
          () => calculateAbsoluteLeukocyteCounts(wbcGL: 8, neutrophilsPercent: 50, bandsPercent: 0, lymphocytesPercent: -5), 'lymphocytes');
    });
  });

  test('les deux équations sont au catalogue et au registre', () {
    for (final id in ['red_cell_indices', 'absolute_leukocyte_counts']) {
      expect(CalculatorCatalog.byId(id), isNotNull, reason: id);
      expect(EquationRegistry.resolve(id)!.stableId, 'HEMATO_${id.toUpperCase()}_001');
    }
  });
}
