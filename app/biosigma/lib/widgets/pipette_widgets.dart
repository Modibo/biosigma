import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../services/number_format_service.dart';
import '../state/app_state.dart';

/// Contrôle de pipetabilité des volumes d'un résultat de dilution, avec les
/// pipettes décrites par l'utilisateur (règle `PIP_CHECK_001`).
class PipetabilityCard extends StatelessWidget {
  const PipetabilityCard({super.key, required this.volumesUl});

  /// Libellé → volume en µL.
  final Map<String, double> volumesUl;

  @override
  Widget build(BuildContext context) {
    final pipettes = context.watch<AppState>().pipettes;
    final theme = Theme.of(context);
    final now = DateTime.now();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pipetabilité', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            if (pipettes.isEmpty)
              Text(
                'Aucune pipette enregistrée : ajoutez vos pipettes dans Réglages (plage de la fiche, '
                'seuil recommandé, vérification) pour contrôler que ces volumes sont réalisables.',
                style: theme.textTheme.bodySmall,
              )
            else
              for (final e in volumesUl.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('${e.key} : ${_fmt(e.value)} µL', style: theme.textTheme.bodyMedium),
                ),
                ..._lines(suggestPipettes(e.value, pipettes, now: now), theme),
              ],
            const SizedBox(height: 6),
            Text(
              'Selon les seuils saisis par votre laboratoire ; BioSigma n\'en fournit aucun.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(double v) => RoundingPolicy.format(v, RoundingPolicy.decimalsForSignificant(v));

  static List<Widget> _lines(List<PipetteCheck> checks, ThemeData theme) {
    if (checks.isEmpty) {
      return [
        Text(
          'Non pipetable directement avec vos pipettes : passer par une dilution intermédiaire '
          'ou un volume plus grand.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
        ),
      ];
    }
    return [
      for (final c in checks)
        Text(
          '• ${c.pipette.name} — ${c.fit.label}${c.notes.isEmpty ? '' : ' (${c.notes.join(' ')})'}',
          style: theme.textTheme.bodyMedium,
        ),
    ];
  }
}

/// Formulaire d'ajout d'une pipette (saisie de la fiche et de la vérification).
Future<void> showAddPipetteDialog(BuildContext context, AppState appState) {
  final sep = appState.settings.decimalSeparator;
  final name = TextEditingController();
  final min = TextEditingController();
  final max = TextEditingController();
  final recommended = TextEditingController();
  final verified = TextEditingController();
  final days = TextEditingController();
  String? error;

  double? num(TextEditingController c) => NumberFormatService.parse(c.text, sep);

  return showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        void save() {
          final minUl = num(min), maxUl = num(max);
          final rec = recommended.text.trim().isEmpty ? null : num(recommended);
          final verifiedOn = verified.text.trim().isEmpty ? null : DateTime.tryParse(verified.text.trim());
          final validDays = days.text.trim().isEmpty ? null : int.tryParse(days.text.trim());
          String? problem;
          if (name.text.trim().isEmpty) {
            problem = 'Donnez un nom ou un numéro d\'inventaire.';
          } else if (minUl == null || minUl <= 0 || maxUl == null || maxUl <= minUl) {
            problem = 'Volumes minimal et nominal : nombres positifs, le nominal doit dépasser le minimal.';
          } else if (recommended.text.trim().isNotEmpty &&
              (rec == null || rec < minUl || rec > maxUl)) {
            problem = 'Le seuil recommandé doit être compris entre le minimal et le nominal.';
          } else if (verified.text.trim().isNotEmpty && verifiedOn == null) {
            problem = 'Date de vérification illisible (format AAAA-MM-JJ).';
          } else if (days.text.trim().isNotEmpty && (validDays == null || validDays <= 0)) {
            problem = 'La durée de validité doit être un nombre entier de jours.';
          } else if ((verifiedOn == null) != (validDays == null)) {
            problem = 'Renseignez ensemble la date de vérification et sa durée de validité, ou ni l\'une ni l\'autre.';
          }
          if (problem != null) {
            setState(() => error = problem);
            return;
          }
          appState.savePipette(Pipette(
            name: name.text.trim(),
            minUl: minUl!,
            maxUl: maxUl!,
            recommendedMinUl: rec,
            verifiedOn: verifiedOn,
            verificationValidDays: validDays,
          ));
          Navigator.pop(ctx);
        }

        Widget field(String label, TextEditingController c, {String? helper, TextInputType? type}) =>
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                controller: c,
                keyboardType: type,
                decoration: InputDecoration(labelText: label, helperText: helper, helperMaxLines: 3),
              ),
            );

        return AlertDialog(
          title: const Text('Ajouter une pipette'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              field('Nom ou numéro d\'inventaire', name),
              field('Volume minimal de la fiche (µL)', min, type: TextInputType.number),
              field('Volume nominal maximal (µL)', max, type: TextInputType.number),
              field('Seuil « recommandé » du laboratoire (µL) — facultatif', recommended,
                  type: TextInputType.number,
                  helper: 'Sous ce seuil, le volume est « possible (déconseillé) ».'),
              field('Dernière vérification (AAAA-MM-JJ) — facultatif', verified),
              field('Validité de la vérification (jours) — facultatif', days,
                  type: TextInputType.number, helper: 'Durée fixée par votre laboratoire.'),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error!, style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
                ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            FilledButton(onPressed: save, child: const Text('Enregistrer')),
          ],
        );
      },
    ),
  );
}

/// Libellé court d'une pipette pour la liste des réglages.
String pipetteSummary(Pipette p, DecimalSeparator sep) {
  String f(double v) => NumberFormatService.format(v, sep, precision: RoundingPolicy.decimalsForSignificant(v));
  final range = '${f(p.minUl)} à ${f(p.maxUl)} µL';
  final rec = p.recommendedMinUl == null ? '' : ' · recommandé dès ${f(p.recommendedMinUl!)} µL';
  final ver = p.verifiedOn == null
      ? ' · vérification non renseignée'
      : ' · vérifiée le ${p.verifiedOn!.toIso8601String().split('T').first}'
          ' (${p.verificationValidDays} j)';
  return '$range$rec$ver';
}
