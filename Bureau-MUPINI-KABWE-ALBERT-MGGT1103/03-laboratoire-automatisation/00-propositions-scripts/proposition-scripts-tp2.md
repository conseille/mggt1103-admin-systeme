# Proposition de scripts — TP2 MGGT1103

## Scripts TP2

- `01-installer-outils-tp2.sh` : installe les outils nécessaires au diagnostic et au hardening.
- `02-diagnostic-performance-tp2.sh` : génère un diagnostic CPU, RAM, disque, réseau et processus.
- `03-audit-lynis-tp2.sh` : lance un audit Lynis et sauvegarde le résultat.
- `04-generer-backup-system.sh` : génère le script final `backup_system.sh`.
- `05-guide-hardening-sensible-tp2.sh` : affiche les commandes sensibles sans les exécuter.
- `06-verifier-resultats-tp2.sh` : vérifie les outils, résultats et fichiers produits.

## Note

Les commandes sensibles liées à `sudoers`, PAM et `limits.conf` ne sont pas exécutées automatiquement.
Elles doivent être vérifiées avant application.
