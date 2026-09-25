import 'package:biosigma_core/src/calculators/hemostasis/inr.dart';
import 'package:biosigma_core/src/models/result.dart';
import 'package:test/test.dart';

void main() {
  group('calculateInr', () {
    test('PT patient=28 s, PT moyen normal=12 s, ISI=1.0', () {
      final result = calculateInr(
        patientPtSeconds: 28,
        meanNormalPtSeconds: 12,
        isi: 1.0,
      );
      expect(result.values.single.value, closeTo(2.3333333333333335, 1e-9));
    });

    test('PT patient=28 s, PT moyen normal=12 s, ISI=1.2', () {
      final result = calculateInr(
        patientPtSeconds: 28,
        meanNormalPtSeconds: 12,
        isi: 1.2,
      );
      expect(result.values.single.value, closeTo(2.7642170559319026, 1e-9));
    });
  });

  group('calculateAptRatio', () {
    test('Patient=45 s, Témoin=30 s', () {
      final result = calculateAptRatio(
        patientAptSeconds: 45,
        controlAptSeconds: 30,
      );
      expect(result.values.single.value, closeTo(1.5, 1e-9));
    });
  });

  group('calculateSerialTrend', () {
    test('previous=2.0, current=3.5, unit=INR', () {
      final result = calculateSerialTrend(
        analyteLabel: 'INR',
        previousValue: 2.0,
        currentValue: 3.5,
        unit: 'INR',
      );
      final absolute = result.values.firstWhere((v) => v.label == 'Variation absolue');
      final relative = result.values.firstWhere((v) => v.label == 'Variation relative');
      expect(absolute.value, closeTo(1.5, 1e-9));
      expect(relative.value, closeTo(75.0, 1e-9));
      expect(result.warnings, isEmpty);
    });

    test('cas limite : previous=0, current=1.0', () {
      final result = calculateSerialTrend(
        analyteLabel: 'Fibrinogène',
        previousValue: 0,
        currentValue: 1.0,
        unit: 'g/L',
      );
      final absolute = result.values.firstWhere((v) => v.label == 'Variation absolue');
      final relative = result.values.firstWhere((v) => v.label == 'Variation relative');
      expect(absolute.value, closeTo(1.0, 1e-9));
      expect(relative.value, isNull);
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.caution &&
            w.message.contains('non calculable')),
        isTrue,
      );
    });
  });
}
