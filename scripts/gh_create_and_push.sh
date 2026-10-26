#!/usr/bin/env bash
# Einmalig anmelden:  gh auth login
# Dann dieses Skript aus dem Projektroot ausführen:
#   ./scripts/gh_create_and_push.sh
# Erstellt ein privates Repo names macro_tracker auf GitHub, setzt origin, push main.
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v gh &>/dev/null; then
  echo "Bitte installieren: brew install gh" >&2
  exit 1
fi
if ! gh auth status &>/dev/null; then
  echo "Zuerst anmelden: gh auth login" >&2
  exit 1
fi
REPO_NAME="${1:-macro_tracker}"
echo "==> Erstelle privates GitHub-Repo '$REPO_NAME' und pushe main …"
gh repo create "$REPO_NAME" --private --source=. --remote=origin --push
echo "==> Fertig. Anderen Rechner: git clone <URL aus GitHub> (grüner Code-Button)"
