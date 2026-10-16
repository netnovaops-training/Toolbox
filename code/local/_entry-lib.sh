#!/usr/bin/env bash
# _entry-lib.sh - shared helpers for newentry.sh, worklog.sh and resolve.sh.
# Sourced by those scripts, not run directly.
#
# Two-branch flow: all ticket work happens on ONE long-lived branch (WORK_BRANCH).
# When it's ready, a pull request merges WORK_BRANCH into main. WORK_BRANCH is kept.

WORK_BRANCH="tickets"
ENTRY_DIRS="knowledge/troubleshooting knowledge/installs knowledge/projects knowledge/learning"

# repo_slug - "owner/name" from the origin URL (https or ssh form)
repo_slug() {
  git remote get-url origin | sed -E 's#^(https://github\.com/|git@github\.com:)##; s#\.git$##'
}

# pr_link - the GitHub page to merge the work branch into main
pr_link() {
  echo "https://github.com/$(repo_slug)/compare/main...$WORK_BRANCH?expand=1"
}

# use_work_branch - switch to the work branch (creating it if needed) and bring in
# the latest from GitHub and from main, so it never falls behind.
use_work_branch() {
  local here
  here="$(git rev-parse --abbrev-ref HEAD)"
  if [ -n "$(git status --porcelain --untracked-files=no)" ] || [ -n "$(git status --porcelain -- knowledge code)" ]; then
    if [ "$here" = "$WORK_BRANCH" ]; then
      # on the work branch: your edits ARE the work - save them before syncing
      git add -u
      git add -- knowledge code 2>/dev/null || true
      git commit -q -m "Save work in progress"
      echo "Saved your edits."
    else
      echo "You have unsaved changes on '$here'. Save them (git add + commit) or undo them first." >&2
      echo "  to see them: git status" >&2
      return 1
    fi
  fi
  git fetch -q origin
  if git show-ref -q --verify "refs/heads/$WORK_BRANCH"; then
    git switch -q "$WORK_BRANCH"
  elif git show-ref -q --verify "refs/remotes/origin/$WORK_BRANCH"; then
    git switch -q -c "$WORK_BRANCH" --track "origin/$WORK_BRANCH"
  else
    git switch -q -c "$WORK_BRANCH" origin/main
    echo "Made the work branch '$WORK_BRANCH' from main."
  fi
  if git show-ref -q --verify "refs/remotes/origin/$WORK_BRANCH"; then
    git merge -q --no-edit "origin/$WORK_BRANCH" || { conflict_help; return 1; }
  fi
  git merge -q --no-edit origin/main || { conflict_help; return 1; }
}

conflict_help() {
  echo "" >&2
  echo "Git couldn't combine the changes by itself (a merge conflict)." >&2
  echo "  see which files: git status" >&2
  echo "  open each one, keep the lines you want, delete the <<<<<<< ======= >>>>>>> markers," >&2
  echo "  then: git add <file> && git commit --no-edit" >&2
  echo "  or give up on this merge and go back: git merge --abort" >&2
}

# all_entries - every logbook entry file (templates, README and GUIDELINE skipped)
all_entries() {
  # shellcheck disable=SC2086
  find $ENTRY_DIRS -maxdepth 1 -name '*.md' ! -name '_*' ! -name README.md ! -name GUIDELINE.md 2>/dev/null | sort
}

# get_field <file> <key> - print the first "key:" value
get_field() {
  sed -n "0,/^$2:/s/^$2: *//p" "$1" | head -1
}

# find_entry [name] - print the ticket to work on.
#   name given: a path, or any part of the file name (e.g. "dns-typo")
#   no name:    the one unresolved ticket; if several, ask which (by number)
find_entry() {
  local want="${1:-}" matches n i choice
  if [ -n "$want" ]; then
    if [ -f "$want" ]; then echo "$want"; return 0; fi
    matches="$(all_entries | grep -F -- "$want" || true)"
  else
    matches="$(all_entries | while read -r f; do
      case "$(get_field "$f" status)" in open|in-progress|blocked) echo "$f" ;; esac
    done)"
  fi
  n="$(printf '%s' "$matches" | grep -c . || true)"
  if [ "$n" = "1" ]; then echo "$matches"; return 0; fi
  if [ "$n" = "0" ]; then
    if [ -n "$want" ]; then echo "No ticket matches '$want'." >&2
    else echo "No open tickets. Start one with: bash code/local/newentry.sh <type> <short-title>" >&2; fi
    return 1
  fi
  echo "Which ticket?" >&2
  i=0
  while read -r f; do
    i=$((i + 1))
    printf '  %d) %s  [%s]\n' "$i" "$(get_field "$f" title)" "$(get_field "$f" status)" >&2
  done <<< "$matches"
  printf 'Number: ' >&2
  choice=""
  if [ -t 0 ]; then
    read -r choice || true
  elif { : < /dev/tty; } 2>/dev/null; then
    read -r choice < /dev/tty || true
  else
    read -r choice || true          # answer piped in, e.g.  echo 2 | bash worklog.sh "note"
  fi
  if [ -z "$choice" ]; then
    echo "" >&2
    echo "No answer. Name the ticket instead, e.g. --file dns-typo" >&2
    return 1
  fi
  if ! printf '%s' "$choice" | grep -Eq '^[0-9]+$' || [ "$choice" -lt 1 ] || [ "$choice" -gt "$n" ]; then
    echo "Not a choice from the list." >&2
    return 1
  fi
  printf '%s\n' "$matches" | sed -n "${choice}p"
}

# set_field <file> <key> <value> - change the first "key:" line (the frontmatter one)
set_field() {
  sed -i "0,/^$2:.*/s##$2: $3#" "$1"
}

# log_line <file> <text> - append a dated bullet under "## Work log" (adds the heading if missing)
log_line() {
  grep -q '^## Work log' "$1" || printf '\n## Work log\n' >> "$1"
  [ -n "$(tail -c1 "$1")" ] && printf '\n' >> "$1"
  printf -- '- %s - %s\n' "$(date +%F)" "$2" >> "$1"
}
