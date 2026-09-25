import 'package:biosigma_core/src/calculators/renal/urine_ratios.dart';
import 'package:test/test.dart';

void main() {
  group('calculateAlbuminCreatinineRatio', () {
    test('albumine 45 mg/L, créatinine 7000 µmol/L', () {
      final result = calculateAlbuminCreatinineRatio(
        albuminValue: 45,
        albuminUnit: 'mg/L',
        creatinineValue: 7000,
        creatinineUnit: 'µmol/L',
      );

      final mgG = result.values.firstWhere((v) => v.unit == 'mg/g');
      final mgMmol = result.values.firstWhere((v) => v.unit == 'mg/mmol');
      expect(mgG.value, closeTo(56.841428571428565, 1e-6));
      expect(mgMmol.value, closeTo(6.428571428571429, 1e-6));
    });
  });

  group('calculateProteinCreatinineRatio', () {
    test('protéines 45 mg/L, créatinine 7000 µmol/L', () {
      final result = calculateProteinCreatinineRatio(
        proteinValue: 45,
        proteinUnit: 'mg/L',
        creatinineValue: 7000,
        creatinineUnit: 'µmol/L',
      );

      final mgG = result.values.firstWhere((v) => v.unit == 'mg/g');
      final mgMmol = result.values.firstWhere((v) => v.unit == 'mg/mmol');
      expect(mgG.value, closeTo(56.841428571428565, 1e-6));
      expect(mgMmol.value, closeTo(6.428571428571429, 1e-6));
    });
  });

  group('calculateTimedCreatinineClearance', () {
    test('U_Cr 8800 µmol/L, P_Cr 90 µmol/L, Volume 1500 mL, Durée 1440 min', () {
      final result = calculateTimedCreatinineClearance(
        urineCreatinineValue: 8800,
        urineCreatinineUnit: 'µmol/L',
        serumCreatinineValue: 90,
        serumCreatinineUnit: 'µmol/L',
        urineVolumeValue: 1500,
        urineVolumeUnit: 'mL',
        durationValue: 1440,
        durationUnit: 'min',
      );
      expect(result.values.single.value, closeTo(101.85185185185185, 1e-6));
    });
  });

  group('calculateFeNa', () {
    test('UNa 40, PNa 140, PCr 2.0 mg/dL, UCr 60 mg/dL', () {
      final result = calculateFeNa(
        urineSodiumValue: 40,
        serumSodiumValue: 140,
        urineCreatinineValue: 60,
        urineCreatinineUnit: 'mg/dL',
        serumCreatinineValue: 2.0,
        serumCreatinineUnit: 'mg/dL',
      );
      expect(result.values.single.value, closeTo(0.9523809523809524, 1e-6));
    });
  });

  group('calculateFeUrea', () {
    test('U_urée 250, S_urée 10, P_Cr 90 µmol/L, U_Cr 8800 µmol/L', () {
      final result = calculateFeUrea(
        urineUreaValue: 250,
        serumUreaValue: 10,
        urineCreatinineValue: 8800,
        urineCreatinineUnit: 'µmol/L',
        serumCreatinineValue: 90,
        serumCreatinineUnit: 'µmol/L',
      );
      expect(result.values.single.value, closeTo(25.568181818181817, 1e-6));
    });
  });
}
