#!/usr/bin/env bash
set -u

DEFAULT_LAB="$HOME/MGGT1103/SEANCE1-git-vagrant/MGGT1103_Cours_Adm_Systeme_MUPINI-KABWE-Albert/01-travaux-pratiques/TP01-environnement-devops-git-vagrant/rendu-final/multi-vm-dns-web"
WINDOWS_LAB_DEFAULT="/mnt/c/Users/Ethan/MGGT1103-vagrant-labs/multi-vm-dns-web"

CONFIG_DIR="$HOME/.config/mggt1103-nav"
CONFIG_FILE="$CONFIG_DIR/vagrantnav.conf"

mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG_FILE" ]; then
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
fi

LAB_PATH="${LAB_PATH:-$WINDOWS_LAB_DEFAULT}"

SELECTED=0
MESSAGE="Vagrantnav prêt."

ACTIONS=(
  "01. Afficher le dossier Vagrant utilisé"
  "02. Changer le dossier Vagrant"
  "03. Vérifier la version de Vagrant"
  "04. Valider le Vagrantfile"
  "05. Voir vagrant status"
  "06. Voir vagrant global-status --prune"
  "07. Voir les machines définies dans le Vagrantfile"
  "08. Lancer toutes les VM : vagrant up"
  "09. Arrêter toutes les VM : vagrant halt"
  "10. Redémarrer toutes les VM : vagrant reload"
  "11. Reprovisionner toutes les VM"
  "12. Lancer une VM précise"
  "13. Arrêter une VM précise"
  "14. Redémarrer une VM précise"
  "15. Reprovisionner une VM précise"
  "16. Ouvrir SSH vers une VM"
  "17. Afficher ssh-config"
  "18. Tester DNS : web.mggt1103.local"
  "19. Tester Web par IP"
  "20. Tester Web par nom DNS"
  "21. Lancer tous les tests DNS/Web et sauvegarder"
  "22. Voir les résultats enregistrés"
  "23. Voir les snapshots"
  "24. Créer un snapshot"
  "25. Restaurer un snapshot"
  "26. Supprimer un snapshot"
  "27. Voir les boxes Vagrant"
  "28. Vérifier les mises à jour des boxes"
  "29. Mettre à jour une box"
  "30. Ouvrir PowerShell dans le dossier Vagrant"
  "31. Ouvrir l’Explorateur Windows"
  "32. Ouvrir VirtualBox"
  "33. Copier le lab WSL vers le lab Windows"
  "34. VirtualBox : voir toutes les VM existantes"
  "35. VirtualBox : allumer une VM existante"
  "36. VirtualBox : arrêter proprement une VM existante"
  "37. VirtualBox : allumer toutes les VM existantes"
  "38. Vagrantfile : créer un lab de 1, 2, 3 ou 6 VM"
  "39. Action dangereuse : destroy une VM"
  "40. Action dangereuse : destroy toutes les VM"
  "41. Aide rapide Vagrant"
  "42. Quitter"
)
save_config() {
  echo "LAB_PATH=\"$LAB_PATH\"" > "$CONFIG_FILE"
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

danger_guard() {
  local action="$1"
  local phrase="$2"
  local key typed_key typed_phrase

  clear
  echo "======================================================================"
  echo "DOUBLE PROTECTION — ACTION VAGRANT DANGEREUSE"
  echo "======================================================================"
  echo
  echo "Action : $action"
  echo
  echo "Cette action peut supprimer une ou plusieurs machines virtuelles."
  echo "Les fichiers du projet restent normalement présents, mais la VM sera supprimée."
  echo

  if ! confirm "Première confirmation : continuer ?"; then
    echo "Action annulée."
    pause_back
    return 1
  fi

  key="VAGRANT-$(date +%S)-$RANDOM"
  key="${key:0:14}"

  echo
  echo "Clé dynamique : $key"
  read -rp "Retape exactement cette clé : " typed_key

  if [ "$typed_key" != "$key" ]; then
    echo
    echo "Clé incorrecte. Action bloquée."
    pause_back
    return 1
  fi

  echo
  echo "Phrase attendue : $phrase"
  read -rp "Retape exactement la phrase : " typed_phrase

  if [ "$typed_phrase" != "$phrase" ]; then
    echo
    echo "Phrase incorrecte. Action bloquée."
    pause_back
    return 1
  fi

  return 0
}

lab_exists() {
  [ -d "$LAB_PATH" ] && [ -f "$LAB_PATH/Vagrantfile" ]
}

lab_win_path() {
  wslpath -w "$LAB_PATH" 2>/dev/null
}

safe_ps_quote() {
  local s="$1"
  s="${s//\'/\'\'}"
  printf "%s" "$s"
}

run_ps_in_lab() {
  local command="$1"

  if ! lab_exists; then
    echo "Erreur : dossier Vagrant invalide ou Vagrantfile absent."
    echo "Dossier actuel : $LAB_PATH"
    echo
    echo "Utilise l’option 02 pour corriger le dossier."
    return 1
  fi

  local lab_win psfile psfile_win lab_quoted
  lab_win="$(lab_win_path)"
  lab_quoted="$(safe_ps_quote "$lab_win")"

  psfile="$(mktemp --suffix=.ps1)"
  psfile_win="$(wslpath -w "$psfile")"

  cat > "$psfile" <<EOF
Set-Location -LiteralPath '$lab_quoted'
$command
EOF

  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$psfile_win"
  local code=$?

  rm -f "$psfile"
  return $code
}

open_ps_in_lab() {
  local command="${1:-}"

  if ! lab_exists; then
    echo "Erreur : dossier Vagrant invalide ou Vagrantfile absent."
    pause_back
    return 1
  fi

  local lab_win lab_quoted psfile psfile_win
  lab_win="$(lab_win_path)"
  lab_quoted="$(safe_ps_quote "$lab_win")"

  psfile="$LAB_PATH/.vagrantnav-open.ps1"
  psfile_win="$(wslpath -w "$psfile")"

  cat > "$psfile" <<EOF
Set-Location -LiteralPath '$lab_quoted'
Write-Host "Dossier Vagrant : $lab_win"
Write-Host ""
$command
EOF

  powershell.exe -NoProfile -Command "Start-Process powershell.exe -ArgumentList '-NoExit','-ExecutionPolicy','Bypass','-File','$psfile_win'" >/dev/null 2>&1
}

draw() {
  clear

  echo "======================================================================"
  echo "VAGRANTNAV — Assistant Vagrant complet MGGT1103"
  echo "======================================================================"
  echo
  echo "Dossier Vagrant : $LAB_PATH"

  if lab_exists; then
    echo "Vagrantfile    : trouvé"
  else
    echo "Vagrantfile    : absent ou mauvais dossier"
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

list_vms() {
  if [ -f "$LAB_PATH/Vagrantfile" ]; then
    grep -oE 'config\.vm\.define[[:space:]]+"[^"]+"' "$LAB_PATH/Vagrantfile" \
      | sed -E 's/.*"([^"]+)"/\1/' \
      | sort -u
  fi
}

choose_vm() {
  local vms=()
  local vm
  local selected

  mapfile -t vms < <(list_vms)

  if [ "${#vms[@]}" -eq 0 ]; then
    echo "Aucune VM détectée dans le Vagrantfile." >&2
    return 1
  fi

  echo >&2
  echo "Machines disponibles :" >&2

  for vm in "${vms[@]}"; do
    echo " - $vm" >&2
  done

  echo >&2
  echo "Exemples :" >&2
  echo "srv-dns" >&2
  echo "srv-web" >&2
  echo "client-test" >&2
  echo >&2

  read -r -p "Tape le nom exact de la VM : " selected < /dev/tty

  selected="$(echo "$selected" | xargs)"

  if [ -z "$selected" ]; then
    echo "Nom vide. Action annulée." >&2
    return 1
  fi

  for vm in "${vms[@]}"; do
    if [ "$selected" = "$vm" ]; then
      echo "$selected"
      return 0
    fi
  done

  echo "Nom invalide : $selected" >&2
  echo "Utilise exactement un nom affiché dans la liste." >&2
  return 1
}


show_lab() {
  clear
  echo "======================================================================"
  echo "DOSSIER VAGRANT UTILISÉ"
  echo "======================================================================"
  echo
  echo "Chemin WSL :"
  echo "$LAB_PATH"
  echo
  echo "Chemin Windows :"
  lab_win_path || true
  echo
  echo "Contenu :"
  if [ -d "$LAB_PATH" ]; then
    ls -la "$LAB_PATH"
  else
    echo "Dossier absent."
  fi

  MESSAGE="Dossier Vagrant affiché."
  pause_back
}

change_lab() {
  clear
  echo "======================================================================"
  echo "CHANGER LE DOSSIER VAGRANT"
  echo "======================================================================"
  echo
  echo "Dossier actuel : $LAB_PATH"
  echo
  echo "Exemples :"
  echo "$WINDOWS_LAB_DEFAULT"
  echo "$DEFAULT_LAB"
  echo
  read -rp "Nouveau chemin WSL du dossier contenant le Vagrantfile : " new_path

  if [ -z "$new_path" ]; then
    MESSAGE="Changement annulé."
    pause_back
    return
  fi

  new_path="${new_path/#\~/$HOME}"

  if [ ! -f "$new_path/Vagrantfile" ]; then
    echo
    echo "Aucun Vagrantfile trouvé dans : $new_path"
    MESSAGE="Dossier refusé."
    pause_back
    return
  fi

  LAB_PATH="$new_path"
  save_config
  MESSAGE="Dossier Vagrant changé."
  pause_back
}

vagrant_version() {
  clear
  echo "======================================================================"
  echo "VERSION DE VAGRANT"
  echo "======================================================================"
  echo
  powershell.exe -NoProfile -Command "vagrant --version" 2>/dev/null || echo "Vagrant introuvable côté Windows."
  MESSAGE="Version Vagrant affichée."
  pause_back
}

validate_vagrantfile() {
  clear
  echo "======================================================================"
  echo "VALIDER LE VAGRANTFILE"
  echo "======================================================================"
  echo
  run_ps_in_lab "vagrant validate"
  MESSAGE="Validation terminée."
  pause_back
}

vagrant_status() {
  clear
  echo "======================================================================"
  echo "VAGRANT STATUS"
  echo "======================================================================"
  echo
  run_ps_in_lab "vagrant status"
  MESSAGE="Status affiché."
  pause_back
}

global_status() {
  clear
  echo "======================================================================"
  echo "VAGRANT GLOBAL-STATUS --PRUNE"
  echo "======================================================================"
  echo
  powershell.exe -NoProfile -Command "vagrant global-status --prune"
  MESSAGE="Global-status affiché."
  pause_back
}

show_vms() {
  clear
  echo "======================================================================"
  echo "MACHINES DÉFINIES DANS LE VAGRANTFILE"
  echo "======================================================================"
  echo
  list_vms || true
  MESSAGE="Liste des VM affichée."
  pause_back
}

up_all() {
  clear
  echo "======================================================================"
  echo "LANCER TOUTES LES VM"
  echo "======================================================================"
  echo
  run_ps_in_lab "vagrant up"
  MESSAGE="vagrant up terminé."
  pause_back
}

halt_all() {
  clear
  echo "======================================================================"
  echo "ARRÊTER TOUTES LES VM"
  echo "======================================================================"
  echo
  run_ps_in_lab "vagrant halt"
  MESSAGE="vagrant halt terminé."
  pause_back
}

reload_all() {
  clear
  echo "======================================================================"
  echo "REDÉMARRER TOUTES LES VM"
  echo "======================================================================"
  echo
  run_ps_in_lab "vagrant reload"
  MESSAGE="vagrant reload terminé."
  pause_back
}

provision_all() {
  clear
  echo "======================================================================"
  echo "REPROVISIONNER TOUTES LES VM"
  echo "======================================================================"
  echo
  run_ps_in_lab "vagrant provision"
  MESSAGE="Provision all terminé."
  pause_back
}

up_vm() {
  clear
  echo "======================================================================"
  echo "LANCER UNE VM"
  echo "======================================================================"
  vm="$(choose_vm)" || { pause_back; return; }
  echo
  run_ps_in_lab "vagrant up $vm"
  MESSAGE="VM lancée : $vm"
  pause_back
}

halt_vm() {
  clear
  echo "======================================================================"
  echo "ARRÊTER UNE VM"
  echo "======================================================================"
  vm="$(choose_vm)" || { pause_back; return; }
  echo
  run_ps_in_lab "vagrant halt $vm"
  MESSAGE="VM arrêtée : $vm"
  pause_back
}

reload_vm() {
  clear
  echo "======================================================================"
  echo "REDÉMARRER UNE VM"
  echo "======================================================================"
  vm="$(choose_vm)" || { pause_back; return; }
  echo
  run_ps_in_lab "vagrant reload $vm"
  MESSAGE="VM redémarrée : $vm"
  pause_back
}

provision_vm() {
  clear
  echo "======================================================================"
  echo "REPROVISIONNER UNE VM"
  echo "======================================================================"
  vm="$(choose_vm)" || { pause_back; return; }
  echo
  run_ps_in_lab "vagrant provision $vm"
  MESSAGE="VM reprovisionnée : $vm"
  pause_back
}

ssh_vm() {
  clear
  echo "======================================================================"
  echo "SSH VERS UNE VM"
  echo "======================================================================"
  vm="$(choose_vm)" || { pause_back; return; }
  echo
  echo "Une fenêtre PowerShell va s’ouvrir avec : vagrant ssh $vm"
  open_ps_in_lab "vagrant ssh $vm"
  MESSAGE="PowerShell SSH ouvert pour $vm."
  pause_back
}

ssh_config() {
  clear
  echo "======================================================================"
  echo "SSH-CONFIG"
  echo "======================================================================"
  echo
  run_ps_in_lab "vagrant ssh-config"
  MESSAGE="ssh-config affiché."
  pause_back
}

test_dns() {
  clear
  echo "======================================================================"
  echo "TEST DNS"
  echo "======================================================================"
  echo
  run_ps_in_lab 'vagrant ssh client-test -c "dig @192.168.56.10 web.mggt1103.local +short"'
  MESSAGE="Test DNS terminé."
  pause_back
}

test_web_ip() {
  clear
  echo "======================================================================"
  echo "TEST WEB PAR IP"
  echo "======================================================================"
  echo
  run_ps_in_lab 'vagrant ssh client-test -c "curl -I http://192.168.56.20"'
  MESSAGE="Test Web IP terminé."
  pause_back
}

test_web_dns() {
  clear
  echo "======================================================================"
  echo "TEST WEB PAR NOM DNS"
  echo "======================================================================"
  echo
  run_ps_in_lab 'vagrant ssh client-test -c "curl -I http://web.mggt1103.local"'
  MESSAGE="Test Web DNS terminé."
  pause_back
}

run_all_tests_save() {
  clear
  echo "======================================================================"
  echo "TESTS DNS/WEB COMPLETS AVEC SAUVEGARDE"
  echo "======================================================================"
  echo

  mkdir -p "$LAB_PATH/resultats"

  {
    echo "RÉSULTATS TESTS VAGRANT DNS/WEB — MGGT1103"
    echo "Date : $(date)"
    echo
    echo "===== vagrant status ====="
    run_ps_in_lab "vagrant status"
    echo
    echo "===== DNS : dig web.mggt1103.local ====="
    run_ps_in_lab 'vagrant ssh client-test -c "dig @192.168.56.10 web.mggt1103.local +short"'
    echo
    echo "===== HTTP par IP ====="
    run_ps_in_lab 'vagrant ssh client-test -c "curl -I http://192.168.56.20"'
    echo
    echo "===== HTTP par DNS ====="
    run_ps_in_lab 'vagrant ssh client-test -c "curl -I http://web.mggt1103.local"'
    echo
    echo "===== Contenu page Web ====="
    run_ps_in_lab 'vagrant ssh client-test -c "curl -s http://web.mggt1103.local"'
  } | tee "$LAB_PATH/resultats/tests-vagrant-dns-web.txt"

  MESSAGE="Tests sauvegardés dans resultats/tests-vagrant-dns-web.txt"
  pause_back
}

show_results() {
  clear
  echo "======================================================================"
  echo "RÉSULTATS ENREGISTRÉS"
  echo "======================================================================"
  echo

  if [ -d "$LAB_PATH/resultats" ]; then
    ls -la "$LAB_PATH/resultats"
    echo
    echo "Aperçu des fichiers texte :"
    find "$LAB_PATH/resultats" -type f \( -name "*.txt" -o -name "*.log" -o -name "*.md" \) | sort | while read -r f; do
      echo
      echo "----- $f -----"
      sed -n '1,80p' "$f"
    done
  else
    echo "Aucun dossier resultats."
  fi

  MESSAGE="Résultats affichés."
  pause_back
}

snapshot_list() {
  clear
  echo "======================================================================"
  echo "SNAPSHOTS VAGRANT"
  echo "======================================================================"
  echo
  run_ps_in_lab "vagrant snapshot list"
  MESSAGE="Snapshots affichés."
  pause_back
}

snapshot_save() {
  clear
  echo "======================================================================"
  echo "CRÉER UN SNAPSHOT"
  echo "======================================================================"
  vm="$(choose_vm)" || { pause_back; return; }
  echo
  read -rp "Nom du snapshot : " snap

  if [ -z "$snap" ]; then
    MESSAGE="Snapshot annulé : nom vide."
    pause_back
    return
  fi

  run_ps_in_lab "vagrant snapshot save $vm $snap"
  MESSAGE="Snapshot créé : $vm / $snap"
  pause_back
}

snapshot_restore() {
  clear
  echo "======================================================================"
  echo "RESTAURER UN SNAPSHOT"
  echo "======================================================================"
  vm="$(choose_vm)" || { pause_back; return; }
  echo
  run_ps_in_lab "vagrant snapshot list $vm"
  echo
  read -rp "Nom du snapshot à restaurer : " snap

  if [ -z "$snap" ]; then
    MESSAGE="Restauration annulée : nom vide."
    pause_back
    return
  fi

  if confirm "Restaurer le snapshot $snap de $vm ?"; then
    run_ps_in_lab "vagrant snapshot restore $vm $snap"
    MESSAGE="Snapshot restauré."
  else
    MESSAGE="Restauration annulée."
  fi

  pause_back
}

snapshot_delete() {
  clear
  echo "======================================================================"
  echo "SUPPRIMER UN SNAPSHOT"
  echo "======================================================================"
  vm="$(choose_vm)" || { pause_back; return; }
  echo
  run_ps_in_lab "vagrant snapshot list $vm"
  echo
  read -rp "Nom du snapshot à supprimer : " snap

  if [ -z "$snap" ]; then
    MESSAGE="Suppression annulée : nom vide."
    pause_back
    return
  fi

  if confirm "Supprimer le snapshot $snap de $vm ?"; then
    run_ps_in_lab "vagrant snapshot delete $vm $snap"
    MESSAGE="Snapshot supprimé."
  else
    MESSAGE="Suppression annulée."
  fi

  pause_back
}

box_list() {
  clear
  echo "======================================================================"
  echo "BOXES VAGRANT"
  echo "======================================================================"
  echo
  powershell.exe -NoProfile -Command "vagrant box list"
  MESSAGE="Boxes affichées."
  pause_back
}

box_outdated() {
  clear
  echo "======================================================================"
  echo "VÉRIFIER LES MISES À JOUR DES BOXES"
  echo "======================================================================"
  echo
  run_ps_in_lab "vagrant box outdated"
  MESSAGE="Vérification des boxes terminée."
  pause_back
}

box_update() {
  clear
  echo "======================================================================"
  echo "METTRE À JOUR UNE BOX"
  echo "======================================================================"
  echo
  echo "Commande : vagrant box update"
  echo
  if confirm "Confirmer la mise à jour des boxes utilisées par ce Vagrantfile ?"; then
    run_ps_in_lab "vagrant box update"
    MESSAGE="Mise à jour box terminée."
  else
    MESSAGE="Mise à jour annulée."
  fi
  pause_back
}

open_powershell() {
  open_ps_in_lab ""
  MESSAGE="PowerShell ouvert dans le dossier Vagrant."
  pause_back
}

open_explorer() {
  if [ -d "$LAB_PATH" ]; then
    explorer.exe "$(lab_win_path)" >/dev/null 2>&1 || true
    MESSAGE="Explorateur Windows ouvert."
  else
    MESSAGE="Dossier introuvable."
  fi
  pause_back
}

open_virtualbox() {
  cmd.exe /C start "" "C:\Program Files\Oracle\VirtualBox\VirtualBox.exe" >/dev/null 2>&1 || true
  MESSAGE="VirtualBox demandé."
  pause_back
}

copy_wsl_to_windows() {
  clear
  echo "======================================================================"
  echo "COPIER LE LAB WSL VERS LE LAB WINDOWS"
  echo "======================================================================"
  echo
  echo "Source WSL :"
  echo "$DEFAULT_LAB"
  echo
  echo "Destination Windows côté WSL :"
  echo "$WINDOWS_LAB_DEFAULT"
  echo

  if [ ! -d "$DEFAULT_LAB" ]; then
    echo "Source WSL introuvable."
    MESSAGE="Copie impossible."
    pause_back
    return
  fi

  if confirm "Copier les fichiers Vagrant vers le dossier Windows ?"; then
    mkdir -p "$WINDOWS_LAB_DEFAULT"
    cp -r "$DEFAULT_LAB"/Vagrantfile "$WINDOWS_LAB_DEFAULT/" 2>/dev/null || true
    cp -r "$DEFAULT_LAB"/scripts "$WINDOWS_LAB_DEFAULT/" 2>/dev/null || true
    cp -r "$DEFAULT_LAB"/README.md "$WINDOWS_LAB_DEFAULT/" 2>/dev/null || true
    mkdir -p "$WINDOWS_LAB_DEFAULT/captures" "$WINDOWS_LAB_DEFAULT/resultats"
    LAB_PATH="$WINDOWS_LAB_DEFAULT"
    save_config
    MESSAGE="Copie terminée et dossier Windows sélectionné."
  else
    MESSAGE="Copie annulée."
  fi

  pause_back
}

destroy_vm() {
  clear
  echo "======================================================================"
  echo "DESTROY UNE VM"
  echo "======================================================================"
  vm="$(choose_vm)" || { pause_back; return; }

  if danger_guard "vagrant destroy -f $vm" "DESTROY $vm"; then
    run_ps_in_lab "vagrant destroy -f $vm"
    MESSAGE="VM supprimée : $vm"
  else
    MESSAGE="Destroy VM annulé."
  fi
}

destroy_all() {
  if danger_guard "vagrant destroy -f" "DESTROY ALL"; then
    run_ps_in_lab "vagrant destroy -f"
    MESSAGE="Toutes les VM Vagrant du lab ont été supprimées."
  else
    MESSAGE="Destroy all annulé."
  fi
}

show_help() {
  clear
  echo "======================================================================"
  echo "AIDE RAPIDE VAGRANT"
  echo "======================================================================"
  echo
  echo "Commandes principales :"
  echo "vagrant status        : voir l’état des VM"
  echo "vagrant up            : démarrer les VM"
  echo "vagrant halt          : arrêter proprement les VM"
  echo "vagrant reload        : redémarrer"
  echo "vagrant provision     : relancer les scripts de configuration"
  echo "vagrant ssh NOM_VM    : entrer dans une VM"
  echo "vagrant validate      : vérifier le Vagrantfile"
  echo
  echo "Pour ton lab DNS/Web :"
  echo "srv-dns     : serveur DNS Bind9"
  echo "srv-web     : serveur Apache"
  echo "client-test : machine de test"
  echo
  echo "Tests importants :"
  echo "dig @192.168.56.10 web.mggt1103.local +short"
  echo "curl -I http://192.168.56.20"
  echo "curl -I http://web.mggt1103.local"
  echo
  echo "Important :"
  echo "Utilise halt pour arrêter les VM."
  echo "Utilise destroy seulement si tu veux vraiment supprimer les VM."

  MESSAGE="Aide affichée."
  pause_back
}

vbox_ps_run() {
  local code="$1"
  local psfile psfile_win

  psfile="$(mktemp --suffix=.ps1)"
  psfile_win="$(wslpath -w "$psfile")"

  cat > "$psfile" <<EOF
\$VBoxManage = Join-Path \$env:ProgramFiles 'Oracle\VirtualBox\VBoxManage.exe'
if (!(Test-Path \$VBoxManage)) {
  Write-Host "VBoxManage introuvable. Vérifie l'installation de VirtualBox."
  exit 1
}
$code
EOF

  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$psfile_win"
  local rc=$?

  rm -f "$psfile"
  return $rc
}

vbox_get_names() {
  local psfile psfile_win

  psfile="$(mktemp --suffix=.ps1)"
  psfile_win="$(wslpath -w "$psfile")"

  cat > "$psfile" <<'EOF'
$VBoxManage = Join-Path $env:ProgramFiles 'Oracle\VirtualBox\VBoxManage.exe'
if (!(Test-Path $VBoxManage)) { exit 1 }

& $VBoxManage list vms | ForEach-Object {
  if ($_ -match '^"(.+)"\s+\{.+\}$') {
    $Matches[1]
  }
}
EOF

  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$psfile_win" | tr -d '\r'

  rm -f "$psfile"
}

vbox_choose_vm() {
  local vms=()
  local vm selected

  mapfile -t vms < <(vbox_get_names)

  if [ "${#vms[@]}" -eq 0 ]; then
    echo "Aucune VM VirtualBox détectée." >&2
    return 1
  fi

  echo >&2
  echo "VM existantes dans VirtualBox :" >&2

  for vm in "${vms[@]}"; do
    echo " - $vm" >&2
  done

  echo >&2
  read -r -p "Tape le nom exact de la VM VirtualBox : " selected < /dev/tty
  selected="$(echo "$selected" | xargs)"

  if [ -z "$selected" ]; then
    echo "Nom vide. Action annulée." >&2
    return 1
  fi

  for vm in "${vms[@]}"; do
    if [ "$selected" = "$vm" ]; then
      echo "$selected"
      return 0
    fi
  done

  echo "Nom invalide : $selected" >&2
  return 1
}

vbox_list_all() {
  clear
  echo "======================================================================"
  echo "VIRTUALBOX — TOUTES LES VM EXISTANTES"
  echo "======================================================================"
  echo

  echo "Toutes les VM :"
  vbox_ps_run '& $VBoxManage list vms'
  echo

  echo "VM en cours d’exécution :"
  vbox_ps_run '& $VBoxManage list runningvms'
  echo

  MESSAGE="Liste VirtualBox affichée."
  pause_back
}

vbox_start_one() {
  clear
  echo "======================================================================"
  echo "VIRTUALBOX — ALLUMER UNE VM EXISTANTE"
  echo "======================================================================"
  local vm vmq ps_code

  vm="$(vbox_choose_vm)" || { pause_back; return; }
  vmq="$(safe_ps_quote "$vm")"

  ps_code=$(cat <<EOF
\$name = '$vmq'
& \$VBoxManage startvm \$name --type headless
EOF
)

  vbox_ps_run "$ps_code"
  MESSAGE="VM VirtualBox demandée au démarrage : $vm"
  pause_back
}

vbox_acpi_one() {
  clear
  echo "======================================================================"
  echo "VIRTUALBOX — ARRÊTER PROPREMENT UNE VM EXISTANTE"
  echo "======================================================================"
  local vm vmq ps_code

  vm="$(vbox_choose_vm)" || { pause_back; return; }
  vmq="$(safe_ps_quote "$vm")"

  ps_code=$(cat <<EOF
\$name = '$vmq'
& \$VBoxManage controlvm \$name acpipowerbutton
EOF
)

  vbox_ps_run "$ps_code"
  MESSAGE="Demande d'arrêt propre envoyée : $vm"
  pause_back
}

vbox_start_all() {
  clear
  echo "======================================================================"
  echo "VIRTUALBOX — ALLUMER TOUTES LES VM EXISTANTES"
  echo "======================================================================"
  echo

  local vms=()
  local vm vmq ps_names sep ps_code count

  mapfile -t vms < <(vbox_get_names)

  count="${#vms[@]}"

  if [ "$count" -eq 0 ]; then
    echo "Aucune VM VirtualBox détectée."
    MESSAGE="Aucune VM à démarrer."
    pause_back
    return
  fi

  echo "VM détectées : $count"
  echo

  for vm in "${vms[@]}"; do
    echo " - $vm"
  done

  echo

  if [ "$count" -gt 3 ]; then
    if ! danger_guard "allumer $count VM VirtualBox" "START ALL VBOX"; then
      MESSAGE="Démarrage global VirtualBox annulé."
      return
    fi
  else
    if ! confirm "Confirmer l’allumage de toutes les VM VirtualBox ?"; then
      MESSAGE="Démarrage global VirtualBox annulé."
      pause_back
      return
    fi
  fi

  ps_names=""
  sep=""

  for vm in "${vms[@]}"; do
    vmq="$(safe_ps_quote "$vm")"
    ps_names="${ps_names}${sep}'$vmq'"
    sep=", "
  done

  ps_code=$(cat <<EOF
\$names = @($ps_names)
foreach (\$n in \$names) {
  Write-Host "Démarrage de : \$n"
  & \$VBoxManage startvm \$n --type headless
  Start-Sleep -Seconds 2
}
EOF
)

  vbox_ps_run "$ps_code"
  MESSAGE="Démarrage global VirtualBox terminé."
  pause_back
}

generate_vagrantfile_lab() {
  clear
  echo "======================================================================"
  echo "GÉNÉRER UN VAGRANTFILE — 1, 2, 3 OU 6 VM"
  echo "======================================================================"
  echo

  echo "Choix disponibles :"
  echo "1. Créer 1 VM"
  echo "2. Créer 2 VM"
  echo "3. Créer 3 VM"
  echo "6. Créer 6 VM"
  echo

  local count base_octet memory lab_name target i ip vmname vbname

  read -rp "Nombre de VM à créer [1/2/3/6] : " count

  case "$count" in
    1|2|3|6)
      ;;
    *)
      echo "Choix invalide. Utilise seulement 1, 2, 3 ou 6."
      MESSAGE="Création Vagrantfile annulée."
      pause_back
      return
      ;;
  esac

  if [ "$count" -gt 3 ]; then
    if ! danger_guard "créer un Vagrantfile pour $count VM simultanées" "CREATE $count VMS"; then
      MESSAGE="Création Vagrantfile annulée."
      return
    fi
  fi

  read -rp "Dernier octet de la première IP [40] : " base_octet
  base_octet="${base_octet:-40}"

  if ! [[ "$base_octet" =~ ^[0-9]+$ ]] || [ "$base_octet" -lt 10 ] || [ "$base_octet" -gt 240 ]; then
    echo "Octet IP invalide."
    MESSAGE="Création Vagrantfile annulée."
    pause_back
    return
  fi

  read -rp "Mémoire par VM en MB [512] : " memory
  memory="${memory:-512}"

  if ! [[ "$memory" =~ ^[0-9]+$ ]] || [ "$memory" -lt 256 ]; then
    echo "Mémoire invalide."
    MESSAGE="Création Vagrantfile annulée."
    pause_back
    return
  fi

  lab_name="generated-lab-${count}vm-$(date +%Y%m%d-%H%M%S)"
  target="/mnt/c/Users/Ethan/MGGT1103-vagrant-labs/$lab_name"

  mkdir -p "$target/scripts" "$target/resultats" "$target/captures"

  cat > "$target/Vagrantfile" <<'EOF'
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.synced_folder ".", "/vagrant", disabled: true

EOF

  for i in $(seq 1 "$count"); do
    ip="192.168.56.$((base_octet + i - 1))"
    vmname="lab-vm$i"
    vbname="MGGT1103-LAB-VM$i"

    cat >> "$target/Vagrantfile" <<EOF
  config.vm.define "$vmname" do |node|
    node.vm.hostname = "$vmname"
    node.vm.network "private_network", ip: "$ip"

    node.vm.provider "virtualbox" do |vb|
      vb.name = "$vbname"
      vb.memory = "$memory"
      vb.cpus = 1
      vb.gui = false
    end

    node.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update -y
      sudo apt-get install -y curl wget nano tree net-tools
      echo "$vmname prêt - IP $ip" | sudo tee /etc/mggt1103_vm.txt
    SHELL
  end

EOF
  done

  cat >> "$target/Vagrantfile" <<'EOF'
end
EOF

  cat > "$target/README.md" <<EOF
# Lab Vagrant généré — MGGT1103

Nombre de VM : $count

## Commandes utiles

\`\`\`powershell
vagrant validate
vagrant up
vagrant status
vagrant halt
\`\`\`

## VM créées

EOF

  for i in $(seq 1 "$count"); do
    ip="192.168.56.$((base_octet + i - 1))"
    echo "- lab-vm$i : $ip" >> "$target/README.md"
  done

  LAB_PATH="$target"
  save_config

  echo
  echo "Lab généré avec succès :"
  echo "$target"
  echo
  echo "Ce dossier devient le nouveau dossier Vagrant sélectionné dans vagrantnav."

  MESSAGE="Vagrantfile généré pour $count VM."
  pause_back
}


execute_action() {
  case "$SELECTED" in
    0) show_lab ;;
    1) change_lab ;;
    2) vagrant_version ;;
    3) validate_vagrantfile ;;
    4) vagrant_status ;;
    5) global_status ;;
    6) show_vms ;;
    7) up_all ;;
    8) halt_all ;;
    9) reload_all ;;
    10) provision_all ;;
    11) up_vm ;;
    12) halt_vm ;;
    13) reload_vm ;;
    14) provision_vm ;;
    15) ssh_vm ;;
    16) ssh_config ;;
    17) test_dns ;;
    18) test_web_ip ;;
    19) test_web_dns ;;
    20) run_all_tests_save ;;
    21) show_results ;;
    22) snapshot_list ;;
    23) snapshot_save ;;
    24) snapshot_restore ;;
    25) snapshot_delete ;;
    26) box_list ;;
    27) box_outdated ;;
    28) box_update ;;
    29) open_powershell ;;
    30) open_explorer ;;
    31) open_virtualbox ;;
    32) copy_wsl_to_windows ;;
    33) vbox_list_all ;;
    34) vbox_start_one ;;
    35) vbox_acpi_one ;;
    36) vbox_start_all ;;
    37) generate_vagrantfile_lab ;;
    38) destroy_vm ;;
    39) destroy_all ;;
    40) show_help ;;
    41)
      clear
      echo "Fin de Vagrantnav."
      exit 0
      ;;
    *)
      MESSAGE="Action inconnue."
      ;;
  esac
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
        echo "Fin de Vagrantnav."
        exit 0
        ;;
      *)
        MESSAGE="Touche non reconnue."
        ;;
    esac
  done
}

main_loop
