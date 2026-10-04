# Dossier de validation préparé — FV-PREP-019
## Équivalence McFarland (`LAB_LAB_MICRO_MCFARLAND_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** La valeur a été **saisie par le validateur** le 2026-10-04, avec la référence McFarland J. JAMA 1907 ; l'assistant n'a lu ni cette publication ni aucune autre source sur ce point.

| Champ | Contenu |
|---|---|
| Élément | `LAB_LAB_MICRO_MCFARLAND_001` (alias `lab_micro_mcfarland`), version 1 |
| Version de l'application | 1.23.1 |
| Fichier | `packages/biosigma_core/lib/src/lab/microbiology.dart` ; écran : mode « McFarland » de Microbiology |

### 1. Ce qui est à valider

**0,5 McFarland ≈ 1,5 × 10⁸ UFC/mL**, seule équivalence embarquée (valeur saisie par le validateur). Aucun autre standard n'est renseigné ni extrapolé : toute autre valeur est refusée. Facteur de dilution = (1,5 × 10⁸) / (UFC/mL visées), refusé si la cible dépasse la suspension.

### 2. Source

| Source | Statut |
|---|---|
| **McFarland J. JAMA. 1907;49:1176–1178.** (référence fournie par le validateur le 2026-10-04, avec la valeur) | **À confronter par le validateur** : l'assistant n'a pas lu cette publication et ne peut pas dire si elle donne elle-même l'équivalence 0,5 ≈ 1,5 × 10⁸ UFC/mL (la correspondance en UFC peut venir d'une norme ultérieure). Date de votre lecture : ______ |

### 3. Points à décider ou à relire

1. **La source** : McFarland J. JAMA 1907 est citée ; **cette publication contient-elle l'équivalence en UFC/mL ?** Sinon, citer la norme qui la donne.
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
