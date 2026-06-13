#!/usr/bin/env bash

echo "============================================================"
echo "VÉRIFICATION GÉNÉRIQUE — RENDU MGGT1103"
echo "============================================================"
echo

echo "[1] Dossier analysé"
pwd

echo
echo "[2] Dépôt Git distant"
git remote -v 2>/dev/null || echo "Aucun dépôt Git distant détecté"

echo
echo "[3] Branche active"
git branch --show-current 2>/dev/null || echo "Aucune branche Git détectée"

echo
echo "[4] État Git"
git status --short 2>/dev/null || echo "Ce dossier n'est pas un dépôt Git"

echo
echo "[5] Derniers commits"
git log --oneline --decorate -5 2>/dev/null || echo "Aucun commit détecté"

echo
echo "------------------------------------------------------------"
echo "Vérification des fichiers principaux"
echo "------------------------------------------------------------"

for file in README.md Vagrantfile rapport-seance1.md rapport_hardening.md backup_system.sh; do
  if [ -f "$file" ]; then
    echo "OK     $file"
  else
    echo "ABSENT $file"
  fi
done

echo
echo "------------------------------------------------------------"
echo "Vérification des dossiers importants"
echo "------------------------------------------------------------"

for dir in captures Bureau-MUPINI-KABWE-ALBERT-MGGT1103; do
  if [ -d "$dir" ]; then
    echo "OK     $dir/"
  else
    echo "ABSENT $dir/"
  fi
done

echo
echo "------------------------------------------------------------"
echo "Captures trouvées"
echo "------------------------------------------------------------"

find . -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | sort || echo "Aucune capture trouvée"

echo
echo "------------------------------------------------------------"
echo "Rapports trouvés"
echo "------------------------------------------------------------"

find . -type f \( -iname "*.md" -o -iname "*.pdf" -o -iname "*.docx" \) | sort

echo
echo "------------------------------------------------------------"
echo "Scripts trouvés"
echo "------------------------------------------------------------"

find . -type f -iname "*.sh" | sort

echo
echo "------------------------------------------------------------"
echo "Vagrantfile"
echo "------------------------------------------------------------"

if [ -f Vagrantfile ]; then
  echo "Vagrantfile présent."
  echo
  echo "Aperçu du Vagrantfile :"
  head -n 30 Vagrantfile
else
  echo "Vagrantfile absent."
fi

echo
echo "============================================================"
echo "FIN DE LA VÉRIFICATION"
echo "============================================================"
