#!/usr/bin/env bash
set -u

ROOT_DEFAULT="$HOME/MGGT1103/SEANCE1-git-vagrant"
DEFAULT_NAME="MUPINI KABWE ALBERT"
DEFAULT_EMAIL="albertmupini21@gmail.com"
DEFAULT_REMOTE="git@github.com:conseille/mggt1103-admin-systeme.git"
DEFAULT_BRANCH="master"

SELECTED=0
MESSAGE="Gitnav complet prêt."

ACTIONS=(
  "01. Configuration Git globale"
  "02. Vérifier la configuration Git"
  "03. Initialiser un nouveau dépôt Git"
  "04. Vérifier l’état du dépôt"
  "05. Voir les fichiers modifiés"
  "06. Voir le résumé des différences"
  "07. Voir les différences complètes"
  "08. Ajouter tous les fichiers"
  "09. Ajouter un fichier précis"
  "10. Retirer un fichier de la zone d’ajout"
  "11. Faire un commit"
  "12. Voir les derniers commits"
  "13. Voir le détail du dernier commit"
  "14. Ajouter ou modifier le remote GitHub"
  "15. Vérifier le remote GitHub"
  "16. Premier push vers GitHub"
  "17. Pull rebase depuis GitHub"
  "18. Push vers GitHub"
  "19. Workflow rapide complet"
  "20. Voir toutes les branches"
  "21. Créer une nouvelle branche"
  "22. Changer de branche"
  "23. Fusionner une branche"
  "24. Mettre le travail de côté avec stash"
  "25. Restaurer le dernier stash"
  "26. Créer un tag de version"
  "27. Voir les tags"
  "28. Ouvrir GitHub dans le navigateur"
  "29. Générer un rapport Git final"
  "30. Aide Git rapide"
  "31. Quitter"
)

repo_root() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null || true)"

  if [ -n "$root" ]; then
    echo "$root"
  elif [ -d "$ROOT_DEFAULT" ]; then
    echo "$ROOT_DEFAULT"
  else
    pwd
  fi
}

is_git_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

get_branch() {
  local branch
  branch="$(git branch --show-current 2>/dev/null || true)"

  if [ -z "$branch" ]; then
    echo "$DEFAULT_BRANCH"
  else
    echo "$branch"
  fi
}

pause_back() {
  echo
  echo "------------------------------------------------------------"
  read -rp "Appuie sur Entrée pour revenir au menu..."
}

confirm() {
  local question="$1"
  local answer

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

need_repo() {
  if ! is_git_repo; then
    echo
    echo "Ce dossier n’est pas encore un dépôt Git."
    echo "Utilise d’abord l’option 03 : Initialiser un nouveau dépôt Git."
    pause_back
    return 1
  fi

  return 0
}

draw() {
  clear

  local root
  root="$(repo_root)"
  cd "$root" 2>/dev/null || true

  echo "======================================================================"
  echo "GITNAV v2 — Assistant Git complet MGGT1103"
  echo "======================================================================"
  echo
  echo "Dossier : $root"

  if is_git_repo; then
    echo "Dépôt   : oui"
    echo "Branche : $(get_branch)"
    echo
    echo "État rapide :"
    git status -sb 2>/dev/null || true
  else
    echo "Dépôt   : non initialisé"
    echo "Branche : aucune"
  fi

  echo
  echo "Touches : ↑ ↓ choisir | Entrée exécuter | r rafraîchir | q quitter"
  echo "Message : $MESSAGE"
  echo "----------------------------------------------------------------------"

  local i=0
  for action in "${ACTIONS[@]}"; do
    if [ "$i" -eq "$SELECTED" ]; then
      printf "➜ %s\n" "$action"
    else
      printf "  %s\n" "$action"
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

configure_git() {
  clear
  echo "======================================================================"
  echo "CONFIGURATION GIT GLOBALE"
  echo "======================================================================"
  echo

  echo "Configuration proposée :"
  echo "Nom    : $DEFAULT_NAME"
  echo "Email  : $DEFAULT_EMAIL"
  echo "Éditeur: code --wait"
  echo "Branche par défaut : $DEFAULT_BRANCH"
  echo

  if confirm "Appliquer cette configuration Git globale ?"; then
    git config --global user.name "$DEFAULT_NAME"
    git config --global user.email "$DEFAULT_EMAIL"
    git config --global core.editor "code --wait"
    git config --global init.defaultBranch "$DEFAULT_BRANCH"

    echo
    echo "Configuration appliquée."
    MESSAGE="Configuration Git globale terminée."
  else
    MESSAGE="Configuration Git annulée."
  fi

  pause_back
}

check_git_config() {
  clear
  echo "======================================================================"
  echo "VÉRIFICATION DE LA CONFIGURATION GIT"
  echo "======================================================================"
  echo

  echo "Nom :"
  git config --global user.name || true
  echo

  echo "Email :"
  git config --global user.email || true
  echo

  echo "Éditeur :"
  git config --global core.editor || true
  echo

  echo "Branche par défaut :"
  git config --global init.defaultBranch || true
  echo

  echo "Configuration globale complète :"
  git config --global --list | sort || true

  MESSAGE="Configuration Git vérifiée."
  pause_back
}

init_repo() {
  clear
  echo "======================================================================"
  echo "INITIALISER UN NOUVEAU DÉPÔT GIT"
  echo "======================================================================"
  echo

  echo "Dossier actuel :"
  pwd
  echo

  if is_git_repo; then
    echo "Ce dossier est déjà un dépôt Git."
    git status -sb
    MESSAGE="Dépôt déjà initialisé."
    pause_back
    return
  fi

  if confirm "Faire git init dans ce dossier ?"; then
    git init
    git branch -M "$DEFAULT_BRANCH" 2>/dev/null || true
    MESSAGE="Dépôt Git initialisé."
  else
    MESSAGE="Initialisation annulée."
  fi

  pause_back
}

show_status() {
  clear
  echo "======================================================================"
  echo "ÉTAT DU DÉPÔT"
  echo "======================================================================"

  need_repo || return

  echo
  echo "Dossier racine :"
  git rev-parse --show-toplevel
  echo

  echo "Branche actuelle :"
  git branch --show-current
  echo

  echo "État complet :"
  git status
  echo

  echo "Dernier commit :"
  git log --oneline -1 2>/dev/null || echo "Aucun commit pour le moment."

  MESSAGE="État du dépôt affiché."
  pause_back
}

show_modified_files() {
  clear
  echo "======================================================================"
  echo "FICHIERS MODIFIÉS OU NON SUIVIS"
  echo "======================================================================"

  need_repo || return

  echo
  if [ -z "$(git status --short)" ]; then
    echo "Aucune modification locale."
  else
    git status --short
  fi

  echo
  echo "Légende :"
  echo " M  = fichier modifié"
  echo "A   = fichier ajouté"
  echo "D   = fichier supprimé"
  echo "??  = fichier non suivi"

  MESSAGE="Fichiers modifiés affichés."
  pause_back
}

show_diff_summary() {
  clear
  echo "======================================================================"
  echo "RÉSUMÉ DES DIFFÉRENCES"
  echo "======================================================================"

  need_repo || return

  echo
  echo "Différences non ajoutées :"
  git diff --stat || true

  echo
  echo "Différences déjà ajoutées avec git add :"
  git diff --cached --stat || true

  MESSAGE="Résumé des différences affiché."
  pause_back
}

show_full_diff() {
  clear
  echo "======================================================================"
  echo "DIFFÉRENCES COMPLÈTES"
  echo "======================================================================"

  need_repo || return

  echo
  if command -v less >/dev/null 2>&1; then
    git diff --color=always | less -R
  else
    git diff | sed -n '1,240p'
    echo
    echo "Aperçu limité aux 240 premières lignes."
    pause_back
  fi

  MESSAGE="Différences complètes affichées."
}

git_add_all() {
  clear
  echo "======================================================================"
  echo "AJOUTER TOUS LES FICHIERS"
  echo "======================================================================"

  need_repo || return

  echo
  echo "Fichiers concernés :"
  git status --short
  echo

  if [ -z "$(git status --short)" ]; then
    echo "Aucun fichier à ajouter."
    MESSAGE="Aucun ajout nécessaire."
    pause_back
    return
  fi

  if confirm "Exécuter git add . ?"; then
    git add .
    MESSAGE="git add . exécuté."
  else
    MESSAGE="Ajout annulé."
  fi

  pause_back
}

git_add_one() {
  clear
  echo "======================================================================"
  echo "AJOUTER UN FICHIER PRÉCIS"
  echo "======================================================================"

  need_repo || return

  echo
  git status --short
  echo
  read -rp "Chemin du fichier à ajouter : " file

  if [ -z "$file" ]; then
    MESSAGE="Ajout annulé : chemin vide."
    pause_back
    return
  fi

  git add -- "$file"
  MESSAGE="Fichier ajouté : $file"
  pause_back
}

git_unstage_one() {
  clear
  echo "======================================================================"
  echo "RETIRER UN FICHIER DE LA ZONE D’AJOUT"
  echo "======================================================================"

  need_repo || return

  echo
  echo "Fichiers déjà ajoutés :"
  git diff --cached --name-only
  echo
  read -rp "Chemin du fichier à retirer de la zone d’ajout : " file

  if [ -z "$file" ]; then
    MESSAGE="Opération annulée : chemin vide."
    pause_back
    return
  fi

  git restore --staged -- "$file"
  MESSAGE="Fichier retiré de la zone d’ajout : $file"
  pause_back
}

git_commit_menu() {
  clear
  echo "======================================================================"
  echo "FAIRE UN COMMIT"
  echo "======================================================================"

  need_repo || return

  echo
  echo "État actuel :"
  git status --short
  echo

  if [ -z "$(git diff --cached --name-only)" ]; then
    echo "Aucun fichier n’est dans la zone d’ajout."
    echo
    if confirm "Faire d’abord git add . ?"; then
      git add .
    else
      MESSAGE="Commit annulé."
      pause_back
      return
    fi
  fi

  echo
  read -rp "Message du commit : " msg

  if [ -z "$msg" ]; then
    MESSAGE="Commit annulé : message vide."
    pause_back
    return
  fi

  git commit -m "$msg"
  MESSAGE="Commit créé."
  pause_back
}

show_log() {
  clear
  echo "======================================================================"
  echo "DERNIERS COMMITS"
  echo "======================================================================"

  need_repo || return

  echo
  git log --oneline --decorate --graph --all -15 2>/dev/null || echo "Aucun commit."

  MESSAGE="Historique affiché."
  pause_back
}

show_last_commit() {
  clear
  echo "======================================================================"
  echo "DÉTAIL DU DERNIER COMMIT"
  echo "======================================================================"

  need_repo || return

  echo
  git show --stat --oneline HEAD 2>/dev/null || echo "Aucun commit disponible."

  MESSAGE="Dernier commit affiché."
  pause_back
}

remote_add_or_set() {
  clear
  echo "======================================================================"
  echo "AJOUTER OU MODIFIER LE REMOTE GITHUB"
  echo "======================================================================"

  need_repo || return

  echo
  echo "Remote actuel :"
  git remote -v || true
  echo

  echo "Remote proposé :"
  echo "$DEFAULT_REMOTE"
  echo

  read -rp "URL GitHub SSH à utiliser [Entrée = valeur proposée] : " remote_url

  if [ -z "$remote_url" ]; then
    remote_url="$DEFAULT_REMOTE"
  fi

  echo
  if git remote get-url origin >/dev/null 2>&1; then
    if confirm "origin existe déjà. Le remplacer par $remote_url ?"; then
      git remote set-url origin "$remote_url"
      MESSAGE="Remote origin modifié."
    else
      MESSAGE="Modification du remote annulée."
    fi
  else
    if confirm "Ajouter origin = $remote_url ?"; then
      git remote add origin "$remote_url"
      MESSAGE="Remote origin ajouté."
    else
      MESSAGE="Ajout du remote annulé."
    fi
  fi

  pause_back
}

remote_check() {
  clear
  echo "======================================================================"
  echo "VÉRIFIER LE REMOTE GITHUB"
  echo "======================================================================"

  need_repo || return

  echo
  git remote -v || true
  echo

  echo "URL origin :"
  git remote get-url origin 2>/dev/null || echo "Aucun remote origin."
  echo

  MESSAGE="Remote GitHub vérifié."
  pause_back
}

first_push() {
  clear
  echo "======================================================================"
  echo "PREMIER PUSH VERS GITHUB"
  echo "======================================================================"

  need_repo || return

  echo
  local branch
  branch="$(get_branch)"

  echo "Branche actuelle détectée : $branch"
  echo "Branche recommandée      : $DEFAULT_BRANCH"
  echo

  read -rp "Nom de branche à utiliser [Entrée = master] : " chosen_branch

  if [ -z "$chosen_branch" ]; then
    chosen_branch="$DEFAULT_BRANCH"
  fi

  echo
  echo "Commande prévue :"
  echo "git branch -M $chosen_branch"
  echo "git push -u origin $chosen_branch"
  echo

  if confirm "Confirmer le premier push ?"; then
    git branch -M "$chosen_branch"
    git push -u origin "$chosen_branch"
    MESSAGE="Premier push terminé."
  else
    MESSAGE="Premier push annulé."
  fi

  pause_back
}

pull_rebase() {
  clear
  echo "======================================================================"
  echo "PULL REBASE DEPUIS GITHUB"
  echo "======================================================================"

  need_repo || return

  local branch
  branch="$(get_branch)"

  echo
  echo "Commande prévue : git pull --rebase origin $branch"
  echo

  if confirm "Confirmer le pull --rebase ?"; then
    git pull --rebase origin "$branch"
    MESSAGE="Pull rebase terminé."
  else
    MESSAGE="Pull rebase annulé."
  fi

  pause_back
}

push_origin() {
  clear
  echo "======================================================================"
  echo "PUSH VERS GITHUB"
  echo "======================================================================"

  need_repo || return

  local branch
  branch="$(get_branch)"

  echo
  echo "Commande prévue : git push origin $branch"
  echo

  if confirm "Confirmer le push ?"; then
    git push origin "$branch"
    MESSAGE="Push terminé."
  else
    MESSAGE="Push annulé."
  fi

  pause_back
}

quick_workflow() {
  clear
  echo "======================================================================"
  echo "WORKFLOW RAPIDE COMPLET"
  echo "======================================================================"

  need_repo || return

  echo
  echo "Ce workflow exécute :"
  echo "1. git status --short"
  echo "2. git add ."
  echo "3. git commit -m \"message\""
  echo "4. git pull --rebase origin branche"
  echo "5. git push origin branche"
  echo

  echo "État actuel :"
  git status --short
  echo

  if [ -z "$(git status --short)" ]; then
    echo "Aucune modification locale à committer."
    echo
    if confirm "Faire seulement pull --rebase puis push ?"; then
      local branch
      branch="$(get_branch)"
      git pull --rebase origin "$branch"
      git push origin "$branch"
      MESSAGE="Synchronisation terminée."
    else
      MESSAGE="Workflow annulé."
    fi
    pause_back
    return
  fi

  read -rp "Message du commit : " msg

  if [ -z "$msg" ]; then
    MESSAGE="Workflow annulé : message vide."
    pause_back
    return
  fi

  if ! confirm "Confirmer add + commit + pull --rebase + push ?"; then
    MESSAGE="Workflow annulé."
    pause_back
    return
  fi

  local branch
  branch="$(get_branch)"

  git add .
  git commit -m "$msg"
  git pull --rebase origin "$branch"
  git push origin "$branch"

  MESSAGE="Workflow rapide terminé."
  pause_back
}

show_branches() {
  clear
  echo "======================================================================"
  echo "BRANCHES GIT"
  echo "======================================================================"

  need_repo || return

  echo
  echo "Branches locales :"
  git branch -vv
  echo

  echo "Branches distantes :"
  git branch -r
  echo

  MESSAGE="Branches affichées."
  pause_back
}

create_branch() {
  clear
  echo "======================================================================"
  echo "CRÉER UNE NOUVELLE BRANCHE"
  echo "======================================================================"

  need_repo || return

  echo
  git branch
  echo

  read -rp "Nom de la nouvelle branche : " branch

  if [ -z "$branch" ]; then
    MESSAGE="Création annulée : nom vide."
    pause_back
    return
  fi

  git switch -c "$branch"
  MESSAGE="Branche créée et activée : $branch"
  pause_back
}

switch_branch() {
  clear
  echo "======================================================================"
  echo "CHANGER DE BRANCHE"
  echo "======================================================================"

  need_repo || return

  echo
  git branch
  echo

  read -rp "Nom de la branche à activer : " branch

  if [ -z "$branch" ]; then
    MESSAGE="Changement annulé : nom vide."
    pause_back
    return
  fi

  git switch "$branch"
  MESSAGE="Branche activée : $branch"
  pause_back
}

merge_branch() {
  clear
  echo "======================================================================"
  echo "FUSIONNER UNE BRANCHE"
  echo "======================================================================"

  need_repo || return

  echo
  echo "Branche actuelle : $(get_branch)"
  echo
  echo "Branches disponibles :"
  git branch
  echo

  read -rp "Nom de la branche à fusionner dans la branche actuelle : " branch

  if [ -z "$branch" ]; then
    MESSAGE="Fusion annulée : nom vide."
    pause_back
    return
  fi

  echo
  echo "Commande prévue : git merge --no-ff $branch"
  echo

  if confirm "Confirmer la fusion ?"; then
    git merge --no-ff "$branch"
    MESSAGE="Fusion terminée."
  else
    MESSAGE="Fusion annulée."
  fi

  pause_back
}

stash_work() {
  clear
  echo "======================================================================"
  echo "METTRE LE TRAVAIL DE CÔTÉ AVEC STASH"
  echo "======================================================================"

  need_repo || return

  echo
  git status --short
  echo

  if [ -z "$(git status --short)" ]; then
    echo "Aucune modification à mettre de côté."
    MESSAGE="Aucun stash nécessaire."
    pause_back
    return
  fi

  read -rp "Message du stash [Entrée = travail temporaire] : " msg

  if [ -z "$msg" ]; then
    msg="travail temporaire"
  fi

  git stash push -m "$msg"
  MESSAGE="Travail mis de côté avec stash."
  pause_back
}

stash_pop() {
  clear
  echo "======================================================================"
  echo "RESTAURER LE DERNIER STASH"
  echo "======================================================================"

  need_repo || return

  echo
  echo "Liste des stash :"
  git stash list
  echo

  if [ -z "$(git stash list)" ]; then
    echo "Aucun stash disponible."
    MESSAGE="Aucun stash à restaurer."
    pause_back
    return
  fi

  if confirm "Restaurer le dernier stash avec git stash pop ?"; then
    git stash pop
    MESSAGE="Dernier stash restauré."
  else
    MESSAGE="Restauration du stash annulée."
  fi

  pause_back
}

create_tag() {
  clear
  echo "======================================================================"
  echo "CRÉER UN TAG DE VERSION"
  echo "======================================================================"

  need_repo || return

  echo
  echo "Derniers commits :"
  git log --oneline -5
  echo

  read -rp "Nom du tag, exemple v1.0-tp3 : " tag

  if [ -z "$tag" ]; then
    MESSAGE="Création du tag annulée : nom vide."
    pause_back
    return
  fi

  read -rp "Message du tag : " msg

  if [ -z "$msg" ]; then
    msg="Version $tag"
  fi

  git tag -a "$tag" -m "$msg"
  MESSAGE="Tag créé : $tag"
  pause_back
}

show_tags() {
  clear
  echo "======================================================================"
  echo "TAGS GIT"
  echo "======================================================================"

  need_repo || return

  echo
  git tag -n || true

  MESSAGE="Tags affichés."
  pause_back
}

open_github() {
  clear
  echo "======================================================================"
  echo "OUVRIR GITHUB"
  echo "======================================================================"

  need_repo || return

  local remote url
  remote="$(git remote get-url origin 2>/dev/null || true)"

  if [ -z "$remote" ]; then
    echo
    echo "Aucun remote origin détecté."
    MESSAGE="Ouverture GitHub impossible."
    pause_back
    return
  fi

  url="$remote"

  if [[ "$remote" == git@github.com:* ]]; then
    url="https://github.com/${remote#git@github.com:}"
    url="${url%.git}"
  elif [[ "$remote" == https://github.com/* ]]; then
    url="${remote%.git}"
  fi

  echo
  echo "URL détectée : $url"
  cmd.exe /C start "" "$url" >/dev/null 2>&1 || true

  MESSAGE="GitHub ouvert dans le navigateur."
  pause_back
}

generate_final_report() {
  clear
  echo "======================================================================"
  echo "GÉNÉRER UN RAPPORT GIT FINAL"
  echo "======================================================================"

  need_repo || return

  local report_dir report_file
  report_dir="$(repo_root)/MGGT1103_Cours_Adm_Systeme_MUPINI-KABWE-Albert/02-laboratoire-automatisation/resultats"
  report_file="$report_dir/rapport-git-final.txt"

  mkdir -p "$report_dir"

  {
    echo "RAPPORT GIT FINAL — MGGT1103"
    echo "Date : $(date)"
    echo
    echo "Dépôt : $(git rev-parse --show-toplevel)"
    echo "Branche : $(git branch --show-current)"
    echo
    echo "Remote :"
    git remote -v
    echo
    echo "État Git :"
    git status
    echo
    echo "Derniers commits :"
    git log --oneline --decorate -15
    echo
    echo "Tags :"
    git tag -n
  } > "$report_file"

  echo
  echo "Rapport généré :"
  echo "$report_file"

  MESSAGE="Rapport Git final généré."
  pause_back
}

show_help() {
  clear
  echo "======================================================================"
  echo "AIDE GIT RAPIDE"
  echo "======================================================================"
  echo
  echo "Début d’un nouveau travail :"
  echo "1. Configuration Git globale"
  echo "2. Initialiser un nouveau dépôt Git"
  echo "3. Ajouter ou modifier le remote GitHub"
  echo "4. Ajouter tous les fichiers"
  echo "5. Faire un commit"
  echo "6. Premier push vers GitHub"
  echo
  echo "Travail quotidien :"
  echo "1. Vérifier l’état"
  echo "2. Voir les différences"
  echo "3. Ajouter tous les fichiers"
  echo "4. Commit"
  echo "5. Pull rebase"
  echo "6. Push"
  echo
  echo "Commande rapide recommandée après modification :"
  echo "Workflow rapide complet"
  echo
  echo "Important :"
  echo "Les commandes dangereuses ne sont pas dans gitnav."
  echo "Elles seront placées dans gitdanger avec double protection."

  MESSAGE="Aide affichée."
  pause_back
}

execute_action() {
  case "$SELECTED" in
    0) configure_git ;;
    1) check_git_config ;;
    2) init_repo ;;
    3) show_status ;;
    4) show_modified_files ;;
    5) show_diff_summary ;;
    6) show_full_diff ;;
    7) git_add_all ;;
    8) git_add_one ;;
    9) git_unstage_one ;;
    10) git_commit_menu ;;
    11) show_log ;;
    12) show_last_commit ;;
    13) remote_add_or_set ;;
    14) remote_check ;;
    15) first_push ;;
    16) pull_rebase ;;
    17) push_origin ;;
    18) quick_workflow ;;
    19) show_branches ;;
    20) create_branch ;;
    21) switch_branch ;;
    22) merge_branch ;;
    23) stash_work ;;
    24) stash_pop ;;
    25) create_tag ;;
    26) show_tags ;;
    27) open_github ;;
    28) generate_final_report ;;
    29) show_help ;;
    30)
      clear
      echo "Fin de Gitnav."
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
  cd "$root" 2>/dev/null || cd "$HOME" || exit 1

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
        ;;
      REFRESH)
        MESSAGE="Affichage rafraîchi."
        ;;
      QUIT)
        clear
        echo "Fin de Gitnav."
        exit 0
        ;;
      *)
        MESSAGE="Touche non reconnue."
        ;;
    esac
  done
}

main_loop
