#!/usr/bin/env bash
# resolve.sh - close the ticket on the current branch: status resolved, closed date,
# a final work-log line, commit and push. Then you mark the PR ready and merge it.
# Usage: bash code/local/resolve.sh ["closing note"]
#        bash code/local/resolve.sh --file knowledge/projects/2026-10-15-x.md ["note"]
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
. code/local/_entry-lib.sh

file=""
if [ "${1:-}" = "--file" ]; then
  file="${2:-}"
  shift 2
fi
note="${*:-resolved}"

branch="$(git rev-parse --abbrev-ref HEAD)"
if [ "$branch" = "main" ]; then
  echo "You are on main. Switch to the ticket branch first: git switch <type>/<title>"
  exit 1
fi

git pull -q --no-edit origin "$branch" 2>/dev/null || true
entry="$(find_entry "$file")"
# count XXX placeholders, ignoring anything inside <!-- --> instruction comments
left="$(awk '/<!--/{c=1} !c && /XXX/{n++} /-->/{c=0} END{print n+0}' "$entry")"
if [ "$left" != "0" ]; then
  echo "Not yet: $entry still has $left line(s) with XXX to fill in (summary, lesson, fix...)."
  echo "Fill them in, then run this again."
  exit 1
fi

set_field "$entry" status resolved
set_field "$entry" closed "$(date +%F)"
log_line "$entry" "$note"

git add "$entry"
git commit -q -m "Resolve: $(get_field "$entry" title)"
git push -q -u origin "$branch"
echo "Resolved: $entry"
echo "Last step: open the pull request, click 'Ready for review', then Merge."
echo "  $(pr_link "$branch")"
echo "After the merge, LOGBOOK.md and JACKET.md rebuild on main by themselves."
