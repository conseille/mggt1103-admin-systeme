#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$HOME/MGGT1103/SEANCE1-git-vagrant"
TP2_DIR="$BASE_DIR/Bureau-MUPINI-KABWE-ALBERT-MGGT1103/02-travaux-pratiques/TP2-diagnostic-hardening-linux"

echo "============================================================"
echo "VÉRIFICATION GÉNÉRALE TP2 — MGGT1103"
echo "============================================================"
echo

echo "[1] Vérification des dossiers principaux"
for dir in captures documents rapport scripts; do
  if [ -d "$TP2_DIR/$dir" ]; then
    echo "OK     $dir/"
  else
    echo "ABSENT $dir/"
  fi
done

echo
echo "[2] Vérification des fichiers obligatoires du TP2"

check_file() {
  local file="$1"
  if [ -f "$file" ]; then
    echo "OK     ${file#$TP2_DIR/}"
  else
    echo "ABSENT ${file#$TP2_DIR/}"
  fi
}

check_file "$TP2_DIR/rapport/rapport_hardening.md"
check_file "$TP2_DIR/scripts/backup_system.sh"
check_file "$TP2_DIR/documents/diagnostic-performance.txt"
check_file "$TP2_DIR/documents/audit-lynis.txt"
check_file "$TP2_DIR/documents/corrections-lynis.txt"

echo
echo "[3] Vérification des scripts TP2"

for script in \
  01-installer-outils-tp2.sh \
  02-diagnostic-performance-tp2.sh \
  03-audit-lynis-tp2.sh \
  04-generer-backup-system.sh \
  05-guide-hardening-sensible-tp2.sh \
  06-verifier-resultats-tp2.sh \
  backup_system.sh \
  preparer-rendu-tp2.sh \
  organiser-captures-tp2.sh \
  verifier-structure-tp2.sh
do
  if [ -f "$TP2_DIR/scripts/$script" ]; then
    if [ -x "$TP2_DIR/scripts/$script" ]; then
      echo "OK     $script"
    else
      echo "NON EXÉCUTABLE $script"
    fi
  else
    echo "ABSENT $script"
  fi
done

echo
echo "[4] Vérification des captures"

if [ -d "$TP2_DIR/captures" ]; then
  ls -lh "$TP2_DIR/captures"
else
  echo "Dossier captures absent."
fi

echo
echo "[5] Détection des noms de captures à corriger"

find "$TP2_DIR/captures" -type f | while read -r file; do
  name="$(basename "$file")"

  if [[ "$name" == *" "* ]]; then
    echo "NOM AVEC ESPACE      $name"
  fi

  if [[ "$name" == *".png.png" ]]; then
    echo "DOUBLE EXTENSION     $name"
  fi

  if [[ "$name" =~ [A-Z] ]]; then
    echo "MAJUSCULES           $name"
  fi
done

echo
echo "[6] Vérification rapide du rapport"

if [ -f "$TP2_DIR/rapport/rapport_hardening.md" ]; then
  echo "Nombre de lignes du rapport :"
  wc -l "$TP2_DIR/rapport/rapport_hardening.md"

  echo
  echo "Recherche des éléments demandés :"

  grep -qi "Hardening index : 59" "$TP2_DIR/rapport/rapport_hardening.md" && echo "OK     Hardening index initial 59" || echo "ABSENT Hardening index initial 59"
  grep -qi "Hardening index : 60" "$TP2_DIR/rapport/rapport_hardening.md" && echo "OK     Hardening index final 60" || echo "ABSENT Hardening index final 60"
  grep -qi "SIGTERM" "$TP2_DIR/rapport/rapport_hardening.md" && echo "OK     SIGTERM" || echo "ABSENT SIGTERM"
  grep -qi "SIGKILL" "$TP2_DIR/rapport/rapport_hardening.md" && echo "OK     SIGKILL" || echo "ABSENT SIGKILL"
  grep -qi "limits.conf" "$TP2_DIR/rapport/rapport_hardening.md" && echo "OK     limits.conf" || echo "ABSENT limits.conf"
  grep -qi "backup_system.sh" "$TP2_DIR/rapport/rapport_hardening.md" && echo "OK     backup_system.sh" || echo "ABSENT backup_system.sh"
else
  echo "Rapport absent."
fi

echo
echo "[7] État Git actuel"
cd "$BASE_DIR"
git status --short

echo
echo "============================================================"
echo "FIN DE LA VÉRIFICATION TP2"
echo "============================================================"
