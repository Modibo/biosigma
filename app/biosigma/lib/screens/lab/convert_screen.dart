import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/disclaimer_banner.dart';
import '../../widgets/lab_widgets.dart';
import '../../widgets/numeric_unit_field.dart';

/// Convert : conversion de grandeurs (préfixes SI, masse molaire et valence
/// saisies) ou d'un analyte clinique (facteurs existants du moteur).
class ConvertScreen extends StatefulWidget {
  const ConvertScreen({super.key});

  @override
  State<ConvertScreen> createState() => _ConvertScreenState();
}

enum _Mode { units, analyte }

class _ConvertScreenState extends State<ConvertScreen> {
  static final List<String> _allUnits = [
    for (final list in LabUnits.offered.values) ...list,
  ];

  _Mode _mode = _Mode.units;
  double? _value;
  String _from = 'mg/dL';
  String _to = 'mmol/L';
  double? _molarMass;
  double? _valence;
  Analyte _analyte = Analyte.glucose;
  String _analyteFrom = 'mg/dL';
  String _analyteTo = 'mmol/L';
  int _generation = 0;
  Map<String, String> _errors = {};
  CalculationResult? _result;

  bool _needs(bool Function(LabUnit, LabUnit) test) {
    final a = LabUnits.parse(_from), b = LabUnits.parse(_to);
    if (a == null || b == null) return false;
    if (a.isConcentration != b.isConcentration) return false;
    if (a.dimension == LabDimension.volume || b.dimension == LabDimension.volume) return false;
    return a.quantityKind != b.quantityKind && test(a, b);
  }

  bool get _needsMolarMass => _needs((a, b) =>
      a.quantityKind == LabDimension.mass || b.quantityKind == LabDimension.mass);
  bool get _needsValence => _needs((a, b) =>
      a.quantityKind == LabDimension.equivalent || b.quantityKind == LabDimension.equivalent);

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
          : calculateAnalyteConversion(
              analyte: _analyte, value: _value, fromUnit: _analyteFrom, toUnit: _analyteTo);
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

  @override
  Widget build(BuildContext context) {
    final sep = context.watch<AppState>().settings.decimalSeparator;
    final analyteUnits = UnitRegistry.unitsFor(_analyte);
    final knownIds = {'value', 'fromUnit', 'toUnit', 'molarMass', 'valence'};
    final general = _errors.entries.where((e) => !knownIds.contains(e.key)).map((e) => e.value);

    return Scaffold(
      appBar: AppBar(title: const Text('Convert')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DisclaimerBanner(),
            const SizedBox(height: 12),
            SegmentedButton<_Mode>(
              segments: const [
                ButtonSegment(value: _Mode.units, label: Text('Unités')),
                ButtonSegment(value: _Mode.analyte, label: Text('Analyte clinique')),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() {
                _mode = s.first;
                _errors = {};
                _result = null;
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _mode == _Mode.units
                  ? 'Conversion par préfixes SI. Pour passer d\'une masse à une quantité de matière '
                      'ou à des équivalents, la masse molaire et la valence sont à saisir : '
                      'BioSigma n\'en fournit aucune.'
                  : 'Conversions des 11 analytes déjà gérés par les calculateurs, avec leurs '
                      'facteurs actuels (arrondis, non validés par un biologiste responsable).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            if (_mode == _Mode.analyte)
              LabDropdown(
                label: 'Analyte',
                value: analyteConversionLabels[_analyte]!,
                options: analyteConversionLabels.values.toList(),
                onChanged: (label) => setState(() {
                  _analyte = analyteConversionLabels.entries.firstWhere((e) => e.value == label).key;
                  final units = UnitRegistry.unitsFor(_analyte);
                  _analyteFrom = units.first;
                  _analyteTo = units.last;
                  _result = null;
                }),
              ),
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
              value: _mode == _Mode.units ? _from : _analyteFrom,
              options: _mode == _Mode.units ? _allUnits : analyteUnits,
              errorText: _errors['fromUnit'],
              onChanged: (u) => setState(() {
                if (_mode == _Mode.units) {
                  _from = u;
                } else {
                  _analyteFrom = u;
                }
              }),
            ),
            LabDropdown(
              label: 'Unité d\'arrivée',
              value: _mode == _Mode.units ? _to : _analyteTo,
              options: _mode == _Mode.units ? _allUnits : analyteUnits,
              errorText: _errors['toUnit'],
              onChanged: (u) => setState(() {
                if (_mode == _Mode.units) {
                  _to = u;
                } else {
                  _analyteTo = u;
                }
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
                helpText: 'Nombre de charges par ion (ex. 1 pour Na⁺, 2 pour Ca²⁺).',
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
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(
                  onPressed: _calculate, icon: const Icon(Icons.swap_horiz), label: const Text('Convertir')),
              OutlinedButton.icon(
                  onPressed: _reset, icon: const Icon(Icons.refresh), label: const Text('Nouvelle saisie')),
            ]),
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
