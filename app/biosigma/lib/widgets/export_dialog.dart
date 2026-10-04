import 'package:biosigma_core/biosigma_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_version.dart';
import '../models/app_settings.dart';
import 'print_html_stub.dart' if (dart.library.html) 'print_html_web.dart';

/// Date et heure locales formatées « JJ/MM/AAAA HH:MM ».
String formatReportDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}

/// Boîte de confirmation avant impression ou export d'un résultat
/// (décision D-11). Rien n'est imprimé ni copié sans confirmation explicite
/// qu'aucune identité de patient n'y figure.
Future<void> showExportDialog(
  BuildContext context, {
  required CalculationResult result,
  required DecimalSeparator separator,
  List<ReportSection> extraSections = const [],
  DateTime? now,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ExportDialog(
      result: result,
      separator: separator,
      extraSections: extraSections,
      now: now ?? DateTime.now(),
    ),
  );
}

class _ExportDialog extends StatefulWidget {
  const _ExportDialog({
    required this.result,
    required this.separator,
    required this.extraSections,
    required this.now,
  });

  final CalculationResult result;
  final DecimalSeparator separator;
  final List<ReportSection> extraSections;
  final DateTime now;

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  final _reference = TextEditingController();
  bool _confirmed = false;

  @override
  void dispose() {
    _reference.dispose();
    super.dispose();
  }

  CalculationReport _report() => CalculationReport(
        result: widget.result,
        generatedAt: formatReportDate(widget.now),
        appVersion: kAppVersion,
        decimalComma: widget.separator == DecimalSeparator.comma,
        reference: _reference.text,
        extraSections: widget.extraSections,
      );

  Future<void> _copy() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await Clipboard.setData(ClipboardData(text: _report().toPlainText()));
    navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Rapport copié dans le presse-papiers.')));
  }

  Future<void> _print() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final report = _report();
    final printed = printHtmlDocument(report.toHtml());
    if (!printed) {
      await Clipboard.setData(ClipboardData(text: report.toPlainText()));
    }
    navigator.pop();
    messenger.showSnackBar(SnackBar(
      content: Text(printed
          ? 'Boîte d\'impression ouverte (choisissez « Enregistrer au format PDF » pour un fichier).'
          : 'L\'impression n\'est pas disponible ici : le rapport a été copié dans le presse-papiers.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Imprimer ou exporter ce résultat'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Le rapport contient : l\'équation et sa version, son statut de validation, les données '
              'saisies, les résultats, les avertissements, les sources et les limites d\'emploi.',
            ),
            const SizedBox(height: 8),
            Text(
              'Il ne contient aucune identité de patient. Vous pouvez ajouter une référence libre '
              '(numéro d\'échantillon anonyme) : n\'y écrivez ni nom ni date de naissance.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reference,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: 'Référence libre (facultatif)',
                helperText: 'Ex. échantillon 2026-0412',
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _confirmed,
              onChanged: (v) => setState(() => _confirmed = v ?? false),
              title: const Text('Je confirme que ce document ne contient aucune identité de patient.'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        OutlinedButton(onPressed: _confirmed ? _copy : null, child: const Text('Copier le texte')),
        FilledButton.icon(
          onPressed: _confirmed ? _print : null,
          icon: const Icon(Icons.print),
          label: Text(canPrintHtml ? 'Imprimer / PDF' : 'Copier le rapport'),
        ),
      ],
    );
  }
}
