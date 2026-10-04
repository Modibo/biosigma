import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_settings.dart';
import '../../services/number_format_service.dart';
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

enum _Mode { concentration, differential, total, duplicate, semen }

class _SpermPair {
  double? a, b;
}

class _CountScreenState extends State<CountScreen> with LabFormMixin<CountScreen> {
  static const _cellTypes = ['Neutrophiles', 'Lymphocytes', 'Monocytes', 'Éosinophiles', 'Basophiles', 'Autres'];

  _Mode _mode = _Mode.concentration;
  double? _counted, _area, _depth, _dilution;
  // Chambre choisie (« custom » = surface et profondeur saisies).
  String _chamberId = 'custom';
  String? _unitLabel;
  double? _unitsCounted;
  double? _totalConc, _totalVolume, _a, _b;
  double? _wbc, _nrbc;
  // Spermatozoïdes (OMS 6e éd.)
  SpermDilution _dilution6 = SpermDilution.d20;
  SpermArea _area6 = SpermArea.grids1;
  final List<_SpermPair> _pairs = [_SpermPair()];
  double? _ejaculateVolume;
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
        final chamber = countingChamberById(_chamberId);
        if (chamber != null) {
          final unit = _chamberUnit(chamber);
          runCalc(() => calculateChamberCount(
                chamber: chamber,
                unit: unit,
                unitsCounted: asInt(_unitsCounted),
                counted: asInt(_counted),
                dilutionFactor: _dilution,
              ));
          break;
        }
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
      case _Mode.semen:
        _calculateSemen();
    }
  }

  ChamberUnit _chamberUnit(CountingChamber c) =>
      c.units.firstWhere((u) => u.label == _unitLabel, orElse: () => c.units.first);

  List<Widget> _chamberFields(DecimalSeparator sep) {
    final theme = Theme.of(context);
    final chamber = countingChamberById(_chamberId);
    final names = [for (final c in countingChambers) c.name, 'Personnalisée (surface et profondeur saisies)'];
    final selected = chamber?.name ?? names.last;
    final unit = chamber == null ? null : _chamberUnit(chamber);
    final units = _unitsCounted == null || unit == null ? null : asInt(_unitsCounted);
    return [
      LabDropdown(
        label: 'Chambre de numération',
        value: selected,
        options: names,
        helperText: chamber == null
            ? 'Choisissez votre chambre (Malassez, Neubauer améliorée…) ou saisissez sa géométrie.'
            : 'Profondeur ${NumberFormatService.formatCompact(chamber.depthMm, sep)} mm.',
        onChanged: (n) => setState(() {
          final c = countingChambers.where((c) => c.name == n);
          _chamberId = c.isEmpty ? 'custom' : c.first.id;
          _unitLabel = c.isEmpty ? null : c.first.units.first.label;
          _unitsCounted = null;
          clearResult();
        }),
      ),
      if (chamber != null && unit != null) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            'Valeurs reprises de documents cités (à confronter à la fiche de votre chambre) : ${chamber.source}',
            style: theme.textTheme.bodySmall,
          ),
        ),
        LabDropdown(
          label: 'Unité de comptage',
          value: unit.label,
          options: [for (final u in chamber.units) u.label],
          onChanged: (l) => setState(() {
            _unitLabel = l;
            _unitsCounted = null;
            clearResult();
          }),
        ),
        numberField(
          id: 'unitsCounted',
          label: 'Nombre d\'unités comptées (entier, au plus ${unit.maxPerChamber})',
          value: _unitsCounted,
          set: (v) => _unitsCounted = v,
          separator: sep,
        ),
        if (units != null && units >= 1 && units <= unit.maxPerChamber)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Surface comptée : ${NumberFormatService.formatCompact(units * unit.areaMm2, sep)} mm² ; volume compté : '
              '${NumberFormatService.formatCompact(units * unit.areaMm2 * chamber.depthMm, sep, precision: 4)} µL.',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    ];
  }

  void _calculateSemen() {
    final missing = <String, String>{};
    final pairs = <(int, int)>[];
    for (var i = 0; i < _pairs.length; i++) {
      final p = _pairs[i];
      final a = asInt(p.a), b = asInt(p.b);
      if (p.a == null || p.b == null) {
        if (i == 0 || p.a != null || p.b != null) {
          missing['pair$i'] = 'Saisissez les deux comptages (chambre 1 et chambre 2).';
        }
        continue;
      }
      if (a == null || b == null) {
        missing['pair$i'] = 'Un comptage est un nombre entier de spermatozoïdes.';
        continue;
      }
      pairs.add((a, b));
    }
    if (missing.isNotEmpty) {
      setState(() {
        errors = missing;
        result = null;
      });
      return;
    }
    runCalc(() => calculateSpermConcentration(
          replicatePairs: pairs,
          dilution: _dilution6,
          area: _area6,
          ejaculateVolumeMl: _ejaculateVolume,
        ));
  }

  List<Widget> _semenFields(DecimalSeparator sep) {
    final theme = Theme.of(context);
    return [
      Text(
        'Méthode du manuel de l\'OMS (6e éd.), chambre de Neubauer améliorée : deux chambres en réplicat, '
        'même surface comptée dans chacune, au moins 200 spermatozoïdes par chambre. Les tableaux 2.1, 2.3, 2.4 '
        'et 8.3 sont ceux du manuel (source lue le 2026-10-04, à relire).',
        style: theme.textTheme.bodySmall,
      ),
      LabDropdown(
        label: 'Dilution',
        value: _dilution6.label,
        options: [for (final d in SpermDilution.values) d.label],
        helperText: 'Selon l\'examen à l\'état frais : ${_dilution6.guidance}. '
            '${_dilution6.semenMicrolitres} µL de sperme + ${_dilution6.fixativeMicrolitres} µL de fixateur.',
        onChanged: (l) => setState(() {
          _dilution6 = SpermDilution.values.firstWhere((d) => d.label == l);
          clearResult();
        }),
      ),
      LabDropdown(
        label: 'Surface comptée dans chaque chambre',
        value: _area6.label,
        options: [for (final a in SpermArea.values) a.label],
        helperText: 'Facteur de correction F = ${NumberFormatService.formatCompact(spermCorrectionFactor(_dilution6, _area6), sep, precision: 1)} '
            '(concentration en ×10⁶/mL = somme des deux comptages / F).',
        onChanged: (l) => setState(() {
          _area6 = SpermArea.values.firstWhere((a) => a.label == l);
          clearResult();
        }),
      ),
      for (var i = 0; i < _pairs.length; i++) ...[
        const SizedBox(height: 8),
        Text(i == 0 ? 'Comptages' : 'Nouveau comptage n° ${i + 1} (écart trop grand au précédent)',
            style: theme.textTheme.titleSmall),
        numberField(id: 'pairA$i', label: 'Chambre 1 : spermatozoïdes comptés', value: _pairs[i].a,
            set: (v) => _pairs[i].a = v, separator: sep),
        numberField(id: 'pairB$i', label: 'Chambre 2 : spermatozoïdes comptés', value: _pairs[i].b,
            set: (v) => _pairs[i].b = v, separator: sep),
        if (errors['pair$i'] != null) LabErrorText(errors['pair$i']!),
      ],
      if (_pairs.length < 3)
        TextButton.icon(
          onPressed: () => setState(() {
            _pairs.add(_SpermPair());
            clearResult();
          }),
          icon: const Icon(Icons.add),
          label: const Text('Ajouter un nouveau comptage (écart trop grand)'),
        ),
      numberField(id: 'volume', label: 'Volume de l\'éjaculat (mL) — facultatif', value: _ejaculateVolume,
          set: (v) => _ejaculateVolume = v, separator: sep, help: 'Pour le nombre total de spermatozoïdes.'),
      ExpansionTile(
        title: const Text('Population de référence de l\'OMS (tableau 8.3)'),
        subtitle: const Text('5e centile, médiane : pas une limite entre hommes fertiles et infertiles'),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        expandedAlignment: Alignment.centerLeft,
        children: [
          for (final r in semenReferences)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${r.parameter} : 5e centile ${NumberFormatService.formatCompact(r.p5, sep, precision: 1)} '
                '(IC 95 % ${r.fifthCi}), médiane ${NumberFormatService.formatCompact(r.median, sep, precision: 1)} ${r.unit} '
                '(n = ${r.n})',
              ),
            ),
          Text(
            'Hommes dont la partenaire a obtenu une grossesse naturelle en moins d\'un an (Campbell et al.). Le 5e '
            'centile ne représente pas une limite entre hommes fertiles et infertiles (OMS § 8.1.3).',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    ];
  }

  void _reset() => setState(() {
        _pairs..clear()..add(_SpermPair());
        _ejaculateVolume = null;
        _counted = _area = _depth = _dilution = null;
        _unitsCounted = null;
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
              options: const [(_Mode.concentration, 'Chambre'), (_Mode.differential, 'Formule'), (_Mode.total, 'Total'), (_Mode.duplicate, 'A / B'), (_Mode.semen, 'Sperme (OMS)')],
              selected: _mode,
              onSelected: (m) => setState(() {
                _mode = m;
                clearResult();
              }),
            ),
            const SizedBox(height: 12),
            if (_mode == _Mode.concentration) ...[
              Text(
                'Choisissez votre chambre : la surface comptée se déduit du nombre d\'unités comptées et la '
                'profondeur est celle de la chambre. Pour une autre chambre, saisissez sa surface comptée et '
                'sa profondeur selon la fiche de VOTRE chambre.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              ..._chamberFields(sep),
              numberField(id: 'counted', label: 'Cellules comptées (entier)', value: _counted,
                  set: (v) => _counted = v, separator: sep),
              if (_chamberId == 'custom') ...[
                numberField(id: 'countedArea', label: 'Surface comptée (mm²)', value: _area,
                    set: (v) => _area = v, separator: sep),
                numberField(id: 'depth', label: 'Profondeur de la chambre (mm)', value: _depth,
                    set: (v) => _depth = v, separator: sep),
              ],
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
            if (_mode == _Mode.semen) ..._semenFields(sep),
            otherErrors({'unitsCounted', 'counted', 'countedArea', 'depth', 'dilution', 'wbc', 'nrbc', 'concentration',
              'volume', 'concentrationA', 'concentrationB',
              for (var i = 0; i < _pairs.length; i++) ...['pairA$i', 'pairB$i', 'pair$i']}),
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
