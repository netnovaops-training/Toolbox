#!/usr/bin/env bash
# _entry-lib.sh - shared helpers for newentry.sh, worklog.sh and resolve.sh.
# Sourced by those scripts, not run directly.

ENTRY_DIRS="knowledge/troubleshooting knowledge/installs knowledge/projects knowledge/learning"

# repo_slug - "owner/name" from the origin URL (https or ssh form)
repo_slug() {
  git remote get-url origin | sed -E 's#^(https://github\.com/|git@github\.com:)##; s#\.git$##'
}

# pr_link <branch> - the GitHub "open a pull request" page for this branch
pr_link() {
  echo "https://github.com/$(repo_slug)/compare/main...$1?expand=1"
}

# find_entry [file] - print the logbook entry this branch is working on.
# Uses the given path, else the one entry this branch added or changed vs main.
find_entry() {
  if [ -n "${1:-}" ]; then
    [ -f "$1" ] || { echo "not found: $1" >&2; return 1; }
    echo "$1"
    return 0
  fi
  local base list n
  base="$(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main)"
  # shellcheck disable=SC2086
  list="$(git diff --name-only "$base" HEAD -- $ENTRY_DIRS \
          | grep -Ev '/(_[^/]*|README\.md|GUIDELINE\.md)$' | grep '\.md$' || true)"
  n="$(printf '%s' "$list" | grep -c . || true)"
  if [ "$n" = "1" ]; then
    echo "$list"
    return 0
  fi
  if [ "$n" = "0" ]; then
    echo "No logbook entry on this branch. Pass one with --file <path>." >&2
  else
    echo "More than one entry on this branch - pick one with --file <path>:" >&2
    printf '%s\n' "$list" | sed 's/^/  /' >&2
  fi
  return 1
}

# set_field <file> <key> <value> - change the first "key:" line (the frontmatter one)
set_field() {
  sed -i "0,/^$2:.*/s##$2: $3#" "$1"
}

# get_field <file> <key> - print the first "key:" value
get_field() {
  sed -n "0,/^$2:/s/^$2: *//p" "$1" | head -1
}

# log_line <file> <text> - append a dated bullet under "## Work log" (adds the heading if missing)
log_line() {
  grep -q '^## Work log' "$1" || printf '\n## Work log\n' >> "$1"
  [ -n "$(tail -c1 "$1")" ] && printf '\n' >> "$1"
  printf -- '- %s - %s\n' "$(date +%F)" "$2" >> "$1"
}
