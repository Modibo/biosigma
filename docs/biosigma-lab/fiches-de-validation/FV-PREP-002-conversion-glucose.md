# Dossier de validation préparé — FV-PREP-002
## Conversion du glucose (`analyte:glucose`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**).

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-002 (brouillon) |
| Élément | `analyte:glucose` (base d'analytes de Convert) |
| Version de l'élément / de l'application | 1 / 1.11.0 |
| Fichiers | `analyte_base.dart` (entrée), `analyte_model.dart` (poids atomiques), `convert.dart` |

### 1. Ce qui est à valider

- **Formule brute** C₆H₁₂O₆ ; **forme** : glucose (aussi galactose et fructose ont cette formule, entrées distinctes).
- **Masse molaire calculée** = 6 × 12,011 + 12 × 1,008 + 6 × 15,999 = **180,156 g/mol** (poids atomiques IUPAC abrégés).
- Unités proposées : g/L, mg/dL, mmol/L, µmol/L… et excrétion (g/24 h, mmol/24 h). Pas de valence (non ionique).

### 2. Contrôles déjà faits (par l'auteur)

| Contrôle | Résultat |
|---|---|
| Formule comparée à PubChem (2026-10-04) | C6H12O6 — identique |
| Masse molaire externe PubChem | 180,16 g/mol (arrondie à 2 décimales) ; code : 180,156 — écart 0,004 |
| Écart avec le facteur arrondi des calculateurs (0,0555) | ≈ 0,01 % ; affiché sous chaque résultat Convert |

### 3. Cas de vérification indépendants (calculés à la main, hors du code)

| # | Entrée | Calcul à la main | Attendu |
|---|---|---|---|
| 1 | 100 mg/dL → mmol/L | 100 mg/dL = 1 000 mg/L = 1 g/L ; 1 ÷ 180,156 = 0,0055507 mol/L | **5,5507 mmol/L** |
| 2 | 5,5 mmol/L → mg/dL | 5,5 × 180,156 = 990,86 mg/L = 99,086 mg/dL | **99,09 mg/dL** |
| 3 | 126 mg/dL → mmol/L | 1 260 ÷ 180,156 = 6,9939 | **6,994 mmol/L** |

Ces valeurs sont aussi dans les tests (`extended_units_and_analytes_test.dart`). Avec une masse molaire de 180,16 (valeur externe arrondie), le cas 1 donne 5,5506 : écart relatif 2 × 10⁻⁵, tolérance retenue 10⁻³.

**À faire par le validateur** : refaire au moins 2 de ces cas lui-même : À COMPLÉTER.

### 4. Points à relire

1. La **masse molaire 180,156** est-elle celle que vous utilisez pour le glucose (glucose anhydre, non monohydraté 198,17 g/mol) ?
2. Les **unités** proposées sont-elles celles rencontrées au laboratoire ?
3. Le facteur arrondi 0,0555 des **calculateurs** (HOMA-IR, TyG, etc.) : acceptable ou à remplacer par la valeur exacte (cela changerait les résultats des calculateurs : décision à part, avec approbation du golden master) ?

### 5. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formule brute ☐ masse molaire ☐ forme chimique ☐ unités ☐ conversions d'excrétion |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : `ValidationRecord(itemId: 'analyte:glucose', itemVersion: 1, …)` dans `validationRecords`.
