# Protocole de tests sur appareils réels (backlog P6-03, test T-OFF)

> **Pourquoi ce protocole** : BioSigma n'a été éprouvé qu'avec des tests automatiques, dans Chrome sur un Mac. **Android natif, iOS natif, Safari et Firefox n'ont jamais été essayés.** Ce document vous permet (ou à un collègue) de dérouler les mêmes scénarios sur chaque appareil, et de me renvoyer des résultats exploitables. Rien ne vaut un essai réel : c'est lui qui dira si le mode hors connexion, le stockage, l'impression et l'accessibilité tiennent en conditions réelles.

## 1. Avant de commencer

1. **Appareils à couvrir** (cochez ceux que vous avez, au moins 3 d'abord) :

| # | Appareil / navigateur | Disponible ? | Testeur | Date |
|---|---|---|---|---|
| A1 | Téléphone **Android**, Chrome | ☐ | | |
| A2 | Téléphone **Android**, Firefox | ☐ | | |
| I1 | **iPhone**, Safari | ☐ | | |
| I2 | **iPad**, Safari | ☐ | | |
| D1 | Ordinateur **Windows**, Chrome ou Edge | ☐ | | |
| D2 | Ordinateur **Mac**, Safari | ☐ | | |
| D3 | Ordinateur **Mac/Windows/Linux**, Firefox | ☐ | | |
| X | Un **téléphone d'entrée de gamme** (référence pour la performance) | ☐ | | |

2. **Version à tester** : ouvrez **À propos → Diagnostic de l'appareil** et notez la version affichée (doit être celle déployée).
3. **Connexion** : au moins un test avec une **connexion lente ou instable** si possible (c'est votre contexte réel).
4. **Ne saisissez aucune donnée de patient** : utilisez des valeurs fictives.

## 2. Scénarios (à dérouler sur chaque appareil)

Pour chacun : noter ✅ réussi / ⚠️ réussi avec réserve / ❌ échec, et décrire en une phrase.

| # | Scénario | Étapes | Résultat attendu |
|---|---|---|---|
| **S1** | **Premier chargement** | Appareil sans cache : ouvrir `https://biosigma.komodi-labo.org`. Chronométrer jusqu'à l'affichage de l'onglet Calcul. | L'application s'affiche ; **noter la durée et le type de connexion**. |
| **S2** | **Diagnostic** | À propos → Diagnostic de l'appareil → *Copier le rapport*. Le coller dans votre compte rendu. | Service worker « actif » (après un rechargement) ; stockage local « OK ». Tout ❌ ou ⚠️ doit être commenté. |
| **S3** | **Hors connexion** | Après S1 et un rechargement, **couper la connexion** (mode avion) ; fermer et rouvrir l'application ; faire un calcul. | L'application démarre et calcule **sans réseau**. |
| **S4** | **Calcul de référence** | Calcul → IMC : poids 70, taille 175 → Calculer. | Résultat **22,9** kg/m² ; avertissements lisibles. |
| **S5** | **Saisie décimale** | Dans un champ, taper `1.5` (point) en mode virgule. | Message « Séparateur ambigu » ; aucun calcul avec ×10. Puis `1,5` : accepté. |
| **S6** | **Convert** | Lab → Convert → Analyte → Glucose, 100 mg/dL → mmol/L. | **5,551** mmol/L ; formule C6H12O6 et masse molaire affichées. |
| **S7** | **Dilute (planificateur)** | Réglages : ajouter une pipette (ex. min 10, nominal 100, recommandé 20). Lab → Dilute → Planificateur : F = 10, 1000 µL. | Une stratégie avec la pipette indiquée. |
| **S8** | **Count (compteur tactile)** | Lab → Count → Formule : appuyer rapidement 20 fois sur « + », annuler 2 fois. | Le total est exact ; **pas de double comptage** ni de retard perceptible. Essayer **avec des gants** si pertinent. |
| **S9** | **Historique et stockage** | Réglages : activer l'historique ; faire 2 calculs ; fermer complètement le navigateur ; rouvrir. | L'historique est **toujours là**. **Répéter après quelques jours sans ouvrir BioSigma** (S9b) : certains navigateurs (notamment sur iPhone) peuvent effacer le stockage des sites peu utilisés. |
| **S10** | **Impression / PDF** | Un résultat → Imprimer / exporter → confirmer → Imprimer / PDF → « Enregistrer au format PDF ». | La page imprimée est lisible, complète, **sans identité de patient** ; noter tout défaut de mise en page. |
| **S11** | **Copie dans le presse-papiers** | Résultat → Copier ; coller dans une autre application. | Le texte est collé correctement. |
| **S12** | **Mise à jour** | Quand une nouvelle version est déployée : rouvrir l'application. | La bannière propose la mise à jour ; elle s'applique ; la version change. |
| **S13** | **Installation (PWA)** | Menu du navigateur → « Ajouter à l'écran d'accueil » / « Installer ». Ouvrir l'icône. | L'application s'ouvre en plein écran ; le diagnostic indique « installée : oui ». |
| **S14** | **Accessibilité** | Texte du système à 200 % ; lecteur d'écran (VoiceOver / TalkBack) sur S4 ; clavier sur ordinateur (Tab, Entrée). | Rien de coupé ; le résultat est annoncé ; tout est atteignable au clavier. Voir `accessibilite.md` §3. |
| **S15** | **Recherche universelle** | Loupe → « dfg », « glucose », « mmHg ». | Les résultats s'ouvrent. |
| **S16** | **Performance ressentie** | Sur le téléphone d'entrée de gamme : ouverture à froid, changement d'onglet, saisie fluide ? Noter toute lenteur. | Pas de blocage > 1 s perceptible. |

## 3. Comment me renvoyer les résultats

Copiez ce modèle, rempli, dans le message (un bloc par appareil) :

```
Appareil : (modèle, système, version)
Navigateur : (nom, version)
Version BioSigma : 
Connexion : (Wi-Fi / 4G / lente…)
Rapport de diagnostic : (coller)
S1 : durée ___ ; S2 : ✅/⚠️/❌ ; S3 : … ; S4 : … ; … S16 : …
Problèmes : (description, capture d'écran si possible)
```

## 4. Ce que je ferai avec vos résultats

- Corriger les défauts reproduits (je peux les rejouer dans Chrome ou par test automatisé).
- Fixer l'**objectif de démarrage** de la décision D-14 sur la mesure du téléphone de référence.
- Mettre à jour `accessibilite.md` et `performance.md`, et passer P6-03 à « fait » **seulement pour les appareils réellement testés**.

## 5. Limites

- Ce protocole ne remplace pas un test de recette formel ; il ne couvre pas Android et iOS **natifs** (applications installées depuis un magasin) : ils ne sont pas compilés, faute de SDK sur la machine de développement.
- Les résultats dépendent de l'appareil et du réseau du testeur : ils ne se généralisent pas à tous les appareils.
