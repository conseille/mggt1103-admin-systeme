#!/usr/bin/env bash

echo "============================================================"
echo "TP2 — Vérification des résultats"
echo "============================================================"
echo

echo "[1] Outils installés"
for outil in htop iotop iostat sar iftop getfacl setfacl lynis; do
  if command -v "$outil" >/dev/null 2>&1; then
    echo "OK     $outil"
  else
    echo "ABSENT $outil"
  fi
done

echo
echo "[2] Dossier des résultats"
if [ -d "$HOME/mggt1103-tp2-resultats" ]; then
  ls -lh "$HOME/mggt1103-tp2-resultats"
else
  echo "Aucun dossier de résultats trouvé."
fi

echo
echo "[3] Script backup_system.sh"
if [ -f backup_system.sh ]; then
  echo "OK     backup_system.sh"
  ls -lh backup_system.sh
else
  echo "ABSENT backup_system.sh dans le dossier courant"
fi

echo
echo "[4] Sysstat"
systemctl is-active sysstat 2>/dev/null || echo "sysstat non actif ou systemctl indisponible"
