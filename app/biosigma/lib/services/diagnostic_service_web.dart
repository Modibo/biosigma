// Fichier chargé uniquement sur le web (import conditionnel).
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'diagnostic_model.dart';

JSObject get _window => globalContext;

T? _try<T>(T Function() f) {
  try {
    return f();
  } catch (_) {
    return null;
  }
}

bool _matchMedia(String query) {
  final mm = _try(() => _window.callMethod('matchMedia'.toJS, query.toJS) as JSObject);
  return mm != null && (mm['matches'] as JSBoolean?)?.toDart == true;
}

/// Contrôles propres au navigateur : mode hors connexion (service worker),
/// stockage, installation, impression, presse-papiers, préférences d'accessibilité.
Future<List<DiagnosticItem>> collectWebDiagnostics() async {
  final nav = _window['navigator'] as JSObject;
  final items = <DiagnosticItem>[];

  items.add(DiagnosticItem('Navigateur (user agent)', (nav['userAgent'] as JSString?)?.toDart ?? '?', DiagnosticStatus.info));
  items.add(DiagnosticItem('Langue du navigateur', (nav['language'] as JSString?)?.toDart ?? '?', DiagnosticStatus.info));
  items.add(DiagnosticItem(
      'Connexion', (nav['onLine'] as JSBoolean?)?.toDart == true ? 'en ligne' : 'hors connexion', DiagnosticStatus.info));
  items.add(DiagnosticItem(
      'Points de contact tactiles', '${(nav['maxTouchPoints'] as JSNumber?)?.toDartInt ?? 0}', DiagnosticStatus.info));

  // Service worker (mode hors connexion)
  final hasSw = nav.has('serviceWorker');
  if (!hasSw) {
    items.add(const DiagnosticItem('Service worker', 'non pris en charge : pas de mode hors connexion', DiagnosticStatus.fail));
  } else {
    final sw = nav['serviceWorker'] as JSObject;
    final controller = sw['controller'];
    items.add(DiagnosticItem(
        'Service worker (mode hors connexion)',
        controller == null ? 'pris en charge, pas encore actif : recharger la page une fois' : 'actif',
        controller == null ? DiagnosticStatus.warning : DiagnosticStatus.ok));
  }

  // Cache de l'application
  if (_window.has('caches')) {
    try {
      final caches = _window['caches'] as JSObject;
      final keys = await (caches.callMethod('keys'.toJS) as JSPromise<JSArray<JSString>>).toDart;
      final names = keys.toDart.map((k) => k.toDart).toList();
      items.add(DiagnosticItem(
          'Caches de l\'application',
          names.isEmpty ? 'aucun (premier chargement ?)' : names.join(', '),
          names.isEmpty ? DiagnosticStatus.warning : DiagnosticStatus.ok));
    } catch (e) {
      items.add(DiagnosticItem('Caches de l\'application', 'illisibles : $e', DiagnosticStatus.warning));
    }
  } else {
    items.add(const DiagnosticItem('Caches de l\'application', 'API absente', DiagnosticStatus.fail));
  }

  // Stockage local
  try {
    final ls = _window['localStorage'] as JSObject;
    ls.callMethod('setItem'.toJS, 'biosigma.diag'.toJS, '1'.toJS);
    final back = (ls.callMethod('getItem'.toJS, 'biosigma.diag'.toJS) as JSString?)?.toDart;
    ls.callMethod('removeItem'.toJS, 'biosigma.diag'.toJS);
    items.add(DiagnosticItem('Stockage local (historique, réglages)',
        back == '1' ? 'écriture et lecture réussies' : 'lecture incohérente',
        back == '1' ? DiagnosticStatus.ok : DiagnosticStatus.fail));
  } catch (e) {
    items.add(DiagnosticItem('Stockage local (historique, réglages)', 'indisponible (navigation privée ?) : $e', DiagnosticStatus.fail));
  }

  // Stockage persistant
  try {
    final storage = nav['storage'] as JSObject?;
    if (storage != null && storage.has('persisted')) {
      final persisted = (await (storage.callMethod('persisted'.toJS) as JSPromise<JSBoolean>).toDart).toDart;
      items.add(DiagnosticItem('Stockage persistant',
          persisted ? 'accordé' : 'non accordé (le navigateur peut effacer les données après une longue inactivité)',
          persisted ? DiagnosticStatus.ok : DiagnosticStatus.warning));
    } else {
      items.add(const DiagnosticItem('Stockage persistant', 'API absente', DiagnosticStatus.warning));
    }
  } catch (e) {
    items.add(DiagnosticItem('Stockage persistant', 'illisible : $e', DiagnosticStatus.warning));
  }

  items.add(DiagnosticItem(
      'Application installée (mode autonome)', _matchMedia('(display-mode: standalone)') ? 'oui' : 'non (onglet du navigateur)', DiagnosticStatus.info));

  // Presse-papiers
  final clip = nav['clipboard'];
  items.add(DiagnosticItem('Presse-papiers', clip == null ? 'API absente (copie impossible)' : 'disponible',
      clip == null ? DiagnosticStatus.warning : DiagnosticStatus.ok));

  // Préférences d'accessibilité
  items.add(DiagnosticItem('Préférence : mouvement réduit', _matchMedia('(prefers-reduced-motion: reduce)') ? 'activée' : 'non', DiagnosticStatus.info));
  items.add(DiagnosticItem('Préférence : thème', _matchMedia('(prefers-color-scheme: dark)') ? 'sombre' : 'clair', DiagnosticStatus.info));
  items.add(DiagnosticItem('Préférence : contraste élevé', _matchMedia('(prefers-contrast: more)') ? 'activée' : 'non', DiagnosticStatus.info));

  return items;
}
