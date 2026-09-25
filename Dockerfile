# BioSigma — image de service pour l'hébergement web (sous-domaine).
#
# Construction en deux étapes : la première compile l'application Flutter
# pour le web (aucun outil Flutter requis sur la machine hôte, tout se passe
# dans l'image) ; la seconde ne contient que les fichiers statiques produits,
# servis par nginx. Aucun secret, aucune base de données — l'app calcule
# entièrement côté client.
#
# Construction et démarrage :  docker compose up -d --build

# ---- Étape 1 : compilation Flutter Web ------------------------------------
FROM debian:bookworm-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
      curl ca-certificates git xz-utils \
    && rm -rf /var/lib/apt/lists/*

ARG FLUTTER_VERSION=3.47.5
RUN curl -fsSL -o /tmp/flutter.tar.xz \
      "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    && tar -xf /tmp/flutter.tar.xz -C /opt \
    && rm /tmp/flutter.tar.xz
ENV PATH="/opt/flutter/bin:${PATH}"

# Le dépôt Flutter doit appartenir à l'utilisateur courant (racine ici) pour
# que `flutter` accepte de s'exécuter dedans.
RUN git config --global --add safe.directory /opt/flutter \
    && flutter config --no-analytics \
    && flutter precache --web

WORKDIR /src
# Le moteur de calcul pur est une dépendance locale (path:) de l'app Flutter.
COPY packages/biosigma_core ./packages/biosigma_core
COPY app/biosigma ./app/biosigma

WORKDIR /src/app/biosigma
RUN flutter pub get
RUN flutter build web --release

# ---- Étape 2 : service statique -------------------------------------------
FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/app/biosigma/build/web /usr/share/nginx/html
# `flutter build web` (exécuté en root dans l'étape précédente) produit des
# fichiers en mode 700 : illisibles par l'utilisateur nginx du conteneur
# final, d'où un 403 sans ce correctif de permissions.
RUN chmod -R a+rX /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=4s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:80/ >/dev/null || exit 1
