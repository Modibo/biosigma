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
      // Un avertissement interprétatif (info) est toujours ajouté, même
      // quand la correction reste pertinente (glycémie > 1,00 g/L).
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.severity, WarningSeverity.info);
    });

    test('glycémie ≤ 1,00 g/L déclenche un avertissement info additionnel, sans bloquer le calcul', () {
      final result = calculateCorrectedSodium(
        sodiumValue: 138,
        glucoseValue: 90,
        glucoseUnit: 'mg/dL',
      );
      expect(result.values, hasLength(2));
      // 1 avertissement "correction peu pertinente" + 1 interprétation.
      expect(result.warnings, hasLength(2));
      expect(result.warnings.every((w) => w.severity == WarningSeverity.info), isTrue);
      expect(result.hasBlockingWarning, isFalse);
    });

    test("l'interprétation reflète les bandes hyponatrémie/normal/hypernatrémie", () {
      final result = calculateCorrectedSodium(
        sodiumValue: 130,
        glucoseValue: 400,
        glucoseUnit: 'mg/dL',
      );
      // Katz ≈ 134,8 (hyponatrémie) ; Hillier ≈ 137,2 (normal).
      final interpretation = result.warnings.firstWhere((w) => w.message.contains('Katz'));
      expect(interpretation.message, contains('hyponatrémie'));
      expect(interpretation.message, contains('normal'));
      expect(interpretation.severity, WarningSeverity.info);
    });
  });
}
