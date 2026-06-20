# Rapport Hardening — TP2 MGGT1103

**Étudiant :** MUPINI KABWE ALBERT  
**Cours :** MGGT1103 — Administration Système, Cloud-Native & DevOps  
**Titulaire :** Dr. Roméo NIBITANGA  
**Thème :** Diagnostic Performance & Durcissement Linux  
**Environnement :** VM Ubuntu Server avec Vagrant  

## 1. Objectif du TP

Ce TP avait pour objectif de diagnostiquer les performances d’un serveur Linux, d’auditer son niveau de sécurité avec Lynis, puis d’appliquer quelques mesures simples de durcissement.

## 2. Diagnostic performance

Les outils utilisés pendant le diagnostic sont : htop, iotop, iostat, sar, journalctl, ss et iftop.

Les résultats sont enregistrés dans le fichier :

`resultats/diagnostic-performance.txt`

## 3. Audit Lynis initial

Commande utilisée :

`sudo lynis audit system`

Résultat observé :

**Hardening Index initial : 59**

La capture correspondante est placée dans le dossier `captures/`.

## 4. Corrections appliquées après l’audit Lynis

### Correction 1 — Installation de fail2ban

Commande utilisée :

`sudo apt install -y fail2ban`

Objectif : renforcer la protection contre les tentatives répétées de connexion.

### Correction 2 — Installation de apt-listbugs et apt-listchanges

Commande utilisée :

`sudo apt install -y apt-listbugs apt-listchanges`

Objectif : améliorer la prudence lors des mises à jour système.

### Correction 3 — Renforcement de UMASK

Fichier concerné :

`/etc/login.defs`

Valeur appliquée :

`UMASK 027`

Objectif : rendre les permissions par défaut plus restrictives.

## 5. Audit Lynis final

Commande utilisée :

`sudo lynis audit system`

Résultat observé :

**Hardening Index final : 60**

Le Hardening Index est passé de **59** à **60** après les corrections appliquées.

## 6. Script backup_system.sh

Le script `backup_system.sh` a été créé et testé avec succès.

Son rôle est de sauvegarder des éléments importants du système, notamment les informations réseau et les fichiers de configuration.

Commande d’exécution :

`sudo ./backup_system.sh`

Vérification des logs :

`sudo journalctl -t BACKUP_ENGINE`

Le script officiel est placé dans :

`rendu-final/backup_system.sh`

## 7. Différence entre SIGTERM(15) et SIGKILL(9)

`SIGTERM` est le signal numéro 15. Il demande à un processus de s’arrêter proprement. Le processus peut libérer ses ressources avant de quitter.

`SIGKILL` est le signal numéro 9. Il force l’arrêt immédiat du processus. Le processus ne peut pas l’ignorer et ne peut pas se fermer proprement.

En résumé, `SIGTERM` est une demande d’arrêt propre, tandis que `SIGKILL` est un arrêt forcé.

## 8. Limitation dans limits.conf

Le fichier `/etc/security/limits.conf` permet de limiter les ressources utilisées par les utilisateurs.

Exemple de limitation :

`vagrant hard nproc 100`

Cette règle limite le nombre maximal de processus que l’utilisateur `vagrant` peut lancer. Elle permet de réduire l’impact d’une Fork Bomb en empêchant un utilisateur de saturer toute la machine avec trop de processus.

## 9. Conclusion

Ce TP m’a permis de pratiquer le diagnostic Linux, l’audit Lynis, le durcissement système et l’automatisation avec Bash.

J’ai compris qu’un administrateur système doit observer le système avant de le modifier, appliquer les corrections avec prudence et toujours documenter les actions réalisées.
