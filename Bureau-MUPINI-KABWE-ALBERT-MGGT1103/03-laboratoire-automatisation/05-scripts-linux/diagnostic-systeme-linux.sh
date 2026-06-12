#!/usr/bin/env bash

echo "Diagnostic système Linux"
echo

echo "[Utilisateur]"
whoami

echo
echo "[Machine]"
hostname

echo
echo "[Noyau]"
uname -a

echo
echo "[Mémoire]"
free -h

echo
echo "[Disque]"
df -h

echo
echo "[Réseau]"
ip -br a 2>/dev/null || ip a

echo
echo "[Processus CPU]"
ps aux --sort=-%cpu | head -n 10
