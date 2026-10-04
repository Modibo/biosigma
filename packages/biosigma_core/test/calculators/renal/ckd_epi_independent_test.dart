// Cas de vérification INDÉPENDANTS du code testé (dossier de validation
// FV-PREP-001) : valeurs calculées en Python à partir de l'équation publiée
// CKD-EPI 2021 dont les constantes ont été confrontées à la page de la
// National Kidney Foundation (source secondaire). Le validateur refait ses
// propres calculs depuis la source primaire (Inker 2021, NEJM).
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  // (Scr mg/dL, âge, femme ?, DFG attendu mL/min/1,73 m²)
  const cases = <(double, double, bool, double)>[
    (1.0, 60, true, 64.4950003539451),
    (1.0, 60, false, 86.16262077966914),
    (1.4, 50, true, 45.83344299705897),
    (2.0, 70, false, 35.24299672901596),
    (0.6, 30, true, 123.75786412164246), // Scr < κ (femme)
    (0.9, 40, false, 110.72559960355491), // Scr = κ (homme) : frontière
    (5.0, 80, false, 11.02896461299844),
    (0.5, 25, true, 133.40144188341029), // Scr < κ (femme)
  ];

  for (final (scr, age, female, expected) in cases) {
    test('Scr $scr mg/dL, ${age.toInt()} ans, ${female ? 'femme' : 'homme'} → $expected', () {
      final r = calculateCkdEpiCreatinine2021(
        age: age,
        sex: female ? Sex.female : Sex.male,
        creatinineValue: scr,
        creatinineUnit: 'mg/dL',
        idmsConfirmed: true,
      );
      expect(r.values.first.value, closeTo(expected, expected * 1e-12));
    });
  }

  test('créatinine en µmol/L : 88,42 µmol/L ≈ 1 mg/dL (facteur 88,42 du moteur)', () {
    final r = calculateCkdEpiCreatinine2021(
        age: 60, sex: Sex.female, creatinineValue: 88.42, creatinineUnit: 'µmol/L', idmsConfirmed: true);
    expect(r.values.first.value, closeTo(64.4950003539451, 1e-9));
  });
}
