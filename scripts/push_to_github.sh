#!/usr/bin/env bash
# Windows: dieselbe Idee in PowerShell: .\scripts\UploadToGitHub.ps1
# Einmalig: Auf github.com leeres Repository anlegen (ohne README, ohne .gitignore),
# dann diese URL unten einsetzen und ausführen:
#   ./scripts/push_to_github.sh https://github.com/DEIN-USER/macro_tracker.git
# Alternativ (SSH):
#   ./scripts/push_to_github.sh git@github.com:DEIN-USER/macro_tracker.git
set -euo pipefail
REPO_URL="${1:-}"
if [[ -z "$REPO_URL" ]]; then
  echo "Usage: $0 <repository-URL>" >&2
  echo "Example: $0 https://github.com/myuser/macro_tracker.git" >&2
  exit 1
fi
cd "$(dirname "$0")/.."
if git remote get-url origin &>/dev/null; then
  echo "==> Setze origin auf: $REPO_URL"
  git remote set-url origin "$REPO_URL"
else
  echo "==> Füge origin hinzu: $REPO_URL"
  git remote add origin "$REPO_URL"
fi
echo "==> Push Branch main"
git push -u origin main
echo "==> Fertig. Anderen Rechner: git clone $REPO_URL"
