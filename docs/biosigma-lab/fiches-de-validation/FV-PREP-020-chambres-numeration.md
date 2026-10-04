# Dossier de validation préparé — FV-PREP-020
## Chambres de numération : Malassez et Neubauer améliorée (`LAB_LAB_COUNT_CONCENTRATION_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** La géométrie de Neubauer améliorée vient du manuel de l'OMS fourni par le validateur ; celle de **Malassez vient de sources web lues par l'assistant** (le validateur ne l'a pas saisie) : elle est à confronter à la fiche de la chambre du laboratoire.

| Champ | Contenu |
|---|---|
| Élément | `LAB_LAB_COUNT_CONCENTRATION_001` (alias `lab_count_concentration`), version 1 |
| Version de l'application | 1.24.0 |
| Fichiers | `packages/biosigma_core/lib/src/lab/count.dart` (`countingChambers`, `calculateChamberCount`) ; écran Count, mode Chambre |

### 1. Ce qui est à valider

Concentration = nombre compté × dilution / volume compté ; volume compté = (unités comptées × surface d'une unité) × profondeur (1 mm³ = 1 µL).

| Chambre | Profondeur | Unités de comptage | Source |
|---|---|---|---|
| **Neubauer améliorée** | 0,1 mm | grille de 1 mm × 1 mm (100 nL), 9 par chambre ; grand carré = 1/25 de la grille centrale (25) | Manuel de l'OMS 6e éd., § 2.4.8.2 et figure 2.5 (page imprimée 29–30) |
| **Malassez** | 0,2 mm | rectangle de 0,20 × 0,25 mm (0,05 mm²), 100 par chambre ; quadrillage entier 2,5 × 2 mm = 5 mm² = 1 µL | Wikipédia « Cellule de Malassez » ; Bioltrop (« quadrillage total : 1 µl, L 2,5 mm, l 2 mm, H 0,20 mm, 100 rectangles d'égales surfaces ») ; Humeau (100 rectangles de 0,20 × 0,25 mm) ; Dutscher (profondeur 0,2 mm, grille 5 mm²) — consultés le 2026-10-04 |

### 2. Contrôles faits par programme (pas une validation)

- **Malassez** : 100 × 0,20 × 0,25 mm = 5 mm² ; × 0,2 mm = 1 mm³ = **1 µL** ; **0,01 µL par rectangle** (Wikipédia) ; 10 rectangles = 0,1 µL : multiplier par **10 000** pour obtenir par mL (Wikipédia) : 120 cellules → 1,2 × 10⁶/mL (test).
- **Neubauer améliorée** : une grille = 1 mm² × 0,1 mm = **100 nL** (OMS) ; 25 grands carrés = 1 grille.
- Les deux chambres donnent le même résultat que le mode « Personnalisée » pour la même surface et la même profondeur (test).

### 3. Points à décider ou à relire

1. **Malassez** : les valeurs correspondent-elles à la fiche de **votre** chambre (certains fabricants proposent des variantes) ?
2. **Autres chambres** (Thoma, Bürker, Neubauer non améliorée, chambres jetables) : non proposées ; à fournir avec leur fiche si utiles. En attendant : « Personnalisée ».
3. **Grand carré de Neubauer** : défini comme 1/25 de la grille centrale (le manuel ne donne que « 25 grands carrés » dans la grille centrale de 1 mm²).
4. **Règles de comptage** (cellules à cheval sur les bords : lignes du bas et de gauche comptées, pas celles du haut et de droite — OMS, figure 2.6, pour les spermatozoïdes) : non appliquées par l'outil ; à décrire dans la procédure du laboratoire.

### 4. Tests associés

`test/lab/chambers_test.dart` (10 tests) · `test/screens/count_chamber_test.dart` (6 tests d'écran).

### 5. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ Neubauer améliorée ☐ Malassez ☐ formule ☐ libellés des unités ☐ mises en garde |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `LAB_LAB_COUNT_CONCENTRATION_001` du registre puis importer (gouvernance §12).
