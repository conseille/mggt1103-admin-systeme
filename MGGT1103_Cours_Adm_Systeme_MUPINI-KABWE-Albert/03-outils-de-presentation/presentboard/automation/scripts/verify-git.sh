#!/usr/bin/env bash
set -euo pipefail

echo "===== VERIFICATION GIT ====="
echo

echo "Dossier courant :"
pwd
echo

echo "Branche actuelle :"
git branch --show-current 2>/dev/null || echo "Aucune branche détectée"
echo

echo "Remote :"
git remote -v 2>/dev/null || echo "Aucun remote détecté"
echo

echo "Derniers commits :"
git log --oneline --decorate -10 2>/dev/null || echo "Aucun commit détecté"
echo

echo "Etat du dépôt :"
git status --short 2>/dev/null || echo "Impossible de lire git status"
echo

echo "Fichiers suivis par Git :"
git ls-files 2>/dev/null | head -n 80
echo

echo "Fichiers non suivis :"
git ls-files --others --exclude-standard 2>/dev/null || true
echo

echo "Fichiers ignorés :"
git ls-files --ignored --exclude-standard -o 2>/dev/null || true
