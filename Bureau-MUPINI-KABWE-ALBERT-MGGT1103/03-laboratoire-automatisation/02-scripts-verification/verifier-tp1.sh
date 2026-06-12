#!/usr/bin/env bash

cd "$(dirname "$0")/../../.."

echo "Vérification TP1"
echo

for file in README.md Vagrantfile rapport-seance1.md; do
  if [ -f "$file" ]; then
    echo "OK     $file"
  else
    echo "ABSENT $file"
  fi
done

echo
echo "Captures TP1 :"
ls -lh captures/tp1 2>/dev/null || echo "ABSENT captures/tp1"

echo
echo "État Git :"
git status --short

echo
echo "Derniers commits :"
git log --oneline --decorate -5
