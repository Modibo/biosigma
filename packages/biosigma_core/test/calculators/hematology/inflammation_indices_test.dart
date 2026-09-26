import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('calculateSiiIndex', () {
    test('Plaquettes 250, Neutrophiles 6, Lymphocytes 2 (×10⁹/L)', () {
      final result = calculateSiiIndex(
        plateletsGL: 250,
        neutrophilsGL: 6,
        lymphocytesGL: 2,
      );
      expect(result.values.single.value, closeTo(750.0, 1e-6));
      expect(
        result.warnings.single.message,
        contains("Aucun seuil clinique consensuel"),
      );
    });

    test('Plaquettes 180,5, Neutrophiles 4,2, Lymphocytes 1,5 (×10⁹/L)', () {
      final result = calculateSiiIndex(
        plateletsGL: 180.5,
        neutrophilsGL: 4.2,
        lymphocytesGL: 1.5,
      );
      expect(result.values.single.value, closeTo(505.40000000000003, 1e-6));
    });

    test('lymphocytes nuls — erreur de validation (division par zéro)', () {
      expect(
        () => calculateSiiIndex(plateletsGL: 250, neutrophilsGL: 6, lymphocytesGL: 0),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('plaquettes négatives — erreur de validation', () {
      expect(
        () => calculateSiiIndex(plateletsGL: -1, neutrophilsGL: 6, lymphocytesGL: 2),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });

  group('calculateSiriIndex', () {
    test('Neutrophiles 6, Monocytes 0,8, Lymphocytes 2 (×10⁹/L)', () {
      final result = calculateSiriIndex(
        neutrophilsGL: 6,
        monocytesGL: 0.8,
        lymphocytesGL: 2,
      );
      expect(result.values.single.value, closeTo(2.4000000000000004, 1e-6));
      expect(
        result.warnings.single.message,
        contains("Aucun seuil clinique consensuel"),
      );
    });

    test('Neutrophiles 4,5, Monocytes 0,6, Lymphocytes 1,2 (×10⁹/L)', () {
      final result = calculateSiriIndex(
        neutrophilsGL: 4.5,
        monocytesGL: 0.6,
        lymphocytesGL: 1.2,
      );
      expect(result.values.single.value, closeTo(2.25, 1e-6));
    });

    test('lymphocytes nuls — erreur de validation (division par zéro)', () {
      expect(
        () => calculateSiriIndex(neutrophilsGL: 6, monocytesGL: 0.8, lymphocytesGL: 0),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('monocytes négatifs — erreur de validation', () {
      expect(
        () => calculateSiriIndex(neutrophilsGL: 6, monocytesGL: -1, lymphocytesGL: 2),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });
}
