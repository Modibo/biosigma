import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_settings.dart';
import '../../services/number_format_service.dart';
import '../../state/app_state.dart';
import '../../widgets/disclaimer_banner.dart';
import '../../widgets/lab_widgets.dart';
import '../../widgets/numeric_unit_field.dart';

/// Convert : conversion de grandeurs (toutes les unités SI et traditionnelles
/// courantes, masse molaire et valence saisies si la nature change) ou d'un
/// analyte de la base (masse molaire calculée à partir de sa formule brute).
class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key, this.initialAnalyteId, this.initialUnit});

  /// Ouvre directement le mode Analyte sur cet analyte (recherche universelle).
  final String? initialAnalyteId;

  /// Ouvre le mode Unités sur la famille de cette unité, en départ.
  final String? initialUnit;

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

enum _Mode { units, analyte }

class _ConvertScreenState extends State<ConvertScreen> {
  _Mode _mode = _Mode.units;
  double? _value;
  double? _molarMass;
  double? _valence;
  int _generation = 0;
  Map<String, String> _errors = {};
  CalculationResult? _result;

  // Saisie rapide (« 88 umol/l en mg/dl ») : trace de la lecture, jamais silencieuse.
  final TextEditingController _quick = TextEditingController();
  List<String> _quickNotes = [];
  List<String> _quickCautions = [];
  List<String> _quickProblems = [];
  List<String> _quickSuggestions = [];
  String _quickBadUnit = '';

  // Mode « Unités »
  String _familyKey = 'concentration';
  String _from = 'mg/dL';
  String _to = 'mmol/L';

  // Mode « Analyte »
  LabAnalyte _analyte = AnalyteBase.byId('glucose')!;
  String _analyteFrom = 'mg/dL';
  String _analyteTo = 'mmol/L';

  @override
  void initState() {
    super.initState();
    final analyte = widget.initialAnalyteId == null
        ? null
        : AnalyteBase.byId(widget.initialAnalyteId!);
    if (analyte != null) {
      _mode = _Mode.analyte;
      _analyte = analyte;
      _analyteFrom = analyte.units.first;
      final compatible = analyte
          .compatibleUnits(_analyteFrom)
          .where((u) => u != _analyteFrom);
      _analyteTo = compatible.isEmpty ? _analyteFrom : compatible.first;
    } else if (widget.initialUnit != null) {
      final matches = LabUnits.families.where(
        (f) => f.units.contains(widget.initialUnit),
      );
      if (matches.isNotEmpty) {
        final family = matches.first;
        _familyKey = family.key;
        _from = widget.initialUnit!;
        _to = family.units.firstWhere((u) => u != _from, orElse: () => _from);
      }
    }
  }

  @override
  void dispose() {
    _quick.dispose();
    super.dispose();
  }

  /// Lit « 88 umol/l » ou « 88 umol/l en mg/dl » : valeur, unité de départ et,
  /// facultativement, unité d'arrivée. Rien n'est appliqué si une partie est
  /// illisible ou ambiguë : l'utilisateur voit pourquoi et les propositions.
  void _applyQuick(DecimalSeparator sep) {
    final text = _quick.text.trim();
    final notes = <String>[], cautions = <String>[], problems = <String>[];
    var suggestions = <String>[];
    void finish() => setState(() {
      _quickNotes = notes;
      _quickCautions = cautions;
      _quickProblems = problems;
      _quickSuggestions = suggestions;
    });
    if (text.isEmpty) return finish();

    final parts = text.split(
      RegExp(r'\s+(?:en|vers|to|->|→)\s+', caseSensitive: false),
    );
    final left = UnitInterpreter.splitQuantity(parts.first);
    if (left == null) {
      problems.add(
        'Saisissez une valeur suivie de son unité, par exemple « 88 µmol/L » ou « 88 umol/l en mg/dl ».',
      );
      return finish();
    }
    final ambiguity = NumberFormatService.ambiguityMessage(left.number, sep);
    final value = NumberFormatService.parse(left.number, sep);
    if (ambiguity != null || value == null) {
      problems.add(ambiguity ?? 'Valeur « ${left.number} » illisible.');
      return finish();
    }
    final from = UnitInterpreter.interpret(left.unit);
    final to = parts.length > 1 ? UnitInterpreter.interpret(parts[1]) : null;
    for (final r in [from, ?to]) {
      notes.addAll(r.notes);
      cautions.addAll(r.cautions);
    }
    if (!from.recognized) {
      problems.add('Unité « ${left.unit} » non reconnue.');
      suggestions = from.suggestions;
      _quickBadUnit = left.unit;
      return finish();
    }
    if (to != null && !to.recognized) {
      problems.add('Unité d\'arrivée « ${parts[1].trim()} » non reconnue.');
      suggestions = to.suggestions;
      _quickBadUnit = parts[1].trim();
      return finish();
    }
    final fromSymbol = from.unit!.symbol;
    final toSymbol = to?.unit!.symbol;

    if (_mode == _Mode.analyte) {
      if (!_analyte.units.contains(fromSymbol)) {
        problems.add(
          '« $fromSymbol » n\'est pas proposée pour ${_analyte.name} : choisissez dans la liste.',
        );
        return finish();
      }
      final compatible = _analyte.compatibleUnits(fromSymbol);
      if (toSymbol != null && !compatible.contains(toSymbol)) {
        problems.add(
          '« $toSymbol » n\'est pas une unité d\'arrivée proposée pour ${_analyte.name} depuis « $fromSymbol ».',
        );
        return finish();
      }
      setState(() {
        _value = value;
        _analyteFrom = fromSymbol;
        _analyteTo =
            toSymbol ??
            (compatible.contains(_analyteTo)
                ? _analyteTo
                : compatible.firstWhere(
                    (c) => c != fromSymbol,
                    orElse: () => fromSymbol,
                  ));
        _result = null;
        _errors = {};
        _generation++;
      });
    } else {
      final family = LabUnits.families
          .where((f) => f.units.contains(fromSymbol))
          .toList();
      if (family.isEmpty) {
        problems.add(
          '« $fromSymbol » est reconnue mais n\'est proposée dans aucune liste de conversion.',
        );
        return finish();
      }
      final f = family.first;
      if (toSymbol != null && !f.units.contains(toSymbol)) {
        problems.add(
          '« $toSymbol » n\'appartient pas à la famille « ${f.label} » de « $fromSymbol » : conversion impossible.',
        );
        return finish();
      }
      setState(() {
        _familyKey = f.key;
        _value = value;
        _from = fromSymbol;
        _to =
            toSymbol ??
            f.units.firstWhere(
              (u) => u != fromSymbol,
              orElse: () => fromSymbol,
            );
        _result = null;
        _errors = {};
        _generation++;
      });
    }
    notes.insert(
      0,
      'Lu : ${NumberFormatService.formatCompact(value, sep)} $fromSymbol'
      '${toSymbol == null ? '' : ' → $toSymbol'}.',
    );
    finish();
  }

  Widget _quickEntry(DecimalSeparator sep) {
    final theme = Theme.of(context);
    final lines = [..._quickNotes, ..._quickCautions, ..._quickProblems];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const ValueKey('quick-entry'),
            controller: _quick,
            decoration: InputDecoration(
              labelText: 'Saisie rapide (facultatif)',
              hintText: '88 umol/l en mg/dl',
              helperText: 'Valeur, unité, et « en » unité d\'arrivée. Les unités sont lues pour vous remplir les listes ci-dessous.',
              helperMaxLines: 3,
              suffixIcon: IconButton(
                tooltip: 'Appliquer la saisie rapide',
                icon: const Icon(Icons.keyboard_return),
                onPressed: () => _applyQuick(sep),
              ),
            ),
            onSubmitted: (_) => _applyQuick(sep),
          ),
          if (lines.isNotEmpty)
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  lines.join('\n'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _quickProblems.isNotEmpty
                        ? theme.colorScheme.error
                        : null,
                  ),
                ),
              ),
            ),
          if (_quickSuggestions.isNotEmpty)
            Wrap(
              spacing: 8,
              children: [
                const Text('Vouliez-vous dire :'),
                for (final sgg in _quickSuggestions)
                  ActionChip(
                    label: Text(sgg),
                    onPressed: () {
                      _quick.text = _quick.text.replaceFirst(
                        _quickBadUnit,
                        sgg,
                      );
                      _applyQuick(sep);
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }

  List<String> get _familyUnits =>
      LabUnits.families.firstWhere((f) => f.key == _familyKey).units;

  bool _needs(bool Function(LabUnit, LabUnit) test) {
    final a = LabUnits.parse(_from), b = LabUnits.parse(_to);
    if (a == null || b == null || a.family != b.family) return false;
    if (a.family != 'quantity' && a.family != 'concentration' && a.family != 'rate') {
      return false;
    }
    return a.quantityKind != b.quantityKind && test(a, b);
  }

  bool get _needsMolarMass => _needs(
    (a, b) =>
        a.quantityKind == LabDimension.mass ||
        b.quantityKind == LabDimension.mass,
  );
  bool get _needsValence => _needs(
    (a, b) =>
        a.quantityKind == LabDimension.equivalent ||
        b.quantityKind == LabDimension.equivalent,
  );

  void _calculate() {
    try {
      final result = _mode == _Mode.units
          ? calculateConversion(
              value: _value,
              fromUnit: _from,
              toUnit: _to,
              molarMassGPerMol: _needsMolarMass ? _molarMass : null,
              valence: _needsValence ? _valence : null,
            )
          : calculateAnalyteUnitConversion(
              analyteId: _analyte.id,
              value: _value,
              fromUnit: _analyteFrom,
              toUnit: _analyteTo,
            );
      setState(() {
        _errors = {};
        _result = result;
      });
    } on CalculationInputException catch (e) {
      setState(() {
        _errors = fieldErrorMap(e);
        _result = null;
      });
    }
  }

  void _reset() => setState(() {
    _value = _molarMass = _valence = null;
    _errors = {};
    _result = null;
    _generation++;
  });

  void _selectFamily(String key) {
    final units = LabUnits.families.firstWhere((f) => f.key == key).units;
    setState(() {
      _familyKey = key;
      _from = units.first;
      _to = units.length > 1 ? units[1] : units.first;
      _result = null;
      _errors = {};
    });
  }

  void _selectAnalyte(LabAnalyte a) {
    final units = a.units;
    final from = units.first;
    final compatible = a.compatibleUnits(from).where((u) => u != from).toList();
    setState(() {
      _analyte = a;
      _analyteFrom = from;
      _analyteTo = compatible.isEmpty ? from : compatible.first;
      _result = null;
      _errors = {};
    });
  }

  Widget _analyteInfo(DecimalSeparator sep) {
    final theme = Theme.of(context);
    final m = _analyte.molarMass;
    final lines = <String>[
      if (_analyte.formulaText != null)
        'Formule brute : ${_analyte.formulaText} — masse molaire calculée : '
            '${NumberFormatService.format(m!, sep, precision: 3)} g/mol'
            '${_analyte.valence != null ? ' — valence ${_analyte.valence}' : ''}',
      if (_analyte.note != null) _analyte.note!,
      'Statut : ${AnalyteBase.statusOf(_analyte.id).label}'
          '${AnalyteBase.statusOf(_analyte.id) == EquationStatus.notValidated ? ' (non revu par un biologiste responsable)' : ''}.',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(lines.join('\n'), style: theme.textTheme.bodySmall),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sep = context.watch<AppState>().settings.decimalSeparator;
    final knownIds = {'value', 'fromUnit', 'toUnit', 'molarMass', 'valence'};
    final general = _errors.entries
        .where((e) => !knownIds.contains(e.key))
        .map((e) => e.value);
    final fromList = _mode == _Mode.units ? _familyUnits : _analyte.units;
    final toList = _mode == _Mode.units
        ? _familyUnits
        : _analyte.compatibleUnits(_analyteFrom);
    final from = _mode == _Mode.units ? _from : _analyteFrom;
    final to = _mode == _Mode.units ? _to : _analyteTo;

    return Scaffold(
      appBar: AppBar(title: const Text('Convert')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DisclaimerBanner(),
            const SizedBox(height: 12),
            ModeChips<_Mode>(
              options: const [
                (_Mode.units, 'Unités'),
                (_Mode.analyte, 'Analyte'),
              ],
              selected: _mode,
              onSelected: (m) => setState(() {
                _mode = m;
                _errors = {};
                _result = null;
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _mode == _Mode.units
                  ? 'Toutes les unités SI et traditionnelles courantes. Pour passer d\'une masse à une '
                        'quantité de matière ou à des équivalents, saisissez la masse molaire et la valence.'
                  : '${AnalyteBase.all.length} analytes et grandeurs : la masse molaire est calculée à '
                        'partir de la formule brute (poids atomiques IUPAC abrégés), jamais saisie de mémoire.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            _quickEntry(sep),
            if (_mode == _Mode.units)
              LabDropdown(
                label: 'Grandeur',
                value: LabUnits.families
                    .firstWhere((f) => f.key == _familyKey)
                    .label,
                options: [for (final f in LabUnits.families) f.label],
                onChanged: (label) => _selectFamily(
                  LabUnits.families.firstWhere((f) => f.label == label).key,
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: DropdownMenu<String>(
                  key: const ValueKey('analyte-menu'),
                  width: double.infinity,
                  label: const Text('Analyte (tapez pour filtrer)'),
                  initialSelection: _analyte.id,
                  enableFilter: true,
                  requestFocusOnTap: true,
                  menuHeight: 360,
                  dropdownMenuEntries: [
                    for (final a in AnalyteBase.all)
                      DropdownMenuEntry(value: a.id, label: a.name),
                  ],
                  onSelected: (id) {
                    if (id != null) _selectAnalyte(AnalyteBase.byId(id)!);
                  },
                ),
              ),
              Text(
                _analyte.category,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              _analyteInfo(sep),
            ],
            NumericUnitField(
              key: ValueKey('value-$_generation'),
              label: 'Valeur',
              helpText: null,
              value: _value,
              unit: '',
              units: null,
              decimalSeparator: sep,
              errorText: _errors['value'],
              onValueChanged: (v) => setState(() => _value = v),
              onUnitChanged: (_) {},
            ),
            LabDropdown(
              label: 'Unité de départ',
              value: from,
              options: fromList,
              errorText: _errors['fromUnit'],
              onChanged: (u) => setState(() {
                if (_mode == _Mode.units) {
                  _from = u;
                } else {
                  _analyteFrom = u;
                  final compatible = _analyte.compatibleUnits(u);
                  if (!compatible.contains(_analyteTo)) {
                    _analyteTo = compatible.firstWhere(
                      (c) => c != u,
                      orElse: () => u,
                    );
                  }
                }
                _result = null;
              }),
            ),
            LabDropdown(
              label: 'Unité d\'arrivée',
              value: toList.contains(to) ? to : toList.first,
              options: toList,
              errorText: _errors['toUnit'],
              onChanged: (u) => setState(() {
                if (_mode == _Mode.units) {
                  _to = u;
                } else {
                  _analyteTo = u;
                }
                _result = null;
              }),
            ),
            if (_mode == _Mode.units && _needsMolarMass)
              NumericUnitField(
                key: ValueKey('molarMass-$_generation'),
                label: 'Masse molaire (g/mol)',
                helpText: 'À saisir : forme chimique réellement dosée (sel, hydrate, forme libre).',
                value: _molarMass,
                unit: 'g/mol',
                units: const ['g/mol'],
                decimalSeparator: sep,
                errorText: _errors['molarMass'],
                onValueChanged: (v) => setState(() => _molarMass = v),
                onUnitChanged: (_) {},
              ),
            if (_mode == _Mode.units && _needsValence)
              NumericUnitField(
                key: ValueKey('valence-$_generation'),
                label: 'Valence',
                helpText:
                    'Nombre de charges par ion (ex. 1 pour Na⁺, 2 pour Ca²⁺).',
                value: _valence,
                unit: '',
                units: null,
                decimalSeparator: sep,
                errorText: _errors['valence'],
                onValueChanged: (v) => setState(() => _valence = v),
                onUnitChanged: (_) {},
              ),
            for (final message in general) LabErrorText(message),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Convertir'),
                ),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Nouvelle saisie'),
                ),
              ],
            ),
            if (_result != null) ...[
              const SizedBox(height: 16),
              LabResultCard(result: _result!, decimalSeparator: sep),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
