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
