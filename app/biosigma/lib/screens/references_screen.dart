import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';

import '../theme/category_icons.dart';
import '../widgets/formula_reference_section.dart';

/// Liste complète des références scientifiques et limites d'emploi de
/// tous les calculs du catalogue, consultable hors connexion, groupée par
/// catégorie clinique. Chaque catégorie se déplie à la demande : à
/// l'échelle du catalogue actuel (une soixantaine de calculs), afficher
/// tout à plat obligerait à défiler sur de nombreux écrans pour atteindre
/// les dernières catégories.
class ReferencesScreen extends StatelessWidget {
  const ReferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final byCategory = {
      for (final category in CalculatorCategory.values)
        category: CalculatorCatalog.byCategory(category),
    };
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final category in CalculatorCategory.values)
            if (byCategory[category]!.isNotEmpty)
              Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ExpansionTile(
                  key: PageStorageKey('references-category-${category.name}'),
                  leading: Icon(categoryIcon(category), color: theme.colorScheme.primary),
                  title: Text(category.label),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${byCategory[category]!.length}', style: theme.textTheme.bodySmall),
                      const SizedBox(width: 4),
                      const Icon(Icons.expand_more),
                    ],
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  children: [
                    for (final meta in byCategory[category]!)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4, left: 4),
                              child: Text(
                                meta.name,
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            FormulaReferenceSection(meta: meta),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
