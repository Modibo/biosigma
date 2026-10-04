import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_settings.dart';
import '../../services/number_format_service.dart';
import '../../state/app_state.dart';
import '../../widgets/disclaimer_banner.dart';
import '../../widgets/lab_widgets.dart';
import '../../widgets/numeric_unit_field.dart';
import '../../widgets/pipette_widgets.dart';

/// Dilute : dilution simple (C1·V1 = C2·V2), dilutions en série, résultat
/// après dilution (hors linéarité).
class DiluteScreen extends StatefulWidget {
  const DiluteScreen({super.key});

  @override
  State<DiluteScreen> createState() => _DiluteScreenState();
}

enum _Mode { simple, series, linearity }

class _DiluteScreenState extends State<DiluteScreen> {
  _Mode _mode = _Mode.simple;
  int _generation = 0;
  Map<String, String> _errors = {};
  CalculationResult? _result;
  SerialDilutionResult? _series;

  // Dilution simple.
  final Map<String, double?> _simpleValues = {};
  final Map<String, String> _simpleUnits = {
    'c1': 'mg/dL', 'c2': 'mg/dL', 'v1': 'mL', 'v2': 'mL',
  };

  // Série.
  double? _stock;
  String _stockUnit = 'mg/dL';
  double? _factor;
  double? _tubes;
  double? _finalVolume;
  String _volumeUnit = 'mL';

  // Hors linéarité.
  double? _diluted;
  String _resultUnit = 'U/L';
  String _stepsText = '';
  double? _totalFactorDirect;
  double? _linMin;
  double? _linMax;

  void _run(void Function() body) {
    try {
      body();
    } on CalculationInputException catch (e) {
      setState(() {
        _errors = fieldErrorMap(e);
        _result = null;
        _series = null;
      });
    }
  }

  void _calculate(AppSettings settings) {
    _run(() {
      switch (_mode) {
        case _Mode.simple:
          final r = calculateDilution(
            c1: _simpleValues['c1'], c1Unit: _simpleUnits['c1']!,
            v1: _simpleValues['v1'], v1Unit: _simpleUnits['v1']!,
            c2: _simpleValues['c2'], c2Unit: _simpleUnits['c2']!,
            v2: _simpleValues['v2'], v2Unit: _simpleUnits['v2']!,
          );
          setState(() {
            _errors = {};
            _result = r;
            _series = null;
          });
        case _Mode.series:
          final tubes = _tubes;
          final s = calculateSerialDilution(
            stockConcentration: _stock,
            concentrationUnit: _stockUnit,
            factor: _factor,
            tubes: tubes != null && tubes == tubes.roundToDouble() ? tubes.toInt() : null,
            finalVolume: _finalVolume,
            volumeUnit: _volumeUnit,
          );
          setState(() {
            _errors = {};
            _result = s.result;
            _series = s;
          });
        case _Mode.linearity:
          final double? total;
          if (_stepsText.trim().isNotEmpty) {
            final parts = _stepsText.split(';').map((p) => p.trim()).where((p) => p.isNotEmpty);
            final parsed = [
              for (final p in parts) NumberFormatService.parse(p, settings.decimalSeparator),
            ];
            if (parsed.any((v) => v == null)) {
              throw CalculationInputException(const [
                FieldError(
                    fieldId: 'factors',
                    message: 'Facteurs illisibles : séparez-les par un point-virgule (ex. 2 ; 5).'),
              ]);
            }
            total = cumulativeDilutionFactor(parsed.cast<double>());
          } else {
            total = _totalFactorDirect;
          }
          final r = calculateOutOfRangeDilution(
            dilutedResult: _diluted,
            resultUnit: _resultUnit.trim().isEmpty ? '(unité non précisée)' : _resultUnit.trim(),
            totalFactor: total,
            linearityMin: _linMin,
            linearityMax: _linMax,
          );
          setState(() {
            _errors = {};
            _result = r;
            _series = null;
          });
      }
    });
  }

  /// Volumes à pipeter (µL) déduits du résultat courant.
  Map<String, double> _pipetteVolumes() {
    final r = _result;
    if (r == null || _mode == _Mode.linearity) return const {};
    double? ul(double? v, String unit) {
      final u = LabUnits.parse(unit);
      return v == null || u == null || u.dimension != LabDimension.volume ? null : v * u.factorToBase * 1e6;
    }

    final out = <String, double>{};
    if (_mode == _Mode.simple) {
      final v1 = r.values.where((v) => v.label.startsWith('V1')).firstOrNull;
      final fromResult = v1 == null ? null : ul(v1.value, v1.unit);
      final fromInput = ul(_simpleValues['v1'], _simpleUnits['v1']!);
      final sample = fromResult ?? fromInput;
      if (sample != null) out['Volume à prélever (V1)'] = sample;
      final diluent = r.values.where((v) => v.label.startsWith('Volume de diluant')).firstOrNull;
      final d = diluent == null ? null : ul(diluent.value, diluent.unit);
      if (d != null) out['Volume de diluant'] = d;
    } else {
      for (final v in r.values) {
        if (v.label.startsWith('Volume transféré') || v.label.startsWith('Volume de diluant')) {
          final x = ul(v.value, v.unit);
          if (x != null) out[v.label] = x;
        }
      }
    }
    return out;
  }

  void _reset() => setState(() {
        _simpleValues.clear();
        _stock = _factor = _tubes = _finalVolume = null;
        _diluted = _totalFactorDirect = _linMin = _linMax = null;
        _stepsText = '';
        _errors = {};
        _result = null;
        _series = null;
        _generation++;
      });

  Widget _number(String id, String label, double? value, void Function(double?) set,
      DecimalSeparator sep,
      {List<String>? units, String? unit, ValueChanged<String>? onUnit, String? help}) {
    return NumericUnitField(
      key: ValueKey('$id-$_generation'),
      label: label,
      helpText: help,
      value: value,
      unit: unit ?? '',
      units: units,
      decimalSeparator: sep,
      errorText: _errors[id],
      onValueChanged: (v) => setState(() => set(v)),
      onUnitChanged: (u) => setState(() => onUnit?.call(u)),
    );
  }

  Widget _simpleForm(DecimalSeparator sep) {
    Widget row(String id, String label, List<String> units) => _number(
          id,
          label,
          _simpleValues[id],
          (v) => _simpleValues[id] = v,
          sep,
          units: units,
          unit: _simpleUnits[id],
          onUnit: (u) => _simpleUnits[id] = u,
        );
    return Column(children: [
      const Text('Renseignez trois grandeurs sur quatre : la quatrième est calculée.'),
      row('c1', 'C1 — concentration de départ', LabUnits.massConcentrations + LabUnits.molarConcentrations + LabUnits.equivalentConcentrations),
      row('v1', 'V1 — volume prélevé', LabUnits.volumes),
      row('c2', 'C2 — concentration finale', LabUnits.massConcentrations + LabUnits.molarConcentrations + LabUnits.equivalentConcentrations),
      row('v2', 'V2 — volume final', LabUnits.volumes),
    ]);
  }

  Widget _seriesForm(DecimalSeparator sep) => Column(children: [
        _number('stockConcentration', 'Concentration de départ', _stock, (v) => _stock = v, sep,
            units: LabUnits.massConcentrations + LabUnits.molarConcentrations + LabUnits.equivalentConcentrations,
            unit: _stockUnit,
            onUnit: (u) => _stockUnit = u),
        _number('factor', 'Facteur de dilution par étape (F)', _factor, (v) => _factor = v, sep,
            help: 'Volume final / volume transféré (ex. 10 pour 1 volume dans 10 au total).'),
        _number('tubes', 'Nombre de tubes (1 à 20)', _tubes, (v) => _tubes = v, sep),
        _number('finalVolume', 'Volume final par tube', _finalVolume, (v) => _finalVolume = v, sep,
            units: LabUnits.volumes, unit: _volumeUnit, onUnit: (u) => _volumeUnit = u),
      ]);

  Widget _linearityForm(DecimalSeparator sep) => Column(children: [
        _number('dilutedResult', 'Résultat obtenu sur l\'échantillon dilué', _diluted,
            (v) => _diluted = v, sep),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
            key: ValueKey('unit-$_generation'),
            initialValue: _resultUnit,
            decoration: const InputDecoration(labelText: 'Unité du résultat (libre)'),
            onChanged: (v) => setState(() => _resultUnit = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
            key: ValueKey('steps-$_generation'),
            initialValue: _stepsText,
            decoration: InputDecoration(
              labelText: 'Facteurs de chaque étape (séparés par « ; »)',
              helperText: 'Ex. « 2 ; 5 » = dilution au 1/2 puis au 1/5 (total 10). '
                  'Ou laissez vide et saisissez le facteur total ci-dessous.',
              helperMaxLines: 3,
              errorText: _errors['factors'],
              errorMaxLines: 3,
            ),
            onChanged: (v) => setState(() => _stepsText = v),
          ),
        ),
        _number('totalFactor', 'Facteur de dilution total (si pas d\'étapes)', _totalFactorDirect,
            (v) => _totalFactorDirect = v, sep),
        _number('linearityMin', 'Limite basse de linéarité de la méthode', _linMin,
            (v) => _linMin = v, sep,
            help: 'Intervalle propre à votre méthode et automate : BioSigma n\'en fournit pas.'),
        _number('linearityMax', 'Limite haute de linéarité de la méthode', _linMax,
            (v) => _linMax = v, sep),
      ]);

  Widget _seriesTable(SerialDilutionResult s, DecimalSeparator sep) {
    String f(double v, {int? d}) =>
        NumberFormatService.format(v, sep, precision: d ?? LabUnits.decimalsForSignificant(v));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        columns: const [
          DataColumn(label: Text('Tube')),
          DataColumn(label: Text('Prélevé')),
          DataColumn(label: Text('Diluant')),
          DataColumn(label: Text('Facteur')),
          DataColumn(label: Text('Dilution cumulée')),
          DataColumn(label: Text('Concentration')),
        ],
        rows: [
          for (final r in s.rows)
            DataRow(cells: [
              DataCell(Text('${r.tube}')),
              DataCell(Text('${f(r.transferredVolume)} $_volumeUnit')),
              DataCell(Text('${f(r.diluentVolume)} $_volumeUnit')),
              DataCell(Text(f(r.stepFactor, d: 2))),
              DataCell(Text('1/${f(r.cumulativeFactor, d: 0)}')),
              DataCell(Text('${f(r.concentration)} $_stockUnit')),
            ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final sep = appState.settings.decimalSeparator;
    final knownIds = {
      'c1', 'c2', 'v1', 'v2', 'stockConcentration', 'factor', 'tubes', 'finalVolume',
      'dilutedResult', 'factors', 'totalFactor', 'linearityMin', 'linearityMax',
    };
    final general = _errors.entries.where((e) => !knownIds.contains(e.key)).map((e) => e.value);

    return Scaffold(
      appBar: AppBar(title: const Text('Dilute')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DisclaimerBanner(),
            const SizedBox(height: 12),
            SegmentedButton<_Mode>(
              segments: const [
                ButtonSegment(value: _Mode.simple, label: Text('Simple')),
                ButtonSegment(value: _Mode.series, label: Text('En série')),
                ButtonSegment(value: _Mode.linearity, label: Text('Hors linéarité')),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() {
                _mode = s.first;
                _errors = {};
                _result = null;
                _series = null;
              }),
            ),
            const SizedBox(height: 12),
            switch (_mode) {
              _Mode.simple => _simpleForm(sep),
              _Mode.series => _seriesForm(sep),
              _Mode.linearity => _linearityForm(sep),
            },
            for (final message in general) LabErrorText(message),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(
                  onPressed: () => _calculate(appState.settings),
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculer')),
              OutlinedButton.icon(
                  onPressed: _reset, icon: const Icon(Icons.refresh), label: const Text('Nouvelle saisie')),
            ]),
            if (_result != null) ...[
              const SizedBox(height: 16),
              LabResultCard(
                result: _result!,
                decimalSeparator: sep,
                extra: _series == null ? null : _seriesTable(_series!, sep),
              ),
              if (_pipetteVolumes().isNotEmpty) PipetabilityCard(volumesUl: _pipetteVolumes()),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
