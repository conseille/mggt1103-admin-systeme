#!/usr/bin/env bash

cd "$(dirname "$0")/../../../.."

mkdir -p Bureau-MUPINI-KABWE-ALBERT-MGGT1103/02-travaux-pratiques/TP2-diagnostic-hardening-linux/rapport
mkdir -p Bureau-MUPINI-KABWE-ALBERT-MGGT1103/02-travaux-pratiques/TP2-diagnostic-hardening-linux/captures
mkdir -p Bureau-MUPINI-KABWE-ALBERT-MGGT1103/02-travaux-pratiques/TP2-diagnostic-hardening-linux/scripts
mkdir -p Bureau-MUPINI-KABWE-ALBERT-MGGT1103/06-preuves-et-captures/tp2
mkdir -p Bureau-MUPINI-KABWE-ALBERT-MGGT1103/07-rapports/tp2

[ -f rapport_hardening.md ] && cp rapport_hardening.md Bureau-MUPINI-KABWE-ALBERT-MGGT1103/02-travaux-pratiques/TP2-diagnostic-hardening-linux/rapport/
[ -f rapport_hardening.md ] && cp rapport_hardening.md Bureau-MUPINI-KABWE-ALBERT-MGGT1103/07-rapports/tp2/
[ -f backup_system.sh ] && cp backup_system.sh Bureau-MUPINI-KABWE-ALBERT-MGGT1103/02-travaux-pratiques/TP2-diagnostic-hardening-linux/scripts/

if [ -d captures/tp2 ]; then
  cp -r captures/tp2/* Bureau-MUPINI-KABWE-ALBERT-MGGT1103/02-travaux-pratiques/TP2-diagnostic-hardening-linux/captures/ 2>/dev/null || true
  cp -r captures/tp2/* Bureau-MUPINI-KABWE-ALBERT-MGGT1103/06-preuves-et-captures/tp2/ 2>/dev/null || true
fi

echo "Rendu TP2 préparé."
