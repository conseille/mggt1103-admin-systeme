Rapport — Séance 1 : Environnement DevOps et Virtualisation avec Vagrant
1. Informations générales

Nom : MUPINI KABWE ALBERT
Cours : MGGT1103 — Administration Système, Cloud-Native et DevOps
Séance : Séance 1
Thème : Mise en place de l’environnement DevOps avec WSL2, Git, VS Code et Vagrant

2. Objectif du travail pratique

Ce travail pratique avait pour objectif de préparer mon ordinateur pour les prochaines séances du cours.
J’ai configuré un environnement de travail composé de Windows 11, Ubuntu avec WSL2, Visual Studio Code, Git, VirtualBox et Vagrant.

Cette préparation est importante parce qu’elle permet de travailler dans un environnement proche de celui utilisé par les administrateurs systèmes modernes et les ingénieurs DevOps. Grâce à cet environnement, je peux écrire des commandes Linux, gérer mes fichiers avec Git, documenter mon travail et créer une machine virtuelle Ubuntu Server pour les laboratoires.

3. Différence entre un administrateur système classique et un ingénieur DevOps/SRE

Un administrateur système classique s’occupe principalement de l’installation, de la configuration, de la surveillance et du dépannage des serveurs. Son travail consiste souvent à intervenir directement sur les machines pour installer des services, résoudre des problèmes ou appliquer des changements.

Un ingénieur DevOps ou SRE garde aussi ces compétences, mais il va plus loin en cherchant à automatiser les tâches répétitives. Il utilise des outils comme Git, des scripts, Vagrant, Ansible, Terraform ou Docker pour rendre l’infrastructure plus fiable, plus rapide à déployer et plus facile à maintenir.

Dans ce TP, j’ai commencé à comprendre cette différence. Le but n’est pas seulement de configurer une machine manuellement, mais aussi de garder une trace claire du travail réalisé, d’utiliser Git pour versionner les fichiers et de préparer une infrastructure reproductible avec Vagrant.

4. Environnement mis en place

Pour réaliser ce TP, j’ai utilisé :

Windows 11 comme système principal ;
Ubuntu 22.04 avec WSL2 comme environnement Linux ;
Visual Studio Code connecté à WSL ;
Git pour suivre les modifications du projet ;
VirtualBox pour héberger les machines virtuelles ;
Vagrant pour créer automatiquement une machine virtuelle Ubuntu Server.

5. Commandes importantes utilisées

Mise à jour d’Ubuntu WSL2
sudo apt update && sudo apt upgrade -y
Installation des outils de base
sudo apt install git curl wget nano tree -y
Configuration de Git
git config --global user.name "MUPINI KABWE ALBERT"
git config --global user.email "albertmupini21@gmail.com"
git config --global core.editor "code --wait"
git config --global init.defaultBranch master
Création du dossier du TP
mkdir -p ~/MGGT1103/SEANCE1-git-vagrant
cd ~/MGGT1103/SEANCE1-git-vagrant
mkdir -p captures
touch README.md rapport-seance1.md commandes.md
Gestion du projet avec Git
git init
git status
git add .
git commit -m "docs: redaction du rapport de la seance 1"
git log --oneline

6. Difficultés rencontrées

Pendant l’installation, j’ai rencontré quelques difficultés. Au début, WSL était installé mais aucune distribution Ubuntu n’était encore disponible. J’ai donc vérifié les distributions disponibles avec PowerShell avant d’installer Ubuntu 22.04.

J’ai aussi rencontré un problème lors de la création du mot de passe Ubuntu, car les deux mots de passe saisis ne correspondaient pas. Après correction, j’ai pu utiliser sudo normalement.

Une autre difficulté concernait l’ouverture de VS Code depuis Ubuntu WSL. J’ai installé l’extension WSL dans VS Code, puis j’ai connecté VS Code à Ubuntu 22.04. Après cela, j’ai pu ouvrir mon dossier de travail directement dans l’environnement Linux.

7. Commandes prévues dans la machine virtuelle Vagrant

Après la création de la VM Ubuntu Server avec Vagrant, les commandes suivantes seront utilisées pour vérifier son fonctionnement :

whoami
hostname
uname -a
free -h
df -h

Les captures d’écran des commandes uname -a et free -h seront placées dans le dossier captures/.

8. Conclusion

Cette première séance m’a permis de préparer mon environnement de travail pour le cours MGGT1103. J’ai compris que le travail d’un administrateur système moderne ne consiste pas seulement à installer des outils, mais aussi à organiser, documenter et versionner son travail.

Grâce à WSL2, Git, VS Code et Vagrant, je dispose maintenant d’une base de travail qui me servira pour les prochaines séances du cours, notamment pour l’administration Linux avancée, l’automatisation et les pratiques DevOps.