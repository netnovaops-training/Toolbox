#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
#
# sed: stream editor — substitute, delete, and print lines non-interactively.
# Some lines CHANGE files (marked WARNING). Everything runs in a scratch dir,
# but still practice in a throwaway VM to build the habit.

# Safety flags (see terminal/examples.sh). Left off so the demo keeps flowing.
# set -euo pipefail

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT
cd "$SCRATCH"

# A sample file to edit.
cat > server.conf << '__EOF__'
line 1: listen 80
line 2: server_name example.com
line 3: root /var/www
line 4: index index.html
line 5: keepalive on
line 6: gzip on
__EOF__

# --- Print one specific line -----------------------------------------------
# -n = don't auto-print; 3p = print line 3. Together you see ONLY line 3.
echo "== line 3 =="
sed -n 3p server.conf

# --- Preview a substitution (no -i, so nothing is written) -----------------
# Always test like this first. s/old/new/ changes the first match per line.
echo "== preview: listen 80 -> listen 8080 (file NOT changed yet) =="
sed 's/listen 80/listen 8080/' server.conf
echo "-- file on disk is still:"; grep listen server.conf

# --- Substitute in place, keeping a backup ---------------------------------
# WARNING: -i writes to the file. -i.orig saves server.conf.orig first so you
# can undo. On macOS/BSD this would be: sed -i '' 's/.../.../' file
echo "== now editing in place (backup -> server.conf.orig) =="
sed -i.orig 's/listen 80/listen 8080/' server.conf
grep listen server.conf
echo "-- backup still holds the original:"; grep listen server.conf.orig

# --- Delete a specific line in place ---------------------------------------
# WARNING: changes the file. 6d deletes line 6. Keep a backup while learning.
cp server.conf work.conf           # work on a copy so the demo stays tidy
echo "== delete line 6 of work.conf =="
sed -i 6d work.conf
cat work.conf

# --- Delete a range of lines -----------------------------------------------
# WARNING: changes the file. 2,4d removes lines 2 through 4 inclusive.
cp server.conf work2.conf
echo "== delete lines 2-4 of work2.conf =="
sed -i '2,4d' work2.conf
cat work2.conf

# --- Delete from a matching line plus the next N ---------------------------
# /root/,+2d = starting at the line matching 'root', delete it and 2 more.
cp server.conf work3.conf
echo "== delete the 'root' line and the 2 lines after it =="
sed -i '/root/,+2d' work3.conf
cat work3.conf

# --- Join all lines into one (replace newlines with spaces) ----------------
# The classic loop idiom: :a label, N pull next line in, $!ba loop unless last,
# then swap every newline for a space. We DON'T use -i so we just view it.
echo "== whole file on one line =="
sed ':a;N;$!ba;s/\n/ /g' server.conf

echo "Done. Scratch dir removed on exit."
