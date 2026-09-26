import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('calculateTibcFromTransferrin', () {
    test('Transferrine=250 mg/dL', () {
      final result = calculateTibcFromTransferrin(transferrinMgDl: 250);
      expect(result.values.single.value, closeTo(355.0, 1e-9));
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.severity, WarningSeverity.info);
    });
  });

  group('calculateTransferrinSaturation', () {
    test('Fer=80 µg/dL, CTF=300 µg/dL (zone intermédiaire)', () {
      final result = calculateTransferrinSaturation(serumIronUgDl: 80, tibcUgDl: 300);
      expect(result.values.single.value, closeTo(26.666666666666668, 1e-9));
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.severity, WarningSeverity.info);
    });

    test('Saturation > 45 % : seuil de dépistage AASLD 2011', () {
      final result = calculateTransferrinSaturation(serumIronUgDl: 200, tibcUgDl: 300);
      expect(result.warnings.single.message, contains('AASLD'));
    });

    test('Saturation < 20 % : évocatrice d\'une carence martiale', () {
      final result = calculateTransferrinSaturation(serumIronUgDl: 40, tibcUgDl: 300);
      expect(result.warnings.single.message, contains('carence'));
    });
  });

  group('calculateGlobulinsAndRatio', () {
    test('Protéines totales=75 g/L, Albumine=40 g/L', () {
      final result = calculateGlobulinsAndRatio(
        totalProteinValue: 75,
        totalProteinUnit: 'g/L',
        albuminValue: 40,
        albuminUnit: 'g/L',
      );
      expect(result.values, hasLength(2));
      final globulines = result.values.firstWhere((v) => v.label == 'Globulines');
      expect(globulines.value, closeTo(35.0, 1e-9));
      final ratio = result.values.firstWhere((v) => v.label == 'Rapport albumine/globulines');
      expect(ratio.value, closeTo(1.1428571428571428, 1e-9));
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.severity, WarningSeverity.info);
    });

    test('rapport A/G bas ou inversé (< 1)', () {
      final result = calculateGlobulinsAndRatio(
        totalProteinValue: 90,
        totalProteinUnit: 'g/L',
        albuminValue: 30,
        albuminUnit: 'g/L',
      );
      // Globulines = 60, ratio = 30/60 = 0,5 < 1.
      expect(result.warnings.single.message, contains('inversé'));
    });
  });

  group('calculateIndirectBilirubin', () {
    test('Totale=20 µmol/L, Directe=5 µmol/L', () {
      final result = calculateIndirectBilirubin(
        totalBilirubinUmolL: 20,
        directBilirubinUmolL: 5,
      );
      expect(result.values.single.value, closeTo(15.0, 1e-9));
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.severity, WarningSeverity.info);
    });

    test('Directe > Totale lève une exception', () {
      expect(
        () => calculateIndirectBilirubin(
          totalBilirubinUmolL: 20,
          directBilirubinUmolL: 25,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });

  group('calculateAstAltRatio', () {
    test('ASAT=80 U/L, ALAT=40 U/L (rapport > 2, hépatite alcoolique)', () {
      final result = calculateAstAltRatio(astUL: 80, altUL: 40);
      expect(result.values.single.value, closeTo(2.0, 1e-9));
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.severity, WarningSeverity.info);
    });

    test('rapport < 1 : évocateur d\'une hépatite virale', () {
      final result = calculateAstAltRatio(astUL: 30, altUL: 60);
      expect(result.warnings.single.message, contains('virale'));
    });
  });

  group('calculateFib4', () {
    test('Âge=55, ASAT=45 U/L, Plaquettes=180 G/L, ALAT=35 U/L (zone indéterminée)', () {
      final result = calculateFib4(
        ageYears: 55,
        astUL: 45,
        plateletsGL: 180,
        altUL: 35,
      );
      expect(result.values.single.value, closeTo(2.3241742005034203, 1e-9));
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.severity, WarningSeverity.info);
      expect(result.warnings.single.message, contains('indéterminée'));
    });
  });

  group('calculateApri', () {
    test('ASAT=80 U/L, ULN=40 U/L, Plaquettes=150 G/L (zone intermédiaire)', () {
      final result = calculateApri(astUL: 80, astUln: 40, plateletsGL: 150);
      expect(result.values.single.value, closeTo(1.3333333333333333, 1e-9));
      expect(result.warnings, hasLength(1));
      expect(result.warnings.single.severity, WarningSeverity.info);
    });

    test('APRI > 2,0 : évocateur de cirrhose (seuil OMS 2016)', () {
      final result = calculateApri(astUL: 200, astUln: 40, plateletsGL: 100);
      // APRI = (200/40*100)/100 = 5.0.
      expect(result.warnings.single.message, contains('cirrhose'));
    });
  });
}
