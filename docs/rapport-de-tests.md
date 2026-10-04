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
  des charges (« score incomplet » si un critère manque ; au moment de cette vérification l'interprétation était masquée par défaut, ce qui a été retiré depuis — décision D-03).
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
    biologiste responsable (seul un échantillon a été relu manuellement). L'extension de la banque
    vers ~1000 questions, qui était l'objectif initial, a été abandonnée par l'utilisateur.

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

## 9. Livraison du 26/09/2026 — SCORE2 + interprétations sourcées sur l'ensemble des 53 calculs existants

Demande utilisateur : « Ajouter le SCORE2, et les interprétations des résultats de l'ensemble des
paramètres calculés selon les recommandations actuelles des sociétés savantes correspondants. »
Clarifiée par question ciblée : affichage **toujours visible, sans blocage** (réponse explicite de
l'utilisateur), et catégorie SCORE2/Framingham rangée dans le domaine cardiométabolique existant
(réponse explicite à une question antérieure).

### Constat de départ

Le mécanisme d'affichage nécessaire existait déjà, sans le savoir explicitement documenté :
`CalculationResult.warnings` (sévérité `info`/`caution`/`blocking`) est rendu **sans aucune
condition** par `WarningList` côté application — confirmé en lisant le code, pas supposé. Le score
ISTH-CIVD avait déjà une interprétation ainsi affichée. Aucune infrastructure de « validation
locale masquant l'interprétation » n'a jamais existé dans le code, malgré du texte affirmant le
contraire dans `limitations` (ISTH-CIVD, 4Ts) et dans l'onglet À propos — corrigé dans cette
livraison (voir plus bas). Conséquence pratique : aucun changement de modèle de données ni d'UI
n'a été nécessaire ; tout le travail consiste à ajouter, calcul par calcul, un `CalculationWarning`
d'interprétation sourcée.

### Méthode

Six agents en arrière-plan, exécutés en parallèle :
- Cinq agents « domaine » (rénal, cardiométabolique, ionogramme/hépatique/acido-basique, hémostase,
  hématologie), chacun scopé strictement à son propre dossier `calculators/<domaine>/` — aucun
  fichier partagé (`catalog.dart`, `biosigma_core.dart`, registres applicatifs) touché par ces
  agents, pour éviter tout conflit de fusion pendant l'exécution parallèle.
- Un agent dédié SCORE2, équipé cette fois d'outils de recherche web (`WebSearch`/`WebFetch`),
  contrairement à la tentative précédente (session du 26/09/2026 plus tôt) qui avait été
  correctement abandonnée faute de coefficients vérifiables en mémoire.

Consigne de sécurité commune à tous les agents (répétée dans chaque brief) : n'attribuer une
interprétation à une société savante que si une source réelle, vérifiable et actuellement en
vigueur l'endosse explicitement pour ce marqueur précis. Quand aucun consensus de société savante
n'existe (cas fréquent en recherche biologique — indices dérivés d'une seule étude de cohorte),
l'interprétation doit le dire explicitement plutôt que d'inventer ou d'emprunter un seuil à une
publication isolée présentée comme une recommandation officielle. Cette réponse honnête est un
résultat correct et attendu, pas un échec de la tâche.

### SCORE2 — implémenté avec succès cette fois

L'agent a recherché et lu en ligne : le texte intégral de l'article original (Hageman et al., Eur
Heart J. 2021;42(25):2439-2454, via PMC), un package R open-source (`RiskScorescvd`) et une
implémentation indépendante en C# (`CVDRiskScores`), le manuel utilisateur d'un dispositif médical
marqué CE reprenant SCORE2 (Evidencio, v5, juillet 2025), et la page officielle ESC HeartScore pour
la table pays→région. **Vérification la plus forte** : l'implémentation reproduit exactement les
deux exemples chiffrés publiés dans l'article original (homme 50 ans fumeur, PAS 140, CT 5,5 mmol/L,
HDL 1,3 mmol/L → 5,9 % en région à faible risque et 14,0 % en région à très haut risque ; femme
équivalente → 4,2 % et 13,7 % — valeurs reproduites par le code au dixième de point près). Le
sélecteur de région de risque (`RiskRegion`, 4 valeurs) affiche un avertissement honnête : aucune
région ESC ne couvre l'Afrique subsaharienne, le choix reste une approximation — pertinent pour le
public malien de l'application.

### Interprétations ajoutées — vue d'ensemble par domaine

- **Rénal** : stadification KDIGO G1-G5 (CKD-EPI ×3, Schwartz, clairance créatinine minutée en
  approximation explicitement caveatée) et catégories d'albuminurie A1-A3 (UACR) ; seuils prérénal/
  nécrose tubulaire aiguë classiques pour FeNa (Espinel 1976) et FeUrée (Carvounis 2002) ; seuil
  néphrotique (≥3,5 g/24h) pour la protéinurie, honnêtement présenté comme un repère de pratique et
  non une recommandation d'une société nommée.
- **Cardiométabolique** : classification IMC OMS 2000 (directe, universelle) ; bandes ESC/EAS 2019
  pour le LDL/non-HDL (explicitement descriptives, la cible thérapeutique réelle dépendant du
  risque CV global) ; catégories ATP III pour Framingham ; catégories ESC 2021 par tranche d'âge
  pour SCORE2. **Absence de seuil honnêtement signalée** pour HOMA-IR, QUICKI, TyG, TyG-IMC,
  HOMA-β (aucune société ADA/EASD/IDF n'endosse de seuil diagnostique universel pour ces index).
- **Ionogramme / hépatique / acido-basique** : seuils WHO 2016/2018 (APRI, cirrhose) et
  Sterling 2006/EASL 2021 (FIB-4) pour la fibrose hépatique ; seuil AASLD 2011 pour la saturation
  de la transferrine ; grades ALBI (Johnson 2015, déjà documentés, promus en avertissement actif) ;
  bandes de mortalité approximatives pour MELD-Na (Kamath 2001/Wiesner 2003) ; plages de référence
  standard pour trou anionique, natrémie/calcémie corrigées, trou osmolaire. La **compensation
  acido-basique attendue** gagne un paramètre optionnel `measuredCompensatoryValue` : si fournie,
  la valeur mesurée est comparée à la fourchette attendue et le résultat indique « compatible » ou
  « hors fourchette — trouble acido-basique mixte possible », sans jamais nommer un second
  diagnostic précis. Rapport bicarbonates/chlorures : honnêtement signalé comme sans seuil
  consensuel.
- **Hémostase** : score ISTH-CIVD et score 4Ts (déjà interprétés, texte de `limitations` corrigé
  pour ne plus laisser croire à un mécanisme de masquage/validation locale qui n'a jamais existé
  dans le code) ; score SIC (seuil ≥4 promu de `limitations` vers un avertissement actif) ; INR et
  ratio TCA : cadre honnête dépendant de l'indication clinique et du réactif local, sans verdict
  unique inventé ; indice de Rosner : convention interprétative classique (Rosner et al. 1987) ;
  rapport normalisé dRVVT : positivité nécessitant l'intervalle de référence local du laboratoire
  (ISTH 2009), aucun seuil universel appliqué par l'application.
- **Hématologie** : les cinq indices discriminants microcytaires (Mentzer, Shine-Lal,
  England-Fraser, Green-King, RDWI) affichent désormais leur seuil de littérature avec la mise en
  garde explicite qu'aucune société savante d'hématologie ne l'endosse formellement — outils de
  dépistage, jamais un diagnostic isolé. RPI : interprétation classique (hypoprolifératif/adapté)
  selon la méthodologie Hillman. **SII et SIRI : absence de seuil honnêtement signalée** (marqueurs
  de recherche pronostique oncologique sans seuil clinique reconnu par une société savante).

### Correction de texte obsolète

L'onglet À propos affirmait auparavant qu'aucun seuil interprétatif n'était jamais imposé et que
l'interprétation d'ISTH-CIVD/4Ts restait masquée jusqu'à validation locale — les deux affirmations
ne correspondaient déjà plus (la seconde n'avait en réalité jamais été vraie dans le code). Le
texte a été réécrit pour refléter fidèlement le nouveau comportement : interprétations toujours
affichées quand une classification reconnue existe, absence de seuil signalée honnêtement sinon,
seuils propres au laboratoire toujours réglables dans Réglages > Seuils locaux. Le même correctif a
été appliqué au texte `limitations` d'ISTH-CIVD et 4Ts dans le moteur de calcul.

### Vérification

- `dart analyze` (biosigma_core) : propre.
- `dart test` (biosigma_core) : **206/206 tests verts** (178 avant cette livraison → 206), incluant
  au moins un cas représentatif par formule confirmant le texte d'interprétation (ou l'honnêteté de
  l'absence de seuil) et les cas d'erreur de validation existants, tous préservés.
- `flutter analyze` (app) : propre.
- `flutter test` (app) : 9/9 verts après correction d'un test devenu ambigu (`find.textContaining('0,3')`
  sur l'écran QUICKI correspondait à la fois au résultat et à un extrait du nouveau texte
  d'interprétation « no consensus » qui contient aussi « 0,3x » — resserré sur la valeur exacte
  affichée, `find.text('0,3194')`).
- Vérification visuelle (navigateur, `flutter build web --release`) :
  - CKD-EPI créatinine 2021, 60 ans, F, créatinine 70 µmol/L, IDMS confirmé → 85,4 mL/min/1,73 m²
    (valeur déjà vérifiée en session précédente) + avertissement « Stade KDIGO G2 : DFG légèrement
    diminué » avec la grille complète G1-G5 et la mise en garde des 3 mois — conforme.
  - SCORE2 : écran ouvert, sélecteur de région et mise en garde Afrique subsaharienne confirmés
    affichés.
  - Recherche testée pour SCORE2 : apparaît avec son sous-titre source (« SCORE2 working group et
    ESC Cardiovascular risk collaboration, 2021 »).

### Non fait / signalé pour suite

- Confiance mitigée sur la citation précise des seuils APRI de fibrose significative (0,5/1,5) :
  attribués à Wai et al. 2003 (source primaire déjà en place) plutôt qu'au document WHO lui-même,
  par prudence — seul le seuil de cirrhose (2,0) est attribué avec confiance à WHO 2016/2018. À
  vérifier contre le PDF WHO si une citation irréprochable est requise.
- `docs/tracabilite-scientifique.md` non mise à jour avec le détail des nouvelles interprétations
  (même limite que pour la livraison précédente) — traçabilité complète disponible dans chaque
  `FormulaMeta` et à l'écran Références.
- Le score SIC et le score ISTH-CIVD/4Ts affichent maintenant tous leur interprétation de la même
  façon (toujours visible), ce qui **annule l'ancien comportement documenté (mais jamais codé) de
  masquage derrière une validation locale** décrit dans le cahier des charges initial — changement
  demandé explicitement par l'utilisateur dans cette session, signalé ici pour traçabilité de la
  décision.

## 10. Livraison du 26/09/2026 — 5 scores de risque hémorragique/thrombotique cliniques

Suite de la demande initiale (« scores de risque hémorragique ou thrombotique », reportée faute de
précision) : l'utilisateur, une fois informé que ce sont des scores cliniques (âge, antécédents,
contexte chirurgical) et non de simples calculs biologiques, a choisi les 5 scores suivants :
**HAS-BLED**, **CHA₂DS₂-VASc** (paire fibrillation atriale/anticoagulation), **score de Padua**,
**IMPROVE** (paire patient hospitalisé en médecine), et **score de Caprini** (périopératoire).

### Méthode

Trois agents en arrière-plan, en parallèle, chacun équipé d'outils de recherche web
(`WebSearch`/`WebFetch`) et instruit de vérifier chaque critère et chaque valeur de points contre
au moins deux sources indépendantes plutôt que de faire confiance à la mémoire seule — ces scores
sont des check-lists denses (jusqu'à 40 critères pour Caprini, avec des valeurs décimales pour
IMPROVE), particulièrement exposées aux erreurs de transcription :
- Agent 1 : HAS-BLED + CHA₂DS₂-VASc.
- Agent 2 : Padua + IMPROVE.
- Agent 3 : Caprini (isolé, du fait de sa complexité — 40 facteurs répartis en 4 paliers de points).

Chaque agent a travaillé exclusivement dans de nouveaux fichiers (aucun fichier partagé —
`catalog.dart`, `biosigma_core.dart`, registres applicatifs existants — touché en parallèle),
intégration finale faite manuellement par la suite. Catégorie retenue : `CalculatorCategory.hemostasis`
(existante, cohérente thématiquement avec Rosner/INR/ISTH-CIVD/4Ts/dRVVT/SIC déjà présents).

### Vérification par score

- **HAS-BLED** : structure à 9 critères/7 lettres confirmée (Wikipedia, mdtools.org, fpnotebook,
  citation originale Pisters et al., Chest 2010). Les taux de saignement annuels par score
  divergeaient entre deux sources secondaires par ailleurs fiables (ex. score 1 : 1,0 % vs 3,4 %) —
  **aucun pourcentage précis n'a été retenu**, seule la catégorisation qualitative (0-1 faible,
  2 modéré, ≥3 élevé) a été conservée, honnêtement présentée comme un repère usuel.
- **CHA₂DS₂-VASc** : structure à 8 critères confirmée (Wikipedia, MDCalc). Point notable signalé
  par l'agent : les recommandations ont divergé entre l'ESC 2020, l'ACC/AHA/ACCP/HRS 2023 (garde le
  sexe, seuils ≥2 hommes/≥3 femmes) et l'**ESC 2024, qui a remplacé le CHA₂DS₂-VASc par un
  CHA₂DS₂-VA sans distinction de sexe**. La structure classique (avec sexe), demandée par
  l'utilisateur, a été conservée, avec le seuil d'anticoagulation de la recommandation ACC/AHA/ACCP/HRS
  2023 (toujours en vigueur pour cette structure) — la divergence ESC 2024 est documentée
  explicitement dans `limitations` plutôt que masquée.
- **Score de Padua** : 11 facteurs et seuil ≥4 confirmés par 4 sources convergentes (MDCalc, mdapp,
  2 articles PMC dont la publication originale reproduite intégralement et le guide ASH 2018) ; une
  5ᵉ source paraphrasait le seuil en « > 4 » plutôt que « ≥ 4 » — écart mineur résolu en faveur de la
  majorité des sources et du texte explicite de l'ASH 2018.
- **IMPROVE** : les 13 facteurs et leurs valeurs décimales (0,5 à 4,5 points) vérifiés sur 4 sources
  indépendantes parfaitement concordantes (wikidoc, practical-haemostasis, ecgwaves, MDCalc), total
  maximal 30,5 cohérent entre toutes ; seuil ≥7 = risque élevé confirmé. Aucun facteur omis.
- **Caprini** : 40 facteurs (17×1pt, 8×2pt, 10×3pt, 5×5pt) vérifiés sur 3 sources indépendantes
  (MDCalc, capriniriskscore.org, practical-haemostasis) plus la référence de bandes de risque ACCP/CHEST
  (Gould et al. 2012). Quelques items rarement cités de manière incohérente entre sources (ex.
  « IMC > 40 » comme item séparé) ont été volontairement repliés dans la case générique « autre
  facteur de risque non listé » plutôt que retenus avec une valeur de points non fiable.

Aucune interprétation n'a été inventée : chaque score renvoie sa catégorie de risque (`info`,
toujours affichée, cf. politique établie lors de la livraison précédente) sourcée par la
littérature originale et, quand vérifiable, par une société savante actuelle (ACCP/CHEST,
ACC/AHA/ACCP/HRS).

### Intégration finale

- Barrel `biosigma_core.dart`, `catalog.dart` et `calculator_registry.dart` (app) mis à jour
  manuellement pour intégrer les 5 nouvelles formules (aucun conflit entre agents, fichiers
  disjoints par construction).
- Corrigé au passage : la liste `caprinCalculators` du registre applicatif portait une coquille de
  nommage (« caprin » au lieu de « caprini ») — renommée en `capriniCalculators` avant intégration.

### Vérification

- `dart analyze` (biosigma_core) : propre.
- `dart test` (biosigma_core) : **240/240 tests verts** (206 avant cette livraison → 240).
- `flutter analyze` (app) : propre.
- `flutter test` (app) : 9/9 verts, aucune régression.
- Vérification visuelle (navigateur, `flutter build web --release`) : écran Score de Caprini ouvert,
  les 40 cases à cocher rendues avec leur valeur de points en sous-titre ; cas test « Âge 41-60 ans »
  + « Chirurgie mineure prévue » cochés → 2 points calculés, avertissement « Score 1-2 : risque
  faible selon les catégories ACCP/CHEST (Gould et al. 2012) » affiché correctement, avec le détail
  des facteurs cochés par palier de points.

### Non fait / signalé pour suite

- `docs/tracabilite-scientifique.md` non mise à jour avec le détail de ces 5 formules (même limite
  que pour les livraisons précédentes) — traçabilité complète disponible dans chaque `FormulaMeta`
  et à l'écran Références.
- Les taux de saignement annuels précis par score HAS-BLED n'ont pas été retenus faute de sources
  concordantes — seule la catégorisation qualitative est affichée.

## 11. Livraison du 26/09/2026 — refonte du design (navigabilité, visuel, mode sombre)

Demande utilisateur : « améliorer le design », précisée par question ciblée après constat visuel
concret (l'écran d'accueil et l'écran Références, avec désormais 59 calculs, étaient devenus des
listes plates obligeant à défiler sur plusieurs écrans pour atteindre les dernières catégories).
L'utilisateur a choisi les trois axes proposés : navigabilité, rafraîchissement visuel général, et
mode sombre.

### Changements

- **Navigabilité** (`lib/screens/home_screen.dart`, `lib/screens/references_screen.dart`) : les
  5 catégories (`CalculatorCategory`) sont désormais chacune une carte `ExpansionTile` repliée par
  défaut, avec icône de domaine, libellé, nombre de calculs et chevron — les 5 catégories tiennent
  sur un seul écran, dépliées à la demande. « Outils composés » et « Favoris » restent toujours
  visibles (peu d'éléments, entrées principales). Nouveau fichier `lib/theme/category_icons.dart`
  (une icône Material par catégorie : goutte pour rénal, cœur pour cardiométabolique, éprouvette
  pour ionogramme, goutte de sang pour hémostase, microscope pour hématologie).
- **Rafraîchissement visuel** (`lib/theme/app_theme.dart`) : les cartes ont désormais un contour
  discret et des coins arrondis (14px) au lieu d'être visuellement plates sur le fond ; thème
  partagé pour les `ListTile` (coins arrondis assortis).
- **Mode sombre** : `AppTheme.dark()` complété pour être au même niveau de détail que `light()`
  (cardTheme, filledButtonTheme avec contraste vérifié). Les couleurs d'avertissement
  (`BioSigmaColors.warningCaution`/`warningBlocking`), auparavant fixes indépendamment du thème,
  ont maintenant des variantes claires dédiées au mode sombre (`warningCautionOnDark`,
  `warningBlockingOnDark`) sélectionnées via `warningCautionFor(brightness)`/
  `warningBlockingFor(brightness)` — appliqué dans `warning_list.dart`, `result_value_tile.dart` et
  `quiz_module_screen.dart` (aucune couleur d'avertissement fixe restante indépendante du thème).
  Le mode sombre suit déjà le thème système (`MaterialApp.darkTheme`, aucun changement de logique
  nécessaire ici, seul le contenu du thème a été complété).

### Vérification

- `flutter analyze` : propre.
- `flutter test` : 9/9 verts. Le test Références a dû être adapté : les catégories étant repliées
  par défaut, le test déplie maintenant explicitement « Fonction rénale et urines » avant de
  vérifier la présence de « CKD-EPI créatinine 2021 » et des fiches techniques.
- Vérification visuelle (navigateur, `flutter build web --release`, clair et sombre, bureau et
  mobile 375×812) :
  - Accueil et Références : les 5 catégories tiennent sur un seul écran (clair et sombre, bureau et
    mobile), dépliage/repliage fonctionnel, icônes de domaine visibles.
  - CKD-EPI créatinine 2021 en mode sombre : formulaire, dropdown de sexe, bouton « Calculer »
    (fond cyan clair / texte bleu nuit, contraste correct) et avertissement d'interprétation KDIGO
    (icône et texte cyan clair sur fond translucide) tous lisibles.
  - Écran À propos en mode sombre, bureau et mobile : logo et texte lisibles, aucun débordement.

### Non fait / signalé pour suite

- Aucun bouton de bascule manuel clair/sombre n'a été ajouté dans Réglages : l'application suit le
  thème du système d'exploitation (`MaterialApp.darkTheme`, comportement déjà existant, jugé
  suffisant sans demande explicite d'un contrôle manuel).
- L'écran Entraînement (5 modules seulement) et l'écran Calculateur générique n'ont pas été touchés
  par la refonte de navigabilité : leur taille ne posait pas le même problème de défilement.

## 12. Livraison — mode hors connexion réel sur le web, 1.5.2 puis 1.6.0

Origine : signalements « la nouvelle version ne se charge pas » / « l'app ne s'affiche plus » sur
téléphone. Diagnostic mesuré : nginx sert `main.dart.js` en 26 ms en local sur le VPS (au repos :
charge 0,28, 16 % de mémoire) ; le débit client observé varie (10 Ko/s un jour, ~200 Ko/s le
lendemain, RTT ~200 ms) ; le premier lancement télécharge ~3,4 Mo compressés (main.dart.js 1,1 Mo +
CanvasKit 2,3 Mo en Brotli depuis gstatic).

**Constat structurant** : le `flutter_service_worker.js` généré par Flutter 3.47 est un stub qui se
désinscrit — aucune mise en cache. Le README affirmait à tort un fonctionnement hors connexion de
la version web ; chaque lancement dépendait donc du réseau.

Changements : `web/biosigma_sw.js` (service worker propre : précache atomique versionné par build,
mise en cache du moteur graphique à la première utilisation, bascule pilotée par la page),
`web/flutter_bootstrap.js` (désactive le service worker Flutter), `--no-web-resources-cdn`
(CanvasKit et Roboto hébergés chez nous), `tool/stamp_sw.sh` + Dockerfile (empreinte du build),
`nginx.conf` (no-cache sur `biosigma_sw.js`), écran de démarrage avec indicateur de chargement,
bouton « Recharger » relié à la bascule du service worker (`reload_page_web.dart`, `dart:js_interop`).

Décisions écartées après mesure : héberger CanvasKit seul (sans service worker) n'allège rien
(gzip 2,9 Mo contre 2,28 Mo en Brotli chez Google, cache d'un an partagé) ; le build `--wasm` ne
gagne que ~0,7 Mo au prix de risques de compatibilité sur anciens téléphones ; le code propre à
BioSigma ajoute ~2 Mo bruts au socle Flutter (1,74 Mo), le différer n'apporterait presque rien.

Vérifié au navigateur : installation sur navigateur vierge (17 fichiers dont la bonne variante de
CanvasKit), démarrage et recherche fonctionnels **serveur arrêté** dès la première visite, bascule
vers un nouveau build (nouveau cache rempli en attente, ancien supprimé, rechargement), bouton
« Recharger » (appel vérifié). `flutter analyze` propre, 9/9 tests.

Non vérifié : le Dockerfile modifié n'a pas été reconstruit ici (pas de Docker lancé dans cette
session) ; le comportement sur Safari/iOS et sur anciens Android WebView n'a pas été essayé.

## Décisions D-03 et D-04 (2026-10-03)

- **D-03** : l'interprétation des scores ISTH-CIVD et 4Ts est désormais **toujours affichée**, comme
  pour tous les autres calculateurs, conformément à la décision de l'utilisateur du 26/09 (« toujours
  affiché, sans blocage »). Le réglage « interprétations locales validées » est retiré. La
  contradiction signalée dans le dossier d'audit (A-14) est levée pour ces deux écrans ; les
  interprétations ne sont toujours pas validées par un biologiste responsable.
- **D-04** : réglages sans effet traités un par un — *précision d'affichage* (retirée : la précision de
  chaque résultat est fixée par son calcul) ; *coefficient de Katz mis en avant* (retiré : Katz et Hillier
  sont toujours affichés côte à côte) ; *équation LDL* (câblée : présélection à l'ouverture du panel
  LDL, sans effet sur un résultat) ; *seuils locaux* (câblés : rappelés sous le résultat du calcul
  concerné, sans comparaison ni interprétation automatique). D'anciens réglages enregistrés contenant
  les clés retirées sont relus normalement.
- Vérification : `flutter analyze` sans remarque ; 37 tests de l'application verts (dont 4 nouveaux pour D-03/D-04) ;
  golden master inchangé.

## Phase 1 — onglet Lab : Convert et Dilute (2026-10-03)

- Moteur (`biosigma_core`, `src/lab/`) : unités par préfixes SI (`lab_units.dart`), conversion
  (`convert.dart`), dilutions (`dilution.dart`). **42 tests ajoutés** (282 au total pour le moteur),
  valeurs attendues calculées à la main (ex. 100 mg/dL avec M = 180,16 g/mol → 1000/180,16 mmol/L ;
  1 g/L, 100 µL dans 1 mL → 100 mg/L ; facteur 2, 4 tubes → 1/16 et 6,25 pour 100).
- Application : 8 tests de widgets ajoutés (`test/screens/lab_test.dart`) ; 45 tests d'application au total.
- Les 59 calculs existants sont inchangés (golden master vert ; le catalogue compte toujours 59
  équations, la catégorie « Outils de laboratoire » est hors catalogue).
- Vérifié visuellement dans le navigateur (build web de production) : onglet Lab et écran Dilute ;
  les parcours de saisie sont couverts par les tests de widgets, pas par un essai sur téléphone.
- **Non fait** : base d'analytes avec masses molaires sourcées (P1-11), registre d'équations versionné
  (P1-13), enregistrement de calcul v2 (P1-14), règle d'arrondi (P1-15), niveaux de résultat (P1-16),
  intégration continue (P1-00), pipettes et pipetabilité (P2-01).

## Phase 2 — Prepare, Count, Microbiology, Quality, Smart Solver (2026-10-04)

- Moteur (`src/lab/prepare.dart`, `count.dart`, `microbiology.dart`, `quality.dart`,
  `smart_solver.dart`) : **45 tests ajoutés** (327 au total pour le moteur), valeurs attendues
  calculées à la main (ex. tampon pH 7,4 / pKa 7,2 : rapport 10^0,2 = 1,58489, base 61,3137 mmol ;
  UFC : 150 colonies, 10^-3, 0,1 mL → 1,5 × 10⁶ ; Sigma : (10 − 2,0408)/1,41421 = 5,628).
  Une première valeur attendue calculée à la main était fausse (61,3125 au lieu de 61,3137) :
  corrigée après recalcul indépendant, le code était juste.
- Défaut trouvé par les tests de widgets et corrigé : le nombre de décimales d'affichage utilisait
  `floor(log10(x))`, inexact pour les puissances de dix (1000 s'affichait « 1000,0 »). Remplacé par
  l'exposant de la notation scientifique ; testé pour 1, 100, 1000, 0,001. Affectait aussi Convert/Dilute.
- Application : 12 tests de widgets ajoutés (57 au total). Les 59 calculs existants sont inchangés
  (golden master vert).
- **Choix de conception** : ces modules étaient marqués « bloqué (données) » dans le dossier d'audit.
  Ils sont livrés en faisant **saisir par l'utilisateur** toute valeur qui exigerait une source
  (masse molaire, pKa, géométrie de chambre, intervalle de colonies, ETa, k). Rien n'est embarqué.
  Non livré volontairement : bibliothèque de chambres de numération, valeurs McFarland, seuils OMS
  des spermatozoïdes, formules de normes de dénombrement (pondération), tableaux de pKa.
- Vérifié visuellement : liste des sept modules dans l'onglet Lab (build web de production) ; le détail
  des parcours est couvert par les tests de widgets, pas par un essai sur téléphone.

## Socle de traçabilité — P1-00, P1-02, P1-13 à P1-16, P2-01 (2026-10-04)

- **Moteur : 351 tests** (+24) ; **application : 81 tests** (+24) ; analyse sans remarque ; golden master
  inchangé (fixture non modifiée).
- **T-REG-003** : les 59 identifiants historiques résolvent via le registre ; identifiants stables uniques.
- **T-ARR-001** : règle `FMT_ARRONDI_001` testée (égalité exacte vers l'extérieur, 1,005 → « 1,00 »,
  chiffres significatifs). Elle décrit le comportement existant : aucun résultat n'a changé.
- **T-TRC-001** : pour les 57 équations du registre générique, calcul → enregistrement → JSON → relecture →
  rejeu reproduit exactement les valeurs.
- **T-MIG-001** : historique v1 converti sans toucher à v1, idempotent, ajout sans perte, v1 corrompu en
  quarantaine, schéma v2 inattendu en quarantaine, effacement des deux clés.
- **T-PIP-001/002** : 0,7 µL impossible avec les pipettes du jeu de test ; classes aux seuils ; « validé »
  seulement avec vérification à jour. Les plages de test sont saisies dans les tests, pas dans le code.
- **Niveaux de résultat (P1-16)** : séparation en *alertes* et *informations/repères* faite sur la sévérité
  existante. **Limite** : le texte de chaque message n'a pas été reclassé un par un (interprétation,
  note, aide) ; le champ « niveau » par message n'existe pas encore.
- **Non fait** : CI jamais exécutée sur GitHub (écrite et cohérente, mais à constater au premier push) ;
  « correction d'équation → enregistrements signalés » ; version d'équation > 1 (aucune équation n'a encore
  changé depuis l'introduction du registre) ; statut VALIDÉ (D-12).

## Extension de Convert : unités et analytes (2026-10-04)

- Moteur : unités étendues (activité catalytique, pression, température affine, numération cellulaire,
  fraction, osmolalité, longueur, temps, excrétion par temps, débits, clairance, mg%, lb/oz) ; base de
  **80+ analytes** (`analyte_base.dart`) ; **35 tests ajoutés** (386 au total pour le moteur). Application :
  85 tests (+4). Golden master inchangé : les 59 calculs et leurs facteurs arrondis ne sont pas touchés.
- **Masses molaires calculées, jamais saisies de mémoire** : somme des poids atomiques IUPAC abrégés × formule
  brute. Les valeurs attendues des tests sont des sommes refaites à la main (glucose 180,156 ; créatinine 113,120 ;
  cholestérol 386,664 ; triglycérides 885,453 [convention de la trioléine] ; BUN 28,014…).
- Propriété vérifiée sur **toutes** les unités de chaque famille et sur **tous** les analytes : l'aller-retour redonne
  la valeur de départ (plus de 5 000 paires).
- **Écart avec les calculateurs** : Convert (formule exacte) donne par ex. 90 mg/dL de glucose = 4,9957 mmol/L
  alors que les calculateurs utilisent le facteur arrondi 0,0555 (4,995). L'écart (≈ 0,01 %) est affiché
  sous le résultat ; les calculateurs ne sont pas modifiés (aucun résultat existant ne change).
- **Choix de prudence** : triglycérides = convention de la trioléine ; phosphate exprimé en P (pas d'équivalents) ;
  fer sans équivalents (valence ambiguë) ; lactate en acide lactique ; D-dimères et troponine : unités FEU/DDU et
  méthodes non convertibles entre elles (mise en garde). Insuline et HbA1c : facteurs du moteur existant.
- **Non fait** : hémoglobine, protéines, hormones peptidiques en molaire (masse molaire hétérogène ou non
  sourcée) ; unités propres aux dosages (UI d'insuline µU, UI de TSH) ; conversions de médicaments sous forme de sels.
  Aucune valeur n'a été relue par un biologiste responsable.

## Relecture des analytes, nouveaux analytes, cadre D-12 (2026-10-04)

- **Contrôle indépendant des formules** : les 125 analytes à formule brute (47 initiaux + 78 ajoutés) ont été
  comparés à une source externe — PubChem (NCBI) et NCI/CADD Chemical Identifier Resolver. **Résultat : 125
  formules identiques, 0 différente.** Cinq cas où un résolveur renvoyait un autre composé (aluminium et arsenic →
  hydrures ; thiamine → chlorure ; pyridoxal-phosphate → hydrate ; metformine → chlorhydrate) ont été tranchés avec
  l'autre source (la metformine par SMILES de la base libre). Limites : un seul type de contrôle (formule du composé
  nommé) ; la **forme chimique retenue** et les **valences** restent à relire par le laboratoire ; PubChem arrondit
  parfois les masses à 0,1 g/mol, d'où des écarts apparents sur le plomb, le lithium et les triglycérides.
- **Base d'analytes : 186 entrées** (+98) : oligo-éléments, métabolites, vitamines, hormones, médicaments (forme libre),
  protéines (conversions massiques), enzymes, numération, pression artérielle. Masses molaires toujours calculées.
- **Cadre de validation (D-12)** : `gouvernance-validation.md` (rôles, statuts, critères, modèle de fiche) ;
  `relecture-analytes.md` (186 lignes à relire, colonnes de décision vides) ; le code dérive le statut des fiches
  (`ValidationRecord`) : fiche incomplète ignorée, fiche d'une autre version sans effet, fiche rejetée = RETIRÉ.
  **Aucune fiche n'existe : tout reste « NON VALIDÉ ».**
- Tests : **moteur 398** (+12), **application 85**. Golden master inchangé.

## Hématologie : constantes érythrocytaires et valeurs absolues (2026-10-04, backlog P3-01)

- Deux équations ajoutées au catalogue (59 → **61**) : **VGM, TCMH, CCMH** (à partir de Hb, hématocrite, GR) et **ANC, ALC**
  (à partir des leucocytes et de la formule). Ce sont des **relations de définition** : aucun intervalle de référence ni seuil
  de neutropénie/lymphopénie n'est appliqué.
- Moteur : **12 tests ajoutés** (422 au total), valeurs calculées à la main (Hb 15, Ht 45, GR 5 → VGM 90, TCMH 30, CCMH 33,33 ;
  8 ×10⁹/L, neutrophiles 60 %, bandes 5 %, lymphocytes 30 % → ANC 5,2, ALC 2,4). Somme de pourcentages > 100 % : avertissement bloquant.
- **Golden master mis à jour par ajout explicite** : 142 → 144 cas ; vérifié par comparaison de l'ancien et du nouveau fichier
  que **aucun cas existant n'est modifié ni supprimé** (seuls `red_cell_indices` et `absolute_leukocyte_counts` s'ajoutent).
- Rejeu T-TRC-001 étendu : 59 équations génériques (57 + 2).
- Citation primaire des définitions (attribuées à Wintrobe) **non vérifiée** : signalée « à compléter » dans la fiche de chaque équation.

## Recherche universelle (2026-10-04, backlog P5-02)

- Moteur (`search/universal_search.dart`) : **17 tests** (moteur : 439 au total). Propriétés vérifiées : **chaque** calcul du
  catalogue est retrouvé par son nom court, **chaque** analyte par son nom, chaque module par son libellé ; chaque synonyme
  désigne un calcul existant ; ET entre les mots ; résultats triés ; pas de doublons ; insensible aux accents et à la casse.
- Application : **9 tests de widgets** (94 au total) : ouverture depuis la loupe, « dfg » → calcul, « glucose »/« sodium » →
  Convert prérempli (formule et masse molaire affichées), « mmhg » → Convert sur la grandeur Pression, « dilution » → Dilute,
  phrase libre → module « à confirmer » sans résultat calculé, aucun résultat → message.
- Limites : classement heuristique (aucun jeu de requêtes réelles de la section 41 du cahier des charges n'a été fourni) ;
  synonymes écrits à la main, non exhaustifs ; pas de correction de fautes de frappe.

## Planificateur de dilutions (2026-10-04, backlog P5-04 / T-PIP-003)

- Moteur (`dilution_planner.dart`) : **15 tests** (moteur : 454 au total). Une fonction de vérification **indépendante du
  planificateur** contrôle chaque stratégie : produit des facteurs = F, prélèvement = V/f, diluant = V − prélèvement,
  tube intermédiaire ≥ prélèvement suivant + volume mort, concentration finale = C0/F (produit des t/V), classe de pipette
  ≥ « recommandé » (sauf option), volume final respecté.
- Cas couverts : une étape (F = 10 dans 1000 µL : 100 µL P100 + 900 µL P1000), non entier (2,5), plusieurs étapes avec rejet
  motivé de l'étape unique (1 µL < 10 µL), volume mort 50 µL, volumes « possibles » refusés puis autorisés, aucune
  stratégie (P1000 seule, F = 10⁵) avec avertissement bloquant et aide, diluant supérieur à la plus grande pipette,
  préférence pour une pipette validée, vérification périmée signalée, refus de saisie, performance (F = 10⁶, 4 étapes :
  ≈ 1,3 s sur machine de développement ; plus long dans un navigateur, d'où l'indicateur d'attente).
- Application : **5 tests de widgets** (99 au total) : une étape, plusieurs étapes avec raison du rejet, aucune stratégie,
  sans pipette, facteur ≤ 1.
- **Limites** : recherche bornée (facteurs entiers pour les premières étapes, dernier facteur déduit ; 3 étapes jusqu'à
  200 × 200, 4 étapes jusqu'à 30 par facteur) : « la plus simple parmi celles explorées », pas une optimalité prouvée ;
  choix du volume des tubes intermédiaires par grille (glouton, de la dernière étape à la première) ; pas de pipetages
  multiples ; exactitude et justesse des pipettes non modélisées.

