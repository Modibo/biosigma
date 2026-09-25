import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('calculateCorrectedSodium', () {
    test('Na=130 mmol/L, Glucose=400 mg/dL', () {
      final result = calculateCorrectedSodium(
        sodiumValue: 130,
        glucoseValue: 400,
        glucoseUnit: 'mg/dL',
      );
      expect(result.values, hasLength(2));
      final katz =
          result.values.firstWhere((v) => v.label == 'Sodium corrigé — coefficient de Katz (1,6)');
      expect(katz.value, closeTo(134.8, 1e-9));
      final hillier = result.values
          .firstWhere((v) => v.label == 'Sodium corrigé — coefficient de Hillier (2,4)');
      expect(hillier.value, closeTo(137.2, 1e-9));
      expect(result.warnings, isEmpty);
    });

    test('glycémie ≤ 1,00 g/L déclenche un avertissement info, sans bloquer le calcul', () {
      final result = calculateCorrectedSodium(
        sodiumValue: 138,
        glucoseValue: 90,
        glucoseUnit: 'mg/dL',
      );
      expect(result.values, hasLength(2));
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.severity, WarningSeverity.info);
      expect(result.hasBlockingWarning, isFalse);
    });
  });
}
