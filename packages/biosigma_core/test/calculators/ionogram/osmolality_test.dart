import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('calculateCalculatedOsmolarity', () {
    test('sans osmolalité mesurée', () {
      final result = calculateCalculatedOsmolarity(
        sodiumValue: 140,
        glucoseValue: 5.5,
        glucoseUnit: 'mmol/L',
        ureaValue: 5.0,
      );
      expect(result.values, hasLength(1));
      expect(result.values.single.label, 'Osmolarité calculée');
      expect(result.values.single.value, closeTo(290.5, 1e-9));
      // Convention : pas de trou osmolaire dans values lorsque l'osmolalité
      // mesurée n'est pas fournie (aucune valeur placeholder).
      expect(
        result.values.any((v) => v.label.contains('Trou osmolaire')),
        isFalse,
      );
    });

    test('avec osmolalité mesurée', () {
      final result = calculateCalculatedOsmolarity(
        sodiumValue: 140,
        glucoseValue: 5.5,
        glucoseUnit: 'mmol/L',
        ureaValue: 5.0,
        measuredOsmolalityValue: 305,
      );
      expect(result.values, hasLength(2));
      final calculee = result.values.firstWhere((v) => v.label == 'Osmolarité calculée');
      expect(calculee.value, closeTo(290.5, 1e-9));
      final trou = result.values
          .firstWhere((v) => v.label == 'Trou osmolaire (osmolalité mesurée − osmolarité calculée)');
      expect(trou.value, closeTo(14.5, 1e-9));
      // Trou osmolaire = 14,5 mOsm/kg > 10 -> interprétation "élevé".
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.severity, WarningSeverity.info);
      expect(result.warnings.single.message, contains('élevé'));
    });

    test('trou osmolaire non élevé (≤ 10 mOsm/kg)', () {
      final result = calculateCalculatedOsmolarity(
        sodiumValue: 140,
        glucoseValue: 5.5,
        glucoseUnit: 'mmol/L',
        ureaValue: 5.0,
        measuredOsmolalityValue: 295,
      );
      // Trou = 295 - 290,5 = 4,5 mOsm/kg <= 10 -> "non élevé".
      expect(result.warnings.single.message, contains('non élevé'));
    });
  });
}
