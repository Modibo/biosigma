# Résultats des essais sur appareils réels (backlog P6-03)

> Registre des essais déclarés par les testeurs, selon `protocole-tests-appareils.md`. **Chaque ligne est un compte rendu déclaré, pas une mesure de l'assistant** : l'assistant n'a pas accès aux appareils. Ce qui n'est pas renseigné reste « non précisé » ; rien n'est complété par supposition.

## Essais enregistrés

| Date | Testeur | Appareil | Système | Navigateur | Version BioSigma | Scénarios | Résultat déclaré | Rapport de diagnostic |
|---|---|---|---|---|---|---|---|---|
| 2026-10-04 | Dr M. M. Coulibaly | iPhone | iOS (version non précisée) | Safari (version non précisée) | **1.17.0** (lue au diagnostic) | « tous » (S1-S16) | **Aucun problème** | non fourni |

### Points à préciser pour que cet essai soit pleinement exploitable

- **Version d'iOS et de Safari**, modèle d'iPhone (nécessaire pour dire sur quoi l'application a été éprouvée).
- **S1** : durée du premier chargement et type de connexion (donnée de performance, D-14).
- **S9b** (persistance de l'historique après plusieurs jours sans ouvrir BioSigma) et **S12** (mise à jour vers une nouvelle version) ne peuvent être constatés qu'**après** un délai ou **après** le déploiement d'une version suivante : si « tous » les couvrait, indiquer comment ; sinon ils restent à faire.
- **S14** (accessibilité : texte 200 %, VoiceOver) et **S16** (téléphone d'entrée de gamme) : confirmer qu'ils ont bien été passés.
- Le **rapport de diagnostic** copié (À propos → Diagnostic) permettrait de consigner l'état exact : service worker, stockage persistant, mode installé.

## Couverture actuelle de la matrice du protocole

| Appareil / navigateur | État |
|---|---|
| A1 Android, Chrome | non testé |
| A2 Android, Firefox | non testé |
| **I1 iPhone, Safari** | **testé (déclaré, voir ci-dessus)** |
| I2 iPad, Safari | non testé |
| D1 Windows, Chrome/Edge | non testé |
| D2 Mac, Safari | non testé |
| D3 Firefox (ordinateur) | non testé |
| X Téléphone d'entrée de gamme | non testé |

Chrome sur Mac est éprouvé par les tests automatiques de l'assistant (pas par un essai manuel).
