#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
# SPDX-License-Identifier: MIT
# Copyright (c) 2017 trimstray (original one-liners)
# Copyright (c) 2026 Jason A. Gibson (adaptations and comments)
# Safe, annotated ngrep examples for learning content-matching packet capture.
#
# AUTHORIZATION: ngrep reads raw payloads off an interface, possibly including
# traffic that isn't yours. Only on your OWN machine/network or with WRITTEN
# permission. These target loopback ('lo') and your own test traffic. Practise
# in a throwaway VM/lab. ngrep needs root: run with sudo.
#
# 'eth0' in the book is replaced here with 'lo' (loopback) so examples stay safe.
# List your real interfaces with:  tcpdump -D

# set -euo pipefail   # -e stop on error, -u unset-var error, pipefail catch mid-pipe errors.
                      # Commented: captures block until Ctrl-C; run pieces by hand.

echo "=== 1) Match a hostname string on a port (basic form) ==="
# ngrep [opts] 'PATTERN' <bpf filter>. Here: look for 'example.com' on port 443.
# On HTTPS you'll see it in the handshake/SNI, but the body is encrypted — note that.
#   sudo ngrep -d lo 'example.com' port 443

echo "=== 2) Filter by source host as well (BPF filter after the pattern) ==="
# The trailing 'src host ... and port ...' is the same filter language tcpdump uses.
#   sudo ngrep -d lo 'example.com' src host 127.0.0.1 and port 443

echo "=== 3) Quiet + timestamps + save matches to a pcap ==="
# -q only print matches (skip the '#' noise), -t timestamp each, -O write to file.
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
echo "   sudo ngrep -d lo -qt -O $work/matches.pcap 'example.com' port 443"
echo "   (saved pcap is removed automatically when this script exits)"

echo "=== 4) Show HTTP header lines readably on your OWN plaintext port ==="
# -W byline prints payloads with real line breaks. 'Host:' is a safe thing to match.
# Generate traffic in another terminal:  curl http://127.0.0.1:8080
#   sudo ngrep -d lo -q -W byline 'Host:' port 8080

echo "=== 5) Case-insensitive match, line-buffered for live output ==="
# -l line-buffered (matches appear immediately), -i case-insensitive (like grep -i).
#   sudo ngrep -d lo -l -q -i 'User-Agent:'

echo "=== 6) Read matches back from a saved pcap (no root needed) ==="
# -I reads from a file instead of a live interface. Safe to run without sudo.
#   ngrep -q -I $work/matches.pcap 'example.com'
echo "   (reads the pcap from example 3 — no capture, no root)"
