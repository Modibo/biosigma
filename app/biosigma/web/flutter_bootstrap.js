{{flutter_js}}
{{flutter_build_config}}

// Pas de `serviceWorkerSettings` : le service worker fourni par Flutter est
// un simple nettoyeur qui se désinscrit (aucune mise en cache hors connexion).
// BioSigma enregistre son propre service worker (`biosigma_sw.js`, voir
// index.html) qui met l'application en cache pour l'usage hors connexion.
_flutter.loader.load();
