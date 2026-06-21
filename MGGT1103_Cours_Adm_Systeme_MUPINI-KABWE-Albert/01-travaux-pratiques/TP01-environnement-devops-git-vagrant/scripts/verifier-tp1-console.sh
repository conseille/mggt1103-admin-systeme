#!/usr/bin/env bash

# ============================================================
# MGGT1103 - Vérification TP01 - Version console
# Développeur : MUPINI KABWE ALBERT
# Environnement : WSL Ubuntu
#
# Rôle :
# Vérifier le TP01 directement dans le terminal.
# Affiche la structure, les fichiers attendus, les droits Linux,
# les fichiers parasites et les informations Git.
#
# Mode :
# Lecture seule. Ce script ne modifie aucun fichier.
# ============================================================

set -u

PROJECT_NAME="Bureau-MUPINI-KABWE-ALBERT-MGGT1103"
TP_NAME="TP01-environnement-devops-git-vagrant"

if git rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  REPO_ROOT="$(pwd)"
fi

TP1="$REPO_ROOT/$PROJECT_NAME/02-travaux-pratiques/$TP_NAME"

GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
BLUE="\033[34m"
BOLD="\033[1m"
RESET="\033[0m"

OK=0
WARN=0

line() {
  echo "======================================================================"
}

check_dir() {
  local path="$1"
  local label="$2"

  if [ -d "$path" ]; then
    echo -e "${GREEN}OK${RESET}        $label"
    OK=$((OK + 1))
  else
    echo -e "${RED}ABSENT${RESET}    $label"
    WARN=$((WARN + 1))
  fi
}

check_file() {
  local path="$1"
  local label="$2"

  if [ -f "$path" ]; then
    echo -e "${GREEN}OK${RESET}        $label"
    OK=$((OK + 1))
  else
    echo -e "${RED}ABSENT${RESET}    $label"
    WARN=$((WARN + 1))
  fi
}

count_files() {
  local dir="$1"
  if [ -d "$dir" ]; then
    find "$dir" -type f ! -name ".gitkeep" | wc -l
  else
    echo 0
  fi
}

clear
line
echo -e "${BOLD}MGGT1103 - Vérification TP01 - Console${RESET}"
line
echo "Étudiant      : MUPINI KABWE ALBERT"
echo "Cours         : MGGT1103 - Administration Système, Cloud-Native & DevOps"
echo "Titulaire     : Dr. Roméo NIBITANGA"
echo "Environnement : WSL Ubuntu"
echo "Mode          : lecture seule"
echo "Dossier TP01  : $TP1"
line
echo

echo -e "${BLUE}1. Structure attendue${RESET}"
check_dir "$TP1" "Dossier principal TP01"
check_dir "$TP1/captures" "Dossier captures"
check_dir "$TP1/rapport" "Dossier rapport"
check_dir "$TP1/resultats" "Dossier resultats"
check_dir "$TP1/rendu-final" "Dossier rendu-final"
check_dir "$TP1/scripts" "Dossier scripts"

echo
echo -e "${BLUE}2. Fichiers importants du TP01${RESET}"
check_file "$TP1/rendu-final/README.md" "README.md dans rendu-final"
check_file "$TP1/rendu-final/Vagrantfile" "Vagrantfile dans rendu-final"
check_file "$TP1/rapport/rapport-seance1.md" "rapport-seance1.md dans rapport"

echo
echo -e "${BLUE}3. Quantité de fichiers par dossier${RESET}"
echo "captures     : $(count_files "$TP1/captures") fichier(s)"
echo "rapport      : $(count_files "$TP1/rapport") fichier(s)"
echo "resultats    : $(count_files "$TP1/resultats") fichier(s)"
echo "rendu-final  : $(count_files "$TP1/rendu-final") fichier(s)"
echo "scripts      : $(find "$TP1/scripts" -type f -name "*.sh" | wc -l) script(s)"

echo
echo -e "${BLUE}4. Fichiers réels avec droits Linux${RESET}"
if [ -d "$TP1" ]; then
  find "$TP1" -type f ! -name ".gitkeep" | sort | while read -r file; do
    droits="$(stat -c '%A' "$file")"
    taille="$(du -h "$file" | awk '{print $1}')"
    date_modif="$(stat -c '%y' "$file" | cut -d'.' -f1)"
    chemin="${file#$REPO_ROOT/}"

    printf "%-11s %-7s %-19s %s\n" "$droits" "$taille" "$date_modif" "$chemin"
  done
else
  echo "Dossier TP01 introuvable."
fi

echo
echo -e "${BLUE}5. Fichiers parasites${RESET}"
PARASITES="$(find "$TP1" \( -name "*:Zone.Identifier" -o -name "Thumbs.db" -o -name ".DS_Store" -o -name "*.tmp" -o -name "*~" \) 2>/dev/null || true)"

if [ -z "$PARASITES" ]; then
  echo -e "${GREEN}OK${RESET}        Aucun fichier parasite détecté"
  OK=$((OK + 1))
else
  echo -e "${YELLOW}À vérifier${RESET} Fichiers parasites détectés :"
  echo "$PARASITES"
  WARN=$((WARN + 1))
fi

echo
echo -e "${BLUE}6. Structure réelle du TP01${RESET}"
tree "$TP1" -L 3

echo
echo -e "${BLUE}7. Informations Git${RESET}"
echo "Branche actuelle : $(git -C "$REPO_ROOT" branch --show-current 2>/dev/null || echo 'non détectée')"
echo "Nom Git          : $(git config --global user.name 2>/dev/null || echo 'non configuré')"
echo "Email Git        : $(git config --global user.email 2>/dev/null || echo 'non configuré')"
echo "Remote GitHub    : $(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || echo 'aucun remote')"
echo "Nombre commits   : $(git -C "$REPO_ROOT" rev-list --count HEAD 2>/dev/null || echo '0')"
echo "Dernier commit   : $(git -C "$REPO_ROOT" log -1 --oneline 2>/dev/null || echo 'aucun commit')"

echo
echo "git status --short :"
git -C "$REPO_ROOT" status --short

echo
line
echo -e "${BOLD}Résumé${RESET}"
line
echo -e "Contrôles OK      : ${GREEN}$OK${RESET}"
echo -e "Points à vérifier : ${YELLOW}$WARN${RESET}"

if [ "$WARN" -eq 0 ]; then
  echo -e "${GREEN}Résultat : TP01 bien organisé selon la structure actuelle.${RESET}"
else
  echo -e "${YELLOW}Résultat : TP01 à vérifier sur certains points.${RESET}"
fi

echo
echo "Analyse intelligente locale :"
if [ "$(count_files "$TP1/captures")" -eq 0 ]; then
  echo "- Ajouter les captures du TP01 dans le dossier captures."
else
  echo "- Les captures du TP01 sont présentes."
fi

if [ -f "$TP1/rendu-final/README.md" ] && [ -f "$TP1/rendu-final/Vagrantfile" ]; then
  echo "- Les fichiers principaux du rendu-final sont présents."
else
  echo "- Vérifier README.md et Vagrantfile dans rendu-final."
fi

if [ -n "$(git -C "$REPO_ROOT" status --short)" ]; then
  echo "- Git contient des changements en attente. Vérifier avant commit."
else
  echo "- Le dépôt Git est propre."
fi
