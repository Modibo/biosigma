// Vérifie l'intégrité des données de quiz (aucune vérification de ce type
// n'est possible à la compilation depuis le retrait de l'assert const —
// voir quiz_question.dart) : 4 options par question, index correct dans
// les bornes, identifiants uniques.
import 'package:biosigma/data/quiz/quiz_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chaque module de quiz a un id unique et au moins une question', () {
    final ids = allQuizModules.map((m) => m.id).toSet();
    expect(ids.length, allQuizModules.length, reason: 'ids de module dupliqués');
    for (final module in allQuizModules) {
      expect(module.questions, isNotEmpty, reason: '${module.id} sans question');
    }
  });

  test('chaque question a exactement 4 options et un index correct valide', () {
    final allQuestionIds = <String>{};
    for (final module in allQuizModules) {
      for (final q in module.questions) {
        expect(q.options.length, 4, reason: '${q.id} : ${q.options.length} options au lieu de 4');
        expect(q.correctIndex, inInclusiveRange(0, 3), reason: '${q.id} : correctIndex hors bornes');
        expect(q.prompt.trim(), isNotEmpty, reason: '${q.id} : énoncé vide');
        expect(q.explanation.trim(), isNotEmpty, reason: '${q.id} : explication vide');
        final added = allQuestionIds.add(q.id);
        expect(added, isTrue, reason: 'id de question dupliqué : ${q.id}');
      }
    }
  });
}
