import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Liste des avertissements d'un résultat, colorés selon leur sévérité.
/// Jamais masquée : la sévérité `blocking` doit toujours être visible en
/// évidence forte, conformément au cahier des charges.
///
/// Niveaux de résultat (backlog P1-16) : la valeur calculée est affichée
/// au-dessus (niveau « calcul ») ; ici, les **alertes** (`blocking`,
/// `caution`) sont séparées des messages d'information (`info`), eux-mêmes
/// regroupés par niveau : précisions analytiques, repères d'interprétation,
/// recommandations publiées (aide à la décision, avec leur source). BioSigma ne
/// formule aucune décision clinique.
class WarningList extends StatelessWidget {
  const WarningList({super.key, required this.warnings});

  final List<CalculationWarning> warnings;

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();
    final alerts = warnings.where((w) => w.severity != WarningSeverity.info).toList(growable: false);
    final levels = groupInfoByLevel(warnings);
    final theme = Theme.of(context);
    Widget heading(String title, {String? caption}) => Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: theme.textTheme.labelLarge),
            if (caption != null) Text(caption, style: theme.textTheme.bodySmall),
          ]),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (alerts.isNotEmpty) ...[
          heading('Alertes'),
          ...alerts.map((w) => _WarningTile(warning: w)),
        ],
        for (final entry in levels.entries) ...[
          heading(entry.key.title, caption: entry.key.caption),
          ...entry.value.map((w) => _WarningTile(warning: w)),
        ],
      ],
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
