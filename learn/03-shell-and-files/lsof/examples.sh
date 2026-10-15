#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
#
# lsof: list open files and network sockets, and map them back to a process.
# Every command here only READS state — nothing is changed. Still, practice in
# a throwaway VM so you are free to poke around.

# Safety flags (see terminal/examples.sh). Commented out so the demo keeps going
# even when a query returns nothing on your machine.
# set -euo pipefail

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT
cd "$SCRATCH"

# lsof may not be installed everywhere. Check first and explain if missing.
if ! command -v lsof >/dev/null 2>&1 ; then
  echo "lsof is not installed here. On Debian/Ubuntu: sudo apt install lsof"
  echo "Read the comments below to learn what each command would show."
fi

# --- Show processes using a network connection right now -------------------
# -P numeric ports, -i network files, -n numeric hosts (no slow DNS).
# As a normal user you only see your own; prefix sudo to see everything.
echo "== current network connections =="
lsof -P -i -n 2>/dev/null | head || true

# --- Show what is using a specific port ------------------------------------
# The daily "port already in use" fix. Swap 443 for the port you care about.
echo "== who holds tcp port 443 (likely nothing in a fresh VM) =="
lsof -i tcp:443 2>/dev/null || echo "  (nothing on 443)"

# --- List everything that is LISTENING -------------------------------------
# Pipe to grep LISTEN to keep only servers waiting for connections. Run with
# sudo on a real box to catch ports owned by root services.
echo "== listening sockets =="
lsof -i -P -n 2>/dev/null | grep -i "listen" | head || echo "  (none visible without sudo)"

# --- All open ports in a tidy column view ----------------------------------
# column -t lines the fields up so the list is readable.
echo "== listening sockets, column-aligned =="
lsof -Pni4 2>/dev/null | grep LISTEN | column -t | head || true

# --- List all files opened by a particular command ------------------------
# -c matches commands whose name STARTS with the text. We use "bash" since a
# shell is almost always running. On a server you might use -c nginx, -c sshd.
echo "== files opened by processes named like 'bash' =="
lsof -c bash 2>/dev/null | head || echo "  (need sudo, or no match)"

# --- Files opened by a user under a directory ------------------------------
# -a ANDs the conditions: this user AND under this directory. +D recurses.
# We point it at our own scratch dir and our own user so it is safe and local.
echo "== open files by $(whoami) under $SCRATCH =="
# Open a file ourselves in the background so there is something to find:
( exec 9<>"$SCRATCH/held.txt"; sleep 2 ) &
HOLDER=$!
sleep 0.3
lsof -u "$(whoami)" -a +D "$SCRATCH" 2>/dev/null || echo "  (nothing held right now)"
wait "$HOLDER" 2>/dev/null || true

# --- Show the current working directory of a process -----------------------
# The FD column shows 'cwd' for a process's working directory. $$ is this shell.
echo "== current working dir of this shell (PID $$) =="
lsof -p "$$" 2>/dev/null | grep cwd || echo "  (need sudo on some systems)"

# --- Show the 10 largest open files ----------------------------------------
# WARNING (performance only, no change): scanning / can be slow on a big box.
# awk keeps files whose size (column 7) is over 1 MB, converts to MB, and prints
# size + name + command; sort -n -u orders them; tail keeps the biggest.
echo "== largest open files (may be slow; needs sudo for the full picture) =="
lsof / 2>/dev/null \
  | awk '{ if ($7 > 1048576) print $7/1048576 "MB " $9 " " $1 }' \
  | sort -n -u | tail | column -t || echo "  (run with sudo to see more)"

echo "Done. Scratch dir removed on exit."
