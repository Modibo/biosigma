import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_settings.dart';
import '../services/number_format_service.dart';

/// Champ de saisie numérique avec sélecteur d'unité optionnel, aide
/// contextuelle et message d'erreur en français affiché sous le champ.
class NumericUnitField extends StatelessWidget {
  const NumericUnitField({
    super.key,
    required this.label,
    required this.helpText,
    required this.value,
    required this.unit,
    required this.units,
    required this.decimalSeparator,
    required this.onValueChanged,
    required this.onUnitChanged,
    this.errorText,
    this.semanticsLabel,
  });

  final String label;
  final String? helpText;
  final double? value;
  final String unit;
  final List<String>? units;
  final DecimalSeparator decimalSeparator;
  final ValueChanged<double?> onValueChanged;
  final ValueChanged<String> onUnitChanged;
  final String? errorText;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final initialText =
        value == null ? '' : NumberFormatService.format(value!, decimalSeparator, precision: 6);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Semantics(
              label: semanticsLabel ?? label,
              child: TextFormField(
                initialValue: initialText,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]')),
                ],
                decoration: InputDecoration(
                  labelText: label,
                  helperText: helpText,
                  helperMaxLines: 3,
                  errorText: errorText,
                  errorMaxLines: 4,
                ),
                onChanged: (text) => onValueChanged(NumberFormatService.parse(text, decimalSeparator)),
              ),
            ),
          ),
          if (units != null && units!.length > 1) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                initialValue: unit,
                decoration: const InputDecoration(labelText: 'Unité'),
                items: units!
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(growable: false),
                onChanged: (u) {
                  if (u != null) onUnitChanged(u);
                },
              ),
            ),
          ] else if (units != null && units!.length == 1) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(units!.first, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Renvoie la liste des unités disponibles pour un [Analyte], dans un
/// ordre stable (unité canonique en premier).
List<String> unitsForAnalyte(Analyte analyte) {
  final canonical = UnitRegistry.canonicalUnit[analyte]!;
  final all = UnitRegistry.unitsFor(analyte);
  return [canonical, ...all.where((u) => u != canonical)];
}
