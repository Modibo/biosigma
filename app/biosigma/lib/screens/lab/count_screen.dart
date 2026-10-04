import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/disclaimer_banner.dart';
import '../../widgets/lab_widgets.dart';

/// Count : concentration en chambre, formule (compteur tactile), nombre
/// total, comptages en double. Aucune géométrie de chambre n'est embarquée :
/// surface comptée et profondeur sont saisies.
class CountScreen extends StatefulWidget {
  const CountScreen({super.key});

  @override
  State<CountScreen> createState() => _CountScreenState();
}

enum _Mode { concentration, differential, total, duplicate }

class _CountScreenState extends State<CountScreen> with LabFormMixin<CountScreen> {
  static const _cellTypes = ['Neutrophiles', 'Lymphocytes', 'Monocytes', 'Éosinophiles', 'Basophiles', 'Autres'];

  _Mode _mode = _Mode.concentration;
  double? _counted, _area, _depth, _dilution;
  double? _totalConc, _totalVolume, _a, _b;
  double? _wbc, _nrbc;
  String _dupUnit = '×10⁶/mL';
  final Map<String, int> _counts = {for (final t in _cellTypes) t: 0};
  final List<String> _history = [];

  int get _sum => _counts.values.fold(0, (a, b) => a + b);

  void _add(String type) => setState(() {
        _counts[type] = _counts[type]! + 1;
        _history.add(type);
        clearResult();
      });

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      final last = _history.removeLast();
      _counts[last] = _counts[last]! - 1;
      clearResult();
    });
  }

  void _resetCounter() => setState(() {
        for (final t in _cellTypes) {
          _counts[t] = 0;
        }
        _history.clear();
        clearResult();
      });

  void _calculate() {
    switch (_mode) {
      case _Mode.concentration:
        runCalc(() => calculateCellCount(
              counted: asInt(_counted),
              countedAreaMm2: _area,
              depthMm: _depth,
              dilutionFactor: _dilution,
            ));
      case _Mode.differential:
        runCalc(() => calculateDifferential(
              counts: {for (final e in _counts.entries.where((e) => e.value > 0)) e.key: e.value},
              wbcGL: _wbc,
              nrbcPer100Wbc: _nrbc,
            ));
      case _Mode.total:
        runCalc(() => calculateTotalCount(concentrationE6PerMl: _totalConc, volumeMl: _totalVolume));
      case _Mode.duplicate:
        runCalc(() => calculateDuplicateCounts(concentrationA: _a, concentrationB: _b, unit: _dupUnit));
    }
  }

  void _reset() => setState(() {
        _counted = _area = _depth = _dilution = null;
        _totalConc = _totalVolume = _a = _b = _wbc = _nrbc = null;
        _resetCounterQuiet();
        clearResult();
        generation++;
      });

  void _resetCounterQuiet() {
    for (final t in _cellTypes) {
      _counts[t] = 0;
    }
    _history.clear();
  }

  Widget _counter() => Column(children: [
        Text('Cellules comptées : $_sum', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final t in _cellTypes)
          Card(
            child: ListTile(
              title: Text(t),
              subtitle: Text(_sum == 0 ? '' : '${(_counts[t]! / _sum * 100).toStringAsFixed(1)} %'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('${_counts[t]}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => _add(t),
                  style: FilledButton.styleFrom(minimumSize: const Size(56, 48)),
                  child: const Icon(Icons.add),
                ),
              ]),
            ),
          ),
        Wrap(spacing: 8, children: [
          OutlinedButton.icon(
              onPressed: _history.isEmpty ? null : _undo,
              icon: const Icon(Icons.undo),
              label: const Text('Annuler le dernier')),
          OutlinedButton.icon(
              onPressed: _sum == 0 ? null : _resetCounter,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Remettre à zéro')),
        ]),
      ]);

  @override
  Widget build(BuildContext context) {
    final sep = context.watch<AppState>().settings.decimalSeparator;
    return Scaffold(
      appBar: AppBar(title: const Text('Count')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DisclaimerBanner(),
            const SizedBox(height: 12),
            ModeChips<_Mode>(
              options: const [(_Mode.concentration, 'Chambre'), (_Mode.differential, 'Formule'), (_Mode.total, 'Total'), (_Mode.duplicate, 'A / B')],
              selected: _mode,
              onSelected: (m) => setState(() {
                _mode = m;
                clearResult();
              }),
            ),
            const SizedBox(height: 12),
            if (_mode == _Mode.concentration) ...[
              Text(
                'Surface comptée = nombre de carrés × surface d\'un carré, et profondeur : '
                'selon la fiche de VOTRE chambre (BioSigma n\'en embarque aucune).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              numberField(id: 'counted', label: 'Cellules comptées (entier)', value: _counted,
                  set: (v) => _counted = v, separator: sep),
              numberField(id: 'countedArea', label: 'Surface comptée (mm²)', value: _area,
                  set: (v) => _area = v, separator: sep),
              numberField(id: 'depth', label: 'Profondeur de la chambre (mm)', value: _depth,
                  set: (v) => _depth = v, separator: sep),
              numberField(id: 'dilution', label: 'Facteur de dilution (1 = sans dilution)',
                  value: _dilution, set: (v) => _dilution = v, separator: sep,
                  help: 'Volume total / volume d\'échantillon (ex. 20 pour 50 µL dans 1 mL).'),
            ],
            if (_mode == _Mode.differential) ...[
              _counter(),
              numberField(id: 'wbc', label: 'Leucocytes (G/L) — facultatif', value: _wbc,
                  set: (v) => _wbc = v, separator: sep, help: 'Pour obtenir les valeurs absolues.'),
              numberField(id: 'nrbc', label: 'Érythroblastes pour 100 leucocytes — facultatif',
                  value: _nrbc, set: (v) => _nrbc = v, separator: sep),
            ],
            if (_mode == _Mode.total) ...[
              Text('La concentration et le nombre total sont deux grandeurs différentes.',
                  style: Theme.of(context).textTheme.bodySmall),
              numberField(id: 'concentration', label: 'Concentration (×10⁶/mL)', value: _totalConc,
                  set: (v) => _totalConc = v, separator: sep),
              numberField(id: 'volume', label: 'Volume (mL)', value: _totalVolume,
                  set: (v) => _totalVolume = v, separator: sep),
            ],
            if (_mode == _Mode.duplicate) ...[
              Text('Deux comptages du même échantillon : moyenne et écart, sans seuil d\'acceptabilité.',
                  style: Theme.of(context).textTheme.bodySmall),
              LabDropdown(
                  label: 'Unité', value: _dupUnit,
                  options: const ['×10⁶/mL', 'cellules/µL', '×10⁹/L'],
                  onChanged: (u) => setState(() => _dupUnit = u)),
              numberField(id: 'concentrationA', label: 'Comptage A', value: _a, set: (v) => _a = v, separator: sep),
              numberField(id: 'concentrationB', label: 'Comptage B', value: _b, set: (v) => _b = v, separator: sep),
            ],
            otherErrors({'counted', 'countedArea', 'depth', 'dilution', 'wbc', 'nrbc', 'concentration',
              'volume', 'concentrationA', 'concentrationB'}),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(
                  onPressed: _calculate, icon: const Icon(Icons.calculate), label: const Text('Calculer')),
              OutlinedButton.icon(
                  onPressed: _reset, icon: const Icon(Icons.refresh), label: const Text('Nouvelle saisie')),
            ]),
            if (result != null) ...[
              const SizedBox(height: 16),
              LabResultCard(result: result!, decimalSeparator: sep),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
