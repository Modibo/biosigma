# Dossier de validation préparé — FV-PREP-016
## Propagation d'incertitude, mode Expert (`LAB_LAB_UNCERTAINTY_001`, version 1)

> **Préparé par l'auteur (assistant de développement). NON SIGNÉ : ce document ne valide rien.** À compléter par le validateur scientifique (**Dr Modibo Mouctar Coulibaly**). L'auteur ne peut pas valider son propre travail : la relecture et la signature restent votre acte.

| Champ | Contenu |
|---|---|
| Référence | FV-PREP-016 (brouillon) → à numéroter à la signature |
| Élément | `LAB_LAB_UNCERTAINTY_001` (alias historique `lab_uncertainty`) |
| Version de l'élément / de l'application | 1 / 1.19.1 |
| Fichiers | `packages/biosigma_core/lib/src/lab/uncertainty.dart` ; écran `app/biosigma/lib/screens/lab/uncertainty_screen.dart` |

### 1. Ce qui est à valider

- **Modèle linéaire** Y = Σ cᵢ·xᵢ : u_c²(y) = Σ cᵢ²·u²(xᵢ).
- **Modèle produit** Y = c·Πxᵢ^pᵢ : [u_c(y)/y]² = Σ [pᵢ·u(xᵢ)/xᵢ]² (implémenté sous la forme équivalente (y·pᵢ·u/xᵢ)² pour obtenir aussi les parts de variance).
- **Dilution** C2 = C1·V1/V2 : modèle produit d'exposants +1, +1, −1.
- **Incertitude élargie** U = k·u_c ; k saisi par l'utilisateur ; avertissement si k est hors de 2–3.
- **Aides** : type A u = s/√n ; type B rectangulaire u = a/√3 ; u = U/k.
- **Hypothèses affichées** : premier ordre, grandeurs non corrélées, aucune covariance, aucun degré de liberté, pas de Welch-Satterthwaite.
- **Cas refusés** : liste vide ; k ≤ 0 ; incertitude négative ; en modèle produit, valeur nulle, ou valeur négative avec exposant non entier.

### 2. Sources

| Source | Statut |
|---|---|
| **Primaire** : JCGM 100:2008, *Evaluation of measurement data — Guide to the expression of uncertainty in measurement* (GUM) | Texte du guide **lu par l'auteur le 2026-10-04** (le PDF du BIPM) : § 5.1.2 éq. (10) ; § 5.1.6 éq. (12) ; § 4.2.3 éq. (5) ; § 4.3.7 éq. (6)-(7) ; § 6.2 ; § 6.3.1 (k de 2 à 3). **Cette lecture est celle de l'auteur, pas la vôtre** : À COMPLÉTER — date de votre propre lecture : ______ |

### 3. Cas de vérification indépendants (calculés hors du code testé)

Calculés en Python (`math`, `statistics`), pas avec le code Dart ; tous égaux à 10⁻¹² près (`uncertainty_test.dart`, 10 tests) ; recoupés par une propagation numérique générale (différences centrales).

| # | Modèle | Données (valeur ± u) | Résultat attendu |
|---|---|---|---|
| 1 | Linéaire x1 + x2 − x3 | 10 ± 0,1 ; 5 ± 0,2 ; 3 ± 0,05 | y = 12 ; u_c = 0,229129 |
| 2 | Dilution C1·V1/V2 | C1 100 ± 1 ; V1 10 ± 0,05 ; V2 100 ± 0,1 | y = 10 ; u_c = 0,112250 (1,12 %) ; U (k = 2) = 0,224499 ; parts de variance 79,4 % / 19,8 % / 0,8 % |
| 3 | Produit 3·x²·z^−0,5 | x 4 ± 0,2 (p = 2) ; z 9 ± 0,3 (p = −0,5) | y = 16 ; u_c = 1,622070 |
| 4 | Type A | 10,1 ; 10,2 ; 9,9 ; 10,0 | u = 0,0645497 |
| 5 | Type B rectangulaire | a = 0,5 | u = 0,288675 |

**À faire par le validateur** : refaire **au moins 2** de ces cas lui-même (tableur) : À COMPLÉTER.

### 4. Points à relire en particulier

1. Le **périmètre** (premier ordre, non corrélé) est-il acceptable pour l'usage de paillasse visé ? Décision D-18 prise par l'assistant (à confirmer).
2. **k = 2 prérempli** : commodité ; l'aide dit « souvent 2, ≈ 95 % pour une loi normale, à choisir ». Libellé acceptable ?
3. **Avertissement hors 2–3** : fidèle au § 6.3.1 (« en général dans l'intervalle 2 à 3 ») ?
4. **Modèle produit avec valeur négative et exposant entier** : accepté (le signe se propage) ; cohérent avec le GUM ?
5. Aucune valeur d'incertitude n'est embarquée (toutes saisies) : conforme à la règle du projet.
6. Défaut corrigé pendant le développement (traçabilité) : un coefficient négatif saisi était lu +1 ; remplacé par un choix explicite du signe.

### 5. Tests du dépôt associés

`test/lab/uncertainty_test.dart` (10) · `test/screens/uncertainty_screen_test.dart` (4) · accessibilité (`guidelines_test.dart`, thèmes clair et sombre).

### 6. Décision (À COMPLÉTER par le validateur)

| | |
|---|---|
| Périmètre validé | ☐ formules ☐ hypothèses affichées ☐ cas refusés ☐ aides type A/B ☐ avertissement sur k ☐ libellés |
| Écarts constatés | |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Dr Modibo Mouctar Coulibaly · fonction : ______ · date : ______ · signature : ______ |
| Relecteur technique | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ |
| Approbateur | Dr Modibo Mouctar Coulibaly · date : ______ · signature : ______ (cumul des trois rôles consigné) |

**Après signature** : renseigner la ligne `LAB_LAB_UNCERTAINTY_001` du registre (`registre-validation.csv`, version 1) puis importer (gouvernance §12).
