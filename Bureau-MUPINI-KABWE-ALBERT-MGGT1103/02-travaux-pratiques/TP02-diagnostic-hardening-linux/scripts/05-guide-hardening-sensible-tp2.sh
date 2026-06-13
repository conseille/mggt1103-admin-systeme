#!/usr/bin/env bash

echo "============================================================"
echo "TP2 — Guide des actions sensibles de hardening"
echo "============================================================"
echo
echo "Ce script N'EXÉCUTE PAS les commandes sensibles."
echo "Il affiche seulement les commandes à utiliser avec prudence."
echo

echo "-------------------- sudoers --------------------"
echo "SENSIBLE : ne jamais modifier /etc/sudoers avec nano directement."
echo "Commande recommandée :"
echo "sudo visudo"
echo

echo "Exemple à comprendre, pas à copier sans consigne :"
echo "utilisateur ALL=(ALL) NOPASSWD: /usr/bin/systemctl status"
echo

echo "-------------------- PAM --------------------"
echo "SENSIBLE : une mauvaise configuration PAM peut bloquer les connexions."
echo "Fichiers concernés selon l'objectif :"
echo "/etc/pam.d/common-password"
echo "/etc/pam.d/common-auth"
echo

echo "-------------------- limits.conf --------------------"
echo "SENSIBLE : limite les ressources des utilisateurs."
echo "Fichier : /etc/security/limits.conf"
echo
echo "Exemple contre fork bomb :"
echo "* hard nproc 100"
echo "* soft nproc 80"
echo

echo "-------------------- ACL --------------------"
echo "Moins risqué, mais à utiliser proprement."
echo "Installer ACL : sudo apt install -y acl"
echo "Voir ACL : getfacl fichier"
echo "Ajouter ACL : setfacl -m u:utilisateur:r fichier"
echo "Retirer ACL : setfacl -x u:utilisateur fichier"
echo

echo "Fin du guide sensible."
