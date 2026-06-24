#!/usr/bin/env bash
set -euo pipefail

echo "===== VERIFICATION VAGRANT ====="
echo

if ! command -v vagrant >/dev/null 2>&1; then
  echo "ERREUR : Vagrant n'est pas installé ou n'est pas accessible dans WSL."
  exit 0
fi

echo "Version Vagrant :"
vagrant --version
echo

echo "===== RECHERCHE DES VAGRANTFILE ====="
mapfile -t files < <(find . -name "Vagrantfile" -type f | sort)

if [ "${#files[@]}" -eq 0 ]; then
  echo "Aucun Vagrantfile trouvé dans le projet."
  exit 0
fi

for vf in "${files[@]}"; do
  dir="$(dirname "$vf")"
  echo
  echo "----- $dir -----"
  (
    cd "$dir"
    echo "Dossier : $(pwd)"
    vagrant status || true
  )
done
