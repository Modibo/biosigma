# Gouvernance de la validation scientifique (décision D-12, tâche P0-07)

> **Statut : cadre rédigé par l'assistant ; validateur scientifique désigné le 2026-10-04 (Dr Coulibaly) ; relecteur technique et approbateur à désigner.** Le cadre n'a de valeur que s'il est approuvé par le responsable scientifique. À ce jour, **aucune équation, aucun analyte, aucun facteur n'est « VALIDÉ »** (le code l'impose : voir « Ce que fait le logiciel »).

## 1. Pourquoi ce cadre

BioSigma affiche des calculs que des professionnels peuvent utiliser pour des décisions. Le code a été écrit par un assistant d'intelligence artificielle ; les tests prouvent que le code **fait ce qu'il dit**, pas que **ce qu'il dit est juste**. La validation est l'acte humain qui comble cet écart. Sans elle, l'application doit continuer à afficher « NON VALIDÉ » (décision D-08 : usage possible avec bandeau).

## 2. Rôles (à pourvoir par des personnes nommées)

| Rôle | Responsabilité | Règle |
|---|---|---|
| **Auteur** | Écrit ou modifie une équation, une constante, une entrée d'analyte | L'assistant de développement ; **ne valide jamais son propre travail** |
| **Relecteur technique** | Vérifie le code et les tests (D-01) | Humain, compétent en développement ; indépendant de l'auteur |
| **Validateur scientifique** | Biologiste médical / biochimiste : confronte l'élément aux sources et à la pratique du laboratoire, signe la fiche | **Nom, fonction et date sur chaque fiche** |
| **Approbateur** | Autorise le statut « VALIDÉ » en production (responsable qualité ou directeur du laboratoire) | Peut être la même personne que le validateur dans un petit laboratoire, à condition de le consigner |

**Désignations (2026-10-04)** :

| Rôle | Personne |
|---|---|
| Auteur | Assistant de développement (IA) — ne valide jamais |
| **Validateur scientifique** | **Dr Modibo Mouctar Coulibaly** (PharmD, CLMS, PhD, Maître de Recherche, Hôpital Sominé Dolo, Mopti) — désigné par lui-même |
| **Relecteur technique** | **Dr Modibo Mouctar Coulibaly** (désigné par lui-même) |
| **Approbateur** | **Dr Modibo Mouctar Coulibaly** (désigné par lui-même) |

**Cumul des trois rôles par une seule personne — consigné.** La séparation auteur / validateur est respectée (l'auteur est l'assistant, les trois rôles sont tenus par un humain). Ce cumul est admis ici car le laboratoire est de petite taille (§2), mais il a une conséquence à connaître : **il n'existe alors aucun regard humain indépendant** entre l'élément et son approbation. Pour les éléments à fort impact clinique, la gouvernance recommande un **second regard** (collègue ou relecteur externe) ; il reste facultatif et peut être ajouté plus tard sans rien changer au reste. Chaque fiche enregistre les trois noms ; le logiciel indique quand ils sont identiques (`rolesCumulated`).

## 3. Ce qui se valide, et à quelle granularité

La validation porte sur **un élément à une version précise** :

- une **équation** (formule, unités d'entrée et de sortie, domaine de validité, population, cas interdits) ;
- une **entrée de la base d'analytes** (formule brute, forme chimique, valence, unités) ;
- un **facteur ou une définition d'unité** non triviale ;
- un **texte d'interprétation** (seuil et formulation) — aujourd'hui noyé dans les messages ; non validable séparément (limite connue).

Toute modification (formule, constante, unité, domaine, forme chimique) crée une **nouvelle version** : l'ancienne fiche ne couvre pas la nouvelle.

## 4. Statuts et transitions

`NON VALIDÉ (existant)` → `PROPOSÉ` → `VALIDÉ` → `RETIRÉ` ; et `BLOQUÉ` (source insuffisante).

- **NON VALIDÉ** : présent, testé, jamais relu par un validateur. **État de tout le catalogue aujourd'hui.**
- **VALIDÉ** : fiche complète et signée **pour la version courante** (voir §5).
- **RETIRÉ** : fiche rejetée, ou élément remplacé ; reste consultable, avec avertissement.
- **BLOQUÉ** : on ne dispose pas d'une source suffisante (ex. masse molaire d'une protéine) ; l'élément n'est pas utilisable pour la partie concernée.

## 5. Critères pour passer à « VALIDÉ » (tous obligatoires)

1. **Source consultée** : le validateur a lu la source primaire (pas un résumé), et la cite (référence complète).
2. **Au moins deux cas de vérification indépendants**, **calculés hors du code testé** (à la main, tableur, autre outil) ; leurs valeurs sont jointes à la fiche.
3. **Tests verts** : les tests du dépôt couvrent ces cas et passent.
4. **Limites documentées** : population, cas interdits, conditions analytiques, forme chimique.
5. **Fiche signée** (modèle ci-dessous), avec nom, fonction, date, périmètre, version de l'élément, référence de la fiche.
6. **Séparation** : l'auteur n'est pas le signataire.

## 6. Quand revalider

- à chaque nouvelle version de l'élément ;
- en cas de changement de méthode analytique, de réactif ou d'automate qui touche l'élément ;
- à une échéance fixée par le laboratoire (proposition : tous les 2 ans) ;
- à la publication d'une recommandation qui remplace la source citée.

## 7. Que se passe-t-il en cas d'erreur découverte ?

Nouvelle version corrigée + note ; les enregistrements d'historique concernés sont **signalés, jamais modifiés** (le rejeu les compare explicitement). L'élément fautif passe « RETIRÉ ».

## 8. Ce que fait le logiciel (déjà implémenté)

- Le statut affiché (« NON VALIDÉ », « VALIDÉ », « RETIRÉ ») est **calculé** à partir de la liste des fiches de validation (`validationRecords`, vide à ce jour). Aucun élément ne devient « VALIDÉ » par un simple changement de drapeau.
- Une fiche **incomplète** (validateur, rôle, relecteur technique, approbateur, périmètre, sources, référence manquants, ou moins de deux cas indépendants) est **ignorée**.
- Une fiche valable pour la version 1 **ne valide pas** la version 2.
- Une fiche **rejetée** marque l'élément « RETIRÉ ».
- Les tests `validation_test.dart` et `extended_units_and_analytes_test.dart` protègent ces règles.

Pour enregistrer une validation : ajouter une `ValidationRecord` à `validationRecords` (`packages/biosigma_core/lib/src/registry/validation.dart`), avec la référence de la fiche signée archivée ; relancer les tests ; publier une nouvelle version de l'application.

## 9. Modèle de fiche de validation

> À imprimer ou à copier. Une fiche par élément et par version. Conserver l'original signé.

| Champ | À renseigner |
|---|---|
| Référence de la fiche | FV-AAAA-NNN |
| Élément validé | Identifiant (`METAB_BMI_001` ou `analyte:glucose`) |
| Version de l'élément | (entier) |
| Version de l'application | |
| Périmètre validé | ☐ formule ☐ unités ☐ domaine/population ☐ cas interdits ☐ forme chimique ☐ valence ☐ constantes ☐ texte d'interprétation |
| Sources consultées | Citation complète ; **date de consultation** ; édition/version |
| Cas de vérification indépendants (≥ 2) | Entrées → résultat attendu (calculé hors du code) ; outil utilisé ; tolérance et sa justification |
| Tests du dépôt associés | Nom des tests |
| Limites et conditions | Population, cas interdits, conditions analytiques, forme chimique |
| Écarts constatés | (aucun / décrire) |
| **Décision** | ☐ approuvé ☐ à corriger ☐ rejeté |
| Validateur | Nom · fonction · date · signature |
| Relecteur technique | Nom · date |
| Approbateur | Nom · fonction · date · signature |

## 10. Par où commencer (proposition réaliste)

Valider **tout** d'un coup n'est pas réaliste. Ordre conseillé :

1. Les **calculs cliniques les plus utilisés** dans votre laboratoire (ex. DFG CKD-EPI, FIB-4, INR, TyG), un par un.
2. Les **conversions d'analytes les plus fréquentes** (glucose, créatinine, urée, calcium, cholestérol, bilirubine) à partir de `relecture-analytes.md`.
3. Les autres, par domaine, au fil de l'usage.

Entre-temps, les éléments non validés restent utilisables avec leur bandeau « NON VALIDÉ ».

## 11. Dossiers de validation préparés

Pour démarrer, deux dossiers prêts à être complétés et signés sont dans [`fiches-de-validation/`](fiches-de-validation/README.md) : DFG CKD-EPI créatinine 2021 (8 cas indépendants déjà calculés hors du code, constantes confrontées à la page de la NKF) et conversion du glucose. Le validateur y consulte la source primaire, refait au moins deux cas lui-même, puis tranche.

## 12. Valider en masse : le registre de validation (tableur)

Valider 261 éléments un par un par échange de messages n'est pas praticable ; ne **rien** vérifier et tout déclarer validé ne l'est pas non plus (ce serait une fausse trace, §5). Le registre de validation est le moyen intermédiaire : **vous remplissez un tableur, le logiciel n'enregistre que ce qui est complet**.

1. **Ouvrir** [`registre-validation.csv`](registre-validation.csv) dans un tableur (séparateur « ; », UTF-8). Une ligne par élément : 61 équations du catalogue, 14 outils Lab, 186 analytes. Les colonnes `validator`, `reviewer`, `approver` sont préremplies avec vos trois rôles ; `points_to_review` signale ce que l'assistant sait fragile (ex. références à reconfirmer pour APRI, Padua, HAS-BLED, CHA₂DS₂-VASc ; citations à compléter pour VGM/TCMH/CCMH, ANC/ALC, Quality, tampon) ; `prepared_dossier` pointe vers un dossier prêt si l'assistant en a préparé un.
2. **Pour chaque élément que vous avez réellement relu**, remplir : `date` (JJ/MM/AAAA), `scope` (ce qui est validé), `sources_reviewed` (sources consultées), `independent_cases` (**au moins 2**, refaits hors du code), `sheet_ref` (référence de la fiche signée ; une même fiche de lot peut couvrir plusieurs lignes si elle les liste), puis `decision` = `approuvé` ou `rejeté`. **Laisser `decision` vide pour tout ce qui n'a pas été relu.**
3. **Importer** : `cd packages/biosigma_core && dart run tool/import_validations.dart ../../docs/biosigma-lab/registre-validation.csv`. L'outil liste chaque ligne refusée et sa raison (champ manquant, moins de 2 cas, date illisible, version ≠ version courante, identifiant inconnu, doublon). Sans `--partial`, **rien n'est écrit** s'il reste un problème ; avec `--partial`, seules les lignes complètes sont écrites.
4. **Publier** : relancer les tests, relever la version, déployer. Les éléments importés s'affichent alors « VALIDÉ » (fiche de référence, rapports imprimés, Convert).

**Ce que le logiciel refuse, par construction** : une ligne sans décision ne valide rien ; une ligne incomplète n'est jamais enregistrée même en partie ; une fiche ne couvre que sa version ; un élément ne peut apparaître qu'une fois. Le logiciel **ne peut pas vérifier** que vous avez réellement consulté les sources ni refait les cas : cette garantie repose sur votre signature, d'où l'importance de la fiche archivée.

**Ordre de relecture conseillé** : les équations les plus utilisées d'abord (DFG, FIB-4, INR, TyG, IMC), puis les conversions fréquentes (glucose, créatinine, urée, calcium, cholestérol, bilirubine), puis le reste par domaine. Les lignes marquées « référence à reconfirmer » ne devraient pas être validées avant lecture du texte source.

