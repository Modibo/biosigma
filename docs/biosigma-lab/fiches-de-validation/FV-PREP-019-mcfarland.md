# Dossier de validation préparé — FV-PREP-019
## Équivalence McFarland (`LAB_LAB_MICRO_MCFARLAND_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** La valeur a été **saisie par le validateur** le 2026-10-04 ; **aucune source n'a été citée** : l'assistant ne l'a confrontée à rien.

| Champ | Contenu |
|---|---|
| Élément | `LAB_LAB_MICRO_MCFARLAND_001` (alias `lab_micro_mcfarland`), version 1 |
| Version de l'application | 1.23.0 |
| Fichier | `packages/biosigma_core/lib/src/lab/microbiology.dart` ; écran : mode « McFarland » de Microbiology |

### 1. Ce qui est à valider

**0,5 McFarland ≈ 1,5 × 10⁸ UFC/mL**, seule équivalence embarquée (valeur saisie par le validateur). Aucun autre standard n'est renseigné ni extrapolé : toute autre valeur est refusée. Facteur de dilution = (1,5 × 10⁸) / (UFC/mL visées), refusé si la cible dépasse la suspension.

### 2. Source

| Source | Statut |
|---|---|
| Valeur saisie par le validateur, 2026-10-04 | **Source primaire non citée : À COMPLÉTER** (norme ou publication de référence : ______) |

### 3. Points à décider ou à relire

1. **La source** de l'équivalence (à citer dans la fiche de l'équation).
2. **Le libellé de mise en garde** : « la turbidité n'est pas un dénombrement ; la correspondance peut varier selon l'espèce, la souche, la phase de croissance et la méthode de lecture » : cette formulation est une **mise en garde générale de l'assistant**, non issue de la valeur saisie ; à confirmer ou corriger.
3. **Autres standards** (1, 2, 3…) : non renseignés ; à fournir (avec leur source) si utiles.

### 4. Tests associés

`test/lab/mcfarland_test.dart` (5 tests : valeur, dilution 300 pour 5 × 10⁵, refus des autres standards, provenance) · `test/screens/semen_mcfarland_test.dart` (3 tests d'écran).

### 5. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ valeur 1,5 × 10⁸ ☐ source citée ☐ mise en garde ☐ refus des autres standards |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |
