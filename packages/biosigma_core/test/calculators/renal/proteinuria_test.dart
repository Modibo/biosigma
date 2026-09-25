import 'package:biosigma_core/src/calculators/renal/proteinuria.dart';
import 'package:biosigma_core/src/models/result.dart';
import 'package:test/test.dart';

void main() {
  group('calculateProteinuria24h', () {
    test('durée exacte de 24h (1440 min) : pas d\'extrapolation, valeur 270 mg', () {
      final result = calculateProteinuria24h(
        concentrationValue: 150,
        concentrationUnit: 'mg/L',
        volumeValue: 1800,
        volumeUnit: 'mL',
        durationValue: 1440,
        durationUnit: 'min',
      );

      expect(
        result.values.any((v) => v.unit == 'mg' && v.value != null && (v.value! - 270.0).abs() < 1e-9),
        isTrue,
      );
      expect(
        result.values.any((v) => v.unit == 'g' && v.value != null && (v.value! - 0.27).abs() < 1e-9),
        isTrue,
      );
      // Pas d'avertissement d'extrapolation pour une collecte de 24h exacte.
      expect(
        result.warnings.any((w) => w.message.contains('incomplète')),
        isFalse,
      );
    });

    test('collecte de 12h (720 min) : mesure 135 mg, extrapolation 270 mg, warning caution', () {
      final result = calculateProteinuria24h(
        concentrationValue: 150,
        concentrationUnit: 'mg/L',
        volumeValue: 900,
        volumeUnit: 'mL',
        durationValue: 12,
        durationUnit: 'h',
      );

      expect(
        result.values.any((v) => v.unit == 'mg' && v.value != null && (v.value! - 135.0).abs() < 1e-9),
        isTrue,
      );
      expect(
        result.values.any((v) => v.value != null && (v.value! - 270.0).abs() < 1e-9),
        isTrue,
      );
      expect(
        result.warnings.any((w) => w.severity == WarningSeverity.caution),
        isTrue,
      );
    });
  });
}
