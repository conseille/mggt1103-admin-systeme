#!/usr/bin/env bash

MGGT_ADMIN_SIGNATURE="${MGGT_ADMIN_SIGNATURE:-admin albert@52}"

mggt_footer() {
  echo
  echo "----------------------------------------------------------------------"
  echo "Signature admin : $MGGT_ADMIN_SIGNATURE"
  echo "----------------------------------------------------------------------"
}

mggt_open_url() {
  local url="$1"

  echo
  echo "Ouverture du site officiel :"
  echo "$url"
  echo

  if command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -Command "Start-Process '$url'" >/dev/null 2>&1 || true
  elif command -v cmd.exe >/dev/null 2>&1; then
    cmd.exe /C start "" "$url" >/dev/null 2>&1 || true
  elif command -v google-chrome >/dev/null 2>&1; then
    google-chrome "$url" >/dev/null 2>&1 &
  elif command -v chromium >/dev/null 2>&1; then
    chromium "$url" >/dev/null 2>&1 &
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$url" >/dev/null 2>&1 &
  else
    echo "Aucun navigateur détecté automatiquement."
    echo "Copiez manuellement ce lien dans Chrome ou votre navigateur :"
    echo "$url"
  fi
}

mggt_tool_url() {
  local tool="$1"

  case "$tool" in
    vagrant)
      echo "https://developer.hashicorp.com/vagrant/install"
      ;;
    virtualbox|vboxmanage)
      echo "https://www.virtualbox.org/wiki/Downloads"
      ;;
    terraform)
      echo "https://developer.hashicorp.com/terraform/install"
      ;;
    docker)
      echo "https://docs.docker.com/engine/install/ubuntu/"
      ;;
    docker-desktop)
      echo "https://docs.docker.com/desktop/setup/install/windows-install/"
      ;;
    ansible)
      echo "https://docs.ansible.com/projects/ansible/latest/installation_guide/intro_installation.html"
      ;;
    kubectl)
      echo "https://kubernetes.io/docs/tasks/tools/"
      ;;
    k3s)
      echo "https://docs.k3s.io/quick-start"
      ;;
    prometheus)
      echo "https://prometheus.io/download/"
      ;;
    grafana)
      echo "https://grafana.com/docs/grafana/latest/setup-grafana/installation/"
      ;;
    loki)
      echo "https://grafana.com/docs/loki/latest/setup/install/"
      ;;
    keycloak)
      echo "https://www.keycloak.org/downloads"
      ;;
    traefik)
      echo "https://doc.traefik.io/traefik/getting-started/install-traefik/"
      ;;
    trivy)
      echo "https://trivy.dev/latest/getting-started/installation/"
      ;;
    hadolint)
      echo "https://github.com/hadolint/hadolint"
      ;;
    git)
      echo "https://git-scm.com/downloads"
      ;;
    vscode|code)
      echo "https://code.visualstudio.com/download"
      ;;
    *)
      echo ""
      ;;
  esac
}

mggt_tool_exists() {
  local tool="$1"

  case "$tool" in
    virtualbox|vboxmanage)
      if command -v VBoxManage >/dev/null 2>&1; then
        return 0
      fi

      if command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -NoProfile -Command "Test-Path 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe'" 2>/dev/null | grep -qi "true" && return 0
      fi

      return 1
      ;;
    vagrant)
      if command -v vagrant >/dev/null 2>&1; then
        return 0
      fi

      if command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -NoProfile -Command "Get-Command vagrant -ErrorAction SilentlyContinue" >/dev/null 2>&1 && return 0
      fi

      return 1
      ;;
    docker)
      command -v docker >/dev/null 2>&1
      ;;
    grafana)
      command -v grafana-server >/dev/null 2>&1 || command -v grafana >/dev/null 2>&1
      ;;
    *)
      command -v "$tool" >/dev/null 2>&1
      ;;
  esac
}

mggt_check_tool_or_open_site() {
  local tool="$1"
  local label="${2:-$tool}"
  local url

  if mggt_tool_exists "$tool"; then
    echo "[OK] $label détecté."
    return 0
  fi

  echo "[MANQUANT] $label n’est pas détecté sur ce système."
  url="$(mggt_tool_url "$tool")"

  if [ -n "$url" ]; then
    echo
    echo "L’assistant peut ouvrir le site officiel pour télécharger ou installer $label."
    read -rp "Ouvrir le site officiel maintenant ? [o/N] : " answer

    case "$answer" in
      o|O|oui|OUI|y|Y|yes|YES)
        mggt_open_url "$url"
        echo
        echo "Installez $label, puis relancez la commande :"
        echo "mggt-assistant"
        ;;
      *)
        echo "Ouverture annulée."
        ;;
    esac
  else
    echo "Aucun lien officiel n’est enregistré pour cet outil."
  fi

  return 1
}

mggt_double_protection() {
  local action="$1"
  local phrase="$2"
  local typed_signature
  local key
  local typed_key
  local typed_phrase

  clear
  echo "======================================================================"
  echo "DOUBLE PROTECTION"
  echo "======================================================================"
  echo
  echo "Action demandée : $action"
  echo
  echo "Cette action demande une autorisation spéciale."
  echo

  read -rp "Première confirmation [o/N] : " answer

  case "$answer" in
    o|O|oui|OUI|y|Y|yes|YES)
      ;;
    *)
      echo "Action annulée."
      return 1
      ;;
  esac

  echo
  echo "Signature admin attendue : $MGGT_ADMIN_SIGNATURE"
  read -rp "Retapez la signature admin : " typed_signature

  if [ "$typed_signature" != "$MGGT_ADMIN_SIGNATURE" ]; then
    echo "Signature incorrecte. Action bloquée."
    return 1
  fi

  key="MGGT-$(date +%S)-$RANDOM"
  key="${key:0:14}"

  echo
  echo "Clé dynamique : $key"
  read -rp "Retapez exactement cette clé : " typed_key

  if [ "$typed_key" != "$key" ]; then
    echo "Clé dynamique incorrecte. Action bloquée."
    return 1
  fi

  echo
  echo "Phrase attendue : $phrase"
  read -rp "Retapez exactement la phrase : " typed_phrase

  if [ "$typed_phrase" != "$phrase" ]; then
    echo "Phrase incorrecte. Action bloquée."
    return 1
  fi

  echo
  echo "Double protection validée."
  return 0
}

mggt_slugify() {
  echo "$1" \
    | tr '[:lower:]' '[:upper:]' \
    | sed 's/[éèêë]/E/g; s/[àâä]/A/g; s/[îï]/I/g; s/[ôö]/O/g; s/[ùûü]/U/g' \
    | tr ' ' '-' \
    | tr -cd 'A-Z0-9_-'
}

mggt_create_standard_structure() {
  local root="$1"
  local student_name="$2"
  local slug
  local base
  local tp

  slug="$(mggt_slugify "$student_name")"

  if [ -z "$slug" ]; then
    slug="ETUDIANT"
  fi

  base="$root/MGGT1103_Cours_Adm_Systeme_$slug"

  mkdir -p "$base/01-travaux-pratiques"
  mkdir -p "$base/02-laboratoire-automatisation/scripts"
  mkdir -p "$base/02-laboratoire-automatisation/resultats"
  mkdir -p "$base/03-outils-de-presentation"

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
    touch "$base/01-travaux-pratiques/$tp/README.md"
  done

  cat > "$base/README.md" <<EOF_README
# MGGT1103 — Cours d’Administration Système

**Étudiant :** $student_name  
**Cours :** MGGT1103 — Administration Système, Cloud-Native et DevOps

## Organisation

\`\`\`text
01-travaux-pratiques/
02-laboratoire-automatisation/
03-outils-de-presentation/
\`\`\`

## Assistant

Pour vérifier le dépôt :

\`\`\`bash
mggt-assistant
\`\`\`

Signature admin par défaut :

\`\`\`text
$MGGT_ADMIN_SIGNATURE
\`\`\`
EOF_README

  echo "$base"
}

mggt_tech_roadmap() {
  cat <<'EOF_ROADMAP'
======================================================================
TECHNOLOGIES PRÉVUES — MGGT1103 TP01 À TP11
======================================================================

TP01 — Environnement DevOps, Git, Vagrant
Technologies :
- WSL2 / Ubuntu
- Git / GitHub
- VS Code
- VirtualBox
- Vagrant
- DNS Bind9
- Apache2
- Client de test Linux

Objectif :
Préparer un environnement DevOps local et créer un premier laboratoire
multi-VM avec DNS et Web.

----------------------------------------------------------------------

TP02 — Diagnostic Performance et Hardening Linux
Technologies :
- Linux CLI
- systemctl
- journalctl
- top / htop
- free / df / ps
- Lynis
- UFW
- Fail2ban
- scripts Bash de diagnostic et sauvegarde

Objectif :
Analyser un système Linux, produire des résultats et appliquer des mesures
de durcissement.

----------------------------------------------------------------------

TP03 — Infrastructure-as-Code avec Terraform
Technologies :
- Terraform
- Provider local
- variables Terraform
- terraform init
- terraform fmt
- terraform validate
- terraform plan
- terraform apply

Objectif :
Comprendre l’Infrastructure-as-Code et produire une configuration déclarative.

----------------------------------------------------------------------

TP04 — Configuration Management avec Ansible
Technologies :
- Ansible
- inventaire
- playbooks
- YAML
- modules Ansible
- ping Ansible
- automatisation de configuration

Objectif :
Automatiser la configuration de serveurs Linux.

----------------------------------------------------------------------

TP05 — Conteneurisation avec Docker Compose
Technologies :
- Docker
- Dockerfile
- Docker Compose
- images
- conteneurs
- volumes
- réseaux Docker
- logs Docker

Objectif :
Conteneuriser des services et les orchestrer localement avec Compose.

----------------------------------------------------------------------

TP06 — Orchestration avec K3s / Kubernetes
Technologies :
- Kubernetes
- K3s
- kubectl
- pods
- deployments
- services
- namespaces
- manifests YAML

Objectif :
Découvrir l’orchestration de conteneurs avec un cluster Kubernetes léger.

----------------------------------------------------------------------

TP07 — Observabilité Prometheus, Grafana, Loki
Technologies :
- Prometheus
- Grafana
- Loki
- métriques
- logs
- dashboards
- alerting de base

Objectif :
Mettre en place une première chaîne d’observabilité.

----------------------------------------------------------------------

TP08 — CI/CD et GitOps
Technologies :
- GitHub
- workflows CI/CD
- pipelines
- automatisation de tests
- déploiement automatisé
- GitOps

Objectif :
Automatiser la validation et le déploiement d’un projet.

----------------------------------------------------------------------

TP09 — Identité, Reverse Proxy et Sécurité d’Accès
Technologies :
- Keycloak
- Traefik
- reverse proxy
- certificats
- authentification
- routage HTTP

Objectif :
Comprendre l’identité, l’authentification et l’accès sécurisé aux services.

----------------------------------------------------------------------

TP10 — Intégration / Hackathon
Technologies :
- Git
- Docker
- Vagrant
- Terraform
- Ansible
- Kubernetes / K3s
- monitoring
- documentation

Objectif :
Assembler plusieurs briques du cours dans un scénario intégré.

----------------------------------------------------------------------

TP11 — DevSecOps
Technologies :
- Trivy
- Hadolint
- analyse d’images Docker
- analyse de Dockerfile
- sécurité CI/CD
- rapports de vulnérabilités

Objectif :
Ajouter des contrôles sécurité dans le cycle DevOps.

======================================================================
EOF_ROADMAP
}
