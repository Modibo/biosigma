import 'package:flutter/material.dart';

/// Sélecteur d'un critère catégoriel pour un score guidé (ISTH-CIVD, 4Ts) :
/// une liste d'options exclusives, chacune avec sa description clinique
/// exacte et ses points, sans jamais présélectionner de valeur par défaut
/// — l'absence de sélection doit rester un état explicite ("score
/// incomplet"), jamais une donnée inférée.
class GuidedCriterionSelector<T> extends StatelessWidget {
  const GuidedCriterionSelector({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.describe,
    required this.points,
  });

  final String title;
  final List<T> options;
  final T? selected;
  final ValueChanged<T?> onChanged;
  final String Function(T) describe;
  final int Function(T) points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            RadioGroup<T>(
              groupValue: selected,
              onChanged: onChanged,
              child: Column(
                children: options
                    .map(
                      (o) => RadioListTile<T>(
                        value: o,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text('${describe(o)}  (${points(o)} pt)'),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
