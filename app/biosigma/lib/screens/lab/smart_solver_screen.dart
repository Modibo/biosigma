import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';

import '../../widgets/disclaimer_banner.dart';

/// Smart Solver : décrit un problème de laboratoire en une phrase ; propose
/// un module **à confirmer**. Analyse déterministe par mots-clés, hors
/// connexion, sans envoi de données. Ne calcule rien et ne remplit aucun champ.
class SmartSolverScreen extends StatefulWidget {
  const SmartSolverScreen({super.key, required this.openModule});

  /// Ouvre l'écran du module choisi par l'utilisateur.
  final void Function(LabModule module) openModule;

  @override
  State<SmartSolverScreen> createState() => _SmartSolverScreenState();
}

class _SmartSolverScreenState extends State<SmartSolverScreen> {
  String _text = '';
  SolverSuggestion? _suggestion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = _suggestion;
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Solver')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DisclaimerBanner(),
            const SizedBox(height: 12),
            Text(
              'Décrivez votre besoin en une phrase (ex. « diluer 100 µL de sérum dans 900 µL », '
              '« préparer 500 mL de NaCl 0,9 % »). BioSigma propose un module : vous confirmez, '
              'et vous saisissez vous-même les valeurs. Analyse locale par mots-clés, rien n\'est envoyé.',
              style: theme.textTheme.bodySmall,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Votre question'),
                onChanged: (v) => setState(() {
                  _text = v;
                  _suggestion = null;
                }),
              ),
            ),
            FilledButton.icon(
              onPressed: _text.trim().isEmpty ? null : () => setState(() => _suggestion = analyzeLabQuestion(_text)),
              icon: const Icon(Icons.search),
              label: const Text('Analyser'),
            ),
            if (s != null) ...[
              const SizedBox(height: 16),
              if (!s.recognized)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Aucun module reconnu. Reformulez avec un mot-clé (convertir, diluer, préparer, '
                      'numération, UFC, CV, biais…) ou ouvrez directement un module depuis l\'onglet Lab.',
                    ),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.ambiguous ? 'Plusieurs modules possibles — à vous de choisir' : 'Module proposé — à confirmer',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final m in s.candidates)
                          FilledButton.tonal(
                            onPressed: () => widget.openModule(m),
                            child: Text('Ouvrir ${m.label}'),
                          ),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                        'Mots reconnus : ${[for (final m in s.candidates) '${m.label} (${s.matchedKeywords[m]!.join(', ')})'].join(' ; ')}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ]),
                  ),
                ),
              if (s.quantities.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Quantités repérées (telles qu\'écrites)', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(s.quantities.map((q) => q.raw).join('  ·  ')),
                      const SizedBox(height: 4),
                      Text('À ressaisir dans le module après vérification : rien n\'est repris automatiquement.',
                          style: theme.textTheme.bodySmall),
                    ]),
                  ),
                ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
