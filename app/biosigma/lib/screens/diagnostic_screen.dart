import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_version.dart';
import '../services/diagnostic_model.dart';
import '../services/diagnostic_service_stub.dart' if (dart.library.html) '../services/diagnostic_service_web.dart';
import '../state/app_state.dart';

/// Diagnostic de l'appareil : aide les testeurs (et le développeur) à savoir
/// précisément ce qui fonctionne sur un navigateur ou un téléphone donné
/// (backlog P6-03). Aucune donnée de calcul, aucune identité : seulement
/// l'état de l'application et du navigateur. Le rapport n'est jamais envoyé :
/// l'utilisateur le copie lui-même.
class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  Future<List<DiagnosticItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery n'est lisible qu'ici (pas dans initState) ; un seul calcul.
    _future ??= _collect();
  }

  Future<List<DiagnosticItem>> _collect() async {
    final state = context.read<AppState>();
    final media = MediaQuery.of(context);
    final items = <DiagnosticItem>[
      DiagnosticItem('Version de BioSigma', kAppVersion, DiagnosticStatus.info),
      DiagnosticItem('Plateforme', defaultTargetPlatform.name, DiagnosticStatus.info),
      DiagnosticItem('Mode', kIsWeb ? 'web' : 'natif', DiagnosticStatus.info),
      DiagnosticItem(
          'Écran', '${media.size.width.round()} × ${media.size.height.round()} (ratio ${media.devicePixelRatio.toStringAsFixed(2)})', DiagnosticStatus.info),
      DiagnosticItem('Échelle du texte', media.textScaler.scale(1).toStringAsFixed(2), DiagnosticStatus.info),
      DiagnosticItem('Thème', media.platformBrightness == Brightness.dark ? 'sombre' : 'clair', DiagnosticStatus.info),
      DiagnosticItem('Historique enregistré', '${state.history.length} entrée(s)', DiagnosticStatus.info),
      DiagnosticItem('Pipettes enregistrées', '${state.pipettes.length}', DiagnosticStatus.info),
      DiagnosticItem(
          'Données illisibles mises de côté',
          state.hasQuarantinedData ? 'oui (voir la documentation)' : 'non',
          state.hasQuarantinedData ? DiagnosticStatus.warning : DiagnosticStatus.ok),
      ...await collectWebDiagnostics(),
    ];
    return items;
  }

  Color _color(BuildContext context, DiagnosticStatus s) {
    final scheme = Theme.of(context).colorScheme;
    return switch (s) {
      DiagnosticStatus.ok => Colors.green.shade800,
      DiagnosticStatus.warning => const Color(0xFF9A5B00),
      DiagnosticStatus.fail => scheme.error,
      DiagnosticStatus.info => scheme.onSurfaceVariant,
    };
  }

  IconData _icon(DiagnosticStatus s) => switch (s) {
        DiagnosticStatus.ok => Icons.check_circle_outline,
        DiagnosticStatus.warning => Icons.warning_amber,
        DiagnosticStatus.fail => Icons.error_outline,
        DiagnosticStatus.info => Icons.info_outline,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic de l\'appareil')),
      body: SafeArea(
        child: FutureBuilder<List<DiagnosticItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data ?? const <DiagnosticItem>[];
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Utile pour tester BioSigma sur un appareil : copiez ce rapport et collez-le dans votre '
                  'compte rendu de test. Il ne contient aucune donnée de calcul ni de patient et n\'est jamais envoyé.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                for (final i in items)
                  Card(
                    child: ListTile(
                      leading: Icon(_icon(i.status), color: _color(context, i.status)),
                      title: Text(i.label),
                      subtitle: Text(i.value),
                      trailing: Text(i.status.label,
                          style: TextStyle(color: _color(context, i.status), fontWeight: FontWeight.bold)),
                    ),
                  ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copier le rapport de diagnostic'),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(
                        ClipboardData(text: diagnosticReportText(kAppVersion, DateTime.now(), items)));
                    messenger.showSnackBar(const SnackBar(content: Text('Rapport copié dans le presse-papiers.')));
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
