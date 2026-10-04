# Dossier de validation préparé — FV-PREP-018
## Spermatozoïdes : concentration et nombre total, OMS 6e éd. (`LAB_LAB_SEMEN_COUNT_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** La source (le manuel de l'OMS, 6e éd.) a été **fournie par le validateur** et **lue par l'assistant le 2026-10-04** ; les tableaux ont été recopiés par programme depuis le texte du PDF puis recoupés. La confrontation visuelle aux pages du manuel reste à faire par le validateur.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-018 (brouillon) → à numéroter à la signature |
| Élément | `LAB_LAB_SEMEN_COUNT_001` (alias historique `lab_semen_count`), version 1 |
| Version de l'application | 1.23.0 |
| Fichiers | `packages/biosigma_core/lib/src/lab/semen.dart` ; écran : mode « Sperme (OMS) » de Count |

### 1. Ce qui est à valider

- **Concentration (×10⁶/mL) = S / F**, S = somme des comptages des deux chambres, F = volume compté total (nL) / facteur de dilution ; volume compté total = 2 chambres × (carrés comptés / 25) × 100 nL (une grille de 1 mm × 1 mm × 100 µm contient 100 nL ; OMS § 2.4.8.2, légende de la figure 2.5).
- **Accord des réplicats** : |A − B| ≤ limite du tableau 2.3 pour la somme S ; couples successifs (jusqu'à trois) : le premier couple acceptable donne le résultat ; trois couples tous trop éloignés : moyenne des trois sommes avec mise en garde ; moins de trois : pas de résultat, nouveau comptage (OMS § 2.4.8.4).
- **Erreur due au nombre d'observations** : 3ᵉ colonne du tableau 2.3.
- **Moins de 25 spermatozoïdes dans chaque chambre** : mention « Trop peu de spermatozoïdes comptés… » avec une borne 50/F (§ 2.4.8.6).
- **Nombre total** = concentration × volume de l'éjaculat ; entier de millions, une décimale sous 10 millions (§ 2.4.8.7).
- **Repères** : 5ᵉ centile et médiane de la population de référence (tableau 8.3), toujours avec la mention que le 5ᵉ centile n'est pas une limite entre fertiles et infertiles (§ 8.1.3).
- **Dilutions** (tableau 2.1) : volumes de sperme et de fixateur, observation à l'état frais qui oriente le choix.

### 2. Pages du manuel à consulter

| Élément | Page imprimée | Page du PDF |
|---|---|---|
| Tableau 2.1 (dilutions) | 20 | 34 |
| Chambre de Neubauer, grilles, 100 nL (légende de la figure 2.5) | 29–31 | 43–45 |
| Règles de comptage, nombre de carrés à compter | 32 | 46 |
| Tableau 2.3 (écart entre réplicats, erreur) | 33–34 | 47–48 |
| Tableau 2.4 (facteurs de correction) | 35 | 49 |
| Nombre total, nombre bas (< 25) | 35 | 49 |
| Tableau 8.3 (population de référence) ; § 8.1.3 en page suivante | 213 | 227 (et 228) |

### 3. Contrôles faits par programme (pas une validation)

- **Tableau 2.4** : les **55 facteurs** (5 dilutions × 11 surfaces) calculés par la formule ci-dessus sont **égaux** à ceux imprimés.
- **Tableau 2.3** : 61 lignes **contiguës** de 1 à 1000 ; **chaque ligne** suit la loi de Poisson (limite = ⌊1,96·√S_min⌋, erreur = 100/√S_min à 0,1 près) : cela recoupe la transcription des 61 lignes. **Une coquille du PDF corrigée** : la ligne imprimée « 22–36 | 9 | 21,3 % » est lue « **22–26** » (la ligne suivante commence à 27 ; la limite et l'erreur sont celles d'une somme de 22). **À confirmer sur la page 34 du manuel.**
- **Tableau 8.3** : 9 paramètres × 9 centiles recopiés ; centiles croissants ; 5ᵉ centiles et effectifs imprimés testés.
- Cas calculés à la main : 1 : 20, 1 grille, 210 et 198 → somme 408, écart 12 ≤ 39, 40,8 ×10⁶/mL, erreur 5,0 %, 3 mL → 122 millions.

### 4. Points à décider ou à relire

1. **La coquille « 22–36 »** (voir § 3).
2. **Sommes > 1000** : le tableau 2.3 s'arrête à 1000 ; l'application calcule avec mise en garde et ne juge pas l'accord. Convient-il ?
3. **Couple retenu** : « le premier couple acceptable » (l'OMS dit : si l'écart est acceptable, calculer ; elle ne dit pas explicitement de grouper les couples successifs). Interprétation à confirmer.
4. **Chiffres significatifs de la concentration** : l'OMS ne les fixe pas dans ce paragraphe (elle les fixe pour d'autres méthodes) : l'application affiche 2 décimales ; à décider.
5. **Mise en garde « < 25 »** : la borne 50/F est **dérivée** (pour 1 : 2 et 9 grilles : 0,056 ×10⁶/mL = « < 55 555/mL » du manuel) ; pour les autres configurations elle est calculée, non citée.
6. **Repères d'interprétation** : le 5ᵉ centile est affiché comme repère « descriptif » avec la mise en garde du § 8.1.3 ; l'application ne conclut ni à une anomalie ni à une infertilité.
7. **Azoospermie** : l'application n'emploie pas le terme ; elle renvoie à l'examen d'un culot de centrifugation (§ 2.4.8.8).
8. **Hors périmètre** : faible nombre (méthodes avec centrifugation), pourcentages (tableau 2.2), mobilité, morphologie.

### 5. Tests associés

`test/lab/semen_test.dart` (20 tests : tableaux 2.1, 2.3, 2.4, 8.3 ; calculs ; refus) · `test/screens/semen_mcfarland_test.dart` (5 tests d'écran du mode sperme).

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ tableau 2.1 ☐ tableau 2.3 (dont « 22–26 ») ☐ tableau 2.4 ☐ tableau 8.3 ☐ formules ☐ conduite en cas d'écart ☐ mises en garde |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `LAB_LAB_SEMEN_COUNT_001` du registre puis importer (gouvernance §12).
