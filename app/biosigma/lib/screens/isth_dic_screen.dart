import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/formula_reference_section.dart';
import '../widgets/guided_criterion_selector.dart';
import '../widgets/numeric_unit_field.dart';
import '../widgets/result_value_tile.dart';

/// Module guidé du score ISTH de CIVD : demande explicitement chaque
/// donnée clinique/analytique requise, n'infère jamais une donnée
/// absente, et affiche « score incomplet » tant que tous les critères ne
/// sont pas renseignés. L'interprétation clinique du score n'est affichée
/// que si le biologiste responsable a coché la validation locale dans les
/// réglages (cf. cahier des charges).
class IsthDicScreen extends StatefulWidget {
  const IsthDicScreen({super.key});

  @override
  State<IsthDicScreen> createState() => _IsthDicScreenState();
}

class _IsthDicScreenState extends State<IsthDicScreen> {
  bool? _underlyingDisorder;
  double? _platelets;
  FibrinMarkerIncrease? _fibrinMarker;
  double? _ptProlongation;
  double? _fibrinogen;
  String _fibrinogenUnit = 'g/L';
  CalculationResult? _result;

  void _calculate() {
    setState(() {
      _result = calculateIsthDicScore(
        underlyingDisorderPresent: _underlyingDisorder ?? false,
        plateletCountGL: _platelets,
        fibrinMarkerIncrease: _fibrinMarker,
        ptProlongationSeconds: _ptProlongation,
        fibrinogenValue: _fibrinogen,
        fibrinogenUnit: _fibrinogenUnit,
      );
    });
  }

  int _formGeneration = 0;

  void _reset() {
    setState(() {
      _underlyingDisorder = null;
      _platelets = null;
      _fibrinMarker = null;
      _ptProlongation = null;
      _fibrinogen = null;
      _result = null;
      _formGeneration++;
    });
  }

  Future<void> _copy() async {
    final r = _result;
    if (r == null) return;
    final buffer = StringBuffer()
      ..writeln(isthDicScoreMeta.name)
      ..writeln(isthDicScoreMeta.version);
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
      appBar: AppBar(title: const Text('Score ISTH-CIVD')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DisclaimerBanner(),
            const SizedBox(height: 12),
            Text(isthDicScoreMeta.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                title: const Text(
                    'Le patient présente une pathologie associée à un risque de CIVD'),
                subtitle: const Text(
                    'Prérequis obligatoire (ISTH 2001) — le score ne doit pas être appliqué hors de ce contexte.'),
                value: _underlyingDisorder ?? false,
                onChanged: (v) => setState(() => _underlyingDisorder = v),
              ),
            ),
            const SizedBox(height: 8),
            NumericUnitField(
              key: ValueKey('platelets-$_formGeneration'),
              label: 'Numération plaquettaire',
              helpText: null,
              value: _platelets,
              unit: 'G/L',
              units: const ['G/L'],
              decimalSeparator: appState.settings.decimalSeparator,
              onValueChanged: (v) => setState(() => _platelets = v),
              onUnitChanged: (_) {},
            ),
            GuidedCriterionSelector<FibrinMarkerIncrease>(
              title: 'Marqueur de fibrine (D-dimères ou PDF)',
              options: FibrinMarkerIncrease.values,
              selected: _fibrinMarker,
              onChanged: (v) => setState(() => _fibrinMarker = v),
              describe: (o) => o.label,
              points: (o) => o.points,
            ),
            NumericUnitField(
              key: ValueKey('ptProlongation-$_formGeneration'),
              label: 'Allongement du TP (patient − témoin)',
              helpText: null,
              value: _ptProlongation,
              unit: 's',
              units: const ['s'],
              decimalSeparator: appState.settings.decimalSeparator,
              onValueChanged: (v) => setState(() => _ptProlongation = v),
              onUnitChanged: (_) {},
            ),
            NumericUnitField(
              key: ValueKey('fibrinogen-$_formGeneration'),
              label: 'Fibrinogène',
              helpText: null,
              value: _fibrinogen,
              unit: _fibrinogenUnit,
              units: unitsForAnalyte(Analyte.fibrinogen),
              decimalSeparator: appState.settings.decimalSeparator,
              onValueChanged: (v) => setState(() => _fibrinogen = v),
              onUnitChanged: (u) => setState(() => _fibrinogenUnit = u),
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
            FormulaReferenceSection(meta: isthDicScoreMeta),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
