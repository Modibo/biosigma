import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import 'formula_reference_section.dart';
import 'result_value_tile.dart';
import 'warning_list.dart';

/// Carte de résultat commune aux modules du laboratoire (Convert, Dilute).
class LabResultCard extends StatelessWidget {
  const LabResultCard({
    super.key,
    required this.result,
    required this.decimalSeparator,
    this.extra,
  });

  final CalculationResult result;
  final DecimalSeparator decimalSeparator;

  /// Contenu supplémentaire sous les valeurs (ex. tableau de dilutions).
  final Widget? extra;

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
