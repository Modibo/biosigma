# Veille de dépendances (P6-04)

Objectif : savoir à tout moment quels paquets sont en retard, et décider de les mettre à jour **à un moment choisi, avec les tests**, jamais en passant.

## Procédure

| Quand | Quoi |
|---|---|
| **Avant chaque version publiée** | `cd app/biosigma && sh tool/veille_dependances.sh` ; noter ici les écarts. |
| **Chaque lundi** (automatique, une fois la CI GitHub activée) | Le workflow `.github/workflows/veille.yml` publie le même rapport dans le résumé de l'exécution. Il est informatif : il n'échoue pas et ne modifie rien. |
| **Mise à jour décidée** | Branche dédiée → `flutter pub upgrade` (mises à jour mineures/correctives) ou modification explicite de `pubspec.yaml` (mise à jour majeure) → `flutter analyze` + `flutter test` (app) + `dart test` (moteur) + `flutter build web --release` + essai manuel sur un appareil → version supérieure publiée. |
| **Flutter lui-même** | Version épinglée dans la CI (`flutter-version: '3.47.5'`) ; `pubspec.yaml` fixe seulement le SDK Dart minimal (`sdk: ^3.13.4`). Une montée de version de Flutter se traite comme une mise à jour majeure : golden master identique, tests d'accessibilité et de texte agrandi, essai hors connexion. |
| **Faille de sécurité signalée** | Mise à jour immédiate du paquet concerné, même hors fenêtre ; noter ici la date et la raison. |

Règle : une mise à jour de dépendance **ne doit jamais modifier un résultat de calcul** ; le golden master (`app/biosigma/test/golden/`) le vérifie.

## État relevé le 2026-10-04 (Flutter 3.47.5)

### Application (`app/biosigma`)

| Paquet | Type | Verrouillé | Dernière | Nature de l'écart | Décision |
|---|---|---|---|---|---|
| `cupertino_icons` | direct | 1.0.9 | 2.0.0 | **majeure** | Ne pas mettre à jour sans essai : pas d'urgence (icônes seulement). |
| `url_launcher` | direct | 6.3.2 | 6.3.3 | corrective | À appliquer à la prochaine version, avec les tests. |
| `meta` | transitif | 1.18.3 | 1.19.0 | mineure | Suit Flutter. |
| `vector_math` | transitif | 2.4.0 | 2.4.3 | corrective | Suit Flutter. |
| `material_color_utilities` | transitif | 0.13.0 | 0.13.1 | corrective | Suit Flutter. |
| `petitparser`, `xml`, `test_api`, `cli_util` | transitifs (dev) | — | — | outillage de test | Sans effet sur l'application publiée. |

### Moteur (`packages/biosigma_core`)

Toutes les dépendances directes et de développement sont à jour. Seul `frontend_server_client` (outillage de test, transitif) a une version corrective plus récente.

## Autres veilles à ne pas oublier

- **Référentiels scientifiques** : les formules dont la source évolue (KDIGO, ESC/EASL, UNOS/MELD, CKD-EPI) sont suivies dans le registre de validation (`registre-validation.csv`) et les dossiers `fiches-de-validation/`. Une évolution de recommandation n'est **pas** détectée par cet outil : elle relève du validateur scientifique.
- **Navigateurs** : le mode hors connexion repose sur un service worker maison (`web/`). Après une mise à jour majeure de Safari, Chrome ou Firefox, refaire le protocole d'essai (`protocole-tests-appareils.md`, scénarios hors connexion et mise à jour).
- **Serveur** : image Docker et Caddy du VPS (voir `DEPLOY-VPS.md`) ; la mise à jour de l'hôte est indépendante de l'application.
