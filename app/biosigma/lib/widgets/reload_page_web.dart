// Fichier chargé uniquement sur le web via l'import conditionnel de
// update_checker.dart (`if (dart.library.html)`) — jamais compilé pour
// Android/iOS/bureau.
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Applique la mise à jour : demande au service worker de BioSigma
/// (`biosigma_sw.js`) d'installer le nouveau build puis de basculer, avant de
/// recharger la page — voir `window.biosigmaApplyUpdate` dans index.html. Un
/// simple rechargement ne suffirait pas : le service worker sert l'ancienne
/// version depuis son cache tant que la nouvelle n'a pas pris le relais.
/// Retombe sur un rechargement ordinaire si cette fonction est absente.
void reloadPage() {
  if (globalContext.has('biosigmaApplyUpdate')) {
    globalContext.callMethod('biosigmaApplyUpdate'.toJS);
  } else {
    (globalContext['location'] as JSObject).callMethod('reload'.toJS);
  }
}
