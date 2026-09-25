import 'package:biosigma_core/src/calculators/hemostasis/four_ts_score.dart';
import 'package:test/test.dart';

void main() {
  group('calculateFourTsScore', () {
    test('les 4 critères à twoPoints -> total = 8.0', () {
      final result = calculateFourTsScore(
        thrombocytopenia: FourTsThrombocytopenia.twoPoints,
        timing: FourTsTiming.twoPoints,
        thrombosisSequelae: FourTsThrombosis.twoPoints,
        otherCauses: FourTsOtherCauses.twoPoints,
      );
      expect(result.isComplete, isTrue);
      expect(result.values.single.value, closeTo(8.0, 1e-9));
    });

    test('cas limite : otherCauses manquant -> incomplet', () {
      final result = calculateFourTsScore(
        thrombocytopenia: FourTsThrombocytopenia.twoPoints,
        timing: FourTsTiming.twoPoints,
        thrombosisSequelae: FourTsThrombosis.twoPoints,
      );
      expect(result.isComplete, isFalse);
      expect(result.values.single.value, isNull);
    });
  });
}
