import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/category_icons.dart';
import 'calculator_router.dart';

/// Onglet Calcul : recherche, outils composés (panel CKD-EPI, scores
/// guidés), favoris et catégories. Point d'entrée unique vers tous les
/// calculateurs du catalogue.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final results = _query.isEmpty ? null : CalculatorCatalog.search(_query);

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un calcul (ex. QUICKI, CKD-EPI, Rosner…)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: results != null
                ? _SearchResultsList(results: results)
                : _BrowseContent(appState: appState),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({required this.results});
  final List<FormulaMeta> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(child: Text('Aucun calcul trouvé.'));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) => _CalculatorTile(meta: results[i]),
    );
  }
}

class _BrowseContent extends StatelessWidget {
  const _BrowseContent({required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final favorites = CalculatorCatalog.all
        .where((m) => appState.isFavorite(m.id))
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      children: [
        _SectionHeader('Outils composés'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.merge_type),
                title: const Text('DFG — panel CKD-EPI'),
                subtitle: const Text(
                  'Créatinine, cystatine C et combinée, côte à côte',
                ),
                onTap: () => openCkdEpiPanel(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.checklist),
                title: const Text('Score ISTH-CIVD (module guidé)'),
                onTap: () => openCalculator(context, 'isth_dic_score'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.checklist),
                title: const Text('Score 4Ts (module guidé)'),
                onTap: () => openCalculator(context, 'four_ts_score'),
              ),
            ],
          ),
        ),
        if (favorites.isNotEmpty) ...[
          _SectionHeader('Favoris'),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < favorites.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _CalculatorTile(meta: favorites[i]),
                ],
              ],
            ),
          ),
        ],
        _SectionHeader('Domaines'),
        for (final category in CalculatorCategory.values)
          _CategorySection(category: category),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

/// Un domaine clinique (ex. « Hématologie »), replié par défaut : à
/// l'échelle du catalogue actuel (une soixantaine de calculs), une liste
/// plate obligerait à défiler sur plusieurs écrans pour atteindre les
/// dernières catégories — chaque domaine se déplie donc à la demande.
class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category});
  final CalculatorCategory category;

  @override
  Widget build(BuildContext context) {
    final items = CalculatorCatalog.byCategory(category);
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        key: PageStorageKey('home-category-${category.name}'),
        leading: Icon(categoryIcon(category), color: theme.colorScheme.primary),
        title: Text(category.label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${items.length}', style: theme.textTheme.bodySmall),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more),
          ],
        ),
        childrenPadding: const EdgeInsets.only(bottom: 4),
        children: [
          const Divider(height: 1),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            _CalculatorTile(meta: items[i]),
          ],
        ],
      ),
    );
  }
}

class _CalculatorTile extends StatelessWidget {
  const _CalculatorTile({required this.meta});
  final FormulaMeta meta;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return ListTile(
      title: Text(meta.shortName),
      subtitle: Text(
        meta.version,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(
          appState.isFavorite(meta.id) ? Icons.star : Icons.star_border,
        ),
        onPressed: () => appState.toggleFavorite(meta.id),
      ),
      onTap: () => openCalculator(context, meta.id),
    );
  }
}
