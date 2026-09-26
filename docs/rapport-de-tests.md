# Rapport de tests — BioSigma

Environnement : Flutter 3.47.5 (canal stable) • Dart 3.13.4 • macOS arm64, exécuté le 25/09/2026.
SDK Flutter/Dart installé pour cette session, sans SDK Android ni Xcode complet (cf. `README.md`
§ Limites d'environnement).

## 1. Moteur de calcul pur (`packages/biosigma_core`)

```
$ dart analyze
No issues found!

$ dart test
...
+95: All tests passed!
```

- **95 tests unitaires**, tous verts : bibliothèque de conversion d'unités (16 tests, aller-retour
  sur les 12 analytes) + 32 calculateurs (≥ 2 cas chacun, dont un cas limite : âge hors domaine,
  triglycérides hors domaine de validité LDL, collecte urinaire incomplète, score incomplet,
  division par valeur nulle, unité inconnue, etc.).
- **0 avertissement d'analyse statique** (`dart analyze`, lints activés).
- Les valeurs « attendues » de chaque test ont été calculées indépendamment de l'implémentation
  Dart, par un script Python distinct écrit à partir des formules publiées, avant que le code
  Dart ne soit écrit par les agents chargés de chaque domaine — conformément à l'exigence de ne
  jamais dériver un nombre attendu par simple copie de la fonction testée.

### Écart de calcul signalé et clarifié pendant l'implémentation

L'agent en charge du domaine ionogramme a signalé un écart de ≈0,002 mmol/L entre une valeur
« attendue » approximative fournie dans les instructions (calcium corrigé ≈ 2,2725 mmol/L) et la
valeur exacte obtenue avec le facteur de conversion figé du registre d'unités (2,27045 mmol/L). Un
second cas de test du même calcul, cohérent avec le facteur du registre, confirme qu'il s'agissait
d'une approximation arrondie dans l'énoncé du test, pas d'une erreur d'implémentation. Le test a
été conservé avec la valeur dérivée du registre, documentée en commentaire. Aucune autre
divergence n'a été signalée par aucun des quatre agents ayant implémenté les 32 calculateurs.

## 2. Application Flutter (`app/biosigma`)

```
$ flutter analyze
No issues found!

$ flutter test
...
+5: All tests passed!
```

5 tests widget, dont un **parcours bout en bout complet** (accueil → recherche → ouverture d'un
calculateur → saisie → calcul → résultat affiché), vérifiant :
- l'affichage du titre, de la recherche et des outils composés à l'accueil ;
- le filtrage par recherche ;
- un calcul réel (QUICKI, insuline 15 µU/mL, glycémie 5,0 mmol/L → résultat ≈ 0,3195 affiché avec
  séparateur décimal virgule) ;
- la navigation vers Réglages et Références.

## 3. Vérification visuelle manuelle (capture d'écran, build web de démonstration)

Flutter permettant de compiler pour le web sans SDK Android/iOS, un build de démonstration
(`flutter build web --release`) a été utilisé pour parcourir visuellement l'application dans un
navigateur — **cela ne remplace pas les paquets Android (APK) ou iOS, qui nécessitent leurs SDK
respectifs (voir `README.md`)**, mais confirme que l'interface se comporte correctement :

- Écran d'accueil : recherche, outils composés (panel CKD-EPI, scores guidés), catégories,
  favoris — vérifié visuellement dans le navigateur intégré (captures d'écran transmises dans la
  conversation de développement, non archivées comme fichiers dans ce dépôt).
- Panel CKD-EPI : saisie Âge=60, Sexe=Femme, Créatininémie=70 µmol/L, IDMS confirmée →
  **DFG CKD-EPI créatinine 2021 = 85,4 mL/min/1,73 m²**, recalculé indépendamment à la main :
  `142 × (70/88,42/0,7)^-0,241 × 1^-1,2 × 0,9938^60 × 1,012 ≈ 85,4` (les deux termes min/max
  s'inversent car 70/88,42/0,7 ≈ 1,13 > 1, cf. détail dans `docs/tracabilite-scientifique.md`).
- Module guidé Score ISTH-CIVD : bascule « pathologie associée », numération plaquettaire,
  sélecteurs catégoriels avec points affichés, champs TP/fibrinogène — rendu conforme au cahier
  des charges (« score incomplet » si un critère manque, interprétation masquée par défaut).
- Testé aux largeurs bureau (800 px) et mobile (375 px) : aucun débordement, mise en page adaptée.

**Anomalie détectée puis corrigée pendant cette vérification visuelle** : le bouton « Nouvelle
saisie » ne vidait pas visuellement les champs de texte déjà saisis (les `TextFormField` non
contrôlés ne suivent pas un changement de valeur externe après leur premier rendu). Corrigé en
attribuant une clé de widget dépendant d'un compteur de génération, incrémenté à chaque
réinitialisation, dans `calculator_screen.dart`, `ckd_epi_panel_screen.dart` et
`isth_dic_screen.dart` — revérifié visuellement après correction, comportement conforme. Ce type
de défaut n'est pas détectable par les tests `flutter test` existants (qui utilisent
`enterText`, qui contourne le rendu DOM/Skia réel) ; il n'a été trouvé que par l'inspection
visuelle manuelle exigée par le cahier des charges.

## 4. Calculs chiffrés vérifiés indépendamment (extrait)

| Calcul | Entrées | Résultat applicatif | Recalcul indépendant |
|---|---|---|---|
| CKD-EPI créatinine 2021 | 60 ans, F, Scr 70 µmol/L, IDMS ok | 85,4 mL/min/1,73 m² | 85,4 (calcul manuel ci-dessus) |
| QUICKI | Insuline 15 µU/mL, Glycémie 5,0 mmol/L | 0,3195 | 0,31945… (Python indépendant) |
| TyG | TG 150 mg/dL, Glycémie 90 mg/dL | 8,8173 | 8,817297… (Python indépendant) |
| Indice de Rosner | Mélange 38 s, témoin 12 s, patient 70 s | 37,14 % | 37,142857… (Python indépendant) |
| INR | TP patient 28 s, TP témoin 12 s, ISI 1,2 | 2,76 | 2,764217… (Python indépendant) |
| LDL Friedewald | TC 200 mg/dL, HDL 50 mg/dL, TG 100 mg/dL | 130,0 mg/dL | 130,0 (calcul manuel : 200−50−100/5) |
| Score ISTH-CIVD | Plaquettes 80 G/L, marqueur modéré, TP+4s, Fibrinogène 0,8 g/L | 5 points | 1+2+1+1=5 (barème manuel) |

## 5. Ce qui reste à faire (hors périmètre de cette session)

- **APK Android** : nécessite le SDK Android, Gradle et un JDK (non installés dans cet
  environnement par choix explicite, cf. `README.md`). Le projet `android/` généré par
  `flutter create` est présent et prêt à compiler une fois ces outils installés.
- **IPA iOS** : nécessite Xcode complet (seules les Command Line Tools sont présentes ici) et un
  compte développeur Apple pour la signature. Le projet `ios/` est présent et prêt à compiler.
- **Tests d'instrumentation sur appareil/émulateur réel** (Android/iOS) : non exécutés ici, faute
  de SDK ; les tests `flutter test` (widget tests, moteur headless) couvrent la logique et le
  rendu, mais pas les comportements spécifiques à une plateforme (permissions, cycle de vie natif).
- **Revue scientifique par un biologiste responsable** des seuils et commentaires cliniques, et
  validation locale des seuils interprétatifs (cf. `README.md` § Décisions dépendant de la
  validation du laboratoire).

## 6. Livraison du 26/09/2026 — navigation par onglets, entraînement, mise à jour

Environnement identique (Flutter 3.47.5, mêmes limites de SDK). Changements :

- **Navigation** : accueil restructuré en 5 onglets (`NavigationBar`, `RootTabScreen`), remplaçant
  les icônes d'AppBar. Testé : présence des 5 onglets, navigation vers chacun, persistance des
  onglets via `IndexedStack`.
- **Écran de démarrage** : généré nativement (Android/iOS) via `flutter_native_splash`, logo sur
  fond bleu nuit (#0F2245). Non testable automatiquement (rendu natif hors du moteur Flutter) —
  fichiers générés vérifiés présents (`android/app/src/main/res/drawable*/splash.png` et
  `android12splash.png`, `ios/Runner/Assets.xcassets/LaunchImage.imageset`).
- **Vérification de nouvelle version** : `lib/widgets/update_checker.dart`, gardé par `kIsWeb`
  (jamais actif sur le build web). Compilation vérifiée (`flutter analyze`), logique de comparaison
  de version couverte par construction (`isNewerVersion`), mais l'appel réseau réel vers
  `biosigma.komodi-labo.org/version.json` et l'ouverture du lien (`url_launcher`) n'ont pas pu être
  exercés en tests automatisés (canaux de plateforme) — à vérifier manuellement sur un appareil réel
  après publication d'une version supérieure à `kAppVersion`.
- **Références et limites** : nom complet de chaque formule maintenant affiché au-dessus de sa fiche
  technique. Vérifié par test et visuellement.
- **Onglet Entraînement** : renommé (ex-« Formation »), restructuré en séries de
  `kQuizSessionSize` = 20 questions tirées au hasard (`QuizModule.sampleSession`) dans une banque par
  domaine, au lieu d'un jeu fixe. La banque est passée de 32 à **232 questions** dans cette
  livraison (55 rénal, 55 cardiométabolique, 68 ionogramme, 54 hémostase), ajoutées par 4 agents en
  parallèle (un par domaine), chacun contraint de n'ancrer ses questions `clinicalCase` que sur des
  faits déjà présents dans les `FormulaMeta` du moteur (aucun seuil clinique inventé). Vérifications :
  - `dart analyze` sur chaque fichier de banque : propre.
  - `flutter test test/data/quiz_content_test.dart` : intégrité structurelle (4 options, index
    valide, ids uniques) sur les 232 questions — vert.
  - Contrôle manuel par échantillonnage (lecture directe d'extraits de chaque fichier, recherche de
    prompts ou d'ids dupliqués sur l'ensemble des 4 fichiers) : aucun doublon, questions bien
    ancrées dans les métadonnées déjà vérifiées du moteur.
  - Test bout en bout (`widget_test.dart`) : ouvre une série réelle de 20 questions tirée de la
    banque rénale (55 questions), répond correctement à chacune en découvrant dynamiquement la
    question affichée (pas d'ordre supposé, compatible avec le tirage aléatoire), vérifie le score
    final 20/20 et son report sur l'écran Entraînement — vert.
  - **Non fait dans cette livraison** : revue clinique exhaustive des 200 nouvelles questions par un
    biologiste responsable (seul un échantillon a été relu manuellement) ; poursuite de la banque
    vers l'objectif de 1000 questions.

## 7. Correctif du 26/09/2026 — onglets en haut, logo visible sur chaque onglet

Suite à un signalement utilisateur : « l'organisation en 5 onglets disponible en entête et
l'affichage du logo au démarrage ne sont pas visibles ». Diagnostic :

- **Cause 1 (blocante)** : cache navigateur/service-worker sur `main.dart.js`, empêchant le
  chargement de la version déployée. Corrigé côté serveur : `nginx.conf` ajoute désormais
  `Cache-Control: no-cache` explicite pour `main.dart.js`, `flutter.js`, `flutter_bootstrap.js` et
  `manifest.json` (en plus des règles déjà existantes pour `index.html`,
  `flutter_service_worker.js` et `version.json`).
- **Cause 2** : le splash natif (`flutter_native_splash`) est exclu du web par construction
  (`web: false`) ; le web n'affichait donc aucun logo au démarrage par design, pas par bug. Ajout
  d'un splash HTML/CSS autonome dans `web/index.html` (`#app-splash`, fond #0F2245, logo centré),
  retiré au premier rendu Flutter via l'évènement `flutter-first-frame`.

En plus de ce correctif, demande explicite de repositionner la barre d'onglets en haut (au lieu du
bas) et de garantir que le logo reste visible à l'ouverture de **chaque** onglet, pas seulement
l'onglet par défaut. Changement d'architecture :

- `RootTabScreen` reconstruit avec `DefaultTabController` + une seule `AppBar` partagée (logo +
  « BioSigma ») portant `bottom: TabBar(isScrollable: true, tabs: [...])`, et un `TabBarView` pour
  le contenu — remplace l'ancienne `NavigationBar` Material 3 en bas d'écran avec `IndexedStack`.
  Comme l'AppBar ne se reconstruit jamais au changement d'onglet, le logo est désormais visible en
  permanence, y compris à l'ouverture de chaque onglet (satisfait explicitement la demande).
- Les 5 écrans d'onglet (`home_screen.dart`, `entrainement_screen.dart`, `references_screen.dart`,
  `settings_screen.dart`, `about_screen.dart`) ont perdu leur propre `Scaffold`/`AppBar` ; chacun
  expose directement son contenu via `SafeArea(top: false, child: ...)`.
- `TabBarView`, contrairement à `IndexedStack`, ne conserve pas ses enfants hors écran par défaut :
  ajout d'un wrapper privé `_KeepAlive` (`AutomaticKeepAliveClientMixin`) autour de chaque onglet
  pour préserver l'état (recherche en cours, position de défilement, session de quiz en cours) au
  changement d'onglet.
- `about_screen.dart` : correction d'un résidu affichant « BioSigma 1.0.0 » en dur ; utilise
  désormais `$kAppVersion`.

Vérifications :

- `flutter analyze` : propre (aucune erreur/avertissement).
- `flutter test` : 9/9 verts après mise à jour de `test/widget_test.dart` (le finder de bascule
  d'onglet et la vérification de présence des onglets ciblent désormais `TabBar` au lieu de
  `NavigationBar`, qui n'existe plus dans l'arbre de rendu).
- Vérification visuelle (`flutter build web --release`, navigateur intégré) : AppBar affichant le
  logo + « BioSigma » avec les 5 onglets défilants en dessous (Calcul, Entraînement, Références,
  Réglages, À propos) ; changement d'onglet confirmé fonctionnel (le contenu de l'onglet
  Entraînement s'affiche correctement, avec la mention de la banque de 232 questions) et le logo
  reste affiché sans interruption dans l'AppBar au changement d'onglet.
- Vérification visuelle en largeur mobile (375×812) : la même AppBar (logo + titre + `TabBar` à 5
  onglets défilants) s'affiche sans débordement horizontal ; le contenu de l'écran À propos
  (première capture testée à cette largeur) s'affiche correctement sous la barre d'onglets.
- **À faire côté serveur** : redéployer (`git pull && bash install-caddy.sh` sur le VPS) pour que
  les correctifs de cache nginx et la nouvelle architecture d'onglets soient effectifs sur
  `biosigma.komodi-labo.org` ; après déploiement, un rechargement forcé (ou navigation privée) reste
  nécessaire pour les navigateurs ayant déjà mis en cache l'ancienne version de `main.dart.js`.

## 8. Livraison du 26/09/2026 — 21 nouveaux calculs (hématologie, hépatique, acido-basique, hémostase, Framingham)

Demande utilisateur : ajouter le calcul de MELD-Na, ALBI, IMC, TyG-IMC, HOMA-β, compensation
respiratoire attendue, rapports bicarbonates/chlorures, Mentzer, Shine-Lal, England-Fraser,
Green-King, RDWI, nombre absolu de réticulocytes, réticulocytes corrigés/IPR, SII, SIRI, rapport
normalisé dRVVT, score SIC, CT/HDL-C, ApoB/ApoA1, puis (message de suivi) SCORE2 et Framingham. Les
« scores de risque hémorragique ou thrombotique » génériques (catégorie, pas une formule précise)
ont été explicitement reportés à la demande de l'utilisateur, faute de score(s) nommé(s).

### Méthode

Quatre agents en arrière-plan, un par domaine, travaillant en parallèle sur des fichiers exclusifs
(aucun fichier partagé — `catalog.dart`, `biosigma_core.dart`, `calculator_registry.dart` —
touché par un agent), pour éviter tout conflit de fusion. Un cinquième agent, dédié et isolé, a
suivi pour Framingham/SCORE2 avec une consigne de sécurité renforcée (voir plus bas). L'intégration
finale (barrel export, catalogue, registre applicatif) a été faite manuellement, séquentiellement,
après réception de tous les rapports.

Nouveau domaine ajouté : `CalculatorCategory.hematology` (« Hématologie — NFS et réticulocytes »),
apparaît automatiquement dans l'écran d'accueil et l'écran Références (ces deux écrans itèrent déjà
génériquement sur `CalculatorCategory.values`, aucune modification d'UI nécessaire au-delà de
l'ajout de la valeur d'énumération).

### Formules ajoutées (21, catégorie entre parenthèses)

- **Hématologie (nouveau domaine)** : indice de Mentzer, indice de Shine & Lal, indice
  d'England & Fraser, indice de Green & King, RDWI, panel réticulocytaire (nombre absolu, CRC,
  indice de production réticulocytaire), SII, SIRI.
- **Cardiométabolique** : IMC, TyG-IMC, HOMA-β, rapport CT/HDL-C (indice de Castelli I), rapport
  ApoB/ApoA1, score de Framingham (risque coronarien « hard CHD » à 10 ans, Wilson et al. 1998).
- **Ionogramme / biochimie générale** : score MELD-Na, score ALBI, compensation acido-basique
  attendue (6 variantes : acidose/alcalose métabolique, acidose/alcalose respiratoire aiguë et
  chronique), rapport bicarbonates/chlorures.
- **Hémostase** : rapport normalisé dRVVT (recherche d'anticoagulant lupique, critères ISTH
  Pengo 2009), score SIC (coagulopathie induite par le sepsis, Iba et al. 2017).

Aucune de ces formules ne rend de verdict/interprétation calculé : les seuils publiés (Mentzer 13,
Shine-Lal 1760, ALBI grades, SIC ≥ 4, etc.) sont mentionnés uniquement à titre informatif dans
`limitations`, jamais comme résultat calculé — cohérent avec la politique déjà en vigueur pour
HOMA-IR/TyG/AIP/FIB4/APRI.

### SCORE2 — non implémenté (décision volontaire)

L'agent dédié a reçu une consigne de sécurité explicite : ne construire SCORE2 (ESC 2021, Hageman
et al.) que s'il pouvait reconstituer l'intégralité des coefficients (âge, tabagisme, PAS,
cholestérol non-HDL, termes d'interaction avec l'âge, par sexe), la fonction de survie de base à
10 ans et les 4 facteurs de recalibration régionaux avec une **confiance élevée** — jamais une
version approximative d'une équation de risque cardiovasculaire. L'agent a pu reconstituer la
structure générale du modèle de Cox mais pas les coefficients numériques exacts avec une confiance
suffisante ; conformément à la consigne, aucune entrée `score2_risk` n'a été créée (ni
`FormulaMeta`, ni fonction, ni test, ni écran). **SCORE2 reste à faire** si l'utilisateur peut
fournir les tables supplémentaires exactes de la publication d'origine.

### Vérification

- `dart analyze` (biosigma_core) : propre, aucune erreur ni avertissement.
- `dart test` (biosigma_core) : **178/178 tests verts** (95 initiaux → 171 après la première vague
  de 20 calculs → 178 après ajout de Framingham), dont pour chaque nouvelle formule au moins un cas
  calculé indépendamment à la main (jamais dérivé du code Dart testé) et un cas d'erreur de
  validation (division par zéro, hors bornes, etc.).
- `flutter analyze` (app) : propre.
- `flutter test` (app) : 9/9 verts (parcours bout en bout existants non affectés).
- Vérification visuelle (navigateur, `flutter build web --release`) :
  - IMC : 70 kg / 175 cm → 22,9 kg/m² (attendu 70/1,75² = 22,857) — conforme.
  - Compensation acido-basique attendue, acidose métabolique, HCO3 15 mmol/L → PaCO2 attendue
    30,5 mmHg (attendu 1,5×15+8 = 30,5) — conforme.
  - Framingham, homme 55 ans, CT 240 mg/dL, HDL 45 mg/dL, PAS 145 mmHg non traité, non-fumeur →
    14 points / 16 % (attendu : âge 8 + CT[50-59, 240-279] 4 + HDL[40-49] 1 + PAS[non traité,
    140-159] 1 + tabac 0 = 14 → 16 %) — conforme.
  - Recherche testée pour Mentzer, MELD-Na, compensation acido-basique, Framingham : chaque
    formule apparaît avec son sous-titre source/version correct.
  - Sélecteur d'énumération (trouble acido-basique primaire, 6 variantes) et champs conditionnels
    (HCO3 vs PaCO2 selon le trouble choisi) vérifiés fonctionnels.

### Non fait dans cette livraison

- SCORE2 (voir ci-dessus).
- Scores de risque hémorragique/thrombotique génériques (HAS-BLED, CHA₂DS₂-VASc, Padua, IMPROVE...)
  — reportés à la demande de l'utilisateur.
- Aucune question d'entraînement (quiz) n'a été ajoutée pour ces 21 nouvelles formules — non
  demandé, la demande portait uniquement sur le calcul.
- Mise à jour de `docs/tracabilite-scientifique.md` (table détaillée dédiée) : non faite pour ces
  21 formules — leur traçabilité complète reste néanmoins disponible dans chaque `FormulaMeta` et
  à l'écran « Références » de l'application, seule la table Markdown séparée n'a pas été étendue.
