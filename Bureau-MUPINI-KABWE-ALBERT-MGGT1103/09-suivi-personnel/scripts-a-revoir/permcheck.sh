#!/usr/bin/env bash

echo "============================================================"
echo "Gestion des permissions Linux — MGGT1103"
echo "============================================================"
echo

echo "[1] Utilisateur courant"
whoami

echo
echo "[2] Groupe principal"
id

echo
echo "[3] Dossier actuel"
pwd

echo
echo "[4] Permissions des fichiers du dossier actuel"
ls -lah

echo
echo "[5] Fichiers exécutables dans le dossier actuel"
find . -maxdepth 2 -type f -perm /111 2>/dev/null

echo
echo "[6] Propriétaires des fichiers"
ls -la | awk '{print $1, $3, $4, $9}'

echo
echo "============================================================"
echo "Commandes utiles à connaître"
echo "============================================================"
echo

echo "chmod +x fichier.sh"
echo "=> Donner le droit d'exécution à un script"

echo
echo "chmod 644 fichier"
echo "=> Lecture/écriture pour le propriétaire, lecture pour les autres"

echo
echo "chmod 755 script.sh"
echo "=> Exécution autorisée pour le propriétaire, le groupe et les autres"

echo
echo "chown utilisateur:groupe fichier"
echo "=> Changer le propriétaire et le groupe d'un fichier"

echo
echo "sudo chown -R utilisateur:groupe dossier"
echo "=> Changer le propriétaire d'un dossier et de son contenu"

echo
echo "============================================================"
echo "Fin du diagnostic des permissions"
echo "============================================================"
