import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('calculateTibcFromTransferrin', () {
    test('Transferrine=250 mg/dL', () {
      final result = calculateTibcFromTransferrin(transferrinMgDl: 250);
      expect(result.values.single.value, closeTo(355.0, 1e-9));
    });
  });

  group('calculateTransferrinSaturation', () {
    test('Fer=80 µg/dL, CTF=300 µg/dL', () {
      final result = calculateTransferrinSaturation(serumIronUgDl: 80, tibcUgDl: 300);
      expect(result.values.single.value, closeTo(26.666666666666668, 1e-9));
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
    });
  });

  group('calculateIndirectBilirubin', () {
    test('Totale=20 µmol/L, Directe=5 µmol/L', () {
      final result = calculateIndirectBilirubin(
        totalBilirubinUmolL: 20,
        directBilirubinUmolL: 5,
      );
      expect(result.values.single.value, closeTo(15.0, 1e-9));
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
    test('ASAT=80 U/L, ALAT=40 U/L', () {
      final result = calculateAstAltRatio(astUL: 80, altUL: 40);
      expect(result.values.single.value, closeTo(2.0, 1e-9));
    });
  });

  group('calculateFib4', () {
    test('Âge=55, ASAT=45 U/L, Plaquettes=180 G/L, ALAT=35 U/L', () {
      final result = calculateFib4(
        ageYears: 55,
        astUL: 45,
        plateletsGL: 180,
        altUL: 35,
      );
      expect(result.values.single.value, closeTo(2.3241742005034203, 1e-9));
    });
  });

  group('calculateApri', () {
    test('ASAT=80 U/L, ULN=40 U/L, Plaquettes=150 G/L', () {
      final result = calculateApri(astUL: 80, astUln: 40, plateletsGL: 150);
      expect(result.values.single.value, closeTo(1.3333333333333333, 1e-9));
    });
  });
}
