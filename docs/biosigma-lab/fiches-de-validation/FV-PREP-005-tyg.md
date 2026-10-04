# Dossier de validation préparé — FV-PREP-005
## Indice TyG (`METAB_TYG_INDEX_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**) après consultation de la **source primaire**.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-005 (brouillon) → à numéroter à la signature |
| Élément | `METAB_TYG_INDEX_001` (alias historique `tyg_index`) |
| Version de l'élément / de l'application | 1 / 1.17.0 |
| Fichier | `packages/biosigma_core/lib/src/calculators/metabolic/insulin_resistance.dart` |

### 1. Ce qui est à valider

`TyG = ln[(TG à jeun, mg/dL × glycémie à jeun, mg/dL) / 2]` (convention Simental-Mendía). Entrées acceptées en mg/dL ou mmol/L, **converties** par les facteurs arrondis du moteur (TG 0,0113 ; glucose 0,0555). Prélèvement à jeun exigé (case à cocher).

Cas interdits codés : valeurs ≤ 0 ; jeûne non confirmé.

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : Simental-Mendía LE, Rodríguez-Morán M, Guerrero-Romero F. Metab Syndr Relat Disord. 2008;6(4):299-304. | **À consulter par le validateur** — date : À COMPLÉTER |
| Secondaire : tentative de lecture du résumé PubMed (2026-10-04) | **Non aboutie** (page de consentement aux cookies) : la formule n'a **pas** été confrontée à une source externe cette session. |

### 3. Cas de vérification indépendants (calculés hors du code testé)

Calculés en Python à partir de la formule ci-dessus (pas avec le code Dart) ; **tous égaux à la valeur du code à 10⁻¹² près** (`independent_priority_test.dart`).

| # | TG (mg/dL) | Glycémie (mg/dL) | TyG attendu |
|---|---|---|---|
| 1 | 150 | 90 | 8,8173 |
| 2 | 200 | 110 | 9,3057 |
| 3 | 90 | 85 | 8,2493 |
| 4 | 300 | 150 | 10,0213 |

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même (calculatrice, tableur, outil en ligne), indépendamment de cette préparation : À COMPLÉTER.

### 4. Points à relire en particulier

1. **Cohérence du seuil cité — constat de l'auteur, à trancher.** Le texte affiché donne en exemple « **TyG > 4,5** évocateur d'une insulinorésistance ». Avec la convention implémentée (mg/dL), un sujet ordinaire a un TyG **de l'ordre de 8 à 10** (cas ci-dessus) : **tout résultat dépasserait 4,5**. Ce seuil correspond-il à une autre convention de notation ? Il risque d'être inapplicable ici. **Décision à prendre** : retirer ce seuil du texte, ou le remplacer par un seuil de la même convention avec sa source. Aucune modification n'a été faite.
2. **Conversion mmol/L → mg/dL par facteurs arrondis** : le TyG calculé avec des entrées en mmol/L diffère d'environ **0,0004** de celui obtenu avec les masses molaires exactes (TG −0,056 %, glucose +0,013 %). Acceptable ?
3. **Convention** : « / 2 » et logarithme népérien — à confirmer dans la source primaire.
4. **Seuils** : aucun seuil consensuel ; le texte le dit, mais cite quand même une valeur (point 1).

### 5. Tests du dépôt associés

`insulin_resistance_test.dart` · `independent_priority_test.dart` (4 cas, unités mg/dL) · golden master (`tyg_index`, variantes d'unités).

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formule ☐ constantes ☐ unités d'entrée/sortie ☐ domaine/population ☐ cas interdits ☐ limites ☐ texte d'interprétation |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `METAB_TYG_INDEX_001` du registre de validation (`registre-validation.csv`) puis importer (gouvernance §12).
