// Dossier FV-PREP-015 — conversions fréquentes : valeurs calculées hors du code
// à partir des formules brutes et des poids atomiques abrégés, puis comparées
// aux masses molaires de PubChem (voir le dossier).
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

double conv(String id, double v, String from, String to) =>
    calculateAnalyteUnitConversion(
      analyteId: id,
      value: v,
      fromUnit: from,
      toUnit: to,
    ).values.first.value!;

void close(double actual, double expected, String reason) =>
    expect(actual, closeTo(expected, expected.abs() * 1e-12), reason: reason);

void main() {
  test('créatinine : 1 mg/dL = 88,4017 µmol/L ; 100 µmol/L = 1,1312 mg/dL', () {
    close(
      conv('creatinine', 1, 'mg/dL', 'µmol/L'),
      88.40169731258841,
      '1 mg/dL',
    );
    close(conv('creatinine', 100, 'µmol/L', 'mg/dL'), 1.1312, '100 µmol/L');
  });
  test('urée : 40 mg/dL = 6,6605 mmol/L ; azote uréique 20 mg/dL = 7,1393 mmol/L d\'urée', () {
    close(conv('urea', 40, 'mg/dL', 'mmol/L'), 6.660450246436659, 'urée');
    close(
      conv('urea_nitrogen', 20, 'mg/dL', 'mmol/L'),
      7.139287499107589,
      'BUN',
    );
  });
  test('calcium : 9,5 mg/dL = 2,3704 mmol/L', () {
    close(
      conv('calcium', 9.5, 'mg/dL', 'mmol/L'),
      2.370377763361445,
      'calcium',
    );
  });
  test('cholestérol : 200 mg/dL = 5,1724 mmol/L ; triglycérides : 150 mg/dL = 1,6940 mmol/L', () {
    close(
      conv('cholesterol', 200, 'mg/dL', 'mmol/L'),
      5.172449465168725,
      'cholestérol',
    );
    close(
      conv('triglycerides', 150, 'mg/dL', 'mmol/L'),
      1.6940481312955065,
      'triglycérides',
    );
  });
  test('bilirubine : 1 mg/dL = 17,1036 µmol/L', () {
    close(
      conv('bilirubin', 1, 'mg/dL', 'µmol/L'),
      17.103577555317244,
      'bilirubine',
    );
  });
  test('sodium : 140 mmol/L = 321,86 mg/dL', () {
    close(conv('sodium', 140, 'mmol/L', 'mg/dL'), 321.86, 'sodium');
  });
}
