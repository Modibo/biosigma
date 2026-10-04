# Dossier de validation préparé — FV-PREP-017
## LDL-C de Martin-Hopkins dans le panel lipidique (`METAB_LDL_PANEL_001`, version 2)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** Le tableau de 180 facteurs a été **saisi par le validateur** (Dr Modibo Mouctar Coulibaly) dans la conversation du 2026-10-04 ; l'assistant l'a recopié par programme, sans retouche, et **ne l'a pas confronté à la publication**. Seule votre confrontation cellule par cellule à la source primaire fait foi.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-017 (brouillon) → à numéroter à la signature |
| Élément | `METAB_LDL_PANEL_001` (alias historique `ldl_panel`), **version 2** (ajout de Martin-Hopkins ; Friedewald et Sampson inchangées) |
| Version de l'application | 1.20.0 |
| Fichiers | `packages/biosigma_core/lib/src/calculators/metabolic/martin_hopkins.dart`, `martin_hopkins_table_data.dart`, `lipids.dart` |

### 1. Ce qui est à valider

`LDL-C = CT − HDL-C − TG / F` (mg/dL), F lu dans le tableau selon la strate de TG (30 lignes) et la strate de non-HDL-C = CT − HDL-C (6 colonnes). Strates à **borne inférieure incluse** ; la dernière s'étend vers le haut. Si TG < 7 mg/dL ou non-HDL-C < 0 : LDL non calculé (bloquant).

### 2. Le tableau tel que saisi (à confronter à la publication)

| TG (mg/dL) | non-HDL <100 | 100–129 | 130–159 | 160–189 | 190–219 | ≥220 |
|---:|---:|---:|---:|---:|---:|---:|
| 7–49 | 3,5 | 3,4 | 3,3 | 3,3 | 3,2 | 3,1 |
| 50–56 | 4,0 | 3,9 | 3,7 | 3,6 | 3,6 | 3,4 |
| 57–61 | 4,3 | 4,1 | 4,0 | 3,9 | 3,8 | 3,6 |
| 62–66 | 4,5 | 4,3 | 4,1 | 4,0 | 3,9 | 3,9 |
| 67–71 | 4,7 | 4,4 | 4,3 | 4,2 | 4,1 | 3,9 |
| 72–75 | 4,8 | 4,6 | 4,4 | 4,2 | 4,2 | 4,1 |
| 76–79 | 4,9 | 4,6 | 4,5 | 4,3 | 4,3 | 4,2 |
| 80–83 | 5,0 | 4,8 | 4,6 | 4,4 | 4,3 | 4,2 |
| 84–87 | 5,1 | 4,8 | 4,6 | 4,5 | 4,4 | 4,3 |
| 88–92 | 5,2 | 4,9 | 4,7 | 4,6 | 4,4 | 4,3 |
| 93–96 | 5,3 | 5,0 | 4,8 | 4,7 | 4,5 | 4,4 |
| 97–100 | 5,4 | 5,1 | 4,8 | 4,7 | 4,5 | 4,3 |
| 101–105 | 5,5 | 5,2 | 5,0 | 4,7 | 4,6 | 4,5 |
| 106–110 | 5,6 | 5,3 | 5,0 | 4,8 | 4,6 | 4,5 |
| 111–115 | 5,7 | 5,4 | 5,1 | 4,9 | 4,7 | 4,5 |
| 116–120 | 5,8 | 5,5 | 5,2 | 5,0 | 4,8 | 4,6 |
| 121–126 | 6,0 | 5,5 | 5,3 | 5,0 | 4,8 | 4,6 |
| 127–132 | 6,1 | 5,7 | 5,3 | 5,1 | 4,9 | 4,7 |
| 133–138 | 6,2 | 5,8 | 5,4 | 5,2 | 5,0 | 4,7 |
| 139–146 | 6,3 | 5,9 | 5,6 | 5,3 | 5,0 | 4,8 |
| 147–154 | 6,5 | 6,0 | 5,7 | 5,4 | 5,1 | 4,8 |
| 155–163 | 6,7 | 6,2 | 5,8 | 5,4 | 5,2 | 4,9 |
| 164–173 | 6,8 | 6,3 | 5,9 | 5,5 | 5,3 | 5,0 |
| 174–185 | 7,0 | 6,5 | 6,0 | 5,7 | 5,4 | 5,1 |
| 186–201 | 7,3 | 6,7 | 6,2 | 5,8 | 5,5 | 5,2 |
| 202–220 | 7,6 | 6,9 | 6,4 | 6,0 | 5,6 | 5,3 |
| 221–247 | 8,0 | 7,2 | 6,6 | 6,2 | 5,9 | 5,4 |
| 248–292 | 8,5 | 7,6 | 7,0 | 6,5 | 6,1 | 5,6 |
| 293–399 | 9,5 | 8,3 | 7,5 | 7,0 | 6,5 | 5,9 |
| ≥400* | 11,9 | 10,0 | 8,8 | 8,1 | 7,5 | 6,7 |

\* l'astérisque de la dernière ligne figure dans le tableau saisi ; sa signification n'est pas connue de l'assistant.

### 3. Contrôles faits par programme (pas une validation)

- 30 strates de TG **contiguës** (7–49, 50–56, … 293–399, ≥ 400) ; 6 colonnes ; **180 facteurs** ; somme des facteurs 949,4 (empreinte testée).
- **Aucun facteur n'augmente avec le non-HDL-C** dans une strate (les 30 lignes sont décroissantes de gauche à droite).
- **Un seul facteur diminue quand les TG augmentent** : colonne ≥ 220, **93–96 → 4,4 puis 97–100 → 4,3**. Peut être réel (médianes par strate) ou une faute de saisie : **à vérifier en priorité à la source**.
- Cas recalculés **hors du code Dart** (Python, à partir du tableau collé) : égaux à 10⁻⁹ près (`martin_hopkins_entered_table_test.dart`) :

| CT | HDL | TG | non-HDL | F | LDL (mg/dL) |
|---|---|---|---|---|---|
| 180 | 40 | 350 | 140 | 7,5 | 93,333 |
| 200 | 50 | 100 | 150 | 4,8 | 129,167 |
| 140 | 60 | 30 | 80 | 3,5 | 71,429 |
| 300 | 35 | 450 | 265 | 6,7 | 197,836 |
| 215 | 85 | 50 | 130 | 3,7 | 116,486 |
| 180 | 51 | 49 | 129 | 3,4 | 114,588 |
| 230 | 50 | 200 | 180 | 5,8 | 145,517 |

### 4. Points à décider ou à relire

1. **Confrontation cellule par cellule** du tableau à la publication (Martin SS, Blaha MJ, Elshazly MB, et al. *JAMA*. 2013;310(19):2061-2068) : À COMPLÉTER — date : ______.
2. **La cellule 93–96 / ≥ 220 (4,4) et 97–100 / ≥ 220 (4,3)** (voir §3).
3. **Astérisque de « ≥ 400* »** : que signifie-t-il ? L'application calcule avec cette ligne mais **avertit** que la signification est à confirmer. Faut-il plutôt **refuser** le calcul à partir de 400 mg/dL (comme Friedewald) ?
4. **TG non entiers** : les strates publiées sont des entiers (« 127–132 », « 133–138 »). Une valeur de 132,86 mg/dL (1,5 mmol/L) tombe, avec la règle « borne inférieure incluse », dans la strate 127–132. Faut-il **arrondir au mg/dL entier** avant la lecture (133 → strate suivante) ? Règle actuelle : pas d'arrondi.
5. **Tolérance de 10⁻⁶ mg/dL aux bornes** : introduite parce qu'un CT de 215 mg/dL revenait de la conversion en 214,99999999999997 et glissait dans la colonne voisine (défaut trouvé par un test). Sans effet biologique.
6. **Domaine** : l'équation n'a aucune limite haute de TG propre hormis l'avertissement ci-dessus.

### 5. Tests associés

`martin_hopkins_entered_table_test.dart` (structure, empreinte, 6 cas Python, bornes, TG ≥ 400, TG < 7, flottant à la borne) · `martin_hopkins_test.dart` (mécanique avec un tableau fictif) · golden master (`ldl_panel#formula=2` ajouté, aucun cas existant modifié).

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ tableau (180 cellules) ☐ strates et bornes ☐ formule ☐ domaine/TG ≥ 400 ☐ TG non entiers ☐ limites |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `METAB_LDL_PANEL_001` (version 2) du registre puis importer (gouvernance §12).
