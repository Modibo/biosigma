/// Résultat d'une tentative de quiz, entièrement anonyme (aucune identité
/// de patient ni d'utilisateur), sauvegardé localement uniquement.
class QuizAttempt {
  const QuizAttempt({
    required this.moduleId,
    required this.timestamp,
    required this.score,
    required this.totalQuestions,
  });

  final String moduleId;
  final DateTime timestamp;
  final int score;
  final int totalQuestions;

  double get ratio => totalQuestions == 0 ? 0 : score / totalQuestions;

  Map<String, dynamic> toJson() => {
        'moduleId': moduleId,
        'timestamp': timestamp.toIso8601String(),
        'score': score,
        'totalQuestions': totalQuestions,
      };

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
        moduleId: json['moduleId'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        score: json['score'] as int,
        totalQuestions: json['totalQuestions'] as int,
      );
}
