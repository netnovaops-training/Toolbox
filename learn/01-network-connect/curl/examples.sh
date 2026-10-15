#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
# SPDX-License-Identifier: MIT
# Copyright (c) 2017 trimstray (original one-liners)
# Copyright (c) 2026 Jason A. Gibson (adaptations and comments)
# Safe, annotated curl examples for learning HTTP/HTTPS from the command line.
#
# These all request public, well-known endpoints or the placeholder example.com.
# They only READ; none of them change anything on a server.

# set -euo pipefail   # -e stop on error, -u error on unset var, pipefail catch mid-pipe errors.
                      # Commented: this is a read-and-copy menu, not a run-through script.

echo "=== 1) Headers only, silent, insecure explained ==="
# -I headers only (HEAD), -k skip cert check (TESTING ONLY), -s hide progress meter.
curl -Iks https://example.com

echo "=== 2) Follow redirects, set method and User-Agent ==="
# --location follow 301/302, -X set method, -A set the User-Agent string.
curl -Iks --location -X GET -A "learning-curl" https://example.com

echo "=== 3) Route a request through a proxy (shown as a comment) ==="
# --proxy sends the request via a proxy server. Only meaningful if you run one.
#   curl -Iks --location -X GET -A "learning-curl" --proxy http://127.0.0.1:8080 https://example.com
echo "   (needs a local proxy on 127.0.0.1:8080 — left as a comment)"

echo "=== 4) Download a file to a safe scratch dir, resumable ==="
# Use a throwaway temp dir so we never clutter real folders.
work="$(mktemp -d)"                 # unique temp directory
trap 'rm -rf "$work"' EXIT          # auto-clean on exit
# -o write body to this file, -C - resume where an interrupted transfer left off.
curl -s -o "$work/robots.txt" -C - https://example.com/robots.txt || true
echo "   saved into: $work/robots.txt (removed automatically on exit)"

echo "=== 5) Find your public IP (several services that just echo it back) ==="
# Any one of these is enough; they each return the IP the internet sees.
curl -s https://ifconfig.me/ip ; echo
#   curl -s https://icanhazip.com
#   curl -s https://ipinfo.io/ip ; echo

echo "=== 6) Repeat a request N times with a shell loop (gentle: a short sleep) ==="
# Useful to watch a flaky endpoint. Keep N small and add a sleep so you don't hammer anyone.
for i in 1 2 3; do
  curl -sIL -o /dev/null -w "attempt %{http_code}\n" https://example.com
  sleep 1                           # be polite; never turn this into a flood
done

echo "=== 7) Call a JSON API with a body (shown against a placeholder host) ==="
# -H adds a header, -d sends a body (and implies POST). Single-quote the JSON.
#   curl -s -X POST -H 'Content-Type: application/json' \
#        -d '{"name":"test"}' https://api.example.com/items
echo "   (points at a placeholder API — left as a comment)"

echo "=== 8) Resolve + header trace for one domain (adapted mini-report) ==="
# Combines a DNS lookup with an HTTP header fetch, the way you'd triage "is it up?".
domain="example.com"
echo "--- resolve ${domain} via a public DNS server ---"
host "${domain}" 9.9.9.9 || true    # 9.9.9.9 is a public resolver (Quad9)
for proto in http https ; do
  echo "--- ${proto} headers for ${domain} ---"
  curl -Iks -A "learning-curl" --location "${proto}://${domain}" || true
done
