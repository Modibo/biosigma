# Performance de BioSigma (backlog P6-02, décision D-14)

> **Statut : mesures réelles + budget PROVISOIRE.** Les budgets ci-dessous sont proposés par l'assistant ; **D-14 reste à confirmer** par le responsable. Les mesures ont été faites le 2026-10-04 sur la machine de développement ; elles ne représentent **pas** un téléphone d'entrée de gamme.

## 1. Mesures (version 1.16.0, build web de production)

Tailles compressées estimées par `gzip -6` (Caddy sert en zstd/gzip, ce qui donne des tailles du même ordre ; zstd est généralement un peu plus petit). Script reproductible : `app/biosigma/tool/check_bundle_size.sh`.

| Fichier (Chrome/Edge) | Brut | Compressé |
|---|---:|---:|
| `main.dart.js` (le code de l'application) | 3,97 Mo | **1,16 Mo** |
| `canvaskit/chromium/canvaskit.wasm` (moteur graphique Flutter) | 5,43 Mo | **2,06 Mo** |
| `canvaskit.js`, `flutter*.js`, `index.html`, service worker, manifeste | 0,12 Mo | 0,04 Mo |
| Police de secours Roboto | 0,17 Mo | 0,09 Mo |
| Icône, polices d'icônes | 0,06 Mo | 0,05 Mo |
| **Total premier chargement (Chrome/Edge)** | | **≈ 3,40 Mo** |
| Autres navigateurs (Safari, Firefox : `canvaskit.wasm` générique, 2,92 Mo compressé) | | ≈ 4,3 Mo |
| **Visite suivante** (service worker, hors connexion) | | **≈ 0 octet** (seul `version.json`, 0,4 Ko, est relu) |

**Évolution du poids de l'application** (`main.dart.js`) : version 1.6.0 = 3,63 Mo brut / **1,06 Mo** compressé ; version 1.16.0 = 3,97 Mo / **1,16 Mo**. Soit **+9 %** pour : 125+ analytes, 7 modules Lab, registre, historique v2, recherche universelle, planificateur, impression, accessibilité, 2 calculs d'hématologie. Le moteur graphique (58 % du premier chargement) ne dépend pas de nous : il vient du SDK Flutter.

**Temps de démarrage** (cache chaud, machine de développement, Chrome) : le canevas du moteur graphique apparaît en ≈ 0,19 s. Ce chiffre ne dit **rien** du premier chargement réel (réseau) ni d'un téléphone modeste (processeur plus lent) : **non mesuré sur appareil réel**.

## 2. Durée de téléchargement du premier chargement (calcul, pas mesure)

Arithmétique simple sur 3,40 Mo (≈ 27 Mbit), sans latence ni redémarrages TCP — la réalité sera plus lente :

| Débit | Durée minimale |
|---|---:|
| 10 Mbit/s | ≈ 3 s |
| 2 Mbit/s | ≈ 14 s |
| 1 Mbit/s | ≈ 27 s |
| 400 kbit/s | ≈ 1 min 8 s |
| 200 kbit/s | ≈ 2 min 16 s |

Après ce premier chargement, plus rien ne se télécharge : c'est le mode hors connexion qui rend le coût supportable. **Conséquence pratique pour votre contexte (réseaux lents)** : faire le premier chargement une fois sur une bonne connexion (Wi-Fi), puis utiliser l'application hors connexion. Un « chargement initial » peut être préparé en amont sur les appareils du laboratoire.

## 3. Budget proposé (à confirmer — D-14)

| Indicateur | Budget proposé | Valeur actuelle |
|---|---:|---:|
| `main.dart.js` compressé | ≤ 1,30 Mo | 1,16 Mo |
| Premier chargement Chrome/Edge (compressé) | ≤ 4,0 Mo | 3,40 Mo |
| Visite suivante | ≈ 0 octet (hors `version.json`) | ≈ 0 |
| Mise à jour (nouvelle version) | re-téléchargement de `main.dart.js` seul (≈ 1,2 Mo) ; CanvasKit reste en cache | — |

Ces budgets sont des **plafonds de non-régression** (version actuelle + ~12 %), pas des objectifs ambitieux : ils empêchent qu'un ajout fasse grossir l'application sans qu'on le voie. Le contrôle est automatisé : `sh tool/check_bundle_size.sh` (échoue si dépassement), exécuté par la CI après un build web.

**Objectif de démarrage sur appareil** (à fixer **après** mesure sur un téléphone de référence, voir `protocole-tests-appareils.md`) : non défini, faute de mesure réelle.

## 4. Pistes de réduction, par ordre d'intérêt

| Piste | Gain estimé | Coût / risque | Recommandation |
|---|---|---|---|
| Rien d'autre à faire pour la visite suivante | — | — | Déjà ≈ 0 octet |
| Chargement différé des banques de quiz (≈ 200 Ko de source) | ≈ 40 Ko compressés (≈ 3 %) | Modification de l'écran Entraînement ; faible gain | **Non** |
| Rendu `skwasm` / compilation WebAssembly de Flutter | Démarrage plus rapide sur navigateurs récents | Prise en charge variable (Safari, anciens appareils) ; changement de moteur à tester sur appareils | **Pas maintenant** : à évaluer après les tests sur appareils réels |
| Brotli en façade | ≈ 10-15 % de moins que gzip | Caddy standard ne le propose pas (zstd + gzip déjà actifs) ; module spécial | **Non** |
| Réduire CanvasKit | Gros gain (58 % du total) | Impossible : fait partie du SDK Flutter | — |
| Préchargement `<link rel=preload>` du moteur | Quelques centaines de ms | Variante CanvasKit dépend du navigateur : risque de télécharger le mauvais fichier | **Non** |

Conclusion : **pas d'optimisation de code justifiée aujourd'hui**. Le poids est dominé par le moteur graphique ; l'application a grandi de 9 % en dix versions. La priorité est de **mesurer sur de vrais appareils** (P6-03) avant d'investir.

## 5. Limites de ces mesures

- Aucune mesure sur téléphone, ni réseau lent réel, ni Safari/Firefox ; les tailles compressées sont des estimations `gzip -6`, pas les octets réellement transférés par Caddy (zstd).
- Le temps de démarrage affiché est celui d'une machine puissante avec cache chaud.
- Mémoire et consommation de batterie non mesurées.
