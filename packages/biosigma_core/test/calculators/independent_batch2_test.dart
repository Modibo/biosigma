// Cas de vérification INDÉPENDANTS du code testé (dossiers FV-PREP-008 à 014) :
// valeurs calculées en Python à partir des formules publiées dont les constantes
// ont été confrontées à des sources secondaires (NKF, Wikipédia).
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void close(double? actual, double expected, String reason) =>
    expect(actual, closeTo(expected, expected.abs() * 1e-12), reason: reason);

void main() {
  group('CKD-EPI cystatine C 2012', () {
    const cases = <(double, double, bool, double)>[
      (1.0, 60, true, 72.4655114056525),
      (0.8, 50, false, 108.84752593992127),
      (0.6, 30, true, 126.87969780594287),
      (1.5, 75, false, 42.73230637286376),
    ];
    for (final (cys, age, female, expected) in cases) {
      test(
        'Cys $cys mg/L, ${age.toInt()} ans, ${female ? 'femme' : 'homme'} → $expected',
        () {
          final r = calculateCkdEpiCystatinC2012(
            age: age,
            sex: female ? Sex.female : Sex.male,
            cystatinCValue: cys,
            cystatinCUnit: 'mg/L',
          );
          close(r.values.first.value, expected, 'DFG cystatine');
        },
      );
    }
  });

  group('Schwartz bedside : 0,413 × taille / créatinine', () {
    const cases = <(double, double, double, double)>[
      (8, 125, 0.5, 103.25),
      (14, 160, 0.8, 82.6),
      (3, 95, 0.4, 98.08749999999999),
    ];
    for (final (age, h, scr, expected) in cases) {
      test('${age.toInt()} ans, $h cm, $scr mg/dL → $expected', () {
        final r = calculateSchwartzBedside(
          ageYears: age,
          heightCm: h,
          creatinineValue: scr,
          creatinineUnit: 'mg/dL',
        );
        close(r.values.first.value, expected, 'Schwartz');
      });
    }
  });

  group('MELD et MELD-Na (UNOS) : (créat. mg/dL, bilirubine µmol/L, INR, Na, dialyse)', () {
    const cases = <(double, double, double, double, bool, double, double)>[
      (1.2, 51.3, 1.5, 130, false, 16.86878096049504, 22.212092558620686),
      (
        0.8,
        17.1,
        1.0,
        140,
        false,
        6.43,
        6.43,
      ), // planchers : MELD brut 6,43, ≤ 11 donc MELD-Na = MELD
      (
        2.5,
        171,
        2.0,
        120,
        false,
        31.665922377824543,
        34.966217116206025,
      ), // Na 120 borné à 125
      (
        1.0,
        34.2,
        1.3,
        135,
        true,
        25.255413140469848,
        26.22855587319884,
      ), // dialyse : créatinine forcée à 4,0
      (3.0, 256.5, 2.5, 128, false, 37.4426055597107, 38.20215170847662),
    ];
    for (final (cr, bili, inr, na, dialysis, meld, meldNa) in cases) {
      test(
        'créat. $cr, bili. $bili µmol/L, INR $inr, Na $na, dialyse $dialysis → MELD $meld / MELD-Na $meldNa',
        () {
          final r = calculateMeldNa(
            creatinineValue: cr,
            creatinineUnit: 'mg/dL',
            bilirubinUmolL: bili,
            inr: inr,
            sodiumMmolL: na,
            onDialysis: dialysis,
          );
          close(r.values[0].value, meld, 'MELD');
          close(r.values[1].value, meldNa, 'MELD-Na');
        },
      );
    }
  });

  group('QUICKI = 1 / (log10 insuline µU/mL + log10 glycémie mg/dL)', () {
    const cases = <(double, double, double)>[
      (15, 90, 0.3194547527373662),
      (10, 85, 0.34136462737440865),
      (20, 100, 0.3029357507546236),
      (5, 70, 0.3930712475323701),
    ];
    for (final (ins, g, expected) in cases) {
      test('insuline $ins µU/mL, glycémie $g mg/dL → $expected', () {
        final r = calculateQuicki(
          fastingInsulinValue: ins,
          fastingInsulinUnit: 'µU/mL',
          fastingGlucoseValue: g,
          fastingGlucoseUnit: 'mg/dL',
          fastingConfirmed: true,
        );
        close(r.values.first.value, expected, 'QUICKI');
      });
    }
  });

  // Vérification exhaustive des barèmes de points, avec un barème réécrit ici
  // directement à partir des tableaux publiés (sources secondaires consultées
  // le 2026-10-04 : Wikipédia CHA₂DS₂-VASc et HAS-BLED).
  test('CHA₂DS₂-VASc : les 192 combinaisons (6 critères binaires × 3 tranches d\'âge)', () {
    var checked = 0;
    for (var mask = 0; mask < 64; mask++) {
      final chf = mask & 1 != 0, htn = mask & 2 != 0, dm = mask & 4 != 0;
      final stroke = mask & 8 != 0,
          vascular = mask & 16 != 0,
          female = mask & 32 != 0;
      for (final age in [50.0, 66.0, 76.0]) {
        final expected =
            (chf ? 1 : 0) +
            (htn ? 1 : 0) +
            (dm ? 1 : 0) +
            (stroke ? 2 : 0) +
            (vascular ? 1 : 0) +
            (female ? 1 : 0) +
            (age >= 75 ? 2 : (age >= 65 ? 1 : 0));
        final r = calculateCha2ds2VascScore(
          congestiveHeartFailureOrLvDysfunction: chf,
          hypertension: htn,
          ageYears: age,
          diabetesMellitus: dm,
          strokeTiaOrThromboembolismHistory: stroke,
          vascularDisease: vascular,
          female: female,
        );
        expect(
          r.values.first.value,
          expected.toDouble(),
          reason: 'mask $mask âge $age',
        );
        checked++;
      }
    }
    expect(checked, 192);
  });

  test('HAS-BLED : les 512 combinaisons (9 critères, âge ≤ 65 / > 65)', () {
    var checked = 0;
    for (var mask = 0; mask < 256; mask++) {
      bool bit(int i) => mask & (1 << i) != 0;
      for (final age in [60.0, 66.0]) {
        final expected =
            [for (var i = 0; i < 8; i++) bit(i)].where((b) => b).length +
            (age > 65 ? 1 : 0);
        final r = calculateHasBledScore(
          hypertensionUncontrolled: bit(0),
          abnormalRenalFunction: bit(1),
          abnormalLiverFunction: bit(2),
          strokeHistory: bit(3),
          bleedingHistoryOrPredisposition: bit(4),
          labileInr: bit(5),
          ageYears: age,
          antiplateletOrNsaidUse: bit(6),
          alcoholExcess: bit(7),
        );
        expect(
          r.values.first.value,
          expected.toDouble(),
          reason: 'mask $mask âge $age',
        );
        checked++;
      }
    }
    expect(checked, 512);
  });
}
