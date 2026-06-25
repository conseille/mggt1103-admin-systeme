#!/usr/bin/env bash
set -euo pipefail

ADMIN_SIGNATURE="${MGGT_ADMIN_SIGNATURE:-admin albert@52}"

slugify() {
  echo "$1" \
    | tr '[:lower:]' '[:upper:]' \
    | sed 's/[éèêë]/E/g; s/[àâä]/A/g; s/[îï]/I/g; s/[ôö]/O/g; s/[ùûü]/U/g; s/[ç]/C/g' \
    | tr ' ' '-' \
    | tr -cd 'A-Z0-9_-'
}

pause() {
  echo
  read -rp "Appuyez sur Entrée pour continuer..."
}

title() {
  clear
  echo "======================================================================"
  echo "$1"
  echo "======================================================================"
  echo
}

create_tp_structure() {
  local base="$1"

  mkdir -p "$base/01-travaux-pratiques"
  mkdir -p "$base/02-laboratoire-automatisation/scripts"
  mkdir -p "$base/02-laboratoire-automatisation/resultats"
  mkdir -p "$base/02-laboratoire-automatisation/install"
  mkdir -p "$base/03-outils-de-presentation"

  local tp

  for tp in \
    "TP01-environnement-devops-git-vagrant" \
    "TP02-diagnostic-hardening-linux" \
    "TP03-infrastructure-as-code-terraform" \
    "TP04-configuration-ansible" \
    "TP05-conteneurisation-docker-compose" \
    "TP06-orchestration-k3s-kubernetes" \
    "TP07-observabilite-prometheus-grafana-loki" \
    "TP08-ci-cd-gitops" \
    "TP09-identite-keycloak-traefik" \
    "TP10-integration-hackathon" \
    "TP11-devsecops-trivy-hadolint"
  do
    mkdir -p "$base/01-travaux-pratiques/$tp/captures"
    mkdir -p "$base/01-travaux-pratiques/$tp/rapport"
    mkdir -p "$base/01-travaux-pratiques/$tp/rendu-final"
    mkdir -p "$base/01-travaux-pratiques/$tp/resultats"
    mkdir -p "$base/01-travaux-pratiques/$tp/scripts"

    cat > "$base/01-travaux-pratiques/$tp/README.md" <<EOF_TP
# $tp

## Objectif

Décrire ici l’objectif du travail pratique.

## Contenu attendu

- rapport/
- captures/
- resultats/
- scripts/
- rendu-final/

## Vérification

Utiliser :

\`\`\`bash
mggt-assistant
tpnav
gitnav
\`\`\`
EOF_TP
  done
}

create_main_readme() {
  local project="$1"
  local base="$2"
  local student="$3"
  local email="$4"

  cat > "$project/README.md" <<EOF_README
# Projet MGGT1103 — Administration Système

**Étudiant :** $student  
**Email Git :** $email  
**Cours :** MGGT1103 — Administration Système, Cloud-Native et DevOps

## Présentation

Ce dépôt contient les travaux pratiques, rapports, captures, résultats,
scripts et outils liés au cours MGGT1103.

## Structure

\`\`\`text
$(basename "$base")/
├── 01-travaux-pratiques/
├── 02-laboratoire-automatisation/
└── 03-outils-de-presentation/
\`\`\`

## Assistant terminal

Après installation de mggt-assistant :

\`\`\`bash
mggt-assistant
\`\`\`

## Outils disponibles

\`\`\`bash
mggt-init
mggt-assistant
mggt-doctor
tpnav
gitnav
vagrantnav
\`\`\`

## Signature admin

\`\`\`text
$ADMIN_SIGNATURE
\`\`\`
EOF_README

  cat > "$base/README.md" <<EOF_BASE
# MGGT1103 — Cours d’Administration Système

**Étudiant :** $student  
**Email Git :** $email

## Organisation

\`\`\`text
01-travaux-pratiques/
02-laboratoire-automatisation/
03-outils-de-presentation/
\`\`\`

## Travaux pratiques prévus

- TP01 — Environnement DevOps, Git, Vagrant
- TP02 — Diagnostic Performance et Hardening Linux
- TP03 — Infrastructure-as-Code Terraform
- TP04 — Configuration Ansible
- TP05 — Docker Compose
- TP06 — K3s / Kubernetes
- TP07 — Prometheus, Grafana, Loki
- TP08 — CI/CD et GitOps
- TP09 — Keycloak et Traefik
- TP10 — Intégration / Hackathon
- TP11 — DevSecOps Trivy / Hadolint
EOF_BASE
}

configure_git() {
  local project="$1"
  local name="$2"
  local email="$3"
  local branch="$4"

  cd "$project"

  git init
  git config user.name "$name"
  git config user.email "$email"
  git config init.defaultBranch "$branch" || true
  git branch -M "$branch" 2>/dev/null || true

  git add .
  git commit -m "chore: initialiser structure MGGT1103" || true
}

main() {
  title "MGGT-INIT — Création d’un nouveau projet MGGT1103"

  echo "Cet assistant crée un projet MGGT1103 complet avant même que la racine existe."
  echo
  echo "Il va créer :"
  echo "- le répertoire principal du projet ;"
  echo "- la structure MGGT1103_Cours_Adm_Systeme_NOM-PRENOM ;"
  echo "- les dossiers TP01 à TP11 ;"
  echo "- les dossiers rapport, captures, resultats, scripts et rendu-final ;"
  echo "- un dépôt Git avec git init ;"
  echo "- une configuration Git locale personnalisée."
  echo
  echo "Signature admin par défaut : $ADMIN_SIGNATURE"
  echo

  read -rp "Nom du répertoire principal du projet [MGGT1103-projet] : " project_name
  project_name="${project_name:-MGGT1103-projet}"

  read -rp "Nom complet de l’étudiant : " student_name
  if [ -z "$student_name" ]; then
    echo "Le nom complet est obligatoire."
    exit 1
  fi

  read -rp "Email Git de l’étudiant : " git_email
  if [ -z "$git_email" ]; then
    echo "L’email Git est obligatoire."
    exit 1
  fi

  read -rp "Branche Git principale [master] : " git_branch
  git_branch="${git_branch:-master}"

  read -rp "Dossier parent où créer le projet [$(pwd)] : " parent_dir
  parent_dir="${parent_dir:-$(pwd)}"

  parent_dir="${parent_dir/#\~/$HOME}"

  mkdir -p "$parent_dir"

  local project_path
  project_path="$parent_dir/$project_name"

  if [ -e "$project_path" ]; then
    echo
    echo "Erreur : ce dossier existe déjà :"
    echo "$project_path"
    exit 1
  fi

  local slug
  slug="$(slugify "$student_name")"

  local base
  base="$project_path/MGGT1103_Cours_Adm_Systeme_$slug"

  title "CRÉATION DE LA STRUCTURE"

  echo "Projet       : $project_path"
  echo "Dossier cours: $base"
  echo "Étudiant     : $student_name"
  echo "Email Git    : $git_email"
  echo "Branche Git  : $git_branch"
  echo

  read -rp "Confirmer la création ? [o/N] : " confirm

  case "$confirm" in
    o|O|oui|OUI|y|Y|yes|YES)
      ;;
    *)
      echo "Création annulée."
      exit 0
      ;;
  esac

  mkdir -p "$base"

  create_tp_structure "$base"
  create_main_readme "$project_path" "$base" "$student_name" "$git_email"
  configure_git "$project_path" "$student_name" "$git_email" "$git_branch"

  title "PROJET MGGT1103 CRÉÉ AVEC SUCCÈS"

  echo "Projet créé :"
  echo "$project_path"
  echo
  echo "Pour commencer :"
  echo
  echo "cd \"$project_path\""
  echo "mggt-assistant"
  echo
  echo "Commandes utiles :"
  echo "mggt-doctor"
  echo "tpnav"
  echo "gitnav"
  echo "vagrantnav"
  echo
  echo "Signature admin : $ADMIN_SIGNATURE"
}

main "$@"
