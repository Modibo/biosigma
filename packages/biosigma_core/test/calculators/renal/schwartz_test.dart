import 'package:biosigma_core/src/calculators/renal/schwartz.dart';
import 'package:biosigma_core/src/models/errors.dart';
import 'package:biosigma_core/src/models/result.dart';
import 'package:test/test.dart';

void main() {
  group('calculateSchwartzBedside', () {
    test('8 ans, taille 100 cm, Scr 0.5 mg/dL', () {
      final result = calculateSchwartzBedside(
        ageYears: 8,
        heightCm: 100,
        creatinineValue: 0.5,
        creatinineUnit: 'mg/dL',
      );
      expect(result.values.single.value, closeTo(82.6, 1e-6));
      // Pas de zone de transition jeune adulte à cet âge.
      expect(
        result.warnings.any((w) => w.severity == WarningSeverity.caution),
        isFalse,
      );
      // DFG ~82.6 mL/min/1,73 m² : stade KDIGO G2 (60-89).
      expect(result.warnings.any((w) => w.message.contains('G2')), isTrue);
    });

    test('12 ans, taille 120 cm, Scr 0.4 mg/dL', () {
      final result = calculateSchwartzBedside(
        ageYears: 12,
        heightCm: 120,
        creatinineValue: 0.4,
        creatinineUnit: 'mg/dL',
      );
      expect(result.values.single.value, closeTo(123.89999999999998, 1e-6));
      // DFG ~123.9 mL/min/1,73 m² : stade KDIGO G1 (≥ 90).
      expect(result.warnings.any((w) => w.message.contains('G1')), isTrue);
    });

    test('âge = 30 ans lève une exception (hors domaine)', () {
      expect(
        () => calculateSchwartzBedside(
          ageYears: 30,
          heightCm: 170,
          creatinineValue: 1.0,
          creatinineUnit: 'mg/dL',
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('âge = 20 ans calcule mais avec un avertissement caution', () {
      final result = calculateSchwartzBedside(
        ageYears: 20,
        heightCm: 170,
        creatinineValue: 0.8,
        creatinineUnit: 'mg/dL',
      );
      expect(result.values.single.value, isNotNull);
      expect(
        result.warnings.any((w) => w.severity == WarningSeverity.caution),
        isTrue,
      );
    });
  });
}
