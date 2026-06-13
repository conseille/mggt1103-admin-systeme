#!/usr/bin/env bash

cd "$(dirname "$0")/../../../.."

mkdir -p Bureau-MUPINI-KABWE-ALBERT-MGGT1103/02-travaux-pratiques/TP1-environnement-devops-git-vagrant/rapport
mkdir -p Bureau-MUPINI-KABWE-ALBERT-MGGT1103/02-travaux-pratiques/TP1-environnement-devops-git-vagrant/captures
mkdir -p Bureau-MUPINI-KABWE-ALBERT-MGGT1103/04-infrastructure-virtualisation/vagrant
mkdir -p Bureau-MUPINI-KABWE-ALBERT-MGGT1103/06-preuves-et-captures/tp1
mkdir -p Bureau-MUPINI-KABWE-ALBERT-MGGT1103/07-rapports/tp1

[ -f rapport-seance1.md ] && cp rapport-seance1.md Bureau-MUPINI-KABWE-ALBERT-MGGT1103/02-travaux-pratiques/TP1-environnement-devops-git-vagrant/rapport/
[ -f rapport-seance1.md ] && cp rapport-seance1.md Bureau-MUPINI-KABWE-ALBERT-MGGT1103/07-rapports/tp1/
[ -f Vagrantfile ] && cp Vagrantfile Bureau-MUPINI-KABWE-ALBERT-MGGT1103/04-infrastructure-virtualisation/vagrant/

if [ -d captures/tp1 ]; then
  cp -r captures/tp1/* Bureau-MUPINI-KABWE-ALBERT-MGGT1103/02-travaux-pratiques/TP1-environnement-devops-git-vagrant/captures/ 2>/dev/null || true
  cp -r captures/tp1/* Bureau-MUPINI-KABWE-ALBERT-MGGT1103/06-preuves-et-captures/tp1/ 2>/dev/null || true
fi

echo "Rendu TP1 préparé."
