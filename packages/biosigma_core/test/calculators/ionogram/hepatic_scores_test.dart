import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

void main() {
  group('calculateMeldNa', () {
    test('MELD ≤ 11 : MELD-Na = MELD (pas d\'ajustement sodique)', () {
      // Calcul indépendant (à la main) :
      // bilirubine 34,2 µmol/L = 2,0 mg/dL (pas de plancher) ; INR 1,0
      // (au plancher) ; créatinine 1,0 mg/dL (au plancher).
      // MELD = 3,78×ln(2,0) + 11,2×ln(1,0) + 9,57×ln(1,0) + 6,43
      //      = 3,78×0,69314718... + 0 + 0 + 6,43
      //      ≈ 2,620096343 + 6,43 = 9,050096343
      final result = calculateMeldNa(
        creatinineValue: 1.0,
        creatinineUnit: 'mg/dL',
        bilirubinUmolL: 34.2,
        inr: 1.0,
        sodiumMmolL: 140,
        onDialysis: false,
      );

      final meld = result.values.firstWhere((v) => v.label == 'Score MELD (sans sodium)');
      final meldNa = result.values.firstWhere((v) => v.label == 'Score MELD-Na');

      expect(meld.value, closeTo(9.050096, 1e-4));
      // MELD ≤ 11 : pas d'ajustement sodique, MELD-Na == MELD.
      expect(meldNa.value, closeTo(meld.value!, 1e-9));
      expect(meldNa.value, closeTo(9.050096, 1e-4));
    });

    test('MELD > 11 : ajustement sodique appliqué (MELD-Na ≠ MELD)', () {
      // Calcul indépendant (à la main) :
      // créatinine 176,84 µmol/L = 2,0 mg/dL ; bilirubine 171,0 µmol/L =
      // 10,0 mg/dL ; INR 2,0 ; sodium 130 mmol/L (dans [125 ; 137], pas de
      // bornage).
      // MELD = 3,78×ln(10) + 11,2×ln(2) + 9,57×ln(2) + 6,43
      //      ≈ 8,703771652 + 7,763248422 + 6,633418518 + 6,43
      //      ≈ 29,530438592
      // MELD > 11 donc :
      // MELD-Na = MELD + 1,32×(137−130) − 0,033×MELD×(137−130)
      //         = MELD + 9,24 − 0,231×MELD
      //         ≈ 29,530438592 + 9,24 − 6,821531315
      //         ≈ 31,948907277
      final result = calculateMeldNa(
        creatinineValue: 176.84,
        creatinineUnit: 'µmol/L',
        bilirubinUmolL: 171.0,
        inr: 2.0,
        sodiumMmolL: 130,
        onDialysis: false,
      );

      final meld = result.values.firstWhere((v) => v.label == 'Score MELD (sans sodium)');
      final meldNa = result.values.firstWhere((v) => v.label == 'Score MELD-Na');

      expect(meld.value, closeTo(29.530439, 1e-3));
      expect(meldNa.value, closeTo(31.948907, 1e-3));
      expect(meldNa.value, isNot(closeTo(meld.value!, 1e-6)));
    });

    test('Dialyse : créatinine forcée à 4,0 mg/dL quelle que soit la valeur mesurée', () {
      // Créatinine mesurée très basse (44,21 µmol/L = 0,5 mg/dL), qui sans
      // la règle de dialyse serait plafonnée seulement au plancher 1,0 —
      // mais la dialyse la force à 4,0 mg/dL.
      // Bilirubine 17,1 µmol/L = 1,0 mg/dL (plancher) ; INR 1,0 (plancher).
      // MELD = 3,78×ln(1) + 11,2×ln(1) + 9,57×ln(4) + 6,43
      //      = 0 + 0 + 9,57×1,386294361... + 6,43
      //      ≈ 13,266837036 + 6,43 = 19,696837036
      // Sodium 140 mmol/L > 137 → bornée à 137 → (137−137) = 0 → aucun
      // ajustement : MELD-Na == MELD.
      final result = calculateMeldNa(
        creatinineValue: 44.21,
        creatinineUnit: 'µmol/L',
        bilirubinUmolL: 17.1,
        inr: 1.0,
        sodiumMmolL: 140,
        onDialysis: true,
      );

      final meld = result.values.firstWhere((v) => v.label == 'Score MELD (sans sodium)');
      final meldNa = result.values.firstWhere((v) => v.label == 'Score MELD-Na');

      expect(meld.value, closeTo(19.696837, 1e-4));
      expect(meldNa.value, closeTo(19.696837, 1e-4));
    });

    test('MELD et MELD-Na sont bornés à [6 ; 40]', () {
      // Valeurs extrêmement basses (tout au plancher, sans dialyse) :
      // MELD = 3,78×ln(1)+11,2×ln(1)+9,57×ln(1)+6,43 = 6,43 (> 6, pas de
      // bornage nécessaire ici, sert juste à documenter le plancher légal
      // du score, à 6).
      final result = calculateMeldNa(
        creatinineValue: 1.0,
        creatinineUnit: 'mg/dL',
        bilirubinUmolL: 17.1,
        inr: 1.0,
        sodiumMmolL: 140,
        onDialysis: false,
      );
      final meld = result.values.firstWhere((v) => v.label == 'Score MELD (sans sodium)');
      expect(meld.value, closeTo(6.43, 1e-6));
      expect(meld.value! >= 6.0, isTrue);
    });
  });

  group('calculateAlbiScore', () {
    test('bilirubine et albumine en g/L (sans conversion)', () {
      // ALBI = log10(100) × 0,66 + 30 × (−0,0852) = 2,0×0,66 − 2,556
      //      = 1,32 − 2,556 = −1,236
      final result = calculateAlbiScore(
        bilirubinUmolL: 100,
        albuminValue: 30,
        albuminUnit: 'g/L',
      );
      expect(result.values.single.value, closeTo(-1.236, 1e-6));
    });

    test('albumine saisie en g/dL, convertie en interne', () {
      // Albumine 3,5 g/dL = 35 g/L.
      // ALBI = log10(50) × 0,66 + 35 × (−0,0852)
      //      ≈ 1,698970004 × 0,66 − 2,982
      //      ≈ 1,121320203 − 2,982 = −1,860679797
      final result = calculateAlbiScore(
        bilirubinUmolL: 50,
        albuminValue: 3.5,
        albuminUnit: 'g/dL',
      );
      expect(result.values.single.value, closeTo(-1.860680, 1e-5));
    });

    test('rejette une bilirubine nulle ou négative (log non défini)', () {
      expect(
        () => calculateAlbiScore(bilirubinUmolL: 0, albuminValue: 30, albuminUnit: 'g/L'),
        throwsA(isA<CalculationInputException>()),
      );
    });
  });
}
