'use strict';

// Service worker de BioSigma : met l'application en cache pour qu'elle
// démarre instantanément et fonctionne hors connexion après la première
// visite. Cache versionné par build : un nouveau déploiement installe un
// nouveau cache complet en arrière-plan, puis bascule en une fois (jamais
// un mélange d'anciens et de nouveaux fichiers).
//
// BUILD_ID est remplacé après chaque compilation par `tool/stamp_sw.sh`
// (empreinte de main.dart.js) : le fichier change donc d'octets à chaque
// build, ce qui est ce qui fait détecter au navigateur une nouvelle version.
// Si le marqueur n'a pas été remplacé (build local oublié), le service
// worker ne met RIEN en cache et laisse tout passer au réseau : sans
// risque, simplement pas de mode hors connexion.

const BUILD_ID = '__BUILD_ID__';
const ENABLED = !BUILD_ID.startsWith('__');
const CACHE = `biosigma-${BUILD_ID}`;

// Fichiers indispensables au démarrage : tous ou aucun (installation atomique).
// Le moteur graphique (canvaskit/…) n'est volontairement pas listé ici : chaque
// navigateur n'utilise qu'une de ses deux variantes, et la précharger toutes
// deux doublerait le premier téléchargement. Il est mis en cache à sa première
// utilisation (gestionnaire `fetch` plus bas), donc disponible hors connexion
// dès le premier lancement réussi.
const CORE = [
  './',
  'index.html',
  'flutter_bootstrap.js',
  'flutter.js',
  'main.dart.js',
  'manifest.json',
  'favicon.png',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
  'assets/AssetManifest.bin.json',
  'assets/FontManifest.json',
  'assets/fonts/MaterialIcons-Regular.otf',
  'assets/fonts/fallback/Roboto-Regular.ttf',
  'assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
  'assets/assets/icon.png',
];

self.addEventListener('install', (event) => {
  if (!ENABLED) return;
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE);
      // `cache: 'reload'` : contourne le cache HTTP du navigateur pour ne
      // jamais figer un fichier périmé dans le nouveau cache.
      await Promise.all(
        CORE.map(async (path) => {
          const response = await fetch(new Request(path, { cache: 'reload' }));
          if (!response.ok) throw new Error(`${path}: ${response.status}`);
          await cache.put(path, response);
        })
      );
      // Pas de skipWaiting automatique : la page décide quand basculer
      // (bandeau « Recharger »), pour ne pas changer de version en pleine saisie.
    })()
  );
});

self.addEventListener('message', (event) => {
  const data = event.data;
  if (data === 'skipWaiting') {
    self.skipWaiting();
  } else if (ENABLED && data && data.type === 'cacheUrls') {
    // Au tout premier lancement, le moteur graphique est téléchargé AVANT que
    // ce service worker ne contrôle la page : il n'est donc pas passé par le
    // gestionnaire `fetch`. La page nous donne la liste de ce qu'elle a chargé
    // (le navigateur les a encore dans son cache HTTP : pas de re-téléchargement
    // complet) pour que l'application soit utilisable hors connexion dès la
    // première visite.
    event.waitUntil(
      (async () => {
        const cache = await caches.open(CACHE);
        for (const href of data.urls) {
          const url = new URL(href, self.location.href);
          if (url.origin !== self.location.origin) continue;
          if (await cache.match(url.href)) continue;
          try {
            const response = await fetch(url.href);
            if (response.ok) await cache.put(url.href, response);
          } catch (_) {}
        }
      })()
    );
  }
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      if (!ENABLED) return;
      const names = await caches.keys();
      await Promise.all(
        names
          .filter((n) => n.startsWith('biosigma-') && n !== CACHE)
          .map((n) => caches.delete(n))
      );
      await self.clients.claim();
    })()
  );
});

self.addEventListener('fetch', (event) => {
  if (!ENABLED) return;
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;
  // version.json sert à détecter une nouvelle version : jamais depuis le cache.
  if (url.pathname.endsWith('/version.json')) return;

  event.respondWith(
    (async () => {
      const cache = await caches.open(CACHE);
      // Navigation (ouverture de l'application) : toujours index.html en cache.
      const key = request.mode === 'navigate' ? 'index.html' : request;
      const cached = await cache.match(key, { ignoreSearch: true });
      if (cached) return cached;
      // Fichier non préchargé (variantes de moteur, polices…) : réseau, puis
      // mise en cache pour les ouvertures suivantes.
      const response = await fetch(request);
      if (response.ok) cache.put(request, response.clone());
      return response;
    })()
  );
});
