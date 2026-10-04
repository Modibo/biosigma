import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/disclaimer_banner.dart';
import '../../widgets/lab_widgets.dart';

/// Prepare : masse à peser, solutions en pourcentage, tampons.
/// Masse molaire, pureté et pKa sont toujours saisis par l'utilisateur.
class PrepareScreen extends StatefulWidget {
  const PrepareScreen({super.key});

  @override
  State<PrepareScreen> createState() => _PrepareScreenState();
}

enum _Mode { mass, percent, buffer }

class _PrepareScreenState extends State<PrepareScreen> with LabFormMixin<PrepareScreen> {
  static final _concUnits = [...LabUnits.massConcentrations, ...LabUnits.molarConcentrations];

  _Mode _mode = _Mode.mass;
  double? _conc, _volume, _molarMass, _purity, _percent, _ph, _pKa;
  String _concUnit = 'g/L', _volumeUnit = 'mL', _bufferConcUnit = 'mmol/L', _kind = 'm/v';

  bool get _molar => LabUnits.parse(_concUnit)?.dimension == LabDimension.molarConcentration;

  void _calculate() {
    switch (_mode) {
      case _Mode.mass:
        runCalc(() => calculateSolutionPreparation(
              targetConcentration: _conc,
              concentrationUnit: _concUnit,
              finalVolume: _volume,
              volumeUnit: _volumeUnit,
              molarMassGPerMol: _molar ? _molarMass : null,
              purityPercent: _purity,
            ));
      case _Mode.percent:
        runCalc(() => calculatePercentSolution(
              percent: _percent,
              kind: _kind == 'm/v' ? 'mv' : 'vv',
              finalVolume: _volume,
              volumeUnit: _volumeUnit,
            ));
      case _Mode.buffer:
        runCalc(() => calculateBuffer(
              targetPh: _ph,
              pKa: _pKa,
              totalConcentration: _conc,
              concentrationUnit: _bufferConcUnit,
              finalVolume: _volume,
              volumeUnit: _volumeUnit,
            ));
    }
  }

  void _reset() => setState(() {
        _conc = _volume = _molarMass = _purity = _percent = _ph = _pKa = null;
        clearResult();
        generation++;
      });

  @override
  Widget build(BuildContext context) {
    final sep = context.watch<AppState>().settings.decimalSeparator;
    return Scaffold(
      appBar: AppBar(title: const Text('Prepare')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DisclaimerBanner(),
            const SizedBox(height: 12),
            SegmentedButton<_Mode>(
              segments: const [
                ButtonSegment(value: _Mode.mass, label: Text('Masse')),
                ButtonSegment(value: _Mode.percent, label: Text('Pourcentage')),
                ButtonSegment(value: _Mode.buffer, label: Text('Tampon')),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() {
                _mode = s.first;
                clearResult();
              }),
            ),
            const SizedBox(height: 8),
            Text(
              'Masse molaire, pureté et pKa sont à saisir : BioSigma n\'en embarque aucun et ne les vérifie pas.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            if (_mode == _Mode.mass) ...[
              numberField(
                  id: 'targetConcentration', label: 'Concentration cible', value: _conc,
                  set: (v) => _conc = v, separator: sep, units: _concUnits, unit: _concUnit,
                  onUnit: (u) => _concUnit = u),
              numberField(
                  id: 'finalVolume', label: 'Volume final', value: _volume, set: (v) => _volume = v,
                  separator: sep, units: LabUnits.volumes, unit: _volumeUnit, onUnit: (u) => _volumeUnit = u),
              if (_molar)
                numberField(
                    id: 'molarMass', label: 'Masse molaire (g/mol)', value: _molarMass,
                    set: (v) => _molarMass = v, separator: sep,
                    help: 'De la forme réellement pesée (sel, hydrate, forme libre).'),
              numberField(
                  id: 'purity', label: 'Pureté (%) — facultatif', value: _purity, set: (v) => _purity = v,
                  separator: sep, help: 'Certificat du lot ; vide = 100 % supposé (avertissement).'),
            ],
            if (_mode == _Mode.percent) ...[
              LabDropdown(
                  label: 'Type de pourcentage', value: _kind, options: const ['m/v', 'v/v'],
                  helperText: 'm/v : g pour 100 mL de solution finale ; v/v : mL pour 100 mL.',
                  errorText: errors['kind'], onChanged: (v) => setState(() => _kind = v)),
              numberField(
                  id: 'percent', label: 'Pourcentage (%)', value: _percent, set: (v) => _percent = v,
                  separator: sep),
              numberField(
                  id: 'finalVolume', label: 'Volume final', value: _volume, set: (v) => _volume = v,
                  separator: sep, units: LabUnits.volumes, unit: _volumeUnit, onUnit: (u) => _volumeUnit = u),
            ],
            if (_mode == _Mode.buffer) ...[
              numberField(id: 'targetPh', label: 'pH cible', value: _ph, set: (v) => _ph = v, separator: sep),
              numberField(
                  id: 'pKa', label: 'pKa du couple (saisi)', value: _pKa, set: (v) => _pKa = v,
                  separator: sep, help: 'Dépend de la température et de la force ionique.'),
              numberField(
                  id: 'totalConcentration', label: 'Concentration totale du tampon', value: _conc,
                  set: (v) => _conc = v, separator: sep, units: LabUnits.molarConcentrations,
                  unit: _bufferConcUnit, onUnit: (u) => _bufferConcUnit = u),
              numberField(
                  id: 'finalVolume', label: 'Volume final', value: _volume, set: (v) => _volume = v,
                  separator: sep, units: LabUnits.volumes, unit: _volumeUnit, onUnit: (u) => _volumeUnit = u),
            ],
            otherErrors({'targetConcentration', 'finalVolume', 'molarMass', 'purity', 'kind', 'percent',
              'targetPh', 'pKa', 'totalConcentration'}),
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
