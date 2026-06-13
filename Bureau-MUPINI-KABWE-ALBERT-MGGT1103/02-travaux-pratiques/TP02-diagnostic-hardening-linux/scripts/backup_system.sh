#!/usr/bin/env bash

set -euo pipefail

BACKUP_DIR="$HOME/backups"
DATE_BACKUP="$(date +%Y%m%d-%H%M%S)"
ARCHIVE="$BACKUP_DIR/backup-system-$DATE_BACKUP.tar.gz"
LOG="$BACKUP_DIR/backup-system-$DATE_BACKUP.log"

mkdir -p "$BACKUP_DIR"

echo "============================================================" | tee "$LOG"
echo "Sauvegarde système — MGGT1103 TP2" | tee -a "$LOG"
echo "============================================================" | tee -a "$LOG"
echo "Date : $(date)" | tee -a "$LOG"
echo "Utilisateur : $(whoami)" | tee -a "$LOG"
echo "Machine : $(hostname)" | tee -a "$LOG"
echo | tee -a "$LOG"

echo "Création de l'archive..." | tee -a "$LOG"

tar -czf "$ARCHIVE" \
  /etc/passwd \
  /etc/group \
  /etc/hostname \
  /etc/hosts \
  /etc/ssh/sshd_config \
  2>>"$LOG" || true

echo | tee -a "$LOG"
echo "Archive créée : $ARCHIVE" | tee -a "$LOG"
echo "Journal : $LOG" | tee -a "$LOG"

ls -lh "$ARCHIVE" | tee -a "$LOG"
