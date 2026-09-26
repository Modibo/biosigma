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
  final List<QuizQuestion> questions;
}
