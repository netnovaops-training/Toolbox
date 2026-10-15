#!/usr/bin/env bash
# rename.sh - rename or move a file/folder in the repo (tracked by git), then push.
# Usage: bash code/scripts/rename.sh <old-path> <new-path>
# Example (rename a folder): bash code/scripts/rename.sh code/scripts code/tools
# Example (rename a file):   bash code/scripts/rename.sh notes/old.md notes/new.md
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"         # run from anywhere in the repo
old="${1:-}"
new="${2:-}"
if [ -z "$old" ] || [ -z "$new" ]; then
  echo 'Usage: bash code/scripts/rename.sh <old-path> <new-path>'
  echo 'Example: bash code/scripts/rename.sh code/scripts code/tools'
  exit 1
fi
if [ ! -e "$old" ]; then
  echo "not found: $old"
  exit 1
fi

git pull --no-edit -q                         # get current first
mkdir -p "$(dirname "$new")"                   # make the destination's parent if needed
git mv "$old" "$new"                           # rename/move, keeping git history
git commit -m "Rename $old -> $new" -q         # spell-check hook runs here
git push -q
echo "renamed: $old -> $new   (committed + pushed)"
