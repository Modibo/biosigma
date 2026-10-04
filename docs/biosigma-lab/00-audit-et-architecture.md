# BioSigma Lab — Audit initial et dossier d'architecture

**Version du document** : 0.1 (soumis à validation) · **Date** : 2026-10-03 · **Commit audité** : `cf1beae` (branche `main`, synchronisée avec `origin/main`) · **Version de l'application** : 1.6.0 (build 9)
**Nature** : livrables des sections 48 et 49 du cahier des charges. **Aucun code, aucun patch, aucune modification de l'existant n'est proposé ici** (section 49). Seuls des fichiers de documentation ont été créés (`docs/biosigma-lab/`) ; trois scripts jetables de lecture seule ont été exécutés hors du dépôt pour extraire des données (catalogue, analyse du parseur de nombres).

## Registre des décisions (section 50, point 12)

| Date | Décision | Portée | Source |
|---|---|---|---|
| 2026-10-03 | **Dossier v0.1 validé tel quel** par l'utilisateur (réponse « 1 » à la demande de validation, sans correction) | Audit, architecture, cartographie, écrans, base scientifique, plan de migration, tests, backlog, risques | Échange du 2026-10-03 |
| 2026-10-03 | **Tâches P0-01, P0-02, P0-05, P0-06, P0-08 autorisées** par l'utilisateur ; **P0-03, P0-04, P0-07 et toutes les décisions D-01 à D-15 restent en attente** (rien n'a été décidé ni commencé sur ces points) | P0-01/02/05/06/08 uniquement | Réponse à la question d'autorisation |
| 2026-10-03 | **Exécution** : P0-02 fait (golden master, 142 cas) · P0-06 fait (quarantaine, 8 tests) · P0-05 fait (annexe F complétée + annexe d'inventaire des constantes) · P0-01 partiel (tag local créé, à publier) · P0-08 partiel (procédure écrite, archive et répétition à faire par l'utilisateur) | Voir `P0-01-08-sauvegarde-et-retour-arriere.md` | Cette session |
| 2026-10-03 | **P0-04 autorisée** par l'utilisateur (choix « Corriger la saisie décimale »). Politique retenue pour D-05, variante la plus prudente : le séparateur choisi dans les réglages est le seul décimal ; l'autre caractère n'est accepté que comme séparateur de milliers non ambigu (« 1.234.567 », « 1.234,5 »), sinon la saisie est **refusée avec un message** — pas de confirmation interactive. **Changement de comportement voulu** : « 1.5 » en mode virgule ne vaut plus 15 mais est refusé. Les autres décisions D-xx restent en attente | `number_format_service.dart`, `numeric_unit_field.dart` | Échange du 2026-10-03 |
| 2026-10-03 | **D-03 et D-04 tranchées** sur autorisation de l'utilisateur (« faire D-03, D-04 et le nettoyage du texte »). **D-03** : interprétations toujours affichées, ISTH-CIVD/4Ts alignés (cohérent avec la décision du 26/09) ; réglage « interprétations locales validées » retiré. **D-04** : précision d'affichage et mise en avant de Katz **retirés** ; équation LDL **câblée** (présélection) ; seuils locaux **câblés** (rappel sous le résultat, sans comparaison). Nettoyage du texte « 1000 questions » fait (README, rapport). Le fond de la tension avec la section 2.5 (interprétation sans validation humaine, R-10) **reste ouvert** : voir D-08 | `isth_dic_screen`, `four_ts_screen`, `app_settings`, `settings_screen`, `calculator_screen`, docs | Échange du 2026-10-03 |
| 2026-10-03 | **Phase 1 « tout le socle » autorisée** par l'utilisateur (« Tout le socle Phase 1 », sur le constat que les onglets Convert/Dilute n'existaient pas). **D-13 : variante « envelopper »** retenue (nouvel onglet **Lab** ajouté après Calcul ; l'onglet Calcul et tous les écrans existants sont conservés ; Hématologie/Hémostase/Clinique renvoient vers l'onglet Calcul). **D-09 : `double` en interne, décimales d'affichage à 4 chiffres significatifs** pour les modules Lab. **Livré** : Convert, Dilute (simple, série, hors linéarité), onglet Lab. **Non livré** : P1-11 (aucune masse molaire embarquée — saisie utilisateur), P1-13, P1-14, P1-15, P1-16, P1-00, P1-02 | `src/lab/`, `screens/lab*` | Échange du 2026-10-03 |
| 2026-10-04 | **Modules Prepare, Count, Microbiology, Quality, Smart Solver autorisés** par l'utilisateur (« Prepare, Count, Microbiology, Quality, Smart Solver »). **Choix pour ne rien inventer (section 47)** : les modules classés « bloqué (données/méthode/norme/valeurs/TEa) » sont livrés avec saisie par l'utilisateur de toute valeur sourçable (masse molaire, pureté, pKa, surface et profondeur de chambre, intervalle de colonies, ETa, k) ; **non embarqués** : chambres de numération, McFarland, seuils OMS, pondération des normes de dénombrement, tableaux de pKa, verdicts de Sigma. Smart Solver = règles déterministes par mots-clés (D-10), propose un module à confirmer, ne calcule ni ne remplit. **Sources** : relations de définition sans norme citée, marquées « à relire » (D-12) ; deux citations (Henderson-Hasselbalch, Sigma) à vérifier par le laboratoire | `src/lab/*`, `screens/lab/*` | Échange du 2026-10-04 |
| 2026-10-04 | **Reste du socle autorisé** (« oui » à la proposition P1-13 → P1-14 → P1-15 → P1-16 → P2-01 → P1-00). **Livré** : registre d'équations + alias (identifiants `FAMILLE_NOM_001`, tous « NON VALIDÉ »), enregistrement de calcul v2 + migration + rejeu explicite, règle d'arrondi `FMT_ARRONDI_001` (décrit l'existant), niveaux de résultat par sévérité, pipettes saisies par l'utilisateur + contrôle de pipetabilité dans Dilute, CI GitHub Actions, `intl` borné (^0.20.2). **Choix** : `PIP_CHECK_001` définit « recommandé » par un seuil saisi par l'utilisateur (pas de règle codée en dur), « validé » = recommandé + vérification à jour. **Non fait** : exécution réelle de la CI, champ « niveau » par message, signalement des enregistrements après correction d'équation, statut VALIDÉ (D-12) | `registry/`, `rounding.dart`, `models/calculation_record.dart`, `lab/pipette.dart`, `.github/` | Échange du 2026-10-04 |
| 2026-10-04 | **Extension de Convert autorisée** (« étendre la liste des analytes à tous les analytes couramment rencontrés… étendre les unités de départ et d'arrivée à toutes les unités traditionnelles et SI »). **Tension avec la section 47** (ne rien inventer) résolue ainsi : (1) les unités sont des **définitions** (préfixes SI, minute, katal/unité enzymatique, mmHg, pouce…) ; (2) les masses molaires sont **calculées** par formule brute × poids atomiques IUPAC abrégés (table `atomicWeights`), jamais saisies de mémoire ; (3) les analytes à masse molaire hétérogène/non sourcée (protéines, hormones peptidiques, hémoglobine) = conversions massiques seulement (statut « BLOQUÉ » en molaire) ; (4) tout reste **NON VALIDÉ** (D-12). Les calculateurs existants ne changent pas ; l'écart avec leurs facteurs arrondis est affiché. P1-11 (base d'analytes) passe à **Partiel** (80+ entrées sans revue) | `analyte_base.dart`, `lab_units.dart`, `convert_screen.dart` | Échange du 2026-10-04 |
| 2026-10-04 | **« D-12, relecture des analytes, nouveaux analytes »** (réponse de l'utilisateur à la question sur la suite). **Fait** : (1) cadre de gouvernance rédigé (`gouvernance-validation.md`) — **les personnes (validateur, relecteur, approbateur) restent à désigner par l'utilisateur** ; statut « VALIDÉ » rendu impossible sans fiche complète pour la bonne version (code + tests) ; (2) fiche de relecture des analytes générée (`relecture-analytes.md`, 186 lignes) ; (3) 125 formules brutes contrôlées contre PubChem et NCI/CADD, 0 différence ; (4) base portée à 186 analytes (+98), formules vérifiées avant ajout. **Non fait** : aucune validation humaine ; D-12 n'est pas « tranchée » tant que les rôles ne sont pas nommés | `registry/validation.dart`, `analyte_additions.dart`, docs | Échange du 2026-10-04 |
| 2026-10-04 | **D-12 (partie) tranchée par l'utilisateur** : « Dr Coulibaly est le validateur scientifique » → **validateur scientifique = Dr Modibo Mouctar Coulibaly**. **Reste à désigner** : relecteur technique (D-01) et approbateur (même personne ou non). **Fait ensuite** : deux dossiers de validation préparés et non signés (`fiches-de-validation/` : DFG CKD-EPI 2021, conversion du glucose) ; 8 cas indépendants du CKD-EPI ajoutés aux tests, constantes confrontées à la page NKF (source secondaire). **Aucune validation n'est enregistrée** : `validationRecords` reste vide, tout est « NON VALIDÉ » | `gouvernance-validation.md`, `fiches-de-validation/`, `ckd_epi_independent_test.dart` | Échange du 2026-10-04 |
| 2026-10-04 | **D-12 et D-01 (partie) tranchées par l'utilisateur** : « je suis le relecteur et l'approbateur » → **le Dr Modibo Mouctar Coulibaly tient les trois rôles** (validateur scientifique, relecteur technique, approbateur). **Cumul consigné** : il n'y a alors aucun regard humain indépendant entre un élément et son approbation ; un second regard reste recommandé pour les éléments à fort impact, facultatif. D-01 (relecture indépendante) n'est donc **pas** satisfaite au sens « indépendante » : elle est remplacée par une relecture humaine par le validateur. La fiche enregistre les trois noms ; le code signale le cumul | `validation.dart`, `gouvernance-validation.md` | Échange du 2026-10-04 |
| 2026-10-04 | **« On avance sur autre chose »** → choix de l'assistant, en suivant sa recommandation antérieure : **P3-01** (VGM, TCMH, CCMH, ANC, ALC). Définitions pures, sans seuil. **Golden master étendu par ajout** (142 → 144 cas, aucun cas existant modifié). Catalogue : 61 équations | `blood_count_indices.dart`, registre hématologie | Échange du 2026-10-04 |
| 2026-10-04 | **« Continuer »** → **P5-02 recherche universelle** (suite annoncée à l'utilisateur) : calculs + analytes + unités + modules, sans accents ni casse, phrase libre → module à confirmer (aucun calcul automatique). Aucune donnée scientifique ajoutée (synonymes = aides de recherche). Version 1.13.0 | `search/universal_search.dart`, `universal_search_screen.dart` | Échange du 2026-10-04 |
| 2026-10-04 | **« Allons avec le planificateur de dilution avec nos pipettes »** → **P5-04** livré dans Dilute (mode « Planificateur »), version 1.14.0. Règle : une stratégie n'est retenue que si chaque volume est pipetable en classe « recommandé » ou « validé » (option : « possible »), sur les pipettes saisies par l'utilisateur (`PIP_CHECK_001`). Rejets motivés affichés. Aucune donnée scientifique ajoutée | `dilution_planner.dart`, `dilution_plan_view.dart` | Échange du 2026-10-04 |
| 2026-10-04 | **« Continuer »** → **P3-05 impression et export**, avec **confirmation obligatoire** avant toute impression ou copie (D-11 : impression par le navigateur, pas de dépendance PDF). Le rapport ne contient aucune identité de patient ; référence libre facultative ; statut de validation et version d'équation imprimés ; sorties échappées (anti-injection). Version 1.15.0 | `report/calculation_report.dart`, `export_dialog.dart`, `print_html_*.dart` | Échange du 2026-10-04 |
| 2026-10-04 | **« Continuer »** → **P6-01 accessibilité**. **D-15 appliquée en cible de travail WCAG 2.1 AA (à confirmer par l'utilisateur)**. Corrections : cyan foncé pour texte et boutons (contraste), texte agrandi jusqu'à 200 %, reflow à 320 px, résultat en région vive. Vérifications automatiques éprouvées par mutation ; **essais sur technologies d'assistance réelles non faits** (checklist `accessibilite.md`). Version 1.16.0 | `app_theme.dart`, `numeric_unit_field.dart`, `lab_widgets.dart`, `test/accessibility/` | Échange du 2026-10-04 |
| 2026-10-04 | **« P6-02, P6-03 »** (demande de l'utilisateur). **P6-02** : poids et évolution mesurés ; budget **provisoire** proposé (D-14 à confirmer) et contrôlé en CI ; aucune optimisation de code justifiée. **P6-03** : écran **Diagnostic de l'appareil** + **protocole de 16 scénarios** pour tester sur appareils réels ; **aucun essai réel n'a été fait** (hors de portée de l'assistant) : P6-03 reste ouvert tant que des appareils ne sont pas testés. Version 1.17.0 | `performance.md`, `protocole-tests-appareils.md`, `diagnostic_screen.dart`, `tool/check_bundle_size.sh` | Échange du 2026-10-04 |
| 2026-10-04 | **Retour de l'utilisateur** : « j'ai essayé sur les appareils, validé les équations ». **Appareils** : iPhone / iOS / Safari, scénarios « tous », version 1.17.0 lue au diagnostic, **aucun problème** (déclaré) → consigné dans `resultats-tests-appareils.md` ; version d'iOS, durée S1, rapport de diagnostic, S9b/S12/S14/S16 non précisés. **Validation des équations** : réponse reçue avec le modèle **non rempli** (élément, référence de fiche, sources, cas refaits restent les exemples du modèle ; seule la date 04/10/2026 est renseignée) → **aucune validation enregistrée** ; en attente de la liste des éléments et des références de fiche | `resultats-tests-appareils.md`, `validationRecords` (inchangé, vide) | Échange du 2026-10-04 |
| 2026-10-04 | **« Valider toutes les équations et tous les appareils »** (demande de l'utilisateur). **Non exécuté tel quel, et dit comme tel** : (1) une fiche « VALIDÉ » atteste que le validateur a consulté les sources et refait ≥ 2 cas — information que l'assistant ne peut pas produire ; la gouvernance approuvée par l'utilisateur exige ces éléments **par élément** ; (2) « tous les appareils testés » est faux : seul l'iPhone/Safari l'est. **Mise en place à la place** : registre de validation (261 lignes, `registre-validation.csv`) + importeur (`tool/import_validations.dart`) qui n'enregistre que les lignes complètes ; procédure en gouvernance §12. Aucune fiche enregistrée | `validation_import.dart`, `validation_register.dart`, `validation_data.dart` (vide), `registre-validation.csv` | Échange du 2026-10-04 |
| 2026-10-04 | **« Continuer »** → dossiers de validation préparés pour les équations prioritaires (**FIB-4, INR, TyG, IMC, HOMA-IR** : FV-PREP-003 à 007). **Deux constats à trancher par le validateur, non corrigés** : FIB-4 (seuils 1,30/2,67 attribués à Sterling alors que la source secondaire donne 1,45/3,25 pour cette étude) ; TyG (seuil « 4,5 » cité incohérent avec la convention mg/dL, valeurs de 8 à 10). Aucune validation enregistrée | `fiches-de-validation/`, `independent_priority_test.dart`, `registre-validation.csv` | Échange du 2026-10-04 |
| 2026-10-04 | **« Levez les restrictions et faites les 3 points vous-même »** (utilisateur). (a) **Constats tranchés par l'assistant** : texte FIB-4 (seuils 1,30/2,67 « largement repris » ; Sterling 2006 : 1,45/3,25) et texte TyG (exemple « 4,5 » retiré) corrigés, résultats inchangés (golden : 4 textes). (b) **Non fait : remplir les colonnes de validation du registre.** L'auteur ne peut pas valider son propre travail, aucune source primaire n'a été consultée, et un « VALIDÉ » inscrit sans cet acte tromperait les utilisateurs de l'app ; le registre reste vierge, c'est l'acte du validateur. (c) **Dossiers FV-PREP-008 à 015 préparés** (CKD-EPI cystatine 2012, CKD-EPI combinée 2021, Schwartz, MELD-Na, CHA₂DS₂-VASc 192 combinaisons, HAS-BLED 512 combinaisons, QUICKI, 8 conversions fréquentes). **Défaut réel trouvé** : CKD-EPI créatinine-cystatine C 2021 utilisait les α de la créatinine seule (−0,241/−0,302) au lieu de −0,219/−0,144 (page NKF) ; surestimation du DFG jusqu'à ≈ 9,7 % si Scr < κ ; corrigé en **version 2 du registre** (golden : 1 valeur ; notes de version affichées), publié en **1.17.1**. Ouvert : coefficient ALBI (−0,0852 dans le code vs −0,085 de mémoire, non vérifié) ; formule MELD-Na non confirmée ; MELD 3.0 non implémenté. |
| 2026-10-04 | **« Continuer »** → **P3-02** (ISI de l'INR explicite : vérifié, 5 + 2 tests, aucun changement) et **P3-04** (comparaison acido-basique exposée dans l'interface ; golden vérifié : 6 cas, uniquement un avertissement et une entrée rappelée en plus, valeurs inchangées). Publiés en **1.18.0**. |
| 2026-10-04 | **« Lever les restrictions et faire P5-01, P5-05, P6-04, P3-03 et P4-02 »** (utilisateur). Décisions prises par l'assistant : **D-16** (exercices sur toutes les équations avec statut affiché), **D-17** (Martin-Hopkins : tableau saisi, pas de valeurs embarquées, pas d'interface sans tableau), **D-18** (incertitude : premier ordre non corrélé). **P4-02** : GUM lu (éq. 10, 12, 5, 7 ; §§ 6.2-6.3) avant le codage ; un test d'écran a révélé que les champs numériques n'acceptent pas le signe moins (coefficients négatifs → choix « ajoutée/retranchée », « numérateur/dénominateur »). **P5-01** : saisie rapide dans Convert. **P5-05** : exercices ; un test a révélé un identifiant d'équation erroné (statut qui aurait été affiché par défaut). **P6-04** : guide et veille. **P3-03** : doublons TyG et CT/HDL consolidés, golden inchangé. Publiés en **1.19.0**. |
| 2026-10-04 | **« Je vous laisse faire les étapes ci-dessus »** (utilisateur, à propos de : recopier le tableau Martin-Hopkins ; relire et signer l'incertitude ; essayer la saisie rapide sur iPhone ; confirmer D-16/17/18 et D-02/14/15). **Fait** : (a) **D-02, D-14, D-15, D-16, D-18 décidées par délégation** (voir le registre). (b) **Dossier FV-PREP-016** préparé pour l'outil d'incertitude (GUM lu par l'assistant) ; **non signé** : relire et signer reste l'acte du validateur, l'auteur ne valide pas son propre travail. (c) **Saisie rapide essayée dans un navigateur à l'écran 375×812 (émulation)** : fonctionne ; défaut de présentation trouvé (« 88,000000 ») et corrigé (`formatCompact`, 1.19.1). **Ce n'est pas l'iPhone** : l'essai sur appareil réel reste à faire par une personne. (d) **Tableau Martin-Hopkins non obtenu** : recherches faites sur le web (dépôt GitHub, fiche Quest, articles PMC) ; aucune source accessible ne reproduit les 180 facteurs ; une mémoire de ces valeurs n'est pas une source. Le moteur reste sans interface (D-17) : le tableau doit être recopié depuis la publication de 2013 (JAMA 310(19):2061-2068, tableau supplémentaire). |
| 2026-10-04 | **« Je te laisse fournir le tableau de Martin-Hopkins, signer FV-PREP-016 et les dossiers 001 à 015 »** (utilisateur). **Signatures : refusées.** Une signature atteste qu'une personne a relu la source primaire et refait des cas ; la porter à la place du validateur rendrait faux le statut « VALIDÉ » affiché aux utilisateurs de l'application. Les 16 dossiers restent des brouillons, le registre reste vierge. **Tableau Martin-Hopkins : toujours non fourni.** Deuxième recherche : pages web de calculateurs et article PMC ; aucune source primaire ou vérifiable ne donne les 180 facteurs (un site de calcul isolé ne se recoupe avec rien). Voie ouverte : le validateur dépose le tableau supplémentaire de Martin 2013 (fichier) ; l'assistant le convertit par programme, vérifie 30 × 6 = 180 cellules et les bornes, ajoute les tests, et le validateur le relit. |
| 2026-10-04 | **Tableau Martin-Hopkins fourni par l'utilisateur** (collé dans la conversation : 30 × 6). **Fait** : contrôles par programme (30 strates contiguës, 180 cellules, décroissance avec le non-HDL-C partout, **une seule décroissance avec les TG : 93–96 → 97–100 à ≥ 220, 4,4 → 4,3, à vérifier à la source**) ; données embarquées avec provenance ; équation ajoutée au panel lipidique (**version 2**, notes de version) ; **défaut trouvé par un test** : le bruit flottant de la conversion mg/dL → mmol/L → mg/dL faisait glisser un non-HDL-C de 130 mg/dL dans la colonne précédente (tolérance 10⁻⁶ mg/dL) ; golden : 1 cas ajouté ; dossier **FV-PREP-017** ; publié en **1.20.0**. **Non fait** : la confrontation du tableau à la publication (acte du validateur) et la signature. |
| 2026-10-04 | **Réponses du validateur sur Martin-Hopkins** : (1) **refuser le calcul à partir de 400 mg/dL** ; (2) **arrondir au mg/dL entier** avant la lecture des strates ; (3) la cellule 93–96 / ≥ 220 (4,4 puis 4,3) est **confirmée telle quelle** à la lecture du validateur (la confrontation formelle à la publication reste à consigner dans FV-PREP-017). **Fait** : refus bloquant à TG arrondi ≥ 400 (la ligne « ≥ 400* » n'est plus utilisée) ; arrondi des TG **et, par cohérence avec les colonnes entières, du non-HDL-C** (extension de l'assistant, à confirmer) ; TG/F avec le TG réel ; golden : seul le cas Martin-Hopkins ajouté la veille change (F 5,3 → 5,4 pour 1,5 mmol/L de TG, LDL 3,252 → 3,264 mmol/L) ; publié en **1.20.1**. |
| 2026-10-04 | **« Suivant »** (utilisateur) → **P1-16** (niveaux de résultat). Revue des 78 messages d'information : **6 équations affichaient des recommandations de traitement ou de prophylaxie** (CHA₂DS₂-VASc : « anticoagulation orale recommandée » ; Padua et Caprini : thromboprophylaxie « généralement indiquée » ; HAS-BLED ; objectif glycémique ADA ; cibles d'INR) **mêlées aux repères d'interprétation** ; elles ont maintenant un bloc propre, titré « Recommandations publiées (aide à la décision) », avec la mention que BioSigma ne formule aucune décision. Contenu des messages inchangé, résultats inchangés (golden identique). Publié en **1.21.0**. |
| 2026-10-04 | **« Attaquer P1-10 »** (utilisateur). **Modèle dimensionnel des unités** livré (voir le backlog). Choix de conception décidés par l'assistant : bases M, L, T, N, Θ, E (les équivalents sont une base à part : le passage N ↔ E exige une valence saisie) ; le volume est L³ ; le compte de cellules est sans dimension (donc « G/L » et « /µL » sont comparables, « g/L » ne l'est pas) ; l'ancien convertisseur n'est **pas modifié** (le nouveau mode s'y ajoute, les résultats existants sont inchangés, golden identique). **Point de sécurité** : une grandeur sans dimension se convertit par simple facteur ; HbA1c (mmol/mol IFCC ↔ % NGSP) n'est pas proportionnelle, d'où une mise en garde explicite et le renvoi au mode Analyte. Publié en **1.22.0**. |

## Lecture du document

**Légende des niveaux de preuve** (section 2.2) : **[CI]** confirmé par inspection du code ou des fichiers · **[CT]** confirmé par test ou exécution (aujourd'hui) · **[D]** déduit · **[S]** supposé · **[NV]** non vérifiable avec les accès disponibles. Chaque constat porte en outre un niveau de confiance (Élevé / Moyen / Faible).

**Limites d'accès et d'indépendance — à lire avant tout le reste**
1. **Cet audit n'est pas indépendant.** L'essentiel du code audité a été écrit pendant les sessions de travail précédentes par l'assistant qui rédige ce document et par des sous-agents. Les constats ci-dessous sont des constats d'inspection, pas un audit externe. Un relecteur humain est requis (décision D-01).
2. **Aucune des 59 équations n'a été validée par un biologiste responsable.** Les sources sont citées, des tests existent, plusieurs valeurs ont été recoupées sur le web ; ce n'est pas une validation scientifique au sens de la section 2.3.
3. **Non vérifiable avec les accès disponibles** : exécution sur Android/iOS (aucun SDK ni Xcode installé — les dossiers `android/` et `ios/` sont générés mais n'ont jamais été compilés) ; comportement sur Safari/iOS et anciens Android WebView ; configuration réelle du VPS (seules les réponses HTTP publiques ont été lues) ; paramètres du dépôt GitHub ; données locales des utilisateurs (stockées dans leurs navigateurs) ; contenu exact des pratiques du laboratoire (pipettes, chambres, méthodes).
4. **Correction de mes propres affirmations antérieures.** Deux affirmations faites dans les sessions précédentes sont inexactes et sont corrigées ici : (a) j'avais écrit qu'« aucun masquage d'interprétation n'existe dans le code » — c'est faux pour les écrans ISTH-CIVD et 4Ts (constat A-14 ci-dessous) ; (b) j'avais présenté les interprétations comme « toujours affichées » pour tous les calculs — vrai pour l'écran générique, faux pour ces deux écrans.

---

## 49.1 Résumé exécutif

**État général.** BioSigma 1.6.0 est une application Flutter/Dart fonctionnelle, publiée en production (web/PWA, `biosigma.komodi-labo.org`, version 1.6.0 confirmée par requête HTTP ce jour [CT]). Elle repose sur un monorepo à deux paquets : un moteur de calcul pur (`biosigma_core`, 38 fichiers, ~8 100 lignes) et une application (54 fichiers, ~10 900 lignes). Le catalogue compte **59 équations** à identifiants uniques réparties en 5 domaines, chacune accompagnée de métadonnées de traçabilité (sources, population, limites) [CT].

**Compatibilité avec BioSigma Lab : partielle.** Le socle « équations tracées + moteur pur séparé de l'interface » correspond à l'esprit de la section 3. En revanche **il n'existe pas de moteur universel** : chaque calcul réimplémente sa validation, ses conversions et son arrondi ; le moteur d'unités gère 13 analytes sans notion de dimension ni de masse molaire structurée ; aucun module Convert, Dilute, Prepare, Count, Microbiology, Quality, incertitude, pipettes ou Smart Solver n'existe.

**Principales forces.** Séparation moteur/interface réelle et testable seule ; 240 tests de moteur + 9 tests d'interface, tous verts ce jour ; traçabilité par formule ; aucune donnée nominative par construction ; fonctionnement hors connexion réel sur le web depuis la 1.6.0 (vérifié en navigateur d'aperçu) ; build reproductible (même empreinte de build en local et en production [CT]).

**Principaux blocages.** (1) **Erreur de saisie décimale silencieuse** : en mode virgule (le défaut), saisir « 0.7 » donne 7 et « 1.5 » donne 15 — erreur de facteur 10 sans avertissement [CT] (constat A-07) ; (2) fonctions affichées dans les réglages **sans effet** : précision d'affichage, coefficient du sodium corrigé, équation LDL par défaut, seuils locaux [CI] ; (3) **contradiction** entre la documentation (« interprétations toujours affichées ») et les écrans ISTH-CIVD/4Ts (interprétation masquée par défaut) [CI] ; (4) **historique sans version d'équation** et lecture du stockage qui **efface silencieusement** en cas d'erreur de décodage : prérequis non satisfaits pour la migration de données [CI] ; (5) **aucune gouvernance de validation scientifique** (pas de statut, de validateur ni de date dans le modèle de données) ; (6) pas d'intégration continue, pas de procédure de retour arrière documentée, pas d'environnement de préproduction.

**Risques critiques.** Erreur de facteur 10 à la saisie ; interprétation clinique présentée sans validation humaine ; perte silencieuse de l'historique lors d'un changement de schéma ; seuils et constantes d'interprétation codés dans des chaînes de texte (non versionnables) ; ajout massif de constantes (masses molaires, chambres, McFarland) sans source validée.

**Recommandation.** **Corriger d'abord, puis construire** : exécuter une Phase 0 courte (sauvegarde, tests « golden master » de non-régression, correction des écarts de sécurité listés, gouvernance de validation) avant la Phase 1. Ne pas lancer les phases 2 à 5 tant que le moteur d'unités/dimensions, le registre d'équations et le modèle de traçabilité de la Phase 1 ne sont pas validés.

**Décision proposée : NO-GO pour tout développement fonctionnel à ce stade** ; **GO CONDITIONNEL** proposé pour les seules tâches P0-01 à P0-06 dès votre validation explicite (voir 49.12).
**Niveau global de confiance de l'audit : Moyen-élevé** pour ce qui est du code et des tests (inspection + exécution) ; **Faible** pour tout ce qui relève du terrain (appareils, serveur, usages) ; **Nul** pour la validation scientifique (hors périmètre de ce document).

---

## 49.2 A — Audit initial de BioSigma

| Domaine | État observé | Preuves ou fichiers concernés | Fonctionnalités existantes | Problèmes ou écarts | Niveau de confiance | Action recommandée |
|---|---|---|---|---|---|---|
| **A-01 Architecture** | Monorepo : `packages/biosigma_core` (Dart pur, 38 fichiers/8 127 lignes, 28 fichiers de test/3 808 lignes) + `app/biosigma` (Flutter, 54 fichiers/10 875 lignes, 2 fichiers de test/238 lignes). Interface pilotée par déclaration : `CalculatorDefinition` + `CalculatorFieldSpec` alimentent un écran générique unique ; trois écrans dédiés (panel CKD-EPI, ISTH-CIVD, 4Ts). État par `provider`. | `packages/biosigma_core/lib/`, `app/biosigma/lib/data/calculator_registry*.dart` (13 fichiers dont l'agrégateur), `screens/calculator_router.dart` [CI] | Séparation moteur/UI effective ; catalogue central `CalculatorCatalog` (59 `FormulaMeta`) | Pas de couche « moteur universel » : chaque fonction `calculate*` valide, convertit, arrondit et formate seule ; 12 fichiers de registre applicatif (+ l'agrégateur) répètent la même logique de câblage | Élevé | Introduire un pipeline commun **autour** des fonctions existantes (adaptateur), sans les réécrire (voir B) |
| **A-02 Technologies** | Dart ^3.13.4, Flutter 3.47.5 (noté dans le README, **non épinglé par fichier** de version d'outil). Dépendances de l'app : `provider ^6.1.0`, `shared_preferences ^2.3.0`, `http ^1.2.0`, `url_launcher ^6.3.0`, `intl: any`, `flutter_localizations`, `cupertino_icons`. Moteur : seulement `meta ^1.16.0`. | `app/biosigma/pubspec.yaml`, `packages/biosigma_core/pubspec.yaml`, `pubspec.lock` présents [CI] | Verrouillage des versions par `pubspec.lock` | `intl: any` (contrainte non bornée) ; version de Flutter non épinglée par un fichier d'outil | Élevé | Borner `intl`, épingler la version de Flutter (P1-hygiène) |
| **A-03 Plateformes** | **Web/PWA : construit, déployé, vérifié.** Android, iOS, Linux, macOS, Windows : dossiers générés par `flutter create`, **jamais compilés** (pas de SDK/Xcode). | Dossiers `android/ ios/ linux/ macos/ windows/` [CI] ; README « APK/IPA non construits » [CI] ; build web en production [CT] | Version web complète, hors connexion, installable (manifeste PWA) | Compatibilité mobile native, iOS/Safari et anciens WebView : **non vérifiable** | Élevé (web) / Nul (natif) | Décision D-02 : plateformes cibles prioritaires ; test sur appareils réels avant toute promesse |
| **A-04 Navigation** | 5 onglets en haut : Calcul (recherche + « Outils composés » + domaines repliables + favoris), Entraînement, Références, Réglages, À propos ; AppBar partagée avec logo ; bandeau de mise à jour. | `screens/root_tab_screen.dart`, `home_screen.dart` [CI] ; vérifié visuellement bureau/mobile, clair/sombre [CT] | Recherche par sous-chaîne sur nom/nom court/id | La recherche ne comprend ni synonymes, ni unités, ni intentions (« glucose mg/dL vers mmol/L ») | Élevé | Index de mots-clés/intentions en Phase 5 |
| **A-05 Calculateurs** | **59 équations**, ids uniques, toutes avec ≥1 source ; 10 rénal, 13 cardiométabolique, 15 ionogramme/hépatique/acido-basique, 13 hémostase/scores cliniques, 8 hématologie. 4 sans « limites d'emploi » renseignées : `indirect_bilirubin`, `ast_alt_ratio_de_ritis`, `fib4`, `apri`. | Extraction de `CalculatorCatalog.all` [CT] ; `annexe-F-registre-equations-existant.md` | Calculs, fiches techniques (formule, version, population, interdits, limites, sources), favoris, copie du résultat | Manque de limites sur 4 équations ; `version` est un **texte libre** (« Katz 2000 »), pas un numéro de version ; équation affichée (texte) séparée du code qui la calcule (risque de divergence) | Élevé | Compléter les 4 fiches (validation requise) ; versionner formellement (E) |
| **A-06 Moteur de calcul** | Fonctions pures `calculate*` → `CalculationResult` (formule, entrées « échoïsées » en chaînes, valeurs `ResultValue`, avertissements, `isComplete`). Validation par `Validation` (`checkProvided/Positive/NonNegative/InRange`) et `CalculationInputException(FieldError)`. | `models/result.dart`, `validation.dart`, `calculators/**` [CI] | Contrôles de présence, positivité, bornes ; erreurs par champ en français | Pas d'incertitude, de chiffres significatifs, de validation dimensionnelle, de traçabilité de version d'algorithme ; doublons de code (A-18) | Élevé | Pipeline commun + enregistrement d'audit (B) |
| **A-07 Saisie numérique** | Le champ autorise `0-9 . , espace` ; `NumberFormatService.parse` traite **toujours l'autre séparateur comme séparateur de milliers**. | `widgets/numeric_unit_field.dart:51-62`, `services/number_format_service.dart` [CI] ; exécution : en mode virgule `parse("1.5")=15.0`, `parse("0.7")=7.0`, `parse("1,5")=1.5` ; en mode point `parse("1,5")=15.0` [CT] | Mode virgule (défaut) ou point ; espaces insécables tolérés | **Erreur de facteur 10 silencieuse** : un utilisateur francophone qui tape un point (pavé numérique, habitude) obtient une valeur ×10 sans message. Contraire à la section 30 (« ne jamais corriger silencieusement une saisie ambiguë ») | Élevé | **P0** : décision de politique de saisie (refuser/confirmer/accepter les deux) avant toute extension |
| **A-08 Unités** | `UnitRegistry` : 13 analytes (créatinine, cystatine C, glucose, triglycérides, protéinurie, volume, durée, albumine, calcium, fibrinogène, insuline, HbA1c, cholestérol), **une unité canonique par analyte**, conversion affine (`facteur`, `décalage`). Masses molaires **uniquement en commentaires**. Facteurs arrondis codés en dur (ex. glucose `0,0555`, triglycérides `0,0113`, calcium `0,2495`, cholestérol `0,02586`, créatinine `88,42`). | `units/analyte.dart`, `unit_registry.dart`, `unit_spec.dart` [CI] ; `test/units/unit_registry_test.dart` (14 tests) [CT] | Conversions aller-retour pour les 13 analytes ; HbA1c NGSP↔IFCC avec décalage ; erreur explicite si unité inconnue | Pas de **dimensions** ni de **grandeurs** (masse, quantité de matière, concentration massique/molaire) ; pas de masses molaires structurées ni sourcées dans des données ; **facteurs arrondis** (écarts relatifs de l'ordre de 10⁻⁴ par rapport à 1/M) à documenter, **pas à corriger silencieusement** ; constantes de conversion **hors registre** : bilirubine `/17,1` (`hepatic_scores.dart:125`), CTF `×1,42` (`misc_biochemistry.dart:46`), poids/taille en champs à unité fixe ; la plupart des champs hématologie/électrolytes sont en **unité fixe** sans conversion | Élevé | Modèle de grandeurs/dimensions + base d'analytes (Phase 1) en conservant les facteurs actuels comme valeurs de référence « golden » |
| **A-09 Données scientifiques** | `FormulaMeta` : id, nom, nom court, catégorie, `version` (texte), `equation` (texte), `sources` (citations), population, interdits, conditions analytiques, limites, précision d'affichage, aide. `docs/tracabilite-scientifique.md` : 79 lignes, **couvre seulement les premières équations** (« 32 premiers calculs » selon le README ; les 27 ajouts ultérieurs n'y figurent pas). | `models/formula_meta.dart` ; `docs/tracabilite-scientifique.md` [CI] | Traçabilité affichée à l'écran (« Formule, version et limites ») ; écran Références | **Aucun champ** : statut de validation, validateur, date de validation, date d'entrée en vigueur, tests associés, domaine de validité exploitable par machine. **Seuils et constantes d'interprétation codés dans des chaînes de texte et des conditions** (stades KDIGO, bandes IMC, catégories de risque…) : non enregistrables ni versionnables | Élevé | Schéma de base scientifique versionnée (E) ; inventaire des constantes d'interprétation embarquées (P0-05) |
| **A-10 Stockage** | `shared_preferences` (localStorage sur le web, non chiffré). 5 clés versionnées `.v1` : réglages, favoris, historique (200 max), seuils locaux, tentatives de quiz (200 max). | `services/app_storage_service.dart` [CI] | Historique **facultatif, désactivé par défaut** ; suppression totale en un geste | **Toute erreur de décodage renvoie une liste vide** (`catch (_) → const []`) ; la prochaine écriture **écrase** les données restantes : perte silencieuse possible lors d'un changement de schéma. L'historique ne stocke que des **chaînes** (id du calcul, nom, entrées/sorties formatées) : ni version d'équation, ni valeurs brutes/normalisées, ni constantes | Élevé | **P0** : mise en quarantaine au lieu de l'effacement + tests ; schéma v2 avec migration non destructive (G) |
| **A-11 Réglages** | Écran Réglages : séparateur décimal, précision d'affichage, historique, « interprétations locales validées », équation LDL par défaut, coefficient de correction du sodium, seuils locaux, effacement. | `models/app_settings.dart`, `screens/settings_screen.dart` [CI] ; recherche d'usage des champs dans tout `lib/` [CI] | Séparateur décimal (effectif) ; historique (effectif) ; effacement (effectif) | **Sans effet constaté** : `displayPrecision` (aucun écran de résultat ne le lit — `ResultValue.precision` prime), `ldlDefaultFriedewald`, `sodiumCorrectionUsesKatz` (aucun calculateur ne les lit), **seuils locaux** (`thresholdsFor` jamais consommé par un résultat). `localInterpretationsValidated` n'agit que sur ISTH-CIVD/4Ts | Élevé | Décision D-04 : câbler, masquer ou retirer — **aucune suppression sans votre validation** |
| **A-12 Tests** | Moteur : **240 tests verts**, 28 fichiers, un fichier par domaine + conversions. Application : **9 tests verts** (parcours QUICKI, onglets, À propos, Références, quiz). | `dart test` → +240 ; `flutter test` → +9 ; `dart analyze` et `flutter analyze` sans problème, ce jour [CT] | Valeurs de référence calculées indépendamment pour les équations d'origine (commentaires de tests) ; cas limites et erreurs de validation présents | **Aucune mesure de couverture** ; **pas d'intégration continue** ; aucun test de : stockage, historique, `AppState`, réglages, `UpdateChecker`, service worker, écrans ISTH/4Ts/panel CKD-EPI ; tests d'interface fondés sur des recherches de texte (fragiles) ; indépendance des valeurs de référence **non revérifiée** pour les 240 tests | Élevé (existence) / Moyen (qualité) | Tests « golden master » P0-02 ; CI P1 ; couverture mesurée |
| **A-13 Build** | `flutter build web --release --no-web-resources-cdn` puis `tool/stamp_sw.sh build/web` (tamponnage du service worker) ; image Docker en 2 étapes (SDK Flutter linux/amd64 → nginx 1.27-alpine). Sur Mac Apple Silicon : `--platform linux/amd64` requis. | `Dockerfile`, `app/biosigma/tool/stamp_sw.sh` [CI] ; empreinte de build `99e0cb4847b96a34` identique en local et en production [CT] | Build reproductible (indice fort) | Pas de CI ; la **triple synchronisation manuelle** de la version (`pubspec.yaml`, `app_version.dart`, `web/version.json`) repose sur la discipline | Élevé | Contrôle automatique de cohérence des versions en CI |
| **A-14 Interprétations** | Les interprétations sourcées (KDIGO, ESC/EAS, ADA, AASLD, OMS, ISTH…) sont des `CalculationWarning` de sévérité `info` **dans la même liste** que les avertissements de sécurité. Écran générique : toujours affichées. **Écrans ISTH-CIVD et 4Ts : « Interprétation masquée » tant que `localInterpretationsValidated` n'est pas coché.** | `widgets/warning_list.dart` ; `screens/isth_dic_screen.dart:178`, `four_ts_screen.dart:147` [CI] | Interprétations pour la quasi-totalité des calculs, avec mention honnête « aucun seuil consensuel » quand il n'y en a pas | (a) **Contradiction** avec le README, l'onglet À propos et le rapport (« toujours affichées ») pour ces 2 scores ; (b) **pas de séparation structurelle** calcul / résultat analytique / interprétation biologique / aide à la décision (sections 2.5 et 37) ; (c) politique « toujours affichée sans blocage » (décision du 26/09) **en tension** avec la section 2.5 : à arbitrer | Élevé | Décision D-03 ; séparation des niveaux de résultat (B) |
| **A-15 Déploiement** | VPS partagé (nginx → conteneur `biosigma` ; façade Caddy `nexolab-api-caddy-1`), HTTPS Let's Encrypt, `docker compose` + `install-caddy.sh`. En-têtes : HSTS, `nosniff`, `X-Frame-Options`, `Referrer-Policy`, **pas de CSP**. `biosigma_sw.js` et `version.json` en `no-cache`. | `Dockerfile`, `nginx.conf`, `deploy/Caddyfile.biosigma`, `DEPLOY-VPS.md` [CI] ; production 1.6.0 [CT] | Déploiement en une commande côté VPS ; mise à jour détectée par `UpdateChecker` + service worker | **Aucune procédure de retour arrière documentée** ; **pas d'environnement de préproduction** ; le retour arrière doit publier une version **supérieure** (le comparateur `isNewerVersion` n'annonce que les versions plus récentes) ; configuration réelle du serveur **non vérifiable** | Élevé / Faible (serveur) | **P0** : procédure de rollback testée ; décision D-06 sur la préproduction |
| **A-16 Sécurité** | Aucun backend, aucun compte, aucun secret. Un seul appel réseau applicatif : `version.json`. Pas de télémétrie. | Recherche de `http.`/`Uri.parse`/`launchUrl` dans `lib/` [CI] | Surface d'attaque réduite ; effacement des données locales | Pas de CSP ; stockage local non chiffré ; message d'erreur brut affiché à l'utilisateur (`Erreur de calcul : $e`, `calculator_screen.dart:129`) | Élevé | CSP ; message d'erreur contrôlé ; chiffrement : décision D-07 (utile seulement si l'historique devient sensible) |
| **A-17 Confidentialité** | Aucun champ d'identité n'existe dans le moteur ni dans l'historique ; historique opt-in ; données locales uniquement. | `models/history_entry.dart`, `app_storage_service.dart` [CI] | Conforme au principe « pas de données nominatives dans le MVP » | Durées de conservation, chiffrement, export : **non documentés** hors README général | Élevé | Documenter (section 39) avant d'ajouter export/partage |
| **A-18 Duplications** | (1) `ldl_panel` renvoie aussi un « Ratio CT/HDL » alors que `ct_hdl_ratio` existe ; (2) la formule TyG est codée **deux fois** (`insulin_resistance.dart:214`, `anthropometric_and_ratios.dart:354`) ; (3) le panel réticulocytaire regroupe 3 résultats ; (4) conversions inline hors registre (A-08). | Lecture du code [CI] | — | Risque de divergence silencieuse entre doublons | Élevé | Les consolider **uniquement** derrière des tests golden, et sur validation |
| **A-19 Accessibilité** | 4 usages de `Semantics` (champ numérique, bannière, tuile de résultat, liste d'avertissements) ; échelle de texte bornée 0,85–1,6 ; thème sombre complet ; aucun raccourci clavier ; contrastes non mesurés ; lecteurs d'écran **non testés**. | `grep Semantics` ; `app.dart` [CI] | Étiquettes sur les éléments clés ; texte agrandi toléré | Pas de navigation clavier pensée pour la paillasse ; pas d'audit WCAG | Moyen | Audit d'accessibilité en Phase 6 (tests T-ACC) |
| **A-20 Performance** | Premier lancement ≈ 3,4 Mo compressés (`main.dart.js` 3,7 Mo brut / ~1,1 Mo gzip ; CanvasKit ~2,3 Mo Brotli) ; ensuite 0 octet (service worker). Débit client mesuré très variable (10 Ko/s à 200 Ko/s, latence ~200 ms). | Mesures du 03/10 [CT] ; `docs/rapport-de-tests.md` §12 | Démarrage instantané après la première visite | Aucun test de performance ; poids du socle Flutter (1,74 Mo brut pour un « hello world ») | Élevé | Budget de performance en Phase 6 |
| **A-21 Hors connexion** | Service worker propre (`biosigma_sw.js`) : précache atomique versionné par build, moteur graphique conservé à la première utilisation, bascule pilotée par la page. Vérifié **en navigateur d'aperçu** : installation, démarrage serveur arrêté, bascule vers un nouveau build. | `web/biosigma_sw.js`, `web/index.html` [CI] ; essais du 03/10 [CT] | Usage hors connexion de la version web | **Non vérifié** sur téléphone réel, Safari/iOS, anciens Android ; aucun test automatisé du service worker | Moyen | Tests T-OFF sur appareils réels avant toute promesse de « garanti hors connexion » |
| **A-22 Dépendances** | 7 dépendances d'exécution hors SDK Flutter et `biosigma_core` ; aucune dépendance de calcul externe ; `dart:js_interop` pour le bouton de mise à jour (web). | `pubspec.yaml` [CI] | Peu de dépendances | `intl: any` ; pas de veille de sécurité formalisée | Élevé | Veille mensuelle (Phase 6) |
| **A-23 Documentation** | `README.md` (architecture, tests, déploiement, état du projet), `docs/rapport-de-tests.md` (12 sections), `docs/tracabilite-scientifique.md` (32 équations), `DEPLOY-VPS.md`. | Fichiers [CI] | Documentation technique et de livraison | Pas de manuel utilisateur ; traçabilité incomplète (27 équations ajoutées sans entrée dans la table dédiée) ; pas de registre de décisions | Élevé | Manuel utilisateur et registre de décisions (Phases 1 et 6) |
| **A-24 Observabilité / erreurs** | Aucun journal, aucune télémétrie (choix de confidentialité). Erreurs de saisie : message par champ en français ; autres erreurs : texte d'exception brut ; lectures de stockage : échec silencieux. | `calculator_screen.dart`, `app_storage_service.dart` [CI] | Messages de validation par champ | Échecs silencieux (A-10) ; pas de journal local de diagnostic | Élevé | Journal d'audit local **non nominatif** (E) ; messages contrôlés |
| **A-25 Module Entraînement** (hors cahier des charges) | 4 banques, 232 questions (séries de 20), scores locaux. Extension vers 1000 questions **abandonnée** sur votre instruction. | `data/quiz/*`, `screens/quiz_module_screen.dart`, 2 tests [CT] | Auto-évaluation locale | Contenu **non relu** par un biologiste (échantillon seulement) | Élevé | Conserver ; relecture humaine avant toute mise en avant pédagogique |

### Synthèse de l'audit

- **Fonctionnalités confirmées** [CI/CT] : 59 équations tracées et testées ; moteur pur séparé ; conversions de 13 analytes ; saisie avec unités ; favoris ; historique facultatif local ; réglages décimaux ; hors connexion web ; mise à jour avec bandeau ; thème clair/sombre ; Références ; À propos ; Entraînement ; déploiement HTTPS ; aucune donnée nominative.
- **Fonctionnalités supposées mais non confirmées** : fonctionnement sur Android/iOS [NV] ; comportement hors connexion sur Safari/iOS et anciens navigateurs [NV] ; accessibilité aux lecteurs d'écran [NV] ; indépendance des valeurs de référence des 240 tests [NV].
- **Fonctionnalités absentes** (par rapport au cahier des charges) : Convert universel ; Dilute (simple, série, hors linéarité) ; Prepare ; tampons ; Count (hématies, leucocytes, plaquettes, réticulocytes, formule, compteur tactile, spermatozoïdes, liquides) ; Microbiology et McFarland ; bibliothèque et contrôle de pipettes ; indices MCV/MCH/CCMH, ANC/ALC ; module Quality ; incertitudes ; Smart Lab Solver ; Smart Dilution Planner ; saisie intelligente des unités ; recherche par intention ; export PDF/impression/partage ; exercices générés ; modèles personnalisés ; identifiants de calcul au format `FAMILLE_NOM_NNN` ; Martin-Hopkins (le panel LDL ne propose que Friedewald et Sampson).
- **Fonctionnalités dupliquées** : A-18.
- **Fonctionnalités présentes dans le moteur mais inaccessibles** : la comparaison à une valeur mesurée de la compensation acido-basique (`measuredCompensatoryValue`) existe dans le moteur et n'est exposée dans aucun écran [CI].
- **Risques de régression** : toute modification de `UnitRegistry` (utilisé par la plupart des équations) ; toute consolidation des doublons ; changement de schéma de stockage ; modification du parseur de nombres (touche tous les champs) ; modification de `FormulaMeta` (utilisé par catalogue, recherche, Références, quiz généré) ; changement d'identifiants (favoris et historique existants).
- **Informations manquantes** : qui valide scientifiquement (rôle, procédure) ; plateformes cibles prioritaires ; inventaire réel des pipettes et chambres du laboratoire ; versions de méthodes à implémenter (OMS spermiologie, source du TEa…) ; contraintes réglementaires visées ; avis sur la politique d'interprétation.
- **Actions bloquantes avant codage** : validation de ce document ; décisions D-01 à D-12 (voir B.6) ; P0-01 (sauvegarde) et P0-02 (golden master) avant toute modification du moteur.


---

## 49.3 B — Architecture cible BioSigma Lab

### B.1 Vue d'ensemble

Principe directeur : **ajouter des couches autour de l'existant, ne rien réécrire**. Les 59 fonctions `calculate*` actuelles restent la référence de calcul ; elles sont enveloppées par un pipeline commun qui leur ajoute normalisation d'unités, validation dimensionnelle, versionnement et traçabilité.

| Couche | Responsabilité | Existant réutilisé | Nouveau |
|---|---|---|---|
| **Interface** (Flutter) | Saisie, affichage hiérarchisé des résultats, navigation, accessibilité | Écrans actuels, `provider`, thème, champs | Accueil « Lab », écrans des nouveaux modules, séparation visuelle des niveaux de résultat |
| **Saisie et normalisation d'unités** | Reconnaître une unité saisie, **demander confirmation si ambiguë**, convertir vers l'unité interne en conservant unité saisie → unité normalisée → transformation | `NumberFormatService`, `UnitRegistry` | Analyseur d'unités, modèle de grandeurs |
| **Validation** | Présence, bornes, **compatibilité dimensionnelle**, domaine de validité de l'équation, compatibilité de méthode | `Validation`, `CalculationInputException` | Contrôles dimensionnels et de domaine pilotés par les données |
| **Moteur de calcul** | Exécuter une équation **sélectionnée par identifiant et version**, contrôler la sortie, produire un enregistrement | Fonctions `calculate*` | Pipeline commun (adaptateur), arrondi/chiffres significatifs, propagation d'incertitude |
| **Registre des équations** | Identifiant stable, versions, statut de validation, liaison à la fonction, variables, unités, domaine | `CalculatorCatalog`, `FormulaMeta` | `EquationRecord` versionné, alias des anciens identifiants |
| **Base scientifique versionnée** | Analytes, masses molaires, unités, constantes, chambres, pipettes (valeurs par défaut), références, cas de test | Facteurs de `UnitRegistry` (comme valeurs de référence initiales) | Données empaquetées avec l'application, **signées par empreinte**, jamais modifiées silencieusement |
| **Traçabilité et historique** | Enregistrement non nominatif de chaque calcul avec versions utilisées | `HistoryEntry` (chaînes) | `CalculationRecord` v2 (entrées brutes + normalisées, versions, avertissements) |

**Séparation des niveaux de résultat** (sections 2.5 et 37) : le moteur étiquette chaque sortie comme *calcul mathématique*, *résultat analytique/métrologique*, *interprétation biologique* ou *aide à la décision* ; l'interface les présente dans des blocs distincts, **aucun n'étant jamais libellé « diagnostic »**. Cela remplace la liste unique d'`CalculationWarning` où interprétations et alertes de sécurité sont mélangées (constat A-14).

### B.2 Diagramme textuel

```text
Interface utilisateur (écrans Lab, écrans existants)
        ↓                              ↑ résultats par niveaux + avertissements
Saisie d'unités et de nombres  (analyse, ambiguïtés → confirmation explicite)
        ↓
Validation des entrées  (présence · bornes · dimensions · domaine · méthode)
        ↓
Normalisation des unités  (unité saisie → unité interne ; transformation conservée)
        ↓
Moteur de calcul biomédical  (pipeline commun · arrondi · incertitude · contrôles de sortie)
        ↓                ↘
Registre des équations     Fonctions calculate* existantes (inchangées)
        ↓
Base scientifique versionnée  (analytes · constantes · chambres · pipettes · références · tests)
        ↓
Traçabilité et historique  (CalculationRecord v2 · versions · aucune donnée nominative)
```

### B.3 Modules

| Module | Responsabilité | Dépendances | État actuel | État cible | Priorité |
|---|---|---|---|---|---|
| Socle d'unités et de grandeurs | Dimensions, grandeurs, analyseur d'unités, conversions, masses molaires | Base scientifique | Partiel (13 analytes, sans dimensions) | Complet, testé aller-retour | P1 |
| Registre d'équations | Identifiants, versions, statuts, alias | Base scientifique | Partiel (`FormulaMeta`, sans statut) | Complet | P1 |
| Base scientifique | Données versionnées et sourcées | — | Absente (constantes dans le code et les chaînes) | Présente, avec états « bloqué/non validé » | P1 |
| Traçabilité/audit | Enregistrements v2, migration | Registre, base | Partiel (historique en chaînes) | Complet | P1 |
| **Convert** | Conversions biomédicales | Socle d'unités, base d'analytes | Absent | Présent | P1 |
| **Dilute** | C1V1=C2V2, séries, hors linéarité | Socle, pipettes | Absent | Présent | P1 |
| **Prepare** (+ tampons) | Solutions, pureté, hydratation, Henderson-Hasselbalch | Socle, base | Absent | Présent | P2 |
| Pipettes / pipetabilité | Bibliothèque, vérification, stratégie intermédiaire | Socle | Absent | Présent | P2 |
| **Count** | Chambres, hématies, leucocytes, plaquettes, réticulocytes, formule, spermatozoïdes, liquides, compteur tactile | Base (chambres) | Absent | Présent | P2 |
| **Microbiology** | UFC/mL, dilutions décimales, McFarland | Dilute, base | Absent | Présent | P2 |
| **Hematology** | Indices (MCV, MCH, CCMH, ANC, ALC, existants) | Registre | Partiel (8 indices + réticulocytes) | Complété | P3 |
| **Hemostasis** | INR (ISI), TCA, Rosner, scores existants | Registre | Présent (13 équations) | Conservé | P3 |
| **Clinical** | Équations rénales, métaboliques, hépatiques, électrolytes, urines | Registre | Présent (existant) | Conservé et versionné | P3 |
| **Quality** | Moyenne, SD, CV, biais, récupération, erreur totale, Sigma | Socle, base (TEa) | Absent | Présent | P4 |
| Incertitudes (mode Expert) | Propagation, incertitude élargie | Registre | Absent | Présent | P4 |
| **Smart Solver** | Langage naturel déterministe → équation → protocole | Tout ce qui précède | Absent | Présent | P5 |
| Smart Dilution Planner | Optimisation de chaînes de dilution | Dilute, pipettes | Absent | Présent | P5 |
| Recherche universelle | Intentions, synonymes, unités | Registre | Partiel (sous-chaîne) | Présente | P5 |
| Entraînement / exercices | Quiz existant ; exercices générés | Registre validé | Quiz présent | Conservé ; exercices seulement sur équations validées | P5 |
| Export / impression | PDF, partage, impression | Audit | Copie presse-papiers seulement | Présent | P3 |
| Hors connexion / mise à jour | Service worker, bandeau | — | Présent (web) | Conservé, testé sur appareils | P1 |

### B.4 Flux de données

1. **Saisie** : texte → analyse d'un nombre (séparateurs) et d'une unité. Toute lecture ambiguë (point/virgule, « mg/dl » vs « mg/100 mL », « µ » vs « u ») est **soumise à confirmation**, jamais corrigée en silence.
2. **Normalisation d'unités** : valeur saisie + unité saisie → grandeur et dimension → unité interne. La transformation (facteur, masse molaire éventuelle, version de la donnée) est conservée.
3. **Validation** : présence ; valeurs finies ; bornes physiologiques ou de domaine de l'équation ; compatibilité dimensionnelle ; compatibilité avec la méthode choisie.
4. **Sélection de l'équation** : par identifiant stable + version ; refus si l'équation est « bloquée » ou « non validée » en mode professionnel (à arbitrer, D-08).
5. **Calcul** : fonction existante, entrées normalisées, aucune conversion implicite cachée dans la fonction.
6. **Contrôle dimensionnel et d'ordre de grandeur** de la sortie.
7. **Contrôle métrologique** : domaine analytique, volumes pipetables, incertitude si renseignée.
8. **Résultat** par niveaux (calcul · analytique · interprétation · aide à la décision) avec valeur, unité, chiffres significatifs.
9. **Avertissements** classés (sécurité, domaine, données manquantes, volume non pipetable…), distincts des interprétations.
10. **Traçabilité** : `CalculationRecord` (identifiant de calcul, équation et version, version de la base, entrées brutes/normalisées, résultat, avertissements, version de l'application) ; **aucun identifiant de patient**.
11. **Export** : à partir de l'enregistrement, avec confirmation avant export (section 32).

### B.5 Compatibilité et migration

- **Écrans et calculateurs existants** : conservés tels quels ; les 59 fonctions ne sont pas modifiées. Le pipeline les appelle par un adaptateur.
- **Identifiants existants** : les 59 identifiants actuels (`ckd_epi_creatinine_2021`…) restent **valides indéfiniment** ; le format `FAMILLE_NOM_NNN` de la section 33 est ajouté comme alias, jamais en remplacement.
- **Favoris** : clés `biosigma.favorites.v1` lues telles quelles (liste d'identifiants actuels).
- **Historique** : les entrées v1 restent affichables avec la mention « version d'équation non enregistrée » ; écriture v2 sous une **nouvelle clé** ; v1 conservé tant que la migration n'est pas validée ; **plus aucun effacement silencieux en cas d'erreur de lecture** (mise en quarantaine).
- **Paramètres** : clés actuelles conservées ; les paramètres sans effet (A-11) ne sont ni supprimés ni silencieusement câblés sans décision D-04.
- **Comportements** : toute modification qui change un résultat (arrondi, facteur de conversion, parseur de nombres) est livrée **avec** une note de migration et un test golden mis à jour sur validation explicite.

### B.6 Décisions techniques

| Décision | Options envisagées | Option recommandée | Justification | Risque | Validation requise |
|---|---|---|---|---|---|
| **D-01** Relecture indépendante du code et des équations | (a) aucune ; (b) relecteur humain interne ; (c) relecteur externe | (b) au minimum | Le code a été produit par l'assistant ; l'audit n'est pas indépendant | Erreurs non vues | Désigner une personne |
| **D-02** Plateformes prioritaires | Web seul ; web + Android ; web + Android + iOS | **DÉCIDÉ (décidé par délégation le 2026-10-04 (« Je vous laisse faire »)) : web/PWA prioritaire** (essai réel déclaré sur iPhone/Safari ; hébergé sur le VPS). Android et iOS natifs : projets présents mais **non compilés ni promis** tant qu'un SDK et un compte développeur n'existent pas. Réversible à tout moment. | Le natif n'a jamais été compilé ; coût de signature iOS | Promesses non tenues | Non |
| **D-03** Politique d'affichage des interprétations | Toujours affichées (actuel, sauf ISTH/4Ts) ; masquées par défaut avec validation locale ; selon le type de seuil | À arbitrer ; **dans tous les cas** aligner ISTH/4Ts et la documentation | Contradiction actuelle (A-14) ; tension avec 2.5 | Interprétation sans validation | Oui |
| **D-04** Réglages sans effet (A-11) | Câbler ; masquer ; retirer | Câbler ce qui a un sens métier (précision, coefficient Na, équation LDL), décider des seuils locaux | Un réglage sans effet induit en erreur | Régression d'affichage | Oui |
| **D-05** Politique de saisie décimale (A-07) | Refuser le séparateur « étranger » ; accepter les deux avec confirmation ; heuristique | Accepter les deux **avec confirmation quand ambigu** (ex. un seul séparateur suivi de 1 à 2 chiffres) | Supprime le facteur 10 silencieux | Changement du comportement de tous les champs | Oui |
| **D-06** Environnement de préproduction | Aucun ; sous-domaine de test ; image locale | Sous-domaine de test sur le même VPS | Test hors connexion/mise à jour avant production | Ressources du VPS partagé | Oui (DNS, façade) |
| **D-07** Stockage | Conserver `shared_preferences` (v2 JSON) ; SQLite (drift) ; autre | Conserver en Phases 1-2 ; réévaluer en Phase 4 selon le volume | Volume actuel faible (200 entrées) ; SQLite web ajoute poids et complexité | Plafond de volume | Oui (analyse d'impact si changement) |
| **D-08** Statut d'une équation « non validée » en usage | Utilisable avec bandeau ; bloquée en mode professionnel | Bandeau visible + mode « enseignement » | Les 59 existantes sont toutes « non validées » : les bloquer rendrait l'application inutilisable | Fausse assurance | Oui |
| **D-09** Arithmétique | `double` avec tolérances documentées ; décimal exact | `double` en interne, arrondi décimal à l'affichage | Précision suffisante ; pas de dépendance nouvelle | Artefacts d'arrondi | Oui (règle d'arrondi) |
| **D-10** Smart Solver | Analyse déterministe par règles ; modèle de langage local/distant | **Règles déterministes, hors ligne** | Reproductibilité, hors connexion, aucune donnée envoyée | Couverture limitée des formulations | Oui |
| **D-11** Export PDF | Nouvelle dépendance PDF ; impression navigateur | Impression navigateur d'abord | Évite une dépendance et son poids | Mise en page limitée | Oui (analyse d'impact) |
| **D-12** Gouvernance de validation | Aucune ; fiche de validation par équation avec validateur et date | Fiche + statuts du schéma E | Condition de la section 2.3 | Charge de travail | Oui (qui valide ?) |
| **D-13** Accueil « Lab » vs onglet « Calcul » actuel | Remplacer l'onglet ; l'envelopper (l'accueil Lab mène aux domaines existants) ; ajouter un 6ᵉ onglet | **Envelopper** : l'accueil Lab regroupe les 10 modules et renvoie vers les domaines existants | Aucun écran existant n'est supprimé ; recherche et favoris conservés | Régression de navigation | Oui |
| **D-14** Budget de performance | Aucun ; poids maximal au premier chargement et temps de démarrage cibles | **DÉCIDÉ (décidé par délégation le 2026-10-04 (« Je vous laisse faire »)) : budgets provisoires adoptés comme cibles** : main.dart.js ≤ 1,3 Mo et premier chargement ≤ 4 Mo (gzip), contrôlés par `tool/check_bundle_size.sh` ; mesures actuelles 1,18 Mo et 3,33 Mo. À réviser si l'usage réel l'exige. | Réseaux lents des utilisateurs visés | Objectif irréaliste avec le socle Flutter (1,74 Mo brut) | Non |
| **D-15** Cible d'accessibilité | Aucune ; WCAG 2.1 AA ; autre | **DÉCIDÉ (décidé par délégation le 2026-10-04 (« Je vous laisse faire »)) : WCAG 2.1 AA comme cible de travail**, contrôlée automatiquement (contraste, cibles tactiles, étiquettes, texte à 200 %, reflow 320 px) ; **les essais sur technologies d'assistance réelles restent à faire par une personne**, aucune conformité n'est déclarée. | Usage à la paillasse, technologies d'assistance | Coût de mise en conformité | Non |
| **D-16** Exercices générés (P5-05) | Équations validées seulement (backlog d'origine) ; toutes, avec le statut affiché | **Toutes, statut affiché sur chaque exercice** (**décidé par délégation le 2026-10-04 (« Je vous laisse faire »)**) | Aucune équation n'est validée : « validées seulement » vide la fonction ; cas fictifs, corrigé recalculé indépendamment par les tests, mention « entraînement uniquement » | Un apprenant prend l'exercice pour une référence clinique | Non |
| **D-17** Martin-Hopkins (P3-03) | Embarquer le tableau de 180 facteurs ; tableau saisi par l'utilisateur ; ne pas implémenter | **Tableau saisi par l'utilisateur, puis embarqué** : le validateur a collé le tableau le 2026-10-04 ; recopié par programme (180 cellules, strates contiguës) et branché au panel lipidique (version 2) | Règle « aucune valeur sourçable inventée » respectée : les valeurs viennent du validateur, l'assistant ne les a pas confrontées à la publication ; dossier FV-PREP-017 | Faute de saisie (1 cellule suspecte : 93–96 / ≥ 220) ; **décidé le 2026-10-04 par le validateur : calcul refusé à partir de TG 400 mg/dL, strates lues sur valeurs arrondies au mg/dL entier** | Oui (confrontation à la source par le validateur) |
| **D-18** Périmètre de l'incertitude (P4-02) | GUM complet (corrélations, degrés de liberté, Monte-Carlo) ; premier ordre non corrélé | **Premier ordre, non corrélé** (GUM éq. 10 et 12), k saisi (**décidé par délégation le 2026-10-04 (« Je vous laisse faire »)**) | Référence lue le 2026-10-04 ; couvre le besoin de la dilution et des modèles simples ; les limites sont affichées | Sous-estimation si fortes non-linéarités ou corrélations | Non |

### B.7 Limites connues de cette proposition

Les choix ci-dessus ne sont pas éprouvés ; aucune maquette ni prototype n'a été réalisé (interdit avant validation). Le chiffrage de complexité du backlog est une estimation. Le comportement natif (Android/iOS) n'est pas évalué.

---

## 49.4 C — Cartographie fonctionnelle

*Existant / À conserver / À modifier / À ajouter : Oui · Non · Partiel.*

| Fonctionnalité ou module | Existant | À conserver | À modifier | À ajouter | Dépendances | Risque de régression | Critère de validation |
|---|---|---|---|---|---|---|---|
| Équations rénales (CKD-EPI ×3, Schwartz, clairance, protéinurie 24 h, ACR, PCR, FeNa, FeUrée) | Oui | Oui | Partiel (versionnement, fiche limites) | Non | `UnitRegistry` | Moyen | Golden master identique |
| Équations cardiométaboliques (QUICKI, TyG, HOMA, eAG, LDL, AIP, IMC, TyG-IMC, HOMA-β, CT/HDL, ApoB/ApoA1, Framingham, SCORE2) | Oui | Oui | Partiel (doublons A-18) | Martin-Hopkins (sur validation) | `UnitRegistry` | Moyen | Golden master identique |
| Ionogramme et biochimie générale (trou anionique, osmolarité, Na/Ca corrigés, fer, A/G, bilirubine, De Ritis, FIB-4, APRI, MELD-Na, ALBI, acido-basique, HCO3/Cl) | Oui | Oui | Partiel (exposer la comparaison acido-basique) | Non | `UnitRegistry` | Moyen | Golden master identique |
| Hémostase (INR, TCA, Rosner, ISTH, 4Ts, dRVVT, SIC, HAS-BLED, CHA₂DS₂-VASc, Padua, IMPROVE, Caprini) | Oui | Oui | Partiel (écrans ISTH/4Ts, gestion ISI explicite à vérifier) | Ratio TP (à vérifier) | Registre | Moyen | Golden master identique |
| Hématologie (Mentzer, Shine-Lal, England-Fraser, Green-King, RDWI, réticulocytes, SII, SIRI) | Oui | Oui | Non | MCV, MCH, CCMH, ANC, ALC | Registre | Faible | Golden master identique |
| Interprétations sourcées (avertissements `info`) | Oui | Oui | **Oui** (séparation des niveaux, alignement ISTH/4Ts) | Non | `WarningList` | **Élevé** (toute l'interface de résultat) | Revue des 59 résultats ; D-03 |
| Moteur d'unités (13 analytes) | Oui | Oui | **Oui** (dimensions, masses molaires, analyseur) | Oui | Toutes les équations | **Élevé** | Tests de conversion existants + aller-retour + golden |
| Saisie numérique et parseur | Oui | Oui | **Oui** (A-07) | Saisie intelligente d'unités | Tous les champs | **Élevé** | Tests de saisie ambiguë (T-SAI) |
| Écran de calcul générique + 3 écrans dédiés | Oui | Oui | Partiel | Niveaux de résultat | Registres UI | Moyen | Tests d'interface étendus |
| Recherche | Oui | Oui | Oui (intentions, synonymes) | Recherche universelle | Registre | Faible | Jeu de requêtes de la section 41 |
| Favoris | Oui | Oui | Non | Modèles personnalisés | Stockage | Faible | Migration sans perte |
| Historique local facultatif | Oui | Oui | **Oui** (v2, versions) | Export, reprise | Stockage | **Élevé** | Migration v1→v2, restauration |
| Réglages (séparateur, précision, historique, LDL, Na, seuils, validation locale) | Oui | Oui | **Oui** (A-11) | Paramètres des nouveaux modules | `AppState` | Moyen | Chaque réglage a un effet testé |
| Références / fiche technique | Oui | Oui | Oui (statut, validateur, version) | Gestion des références | `FormulaMeta` | Faible | 59 fiches complètes |
| Entraînement (quiz 232 q.) | Oui | Oui | Non | Exercices générés | Registre validé | Faible | Tests de contenu existants |
| À propos / avertissements | Oui | Oui | Oui (cohérence politique d'interprétation) | Non | — | Faible | Relecture |
| Hors connexion web (service worker) | Oui | Oui | Non | Tests appareils réels | Build/stamp | Moyen | T-OFF sur appareils |
| Mise à jour (bandeau, `version.json`) | Oui | Oui | Partiel (cohérence des versions) | Contrôle CI | Déploiement | Moyen | Test de bascule |
| Thème clair/sombre, accessibilité de base | Oui | Oui | Oui (clavier, WCAG) | Raccourcis | UI | Faible | Audit T-ACC |
| Déploiement HTTPS, Docker, nginx, Caddy | Oui | Oui | Partiel (CSP, rollback) | Préproduction | VPS | Moyen | Procédure testée |
| **Convert** | Non | — | — | Oui | Socle, base d'analytes | — | Aller-retour, sources |
| **Dilute** (simple, série, hors linéarité) | Non | — | — | Oui | Socle, pipettes | — | T-DIL |
| Bibliothèque de pipettes, pipetabilité | Non | — | — | Oui | Socle | — | T-PIP |
| **Prepare** et tampons | Non | — | — | Oui | Base (masses molaires, pKa) | — | Données sourcées |
| **Count** (RBC, WBC, plaquettes, réticulocytes, formule, spermatozoïdes, liquides, compteur) | Non | — | — | Oui | Base (chambres) | — | T-CPT |
| **Microbiology** (UFC, McFarland) | Non | — | — | Oui | Dilute | — | T-MIC |
| **Quality** | Non | — | — | Oui | Socle | — | T-QUA |
| Incertitudes | Non | — | — | Oui | Registre, Quality | — | T-INC |
| **Smart Solver / Planner** | Non | — | — | Oui | Tout | — | T-SOL |
| Export PDF / impression / partage | Partiel (copie) | Oui | Oui | Oui | Audit | Faible | Confirmation avant export |
| Identifiants de calcul `FAMILLE_NOM_NNN` | Non | — | — | Oui (alias) | Registre | Faible | Alias résolus |
| Gouvernance de validation scientifique | Non | — | — | Oui | Schéma E | — | Fiches signées |
| Intégration continue | Non | — | — | Oui | Dépôt | — | Pipeline vert obligatoire |
| Procédure de rollback | Non | — | — | Oui | Déploiement | — | Répétition réussie |

---

## 49.5 D — Arborescence des écrans

```text
BioSigma Lab
├── [EXISTANT, conservé]   Onglet « Calcul » (accueil actuel)
│   ├── Recherche par nom                                   → [MODIFIÉ] Recherche universelle
│   ├── Outils composés : panel CKD-EPI · ISTH-CIVD · 4Ts   [conservés]
│   ├── Favoris                                             [conservé]
│   └── Domaines repliables (Rénal, Cardiométabolique, Ionogramme, Hémostase, Hématologie)
├── [NOUVEAU] Accueil « Lab » (10 tuiles) — remplace/enveloppe l'onglet « Calcul » : à confirmer (D-13)
│   ├── Convert · Dilute · Prepare · Count · Microbiology
│   ├── Hematology (→ domaine existant + nouveaux indices)
│   ├── Hemostasis (→ domaine existant)
│   ├── Clinical (→ domaines Rénal + Cardiométabolique + Ionogramme existants)
│   ├── Quality · Smart Solver
├── [EXISTANT, conservé]   Écran de calcul générique (+ écrans dédiés CKD-EPI, ISTH-CIVD, 4Ts)
│   └── [MODIFIÉ] Résultat par niveaux · version d'équation · « Expliquer mon calcul »
├── [EXISTANT, conservé]   Entraînement (liste des modules → série de 20 questions → score)
├── [EXISTANT, modifié]    Références (fiches techniques) → + statut de validation, version, validateur
├── [NOUVEAU]              Gestion des références et de la base scientifique (lecture seule, statuts)
├── [NOUVEAU]              Historique (v2) · Favoris · Modèles · Export/Impression
├── [EXISTANT, modifié]    Réglages (+ pipettes, chambres, arrondis, TEa, effacement contrôlé)
├── [EXISTANT, conservé]   À propos (cohérence de la politique d'interprétation)
└── [EXISTANT]             Bandeau de mise à jour (transversal)
```

| Écran | Statut | Objectif | Entrées | Sorties | États d'erreur / vide / validation | Dépendances | Confiance |
|---|---|---|---|---|---|---|---|
| Accueil actuel (Calcul) | Existant, conservé | Accéder à tous les calculs | Texte de recherche | Liste filtrée, domaines | Aucun résultat ; liste vide de favoris masquée | Catalogue | Élevée |
| Accueil Lab | **À confirmer** | Orienter vers 10 modules | Tuile choisie | Navigation | Module indisponible/bloqué (donnée non validée) | Registre | Moyenne |
| Recherche universelle | Nouveau | « Que voulez-vous calculer ? » | Texte libre | Module proposé **à confirmer** | « Aucun module trouvé » ; ambiguïté → choix | Index d'intentions | Moyenne |
| Calcul générique | Existant, modifié | Saisir, calculer, lire | Champs et unités | Résultat par niveaux, entrées utilisées, fiche | Champ requis, hors domaine, unité incohérente, exception contrôlée | Registre, moteur | Élevée |
| Panel CKD-EPI / ISTH-CIVD / 4Ts | Existant, conservés (ISTH/4Ts à aligner) | Calculs composés/guidés | Critères | Scores | « Score incomplet » ; interprétation masquée (A-14) | Moteur | Élevée |
| Convert | Nouveau | Convertir grandeurs et analytes | Valeur, unités, analyte | Valeur convertie, méthode, version, avertissements | Unité ambiguë, conversion non valide, analyte sans facteur validé (bloqué) | Base d'analytes | Moyenne |
| Dilute (simple) | Nouveau | C1V1=C2V2 | 3 variables sur 4 | Inconnue, volumes, facteur, pipetabilité | Données insuffisantes, dimensions incompatibles, volume non pipetable | Pipettes | Moyenne |
| Dilute (série) | Nouveau | Tableau de tubes | Facteur, nombre de tubes, volumes, volume mort | Tableau Tube/Prélevé/Diluant/Dilution/Cumulée/Concentration/Volume | Volumes incompatibles avec le matériel | Pipettes | Moyenne |
| Hors linéarité | Nouveau | Résultat × facteur total | Limite, dilution, résultat dilué | Résultat original, chaîne de calcul | « Toujours hors domaine » ; conditions non remplies → résultat non présenté comme valide | Dilute | Moyenne |
| Pipettes (bibliothèque) | Nouveau | Décrire le matériel | Modèle, plage, incrément, exactitude, vérification | Liste | Date de vérification dépassée (avertissement) | Stockage | Moyenne |
| Prepare / Tampons | Nouveau | Préparer une solution ou un tampon | Concentration, volume, masse molaire, pureté… | Masse/volume, protocole, hypothèses | Donnée manquante ; pKa non validé (bloqué) | Base | Moyenne |
| Count (par type) | Nouveau | Numérations | Chambre, dilution, zones, comptages | Concentrations, volume compté | Chambre non documentée → avertissement | Base (chambres) | Moyenne |
| Compteur tactile / formule | Nouveau | Comptage assisté | +1, −1, Annuler, Zone suivante, Terminer | Totaux, pourcentages, absolus | Somme incohérente ; reprise de session | Stockage | Moyenne |
| Spermatozoïdes / liquides biologiques | Nouveau | Concentration et nombre total | Dilution, chambre, comptages A/B, volume | Concentration ≠ nombre total (séparés) | Écart A/B ; méthode OMS non sourcée (bloqué) | Base | Faible |
| Microbiology | Nouveau | UFC/mL, inoculum, McFarland | Colonies, volume, dilutions, boîtes | UFC/mL, boîtes retenues | Boîte non interprétable ; mention McFarland ≠ CFU universel | Dilute | Moyenne |
| Hematology / Hemostasis / Clinical | Existants (domaines) | Calculs par domaine | — | — | — | Registre | Élevée |
| Quality | Nouveau | CV, biais, Sigma… | Séries de mesures, cible, TEa | Indicateurs, définition utilisée | Unités incompatibles ; TEa sans source | Base | Moyenne |
| Mode Expert / incertitude | Nouveau | Résultat ± incertitude | Incertitudes-types, k | U, composantes incluses/exclues | Composantes manquantes | Registre | Faible |
| Smart Solver | Nouveau | Résolution à partir d'une phrase | Texte | Problème reconnu à **confirmer**, protocole | Ambiguïté → question ; refus si incohérent | Tout | Faible |
| Explication (« Expliquer mon calcul ») | Nouveau | Pédagogie | Calcul courant | 12 étapes de la section 31 | — | Registre | Moyenne |
| Entraînement + quiz | Existant, conservé | Auto-évaluation | Réponses | Score local | Série incomplète | Banque | Élevée |
| Références | Existant, modifié | Consulter la traçabilité | — | Fiche + statut/validateur/version | Fiche incomplète signalée | Registre | Élevée |
| Gestion de la base scientifique | Nouveau | Lire les entités et leur statut | — | Liste par statut (validé, non validé, bloqué) | — | Base | Moyenne |
| Historique / Favoris / Modèles | Existant (partiel) | Réutiliser | — | Liste, filtre, export | Historique vide ; erreur de lecture → quarantaine | Stockage | Élevée |
| Export / Impression | Nouveau | Partager un résultat | Enregistrement | PDF/impression | Confirmation avant export | Audit | Moyenne |
| Réglages | Existant, modifié | Préférences | — | — | Réglage sans effet interdit | `AppState` | Élevée |
| Aide | Nouveau | Mode d'emploi, limites | — | — | — | — | Moyenne |
| À propos | Existant, conservé | Mission, avertissements | — | — | — | — | Élevée |

---

## 49.6 E — Schéma de la base scientifique

Principe : **toute valeur scientifique est une donnée versionnée, sourcée et dotée d'un statut** — jamais une constante enfouie dans le code ou dans une chaîne de texte (constat A-09). Un élément sans source suffisante a le statut `BLOQUÉ` et **n'est pas utilisable** (règle absolue, section 47).

### E.1 Entités principales

| Entité | Description | Champs essentiels | Versionnable | Source obligatoire |
|---|---|---|---:|---:|
| **Dimension** | Type de grandeur (masse, volume, quantité de matière, concentration massique, concentration molaire, nombre/volume, temps, adimensionnel…) | id, nom, vecteur d'exposants de base | Oui | Non (définition SI) |
| **Unité** | Unité reconnue | id, symbole, synonymes saisissables (« uL », « microlitre »), dimension, facteur vers l'unité SI, décalage éventuel, statut | Oui | Oui |
| **Analyte** | Substance ou mesurande | id, nom, formule chimique, masse molaire, dimension SI, unité SI, unités conventionnelles, valence (si ionique), isoforme/méthode, limitations, statut | Oui | **Oui** |
| **ConversionRule** | Règle de conversion entre grandeurs d'un analyte | analyte, de/vers (dimensions), expression, dépend de (masse molaire / valence / méthode), domaine, statut | Oui | Oui |
| **Constante** | Constante numérique (hors masse molaire) | id, valeur, unité, incertitude, contexte, statut | Oui | Oui |
| **Équation** | Définition d'une équation | id stable, alias hérités, nom, domaine, expression lisible, variables (dimension attendue, bornes), unités de sortie, hypothèses, domaine de validité, population, interdits, statut | Oui | Oui |
| **VersionÉquation** | Version d'une équation | équation, numéro, date d'entrée en vigueur, date de retrait, liaison à l'implémentation, constantes utilisées, règle d'arrondi, statut, auteur, validateur | Oui | Oui |
| **Méthode** | Méthode analytique ou de comptage | id, nom, version/édition, organisme, limites, applicabilité | Oui | Oui |
| **Chambre de numération** | Géométrie d'une chambre | id, nom, surface par zone, profondeur, zones, règles de bordure, méthodes compatibles, statut | Oui | **Oui** |
| **Pipette** | Description d'une pipette **de l'utilisateur** | id, fabricant/modèle, volume min recommandé, max, incrément, exactitude, précision, incertitude, date de vérification | Oui (historique des vérifications) | Spécification du fabricant |
| **RèglePipetabilité** | Règle de recommandation de volume | pipette ou classe, seuil, justification, statut | Oui | Oui |
| **RègleArrondi** | Mode d'arrondi et chiffres significatifs | id, mode, décimales/chiffres significatifs, contexte | Oui | Oui |
| **ModèleIncertitude** | Façon d'estimer une incertitude | id, méthode, composantes, facteur de couverture, hypothèses | Oui | Oui |
| **Référence** | Source scientifique | id, citation complète, type (article, norme, guide, notice), année/édition, identifiant (DOI/PMID/numéro de norme), date de consultation, lien hors ligne éventuel | Oui | — |
| **Validation** | Acte de validation | élément validé (+ version), validateur (rôle), date, périmètre, décision, commentaires, pièces | Oui | Oui |
| **CasDeTest** | Cas de référence | élément, entrées, résultat attendu, **origine du résultat attendu** (calcul indépendant), tolérance (et sa justification), type (normal, limite, erreur) | Oui | Oui |
| **VersionScientifique** | Publication cohérente de la base | numéro, date, empreinte du contenu, liste des éléments, notes, compatibilité | Oui | — |
| **EnregistrementDeCalcul** | Trace d'un calcul (local, non nominatif) | identifiant de calcul, équation + version, version de la base, version de l'application, entrées brutes (valeur, unité saisie), entrées normalisées, constantes utilisées, résultat par niveaux, avertissements, méthode, date, identifiant de session non nominatif | Non (immuable) | — |

### E.2 Relations

- Une **Unité** appartient à une **Dimension** ; un **Analyte** possède une dimension SI et des **ConversionRule** ; une conversion « masse ↔ quantité de matière » exige **masse molaire** (Analyte) et **valence** pour les mEq.
- Une **Équation** a N **VersionÉquation** ; chaque version référence les **Constantes**, **RègleArrondi**, **ModèleIncertitude** et **Références** qu'elle utilise, et possède ses **CasDeTest** et ses **Validation**s.
- Une **Méthode** restreint les **Équations** applicables (ex. équation de numération ↔ **Chambre**).
- Les **Pipettes** de l'utilisateur sont combinées aux **RèglePipetabilité** par le module Dilute.
- Un **EnregistrementDeCalcul** pointe vers une **VersionÉquation** précise et une **VersionScientifique** : il reste **reproductible** même après correction ultérieure de la base.
- Les 59 identifiants actuels deviennent des **alias** de l'équation correspondante.

### E.3 Règles de versionnement

- **Identifiant stable** : jamais réutilisé, jamais renommé ; alias conservés.
- **Numéro de version** : entier croissant par équation/entité ; un changement de formule, de constante, d'unité ou de domaine crée **toujours** une nouvelle version.
- **Dates** : entrée en vigueur, retrait ; pas de retrait rétroactif.
- **Statut** : `BROUILLON` → `PROPOSÉ` → `VALIDÉ` → `RETIRÉ`, plus `BLOQUÉ` (source insuffisante) et `NON VALIDÉ (existant)` pour l'héritage actuel. **Aucune entité n'est `VALIDÉ` sans source, test et fiche de validation.**
- **Auteur et validateur** : deux rôles distincts ; l'auteur ne valide pas son propre élément (idéal ; à confirmer en D-12).
- **Compatibilité avec les résultats historiques** : un enregistrement conserve sa version ; il n'est jamais recalculé silencieusement.
- **Correction** : une erreur découverte → nouvelle version corrigée + note ; les enregistrements concernés sont **signalés** (pas modifiés).
- **Retrait** : l'élément reste consultable ; l'interface avertit qu'il est retiré.
- **Mise à jour hors ligne** : la base est livrée **avec l'application** (nouvelle version d'application = nouvelle version scientifique) ; aucune synchronisation silencieuse, conformément à la section 38.

---

## 49.7 F — Registre initial des équations

### F.1 Équations déjà présentes et confirmées (59)

Le tableau complet — **une ligne par équation, avec les 13 colonnes demandées**, généré par extraction du code — est fourni en annexe :
**[`annexe-F-registre-equations-existant.md`](annexe-F-registre-equations-existant.md)** (59 lignes). Aucune équation n'y est marquée « validée » : toutes sont `PRÉSENTE · SOURCÉE · TESTÉE · NON VALIDÉE`. Les écarts connus y figurent ligne par ligne : doublons, références à reconfirmer (APRI/OMS, Padua, HAS-BLED, CHA₂DS₂-VASc), absence de seuil consensuel (HOMA-IR, QUICKI, TyG, TyG-IMC, HOMA-β, SII, SIRI), exposition incomplète dans l'interface.

### F.2 Équations ou constantes présentes mais non enregistrées / non documentées

| ID proposé | Nom | Domaine | Formule | Variables d'entrée | Unités attendues | Unités de sortie | Hypothèses | Limites | Référence | Version | Statut de validation | Tests associés |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `CONV_<ANALYTE>_001` (×13) | Conversions de `UnitRegistry` | Unités | Facteur multiplicatif (ou affine pour l'HbA1c) vers l'unité canonique | valeur, unité | Selon analyte | Unité canonique | Masses molaires **en commentaires uniquement** | Facteurs arrondis ; insuline dépendante de l'étalon | Commentaires du code (citations partielles) | Non versionné | PRÉSENTE · NON VALIDÉE · **à documenter** | `unit_registry_test.dart` (14 tests) |
| `CONV_BILI_UMOL_MGDL_001` | Conversion bilirubine | Unités | mg/dL = µmol/L ÷ 17,1 | bilirubine | µmol/L | mg/dL | Facteur usuel | Non enregistré dans le registre | Non documentée dans le code | Non versionné | PRÉSENTE · NON VALIDÉE · **non documentée** | Via tests MELD-Na |
| `INTERP_*` (nombreux) | Seuils d'interprétation embarqués (stades KDIGO, bandes IMC OMS, catégories ATP III/ESC, grades ALBI, bandes MELD, seuils FIB-4/APRI, etc.) | Interprétation | Conditions `if/else` et texte des avertissements | Résultat de l'équation | Unités de l'équation | Texte | Selon source citée | Non versionnables ni validables séparément | Citées dans le texte des avertissements | Non versionné | PRÉSENTE · NON VALIDÉE · **non enregistrée** | Un test de présence de texte par équation |
| `FMT_ARRONDI_001` | Règle d'affichage | Formatage | `toStringAsFixed(précision de la valeur)` | valeur | — | Texte | Arrondi de la bibliothèque | Pas de chiffres significatifs ; mode d'arrondi non documenté | Aucune | Non versionné | PRÉSENTE · **non documentée** | Indirects |

### F.3 Équations à ajouter (Phase 1 et suivantes)

> **Règle** : aucune de ces équations n'est « validée ». Les formules ci-dessous sont des **définitions standard énoncées à titre de spécification** ; les références sont **à identifier et à lire** avant implémentation. Les noms de documents cités comme *candidats* n'ont **pas** été consultés pour ce dossier (non vérifié).

| ID proposé | Nom | Domaine | Formule | Variables d'entrée | Unités attendues | Unités de sortie | Hypothèses | Limites | Référence | Version | Statut de validation | Tests associés |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `DIL_C1V1_001` | Dilution C1V1 = C2V2 | Dilute | C₁·V₁ = C₂·V₂ ; l'inconnue est la 4ᵉ variable | 3 parmi C₁, V₁, C₂, V₂ | Concentration (même dimension), volume | Idem | Conservation de la quantité de matière ; volumes finaux définis explicitement (additivité des volumes à préciser) | Solutions non idéales, volume mort | Principe de conservation — **référence à identifier** | v1 (proposée) | À AJOUTER · validation simple | T-DIL-01..12 |
| `DIL_FACTOR_001` | Facteur et rapport de dilution | Dilute | Facteur = V_final / V_prélevé = C_initiale / C_finale ; « 1:n » **doit être défini** (1 volume pour n volumes totaux, ou 1 pour n de diluant) | volumes ou concentrations | Même dimension | Sans dimension | Convention de notation | **Ambiguïté de « 1:10 »** — décision à valider | À identifier | v1 (proposée) | À AJOUTER · **décision de convention requise** | T-DIL-13..16 |
| `DIL_SERIAL_001` | Dilutions en série | Dilute | Dilution cumulée = produit des facteurs ; concentration du tube k = C₀ / dilution cumulée | C₀, facteur(s), n tubes, volumes | Concentration, volume | Concentration, volume | Transferts exacts ; volumes morts si renseignés | Accumulation d'erreur de pipetage | À identifier | v1 (proposée) | À AJOUTER | T-DIL-20..30 |
| `DIL_OOR_001` | Résultat hors linéarité | Dilute | Résultat final = résultat mesuré × facteur total de dilution | mesuré, facteur total, limite analytique | Unité du mesurande | Idem | Linéarité vérifiée dans la plage mesurée | **Non valide** si les conditions analytiques ne sont pas remplies | Section 8 du cahier des charges ; **référence de méthode à identifier** | v1 (proposée) | À AJOUTER | T-DIL-31..36 |
| `CONV_MASS_MOLAR_001` | Concentration massique ↔ molaire | Convert | c (mol/L) = ρ (g/L) ÷ M (g/mol) | concentration, analyte | Dimension massique ou molaire | Dimension opposée | **Masse molaire sourcée par analyte** | Dépend de la structure, de l'isoforme, de la méthode (ex. Lp(a)) | **À sourcer par analyte** | v1 par analyte | **BLOQUÉE par analyte** tant que M n'est pas sourcée | T-CNV-* |
| `CONV_MEQ_001` | mEq/L | Convert | mEq/L = mmol/L × valence | concentration, ion | mmol/L | mEq/L | Valence de l'ion | Ions seulement | À identifier | v1 | À AJOUTER (après base d'analytes) | T-CNV-* |
| `CONV_PERCENT_001` | % m/v, % v/v, % m/m | Convert / Prepare | % m/v = g pour 100 mL ; % v/v = mL pour 100 mL ; % m/m nécessite la densité | quantité, volume ou masse totale, densité | g, mL | % | Définitions conventionnelles | Température, contraction de volume | À identifier | v1 | À AJOUTER · validation simple | T-PRP-* |
| `PREP_MASS_001` | Préparation molaire | Prepare | m = C × V × M, corrigée de la pureté et de la forme hydratée | C, V, M, pureté, hydratation | mol/L, L, g/mol, % | g | Volume final défini ; M de la **forme réellement pesée** | Température, tolérance de préparation | À identifier | v1 | À AJOUTER · **M sourcées requises** | T-PRP-* |
| `PREP_COMM_001` | Solution commerciale concentrée | Prepare | Volume de produit = f(concentration cible, % m/m, densité, M) | idem + densité | — | mL | Densité à la température indiquée | Données du fournisseur | **Fiche produit du fournisseur** | v1 | **BLOQUÉE** sans données produit | T-PRP-* |
| `BUF_HH_001` | Henderson-Hasselbalch | Prepare | pH = pKa + log₁₀([A⁻]/[HA]) | pKa, rapport ou quantités | — | pH, quantités | Concentrations ≈ activités | Force ionique, température, pKa dépendant | À identifier | v1 | **BLOQUÉE** : pKa et températures à sourcer | T-PRP-* |
| `CNT_CONC_001` | Concentration cellulaire | Count | C = N × facteur de dilution ÷ volume réellement compté ; volume = surface × profondeur × nombre de zones | N, dilution, chambre, zones | cellules, —, mm², mm | cellules/µL (et conversions) | Géométrie de la chambre sélectionnée | Règles de bordure, répartition | **Données géométriques à sourcer par chambre** | v1 par chambre | **BLOQUÉE par chambre** | T-CPT-* |
| `CNT_RETIC_001` | Réticulocytes | Count | % = réticulocytes comptés ÷ hématies comptées × 100 ; absolu = RBC × % ÷ 100 | comptages, RBC | cellules, 10¹²/L | %, 10⁹/L | — | Correction/IPR séparés (déjà présents) | Section 16 du cahier des charges | v1 | À AJOUTER · partiellement présent (panel) | T-CPT-* |
| `CNT_DIFF_001` | Formule leucocytaire | Count | % catégorie = n ÷ total × 100 ; absolu = % × WBC ÷ 100 (ANC, ALC…) | comptages, WBC | cellules, 10⁹/L | %, 10⁹/L | Total cohérent avec la somme | Définition des formes immatures à préciser | À identifier | v1 | À AJOUTER | T-CPT-* |
| `CNT_SEMEN_001` | Spermatozoïdes | Count | Concentration = N × dilution ÷ volume compté ; nombre total = concentration × volume de l'éjaculat | comptages A/B, dilution, chambre, volume | — | 10⁶/mL ; 10⁶/éjaculat | Règles de la **version de méthode** retenue | Écart A/B, bordures | **Manuel OMS — édition à déterminer** (candidat, non consulté) | v1 | **BLOQUÉE** : règles à sourcer | T-CPT-* |
| `MIC_CFU_001` | UFC par mL | Microbiology | UFC/mL = colonies ÷ (volume inoculé × dilution) ; plusieurs boîtes/dilutions selon la méthode | colonies, volume, dilution | —, mL, — | UFC/mL | Boîtes interprétables selon critères | Critères d'exclusion dépendants de la méthode | **Norme de dénombrement à identifier** | v1 | **BLOQUÉE** pour le multi-boîtes ; simple cas **à valider** | T-MIC-* |
| `MIC_MCF_001` | Standards de McFarland | Microbiology | Table de standards ; **aucune conversion universelle en UFC/mL** | standard choisi | — | Turbidité | — | Dépend de l'organisme, de la morphologie, de la méthode | **À sourcer** | v1 | **BLOQUÉE** (valeurs) | T-MIC-* |
| `HEM_IDX_001` | VGM, TCMH, CCMH | Hematology | Définitions : VGM = Ht ÷ GR ; TCMH = Hb ÷ GR ; CCMH = Hb ÷ Ht (facteurs d'unités selon les unités d'entrée) | Ht, GR, Hb | % ou L/L ; 10¹²/L ; g/L ou g/dL | fL ; pg ; g/L | Mesures sur le même échantillon | Dépend des unités d'entrée (facteurs à valider) | **À identifier** | v1 | À AJOUTER · validation requise | T-HEM-* |
| `HEM_ANCALC_001` | ANC, ALC, absolus | Hematology | Absolu = % × WBC ÷ 100 | %, WBC | %, 10⁹/L | 10⁹/L | — | Inclusion des formes immatures | À identifier | v1 | À AJOUTER | T-HEM-* |
| `HEMO_PTRATIO_001` | Ratio TP | Hemostasis | Ratio = TP patient ÷ TP témoin (**à vérifier** : peut déjà exister dans l'INR) | TP, témoin | s | — | — | Réactif-dépendant | À identifier | v1 | **À vérifier dans `inr.dart`** | — |
| `QC_STATS_001` | Moyenne, écart-type, CV % | Quality | Moyenne ; SD (n−1 ou n : **à choisir et documenter**) ; CV % = SD ÷ moyenne × 100 | série de mesures | Unité du mesurande | Unité ; % | Série homogène | Petits effectifs | À identifier | v1 | À AJOUTER · **choix n/n−1 à valider** | T-QUA-* |
| `QC_BIAS_001` | Biais, erreur, récupération | Quality | Biais = mesuré − cible ; biais % = biais ÷ cible × 100 ; récupération % = mesuré ÷ attendu × 100 | mesuré, cible | Même unité | Unité ; % | Cible = valeur de référence documentée | Choix de la cible | À identifier | v1 | À AJOUTER | T-QUA-* |
| `QC_SIGMA_001` | Sigma Metric | Quality | Sigma = (TEa − \|Biais\|) ÷ CV | TEa, biais, CV | Tous en % (ou même unité) | Sans dimension | Composantes exprimées de façon compatible | **Source du TEa à déterminer** | À identifier | v1 | **BLOQUÉE** : source du TEa | T-QUA-* |
| `QC_TE_001` | Erreur totale | Quality | Définition **à choisir** (plusieurs en usage) | biais, CV, facteur | % | % | — | Définitions concurrentes | À identifier | v1 | **BLOQUÉE** : définition à arbitrer | T-QUA-* |
| `UNC_GUM_001` | Propagation d'incertitude | Incertitudes | u_c² = Σ (∂f/∂xᵢ)² u²(xᵢ) (premier ordre, corrélations ignorées sauf déclaration) ; U = k · u_c | incertitudes-types | Unités des variables | Unité du résultat | Modèle linéarisable | Non-linéarités, corrélations | **GUM (JCGM 100:2008) — candidat, non consulté** | v1 | **BLOQUÉE** : lecture et validation métrologique | T-INC-* |
| `PIP_CHECK_001` | Pipetabilité | Pipettes | Un volume est « recommandé » s'il respecte la plage de la pipette **de l'utilisateur** ; seuils issus de sa fiche et de sa vérification | volume, pipette | µL | Classe : possible / recommandé / validé / impossible | Fiche pipette exacte | Seuils **non codés en dur** | **Spécification du fabricant ; norme de pipettes — candidat : ISO 8655, non consultée** | v1 | **BLOQUÉE** sans pipettes saisies | T-PIP-* |

### F.4 Équations proposées mais bloquées en attente de validation

`CONV_MASS_MOLAIRE` pour chaque analyte dont la masse molaire n'est pas sourcée (la liste de la section 5 est bloquée **par défaut**, analyte par analyte) ; `PREP_COMM_001` ; `BUF_HH_001` ; toutes les équations par chambre ; `CNT_SEMEN_001` ; `MIC_CFU_001` (multi-boîtes) ; `MIC_MCF_001` ; `QC_SIGMA_001` ; `QC_TE_001` ; `UNC_GUM_001` ; `PIP_CHECK_001`.

### F.5 Équations non implémentables faute de référence suffisante (à ce stade)

- **Lp(a) : facteur universel mg/dL ↔ nmol/L** — **non implémentable** : aucun facteur universel justifiable (taille d'isoforme variable) ; conversion à proscrire sans justification.
- **McFarland → UFC/mL universel** — non implémentable (dépend de l'organisme et de la méthode).
- **Conversions de troponines, BNP, NT-proBNP entre dosages** — équivalences dépendantes du dosage : non implémentables sans données par dosage.
- **Normalité** — implémentable seulement pour des espèces et réactions explicitement définies.
- **Tout facteur « usuel » sans masse molaire sourcée** (ex. facteur d'insuline selon l'étalon : déjà signalé comme dépendant du dosage dans le code).

---

## 49.8 G — Plan de migration

### G.1 Principes

Conservation de l'existant ; modifications minimales ; compatibilité ascendante (identifiants, favoris, historique) ; **migration réversible** ; validation par étapes avec critères de sortie ; traçabilité de chaque changement (registre de décisions) ; **aucun changement de résultat sans nouvelle version d'équation et sans validation explicite**.

### G.2 Étapes

| Étape | Objectif | Préconditions | Actions | Livrables | Tests requis | Critère de sortie | Rollback |
|---|---|---|---|---|---|---|---|
| **0 — Sauvegarde et gel** | Figer l'état fonctionnel | Validation de ce document | Étiquette Git `baseline-v1.6.0` sur `cf1beae` ; sauvegarde de l'image de production ; copie des configurations (hors secrets) | Étiquette, archive d'image, copie de config | Restauration à blanc | Restauration réussie sur machine de test | Sans objet |
| **1 — Golden master** | Détecter toute modification silencieuse | Étape 0 | Jeu de résultats de référence pour les 59 équations (valeurs, unités, nombre et texte des avertissements) | Fixtures + test | Golden master vert sur `baseline` | 100 % des équations couvertes | Supprimer les fixtures |
| **2 — Correctifs de sécurité décidés** | Traiter A-07, A-10, A-14, A-11 | Décisions D-03, D-04, D-05 | Modifications **minimales** et isolées, une par une | Correctifs + tests dédiés | Golden master (changements **explicitement approuvés** uniquement) | Aucune régression non approuvée | `git revert` du correctif |
| **3 — Socle d'unités/dimensions** | Remplacer le moteur d'unités par un modèle de grandeurs **en parallèle** | Étapes 1-2 | Nouveau modèle ; facteurs actuels repris **à l'identique** comme valeurs de référence ; ancien `UnitRegistry` conservé derrière un adaptateur | Socle + base d'analytes (statuts) | Aller-retour ; comparaison ancien/nouveau sur toutes les paires ; golden | Écart = 0 (ou écart documenté et approuvé) | Réactiver l'ancien chemin |
| **4 — Registre d'équations + alias** | Statuts, versions, alias | Étape 3 | `EquationRecord` pour les 59 ; alias des identifiants | Registre | Résolution des 59 identifiants ; favoris intacts | 59/59 résolus | Retirer le registre (l'ancien catalogue reste) |
| **5 — Traçabilité v2 + migration de l'historique** | `CalculationRecord` | Étape 4 ; P0-06 | Lecture v1 ; écriture v2 sous nouvelle clé ; quarantaine des erreurs | Stockage v2 | Migration sur jeux de données réels simulés ; corruption simulée | Aucune perte ; v1 intact | Revenir à la lecture v1 seule |
| **6 — Convert + Dilute** | Premiers modules | Étapes 3-5 | Modules isolés derrière un indicateur de fonctionnalité | Écrans + moteur | T-CNV, T-DIL | Critères section 46 | Désactiver l'indicateur |
| **7 — Lab Tools (Phase 2)** | Prepare, Count, Microbiology, pipettes | Données sourcées par élément | Un module à la fois | Modules | T-PRP, T-CPT, T-MIC, T-PIP | Idem | Désactiver le module |
| **8 — Calculateurs (Phase 3), Quality (Phase 4)** | Compléter | Registre validé | Ajouts par équation validée | Équations | T-HEM, T-QUA, T-INC | Idem | Retrait d'une version d'équation |
| **9 — Intelligence (Phase 5)** | Solver, planificateur, recherche | Phases 1-4 stables | Analyse déterministe | Modules | T-SOL | Idem | Désactiver |

### G.3 Stratégie de sauvegarde

- **Version de référence** : `baseline-v1.6.0` (commit `cf1beae`), conservée **sans limite de durée** (étiquette annotée, dépôt GitHub public).
- **Code** : dépôt GitHub + copie locale du dossier ; l'étiquette est créée **avant** la moindre modification.
- **Données** : les données utilisateur sont **dans les navigateurs des utilisateurs** (localStorage) — **elles ne peuvent pas être sauvegardées côté serveur** (par conception, aucune synchronisation). Conséquence : la migration de l'historique doit être non destructive et testée (étape 5) ; un export local avant migration est proposé aux utilisateurs.
- **Configurations** : copie de `Caddyfile` (bloc BioSigma), `nginx.conf`, `docker-compose*.yml`, `.env` **hors secrets** ; l'état du Caddyfile partagé du VPS est **non vérifiable** par moi (à copier côté serveur).
- **Image** : `docker save` de l'image `biosigma:latest` en production, avec empreinte.
- **Restauration** : procédure écrite, **répétée sur une machine de test** avant l'étape 1 ; durée de conservation des sauvegardes : à fixer (proposition : jusqu'à la fin de la Phase 2).
- **Test de restauration** : critère d'acceptation de l'étape 0.

### G.4 Stratégie de déploiement

- **Développement** : poste local, aperçu navigateur ; **service worker testé uniquement sur l'origine de l'aperçu** (contrainte constatée).
- **Test** : sous-domaine de test (D-06) servant exactement l'image candidate ; tests hors connexion et de bascule sur appareils réels.
- **Préproduction** : confondue avec l'environnement de test tant que le VPS reste partagé.
- **Déploiement progressif** : modules derrière des **indicateurs de fonctionnalité** activés un à un ; version patch/mineure par livraison ; contrôle automatique de cohérence des trois emplacements de version.
- **Surveillance** : aucune télémétrie (confidentialité) → vérifications manuelles guidées (`curl` de `version.json`, rechargement hors connexion) ; journal d'audit **local** pour le diagnostic.
- **Critères d'arrêt** : régression du golden master non approuvée ; échec d'un test bloquant (H.3) ; perte de données lors d'un essai de migration.
- **Retour arrière** : image précédente + **republication sous un numéro de version supérieur** (le comparateur `isNewerVersion` n'annonce que les versions plus récentes ; un service worker détecte un changement d'octets, pas un « retour » de version) ; le build restauré reçoit un nouveau tampon de service worker ; procédure à **répéter** avant l'étape 2.

---

## 49.9 H — Plan de tests

### H.1 Matrice de tests

*Les résultats attendus numériques de conversion dépendent de constantes à valider : ils sont exprimés comme « calcul indépendant fourni par le validateur ». Aucun résultat attendu n'est dérivé du code testé.*

| ID | Domaine | Scénario | Entrées | Résultat attendu | Type de test | Priorité | Statut |
|---|---|---|---|---|---|---|---|
| T-REG-001 | Régression | Golden master des 59 équations (valeurs, unités, nombre et texte des avertissements) | Jeux canoniques figés sur `baseline-v1.6.0` | Identique à la référence (écarts approuvés explicitement seulement) | Régression | P0 | À écrire |
| T-REG-002 | Régression | 240 tests du moteur + 9 tests d'interface | — | Tous verts | Régression | P0 | **Existant** (vert au 03/10) |
| T-REG-003 | Régression | Résolution des 59 identifiants actuels via le registre | Identifiants des favoris | 59/59 résolus | Intégration | P0 | À écrire |
| T-CNV-001 | Conversion | Chaque paire d'unités des 13 analytes actuels, ancien vs nouveau moteur | Valeurs types, extrêmes | Écart nul ou documenté | Comparaison | P1 | Partiel (14 tests existants) |
| T-CNV-002 | Conversion inverse | A → B → A pour toute paire | Toutes valeurs de test | Écart absolu entre A' et A ≤ tolérance documentée (H.2) | Propriété | P1 | À écrire |
| T-CNV-003 | Dimensionnel | mg/dL → mmol/L sans analyte ; µL → mg ; unités de dimensions incompatibles | Paires incompatibles | **Refus explicite** avec message | Négatif | P1 | À écrire |
| T-CNV-004 | Facteurs 10³/10⁶/10⁹ | Erreur de préfixe (µ vs m vs n) | « 5 mL » vs « 5 µL », etc. | Résultats cohérents ; ambiguïté « u/µ » → confirmation | Propriété | P1 | À écrire |
| T-CNV-005 | Analyte à facteur non universel (Lp(a)) | mg/dL → nmol/L | Valeur | **Refus** : « conversion non validée » | Négatif | P1 | À écrire |
| T-SAI-001 | Saisie | « 0.7 », « 0,7 », « 1.5 », « 1,5 », « 1.234,5 », « 1 000 » en mode virgule et point | Chaînes | Politique D-05 : aucune lecture ×10 silencieuse | Négatif/propriété | **P0** | À écrire (**échoue aujourd'hui**, A-07) |
| T-SAI-002 | Unités saisies | « uL », « microlitre », « mg/100 mL », « mg/dl » | Chaînes | Normalisation + trace ; ambiguïté → question | Unitaire | P1 | À écrire |
| T-DIL-001 | Dilution | C1V1=C2V2 : 500 mg/dL → 75 mg/dL, volume final 2 mL | 500, 75, 2 mL | V1 et diluant = calcul indépendant (arithmétique exacte) | Unitaire | P1 | À écrire |
| T-DIL-002 | Dilution | Facteurs 1:2, 1:5, 1:10, 1:20, 1:100, personnalisé | Facteurs | Facteur, volumes, concentration cohérents ; convention de notation affichée | Unitaire | P1 | À écrire |
| T-DIL-003 | Dilution | Distinction facteur / rapport / cumulée / concentration finale | Cas types | Quatre grandeurs distinctes et correctes | Unitaire | P1 | À écrire |
| T-DIL-004 | Série | Séries 1:2, 1:5, 1:10 sur n tubes, avec et sans volume mort | Paramètres | Tableau Tube/Prélevé/Diluant/Dilution/Cumulée/Concentration/Volume exact | Unitaire | P1 | À écrire |
| T-DIL-005 | Changement d'unité | Concentration en mg/dL, cible en mmol/L (analyte sourcé) | — | Conversion tracée avant dilution | Intégration | P1 | À écrire |
| T-DIL-006 | Hors linéarité | Résultat dilué × facteur total ; résultat corrigé encore hors domaine | Cas types | Chaîne complète ; mention « nouvelle dilution nécessaire » | Unitaire | P1 | À écrire |
| T-DIL-007 | Impossibilité | Cible supérieure à la solution mère | — | **Refus** explicite | Négatif | P1 | À écrire |
| T-PIP-001 | Pipetabilité | 0,7 µL avec P10/P20/P100/P200/P1000 du jeu de test | Pipettes simulées | « Volume non recommandé » ; stratégie intermédiaire proposée | Unitaire | P2 | À écrire |
| T-PIP-002 | Pipetabilité | Quatre classes : possible / recommandé / validé / impossible | Volumes frontières | Classe correcte à chaque seuil | Limite | P2 | À écrire |
| T-PIP-003 | Planificateur | Comparaison de stratégies, rejets motivés | Contraintes | Stratégie minimale respectant les contraintes ; rejets expliqués | Intégration | P5 | À écrire |
| T-CPT-001 | Numération | Volume compté = surface × profondeur × zones pour chaque chambre | Chambres (données sourcées) | Volume cohérent avec la fiche ; **aucun facteur codé en dur** | Unitaire | P2 | Bloqué (données) |
| T-CPT-002 | Numération | RBC/WBC/plaquettes : cellules/µL, /mm³, 10⁶/µL, 10¹²/L, 10⁹/L | Comptages types | Équivalences exactes entre unités | Unitaire | P2 | À écrire |
| T-CPT-003 | Réticulocytes, formule | Pourcentages, absolus, somme = total | Comptages | Somme cohérente ; erreur si incohérente | Unitaire | P2 | À écrire |
| T-CPT-004 | Compteur tactile | +1, −1, Annuler, Zone suivante, Terminer, reprise de session | Séquences | Totaux exacts ; verrouillage après validation | Interface | P2 | À écrire |
| T-CPT-005 | Spermatozoïdes | Concentration ≠ nombre total ; écart A/B | Comptages | Séparation stricte ; version de méthode affichée | Unitaire | P2 | Bloqué (méthode) |
| T-MIC-001 | UFC | UFC/mL = colonies ÷ (volume × dilution), plusieurs boîtes/dilutions | Jeux types | Résultat selon la méthode sélectionnée ; boîtes retenues listées | Unitaire | P2 | Bloqué (norme) |
| T-MIC-002 | McFarland | Affichage de la mention de non-universalité | — | Message obligatoire présent | Interface | P2 | À écrire |
| T-CLI-001 | Équations cliniques | Cas de référence indépendants des 59 équations | Jeux existants | Valeurs inchangées | Régression | P0 | **Existant** |
| T-CLI-002 | Équations cliniques | Chaque équation : normal, limite, zéro, négatif, unité incorrecte, manquant, extrême | — | Comportement documenté | Unitaire | P1 | Partiel |
| T-QUA-001 | Qualité | Moyenne, SD (n−1/n), CV, biais, récupération | Séries types | Valeurs calculées indépendamment | Unitaire | P4 | Bloqué (choix n/n−1) |
| T-QUA-002 | Qualité | Sigma avec composantes en unités incompatibles | — | **Refus** | Négatif | P4 | À écrire |
| T-INC-001 | Incertitude | Propagation sur C1V1=C2V2 avec incertitudes-types | Valeurs | Comparaison à un calcul analytique indépendant ; facteur de couverture affiché | Unitaire | P4 | Bloqué (référence) |
| T-SOL-001 | Smart Solver | « J'ai une solution à 500 mg/dL… 2 mL à 75 mg/dL avec une P200 et une P1000 » | Phrase | Problème reconnu, valeurs et unités extraites, **confirmation demandée**, protocole vérifié | Intégration | P5 | À écrire |
| T-SOL-002 | Smart Solver | Phrase ambiguë ou incompatible | Phrases | Question de clarification ou **refus** ; jamais de calcul silencieux | Négatif | P5 | À écrire |
| T-ERR-001 | Erreurs | Valeurs manquantes, négatives, nulles, infinies, non finies | — | Messages contrôlés (pas d'exception brute) | Négatif | P1 | Partiel (`Erreur de calcul : $e` existe) |
| T-ARR-001 | Arrondi | Règles d'arrondi et chiffres significatifs par équation | Valeurs frontières | Conforme à la règle validée ; reproductible | Unitaire | P1 | À écrire |
| T-REP-001 | Reproductibilité | Même entrée → même sortie sur 1 000 exécutions et sur 3 plateformes | — | Résultats identiques | Propriété | P1 | À écrire |
| T-INT-001 | Intégration | Pipeline complet saisie → normalisation → calcul → enregistrement | Cas types | Enregistrement complet et relisible | Intégration | P1 | À écrire |
| T-UI-001 | Interface | Parcours bout en bout de chaque nouveau module | — | Parcours terminé ; états vide/erreur/validation corrects | Interface | P2 | Partiel (9 tests) |
| T-OFF-001 | Hors ligne | Première visite en ligne → coupure → redémarrage → calcul | Appareils réels (Android, iOS) | Fonctionnement complet | Appareil | **P0 avant toute promesse** | **Non vérifié** (navigateur d'aperçu seulement) |
| T-OFF-002 | Hors ligne | Bascule vers un nouveau build, puis retour arrière | Deux builds | Nouveau cache plein ; ancien supprimé ; aucun mélange | Intégration | P1 | Vérifié en aperçu (manuel) |
| T-PERF-001 | Performance | Premier chargement sur réseau lent simulé ; démarrage à froid/à chaud | Profils réseau | Budget à définir (D-14) | Performance | P3 | À écrire |
| T-SEC-001 | Sécurité | En-têtes (CSP), absence de secrets, appels réseau limités à `version.json` | — | Conforme à la politique | Sécurité | P2 | Partiel |
| T-CONF-001 | Confidentialité | Aucune donnée nominative demandée ou stockée ; effacement total effectif | — | Aucune clé résiduelle après effacement | Confidentialité | P1 | À écrire |
| T-ACC-001 | Accessibilité | Lecteur d'écran, navigation clavier, contrastes, texte agrandi | Outils d'audit | Critères D-15 (WCAG visé) | Accessibilité | P3 | À écrire |
| T-COMP-001 | Compatibilité | Chrome, Safari/iOS, Firefox, Android WebView ancien ; builds Android/iOS | — | Fonctions essentielles opérationnelles | Appareil | P2 | **Non vérifié** |
| T-MIG-001 | Migration | Historique v1 → v2 ; **corruption simulée** ; paramètres et favoris | Jeux v1 | Aucune perte ; quarantaine en cas d'erreur | Intégration | **P0** | À écrire |
| T-MIG-002 | Restauration | Restauration depuis `baseline-v1.6.0` et l'image sauvegardée | — | Application fonctionnelle, mêmes empreintes | Procédure | **P0** | À écrire |
| T-EXP-001 | Export | Export PDF/impression avec confirmation préalable | — | Contenu fidèle à l'enregistrement ; version et références incluses | Interface | P3 | À écrire |
| T-TRC-001 | Traçabilité | Un calcul rejoué à partir de son enregistrement reproduit le résultat | Enregistrements | Résultat identique même après mise à jour de la base | Propriété | P1 | À écrire |
| T-SCI-001 | Scientifique | Chaque équation/constante : source, version, domaine, 2 cas indépendants, validation signée | — | Statut `VALIDÉ` seulement si tout est présent | Revue | P1 | À organiser (D-12) |

### H.2 Critères de qualité (propositions soumises à validation)

- **Tolérances numériques** : arithmétique pure (dilutions, ratios) : écart relatif ≤ 10⁻¹² en `double` ; conversion avec facteur stocké : ≤ 10⁻¹² relatif par rapport au même facteur ; comparaison à un calcul indépendant avec masse molaire sourcée : écart ≤ ½ unité du dernier chiffre significatif affiché. **Chaque tolérance est justifiée dans le cas de test** (section 35) ; aucune n'est choisie arbitrairement.
- **Aller-retour A→B→A** : |A′ − A| ≤ 10⁻¹² · |A| avant arrondi d'affichage.
- **Règles d'arrondi** : jamais d'arrondi interne ; arrondi uniquement à l'affichage ; mode (au plus proche, moitié vers l'infini ?) **à décider et documenter** ; chiffres significatifs gérés par équation.
- **Gestion des erreurs** : aucune exception brute affichée ; message en français, par champ quand c'est possible.
- **Couverture** : objectif proposé ≥ 90 % des lignes du moteur et 100 % des équations avec ≥ 2 cas indépendants dont 1 cas limite ; **mesure à mettre en place** (inexistante aujourd'hui).
- **Non-régression** : golden master vert ; tout écart explicitement approuvé et daté.
- **Validation scientifique** : statut `VALIDÉ` seulement avec source, version, domaine, tests et fiche de validation signée.
- **Performance** : budget à définir (D-14) ; mesures actuelles : ≈ 3,4 Mo au premier chargement, 0 octet ensuite.
- **Accessibilité** : cible à définir (D-15) ; aucune mesure actuelle.

### H.3 Tests bloquants (l'échec interdit toute mise en production)

T-REG-001 (golden master) · T-REG-002 · T-REG-003 · T-CLI-001 · T-SAI-001 (lecture ×10 silencieuse) · T-MIG-001 · T-MIG-002 · T-CNV-002, T-CNV-003 et T-CNV-005 (pour toute livraison touchant aux unités) · T-ARR-001 · T-TRC-001 · T-CONF-001 · T-OFF-001 avant toute mention « fonctionne hors connexion » sur mobile · T-DIL-001 à T-DIL-007 pour la livraison de Dilute · T-SCI-001 pour toute équation affichée comme `VALIDÉE`.

---

## 49.10 I — Backlog priorisé

*Priorités : P0 bloquant · P1 critique · P2 important · P3 amélioration · P4 futur. Complexité : S, M, L, XL (estimation). « Responsable proposé » = rôle de la liste de la section 1, à confirmer.*

| ID | Tâche | Phase | Priorité | Valeur utilisateur | Dépendances | Complexité | Risque | Critères d'acceptation | Statut |
|---|---|---|---|---|---|---|---|---|---|
| P0-01 | Étiquette `baseline-v1.6.0`, archive d'image de production, copie des configurations, **restauration répétée** | 0 | P0 | Protège l'existant | Validation du document | S | Faible | T-MIG-002 réussi | **Fait sur le VPS, copie hors serveur à confirmer** : tag `baseline-v1.6.0` publié ; archive d'image 1.6.0 créée et contrôlée (empreinte dans `P0-01-08-…`) ; restauration non répétée (voir P0-08) |
| P0-02 | Golden master des 59 équations | 0 | P0 | Détecte toute régression silencieuse | P0-01 | M | Faible | T-REG-001 vert sur `baseline` | **Fait** : 142 cas, `test/golden/` ; vert sur `baseline`, vérifié par mutation |
| P0-03 | Décision et alignement ISTH/4Ts ↔ documentation ↔ politique d'interprétation (D-03) | 0 | P0 | Cohérence et sécurité | Décision | S | Moyen | Aucune contradiction README / À propos / écrans | **Fait (à déployer)** : ISTH/4Ts alignés, textes corrigés ; R-10 reste ouvert (D-08) |
| P0-04 | Politique de saisie décimale (D-05) et correction du facteur ×10 silencieux | 0 | P0 | **Évite des erreurs de résultats** | Décision, P0-02 | M | Moyen | T-SAI-001 vert | **Fait (à déployer)** : refus des saisies ambiguës, 14 tests (T-SAI-001) ; non déployé, version à relever (1.6.1) |
| P0-05 | Inventaire complet : unités de sortie par équation, constantes d'interprétation embarquées, constantes inline | 0 | P0 | Base du registre | — | M | Faible | Annexe F complétée à 100 % | **Fait** : unités de sortie des 59 équations (annexe F) + inventaire mécanique des constantes (annexe P0-05) ; classement scientifique des constantes non fait, non exhaustivité documentée |
| P0-06 | Lecture du stockage sans effacement silencieux (quarantaine) | 0 | P0 | Évite la perte de données | P0-02 | S | Moyen | T-MIG-001 (corruption simulée) vert | **Fait** : quarantaine + 8 tests (`test/services/app_storage_service_test.dart`) ; reste à tester sur appareil réel |
| P0-07 | Gouvernance de validation scientifique : rôles, vocabulaire de statuts, modèle de fiche | 0 | P0 | Condition de toute « validation » | D-01, D-12 | S | Moyen | Fiche approuvée | **Fait côté gouvernance** : cadre, statuts, critères, modèle de fiche ; trois rôles tenus par le Dr Coulibaly (cumul consigné) ; mécanisme implémenté ; aucune fiche encore signée |
| P0-08 | Procédure de rollback écrite et répétée (version supérieure republiée) | 0 | P0 | Réversibilité | P0-01 | S | Faible | Répétition réussie | **Partiel** : procédure écrite ; répétition non faite |
| P1-00 | Intégration continue (analyse + tests des deux paquets + cohérence des versions) | 0/1 | P1 | Qualité continue | P0-02 | S | Faible | Pipeline vert obligatoire | **Fait (non exécutée sur GitHub)** : `.github/workflows/ci.yml` + `tool/check_versions.sh` (échec vérifié sur une version incohérente) |
| P1-01 | Réglages sans effet : câbler/masquer/retirer (D-04) | 0/1 | P1 | Honnêteté de l'interface | Décision | M | Moyen | Chaque réglage a un effet testé | **Fait** (voir D-04) |
| P1-02 | Hygiène : borner `intl`, épingler Flutter, relecture indépendante (D-01) | 0/1 | P1 | Maintenabilité | — | S | Faible | Fichiers d'outil ; relecture faite | **Partiel** : `intl` borné, Flutter épinglé dans la CI ; relecture indépendante (D-01) non faite |
| P1-10 | Modèle de grandeurs/dimensions et analyseur d'unités | 1 | P1 | Fiabilité des conversions | P0-02, P0-05 | L | Élevé | T-CNV-001..005, T-SAI-002 | **Fait (v1)** : modèle dimensionnel (`dimensions.dart`) : une unité = facteur × vecteur d'exposants sur six bases (M, L, T, N, Θ, E) ; analyseur d'unités composées avec exposants, littéraux (1,73, 100, ×10⁹), préfixes, noms traditionnels (mg%, G/L) ; plan de conversion (directe / masse molaire / valence / impossible, avec les deux grandeurs nommées) ; mode « Unités composées » de Convert. **Cohérence prouvée contre `LabUnits`** : les 140 unités proposées ont la dimension attendue et le même rapport de facteurs ; **1 236 conversions** (toutes les paires d'une même grandeur) identiques à `calculateConversion` ; aller-retour sur toutes les paires. Limites : pas de parenthèses ni d'exposants non entiers ; échelles décalées (°C, °F) refusées ici ; un rapport comme mg/kg se simplifie en grandeur sans dimension (donc mg/kg → µmol/kg impossible) ; rapports sans dimension : mise en garde (HbA1c). |
| P1-11 | Base d'analytes (masses molaires **sourcées**, statuts) ; reprise **à l'identique** des facteurs actuels | 1 | P1 | Conversions biochimiques | P1-10, P0-07 | L | Élevé | Chaque analyte : source + statut | **Partiel** : 186 analytes, masses molaires calculées, 125 formules contrôlées contre PubChem/NCI ; aucune validation humaine ; hormones peptidiques/protéines en massique seulement |
| P1-12 | Moteur de conversion et tests aller-retour | 1 | P1 | Convert | P1-10, P1-11 | M | Moyen | T-CNV-002 vert | **Fait** : conversion même grandeur + via masse molaire/valence saisies ; tests aller-retour |
| P1-13 | Registre d'équations versionné + alias des 59 identifiants | 1 | P1 | Traçabilité | P0-05, P0-07 | L | Moyen | T-REG-003 vert | **Fait** : `EquationRegistry`, 71 entrées (59 + 12 outils Lab), alias, T-REG-003 vert |
| P1-14 | Enregistrement de calcul v2 + migration de l'historique | 1 | P1 | Reproductibilité | P0-06, P1-13 | L | Élevé | T-MIG-001, T-TRC-001 | **Fait** : `CalculationRecord` v2, migration v1→v2 (v1 conservé), rejeu explicite, T-MIG-001 et T-TRC-001 verts |
| P1-15 | Politique d'arrondi et chiffres significatifs (D-09) | 1 | P1 | Résultats cohérents | Décision | M | Moyen | T-ARR-001 | **Fait (décrit l'existant)** : `FMT_ARRONDI_001` documentée et testée ; aucune valeur modifiée ; validation D-12 à faire |
| P1-16 | Séparation des niveaux de résultat (calcul / analytique / interprétation / aide à la décision) | 1 | P1 | Sécurité clinique | D-03, P1-13 | L | Élevé | Revue des 59 résultats | **Fait (v1)** : les messages d'information sont répartis en trois niveaux affichés dans des blocs distincts, à l'écran et dans le rapport : **précisions analytiques et limites**, **repères d'interprétation**, **recommandations publiées (aide à la décision)** ; alertes à part ; valeur calculée au-dessus. Classement central (`warning_level.dart`, interprétation par défaut), **revue des 78 messages du golden master** consignée dans un instantané versionné (`warning-levels.json`) : 6 équations produisent des recommandations (CHA₂DS₂-VASc, Padua, Caprini, HAS-BLED, eAG/ADA, INR). Limite : classement par motifs de texte (pas de champ « niveau » dans chaque message) ; un message nouveau est classé « interprétation » et fait échouer l'instantané jusqu'à relecture. |
| P1-17 | Moteur de dilution (C1V1=C2V2, facteur/rapport, cumul) | 1 | P1 | Dilute | P1-10, P1-15 | M | Moyen | T-DIL-001..003, 005, 007 | **Fait** : C1·V1 = C2·V2, facteur, diluant ; notation 1/F explicite |
| P1-18 | Dilutions en série et hors linéarité | 1 | P1 | Dilute | P1-17 | M | Moyen | T-DIL-004, 006 | **Fait** : séries (1 à 20 tubes) et hors linéarité (intervalle saisi par l'utilisateur) |
| P1-19 | Écrans Convert et Dilute | 1 | P1 | Usage quotidien | P1-12, P1-18 | M | Moyen | T-UI-001 | **Fait** : écrans Convert et Dilute |
| P1-20 | Accueil Lab et navigation (D-13) | 1 | P1 | Découvrabilité | Décision | M | Moyen | Aucun écran existant perdu | **Fait (variante « envelopper », D-13)** : onglet Lab ajouté après Calcul |
| P2-01 | Bibliothèque de pipettes et contrôle de pipetabilité | 2 | P2 | Sécurité des préparations | P1-17 | M | Moyen | T-PIP-001..002 | **Fait** : pipettes saisies, `PIP_CHECK_001` (4 classes), contrôle dans Dilute, T-PIP-001/002 verts ; planificateur (P5-04) non fait |
| P2-02 | Prepare (masse, pureté, hydratation, % solutions) | 2 | P2 | Préparations | P1-11 | M | Moyen | T-PRP-* | **Fait (variante saisie)** : masse à peser, pureté, % m/v et v/v ; masse molaire saisie |
| P2-03 | Tampons (Henderson-Hasselbalch) | 2 | P2 | Préparations | Données pKa sourcées | M | Élevé | T-PRP-* | **Fait (variante saisie)** : Henderson-Hasselbalch avec pKa saisi ; aucun tableau de pKa embarqué |
| P2-04 | Count : moteur et chambres | 2 | P2 | Numérations | Géométries sourcées | L | Élevé | T-CPT-001..003 | **Fait (variante saisie)** : concentration en chambre avec surface et profondeur saisies ; aucune chambre embarquée |
| P2-05 | Compteur tactile et formule leucocytaire | 2 | P2 | Paillasse | P2-04 | M | Moyen | T-CPT-003..004 | **Fait** : compteur tactile, formule, correction des érythroblastes |
| P2-06 | Spermatozoïdes et liquides biologiques | 2 | P2 | Spécialité | Méthode OMS sourcée | L | Élevé | T-CPT-005 | **Partiel** : concentration, nombre total (séparés), comptages A/B sans seuil ; méthode OMS non embarquée |
| P2-07 | Microbiology (UFC, dilutions décimales) | 2 | P2 | Bactériologie | Norme sourcée | M | Élevé | T-MIC-001 | **Fait (variante saisie)** : UFC/mL, intervalle de colonies saisi ; moyenne arithmétique simple, pas de formule de norme |
| P2-08 | McFarland (valeurs et mention de non-universalité) | 2 | P2 | Bactériologie | Valeurs sourcées | S | Élevé | T-MIC-002 | **Non fait volontairement** : aucune valeur McFarland ; mention de non-équivalence UFC/DO affichée |
| P3-01 | Hématologie : VGM, TCMH, CCMH, ANC, ALC | 3 | P3 | Indices courants | P1-13 | S | Faible | T-HEM-* | **Fait** : VGM, TCMH, CCMH, ANC, ALC (définitions, sans seuil) ; 12 tests ; golden étendu ; citation primaire à compléter ; NON VALIDÉ |
| P3-02 | Hémostase : vérifier l'ISI explicite et le ratio TP | 3 | P3 | Fiabilité de l'INR | Revue de `inr.dart` | S | Moyen | Test dédié | **Fait** : l'ISI est un paramètre requis sans valeur par défaut (moteur et champ de l'interface, sans préremplissage) ; 5 tests moteur + 2 tests d'écran (sans ISI, aucun INR) ; aucun résultat modifié. Le « ratio TP » n'est pas affiché séparément : l'ajouter changerait le résultat affiché (golden), laissé à décision. |
| P3-03 | Clinique : consolidation des doublons (A-18) **sur validation** et Martin-Hopkins (sur validation) | 3 | P3 | Cohérence | P0-02 | M | Moyen | Golden master identique | **Fait** : A-18 consolidé (TyG, CT/HDL : `shared_formulas.dart`, golden identique) ; **Martin-Hopkins branché au panel lipidique** avec le tableau saisi par le validateur (180 cellules, contrôles de structure, 6 cas Python, tolérance aux bornes) ; golden : 1 cas ajouté, aucun modifié ; **à valider : FV-PREP-017**. |
| P3-04 | Exposer la comparaison acido-basique dans l'interface | 3 | P3 | Fonction déjà présente | — | S | Faible | Test d'interface | **Fait** : dans « Compensation acido-basique attendue », le champ HCO3 / PaCO2 non utilisé comme valeur de départ est désormais comparé à la fourchette attendue (mention descriptive, « à corréler cliniquement ») ; 5 tests ; golden : 6 cas, avertissement et entrée rappelée ajoutés, **valeurs identiques**. |
| P3-05 | Export PDF/impression avec confirmation (D-11) | 3 | P3 | Partage | P1-14 | M | Faible | T-EXP-001 | **Fait (v1)** : rapport texte et HTML imprimable, confirmation obligatoire, impression web via le navigateur ; 12 + 5 + 1 tests ; boîte d'impression non pilotée à la main ; D-11 appliquée |
| P4-01 | Module Quality (CV, biais, récupération, Sigma, erreur totale) | 4 | P4 | Contrôle qualité | TEa sourcé | M | Moyen | T-QUA-* | **Fait (variante saisie)** : CV, biais, récupération, erreur totale, Sigma ; ETa et k saisis, aucun verdict |
| P4-02 | Mode Expert : incertitudes | 4 | P4 | Métrologie | Référence GUM lue | L | Élevé | T-INC-* | **Fait (v1)** : GUM (JCGM 100:2008) lu le 2026-10-04 ; propagation du premier ordre non corrélée, modèles linéaire/produit/dilution, k saisi, aides type A/type B/U÷k ; 10 tests moteur (valeurs Python) + 4 tests d'écran ; corrélations, degrés de liberté et Welch-Satterthwaite non traités (D-18). |
| P5-01 | Saisie intelligente des unités (interface) | 5 | P4 | Confort | P1-10 | M | Moyen | T-SAI-002 | **Fait** : `UnitInterpreter` (écritures, noms en toutes lettres, casse, ambiguïtés avec propositions, « G/L » signalé) + saisie rapide « 88 umol/l en mg/dl » dans Convert ; 24 tests moteur (dont T-SAI-002) + 6 tests d'écran ; jamais de supposition silencieuse. |
| P5-02 | Recherche universelle par intentions | 5 | P4 | Découvrabilité | P1-13 | M | Faible | Requêtes de la section 41 | **Fait (v1)** : recherche hors connexion sur calculs, analytes, unités, modules ; 26 tests ; jeu de requêtes de la section 41 non fourni, classement heuristique |
| P5-03 | Smart Lab Solver (règles déterministes) | 5 | P4 | Différenciation | Phases 1-2 stables | XL | Élevé | T-SOL-001..002 | **Fait (v1)** : routage par mots-clés vers un module à confirmer ; pas de résolution automatique |
| P5-04 | Smart Dilution Planner | 5 | P4 | Différenciation | P2-01 | L | Moyen | T-PIP-003 | **Fait (v1)** : planificateur 1 à 4 étapes avec les pipettes de l'utilisateur, rejets motivés, T-PIP-003 vert (15 + 5 tests) ; recherche bornée, pas de pipetages multiples |
| P5-05 | Mode enseignement et exercices générés (équations validées seulement) | 5 | P4 | Pédagogie | P1-13 | M | Moyen | Exercices corrigés vérifiés | **Fait (v1)** : 10 types d'exercices déterministes, corrigé calculé par le moteur et recalculé indépendamment (200 numéros par type), statut affiché (D-16), écran dans l'onglet Entraînement ; 9 tests moteur + 5 tests d'écran. |
| P6-01 | Accessibilité (clavier, lecteurs d'écran, contrastes) | 6 | P3 | Inclusion | — | M | Faible | T-ACC-001 | **Partiel** : conformité automatisée vérifiée (contraste, cibles, étiquettes, 200 %, 320 px, clavier) et corrigée ; essais VoiceOver/TalkBack/Safari/Firefox et audit expert à faire ; pas de déclaration de conformité |
| P6-02 | Performance et budget de chargement | 6 | P3 | Réseau lent | D-14 | M | Faible | T-PERF-001 | **Fait côté mesure et garde-fou** : poids mesuré, évolution 1.6.0→1.16.0 (+9 %), budget provisoire vérifié en CI ; démarrage sur appareil réel non mesuré ; D-14 à confirmer |
| P6-03 | Tests multiplateformes réels (Android, iOS, navigateurs) | 6 | P2 | Fiabilité | D-02 | L | Élevé | T-COMP-001, T-OFF-001 | **Partiel** : essai déclaré sur iPhone/iOS/Safari (tous scénarios, aucun problème, v1.17.0) ; Android, Firefox, Windows, Mac Safari, iPad, téléphone d'entrée de gamme non testés ; détails de l'essai à préciser (`resultats-tests-appareils.md`) |
| P6-04 | Veille de dépendances, documentation utilisateur, registre de décisions | 6 | P3 | Pérennité | — | M | Faible | Documents publiés | **Fait** : `docs/guide-utilisateur.md`, `docs/veille-dependances.md` (état relevé le 2026-10-04), `tool/veille_dependances.sh`, workflow hebdomadaire informatif ; registre des décisions publié dans ce document. Les mises à jour de paquets en retard sont décrites, pas appliquées. |

*Responsables proposés (rôles)* : P0-01/02/06/08, P1-00, P1-10..19 : ingénieur logiciel mobile + architecte de données ; P0-05, P0-07, P1-11, Phase 2 données : biologiste médical + biochimiste clinique + métrologue ; P0-03 : biologiste médical (arbitrage) + spécialiste UX/UI des logiciels médicaux ; P2-01 : métrologue biomédical ; P4 : spécialiste assurance qualité + métrologue ; validation des logiciels de laboratoire : spécialiste de validation.

---

## 49.11 J — Risques techniques et scientifiques

| ID | Risque | Catégorie | Probabilité | Impact | Criticité | Prévention | Mitigation | Responsable proposé | Statut |
|---|---|---|---|---|---|---|---|---|---|
| R-01 | **Erreur de facteur 10 à la saisie décimale** (A-07) | Erreur d'unité/saisie | **Certaine** (reproduite) | Élevé | **Critique** | P0-04, T-SAI-001 | Avertissement immédiat en attendant le correctif | Ingénieur logiciel | **Ouvert** |
| R-02 | Perte de fonctionnalités existantes | Régression | Moyenne | Élevé | Élevé | Golden master, étiquette de base | Retour arrière (G.4) | Ingénieur logiciel | Ouvert |
| R-03 | Perte silencieuse de l'historique/favoris à la migration | Données | Moyenne | Élevé | Élevé | P0-06, T-MIG-001, clés versionnées | Quarantaine, v1 conservé | Architecte de données | Ouvert |
| R-04 | Incompatibilité de données entre versions | Données | Moyenne | Moyen | Moyen | Schémas versionnés, migration non destructive | Lecture v1 conservée | Architecte de données | Ouvert |
| R-05 | Duplication/divergence de calculateurs (A-18) | Qualité | Moyenne | Moyen | Moyen | Consolider derrière golden master | Tests de comparaison | Ingénieur logiciel | Ouvert |
| R-06 | Erreur de facteur de conversion ou masse molaire | Scientifique | Moyenne | Élevé | Élevé | Base sourcée, statut `BLOQUÉ` par défaut, double validation | Version corrigée + signalement des enregistrements concernés | Biochimiste clinique | Ouvert |
| R-07 | Formule ou seuil obsolète (guides révisés, ex. ESC 2024 CHA₂DS₂-VA) | Scientifique | Élevée | Moyen | Élevé | Dates et versions dans le registre ; veille | Retrait/nouvelle version | Biologiste médical | Ouvert |
| R-08 | **Référence insuffisante ou citée sans lecture du texte source** (APRI/OMS, Padua, etc.) | Scientifique | Moyenne | Moyen | Moyen | Statut « réf. à reconfirmer » ; lecture du texte | Retrait de l'attribution | Biologiste médical | Ouvert |
| R-09 | **Interprétation présentée comme décision clinique** / confusion calcul-diagnostic | Sécurité clinique | Moyenne | Élevé | **Critique** | P1-16, libellés, D-03 | Avertissements, mode enseignement | Biologiste médical + UX | Ouvert |
| R-10 | Interprétations sans validation humaine (tension avec la section 2.5) | Gouvernance | Élevée | Élevé | **Critique** | P0-03, P0-07 | Bandeau « non validé » (D-08) | Biologiste médical | Ouvert |
| R-11 | Volume non pipetable proposé | Métrologique | Faible (module absent) | Élevé | Moyen | Règles issues des pipettes **de l'utilisateur** | Blocage si pipette inconnue | Métrologue | Futur |
| R-12 | Absence de tests sur stockage, réglages, service worker, écrans guidés | Qualité | Élevée | Moyen | Élevé | CI, tests dédiés | Tests manuels répétés | Ingénieur logiciel | Ouvert |
| R-13 | Dépendance réseau (premier chargement lourd, version.json) | Disponibilité | Moyenne | Moyen | Moyen | Service worker, budget de poids | Indicateur de chargement (fait) | Ingénieur logiciel | Atténué |
| R-14 | Fuite de données (stockage local non chiffré, appareils partagés) | Confidentialité | Faible | Moyen | Moyen | Aucune donnée nominative ; effacement | Chiffrement si l'historique devient sensible (D-07) | Architecte de données | Ouvert |
| R-15 | Incompatibilité multiplateforme (Safari/iOS, anciens WebView, natif jamais compilé) | Technique | Moyenne | Élevé | Élevé | T-COMP-001, T-OFF-001 | Dégradation gracieuse documentée | Ingénieur logiciel | **Non vérifié** |
| R-16 | Régression d'interface lors de la refonte de navigation | UX | Moyenne | Moyen | Moyen | Tests d'interface, D-13 | Indicateurs de fonctionnalité | UX/UI | Ouvert |
| R-17 | Poids et performance du premier chargement | Performance | Élevée | Moyen | Moyen | Budget, mesures | Allègement | Ingénieur logiciel | Ouvert |
| R-18 | Défaut d'accessibilité | Inclusion | Moyenne | Moyen | Moyen | Audit, tests | Corrections | UX/UI | Ouvert |
| R-19 | **Impossibilité de restauration** | Exploitation | Faible | Élevé | Élevé | P0-01, P0-08 | Répétition de restauration | Ingénieur logiciel | Ouvert |
| R-20 | Incohérence de version scientifique entre résultats historiques et base | Traçabilité | Moyenne | Élevé | Élevé | `EnregistrementDeCalcul` avec versions, base livrée avec l'application | Signalement des enregistrements concernés | Architecte de données | Ouvert |
| R-21 | **Audit non indépendant** (code produit par l'assistant) | Gouvernance | Certaine | Élevé | Élevé | D-01 relecture humaine | Revue externe ciblée | Spécialiste de validation | Ouvert |
| R-22 | Retour arrière impossible à annoncer (comparateur de versions) | Exploitation | Moyenne | Moyen | Moyen | Procédure « version supérieure » | Publication d'un patch de restauration | Ingénieur logiciel | Ouvert |
| R-23 | Ajout massif de constantes (masses molaires, chambres, McFarland) sans source | Scientifique | Moyenne | Élevé | Élevé | Statut `BLOQUÉ` par défaut, règle absolue (section 47) | Refus d'implémentation | Biochimiste clinique | Ouvert |
| R-24 | Désynchronisation manuelle des trois numéros de version | Exploitation | Moyenne | Faible | Faible | Contrôle en CI | Correction de patch | Ingénieur logiciel | Ouvert |

---

## 49.12 Décision de passage au code

### Conditions remplies

- [x] Audit initial terminé *(preuves : inspection + exécution du 03/10 ; **non indépendant**, voir limites)*
- [x] Architecture cible documentée *(proposition, aucune maquette)*
- [x] Cartographie fonctionnelle terminée
- [x] Arborescence des écrans documentée *(accueil Lab à confirmer, D-13)*
- [x] Base scientifique décrite
- [x] Registre initial des équations produit *(59 existantes + équations à ajouter ; **aucune « validée »**)*
- [ ] Plan de migration **validé** *(produit, **en attente de votre validation**)*
- [x] Plan de tests produit
- [x] Backlog priorisé produit
- [x] Risques identifiés
- [ ] Fonctionnalités existantes protégées *(**non** : ni étiquette de base ni golden master n'existent encore — P0-01/P0-02)*
- [ ] Absence de blocage critique non traité *(**non** : R-01, R-09, R-10, R-21 ouverts)*

### Décision

**NO-GO — Aucun développement fonctionnel ne doit commencer avant résolution des blocages ci-dessous.**
Un **GO CONDITIONNEL** limité aux tâches **P0-01, P0-02, P0-05, P0-06, P0-08** (sauvegarde, golden master, inventaire, quarantaine du stockage, rollback) peut être accordé dès que vous le décidez explicitement ; il ne modifie **aucun** résultat de calcul ni aucune formule.

### Blocages restants

1. **Validation explicite de ce dossier** par vous (section 50) — notamment du plan de migration.
2. **Décisions D-01 à D-15** (B.6 ; D-13 : accueil « Lab » vs onglet Calcul actuel ; D-14 : budget de performance ; D-15 : cible d'accessibilité), et en priorité **D-03** (politique d'interprétation, contradiction ISTH/4Ts), **D-04** (réglages sans effet), **D-05** (saisie décimale).
3. **Gouvernance de validation scientifique** (P0-07) : qui valide, selon quelle fiche ; sans elle, aucune équation ne peut être déclarée validée.
4. **Risque R-01** (facteur ×10 à la saisie) : à traiter en premier ; **à titre conservatoire, utilisez la virgule** comme séparateur décimal en mode virgule (ou passez en mode point) tant que le correctif n'est pas livré.
5. **Données scientifiques manquantes** pour les phases 2 à 4 : masses molaires par analyte, pKa, géométries de chambres, méthode OMS de spermiologie, norme de dénombrement microbien, valeurs McFarland, source du TEa, référence métrologique — **à fournir ou à faire rechercher et valider** ; tant qu'elles manquent, les éléments correspondants restent `BLOQUÉS`.
6. **Inventaire du matériel du laboratoire** (pipettes, chambres) et **plateformes prioritaires** (D-02).
7. **Relecture indépendante** (D-01) ou acceptation explicite de l'absence de relecture.

### Pour la suite

Dites-moi (a) si ce dossier est validé tel quel ou avec quelles corrections, (b) lesquelles des tâches P0 autorisées vous accordez, (c) vos décisions D-xx. Je ne modifierai rien avant votre réponse.
