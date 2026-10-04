# Dossier de validation préparé — FV-PREP-009
## DFG CKD-EPI créatinine-cystatine C 2021 (`RENAL_CKD_EPI_CREATININE_CYSTATIN_C_2021_001`, version 2)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**) après consultation de la **source primaire**.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-009 (brouillon) → à numéroter à la signature |
| Élément | `RENAL_CKD_EPI_CREATININE_CYSTATIN_C_2021_001` (alias historique `ckd_epi_creatinine_cystatin_c_2021`) |
| Version de l'élément / de l'application | 2 / 1.17.1 |
| Fichier | `packages/biosigma_core/lib/src/calculators/renal/ckd_epi.dart` |

> **Correction de version (2026-10-04).** La version 1 contenait une erreur de coefficient α, trouvée lors de la préparation de ce dossier. Corrigée en **version 2** (publiée en application 1.17.1). L'historique figure dans la fiche de l'équation et dans les comptes rendus.

### 1. Ce qui est à valider

`DFG = 135 × min(Scr/κ ; 1)^α × max(Scr/κ ; 1)^−0,544 × min(Cys/0,8 ; 1)^−0,323 × max(Cys/0,8 ; 1)^−0,778 × 0,9961^Âge × 0,963 [si femme]` ; κ = 0,7 (F) / 0,9 (H) ; **α = −0,219 (F) / −0,144 (H)** ; Scr en mg/dL, Cys en mg/L.

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : Inker LA, Eneanya ND, Coresh J, et al. *N Engl J Med.* 2021;385(19):1737-1749. | **À consulter par le validateur** — date : À COMPLÉTER |
| Secondaire consultée par l'auteur le 2026-10-04 : page NKF « CKD-EPI Creatinine-Cystatin Equation (2021) » (version « professionals ») | Constantes lues : 135 ; κ 0,7/0,9 ; α −0,219/−0,144 ; −0,544 ; −0,323 ; −0,778 ; 0,9961 ; 0,963. **Conformes à la version 2 du code.** |

### 3. Cas de vérification indépendants (calculés hors du code testé)

Calculés en Python à partir de la formule ci-dessus ; tous égaux à la valeur du code (version 2) à 10⁻¹² près (`ckd_epi_independent_test.dart`).

| # | Scr (mg/dL) | Cys (mg/L) | Âge | Sexe | DFG attendu (v. 2) | Valeur de la version 1 (erronée) | Écart |
|---|---|---|---|---|---|---|---|
| 1 | 0,6 | 0,9 | 60 | F | 97,05 | 97,38 | +0,3 % |
| 2 | 0,8 | 0,9 | 60 | H | 99,10 | 100,96 | +1,9 % |
| 3 | 0,5 | 0,7 | 40 | H | 131,20 | 143,97 | **+9,7 %** |
| 4 | 0,5 | 0,6 | 30 | F | 136,59 | 137,60 | +0,7 % |
| 5 | 1,4 | 1,2 | 70 | H | 58,91 | 58,91 | 0 (Scr ≥ κ) |
| 6 | 1,0 | 1,0 | 55 | F | 72,60 | idem | 0 (Scr ≥ κ) |
| 7 | 0,9 | 0,8 | 45 | H | 113,23 | idem | 0 (frontière) |
| 8 | 0,7 | 0,8 | 45 | F | 109,04 | idem | 0 (frontière) |

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même, indépendamment de cette préparation : À COMPLÉTER.

### 4. Points à relire en particulier

1. **Les α** : la version 1 reprenait par erreur les α de l'équation à la créatinine seule (−0,241/−0,302). À confirmer contre le *Tableau* de l'article primaire.
2. **Impact sur les anciens résultats** : surestimation du DFG, jusqu'à ≈ 9,7 % dans l'exemple n° 3, **uniquement quand Scr < κ** (jeunes adultes, faible masse musculaire). Les historiques enregistrés en version 1 se rejouent désormais comme « différents ».
3. Les autres constantes (135, −0,544, −0,323, −0,778, 0,9961, 0,963) : conformes à la page NKF, à confirmer à la source primaire.

### 5. Tests du dépôt associés

`ckd_epi_independent_test.dart` (8 cas + régression + texte de l'équation) · `registry_and_rounding_test.dart` (version 2 et notes de version) · golden master (cas `#sex=1` mis à jour le 2026-10-04 après vérification du diff).

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formule ☐ constantes ☐ unités d'entrée/sortie ☐ domaine/population ☐ cas interdits ☐ limites ☐ texte d'interprétation |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `RENAL_CKD_EPI_CREATININE_CYSTATIN_C_2021_001` du registre de validation (`registre-validation.csv`, version 2) puis importer (gouvernance §12).
