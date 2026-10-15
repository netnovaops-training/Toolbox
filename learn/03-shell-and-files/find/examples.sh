#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
#
# find: search the filesystem by name/size/time/owner/permission, then act.
# Practice in a throwaway VM or container. The risky lines are marked WARNING.

# Safety flags (see terminal/examples.sh for what each does). Commented out so
# every demo line runs even if one test matches nothing.
# set -euo pipefail

# Scratch dir with sample files so we never search the real system destructively.
SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT
cd "$SCRATCH"

# Build a small tree to search.
mkdir -p site/css site/js empty_dir
echo "body {}"        > site/css/style.css
echo "console.log(1)" > site/js/app.js
echo "# config"       > site/app.conf
head -c 2M /dev/zero  > site/big.bin        # a 2 MB file to find by size
echo "old"            > site/old.txt
touch -d '90 days ago' site/old.txt 2>/dev/null || true   # make it look old

# --- Find files modified in the last 60 minutes ----------------------------
# -mmin 60 = modified within the last 60 minutes. Great right after an incident.
echo "== recently modified files =="
find . -mmin -60 -type f

# --- Find all files larger than a size -------------------------------------
# -size +1M = strictly larger than 1 megabyte. Classic "what filled the disk".
echo "== files larger than 1M =="
find . -type f -size +1M

# --- Find files by name (quote the glob!) ----------------------------------
# Quoting '*.conf' stops the shell expanding it before find sees it.
echo "== .conf files =="
find . -type f -name '*.conf'

# --- Find files owned by a specific user -----------------------------------
# Handy when offboarding someone. We use the current user so it actually matches.
echo "== files owned by $(whoami) =="
find . -type f -user "$(whoami)" | head

# --- Find files NOT owned by a user ----------------------------------------
# \! negates the test. Backslash protects the ! from the shell.
echo "== files NOT owned by root =="
find . -type f \! -user root | head

# --- Recursively find the latest modified files ----------------------------
# stat prints "epoch :human-time name"; sort -nr puts newest first; cut drops
# the epoch key we only used for sorting; head keeps the top few.
echo "== newest files first =="
find . -type f -exec stat --format '%Y :%y %n' "{}" \; | sort -nr | cut -d: -f2- | head

# --- Change permission for files only (not directories) --------------------
# WARNING: this CHANGES permissions. Safe here (scratch). {} + batches files
# into one chmod call, which is faster than one call per file (\;).
echo "== setting files to 664 =="
find site -type f -exec chmod 664 {} +
ls -l site/app.conf

# --- Change permission for directories only --------------------------------
# WARNING: changes permissions. Directories usually need the execute bit to be
# enterable, so we add group execute here.
echo "== adding group-execute to directories =="
find site -type d -exec chmod g+rx {} +

# --- Find setuid / setgid executables (security audit) ---------------------
# -perm -4000 = setuid bit set, -2000 = setgid. These run as the file's owner,
# so attackers love them. On a real box run this as root over / to see all.
echo "== setuid/setgid files under this tree (usually none here) =="
find . \( -perm -4000 -o -perm -2000 \) -type f -exec ls -la {} \; || true

# --- Remove empty sub-directories ------------------------------------------
# WARNING: removes directories. -empty matches only empty ones; rmdir refuses
# non-empty dirs as a safety net. -depth processes children before parents.
echo "== removing empty directories =="
find . -depth -type d -empty -exec rmdir {} \; 2>/dev/null || true
ls -1

# --- Delete files older than N days ----------------------------------------
# WARNING: -delete is IRREVERSIBLE — no undo, no trash. Test the SAME filter
# with -print FIRST so you can see exactly what would be deleted:
echo "== files older than 60 days (preview only) =="
find . -type f -mtime +60 -print
# Only after you trust the preview would you swap -print for -delete:
# find . -type f -mtime +60 -delete

# --- HARDER: biggest files under a tree, human-readable, top 5 -------------
# The classic "what filled the disk" done properly. -printf prints size+path
# with no per-file stat (fast). sort -nr = biggest first. awk converts to MB.
# (-printf is GNU find; BSD/macOS use: find . -type f -exec stat -f '%z %N' {} +)
echo "== top files by size (MB) =="
find . -type f -printf '%s %p\n' 2>/dev/null \
  | sort -nr | head -n 5 \
  | awk '{ printf "%.2fMB  %s\n", $1/1048576, $2 }'

# --- HARDER: skip a subtree with -prune ------------------------------------
# Pretend site/js is a vendored dir we never want to touch. The idiom is:
# match the dir, -prune it, -o (OR) then do the real action on everything else.
echo "== all files EXCEPT anything under site/js =="
find . -type d -path '*/js' -prune -o -type f -print

# --- HARDER + COMBINE: count files per extension ---------------------------
# find lists files; sed strips everything up to the last dot to leave the
# extension; sort|uniq -c tallies; sort -nr ranks. A whole report in one pipe.
echo "== file count per extension =="
find . -type f -name '*.*' | sed 's/.*\.//' | sort | uniq -c | sort -nr

# --- HARDER + COMBINE: safe action over odd filenames (find + xargs) -------
# WARNING (no change — just echoes): filenames can contain spaces/newlines.
# -print0 emits NUL-separated names; xargs -0 splits on NUL, so nothing breaks.
echo "== find -print0 | xargs -0 handles spaces safely =="
mkdir -p tricky
touch "tricky/with space.txt" "tricky/new
line.txt" 2>/dev/null || touch "tricky/with space.txt"
find tricky -type f -print0 | xargs -0 -n1 echo "safe:"

# --- HARDER + COMBINE: what changed since a reference file -----------------
# Touch a marker, change one file, then find everything newer than the marker.
# Real use: "what changed since the last known-good deploy?"
echo "== files changed since a marker =="
touch marker
sleep 1
echo "update" >> site/app.conf           # change one file after the marker
find . -type f -newer marker ! -name marker

echo "Done. Scratch dir removed on exit."
