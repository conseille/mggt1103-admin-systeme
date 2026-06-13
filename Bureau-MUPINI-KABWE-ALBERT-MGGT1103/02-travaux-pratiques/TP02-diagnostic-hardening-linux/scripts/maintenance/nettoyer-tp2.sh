#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$HOME/MGGT1103/SEANCE1-git-vagrant"
BUREAU="$BASE_DIR/Bureau-MUPINI-KABWE-ALBERT-MGGT1103"
TP2="$BUREAU/02-travaux-pratiques/TP2-diagnostic-hardening-linux"

echo "============================================================"
echo "NETTOYAGE TP2 — MGGT1103"
echo "============================================================"
echo

cd "$BASE_DIR"

mkdir -p "_backup-nettoyage-tp2"

echo "[1] Suppression des fichiers temporaires inutiles"

rm -f 00-reprendre-session-tp2.sh
rm -f 00-sauvegarder-session-tp2.sh
rm -f rapport_hardening.md
rm -f backup_system.sh
rm -f diagnostic-performance.txt
rm -f audit-lynis.txt
rm -f corrections-lynis.txt

find . -name "*~" -delete
find . -name "*.tmp" -delete
find . -name "*.bak" -delete
find . -name "*.Zone.Identifier" -delete
find . -name ".DS_Store" -delete
find . -name "Thumbs.db" -delete

echo "OK fichiers temporaires nettoyés"
echo

echo "[2] Vérification du dossier principal TP2"

mkdir -p "$TP2/captures"
mkdir -p "$TP2/documents"
mkdir -p "$TP2/rapport"
mkdir -p "$TP2/scripts"

echo "OK structure TP2 présente"
echo

echo "[3] Nettoyage des captures avec noms non professionnels"

cd "$TP2/captures"

rename_if_exists() {
  old="$1"
  new="$2"

  if [ -f "$old" ]; then
    if [ -f "$new" ]; then
      mv "$old" "$BASE_DIR/_backup-nettoyage-tp2/$old"
    else
      mv "$old" "$new"
    fi
  fi
}

rename_if_exists "Hardening-index initial.png.png" "01-hardening-index-initial-59.png"
rename_if_exists "hardening Initial 1.png.png" "01-hardening-index-initial-59-bis.png"
rename_if_exists "audit Lynis .png" "02-audit-lynis.png"
rename_if_exists "capture Diagnostic et audit.png" "03-diagnostic-et-audit.png"
rename_if_exists "diagnostic-performance.png.png" "04-diagnostic-performance.png"
rename_if_exists "capture backup-system.png" "05-backup-system-teste.png"
rename_if_exists "Capture correction lynis.png" "06-corrections-lynis.png"
rename_if_exists "HARDENING INDEX-60.png" "07-hardening-index-final-60.png"
rename_if_exists "capture Hardening.png" "08-hardening-verification.png"

cd "$BASE_DIR"

echo "OK captures renommées si nécessaire"
echo

echo "[4] Suppression des doublons globaux inutiles"

# On garde les captures principales seulement dans le dossier TP2.
# Le dossier 06-preuves-et-captures/tp2 peut être recréé plus tard si besoin.
rm -rf "$BUREAU/06-preuves-et-captures/tp2"
mkdir -p "$BUREAU/06-preuves-et-captures/tp2"
touch "$BUREAU/06-preuves-et-captures/tp2/.gitkeep"

# On garde le rapport principal dans le dossier TP2.
# Le dossier global des rapports reste vide pour éviter la répétition.
rm -rf "$BUREAU/07-rapports/tp2"
mkdir -p "$BUREAU/07-rapports/tp2"
touch "$BUREAU/07-rapports/tp2/.gitkeep"

echo "OK doublons globaux réduits"
echo

echo "[5] Vérification des fichiers obligatoires"

check_file() {
  if [ -f "$1" ]; then
    echo "OK     ${1#$BASE_DIR/}"
  else
    echo "ABSENT ${1#$BASE_DIR/}"
  fi
}

check_file "$TP2/rapport/rapport_hardening.md"
check_file "$TP2/scripts/backup_system.sh"
check_file "$TP2/documents/diagnostic-performance.txt"
check_file "$TP2/documents/audit-lynis.txt"
check_file "$TP2/documents/corrections-lynis.txt"

echo

echo "[6] Vérification des captures propres"

ls -lh "$TP2/captures"

echo

echo "[7] Détection restante des noms sales"

find "$TP2/captures" -type f | while read -r file; do
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

echo "[8] État Git après nettoyage"

cd "$BASE_DIR"
git status --short

echo
echo "============================================================"
echo "NETTOYAGE TERMINÉ"
echo "============================================================"
echo
echo "Avant commit, vérifie le résultat avec :"
echo "tree Bureau-MUPINI-KABWE-ALBERT-MGGT1103/02-travaux-pratiques/TP2-diagnostic-hardening-linux -L 3"
echo
echo "Puis :"
echo "git add -A"
echo "git status --short"
