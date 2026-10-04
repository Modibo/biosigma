#!/bin/sh
# Contrôle du budget de poids de la version web (backlog P6-02, décision D-14).
# Usage : sh tool/check_bundle_size.sh [build/web]
#
# Mesure la taille COMPRESSÉE (gzip -6, proche de ce que le serveur envoie) des
# fichiers du premier chargement sous Chrome/Edge et la compare à un budget.
# Les budgets ci-dessous sont PROVISOIRES (« pas de régression » : taille de la
# 1.16.0 + ~12 %) tant que la décision D-14 n'est pas confirmée par le
# responsable.
set -eu

DIR="${1:-build/web}"

# Budgets provisoires, en octets (gzip -6).
BUDGET_MAIN_GZ=1300000       # main.dart.js : mesuré 1 157 275 en 1.16.0
BUDGET_FIRST_LOAD_GZ=4000000 # premier chargement Chrome : mesuré ≈ 3,5 Mo

gz() { gzip -6 -c "$1" | wc -c | tr -d ' '; }

[ -d "$DIR" ] || { echo "ERREUR : dossier $DIR introuvable (construire d'abord : flutter build web --release --no-web-resources-cdn)" >&2; exit 2; }

total=0
fail=0
report() {
  f="$DIR/$1"
  if [ ! -f "$f" ]; then echo "  (absent) $1"; return; fi
  size=$(gz "$f")
  total=$((total + size))
  printf '  %-45s %10s octets compressés\n' "$1" "$size"
}

echo "Premier chargement (Chrome/Edge), tailles gzip -6 :"
for f in index.html flutter_bootstrap.js flutter.js main.dart.js biosigma_sw.js manifest.json \
         canvaskit/chromium/canvaskit.js canvaskit/chromium/canvaskit.wasm \
         assets/fonts/fallback/Roboto-Regular.ttf assets/fonts/MaterialIcons-Regular.otf \
         assets/assets/icon.png assets/FontManifest.json assets/AssetManifest.bin.json; do
  report "$f"
done
echo "  ----------------------------------------------------------"
printf '  %-45s %10s octets\n' "TOTAL estimé" "$total"

main_gz=$(gz "$DIR/main.dart.js")
echo
echo "Budget main.dart.js : $main_gz / $BUDGET_MAIN_GZ"
[ "$main_gz" -le "$BUDGET_MAIN_GZ" ] || { echo "ERREUR : main.dart.js dépasse le budget." >&2; fail=1; }
echo "Budget premier chargement : $total / $BUDGET_FIRST_LOAD_GZ"
[ "$total" -le "$BUDGET_FIRST_LOAD_GZ" ] || { echo "ERREUR : le premier chargement dépasse le budget." >&2; fail=1; }

[ "$fail" -eq 0 ] && echo "OK : budgets respectés." || exit 1
