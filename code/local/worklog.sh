#!/usr/bin/env bash
# worklog.sh - save today's progress on the current ticket: adds a dated line under
# "## Work log", sets the status, commits and pushes the branch.
# Usage: bash code/local/worklog.sh "what I did"
#        bash code/local/worklog.sh --blocked "waiting on X"
#        bash code/local/worklog.sh --file dns-typo "note"   (pick the ticket by name)
# With several tickets open and no --file, it asks which one (by number).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
. code/local/_entry-lib.sh

status="in-progress"
file=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --blocked) status="blocked"; shift ;;
    --file)    file="${2:-}"; shift 2 ;;
    *) break ;;
  esac
done
note="${*:-}"
if [ -z "$note" ]; then
  echo 'Usage: bash code/local/worklog.sh [--blocked] [--file <entry>] "what I did"'
  exit 1
fi

use_work_branch
branch="$WORK_BRANCH"
entry="$(find_entry "$file")"
set_field "$entry" status "$status"
if [ "$status" = "blocked" ]; then note="blocked: $note"; fi
log_line "$entry" "$note"

git add "$entry"
git commit -q -m "Work log ($status): $(get_field "$entry" title)"
git push -q -u origin "$branch"
echo "Saved to $entry  (status: $status)"
