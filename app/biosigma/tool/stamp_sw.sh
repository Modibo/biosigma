#!/bin/sh
# Remplace le marqueur __BUILD_ID__ de biosigma_sw.js par l'empreinte de
# main.dart.js + du service worker lui-même, après `flutter build web`. À lancer à chaque build destiné au
# déploiement (le Dockerfile le fait déjà) :
#   tool/stamp_sw.sh build/web
set -eu
DIR="${1:-build/web}"
if command -v sha256sum >/dev/null 2>&1; then H=sha256sum; else H="shasum -a 256"; fi
ID=$(cat "$DIR/main.dart.js" "$DIR/biosigma_sw.js" | $H | cut -c1-16)
sed -i.bak "s/__BUILD_ID__/$ID/" "$DIR/biosigma_sw.js" && rm -f "$DIR/biosigma_sw.js.bak"
echo "biosigma_sw.js tamponné : $ID"
