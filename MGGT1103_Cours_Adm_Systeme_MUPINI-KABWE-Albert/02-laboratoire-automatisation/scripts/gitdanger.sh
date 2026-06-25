#!/usr/bin/env bash
set -u

ROOT_DEFAULT="$HOME/MGGT1103/SEANCE1-git-vagrant"
SELECTED=0
MESSAGE="Zone dangereuse Git prête."

ACTIONS=(
  "Voir l’état Git avant action dangereuse"
  "git reset --hard HEAD"
  "git clean -fd"
  "git push --force-with-lease"
  "git rebase -i HEAD~N"
  "git remote remove origin"
  "Quitter"
)

repo_root() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null || true)"

  if [ -z "$root" ]; then
    if [ -d "$ROOT_DEFAULT/.git" ]; then
      echo "$ROOT_DEFAULT"
    else
      echo ""
    fi
  else
    echo "$root"
  fi
}

get_branch() {
  local branch
  branch="$(git branch --show-current 2>/dev/null || true)"

  if [ -z "$branch" ]; then
    echo "master"
  else
    echo "$branch"
  fi
}

pause_back() {
  echo
  echo "------------------------------------------------------------"
  read -rp "Appuie sur Entrée pour revenir..."
}

normal_confirm() {
  local question="$1"
  echo
  read -rp "$question [o/N] : " answer

  case "$answer" in
    o|O|oui|OUI|y|Y|yes|YES)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

danger_guard() {
  local action_name="$1"
  local phrase="$2"

  clear
  echo "======================================================================"
  echo "DOUBLE PROTECTION — ACTION DANGEREUSE"
  echo "======================================================================"
  echo
  echo "Action demandée : $action_name"
  echo
  echo "Cette commande peut supprimer, écraser ou modifier fortement ton travail."
  echo "Elle ne sera exécutée qu’après une double confirmation."
  echo

  echo "État Git actuel :"
  git status --short
  echo

  if ! normal_confirm "Première confirmation : continuer ?"; then
    echo "Action annulée."
    pause_back
    return 1
  fi

  local key
  key="GIT-$(date +%S)-$RANDOM"
  key="${key:0:12}"

  echo
  echo "Clé dynamique de sécurité : $key"
  read -rp "Retape exactement cette clé : " typed_key

  if [ "$typed_key" != "$key" ]; then
    echo
    echo "Clé incorrecte. Action bloquée."
    pause_back
    return 1
  fi

  echo
  echo "Phrase de validation attendue : $phrase"
  read -rp "Retape exactement la phrase : " typed_phrase

  if [ "$typed_phrase" != "$phrase" ]; then
    echo
    echo "Phrase incorrecte. Action bloquée."
    pause_back
    return 1
  fi

  echo
  echo "Double protection validée."
  return 0
}

draw() {
  clear

  local root
  root="$(repo_root)"

  echo "======================================================================"
  echo "GITDANGER — Zone dangereuse Git protégée"
  echo "======================================================================"
  echo

  if [ -z "$root" ]; then
    echo "Erreur : aucun dépôt Git trouvé."
    exit 1
  fi

  cd "$root" || exit 1

  echo "Dépôt   : $root"
  echo "Branche : $(get_branch)"
  echo
  echo "IMPORTANT : ces commandes sont protégées par clé + phrase exacte."
  echo
  echo "Touches : ↑ ↓ choisir | Entrée exécuter | r rafraîchir | q quitter"
  echo "Message : $MESSAGE"
  echo "----------------------------------------------------------------------"

  local i=0
  for action in "${ACTIONS[@]}"; do
    if [ "$i" -eq "$SELECTED" ]; then
      printf "➜ %2d. %s\n" "$((i+1))" "$action"
    else
      printf "  %2d. %s\n" "$((i+1))" "$action"
    fi
    i=$((i + 1))
  done

  echo "----------------------------------------------------------------------"
}

read_key() {
  local key rest

  IFS= read -rsn1 key || true

  if [[ "$key" == $'\e' ]]; then
    IFS= read -rsn2 rest || true

    case "$rest" in
      "[A") echo "UP" ;;
      "[B") echo "DOWN" ;;
      *) echo "OTHER" ;;
    esac
  else
    case "$key" in
      "") echo "ENTER" ;;
      q) echo "QUIT" ;;
      r) echo "REFRESH" ;;
      *) echo "OTHER" ;;
    esac
  fi
}

show_status() {
  clear
  echo "======================================================================"
  echo "ÉTAT GIT AVANT ACTION DANGEREUSE"
  echo "======================================================================"
  echo

  echo "Branche :"
  git branch --show-current
  echo

  echo "État Git :"
  git status
  echo

  echo "Derniers commits :"
  git log --oneline --decorate -8
  echo

  echo "Remotes :"
  git remote -v
  echo

  pause_back
  MESSAGE="État Git affiché."
}

do_reset_hard() {
  if danger_guard "git reset --hard HEAD" "RESET HARD"; then
    git reset --hard HEAD
    MESSAGE="git reset --hard HEAD exécuté."
  else
    MESSAGE="reset hard annulé."
  fi
}

do_clean_fd() {
  if danger_guard "git clean -fd" "CLEAN FD"; then
    git clean -fd
    MESSAGE="git clean -fd exécuté."
  else
    MESSAGE="clean annulé."
  fi
}

do_force_push() {
  local branch
  branch="$(get_branch)"

  if danger_guard "git push --force-with-lease origin $branch" "FORCE PUSH"; then
    git push --force-with-lease origin "$branch"
    MESSAGE="push force-with-lease exécuté."
  else
    MESSAGE="push force annulé."
  fi
}

do_rebase_interactive() {
  clear
  echo "======================================================================"
  echo "REBASE INTERACTIF"
  echo "======================================================================"
  echo

  echo "Derniers commits :"
  git log --oneline --decorate -10
  echo

  read -rp "Combien de commits veux-tu modifier ? Exemple 2 ou 3 : " n

  if ! [[ "$n" =~ ^[0-9]+$ ]] || [ "$n" -lt 1 ]; then
    MESSAGE="Nombre invalide."
    pause_back
    return
  fi

  if danger_guard "git rebase -i HEAD~$n" "REBASE INTERACTIF"; then
    git rebase -i "HEAD~$n"
    MESSAGE="rebase interactif terminé ou lancé."
  else
    MESSAGE="rebase interactif annulé."
  fi
}

do_remote_remove_origin() {
  echo
  echo "Remote actuel :"
  git remote -v
  echo

  if danger_guard "git remote remove origin" "REMOVE ORIGIN"; then
    git remote remove origin
    MESSAGE="remote origin supprimé."
  else
    MESSAGE="suppression du remote annulée."
  fi
}

execute_action() {
  case "$SELECTED" in
    0) show_status ;;
    1) do_reset_hard ;;
    2) do_clean_fd ;;
    3) do_force_push ;;
    4) do_rebase_interactive ;;
    5) do_remote_remove_origin ;;
    6)
      clear
      echo "Fin de Gitdanger."
      exit 0
      ;;
    *)
      MESSAGE="Action inconnue."
      ;;
  esac
}

main_loop() {
  local root
  root="$(repo_root)"

  if [ -z "$root" ]; then
    echo "Erreur : dépôt Git introuvable."
    exit 1
  fi

  cd "$root" || exit 1

  while true; do
    draw
    action="$(read_key)"

    case "$action" in
      UP)
        if [ "$SELECTED" -gt 0 ]; then
          SELECTED=$((SELECTED - 1))
        fi
        ;;
      DOWN)
        if [ "$SELECTED" -lt "$((${#ACTIONS[@]} - 1))" ]; then
          SELECTED=$((SELECTED + 1))
        fi
        ;;
      ENTER)
        execute_action
        pause_back
        ;;
      REFRESH)
        MESSAGE="Affichage rafraîchi."
        ;;
      QUIT)
        clear
        echo "Fin de Gitdanger."
        exit 0
        ;;
      *)
        MESSAGE="Touche non reconnue."
        ;;
    esac
  done
}

main_loop
