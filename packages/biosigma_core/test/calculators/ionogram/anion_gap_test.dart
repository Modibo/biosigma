import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('calculateAnionGap', () {
    test('sans potassium ni albumine', () {
      final result = calculateAnionGap(
        sodiumValue: 140,
        chlorideValue: 104,
        bicarbonateValue: 24,
      );
      expect(result.values, hasLength(1));
      expect(result.values.single.label, 'Trou anionique (sans potassium)');
      expect(result.values.single.value, closeTo(12.0, 1e-9));
      // Interprétation toujours présente : ici AG = 12, catégorie "normal".
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.severity, WarningSeverity.info);
      expect(result.warnings.single.message, contains('normal'));
    });

    test('trou anionique élevé déclenche une interprétation adaptée', () {
      final result = calculateAnionGap(
        sodiumValue: 140,
        chlorideValue: 95,
        bicarbonateValue: 15,
      );
      // AG = 140 - (95+15) = 30 mmol/L -> élevé.
      expect(result.warnings.single.message, contains('élevé'));
      expect(result.warnings.single.message, contains('MUDPILES'));
    });

    test('avec potassium', () {
      final result = calculateAnionGap(
        sodiumValue: 140,
        chlorideValue: 104,
        bicarbonateValue: 24,
        potassiumValue: 4.5,
      );
      expect(result.values, hasLength(2));
      final avecK =
          result.values.firstWhere((v) => v.label == 'Trou anionique (avec potassium)');
      expect(avecK.value, closeTo(16.5, 1e-9));
      final sansK =
          result.values.firstWhere((v) => v.label == 'Trou anionique (sans potassium)');
      expect(sansK.value, closeTo(12.0, 1e-9));
    });

    test('avec potassium et albumine — les 3 valeurs sont présentes', () {
      final result = calculateAnionGap(
        sodiumValue: 140,
        chlorideValue: 104,
        bicarbonateValue: 24,
        potassiumValue: 4.5,
        albuminValue: 20,
        albuminUnit: 'g/L',
      );
      expect(result.values, hasLength(3));

      final sansK =
          result.values.firstWhere((v) => v.label == 'Trou anionique (sans potassium)');
      expect(sansK.value, closeTo(12.0, 1e-9));

      final avecK =
          result.values.firstWhere((v) => v.label == 'Trou anionique (avec potassium)');
      expect(avecK.value, closeTo(16.5, 1e-9));

      final corrige = result.values
          .firstWhere((v) => v.label == "Trou anionique corrigé pour l'albuminémie");
      expect(corrige.value, closeTo(17.0, 1e-9));

      // 1 interprétation de l'AG sans K + 1 note sur la correction albumine.
      expect(result.warnings, hasLength(2));
      expect(
        result.warnings.any((w) => w.message.contains('albuminémie')),
        isTrue,
      );
    });
  });
}
