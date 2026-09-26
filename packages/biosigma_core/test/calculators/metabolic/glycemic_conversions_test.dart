import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('Glycémie moyenne estimée (eAG, ADAG)', () {
    test('HbA1c = 7.0 %', () {
      final result = calculateEstimatedAverageGlucose(hba1cValue: 7.0, hba1cUnit: '%');
      final mgDl = result.values.firstWhere((v) => v.unit == 'mg/dL');
      final mmolL = result.values.firstWhere((v) => v.unit == 'mmol/L');
      expect(mgDl.value, closeTo(154.2, 1e-6));
      expect(mmolL.value, closeTo(8.5581, 1e-3));
      expect(result.formula.id, 'estimated_average_glucose_adag');
      // Objectif ADA (< 7 %, à individualiser) toujours affiché, jamais
      // présenté comme un seuil universel non individualisé.
      expect(
        result.warnings.any((w) =>
            w.message.contains('American Diabetes Association') &&
            w.message.contains('individualisé') &&
            w.severity == WarningSeverity.info),
        isTrue,
      );
    });

    test('HbA1c = 5.5 %', () {
      final result = calculateEstimatedAverageGlucose(hba1cValue: 5.5, hba1cUnit: '%');
      final mgDl = result.values.firstWhere((v) => v.unit == 'mg/dL');
      expect(mgDl.value, closeTo(111.14999999999999, 1e-6));
    });

    test('HbA1c = 53 mmol/mol (IFCC) -> eAG proche de 154.2 mg/dL', () {
      final result =
          calculateEstimatedAverageGlucose(hba1cValue: 53, hba1cUnit: 'mmol/mol');
      final mgDl = result.values.firstWhere((v) => v.unit == 'mg/dL');
      expect(mgDl.value, closeTo(154.2, 0.5));
    });

    test('valeur manquante ou non positive -> exception', () {
      expect(
        () => calculateEstimatedAverageGlucose(hba1cValue: -1, hba1cUnit: '%'),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('unité inconnue -> exception', () {
      expect(
        () => calculateEstimatedAverageGlucose(hba1cValue: 7.0, hba1cUnit: 'g/L'),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });
}
