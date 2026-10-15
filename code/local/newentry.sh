#!/usr/bin/env bash
# newentry.sh - open a logbook ticket: a branch plus a dated entry from the right
# template, frontmatter filled in, committed and pushed. Never commits to main.
# Usage: bash code/local/newentry.sh <type> <short-title> [tech ...]
#   type: troubleshooting | quick | install | project | learning
#   short-title: lowercase-with-dashes
# Example: bash code/local/newentry.sh project add-branches-to-flow git github
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
. code/local/_entry-lib.sh

usage() {
  echo "Usage: bash code/local/newentry.sh <type> <short-title> [tech ...]"
  echo "  type: troubleshooting | quick | install | project | learning"
  echo "  e.g.  bash code/local/newentry.sh install caddy-reverse-proxy caddy linux"
}

type="${1:-}"
slug="${2:-}"
if [ -z "$type" ] || [ -z "$slug" ]; then
  usage
  exit 1
fi
shift 2

case "$type" in
  troubleshooting) dir=troubleshooting; tpl=_template.md ;;
  quick)           dir=troubleshooting; tpl=_quick.md; type=troubleshooting ;;
  install)         dir=installs;        tpl=_template.md ;;
  project)         dir=projects;        tpl=_template.md ;;
  learning)        dir=learning;        tpl=_template.md ;;
  *) echo "Unknown type: $type"; usage; exit 1 ;;
esac

if ! printf '%s' "$slug" | grep -Eq '^[a-z0-9][a-z0-9-]*$'; then
  echo "short-title must be lowercase letters, numbers and dashes (e.g. caddy-502-error)"
  exit 1
fi

today="$(date +%F)"
branch="$(git rev-parse --abbrev-ref HEAD)"
if [ "$branch" = "main" ]; then
  git pull -q --no-edit
  branch="$type/$slug"
  git switch -q -c "$branch"
  echo "You were on main, so I made a ticket branch: $branch"
fi

file="knowledge/$dir/$today-$slug.md"
if [ -e "$file" ]; then
  echo "Already exists: $file"
  exit 1
fi

# tech list from the remaining args, lowercased, e.g. [git, github]
tech="[]"
if [ "$#" -gt 0 ]; then
  tech="[$(printf '%s\n' "$@" | tr 'A-Z' 'a-z' | paste -sd, - | sed 's/,/, /g')]"
fi
title="$(printf '%s' "$slug" | tr '-' ' ')"

cp "knowledge/$dir/$tpl" "$file"
sed -i -e "s|__TYPE__|$type|g" -e "s|__TITLE__|$title|g" -e "s|__DATE__|$today|g" \
       -e "s|__BRANCH__|$branch|g" -e "s|__TECH__|$tech|g" "$file"

git add "$file"
git commit -q -m "Open $type: $title"
git push -q -u origin "$branch"

echo ""
echo "Opened:  $file"
echo "Branch:  $branch"
echo "Next:    fill in the XXX parts. Save progress any time with:"
echo "           bash code/local/worklog.sh \"what I did\""
echo "         Open a DRAFT pull request (this is your ticket):"
echo "           $(pr_link "$branch")"
