import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_settings.dart';
import '../../services/number_format_service.dart';
import '../../state/app_state.dart';
import '../../widgets/disclaimer_banner.dart';
import '../../widgets/lab_widgets.dart';

enum _Mode { dilution, product, linear }

/// Mode Expert : propagation d'incertitude (GUM, premier ordre, grandeurs non
/// corrélées). Les incertitudes-types et le facteur k sont saisis par vous ;
/// aucune valeur d'incertitude n'est fournie par BioSigma.
class UncertaintyScreen extends StatefulWidget {
  const UncertaintyScreen({super.key});

  @override
  State<UncertaintyScreen> createState() => _UncertaintyScreenState();
}

class _Row {
  double? value, u;

  /// Valeur absolue du coefficient/exposant (les champs numériques n'acceptent
  /// pas de signe : il se choisit à part).
  double? magnitude = 1;
  bool negative = false;
}

class _UncertaintyScreenState extends State<UncertaintyScreen> with LabFormMixin<UncertaintyScreen> {
  _Mode _mode = _Mode.dilution;
  double? _k = 2;
  double _constant = 1;
  final List<_Row> _rows = [_Row(), _Row(), _Row()];

  // Aide à l'évaluation d'une incertitude-type.
  String _repeatsText = '';
  double? _halfWidth, _expanded, _expandedK;
  String? _helperResult, _helperError;

  static const _dilutionNames = ['C1', 'V1', 'V2'];
  static const _dilutionWeights = [1.0, 1.0, -1.0];

  String _name(int i) => _mode == _Mode.dilution ? _dilutionNames[i] : 'x${i + 1}';

  void _setMode(_Mode m) => setState(() {
        _mode = m;
        while (_rows.length < 3) {
          _rows.add(_Row());
        }
        if (m == _Mode.dilution && _rows.length > 3) _rows.removeRange(3, _rows.length);
        clearResult();
        generation++;
      });

  void _calculate() {
    final missing = <String, String>{};
    for (var i = 0; i < _rows.length; i++) {
      if (_rows[i].value == null) missing['value:${_name(i)}'] = 'Valeur requise.';
      if (_rows[i].u == null) missing['uncertainty:${_name(i)}'] = 'Incertitude-type requise (0 si négligeable).';
      if (_mode != _Mode.dilution && _rows[i].magnitude == null) {
        missing['weight:${_name(i)}'] = 'Valeur requise (1 par défaut).';
      }
    }
    if (_k == null) missing['coverageFactor'] = 'Facteur d\'élargissement k requis.';
    if (missing.isNotEmpty) {
      setState(() {
        errors = missing;
        result = null;
      });
      return;
    }
    runCalc(() => calculateUncertainty(
          model: _mode == _Mode.linear ? UncertaintyModel.linear : UncertaintyModel.product,
          constant: _mode == _Mode.product ? _constant : 1,
          coverageFactor: _k!,
          inputs: [
            for (var i = 0; i < _rows.length; i++)
              UncertaintyInput(
                name: _name(i),
                value: _rows[i].value!,
                standardUncertainty: _rows[i].u!,
                weight: _mode == _Mode.dilution
                    ? _dilutionWeights[i]
                    : (_rows[i].negative ? -1 : 1) * _rows[i].magnitude!,
              ),
          ],
        ));
  }

  void _helperRun(String kind, DecimalSeparator sep) {
    try {
      final double u;
      switch (kind) {
        case 'a':
          final list = parseNumberList(_repeatsText, sep);
          if (list.any((v) => v == null)) {
            throw const FormatException('Valeur illisible : séparez-les par « ; » ou un retour à la ligne.');
          }
          u = standardUncertaintyOfMean(list.cast<double>());
        case 'b':
          if (_halfWidth == null) throw const FormatException('Demi-largeur requise.');
          u = standardUncertaintyRectangular(_halfWidth!);
        default:
          if (_expanded == null || _expandedK == null) throw const FormatException('U et k requis.');
          u = standardUncertaintyFromExpanded(_expanded!, _expandedK!);
      }
      setState(() {
        _helperError = null;
        _helperResult = 'Incertitude-type u = ${NumberFormatService.format(u, sep, precision: 5)}';
      });
    } on FormatException catch (e) {
      setState(() {
        _helperError = e.message;
        _helperResult = null;
      });
    } on CalculationInputException catch (e) {
      setState(() {
        _helperError = e.errors.map((x) => x.message).join(' ');
        _helperResult = null;
      });
    }
  }

  void _reset() => setState(() {
        _k = 2;
        _constant = 1;
        _rows
          ..clear()
          ..addAll([_Row(), _Row(), _Row()]);
        clearResult();
        generation++;
      });

  @override
  Widget build(BuildContext context) {
    final sep = context.watch<AppState>().settings.decimalSeparator;
    final theme = Theme.of(context);
    final weightLabel = _mode == _Mode.linear ? 'Coefficient c' : 'Exposant p';
    return Scaffold(
      appBar: AppBar(title: const Text('Incertitude (mode Expert)')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DisclaimerBanner(),
            const SizedBox(height: 12),
            Text(
              'Propagation d\'incertitude selon le GUM (JCGM 100:2008, § 5.1), au premier ordre et pour des '
              'grandeurs non corrélées. Les incertitudes-types et le facteur k sont les vôtres : BioSigma '
              'n\'en propose aucun.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ModeChips<_Mode>(
              options: const [
                (_Mode.dilution, 'Dilution C2 = C1·V1/V2'),
                (_Mode.product, 'Produit / quotient'),
                (_Mode.linear, 'Somme pondérée'),
              ],
              selected: _mode,
              onSelected: _setMode,
            ),
            if (_mode == _Mode.product)
              numberField(
                id: 'constant',
                label: 'Constante c',
                value: _constant,
                set: (v) => _constant = v ?? 1,
                separator: sep,
                help: 'Y = c · Π xᵢ^pᵢ ; laisser 1 si aucune constante.',
              ),
            for (var i = 0; i < _rows.length; i++) ...[
              const SizedBox(height: 8),
              Text(_name(i), style: theme.textTheme.titleSmall),
              numberField(
                id: 'value:${_name(i)}',
                label: 'Valeur de ${_name(i)}',
                value: _rows[i].value,
                set: (v) => _rows[i].value = v,
                separator: sep,
              ),
              numberField(
                id: 'uncertainty:${_name(i)}',
                label: 'Incertitude-type u(${_name(i)})',
                value: _rows[i].u,
                set: (v) => _rows[i].u = v,
                separator: sep,
                help: 'Même unité que la valeur.',
              ),
              if (_mode != _Mode.dilution) ...[
                ModeChips<bool>(
                  options: _mode == _Mode.linear
                      ? const [(false, 'Ajoutée (+)'), (true, 'Retranchée (−)')]
                      : const [(false, 'Au numérateur'), (true, 'Au dénominateur')],
                  selected: _rows[i].negative,
                  onSelected: (v) => setState(() => _rows[i].negative = v),
                ),
                numberField(
                  id: 'weight:${_name(i)}',
                  label: '$weightLabel de ${_name(i)} (valeur absolue)',
                  value: _rows[i].magnitude,
                  set: (v) => _rows[i].magnitude = v,
                  separator: sep,
                  help: _mode == _Mode.linear
                      ? 'Y = Σ cᵢ·xᵢ ; le signe se choisit ci-dessus.'
                      : 'Y = c·Π xᵢ^pᵢ ; 1 pour une grandeur simple, 2 pour un carré, 0,5 pour une racine.',
                ),
              ],
            ],
            if (_mode != _Mode.dilution)
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(spacing: 8, children: [
                  TextButton.icon(
                    onPressed: _rows.length >= 8 ? null : () => setState(() => _rows.add(_Row())),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une grandeur'),
                  ),
                  if (_rows.length > 1)
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _rows.removeLast();
                        generation++;
                      }),
                      icon: const Icon(Icons.remove),
                      label: const Text('Retirer la dernière'),
                    ),
                ]),
              ),
            const SizedBox(height: 8),
            numberField(
              id: 'coverageFactor',
              label: 'Facteur d\'élargissement k',
              value: _k,
              set: (v) => _k = v,
              separator: sep,
              help: 'Souvent 2 (≈ 95 % pour une loi normale, GUM § 6.3) : à choisir selon votre besoin.',
            ),
            otherErrors({
              'coverageFactor',
              for (var i = 0; i < _rows.length; i++) ...[
                'value:${_name(i)}',
                'uncertainty:${_name(i)}',
                'weight:${_name(i)}',
              ],
            }),
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
            ExpansionTile(
              title: const Text('Évaluer une incertitude-type'),
              subtitle: const Text('Répétitions (type A), bornes (type B), incertitude élargie'),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 4),
              children: [
                TextFormField(
                  key: ValueKey('repeats-$generation'),
                  initialValue: _repeatsText,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Type A : répétitions (« ; » ou une par ligne)',
                    helperText: 'u = s/√n (GUM § 4.2.3)',
                  ),
                  onChanged: (v) => _repeatsText = v,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(onPressed: () => _helperRun('a', sep), child: const Text('Calculer u (type A)')),
                ),
                numberField(
                  id: 'halfWidth',
                  label: 'Type B : demi-largeur a (loi rectangulaire)',
                  value: _halfWidth,
                  set: (v) => _halfWidth = v,
                  separator: sep,
                  help: 'u = a/√3 (GUM § 4.3.7)',
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(onPressed: () => _helperRun('b', sep), child: const Text('Calculer u (type B)')),
                ),
                numberField(
                  id: 'expanded',
                  label: 'Incertitude élargie U donnée',
                  value: _expanded,
                  set: (v) => _expanded = v,
                  separator: sep,
                ),
                numberField(
                  id: 'expandedK',
                  label: 'Facteur k associé',
                  value: _expandedK,
                  set: (v) => _expandedK = v,
                  separator: sep,
                  help: 'u = U/k',
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(onPressed: () => _helperRun('c', sep), child: const Text('Calculer u (U/k)')),
                ),
                if (_helperResult != null)
                  Semantics(liveRegion: true, child: Text(_helperResult!, style: theme.textTheme.titleSmall)),
                if (_helperError != null) LabErrorText(_helperError!),
                const SizedBox(height: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
