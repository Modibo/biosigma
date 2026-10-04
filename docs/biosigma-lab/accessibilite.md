# Accessibilité de BioSigma (backlog P6-01, décision D-15)

> **Cible de travail : WCAG 2.1 niveau AA** — proposée par l'assistant dans le dossier d'audit, appliquée ici « à confirmer » par le responsable (D-15). Ce document dit ce qui est **vérifié automatiquement**, ce qui a été **corrigé**, et ce qui **reste à éprouver sur de vrais appareils**.

## 1. Vérifié automatiquement (tests dans `app/biosigma/test/accessibility/`)

| Critère WCAG | Vérification | Résultat |
|---|---|---|
| 1.4.3 Contraste du texte (4,5:1) | `textContrastGuideline` de Flutter sur 10 écrans × thèmes clair et sombre (20 tests) | **Conforme** après correction (voir §2) |
| 2.5.5 / 2.5.8 Taille des cibles tactiles | `androidTapTargetGuideline` (48 × 48 dp) et `iOSTapTargetGuideline` (44 × 44 pt), mêmes écrans | Conforme |
| 4.1.2 Nom, rôle, valeur | `labeledTapTargetGuideline` : toute cible tactile a une étiquette sémantique | Conforme |
| 1.4.4 Redimensionnement du texte (200 %) | 11 écrans à 200 % sur 360 px et 320 px de large : **aucun débordement** | Conforme après correction |
| 1.4.10 Reflow (320 px) | 11 écrans à 320 px de large, texte 100 % et 200 % | Conforme après correction |
| 2.1.1 Clavier | Tab parcourt Convert sans blocage ; le bouton « Convertir » est atteignable puis activé au clavier (Entrée) | Conforme sur ces parcours |
| 4.1.3 Messages d'état | Le résultat est une **région vive** : annoncé par les lecteurs d'écran à son apparition ; les avertissements bloquants l'étaient déjà | Conforme (structure) |
| Mode sélectionné annoncé | Les pastilles de mode portent l'état « sélectionné » | Conforme |

Les tests ont été **éprouvés par mutation** : avec l'ancien thème, ils échouent (contrastes mesurés de 2,78:1 et 2,96:1) ; avec le thème corrigé, ils passent.

## 2. Corrections apportées

1. **Contraste du thème clair** : le cyan de la marque (2,96:1 sur blanc) ne convient pas au texte ni aux boutons. Texte et boutons utilisent maintenant un **cyan foncé `#0B6CA3` (5,7:1)** ; le cyan d'origine reste pour le logo. Avertissement « attention » assombri (`#9A5B00`, 5,4:1) et corail de texte foncé (`#C62F22`, 5,5:1). Le thème sombre était déjà conforme.
2. **Texte agrandi** : la limite d'agrandissement passait de 160 % à **200 %**.
3. **Reflow** : sur écran étroit (< 380 px), l'unité d'un champ passe **sous** le champ au lieu de déborder ; les choix de mode (Convert, Dilute, Prepare, Count) sont des **pastilles qui passent à la ligne** au lieu de boutons segmentés qui débordaient.
4. **Annonces** : résultat déclaré région vive.

## 3. Ce qui n'est PAS vérifié (à faire sur appareils réels — checklist)

Les tests automatiques ne remplacent pas un essai avec une technologie d'assistance. À faire par vous ou un utilisateur concerné, et à me rapporter :

- [ ] **Lecteur d'écran** : VoiceOver (iPhone/Mac, Safari) ou TalkBack (Android, Chrome) : parcourir Calcul → un calcul → saisir → Calculer ; le résultat est-il annoncé ? les étiquettes des champs sont-elles claires ? les unités sont-elles comprises ?
- [ ] **Navigation au clavier sur ordinateur** (Chrome, Firefox, Safari) : Tab / Maj+Tab / Entrée / espace sur Convert, Dilute (planificateur), Count (compteur tactile), Réglages.
- [ ] **Agrandissement du texte du système** (200 %) sur téléphone réel, et zoom du navigateur à 200 %/400 %.
- [ ] **Mode contraste élevé / réduction des animations** du système.
- [ ] **Safari et Firefox** (jamais testés), **Android et iOS natifs** (jamais compilés).
- [ ] **Compteur tactile (Count)** : essai avec un seul doigt, gants, écran mouillé (usage à la paillasse).
- [ ] **Daltonisme** : les alertes ne reposent pas sur la seule couleur (icône + libellé « Alertes »), mais un essai avec un simulateur est conseillé.

## 4. Limites connues

- Pas d'audit WCAG complet par un expert : ce document ne vaut **pas** déclaration de conformité.
- Le canevas Flutter Web expose l'accessibilité par une couche sémantique qui peut varier selon le navigateur ; le comportement avec chaque lecteur d'écran n'est pas garanti.
- Les ordres de focus personnalisés, les raccourcis clavier propres à l'application et le mode « focus visible » renforcé ne sont pas implémentés.
- Les textes des interprétations sont longs : une lecture à voix haute peut être pénible (pas de version résumée).
