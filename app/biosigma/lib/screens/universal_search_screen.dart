import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';

import '../theme/category_icons.dart';
import 'calculator_router.dart';
import 'lab/convert_screen.dart';
import 'lab_screen.dart';

/// Recherche universelle hors connexion : calculs, analytes, unités et
/// modules Lab, par nom, abréviation ou phrase libre (sans accents ni
/// majuscules). Une phrase propose un module à confirmer, sans rien calculer.
class UniversalSearchScreen extends StatefulWidget {
  const UniversalSearchScreen({super.key});

  @override
  State<UniversalSearchScreen> createState() => _UniversalSearchScreenState();
}

class _UniversalSearchScreenState extends State<UniversalSearchScreen> {
  String _query = '';

  void _open(SearchHit hit) {
    switch (hit.kind) {
      case SearchKind.calculator:
        openCalculator(context, hit.id);
      case SearchKind.analyte:
        Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => ConvertScreen(initialAnalyteId: hit.id)));
      case SearchKind.unit:
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => ConvertScreen(initialUnit: hit.id)));
      case SearchKind.module:
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => labModuleScreen(hit.module!)));
    }
  }

  IconData _icon(SearchHit hit) => switch (hit.kind) {
        SearchKind.calculator => categoryIcon(
            CalculatorCatalog.byId(hit.id)?.category ?? CalculatorCategory.laboratory),
        SearchKind.analyte => Icons.science_outlined,
        SearchKind.unit => Icons.straighten,
        SearchKind.module => Icons.biotech,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hits = universalSearch(_query);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Calcul, analyte, unité, module… ou une phrase',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: SafeArea(
        child: _query.trim().isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Exemples : « dfg », « imc », « glucose », « mmHg », « dilution », '
                  '« diluer 100 µL dans 900 µL ». Sans accents ni majuscules.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            : hits.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Aucun résultat. Essayez une abréviation (DFG, VGM, INR…) ou un nom d\'analyte.'),
                  )
                : ListView.separated(
                    itemCount: hits.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final h = hits[i];
                      return ListTile(
                        leading: Icon(_icon(h)),
                        title: Text(h.title),
                        subtitle: Text('${h.kind.label} · ${h.subtitle}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _open(h),
                      );
                    },
                  ),
      ),
    );
  }
}
