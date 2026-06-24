#!/usr/bin/env bash
set -euo pipefail

echo "===== VERIFICATION DU PROJET WSL ====="
echo

echo "Utilisateur : $(whoami)"
echo "Machine : $(hostname)"
echo "Dossier : $(pwd)"
echo

echo "===== STRUCTURE PRINCIPALE ====="
tree -L 3 . 2>/dev/null || find . -maxdepth 3 -type d
echo

echo "===== README RACINE ====="
test -f README.md && echo "OK README.md présent" || echo "ABSENT README.md"
echo

echo "===== DOSSIERS TP DETECTES ====="
find . -maxdepth 4 -type d -iname "TP*" | sort
echo

echo "===== RAPPORTS DETECTES ====="
find . -type f \( -iname "*.md" -o -iname "*.docx" -o -iname "*.pdf" \) | sort
echo

echo "===== CAPTURES DETECTEES ====="
find . -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | sort
echo

echo "===== SCRIPTS DETECTES ====="
find . -type f \( -iname "*.sh" -o -iname "*.ps1" -o -iname "*.py" \) | sort
echo

echo "===== ANCIENNES STRUCTURES A DETECTER ====="
find . -path "*Bureau-MUPINI*" -o -path "*09-suivi-personnel*" -o -path "*05-bibliotheque-technique*" || true
