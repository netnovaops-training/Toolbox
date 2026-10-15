#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
#
# fuser: find which process is using a file, directory, mount, or port.
# The LOOKUP examples are read-only and safe. The KILL examples send signals
# that stop processes and can lose data — they are shown but commented out.
# Practice in a throwaway VM/container, never on a machine you care about.

set -euo pipefail   # -e stop on error, -u error on unset var, pipefail catch mid-pipe failures

work="$(mktemp -d)"                 # unique scratch dir
trap 'rm -rf "$work"' EXIT          # auto-clean on exit

echo "=== 1) Which processes are using a file? ==="
# Create a file and hold it open with a background process so there's something
# to find. 'tail -f' keeps the file open until we stop it.
echo "hello" > "$work/demo.log"
tail -f "$work/demo.log" >/dev/null &   # background holder of the file
holder=$!                               # remember its PID so we can stop it later
sleep 1                                  # give tail a moment to open the file
fuser "$work/demo.log" || true           # prints the PID(s) using the file

echo "=== 2) Same, but verbose: user, PID, access type, command ==="
# -v is the readable table. ACCESS 'f' = open file. Much clearer than bare PIDs.
fuser -v "$work/demo.log" || true

echo "=== 3) Which processes use anything under a directory/filesystem ==="
# -m treats the path as a mount/filesystem and finds EVERY user of it.
# This is the command for "can't unmount: target is busy".
fuser -mv "$work" || true

echo "=== 4) Which process is listening on a port? ==="
# Syntax is port/protocol. Here we check a UDP and a TCP port.
# On your box these may be empty (nothing listening) — that's fine.
fuser -v 53/udp  || true     # classic DNS port
fuser -v 443/tcp || true     # classic HTTPS port

echo "=== 5) List the signal names fuser can send ==="
# Useful before using -k so you know your options (HUP, TERM, KILL, ...).
fuser --list-signals || true

echo "=== 6) COMBINE with ps (lesson 04): turn the PID into full details ==="
# fuser prints PIDs on stdout and its labels on stderr, so 2>/dev/null leaves
# only the numbers — perfect to hand to ps. This answers 'who holds my file,
# since when, and what's the full command line?' in one go.
holder_pids="$(fuser "$work/demo.log" 2>/dev/null || true)"
if [ -n "${holder_pids// }" ]; then
  ps -o pid,user,etime,cmd -p $holder_pids || true
else
  echo "(no holder found — nothing to look up)"
fi

echo "=== 7) COMBINE with awk (lesson 04): extract just the PID column ==="
# Parse the verbose table and pull field 2 (the PID). This is how you'd feed
# fuser's result into a script step — e.g. to look up or (carefully) signal it.
fuser -v "$work/demo.log" 2>&1 | awk 'NR>1 && $2 ~ /^[0-9]+$/ { print "PID holding the file:", $2 }' || true

echo "=== 8) COMBINE: fuser finds the PID, lsof explains it (if lsof present) ==="
# fuser answers 'who holds it?' fast; lsof answers 'what exactly are they doing?'.
# Knowing both tools and when to reach for each is the job-level skill.
if command -v lsof >/dev/null 2>&1; then
  lsof "$work/demo.log" || true
else
  echo "(lsof not installed — on a real box: lsof <file> or lsof -i :<port>)"
fi

# Stop our background holder cleanly now that all the lookups are done.
kill "$holder" 2>/dev/null || true
wait "$holder" 2>/dev/null || true

# --- KILL examples from the book (LEFT COMMENTED ON PURPOSE) -----------------
# WARNING: every command below sends a signal that stops a process and can
# lose unsaved data. Run `fuser -v <target>` FIRST and be sure. Throwaway VM only.
#
#   # Kill holders of a file, asking before each one (-i = interactive):
#   fuser -ki "$work/demo.log"
#
#   # Send a specific signal instead of the default SIGKILL — here SIGHUP,
#   # which many daemons treat as "reload your config / reopen files":
#   fuser -k -HUP "$work/demo.log"
#
#   # Free a busy mount so you can unmount it (polite TERM, confirm each):
#   fuser -k -i -TERM -m /mnt/data
# -----------------------------------------------------------------------------
echo "done (kill examples are commented out for safety)"
