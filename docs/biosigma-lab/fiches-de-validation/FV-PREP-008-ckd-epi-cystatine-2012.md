# Dossier de validation préparé — FV-PREP-008
## DFG CKD-EPI cystatine C 2012 (`RENAL_CKD_EPI_CYSTATIN_C_2012_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**) après consultation de la **source primaire**.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-008 (brouillon) → à numéroter à la signature |
| Élément | `RENAL_CKD_EPI_CYSTATIN_C_2012_001` (alias historique `ckd_epi_cystatin_c_2012`) |
| Version de l'élément / de l'application | 1 / 1.17.1 |
| Fichier | `packages/biosigma_core/lib/src/calculators/renal/ckd_epi.dart` |

### 1. Ce qui est à valider

`DFG = 133 × min(Cys/0,8 ; 1)^−0,499 × max(Cys/0,8 ; 1)^−1,328 × 0,996^Âge × 0,932 [si femme]` (Cys en mg/L ; résultat en mL/min/1,73 m²). Adulte ≥ 18 ans ; cystatine C standardisée (étalon ERM-DA471/IFCC) à confirmer.

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : Inker LA, Schmid CH, Tighiouart H, et al. Estimating GFR from serum creatinine and cystatin C. *N Engl J Med.* 2012;367(1):20-29. | **À consulter par le validateur** — date : À COMPLÉTER |
| Secondaire consultée par l'auteur le 2026-10-04 : page « CKD-EPI Cystatin C Equation (2012) » de la National Kidney Foundation | **Constantes identiques à celles du code** (133 ; 0,8 ; −0,499 ; −1,328 ; 0,996 ; 0,932). Une source secondaire ne remplace pas la source primaire. |

### 3. Cas de vérification indépendants (calculés hors du code testé)

Calculés en Python à partir de la formule ci-dessus (pas avec le code Dart) ; tous égaux à la valeur du code à 10⁻¹² près (`independent_batch2_test.dart`).

| # | Cys (mg/L) | Âge | Sexe | DFG attendu (mL/min/1,73 m²) |
|---|---|---|---|---|
| 1 | 1,0 | 60 | F | 72,4655 |
| 2 | 0,8 | 50 | H | 108,8475 |
| 3 | 0,6 | 30 | F | 126,8797 |
| 4 | 1,5 | 75 | H | 42,7323 |

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même, indépendamment de cette préparation : À COMPLÉTER.

### 4. Points à relire en particulier

1. **Normalisation de la cystatine C** : l'équation suppose un dosage standardisé ; l'app le rappelle-t-elle suffisamment ?
2. **Frontière Cys = 0,8** : les deux branches se rejoignent.
3. **Limites** affichées (corticoïdes, dysthyroïdie, inflammation, obésité) : complètes ?

### 5. Tests du dépôt associés

`ckd_epi_test.dart` · `independent_batch2_test.dart` (4 cas) · golden master (`ckd_epi_cystatin_c_2012`).

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formule ☐ constantes ☐ unités d'entrée/sortie ☐ domaine/population ☐ cas interdits ☐ limites ☐ texte d'interprétation |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `RENAL_CKD_EPI_CYSTATIN_C_2012_001` du registre de validation (`registre-validation.csv`, version 1) puis importer (gouvernance §12).
