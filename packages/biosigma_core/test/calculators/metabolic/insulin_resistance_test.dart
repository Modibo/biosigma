import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('QUICKI', () {
    test('insuline=15 µU/mL, glycémie=90 mg/dL', () {
      final result = calculateQuicki(
        fastingInsulinValue: 15,
        fastingInsulinUnit: 'µU/mL',
        fastingGlucoseValue: 90,
        fastingGlucoseUnit: 'mg/dL',
        fastingConfirmed: true,
      );
      expect(result.values.single.value, closeTo(0.3194547527373662, 1e-9));
      expect(result.formula.id, 'quicki');
      // Aucune société savante (ADA/EASD/IDF) n'a publié de seuil
      // diagnostique officiel pour le QUICKI : l'interprétation doit le
      // dire honnêtement plutôt que d'inventer une recommandation.
      expect(
        result.warnings.any((w) =>
            w.message.contains('Aucun seuil diagnostique consensuel') &&
            w.severity == WarningSeverity.info),
        isTrue,
      );
    });

    test('insuline=5 µU/mL, glycémie=80 mg/dL', () {
      final result = calculateQuicki(
        fastingInsulinValue: 5,
        fastingInsulinUnit: 'µU/mL',
        fastingGlucoseValue: 80,
        fastingGlucoseUnit: 'mg/dL',
        fastingConfirmed: true,
      );
      expect(result.values.single.value, closeTo(0.38431089342012037, 1e-9));
    });

    test('insuline = 0 -> exception', () {
      expect(
        () => calculateQuicki(
          fastingInsulinValue: 0,
          fastingInsulinUnit: 'µU/mL',
          fastingGlucoseValue: 90,
          fastingGlucoseUnit: 'mg/dL',
          fastingConfirmed: true,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('glycémie négative -> exception', () {
      expect(
        () => calculateQuicki(
          fastingInsulinValue: 15,
          fastingInsulinUnit: 'µU/mL',
          fastingGlucoseValue: -10,
          fastingGlucoseUnit: 'mg/dL',
          fastingConfirmed: true,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('non à jeun -> exception', () {
      expect(
        () => calculateQuicki(
          fastingInsulinValue: 15,
          fastingInsulinUnit: 'µU/mL',
          fastingGlucoseValue: 90,
          fastingGlucoseUnit: 'mg/dL',
          fastingConfirmed: false,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });

  group('Indice TyG', () {
    test('TG=150 mg/dL, Glu=90 mg/dL', () {
      final result = calculateTyg(
        triglyceridesValue: 150,
        triglyceridesUnit: 'mg/dL',
        fastingGlucoseValue: 90,
        fastingGlucoseUnit: 'mg/dL',
        fastingConfirmed: true,
      );
      expect(result.values.single.value, closeTo(8.817297783866575, 1e-9));
      expect(result.formula.id, 'tyg_index');
      expect(
        result.warnings.any((w) =>
            w.message.contains('Aucun seuil diagnostique consensuel') &&
            w.severity == WarningSeverity.info),
        isTrue,
      );
    });

    test('TG=200 mg/dL, Glu=110 mg/dL', () {
      final result = calculateTyg(
        triglyceridesValue: 200,
        triglyceridesUnit: 'mg/dL',
        fastingGlucoseValue: 110,
        fastingGlucoseUnit: 'mg/dL',
        fastingConfirmed: true,
      );
      expect(result.values.single.value, closeTo(9.305650551780507, 1e-9));
    });

    test('TG = 0 -> exception (ln(0) interdit)', () {
      expect(
        () => calculateTyg(
          triglyceridesValue: 0,
          triglyceridesUnit: 'mg/dL',
          fastingGlucoseValue: 90,
          fastingGlucoseUnit: 'mg/dL',
          fastingConfirmed: true,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('non à jeun -> exception', () {
      expect(
        () => calculateTyg(
          triglyceridesValue: 150,
          triglyceridesUnit: 'mg/dL',
          fastingGlucoseValue: 90,
          fastingGlucoseUnit: 'mg/dL',
          fastingConfirmed: false,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });

  group('HOMA-IR', () {
    test('insuline=15 µU/mL, glycémie=90 mg/dL (conversion mmol/L)', () {
      final result = calculateHomaIr(
        fastingInsulinValue: 15,
        fastingInsulinUnit: 'µU/mL',
        fastingGlucoseValue: 90,
        fastingGlucoseUnit: 'mg/dL',
        fastingConfirmed: true,
      );
      expect(result.values.single.value, closeTo(3.3333333333333335, 0.01));
      expect(result.formula.id, 'homa_ir');
      expect(
        result.warnings.any((w) =>
            w.message.contains('Aucun seuil diagnostique consensuel') &&
            w.severity == WarningSeverity.info),
        isTrue,
      );
    });

    test('insuline=15 µU/mL, glycémie=5.0 mmol/L saisie directement', () {
      final result = calculateHomaIr(
        fastingInsulinValue: 15,
        fastingInsulinUnit: 'µU/mL',
        fastingGlucoseValue: 5.0,
        fastingGlucoseUnit: 'mmol/L',
        fastingConfirmed: true,
      );
      expect(result.values.single.value, closeTo(3.3333333333333335, 1e-9));
    });

    test('insuline négative -> exception', () {
      expect(
        () => calculateHomaIr(
          fastingInsulinValue: -5,
          fastingInsulinUnit: 'µU/mL',
          fastingGlucoseValue: 5.0,
          fastingGlucoseUnit: 'mmol/L',
          fastingConfirmed: true,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('non à jeun -> exception', () {
      expect(
        () => calculateHomaIr(
          fastingInsulinValue: 15,
          fastingInsulinUnit: 'µU/mL',
          fastingGlucoseValue: 5.0,
          fastingGlucoseUnit: 'mmol/L',
          fastingConfirmed: false,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });
}
