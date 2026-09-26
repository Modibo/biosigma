import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/quiz_attempt.dart';
import '../models/quiz_question.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Taille d'une série d'évaluation, tirée au hasard dans la banque du
/// domaine à chaque lancement.
const int kQuizSessionSize = 20;

/// Écran d'une série d'entraînement : [kQuizSessionSize] questions tirées
/// au hasard dans la banque du domaine (moins si la banque est plus
/// petite), une à la fois, correction immédiate avec explication, score
/// final sauvegardé localement. Outil d'auto-évaluation pédagogique — ne
/// remplace jamais un jugement clinique ni une formation validante.
class QuizModuleScreen extends StatefulWidget {
  const QuizModuleScreen({super.key, required this.module});

  final QuizModule module;

  @override
  State<QuizModuleScreen> createState() => _QuizModuleScreenState();
}

class _QuizModuleScreenState extends State<QuizModuleScreen> {
  late List<QuizQuestion> _session = widget.module.sampleSession(sessionSize: kQuizSessionSize);
  int _index = 0;
  int? _selected;
  bool _answered = false;
  int _correctCount = 0;
  bool _finished = false;
  bool _saved = false;

  QuizQuestion get _question => _session[_index];
  bool get _isLast => _index == _session.length - 1;

  void _validate() {
    if (_selected == null) return;
    setState(() {
      _answered = true;
      if (_selected == _question.correctIndex) _correctCount++;
    });
  }

  Future<void> _next() async {
    if (_isLast) {
      setState(() => _finished = true);
      if (!_saved) {
        _saved = true;
        await context.read<AppState>().recordQuizAttempt(QuizAttempt(
              moduleId: widget.module.id,
              timestamp: DateTime.now(),
              score: _correctCount,
              totalQuestions: _session.length,
            ));
      }
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _answered = false;
    });
  }

  void _restart() {
    setState(() {
      // Nouvelle série tirée au hasard : les questions ne sont pas figées
      // d'une évaluation à l'autre.
      _session = widget.module.sampleSession(sessionSize: kQuizSessionSize);
      _index = 0;
      _selected = null;
      _answered = false;
      _correctCount = 0;
      _finished = false;
      _saved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.module.title)),
      body: SafeArea(
        child: _finished ? _buildResult(context) : _buildQuestion(context),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final theme = Theme.of(context);
    final total = _session.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Auto-évaluation pédagogique — ne remplace ni une formation validante ni un jugement '
            'clinique.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
          ),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: (_index) / total),
        const SizedBox(height: 8),
        Text('Question ${_index + 1} / $total', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Chip(label: Text(_question.type.label), visualDensity: VisualDensity.compact),
        const SizedBox(height: 12),
        Text(_question.prompt, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        RadioGroup<int>(
          groupValue: _selected,
          onChanged: (v) {
            if (_answered) return;
            setState(() => _selected = v);
          },
          child: Column(
            children: [
              for (var i = 0; i < _question.options.length; i++)
                _buildOptionTile(context, i),
            ],
          ),
        ),
        if (_answered) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (_selected == _question.correctIndex
                      ? Colors.green
                      : BioSigmaColors.warningBlocking)
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selected == _question.correctIndex ? 'Correct.' : 'Ce n\'était pas la bonne réponse.',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(_question.explanation),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (!_answered)
          FilledButton(
            onPressed: _selected == null ? null : _validate,
            child: const Text('Valider'),
          )
        else
          FilledButton(
            onPressed: _next,
            child: Text(_isLast ? 'Voir le score' : 'Question suivante'),
          ),
      ],
    );
  }

  Widget _buildOptionTile(BuildContext context, int i) {
    final isCorrect = i == _question.correctIndex;
    Color? tileColor;
    if (_answered) {
      if (isCorrect) {
        tileColor = Colors.green.withValues(alpha: 0.12);
      } else if (i == _selected) {
        tileColor = BioSigmaColors.warningBlocking.withValues(alpha: 0.12);
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: tileColor ?? Colors.transparent,
        child: RadioListTile<int>(
          value: i,
          title: Text(_question.options[i]),
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final theme = Theme.of(context);
    final total = _session.length;
    final appState = context.watch<AppState>();
    final best = appState.bestAttemptFor(widget.module.id);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Résultat', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('$_correctCount / $total', style: theme.textTheme.displaySmall),
                const SizedBox(height: 8),
                Text('${(100 * _correctCount / total).round()} % de bonnes réponses'),
                if (best != null) ...[
                  const SizedBox(height: 12),
                  Text('Meilleur score enregistré : ${best.score}/${best.totalQuestions}',
                      style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _restart,
          icon: const Icon(Icons.refresh),
          label: const Text('Nouvelle série'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Retour à l\'entraînement'),
        ),
      ],
    );
  }
}
