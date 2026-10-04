# Dossier de validation préparé — FV-PREP-013
## Score HAS-BLED (`HEMO_HAS_BLED_SCORE_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**) après consultation de la **source primaire**.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-013 (brouillon) → à numéroter à la signature |
| Élément | `HEMO_HAS_BLED_SCORE_001` (alias historique `has_bled_score`) |
| Version de l'élément / de l'application | 1 / 1.17.1 |
| Fichier | `packages/biosigma_core/lib/src/calculators/hemostasis/` |

### 1. Ce qui est à valider

1 point par critère : HTA non contrôlée ; fonction rénale anormale ; fonction hépatique anormale ; AVC ; saignement/prédisposition ; INR labile ; âge > 65 ; antiagrégants/AINS ; alcool. Total 0–9.

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : Pisters R, et al. *Chest.* 2010;138(5):1093-1100. | **À consulter par le validateur** — date : À COMPLÉTER |
| Secondaire consultée par l'auteur le 2026-10-04 : Wikipédia « HAS-BLED » | Barème confirmé. |

### 3. Cas de vérification indépendants (calculés hors du code testé)

Test **exhaustif** : les **512 combinaisons** (9 critères) comparées à un barème réécrit à part. Aucune différence.

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même, indépendamment de cette préparation : À COMPLÉTER.

### 4. Points à relire en particulier

1. **Définitions des critères** (ex. fonction rénale anormale : dialyse/greffe/créatinine > 200 µmol/L ; hépatique : cirrhose ou bilirubine > 2× + ASAT/ALAT > 3×) : les seuils éventuellement affichés sont à relire dans la source primaire.
2. **Interprétation du score ≥ 3** : source à citer.
3. Référence « R-08 » du registre : à reconfirmer.

### 5. Tests du dépôt associés

`independent_batch2_test.dart` (512 combinaisons) · golden master.

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formule ☐ constantes ☐ unités d'entrée/sortie ☐ domaine/population ☐ cas interdits ☐ limites ☐ texte d'interprétation |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `HEMO_HAS_BLED_SCORE_001` du registre de validation (`registre-validation.csv`, version 1) puis importer (gouvernance §12).
