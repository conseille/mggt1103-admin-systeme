#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/MGGT1103/SEANCE1-git-vagrant"
BASE="$ROOT/MGGT1103_Cours_Adm_Systeme_MUPINI-KABWE-Albert"
TP_ROOT="$BASE/01-travaux-pratiques"

START="$(realpath "$TP_ROOT")"
CURRENT="$START"
SELECTED=0
MESSAGE="Navigation prête."

items=()

ignore_name() {
  local name="$1"

  case "$name" in
    "."|".."|".git"|".vagrant"|".terraform"|node_modules|__pycache__|".gitkeep")
      return 0
      ;;
    *":Zone.Identifier")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

inside_start() {
  local path
  path="$(realpath -m "$1")"

  [[ "$path" == "$START" || "$path" == "$START/"* ]]
}

relpath() {
  local path
  path="$(realpath -m "$1")"

  if [[ "$path" == "$START" ]]; then
    echo "."
  else
    echo "${path#$START/}"
  fi
}

load_items() {
  items=()

  local dirs=()
  local files=()

  while IFS= read -r p; do
    local name
    name="$(basename "$p")"

    if ignore_name "$name"; then
      continue
    fi

    if [ -d "$p" ]; then
      dirs+=("$p")
    else
      files+=("$p")
    fi
  done < <(find "$CURRENT" -maxdepth 1 -mindepth 1 2>/dev/null | sort)

  items=("${dirs[@]}" "${files[@]}")

  if [ "${#items[@]}" -eq 0 ]; then
    SELECTED=0
  elif [ "$SELECTED" -ge "${#items[@]}" ]; then
    SELECTED=$((${#items[@]} - 1))
  fi
}

file_icon() {
  local path="$1"

  if [ -d "$path" ]; then
    echo "📁"
    return
  fi

  case "${path##*.}" in
    md|txt|log) echo "📄" ;;
    sh|ps1|py) echo "⚙️" ;;
    tf) echo "🏗️" ;;
    png|jpg|jpeg|webp) echo "🖼️" ;;
    pdf|docx) echo "📝" ;;
    html) echo "🌐" ;;
    *) echo "📌" ;;
  esac
}

draw() {
  load_items
  clear

  echo "======================================================================"
  echo "TPNAV — Navigateur interactif des TP MGGT1103"
  echo "======================================================================"
  echo
  echo "Position : $(relpath "$CURRENT")"
  echo "Chemin   : $CURRENT"
  echo
  echo "Touches  : ↑ ↓ naviguer | → ou Entrée entrer/ouvrir | ← cd .. | c cd"
  echo "Actions  : v afficher | g git | o explorateur | e VS Code | r refresh | q quitter"
  echo
  echo "Message  : $MESSAGE"
  echo "----------------------------------------------------------------------"

  if [ "${#items[@]}" -eq 0 ]; then
    echo "Dossier vide."
    echo
    return
  fi

  local i=0
  for item in "${items[@]}"; do
    local name icon type marker
    name="$(basename "$item")"
    icon="$(file_icon "$item")"

    if [ -d "$item" ]; then
      type="dossier"
    else
      type="fichier"
    fi

    if [ "$i" -eq "$SELECTED" ]; then
      marker="➜"
    else
      marker=" "
    fi

    printf "%s %2d. %s %-45s [%s]\n" "$marker" "$((i+1))" "$icon" "$name" "$type"

    i=$((i + 1))
  done

  echo "----------------------------------------------------------------------"
}

go_parent() {
  local parent
  parent="$(dirname "$CURRENT")"

  if inside_start "$parent"; then
    CURRENT="$(realpath "$parent")"
    SELECTED=0
    MESSAGE="Commande cd .. exécutée."
  else
    MESSAGE="Impossible de sortir du dossier des TP."
  fi
}

enter_selected() {
  load_items

  if [ "${#items[@]}" -eq 0 ]; then
    MESSAGE="Aucun élément à ouvrir."
    return
  fi

  local target="${items[$SELECTED]}"

  if [ -d "$target" ]; then
    CURRENT="$(realpath "$target")"
    SELECTED=0
    MESSAGE="Commande cd $(basename "$target") exécutée."
  else
    preview_file "$target"
  fi
}

preview_file() {
  local file="$1"
  clear

  echo "======================================================================"
  echo "APERÇU DU FICHIER"
  echo "======================================================================"
  echo
  echo "Fichier : $(basename "$file")"
  echo "Chemin  : $file"
  echo

  case "${file##*.}" in
    md|txt|log|sh|ps1|py|tf|html|json|css|js)
      echo "---------- Début du contenu ----------"
      sed -n '1,160p' "$file" 2>/dev/null || echo "Impossible de lire le fichier."
      echo "----------- Fin de l’aperçu ----------"
      ;;
    png|jpg|jpeg|webp|pdf|docx)
      echo "Ce fichier n’est pas affiché directement dans le terminal."
      echo "Utilise la touche o pour ouvrir le dossier dans l’Explorateur Windows."
      ;;
    *)
      echo "Type de fichier non prévu pour aperçu direct."
      ;;
  esac

  echo
  read -rp "Appuie sur Entrée pour revenir..."
  MESSAGE="Retour à la navigation."
}

show_position() {
  clear

  echo "======================================================================"
  echo "AFFICHAGE AUTOMATIQUE DE LA POSITION COURANTE"
  echo "======================================================================"
  echo
  echo "1. Commande pwd"
  echo "----------------------------------------------------------------------"
  pwd
  echo

  echo "2. Commande ls -la"
  echo "----------------------------------------------------------------------"
  ls -la "$CURRENT"
  echo

  echo "3. Arborescence tree -a -L 3"
  echo "----------------------------------------------------------------------"
  if command -v tree >/dev/null 2>&1; then
    tree -a -L 3 -I ".git|.vagrant|.terraform|node_modules|__pycache__" "$CURRENT"
  else
    find "$CURRENT" -maxdepth 3 \
      -path "*/.git" -prune -o \
      -path "*/.vagrant" -prune -o \
      -path "*/.terraform" -prune -o \
      -print
  fi
  echo

  echo "4. Liste des fichiers importants"
  echo "----------------------------------------------------------------------"
  find "$CURRENT" -maxdepth 3 -type f \
    ! -path "*/.git/*" \
    ! -path "*/.vagrant/*" \
    ! -path "*/.terraform/*" \
    ! -name "*:Zone.Identifier" \
    | sort
  echo

  echo "5. Taille du dossier courant"
  echo "----------------------------------------------------------------------"
  du -sh "$CURRENT" 2>/dev/null || true
  echo

  echo "6. Nombre de fichiers"
  echo "----------------------------------------------------------------------"
  find "$CURRENT" -type f \
    ! -path "*/.git/*" \
    ! -path "*/.vagrant/*" \
    ! -path "*/.terraform/*" \
    ! -name "*:Zone.Identifier" \
    | wc -l
  echo

  read -rp "Appuie sur Entrée pour revenir..."
  MESSAGE="Affichage automatique terminé."
}

show_git() {
  clear

  echo "======================================================================"
  echo "ÉTAT GIT DU DÉPÔT"
  echo "======================================================================"
  echo

  cd "$ROOT"

  echo "Branche actuelle :"
  git branch --show-current
  echo

  echo "Dernier commit :"
  git log --oneline -1
  echo

  echo "État Git :"
  git status --short
  echo

  echo "Derniers commits :"
  git log --oneline --decorate -8
  echo

  read -rp "Appuie sur Entrée pour revenir..."
  MESSAGE="Affichage Git terminé."
}

open_explorer() {
  explorer.exe "$CURRENT" >/dev/null 2>&1 || true
  MESSAGE="Explorateur Windows ouvert."
}

open_vscode() {
  code "$CURRENT" >/dev/null 2>&1 &
  MESSAGE="VS Code demandé."
}

command_mode() {
  echo
  read -rp "Commande cd : " cmd

  case "$cmd" in
    "cd")
      CURRENT="$START"
      SELECTED=0
      MESSAGE="Retour à la racine des TP."
      ;;
    "cd.."|"cd ..")
      go_parent
      ;;
    cd\ *)
      local arg="${cmd#cd }"
      local target

      if [[ "$arg" == /* ]]; then
        target="$(realpath -m "$arg")"
      else
        target="$(realpath -m "$CURRENT/$arg")"
      fi

      if [ -d "$target" ] && inside_start "$target"; then
        CURRENT="$target"
        SELECTED=0
        MESSAGE="Commande cd $arg exécutée."
      else
        MESSAGE="Dossier introuvable ou hors zone TP : $arg"
      fi
      ;;
    *)
      MESSAGE="Commande non acceptée. Utilise : cd, cd .., cd.. ou cd dossier"
      ;;
  esac
}

read_key() {
  local key rest

  IFS= read -rsn1 key || true

  if [[ "$key" == $'\e' ]]; then
    IFS= read -rsn2 rest || true

    case "$rest" in
      "[A") echo "UP" ;;
      "[B") echo "DOWN" ;;
      "[C") echo "RIGHT" ;;
      "[D") echo "LEFT" ;;
      *) echo "ESC" ;;
    esac
  else
    case "$key" in
      "") echo "ENTER" ;;
      q) echo "QUIT" ;;
      r) echo "REFRESH" ;;
      v) echo "VIEW" ;;
      g) echo "GIT" ;;
      o) echo "OPEN" ;;
      e) echo "CODE" ;;
      c|:) echo "COMMAND" ;;
      h|?) echo "HELP" ;;
      *) echo "OTHER" ;;
    esac
  fi
}

show_help() {
  clear

  echo "======================================================================"
  echo "AIDE TPNAV"
  echo "======================================================================"
  echo
  echo "↑        : monter dans la liste"
  echo "↓        : descendre dans la liste"
  echo "→        : entrer dans le dossier sélectionné"
  echo "←        : revenir au dossier parent, comme cd .."
  echo "Entrée   : entrer dans un dossier ou afficher un fichier"
  echo "v        : afficher automatiquement pwd, ls -la, tree et find"
  echo "g        : afficher l’état Git"
  echo "o        : ouvrir le dossier courant dans l’Explorateur Windows"
  echo "e        : ouvrir le dossier courant dans VS Code"
  echo "c ou :   : taper une commande cd"
  echo "r        : rafraîchir"
  echo "q        : quitter"
  echo
  echo "Commandes acceptées en mode cd :"
  echo "cd"
  echo "cd .."
  echo "cd.."
  echo "cd nom-du-dossier"
  echo
  read -rp "Appuie sur Entrée pour revenir..."
  MESSAGE="Aide affichée."
}

main_loop() {
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
        if [ "${#items[@]}" -gt 0 ] && [ "$SELECTED" -lt "$((${#items[@]} - 1))" ]; then
          SELECTED=$((SELECTED + 1))
        fi
        ;;
      RIGHT|ENTER)
        enter_selected
        ;;
      LEFT)
        go_parent
        ;;
      VIEW)
        show_position
        ;;
      GIT)
        show_git
        ;;
      OPEN)
        open_explorer
        ;;
      CODE)
        open_vscode
        ;;
      COMMAND)
        command_mode
        ;;
      REFRESH)
        MESSAGE="Affichage rafraîchi."
        ;;
      HELP)
        show_help
        ;;
      QUIT)
        clear
        echo "Fin de TPNAV."
        exit 0
        ;;
      *)
        MESSAGE="Touche non reconnue. Appuie sur h pour l’aide."
        ;;
    esac
  done
}

if [ ! -d "$START" ]; then
  echo "Erreur : dossier des TP introuvable."
  echo "$START"
  exit 1
fi

main_loop
