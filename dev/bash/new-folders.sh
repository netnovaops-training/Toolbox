#!/usr/bin/env bash
# new-folders.sh — make folders, keep each in git with a .gitkeep.
# Edit the list, then: bash new-folders.sh
folders=(
  "infra/networking/firewall"
  "infra/security/sso"
  "dev/python"
)
for f in "${folders[@]}"; do
  mkdir -p "$f"
  [ -e "$f/.gitkeep" ] || touch "$f/.gitkeep"
done
echo "Done. Now: git add . && git commit -m 'Add folders' && git push"
