import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/calculator_registry.dart';
import '../models/calculation_record.dart';
import '../services/record_replay.dart';
import '../state/app_state.dart';

/// Historique local des calculs (enregistrements v2, anonymes). Chaque
/// enregistrement montre l'équation, sa version et la version de
/// l'application ; « Rejouer » refait le calcul avec l'équation actuelle et
/// compare — opération explicite, rien n'est recalculé en silence.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final records = context.watch<AppState>().history;
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des calculs')),
      body: SafeArea(
        child: records.isEmpty
            ? const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Aucun calcul enregistré. L\'historique est facultatif : activez-le dans Réglages.',
                    textAlign: TextAlign.center),
              ))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: records.length,
                itemBuilder: (_, i) => _RecordTile(record: records[i]),
              ),
      ),
    );
  }
}

class _RecordTile extends StatefulWidget {
  const _RecordTile({required this.record});
  final CalculationRecord record;

  @override
  State<_RecordTile> createState() => _RecordTileState();
}

class _RecordTileState extends State<_RecordTile> {
  String? _replayMessage;

  void _replay() {
    final record = widget.record;
    final definition = allCalculators.where((d) => d.meta.id == record.equationId);
    if (definition.isEmpty) {
      setState(() => _replayMessage = 'Équation introuvable dans cette version de l\'application.');
      return;
    }
    try {
      final result = RecordReplay.replay(definition.first, record);
      if (result == null) {
        setState(() => _replayMessage = 'Cet enregistrement ne peut pas être rejoué.');
        return;
      }
      final mismatches = <String>[];
      if (result.values.length != record.results.length) {
        mismatches.add('nombre de résultats différent');
      } else {
        for (var i = 0; i < result.values.length; i++) {
          final a = result.values[i].value, b = record.results[i].value;
          final same = (a == null && b == null) ||
              (a != null && b != null && (a - b).abs() <= 1e-12 * (a.abs() > b.abs() ? a.abs() : b.abs()));
          if (!same) mismatches.add(record.results[i].label);
        }
      }
      setState(() => _replayMessage = mismatches.isEmpty
          ? 'Rejoué avec l\'équation actuelle : résultats identiques à l\'enregistrement.'
          : 'Rejoué avec l\'équation actuelle : résultats DIFFÉRENTS (${mismatches.join(', ')}). '
              'L\'équation a été modifiée depuis cet enregistrement ; celui-ci n\'est pas altéré.');
    } on CalculationInputException {
      setState(() => _replayMessage = 'Les entrées enregistrées ne sont plus acceptées par l\'équation actuelle.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final theme = Theme.of(context);
    final date = r.timestamp.toLocal().toString().split('.').first;
    return Card(
      child: ExpansionTile(
        title: Text(r.equationName),
        subtitle: Text(r.legacy ? '$date · ancien format' : date),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Résultats', style: theme.textTheme.labelLarge),
          for (final line in r.resultSummary) Text(line),
          const SizedBox(height: 8),
          Text('Entrées', style: theme.textTheme.labelLarge),
          for (final e in r.echoedInputs.entries) Text('${e.key} : ${e.value}'),
          const SizedBox(height: 8),
          if (r.legacy)
            Text(
              'Enregistrement converti depuis l\'ancien historique : la version de l\'équation et les '
              'entrées brutes n\'avaient pas été conservées, il ne peut pas être rejoué.',
              style: theme.textTheme.bodySmall,
            )
          else ...[
            Text(
              'Équation ${r.equationStableId ?? r.equationId} · version ${r.equationVersion} '
              '(${r.equationVersionLabel}) · application ${r.appVersion} · arrondi ${r.roundingRule}',
              style: theme.textTheme.bodySmall,
            ),
            if (!r.complete)
              Text('Calcul incomplet au moment de l\'enregistrement.', style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            OutlinedButton.icon(
                onPressed: r.replayable ? _replay : null,
                icon: const Icon(Icons.replay),
                label: const Text('Rejouer avec l\'équation actuelle')),
          ],
          if (_replayMessage != null) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_replayMessage!),
          ),
        ],
      ),
    );
  }
}
