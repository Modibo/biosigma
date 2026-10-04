# Dossier de validation préparé — FV-PREP-011
## MELD et MELD-Na (UNOS) (`IONO_MELD_NA_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**) après consultation de la **source primaire**.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-011 (brouillon) → à numéroter à la signature |
| Élément | `IONO_MELD_NA_001` (alias historique `meld_na`) |
| Version de l'élément / de l'application | 1 / 1.17.1 |
| Fichier | `packages/biosigma_core/lib/src/calculators/ionogram/` |

### 1. Ce qui est à valider

MELD brut = 3,78 ln(bilirubine mg/dL) + 11,2 ln(INR) + 9,57 ln(créatinine mg/dL) + 6,43, avec planchers à 1,0 et créatinine plafonnée à 4,0 (forcée à 4,0 en dialyse) ; MELD-Na = MELD + 1,32 (137 − Na) − 0,033 MELD (137 − Na) si MELD > 11, Na borné à 125–137. **Valeurs codées à confirmer sur la source** (les constantes de la formule sont à relire une à une ; une seule source secondaire — Wikipédia MELD — a été consultée, et elle ne confirme pas la formule MELD-Na).

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : Kamath PS, et al. *Hepatology.* 2001;33(2):464-470 (MELD) ; Kim WR, et al. *N Engl J Med.* 2008;359(10):1018-1026 (MELD-Na) ; politique UNOS/OPTN en vigueur. | **À consulter par le validateur** — date : À COMPLÉTER |
| Secondaire consultée par l'auteur le 2026-10-04 : Wikipédia « Model for End-Stage Liver Disease » | MELD brut confirmé ; formule MELD-Na **non confirmée**. |

### 3. Cas de vérification indépendants (calculés hors du code testé)

| # | Créat. | Bili. (µmol/L) | INR | Na | Dialyse | MELD | MELD-Na |
|---|---|---|---|---|---|---|---|
| 1 | 1,2 | 51,3 | 1,5 | 130 | non | 16,87 | 22,21 |
| 2 | 0,8 | 17,1 | 1,0 | 140 | non | 6,43 | 6,43 |
| 3 | 2,5 | 171 | 2,0 | 120 | non | 31,67 | 34,97 |
| 4 | 1,0 | 34,2 | 1,3 | 135 | oui | 25,26 | 26,23 |
| 5 | 3,0 | 256,5 | 2,5 | 128 | non | 37,44 | 38,20 |

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même, indépendamment de cette préparation : À COMPLÉTER.

### 4. Points à relire en particulier

1. **MELD-Na** : formule et bornes (Na 125–137 ; seuil MELD > 11) à confirmer sur Kim 2008 / UNOS.
2. **MELD 3.0** (2023) : non implémenté ; à signaler dans les limites ? (non vérifié ici : à confirmer par le validateur)
3. **Arrondi** (MELD en entier) : l'app arrondit-elle comme UNOS ?
4. **Bilirubine en µmol/L** : conversion en mg/dL (÷ 17,1) exacte ?

### 5. Tests du dépôt associés

`independent_batch2_test.dart` (5 cas) · golden master.

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formule ☐ constantes ☐ unités d'entrée/sortie ☐ domaine/population ☐ cas interdits ☐ limites ☐ texte d'interprétation |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `IONO_MELD_NA_001` du registre de validation (`registre-validation.csv`, version 1) puis importer (gouvernance §12).
