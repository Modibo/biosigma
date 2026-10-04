# Dossier de validation préparé — FV-PREP-012
## Score CHA₂DS₂-VASc (`HEMO_CHA2DS2_VASC_SCORE_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**) après consultation de la **source primaire**.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-012 (brouillon) → à numéroter à la signature |
| Élément | `HEMO_CHA2DS2_VASC_SCORE_001` (alias historique `cha2ds2_vasc_score`) |
| Version de l'élément / de l'application | 1 / 1.17.1 |
| Fichier | `packages/biosigma_core/lib/src/calculators/hemostasis/` |

### 1. Ce qui est à valider

Points : insuffisance cardiaque 1 ; HTA 1 ; âge ≥ 75 : 2 ; diabète 1 ; AVC/AIT/embolie : 2 ; maladie vasculaire 1 ; âge 65–74 : 1 ; sexe féminin 1. Total 0–9.

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : Lip GYH, et al. *Chest.* 2010;137(2):263-272. | **À consulter par le validateur** — date : À COMPLÉTER |
| Secondaire consultée par l'auteur le 2026-10-04 : Wikipédia « CHA₂DS₂–VASc score » | Barème confirmé. |
| Recommandations sur le traitement (ESC) | **Non vérifiées** ; une évolution (CHA₂DS₂-VA, sans le critère de sexe) existe selon mes souvenirs, **à vérifier par le validateur**. |

### 3. Cas de vérification indépendants (calculés hors du code testé)

Test **exhaustif** : les **192 combinaisons** (6 critères binaires × 3 tranches d'âge) comparées à un barème réécrit à part (`independent_batch2_test.dart`). Aucune différence.

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même, indépendamment de cette préparation : À COMPLÉTER.

### 4. Points à relire en particulier

1. **Le critère de sexe** : maintenu comme dans la publication originale ; l'évolution des recommandations est à vérifier.
2. **Interprétation** (seuils de décision) : la source est à citer.
3. Référence « R-08 » du registre : à reconfirmer.

### 5. Tests du dépôt associés

`independent_batch2_test.dart` (192 combinaisons) · golden master.

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formule ☐ constantes ☐ unités d'entrée/sortie ☐ domaine/population ☐ cas interdits ☐ limites ☐ texte d'interprétation |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `HEMO_CHA2DS2_VASC_SCORE_001` du registre de validation (`registre-validation.csv`, version 1) puis importer (gouvernance §12).
