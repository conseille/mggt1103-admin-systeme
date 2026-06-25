# Complément TP01 — Multi-VM DNS + Web avec Vagrant

## Objectif

Ce complément met en place une architecture locale avec plusieurs machines virtuelles Vagrant.

L’objectif est de créer automatiquement :

- srv-dns : serveur DNS Bind9 ;
- srv-web : serveur Web Apache2 ;
- client-test : client Linux pour tester DNS et Web.

## Architecture

| Machine | Rôle | IP |
|---|---|---|
| srv-dns | Serveur DNS | 192.168.56.10 |
| srv-web | Serveur Web | 192.168.56.20 |
| client-test | Client de test | 192.168.56.30 |

## Domaine local

Nom de domaine utilisé :

mggt1103.local

Nom DNS principal :

web.mggt1103.local -> 192.168.56.20

## Commandes principales

Démarrer les VM :

vagrant up

Voir l’état :

vagrant status

Tester le laboratoire :

bash scripts/verify-lab.sh

Arrêter les VM :

vagrant halt
