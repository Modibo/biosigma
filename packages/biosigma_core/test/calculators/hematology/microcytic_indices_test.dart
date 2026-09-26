import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('calculateMentzerIndex', () {
    test('VGM 70 fL, GR 5,5 ×10¹²/L', () {
      final result = calculateMentzerIndex(mcvFl: 70, rbcTeraL: 5.5);
      expect(result.values.single.value, closeTo(12.727272727272727, 1e-6));
    });

    test('cas exact — VGM 100 fL, GR 4,0 ×10¹²/L', () {
      final result = calculateMentzerIndex(mcvFl: 100, rbcTeraL: 4.0);
      expect(result.values.single.value, closeTo(25.0, 1e-9));
    });

    test('GR nul — erreur de validation', () {
      expect(
        () => calculateMentzerIndex(mcvFl: 70, rbcTeraL: 0),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });

  group('calculateShineLalIndex', () {
    test('VGM 70 fL, TCMH 22 pg', () {
      final result = calculateShineLalIndex(mcvFl: 70, mchPg: 22);
      expect(result.values.single.value, closeTo(1078.0, 1e-6));
    });

    test('VGM 80 fL, TCMH 25 pg', () {
      final result = calculateShineLalIndex(mcvFl: 80, mchPg: 25);
      expect(result.values.single.value, closeTo(1600.0, 1e-6));
    });

    test('TCMH négative — erreur de validation', () {
      expect(
        () => calculateShineLalIndex(mcvFl: 70, mchPg: -1),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });

  group('calculateEnglandFraserIndex', () {
    test('VGM 70 fL, GR 5,5 ×10¹²/L, Hb 10 g/dL', () {
      final result = calculateEnglandFraserIndex(mcvFl: 70, rbcTeraL: 5.5, hbGDl: 10);
      expect(result.values.single.value, closeTo(11.1, 1e-6));
    });

    test('VGM 100 fL, GR 4,0 ×10¹²/L, Hb 15 g/dL', () {
      final result = calculateEnglandFraserIndex(mcvFl: 100, rbcTeraL: 4.0, hbGDl: 15);
      expect(result.values.single.value, closeTo(17.6, 1e-6));
    });

    test('Hb nulle — erreur de validation', () {
      expect(
        () => calculateEnglandFraserIndex(mcvFl: 70, rbcTeraL: 5.5, hbGDl: 0),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });

  group('calculateGreenKingIndex', () {
    test('VGM 70 fL, IDR 20 %, Hb 10 g/dL', () {
      final result = calculateGreenKingIndex(mcvFl: 70, rdwPercent: 20, hbGDl: 10);
      expect(result.values.single.value, closeTo(98.0, 1e-6));
    });

    test('VGM 85 fL, IDR 15 %, Hb 13 g/dL', () {
      final result = calculateGreenKingIndex(mcvFl: 85, rdwPercent: 15, hbGDl: 13);
      expect(result.values.single.value, closeTo(83.36538461538461, 1e-6));
    });

    test('IDR nulle — erreur de validation', () {
      expect(
        () => calculateGreenKingIndex(mcvFl: 70, rdwPercent: 0, hbGDl: 10),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });

  group('calculateRdwIndex', () {
    test('VGM 70 fL, IDR 20 %, GR 5,5 ×10¹²/L', () {
      final result = calculateRdwIndex(mcvFl: 70, rdwPercent: 20, rbcTeraL: 5.5);
      expect(result.values.single.value, closeTo(254.54545454545453, 1e-6));
    });

    test('cas exact — VGM 90 fL, IDR 14 %, GR 6,0 ×10¹²/L', () {
      final result = calculateRdwIndex(mcvFl: 90, rdwPercent: 14, rbcTeraL: 6.0);
      expect(result.values.single.value, closeTo(210.0, 1e-6));
    });

    test('GR négatif — erreur de validation', () {
      expect(
        () => calculateRdwIndex(mcvFl: 70, rdwPercent: 20, rbcTeraL: -5),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });
}
