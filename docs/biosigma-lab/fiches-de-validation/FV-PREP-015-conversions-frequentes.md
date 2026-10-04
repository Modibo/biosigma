# Dossier de validation préparé — FV-PREP-015
## Conversions d'unités fréquentes (créatinine, urée, azote uréique, calcium, cholestérol, triglycérides, bilirubine, sodium) (`analyte:creatinine, analyte:urea, analyte:urea_nitrogen, analyte:calcium, analyte:cholesterol, analyte:triglycerides, analyte:bilirubin, analyte:sodium`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**) après consultation de la **source primaire**.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-015 (brouillon) → à numéroter à la signature |
| Élément | `analyte:creatinine, analyte:urea, analyte:urea_nitrogen, analyte:calcium, analyte:cholesterol, analyte:triglycerides, analyte:bilirubin, analyte:sodium` (alias historique `—`) |
| Version de l'élément / de l'application | 1 / 1.17.1 |
| Fichier | `packages/biosigma_core/lib/src/lab/analyte_base.dart` |

### 1. Ce qui est à valider

Facteurs masse ↔ quantité de matière calculés à partir de la **masse molaire = Σ (poids atomique abrégé IUPAC × nombre d'atomes)** de la formule chimique, pas à partir de facteurs recopiés : créatinine C₄H₇N₃O (113,12 g/mol) ; urée CH₄N₂O (60,056) ; azote uréique (28,014 g/mol d'azote, conversion en mmol/L d'urée) ; calcium (40,078) ; cholestérol C₂₇H₄₆O (386,664) ; triglycérides (885,453 : trioléine C₅₇H₁₀₄O₆, **hypothèse usuelle**, à confirmer) ; bilirubine C₃₃H₃₆N₄O₆ (584,673) ; sodium (22,99).

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : tableau IUPAC des poids atomiques abrégés ; conventions IFCC/SFBC de conversion d'unités SI | **À consulter par le validateur** — date : À COMPLÉTER |
| Secondaire (formules brutes) | Les formules chimiques de ces analytes ont été comparées par l'auteur à PubChem/NCI (voir `relecture-analytes.md`) : **formule identique** pour chacun. Les masses molaires qui en découlent n'ont pas été comparées à une table externe. |

### 3. Cas de vérification indépendants (calculés hors du code testé)

Valeurs calculées en Python à partir des masses molaires ci-dessus, **sans** le code Dart (`independent_conversions_test.dart`, 6 tests verts).

| # | Analyte | Valeur | Conversion attendue |
|---|---|---|---|
| 1 | Créatinine | 1 mg/dL | 88,4017 µmol/L |
| 2 | Créatinine | 100 µmol/L | 1,1312 mg/dL |
| 3 | Urée | 40 mg/dL | 6,6605 mmol/L |
| 4 | Azote uréique (BUN) | 20 mg/dL | 7,1393 mmol/L d'urée |
| 5 | Calcium | 9,5 mg/dL | 2,3704 mmol/L |
| 6 | Cholestérol | 200 mg/dL | 5,1724 mmol/L |
| 7 | Triglycérides | 150 mg/dL | 1,6940 mmol/L |
| 8 | Bilirubine | 1 mg/dL | 17,1036 µmol/L |
| 9 | Sodium | 140 mmol/L | 321,86 mg/dL |

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même, indépendamment de cette préparation : À COMPLÉTER.

### 4. Points à relire en particulier

1. **Écart de facteur** : le moteur Calcul (créatinine 88,42) et le convertisseur Lab (88,4017) diffèrent d'environ 0,02 % ; assumé ? (les deux sont tracés).
2. **Triglycérides** : une seule masse molaire (trioléine) alors que la composition réelle varie ; l'écart est connu mais à valider.
3. **Cholestérol** : valeur 38,67 mg/dL par mmol/L (facteur courant 38,67) cohérente avec 386,664.
4. **Bilirubine** : facteur courant 17,1 (58,47 ÷ 3,42) cohérent.
5. Les autres analytes (186 au total) : voir `relecture-analytes.md`.

### 5. Tests du dépôt associés

`independent_conversions_test.dart` · tests de propriété aller-retour (> 5000 paires) · `analyte_base_test.dart`.

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ masses molaires ☐ facteurs de conversion ☐ unités traditionnelles/SI ☐ arrondi ☐ limites |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `analyte:creatinine, analyte:urea, analyte:urea_nitrogen, analyte:calcium, analyte:cholesterol, analyte:triglycerides, analyte:bilirubin, analyte:sodium` du registre de validation (`registre-validation.csv`, version 1) puis importer (gouvernance §12).
