import 'package:biosigma_core/src/calculators/hemostasis/isth_dic_score.dart';
import 'package:test/test.dart';

void main() {
  group('calculateIsthDicScore', () {
    test('tous les critères renseignés : total = 5.0', () {
      final result = calculateIsthDicScore(
        underlyingDisorderPresent: true,
        plateletCountGL: 80,
        fibrinMarkerIncrease: FibrinMarkerIncrease.moderate,
        ptProlongationSeconds: 4,
        fibrinogenValue: 0.8,
        fibrinogenUnit: 'g/L',
      );
      expect(result.isComplete, isTrue);
      expect(result.values.single.value, closeTo(5.0, 1e-9));
    });

    test('cas limite : fibrinogène manquant -> incomplet', () {
      final result = calculateIsthDicScore(
        underlyingDisorderPresent: true,
        plateletCountGL: 80,
        fibrinMarkerIncrease: FibrinMarkerIncrease.moderate,
        ptProlongationSeconds: 4,
        fibrinogenValue: null,
      );
      expect(result.isComplete, isFalse);
      expect(result.values.single.value, isNull);
    });

    test('cas limite : pas de pathologie sous-jacente -> incomplet', () {
      final result = calculateIsthDicScore(
        underlyingDisorderPresent: false,
      );
      expect(result.isComplete, isFalse);
      expect(result.values.single.value, isNull);
    });
  });
}
