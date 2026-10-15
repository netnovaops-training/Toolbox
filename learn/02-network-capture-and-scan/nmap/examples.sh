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
