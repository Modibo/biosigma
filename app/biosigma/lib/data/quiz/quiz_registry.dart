import '../../models/quiz_question.dart';
import 'quiz_hemostasis.dart';
import 'quiz_ionogram.dart';
import 'quiz_metabolic.dart';
import 'quiz_renal.dart';

/// Les 4 modules de quiz, un par domaine, alignés sur les catégories du
/// catalogue de calculateurs.
final List<QuizModule> allQuizModules = [
  quizRenal,
  quizMetabolic,
  quizIonogram,
  quizHemostasis,
];

QuizModule? findQuizModule(String id) {
  for (final module in allQuizModules) {
    if (module.id == id) return module;
  }
  return null;
}
