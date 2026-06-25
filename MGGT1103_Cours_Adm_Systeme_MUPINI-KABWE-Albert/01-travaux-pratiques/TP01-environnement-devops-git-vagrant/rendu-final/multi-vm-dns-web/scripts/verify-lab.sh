#!/usr/bin/env bash
set -euo pipefail

echo "===== STATUT DES VM ====="
vagrant status

echo
echo "===== TEST DNS DIRECT ====="
vagrant ssh client-test -c "dig @192.168.56.10 web.mggt1103.local +short"

echo
echo "===== TEST RESOLUTION DNS NORMALE ====="
vagrant ssh client-test -c "getent hosts web.mggt1103.local"

echo
echo "===== TEST HTTP PAR IP ====="
vagrant ssh client-test -c "curl -I http://192.168.56.20"

echo
echo "===== TEST HTTP PAR NOM DNS ====="
vagrant ssh client-test -c "curl -I http://web.mggt1103.local"

echo
echo "===== TEST PAGE WEB ====="
vagrant ssh client-test -c "curl -s http://web.mggt1103.local | grep -i 'Serveur Web MGGT1103' || true"
