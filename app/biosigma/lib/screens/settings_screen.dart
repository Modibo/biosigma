import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../models/local_threshold.dart';
import '../state/app_state.dart';
import '../widgets/pipette_widgets.dart';
import 'history_screen.dart';

/// Écran Réglages : séparateur décimal, historique local (facultatif,
/// désactivé par défaut), équation LDL présélectionnée, seuils locaux du
/// laboratoire, et suppression totale des données locales.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final settings = appState.settings;

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Affichage', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioGroup<DecimalSeparator>(
                  groupValue: settings.decimalSeparator,
                  onChanged: (v) {
                    if (v != null) {
                      appState.updateSettings(
                        (s) => s.copyWith(decimalSeparator: v),
                      );
                    }
                  },
                  child: Column(
                    children: const [
                      RadioListTile<DecimalSeparator>(
                        value: DecimalSeparator.comma,
                        title: Text('Virgule (1,50)'),
                      ),
                      RadioListTile<DecimalSeparator>(
                        value: DecimalSeparator.dot,
                        title: Text('Point (1.50)'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Formation — scores de quiz',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: appState.quizAttempts.isEmpty
                ? const ListTile(title: Text('Aucun quiz encore tenté.'))
                : ListTile(
                    leading: const Icon(Icons.delete_forever),
                    title: Text(
                      'Effacer les scores de quiz (${appState.quizAttempts.length} tentative(s))',
                    ),
                    onTap: () async {
                      await appState.clearQuizAttempts();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Scores de quiz effacés.'),
                          ),
                        );
                      }
                    },
                  ),
          ),
          const SizedBox(height: 24),
          Text(
            'Historique local',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Activer l\'historique local'),
                  subtitle: const Text(
                    'Désactivé par défaut. Aucune identité de patient n\'est jamais demandée '
                    'ni stockée ; seuls calcul, entrées et résultat sont conservés.',
                  ),
                  value: settings.historyEnabled,
                  onChanged: (v) => appState.updateSettings(
                    (s) => s.copyWith(historyEnabled: v),
                  ),
                ),
                if (appState.history.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('Voir l\'historique (${appState.history.length} entrée(s))'),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (_) => const HistoryScreen())),
                  ),
                if (appState.history.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.delete_forever),
                    title: Text(
                      'Effacer l\'historique (${appState.history.length} entrée(s))',
                    ),
                    onTap: () async {
                      await appState.clearHistory();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Historique effacé.')),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pipettes du laboratoire', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Ajouter une pipette',
                onPressed: () => showAddPipetteDialog(context, appState),
              ),
            ],
          ),
          Text(
            'Plage de la fiche, seuil recommandé et vérification sont saisis par vous : '
            'BioSigma n\'embarque aucune pipette. Utilisées par Dilute pour contrôler les volumes.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          if (appState.pipettes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Aucune pipette enregistrée.'),
            )
          else
            Card(
              child: Column(
                children: [
                  for (final p in appState.pipettes)
                    ListTile(
                      title: Text(p.name),
                      subtitle: Text(pipetteSummary(p, settings.decimalSeparator)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Supprimer cette pipette',
                        onPressed: () => appState.removePipette(p),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Panel LDL',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Présélectionner Friedewald dans le panel LDL'),
                  subtitle: const Text(
                    'Sinon Sampson. Simple présélection à l\'ouverture : l\'équation reste '
                    'modifiable avant le calcul et aucun résultat n\'est changé.',
                  ),
                  value: settings.ldlDefaultFriedewald,
                  onChanged: (v) => appState.updateSettings(
                    (s) => s.copyWith(ldlDefaultFriedewald: v),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seuils locaux du laboratoire',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Ajouter un seuil local',
                onPressed: () => _showAddThresholdDialog(context, appState),
              ),
            ],
          ),
          Text(
            'Aucun seuil universel n\'est imposé par BioSigma. Ceux définis ici (valeur, unité, '
            'méthode, responsable de validation) sont rappelés sous le résultat du calcul concerné, '
            'tels que vous les avez saisis : l\'application ne compare pas le résultat au seuil.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          if (appState.thresholds.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Aucun seuil local défini.'),
            )
          else
            Card(
              child: Column(
                children: appState.thresholds
                    .map(
                      (t) => ListTile(
                        title: Text('${t.label} — ${t.value} ${t.unit}'),
                        subtitle: Text(
                          '${t.method}\nValidé le ${t.validatedOn.toLocal().toString().split(' ').first} par ${t.validatedBy}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => appState.removeThreshold(t),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          const SizedBox(height: 32),
          Text(
            'Confidentialité',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Supprimer toutes les données locales'),
              subtitle: const Text(
                'Réglages, favoris, historique et seuils locaux — action immédiate et irréversible.',
              ),
              onTap: () => _confirmClearAll(context, appState),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "BioSigma ne collecte aucune donnée nominative ni télémétrie. Tous les calculs sont "
            "effectués localement, hors connexion.",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, AppState appState) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer toutes les données locales ?'),
        content: const Text(
          'Réglages, favoris, historique et seuils locaux seront définitivement supprimés de cet appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              await appState.clearAllLocalData();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showAddThresholdDialog(BuildContext context, AppState appState) {
    final calculators = CalculatorCatalog.all;
    String selectedId = calculators.first.id;
    final labelCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    final methodCtrl = TextEditingController();
    final byCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Ajouter un seuil local'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedId,
                  decoration: const InputDecoration(
                    labelText: 'Calcul concerné',
                  ),
                  isExpanded: true,
                  items: calculators
                      .map(
                        (m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.shortName),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (v) =>
                      setDialogState(() => selectedId = v ?? selectedId),
                ),
                TextField(
                  controller: labelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Libellé du seuil',
                  ),
                ),
                TextField(
                  controller: valueCtrl,
                  decoration: const InputDecoration(labelText: 'Valeur'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                TextField(
                  controller: unitCtrl,
                  decoration: const InputDecoration(labelText: 'Unité'),
                ),
                TextField(
                  controller: methodCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Méthode / réactif',
                  ),
                ),
                TextField(
                  controller: byCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Validé par (nom ou fonction)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(
                  valueCtrl.text.replaceAll(',', '.'),
                );
                if (labelCtrl.text.trim().isEmpty ||
                    value == null ||
                    unitCtrl.text.trim().isEmpty) {
                  return;
                }
                appState.saveThreshold(
                  LocalThreshold(
                    calculatorId: selectedId,
                    label: labelCtrl.text.trim(),
                    value: value,
                    unit: unitCtrl.text.trim(),
                    method: methodCtrl.text.trim().isEmpty
                        ? 'Non précisée'
                        : methodCtrl.text.trim(),
                    validatedOn: DateTime.now(),
                    validatedBy: byCtrl.text.trim().isEmpty
                        ? 'Non précisé'
                        : byCtrl.text.trim(),
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
