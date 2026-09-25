import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('calculateCorrectedCalcium', () {
    test('Calcium=7.5 mg/dL, Albumine=2.0 g/dL', () {
      final result = calculateCorrectedCalcium(
        calciumValue: 7.5,
        calciumUnit: 'mg/dL',
        albuminValue: 2.0,
        albuminUnit: 'g/dL',
      );
      expect(result.values, hasLength(2));
      final mgDl = result.values.firstWhere((v) => v.unit == 'mg/dL');
      expect(mgDl.value, closeTo(9.1, 1e-9));
      final mmolL = result.values.firstWhere((v) => v.unit == 'mmol/L');
      // 9.1 mg/dL converti via UnitRegistry (facteur 0,2495 mg/dL -> mmol/L
      // du registre du paquet) = 2,27045 mmol/L.
      expect(mmolL.value, closeTo(2.27045, 1e-9));
    });

    test('Calcium=2.0 mmol/L, Albumine=20 g/L (=2.0 g/dL)', () {
      final result = calculateCorrectedCalcium(
        calciumValue: 2.0,
        calciumUnit: 'mmol/L',
        albuminValue: 20,
        albuminUnit: 'g/L',
      );
      final mgDl = result.values.firstWhere((v) => v.unit == 'mg/dL');
      // calciumMgDl = 2.0 / 0.2495 ≈ 8.016032 ; corrigé = +0.8*(4-2) = 9.616032.
      expect(mgDl.value, closeTo(9.616, 1e-2));
    });
  });
}
