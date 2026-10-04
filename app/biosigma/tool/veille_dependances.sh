#!/bin/sh
# Veille de dépendances (backlog P6-04) : liste les paquets en retard dans les
# deux projets. Ne modifie rien ; ne fait pas échouer la commande (information).
# Usage : sh tool/veille_dependances.sh   (depuis app/biosigma)
set -u
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
echo "== Application Flutter (app/biosigma) =="
(cd "$ROOT/app/biosigma" && flutter pub outdated) || true
echo
echo "== Moteur Dart (packages/biosigma_core) =="
(cd "$ROOT/packages/biosigma_core" && dart pub outdated) || true
echo
echo "Version de Flutter utilisée pour valider :"
grep -n "flutter-version" "$ROOT/.github/workflows/ci.yml" || true
flutter --version 2>/dev/null | head -1 || true
