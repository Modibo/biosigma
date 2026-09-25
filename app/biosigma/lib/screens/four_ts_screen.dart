import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/formula_reference_section.dart';
import '../widgets/guided_criterion_selector.dart';
import '../widgets/result_value_tile.dart';

/// Module guidé du score 4Ts (thrombopénie induite par l'héparine) :
/// quatre critères catégoriels, jamais présélectionnés, « score incomplet »
/// tant qu'un critère manque. Interprétation masquée par défaut, comme
/// pour le score ISTH-CIVD.
class FourTsScreen extends StatefulWidget {
  const FourTsScreen({super.key});

  @override
  State<FourTsScreen> createState() => _FourTsScreenState();
}

class _FourTsScreenState extends State<FourTsScreen> {
  FourTsThrombocytopenia? _thrombocytopenia;
  FourTsTiming? _timing;
  FourTsThrombosis? _thrombosis;
  FourTsOtherCauses? _otherCauses;
  CalculationResult? _result;

  void _calculate() {
    setState(() {
      _result = calculateFourTsScore(
        thrombocytopenia: _thrombocytopenia,
        timing: _timing,
        thrombosisSequelae: _thrombosis,
        otherCauses: _otherCauses,
      );
    });
  }

  void _reset() {
    setState(() {
      _thrombocytopenia = null;
      _timing = null;
      _thrombosis = null;
      _otherCauses = null;
      _result = null;
    });
  }

  Future<void> _copy() async {
    final r = _result;
    if (r == null) return;
    final buffer = StringBuffer()
      ..writeln(fourTsScoreMeta.name)
      ..writeln(fourTsScoreMeta.version);
    for (final v in r.values) {
      buffer.writeln('${v.label} : ${v.isComputed ? v.value!.toStringAsFixed(0) : "incomplet"} ${v.unit}');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Résultat copié dans le presse-papiers.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final validated = appState.settings.localInterpretationsValidated;

    return Scaffold(
      appBar: AppBar(title: const Text('Score 4Ts')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DisclaimerBanner(),
            const SizedBox(height: 12),
            Text(fourTsScoreMeta.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            GuidedCriterionSelector<FourTsThrombocytopenia>(
              title: '1. Thrombopénie',
              options: FourTsThrombocytopenia.values,
              selected: _thrombocytopenia,
              onChanged: (v) => setState(() => _thrombocytopenia = v),
              describe: (o) => o.description,
              points: (o) => o.points,
            ),
            GuidedCriterionSelector<FourTsTiming>(
              title: '2. Chronologie de la chute plaquettaire',
              options: FourTsTiming.values,
              selected: _timing,
              onChanged: (v) => setState(() => _timing = v),
              describe: (o) => o.description,
              points: (o) => o.points,
            ),
            GuidedCriterionSelector<FourTsThrombosis>(
              title: '3. Thrombose ou autre séquelle',
              options: FourTsThrombosis.values,
              selected: _thrombosis,
              onChanged: (v) => setState(() => _thrombosis = v),
              describe: (o) => o.description,
              points: (o) => o.points,
            ),
            GuidedCriterionSelector<FourTsOtherCauses>(
              title: '4. Autre cause de thrombopénie',
              options: FourTsOtherCauses.values,
              selected: _otherCauses,
              onChanged: (v) => setState(() => _otherCauses = v),
              describe: (o) => o.description,
              points: (o) => o.points,
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculer')),
              if (_result != null)
                OutlinedButton.icon(
                    onPressed: () => setState(() => _result = null),
                    icon: const Icon(Icons.clear),
                    label: const Text('Effacer le résultat')),
              OutlinedButton.icon(
                  onPressed: _reset, icon: const Icon(Icons.refresh), label: const Text('Nouvelle saisie')),
              if (_result != null)
                OutlinedButton.icon(
                    onPressed: _copy, icon: const Icon(Icons.copy), label: const Text('Copier')),
            ]),
            if (_result != null) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Résultat', style: Theme.of(context).textTheme.titleMedium),
                      if (!_result!.isComplete)
                        const Text('Score incomplet',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._result!.values.map((v) => ResultValueTile(
                          result: v, decimalSeparator: appState.settings.decimalSeparator)),
                      const SizedBox(height: 8),
                      if (_result!.isComplete && !validated)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            "Interprétation masquée : cochez « interprétations locales validées » "
                            'dans Réglages pour l\'afficher (validation par le biologiste responsable).',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        )
                      else
                        ..._result!.warnings.map((w) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(w.message),
                            )),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            FormulaReferenceSection(meta: fourTsScoreMeta),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
