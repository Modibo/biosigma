import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Liste des avertissements d'un résultat, colorés selon leur sévérité.
/// Jamais masquée : la sévérité `blocking` doit toujours être visible en
/// évidence forte, conformément au cahier des charges.
class WarningList extends StatelessWidget {
  const WarningList({super.key, required this.warnings});

  final List<CalculationWarning> warnings;

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: warnings.map((w) => _WarningTile(warning: w)).toList(growable: false),
    );
  }
}

class _WarningTile extends StatelessWidget {
  const _WarningTile({required this.warning});
  final CalculationWarning warning;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final (color, icon) = switch (warning.severity) {
      WarningSeverity.blocking => (BioSigmaColors.warningBlockingFor(brightness), Icons.error),
      WarningSeverity.caution => (BioSigmaColors.warningCautionFor(brightness), Icons.warning_amber),
      WarningSeverity.info => (Theme.of(context).colorScheme.primary, Icons.info_outline),
    };
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Semantics(
              liveRegion: warning.severity == WarningSeverity.blocking,
              child: Text(warning.message, style: TextStyle(color: color)),
            ),
          ),
        ],
      ),
    );
  }
}
