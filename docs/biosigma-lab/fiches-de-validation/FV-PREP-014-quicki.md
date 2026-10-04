# Dossier de validation préparé — FV-PREP-014
## QUICKI (`METAB_QUICKI_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**) après consultation de la **source primaire**.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-014 (brouillon) → à numéroter à la signature |
| Élément | `METAB_QUICKI_001` (alias historique `quicki`) |
| Version de l'élément / de l'application | 1 / 1.17.1 |
| Fichier | `packages/biosigma_core/lib/src/calculators/metabolic/` |

### 1. Ce qui est à valider

`QUICKI = 1 / (log10 insuline [µU/mL] + log10 glycémie [mg/dL])`. À jeun.

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : Katz A, Nambi SS, Mather K, et al. *J Clin Endocrinol Metab.* 2000;85(7):2402-2410. | **À consulter par le validateur** — date : À COMPLÉTER |
| Secondaire consultée par l'auteur le 2026-10-04 : Wikipédia « Quantitative insulin sensitivity check index » | Formule confirmée. |

### 3. Cas de vérification indépendants (calculés hors du code testé)

| # | Insuline (µU/mL) | Glycémie (mg/dL) | QUICKI attendu |
|---|---|---|---|
| 1 | 15 | 90 | 0,319455 |
| 2 | 10 | 85 | 0,341365 |
| 3 | 20 | 100 | 0,302936 |
| 4 | 5 | 70 | 0,393071 |

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même, indépendamment de cette préparation : À COMPLÉTER.

### 4. Points à relire en particulier

1. **Conversion des entrées** : glucose mmol/L → mg/dL (× 18,0156 ?) et insuline pmol/L → µU/mL (÷ 6,945) : facteurs à valider.
2. **Seuils d'interprétation** (le cas échéant) : source à citer.

### 5. Tests du dépôt associés

`independent_batch2_test.dart` (4 cas) · golden master.

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formule ☐ constantes ☐ unités d'entrée/sortie ☐ domaine/population ☐ cas interdits ☐ limites ☐ texte d'interprétation |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `METAB_QUICKI_001` du registre de validation (`registre-validation.csv`, version 1) puis importer (gouvernance §12).
