import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/quiz/quiz_registry.dart';
import '../models/quiz_question.dart';
import '../state/app_state.dart';
import 'quiz_module_screen.dart';

/// Onglet Entraînement : une série de [kQuizSessionSize] questions tirées
/// au hasard dans la banque de chaque domaine à chaque lancement,
/// essentiellement des cas cliniques et d'interprétation. Auto-évaluation
/// pédagogique, scores sauvegardés localement uniquement.
class EntrainementScreen extends StatelessWidget {
  const EntrainementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalQuestions = allQuizModules.fold<int>(
      0,
      (sum, m) => sum + m.poolSize,
    );
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Séries de $kQuizSessionSize questions, tirées au hasard dans une banque de '
            '$totalQuestions questions au total, essentiellement des cas cliniques et '
            "d'interprétation. Auto-évaluation pédagogique : les scores restent sur cet "
            "appareil et ne remplacent ni un jugement clinique ni une formation validante.",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ...allQuizModules.map((module) => _QuizModuleCard(module: module)),
        ],
      ),
    );
  }
}

class _QuizModuleCard extends StatelessWidget {
  const _QuizModuleCard({required this.module});
  final QuizModule module;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final best = appState.bestAttemptFor(module.id);
    final sessionSize = module.poolSize < kQuizSessionSize
        ? module.poolSize
        : kQuizSessionSize;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.school_outlined),
        title: Text(module.title),
        subtitle: Text(
          'Série de $sessionSize question(s) — banque de ${module.poolSize}',
        ),
        trailing: best == null
            ? const Icon(Icons.chevron_right)
            : Chip(
                label: Text('${best.score}/${best.totalQuestions}'),
                visualDensity: VisualDensity.compact,
              ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => QuizModuleScreen(module: module)),
        ),
      ),
    );
  }
}
