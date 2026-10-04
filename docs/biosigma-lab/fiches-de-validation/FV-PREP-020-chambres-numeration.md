# Dossier de validation préparé — FV-PREP-020
## Chambres de numération (14 chambres) (`LAB_LAB_COUNT_CONCENTRATION_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** Les géométries viennent de **fiches de fabricants et de documents cités, lus par l'assistant le 2026-10-04** (le validateur ne les a pas saisies, sauf l'OMS qu'il a fournie). Elles sont à confronter à la fiche de la chambre du laboratoire.

| Champ | Contenu |
|---|---|
| Élément | `LAB_LAB_COUNT_CONCENTRATION_001` (alias `lab_count_concentration`), version 1 |
| Version de l'application | 1.25.0 |
| Fichiers | `packages/biosigma_core/lib/src/lab/count.dart` (`countingChambers`, `calculateChamberCount`) ; écran Count, mode Chambre |

### 1. Ce qui est à valider

Concentration = nombre compté × dilution / volume compté ; volume compté = (unités comptées × surface d'une unité) × profondeur (1 mm³ = 1 µL).

| Chambre | Profondeur | Unités de comptage (surface, nombre max) | Usage cité |
|---|---|---|---|
| **Neubauer améliorée** | 0,1 mm | grille 1 mm² (9) · grand carré 0,04 mm² (25) · petit carré 0,0025 mm² (400) | sang ; sperme (OMS) |
| **Neubauer** | 0,1 mm | grand carré 1 mm² (9) · groupe 0,04 mm² (16) · petit carré 0,0025 mm² (256) | sang |
| **Bürker** | 0,1 mm | grand carré 1 mm² (9) · petit carré 0,04 mm² (144) | sang |
| **Bürker-Türk** | 0,1 mm | grand carré 1 mm² (9) · petit 0,04 mm² (144) · plus petit 0,0025 mm² (256) | sang |
| **Thoma** | 0,1 mm | grille 1 mm² (1) · groupe 0,04 mm² (25) · petit carré 0,0025 mm² (400) | sang |
| **Thoma nouvelle** | 0,1 mm | groupe 0,04 mm² (16) | sang |
| **Fuchs-Rosenthal** | 0,2 mm | grand carré 1 mm² (16 ; 3,2 µL au total) · petit carré 0,0625 mm² (256) | liquide cérébro-spinal |
| **Nageotte** | 0,5 mm | bande 0,25 × 10 mm = 2,5 mm² (40 ; 1,25 µL chacune, 50 µL au total) | LCR, faibles concentrations de leucocytes |
| **Malassez** | 0,2 mm | rectangle 0,05 mm² (100) · quadrillage 5 mm² (1 µL) · petit carré 0,0025 mm² (2000) | sang, LCR |
| **Makler (sperme)** | 0,01 mm | bande de 10 carrés 0,1 mm² (1) · carré 0,01 mm² (100) · quadrillage 1 mm² | sperme, sans dilution |
| **Petroff-Hausser** | 0,02 mm | grille 1 mm² (9) · groupe 0,04 mm² (25) · petit carré 0,0025 mm² (400) | bactéries, sperme |
| **Neubauer améliorée 0,01 mm / 0,02 mm** (Petroff, Marienfeld) | 0,01 / 0,02 mm | comme la Neubauer améliorée | profondeur spéciale |
| **Thoma (Helber)** | 0,02 mm | comme la Thoma | profondeur spéciale |

### 2. Sources (consultées le 2026-10-04, texte brut des pages)

- **Paul Marienfeld, « Counting grids »** (fiche technique, avec les tableaux « sqmm / cmm = µl ») : Neubauer améliorée, Neubauer, Bürker, Bürker-Türk, Fuchs-Rosenthal, Thoma, Thoma nouvelle, Nageotte, Malassez ; **« Counting chambers with special depth »** : profondeurs 0,01 et 0,02 mm.
- **Manuel de l'OMS, 6e éd.** (fourni par le validateur) : Neubauer améliorée (§ 2.4.8.2, figure 2.5).
- **Malassez** (recoupement) : Wikipédia « Cellule de Malassez », Bioltrop (« quadrillage total : 1 µl ; L 2,5 mm, l 2 mm, H 0,20 mm ; 100 rectangles d'égales surfaces »), Laboratoires Humeau, Dutscher.
- **Makler** : Graticules Optics (profondeur 10 µm, quadrillage de 1 mm avec zone centrale en carrés de 0,1 mm) et COLO.Science (« 10 µm depth, 1 mm² grid »).
- **Petroff-Hausser** : Hausser Scientific (via Microscope World) : profondeur 0,02 mm, ruling Neubauer amélioré de 9 mm², volume 0,02 mm³ au-dessus d'un mm².

### 3. Contrôles faits par programme (pas une validation)

- **Surface et volume de chaque unité** égaux aux colonnes imprimées par Marienfeld (« sqmm » et « µl »), pour la famille Neubauer/Bürker/Fuchs-Rosenthal.
- **Totaux** : 9 mm² = 0,9 µL (Neubauer, Bürker…) ; Fuchs-Rosenthal 16 mm² = 3,2 µL ; Nageotte 40 × 2,5 mm² = 100 mm², 1,25 µL par bande, 50 µL au total ; Malassez 100 rectangles = 5 mm² = 1 µL (0,01 µL par rectangle) ; Petroff 0,02 mm³ par mm² ; Makler : bande de 10 carrés = 0,001 µL → **150 spermatozoïdes = 150 × 10⁶/mL**, sans facteur (règle du fabricant retrouvée par le calcul).
- Même résultat que le mode « Personnalisée » pour la même surface et la même profondeur.

### 4. Points à décider ou à relire

1. **Chaque chambre** est-elle conforme à la fiche de **votre** chambre (fabricants et variantes) ?
2. **Valeurs dérivées par l'assistant, non imprimées** : Neubauer / Bürker-Türk : nombre maximal de petits carrés (256 = 16 × 16) ; Thoma : 400 petits carrés = 25 × 16 ; Malassez : 2000 petits carrés = 100 × 20 ; Bürker : 144 petits carrés = 9 × 16 ; Fuchs-Rosenthal : 256 petits carrés = 16 × 16. Ces maxima servent seulement à refuser une saisie impossible.
3. **Thoma nouvelle** : seule l'unité « carré de groupe » est proposée (la fiche n'indique pas la taille des petits carrés).
4. **Non proposées** : **McMaster** (œufs de parasites), **Sedgewick-Rafter** (plancton), **Howard** (moisissures) : usages hors dénombrement cellulaire médical, et fiches non vérifiées en texte brut ; **Neubauer de profondeur 0,1 mm « standard » pour sperme** : voir le mode Sperme (OMS). À ajouter si besoin avec leur fiche.
5. **Règles de comptage** (cellules à cheval sur les bords) : non appliquées par l'outil ; à décrire dans la procédure du laboratoire (OMS, figure 2.6, pour les spermatozoïdes).
6. **Makler** : le fabricant décrit une lamelle quadrillée sans dilution ; l'outil applique la dilution saisie (1 pour un sperme pur).

### 5. Tests associés

`test/lab/chambers_test.dart` (17 tests) · `test/screens/count_chamber_test.dart` (9 tests d'écran).

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ les 14 chambres ☐ formule ☐ libellés des unités ☐ valeurs dérivées ☐ mises en garde |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `LAB_LAB_COUNT_CONCENTRATION_001` du registre puis importer (gouvernance §12).
