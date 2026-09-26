import 'package:biosigma_core/src/calculators/hemostasis/caprini_score.dart';
import 'package:biosigma_core/src/models/result.dart';
import 'package:test/test.dart';

void main() {
  group('calculateCapriniScore', () {
    test('aucun facteur coché -> total = 0 (risque très faible)', () {
      final result = calculateCapriniScore();
      expect(result.values.single.value, closeTo(0.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('risque très faible') &&
            w.message.contains('Gould et al. 2012')),
        isTrue,
      );
    });

    test(
        'âge 41-60 (1) + chirurgie mineure prévue (1) -> total = 2 '
        '(risque faible)', () {
      // Arithmétique : age41to60 (1 pt) + minorSurgeryPlanned (1 pt) = 2.
      final result = calculateCapriniScore(
        age41to60: true,
        minorSurgeryPlanned: true,
      );
      expect(result.values.single.value, closeTo(2.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('risque faible') &&
            !w.message.contains('très faible') &&
            !w.message.contains('élevé')),
        isTrue,
      );
    });

    test(
        'âge 61-74 (2) + cancer actuel/antérieur (2) -> total = 4 '
        '(risque modéré)', () {
      // Arithmétique : age61to74 (2 pt) + malignancyCurrentOrPrevious
      // (2 pt) = 4.
      final result = calculateCapriniScore(
        age61to74: true,
        malignancyCurrentOrPrevious: true,
      );
      expect(result.values.single.value, closeTo(4.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info && w.message.contains('risque modéré')),
        isTrue,
      );
    });

    test(
        'antécédent de MTEV (3) + âge 41-60 (1) -> total = 4 '
        '(risque modéré, autre combinaison)', () {
      // Arithmétique : historyOfVte (3 pt) + age41to60 (1 pt) = 4.
      final result = calculateCapriniScore(
        historyOfVte: true,
        age41to60: true,
      );
      expect(result.values.single.value, closeTo(4.0, 1e-9));
    });

    test('AVC < 1 mois (5) seul -> total = 5 (risque élevé)', () {
      // Arithmétique : strokeUnder1Month (5 pt) = 5.
      final result = calculateCapriniScore(strokeUnder1Month: true);
      expect(result.values.single.value, closeTo(5.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('risque élevé') &&
            w.message.contains('Gould et al. 2012')),
        isTrue,
      );
    });

    test(
        'antécédent de MTEV (3) + âge ≥ 75 ans (3) -> total = 6 '
        '(risque élevé, combinaison de facteurs à 3 points)', () {
      // Arithmétique : historyOfVte (3 pt) + age75OrOlder (3 pt) = 6.
      final result = calculateCapriniScore(
        historyOfVte: true,
        age75OrOlder: true,
      );
      expect(result.values.single.value, closeTo(6.0, 1e-9));
    });

    test('score maximal : tous les facteurs cochés -> somme correcte', () {
      // Arithmétique : 17 facteurs à 1 pt (=17) + 8 facteurs à 2 pts (=16)
      // + 10 facteurs à 3 pts (=30) + 5 facteurs à 5 pts (=25)
      // = 17 + 16 + 30 + 25 = 88.
      final result = calculateCapriniScore(
        age41to60: true,
        minorSurgeryPlanned: true,
        priorMajorSurgeryHistory: true,
        varicoseVeins: true,
        inflammatoryBowelDiseaseHistory: true,
        currentSwollenLegs: true,
        obesityBmiOver25: true,
        acuteMyocardialInfarction: true,
        congestiveHeartFailureUnder1Month: true,
        sepsisUnder1Month: true,
        seriousLungDiseaseOrPneumoniaUnder1Month: true,
        abnormalPulmonaryFunction: true,
        oralContraceptiveOrHormoneReplacementTherapy: true,
        pregnancyOrPostpartumUnder1Month: true,
        historyOfUnexplainedStillbirthOrRecurrentMiscarriageOrToxemia: true,
        medicalPatientCurrentlyOnBedRest: true,
        otherRiskFactorNotListed: true,
        age61to74: true,
        arthroscopicSurgery: true,
        malignancyCurrentOrPrevious: true,
        majorOpenSurgeryOver45Minutes: true,
        laparoscopicSurgeryOver45Minutes: true,
        bedConfinementOver72Hours: true,
        immobilizingPlasterCast: true,
        centralVenousAccess: true,
        age75OrOlder: true,
        historyOfVte: true,
        familyHistoryOfVteOrThrombophilia: true,
        factorVLeidenPositive: true,
        prothrombin20210APositive: true,
        elevatedSerumHomocysteine: true,
        lupusAnticoagulantPositive: true,
        elevatedAnticardiolipinAntibodies: true,
        heparinInducedThrombocytopeniaHistory: true,
        otherCongenitalOrAcquiredThrombophilia: true,
        electiveMajorLowerExtremityArthroplasty: true,
        hipPelvisOrLegFractureUnder1Month: true,
        strokeUnder1Month: true,
        multipleTraumaUnder1Month: true,
        acuteSpinalCordInjuryWithParalysisUnder1Month: true,
      );
      expect(result.values.single.value, closeTo(88.0, 1e-9));
    });

    test('chaque facteur individuel contribue son point exact (isolé)', () {
      // Vérifie qu'un échantillon d'une douzaine de facteurs, chacun
      // coché seul (tous les autres à false), produit exactement le
      // total attendu — confirme que chaque poids est câblé correctement.
      final onePointChecks = <String, CalculationResult Function()>{
        'age41to60': () => calculateCapriniScore(age41to60: true),
        'minorSurgeryPlanned': () => calculateCapriniScore(minorSurgeryPlanned: true),
        'varicoseVeins': () => calculateCapriniScore(varicoseVeins: true),
        'obesityBmiOver25': () => calculateCapriniScore(obesityBmiOver25: true),
        'acuteMyocardialInfarction': () =>
            calculateCapriniScore(acuteMyocardialInfarction: true),
      };
      for (final entry in onePointChecks.entries) {
        expect(entry.value().values.single.value, closeTo(1.0, 1e-9),
            reason: '${entry.key} doit valoir 1 point');
      }

      final twoPointChecks = <String, CalculationResult Function()>{
        'age61to74': () => calculateCapriniScore(age61to74: true),
        'arthroscopicSurgery': () => calculateCapriniScore(arthroscopicSurgery: true),
        'malignancyCurrentOrPrevious': () =>
            calculateCapriniScore(malignancyCurrentOrPrevious: true),
        'centralVenousAccess': () => calculateCapriniScore(centralVenousAccess: true),
      };
      for (final entry in twoPointChecks.entries) {
        expect(entry.value().values.single.value, closeTo(2.0, 1e-9),
            reason: '${entry.key} doit valoir 2 points');
      }

      final threePointChecks = <String, CalculationResult Function()>{
        'age75OrOlder': () => calculateCapriniScore(age75OrOlder: true),
        'historyOfVte': () => calculateCapriniScore(historyOfVte: true),
        'factorVLeidenPositive': () => calculateCapriniScore(factorVLeidenPositive: true),
      };
      for (final entry in threePointChecks.entries) {
        expect(entry.value().values.single.value, closeTo(3.0, 1e-9),
            reason: '${entry.key} doit valoir 3 points');
      }

      final fivePointChecks = <String, CalculationResult Function()>{
        'strokeUnder1Month': () => calculateCapriniScore(strokeUnder1Month: true),
        'electiveMajorLowerExtremityArthroplasty': () =>
            calculateCapriniScore(electiveMajorLowerExtremityArthroplasty: true),
      };
      for (final entry in fivePointChecks.entries) {
        expect(entry.value().values.single.value, closeTo(5.0, 1e-9),
            reason: '${entry.key} doit valoir 5 points');
      }
    });

    test('echoedInputs liste les facteurs cochés par catégorie de points', () {
      final result = calculateCapriniScore(
        age41to60: true,
        historyOfVte: true,
      );
      final onePointKey = result.echoedInputs.keys
          .firstWhere((k) => k.startsWith('Facteurs à 1 point'));
      final threePointKey = result.echoedInputs.keys
          .firstWhere((k) => k.startsWith('Facteurs à 3 points'));
      expect(result.echoedInputs[onePointKey], contains('Âge 41-60 ans'));
      expect(
        result.echoedInputs[threePointKey],
        contains('thromboembolique veineuse'),
      );
    });
  });
}
