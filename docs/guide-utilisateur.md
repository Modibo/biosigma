# Guide de l'utilisateur de BioSigma

BioSigma est une application de calculs de biochimie clinique, d'hémostase et de paillasse, à l'usage de **professionnels de laboratoire**. Elle fonctionne **hors connexion**, ne demande **aucune identité de patient** et n'envoie **aucune donnée**.

> **À lire d'abord.** BioSigma aide au calcul ; elle ne pose aucun diagnostic et ne remplace ni le jugement du biologiste ni les procédures de votre laboratoire. **Aucune équation n'est aujourd'hui « VALIDÉE »** par un biologiste responsable : chaque résultat porte la mention « NON VALIDÉ » tant que votre laboratoire n'a pas relu la formule et sa source (voir § 8).

## 1. Installer et ouvrir

- **Navigateur** : ouvrez l'adresse fournie par votre laboratoire (par exemple `https://biosigma.komodi-labo.org`). Au premier chargement, l'application se met en mémoire pour fonctionner ensuite **sans réseau**.
- **Écran d'accueil du téléphone** : dans le menu du navigateur, « Ajouter à l'écran d'accueil » (Safari : bouton Partager). L'application s'ouvre ensuite comme une application.
- **Mise à jour** : quand une nouvelle version existe, l'application le signale ; acceptez la mise à jour. Le numéro de version est dans l'onglet **À propos**.
- **Vérifier que tout fonctionne** : À propos → **Diagnostic de l'appareil** (hors connexion, stockage, impression). Le rapport peut être copié ; il ne contient aucune donnée personnelle.

## 2. Les six onglets

| Onglet | Rôle |
|---|---|
| **Calcul** | Les calculateurs cliniques (rénal, cardiométabolique, ionogramme/biochimie, hémostase, hématologie), avec recherche, favoris et recherche universelle. |
| **Lab** | Les outils de paillasse : Convert, Dilute, Prepare, Count, Microbiology, Quality, Incertitude, Smart Solver. |
| **Entraînement** | Quiz d'auto-évaluation et **exercices de calcul** (cas fictifs). |
| **Références** | Sources, formules et limites de chaque calcul. |
| **Réglages** | Séparateur décimal, historique local, pipettes, seuils locaux, suppression des données. |
| **À propos** | Version, diagnostic, avertissements. |

## 3. Faire un calcul clinique

1. Choisissez le calcul (liste, recherche ou favoris).
2. Saisissez les valeurs **avec leur unité** (liste déroulante à côté du champ). Les champs obligatoires sont signalés.
3. Appuyez sur **Calculer**.
4. Lisez le résultat, **les alertes** (bloquantes, de prudence ou d'information), puis la fiche : équation, version, source, population, **limites d'emploi**.

À savoir :
- **Séparateur décimal.** Par défaut la virgule (« 1,5 »). Une saisie ambiguë, par exemple « 1.5 » en mode virgule, est **refusée avec un message** plutôt que lue comme 15 : corrigez ou changez le réglage. Les espaces de milliers sont acceptés (« 1 000 »).
- **Interprétation.** Les repères d'interprétation (stades, seuils) sont des repères de la littérature, affichés à part, « à valider localement ». Les seuils propres à votre laboratoire se saisissent dans **Réglages → Seuils locaux**.
- **Résultat incomplet.** Si une donnée obligatoire manque, l'application l'indique au lieu de deviner.
- **Version de l'équation.** Quand une équation a été corrigée, un encadré « Historique des versions » le dit (par exemple le DFG CKD-EPI créatinine-cystatine C 2021, version 2).

## 4. Les outils Lab

### Convert : conversions d'unités
- **Saisie rapide** : tapez par exemple `88 umol/l en mg/dl` puis Entrée. L'application lit la valeur et les unités, remplit les listes et **affiche ce qu'elle a compris** (par exemple « mg/dl lu comme mg/dL, casse corrigée : à confirmer »). Une unité douteuse n'est **jamais devinée** : un message et des propositions s'affichent.
- **Mode Unités** : masse, concentration (mg/dL, mmol/L, mEq/L, mg%…), activité enzymatique, numération cellulaire, pression, température, fraction, osmolalité, excrétions par temps, DFG, longueurs. Pour passer d'une masse à des moles, **saisissez la masse molaire** (et la valence pour les équivalents).
- **Mode Analyte** : 186 analytes ; la masse molaire est calculée à partir de la formule brute. Chaque analyte porte le statut « NON VALIDÉ » jusqu'à relecture.

### Dilute : dilutions
Dilution simple (C1·V1 = C2·V2), en série, hors linéarité (avec l'intervalle de linéarité **que vous saisissez**), et **planificateur** qui propose une stratégie réalisable avec **vos pipettes** (à déclarer dans Réglages → Pipettes) et explique les stratégies écartées. Le calcul est théorique : exactitude réelle et volume mort réel ne sont pas modélisés.

### Prepare, Count, Microbiology, Quality
Ces modules **ne contiennent aucune valeur à source** : masse molaire, pureté, pKa, géométrie de la chambre, intervalle de colonies, erreur totale admissible (ETa) et facteur k sont **à saisir par vous**, et le résultat les rappelle. Aucune équivalence McFarland n'est proposée ; Quality ne rend aucun verdict.

### Incertitude (mode Expert)
Propagation d'incertitude selon le **GUM (JCGM 100:2008)**, au premier ordre, pour des grandeurs **non corrélées** : choisissez le modèle (dilution C2 = C1·V1/V2, produit/quotient, somme pondérée), saisissez valeurs et **incertitudes-types**, puis le **facteur d'élargissement k** (souvent 2, à choisir). Vous obtenez l'incertitude-type composée, l'incertitude élargie et la part de chaque grandeur. La rubrique « Évaluer une incertitude-type » aide à passer de répétitions (type A), de bornes (type B rectangulaire) ou d'une incertitude élargie à l'incertitude-type. Aucune incertitude n'est fournie par l'application.

### Smart Solver
Tapez votre besoin en une phrase : un module vous est **proposé, à confirmer**. Rien n'est calculé ni rempli à votre place.

## 5. Entraînement

- **Quiz** : séries de questions tirées d'une banque ; le meilleur score reste sur l'appareil.
- **Exercices de calcul** : cas **fictifs** générés au hasard (IMC, HOMA-IR, QUICKI, TyG, FIB-4, INR, DFG, trou anionique, conversion de la créatinine, dilution). Saisissez votre réponse arrondie au nombre de décimales demandé, vérifiez, puis ouvrez la **solution détaillée**. Chaque exercice rappelle le statut de l'équation (« NON VALIDÉ ») : c'est un entraînement, **jamais une référence pour un résultat patient**. Rien n'est enregistré.

## 6. Historique, impression et export

- **Historique local** : désactivé par défaut (Réglages). Activé, il garde le calcul, les entrées et le résultat (jamais d'identité), peut être **rejoué** (l'application indique si le résultat a changé depuis, par exemple après une correction d'équation) et effacé à tout moment.
- **Imprimer / exporter** : bouton sous chaque résultat. Une **confirmation** est obligatoire ; le rapport ne contient aucune identité de patient (seule une référence libre, par exemple un numéro d'échantillon anonyme, peut y figurer) et reprend équation, version, statut de validation, données, résultats, alertes, sources et limites.

## 7. Confidentialité et données locales

Aucune télémétrie, aucun envoi de données. Tout ce qui est enregistré (réglages, favoris, historique, seuils, pipettes, scores) reste **sur l'appareil**. Réglages → **Supprimer toutes les données locales** efface tout. Si des données stockées sont devenues illisibles, elles sont **mises de côté** (quarantaine) plutôt que perdues en silence.

## 8. Que veut dire « NON VALIDÉ » ?

Une équation est « VALIDÉE » quand un biologiste responsable a relu la formule, ses constantes et sa source primaire, a refait au moins deux cas, et a signé la fiche (voir `docs/biosigma-lab/gouvernance-validation.md`). **Aujourd'hui, aucune ne l'est.** Cela ne signifie pas qu'elles sont fausses : des cas de vérification indépendants existent pour une partie d'entre elles (voir `docs/rapport-de-tests.md`), mais l'acte de validation reste à faire par votre laboratoire. Utilisez les résultats comme une aide au calcul, et **confirmez** par vos procédures.

## 9. Que faire si…

| Situation | Que faire |
|---|---|
| Un nombre est refusé (« séparateur ambigu ») | Écrivez le nombre selon le séparateur choisi (virgule par défaut) ou changez le réglage. |
| Une unité n'est pas reconnue | Choisissez-la dans la liste, ou utilisez une des propositions affichées. |
| Un résultat semble faux | Vérifiez l'unité de chaque champ, relisez les **limites d'emploi** de la fiche, refaites le calcul par une autre voie ; signalez l'écart au responsable de l'application avec la version (À propos). |
| L'application ne se met pas à jour | Fermez-la complètement et rouvrez-la en ligne ; en dernier recours, supprimez les données du site dans le navigateur (cela efface aussi les données locales). |
| Le mode hors connexion ne fonctionne pas | À propos → Diagnostic de l'appareil, puis copiez le rapport pour le support. |

## 10. Signaler un problème

Indiquez : la **version** (À propos), l'appareil et le navigateur, le calcul concerné, les valeurs saisies **sans aucune donnée de patient**, et ce que vous attendiez. Le rapport du Diagnostic peut être joint.
