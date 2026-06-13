#!/usr/bin/env bash

set -euo pipefail

mkdir -p "$HOME/mggt1103-tp2-resultats"

LOG="$HOME/mggt1103-tp2-resultats/audit-lynis.txt"

echo "============================================================"
echo "TP2 — Audit sécurité Lynis"
echo "============================================================"
echo
echo "À exécuter dans la VM Ubuntu Server."
echo
echo "Ce script lance un audit Lynis et enregistre le résultat."
echo

if ! command -v lynis >/dev/null 2>&1; then
  echo "Lynis n'est pas installé."
  echo "Installe-le avec : sudo apt install -y lynis"
  exit 1
fi

read -r -p "Lancer l'audit Lynis avec sudo ? [o/N] : " reponse

case "$reponse" in
  o|O|oui|OUI)
    sudo lynis audit system | tee "$LOG"
    echo
    echo "Audit enregistré dans : $LOG"
    echo
    echo "Recherche du Hardening Index :"
    grep -i "Hardening index" "$LOG" || true
    ;;
  *)
    echo "Audit annulé."
    ;;
esac
