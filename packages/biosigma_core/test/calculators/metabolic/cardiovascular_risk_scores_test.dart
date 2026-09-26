import 'package:biosigma_core/src/calculators/metabolic/cardiovascular_risk_scores.dart';
import 'package:biosigma_core/src/models/errors.dart';
import 'package:biosigma_core/src/models/sex.dart';
import 'package:test/test.dart';

void main() {
  group('calculateFraminghamRiskScore', () {
    test('homme 55 ans, cas complet calculé point par point', () {
      // Barème (Wilson et al. 1998, hommes) :
      //   Âge 55 ans -> tranche 55-59        -> 8 points
      //   Cholestérol total 250 mg/dL, tranche d'âge 50-59, bande 240-279
      //       -> ligne [0,2,3,4,5] index 3    -> 4 points
      //   Non-fumeur                          -> 0 point
      //   HDL 45 mg/dL (bande 40-49)          -> 1 point
      //   PA systolique 125 mmHg non traitée, bande 120-129
      //       -> ligne [0,0,1,1,2] index 1    -> 0 point
      //   Total = 8 + 4 + 0 + 1 + 0 = 13 points
      //   Table hommes : 13 points -> 12 %
      final result = calculateFraminghamRiskScore(
        age: 55,
        sex: Sex.male,
        totalCholesterolValue: 250,
        totalCholesterolUnit: 'mg/dL',
        hdlValue: 45,
        hdlUnit: 'mg/dL',
        systolicBloodPressure: 125,
        treatedHypertension: false,
        currentSmoker: false,
      );
      expect(result.values[0].value, closeTo(13, 1e-9));
      expect(result.values[1].value, closeTo(12, 1e-9));
    });

    test('femme 60 ans, cas complet calculé point par point', () {
      // Barème (Wilson et al. 1998, femmes) :
      //   Âge 60 ans -> tranche 60-64          -> 10 points
      //   Cholestérol total 220 mg/dL, tranche d'âge 60-69, bande 200-239
      //       -> ligne [0,1,2,3,4] index 2      -> 2 points
      //   Fumeuse active, tranche d'âge 60-69   -> 2 points
      //   HDL 55 mg/dL (bande 50-59)            -> 0 point
      //   PA systolique 150 mmHg traitée, bande 140-159
      //       -> ligne [0,3,4,5,6] index 3       -> 5 points
      //   Total = 10 + 2 + 2 + 0 + 5 = 19 points
      //   Table femmes : 19 points -> 8 %
      final result = calculateFraminghamRiskScore(
        age: 60,
        sex: Sex.female,
        totalCholesterolValue: 220,
        totalCholesterolUnit: 'mg/dL',
        hdlValue: 55,
        hdlUnit: 'mg/dL',
        systolicBloodPressure: 150,
        treatedHypertension: true,
        currentSmoker: true,
      );
      expect(result.values[0].value, closeTo(19, 1e-9));
      expect(result.values[1].value, closeTo(8, 1e-9));
    });

    test('femme 45 ans, PA systolique exactement à la borne de bande 140 mmHg', () {
      // Vérifie que 140 mmHg est bien classé dans la bande 140-159 (et non
      // 130-139, dont les points diffèrent chez la femme : 2 vs 3 non
      // traitée) — un test de non-régression sur la borne d'intervalle.
      //   Âge 45 ans -> tranche 45-49            -> 3 points
      //   Cholestérol total 170 mg/dL, tranche d'âge 40-49, bande 160-199
      //       -> ligne [0,3,6,8,10] index 1        -> 3 points
      //   Non-fumeuse                             -> 0 point
      //   HDL 55 mg/dL (bande 50-59)               -> 0 point
      //   PA systolique 140 mmHg non traitée, bande 140-159 (PAS 130-139)
      //       -> ligne [0,1,2,3,4] index 3          -> 3 points
      //   Total = 3 + 3 + 0 + 0 + 3 = 9 points
      //   Table femmes : 9 points -> 1 % (borne basse exacte de la table,
      //   juste au-dessus du seuil "< 1 %" qui s'applique pour < 9 points)
      final result = calculateFraminghamRiskScore(
        age: 45,
        sex: Sex.female,
        totalCholesterolValue: 170,
        totalCholesterolUnit: 'mg/dL',
        hdlValue: 55,
        hdlUnit: 'mg/dL',
        systolicBloodPressure: 140,
        treatedHypertension: false,
        currentSmoker: false,
      );
      expect(result.values[0].value, closeTo(9, 1e-9));
      expect(result.values[1].value, closeTo(1, 1e-9));
    });

    test('âge en dessous du domaine de validité (< 30 ans) lève une exception', () {
      expect(
        () => calculateFraminghamRiskScore(
          age: 29,
          sex: Sex.male,
          totalCholesterolValue: 200,
          totalCholesterolUnit: 'mg/dL',
          hdlValue: 50,
          hdlUnit: 'mg/dL',
          systolicBloodPressure: 120,
          treatedHypertension: false,
          currentSmoker: false,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('âge au-dessus du domaine de validité (> 74 ans) lève une exception', () {
      expect(
        () => calculateFraminghamRiskScore(
          age: 75,
          sex: Sex.female,
          totalCholesterolValue: 200,
          totalCholesterolUnit: 'mg/dL',
          hdlValue: 50,
          hdlUnit: 'mg/dL',
          systolicBloodPressure: 120,
          treatedHypertension: false,
          currentSmoker: false,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('total de points extrême (bas) donne la bande ouverte "< 1 %"', () {
      // Homme 30 ans (âge -9 pts, borne basse du domaine 30-74),
      // cholestérol < 160 mg/dL (0 pt), non-fumeur (0 pt), HDL >= 60 (-1 pt),
      // PA systolique < 120 non traitée (0 pt) -> total = -9 + 0 + 0 - 1 + 0 = -10
      // -10 < 0 -> bande "< 1 %", valeur affichée = borne 1.
      final result = calculateFraminghamRiskScore(
        age: 30,
        sex: Sex.male,
        totalCholesterolValue: 150,
        totalCholesterolUnit: 'mg/dL',
        hdlValue: 65,
        hdlUnit: 'mg/dL',
        systolicBloodPressure: 110,
        treatedHypertension: false,
        currentSmoker: false,
      );
      expect(result.values[0].value, closeTo(-10, 1e-9));
      expect(result.values[1].value, closeTo(1, 1e-9));
      expect(result.values[1].label, contains('<'));
    });

    test('total de points extrême (haut) donne la bande ouverte "≥ 30 %"', () {
      // Femme 74 ans -> tranche 70-74 (14 pts, PAS 75-79/16 pts, hors
      // domaine validé de toute façon), cholestérol >= 280 mg/dL tranche
      // 70-79 -> ligne [0,1,1,2,2] index 4 (2 pts), fumeuse tranche 70-79
      // -> 1 pt, HDL < 40 -> 2 pts, PA systolique >= 160 traitée ->
      // ligne [0,3,4,5,6] index 4 (6 pts).
      // Total = 14 + 2 + 1 + 2 + 6 = 25 -> table femmes : 25 >= 25 ->
      // bande "≥ 30 %".
      final result = calculateFraminghamRiskScore(
        age: 74,
        sex: Sex.female,
        totalCholesterolValue: 300,
        totalCholesterolUnit: 'mg/dL',
        hdlValue: 35,
        hdlUnit: 'mg/dL',
        systolicBloodPressure: 170,
        treatedHypertension: true,
        currentSmoker: true,
      );
      expect(result.values[0].value, closeTo(25, 1e-9));
      expect(result.values[1].value, closeTo(30, 1e-9));
      expect(result.values[1].label, contains('≥'));
    });
  });
}
