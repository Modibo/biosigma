# Dossier de validation préparé — FV-PREP-007
## HOMA-IR (`METAB_HOMA_IR_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**) après consultation de la **source primaire**.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-007 (brouillon) → à numéroter à la signature |
| Élément | `METAB_HOMA_IR_001` (alias historique `homa_ir`) |
| Version de l'élément / de l'application | 1 / 1.17.0 |
| Fichier | `packages/biosigma_core/lib/src/calculators/metabolic/insulin_resistance.dart` |

### 1. Ce qui est à valider

`HOMA-IR = glycémie (mmol/L) × insulinémie (µU/mL) / 22,5` ; la forme mg/dL (÷ 405) est mentionnée dans les limites. Entrées converties si saisies dans d'autres unités (glucose mg/dL ↔ mmol/L par 0,0555 ; insuline pmol/L ↔ µU/mL par 1/6,945). Prélèvement à jeun exigé.

Cas interdits codés : valeurs ≤ 0 ; jeûne non confirmé.

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : Matthews DR, Hosker JP, Rudenski AS, et al. Diabetologia. 1985;28(7):412-419. | **À consulter par le validateur** — date : À COMPLÉTER |
| Secondaire consultée par l'auteur le 2026-10-04 : page « Homeostatic model assessment » de Wikipédia | **Constantes identiques** : 22,5 (mmol/L) et 405 (mg/dL). Les constantes du HOMA-β (20 et 3,5 ; 360 et 63 en mg/dL) y figurent aussi et **correspondent** à celles du code (hors périmètre de ce dossier). |

### 3. Cas de vérification indépendants (calculés hors du code testé)

Calculés en Python à partir de la formule ci-dessus (pas avec le code Dart) ; **tous égaux à la valeur du code à 10⁻¹² près** (`independent_priority_test.dart`).

| # | Glycémie (mmol/L) | Insuline (µU/mL) | HOMA-IR attendu |
|---|---|---|---|
| 1 | 5,0 | 10 | 2,2222 |
| 2 | 6,5 | 20 | 5,7778 |
| 3 | 4,5 | 5 | 1,0000 |
| 4 | 7,8 | 30 | 10,4000 |

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même (calculatrice, tableur, outil en ligne), indépendamment de cette préparation : À COMPLÉTER.

### 4. Points à relire en particulier

1. **Facteur insuline µU/mL ↔ pmol/L = 6,945** : dépend de l'étalon du dosage (déjà signalé) ; validé tel quel ou à rendre modifiable ?
2. **Facteur glucose 0,0555** (arrondi) : l'écart avec la valeur exacte est d'environ 0,01 %.
3. **Seuil cité en exemple (HOMA-IR > 2,5)** : seuil de recherche, signalé comme tel ; la source du chiffre n'est pas citée — à confirmer.
4. **Forme mg/dL (÷ 405)** : mentionnée mais non calculée ; cohérence avec 22,5 × 18,0156 ≈ 405,4 (arrondi à 405) à confirmer.

### 5. Tests du dépôt associés

`insulin_resistance_test.dart` · `independent_priority_test.dart` (4 cas) · golden master (`homa_ir`).

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formule ☐ constantes ☐ unités d'entrée/sortie ☐ domaine/population ☐ cas interdits ☐ limites ☐ texte d'interprétation |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `METAB_HOMA_IR_001` du registre de validation (`registre-validation.csv`) puis importer (gouvernance §12).
