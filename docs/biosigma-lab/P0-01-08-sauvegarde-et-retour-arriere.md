# P0-01 + P0-08 — Référence de version et retour arrière

Tâches du backlog : **P0-01** (référence Git de la version 1.6.0) et **P0-08**
(archive de l'image de production, procédure de retour arrière).
Statut : référence Git créée ; archive de l'image et répétition du retour
arrière **à exécuter par l'utilisateur** (je n'ai pas accès au VPS).

## 1. Référence Git

- Tag annoté `baseline-v1.6.0` sur le commit `cf1beae`
  (« Mode hors connexion réel sur le web… »), créé en local.
- Il n'est **pas encore publié** : `git push origin baseline-v1.6.0`
  (à lancer par l'utilisateur).
- Rôle : tout état ultérieur peut être comparé à cette version
  (`git diff baseline-v1.6.0`), et le golden master
  (`app/biosigma/test/golden/fixtures/baseline-v1.6.0.json`) en fige le
  comportement observable.

## 2. Archive de l'image de production (à faire AVANT tout déploiement ultérieur)

Sur le VPS, dans `/opt/biosigma` :

```bash
cd /opt/biosigma
docker image ls biosigma
docker tag biosigma:latest biosigma:1.6.0
mkdir -p /opt/biosigma-backups
docker save biosigma:1.6.0 | gzip > /opt/biosigma-backups/biosigma-1.6.0-image.tar.gz
sha256sum /opt/biosigma-backups/biosigma-1.6.0-image.tar.gz > /opt/biosigma-backups/biosigma-1.6.0-image.sha256
ls -lh /opt/biosigma-backups
```

Précondition : l'image `biosigma:latest` en place doit être bien celle de la
version 1.6.0 (vérifier que `curl -s https://biosigma.komodi-labo.org/version.json`
renvoie `1.6.0`). Si le VPS a été reconstruit depuis un autre commit, l'archive
ne serait pas la référence attendue.

Copie de la configuration de façade, **sans secret** (le Caddyfile ne contient
pas de jeton ; vérifier tout de même avant de copier) :

```bash
grep -inE "token|secret|password|key" /home/ubuntu/nexolab-api/Caddyfile
cp /home/ubuntu/nexolab-api/Caddyfile /opt/biosigma-backups/Caddyfile.$(date +%F)
```

Si la commande `grep` affiche une ligne, ne pas copier le fichier tel quel.

Récupération de l'archive sur le Mac (hors VPS) :

```bash
scp VOTRE_COMPTE@VOTRE_SERVEUR:/opt/biosigma-backups/biosigma-1.6.0-image.tar.gz ~/Documents/
```

### Contrôles effectués le 2026-10-03 (sorties relevées sur le VPS)

| Contrôle | Résultat |
|---|---|
| Version en ligne (`version.json`) | `1.6.0` |
| Commit déployé sur le VPS | `cf1beae` (= `baseline-v1.6.0`) |
| Image `biosigma:1.6.0` et `biosigma:latest` | même ID `3b3fb7b0a6e7` (132 Mo, 35,9 Mo compressé) |
| Archive `/opt/biosigma-backups/biosigma-1.6.0-image.tar.gz` (35 Mo) | lisible (`gunzip -t`), contenu listé (`blobs/sha256/…`) |
| Empreinte SHA-256 | `8cd8b795b9f04d02fe15b3b8401ab4f963159a998c7db68558388c62cd458135` (aussi dans `biosigma-1.6.0-image.sha256`) |
| Copie hors VPS (`scp` vers le Mac) | **non confirmée** à ce jour |
| Copie du Caddyfile | **non confirmée** à ce jour |
| Rechargement réel de l'archive (`docker load`) | **non fait** (voir §4) |

Limite : « lisible » et « contenu listé » prouvent que l'archive n'est pas tronquée, pas qu'elle redémarre. Seule la répétition du §4 le prouve.

## 3. Procédure de retour arrière

### Règle à connaître
Le vérificateur de mise à jour (`isNewerVersion`) n'annonce que les versions
**strictement supérieures**. Republier un ancien numéro de version ne fait donc
pas revenir les appareils déjà mis à jour. Un retour arrière doit être publié
sous un **numéro plus élevé** (ex. 1.6.0 → défectueuse 1.7.0 → retour 1.7.1
contenant le code de 1.6.0).

### Cas A — le site est cassé, il faut rétablir vite (serveur seulement)

```bash
cd /opt/biosigma
docker load < <(gunzip -c /opt/biosigma-backups/biosigma-1.6.0-image.tar.gz)
docker tag biosigma:1.6.0 biosigma:latest
docker compose up -d --no-build
```

Vérifier ensuite `https://biosigma.komodi-labo.org/version.json`.
Limite : les appareils qui ont déjà installé la version défectueuse restent
sur celle-ci tant qu'un numéro supérieur n'est pas publié (cas B).

### Cas B — rétablir aussi les appareils déjà mis à jour

Sur le Mac :

1. `git checkout -b retour-arriere baseline-v1.6.0`
2. Porter la version à un numéro supérieur à celui publié, dans les trois
   fichiers à garder synchronisés : `app/biosigma/pubspec.yaml`,
   `app/biosigma/lib/app_version.dart` (`kAppVersion`),
   `app/biosigma/web/version.json`.
3. `cd app/biosigma && flutter analyze && flutter test`
4. Commit, push, puis sur le VPS : `git pull && docker compose up -d --build`
   (voir la commande de mise à jour de `DEPLOY-VPS.md`).

### Données locales de l'utilisateur
Un retour arrière ne touche pas au stockage du navigateur ou du téléphone
(`biosigma.*.v1`). Depuis P0-06, une donnée illisible est conservée sous
`biosigma.quarantine.*` au lieu d'être écrasée.

## 4. À répéter une fois à blanc
Un retour arrière jamais essayé n'est pas une garantie. Répétition conseillée :
cas A sur le VPS à un moment creux (coupure de quelques secondes), puis noter la
durée réelle ici.

| Date | Cas répété | Durée | Résultat |
|---|---|---|---|
| — | — | — | non répété à ce jour |

## 5. Risques et retour arrière de cette tâche
- Aucun code applicatif modifié par P0-01/P0-08 : le tag et l'archive sont
  additifs. Supprimer le tag : `git tag -d baseline-v1.6.0`.
- `docker tag` ne modifie pas l'image en service.
- Limite : l'archive est une copie sur le même VPS ; la récupérer aussi hors
  serveur (commande `scp` ci-dessus).
