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

# Build a small access-log so the harder examples have realistic data.
cat > access.log << '__EOF__'
192.168.1.10 - - [15/Oct/2026:08:01:12] "GET /home" 200 531
192.168.1.11 - - [15/Oct/2026:08:14:55] "GET /login" 200 220
192.168.1.10 - - [15/Oct/2026:09:02:01] "POST /login" 401 90
192.168.1.12 - - [15/Oct/2026:09:33:40] "GET /app" 500 0
192.168.1.10 - - [15/Oct/2026:09:47:19] "GET /app" 500 0
192.168.1.11 - - [15/Oct/2026:10:05:00] "GET /home" 200 531
__EOF__

# --- Context lines around a match (incident triage) ------------------------
# -C2 shows 2 lines before AND after each match, so you see what led up to it.
echo "== 500 errors with surrounding context =="
grep -C2 ' 500 ' access.log

# --- Extract just the matched part with -o ---------------------------------
# -o prints only what matched, one match per line. -E for the IP regex.
echo "== every client IP (one per line) =="
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log

# --- HARDER + COMBINE: top client IPs (grep | sort | uniq -c | sort -nr) ---
# grep -o extracts the field; sort groups equal values; uniq -c counts each
# run; sort -nr ranks by count. The canonical log-ranking pipeline.
echo "== top client IPs by request count =="
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log \
  | sort | uniq -c | sort -nr

# --- HARDER + COMBINE: count requests per hour -----------------------------
# grep narrows to real requests; awk pulls the [date:time] field; grep -o grabs
# the HH; sort|uniq -c tallies. Each stage does one small job.
echo "== requests per hour =="
grep '"' access.log \
  | grep -oE ':[0-9]{2}:' | tr -d ':' \
  | sort | uniq -c

# --- Quiet test for use in scripts -----------------------------------------
# -q prints nothing and just sets the exit code. This is how scripts branch.
echo "== script-style check: are there any 500s? =="
if grep -q ' 500 ' access.log ; then
  echo "  yes — $(grep -c ' 500 ' access.log) server errors found"
else
  echo "  none"
fi

# --- Fixed-string search for a literal IP (-F, no regex escaping) ----------
# -F treats the pattern literally, so the dots are dots, not 'any char'. Faster
# and safer when the needle is full of regex metacharacters.
echo "== lines from one exact IP (literal match) =="
grep -F '192.168.1.10' access.log

echo "Done. Scratch dir removed on exit."
