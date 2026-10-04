#!/bin/sh
# Vérifie que les trois numéros de version restent synchronisés
# (pubspec.yaml, lib/app_version.dart, web/version.json) — règle de livraison
# de BioSigma : un oubli empêche les appareils de voir la mise à jour.
# Usage : sh tool/check_versions.sh   (depuis app/biosigma)
set -eu

pub=$(sed -n 's/^version: \([0-9][0-9.]*\)+.*/\1/p' pubspec.yaml)
dart=$(sed -n "s/.*kAppVersion = '\([0-9][0-9.]*\)'.*/\1/p" lib/app_version.dart)
json=$(sed -n 's/.*"latest": *"\([0-9][0-9.]*\)".*/\1/p' web/version.json)

echo "pubspec.yaml : $pub"
echo "app_version.dart : $dart"
echo "version.json : $json"

if [ -z "$pub" ] || [ "$pub" != "$dart" ] || [ "$pub" != "$json" ]; then
  echo "ERREUR : les trois versions doivent être identiques et non vides." >&2
  exit 1
fi
echo "OK : versions cohérentes ($pub)."
