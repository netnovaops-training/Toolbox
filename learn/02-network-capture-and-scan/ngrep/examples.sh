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

echo "=== 7) Watch DNS questions fly by (own traffic) ==="
# Empty pattern '' + a BPF filter = ngrep formatting with no content filter.
# Shows the names this box is looking up. Generate some with: dig example.com
#   sudo ngrep -d lo -q -W byline '' udp port 53

echo "=== 8) Extract + tally Host: headers from your own HTTP (ngrep + grep + sort) ==="
# -W single keeps each match on one line so the pipeline is clean.
# Generate traffic in another terminal: curl http://127.0.0.1:8080
#   sudo ngrep -l -q -W single -d lo 'Host:' port 8080 \
#     | grep -oiE 'Host: [^ ]+' | sort | uniq -c | sort -rn
echo "   (live capture + pipeline — left as a comment; run on your own port)"

echo "=== 9) Unique hostnames seen in DNS traffic (ngrep + grep -o + sort -u) ==="
# Pulls domain-looking tokens out of the matched payloads and de-dupes them.
#   sudo ngrep -l -q -W single -d lo '' udp port 53 \
#     | grep -oE '[A-Za-z0-9.-]+\.(com|net|org|local)' | sort -u
echo "   (DNS-name harvest from YOUR own traffic — left as a comment)"

echo "=== 10) Stop after N matches instead of watching forever (-n) ==="
# -n 5 grabs five matching packets then exits — a quick bounded sample.
#   sudo ngrep -q -n 5 -W byline 'GET ' -d lo port 8080

echo "=== 11) Capture matches now, analyse the pcap offline later (no root to re-read) ==="
# Save with -O (needs root), then re-grep the file with -I (no root needed).
work2="$(mktemp -d)"
trap 'rm -rf "$work" "$work2"' EXIT
echo "   capture:  sudo ngrep -qt -O $work2/hits.pcap 'GET ' -d lo port 8080"
echo "   re-grep:  ngrep -q -W byline -I $work2/hits.pcap 'GET ' | grep -E '^GET '"
