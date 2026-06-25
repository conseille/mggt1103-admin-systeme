#!/usr/bin/env bash
set -euo pipefail

echo "[CLIENT] Mise à jour du système"
apt-get update -y

echo "[CLIENT] Installation des outils de test"
apt-get install -y dnsutils curl iputils-ping

echo "[CLIENT] Configuration DNS vers srv-dns"
rm -f /etc/resolv.conf
cat > /etc/resolv.conf <<'RESOLV'
nameserver 192.168.56.10
search mggt1103.local
RESOLV

echo "[CLIENT] Client prêt pour tester DNS et Web"
