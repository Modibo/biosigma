# Dossier de validation préparé — FV-PREP-003
## Score FIB-4 (`IONO_FIB4_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**) après consultation de la **source primaire**.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-003 (brouillon) → à numéroter à la signature |
| Élément | `IONO_FIB4_001` (alias historique `fib4`) |
| Version de l'élément / de l'application | 1 / 1.17.0 |
| Fichier | `packages/biosigma_core/lib/src/calculators/ionogram/misc_biochemistry.dart` |

### 1. Ce qui est à valider

`FIB-4 = Âge × ASAT / (Plaquettes × √ALAT)` ; âge en années, ASAT et ALAT en U/L, plaquettes en ×10⁹/L. Résultat sans unité (2 décimales). Interprétation affichée : **< 1,30** faible probabilité de fibrose avancée ; **1,30 à 2,67** zone indéterminée ; **> 2,67** forte probabilité.

Population déclarée : adulte (développé chez des patients co-infectés VIH/VHC). Cas interdits codés : âge, plaquettes, ALAT ≤ 0 ; ASAT < 0.

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : Sterling RK, Lissen E, Clumeck N, et al. Hepatology. 2006;43(6):1317-1325. | **À consulter par le validateur** — date : À COMPLÉTER |
| Secondaire consultée par l'auteur le 2026-10-04 : page « FIB-4 calculator » de l'Université de Washington (hepatitisc.uw.edu) | **Formule identique** à celle du code. **Seuils différents** : cette source donne **1,45** et **3,25**, pas 1,30 et 2,67 (voir §4.1). |

### 3. Cas de vérification indépendants (calculés hors du code testé)

Calculés en Python à partir de la formule ci-dessus (pas avec le code Dart) ; **tous égaux à la valeur du code à 10⁻¹² près** (`independent_priority_test.dart`).

| # | Âge | ASAT | Plaquettes | ALAT | FIB-4 attendu |
|---|---|---|---|---|---|
| 1 | 50 | 40 | 200 | 35 | 1,6903 |
| 2 | 65 | 30 | 150 | 25 | 2,6000 |
| 3 | 35 | 25 | 250 | 20 | 0,7826 |
| 4 | 70 | 80 | 100 | 40 | 8,8544 |
| 5 | 45 | 60 | 180 | 80 | 1,6771 |

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même (calculatrice, tableur, outil en ligne), indépendamment de cette préparation : À COMPLÉTER.

### 4. Points à relire en particulier

1. **Seuils et attribution — constat de l'auteur, à trancher.** Le texte affiché reprend **1,30 / 2,67** et ajoute que ces seuils sont « dérivés de la cohorte de dérivation originale (Sterling et al. 2006) ». Or la source secondaire consultée donne pour l'étude de Sterling **1,45 / 3,25**. Les valeurs 1,30 / 2,67 sont couramment citées (la fiche cite EASL 2021), mais **leur attribution à Sterling semble inexacte** : à vérifier dans la source primaire et dans EASL 2021. **Décision à prendre** : (a) corriger l'attribution du texte, (b) changer de seuils, (c) afficher les deux jeux avec leur origine. Aucune modification n'a été faite (changerait un résultat existant ; golden master).
2. **Adaptation à l'âge** (seuil bas différent chez les ≥ 65 ans dans certaines recommandations) : non implémentée — à vérifier dans EASL 2021 et à décider.
3. **Frontières** : la valeur 1,30 exactement tombe en « indéterminée » ; 2,67 exactement aussi (conditions `< 1,30` puis `≤ 2,67`). Cohérent avec les libellés ?
4. **Population** : l'outil s'applique à tout adulte, alors que le score a été dérivé chez des co-infectés VIH/VHC.

### 5. Tests du dépôt associés

`misc_biochemistry_test.dart` (calculs, bornes) · `independent_priority_test.dart` (5 cas indépendants) · golden master (`fib4`).

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formule ☐ constantes ☐ unités d'entrée/sortie ☐ domaine/population ☐ cas interdits ☐ limites ☐ texte d'interprétation |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `IONO_FIB4_001` du registre de validation (`registre-validation.csv`) puis importer (gouvernance §12).
