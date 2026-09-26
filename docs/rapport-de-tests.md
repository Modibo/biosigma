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
