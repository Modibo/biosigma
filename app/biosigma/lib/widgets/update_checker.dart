import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../app_version.dart';

/// URL du fichier de version publié sur le site (jamais mis en cache côté
/// serveur — voir `nginx.conf`). Uniquement interrogé sur les plateformes
/// natives (téléphone, ordinateur) : la version web se met déjà à jour
/// elle-même via son service worker.
const String _kVersionCheckUrl = 'https://biosigma.komodi-labo.org/version.json';

/// Vérifie, une fois au démarrage et uniquement sur les applications
/// installées (Android, iOS, bureau — jamais sur le web), si une version
/// plus récente est publiée, et affiche un bandeau avec un lien si c'est le
/// cas. Entièrement silencieux en cas d'échec (hors connexion, serveur
/// injoignable) : ne bloque jamais le lancement de l'application.
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
    if (!kIsWeb) {
      _checkForUpdate();
    }
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

  Future<void> _openUpdateLink() async {
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
              content: Text('Nouvelle version de BioSigma disponible (v$_latestVersion). '
                  'Version installée : v$kAppVersion.'),
              leading: const Icon(Icons.system_update_outlined),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _dismissed = true),
                  child: const Text('Plus tard'),
                ),
                FilledButton(
                  onPressed: _openUpdateLink,
                  child: const Text('Mettre à jour'),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
