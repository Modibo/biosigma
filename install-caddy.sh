#!/usr/bin/env bash
# install-caddy.sh — installer/mettre à jour BioSigma sur un serveur qui sert
# DÉJÀ un ou plusieurs sites via Caddy en conteneur (ce VPS : NexoLab, PhénoBac).
#
# Ce script ne touche ni à Caddy, ni aux certificats, ni au DNS. Il construit
# et démarre BioSigma en conteneur, écoutant sur la loopback, joint au réseau
# Docker de la façade Caddy. Idempotent : relancez-le sans crainte, y compris
# pour mettre à jour après un `git pull`.
#
# Usage :  bash install-caddy.sh
#          HOST_PORT=8090 bash install-caddy.sh    # pour imposer un port

set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$APP_DIR"

log(){ printf "\033[1;36m==>\033[0m %s\n" "$*"; }
avert(){ printf "\033[1;33mAttention:\033[0m %s\n" "$*"; }
err(){ printf "\033[1;31mErreur:\033[0m %s\n" "$*" >&2; exit 1; }

[ -f Dockerfile ] && [ -f docker-compose.yml ] || err "Lancez ce script depuis le dossier BioSigma (racine du dépôt)."

# --- Docker ---------------------------------------------------------------
command -v docker >/dev/null 2>&1 || err "Docker n'est pas installé. Installez-le, puis relancez :  curl -fsSL https://get.docker.com | sudo sh"
docker compose version >/dev/null 2>&1 || err "Le plugin 'docker compose' est manquant (paquet docker-compose-plugin)."
docker info >/dev/null 2>&1 || err "Le démon Docker ne répond pas. Démarrez-le (sudo systemctl start docker), ou ajoutez-vous au groupe 'docker'."

# --- Choix d'un port libre sur la loopback --------------------------------
port_occupe(){
  if command -v ss >/dev/null 2>&1; then ss -ltnH 2>/dev/null | awk '{print $4}' | grep -qE "[:.]$1\$"
  elif command -v lsof >/dev/null 2>&1; then lsof -iTCP:"$1" -sTCP:LISTEN -n -P >/dev/null 2>&1
  else return 1; fi
}

PORT="${HOST_PORT:-}"
if [ -z "$PORT" ] && [ -f .env ]; then
  PORT="$(sed -n 's/^HOST_PORT=//p' .env | tail -1)"
fi
if [ -z "$PORT" ]; then
  PORT=8081
  while port_occupe "$PORT" && [ "$PORT" -lt 8130 ]; do
    avert "le port $PORT est déjà pris sur cette machine — j'essaie le suivant"
    PORT=$((PORT+1))
  done
fi
log "BioSigma écoutera sur 127.0.0.1:$PORT (loopback uniquement)."

# --- Configuration ----------------------------------------------------------
if [ ! -f .env ]; then
  log "Création de .env à partir de .env.example…"
  cp .env.example .env
fi
if grep -q '^HOST_PORT=' .env; then
  sed -i.bak "s/^HOST_PORT=.*/HOST_PORT=$PORT/" .env && rm -f .env.bak
else
  printf 'HOST_PORT=%s\n' "$PORT" >> .env
fi

COMPOSE=(docker compose -f docker-compose.yml)
if grep -q '^PROXY_NETWORK=.\+' .env 2>/dev/null; then
  COMPOSE+=(-f docker-compose.caddy.yml)
  log "Réseau de façade détecté (PROXY_NETWORK) : la surcouche docker-compose.caddy.yml est utilisée."
else
  avert "PROXY_NETWORK n'est pas renseigné dans .env : BioSigma restera injoignable par Caddy (conteneur)."
fi

# --- Construction et démarrage ---------------------------------------------
# La compilation Flutter Web a lieu DANS l'image (voir Dockerfile) : ce
# build peut prendre quelques minutes la première fois (téléchargement du
# SDK Flutter), puis est mis en cache par Docker tant que le code ne change
# pas.
log "Construction et démarrage du conteneur (peut prendre plusieurs minutes la première fois)…"
"${COMPOSE[@]}" up -d --build

log "Attente de la sonde de santé…"
SANTE="à vérifier"
for _ in $(seq 1 60); do
  if curl -fsS "http://127.0.0.1:$PORT/" >/dev/null 2>&1; then SANTE="OK"; break; fi
  sleep 3
done

printf "\n\033[1;32m======== BioSigma est en service ========\033[0m\n"
cat <<FIN
  Écoute        : http://127.0.0.1:$PORT   (loopback — rien n'est public)
  Santé         : $SANTE

  Pour y jeter un œil depuis votre poste, sans rien exposer, ouvrez un tunnel :
      ssh -L $PORT:127.0.0.1:$PORT VOTRE_COMPTE@VOTRE_SERVEUR
  puis http://127.0.0.1:$PORT dans votre navigateur.

  QUAND LE DOMAINE biosigma.komodi-labo.org POINTE DÉJÀ VERS CE SERVEUR :
   1. Ajoutez le contenu de deploy/Caddyfile.biosigma au Caddyfile partagé
      (/home/ubuntu/nexolab-api/Caddyfile).
   2. Rechargez sans coupure des autres sites :
        docker exec nexolab-api-caddy-1 caddy reload --config /etc/caddy/Caddyfile
   3. Vérifiez :  curl -s https://biosigma.komodi-labo.org/ | grep -c BioSigma

  Logs        : docker compose logs -f
  Mise à jour : git pull && bash install-caddy.sh
FIN
