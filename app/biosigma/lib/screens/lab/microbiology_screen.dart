import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/disclaimer_banner.dart';
import '../../widgets/lab_widgets.dart';

/// Microbiology : UFC/mL à partir de boîtes dénombrées (l'intervalle de
/// colonies dénombrables est saisi) et équivalence McFarland (0,5 seulement,
/// valeur saisie par le validateur).
class MicrobiologyScreen extends StatefulWidget {
  const MicrobiologyScreen({super.key});

  @override
  State<MicrobiologyScreen> createState() => _MicrobiologyScreenState();
}

class _PlateInput {
  double? colonies, exponent, volume;
}

enum _Mode { plates, mcfarland }

class _MicrobiologyScreenState extends State<MicrobiologyScreen>
    with LabFormMixin<MicrobiologyScreen> {
  final List<_PlateInput> _plates = [_PlateInput()];
  double? _min, _max;
  _Mode _mode = _Mode.plates;
  double? _standard = 0.5, _target;

  void _calculate() {
    if (_mode == _Mode.mcfarland) {
      runCalc(
        () => calculateMcFarland(standard: _standard, targetCfuPerMl: _target),
      );
      return;
    }
    runCalc(
      () => calculateCfu(
        plates: [
          for (final p in _plates)
            PlateCount(
              colonies: asInt(p.colonies),
              dilutionExponent: asInt(p.exponent),
              platedVolumeMl: p.volume,
            ),
        ],
        countMin: asInt(_min),
        countMax: asInt(_max),
      ),
    );
  }

  void _reset() => setState(() {
    _plates
      ..clear()
      ..add(_PlateInput());
    _min = _max = null;
    _standard = 0.5;
    _target = null;
    clearResult();
    generation++;
  });

  @override
  Widget build(BuildContext context) {
    final sep = context.watch<AppState>().settings.decimalSeparator;
    return Scaffold(
      appBar: AppBar(title: const Text('Microbiology')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DisclaimerBanner(),
            const SizedBox(height: 12),
            ModeChips<_Mode>(
              options: const [
                (_Mode.plates, 'Boîtes (UFC/mL)'),
                (_Mode.mcfarland, 'McFarland'),
              ],
              selected: _mode,
              onSelected: (m) => setState(() {
                _mode = m;
                clearResult();
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _mode == _Mode.mcfarland
                  ? 'Équivalence saisie par le validateur : 0,5 McFarland ≈ 1,5 × 10⁸ UFC/mL. Seul le standard 0,5 '
                        'est renseigné ; aucun autre n\'est embarqué ni extrapolé. La turbidité n\'est pas un '
                        'dénombrement : valeur approximative.'
                  : 'UFC/mL = colonies × 10^k / volume ensemencé. L\'intervalle de colonies dénombrables '
                        'dépend de votre norme : saisissez-le. L\'équivalence McFarland ↔ UFC est dans l\'onglet '
                        '« McFarland » (0,5 seulement).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            if (_mode == _Mode.mcfarland) ...[
              numberField(
                id: 'standard',
                label: 'Standard McFarland',
                value: _standard,
                set: (v) => _standard = v,
                separator: sep,
                help: 'Seul 0,5 est renseigné.',
              ),
              numberField(
                id: 'target',
                label: 'Concentration visée (UFC/mL) — facultatif',
                value: _target,
                set: (v) => _target = v,
                separator: sep,
                help: 'En nombre entier, par exemple 500000 pour 5 × 10⁵ ; donne le facteur de dilution.',
              ),
              otherErrors({'standard', 'target'}),
            ] else ...[
              for (var i = 0; i < _plates.length; i++)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Boîte ${i + 1}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            if (_plates.length > 1)
                              IconButton(
                                tooltip: 'Retirer cette boîte',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => setState(() {
                                  _plates.removeAt(i);
                                  clearResult();
                                  generation++;
                                }),
                              ),
                          ],
                        ),
                        numberField(
                          id: 'colonies$i',
                          label: 'Colonies comptées (entier)',
                          value: _plates[i].colonies,
                          set: (v) => _plates[i].colonies = v,
                          separator: sep,
                        ),
                        numberField(
                          id: 'exponent$i',
                          label: 'Dilution ensemencée 10^(−k) : k (0 à 12)',
                          value: _plates[i].exponent,
                          set: (v) => _plates[i].exponent = v,
                          separator: sep,
                          help: 'k = 0 : suspension non diluée ; k = 3 : dilution au 1/1000.',
                        ),
                        numberField(
                          id: 'volume$i',
                          label: 'Volume ensemencé (mL)',
                          value: _plates[i].volume,
                          set: (v) => _plates[i].volume = v,
                          separator: sep,
                        ),
                      ],
                    ),
                  ),
                ),
              if (_plates.length < 6)
                TextButton.icon(
                  onPressed: () => setState(() {
                    _plates.add(_PlateInput());
                    clearResult();
                  }),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une boîte'),
                ),
              numberField(
                id: 'countMin',
                label: 'Colonies par boîte : borne basse — facultatif',
                value: _min,
                set: (v) => _min = v,
                separator: sep,
              ),
              numberField(
                id: 'countMax',
                label: 'Colonies par boîte : borne haute — facultatif',
                value: _max,
                set: (v) => _max = v,
                separator: sep,
                help: 'Selon votre norme ou votre procédure.',
              ),
              otherErrors({
                'countMin',
                'countMax',
                for (var i = 0; i < _plates.length; i++) ...[
                  'colonies$i',
                  'exponent$i',
                  'volume$i',
                ],
              }),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculer'),
                ),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Nouvelle saisie'),
                ),
              ],
            ),
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
