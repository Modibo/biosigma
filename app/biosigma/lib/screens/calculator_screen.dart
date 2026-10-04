import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../models/calculator_definition.dart';
import '../models/calculator_field.dart';
import '../models/calculation_record.dart';
import '../models/local_threshold.dart';
import '../state/app_state.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/formula_reference_section.dart';
import '../widgets/numeric_unit_field.dart';
import '../widgets/result_value_tile.dart';
import '../widgets/warning_list.dart';

/// Écran calculateur générique : construit le formulaire de saisie à
/// partir d'un [CalculatorDefinition] déclaratif, exécute le calcul,
/// affiche le résultat détaillé, ses avertissements et sa fiche
/// technique. Un seul écran couvre l'ensemble du catalogue standard.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key, required this.definition});

  final CalculatorDefinition definition;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late Map<String, dynamic> _values;
  Map<String, String> _fieldErrors = {};
  CalculationResult? _result;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _values = _initialValues();
  }

  Map<String, dynamic> _initialValues() {
    final map = <String, dynamic>{};
    for (final field in widget.definition.fields) {
      switch (field.kind) {
        case FieldKind.numberWithUnit:
          final unit = field.defaultUnit ?? unitsForAnalyte(field.analyte!).first;
          map[field.id] = NumericEntry(null, unit);
        case FieldKind.numberFixedUnit:
          map[field.id] = NumericEntry(null, field.fixedUnitLabel ?? '');
        case FieldKind.boolean:
          map[field.id] = field.defaultBoolValue;
        case FieldKind.enumSelect:
          map[field.id] = _presetEnumValue(field);
        case FieldKind.text:
          map[field.id] = field.defaultText ?? '';
      }
    }
    return map;
  }

  /// Seule présélection : l'équation LDL choisie dans Réglages. Tout autre
  /// choix reste vide, pour que l'utilisateur le fasse explicitement.
  Object? _presetEnumValue(CalculatorFieldSpec field) {
    if (widget.definition.meta.id == 'ldl_panel' && field.id == 'formula') {
      final friedewald = context.read<AppState>().settings.ldlDefaultFriedewald;
      return friedewald ? LdlFormula.friedewald : LdlFormula.sampson;
    }
    return null;
  }

  int _formGeneration = 0;

  void _resetForm() {
    setState(() {
      _values = _initialValues();
      _fieldErrors = {};
      _result = null;
      _generalError = null;
      // Change de clé pour forcer la recréation des champs de saisie :
      // un TextFormField non contrôlé ne se vide pas tout seul quand sa
      // valeur initiale change après le premier rendu.
      _formGeneration++;
    });
  }

  Future<void> _calculate() async {
    setState(() {
      _fieldErrors = {};
      _generalError = null;
    });

    // Validation de présence côté interface, avant l'appel au moteur.
    final missing = <String, String>{};
    for (final field in widget.definition.fields) {
      if (!field.required) continue;
      final v = _values[field.id];
      if (field.kind == FieldKind.enumSelect && v == null) {
        missing[field.id] = 'Ce champ est requis.';
      } else if (field.kind == FieldKind.text && (v as String).trim().isEmpty) {
        missing[field.id] = 'Ce champ est requis.';
      } else if ((field.kind == FieldKind.numberWithUnit ||
              field.kind == FieldKind.numberFixedUnit) &&
          (v as NumericEntry).value == null) {
        missing[field.id] = 'Ce champ est requis.';
      } else if ((field.kind == FieldKind.numberWithUnit ||
              field.kind == FieldKind.numberFixedUnit) &&
          !field.allowNegative &&
          (v as NumericEntry).value! < 0) {
        missing[field.id] = 'Une valeur négative n\'est pas autorisée ici.';
      }
    }
    if (missing.isNotEmpty) {
      setState(() => _fieldErrors = missing);
      return;
    }

    try {
      final result = widget.definition.compute(_values);
      setState(() => _result = result);
      final appState = context.read<AppState>();
      if (appState.settings.historyEnabled) {
        await appState.recordCalculation(CalculationRecord.fromCalculation(
          definition: widget.definition,
          values: _values,
          result: result,
          now: DateTime.now(),
        ));
      }
    } on CalculationInputException catch (e) {
      setState(() {
        _fieldErrors = {for (final err in e.errors) err.fieldId: err.message};
      });
    } catch (e) {
      setState(() => _generalError = 'Erreur de calcul : $e');
    }
  }

  Future<void> _copyResult() async {
    final r = _result;
    if (r == null) return;
    final buffer = StringBuffer()
      ..writeln(widget.definition.meta.name)
      ..writeln(widget.definition.meta.version)
      ..writeln(widget.definition.meta.equation)
      ..writeln();
    r.echoedInputs.forEach((k, v) => buffer.writeln('$k : $v'));
    buffer.writeln();
    for (final v in r.values) {
      buffer.writeln('${v.label} : '
          '${v.isComputed ? v.value!.toStringAsFixed(v.precision) : "non calculé"} ${v.unit}');
    }
    if (r.warnings.isNotEmpty) {
      buffer.writeln();
      for (final w in r.warnings) {
        buffer.writeln('⚠ ${w.message}');
      }
    }
    buffer.writeln();
    buffer.writeln("Outil d'aide au calcul ; à valider par un professionnel compétent.");
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Résultat copié dans le presse-papiers.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final settings = appState.settings;
    final meta = widget.definition.meta;

    return Scaffold(
      appBar: AppBar(
        title: Text(meta.shortName),
        actions: [
          IconButton(
            tooltip: appState.isFavorite(meta.id) ? 'Retirer des favoris' : 'Ajouter aux favoris',
            icon: Icon(appState.isFavorite(meta.id) ? Icons.star : Icons.star_border),
            onPressed: () => appState.toggleFavorite(meta.id),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DisclaimerBanner(),
            const SizedBox(height: 12),
            Text(meta.name, style: Theme.of(context).textTheme.titleLarge),
            if (meta.helpText != null) ...[
              const SizedBox(height: 4),
              Text(meta.helpText!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            ...widget.definition.fields.map((field) => _buildField(field, settings)),
            if (_generalError != null) ...[
              const SizedBox(height: 8),
              Text(_generalError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calculer'),
                ),
                if (_result != null)
                  OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _result = null;
                      _generalError = null;
                      _fieldErrors = {};
                    }),
                    icon: const Icon(Icons.clear),
                    label: const Text('Effacer le résultat'),
                  ),
                OutlinedButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Nouvelle saisie'),
                ),
                if (_result != null)
                  OutlinedButton.icon(
                    onPressed: _copyResult,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copier'),
                  ),
              ],
            ),
            if (_result != null) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Résultat', style: Theme.of(context).textTheme.titleMedium),
                      if (!_result!.isComplete) ...[
                        const SizedBox(height: 4),
                        Text('Score incomplet',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold)),
                      ],
                      const SizedBox(height: 8),
                      ..._result!.values.map(
                        (v) => ResultValueTile(
                            result: v, decimalSeparator: settings.decimalSeparator),
                      ),
                      const SizedBox(height: 8),
                      WarningList(warnings: _result!.warnings),
                    ],
                  ),
                ),
              ),
              _LocalThresholdsCard(thresholds: appState.thresholdsFor(meta.id)),
              const SizedBox(height: 12),
              _EchoedInputsCard(inputs: _result!.echoedInputs),
            ],
            const SizedBox(height: 16),
            FormulaReferenceSection(meta: meta),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildField(CalculatorFieldSpec field, AppSettings settings) {
    switch (field.kind) {
      case FieldKind.numberWithUnit:
        final entry = _values[field.id] as NumericEntry;
        return NumericUnitField(
          key: ValueKey('${field.id}-$_formGeneration'),
          label: field.label,
          helpText: field.helpText,
          value: entry.value,
          unit: entry.unit,
          units: unitsForAnalyte(field.analyte!),
          decimalSeparator: settings.decimalSeparator,
          errorText: _fieldErrors[field.id],
          onValueChanged: (v) => setState(() => _values[field.id] = entry.copyWith(value: v)),
          onUnitChanged: (u) => setState(() => _values[field.id] = entry.copyWith(unit: u)),
        );
      case FieldKind.numberFixedUnit:
        final entry = _values[field.id] as NumericEntry;
        return NumericUnitField(
          key: ValueKey('${field.id}-$_formGeneration'),
          label: field.label,
          helpText: field.helpText,
          value: entry.value,
          unit: entry.unit,
          units: [field.fixedUnitLabel ?? ''],
          decimalSeparator: settings.decimalSeparator,
          errorText: _fieldErrors[field.id],
          onValueChanged: (v) => setState(() => _values[field.id] = entry.copyWith(value: v)),
          onUnitChanged: (_) {},
        );
      case FieldKind.boolean:
        final value = _values[field.id] as bool;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: value,
            title: Text(field.label),
            subtitle: field.helpText != null ? Text(field.helpText!) : null,
            onChanged: (v) => setState(() => _values[field.id] = v ?? false),
          ),
        );
      case FieldKind.enumSelect:
        final options = field.enumOptions!;
        final current = _values[field.id];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DropdownButtonFormField<int>(
            key: ValueKey('${field.id}-$_formGeneration'),
            initialValue: options.indexWhere((o) => o.value == current) >= 0
                ? options.indexWhere((o) => o.value == current)
                : null,
            decoration: InputDecoration(
              labelText: field.label,
              helperText: field.helpText,
              helperMaxLines: 4,
              errorText: _fieldErrors[field.id],
              errorMaxLines: 4,
            ),
            items: [
              for (var i = 0; i < options.length; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(
                    options[i].description != null
                        ? '${options[i].label} — ${options[i].description}'
                        : options[i].label,
                  ),
                ),
            ],
            onChanged: (i) => setState(() => _values[field.id] = i == null ? null : options[i].value),
            isExpanded: true,
          ),
        );
      case FieldKind.text:
        final value = _values[field.id] as String;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
            key: ValueKey('${field.id}-$_formGeneration'),
            initialValue: value,
            decoration: InputDecoration(
              labelText: field.label,
              helperText: field.helpText,
              helperMaxLines: 3,
              errorText: _fieldErrors[field.id],
            ),
            onChanged: (v) => setState(() => _values[field.id] = v),
          ),
        );
    }
  }
}

class _EchoedInputsCard extends StatelessWidget {
  const _EchoedInputsCard({required this.inputs});
  final Map<String, String> inputs;

  @override
  Widget build(BuildContext context) {
    if (inputs.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Données et unités utilisées', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...inputs.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text('${e.key} : ${e.value}'),
                )),
          ],
        ),
      ),
    );
  }
}

/// Rappel des seuils définis localement par le laboratoire pour ce calcul.
/// Affichage seul : aucune comparaison ni interprétation automatique.
class _LocalThresholdsCard extends StatelessWidget {
  const _LocalThresholdsCard({required this.thresholds});

  final List<LocalThreshold> thresholds;

  @override
  Widget build(BuildContext context) {
    if (thresholds.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Seuils locaux du laboratoire',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Définis par votre laboratoire, non fournis par BioSigma. '
                'Le résultat n\'est pas comparé automatiquement à ces seuils.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final t in thresholds)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${t.label} : ${t.value} ${t.unit}\n${t.method} — validé le '
                    '${t.validatedOn.toLocal().toString().split(' ').first} par ${t.validatedBy}',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
