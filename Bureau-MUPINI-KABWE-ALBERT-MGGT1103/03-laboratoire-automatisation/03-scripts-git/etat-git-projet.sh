#!/usr/bin/env bash

cd "$(dirname "$0")/../../.."

echo "Branche active :"
git branch --show-current

echo
echo "État Git :"
git status --short

echo
echo "Derniers commits :"
git log --oneline --decorate -10

echo
echo "Dépôt distant :"
git remote -v
