// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
// Fichier chargé uniquement sur le web via l'import conditionnel de
// update_checker.dart (`if (dart.library.html)`) — jamais compilé pour
// Android/iOS/bureau, donc l'usage de dart:html ici est intentionnel et sûr.
import 'dart:html' as html;

/// Recharge la page web : force le navigateur à récupérer le nouveau
/// `main.dart.js` et le nouveau service worker déployés, plutôt que
/// d'attendre son propre cycle de mise à jour en arrière-plan (parfois
/// long à se déclencher, notamment sur navigateur mobile).
void reloadPage() => html.window.location.reload();
