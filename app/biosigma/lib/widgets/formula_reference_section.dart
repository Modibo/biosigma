import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';

/// Fiche technique d'un calcul : formule exacte, version/source,
/// population d'application, cas interdits, conditions analytiques et
/// limites d'emploi. Toujours visible sous le résultat — jamais un indice
/// isolé sans son contexte scientifique.
class FormulaReferenceSection extends StatelessWidget {
  const FormulaReferenceSection({super.key, required this.meta, this.initiallyExpanded = false});

  final FormulaMeta meta;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text('Formule, version et limites', style: theme.textTheme.titleSmall),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (EquationRegistry.resolve(meta.id) case final record?) ...[
            _section(context, 'Identifiant et statut',
                '${record.stableId} · version ${record.version} · statut : ${record.status.label}'),
          ],
          if (EquationRegistry.resolve(meta.id)?.changeNotes case final notes? when notes.isNotEmpty)
            _bulletSection(context, 'Historique des versions', notes),
          _section(context, 'Version', meta.version),
          _section(context, 'Formule', meta.equation, monospace: true),
          _section(context, 'Population d\'application', meta.applicablePopulation),
          if (meta.analyticalConditions.isNotEmpty)
            _bulletSection(context, 'Conditions analytiques requises', meta.analyticalConditions),
          if (meta.forbiddenConditions.isNotEmpty)
            _bulletSection(context, 'Cas interdits', meta.forbiddenConditions,
                color: theme.colorScheme.error),
          if (meta.limitations.isNotEmpty)
            _bulletSection(context, 'Limites d\'emploi', meta.limitations),
          const SizedBox(height: 8),
          Text('Sources', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          ...meta.sources.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• ${s.toString()}', style: theme.textTheme.bodySmall),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, String value, {bool monospace = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: 2),
          Text(value,
              style: monospace
                  ? theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace')
                  : theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _bulletSection(BuildContext context, String title, List<String> items, {Color? color}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge?.copyWith(color: color)),
          const SizedBox(height: 2),
          ...items.map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('• $i', style: theme.textTheme.bodyMedium?.copyWith(color: color)),
              )),
        ],
      ),
    );
  }
}
