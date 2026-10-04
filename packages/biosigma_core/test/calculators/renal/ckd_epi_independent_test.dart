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
    test(
      'Scr $scr mg/dL, ${age.toInt()} ans, ${female ? 'femme' : 'homme'} → $expected',
      () {
        final r = calculateCkdEpiCreatinine2021(
          age: age,
          sex: female ? Sex.female : Sex.male,
          creatinineValue: scr,
          creatinineUnit: 'mg/dL',
          idmsConfirmed: true,
        );
        expect(r.values.first.value, closeTo(expected, expected * 1e-12));
      },
    );
  }

  test(
    'créatinine en µmol/L : 88,42 µmol/L ≈ 1 mg/dL (facteur 88,42 du moteur)',
    () {
      final r = calculateCkdEpiCreatinine2021(
        age: 60,
        sex: Sex.female,
        creatinineValue: 88.42,
        creatinineUnit: 'µmol/L',
        idmsConfirmed: true,
      );
      expect(r.values.first.value, closeTo(64.4950003539451, 1e-9));
    },
  );

  group('CKD-EPI créatinine-cystatine C 2021 (version 2 : α = −0,219 / −0,144)', () {
    // (Scr mg/dL, Cys mg/L, âge, femme ?, DFG attendu) — Python, constantes de la page NKF
    // de l'équation combinée ; les quatre premiers cas ont Scr < κ (là où α intervient).
    const combined = <(double, double, double, bool, double)>[
      (0.6, 0.9, 60, true, 97.05125281876035),
      (0.8, 0.9, 60, false, 99.1013282100605),
      (0.5, 0.7, 40, false, 131.20247028983707),
      (0.5, 0.6, 30, true, 136.58578729213517),
      (1.4, 1.2, 70, false, 58.905364753919244),
      (1.0, 1.0, 55, true, 72.60375869313832),
      (0.9, 0.8, 45, false, 113.23119036117035),
      (0.7, 0.8, 45, true, 109.04163631780705),
    ];
    for (final (scr, cys, age, female, expected) in combined) {
      test(
        'Scr $scr, Cys $cys, ${age.toInt()} ans, ${female ? 'femme' : 'homme'} → $expected',
        () {
          final r = calculateCkdEpiCreatinineCystatinC2021(
            age: age,
            sex: female ? Sex.female : Sex.male,
            creatinineValue: scr,
            creatinineUnit: 'mg/dL',
            cystatinCValue: cys,
            cystatinCUnit: 'mg/L',
            idmsConfirmed: true,
          );
          expect(r.values.first.value, closeTo(expected, expected * 1e-12));
        },
      );
    }

    test('régression : la version 1 (α de la créatinine seule) donnait 143,97 au lieu de 131,20 (homme, Scr 0,5)', () {
      final r = calculateCkdEpiCreatinineCystatinC2021(
        age: 40,
        sex: Sex.male,
        creatinineValue: 0.5,
        creatinineUnit: 'mg/dL',
        cystatinCValue: 0.7,
        cystatinCUnit: 'mg/L',
        idmsConfirmed: true,
      );
      expect(r.values.first.value, lessThan(135));
      expect(r.values.first.value, isNot(closeTo(143.9710, 0.01)));
    });

    test('l\'équation affichée donne les valeurs de κ et de α', () {
      expect(
        ckdEpiCreatinineCystatinC2021Meta.equation,
        contains('α=-0,219 femme/-0,144 homme'),
      );
    });
  });
}
