import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../app_version.dart';
import 'reload_page_stub.dart' if (dart.library.html) 'reload_page_web.dart';

/// URL du fichier de version publié sur le site (jamais mis en cache côté
/// serveur — voir `nginx.conf`). Interrogé sur toutes les plateformes, y
/// compris le web (navigateur mobile ou PWA) : le service worker Flutter
/// finit par se mettre à jour tout seul en arrière-plan, mais ce délai est
/// invisible et parfois long pour l'utilisateur — le bandeau donne un
/// signal explicite et un moyen immédiat de forcer la mise à jour.
const String _kVersionCheckUrl = 'https://biosigma.komodi-labo.org/version.json';

/// Vérifie, une fois au démarrage, si une version plus récente est publiée,
/// et affiche un bandeau si c'est le cas : sur les applications installées
/// (Android, iOS, bureau), un lien vers la page de téléchargement ; sur le
/// web, un rechargement immédiat de la page pour récupérer les nouveaux
/// fichiers déployés. Entièrement silencieux en cas d'échec (hors
/// connexion, serveur injoignable) : ne bloque jamais le lancement de
/// l'application.
class UpdateChecker extends StatefulWidget {
  const UpdateChecker({super.key, required this.child});

  final Widget child;

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  String? _latestVersion;
  String? _updateUrl;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      final response = await http
          .get(Uri.parse(_kVersionCheckUrl))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode != 200) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final latest = data['latest'] as String?;
      final url = data['url'] as String?;
      if (latest == null || url == null) return;
      if (isNewerVersion(latest, kAppVersion) && mounted) {
        setState(() {
          _latestVersion = latest;
          _updateUrl = url;
        });
      }
    } catch (_) {
      // Hors connexion ou serveur injoignable : silencieux, pas de retentative.
    }
  }

  Future<void> _applyUpdate() async {
    if (kIsWeb) {
      reloadPage();
      return;
    }
    final url = _updateUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showBanner = !_dismissed && _latestVersion != null;
    return Column(
      children: [
        if (showBanner)
          SafeArea(
            bottom: false,
            child: MaterialBanner(
              content: Text(kIsWeb
                  ? 'Nouvelle version de BioSigma disponible (v$_latestVersion). '
                      'Version installée : v$kAppVersion. Si « Recharger » ne suffit pas, '
                      'fermez et rouvrez l\'onglet, ou videz le cache du navigateur.'
                  : 'Nouvelle version de BioSigma disponible (v$_latestVersion). '
                      'Version installée : v$kAppVersion.'),
              leading: const Icon(Icons.system_update_outlined),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _dismissed = true),
                  child: const Text('Plus tard'),
                ),
                FilledButton(
                  onPressed: _applyUpdate,
                  child: Text(kIsWeb ? 'Recharger' : 'Mettre à jour'),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
