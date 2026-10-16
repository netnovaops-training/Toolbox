#!/usr/bin/env bash
# resolve.sh - close a ticket: status resolved, closed date, a final work-log line,
# commit and push to the work branch. Publish later by merging 'tickets' into main.
# Usage: bash code/local/resolve.sh ["closing note"]
#        bash code/local/resolve.sh --file dns-typo ["note"]   (pick the ticket by name)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
. code/local/_entry-lib.sh

file=""
if [ "${1:-}" = "--file" ]; then
  file="${2:-}"
  shift 2
fi
note="${*:-resolved}"

use_work_branch
branch="$WORK_BRANCH"
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
echo "To publish it: open a pull request from $branch into main and merge it (keep the branch)."
echo "  $(pr_link)"
echo "After the merge, LOGBOOK.md, JACKET.md and your portfolio rebuild on main by themselves."
