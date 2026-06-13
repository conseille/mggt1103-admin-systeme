#!/usr/bin/env bash

# ============================================================
# MGGT1103 - Tableau de bord du projet
# Auteur : MUPINI KABWE ALBERT
# Environnement : WSL Ubuntu
# Rôle : afficher un résumé graphique simple du dépôt MGGT1103
# Sécurité : lecture seule, aucune modification du système
# ============================================================

clear

# Couleurs
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"
RED="\033[31m"
WHITE="\033[97m"

PROJECT_NAME="Bureau-MUPINI-KABWE-ALBERT-MGGT1103"
EXPECTED_TP=11

# Détection de la racine Git
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  REPO_ROOT="$(pwd)"
fi

BUREAU="$REPO_ROOT/$PROJECT_NAME"
TP_BASE="$BUREAU/02-travaux-pratiques"
LAB="$BUREAU/03-laboratoire-automatisation"

line() {
  printf "${BLUE}%s${RESET}\n" "======================================================================"
}

title() {
  line
  printf "${BOLD}${WHITE}  %s${RESET}\n" "$1"
  line
}

card() {
  local label="$1"
  local value="$2"
  printf "${CYAN}%-35s${RESET} : ${BOLD}%s${RESET}\n" "$label" "$value"
}

status_ok() {
  printf "${GREEN}OK${RESET}"
}

status_warn() {
  printf "${YELLOW}À vérifier${RESET}"
}

progress_bar() {
  local current="$1"
  local total="$2"
  local width=30

  if [ "$total" -eq 0 ]; then
    total=1
  fi

  local filled=$(( current * width / total ))
  local empty=$(( width - filled ))

  printf "["
  printf "%0.s#" $(seq 1 "$filled" 2>/dev/null)
  printf "%0.s-" $(seq 1 "$empty" 2>/dev/null)
  printf "] %s/%s" "$current" "$total"
}

count_files() {
  local dir="$1"
  local pattern="$2"

  if [ -d "$dir" ]; then
    find "$dir" -type f -name "$pattern" | wc -l
  else
    echo 0
  fi
}

title "MGGT1103 - TABLEAU DE BORD DU PROJET"

card "Utilisateur" "MUPINI KABWE ALBERT"
card "Cours" "Administration Système, Cloud-Native & DevOps"
card "Environnement d'exécution" "WSL Ubuntu"
card "Racine Git" "$REPO_ROOT"

echo

if [ -d "$BUREAU" ]; then
  card "Bureau MGGT1103" "$(status_ok)"
else
  card "Bureau MGGT1103" "$(status_warn)"
fi

if [ -d "$TP_BASE" ]; then
  card "Dossier des travaux pratiques" "$(status_ok)"
else
  card "Dossier des travaux pratiques" "$(status_warn)"
fi

if [ -d "$LAB" ]; then
  card "Laboratoire d'automatisation" "$(status_ok)"
else
  card "Laboratoire d'automatisation" "$(status_warn)"
fi

echo
title "AVANCEMENT DES TRAVAUX PRATIQUES"

TP_COUNT=0
if [ -d "$TP_BASE" ]; then
  TP_COUNT="$(find "$TP_BASE" -maxdepth 1 -type d -name "TP*" | wc -l)"
fi

printf "${CYAN}TP préparés${RESET} : "
progress_bar "$TP_COUNT" "$EXPECTED_TP"
echo

echo

if [ -d "$TP_BASE" ]; then
  find "$TP_BASE" -maxdepth 1 -type d -name "TP*" | sort | while read -r tp; do
    tp_name="$(basename "$tp")"

    captures="$(count_files "$tp/captures" "*")"
    rapports="$(count_files "$tp/rapport" "*")"
    resultats="$(count_files "$tp/resultats" "*")"
    scripts="$(count_files "$tp/scripts" "*.sh")"

    printf "${BOLD}%-55s${RESET}  captures:%-3s rapport:%-3s resultats:%-3s scripts:%-3s\n" \
      "$tp_name" "$captures" "$rapports" "$resultats" "$scripts"
  done
else
  printf "${RED}Dossier des TP introuvable.${RESET}\n"
fi

echo
title "SCRIPTS D'AUTOMATISATION"

GENERAL_SCRIPTS="$(count_files "$LAB" "*.sh")"
TP_SCRIPTS="$(count_files "$TP_BASE" "*.sh")"

card "Scripts généraux laboratoire" "$GENERAL_SCRIPTS"
card "Scripts dans les TP" "$TP_SCRIPTS"

echo
title "ÉTAT GIT"

if command -v git >/dev/null 2>&1 && [ -d "$REPO_ROOT/.git" ]; then
  BRANCH="$(git -C "$REPO_ROOT" branch --show-current 2>/dev/null)"
  MODIFIED="$(git -C "$REPO_ROOT" status --short | wc -l)"

  card "Branche actuelle" "${BRANCH:-inconnue}"
  card "Fichiers modifiés/non suivis" "$MODIFIED"

  if [ "$MODIFIED" -eq 0 ]; then
    printf "${GREEN}Le dépôt est propre.${RESET}\n"
  else
    printf "${YELLOW}Des changements sont en attente. Vérifie avant commit.${RESET}\n"
  fi
else
  printf "${YELLOW}Git non détecté ou dossier non versionné.${RESET}\n"
fi

echo
title "RÉSUMÉ"

printf "${GREEN}Tableau de bord terminé.${RESET}\n"
printf "Ce script est en lecture seule et peut être présenté comme outil général WSL.\n"
echo
