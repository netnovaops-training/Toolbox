#!/usr/bin/env bash
# note.sh - add a quick tagged note and push it in one go.
# Usage: bash code/mine/note.sh "fixed the Caddy proxy #caddy #networking"
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"        # run from the repo root, wherever you are
note="${*:-}"
if [ -z "$note" ]; then
  echo 'Usage: bash code/mine/note.sh "your note #tag"'
  exit 1
fi

git pull --no-edit -q                        # get current first
echo "$(date +%F) - $note" >> knowledge/daily-log/quick-notes.md
git commit -am "note" -q                     # spell-check hook runs here
git push -q
echo "added: $(date +%F) - $note"
