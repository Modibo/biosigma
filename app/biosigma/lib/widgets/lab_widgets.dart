import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/number_format_service.dart';
import 'export_dialog.dart';
import 'formula_reference_section.dart';
import 'numeric_unit_field.dart';
import 'result_value_tile.dart';
import 'warning_list.dart';

/// Carte de résultat commune aux modules du laboratoire (Convert, Dilute).
class LabResultCard extends StatelessWidget {
  const LabResultCard({
    super.key,
    required this.result,
    required this.decimalSeparator,
    this.extra,
    this.reportSections = const [],
  });

  final CalculationResult result;
  final DecimalSeparator decimalSeparator;

  /// Contenu supplémentaire sous les valeurs (ex. tableau de dilutions).
  final Widget? extra;

  /// Sections ajoutées au rapport imprimé (ex. étapes d'un plan de dilution).
  final List<ReportSection> reportSections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Résultat', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...result.values
                    .map((v) => ResultValueTile(result: v, decimalSeparator: decimalSeparator)),
                if (extra != null) ...[const SizedBox(height: 8), extra!],
                const SizedBox(height: 8),
                WarningList(warnings: result.warnings),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => showExportDialog(
                      context,
                      result: result,
                      separator: decimalSeparator,
                      extraSections: reportSections,
                    ),
                    icon: const Icon(Icons.print),
                    label: const Text('Imprimer / exporter'),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (result.echoedInputs.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Données et méthode utilisées', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  for (final e in result.echoedInputs.entries) Text('${e.key} : ${e.value}'),
                ],
              ),
            ),
          ),
        FormulaReferenceSection(meta: result.formula),
      ],
    );
  }
}

/// Message d'erreur général (champ sans emplacement propre).
class LabErrorText extends StatelessWidget {
  const LabErrorText(this.message, {super.key});
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(message!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
    );
  }
}

/// Liste déroulante de libellés (unités, analytes…) avec message d'erreur.
class LabDropdown extends StatelessWidget {
  const LabDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.errorText,
    this.helperText,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
            labelText: label, errorText: errorText, helperText: helperText, helperMaxLines: 3),
        items: [for (final o in options) DropdownMenuItem(value: o, child: Text(o))],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

/// Erreurs de champ d'un calcul, indexées par identifiant de champ.
Map<String, String> fieldErrorMap(CalculationInputException e) => {
      for (final err in e.errors) err.fieldId: err.message,
    };

/// Entier à partir d'un nombre saisi (`null` s'il n'est pas entier).
int? asInt(double? v) => v != null && v == v.roundToDouble() ? v.toInt() : null;

/// Liste de nombres saisis, séparés par « ; » ou par des retours à la ligne
/// (la virgule reste le séparateur décimal). Un élément illisible donne `null`.
List<double?> parseNumberList(String text, DecimalSeparator separator) => [
      for (final part in text.split(RegExp(r'[;\n]')).map((p) => p.trim()).where((p) => p.isNotEmpty))
        NumberFormatService.parse(part, separator),
    ];

/// Aides communes aux formulaires des modules Lab : erreurs par champ,
/// remise à zéro, champs numériques.
mixin LabFormMixin<T extends StatefulWidget> on State<T> {
  Map<String, String> errors = {};
  int generation = 0;
  CalculationResult? result;

  /// Exécute un calcul ; une erreur de saisie s'affiche sous le champ concerné.
  void runCalc(CalculationResult Function() body, {void Function()? onSuccess}) {
    try {
      final r = body();
      setState(() {
        errors = {};
        result = r;
        onSuccess?.call();
      });
    } on CalculationInputException catch (e) {
      setState(() {
        errors = fieldErrorMap(e);
        result = null;
      });
    }
  }

  void clearResult() {
    errors = {};
    result = null;
  }

  Widget numberField({
    required String id,
    required String label,
    required double? value,
    required void Function(double?) set,
    required DecimalSeparator separator,
    List<String>? units,
    String? unit,
    ValueChanged<String>? onUnit,
    String? help,
  }) =>
      NumericUnitField(
        key: ValueKey('$id-$generation'),
        label: label,
        helpText: help,
        value: value,
        unit: unit ?? '',
        units: units,
        decimalSeparator: separator,
        errorText: errors[id],
        onValueChanged: (v) => setState(() => set(v)),
        onUnitChanged: (u) => setState(() => onUnit?.call(u)),
      );

  /// Messages d'erreur dont le champ n'est pas dans [knownIds].
  Widget otherErrors(Set<String> knownIds) => Column(children: [
        for (final e in errors.entries.where((e) => !knownIds.contains(e.key))) LabErrorText(e.value),
      ]);
}
