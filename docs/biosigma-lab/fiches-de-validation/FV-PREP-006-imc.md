# Dossier de validation préparé — FV-PREP-006
## Indice de masse corporelle (IMC) (`METAB_BMI_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**) après consultation de la **source primaire**.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-006 (brouillon) → à numéroter à la signature |
| Élément | `METAB_BMI_001` (alias historique `bmi`) |
| Version de l'élément / de l'application | 1 / 1.17.0 |
| Fichier | `packages/biosigma_core/lib/src/calculators/metabolic/anthropometric_and_ratios.dart` |

### 1. Ce qui est à valider

`IMC = Poids (kg) / [Taille (m)]²` ; taille saisie en cm, convertie en m. Résultat 1 décimale. Bandes OMS affichées à titre informatif : < 18,5 ; 18,5–24,9 ; 25,0–29,9 ; ≥ 30,0 kg/m².

Population : adulte ≥ 18 ans. Cas interdits codés : poids ou taille ≤ 0.

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : Quetelet 1832 (origine de l'indice) ; OMS. Obesity: Preventing and Managing the Global Epidemic. TRS 894, 2000. | **À consulter par le validateur** — date : À COMPLÉTER |
| Secondaire consultée par l'auteur le 2026-10-04 : page « BMI categories » des CDC | **Formule identique** (poids en kg divisé par le carré de la taille en m). **Catégories identiques** : < 18,5 ; 18,5 à < 25 ; 25 à < 30 ; ≥ 30. |

### 3. Cas de vérification indépendants (calculés hors du code testé)

Calculés en Python à partir de la formule ci-dessus (pas avec le code Dart) ; **tous égaux à la valeur du code à 10⁻¹² près** (`independent_priority_test.dart`).

| # | Poids (kg) | Taille (cm) | IMC attendu |
|---|---|---|---|
| 1 | 70 | 175 | 22,8571 |
| 2 | 95 | 180 | 29,3210 |
| 3 | 50 | 160 | 19,5313 |
| 4 | 120 | 170 | 41,5225 |
| 5 | 60 | 150 | 26,6667 |

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même (calculatrice, tableur, outil en ligne), indépendamment de cette préparation : À COMPLÉTER.

### 4. Points à relire en particulier

1. **Frontières** : IMC = 25,0 exactement ; 24,95 affiché « 25,0 » (arrondi à 1 décimale) mais classé selon la valeur non arrondie : le libellé de bande correspond-il à ce que le clinicien voit ?
2. **Bandes OMS vs formulation « 24,9 / 25,0 »** : l'OMS parle de « 18,50–24,99 » ; le texte écrit « 18,5–24,9 ». Acceptable ?
3. **Populations** : seuils différents pour certaines populations (signalé dans les limites, non appliqué) — suffisant ?
4. **Enfant/adolescent** : non géré (bien indiqué).

### 5. Tests du dépôt associés

`anthropometric_and_ratios_test.dart` · `independent_priority_test.dart` (5 cas) · golden master (`bmi`).

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formule ☐ constantes ☐ unités d'entrée/sortie ☐ domaine/population ☐ cas interdits ☐ limites ☐ texte d'interprétation |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `METAB_BMI_001` du registre de validation (`registre-validation.csv`) puis importer (gouvernance §12).
