# Dossier de validation préparé — FV-PREP-001
## DFG CKD-EPI créatinine 2021 (`RENAL_CKD_EPI_CREATININE_2021_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** Il rassemble ce qu'il faut pour que le validateur scientifique (**Dr Modibo Mouctar Coulibaly**) puisse trancher. Les cases « À COMPLÉTER » sont à remplir par lui, après consultation de la **source primaire**.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-001 (brouillon) → à numéroter FV-2026-001 à la signature |
| Élément | `RENAL_CKD_EPI_CREATININE_2021_001` (alias historique `ckd_epi_creatinine_2021`) |
| Version de l'élément / de l'application | 1 / 1.11.0 |
| Fichier | `packages/biosigma_core/lib/src/calculators/renal/ckd_epi.dart` |

### 1. Ce qui est à valider (équation implémentée)

`DFG = 142 × min(Scr/κ, 1)^α × max(Scr/κ, 1)^−1,200 × 0,9938^Âge × 1,012 [si femme]`
avec Scr en mg/dL ; κ = 0,7 (femme) / 0,9 (homme) ; α = −0,241 (femme) / −0,302 (homme) ; résultat en mL/min/1,73 m².

- Entrée en µmol/L convertie par le facteur **88,42** du moteur (créatinine, `UnitRegistry`) : à valider aussi (voir §4).
- Cas interdits codés : âge < 18 ans ; standardisation IDMS non confirmée.
- Population : adulte ≥ 18 ans.

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : Inker LA, Eneanya ND, Coresh J, et al. New Creatinine- and Cystatin C-Based Equations to Estimate GFR without Race. *N Engl J Med.* 2021;385(19):1737-1749. | **À consulter par le validateur** — date de consultation : À COMPLÉTER |
| Secondaire (déjà consultée par l'auteur le 2026-10-04) : page « CKD-EPI Creatinine Equation (2021) » de la National Kidney Foundation, qui donne 142 ; κ 0,7/0,9 ; α −0,241/−0,302 ; −1,200 ; 0,9938 ; 1,012. | **Constantes identiques à celles du code.** Une source secondaire ne remplace pas la source primaire. |
| Interprétation (stades G1-G5) : KDIGO 2012 (Kidney Int Suppl 2013;3(1):1-150). | À consulter si l'interprétation est dans le périmètre |

### 3. Cas de vérification indépendants (calculés hors du code testé)

Calculés en Python à partir de l'équation ci-dessus (pas avec le code Dart) ; **tous égaux à la valeur du code à 10⁻¹² près** (test `ckd_epi_independent_test.dart`, 9 tests verts).

| # | Scr (mg/dL) | Âge | Sexe | DFG attendu (mL/min/1,73 m²) | Particularité |
|---|---|---|---|---|---|
| 1 | 1,0 | 60 | F | 64,495 | |
| 2 | 1,0 | 60 | H | 86,163 | |
| 3 | 1,4 | 50 | F | 45,833 | |
| 4 | 2,0 | 70 | H | 35,243 | |
| 5 | 0,6 | 30 | F | 123,758 | Scr < κ |
| 6 | 0,9 | 40 | H | 110,726 | Scr = κ (frontière) |
| 7 | 5,0 | 80 | H | 11,029 | forte créatininémie |
| 8 | 0,5 | 25 | F | 133,401 | Scr < κ |

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même (calculatrice, tableur, ou le calculateur en ligne de la NKF), indépendamment de cette préparation, et noter son résultat : À COMPLÉTER.

### 4. Points à relire en particulier

1. Le **facteur 88,42** µmol/L ↔ mg/dL (= 10⁴ ÷ 113,12 g/mol, arrondi) : acceptable pour cette équation ? Écart avec la valeur exacte 88,40 : environ 0,02 %.
2. La **frontière Scr = κ** : les deux branches (min/max) se rejoignent (cas 6).
3. Le **texte d'interprétation** KDIGO (stades) : dans le périmètre de cette validation ou non ?
4. Les **limites** affichées (grossesse, masse musculaire, etc.) : complètes et exactes ?

### 5. Tests du dépôt associés

`ckd_epi_test.dart` (calculs, âge < 18, IDMS) · `ckd_epi_independent_test.dart` (8 cas indépendants + µmol/L) · golden master (`ckd_epi_creatinine_2021` : cas de base et variantes d'unité figés).

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formule ☐ constantes ☐ unités d'entrée/sortie ☐ domaine/population ☐ cas interdits ☐ limites ☐ interprétation KDIGO |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : ajouter la fiche à `validationRecords` (`packages/biosigma_core/lib/src/registry/validation.dart`) avec `itemId: 'RENAL_CKD_EPI_CREATININE_2021_001'`, `itemVersion: 1`, `independentCases: 2` au minimum, les noms du validateur, du relecteur technique et de l'approbateur, et la référence de la fiche archivée ; relancer les tests ; publier une nouvelle version.
