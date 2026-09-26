import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/quiz/quiz_registry.dart';
import '../models/quiz_question.dart';
import '../state/app_state.dart';
import 'about_screen.dart';
import 'calculator_router.dart';
import 'quiz_module_screen.dart';
import 'references_screen.dart';
import 'settings_screen.dart';

/// Écran d'accueil : recherche, outils composés (panel CKD-EPI, scores
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('BioSigma'),
        actions: [
          IconButton(
            tooltip: 'À propos',
            icon: const Icon(Icons.info_outline),
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
          IconButton(
            tooltip: 'Références et limites',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReferencesScreen())),
          ),
          IconButton(
            tooltip: 'Réglages',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
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
    final favorites =
        CalculatorCatalog.all.where((m) => appState.isFavorite(m.id)).toList(growable: false);

    return ListView(
      children: [
        _SectionHeader('Outils composés'),
        ListTile(
          leading: const Icon(Icons.merge_type),
          title: const Text('DFG — panel CKD-EPI'),
          subtitle: const Text('Créatinine, cystatine C et combinée, côte à côte'),
          onTap: () => openCkdEpiPanel(context),
        ),
        ListTile(
          leading: const Icon(Icons.checklist),
          title: const Text('Score ISTH-CIVD (module guidé)'),
          onTap: () => openCalculator(context, 'isth_dic_score'),
        ),
        ListTile(
          leading: const Icon(Icons.checklist),
          title: const Text('Score 4Ts (module guidé)'),
          onTap: () => openCalculator(context, 'four_ts_score'),
        ),
        _SectionHeader('Formation — quiz'),
        ...allQuizModules.map((module) => _QuizModuleTile(module: module)),
        if (favorites.isNotEmpty) ...[
          _SectionHeader('Favoris'),
          ...favorites.map((m) => _CalculatorTile(meta: m)),
        ],
        for (final category in CalculatorCategory.values) ...[
          _SectionHeader(category.label),
          ...CalculatorCatalog.byCategory(category).map((m) => _CalculatorTile(meta: m)),
        ],
        const SizedBox(height: 24),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Theme.of(context).colorScheme.primary)),
    );
  }
}

class _QuizModuleTile extends StatelessWidget {
  const _QuizModuleTile({required this.module});
  final QuizModule module;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final best = appState.bestAttemptFor(module.id);
    return ListTile(
      leading: const Icon(Icons.school_outlined),
      title: Text(module.title),
      subtitle: Text('${module.questions.length} questions'),
      trailing: best == null
          ? null
          : Chip(
              label: Text('${best.score}/${best.totalQuestions}'),
              visualDensity: VisualDensity.compact,
            ),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => QuizModuleScreen(module: module))),
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
      subtitle: Text(meta.version, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        icon: Icon(appState.isFavorite(meta.id) ? Icons.star : Icons.star_border),
        onPressed: () => appState.toggleFavorite(meta.id),
      ),
      onTap: () => openCalculator(context, meta.id),
    );
  }
}
