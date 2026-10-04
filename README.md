# BioSigma

Application mobile (Android/iOS), en français, de calculs de biochimie clinique et d'hémostase
pour les biologistes médicaux et professionnels de santé. Fonctionne **entièrement hors
connexion** : tous les calculs s'exécutent sur l'appareil, aucun compte ni serveur.

> **Outil d'aide au calcul.** Chaque résultat doit être confronté aux données analytiques et
> cliniques, et validé par un professionnel compétent. BioSigma ne pose jamais de diagnostic.

## Sommaire

- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installer et lancer l'application](#installer-et-lancer-lapplication)
- [Exécuter les tests](#exécuter-les-tests)
- [Construire les paquets Android (APK) et iOS](#construire-les-paquets-android-apk-et-ios)
- [Héberger la version web sur un sous-domaine](#héberger-la-version-web-sur-un-sous-domaine)
- [Catalogue des calculs et sources scientifiques](#catalogue-des-calculs-et-sources-scientifiques)
- [Onglet Entraînement](#onglet-entraînement)
- [Décisions qui dépendent de la validation du laboratoire](#décisions-qui-dépendent-de-la-validation-du-laboratoire)
- [Confidentialité](#confidentialité)
- [État du projet : ce qui est construit et testé, ce qui reste à faire](#état-du-projet--ce-qui-est-construit-et-testé-ce-qui-reste-à-faire)

## Architecture

Monorepo à deux paquets Dart/Flutter :

```
BioSigma/
  packages/biosigma_core/   # Moteur de calcul PUR — aucune dépendance Flutter
    lib/src/models/         # Quantity, CalculationResult, FormulaMeta, Reference, erreurs
    lib/src/units/          # Bibliothèque centrale de conversion d'unités (Analyte, UnitRegistry)
    lib/src/calculators/    # 59 fonctions de calcul pures, groupées par domaine :
      renal/  metabolic/  ionogram/  hemostasis/  hematology/
    lib/src/catalog.dart    # Registre déclaratif des métadonnées (recherche, catégories)
    test/                   # 240 tests unitaires (dart test)
  app/biosigma/              # Application Flutter
    lib/models/               Contrat déclaratif du formulaire (CalculatorDefinition, champs),
                               questions/tentatives d'entraînement
    lib/data/                  Câblage des 59 calculateurs + banques de questions par domaine
    lib/screens/               root_tab_screen (barre de navigation à 5 onglets), calculateur
                                générique, panel CKD-EPI, scores guidés (ISTH-CIVD, 4Ts),
                                entraînement, références, réglages, à propos
    lib/services/              stockage local (réglages/historique/seuils/scores), formatage
                                des nombres
    lib/state/                 état applicatif partagé (provider)
    lib/widgets/update_checker.dart   vérification de nouvelle version (apps installées)
    lib/app_version.dart       version affichée, à synchroniser avec pubspec.yaml et web/version.json
    test/                      tests widget (dart test / flutter test), parcours bout en bout
    android/ ios/               projets natifs générés par `flutter create`, prêts à compiler
                                 (icônes + écran de démarrage déjà générés)
  docs/
    tracabilite-scientifique.md   Table complète : calcul → source → version → formule → limites
    rapport-de-tests.md           Résultats des analyses et tests exécutés dans cette session
    branding/                     Source SVG de l'icône (sigma + molécule + goutte)
  README.md                       Ce document
```

**Pourquoi un paquet séparé `biosigma_core`** : c'est le noyau scientifique, testable avec le seul
SDK Dart (sans Android Studio ni Xcode), indépendant de l'interface. Chaque calcul y est une
fonction pure retournant une valeur, sa formule exacte, sa version/source, ses unités, ses
avertissements et ses limites d'emploi — jamais un indice isolé.

**Interface pilotée par déclaration** : chaque calcul standard est décrit par un
`CalculatorDefinition` (`app/biosigma/lib/data/calculator_registry_*.dart`) qui relie ses champs de
saisie à la fonction du moteur. Un seul écran générique (`calculator_screen.dart`) affiche la
saisie, le résultat, les unités utilisées, la formule, la version et les limites. Trois écrans
dédiés existent pour les cas explicitement composés par le cahier des charges : le panel DFG
CKD-EPI (jusqu'à 3 équations côte à côte, jamais mélangées) et les modules guidés Score ISTH-CIVD
et Score 4Ts (saisie pas à pas, jamais d'inférence d'une donnée manquante).

**Interprétations toujours affichées, sourcées par société savante** : chaque résultat est
accompagné, quand une classification reconnue existe (KDIGO, ESC/EAS, ADA, AASLD, WHO, ISTH...),
d'un avertissement `info` (`CalculationWarning`, toujours rendu par `WarningList`, jamais masqué)
donnant l'interprétation courante — ex. stade KDIGO pour le DFG, grade ALBI, catégorie de risque
Framingham/SCORE2. Quand aucun seuil consensuel n'est reconnu par une société savante pour un
paramètre (HOMA-IR, QUICKI, TyG, SII, SIRI...), l'application le signale explicitement plutôt que
d'inventer un seuil — c'est une réponse honnête attendue, pas une lacune.

**Navigation** : cinq onglets en haut de l'écran (`RootTabScreen`, `TabBar` défilant sous une
`AppBar` unique et partagée) — Calcul, Entraînement, Références, Réglages, À propos. L'AppBar
(logo + « BioSigma ») ne se reconstruit pas au changement d'onglet : le logo reste donc visible en
permanence, y compris à l'ouverture de chaque onglet. Chaque écran d'onglet n'a plus son propre
`Scaffold`/`AppBar` ; un wrapper `AutomaticKeepAliveClientMixin` par onglet (le `TabBarView` ne
conserve pas ses enfants hors écran par défaut, contrairement à `IndexedStack`) préserve l'état de
chaque onglet (recherche en cours, position de défilement) au changement d'onglet.

**Vérification de nouvelle version** (`lib/widgets/update_checker.dart`) : au démarrage, sur
**toutes** les plateformes y compris le web (navigateur mobile ou PWA — le service worker de
BioSigma installe bien la nouvelle version en arrière-plan, mais rien n'en avertit l'utilisateur),
l'app interroge silencieusement `https://biosigma.komodi-labo.org/version.json` ; si une version plus
récente que `kAppVersion` (`lib/app_version.dart`) y est publiée, un bandeau propose soit un lien de
mise à jour (Android/iOS/bureau), soit, sur le web, la bascule vers le nouveau build puis le rechargement de la page (via
`lib/widgets/reload_page_web.dart` → `window.biosigmaApplyUpdate` dans `web/index.html`). Échec réseau = silencieux, aucun blocage du lancement. **À chaque livraison**, mettre à jour
ensemble `pubspec.yaml` (`version:`), `lib/app_version.dart` (`kAppVersion`) et
`app/biosigma/web/version.json` (`latest`) — sinon l'application se croira à jour, ou à l'inverse
proposera indéfiniment une « mise à jour » déjà installée.

## Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (canal stable — testé avec Flutter
  3.47.5 / Dart 3.13.4). Le SDK embarque Dart, aucune installation séparée n'est nécessaire.
- Pour Android : Android Studio (SDK, plateforme, outils de build, un JDK 17+) et un appareil ou
  émulateur.
- Pour iOS : un Mac avec Xcode complet (pas seulement les Command Line Tools) et, pour un appareil
  physique ou une publication, un compte développeur Apple.

## Installer et lancer l'application

```bash
cd BioSigma/app/biosigma
flutter pub get
flutter run            # lance sur l'appareil/émulateur/navigateur connecté
```

Le paquet `biosigma_core` est référencé en dépendance locale (`path: ../../packages/biosigma_core`)
dans `app/biosigma/pubspec.yaml` : aucune publication sur pub.dev n'est nécessaire.

## Exécuter les tests

```bash
# Moteur de calcul pur (240 tests) :
cd BioSigma/packages/biosigma_core
dart analyze
dart test

# Application Flutter (analyse + tests widget, dont un parcours bout en bout) :
cd BioSigma/app/biosigma
flutter analyze
flutter test
```

Résultats obtenus dans cette session : voir [`docs/rapport-de-tests.md`](docs/rapport-de-tests.md)
— `dart analyze` et `flutter analyze` sans aucun problème, 240/240 puis 9/9 tests verts.

## Construire les paquets Android (APK) et iOS

### Android

```bash
cd BioSigma/app/biosigma
flutter build apk --release      # APK de démonstration (signature debug par défaut)
# ou, pour le Play Store :
flutter build appbundle --release
```

Pour une signature de production, suivez le guide officiel
[« Sign your Android app »](https://docs.flutter.dev/deployment/android#signing-the-app) (création
d'un keystore, configuration de `android/key.properties`, référencé dans
`android/app/build.gradle.kts`).

**Non exécuté dans cette session** : cet environnement de développement ne contenait pas de SDK
Android (aucun Android Studio, Gradle, JDK) — installation volontairement écartée avec
l'utilisateur pour limiter le temps et le volume de téléchargement de cette passe. Le projet
`android/` généré par `flutter create` est présent, personnalisé (nom « BioSigma », icônes
générées), et prêt à compiler dès que ces outils sont installés.

### iOS

```bash
cd BioSigma/app/biosigma
flutter build ios --release      # nécessite Xcode complet et une équipe de signature configurée
```

Étapes restantes précises pour aller jusqu'à l'IPA :
1. Ouvrir `ios/Runner.xcworkspace` dans Xcode.
2. Sélectionner une équipe de développement (Signing & Capabilities) — un compte développeur
   Apple est nécessaire pour un appareil physique ou TestFlight/App Store.
3. `flutter build ipa --release`, ou archiver directement depuis Xcode (Product → Archive).

**Non exécuté dans cette session** : seules les Command Line Tools Xcode sont installées sur cette
machine (pas Xcode.app complet), et aucun compte développeur Apple n'est configuré pour la
signature — conformément à la consigne de ne jamais prétendre livrer un IPA sans les moyens
effectifs de le construire. Le projet `ios/` généré par `flutter create` est présent, personnalisé
(nom « BioSigma », icônes générées), et prêt à compiler dès que ces prérequis sont réunis.

### Vérification alternative effectuée dans cette session

`flutter build web --release` compile avec succès (voir `docs/rapport-de-tests.md`) et a permis de
vérifier visuellement l'ensemble des écrans dans un navigateur, y compris à largeur mobile (375 px)
— une confirmation supplémentaire que le code Dart/Flutter est correct, en complément des tests
automatisés, en l'absence d'émulateur/simulateur Android ou iOS dans cet environnement.

## Héberger la version web sur un sous-domaine

Flutter compile aussi vers le web (`flutter build web`) : cette même base de code peut être servie
comme site à part entière, en plus (ou en attendant) des paquets Android/iOS. Un déploiement Docker
prêt à l'emploi est fourni à la racine (`Dockerfile`, `nginx.conf`, `docker-compose.yml`,
`docker-compose.caddy.yml`, `deploy/Caddyfile.biosigma`, `install-caddy.sh`) — construit et testé
localement dans cette session (image Docker fonctionnelle, servie par nginx, vérifiée en HTTP 200).

Pour l'installation sur le VPS partagé avec NexoLab et PhénoBac
(`biosigma.komodi-labo.org`), voir [`DEPLOY-VPS.md`](DEPLOY-VPS.md) — spécifique à cette
infrastructure (réseau Docker de la façade Caddy déjà identifié, commande de rechargement exacte).

**Important** : la version web n'est qu'une vitrine supplémentaire du même moteur de calcul ; elle
ne remplace pas les paquets Android/iOS natifs pour un usage professionnel hors connexion garanti
(un navigateur reste tributaire de son cache, moins robuste qu'une application installée).

**Mode hors connexion du web** (`web/biosigma_sw.js`) : le service worker généré par Flutter 3.47
(`flutter_service_worker.js`) n'est qu'un nettoyeur qui se désinscrit, il ne met **rien** en cache ;
BioSigma enregistre donc le sien (le bootstrap personnalisé `web/flutter_bootstrap.js` empêche Flutter
d'enregistrer le sien). À la première visite il met en cache l'application, le moteur graphique
(CanvasKit, hébergé sur notre serveur grâce à `--no-web-resources-cdn`) et les polices ; ensuite elle
démarre sans rien télécharger et fonctionne sans connexion. Le cache est versionné par build :
`tool/stamp_sw.sh` (lancé par le Dockerfile) inscrit l'empreinte du build dans `biosigma_sw.js`, ce qui
fait détecter la nouvelle version au navigateur ; un nouveau build s'installe en arrière-plan puis
bascule d'un coup (jamais un mélange d'ancien et de nouveau). **Pour un build local destiné à être
servi** : `flutter build web --release --no-web-resources-cdn && sh tool/stamp_sw.sh build/web` ;
sans l'étape `stamp_sw.sh`, le service worker reste inerte (aucune mise en cache, rien ne casse).

## Catalogue des calculs et sources scientifiques

Voir [`docs/tracabilite-scientifique.md`](docs/tracabilite-scientifique.md) pour la table des 32
premiers calculs (source primaire → version → formule → unités → population → cas interdits →
limites) ; les 27 calculs ajoutés ultérieurement (MELD-Na, ALBI, IMC, TyG-IMC, HOMA-β, CT/HDL-C,
ApoB/ApoA1, compensation acido-basique attendue, rapport bicarbonates/chlorures, indices de Mentzer,
Shine-Lal, England-Fraser, Green-King et RDWI, panel réticulocytaire, SII, SIRI, rapport normalisé
dRVVT, score SIC, score de Framingham, SCORE2, HAS-BLED, CHA₂DS₂-VASc, score de Padua, IMPROVE et
score de Caprini) suivent la même exigence de traçabilité, documentée directement dans leur
`FormulaMeta` (source, équation, population, limites) et consultable hors connexion depuis l'écran
« Références ». Les 5 derniers (HAS-BLED, CHA₂DS₂-VASc, Padua, IMPROVE, Caprini) sont des **scores
cliniques** — âge, antécédents, contexte chirurgical — pas de simples calculs biologiques ; ajoutés
à la demande explicite de l'utilisateur, qui en a choisi la liste après avoir été informé de cette
nature clinique. Les 8 ajouts initialement requis sont présents et testés : indice de Rosner, les
trois équations CKD-EPI (créatinine 2021, cystatine C 2012, créatinine-cystatine C 2021), Schwartz
bedside, protéinurie des 24 h, QUICKI et TyG.

Les références complètes (citations) sont embarquées dans le code (`FormulaMeta.sources`) et
consultables hors connexion depuis l'écran « Références et limites » de l'application.

## Onglet Lab (phase 1 de BioSigma Lab)

Deux modules sont disponibles ; ils ne font pas partie du catalogue des 59 calculs cliniques.

- **Convert** : conversion de grandeurs par préfixes SI (masse, volume, quantité de matière,
  équivalents, concentrations). Pour changer de nature (masse → mol → équivalents), la **masse molaire
  et la valence sont saisies par l'utilisateur** : BioSigma n'embarque aucune masse molaire nouvelle.
  Un second mode convertit les 11 analytes cliniques déjà gérés, avec leurs facteurs existants
  (arrondis, non validés).
- **Dilute** : dilution simple (C1·V1 = C2·V2), dilutions en série, résultat après dilution avec
  contrôle de l'intervalle de linéarité saisi par l'utilisateur.

Les modules Prepare, Count, Microbiology, Quality et Smart Solver sont affichés comme **prévus et
non disponibles** : ils attendent des données sourcées et validées (masses molaires, pKa, chambres de
numération, norme, limites d'erreur) — aucune valeur n'est inventée. Voir
`docs/biosigma-lab/00-audit-et-architecture.md` (backlog P1-xx, P2-xx).

## Onglet Entraînement

Quatre banques de questions (une par domaine : rénal, cardiométabolique, ionogramme, hémostase —
`lib/data/quiz/`), tirées par **séries de `kQuizSessionSize` (20) questions au hasard** à chaque
lancement (`QuizModule.sampleSession`, `lib/screens/quiz_module_screen.dart`).

**État actuel de la banque : 232 questions** (55 rénal, 55 cardiométabolique, 68 ionogramme,
54 hémostase). La banque est **volontairement arrêtée à ce volume** (l'extension à ~1000 questions
a été abandonnée). Elle est essentiellement composée de **cas cliniques et questions
d'interprétation**, complétées par de la culture scientifique et du vocabulaire, sans jamais
asserter un seuil clinique numérique comme une vérité universelle :

- **Cas clinique / interprétation** (majoritaire) : un bref contexte patient-laboratoire, puis une
  question fermée dont la bonne réponse reprend fidèlement un fait déjà documenté dans le
  `FormulaMeta` du calcul concerné (population d'application, condition interdite, condition
  analytique, limite d'emploi) — jamais un fait inventé, jamais un seuil diagnostique non codé.
- **Culture scientifique** : auteur, année, revue de la publication d'origine d'une formule.
- **Vocabulaire** : définition des acronymes utilisés dans l'application (IDMS, ISI, AIP…).

Correction immédiate avec explication sourcée après chaque réponse ; score de la série sauvegardé
localement uniquement (`AppStorageService`, jamais transmis en ligne), effaçable depuis Réglages.
C'est un outil d'auto-évaluation pédagogique — il ne remplace ni une formation validante ni un
jugement clinique, rappelé en bandeau sur chaque écran d'entraînement.

## Décisions qui dépendent de la validation du laboratoire

BioSigma ne code aucun seuil interprétatif clinique comme une vérité universelle. Les points
suivants nécessitent une décision et une validation propres à chaque laboratoire :

1. **Confirmation IDMS** : une case à cocher est exigée avant tout calcul CKD-EPI/Schwartz — la
   méthode analytique ne peut pas être vérifiée automatiquement par l'application.
2. **Seuils interprétatifs** (HOMA-IR, TyG, indice athérogène, TSAT, A/G, ASAT/ALAT, indice de
   Rosner…) : configurables dans Réglages → Seuils locaux (valeur, unité, méthode, date,
   responsable de validation) ; aucune valeur par défaut n'est présentée comme universelle.
3. **Formule LDL par défaut** (Friedewald ou Sampson) et seuil de triglycérides bloquant : un choix
   par défaut est proposé mais reconfigurable.
4. **Facteur transferrine → CTF** (×1,42 usuel) : affiché comme un facteur de laboratoire par
   défaut, à confirmer localement.
5. **Interprétation des scores ISTH-CIVD et 4Ts** : comme pour tous les autres calculateurs, le
   texte d'interprétation est toujours affiché (décision D-03 du 2026-10-03 ; l'ancien réglage
   « interprétations locales validées », qui masquait ce texte, a été retiré). Aucune interprétation
   n'est pour autant validée par un biologiste responsable : voir la revue scientifique finale
   ci-dessous.
6. **Coefficient de correction du sodium** (Katz 1,6 ou Hillier 2,4) : les deux résultats sont
   toujours affichés côte à côte, le laboratoire retient celui qu'il utilise en pratique.

## Confidentialité

- Aucune identité de patient n'est jamais demandée ni stockée.
- Aucune télémétrie, aucun accès réseau nécessaire au fonctionnement.
- L'historique local est **désactivé par défaut** ; une fois activé, il ne contient que le calcul,
  les entrées et le résultat (jamais d'identité), et peut être effacé à tout moment.
- Un bouton « Supprimer toutes les données locales » (réglages, favoris, historique, seuils) est
  disponible dans Réglages.
- Copier ou partager un résultat exige une action explicite de l'utilisateur.

## État du projet : ce qui est construit et testé, ce qui reste à faire

| Élément | État |
|---|---|
| Moteur de calcul pur (59 calculs, conversions, métadonnées, 5 domaines dont hématologie, interprétations sourcées) | ✅ Construit, `dart analyze` propre, 240/240 tests verts |
| Application Flutter (accueil, recherche, favoris, 59 calculateurs génériques, panel CKD-EPI, scores guidés, réglages, références, historique, seuils locaux, accessibilité, thème clair/sombre) | ✅ Construite, `flutter analyze` propre, 9/9 tests widget verts, vérifiée visuellement (bureau et mobile) |
| Navigation par onglets, en haut de l'écran (Calcul, Entraînement, Références, Réglages, À propos) | ✅ `TabBar` sous une `AppBar` partagée (logo visible en permanence, y compris à l'ouverture de chaque onglet), testée (parcours bout en bout par onglet) |
| Interprétations toujours affichées, sourcées par société savante (KDIGO, ESC/EAS, ADA, AASLD, WHO, ISTH...) ; honnêtement signalées comme non consensuelles quand aucune n'existe (SII, SIRI, HOMA-IR, QUICKI, TyG...) | ✅ `CalculationWarning` (sévérité `info`) sur chaque calculateur concerné, jamais masqué |
| SCORE2 (risque cardiovasculaire ESC 2021, 4 régions européennes) | ✅ Coefficients vérifiés par recherche web contre le papier original et deux implémentations indépendantes (résultats reproduits au dixième de %) |
| Scores de risque hémorragique/thrombotique cliniques (HAS-BLED, CHA₂DS₂-VASc, Padua, IMPROVE, Caprini) | ✅ Chaque critère et valeur de points vérifiés par recherche web contre ≥2 sources indépendantes ; catégories de risque sourcées (ACCP/CHEST, ACC/AHA/HRS...) |
| Écran de démarrage (logo) | ✅ Généré pour Android et iOS (`flutter_native_splash`) ; équivalent HTML/CSS ajouté pour le web (retiré au premier rendu Flutter) |
| Vérification de nouvelle version (toutes plateformes, y compris le web) | ✅ `version.json` publié sur le site, bandeau in-app (lien de mise à jour hors web, rechargement de page sur web) si une version plus récente existe |
| Onglet Entraînement (4 banques, séries de 20 tirées au hasard, majorité cas cliniques/interprétation) | ✅ **232 questions** au total (55 rénal, 55 cardiométabolique, 68 ionogramme, 54 hémostase) ; scores locaux uniquement, tests de contenu + parcours bout en bout verts. Banque en expansion progressive vers l'objectif de ~1000 questions. |
| Icône et identité visuelle (bleu nuit/cyan/corail, sigma + molécule + goutte) | ✅ Générée pour Android et iOS (`flutter_launcher_icons`) |
| Table de traçabilité scientifique complète | ✅ `docs/tracabilite-scientifique.md` |
| Build web de démonstration | ✅ `flutter build web` réussi, utilisé pour la vérification visuelle |
| Hébergement web (Dockerfile, nginx, Caddy) | ✅ **En service** sur https://biosigma.komodi-labo.org (VPS partagé avec NexoLab/PhénoBac) — voir `DEPLOY-VPS.md` |
| **APK Android** | ❌ Non construit : SDK Android absent de cet environnement (choix explicite pour cette passe). Projet `android/` prêt. |
| **IPA iOS** | ❌ Non construit : Xcode complet et compte développeur Apple absents. Projet `ios/` prêt. |
| Tests d'instrumentation sur appareil/émulateur réel | ❌ Non exécutés (pas de SDK Android/iOS) |
| Revue scientifique finale par un biologiste responsable | ❌ À faire par le laboratoire avant mise en production |

---

*Nom de travail « BioSigma » et icône fournis à titre provisoire — remplaçables si une vérification
de disponibilité du nom (stores, marques) le nécessite ; voir `docs/branding/icon.svg` pour la
source modifiable de l'icône.*
