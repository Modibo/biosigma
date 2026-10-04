# Dossier de validation préparé — FV-PREP-010
## Schwartz « bedside » pédiatrique (`RENAL_SCHWARTZ_BEDSIDE_PEDIATRIC_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**) après consultation de la **source primaire**.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-010 (brouillon) → à numéroter à la signature |
| Élément | `RENAL_SCHWARTZ_BEDSIDE_PEDIATRIC_001` (alias historique `schwartz_bedside`) |
| Version de l'élément / de l'application | 1 / 1.17.1 |
| Fichier | `packages/biosigma_core/lib/src/calculators/renal/` |

### 1. Ce qui est à valider

`DFG = 0,413 × taille (cm) / créatinine (mg/dL)` ; mL/min/1,73 m². Domaine codé : 1 à 25 ans (à confirmer).

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : Schwartz GJ, Muñoz A, Schneider MF, et al. New equations to estimate GFR in children with CKD. *J Am Soc Nephrol.* 2009;20(3):629-637. | **À consulter par le validateur** — date : À COMPLÉTER |
| Secondaire consultée par l'auteur le 2026-10-04 : article Wikipédia « Glomerular filtration rate » | Coefficient 0,413 confirmé. Pas de borne d'âge vérifiée en secondaire. |

### 3. Cas de vérification indépendants (calculés hors du code testé)

| # | Âge | Taille (cm) | Scr (mg/dL) | DFG attendu |
|---|---|---|---|---|
| 1 | 8 | 125 | 0,5 | 103,25 |
| 2 | 14 | 160 | 0,8 | 82,6 |
| 3 | 3 | 95 | 0,4 | 98,0875 |

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même, indépendamment de cette préparation : À COMPLÉTER.

### 4. Points à relire en particulier

1. **Domaine d'âge** (1–25 ans dans le code) : à confirmer ; l'étude portait sur des enfants avec MRC.
2. **Créatinine standardisée IDMS** : exigée ? affichée ?
3. Le nom « bedside » (Schwartz 2009) vs. Schwartz initial (k variable) : cohérence du libellé.

### 5. Tests du dépôt associés

`independent_batch2_test.dart` (3 cas) · golden master (`schwartz_bedside`).

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formule ☐ constantes ☐ unités d'entrée/sortie ☐ domaine/population ☐ cas interdits ☐ limites ☐ texte d'interprétation |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `RENAL_SCHWARTZ_BEDSIDE_PEDIATRIC_001` du registre de validation (`registre-validation.csv`, version 1) puis importer (gouvernance §12).
