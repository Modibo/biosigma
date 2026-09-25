import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../state/app_state.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/formula_reference_section.dart';
import '../widgets/numeric_unit_field.dart';
import '../widgets/result_value_tile.dart';
import '../widgets/warning_list.dart';

/// Panel DFG CKD-EPI : jusqu'à trois résultats (créatinine seule,
/// cystatine C seule, combiné) affichés côte à côte lorsque les données
/// sont disponibles, chacun avec sa propre fiche technique — sans jamais
/// mélanger les versions d'équation, conformément au cahier des charges.
class CkdEpiPanelScreen extends StatefulWidget {
  const CkdEpiPanelScreen({super.key});

  @override
  State<CkdEpiPanelScreen> createState() => _CkdEpiPanelScreenState();
}

class _CkdEpiPanelScreenState extends State<CkdEpiPanelScreen> {
  double? _age;
  Sex _sex = Sex.female;
  double? _creatinine;
  String _creatinineUnit = 'µmol/L';
  double? _cystatinC;
  final String _cystatinCUnit = 'mg/L';
  bool _idmsConfirmed = false;

  CalculationResult? _creatResult;
  String? _creatError;
  CalculationResult? _cystResult;
  String? _cystError;
  CalculationResult? _combinedResult;
  String? _combinedError;
  bool _calculated = false;

  void _calculate() {
    setState(() {
      _calculated = true;
      _creatResult = null;
      _creatError = null;
      _cystResult = null;
      _cystError = null;
      _combinedResult = null;
      _combinedError = null;

      if (_age == null) return;

      if (_creatinine != null) {
        try {
          _creatResult = calculateCkdEpiCreatinine2021(
            age: _age!,
            sex: _sex,
            creatinineValue: _creatinine!,
            creatinineUnit: _creatinineUnit,
            idmsConfirmed: _idmsConfirmed,
          );
        } on CalculationInputException catch (e) {
          _creatError = e.errors.map((x) => x.message).join(' ');
        }
      }
      if (_cystatinC != null) {
        try {
          _cystResult = calculateCkdEpiCystatinC2012(
            age: _age!,
            sex: _sex,
            cystatinCValue: _cystatinC!,
            cystatinCUnit: _cystatinCUnit,
          );
        } on CalculationInputException catch (e) {
          _cystError = e.errors.map((x) => x.message).join(' ');
        }
      }
      if (_creatinine != null && _cystatinC != null) {
        try {
          _combinedResult = calculateCkdEpiCreatinineCystatinC2021(
            age: _age!,
            sex: _sex,
            creatinineValue: _creatinine!,
            creatinineUnit: _creatinineUnit,
            cystatinCValue: _cystatinC!,
            cystatinCUnit: _cystatinCUnit,
            idmsConfirmed: _idmsConfirmed,
          );
        } on CalculationInputException catch (e) {
          _combinedError = e.errors.map((x) => x.message).join(' ');
        }
      }
    });
  }

  int _formGeneration = 0;

  void _reset() {
    setState(() {
      _age = null;
      _creatinine = null;
      _cystatinC = null;
      _idmsConfirmed = false;
      _creatResult = null;
      _cystResult = null;
      _combinedResult = null;
      _creatError = null;
      _cystError = null;
      _combinedError = null;
      _calculated = false;
      // Force la recréation des champs (non contrôlés) pour qu'ils
      // s'affichent réellement vides après réinitialisation.
      _formGeneration++;
    });
  }

  Future<void> _copyAll() async {
    final buffer = StringBuffer();
    for (final r in [_creatResult, _cystResult, _combinedResult]) {
      if (r == null) continue;
      buffer.writeln(r.formula.name);
      for (final v in r.values) {
        buffer.writeln('  ${v.label} : ${v.isComputed ? v.value!.toStringAsFixed(v.precision) : "non calculé"} ${v.unit}');
      }
      buffer.writeln();
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Résultats copiés dans le presse-papiers.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final separator = appState.settings.decimalSeparator;

    return Scaffold(
      appBar: AppBar(title: const Text('DFG — panel CKD-EPI')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DisclaimerBanner(),
            const SizedBox(height: 12),
            Text(
              'Renseignez la créatinine et/ou la cystatine C : les équations disponibles '
              'sont calculées séparément et affichées côte à côte, sans jamais être mélangées.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            NumericUnitField(
              key: ValueKey('age-$_formGeneration'),
              label: 'Âge',
              helpText: 'Adulte ≥ 18 ans pour les trois équations.',
              value: _age,
              unit: 'ans',
              units: const ['ans'],
              decimalSeparator: separator,
              onValueChanged: (v) => setState(() => _age = v),
              onUnitChanged: (_) {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: DropdownButtonFormField<Sex>(
                key: ValueKey('sex-$_formGeneration'),
                initialValue: _sex,
                decoration: const InputDecoration(labelText: 'Sexe'),
                items: const [
                  DropdownMenuItem(value: Sex.female, child: Text('Femme')),
                  DropdownMenuItem(value: Sex.male, child: Text('Homme')),
                ],
                onChanged: (v) => setState(() => _sex = v ?? Sex.female),
              ),
            ),
            NumericUnitField(
              key: ValueKey('creatinine-$_formGeneration'),
              label: 'Créatininémie (facultatif)',
              helpText: null,
              value: _creatinine,
              unit: _creatinineUnit,
              units: unitsForAnalyte(Analyte.creatinine),
              decimalSeparator: separator,
              onValueChanged: (v) => setState(() => _creatinine = v),
              onUnitChanged: (u) => setState(() => _creatinineUnit = u),
            ),
            NumericUnitField(
              key: ValueKey('cystatinC-$_formGeneration'),
              label: 'Cystatine C (facultatif)',
              helpText: null,
              value: _cystatinC,
              unit: _cystatinCUnit,
              units: unitsForAnalyte(Analyte.cystatinC),
              decimalSeparator: separator,
              onValueChanged: (v) => setState(() => _cystatinC = v),
              onUnitChanged: (_) {},
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _idmsConfirmed,
              title: const Text('Créatininémie standardisée IDMS confirmée'),
              subtitle: const Text('Requis pour toute équation utilisant la créatinine.'),
              onChanged: (v) => setState(() => _idmsConfirmed = v ?? false),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculer')),
              if (_creatResult != null || _cystResult != null || _combinedResult != null)
                OutlinedButton.icon(
                    onPressed: () => setState(() {
                          _creatResult = null;
                          _cystResult = null;
                          _combinedResult = null;
                          _creatError = null;
                          _cystError = null;
                          _combinedError = null;
                        }),
                    icon: const Icon(Icons.clear),
                    label: const Text('Effacer le résultat')),
              OutlinedButton.icon(
                  onPressed: _reset, icon: const Icon(Icons.refresh), label: const Text('Nouvelle saisie')),
              if (_creatResult != null || _cystResult != null || _combinedResult != null)
                OutlinedButton.icon(
                    onPressed: _copyAll, icon: const Icon(Icons.copy), label: const Text('Copier')),
            ]),
            if (_calculated && _creatinine == null && _cystatinC == null)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Renseignez au moins la créatinine ou la cystatine C.'),
              ),
            const SizedBox(height: 16),
            _ResultCard(title: 'CKD-EPI créatinine 2021', result: _creatResult, error: _creatError, separator: separator, meta: ckdEpiCreatinine2021Meta),
            _ResultCard(title: 'CKD-EPI cystatine C 2012', result: _cystResult, error: _cystError, separator: separator, meta: ckdEpiCystatinC2012Meta),
            _ResultCard(title: 'CKD-EPI créatinine-cystatine C 2021', result: _combinedResult, error: _combinedError, separator: separator, meta: ckdEpiCreatinineCystatinC2021Meta),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.result,
    required this.error,
    required this.separator,
    required this.meta,
  });

  final String title;
  final CalculationResult? result;
  final String? error;
  final DecimalSeparator separator;
  final FormulaMeta meta;

  @override
  Widget build(BuildContext context) {
    if (result == null && error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (error != null)
                Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error))
              else ...[
                ...result!.values.map((v) => ResultValueTile(result: v, decimalSeparator: separator)),
                WarningList(warnings: result!.warnings),
              ],
              const SizedBox(height: 8),
              FormulaReferenceSection(meta: meta),
            ],
          ),
        ),
      ),
    );
  }
}
