# Déployer BioSigma sur biosigma.komodi-labo.org

Ce guide est spécifique au VPS OVH qui héberge déjà NexoLab et PhénoBac
(Caddy en conteneur `nexolab-api-caddy-1`, réseau Docker
`nexolab-api_default`) — pas un guide générique. BioSigma est une
application **statique** (Flutter Web) : aucun secret, aucune base de
données, aucun port à ouvrir autre que ceux déjà utilisés par Caddy.

## 0. Mettre le code sur le serveur

BioSigma n'a pas encore de dépôt Git à lui (il vit actuellement dans le
dossier de travail `MedLab SIL`, avec des documents sans rapport). Comme pour
PhénoBac, le plus simple est un dépôt séparé, cloné dans `/opt/biosigma` :

```bash
# Sur le Mac, DANS le dossier BioSigma/ (déjà initialisé en dépôt Git local) :
git remote add origin git@github.com:VOTRE_COMPTE/biosigma.git   # créez le dépôt vide sur GitHub d'abord
git push -u origin main
```

```bash
# Sur le VPS, une fois le dépôt poussé :
cd /opt
git clone git@github.com:VOTRE_COMPTE/biosigma.git   # ou par clé de déploiement, comme phenobac
cd biosigma
```

## 1. Premier démarrage (rien n'est encore public)

```bash
cp .env.example .env        # PROXY_NETWORK=nexolab-api_default est déjà renseigné
bash install-caddy.sh
```

La première construction compile l'application Flutter Web **dans**
l'image Docker (télécharge le SDK Flutter, ~1 Go) : comptez quelques
minutes. Les suivantes sont bien plus rapides (couches mises en cache tant
que le code ne change pas).

À l'issue, BioSigma écoute sur `127.0.0.1:8081`, joint au réseau de la
façade Caddy — **rien n'est encore accessible depuis l'internet**, c'est
voulu. Pour vérifier sans rien exposer :

```bash
ssh -L 8081:127.0.0.1:8081 VOTRE_COMPTE@VOTRE_SERVEUR
# puis http://127.0.0.1:8081 dans votre navigateur
```

## 2. Exposer sur biosigma.komodi-labo.org

1. Créez l'enregistrement DNS **A** pour `biosigma.komodi-labo.org` vers
   l'adresse de ce VPS (si ce n'est déjà fait), et attendez la propagation.
2. Ajoutez le contenu de [`deploy/Caddyfile.biosigma`](deploy/Caddyfile.biosigma)
   à la fin de `/home/ubuntu/nexolab-api/Caddyfile`, **sans toucher aux
   blocs existants** (NexoLab, PhénoBac).
3. Rechargez Caddy sans couper les autres sites :

   ```bash
   docker exec nexolab-api-caddy-1 caddy reload --config /etc/caddy/Caddyfile
   ```

4. Vérifiez :

   ```bash
   curl -s https://biosigma.komodi-labo.org/ | grep -o '<title>[^<]*</title>'
   ```

Caddy obtient et renouvelle seul le certificat HTTPS (Let's Encrypt) — ni
certbot, ni cron.

## Mettre à jour après une nouvelle livraison

```bash
# Sur le Mac : poussez vous-même (voir la note ci-dessous).
cd "…/BioSigma" && git push

# Sur le VPS :
cd /opt/biosigma && git pull && bash install-caddy.sh
```

`install-caddy.sh` reconstruit l'image (donc relance `flutter build web`
avec le code à jour) et redémarre le conteneur ; il est idempotent, sans
effet sur les autres sites de la façade.

**Rappel du piège déjà rencontré avec PhénoBac** : le déploiement se fait en
deux temps, sur deux machines différentes. Poussez depuis le Mac vous-même
(`prof.modibocoulibaly@…`), donnez seulement la commande du serveur à
exécuter dans la session SSH (`root@vps-…` ou l'utilisateur configuré). Ne
jamais annoncer « c'est déployé » sans l'avoir vérifié :

```bash
git log --oneline origin/main..HEAD          # doit être vide, côté Mac
curl -s https://biosigma.komodi-labo.org/ | grep -c BioSigma
```

## Vérifier

```bash
docker compose logs -f biosigma
curl -sI https://biosigma.komodi-labo.org/ | head -5
```

## Ce qui n'existe pas (volontairement)

- Pas de `.env` de secrets applicatifs : l'app ne calcule que côté client,
  rien à protéger côté serveur.
- Pas de base de données, pas de volume de données à sauvegarder.
- Pas d'API : `nginx` sert uniquement les fichiers statiques produits par
  `flutter build web`.
