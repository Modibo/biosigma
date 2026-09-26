import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('calculateReticulocyteIndicesPanel', () {
    ResultValue byLabel(CalculationResult result, String label) =>
        result.values.firstWhere((v) => v.label == label);

    test('Hct 40 % (borne haute du palier 1,0)', () {
      final result = calculateReticulocyteIndicesPanel(
        reticulocytePercent: 2.0,
        rbcTeraL: 4.5,
        hematocritPercent: 40,
      );
      expect(byLabel(result, 'Nombre absolu de réticulocytes').value, closeTo(90.0, 1e-6));
      expect(
        byLabel(result, 'Réticulocytes corrigés (CRC)').value,
        closeTo(1.7777777777777777, 1e-6),
      );
      expect(
        byLabel(result, 'Indice de production réticulocytaire (RPI)').value,
        closeTo(1.7777777777777777, 1e-6),
      );
      expect(
        result.warnings.single.message,
        contains('réponse médullaire inadaptée'),
      );
    });

    test('Hct 35 % (palier 1,5)', () {
      final result = calculateReticulocyteIndicesPanel(
        reticulocytePercent: 5.0,
        rbcTeraL: 3.0,
        hematocritPercent: 35,
      );
      expect(byLabel(result, 'Nombre absolu de réticulocytes').value, closeTo(150.0, 1e-6));
      expect(
        byLabel(result, 'Réticulocytes corrigés (CRC)').value,
        closeTo(3.888888888888889, 1e-6),
      );
      expect(
        byLabel(result, 'Indice de production réticulocytaire (RPI)').value,
        closeTo(2.5925925925925926, 1e-6),
      );
      expect(
        result.warnings.single.message,
        contains('réponse médullaire compensatrice adaptée'),
      );
    });

    test('Hct 39,9 % — juste sous la borne 40, doit rester au palier 1,5', () {
      final result = calculateReticulocyteIndicesPanel(
        reticulocytePercent: 3.0,
        rbcTeraL: 4.0,
        hematocritPercent: 39.9,
      );
      expect(
        byLabel(result, 'Indice de production réticulocytaire (RPI)').value,
        closeTo(1.7733333333333332, 1e-6),
      );
    });

    test('Hct 40 % exactement — bascule au palier 1,0', () {
      final result = calculateReticulocyteIndicesPanel(
        reticulocytePercent: 3.0,
        rbcTeraL: 4.0,
        hematocritPercent: 40,
      );
      expect(
        byLabel(result, 'Indice de production réticulocytaire (RPI)').value,
        closeTo(2.6666666666666665, 1e-6),
      );
    });

    test('Hct 29,9 % — palier 2,0', () {
      final result = calculateReticulocyteIndicesPanel(
        reticulocytePercent: 4.0,
        rbcTeraL: 4.0,
        hematocritPercent: 29.9,
      );
      expect(
        byLabel(result, 'Indice de production réticulocytaire (RPI)').value,
        closeTo(1.3288888888888888, 1e-6),
      );
    });

    test('Hct 20 % exactement — reste au palier 2,0', () {
      final result = calculateReticulocyteIndicesPanel(
        reticulocytePercent: 4.0,
        rbcTeraL: 4.0,
        hematocritPercent: 20,
      );
      expect(
        byLabel(result, 'Indice de production réticulocytaire (RPI)').value,
        closeTo(0.8888888888888888, 1e-6),
      );
    });

    test('Hct 19,9 % — bascule au palier 2,5', () {
      final result = calculateReticulocyteIndicesPanel(
        reticulocytePercent: 4.0,
        rbcTeraL: 4.0,
        hematocritPercent: 19.9,
      );
      expect(
        byLabel(result, 'Indice de production réticulocytaire (RPI)').value,
        closeTo(0.7075555555555555, 1e-6),
      );
    });

    test('réticulocytes négatifs — erreur de validation', () {
      expect(
        () => calculateReticulocyteIndicesPanel(
          reticulocytePercent: -1,
          rbcTeraL: 4.0,
          hematocritPercent: 40,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('hématocrite nul — erreur de validation', () {
      expect(
        () => calculateReticulocyteIndicesPanel(
          reticulocytePercent: 2.0,
          rbcTeraL: 4.0,
          hematocritPercent: 0,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });
}
