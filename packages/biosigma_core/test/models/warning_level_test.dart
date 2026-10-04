// P1-16 : niveaux des messages d'information.
import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

CalculationWarning _info(String m) => CalculationWarning(m, severity: WarningSeverity.info);

void main() {
  test('une recommandation publiée est classée « aide à la décision »', () {
    for (final m in [
      'Score CHA₂DS₂-VASc = 4/9. Anticoagulation orale recommandée (recommandation de classe I) : score ≥ 3.',
      'Score ≥ 4 : risque élevé — une thromboprophylaxie pharmacologique est généralement indiquée (ASH 2018).',
      'Score ≥ 5 : une prophylaxie pharmacologique associée à une prophylaxie mécanique est généralement indiquée.',
      'Objectif glycémique habituel selon l\'American Diabetes Association (ADA) : HbA1c < 7 %.',
      'La cible thérapeutique de l\'INR dépend entièrement de l\'indication clinique.',
      'Un score élevé doit inciter à corriger les facteurs de risque hémorragique modifiables.',
    ]) {
      expect(levelOfInfo(_info(m)), ResultLevel.decisionSupport, reason: m);
    }
  });

  test('limites de la méthode : « précisions analytiques »', () {
    for (final m in [
      'Aucun intervalle de référence n\'est comparé : il dépend de l\'âge.',
      'Aucun seuil n\'est appliqué : neutropénie dépend du contexte.',
      'Correction peu pertinente pour une glycémie ≤ 1,00 g/L.',
      'Approximation informative : la clairance mesurée n\'est pas équivalente au DFG.',
      'Il n\'existe pas de seuil universel pour le ratio TCA.',
      'Facteur ajustable F = 5,4 lu dans le tableau.',
      'Modèle dérivé et calibré sur des cohortes européennes.',
    ]) {
      expect(levelOfInfo(_info(m)), ResultLevel.analytical, reason: m);
    }
  });

  test('par défaut : interprétation (jamais une recommandation sans décision explicite)', () {
    expect(levelOfInfo(_info('Stade KDIGO G2 : DFG légèrement diminué.')), ResultLevel.interpretation);
    expect(levelOfInfo(_info('Message inédit quelconque.')), ResultLevel.interpretation);
  });

  test('regroupement : ordre des niveaux, alertes exclues, niveaux vides omis', () {
    final g = groupInfoByLevel([
      _info('Stade KDIGO G2.'),
      const CalculationWarning('Alerte bloquante.', severity: WarningSeverity.blocking),
      _info('Aucun intervalle de référence n\'est comparé.'),
      _info('Anticoagulation orale recommandée (recommandation de classe I).'),
    ]);
    expect(g.keys.toList(), [ResultLevel.analytical, ResultLevel.interpretation, ResultLevel.decisionSupport]);
    expect(g.values.expand((x) => x).length, 3);
    expect(groupInfoByLevel([_info('Stade KDIGO.')]).keys.toList(), [ResultLevel.interpretation]);
    expect(groupInfoByLevel(const []), isEmpty);
  });

  test('chaque niveau a un titre et une phrase d\'accompagnement ; la mention « aucune décision » figure', () {
    for (final l in ResultLevel.values) {
      expect(l.title, isNotEmpty);
      expect(l.caption, isNotEmpty);
    }
    expect(ResultLevel.decisionSupport.caption, contains('ne formule aucune décision'));
  });

  test('le rapport sépare les niveaux (texte et HTML) et nomme les recommandations comme telles', () {
    final r = calculateCha2ds2VascScore(
      congestiveHeartFailureOrLvDysfunction: true, hypertension: true, ageYears: 70,
      diabetesMellitus: false, strokeTiaOrThromboembolismHistory: false, vascularDisease: false, female: true,
    );
    final report = CalculationReport(result: r, appVersion: '1.0', generatedAt: '2026-01-01');
    expect(report.toPlainText(), contains('RECOMMANDATIONS PUBLIÉES (AIDE À LA DÉCISION)'));
    expect(report.toHtml(), contains('<h2>Recommandations publiées (aide à la décision)</h2>'));
  });
}
