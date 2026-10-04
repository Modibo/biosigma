// P3-03 (duplication A-18) : les formules partagées donnent les mêmes résultats
// quel que soit le calcul qui les utilise.
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

double _v(CalculationResult r, String labelStart) =>
    r.values.firstWhere((v) => v.label.startsWith(labelStart)).value!;

void main() {
  test(
    'TyG : le calcul autonome et la composante du TyG-IMC sont identiques',
    () {
      for (final (tg, g) in [(150.0, 90.0), (1.7, 5.0), (300.0, 126.0)]) {
        final unit = tg < 10 ? 'mmol/L' : 'mg/dL';
        final gUnit = g < 20 ? 'mmol/L' : 'mg/dL';
        final alone = calculateTyg(
          triglyceridesValue: tg,
          triglyceridesUnit: unit,
          fastingGlucoseValue: g,
          fastingGlucoseUnit: gUnit,
          fastingConfirmed: true,
        );
        final withBmi = calculateTygBmi(
          triglyceridesValue: tg,
          triglyceridesUnit: unit,
          fastingGlucoseValue: g,
          fastingGlucoseUnit: gUnit,
          weightKgValue: 70,
          heightCmValue: 170,
          fastingConfirmed: true,
        );
        expect(
          _v(withBmi, 'Indice TyG'),
          _v(alone, 'Indice TyG'),
          reason: '$tg/$g',
        );
      }
    },
  );

  test(
    'CT/HDL : le panel lipidique et le ratio autonome donnent la même valeur',
    () {
      for (final (tc, hdl) in [(5.2, 1.3), (200.0, 50.0), (7.8, 0.9)]) {
        final unit = tc < 20 ? 'mmol/L' : 'mg/dL';
        final panel = calculateLdlPanel(
          totalCholesterolValue: tc,
          totalCholesterolUnit: unit,
          hdlValue: hdl,
          hdlUnit: unit,
          triglyceridesValue: 1.2,
          triglyceridesUnit: 'mmol/L',
          formula: LdlFormula.friedewald,
        );
        final alone = calculateCtHdlRatio(
          totalCholesterolValue: tc,
          totalCholesterolUnit: unit,
          hdlValue: hdl,
          hdlUnit: unit,
        );
        expect(
          _v(panel, 'Ratio CT/HDL'),
          _v(alone, 'Indice de Castelli I'),
          reason: '$tc/$hdl',
        );
      }
    },
  );

  test('formules partagées : valeurs de référence calculées à la main', () {
    // ln((150 × 90) / 2) = ln 6750
    expect(tygIndexFromMgDl(150, 90), closeTo(8.817, 1e-3));
    expect(totalToHdlCholesterolRatio(5.2, 1.3), closeTo(4.0, 1e-12));
  });
}
