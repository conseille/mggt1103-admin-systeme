#!/usr/bin/env bash
set -euo pipefail

echo "===== VERIFICATION ENVIRONNEMENT WSL ====="
echo

echo "Utilisateur : $(whoami)"
echo "Machine     : $(hostname)"
echo "Dossier     : $(pwd)"
echo

echo "===== VERSION SYSTEME ====="
uname -a
echo

echo "===== OUTILS DISPONIBLES ====="
for cmd in git php tree vagrant terraform code; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK      $cmd : $($cmd --version 2>/dev/null | head -n 1)"
  else
    echo "ABSENT  $cmd"
  fi
done
