#!/usr/bin/env bash

mggt_find_upward() {
  local dir="$PWD"

  while [ "$dir" != "/" ]; do
    if find "$dir" -maxdepth 1 -type d -name "MGGT1103_Cours_Adm_Systeme_*" | grep -q .; then
      echo "$dir"
      return 0
    fi

    if [ -d "$dir/.git" ]; then
      echo "$dir"
      return 0
    fi

    dir="$(dirname "$dir")"
  done

  return 1
}

mggt_detect_root() {
  if [ -n "${MGGT1103_ROOT:-}" ] && [ -d "$MGGT1103_ROOT" ]; then
    echo "$MGGT1103_ROOT"
    return 0
  fi

  local git_root
  git_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"

  if [ -n "$git_root" ] && [ -d "$git_root" ]; then
    echo "$git_root"
    return 0
  fi

  local upward
  upward="$(mggt_find_upward 2>/dev/null || true)"

  if [ -n "$upward" ] && [ -d "$upward" ]; then
    echo "$upward"
    return 0
  fi

  echo "$PWD"
}

mggt_detect_base() {
  local root="$1"

  if [ -n "${MGGT1103_BASE:-}" ] && [ -d "$MGGT1103_BASE" ]; then
    echo "$MGGT1103_BASE"
    return 0
  fi

  find "$root" -maxdepth 2 -type d -name "MGGT1103_Cours_Adm_Systeme_*" | head -n 1
}

mggt_detect_windows_user() {
  if command -v cmd.exe >/dev/null 2>&1; then
    cmd.exe /c echo %USERNAME% 2>/dev/null | tr -d '\r'
  fi
}

mggt_prepare_environment() {
  export MGGT1103_ROOT
  export MGGT1103_BASE

  MGGT1103_ROOT="$(mggt_detect_root)"
  MGGT1103_BASE="$(mggt_detect_base "$MGGT1103_ROOT")"

  if [ -z "$MGGT1103_BASE" ] || [ ! -d "$MGGT1103_BASE" ]; then
    echo "Erreur : aucun dossier MGGT1103_Cours_Adm_Systeme_* détecté."
    echo
    echo "Placez-vous dans la racine du dépôt MGGT1103, puis relancez l’outil."
    echo "Exemple :"
    echo "cd ~/mggt1103-admin-systeme"
    echo "mggt-assistant"
    exit 1
  fi
}
