#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
# SPDX-License-Identifier: MIT
# Copyright (c) 2017 trimstray (original one-liners)
# Copyright (c) 2026 Jason A. Gibson (adaptations and comments)
# Safe, annotated tcpdump examples for learning packet capture.
#
# AUTHORIZATION: tcpdump can read OTHER people's traffic on a shared network.
# Only capture on your OWN machine/network or with WRITTEN permission. These
# examples capture on 'lo' (loopback = traffic that never leaves your computer)
# or your own host, with tight filters and small packet counts. Practise in a
# throwaway VM/lab, never on production or a shared segment.
#
# tcpdump needs root: run these with sudo. 'eth0' below is a placeholder — list
# your real interfaces first with:  tcpdump -D

# set -euo pipefail   # -e stop on error, -u unset-var error, pipefail catch mid-pipe errors.
                      # Commented: captures block until Ctrl-C or -c fires; run pieces by hand.

echo "=== 0) List the interfaces you can capture on (safe, no capture) ==="
#   tcpdump -D
echo "   run:  tcpdump -D    then use one of those names below instead of 'lo'"

echo "=== 1) Watch traffic on one port, numeric, on loopback (safe demo) ==="
# -n don't resolve names, -i lo loopback only. Ctrl-C to stop.
# In another terminal run e.g.  curl http://127.0.0.1:8080  to generate traffic.
#   sudo tcpdump -n -i lo port 8080

echo "=== 2) Capture just the first 10 packets, then stop automatically ==="
# -c 10 caps the capture so it won't flood your screen. Great for a quick sample.
#   sudo tcpdump -n -i lo -c 10 host 127.0.0.1 and port 8080

echo "=== 3) Filter by direction and host:port (adapted to a safe target) ==="
# -e print link-layer header, -Q in = only inbound packets.
# Original targeted a real host:port; here we keep it on loopback and your own host.
#   sudo tcpdump -ne -i lo -Q in host 127.0.0.1 and port 8080

echo "=== 4) Save packets to a file, read them back later ==="
# -w writes a .pcap (open in Wireshark). -r reads it back. Capture to a scratch dir.
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
echo "   capture:  sudo tcpdump -n -i lo -c 100 port 8080 -w $work/cap.pcap"
echo "   read:     tcpdump -n -r $work/cap.pcap"

echo "=== 5) Capture only ICMP (ping) packets ==="
# Run 'ping 127.0.0.1' in another terminal to see echo request/reply pairs.
#   sudo tcpdump -n -i lo icmp

echo "=== 6) Show payload as ASCII (watch YOUR OWN plaintext HTTP) ==="
# -A prints payload text, -s0 captures the whole packet. This is how you PROVE to
# yourself that plain HTTP is readable on the wire (and why HTTPS exists).
# Only on your own loopback traffic.
#   sudo tcpdump -i lo -A -s0 port 8080

echo "=== 7) Just GET/POST/Host lines from your own HTTP traffic (readable) ==="
# A gentle version of the book's HTTP filter: show request lines, skip the rest.
# (The book also had a password-grepping one-liner; omitted on purpose — that is
#  credential interception and out of scope for learning.)
#   sudo tcpdump -i lo -s0 -v -n -l | egrep -i "GET /|POST /|Host:"

echo "=== 8) Top talkers: count packets by source address (adapted) ==="
# -t drop timestamps, -c 200 sample 200 packets, then count by source IP.
#   sudo tcpdump -n -i lo -t -c 200 | awk '{print $3}' | cut -d. -f1-4 | sort | uniq -c | sort -nr | head
echo "   (see the doc; run on your own interface with a small -c sample)"
