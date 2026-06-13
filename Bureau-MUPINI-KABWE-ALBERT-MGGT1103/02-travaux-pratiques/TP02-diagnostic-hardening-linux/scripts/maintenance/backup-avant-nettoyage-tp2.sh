#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$HOME/MGGT1103/SEANCE1-git-vagrant"
BACKUP_ROOT="$HOME/MGGT1103/backups-securite"
DATE_BACKUP="$(date '+%Y%m%d-%H%M%S')"
BACKUP_DIR="$BACKUP_ROOT/backup-avant-nettoyage-tp2-$DATE_BACKUP"
ARCHIVE="$BACKUP_ROOT/backup-avant-nettoyage-tp2-$DATE_BACKUP.tar.gz"

echo "============================================================"
echo "BACKUP DE SÉCURITÉ — AVANT NETTOYAGE TP2"
echo "============================================================"
echo

mkdir -p "$BACKUP_ROOT"

echo "[1] Dossier source"
echo "$BASE_DIR"
echo

echo "[2] Dossier backup"
echo "$BACKUP_DIR"
echo

cp -a "$BASE_DIR" "$BACKUP_DIR"

echo "[3] Création de l'archive compressée"
tar -czf "$ARCHIVE" -C "$BACKUP_ROOT" "$(basename "$BACKUP_DIR")"

echo
echo "[4] Vérification du backup"
ls -lh "$ARCHIVE"
echo

echo "[5] Contenu sauvegardé"
tree "$BACKUP_DIR" -L 2 2>/dev/null || find "$BACKUP_DIR" -maxdepth 2 -type d

echo
echo "============================================================"
echo "BACKUP TERMINÉ AVEC SUCCÈS"
echo "============================================================"
echo
echo "Archive créée :"
echo "$ARCHIVE"
echo
echo "Dossier sauvegardé :"
echo "$BACKUP_DIR"
echo
echo "Tu peux maintenant lancer le script de nettoyage."
