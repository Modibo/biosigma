import 'package:biosigma_core/src/calculators/hemostasis/hospitalized_vte_risk_scores.dart';
import 'package:biosigma_core/src/models/result.dart';
import 'package:biosigma_core/src/models/sex.dart';
import 'package:test/test.dart';

void main() {
  group('calculatePaduaPredictionScore', () {
    test('aucun facteur coché, âge 50 ans → score = 0 (risque faible)', () {
      // Calcul indépendant : aucun facteur (âge < 70 ans) → total = 0.
      final result = calculatePaduaPredictionScore(
        ageYears: 50,
        activeCancer: false,
        previousVte: false,
        reducedMobility: false,
        knownThrombophilicCondition: false,
        recentTraumaOrSurgery: false,
        heartOrRespiratoryFailure: false,
        acuteMyocardialInfarctionOrIschemicStroke: false,
        acuteInfectionOrRheumatologicDisorder: false,
        obesityBmiOver30: false,
        ongoingHormonalTreatment: false,
      );
      expect(result.values[0].value, 0.0);
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('Score < 4') &&
            w.message.contains('Barbar et al. 2010')),
        isTrue,
      );
    });

    test('antécédent de MTEV seul, âge 50 ans → score = 3 (juste sous le '
        'seuil, risque faible)', () {
      // Calcul indépendant : previousVte = 3 points ; âge 50 < 70 → 0.
      // Total = 3 < 4 → risque faible (cas limite juste sous le seuil).
      final result = calculatePaduaPredictionScore(
        ageYears: 50,
        activeCancer: false,
        previousVte: true,
        reducedMobility: false,
        knownThrombophilicCondition: false,
        recentTraumaOrSurgery: false,
        heartOrRespiratoryFailure: false,
        acuteMyocardialInfarctionOrIschemicStroke: false,
        acuteInfectionOrRheumatologicDisorder: false,
        obesityBmiOver30: false,
        ongoingHormonalTreatment: false,
      );
      expect(result.values[0].value, 3.0);
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info && w.message.contains('Score < 4')),
        isTrue,
      );
    });

    test('mobilité réduite + insuffisance cardiaque/respiratoire, âge 50 '
        'ans → score = 4 (cas limite au seuil, risque élevé)', () {
      // Calcul indépendant : reducedMobility = 3 ; heartOrRespiratoryFailure
      // = 1 ; âge 50 < 70 → 0. Total = 3 + 1 = 4 → risque élevé (seuil ≥ 4
      // atteint exactement).
      final result = calculatePaduaPredictionScore(
        ageYears: 50,
        activeCancer: false,
        previousVte: false,
        reducedMobility: true,
        knownThrombophilicCondition: false,
        recentTraumaOrSurgery: false,
        heartOrRespiratoryFailure: true,
        acuteMyocardialInfarctionOrIschemicStroke: false,
        acuteInfectionOrRheumatologicDisorder: false,
        obesityBmiOver30: false,
        ongoingHormonalTreatment: false,
      );
      expect(result.values[0].value, 4.0);
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('Score ≥ 4') &&
            w.message.contains('Barbar et al. 2010')),
        isTrue,
      );
    });

    test('antécédent de MTEV + thrombophilie connue + traumatisme/chirurgie '
        'récent(e) + âge 75 ans + obésité → score = 10 (risque élevé)', () {
      // Calcul indépendant : previousVte = 3 ; knownThrombophilicCondition
      // = 3 ; recentTraumaOrSurgery = 2 ; âge 75 ≥ 70 → 1 ;
      // obesityBmiOver30 = 1. Total = 3 + 3 + 2 + 1 + 1 = 10.
      final result = calculatePaduaPredictionScore(
        ageYears: 75,
        activeCancer: false,
        previousVte: true,
        reducedMobility: false,
        knownThrombophilicCondition: true,
        recentTraumaOrSurgery: true,
        heartOrRespiratoryFailure: false,
        acuteMyocardialInfarctionOrIschemicStroke: false,
        acuteInfectionOrRheumatologicDisorder: false,
        obesityBmiOver30: true,
        ongoingHormonalTreatment: false,
      );
      expect(result.values[0].value, 10.0);
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info && w.message.contains('Score ≥ 4')),
        isTrue,
      );
    });

    test('âge hors intervalle adulte (< 18 ans) → erreur de validation', () {
      expect(
        () => calculatePaduaPredictionScore(
          ageYears: 10,
          activeCancer: false,
          previousVte: false,
          reducedMobility: false,
          knownThrombophilicCondition: false,
          recentTraumaOrSurgery: false,
          heartOrRespiratoryFailure: false,
          acuteMyocardialInfarctionOrIschemicStroke: false,
          acuteInfectionOrRheumatologicDisorder: false,
          obesityBmiOver30: false,
          ongoingHormonalTreatment: false,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('calculateImproveBleedingScore', () {
    test('aucun facteur, âge 30 ans, femme, DFG normal → score = 0 (pas de '
        'risque hémorragique accru)', () {
      // Calcul indépendant : âge 30 < 40 → 0 ; sexe féminin → 0 ; DFG 90
      // ≥ 60 → 0 ; plaquettes 250 ≥ 50 → 0 ; INR 1,0 ≤ 1,5 → 0 ; aucun
      // facteur binaire. Total = 0.
      final result = calculateImproveBleedingScore(
        ageYears: 30,
        sex: Sex.female,
        gfrMlMin173m2: 90,
        plateletCountGL: 250,
        inr: 1.0,
        icuOrCcuAdmission: false,
        centralVenousCatheter: false,
        rheumaticDisease: false,
        currentCancer: false,
        activeGastroduodenalUlcer: false,
        bleedingInPrior3Months: false,
      );
      expect(result.values[0].value, closeTo(0.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('Score < 7') &&
            w.message.contains('Decousus et al. 2011')),
        isTrue,
      );
    });

    test('âge ≥ 85 ans, homme, admission en soins intensifs, DFG normal → '
        'score = 7,0 (cas limite au seuil, risque élevé)', () {
      // Calcul indépendant : âge 85 ≥ 85 → 3,5 ; sexe masculin → 1 ; DFG 90
      // ≥ 60 → 0 ; plaquettes 250 ≥ 50 → 0 ; INR 1,0 ≤ 1,5 → 0 ; admission
      // en soins intensifs → 2,5. Total = 3,5 + 1 + 2,5 = 7,0 → seuil
      // atteint exactement (≥ 7 = risque élevé).
      final result = calculateImproveBleedingScore(
        ageYears: 85,
        sex: Sex.male,
        gfrMlMin173m2: 90,
        plateletCountGL: 250,
        inr: 1.0,
        icuOrCcuAdmission: true,
        centralVenousCatheter: false,
        rheumaticDisease: false,
        currentCancer: false,
        activeGastroduodenalUlcer: false,
        bleedingInPrior3Months: false,
      );
      expect(result.values[0].value, closeTo(7.0, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info &&
            w.message.contains('Score ≥ 7') &&
            w.message.contains('Decousus et al. 2011')),
        isTrue,
      );
    });

    test('âge ≥ 85 ans, homme, cathéter veineux central, DFG normal → '
        'score = 6,5 (cas limite juste sous le seuil, risque non accru)',
        () {
      // Calcul indépendant : âge 85 ≥ 85 → 3,5 ; sexe masculin → 1 ; DFG 90
      // ≥ 60 → 0 (pas de majoration) ; plaquettes 250 ≥ 50 → 0 ; INR 1,0 ≤
      // 1,5 → 0 ; cathéter veineux central → 2. Total = 3,5 + 1 + 2 = 6,5
      // < 7 → juste sous le seuil (risque non accru).
      final result = calculateImproveBleedingScore(
        ageYears: 85,
        sex: Sex.male,
        gfrMlMin173m2: 90,
        plateletCountGL: 250,
        inr: 1.0,
        icuOrCcuAdmission: false,
        centralVenousCatheter: true,
        rheumaticDisease: false,
        currentCancer: false,
        activeGastroduodenalUlcer: false,
        bleedingInPrior3Months: false,
      );
      expect(result.values[0].value, closeTo(6.5, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info && w.message.contains('Score < 7')),
        isTrue,
      );
    });

    test('tous les facteurs positifs, âge ≥ 85 ans, homme, DFG < 30, INR '
        '> 1,5, plaquettes < 50 → score = 30,5 (maximum théorique, risque '
        'élevé)', () {
      // Calcul indépendant : âge ≥ 85 → 3,5 ; sexe masculin → 1 ; DFG 20
      // (< 30) → 2,5 (insuffisance rénale sévère) ; INR 2,0 (> 1,5) → 2,5
      // (insuffisance hépatique) ; plaquettes 30 (< 50) → 4 ; soins
      // intensifs → 2,5 ; cathéter veineux central → 2 ; maladie
      // rhumatologique → 2 ; cancer actuel → 2 ; ulcère gastroduodénal
      // actif → 4,5 ; saignement < 3 mois → 4. Total = 3,5 + 1 + 2,5 + 2,5
      // + 4 + 2,5 + 2 + 2 + 2 + 4,5 + 4 = 30,5 (score maximal du modèle).
      final result = calculateImproveBleedingScore(
        ageYears: 90,
        sex: Sex.male,
        gfrMlMin173m2: 20,
        plateletCountGL: 30,
        inr: 2.0,
        icuOrCcuAdmission: true,
        centralVenousCatheter: true,
        rheumaticDisease: true,
        currentCancer: true,
        activeGastroduodenalUlcer: true,
        bleedingInPrior3Months: true,
      );
      expect(result.values[0].value, closeTo(30.5, 1e-9));
      expect(
        result.warnings.any((w) =>
            w.severity == WarningSeverity.info && w.message.contains('Score ≥ 7')),
        isTrue,
      );
    });

    test('INR hors domaine (≤ 0) → erreur de validation', () {
      expect(
        () => calculateImproveBleedingScore(
          ageYears: 60,
          sex: Sex.female,
          gfrMlMin173m2: 90,
          plateletCountGL: 250,
          inr: 0,
          icuOrCcuAdmission: false,
          centralVenousCatheter: false,
          rheumaticDisease: false,
          currentCancer: false,
          activeGastroduodenalUlcer: false,
          bleedingInPrior3Months: false,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
