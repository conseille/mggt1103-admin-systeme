#!/usr/bin/env bash

set -euo pipefail

mkdir -p "$HOME/mggt1103-tp2-resultats"

LOG="$HOME/mggt1103-tp2-resultats/diagnostic-performance.txt"

{
echo "============================================================"
echo "TP2 — Diagnostic performance Linux"
echo "============================================================"
echo
echo "Date : $(date)"
echo "Utilisateur : $(whoami)"
echo "Machine : $(hostname)"
echo

echo "-------------------- Système --------------------"
uname -a
echo

echo "-------------------- Mémoire --------------------"
free -h
echo

echo "-------------------- Disque --------------------"
df -h
echo

echo "-------------------- Réseau --------------------"
ip -br a 2>/dev/null || ip a
echo

echo "-------------------- Ports ouverts --------------------"
ss -tulpen 2>/dev/null || ss -tuln
echo

echo "-------------------- Charge système --------------------"
uptime
echo

echo "-------------------- Top processus CPU --------------------"
ps aux --sort=-%cpu | head -n 10
echo

echo "-------------------- Top processus mémoire --------------------"
ps aux --sort=-%mem | head -n 10
echo

echo "-------------------- iostat --------------------"
iostat 2>/dev/null || echo "iostat indisponible. Installer sysstat."
echo

echo "-------------------- sar CPU --------------------"
sar -u 1 3 2>/dev/null || echo "sar indisponible ou sysstat non actif."
echo

echo "-------------------- journaux récents --------------------"
journalctl -p warning -n 20 --no-pager 2>/dev/null || echo "journalctl indisponible."
echo
} | tee "$LOG"

echo
echo "Résultat enregistré dans : $LOG"
