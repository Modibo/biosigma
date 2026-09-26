import 'dart:math';

import 'package:biosigma_core/biosigma_core.dart';

/// Nature d'une question de quiz.
enum QuizQuestionType {
  /// Culture scientifique : source, auteur, année de la publication d'origine.
  scientificSource('Culture scientifique'),

  /// Cas clinique conceptuel : reconnaître quand/pourquoi un outil s'applique
  /// ou ne s'applique pas — jamais un seuil numérique présenté comme une
  /// vérité universelle (cohérent avec le moteur de calcul).
  clinicalCase('Cas clinique'),

  /// Définition d'un acronyme ou d'un terme technique.
  vocabulary('Vocabulaire');

  const QuizQuestionType(this.label);
  final String label;
}

/// Question à choix unique parmi 4 options.
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final QuizQuestionType type;
  final String prompt;
  final List<String> options;
  final int correctIndex;

  /// Affichée après la réponse, qu'elle soit correcte ou non — jamais un
  /// verdict clinique définitif, toujours un rappel pédagogique.
  final String explanation;
}

/// Un module de quiz, aligné sur une catégorie du catalogue de calculateurs.
class QuizModule {
  const QuizModule({
    required this.id,
    required this.title,
    required this.category,
    required this.questions,
  });

  final String id;
  final String title;
  final CalculatorCategory category;

  /// Banque complète de questions du domaine (pas une série figée) : une
  /// évaluation en tire un échantillon aléatoire via [sampleSession].
  final List<QuizQuestion> questions;

  /// Nombre de questions dans la banque de ce domaine.
  int get poolSize => questions.length;

  /// Tire un échantillon aléatoire, sans répétition, d'au plus
  /// [sessionSize] questions (par défaut 20 — une « série » d'évaluation).
  /// Si la banque contient moins de questions que [sessionSize], la banque
  /// entière est renvoyée, mélangée.
  List<QuizQuestion> sampleSession({int sessionSize = 20, Random? random}) {
    final shuffled = List<QuizQuestion>.from(questions)..shuffle(random ?? Random());
    final count = sessionSize < shuffled.length ? sessionSize : shuffled.length;
    return shuffled.sublist(0, count);
  }
}
