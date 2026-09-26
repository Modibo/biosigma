import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

double? _byLabel(CalculationResult result, String label) =>
    result.values.firstWhere((v) => v.label == label).value;

void main() {
  group('IMC (BMI)', () {
    test('poids=70 kg, taille=170 cm', () {
      final result = calculateBmi(weightKgValue: 70, heightCmValue: 170);
      // Calcul indépendant (Python) : 70 / (1.70^2) = 24.221453287197235
      expect(result.values.single.value, closeTo(24.221453287197235, 1e-6));
      expect(result.formula.id, 'bmi');
      // Classification OMS 2000, universellement reconnue : toujours
      // affichée en avertissement informatif.
      expect(
        result.warnings.any((w) =>
            w.message.contains('OMS 2000') &&
            w.message.contains('poids normal') &&
            w.severity == WarningSeverity.info),
        isTrue,
      );
    });

    test('poids=55 kg, taille=160 cm', () {
      final result = calculateBmi(weightKgValue: 55, heightCmValue: 160);
      // Calcul indépendant (Python) : 55 / (1.60^2) = 21.484375
      expect(result.values.single.value, closeTo(21.484374999999996, 1e-6));
    });

    test('poids nul -> exception', () {
      expect(
        () => calculateBmi(weightKgValue: 0, heightCmValue: 170),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('taille négative -> exception', () {
      expect(
        () => calculateBmi(weightKgValue: 70, heightCmValue: -170),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });

  group('TyG-IMC', () {
    test('TG=150 mg/dL, Glu=90 mg/dL, poids=70 kg, taille=170 cm', () {
      final result = calculateTygBmi(
        triglyceridesValue: 150,
        triglyceridesUnit: 'mg/dL',
        fastingGlucoseValue: 90,
        fastingGlucoseUnit: 'mg/dL',
        weightKgValue: 70,
        heightCmValue: 170,
        fastingConfirmed: true,
      );
      // Calcul indépendant (Python) :
      // TyG = ln(150*90/2) = 8.817297783866575
      // IMC = 70/(1.70^2) = 24.221453287197235
      // TyG-IMC = 213.56776639123194
      final tygBmi = _byLabel(result, 'TyG-IMC');
      expect(tygBmi, closeTo(213.56776639123194, 1e-6));
      expect(result.formula.id, 'tyg_bmi');
      expect(
        result.warnings.any((w) =>
            w.message.contains('Aucun seuil diagnostique consensuel') &&
            w.severity == WarningSeverity.info),
        isTrue,
      );

      final tygComponent = _byLabel(result, 'Indice TyG (composante)');
      expect(tygComponent, closeTo(8.817297783866575, 1e-6));
      final bmiComponent = _byLabel(result, 'IMC (composante)');
      expect(bmiComponent, closeTo(24.221453287197235, 1e-6));
    });

    test(
        'conversion unité — glycémie saisie en mmol/L au lieu de mg/dL '
        '(5,0 mmol/L équivaut à 90,090090... mg/dL)', () {
      final result = calculateTygBmi(
        triglyceridesValue: 150,
        triglyceridesUnit: 'mg/dL',
        fastingGlucoseValue: 5.0,
        fastingGlucoseUnit: 'mmol/L',
        weightKgValue: 70,
        heightCmValue: 170,
        fastingConfirmed: true,
      );
      // Calcul indépendant (Python) : glucose 5.0 mmol/L -> 90.09009009009009
      // mg/dL ; TyG = ln(150*90.09009009009009/2) ; IMC = 24.221453287197235
      // TyG-IMC = 213.5919999633257
      final tygBmi = _byLabel(result, 'TyG-IMC');
      expect(tygBmi, closeTo(213.5919999633257, 1e-6));
    });

    test('triglycérides nulles -> exception (ln(0) interdit)', () {
      expect(
        () => calculateTygBmi(
          triglyceridesValue: 0,
          triglyceridesUnit: 'mg/dL',
          fastingGlucoseValue: 90,
          fastingGlucoseUnit: 'mg/dL',
          weightKgValue: 70,
          heightCmValue: 170,
          fastingConfirmed: true,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('non à jeun -> exception', () {
      expect(
        () => calculateTygBmi(
          triglyceridesValue: 150,
          triglyceridesUnit: 'mg/dL',
          fastingGlucoseValue: 90,
          fastingGlucoseUnit: 'mg/dL',
          weightKgValue: 70,
          heightCmValue: 170,
          fastingConfirmed: false,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });

  group('HOMA-β', () {
    test('insuline=15 µU/mL, glycémie=5.0 mmol/L', () {
      final result = calculateHomaBeta(
        fastingInsulinValue: 15,
        fastingInsulinUnit: 'µU/mL',
        fastingGlucoseValue: 5.0,
        fastingGlucoseUnit: 'mmol/L',
        fastingConfirmed: true,
      );
      // Calcul indépendant (Python) : (20*15)/(5.0-3.5) = 200.0
      expect(result.values.single.value, closeTo(200.0, 1e-6));
      expect(result.formula.id, 'homa_beta');
      expect(
        result.warnings.any((w) =>
            w.message.contains("Aucun seuil consensuel") &&
            w.severity == WarningSeverity.info),
        isTrue,
      );
    });

    test('insuline=8 µU/mL, glycémie=4.5 mmol/L', () {
      final result = calculateHomaBeta(
        fastingInsulinValue: 8,
        fastingInsulinUnit: 'µU/mL',
        fastingGlucoseValue: 4.5,
        fastingGlucoseUnit: 'mmol/L',
        fastingConfirmed: true,
      );
      // Calcul indépendant (Python) : (20*8)/(4.5-3.5) = 160.0
      expect(result.values.single.value, closeTo(160.0, 1e-6));
    });

    test('insuline=15 µU/mL, glycémie=90 mg/dL (conversion mg/dL -> mmol/L)',
        () {
      final result = calculateHomaBeta(
        fastingInsulinValue: 15,
        fastingInsulinUnit: 'µU/mL',
        fastingGlucoseValue: 90,
        fastingGlucoseUnit: 'mg/dL',
        fastingConfirmed: true,
      );
      // Calcul indépendant (Python) : 90 mg/dL -> 90*0.0555 = 4.995 mmol/L
      // (20*15)/(4.995-3.5) = 200.6688963210702
      expect(result.values.single.value, closeTo(200.6688963210702, 1e-6));
    });

    test('glycémie = 3,5 mmol/L (dénominateur nul) -> exception', () {
      expect(
        () => calculateHomaBeta(
          fastingInsulinValue: 15,
          fastingInsulinUnit: 'µU/mL',
          fastingGlucoseValue: 3.5,
          fastingGlucoseUnit: 'mmol/L',
          fastingConfirmed: true,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('glycémie = 3,0 mmol/L (dénominateur négatif) -> exception', () {
      expect(
        () => calculateHomaBeta(
          fastingInsulinValue: 15,
          fastingInsulinUnit: 'µU/mL',
          fastingGlucoseValue: 3.0,
          fastingGlucoseUnit: 'mmol/L',
          fastingConfirmed: true,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('non à jeun -> exception', () {
      expect(
        () => calculateHomaBeta(
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

  group('Rapport CT/HDL (Castelli I)', () {
    test('CT=5,0 mmol/L, HDL=1,2 mmol/L', () {
      final result = calculateCtHdlRatio(
        totalCholesterolValue: 5.0,
        totalCholesterolUnit: 'mmol/L',
        hdlValue: 1.2,
        hdlUnit: 'mmol/L',
      );
      // Calcul indépendant (Python) : 5.0/1.2 = 4.166666666666667
      expect(result.values.single.value, closeTo(4.166666666666667, 1e-6));
      expect(result.formula.id, 'ct_hdl_ratio');
      // Repère informel légué par l'ère NCEP, explicitement non retenu par
      // les recommandations actuelles (ESC/EAS, ADA) comme critère de
      // première ligne.
      expect(
        result.warnings.any((w) =>
            w.message.contains('ESC/EAS') &&
            w.message.contains('repère informel') &&
            w.severity == WarningSeverity.info),
        isTrue,
      );
    });

    test('conversion unité — cholestérol saisi en g/L au lieu de mmol/L', () {
      final result = calculateCtHdlRatio(
        totalCholesterolValue: 2.0,
        totalCholesterolUnit: 'g/L',
        hdlValue: 0.5,
        hdlUnit: 'g/L',
      );
      // Calcul indépendant (Python) : 2.0 g/L -> 5.172 mmol/L ;
      // 0.5 g/L -> 1.293 mmol/L ; ratio = 4.0 (identique au ratio g/L brut
      // car la conversion est linéaire et s'annule).
      expect(result.values.single.value, closeTo(4.0, 1e-6));
    });

    test('HDL nul -> exception', () {
      expect(
        () => calculateCtHdlRatio(
          totalCholesterolValue: 5.0,
          totalCholesterolUnit: 'mmol/L',
          hdlValue: 0,
          hdlUnit: 'mmol/L',
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });

  group('Rapport ApoB/ApoA1', () {
    test('ApoB=1,1 g/L, ApoA1=1,5 g/L', () {
      final result = calculateApoBApoA1Ratio(apoBValue: 1.1, apoA1Value: 1.5);
      // Calcul indépendant (Python) : 1.1/1.5 = 0.7333333333333334
      expect(result.values.single.value, closeTo(0.7333333333333334, 1e-6));
      expect(result.formula.id, 'apob_apoa1_ratio');
      // Pas de seuil unique consensuel ESC/AHA ; mentionné en ESC/EAS 2019
      // comme outil d'affinement du risque dans des situations spécifiques.
      expect(
        result.warnings.any((w) =>
            w.message.contains('ESC/EAS 2019') &&
            w.message.contains("affinement du risque") &&
            w.severity == WarningSeverity.info),
        isTrue,
      );
    });

    test('ApoB=0,9 g/L, ApoA1=1,6 g/L', () {
      final result = calculateApoBApoA1Ratio(apoBValue: 0.9, apoA1Value: 1.6);
      // Calcul indépendant (Python) : 0.9/1.6 = 0.5625
      expect(result.values.single.value, closeTo(0.5625, 1e-6));
    });

    test('ApoA1 nul -> exception', () {
      expect(
        () => calculateApoBApoA1Ratio(apoBValue: 1.1, apoA1Value: 0),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('ApoB négatif -> exception', () {
      expect(
        () => calculateApoBApoA1Ratio(apoBValue: -1.1, apoA1Value: 1.5),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });
}
