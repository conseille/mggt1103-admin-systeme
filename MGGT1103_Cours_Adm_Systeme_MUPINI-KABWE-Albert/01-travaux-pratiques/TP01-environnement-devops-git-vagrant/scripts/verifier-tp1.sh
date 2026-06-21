#!/usr/bin/env bash

# Lanceur TP01
# Usage :
# ./verifier-tp1.sh console
# ./verifier-tp1.sh graphique

set -u

DIR="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-menu}"

case "$MODE" in
  console)
    "$DIR/verifier-tp1-console.sh"
    ;;
  graphique)
    "$DIR/verifier-tp1-graphique.sh"
    ;;
  *)
    echo "MGGT1103 - Vérification TP01"
    echo
    echo "1. Version console"
    echo "2. Version graphique"
    echo
    read -rp "Choix [1-2] : " choix

    case "$choix" in
      1) "$DIR/verifier-tp1-console.sh" ;;
      2) "$DIR/verifier-tp1-graphique.sh" ;;
      *) echo "Choix invalide." ;;
    esac
    ;;
esac
