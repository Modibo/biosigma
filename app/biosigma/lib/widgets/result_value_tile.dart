import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/number_format_service.dart';
import '../theme/app_theme.dart';

/// Une valeur de résultat, avec libellé, unité, et rendu distinct quand la
/// valeur n'a pas pu être calculée (hors domaine de validité).
class ResultValueTile extends StatelessWidget {
  const ResultValueTile({super.key, required this.result, required this.decimalSeparator});

  final ResultValue result;
  final DecimalSeparator decimalSeparator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!result.isComputed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.block, color: BioSigmaColors.warningBlocking, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text('${result.label} : non calculé',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: BioSigmaColors.warningBlocking)),
            ),
          ],
        ),
      );
    }
    final formatted = NumberFormatService.format(result.value!, decimalSeparator,
        precision: result.precision);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        label: '${result.label} : $formatted ${result.unit}',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(result.label, style: theme.textTheme.bodyMedium),
            ),
            Text(formatted,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text(result.unit, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
