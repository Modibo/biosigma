import 'package:biosigma_core/src/calculators/hemostasis/rosner_index.dart';
import 'package:test/test.dart';

void main() {
  group('calculateRosnerIndex', () {
    test('lecture immédiate : mix=38 s, témoin=12 s, patient=70 s', () {
      final result = calculateRosnerIndex(
        mixTimeSeconds: 38,
        normalPlasmaTimeSeconds: 12,
        patientPlasmaTimeSeconds: 70,
        phase: RosnerTimingPhase.immediate,
      );
      expect(result.values.single.value, closeTo(37.142857142857146, 1e-9));
      expect(result.values.single.label, contains('Lecture immédiate'));
      expect(result.echoedInputs['Phase'], 'Lecture immédiate');
    });

    test('après incubation : mix=45 s, témoin=12 s, patient=70 s', () {
      final result = calculateRosnerIndex(
        mixTimeSeconds: 45,
        normalPlasmaTimeSeconds: 12,
        patientPlasmaTimeSeconds: 70,
        phase: RosnerTimingPhase.afterIncubation,
      );
      expect(result.values.single.value, closeTo(47.142857142857146, 1e-9));
      expect(result.values.single.label, contains('Après incubation'));
      expect(result.echoedInputs['Phase'], contains('Après incubation'));
    });

    test('le label diffère selon la phase', () {
      final immediate = calculateRosnerIndex(
        mixTimeSeconds: 38,
        normalPlasmaTimeSeconds: 12,
        patientPlasmaTimeSeconds: 70,
        phase: RosnerTimingPhase.immediate,
      );
      final afterIncubation = calculateRosnerIndex(
        mixTimeSeconds: 45,
        normalPlasmaTimeSeconds: 12,
        patientPlasmaTimeSeconds: 70,
        phase: RosnerTimingPhase.afterIncubation,
      );
      expect(immediate.values.single.label, isNot(equals(afterIncubation.values.single.label)));
    });
  });
}
