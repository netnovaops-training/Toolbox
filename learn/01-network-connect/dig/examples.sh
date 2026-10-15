#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
# SPDX-License-Identifier: MIT
# Copyright (c) 2017 trimstray (original one-liners)
# Copyright (c) 2026 Jason A. Gibson (adaptations and comments)
# Safe, annotated dig (and host) examples for learning DNS lookups.
#
# DNS lookups are read-only and harmless. They query public resolvers about
# the placeholder domain example.com. Nothing here changes any record.

# set -euo pipefail   # -e stop on error, -u unset-var error, pipefail catch mid-pipe errors.
                      # Commented: read-and-copy menu, not a run-through script.

domain="example.com"

echo "=== 1) Resolve a name, short output (just the address) ==="
# +short strips everything except the answer value(s).
dig "${domain}" +short

echo "=== 2) Ask a SPECIFIC resolver (compare against your system default) ==="
# @9.9.9.9 = Quad9, @1.1.1.1 = Cloudflare — both public resolvers.
# If these disagree with your local one, your local cache may be stale.
dig @9.9.9.9 "${domain}" +short
dig @1.1.1.1 "${domain}" +short

echo "=== 3) Look up the name servers (who is authoritative) ==="
dig "${domain}" NS +short

echo "=== 4) Look up where email goes (MX records) ==="
dig "${domain}" MX +short

echo "=== 5) Only the Answer section (quiet, no comments/question/stats) ==="
# +noall turns everything off, +answer turns just the answer back on.
dig "${domain}" ANY +noall +answer

echo "=== 6) Reverse lookup: address -> name ==="
# -x takes an IP and asks for its PTR record. Using a public example address.
dig -x 93.184.216.34 +short || true

echo "=== 7) Full delegation trace (root servers down to the answer) ==="
# +trace shows each hop DNS takes. Great for *understanding* resolution.
# Output is long; piped to head so it stays readable in a lesson.
dig "${domain}" +trace | head -n 30

echo "=== 8) host: the simpler cousin for a quick check ==="
# host NAME SERVER resolves NAME using the given server.
host "${domain}" 9.9.9.9 || true
# -t soa asks for the Start Of Authority record (zone owner + timers).
host -t soa "${domain}" 9.9.9.9 || true
