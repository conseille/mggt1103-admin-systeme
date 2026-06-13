#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$HOME/MGGT1103/SEANCE1-git-vagrant"
TP2_DIR="$BASE_DIR/Bureau-MUPINI-KABWE-ALBERT-MGGT1103/02-travaux-pratiques/TP2-diagnostic-hardening-linux"
CAPTURES_DIR="$TP2_DIR/captures"
GLOBAL_CAPTURES="$BASE_DIR/Bureau-MUPINI-KABWE-ALBERT-MGGT1103/06-preuves-et-captures/tp2"

mkdir -p "$CAPTURES_DIR"
mkdir -p "$GLOBAL_CAPTURES"

echo "============================================================"
echo "Organisation des captures TP2 — MGGT1103"
echo "============================================================"
echo

if ls "$CAPTURES_DIR"/*.png >/dev/null 2>&1; then
  cp "$CAPTURES_DIR"/*.png "$GLOBAL_CAPTURES/"
  echo "OK : captures copiées dans le dossier global des preuves."
else
  echo "Aucune capture PNG trouvée dans le dossier TP2."
fi

echo
echo "Captures TP2 :"
ls -lh "$CAPTURES_DIR"

echo
echo "Preuves globales TP2 :"
ls -lh "$GLOBAL_CAPTURES"
