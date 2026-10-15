#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
# SPDX-License-Identifier: MIT
# Copyright (c) 2017 trimstray (original one-liners)
# Copyright (c) 2026 Jason A. Gibson (adaptations and comments)
# Safe, annotated nmap examples for learning host/port/service discovery.
#
# AUTHORIZATION (read twice): scanning machines you don't own can be ILLEGAL.
# Only scan: hosts YOU OWN, a network you have WRITTEN permission to test, or the
# makers' sanctioned practice host scanme.nmap.org (gently). Everything below
# targets localhost, the placeholder lab subnet 192.168.1.0/24, or that practice
# host. Do real learning inside a throwaway VM/lab you control.
#
# The book's aggressive multi-script web-attack recipe is intentionally NOT
# included — that is offensive tooling, out of scope for learning fundamentals.

# set -euo pipefail   # -e stop on error, -u unset-var error, pipefail catch mid-pipe errors.
                      # Commented: these are real network actions — run them one at a time,
                      # on purpose, against a target you are allowed to scan.

echo "=== 1) Ping scan: which hosts are UP on my own lab subnet (no port scan) ==="
# -sn just discovers live hosts. 192.168.1.0/24 is a placeholder for YOUR lab LAN.
#   sudo nmap -sn 192.168.1.0/24

echo "=== 2) Fast look at common OPEN ports on one host I own ==="
# -F fast (~100 common ports), --open hide closed/filtered clutter.
#   sudo nmap -F --open 192.168.1.50

echo "=== 3) Unprivileged scan of my OWN machine (no sudo needed) ==="
# -sT TCP connect scan uses the normal connect() call, so no root required.
# Safe to run right now against loopback.
nmap -sT --open 127.0.0.1 || echo "   (install nmap to try this: apt/brew install nmap)"

echo "=== 4) Full TCP range + service/version detection on a host I own ==="
# -p 1-65535 all TCP ports, -sV name the service/version, -sS SYN scan (needs root),
# -T4 brisk timing that's fine on your own LAN (don't crank to T5 on fragile nets).
# Replace the IP with a machine YOU OWN.
#   sudo nmap -p 1-65535 -sV -sS -T4 192.168.1.50

echo "=== 5) Identify services on specific ports only ==="
# Narrowing to a few ports is faster and gentler than scanning everything.
#   sudo nmap -sV -p 22,80,443 192.168.1.50

echo "=== 6) Save results to files (normal / greppable / XML) ==="
# -oN human-readable, -oG greppable, -oX XML for other tools. Writes to a scratch dir.
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
echo "   sudo nmap -F --open -oN $work/scan.txt -oG $work/scan.grep 192.168.1.50"
echo "   (output files are removed automatically when this script exits)"

echo "=== 7) The makers' sanctioned practice target (gently, rarely) ==="
# scanme.nmap.org is provided by nmap's authors FOR practice. Be light-handed.
#   nmap -F scanme.nmap.org
echo "   (public practice host — left as a comment so you run it deliberately)"

echo "=== 8) Greppable output -> list of IPs with port 22 open (nmap + grep + awk) ==="
# -oG - prints greppable output to stdout; grep the open SSH line, awk the IP.
# The result is a clean host list you could feed straight into an ssh loop.
#   sudo nmap -p22 --open -oG - 192.168.1.0/24 | grep '22/open' | awk '{print $2}'
echo "   (scans YOUR lab subnet — left as a comment; swap in your real range)"

echo "=== 9) Scan targets from a FILE and exclude the gateway (-iL / --exclude) ==="
# Maintain your inventory as text; -iL reads it, --exclude keeps fragile hosts out.
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
printf '127.0.0.1\n192.168.1.50\n' > "$work/targets.txt"
echo "   built demo target list at $work/targets.txt"
#   sudo nmap -F --open -iL $work/targets.txt --exclude 192.168.1.1

echo "=== 10) Quick-but-meaningful: top 20 ports with the REASON column ==="
# --top-ports 20 = the 20 most common; --reason explains each verdict (syn-ack/reset/...).
# Safe to run against loopback right now (unprivileged -sT).
nmap -sT --top-ports 20 --reason --open 127.0.0.1 \
  || echo "   (install nmap to try this: apt/brew install nmap)"

echo "=== 11) Safe NSE scripts on a host you own (read-only checks) ==="
# --script safe stays in the read-only category. -sV adds version detection.
# Stay in safe/default categories for learning; intrusive scripts need authorisation.
#   sudo nmap -sV --script safe -p 22,80,443 192.168.1.50

echo "=== 12) Baseline now, diff later: did a new port open? (ndiff) ==="
# Save XML today and tomorrow, then ndiff shows exactly what changed. Monitoring 101.
echo "   today:     sudo nmap -F -oX $work/baseline.xml 192.168.1.50"
echo "   tomorrow:  sudo nmap -F -oX $work/today.xml 192.168.1.50"
echo "   compare:   ndiff $work/baseline.xml $work/today.xml"
