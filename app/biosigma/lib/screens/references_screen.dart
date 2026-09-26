import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';

import '../widgets/formula_reference_section.dart';

/// Liste complète des références scientifiques et limites d'emploi de
/// tous les calculs du catalogue, consultable hors connexion, groupée par
/// catégorie clinique.
class ReferencesScreen extends StatelessWidget {
  const ReferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final byCategory = {
      for (final category in CalculatorCategory.values)
        category: CalculatorCatalog.byCategory(category),
    };
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final category in CalculatorCategory.values) ...[
            if (byCategory[category]!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  category.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
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
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      FormulaReferenceSection(meta: meta),
                    ],
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}
