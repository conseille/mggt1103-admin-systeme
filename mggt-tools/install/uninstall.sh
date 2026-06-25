#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$HOME/.local/share/mggt-tools"
BIN_DIR="$HOME/.local/bin"

echo "============================================================"
echo "Désinstallation de mggt-tools"
echo "============================================================"
echo

for tool in mggt-assistant mggt-doctor tpnav gitnav vagrantnav; do
  rm -f "$BIN_DIR/$tool"
  echo "[OK] commande supprimée : $tool"
done

rm -rf "$APP_DIR"
echo "[OK] dossier supprimé : $APP_DIR"

echo
echo "Désinstallation terminée."
