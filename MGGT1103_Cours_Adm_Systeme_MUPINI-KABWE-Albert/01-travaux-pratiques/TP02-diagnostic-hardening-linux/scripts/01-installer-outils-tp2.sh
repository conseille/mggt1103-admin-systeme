#!/usr/bin/env bash

set -euo pipefail

echo "============================================================"
echo "TP2 — Installation des outils de diagnostic et hardening"
echo "============================================================"
echo
echo "À exécuter dans la VM Ubuntu Server Vagrant."
echo
echo "Outils installés : htop, iotop, sysstat, iftop, acl, lynis, tree, nano, curl, wget"
echo

read -r -p "Continuer l'installation avec sudo apt ? [o/N] : " reponse

case "$reponse" in
  o|O|oui|OUI)
    sudo apt update
    sudo apt install -y htop iotop sysstat iftop acl lynis tree nano curl wget
    sudo sed -i 's/ENABLED="false"/ENABLED="true"/' /etc/default/sysstat || true
    sudo systemctl enable sysstat || true
    sudo systemctl restart sysstat || true
    echo
    echo "Installation terminée."
    ;;
  *)
    echo "Installation annulée."
    ;;
esac
