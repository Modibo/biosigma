import 'package:biosigma_core/src/calculators/renal/ckd_epi.dart';
import 'package:biosigma_core/src/models/errors.dart';
import 'package:biosigma_core/src/models/sex.dart';
import 'package:test/test.dart';

void main() {
  group('calculateCkdEpiCreatinine2021', () {
    test('femme 60 ans, Scr 1.0 mg/dL', () {
      final result = calculateCkdEpiCreatinine2021(
        age: 60,
        sex: Sex.female,
        creatinineValue: 1.0,
        creatinineUnit: 'mg/dL',
        idmsConfirmed: true,
      );
      expect(result.values.single.value, closeTo(64.4950003539451, 1e-6));
    });

    test('homme 60 ans, Scr 1.0 mg/dL', () {
      final result = calculateCkdEpiCreatinine2021(
        age: 60,
        sex: Sex.male,
        creatinineValue: 1.0,
        creatinineUnit: 'mg/dL',
        idmsConfirmed: true,
      );
      expect(result.values.single.value, closeTo(86.16262077966914, 1e-6));
    });

    test('femme 50 ans, Scr 1.4 mg/dL', () {
      final result = calculateCkdEpiCreatinine2021(
        age: 50,
        sex: Sex.female,
        creatinineValue: 1.4,
        creatinineUnit: 'mg/dL',
        idmsConfirmed: true,
      );
      expect(result.values.single.value, closeTo(45.83344299705897, 1e-6));
      // DFG ~45.8 mL/min/1,73 m² : stade KDIGO G3a (45-59).
      expect(result.warnings.any((w) => w.message.contains('G3a')), isTrue);
    });

    test('homme 70 ans, Scr 2.0 mg/dL', () {
      final result = calculateCkdEpiCreatinine2021(
        age: 70,
        sex: Sex.male,
        creatinineValue: 2.0,
        creatinineUnit: 'mg/dL',
        idmsConfirmed: true,
      );
      expect(result.values.single.value, closeTo(35.24299672901596, 1e-6));
      // DFG ~35.2 mL/min/1,73 m² : stade KDIGO G3b (30-44).
      expect(result.warnings.any((w) => w.message.contains('G3b')), isTrue);
    });

    test('âge < 18 ans lève une exception', () {
      expect(
        () => calculateCkdEpiCreatinine2021(
          age: 17,
          sex: Sex.female,
          creatinineValue: 1.0,
          creatinineUnit: 'mg/dL',
          idmsConfirmed: true,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('IDMS non confirmé lève une exception', () {
      expect(
        () => calculateCkdEpiCreatinine2021(
          age: 60,
          sex: Sex.female,
          creatinineValue: 1.0,
          creatinineUnit: 'mg/dL',
          idmsConfirmed: false,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });

  group('calculateCkdEpiCystatinC2012', () {
    test('femme 60 ans, Cys 1.0 mg/L', () {
      final result = calculateCkdEpiCystatinC2012(
        age: 60,
        sex: Sex.female,
        cystatinCValue: 1.0,
        cystatinCUnit: 'mg/L',
      );
      expect(result.values.single.value, closeTo(72.4655114056525, 1e-6));
    });

    test('homme 50 ans, Cys 0.8 mg/L', () {
      final result = calculateCkdEpiCystatinC2012(
        age: 50,
        sex: Sex.male,
        cystatinCValue: 0.8,
        cystatinCUnit: 'mg/L',
      );
      expect(result.values.single.value, closeTo(108.84752593992127, 1e-6));
      // DFG ~108.8 mL/min/1,73 m² : stade KDIGO G1 (≥ 90).
      expect(result.warnings.any((w) => w.message.contains('G1')), isTrue);
    });

    test('âge < 18 ans lève une exception', () {
      expect(
        () => calculateCkdEpiCystatinC2012(
          age: 15,
          sex: Sex.female,
          cystatinCValue: 1.0,
          cystatinCUnit: 'mg/L',
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });

  group('calculateCkdEpiCreatinineCystatinC2021', () {
    test('femme 60 ans, Scr 1.0 mg/dL, Cys 1.0 mg/L', () {
      final result = calculateCkdEpiCreatinineCystatinC2021(
        age: 60,
        sex: Sex.female,
        creatinineValue: 1.0,
        creatinineUnit: 'mg/dL',
        cystatinCValue: 1.0,
        cystatinCUnit: 'mg/L',
        idmsConfirmed: true,
      );
      expect(result.values.single.value, closeTo(71.19898544641248, 1e-6));
    });

    test('homme 50 ans, Scr 1.4 mg/dL, Cys 0.9 mg/L', () {
      final result = calculateCkdEpiCreatinineCystatinC2021(
        age: 50,
        sex: Sex.male,
        creatinineValue: 1.4,
        creatinineUnit: 'mg/dL',
        cystatinCValue: 0.9,
        cystatinCUnit: 'mg/L',
        idmsConfirmed: true,
      );
      expect(result.values.single.value, closeTo(79.6706544530851, 1e-6));
      // DFG ~79.7 mL/min/1,73 m² : stade KDIGO G2 (60-89).
      expect(result.warnings.any((w) => w.message.contains('G2')), isTrue);
    });
  });
}
