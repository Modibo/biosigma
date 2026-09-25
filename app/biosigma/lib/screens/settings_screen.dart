import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../models/local_threshold.dart';
import '../state/app_state.dart';

/// Écran Réglages : séparateur décimal, précision d'affichage, historique
/// local (facultatif, désactivé par défaut), validation locale des
/// interprétations de score, seuils locaux du laboratoire, et suppression
/// totale des données locales.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final settings = appState.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
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
                      appState.updateSettings((s) => s.copyWith(decimalSeparator: v));
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
                ListTile(
                  title: const Text('Précision d\'affichage par défaut'),
                  subtitle: Text('${settings.displayPrecision} décimale(s) — '
                      'la précision propre à chaque formule reste prioritaire'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: settings.displayPrecision > 0
                            ? () => appState.updateSettings(
                                (s) => s.copyWith(displayPrecision: s.displayPrecision - 1))
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: settings.displayPrecision < 6
                            ? () => appState.updateSettings(
                                (s) => s.copyWith(displayPrecision: s.displayPrecision + 1))
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Historique local', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Activer l\'historique local'),
                  subtitle: const Text(
                      'Désactivé par défaut. Aucune identité de patient n\'est jamais demandée '
                      'ni stockée ; seuls calcul, entrées et résultat sont conservés.'),
                  value: settings.historyEnabled,
                  onChanged: (v) => appState.updateSettings((s) => s.copyWith(historyEnabled: v)),
                ),
                if (appState.history.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.delete_forever),
                    title: Text('Effacer l\'historique (${appState.history.length} entrée(s))'),
                    onTap: () async {
                      await appState.clearHistory();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Historique effacé.')));
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Scores guidés (ISTH-CIVD, 4Ts)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              title: const Text('Interprétations locales validées'),
              subtitle: const Text(
                  'À cocher uniquement par le biologiste responsable, après validation locale : '
                  'affiche le texte d\'interprétation clinique des scores ISTH-CIVD et 4Ts.'),
              value: settings.localInterpretationsValidated,
              onChanged: (v) =>
                  appState.updateSettings((s) => s.copyWith(localInterpretationsValidated: v)),
            ),
          ),
          const SizedBox(height: 24),
          Text('Panel LDL et sodium corrigé', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Mettre en avant Friedewald par défaut'),
                  subtitle: const Text('Sinon Sampson. Les deux résultats restent calculables.'),
                  value: settings.ldlDefaultFriedewald,
                  onChanged: (v) =>
                      appState.updateSettings((s) => s.copyWith(ldlDefaultFriedewald: v)),
                ),
                SwitchListTile(
                  title: const Text('Mettre en avant le coefficient de Katz (1,6)'),
                  subtitle: const Text('Sinon Hillier (2,4). Les deux valeurs restent affichées.'),
                  value: settings.sodiumCorrectionUsesKatz,
                  onChanged: (v) =>
                      appState.updateSettings((s) => s.copyWith(sodiumCorrectionUsesKatz: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Seuils locaux du laboratoire', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Ajouter un seuil local',
                onPressed: () => _showAddThresholdDialog(context, appState),
              ),
            ],
          ),
          Text(
            'Aucun seuil universel n\'est imposé par BioSigma : ceux définis ici, avec valeur, '
            'unité, méthode et responsable de validation, sont les seuls affichés dans l\'application.',
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
                    .map((t) => ListTile(
                          title: Text('${t.label} — ${t.value} ${t.unit}'),
                          subtitle: Text(
                              '${t.method}\nValidé le ${t.validatedOn.toLocal().toString().split(' ').first} par ${t.validatedBy}'),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => appState.removeThreshold(t),
                          ),
                        ))
                    .toList(growable: false),
              ),
            ),
          const SizedBox(height: 32),
          Text('Confidentialité', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Supprimer toutes les données locales'),
              subtitle: const Text(
                  'Réglages, favoris, historique et seuils locaux — action immédiate et irréversible.'),
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
            'Réglages, favoris, historique et seuils locaux seront définitivement supprimés de cet appareil.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
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
                  decoration: const InputDecoration(labelText: 'Calcul concerné'),
                  isExpanded: true,
                  items: calculators
                      .map((m) => DropdownMenuItem(value: m.id, child: Text(m.shortName)))
                      .toList(growable: false),
                  onChanged: (v) => setDialogState(() => selectedId = v ?? selectedId),
                ),
                TextField(
                    controller: labelCtrl,
                    decoration: const InputDecoration(labelText: 'Libellé du seuil')),
                TextField(
                    controller: valueCtrl,
                    decoration: const InputDecoration(labelText: 'Valeur'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Unité')),
                TextField(
                    controller: methodCtrl,
                    decoration: const InputDecoration(labelText: 'Méthode / réactif')),
                TextField(
                    controller: byCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Validé par (nom ou fonction)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(valueCtrl.text.replaceAll(',', '.'));
                if (labelCtrl.text.trim().isEmpty || value == null || unitCtrl.text.trim().isEmpty) {
                  return;
                }
                appState.saveThreshold(LocalThreshold(
                  calculatorId: selectedId,
                  label: labelCtrl.text.trim(),
                  value: value,
                  unit: unitCtrl.text.trim(),
                  method: methodCtrl.text.trim().isEmpty ? 'Non précisée' : methodCtrl.text.trim(),
                  validatedOn: DateTime.now(),
                  validatedBy: byCtrl.text.trim().isEmpty ? 'Non précisé' : byCtrl.text.trim(),
                ));
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
