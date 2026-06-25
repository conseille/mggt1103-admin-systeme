#!/usr/bin/env bash
set -u

TOOL_HOME="${TOOL_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$TOOL_HOME/lib/mggt-detect.sh"
mggt_prepare_environment

SELECTED=0
MESSAGE="MGGT Doctor prêt."

ACTIONS=(
  "01. Voir la roadmap technologique TP01 à TP11"
  "02. Vérifier la structure du dépôt"
  "03. Vérifier les outils essentiels TP01 à TP03"
  "04. Vérifier les outils prévus TP04 à TP11"
  "05. Ouvrir le site officiel de Vagrant"
  "06. Ouvrir le site officiel de VirtualBox"
  "07. Ouvrir le site officiel de Terraform"
  "08. Ouvrir le site officiel de Docker"
  "09. Ouvrir le site officiel de Kubernetes"
  "10. Ouvrir le site officiel de K3s"
  "11. Ouvrir le site officiel de Prometheus"
  "12. Afficher la signature admin"
  "13. Quitter"
)

pause_back() {
  echo
  echo "------------------------------------------------------------"
  read -rp "Appuyez sur Entrée pour revenir..."
}

draw() {
  clear
  echo "======================================================================"
  echo "MGGT-DOCTOR — Diagnostic intelligent du laboratoire MGGT1103"
  echo "======================================================================"
  echo
  echo "Racine projet : $MGGT1103_ROOT"
  echo "Dossier cours : $MGGT1103_BASE"
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

show_roadmap() {
  clear
  mggt_tech_roadmap
  mggt_footer
  MESSAGE="Roadmap technologique affichée."
  pause_back
}

check_structure() {
  clear
  echo "======================================================================"
  echo "VÉRIFICATION DE LA STRUCTURE"
  echo "======================================================================"
  echo
  echo "Racine : $MGGT1103_ROOT"
  echo "Base   : $MGGT1103_BASE"
  echo

  for dir in \
    "$MGGT1103_BASE/01-travaux-pratiques" \
    "$MGGT1103_BASE/02-laboratoire-automatisation" \
    "$MGGT1103_BASE/03-outils-de-presentation"
  do
    if [ -d "$dir" ]; then
      echo "[OK] $dir"
    else
      echo "[MANQUANT] $dir"
    fi
  done

  echo
  echo "TP attendus :"
  find "$MGGT1103_BASE/01-travaux-pratiques" -maxdepth 1 -type d -name "TP*" 2>/dev/null | sort | sed 's/^/- /'

  mggt_footer
  MESSAGE="Structure vérifiée."
  pause_back
}

check_tp01_tp03_tools() {
  clear
  echo "======================================================================"
  echo "OUTILS ESSENTIELS TP01 À TP03"
  echo "======================================================================"
  echo

  mggt_check_tool_or_open_site git "Git"
  mggt_check_tool_or_open_site code "Visual Studio Code"
  mggt_check_tool_or_open_site vagrant "Vagrant"
  mggt_check_tool_or_open_site virtualbox "VirtualBox"
  mggt_check_tool_or_open_site terraform "Terraform"

  mggt_footer
  MESSAGE="Outils TP01 à TP03 vérifiés."
  pause_back
}

check_tp04_tp11_tools() {
  clear
  echo "======================================================================"
  echo "OUTILS PRÉVUS TP04 À TP11"
  echo "======================================================================"
  echo

  mggt_check_tool_or_open_site ansible "Ansible"
  mggt_check_tool_or_open_site docker "Docker"
  mggt_check_tool_or_open_site kubectl "kubectl"
  mggt_check_tool_or_open_site k3s "K3s"
  mggt_check_tool_or_open_site prometheus "Prometheus"
  mggt_check_tool_or_open_site grafana "Grafana"
  mggt_check_tool_or_open_site trivy "Trivy"
  mggt_check_tool_or_open_site hadolint "Hadolint"

  echo
  echo "Remarque : certains outils seront installés plus tard selon l’avancement du cours."
  echo "L’objectif ici est d’aider l’utilisateur à trouver les sources officielles."

  mggt_footer
  MESSAGE="Outils TP04 à TP11 vérifiés."
  pause_back
}

open_official() {
  local tool="$1"
  local url

  url="$(mggt_tool_url "$tool")"

  if [ -z "$url" ]; then
    echo "Aucun lien enregistré pour : $tool"
    pause_back
    return
  fi

  mggt_open_url "$url"
  MESSAGE="Site officiel ouvert : $tool"
  pause_back
}

show_signature() {
  clear
  echo "======================================================================"
  echo "SIGNATURE ADMIN"
  echo "======================================================================"
  echo
  echo "Signature utilisée par défaut pour les doubles protections :"
  echo
  echo "$MGGT_ADMIN_SIGNATURE"
  echo
  echo "Cette signature n’est pas un mot de passe cryptographique."
  echo "Elle sert de confirmation pédagogique pour éviter les actions accidentelles."
  mggt_footer
  MESSAGE="Signature affichée."
  pause_back
}

execute_action() {
  case "$SELECTED" in
    0) show_roadmap ;;
    1) check_structure ;;
    2) check_tp01_tp03_tools ;;
    3) check_tp04_tp11_tools ;;
    4) open_official vagrant ;;
    5) open_official virtualbox ;;
    6) open_official terraform ;;
    7) open_official docker ;;
    8) open_official kubectl ;;
    9) open_official k3s ;;
    10) open_official prometheus ;;
    11) show_signature ;;
    12)
      clear
      echo "Fin de MGGT Doctor."
      exit 0
      ;;
    *)
      MESSAGE="Action inconnue."
      ;;
  esac
}

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
      echo "Fin de MGGT Doctor."
      exit 0
      ;;
    *)
      MESSAGE="Touche non reconnue."
      ;;
  esac
done
