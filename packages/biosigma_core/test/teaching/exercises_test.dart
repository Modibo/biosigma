// P5-05 : exercices générés. Le corrigé (calculé par le moteur) est recomputé ici
// à partir des données structurées de l'énoncé, avec des formules réécrites à part.
import 'dart:math' as math;

import 'package:biosigma_core/biosigma_core.dart';
import 'package:test/test.dart';

double _ckdEpi2021(double age, double scr, bool female) {
  final kappa = female ? 0.7 : 0.9, alpha = female ? -0.241 : -0.302;
  return 142 *
      math.pow(math.min(scr / kappa, 1), alpha) *
      math.pow(math.max(scr / kappa, 1), -1.2) *
      math.pow(0.9938, age) *
      (female ? 1.012 : 1);
}

double _independent(Exercise e) {
  final i = e.inputs;
  switch (e.kindId) {
    case 'bmi':
      return (i['poids_kg'] as int) / math.pow((i['taille_cm'] as int) / 100, 2);
    case 'homa_ir':
      return (i['glycemie_mmolL'] as double) * (i['insuline_uUmL'] as double) / 22.5;
    case 'quicki':
      return 1 / (math.log(i['insuline_uUmL'] as double) / math.ln10 + math.log((i['glycemie_mgdL'] as int).toDouble()) / math.ln10);
    case 'tyg':
      return math.log((i['tg_mgdL'] as int) * (i['glycemie_mgdL'] as int) / 2);
    case 'fib4':
      return (i['age'] as int) * (i['ast'] as int) / ((i['plaquettes'] as int) * math.sqrt((i['alt'] as int).toDouble()));
    case 'inr':
      return math.pow((i['tp_patient'] as double) / (i['tp_normal'] as double), i['isi'] as double).toDouble();
    case 'ckd_epi_2021':
      return _ckdEpi2021((i['age'] as int).toDouble(), i['creatinine_mgdL'] as double, i['femme'] as bool);
    case 'anion_gap':
      return ((i['na'] as int) - (i['cl'] as int) - (i['hco3'] as int)).toDouble();
    case 'creatinine_conversion':
      return (i['creatinine_mgdL'] as double) * 10 / 113.12 * 1000;
    case 'dilution_v1':
      return (i['c2'] as int) * (i['v2'] as int) / (i['c1'] as int);
  }
  throw StateError('type non couvert : ${e.kindId}');
}

void main() {
  test('chaque type a un corrigé égal au recalcul indépendant, sur 200 numéros', () {
    for (final kind in ExerciseGenerator.kinds) {
      for (var seed = 1; seed <= 200; seed++) {
        final e = ExerciseGenerator.generate(kind.id, seed);
        expect(e.expected, closeTo(_independent(e), _independent(e).abs() * 1e-9 + 1e-9),
            reason: '${kind.id} #$seed ${e.inputs}');
      }
    }
  });

  test('déterminisme : même numéro → même exercice ; numéros différents → exercices variés', () {
    for (final kind in ExerciseGenerator.kinds) {
      final a = ExerciseGenerator.generate(kind.id, 42), b = ExerciseGenerator.generate(kind.id, 42);
      expect(a.statement, b.statement);
      expect(a.expected, b.expected);
      final distinct = {for (var s = 1; s <= 30; s++) ExerciseGenerator.generate(kind.id, s).statement};
      expect(distinct.length, greaterThan(10), reason: kind.id);
    }
  });

  test('l\'énoncé contient toutes les données numériques ; la solution est non vide', () {
    for (final kind in ExerciseGenerator.kinds) {
      final e = ExerciseGenerator.generate(kind.id, 7);
      expect(e.statement, isNotEmpty);
      expect(e.solution.length, greaterThanOrEqualTo(2));
      expect(e.answerLabel, isNotEmpty);
    }
    final bmi = ExerciseGenerator.generate('bmi', 7);
    expect(bmi.statement, contains('${bmi.inputs['poids_kg']} kg'));
    expect(bmi.statement, contains('${bmi.inputs['taille_cm']} cm'));
  });

  test('chaque exercice porte le statut du registre ; aucune équation n\'est validée : mention d\'entraînement', () {
    for (final kind in ExerciseGenerator.kinds) {
      final e = ExerciseGenerator.generate(kind.id, 3);
      expect(EquationRegistry.resolve(e.equationId), isNotNull, reason: '${kind.id} → ${e.equationId}');
      expect(e.statusLabel, 'NON VALIDÉ');
      expect(e.banner, contains('entraînement'));
      expect(e.banner, contains('Cas fictif'));
    }
  });

  group('vérification d\'une réponse', () {
    final e = ExerciseGenerator.generate('anion_gap', 5); // décimales : 0
    test('le corrigé arrondi est correct ; à une demi-unité près seulement', () {
      expect(e.check(e.expectedRounded).correct, isTrue);
      expect(e.check(e.expected + 0.49).correct, isTrue);
      expect(e.check(e.expected + 0.51).correct, isFalse);
      expect(e.check(e.expected - 1).correct, isFalse);
    });
    test('réponse absente ou non finie : refusée avec consigne', () {
      expect(e.check(null).correct, isFalse);
      expect(e.check(double.nan).message, contains('nombre'));
    });
    test('trois décimales (QUICKI) : tolérance 0,0005', () {
      final q = ExerciseGenerator.generate('quicki', 5);
      expect(q.decimals, 3);
      expect(q.check(q.expectedRounded).correct, isTrue);
      expect(q.check(q.expected + 0.0006).correct, isFalse);
    });
  });

  test('type inconnu : erreur explicite', () {
    expect(() => ExerciseGenerator.generate('nope', 1), throwsArgumentError);
  });

  test('plages : les entrées générées restent dans les bornes acceptées par les calculateurs', () {
    for (final kind in ExerciseGenerator.kinds) {
      for (var seed = 1; seed <= 500; seed++) {
        expect(() => ExerciseGenerator.generate(kind.id, seed), returnsNormally, reason: '${kind.id} #$seed');
      }
    }
  });
}
