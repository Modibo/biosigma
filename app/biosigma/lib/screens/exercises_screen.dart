import 'dart:math' as math;

import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/number_format_service.dart';
import '../state/app_state.dart';
import '../widgets/lab_widgets.dart';
import '../widgets/numeric_unit_field.dart';

/// Mode enseignement : exercices de calcul générés (cas fictifs). Le corrigé est
/// calculé par le moteur de l'application ; l'exercice rappelle le statut de
/// validation de l'équation utilisée.
class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key, this.initialSeed, this.initialKindId});

  /// Fixe le numéro du premier exercice (tests, partage d'un exercice).
  final int? initialSeed;
  final String? initialKindId;

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late String _kindId = widget.initialKindId ?? ExerciseGenerator.kinds.first.id;
  late int _seed = widget.initialSeed ?? math.Random().nextInt(1 << 30);
  double? _answer;
  ExerciseCheck? _check;
  int _generation = 0;
  int _answered = 0, _correct = 0;

  Exercise get _exercise => ExerciseGenerator.generate(_kindId, _seed);

  void _next() => setState(() {
        _seed = math.Random().nextInt(1 << 30);
        _answer = null;
        _check = null;
        _generation++;
      });

  void _verify() {
    final c = _exercise.check(_answer);
    setState(() {
      if (_check == null && _answer != null) {
        _answered++;
        if (c.correct) _correct++;
      }
      _check = c;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sep = context.watch<AppState>().settings.decimalSeparator;
    final theme = Theme.of(context);
    final e = _exercise;
    final unit = e.answerUnit;
    return Scaffold(
      appBar: AppBar(title: const Text('Exercices de calcul')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(e.banner, style: theme.textTheme.bodySmall),
              ),
            ),
            LabDropdown(
              label: 'Type d\'exercice',
              value: ExerciseGenerator.kindById(_kindId)!.title,
              options: [for (final k in ExerciseGenerator.kinds) k.title],
              onChanged: (title) => setState(() {
                _kindId = ExerciseGenerator.kinds.firstWhere((k) => k.title == title).id;
                _seed = math.Random().nextInt(1 << 30);
                _answer = null;
                _check = null;
                _generation++;
              }),
            ),
            const SizedBox(height: 8),
            Text('Exercice n° ${e.seed}', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(e.statement, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            NumericUnitField(
              key: ValueKey('answer-$_generation'),
              label: '${e.answerLabel}${unit.isEmpty ? '' : ' ($unit)'}',
              helpText: 'Arrondissez à ${e.decimals} décimale${e.decimals > 1 ? 's' : ''}.',
              value: _answer,
              unit: unit,
              units: unit.isEmpty ? null : [unit],
              decimalSeparator: sep,
              onValueChanged: (v) => setState(() {
                _answer = v;
              }),
              onUnitChanged: (_) {},
            ),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(
                  onPressed: _verify, icon: const Icon(Icons.check), label: const Text('Vérifier')),
              OutlinedButton.icon(
                  onPressed: _next, icon: const Icon(Icons.refresh), label: const Text('Nouvel exercice')),
            ]),
            if (_check != null) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(_check!.correct ? Icons.check_circle_outline : Icons.error_outline,
                              color: _check!.correct ? theme.colorScheme.primary : theme.colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_check!.message, style: theme.textTheme.titleMedium)),
                        ]),
                        const SizedBox(height: 6),
                        Text('Corrigé : ${NumberFormatService.format(e.expectedRounded, sep, precision: e.decimals)}'
                            '${unit.isEmpty ? '' : ' $unit'}'),
                      ],
                    ),
                  ),
                ),
              ),
              ExpansionTile(
                title: const Text('Solution détaillée'),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                expandedAlignment: Alignment.centerLeft,
                children: [for (final line in e.solution) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(line))],
              ),
            ],
            const SizedBox(height: 12),
            Text('Cette série : $_correct bonne${_correct > 1 ? 's' : ''} réponse${_correct > 1 ? 's' : ''} sur $_answered. '
                'Rien n\'est enregistré.',
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
