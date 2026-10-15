#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
#
# grep: print lines that match a pattern. Nothing here changes your system;
# grep only reads. Still, practice in a throwaway VM to experiment freely.

# Safety flags (see terminal/examples.sh). Left off so every demo runs.
# set -euo pipefail

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT
cd "$SCRATCH"

# Build a sample log and a sample config so the searches have something to hit.
cat > app.log << '__EOF__'
2026-10-15 INFO  starting up
2026-10-15 WARN  disk at 80%
2026-10-15 ERROR connection to example.com failed
2026-10-15 INFO  retrying
2026-10-15 CRITICAL out of memory
__EOF__

cat > app.conf << '__EOF__'
# main config
  # indented comment
port = 8080

host = 192.168.1.10
__EOF__

# --- Search a whole directory for a pattern --------------------------------
# -r recurse, -n line numbers. Output is path:line:text so you know where.
echo "== every line mentioning ERROR under here =="
grep -rn "ERROR" .

# --- Match any of several patterns -----------------------------------------
# -E turns on extended regex so the | means OR without backslashes.
echo "== INFO or WARN lines =="
grep -E '(INFO|WARN)' app.log

# Same idea, two other spellings (pick whichever reads best to you):
grep -e INFO -e WARN app.log           # repeat -e per pattern
grep 'INFO\|WARN' app.log              # basic regex: escape the pipe

# --- Exclude several patterns ----------------------------------------------
# -v inverts the match; -E for the OR group. Result = lines that are NONE of
# error/critical/warning (case-sensitive here).
echo "== lines that are not error/critical/warning =="
grep -vE '(ERROR|CRITICAL|WARN)' app.log

# --- Show a config without comments ----------------------------------------
# ^[[:space:]]*# matches a line whose first non-space character is #. -v drops
# those, leaving the real settings (and blank lines, for now).
echo "== config without comment lines =="
grep -v '^[[:space:]]*#' app.conf

# --- Show a config without comments AND without blank lines ----------------
# ^$ matches an empty line; combined with # in one OR group, -v removes both.
echo "== config, no comments, no blank lines =="
grep -vE '^[[:space:]]*#|^$' app.conf

# --- Remove blank lines and save to a new file -----------------------------
# A single dot matches any line with at least one character, so blank lines are
# dropped. Writing to a NEW file keeps the original intact.
echo "== config with blank lines stripped (written to clean.conf) =="
grep . app.conf > clean.conf
cat clean.conf

# --- Search for strings that start with a dash -----------------------------
# Without -- grep would read --foo as options. -- means "options are done".
printf -- '--keep-this\nnormal line\n' > flags.txt
echo "== lines containing a double dash =="
grep -- -- flags.txt

echo "Done. Scratch dir removed on exit."
