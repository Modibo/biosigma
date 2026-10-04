// Cas de vérification INDÉPENDANTS du code testé (dossiers de validation
// FV-PREP-003 à 007) : valeurs calculées en Python à partir des formules
// publiées (constantes confrontées à des sources secondaires), jamais avec le
// code Dart. Le validateur refait ses propres calculs depuis les sources primaires.
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void close(double? actual, double expected, String reason) =>
    expect(actual, closeTo(expected, expected.abs() * 1e-12), reason: reason);

void main() {
  group('FIB-4 = Âge × ASAT / (Plaquettes × √ALAT)', () {
    const cases = <(double, double, double, double, double)>[
      (50, 40, 200, 35, 1.6903085094570331),
      (65, 30, 150, 25, 2.6),
      (35, 25, 250, 20, 0.7826237921249264),
      (70, 80, 100, 40, 8.854377448471462),
      (45, 60, 180, 80, 1.6770509831248424),
    ];
    for (final (age, ast, plt, alt, expected) in cases) {
      test('âge $age, ASAT $ast, plaquettes $plt, ALAT $alt → $expected', () {
        final r = calculateFib4(
          ageYears: age,
          astUL: ast,
          plateletsGL: plt,
          altUL: alt,
        );
        close(r.values.first.value, expected, 'FIB-4');
      });
    }
  });

  group('INR = (TP patient / TP normal)^ISI', () {
    const cases = <(double, double, double, double)>[
      (28, 12, 1.2, 2.7642170559319026),
      (15, 12, 1.0, 1.25),
      (40, 13, 1.5, 5.397280118812488),
      (12, 12, 1.1, 1.0),
      (18, 11.5, 0.95, 1.5305443958532325),
    ];
    for (final (pt, normal, isi, expected) in cases) {
      test('TP $pt s, normal $normal s, ISI $isi → $expected', () {
        final r = calculateInr(
          patientPtSeconds: pt,
          meanNormalPtSeconds: normal,
          isi: isi,
        );
        close(r.values.first.value, expected, 'INR');
      });
    }
  });

  group('TyG = ln(TG mg/dL × glycémie mg/dL / 2)', () {
    const cases = <(double, double, double)>[
      (150, 90, 8.817297783866575),
      (200, 110, 9.305650551780507),
      (90, 85, 8.249313746260636),
      (300, 150, 10.021270588192511),
    ];
    for (final (tg, glucose, expected) in cases) {
      test('TG $tg mg/dL, glycémie $glucose mg/dL → $expected', () {
        final r = calculateTyg(
          triglyceridesValue: tg,
          triglyceridesUnit: 'mg/dL',
          fastingGlucoseValue: glucose,
          fastingGlucoseUnit: 'mg/dL',
          fastingConfirmed: true,
        );
        close(r.values.first.value, expected, 'TyG');
      });
    }
  });

  group('IMC = poids / taille²', () {
    const cases = <(double, double, double)>[
      (70, 175, 22.857142857142858),
      (95, 180, 29.320987654320987),
      (50, 160, 19.531249999999996),
      (120, 170, 41.52249134948097),
      (60, 150, 26.666666666666668),
    ];
    for (final (w, h, expected) in cases) {
      test('$w kg, $h cm → $expected', () {
        final r = calculateBmi(weightKgValue: w, heightCmValue: h);
        close(r.values.first.value, expected, 'IMC');
      });
    }
  });

  group('HOMA-IR = glycémie (mmol/L) × insuline (µU/mL) / 22,5', () {
    const cases = <(double, double, double)>[
      (5.0, 10, 2.2222222222222223),
      (6.5, 20, 5.777777777777778),
      (4.5, 5, 1.0),
      (7.8, 30, 10.4),
    ];
    for (final (g, i, expected) in cases) {
      test('glycémie $g mmol/L, insuline $i µU/mL → $expected', () {
        final r = calculateHomaIr(
          fastingInsulinValue: i,
          fastingInsulinUnit: 'µU/mL',
          fastingGlucoseValue: g,
          fastingGlucoseUnit: 'mmol/L',
          fastingConfirmed: true,
        );
        close(r.values.first.value, expected, 'HOMA-IR');
      });
    }
  });
}
