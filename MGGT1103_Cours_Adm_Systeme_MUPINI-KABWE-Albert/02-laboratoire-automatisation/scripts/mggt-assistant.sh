#!/usr/bin/env bash
set -u

ROOT="$HOME/MGGT1103/SEANCE1-git-vagrant"
BASE="$ROOT/MGGT1103_Cours_Adm_Systeme_MUPINI-KABWE-Albert"
TP_ROOT="$BASE/01-travaux-pratiques"
AUTO_ROOT="$BASE/02-laboratoire-automatisation"
PRESENT_ROOT="$BASE/03-outils-de-presentation"
RESULT_DIR="$AUTO_ROOT/resultats"

SELECTED=0
MESSAGE="Assistant professeur prêt."

ACTIONS=(
  "01. Accueil et présentation au professeur"
  "02. Comprendre l’organisation générale du dépôt"
  "03. Voir les travaux pratiques détectés"
  "04. Présenter TP01 — Environnement DevOps, Git, Vagrant, DNS/Web"
  "05. Présenter TP02 — Diagnostic Performance et Hardening Linux"
  "06. Présenter TP03 — Terraform et Infrastructure-as-Code"
  "07. Explorer les rapports disponibles"
  "08. Explorer les captures de preuve"
  "09. Explorer les résultats techniques"
  "10. Présenter les scripts et outils créés"
  "11. Lancer TPNAV — Explorateur interactif des TP"
  "12. Lancer GITNAV — Assistant Git complet"
  "13. Lancer VAGRANTNAV — Assistant Vagrant / VirtualBox"
  "14. Vérification rapide du dépôt"
  "15. Générer un rapport professeur"
  "16. Ouvrir le dépôt dans VS Code"
  "17. Ouvrir le dépôt dans l’Explorateur Windows"
  "18. Quitter"
)

pause_back() {
  echo
  echo "------------------------------------------------------------"
  read -rp "Appuyez sur Entrée pour revenir au menu..."
}

clear_title() {
  clear
  echo "======================================================================"
  echo "$1"
  echo "======================================================================"
  echo
}

safe_tree() {
  local dir="$1"
  local depth="${2:-3}"

  if [ ! -d "$dir" ]; then
    echo "Dossier introuvable : $dir"
    return
  fi

  if command -v tree >/dev/null 2>&1; then
    tree -a -L "$depth" \
      -I ".git|.vagrant|.terraform|node_modules|__pycache__|*.Zone.Identifier" \
      "$dir"
  else
    find "$dir" -maxdepth "$depth" \
      -path "*/.git" -prune -o \
      -path "*/.vagrant" -prune -o \
      -path "*/.terraform" -prune -o \
      -path "*/node_modules" -prune -o \
      -print
  fi
}

count_files() {
  local dir="$1"
  if [ -d "$dir" ]; then
    find "$dir" -type f \
      ! -path "*/.git/*" \
      ! -path "*/.vagrant/*" \
      ! -path "*/.terraform/*" \
      ! -name "*.Zone.Identifier" 2>/dev/null | wc -l
  else
    echo "0"
  fi
}

section_status() {
  local dir="$1"
  if [ -d "$dir" ] && [ "$(count_files "$dir")" -gt 0 ]; then
    echo "présent"
  elif [ -d "$dir" ]; then
    echo "vide"
  else
    echo "absent"
  fi
}

tp_status() {
  local tp="$1"
  local rapport captures resultats scripts rendu

  rapport="$(section_status "$tp/rapport")"
  captures="$(section_status "$tp/captures")"
  resultats="$(section_status "$tp/resultats")"
  scripts="$(section_status "$tp/scripts")"
  rendu="$(section_status "$tp/rendu-final")"

  if [ "$rapport" = "présent" ] && [ "$captures" = "présent" ] && [ "$resultats" = "présent" ]; then
    echo "vérifiable"
  elif [ "$(count_files "$tp")" -gt 0 ]; then
    echo "à vérifier"
  else
    echo "non commencé"
  fi
}

draw() {
  clear

  echo "======================================================================"
  echo "MGGT-ASSISTANT — Assistant professeur du cours MGGT1103"
  echo "======================================================================"
  echo
  echo "Étudiant : MUPINI KABWE Albert"
  echo "Cours    : MGGT1103 — Administration Système, Cloud-Native et DevOps"
  echo "Dépôt    : $ROOT"
  echo
  echo "Rôle     : guider le professeur dans la vérification du laboratoire."
  echo
  echo "Touches  : ↑ ↓ choisir | Entrée exécuter | r rafraîchir | q quitter"
  echo "Message  : $MESSAGE"
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

prof_welcome() {
  clear_title "ACCUEIL — MESSAGE AU PROFESSEUR"

  cat <<EOF
Bonjour Professeur.

Je suis l’assistant terminal du dépôt MGGT1103 de MUPINI KABWE Albert.

Mon rôle est de vous aider à comprendre et vérifier rapidement le travail réalisé
dans le cadre du cours :

  MGGT1103 — Administration Système, Cloud-Native et DevOps

Je peux vous guider dans :

  - l’organisation générale du dépôt ;
  - les travaux pratiques réalisés ;
  - les rapports produits ;
  - les captures de preuve ;
  - les résultats techniques ;
  - les scripts d’automatisation ;
  - l’historique Git ;
  - les environnements Vagrant et VirtualBox ;
  - les tests DNS/Web ;
  - les fichiers Terraform.

Des outils spécialisés sont également disponibles :

  tpnav       : explorer les dossiers et fichiers des TP avec les flèches ;
  gitnav      : vérifier Git, commits, branches, remote et push ;
  vagrantnav  : vérifier les VM Vagrant, VirtualBox et les tests DNS/Web.

Cet assistant ne remplace pas les rapports.
Il sert de guide interactif pour lire, comprendre et vérifier le laboratoire.

EOF

  MESSAGE="Accueil professeur affiché."
  pause_back
}

show_structure() {
  clear_title "ORGANISATION GÉNÉRALE DU DÉPÔT"

  cat <<EOF
Le dépôt est organisé en trois grandes parties :

1. 01-travaux-pratiques
   Contient les TP du cours : rapports, captures, résultats, scripts et rendus.

2. 02-laboratoire-automatisation
   Contient les scripts utiles pour naviguer, vérifier, automatiser et présenter
   les travaux réalisés.

3. 03-outils-de-presentation
   Contient les outils de présentation du travail, notamment les interfaces ou
   projets locaux de démonstration.

Arborescence principale :

EOF

  safe_tree "$BASE" 2

  echo
  echo "Résumé numérique :"
  echo "- Fichiers dans les travaux pratiques       : $(count_files "$TP_ROOT")"
  echo "- Fichiers dans le laboratoire automatisation : $(count_files "$AUTO_ROOT")"
  echo "- Fichiers dans les outils de présentation  : $(count_files "$PRESENT_ROOT")"

  MESSAGE="Organisation générale affichée."
  pause_back
}

show_detected_tps() {
  clear_title "TRAVAUX PRATIQUES DÉTECTÉS"

  if [ ! -d "$TP_ROOT" ]; then
    echo "Dossier des TP introuvable."
    MESSAGE="Aucun dossier TP détecté."
    pause_back
    return
  fi

  printf "%-50s %-15s %-10s\n" "Travail pratique" "Statut" "Fichiers"
  printf "%-50s %-15s %-10s\n" "--------------------------------------------------" "---------------" "----------"

  find "$TP_ROOT" -maxdepth 1 -type d -name "TP*" | sort | while read -r tp; do
    name="$(basename "$tp")"
    status="$(tp_status "$tp")"
    files="$(count_files "$tp")"
    printf "%-50s %-15s %-10s\n" "$name" "$status" "$files"
  done

  echo
  echo "Un TP est considéré comme vérifiable lorsqu’il contient au minimum"
  echo "des éléments de rapport, de captures et de résultats techniques."

  MESSAGE="TP détectés affichés."
  pause_back
}

present_tp() {
  local tp_name="$1"
  local title="$2"
  local description="$3"
  local tp_path="$TP_ROOT/$tp_name"

  clear_title "$title"

  if [ ! -d "$tp_path" ]; then
    echo "Ce TP n’est pas encore présent dans le dépôt :"
    echo "$tp_path"
    MESSAGE="TP absent."
    pause_back
    return
  fi

  cat <<EOF
Présentation pédagogique :

$description

Chemin du TP :
$tp_path

Statut détecté : $(tp_status "$tp_path")

Sections principales :
- rapport     : $(section_status "$tp_path/rapport") — $(count_files "$tp_path/rapport") fichier(s)
- captures    : $(section_status "$tp_path/captures") — $(count_files "$tp_path/captures") fichier(s)
- resultats   : $(section_status "$tp_path/resultats") — $(count_files "$tp_path/resultats") fichier(s)
- scripts     : $(section_status "$tp_path/scripts") — $(count_files "$tp_path/scripts") fichier(s)
- rendu-final : $(section_status "$tp_path/rendu-final") — $(count_files "$tp_path/rendu-final") fichier(s)

Arborescence du TP :

EOF

  safe_tree "$tp_path" 3

  echo
  echo "Fichiers importants détectés :"
  find "$tp_path" -type f \
    \( -name "*.md" -o -name "*.docx" -o -name "*.pdf" -o -name "*.sh" -o -name "*.tf" -o -name "Vagrantfile" -o -name "README.md" \) \
    ! -path "*/.vagrant/*" \
    ! -path "*/.terraform/*" \
    ! -name "*.Zone.Identifier" 2>/dev/null | sort

  MESSAGE="$tp_name présenté."
  pause_back
}

present_tp01() {
  present_tp \
    "TP01-environnement-devops-git-vagrant" \
    "TP01 — ENVIRONNEMENT DEVOPS, GIT, VAGRANT, DNS/WEB" \
    "Ce TP montre la mise en place de l’environnement DevOps de base.
Il inclut l’utilisation de WSL2 Ubuntu, Git, VS Code, VirtualBox et Vagrant.
Un complément multi-VM a été réalisé avec un serveur DNS, un serveur Web et
un client de test. Le nom web.mggt1103.local pointe vers le serveur Web."
}

present_tp02() {
  present_tp \
    "TP02-diagnostic-hardening-linux" \
    "TP02 — DIAGNOSTIC PERFORMANCE ET DURCISSEMENT LINUX" \
    "Ce TP présente un travail de diagnostic système Linux et de durcissement.
Il contient des résultats techniques, un audit de sécurité, des corrections,
des scripts et un rapport de synthèse."
}

present_tp03() {
  present_tp \
    "TP03-infrastructure-as-code-terraform" \
    "TP03 — TERRAFORM ET INFRASTRUCTURE-AS-CODE" \
    "Ce TP présente l’utilisation de Terraform pour produire une configuration
déclarative. Il montre l’initialisation, la validation, le plan Terraform et
la génération d’un fichier de configuration DNS."
}

list_reports() {
  clear_title "RAPPORTS DISPONIBLES"

  echo "Rapports Markdown, Word et PDF détectés dans le dépôt :"
  echo

  find "$BASE" -type f \
    \( -name "*.md" -o -name "*.docx" -o -name "*.pdf" \) \
    ! -path "*/.git/*" \
    ! -path "*/.vagrant/*" \
    ! -name "*.Zone.Identifier" 2>/dev/null | sort

  echo
  echo "Le professeur peut ouvrir ces rapports directement depuis VS Code,"
  echo "l’Explorateur Windows ou avec les outils du système."

  MESSAGE="Rapports listés."
  pause_back
}

list_captures() {
  clear_title "CAPTURES DE PREUVE"

  echo "Captures détectées dans les TP :"
  echo

  find "$TP_ROOT" -type f \
    \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) \
    ! -path "*/.git/*" \
    ! -path "*/.vagrant/*" \
    ! -name "*.Zone.Identifier" 2>/dev/null | sort

  echo
  echo "Ces captures servent de preuves visuelles pour montrer les commandes,"
  echo "résultats, interfaces, tests et validations effectués."

  MESSAGE="Captures listées."
  pause_back
}

list_results() {
  clear_title "RÉSULTATS TECHNIQUES"

  echo "Fichiers de résultats détectés :"
  echo

  find "$TP_ROOT" -type f \
    \( -name "*.txt" -o -name "*.log" -o -name "*.out" -o -name "*.json" \) \
    ! -path "*/.git/*" \
    ! -path "*/.vagrant/*" \
    ! -path "*/.terraform/*" \
    ! -name "*.Zone.Identifier" 2>/dev/null | sort

  echo
  echo "Aperçu des premiers fichiers texte :"
  echo

  find "$TP_ROOT" -type f \
    \( -name "*.txt" -o -name "*.log" -o -name "*.md" \) \
    ! -path "*/.git/*" \
    ! -path "*/.vagrant/*" \
    ! -path "*/.terraform/*" \
    ! -name "*.Zone.Identifier" 2>/dev/null | sort | head -5 | while read -r f; do
      echo "----------------------------------------------------------------------"
      echo "$f"
      echo "----------------------------------------------------------------------"
      sed -n '1,25p' "$f" 2>/dev/null || true
      echo
    done

  MESSAGE="Résultats techniques affichés."
  pause_back
}

present_tools() {
  clear_title "SCRIPTS ET OUTILS CRÉÉS"

  cat <<EOF
Le laboratoire contient plusieurs outils pour faciliter la vérification :

1. tpnav
   Explorateur interactif des TP.
   Il permet de naviguer dans les dossiers avec les flèches, comme un mini
   explorateur de fichiers dans le terminal.

2. gitnav
   Assistant Git complet.
   Il permet de vérifier la configuration Git, les commits, les branches,
   le remote GitHub, les différences, le pull et le push.

3. vagrantnav
   Assistant Vagrant et VirtualBox.
   Il permet de gérer les VM, vérifier les Vagrantfile, lancer les tests
   DNS/Web et contrôler les machines virtuelles.

4. mggt-assistant
   Assistant professeur.
   Il guide la lecture du dépôt, explique les TP et propose les bons outils
   de vérification.

Scripts détectés :

EOF

  find "$AUTO_ROOT" -type f -name "*.sh" ! -name "*.Zone.Identifier" 2>/dev/null | sort

  MESSAGE="Scripts et outils présentés."
  pause_back
}

run_tool() {
  local tool="$1"

  clear_title "LANCEMENT DE $tool"

  if command -v "$tool" >/dev/null 2>&1; then
    echo "Lancement de l’outil : $tool"
    echo
    "$tool"
    MESSAGE="$tool lancé."
  else
    echo "Commande introuvable : $tool"
    echo
    echo "Vérifiez que le raccourci existe dans ~/.local/bin."
    echo "Vous pouvez aussi lancer le script directement depuis :"
    echo "$AUTO_ROOT/scripts"
    MESSAGE="$tool introuvable."
    pause_back
  fi
}

quick_check() {
  clear_title "VÉRIFICATION RAPIDE DU DÉPÔT"

  echo "1. Vérification des dossiers principaux"
  echo "----------------------------------------------------------------------"
  for d in "$TP_ROOT" "$AUTO_ROOT" "$PRESENT_ROOT"; do
    if [ -d "$d" ]; then
      echo "[OK] $d"
    else
      echo "[ABSENT] $d"
    fi
  done

  echo
  echo "2. Travaux pratiques"
  echo "----------------------------------------------------------------------"
  if [ -d "$TP_ROOT" ]; then
    find "$TP_ROOT" -maxdepth 1 -type d -name "TP*" | sort | while read -r tp; do
      echo "- $(basename "$tp") : $(tp_status "$tp") — $(count_files "$tp") fichier(s)"
    done
  fi

  echo
  echo "3. Git"
  echo "----------------------------------------------------------------------"
  if [ -d "$ROOT/.git" ]; then
    cd "$ROOT" || true
    echo "Branche : $(git branch --show-current 2>/dev/null || echo inconnue)"
    echo "Dernier commit :"
    git log --oneline -1 2>/dev/null || echo "Aucun commit."
    echo
    echo "État Git :"
    git status --short 2>/dev/null || true
  else
    echo "Dépôt Git non détecté."
  fi

  echo
  echo "4. Outils disponibles"
  echo "----------------------------------------------------------------------"
  for tool in tpnav gitnav vagrantnav mggt-assistant; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "[OK] $tool"
    else
      echo "[MANQUANT] $tool"
    fi
  done

  MESSAGE="Vérification rapide terminée."
  pause_back
}

generate_prof_report() {
  clear_title "GÉNÉRATION DU RAPPORT PROFESSEUR"

  mkdir -p "$RESULT_DIR"

  local report="$RESULT_DIR/rapport-professeur-mggt1103.txt"

  {
    echo "RAPPORT PROFESSEUR — MGGT1103"
    echo "Étudiant : MUPINI KABWE Albert"
    echo "Date     : $(date)"
    echo "Dépôt    : $ROOT"
    echo
    echo "1. Organisation générale"
    echo "----------------------------------------------------------------------"
    echo "$BASE"
    echo
    safe_tree "$BASE" 2
    echo
    echo "2. Travaux pratiques détectés"
    echo "----------------------------------------------------------------------"
    if [ -d "$TP_ROOT" ]; then
      find "$TP_ROOT" -maxdepth 1 -type d -name "TP*" | sort | while read -r tp; do
        echo "- $(basename "$tp") : $(tp_status "$tp") — $(count_files "$tp") fichier(s)"
      done
    fi
    echo
    echo "3. Rapports"
    echo "----------------------------------------------------------------------"
    find "$BASE" -type f \( -name "*.md" -o -name "*.docx" -o -name "*.pdf" \) \
      ! -path "*/.git/*" ! -path "*/.vagrant/*" ! -name "*.Zone.Identifier" 2>/dev/null | sort
    echo
    echo "4. Captures"
    echo "----------------------------------------------------------------------"
    find "$TP_ROOT" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) \
      ! -path "*/.git/*" ! -path "*/.vagrant/*" ! -name "*.Zone.Identifier" 2>/dev/null | sort
    echo
    echo "5. Résultats techniques"
    echo "----------------------------------------------------------------------"
    find "$TP_ROOT" -type f \( -name "*.txt" -o -name "*.log" -o -name "*.out" -o -name "*.json" \) \
      ! -path "*/.git/*" ! -path "*/.vagrant/*" ! -path "*/.terraform/*" ! -name "*.Zone.Identifier" 2>/dev/null | sort
    echo
    echo "6. Scripts d’automatisation"
    echo "----------------------------------------------------------------------"
    find "$AUTO_ROOT" -type f -name "*.sh" ! -name "*.Zone.Identifier" 2>/dev/null | sort
    echo
    echo "7. Git"
    echo "----------------------------------------------------------------------"
    if [ -d "$ROOT/.git" ]; then
      cd "$ROOT" || true
      echo "Branche : $(git branch --show-current 2>/dev/null || echo inconnue)"
      echo
      echo "Derniers commits :"
      git log --oneline --decorate -10 2>/dev/null || true
      echo
      echo "État Git :"
      git status --short 2>/dev/null || true
    fi
    echo
    echo "8. Outils recommandés pour la vérification"
    echo "----------------------------------------------------------------------"
    echo "tpnav       : explorer les TP"
    echo "gitnav      : vérifier Git"
    echo "vagrantnav  : vérifier les VM et les tests Vagrant"
    echo "mggt-assistant : relancer ce guide professeur"
  } > "$report"

  echo "Rapport généré :"
  echo "$report"
  echo
  echo "Aperçu :"
  echo "----------------------------------------------------------------------"
  sed -n '1,80p' "$report"

  MESSAGE="Rapport professeur généré."
  pause_back
}

open_vscode() {
  clear_title "OUVERTURE DANS VS CODE"

  if command -v code >/dev/null 2>&1; then
    code "$ROOT" >/dev/null 2>&1 &
    echo "VS Code demandé pour : $ROOT"
  else
    echo "La commande code n’est pas disponible."
  fi

  MESSAGE="Ouverture VS Code demandée."
  pause_back
}

open_explorer() {
  clear_title "OUVERTURE DANS L’EXPLORATEUR WINDOWS"

  explorer.exe "$ROOT" >/dev/null 2>&1 || true
  echo "Explorateur Windows demandé pour : $ROOT"

  MESSAGE="Explorateur Windows demandé."
  pause_back
}

execute_action() {
  case "$SELECTED" in
    0) prof_welcome ;;
    1) show_structure ;;
    2) show_detected_tps ;;
    3) present_tp01 ;;
    4) present_tp02 ;;
    5) present_tp03 ;;
    6) list_reports ;;
    7) list_captures ;;
    8) list_results ;;
    9) present_tools ;;
    10) run_tool "tpnav" ;;
    11) run_tool "gitnav" ;;
    12) run_tool "vagrantnav" ;;
    13) quick_check ;;
    14) generate_prof_report ;;
    15) open_vscode ;;
    16) open_explorer ;;
    17)
      clear
      echo "Fin de l’assistant professeur MGGT1103."
      exit 0
      ;;
    *)
      MESSAGE="Action inconnue."
      ;;
  esac
}

main_loop() {
  if [ ! -d "$BASE" ]; then
    echo "Erreur : dossier principal MGGT1103 introuvable."
    echo "$BASE"
    exit 1
  fi

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
        echo "Fin de l’assistant professeur MGGT1103."
        exit 0
        ;;
      *)
        MESSAGE="Touche non reconnue."
        ;;
    esac
  done
}

main_loop
