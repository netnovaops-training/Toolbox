#!/usr/bin/env bash
# newfix.sh - start a troubleshooting write-up from the quick template.
# Usage: bash code/mine/newfix.sh container-permission-denied
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
title="${1:-}"
if [ -z "$title" ]; then
  echo 'Usage: bash code/mine/newfix.sh short-title   (use-dashes-not-spaces)'
  exit 1
fi

file="knowledge/troubleshooting/$(date +%F)-$title.md"
cp knowledge/troubleshooting/_quick.md "$file"
echo "created: $file"
echo "Now open it, fill the XXX, then save it with:"
echo "  git add \"$file\" && git commit -m \"Troubleshooting: $title\" && git push"
