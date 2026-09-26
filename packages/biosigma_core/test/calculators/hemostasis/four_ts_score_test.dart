import 'package:biosigma_core/src/calculators/hemostasis/four_ts_score.dart';
import 'package:biosigma_core/src/models/result.dart';
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
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('probabilité clinique élevée') &&
            w.message.contains('Lo et al. (2006)')),
        isTrue,
      );
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
