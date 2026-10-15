#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
# SPDX-License-Identifier: MIT
# Copyright (c) 2017 trimstray (original one-liners)
# Copyright (c) 2026 Jason A. Gibson (adaptations and comments)
# Safe, annotated netcat (nc) examples for learning raw TCP/UDP connections.
#
# AUTHORIZATION: only point nc at machines you OWN or have WRITTEN permission to
# test. Every example below targets localhost or the placeholder lab subnet
# 192.168.1.0/24. Practise in a throwaway VM/lab, never on production or a
# stranger's host. No reverse/bind-shell recipes are included on purpose.

# set -euo pipefail   # -e stop on error, -u unset-var error, pipefail catch mid-pipe errors.
                      # Commented: listeners block, so run these pieces by hand, two terminals.

echo "=== 1) Test whether a port is open (the everyday check) ==="
# -v verbose (say what happened), -z just probe (send nothing), -w1 give up after 1s.
# Points at loopback so it's safe to run right now.
nc -vz -w1 127.0.0.1 22 || echo "   (port 22 closed/filtered on this host — that's fine)"

echo "=== 2) Check a UDP port on your OWN host ==="
# -u switches to UDP. UDP has no handshake, so 'open' is less definite than TCP.
#   nc -vzu -w1 127.0.0.1 53

echo "=== 3) Scan a TINY range on a host YOU OWN (comment; use nmap for real scans) ==="
# WARNING: scanning is intrusive. Only on your own machines. Keep the range small.
#   nc -vz -w1 192.168.1.50 20-25
echo "   (left as a comment — see the nmap lesson for proper scanning)"

echo "=== 4) A simple listener + client (run in TWO terminals, your machines only) ==="
# Terminal A (listener, keeps running with -k after each client disconnects):
#   nc -lk 5000
# Terminal B (client — type lines, they appear in terminal A):
#   nc 192.168.1.50 5000
echo "   (two-terminal demo — commands are in the comments above)"

echo "=== 5) Prove it locally with a background listener (safe, self-contained) ==="
# Start a one-shot listener in the background on a high port, send it a line, read it back.
port=5000
outfile="$(mktemp)"
trap 'rm -f "$outfile"' EXIT
# Some nc builds differ on flags; this uses the most portable form. If it errors,
# your nc variant differs — that's a useful thing to notice, not a failure.
( nc -l "$port" > "$outfile" & echo "hello over tcp" | nc -w1 127.0.0.1 "$port" ) 2>/dev/null || true
sleep 1
echo "   listener received: $(cat "$outfile" 2>/dev/null || echo '(nothing / nc flag variant)')"

echo "=== 6) Transfer a file between two of YOUR machines (comment) ==="
# Receiver (machine A):   nc -l 5000 > received.tar
# Sender  (machine B):    nc 192.168.1.50 5000 < to_send.tar
echo "   (two-machine demo — commands in the comments above)"

echo "=== 7) Grab a service banner (what a service announces on connect) ==="
# Connect briefly and see the greeting. -w1 so it won't hang if nothing speaks first.
#   nc -v -w1 192.168.1.50 22     # an SSH daemon prints its version string
echo "   (point at your own host — left as a comment)"

echo "=== 8) Scriptable port check via EXIT CODE (no text parsing) ==="
# nc -z sets $? : 0 = open, non-zero = closed/filtered. Clean for 'if' tests.
if nc -z -w1 127.0.0.1 22 2>/dev/null; then
  echo "   127.0.0.1:22 is OPEN"
else
  echo "   127.0.0.1:22 is closed/filtered (fine on most desktops)"
fi

echo "=== 9) Check a LIST of ports and summarise open vs closed (loop + sort) ==="
# Loop a handful of ports on loopback; print each state, then sort for readability.
host=127.0.0.1
for p in 22 80 443 5432 8080; do
  if nc -z -w1 "$host" "$p" 2>/dev/null; then echo "$p open"; else echo "$p closed"; fi
done | sort -n

echo "=== 10) Target list from a file -> reachability report (while-read, YOUR hosts) ==="
# WARNING: only list hosts you OWN. Build a demo list in a scratch dir first.
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
printf '127.0.0.1 22\n127.0.0.1 9999\n' > "$work/targets.txt"
while read -r h p; do
  nc -z -w1 "$h" "$p" 2>/dev/null && echo "UP   $h:$p" || echo "DOWN $h:$p"
done < "$work/targets.txt"

echo "=== 11) Send a raw HTTP request by hand and grep the status line ==="
# No curl needed: printf the wire-format request, pipe into nc, grep the first line.
# \r\n is the real HTTP line ending. Points at a placeholder host YOU own.
#   printf 'GET / HTTP/1.0\r\nHost: 192.168.1.50\r\n\r\n' | nc -w3 192.168.1.50 80 | grep -i '^HTTP/'
echo "   (raw HTTP demo against your own host — left as a comment)"

echo "=== 12) Pure-bash fallback when nc isn't installed (recognise this) ==="
# Minimal containers often lack nc; bash can open /dev/tcp itself.
#   (echo > /dev/tcp/127.0.0.1/22) 2>/dev/null && echo "open" || echo "closed"
echo "   (bash /dev/tcp trick — left as a comment)"
