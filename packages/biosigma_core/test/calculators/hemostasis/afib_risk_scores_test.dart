import 'package:biosigma_core/src/calculators/hemostasis/afib_risk_scores.dart';
import 'package:biosigma_core/src/models/errors.dart';
import 'package:biosigma_core/src/models/result.dart';
import 'package:test/test.dart';

void main() {
  group('calculateHasBledScore', () {
    // Barème (Pisters et al. 2010) : 1 point chacun pour hypertension non
    // contrôlée, fonction rénale anormale, fonction hépatique anormale,
    // AVC, hémorragie/prédisposition, INR labile, âge > 65 ans,
    // médicaments (antiagrégants/AINS), alcool excessif. Max 9.
    test('aucun critère, âge 50 ans : total = 0 -> risque faible', () {
      // 0 (HTA) + 0 (rénal) + 0 (hépatique) + 0 (AVC) + 0 (hémorragie) +
      // 0 (INR labile) + 0 (âge 50 <= 65) + 0 (médicaments) + 0 (alcool) = 0
      final result = calculateHasBledScore(
        hypertensionUncontrolled: false,
        abnormalRenalFunction: false,
        abnormalLiverFunction: false,
        strokeHistory: false,
        bleedingHistoryOrPredisposition: false,
        labileInr: false,
        ageYears: 50,
        antiplateletOrNsaidUse: false,
        alcoholExcess: false,
      );
      expect(result.values.single.value, closeTo(0.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('risque hémorragique faible')),
        isTrue,
      );
    });

    test('trois critères + âge > 65 : total = 3 -> risque élevé', () {
      // 1 (HTA) + 1 (rénal) + 0 (hépatique) + 0 (AVC) + 0 (hémorragie) +
      // 0 (INR labile) + 1 (âge 70 > 65) + 0 (médicaments) + 0 (alcool) = 3
      final result = calculateHasBledScore(
        hypertensionUncontrolled: true,
        abnormalRenalFunction: true,
        abnormalLiverFunction: false,
        strokeHistory: false,
        bleedingHistoryOrPredisposition: false,
        labileInr: false,
        ageYears: 70,
        antiplateletOrNsaidUse: false,
        alcoholExcess: false,
      );
      expect(result.values.single.value, closeTo(3.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('risque hémorragique élevé')),
        isTrue,
      );
    });

    test('deux critères, âge 60 ans : total = 2 -> risque modéré', () {
      // 1 (hépatique) + 1 (hémorragie) + 0 (âge 60 <= 65) + 0 (reste) = 2
      final result = calculateHasBledScore(
        hypertensionUncontrolled: false,
        abnormalRenalFunction: false,
        abnormalLiverFunction: true,
        strokeHistory: false,
        bleedingHistoryOrPredisposition: true,
        labileInr: false,
        ageYears: 60,
        antiplateletOrNsaidUse: false,
        alcoholExcess: false,
      );
      expect(result.values.single.value, closeTo(2.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('risque hémorragique modéré')),
        isTrue,
      );
    });

    test('tous les critères, âge 80 ans : total = 9 (maximum)', () {
      // 1+1+1+1+1+1 (âge 80 > 65) +1+1+1 = 9
      final result = calculateHasBledScore(
        hypertensionUncontrolled: true,
        abnormalRenalFunction: true,
        abnormalLiverFunction: true,
        strokeHistory: true,
        bleedingHistoryOrPredisposition: true,
        labileInr: true,
        ageYears: 80,
        antiplateletOrNsaidUse: true,
        alcoholExcess: true,
      );
      expect(result.values.single.value, closeTo(9.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('risque hémorragique élevé')),
        isTrue,
      );
    });

    test('âge implausible (12 ans) -> exception de validation', () {
      expect(
        () => calculateHasBledScore(
          hypertensionUncontrolled: false,
          abnormalRenalFunction: false,
          abnormalLiverFunction: false,
          strokeHistory: false,
          bleedingHistoryOrPredisposition: false,
          labileInr: false,
          ageYears: 12,
          antiplateletOrNsaidUse: false,
          alcoholExcess: false,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('âge exactement 65 ans -> pas de point "Elderly" (critère > 65)', () {
      final result = calculateHasBledScore(
        hypertensionUncontrolled: false,
        abnormalRenalFunction: false,
        abnormalLiverFunction: false,
        strokeHistory: false,
        bleedingHistoryOrPredisposition: false,
        labileInr: false,
        ageYears: 65,
        antiplateletOrNsaidUse: false,
        alcoholExcess: false,
      );
      expect(result.values.single.value, closeTo(0.0, 1e-9));
    });
  });

  group('calculateCha2ds2VascScore', () {
    // Barème (Lip et al. 2010) : insuffisance cardiaque/dysfonction VG = 1,
    // HTA = 1, âge 65-74 = 1 / âge >= 75 = 2, diabète = 1,
    // AVC/AIT/embolie = 2, maladie vasculaire = 1, sexe féminin = 1. Max 9.
    test('homme, aucun critère, âge 50 : total = 0 -> risque faible, pas d\'anticoagulation', () {
      // 0 (IC) + 0 (HTA) + 0 (âge 50) + 0 (diabète) + 0 (AVC) + 0 (vasc) + 0 (sexe) = 0
      final result = calculateCha2ds2VascScore(
        congestiveHeartFailureOrLvDysfunction: false,
        hypertension: false,
        ageYears: 50,
        diabetesMellitus: false,
        strokeTiaOrThromboembolismHistory: false,
        vascularDisease: false,
        female: false,
      );
      expect(result.values.single.value, closeTo(0.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('non recommandée sur la seule base')),
        isTrue,
      );
    });

    test('homme, HTA + diabète, âge 68 : total = 3 -> anticoagulation recommandée', () {
      // 0 (IC) + 1 (HTA) + 1 (âge 68 -> 65-74) + 1 (diabète) + 0 (AVC) + 0 (vasc) + 0 (sexe) = 3
      final result = calculateCha2ds2VascScore(
        congestiveHeartFailureOrLvDysfunction: false,
        hypertension: true,
        ageYears: 68,
        diabetesMellitus: true,
        strokeTiaOrThromboembolismHistory: false,
        vascularDisease: false,
        female: false,
      );
      expect(result.values.single.value, closeTo(3.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('recommandation de classe I') &&
            w.message.contains('score ≥ 2 chez un homme')),
        isTrue,
      );
    });

    test('femme, aucun autre facteur, âge 50 : total = 1 (sexe seul) -> risque faible', () {
      // 0 (IC) + 0 (HTA) + 0 (âge) + 0 (diabète) + 0 (AVC) + 0 (vasc) + 1 (sexe) = 1
      final result = calculateCha2ds2VascScore(
        congestiveHeartFailureOrLvDysfunction: false,
        hypertension: false,
        ageYears: 50,
        diabetesMellitus: false,
        strokeTiaOrThromboembolismHistory: false,
        vascularDisease: false,
        female: true,
      );
      expect(result.values.single.value, closeTo(1.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('ne justifie pas, à lui seul, une anticoagulation')),
        isTrue,
      );
    });

    test('femme, AVC antérieur, âge >= 75 : total = 5 -> anticoagulation recommandée', () {
      // 0 (IC) + 0 (HTA) + 2 (âge 76 -> >=75) + 0 (diabète) + 2 (AVC) + 0 (vasc) + 1 (sexe) = 5
      final result = calculateCha2ds2VascScore(
        congestiveHeartFailureOrLvDysfunction: false,
        hypertension: false,
        ageYears: 76,
        diabetesMellitus: false,
        strokeTiaOrThromboembolismHistory: true,
        vascularDisease: false,
        female: true,
      );
      expect(result.values.single.value, closeTo(5.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('recommandation de classe I') &&
            w.message.contains('score ≥ 3 chez une femme')),
        isTrue,
      );
    });

    test('femme, un seul facteur (HTA) en plus du sexe : total = 2 -> à envisager', () {
      // 0 (IC) + 1 (HTA) + 0 (âge 50) + 0 (diabète) + 0 (AVC) + 0 (vasc) + 1 (sexe) = 2
      final result = calculateCha2ds2VascScore(
        congestiveHeartFailureOrLvDysfunction: false,
        hypertension: true,
        ageYears: 50,
        diabetesMellitus: false,
        strokeTiaOrThromboembolismHistory: false,
        vascularDisease: false,
        female: true,
      );
      expect(result.values.single.value, closeTo(2.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('recommandation de classe IIa') &&
            w.message.contains('score de 2 chez une femme')),
        isTrue,
      );
    });

    test('tous les critères, femme, âge >= 75 : total = 9 (maximum)', () {
      // 1 (IC) + 1 (HTA) + 2 (âge) + 1 (diabète) + 2 (AVC) + 1 (vasc) + 1 (sexe) = 9
      final result = calculateCha2ds2VascScore(
        congestiveHeartFailureOrLvDysfunction: true,
        hypertension: true,
        ageYears: 80,
        diabetesMellitus: true,
        strokeTiaOrThromboembolismHistory: true,
        vascularDisease: true,
        female: true,
      );
      expect(result.values.single.value, closeTo(9.0, 1e-9));
    });

    test('âge implausible (10 ans) -> exception de validation', () {
      expect(
        () => calculateCha2ds2VascScore(
          congestiveHeartFailureOrLvDysfunction: false,
          hypertension: false,
          ageYears: 10,
          diabetesMellitus: false,
          strokeTiaOrThromboembolismHistory: false,
          vascularDisease: false,
          female: false,
        ),
        throwsA(isA<CalculationInputException>()),
      );
    });

    test('homme, âge exactement 65 : 1 point d\'âge (bande 65-74)', () {
      final result = calculateCha2ds2VascScore(
        congestiveHeartFailureOrLvDysfunction: false,
        hypertension: false,
        ageYears: 65,
        diabetesMellitus: false,
        strokeTiaOrThromboembolismHistory: false,
        vascularDisease: false,
        female: false,
      );
      expect(result.values.single.value, closeTo(1.0, 1e-9));
    });

    test('homme, âge exactement 75 : 2 points d\'âge (bande >= 75)', () {
      final result = calculateCha2ds2VascScore(
        congestiveHeartFailureOrLvDysfunction: false,
        hypertension: false,
        ageYears: 75,
        diabetesMellitus: false,
        strokeTiaOrThromboembolismHistory: false,
        vascularDisease: false,
        female: false,
      );
      expect(result.values.single.value, closeTo(2.0, 1e-9));
    });
  });
}
