# Dossier de validation préparé — FV-PREP-004
## INR (International Normalized Ratio) (`HEMO_INR_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**) après consultation de la **source primaire**.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-004 (brouillon) → à numéroter à la signature |
| Élément | `HEMO_INR_001` (alias historique `inr`) |
| Version de l'élément / de l'application | 1 / 1.17.0 |
| Fichier | `packages/biosigma_core/lib/src/calculators/hemostasis/inr.dart` |

### 1. Ce qui est à valider

`INR = (TP patient / TP moyen normal du laboratoire) ^ ISI` ; temps en secondes, ISI sans unité (propre au couple réactif/automate). Résultat sans unité (2 décimales). Texte affiché : valeur de référence hors traitement ≈ 0,8–1,2 ; cible sous antivitamine K « généralement 2,0 à 3,0 » ; « 2,5 à 3,5 » pour certaines valves mécaniques à haut risque.

Cas interdits codés : TP patient, TP normal et ISI ≤ 0.

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : Kirkwood TB. Thromb Haemost. 1983;49:238-244 ; recommandations OMS sur les thromboplastines ; January CT et al., Circulation 2019;140(2):e125-e151 (cible 2,0–3,0 en fibrillation atriale). | **À consulter par le validateur** — date : À COMPLÉTER |
| Secondaire consultée par l'auteur le 2026-10-04 : page « Prothrombin time » de Wikipédia (anglais) : « INR = (PT test / PT normal)^ISI » | **Formule identique** à celle du code. |

### 3. Cas de vérification indépendants (calculés hors du code testé)

Calculés en Python à partir de la formule ci-dessus (pas avec le code Dart) ; **tous égaux à la valeur du code à 10⁻¹² près** (`independent_priority_test.dart`).

| # | TP patient (s) | TP normal (s) | ISI | INR attendu |
|---|---|---|---|---|
| 1 | 28 | 12 | 1,2 | 2,7642 |
| 2 | 15 | 12 | 1,0 | 1,2500 |
| 3 | 40 | 13 | 1,5 | 5,3973 |
| 4 | 12 | 12 | 1,1 | 1,0000 |
| 5 | 18 | 11,5 | 0,95 | 1,5305 |

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même (calculatrice, tableur, outil en ligne), indépendamment de cette préparation : À COMPLÉTER.

### 4. Points à relire en particulier

1. **TP moyen normal** : la formule officielle utilise le **TP moyen normal géométrique** (MNPT) du laboratoire ; l'outil demande « TP moyen normal du laboratoire » sans préciser « géométrique » dans le libellé — à relire.
2. **ISI** : fourni par l'utilisateur ; aucun contrôle de plausibilité (ex. ISI très éloigné de 1). Acceptable ?
3. **Texte d'interprétation** : plages 0,8–1,2, 2,0–3,0 et 2,5–3,5 (valves mécaniques) : sources à confirmer (la seule citée nommément est l'AHA/ACC/HRS 2019 pour la fibrillation atriale ; les 2,5–3,5 ne sont rattachés à aucune source précise).
4. **Limites** : aucune recommandation de dose (bien affiché).

### 5. Tests du dépôt associés

`inr_test.dart` · `independent_priority_test.dart` (5 cas) · golden master (`inr`).

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formule ☐ constantes ☐ unités d'entrée/sortie ☐ domaine/population ☐ cas interdits ☐ limites ☐ texte d'interprétation |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `HEMO_INR_001` du registre de validation (`registre-validation.csv`) puis importer (gouvernance §12).
